import 'dart:convert';

class ResponseDto {
  const ResponseDto({
    this.success = false,
    this.message = '',
    this.data,
  });

  final bool success;
  final String message;
  final dynamic data;

  ResponseDto copyWith({
    bool? success,
    String? message,
    dynamic data,
  }) {
    return ResponseDto(
      success: success ?? this.success,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }

  factory ResponseDto.fromJson(Map<String, dynamic> json) {
    return ResponseDto(
      success: _asBool(json['success']) ?? false,
      message: _asString(json['message']) ?? '',
      data: json['data'],
    );
  }

  static ResponseDto fromJsonString(String jsonString) {
    final dynamic decoded = jsonDecode(jsonString);
    if (decoded is! Map) {
      throw const FormatException('JSON string is not an object.');
    }

    return ResponseDto.fromJson(
      decoded.map((key, value) => MapEntry(key.toString(), value)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
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
}
