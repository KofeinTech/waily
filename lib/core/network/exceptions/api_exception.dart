sealed class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => '$runtimeType($statusCode): $message';
}

class NetworkException extends ApiException {
  const NetworkException([super.message = 'No internet connection']);
}

class TimeoutApiException extends ApiException {
  const TimeoutApiException([super.message = 'Request timed out']);
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException([super.message = 'Unauthorized'])
      : super(statusCode: 401);
}

class ForbiddenException extends ApiException {
  const ForbiddenException([super.message = 'Forbidden'])
      : super(statusCode: 403);
}

class NotFoundException extends ApiException {
  const NotFoundException([super.message = 'Not found'])
      : super(statusCode: 404);
}

class BadRequestException extends ApiException {
  const BadRequestException(int statusCode, [String? message])
      : super(message ?? 'Bad request', statusCode: statusCode);
}

class ServerException extends ApiException {
  const ServerException(int statusCode, [String? message])
      : super(message ?? 'Server error', statusCode: statusCode);
}

class UnknownApiException extends ApiException {
  const UnknownApiException([super.message = 'Unknown error']);
}
