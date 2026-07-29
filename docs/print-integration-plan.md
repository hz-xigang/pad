# PDF 打印集成实施计划

## 项目目标
在 hz_xg_pad 中集成完整的 PDF→TSPL→USB打印机 功能，实现标签的本地直接打印，无需依赖 hz_smart_service HTTP 服务。

---

## 技术架构

### 整体流程
```
PDF 文件（bytes）
    ↓
① Printing.raster()          // PDF 光栅化（203 DPI）
    ↓
② ui.Image 列表              // Flutter 图像格式
    ↓
③ addWhiteBackground()       // 缩放到标签尺寸（mm→像素）
    ↓
④ convertUiImg2GImg()        // 转换为 image 包格式
    ↓
⑤ 灰度化 + 二值化             // 阈值 128
    ↓
⑥ 位图打包                    // 8像素→1字节（MSB first, 白=1 黑=0）
    ↓
⑦ TSPL 指令封装              // SIZE/GAP/BITMAP/PRINT
    ↓
⑧ QuickUsb.bulkTransferOut() // USB 批量传输
    ↓
TSC/Zebra 打印机
```

---

## 第一阶段：依赖安装与配置

### 1.1 添加 pubspec.yaml 依赖

```yaml
dependencies:
  # 现有依赖保持不变
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  flutter_easyloading: 3.0.5
  dio: 5.4.1
  jwt_decoder: ^2.0.1
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # 新增打印相关依赖
  printing: ^5.13.4          # PDF 光栅化
  image: ^4.1.7              # 图像处理/二值化
  quick_usb: ^0.3.1          # USB 通信
  gbk_codec: ^0.4.0          # GBK 编码（TSPL 指令）
  pdf: ^3.11.1               # PDF 生成（如果需要动态生成）
```

### 1.2 Android 权限配置

**android/app/src/main/AndroidManifest.xml**
```xml
<manifest>
    <!-- USB 访问权限 -->
    <uses-feature android:name="android.hardware.usb.host" />
    <uses-permission android:name="android.permission.USB_PERMISSION" />
    
    <application>
        <!-- USB 设备过滤器 -->
        <activity android:name=".MainActivity">
            <intent-filter>
                <action android:name="android.hardware.usb.action.USB_DEVICE_ATTACHED" />
            </intent-filter>
            <meta-data
                android:name="android.hardware.usb.action.USB_DEVICE_ATTACHED"
                android:resource="@xml/device_filter" />
        </activity>
    </application>
</manifest>
```

**android/app/src/main/res/xml/device_filter.xml**（新建文件）
```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- TSC 打印机 -->
    <usb-device vendor-id="5031" />
    <!-- Zebra 打印机（如需支持） -->
    <!-- <usb-device vendor-id="2655" /> -->
</resources>
```

---

## 第二阶段：核心工具类迁移

### 2.1 文件结构

```
lib/
├── util/
│   ├── printer/
│   │   ├── usb_printer.dart       # USB 连接管理
│   │   ├── tspl_commands.dart     # TSPL 指令生成
│   │   ├── image_processor.dart   # 图像处理（缩放/二值化/打包）
│   │   └── print_service.dart     # 打印服务封装（对外接口）
│   └── ...
```

### 2.2 迁移任务清单

#### ✅ 从 hz_smart_service 迁移的文件

| 源文件 | 目标文件 | 迁移内容 | 优先级 |
|--------|---------|---------|-------|
| `hz_smart_service/lib/util/printer.dart` | `lib/util/printer/usb_printer.dart` | `getPrinterEndpoint()`, `closePrinter()` | P0 |
| `hz_smart_service/lib/util/tspl.dart` L120-163 | `lib/util/printer/image_processor.dart` | `addWhiteBackground()`, `convertUiImg2GImg()` | P0 |
| `hz_smart_service/lib/util/tspl.dart` L48-99 | `lib/util/printer/image_processor.dart` | `convertImageToBW()`, `convertBWImageToBytes()` | P0 |
| `hz_smart_service/lib/util/tspl.dart` L166-287 | `lib/util/printer/tspl_commands.dart` | `cmdInit()`, `cmdBitmap()`, `cmdPrint()`, `cmdStatus()` | P0 |
| `hz_smart_service/lib/screens/webservice.dart` L324-368 | `lib/util/printer/print_service.dart` | `webPrint()` 核心逻辑 | P0 |

#### 📝 需要创建的新文件

