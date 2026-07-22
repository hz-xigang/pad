import 'dart:convert';

import 'package:hive/hive.dart';

class LoginUser {
  const LoginUser({
    this.username = '',
    this.pwd = '',
    this.rememberMe = false,
    this.token = '',
    this.realName = ''
  });

  final String username;
  final String pwd;
  final bool rememberMe;
  final String token;
  final String realName;

  LoginUser copyWith({
    String? username,
    String? pwd,
    bool? rememberMe,
    String? token,
    String? realName
  }) {
    return LoginUser(
      username: username ?? this.username,
      pwd: pwd ?? this.pwd,
      rememberMe: rememberMe ?? this.rememberMe,
      token: token ?? this.token,
      realName : realName ?? this.realName,
    );
  }

  factory LoginUser.fromJson(Map<String, dynamic> json) {
    return LoginUser(
      username: _asString(json['username']) ?? '',
      pwd: _asString(json['pwd']) ?? '',
      rememberMe: _asBool(json['rememberMe']) ?? false,
      token: _asString(json['token']) ?? '',
      realName: _asString(json['realName']) ?? '',
    );
  }

  static LoginUser fromJsonString(String jsonString) {
    final dynamic decoded = jsonDecode(jsonString);
    if (decoded is! Map) {
      throw const FormatException('JSON string is not an object.');
    }
    return LoginUser.fromJson(
      decoded.map((key, value) => MapEntry(key.toString(), value)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'pwd': pwd,
      'rememberMe': rememberMe,
      'token': token,
      'realName' : realName,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  static String? _asString(dynamic value) {
    if (value == null) {
      return null;
    }
    return value.toString();
  }

  static bool? _asBool(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }

    final String normalized = value.toString().trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') {
      return true;
    }
    if (normalized == 'false' || normalized == '0') {
      return false;
    }
    return null;
  }

  @override
  String toString() {
    return 'LoginUser{username: $username, pwd: $pwd, rememberMe: $rememberMe, token: $token, realName: $realName}';
  }


}

class LoginUserAdapter extends TypeAdapter<LoginUser> {
  @override
  final int typeId = 0;

  @override
  LoginUser read(BinaryReader reader) {
    final int numOfFields = reader.readByte();
    final Map<int, dynamic> fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }

    return LoginUser(
      username: fields[0] as String? ?? '',
      pwd: fields[1] as String? ?? '',
      rememberMe: fields[2] as bool? ?? false,
      token: fields[3] as String? ?? '',
      realName: fields[4] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, LoginUser obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.username)
      ..writeByte(1)
      ..write(obj.pwd)
      ..writeByte(2)
      ..write(obj.rememberMe)
      ..writeByte(3)
      ..write(obj.token)
        ..writeByte(4)
      ..write(obj.realName);
  }
}
