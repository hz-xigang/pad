import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:image/image.dart' as g_image;
import 'package:printing/printing.dart';

import 'image_processor.dart';
import 'printer_config.dart';
import 'tspl_commands.dart';
import 'usb_printer.dart';

/// 打印结果。
class PrintResult {
  PrintResult({
    required this.success,
    this.errorMessage,
    this.pagesPrinted = 0,
  });

  final bool success;
  final String? errorMessage;
  final int pagesPrinted;

  factory PrintResult.ok(int pages) =>
      PrintResult(success: true, pagesPrinted: pages);

  factory PrintResult.fail(String message) =>
      PrintResult(success: false, errorMessage: message);
}

/// 打印服务：编排 PDF 光栅化 → 图像处理 → TSPL 指令 → USB 发送。
///
/// 迁移自 hz_smart_service 的 webservice.dart webPrint() 逻辑。
class PrintService {
  PrintService({UsbPrinterManager? usbManager})
      : _usbManager = usbManager ?? UsbPrinterManager();

  final UsbPrinterManager _usbManager;

  /// 打印 PDF 字节数据。
  Future<PrintResult> printPdf({
    required Uint8List pdfBytes,
    int widthMm = PrinterConfig.defaultWidthMm,
    int heightMm = PrinterConfig.defaultHeightMm,
    int quantity = 1,
    String? printerVendorId,
    void Function(int current, int total)? onProgress,
  }) async {
    final List<ui.Image> images = await _rasterizePdf(pdfBytes);
    return printImages(
      images: images,
      widthMm: widthMm,
      heightMm: heightMm,
      quantity: quantity,
      printerVendorId: printerVendorId,
      onProgress: onProgress,
    );
  }

  /// 打印一组 ui.Image（每张作为一个标签）。
  Future<PrintResult> printImages({
    required List<ui.Image> images,
    int widthMm = PrinterConfig.defaultWidthMm,
    int heightMm = PrinterConfig.defaultHeightMm,
    int quantity = 1,
    String? printerVendorId,
    void Function(int current, int total)? onProgress,
  }) async {
    if (images.isEmpty) {
      return PrintResult.fail('没有可打印的内容');
    }

    PrinterConnection? connection;
    try {
      connection = await _usbManager.connect(
        printerVendorId ?? PrinterConfig.tscVendorId,
      );

      final tspl = TsplCommands(connection);

      final String status = await tspl.status();
      if (status != '1') {
        return PrintResult.fail(status);
      }

      final double targetWidth = ImageProcessor.mmToPixels(widthMm).toDouble();
      final double targetHeight =
          ImageProcessor.mmToPixels(heightMm).toDouble();

      for (int i = 0; i < images.length; i++) {
        onProgress?.call(i + 1, images.length);

        final ui.Image scaled = await ImageProcessor.scaleToLabel(
          images[i],
          targetWidth,
          targetHeight,
        );
        final g_image.Image? gimg = await ImageProcessor.convertUiImage(scaled);

        await tspl.init(widthMm: widthMm, heightMm: heightMm);
        await tspl.bitmap(gimg);
        await tspl.print(quantity);
      }

      return PrintResult.ok(images.length);
    } on PrinterConnectException catch (e) {
      return PrintResult.fail('连接打印机出错，${e.message}');
    } catch (e) {
      return PrintResult.fail('打印异常：$e');
    } finally {
      if (connection != null) {
        await _usbManager.disconnect(connection);
      }
    }
  }

  /// 检查打印机是否可连接（连接后立即断开）。
  Future<bool> checkPrinterAvailable(String vendorId) async {
    try {
      final connection = await _usbManager.connect(vendorId);
      await _usbManager.disconnect(connection);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// PDF 光栅化为 ui.Image 列表（203 DPI）。
  Future<List<ui.Image>> _rasterizePdf(Uint8List pdfBytes) async {
    final List<ui.Image> images = [];
    await for (final PdfRaster raster in Printing.raster(
      pdfBytes,
      dpi: PrinterConfig.dpi.toDouble(),
    )) {
      images.add(await raster.toImage());
    }
    return images;
  }
}