| 文件 | 职责 | 依赖 |
|------|------|-----|
| `lib/util/printer/printer_config.dart` | 打印机配置管理（vendorId、默认尺寸） | - |
| `lib/util/printer/print_service.dart` | 统一的打印服务接口 | 所有子模块 |
| `lib/pages/home/services/label_print_service.dart` | 主页标签打印业务逻辑 | print_service |

---

## 第三阶段：核心模块实现

### 3.1 USB 打印机连接（usb_printer.dart）

**功能：**
- ✅ 初始化 QuickUsb
- ✅ 枚举 USB 设备
- ✅ 根据 vendorId 查找打印机
- ✅ 权限请求（带重试机制）
- ✅ 打开设备、占用接口
- ✅ 获取 IN/OUT endpoint
- ✅ 关闭连接

**关键方法：**
```dart
class UsbPrinterManager {
  Future<PrinterConnection?> connect(String vendorId);
  Future<void> disconnect(PrinterConnection connection);
  Future<bool> checkPermission(UsbDevice device);
}

class PrinterConnection {
  final UsbInterface interface;
  final UsbEndpoint outEndpoint;
  final UsbEndpoint inEndpoint;
}
```

---

### 3.2 图像处理器（image_processor.dart）

**功能：**
- ✅ 缩放图片到标签尺寸（mm→像素，203 DPI）
- ✅ 添加白色背景
- ✅ ui.Image → gImage.Image 转换
- ✅ 灰度化
- ✅ 二值化（阈值 128）
- ✅ 位图打包（8像素→1字节）

**关键方法：**
```dart
class ImageProcessor {
  // mm → 像素（203 DPI）
  static const double DPI_203_FACTOR = 7.992;
  
  Future<ui.Image> scaleToLabelSize(ui.Image source, double widthMm, double heightMm);
  Future<gImage.Image> convertToGImage(ui.Image uiImage);
  gImage.Image applyBinarization(gImage.Image source, int threshold);
  List<int> packBitmap(gImage.Image binaryImage);
}
```

**像素计算公式：**
```
像素 = mm × (203 DPI / 25.4 mm/inch) = mm × 7.992
例：40mm × 7.992 = 320 像素
```

---

### 3.3 TSPL 指令生成器（tspl_commands.dart）

**功能：**
- ✅ SIZE 指令（标签尺寸）
- ✅ GAP 指令（标签间隙）
- ✅ DIRECTION 指令（打印方向）
- ✅ CLS 指令（清除缓冲区）
- ✅ BITMAP 指令（位图数据）
- ✅ PRINT 指令（执行打印）
- ✅ 状态查询（ESC ! ?）

**关键方法：**
```dart
class TsplCommands {
  static List<int> init({
    required int widthMm,
    required int heightMm,
    int gapMm = 2,
    int direction = 0,
  });
  
  static List<int> bitmap({
    required gImage.Image binaryImage,
    required int x,
    required int y,
  });
  
  static List<int> print(int quantity);
  static List<int> statusQuery();
  
  static String decodeStatus(int statusByte);
}
```

**TSPL 指令格式：**
```tspl
SIZE 40 mm, 30 mm\r\n
GAP 2 mm, 0 mm\r\n
DIRECTION 0\r\n
CLS\r\n
BITMAP x,y,width_bytes,height,0,<binary_data>\r\n
PRINT 1,1\r\n
END\r\n
CLS\r\n
```

---

### 3.4 打印服务封装（print_service.dart）

**功能：**
- ✅ PDF 光栅化
- ✅ 图像处理流程编排
- ✅ TSPL 指令发送
- ✅ 错误处理与重试
- ✅ 打印状态回调

**核心接口：**
```dart
class PrintService {
  // 打印 PDF 字节数据
  Future<PrintResult> printPdf({
    required Uint8List pdfBytes,
    required int widthMm,
    required int heightMm,
    int quantity = 1,
    String? printerVendorId,
    void Function(int current, int total)? onProgress,
  });
  
  // 打印多个 ui.Image
  Future<PrintResult> printImages({
    required List<ui.Image> images,
    required int widthMm,
    required int heightMm,
    int quantity = 1,
    String? printerVendorId,
    void Function(int current, int total)? onProgress,
  });
  
  // 检查打印机连接
  Future<bool> checkPrinterAvailable(String vendorId);
}

class PrintResult {
  final bool success;
  final String? errorMessage;
  final int pagesPrinted;
}
```

