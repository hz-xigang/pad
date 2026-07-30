/// 打印机配置常量。
///
/// 集中管理打印机厂商、标签尺寸、DPI、二值化阈值等参数，
/// 迁移自 hz_smart_service 的散落配置（globals.printerVendorId 等）。
class PrinterConfig {
  PrinterConfig._();

  /// TSC 标签打印机 vendorId。
  static const String tscVendorId = '4611';

  /// Zebra 打印机 vendorId（可选，暂未启用）。
  static const String zebraVendorId = '2655';

  /// 默认标签尺寸（毫米）。
  static const int defaultWidthMm = 90;
  static const int defaultHeightMm = 75;

  /// 默认标签间隙（毫米）。
  static const int defaultGapMm = 2;

  /// 默认打印方向（0=正常，1/2/3=旋转 90/180/270 度）。
  static const int defaultDirection = 0;

  /// 二值化阈值（0-255），128 适合大多数场景。
  static const int binarizationThreshold = 128;

  /// 打印分辨率。
  static const int dpi = 203;

  /// 毫米转像素系数：203 DPI ÷ 25.4 mm/inch ≈ 7.992 像素/mm。
  static const double dpiFactor = 7.992;

  /// USB 权限请求的重试间隔。
  static const Duration permissionRetryDelay = Duration(milliseconds: 600);

  /// 状态查询读取超时。
  static const Duration statusReadTimeout = Duration(seconds: 2);
}
