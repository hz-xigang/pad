import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../entity/response_dto.dart';
import '../provider/TokenProvider.dart';
import '../util/feedback_util.dart';
import 'ApiException.dart';


class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  factory ApiClient() => instance;

  static final String baseUrl = kDebugMode
      ? 'http://192.168.1.100:7100/'
      : 'http://175.178.92.52/';

  late final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      contentType: Headers.formUrlEncodedContentType,
    ),
  );

  Dio get dio => _dio;

  Future<dynamic> request({
    required String url,
    required String method,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(ApiException exception)? onError,
  }) async {
    try {
      // final Map<String, dynamic> tokenHeaders = await TokenProvider.buildTokenHeaders();
      final loginUser = await TokenProvider.getLoginUser();

      final response = await _dio.request<dynamic>(
        url,
        data: data,
        queryParameters: queryParameters,
        options: (options ?? Options()).copyWith(
          method: method,
          headers: {
            // ...tokenHeaders,
            "Authorization" :   "Bearer ${loginUser?.token.trim().isNotEmpty == true
                ? loginUser!.token.trim()
                : ''}",
            ...?options?.headers,
          },
        ),
      );

      final dynamic decodedData = _decodeResponseData(response.data);
      if (decodedData is! Map) {
        throw ApiException(
          message: '响应格式错误',
          statusCode: response.statusCode,
          rawResponse: decodedData,
        );
      }

      final Map<String, dynamic> jsonMap = Map<String, dynamic>.from(
        decodedData,
      );

      final ResponseDto resp = ResponseDto.fromJson(jsonMap);

      if (!resp.success) {
        final exception = ApiException(
          message: resp.message.isEmpty ? '请求失败' : resp.message,
          statusCode: response.statusCode,
          rawResponse: jsonMap,
        );
        onError?.call(exception);
        FeedbackUtil.showError(
          resp.message.isEmpty ? '请求失败' : resp.message,
        );
        throw exception;
      }

      return resp.data;
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      final exception = ApiException(
        message: e.message ?? '网络请求失败',
        statusCode: e.response?.statusCode,
        rawResponse: e.response?.data,
      );
      onError?.call(exception);
      FeedbackUtil.showError(e.message ?? '网络请求失败');
      print(e);
      print(url);
      throw exception;
    } on FormatException catch (e) {
      final exception = ApiException(
        message: e.message,
        rawResponse: e.source,
      );
      onError?.call(exception);
      FeedbackUtil.showError(e.message);
      throw exception;
    } catch (e) {
      final exception = ApiException(
        message: e.toString(),
      );
      onError?.call(exception);
      print(e);
      FeedbackUtil.showError(e.toString());
      throw exception;
    }
  }

  Future<dynamic> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(ApiException exception)? onError,
  }) {
    return request(
      url: url,
      method: 'GET',
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onError: onError,
    );
  }

  Future<dynamic> post(
    String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(ApiException exception)? onError,
  }) {
    options ??= Options(
      contentType: Headers.jsonContentType,
    );

    return request(
      url: url,
      method: 'POST',
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onError: onError,
    );
  }

  Future<dynamic> put(
    String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(ApiException exception)? onError,
  }) {
    return request(
      url: url,
      method: 'PUT',
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onError: onError,
    );
  }

  Future<dynamic> delete(
    String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(ApiException exception)? onError,
  }) {
    return request(
      url: url,
      method: 'DELETE',
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onError: onError,
    );
  }

  dynamic _decodeResponseData(dynamic rawData) {
    if (rawData is String) {
      return jsonDecode(rawData);
    }
    return rawData;
  }
}