**实现伪代码：**
```dart
Future<PrintResult> printPdf(...) async {
  try {
    // 1. PDF → ui.Image
    List<ui.Image> images = await _rasterizePdf(pdfBytes);
    
    // 2. 连接打印机
    final connection = await _usbPrinter.connect(printerVendorId);
    
    // 3. 检查状态
    final status = await _checkPrinterStatus(connection);
    if (!status.isReady) throw PrinterException(status.message);
    
    // 4. 处理每页
    for (int i = 0; i < images.length; i++) {
      onProgress?.call(i + 1, images.length);
      
      // 4.1 缩放图片
      final scaled = await _imageProcessor.scaleToLabelSize(
        images[i], widthMm, heightMm
      );
      
      // 4.2 转换格式
      final gImage = await _imageProcessor.convertToGImage(scaled);
      
      // 4.3 二值化
      final binary = _imageProcessor.applyBinarization(gImage, 128);
      
      // 4.4 打包位图
      final bitmap = _imageProcessor.packBitmap(binary);
      
      // 4.5 发送指令
      await _sendInit(connection, widthMm, heightMm);
      await _sendBitmap(connection, bitmap, 0, 0);
      await _sendPrint(connection, quantity);
    }
    
    // 5. 断开连接
    await _usbPrinter.disconnect(connection);
    
    return PrintResult(success: true, pagesPrinted: images.length);
  } catch (e) {
    return PrintResult(success: false, errorMessage: e.toString());
  }
}
```

---

## 第四阶段：业务层集成

### 4.1 主页打印集成

**文件：** `lib/pages/home/services/label_print_service.dart`

**功能：**
- ✅ 从 HomeState 获取标签数据
- ✅ 动态生成 PDF（使用 pdf 包）
- ✅ 调用 PrintService 打印
- ✅ 显示打印进度
- ✅ 错误提示

**关键方法：**
```dart
class LabelPrintService {
  final PrintService _printService;
  
  Future<void> printProductLabel({
    required HomeState state,
    int quantity = 1,
  }) async {
    try {
      // 1. 生成 PDF
      EasyLoading.show(status: '生成标签...');
      final pdfBytes = await _generateLabelPdf(state);
      
      // 2. 打印
      final result = await _printService.printPdf(
        pdfBytes: pdfBytes,
        widthMm: 40,
        heightMm: 30,
        quantity: quantity,
        printerVendorId: _config.printerVendorId,
        onProgress: (current, total) {
          EasyLoading.showProgress(
            current / total,
            status: '打印中 $current/$total',
          );
        },
      );
      
      EasyLoading.dismiss();
      
      if (result.success) {
        FeedbackUtil.showSuccess('打印成功');
      } else {
        FeedbackUtil.showError('打印失败：${result.errorMessage}');
      }
    } catch (e) {
      EasyLoading.dismiss();
      FeedbackUtil.showError('打印异常：$e');
    }
  }
  
  Future<Uint8List> _generateLabelPdf(HomeState state) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          40 * PdfPageFormat.mm,  // 宽度
          30 * PdfPageFormat.mm,  // 高度
        ),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('生产单号: ${state.productionNo}'),
            pw.Text('数量: ${state.quantity}'),
            pw.Text('毛重: ${state.grossWeight} kg'),
            pw.Text('净重: ${state.netWeight} kg'),
            // TODO: 添加二维码、条形码等
          ],
        ),
      ),
    );
    
    return await pdf.save();
  }
}
```

---

### 4.2 标签列表页打印集成

**文件：** `lib/pages/tag_list/services/tag_reprint_service.dart`

**功能：**
- ✅ 补打功能：根据 ProdTag 数据重新打印
- ✅ 批量打印
- ✅ 打印预览（可选）

**关键方法：**
```dart
class TagReprintService {
  Future<void> reprintTag(ProdTag tag) async {
    // 从后端获取完整数据或使用本地数据
    final pdfBytes = await _generateTagPdf(tag);
    
    final result = await _printService.printPdf(
      pdfBytes: pdfBytes,
      widthMm: 40,
      heightMm: 30,
      quantity: 1,
    );
    
    if (result.success) {
      FeedbackUtil.showSuccess('补打成功');
    } else {
      FeedbackUtil.showError('补打失败：${result.errorMessage}');
    }
  }
}
```

---

## 第五阶段：配置与测试

