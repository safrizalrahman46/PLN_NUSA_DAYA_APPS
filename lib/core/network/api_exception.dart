import 'package:dio/dio.dart';

enum ApiExceptionType {
  timeout,
  connection,
  validation,
  unauthorized,
  forbidden,
  notFound,
  server,
  unknown,
}

class ApiException implements Exception {
  ApiException(
    this.message, {
    this.statusCode,
    this.type = ApiExceptionType.unknown,
    this.detail,
  });

  final String message;
  final int? statusCode;
  final ApiExceptionType type;
  final String? detail;

  bool get shouldQueueForRetry =>
      type == ApiExceptionType.timeout || type == ApiExceptionType.connection;

  bool get isRetryable =>
      shouldQueueForRetry || type == ApiExceptionType.server;

  factory ApiException.fromDioException(
    DioException error, {
    String fallbackMessage = 'Terjadi kendala saat menghubungi server.',
  }) {
    final statusCode = error.response?.statusCode;
    final responseMessage = _extractMessage(error.response?.data);
    final rawDetail = responseMessage ?? error.message ?? fallbackMessage;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          'Koneksi ke server terlalu lama. Coba lagi sebentar lagi.',
          statusCode: statusCode,
          type: ApiExceptionType.timeout,
          detail: rawDetail,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
          statusCode: statusCode,
          type: ApiExceptionType.connection,
          detail: rawDetail,
        );
      case DioExceptionType.badResponse:
        return _fromStatusCode(
          statusCode,
          responseMessage,
          fallbackMessage,
          rawDetail,
        );
      case DioExceptionType.cancel:
        return ApiException(
          'Permintaan dibatalkan sebelum selesai diproses.',
          statusCode: statusCode,
          type: ApiExceptionType.unknown,
          detail: rawDetail,
        );
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return ApiException(
          responseMessage ?? fallbackMessage,
          statusCode: statusCode,
          type: ApiExceptionType.unknown,
          detail: rawDetail,
        );
    }
  }

  factory ApiException.fromObject(
    Object error, {
    String fallbackMessage = 'Terjadi kendala pada aplikasi.',
  }) {
    if (error is ApiException) {
      return error;
    }
    if (error is DioException) {
      return ApiException.fromDioException(
        error,
        fallbackMessage: fallbackMessage,
      );
    }

    final raw = error.toString().replaceFirst('Exception: ', '').trim();
    final lower = raw.toLowerCase();
    if (lower.contains('timeout') || raw.contains('0:00:15')) {
      return ApiException(
        'Koneksi ke server terlalu lama. Coba lagi sebentar lagi.',
        type: ApiExceptionType.timeout,
        detail: raw,
      );
    }
    if (lower.contains('socketexception') ||
        lower.contains('connection') ||
        lower.contains('network')) {
      return ApiException(
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
        type: ApiExceptionType.connection,
        detail: raw,
      );
    }
    return ApiException(
      raw.isEmpty ? fallbackMessage : raw,
      type: ApiExceptionType.unknown,
      detail: raw.isEmpty ? fallbackMessage : raw,
    );
  }

  static ApiException _fromStatusCode(
    int? statusCode,
    String? responseMessage,
    String fallbackMessage,
    String rawDetail,
  ) {
    switch (statusCode) {
      case 400:
      case 409:
      case 422:
        return ApiException(
          responseMessage ?? 'Data belum dapat diproses oleh server.',
          statusCode: statusCode,
          type: ApiExceptionType.validation,
          detail: rawDetail,
        );
      case 401:
        return ApiException(
          responseMessage ?? 'Sesi login berakhir. Silakan masuk kembali.',
          statusCode: statusCode,
          type: ApiExceptionType.unauthorized,
          detail: rawDetail,
        );
      case 403:
        return ApiException(
          responseMessage ?? 'Anda tidak memiliki akses untuk proses ini.',
          statusCode: statusCode,
          type: ApiExceptionType.forbidden,
          detail: rawDetail,
        );
      case 404:
        return ApiException(
          responseMessage ?? 'Data yang diminta tidak ditemukan di server.',
          statusCode: statusCode,
          type: ApiExceptionType.notFound,
          detail: rawDetail,
        );
      default:
        return ApiException(
          responseMessage ?? fallbackMessage,
          statusCode: statusCode,
          type: statusCode != null && statusCode >= 500
              ? ApiExceptionType.server
              : ApiExceptionType.unknown,
          detail: rawDetail,
        );
    }
  }

  static String? _extractMessage(dynamic data) {
    if (data is Map) {
      final candidates = [
        data['message'],
        data['error'],
        data['detail'],
      ];
      for (final candidate in candidates) {
        final text = candidate?.toString().trim() ?? '';
        if (text.isNotEmpty) {
          return text;
        }
      }
    }
    final text = data?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }

  @override
  String toString() => message;
}
