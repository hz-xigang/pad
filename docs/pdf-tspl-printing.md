# PDF → TSPL → USB 标签打印技术文档

本文档描述 `hz_xg_pad` 应用内的标签打印实现：如何把后端返回的 PDF 字节流，经过光栅化、图像处理、TSPL 指令生成，最终通过 USB 发送到 TSC 热敏标签打印机。

## 1. 总体流程

```
后端接口 (PDF 字节流)
      │
      ▼
PdfRaster 光栅化 (203 DPI)  ──► List<ui.Image>
      │
      ▼
图像处理 (缩放铺白 → 灰度 → 二值化 → 位图打包)
      │
      ▼
TSPL 指令 (SIZE/GAP/DIRECTION/CLS/BITMAP/PRINT)
      │
      ▼
USB 批量传输 (quick_usb bulkTransferOut)
      │
      ▼
TSC 打印机出标签
```

核心约定：提交生产标签接口返回 **二进制 PDF 流** 表示需要打印，返回 **JSON** 表示无需打印（业务提示）。

## 2. 目录结构

打印相关代码集中在 `lib/util/printer/`：

| 文件 | 职责 |
| --- | --- |
| `printer_config.dart` | 打印机配置常量（厂商 ID、尺寸、DPI、阈值、超时） |
| `usb_printer.dart` | USB 连接管理（连接 / 断开 / 权限请求） |
| `image_processor.dart` | 图像处理（缩放、格式转换、灰度、二值化、位图打包） |
| `tspl_commands.dart` | TSPL 指令生成与发送 |
| `print_service.dart` | 打印服务编排（PDF → 图像 → 指令 → USB） |

调用入口在 `lib/pages/home/layouts/action_buttons.dart` 的 `_handlePrint`，接口在 `lib/http/ProdTagApi.dart`。

## 3. 接口约定（PDF vs JSON 分支）

`ProdTagApi.add` 以 `ResponseType.bytes` 接收响应，按内容分支：

- Content-Type 含 `pdf`，或字节以 `%PDF`（`0x25 0x50 0x44 0x46`）开头 → 需要打印；
- 其它（通常 `application/json`）→ 解析为 JSON，无需打印。

```dart
final AddTagResult result = await ProdTagApi.add(dto);
if (result.needsPrint) {
  await PrintService().printPdf(pdfBytes: result.pdfBytes!);
} else {
  // result.message：后端业务提示
}
```

`AddTagResult`：

| 成员 | 说明 |
| --- | --- |
| `pdfBytes` | 非空表示需要打印的 PDF 字节流 |
| `json` | 非空表示无需打印时的 JSON 响应 |
| `needsPrint` | `pdfBytes != null` |
| `message` | JSON 响应中的 `message`/`msg` 业务提示 |

> 注意：该接口绕过了 `ApiClient.request()` 的 JSON 信封（`ResponseDto`）逻辑，直接用 `ApiClient.instance.dio` 发请求，因为共享的 `request()` 强制把响应当 JSON 解析，无法透传二进制。鉴权沿用相同的 `Bearer <token>` 方案。

## 4. 打印管线详解

### 4.1 PDF 光栅化

`PrintService._rasterizePdf` 使用 `printing` 包的 `Printing.raster`，按 **203 DPI** 把 PDF 每一页转成 `ui.Image`：

```dart
await for (final PdfRaster raster in Printing.raster(pdfBytes, dpi: 203.0)) {
  images.add(await raster.toImage());
}
```

每一页作为一个标签处理。

### 4.2 图像处理（`ImageProcessor`）

1. **缩放铺白** `scaleToLabel`：先铺白色背景（避免透明区域被打成黑色），再把原图缩放绘制到标签目标像素尺寸。目标尺寸由 `mmToPixels(mm)` 计算。
2. **格式转换** `convertUiImage`：`ui.Image` → `image` 包的 `Image`（RGBA，4 通道）。
3. **二值化** `binarize`：灰度化后按亮度阈值判定，`0.299R + 0.587G + 0.114B < 128` 记为黑，否则白。
4. **位图打包** `packBitmap`：每 8 个像素打包成 1 字节，MSB first，**白色=1 黑色=0**；宽度不足 8 的倍数时右侧补白（补 1）。

### 4.3 单位换算

- 毫米转像素：`mmToPixels(mm) = round(mm × 7.992)`，其中 `7.992 = 203 DPI ÷ 25.4 mm/inch`。
- 例：40mm → 320px，30mm → 240px。
- 位图行字节数：`widthBytes = (width + 7) ~/ 8`。

## 5. TSPL 指令（`TsplCommands`）

所有指令以 **GBK 编码**（`gbk_bytes.encode`）、`\r\n` 结尾，经 `bulkTransferOut` 发送。