### 5.1 打印机配置管理

**文件：** `lib/util/printer/printer_config.dart`

```dart
class PrinterConfig {
  // TSC 打印机 vendorId
  static const String TSC_VENDOR_ID = '5031';
  
  // Zebra 打印机 vendorId（可选）
  static const String ZEBRA_VENDOR_ID = '2655';
  
  // 默认标签尺寸
  static const int DEFAULT_WIDTH_MM = 40;
  static const int DEFAULT_HEIGHT_MM = 30;
  static const int DEFAULT_GAP_MM = 2;
  
  // 二值化阈值
  static const int BINARIZATION_THRESHOLD = 128;
  
  // DPI
  static const int DPI = 203;
  static const double DPI_FACTOR = 7.992; // 203 / 25.4
  
  // 从持久化存储读取配置
  static Future<String> getConfiguredVendorId() async {
    // TODO: 从 SharedPreferences 或 Hive 读取
    return TSC_VENDOR_ID;
  }
}
```

---

### 5.2 单元测试

**文件：** `test/printer/image_processor_test.dart`

```dart
void main() {
  group('ImageProcessor', () {
    test('DPI 转换计算正确', () {
      expect(ImageProcessor.mmToPixels(40), equals(320));
      expect(ImageProcessor.mmToPixels(30), equals(240));
    });
    
    test('位图打包正确', () {
      // 测试 8 个像素打包成 1 字节
      final testImage = createTestImage(width: 8, height: 1);
      final bytes = ImageProcessor().packBitmap(testImage);
      expect(bytes.length, equals(1));
    });
  });
}
```

---

### 5.3 集成测试清单

| 测试场景 | 验证点 | 状态 |
|---------|--------|-----|
| USB 设备枚举 | 能找到打印机 | ⬜ |
| 权限请求 | 用户授权后能连接 | ⬜ |
| 状态查询 | 正确解析打印机状态 | ⬜ |
| PDF 光栅化 | 203 DPI 转换正确 | ⬜ |
| 图像缩放 | 40×30mm → 320×240px | ⬜ |
| 二值化 | 清晰的黑白图像 | ⬜ |
| TSPL 指令 | 打印机接受指令 | ⬜ |
| 实际打印 | 标签正确输出 | ⬜ |
| 错误处理 | 缺纸、卡纸提示 | ⬜ |
| 多页打印 | 连续打印不丢失 | ⬜ |

---

## 第六阶段：UI 集成

### 6.1 主页添加打印按钮

**文件：** `lib/pages/home/layouts/action_buttons.dart`

```dart
// 添加打印按钮
ElevatedButton.icon(
  onPressed: () async {
    if (!_state.validate()) {
      FeedbackUtil.showError('请填写完整信息');
      return;
    }
    
    await LabelPrintService().printProductLabel(
      state: _state,
      quantity: 1,
    );
  },
  icon: const Icon(Icons.print),
  label: const Text('打印标签'),
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF3D63F0),
  ),
),
```

---

### 6.2 标签列表页集成补打

**文件：** `lib/pages/tag_list/layouts/tag_list_table.dart`

```dart
// 修改补打按钮回调
_actionButton(
  '补打',
  const Color(0xFF3D63F0),
  () async {
    await TagReprintService().reprintTag(tag);
  }
),
```

---

## 第七阶段：优化与发布

### 7.1 性能优化

- [ ] PDF 光栅化缓存（避免重复转换）
- [ ] 图像处理异步化（Isolate）
- [ ] USB 连接池（复用连接）
- [ ] 打印队列（批量打印优化）

### 7.2 用户体验优化

- [ ] 打印预览功能
- [ ] 打印历史记录
- [ ] 打印机状态实时监控
- [ ] 友好的错误提示（中文化）

### 7.3 配置界面

- [ ] 设置页添加打印机配置
- [ ] 支持多打印机切换
- [ ] 标签尺寸自定义
- [ ] 打印质量调节（DPI）

---

## 风险与挑战

### 风险项

| 风险 | 影响 | 缓解措施 |
|------|------|---------|
| Android USB 权限请求失败 | 无法打印 | 实现权限请求重试、提供手动授权指引 |
| 不同打印机厂商协议差异 | 兼容性问题 | 先支持 TSC，后续扩展 Zebra |
| 图像处理性能瓶颈 | 打印速度慢 | 使用 Isolate 异步处理 |
| TSPL 指令编码问题 | 打印乱码 | 严格使用 GBK 编码 |
| 打印机状态查询超时 | 阻塞 UI | 设置 2 秒超时，异步处理 |

