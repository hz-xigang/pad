import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image/image.dart' as g_image;

import 'printer_config.dart';

/// 图像处理：缩放、格式转换、灰度化、二值化、位图打包。
///
/// 迁移自 hz_smart_service 的 tspl.dart（addWhiteBackground / convertUiImg2GImg /
/// convertImageToBW / convertBWImageToBytes），算法与阈值保持一致。
class ImageProcessor {
  ImageProcessor._();

  /// 毫米转像素（203 DPI）。例：40mm → 320px。
  static int mmToPixels(num mm) => (mm * PrinterConfig.dpiFactor).round();

  /// 将原图缩放到标签目标尺寸，并铺白色背景（避免透明区域被打成黑色）。
  ///
  /// [targetWidth] / [targetHeight] 单位为像素，可用 [mmToPixels] 计算。
  static Future<ui.Image> scaleToLabel(
    ui.Image source,
    double targetWidth,
    double targetHeight,
  ) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    // 先铺白色背景。
    canvas.drawRect(
      Rect.fromLTWH(0, 0, targetWidth, targetHeight),
      Paint()..color = Colors.white,
    );

    // 再把原图缩放绘制到目标区域。
    canvas.drawImageRect(
      source,
      Rect.fromLTWH(0, 0, source.width.toDouble(), source.height.toDouble()),
      Rect.fromLTWH(0, 0, targetWidth, targetHeight),
      Paint(),
    );

    return recorder
        .endRecording()
        .toImage(targetWidth.ceil(), targetHeight.ceil());
  }

  /// ui.Image → image 包的 Image（RGBA，4 通道）。
  static Future<g_image.Image?> convertUiImage(ui.Image image) async {
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) {
      return null;
    }
    return g_image.Image.fromBytes(
      width: image.width,
      height: image.height,
      bytes: byteData.buffer,
      numChannels: 4,
      format: g_image.Format.uint8,
    );
  }

  /// 灰度化 + 二值化：亮度 < threshold 记为黑色，否则白色。
  static g_image.Image binarize(
    g_image.Image source, {
    int threshold = PrinterConfig.binarizationThreshold,
  }) {
    final g_image.Image bwImage = g_image.grayscale(source);
    for (int y = 0; y < bwImage.height; y++) {
      for (int x = 0; x < bwImage.width; x++) {
        final pixel = bwImage.getPixel(x, y);
        final double luminance =
            0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b;

        final black = g_image.ColorInt8(4)
          ..r = 0
          ..g = 0
          ..b = 0
          ..a = 255;
        final white = g_image.ColorInt8(4)
          ..r = 255
          ..g = 255
          ..b = 255
          ..a = 255;

        bwImage.setPixel(x, y, luminance < threshold ? black : white);
      }
    }
    return bwImage;
  }

  /// 位图打包：每 8 个像素打包成 1 字节，MSB first，白色=1 黑色=0。
  /// 宽度不足 8 的倍数时右侧补白（补 1）。
  static List<int> packBitmap(g_image.Image bwImage) {
    final List<int> bytes = [];
    for (int y = 0; y < bwImage.height; y++) {
      for (int x = 0; x < bwImage.width; x += 8) {
        int value = 0;
        for (int i = 0; i < 8; i++) {
          if (x + i < bwImage.width) {
            if (bwImage.getPixel(x + i, y).r > 0) {
              value |= (1 << (7 - i));
            }
          } else {
            value |= (1 << (7 - i));
          }
        }
        bytes.add(value);
      }
    }
    return bytes;
  }
}
