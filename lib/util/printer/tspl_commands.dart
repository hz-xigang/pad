import 'dart:typed_data';

import 'package:gbk_codec/gbk_codec.dart';
import 'package:image/image.dart' as g_image;
import 'package:quick_usb/quick_usb.dart';

import 'image_processor.dart';
import 'printer_config.dart';
import 'usb_printer.dart';

/// TSPL 指令生成与发送。
///
/// 迁移自 hz_smart_service 的 tspl.dart（cmdInit / cmdBitmap / cmdPrint /
/// cmdStatus / getStatusMessage）。所有指令以 GBK 编码、`\r\n` 结尾。
class TsplCommands {
  TsplCommands(this.connection);

  final PrinterConnection connection;

  UsbEndpoint get _out => connection.outEndpoint;
  UsbEndpoint get _in => connection.inEndpoint;

  /// 初始化：SIZE + （可选 GAP）+ DIRECTION + CLS。
  Future<int> init({
    required int widthMm,
    required int heightMm,
    int? gapMm = PrinterConfig.defaultGapMm,
    int direction = PrinterConfig.defaultDirection,
  }) async {
    final String command = gapMm == null
        ? 'SIZE $widthMm mm, $heightMm mm \r\n DIRECTION $direction \r\n CLS \r\n '
        : 'SIZE $widthMm mm, $heightMm mm \r\n GAP $gapMm mm,0 \r\n DIRECTION $direction \r\n CLS \r\n ';
    return _sendString(command);
  }

  /// 位图指令：`BITMAP x,y,width_bytes,height,0,<binary>`。
  /// 内部完成灰度化、二值化（阈值 128）、位图打包。
  Future<void> bitmap(g_image.Image? image, {int x = 0, int y = 0}) async {
    if (image == null) {
      return;
    }
    final g_image.Image bwImage = ImageProcessor.binarize(image);
    final List<int> bitmapBytes = ImageProcessor.packBitmap(bwImage);
    final int widthBytes = (bwImage.width + 7) ~/ 8;

    await _sendString('BITMAP $x,$y,$widthBytes,${bwImage.height},0,');
    await QuickUsb.bulkTransferOut(_out, Uint8List.fromList(bitmapBytes));
    await _sendString('\r\n');
  }

  /// 执行打印：PRINT 1,qty + END + CLS。
  Future<int> print(int qty) {
    return _sendString('PRINT 1,$qty \r\n END \r\n CLS \r\n');
  }

  /// 查询打印机状态，返回 '1' 表示正常，其它为中文错误描述。
  Future<String> status() async {
    final int ret = await QuickUsb.bulkTransferOut(
      _out,
      Uint8List.fromList([0x1B, 0x21, 0x3F]),
    );
    if (ret < 0) {
      return '发送查询指令失败，错误码：$ret';
    }
    try {
      final Uint8List response = await QuickUsb.bulkTransferIn(_in, 1)
          .timeout(PrinterConfig.statusReadTimeout);
      // 未读到数据视为就绪（与参考实现一致），避免把空响应误判为错误。
      if (response.isEmpty) {
        return '1';
      }
      return decodeStatus(response[0]);
    } catch (_) {
      // 读取超时视为就绪（与参考实现一致）。
      return '1';
    }
  }

  /// 状态码解析。0x00 正常返回 '1'，否则按位组合中文错误。
  static String decodeStatus(int code) {
    if (code == 0x00) return '1';
    final List<String> errors = [];
    if ((code & 0x01) != 0) errors.add('打印头未关闭');
    if ((code & 0x02) != 0) errors.add('卡纸');
    if ((code & 0x04) != 0) errors.add('缺纸');
    if ((code & 0x08) != 0) errors.add('缺碳带');
    if ((code & 0x10) != 0) errors.add('打印机暂停');
    if ((code & 0x20) != 0) errors.add('打印正忙');
    if ((code & 0x80) != 0) errors.add('其他错误');
    return errors.isEmpty ? '未知状态' : errors.join(' + ');
  }

  Future<int> _sendString(String command) {
    final data = Uint8List.fromList(gbk_bytes.encode(command));
    return QuickUsb.bulkTransferOut(_out, data);
  }
}
