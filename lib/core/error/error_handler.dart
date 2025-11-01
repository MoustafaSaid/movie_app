import 'package:dio/dio.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Base error class for application errors
abstract class AppError {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppError({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => message;
}

/// Network-related errors
class NetworkError extends AppError {
  const NetworkError({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Server errors (4xx, 5xx)
class ServerError extends AppError {
  final int? statusCode;
  final String? statusMessage;

  const ServerError({
    required super.message,
    this.statusCode,
    this.statusMessage,
    super.code,
    super.originalError,
  });
}

/// Timeout errors
class TimeoutError extends AppError {
  const TimeoutError({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Parsing/Format errors
class ParseError extends AppError {
  const ParseError({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Unknown/Unhandled errors
class UnknownError extends AppError {
  const UnknownError({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Error handler class that converts exceptions to AppError
class ErrorHandler {
  /// Handle DioException and convert to appropriate AppError
  static Future<AppError> handleDioException(
    DioException exception, {
    String? endpoint,
    Map<String, dynamic>? additionalContext,
  }) async {
    final context = {
      if (endpoint != null) 'endpoint': endpoint,
      ...?additionalContext,
      'error_type': 'DioException',
      'dio_error_type': exception.type.toString(),
      'error_message': exception.message,
      'error_string': exception.error?.toString(),
      'response_status_code': exception.response?.statusCode?.toString(),
      'response_data': exception.response?.data?.toString(),
      'response_data_type': exception.response?.data?.runtimeType.toString(),
    };

    // Log to Sentry
    await Sentry.captureException(
      exception,
      stackTrace: exception.stackTrace,
      hint: Hint.withMap(context),
    );

    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutError(
          message: _getTimeoutMessage(exception.type),
          code: 'TIMEOUT',
          originalError: exception,
        );

      case DioExceptionType.badResponse:
        final statusCode = exception.response?.statusCode;
        final statusMessage = exception.response?.statusMessage;
        return ServerError(
          message: statusMessage ?? 'Server error occurred',
          statusCode: statusCode,
          statusMessage: statusMessage,
          code: 'SERVER_ERROR',
          originalError: exception,
        );

      case DioExceptionType.cancel:
        return NetworkError(
          message: 'Request was cancelled',
          code: 'CANCELLED',
          originalError: exception,
        );

      case DioExceptionType.unknown:
        // Check for parsing errors first
        final errorMessage = exception.error?.toString() ?? '';
        if (errorMessage.contains('type') || 
            errorMessage.contains('cast') ||
            errorMessage.contains('FormatException') ||
            errorMessage.contains('TypeError')) {
          // Likely a JSON parsing error
          return ParseError(
            message: 'Failed to parse response: ${errorMessage.isNotEmpty ? errorMessage : "Unknown parsing error"}',
            code: 'PARSE_ERROR',
            originalError: exception,
          );
        }
        
        if (exception.message?.isNotEmpty == true) {
          return NetworkError(
            message: exception.message!,
            code: 'NETWORK_ERROR',
            originalError: exception,
          );
        }
        if (exception.error != null) {
          return NetworkError(
            message: 'Network error: ${exception.error}',
            code: 'NETWORK_ERROR',
            originalError: exception,
          );
        }
        
        // Try to extract error from response
        if (exception.response?.data != null) {
          try {
            final responseData = exception.response!.data;
            if (responseData is Map<String, dynamic>) {
              final errorMsg = responseData['status_message'] ?? 
                              responseData['message'] ?? 
                              responseData.toString();
              return NetworkError(
                message: 'Error: $errorMsg',
                code: 'NETWORK_ERROR',
                originalError: exception,
              );
            }
          } catch (_) {}
        }
        
        return NetworkError(
          message: 'Network error occurred. Please check your internet connection.',
          code: 'NETWORK_ERROR',
          originalError: exception,
        );

      default:
        return NetworkError(
          message: exception.message ?? 'Network error occurred',
          code: 'NETWORK_ERROR',
          originalError: exception,
        );
    }
  }

  /// Handle FormatException and convert to ParseError
  static Future<AppError> handleFormatException(
    FormatException exception, {
    String? endpoint,
    Map<String, dynamic>? additionalContext,
  }) async {
    final context = {
      if (endpoint != null) 'endpoint': endpoint,
      ...?additionalContext,
      'error_type': 'FormatException',
      'error_message': exception.message,
      'error_source': exception.source?.toString(),
      'error_offset': exception.offset?.toString(),
    };

    // Log to Sentry
    await Sentry.captureException(
      exception,
      hint: Hint.withMap(context),
    );

    return ParseError(
      message: 'Failed to parse response: ${exception.message}',
      code: 'PARSE_ERROR',
      originalError: exception,
    );
  }

  /// Handle TypeError and convert to ParseError
  static Future<AppError> handleTypeError(
    TypeError exception, {
    String? endpoint,
    Map<String, dynamic>? additionalContext,
  }) async {
    final context = {
      if (endpoint != null) 'endpoint': endpoint,
      ...?additionalContext,
      'error_type': 'TypeError',
      'error_message': exception.toString(),
    };

    // Log to Sentry
    await Sentry.captureException(
      exception,
      hint: Hint.withMap(context),
    );

    return ParseError(
      message: 'Type error during parsing: ${exception.toString()}',
      code: 'TYPE_ERROR',
      originalError: exception,
    );
  }

  /// Handle unknown exceptions
  static Future<AppError> handleUnknownError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? endpoint,
    Map<String, dynamic>? additionalContext,
  }) async {
    final context = {
      if (endpoint != null) 'endpoint': endpoint,
      ...?additionalContext,
      'error_type': exception.runtimeType.toString(),
      'error_message': exception.toString(),
    };

    // Log to Sentry
    await Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      hint: Hint.withMap(context),
    );

    return UnknownError(
      message: 'Unexpected error: ${exception.toString()}',
      code: 'UNKNOWN_ERROR',
      originalError: exception,
    );
  }

  static String _getTimeoutMessage(DioExceptionType type) {
    switch (type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout';
      case DioExceptionType.sendTimeout:
        return 'Send timeout';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout';
      default:
        return 'Timeout occurred';
    }
  }
}

