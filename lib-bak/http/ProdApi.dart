
import 'package:dio/dio.dart';
import '../entity/production_order.dart';
import 'ApiClient.dart';

class ProdApi {
  ProdApi._();

  static const String _basePath = '/api/prod';

  static Future<ProductionOrder> findByPgNo(String pgNo) async{

    String url = "$_basePath/pgNo/$pgNo";

    var res = await ApiClient.instance.get(
        url,
      options: Options(
        contentType: Headers.jsonContentType,
      )
    );

    return ProductionOrder.fromJson(res);
  }



}