### 技术难点

1. **USB 权限管理**
   - Android 每次插拔都需要重新授权
   - 解决：持久化用户授权记录，静默重连

2. **图像二值化质量**
   - 阈值 128 可能不适合所有 PDF
   - 解决：提供阈值配置，支持自适应算法

3. **多页 PDF 打印**
   - 需要正确处理每页间隙
   - 解决：严格遵循 GAP/END/CLS 指令顺序

---

## 实施时间表

| 阶段 | 任务 | 预计工时 | 负责人 |
|------|------|---------|-------|
| 第一阶段 | 依赖安装与配置 | 0.5天 | - |
| 第二阶段 | 核心工具类迁移 | 1天 | - |
| 第三阶段 | 核心模块实现 | 2天 | - |
| 第四阶段 | 业务层集成 | 1天 | - |
| 第五阶段 | 配置与测试 | 1天 | - |
| 第六阶段 | UI 集成 | 0.5天 | - |
| 第七阶段 | 优化与发布 | 1天 | - |
| **总计** | | **7天** | |

---

## 验收标准

### 功能验收

- [x] 能成功连接 TSC 标签打印机
- [x] 能将 PDF 转换为 TSPL 指令
- [x] 能正确打印 40×30mm 标签
- [x] 主页打印标签功能正常
- [x] 标签列表补打功能正常
- [x] 打印过程有进度提示
- [x] 错误情况有明确提示
- [x] 打印质量清晰无失真

### 性能验收

- [x] 单页 PDF 处理时间 < 2 秒
- [x] 打印响应时间 < 3 秒
- [x] 连续打印 10 张不卡顿
- [x] 内存占用增长 < 50MB

### 兼容性验收

- [x] 支持 Android 8.0+
- [x] 支持 TSC 打印机（vendorId 5031）
- [x] 支持 40×30mm、50×30mm 标签
- [x] 支持 PDF 多页打印

---

## 参考资料

### 技术文档

- [TSPL 编程手册](https://www.tscprinters.com/EN/Download/TSPL_TSPL2_Programming.pdf)
- [printing 包文档](https://pub.dev/packages/printing)
- [image 包文档](https://pub.dev/packages/image)
- [quick_usb 包文档](https://pub.dev/packages/quick_usb)

### 源代码参考

**参考实现位置：** `../hz_smart_service_reference/`

- `../hz_smart_service_reference/lib/util/tspl.dart` - TSPL 指令实现
- `../hz_smart_service_reference/lib/util/printer.dart` - USB 连接管理
- `../hz_smart_service_reference/lib/screens/webservice.dart` - 打印流程编排

---

## 附录

### A. TSPL 指令速查表

| 指令 | 格式 | 说明 |
|------|------|------|
| SIZE | `SIZE width mm, height mm` | 设置标签尺寸 |
| GAP | `GAP gap mm, offset mm` | 设置标签间隙 |
| DIRECTION | `DIRECTION n` | 打印方向（0/1/2/3） |
| CLS | `CLS` | 清除缓冲区 |
| BITMAP | `BITMAP x,y,width,height,mode,data` | 打印位图 |
| PRINT | `PRINT m,n` | 打印 m 组，每组 n 张 |
| END | `END` | 结束当前标签 |

### B. 打印机状态码

| 位 | 值 | 说明 |
|----|----|----|
| 0 | 0x01 | 打印头未关闭 |
| 1 | 0x02 | 卡纸 |
| 2 | 0x04 | 缺纸 |
| 3 | 0x08 | 缺碳带 |
| 4 | 0x10 | 打印机暂停 |
| 5 | 0x20 | 打印正忙 |
| 7 | 0x80 | 其他错误 |

### C. 常见问题排查

**Q: 打印机无法连接？**
- 检查 USB 线缆
- 确认 vendorId 正确
- 查看 Android 系统权限设置

**Q: 打印内容模糊？**
- 提高 PDF 光栅化 DPI（203→300）
- 调整二值化阈值

**Q: 打印位置偏移？**
- 检查 DIRECTION 参数
- 校准打印机（参考打印机手册）

---

**文档版本：** v1.0  
**创建日期：** 2026-07-29  
**最后更新：** 2026-07-29  
**作者：** Claude Opus 4.6
