import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import '../entity/prod_tag.dart';
import '../provider/TokenProvider.dart';
import 'ApiClient.dart';
import 'ApiException.dart';

/// 提交生产标签的返回结果。
///
/// 后端约定：返回二进制 PDF 流表示需要打印；返回 JSON 表示无需打印
/// （通常是业务提示或校验信息）。
class AddTagResult {
  AddTagResult.pdf(Uint8List this.pdfBytes) : json = null;
  AddTagResult.json(this.json) : pdfBytes = null;

  /// 需要打印时的 PDF 字节流，非 null 表示需要打印。
  final Uint8List? pdfBytes;

  /// 无需打印时的 JSON 响应（可能为 null，表示无法解析）。
  final Map<String, dynamic>? json;

  /// 是否需要打印。
  bool get needsPrint => pdfBytes != null;

  /// JSON 响应中的业务消息（如果有）。
  String? get message {
    final Map<String, dynamic>? m = json;
    if (m == null) return null;
    final dynamic msg = m['message'] ?? m['msg'];
    return msg?.toString();
  }
}

class ProdTagApi {
  ProdTagApi._();

  static const String _basePath = '/api/productionTag';

  /// 提交生产标签。
  ///
  /// 以二进制方式接收响应，按 Content-Type 分支：
  /// - `application/pdf`（或以 `%PDF` 开头）→ 返回 PDF 字节流，需要打印；
  /// - 其它（通常是 `application/json`）→ 解析为 JSON，无需打印。
  static Future<AddTagResult> add(
    Map<String, dynamic> dto, {
    CancelToken? cancelToken,
  }) async {
    final loginUser = await TokenProvider.getLoginUser();
    final String token = loginUser?.token.trim() ?? '';

    try {
      final Response<List<int>> response =
          await ApiClient.instance.dio.post<List<int>>(
        _basePath,
        data: dto,
        options: Options(
          contentType: Headers.jsonContentType,
          responseType: ResponseType.bytes,
          headers: <String, dynamic>{
            'Authorization': 'Bearer $token',
          },
        ),
        cancelToken: cancelToken,
      );

      final List<int> bytes = response.data ?? const <int>[];
      final String contentType =
          (response.headers.value(Headers.contentTypeHeader) ?? '')
              .toLowerCase();

      if (contentType.contains('pdf') || _looksLikePdf(bytes)) {
        return AddTagResult.pdf(Uint8List.fromList(bytes));
      }

      return AddTagResult.json(_tryDecodeJson(bytes));
    } on DioException catch (e) {
      // 错误响应体也是 bytes，尝试解析出后端返回的中文提示。
      final dynamic raw = e.response?.data;
      String? message;
      if (raw is List<int>) {
        final Map<String, dynamic>? jsonMap = _tryDecodeJson(raw);
        message = jsonMap?['message']?.toString() ?? jsonMap?['msg']?.toString();
      }
      throw ApiException(
        message: message ?? e.message ?? '网络请求失败',
        statusCode: e.response?.statusCode,
        rawResponse: raw,
      );
    }
  }

  static bool _looksLikePdf(List<int> bytes) {
    return bytes.length >= 4 &&
        bytes[0] == 0x25 && // %
        bytes[1] == 0x50 && // P
        bytes[2] == 0x44 && // D
        bytes[3] == 0x46; // F
  }

  static Map<String, dynamic>? _tryDecodeJson(List<int> bytes) {
    if (bytes.isEmpty) return null;
    try {
      final dynamic decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      // 解析失败时返回 null，交由调用方处理。
    }
    return null;
  }

  static Future<List<ProdTag>> list(dynamic data) async {
    final dynamic res = await ApiClient.instance.post(
      '$_basePath/list',
      data: data,
      options: Options(
        contentType: Headers.jsonContentType,
      ),
    );

    return ProdTag.listFromDynamic(res);
  }

  static Future<ProdTag> findByTagNo(String tagNo, int type,
      void Function(ApiException exception)? onError) async {
    final dynamic res = await ApiClient.instance.get(
      '$_basePath/tag/$tagNo?type=$type',
      options: Options(contentType: Headers.jsonContentType),
      onError: onError,
    );
    return ProdTag.fromJson(res);
  }

  static Future<List<ProdTag>> listByDate(
      String startDate, String endDate) async {
    final dynamic res = await ApiClient.instance.get(
      '$_basePath/list',
      queryParameters: {'startDate': startDate, 'endDate': endDate},
      options: Options(contentType: Headers.jsonContentType),
    );
    return ProdTag.listFromDynamic(res);
  }
}
