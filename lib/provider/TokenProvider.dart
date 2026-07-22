import 'package:hive/hive.dart';

import '../entity/login_user.dart';


class TokenProvider {
  TokenProvider._();

  static const String boxName = 'login_user_box';
  static const String loginUserKey = 'login_user';

  static Future<Box<dynamic>> _getBox() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<dynamic>(boxName);
    }
    return Hive.openBox<dynamic>(boxName);
  }

  static Future<LoginUser?> getLoginUser() async {
    final box = await _getBox();
    final dynamic raw = box.get(loginUserKey);

    if (raw == null) {
      return null;
    }
    if (raw is LoginUser) {
      return raw;
    }
    if (raw is String && raw.isNotEmpty) {
      return LoginUser.fromJsonString(raw);
    }
    if (raw is Map) {
      return LoginUser.fromJson(
        raw.map((key, value) => MapEntry(key.toString(), value)),
      );
    }
    return null;
  }

  static Future<void> saveLoginUser(LoginUser loginUser) async {
    final box = await _getBox();
    await box.put(loginUserKey, loginUser);
  }

  static Future<void> clearLoginUser() async {
    final box = await _getBox();
    await box.delete(loginUserKey);
  }

  static Future<String> getToken() async {
    final LoginUser? loginUser = await getLoginUser();
    return loginUser?.token.trim() ?? '';
  }

  static Future<Map<String, dynamic>> buildTokenHeaders() async {
    final String token = await getToken();
    if (token.isEmpty) {
      return <String, dynamic>{};
    }

    return <String, dynamic>{
      'token': token,
    };
  }
}
