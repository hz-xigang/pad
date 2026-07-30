import 'package:quick_usb/quick_usb.dart';

import 'printer_config.dart';

/// 已建立的打印机连接，持有接口与收发 endpoint。
class PrinterConnection {
  PrinterConnection({
    required this.interface,
    required this.outEndpoint,
    required this.inEndpoint,
  });

  /// 已占用的 USB 接口，断开时需要 releaseInterface。
  final UsbInterface interface;

  /// 数据输出 endpoint（发送 TSPL 指令）。
  final UsbEndpoint outEndpoint;

  /// 数据输入 endpoint（读取打印机状态）。
  final UsbEndpoint inEndpoint;
}

/// 连接打印机时抛出的异常，message 为面向用户的中文提示。
class PrinterConnectException implements Exception {
  PrinterConnectException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// USB 打印机连接管理。
///
/// 迁移自 hz_smart_service 的 printer.dart（getPrinterEndpoint / closePrinter），
/// 保留了权限请求的两次重试逻辑（每次间隔 600ms）。
class UsbPrinterManager {
  /// 连接指定 vendorId 的打印机，成功返回 [PrinterConnection]。
  ///
  /// 失败时抛出 [PrinterConnectException]，message 可直接展示给用户。
  Future<PrinterConnection> connect(String vendorId) async {
    await QuickUsb.init();

    final List<UsbDevice> devices = await QuickUsb.getDeviceList();
    if (devices.isEmpty) {
      throw PrinterConnectException('没有 USB 设备');
    }

    UsbDevice? printer;
    for (final UsbDevice device in devices) {
      if (device.vendorId.toString() == vendorId) {
        printer = device;
        break;
      }
    }
    if (printer == null) {
      throw PrinterConnectException('没有连接打印机');
    }

    await _ensurePermission(printer);

    await QuickUsb.openDevice(printer);
    final UsbConfiguration config = await QuickUsb.getConfiguration(0);
    if (config.interfaces.isEmpty) {
      await QuickUsb.closeDevice();
      throw PrinterConnectException('打印机接口为空');
    }

    final UsbInterface interface = config.interfaces[0];
    await QuickUsb.claimInterface(interface);

    return PrinterConnection(
      interface: interface,
      outEndpoint: interface.endpoints
          .firstWhere((e) => e.direction == UsbEndpoint.DIRECTION_OUT),
      inEndpoint: interface.endpoints
          .firstWhere((e) => e.direction == UsbEndpoint.DIRECTION_IN),
    );
  }

  /// 断开连接：释放接口 → 关闭设备 → 退出 QuickUsb。异常被吞掉，保证幂等。
  Future<void> disconnect(PrinterConnection connection) async {
    try {
      await QuickUsb.releaseInterface(connection.interface);
      await QuickUsb.closeDevice();
      await QuickUsb.exit();
    } catch (_) {}
  }

  /// 请求 USB 权限，Android 每次插拔都需重新授权，最多重试两次。
  Future<void> _ensurePermission(UsbDevice device) async {
    if (await QuickUsb.hasPermission(device)) {
      return;
    }
    for (int attempt = 0; attempt < 2; attempt++) {
      await QuickUsb.requestPermission(device);
      await Future.delayed(PrinterConfig.permissionRetryDelay);
      if (await QuickUsb.hasPermission(device)) {
        return;
      }
    }
    throw PrinterConnectException('请允许访问 USB 打印机');
  }
}