| 方法 | 生成指令 | 说明 |
| --- | --- | --- |
| `init` | `SIZE w mm, h mm` + `GAP g mm,0` + `DIRECTION d` + `CLS` | 初始化标签尺寸、间隙、方向并清缓存 |
| `bitmap` | `BITMAP x,y,widthBytes,height,0,<二进制>` | 发送位图数据，后接 `\r\n` |
| `print` | `PRINT 1,qty` + `END` + `CLS` | 执行打印 qty 份 |
| `status` | `0x1B 0x21 0x3F`（`<ESC>!?`） | 实时状态查询，读 1 字节 |

单张标签发送顺序：`init` → `bitmap` → `print`。

### 5.1 状态码解析（`decodeStatus`）

`0x00` 表示正常（返回 `'1'`）；否则按位组合中文错误：

| 位 | 含义 |
| --- | --- |
| `0x01` | 打印头未关闭 |
| `0x02` | 卡纸 |
| `0x04` | 缺纸 |
| `0x08` | 缺碳带 |
| `0x10` | 打印机暂停 |
| `0x20` | 打印正忙 |
| `0x80` | 其他错误 |

> **就绪判定**：状态查询读不到数据（空响应或超时）视为 **就绪 `'1'`**，与参考实现一致。不能把空响应当作 `-1` 去解析状态位，否则会命中所有错误位造成误报。

## 6. USB 连接（`UsbPrinterManager`）

基于 `quick_usb`：

1. `QuickUsb.init()` → `getDeviceList()`，按 `vendorId` 匹配打印机（TSC = `5031`）。
2. 权限：`hasPermission` 不通过则 `requestPermission`，最多重试 2 次，每次间隔 600ms（Android 每次插拔需重新授权）。
3. `openDevice` → `getConfiguration(0)` → `claimInterface`，取 `DIRECTION_OUT` / `DIRECTION_IN` 两个 endpoint。
4. 断开：`releaseInterface` → `closeDevice` → `exit`，异常吞掉保证幂等。

`PrintService.printImages` 用 `try/finally` 保证无论成功失败都会断开连接。

## 7. 关键配置（`PrinterConfig`）

| 常量 | 默认值 | 说明 |
| --- | --- | --- |
| `tscVendorId` | `'5031'` | TSC 打印机 vendorId |
| `zebraVendorId` | `'2655'` | Zebra vendorId（暂未启用） |
| `defaultWidthMm` / `defaultHeightMm` | `40` / `30` | 默认标签尺寸 |
| `defaultGapMm` | `2` | 标签间隙 |
| `defaultDirection` | `0` | 打印方向（0/1/2/3 = 0/90/180/270°） |
| `binarizationThreshold` | `128` | 二值化阈值（0-255） |
| `dpi` | `203` | 打印分辨率 |
| `dpiFactor` | `7.992` | 毫米转像素系数 |
| `permissionRetryDelay` | `600ms` | 权限请求重试间隔 |
| `statusReadTimeout` | `2s` | 状态读取超时 |

## 8. 已知问题与排查

### 8.1 `IllegalArgumentException: Requested element count -1 is less than zero`

**现象**：打印时崩溃，打印机红灯。

**原因**：`quick_usb` 原生层 `bulkTransferIn` 在读超时/失败时 `bulkTransfer` 返回 `-1`，代码直接 `buffer.take(-1)` 抛异常。状态查询 `<ESC>!?` 打印机不立即回数据时必现。

**修复**：`QuickUsbPlugin.kt` 中对负数长度做保护，视为空数据返回：

```kotlin
result.success(buffer.take(if (actualLength < 0) 0 else actualLength))
```

> 该插件为本地 vendored 插件（`plugins/quick_usb/`），改动 Kotlin 后需 **完整重装**（`flutter run`），热重载不生效。

### 8.2 打印机红灯 / 出白纸 / 内容偏移

多为物理或配置问题，排查方向：

- **标签尺寸不匹配**：`printPdf` 的 `widthMm/heightMm` 需与实际标签及后端 PDF 页面尺寸一致。
- **间隙检测**：GAP 值与实际标签间隙不符会导致定位错误。
- **方向**：内容旋转 90/180/270° 时调整 `direction`。
- **打印份数**：`printPdf` 默认 `quantity: 1`（每页打 1 份），假设后端已按提交的 `qty` 生成对应页数；若后端返回单页需复制多份，应传入对应 `quantity`。

## 9. 相关文件索引

- 配置：`lib/util/printer/printer_config.dart`
- USB：`lib/util/printer/usb_printer.dart`
- 图像：`lib/util/printer/image_processor.dart`
- 指令：`lib/util/printer/tspl_commands.dart`
- 服务：`lib/util/printer/print_service.dart`
- 接口：`lib/http/ProdTagApi.dart`
- 入口：`lib/pages/home/layouts/action_buttons.dart`
- 原生插件：`plugins/quick_usb/android/src/main/kotlin/com/example/quick_usb/QuickUsbPlugin.kt`
- 集成计划：`docs/print-integration-plan.md`

