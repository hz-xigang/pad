# hz_xg_pad

宏正西港智能标签打印 Pad 应用。

## 项目简介

基于 Flutter 开发的 Android Pad 应用，用于生产现场的标签打印和数据采集。

### 主要功能

- ✅ 用户登录认证
- ✅ 生产单信息录入
- ✅ 标签列表查询与筛选
- 🚧 PDF 标签打印（开发中）
- 🚧 标签补打与作废

## 技术栈

- **框架**: Flutter 3.10+
- **状态管理**: ChangeNotifier
- **网络请求**: Dio 5.4
- **本地存储**: Hive 2.2
- **打印**: printing + quick_usb（规划中）

## 参考项目

技术参考实现位于：`../hz_smart_service_reference/`

该目录包含完整的 PDF→TSPL→USB 打印流程实现，供本项目开发参考。**不参与编译**。

关键参考文件：
- `lib/util/tspl.dart` - TSPL 指令生成
- `lib/util/printer.dart` - USB 连接管理
- `lib/screens/webservice.dart` - 打印服务实现

## 项目结构

```
lib/
├── entity/              # 实体类
├── http/                # API 接口
├── pages/               # 页面
│   ├── home/           # 主页（标签打印）
│   ├── login/          # 登录页
│   └── tag_list/       # 标签列表
├── util/                # 工具类
│   ├── printer/        # 打印模块（开发中）
│   └── ...
└── main.dart

docs/
└── print-integration-plan.md  # PDF 打印集成计划
```

## 开发指南

### 环境要求

- Flutter SDK: ^3.10.1
- Dart SDK: ^3.10.1
- Android SDK: API 26+ (Android 8.0+)

### 安装依赖

```bash
flutter pub get
```

### 运行项目

```bash
# 连接 Android Pad 或启动模拟器
flutter run
```

### 打印功能开发

参考 [PDF 打印集成计划](docs/print-integration-plan.md) 文档。

## 页面路由

| 路由 | 页面 | 说明 |
|------|------|------|
| `/login` | 登录页 | 用户认证 |
| `/home` | 主页 | 生产单录入与打印 |
| `/tagList` | 标签列表 | 查询、补打、作废 |

## API 接口

- **Base URL**: 配置在 `lib/http/` 中
- **认证**: JWT Token（存储在 Hive）

## 许可证

Copyright © 2024 广东宏正
