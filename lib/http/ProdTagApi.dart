import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../entity/prod_tag.dart';
import 'ApiClient.dart';
import 'ApiException.dart';

class ProdTagApi {
  ProdTagApi._();

  static const String _basePath = '/api/productionTag';

  static Future<dynamic> add(
    Map<String, dynamic> dto, {
    CancelToken? cancelToken,
  }) {
    return ApiClient.instance.post(
      _basePath,
      data: dto,
      options: Options(
        contentType: Headers.jsonContentType,
      ),
      cancelToken: cancelToken,
    );
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
