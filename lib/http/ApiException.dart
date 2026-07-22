class ApiException implements Exception {
  ApiException({
    required this.message,
    this.statusCode,
    this.rawResponse,
  });

  final String message;
  final int? statusCode;
  final dynamic rawResponse;

  @override
  String toString() {
    return 'ApiException(statusCode: $statusCode, message: $message)';
  }
}
