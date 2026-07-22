
import 'ApiClient.dart';

class UserApi{

  UserApi._();

  static const String _basePath = '/api/user';

  static Future<String> login(Map<String,dynamic> data) async{
    var token =  await ApiClient.instance.post(
      "$_basePath/login" ,
      data: data,
    );
    return token.toString();
  }


}