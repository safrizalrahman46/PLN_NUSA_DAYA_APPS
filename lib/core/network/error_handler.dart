import 'package:dio/dio.dart';

class ErrorHandler {
  static String handle(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return 'Koneksi ke server terputus. Silakan periksa jaringan Anda.';
        case DioExceptionType.sendTimeout:
          return 'Waktu pengiriman data habis. Silakan coba lagi.';
        case DioExceptionType.receiveTimeout:
          return 'Waktu tunggu respon habis. Silakan coba lagi.';
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final data = error.response?.data;
          
          if (statusCode == 401) {
            return data?['message'] ?? 'Sesi telah berakhir atau kredensial salah.';
          } else if (statusCode == 422) {
            // Validation errors
            if (data != null && data['errors'] != null) {
              final Map<String, dynamic> errors = data['errors'] as Map<String, dynamic>;
              return errors.values.map((e) => (e as List).join('\n')).join('\n');
            }
            return data?['message'] ?? 'Data yang dikirimkan tidak valid.';
          } else if (statusCode == 404) {
            return 'Layanan atau data tidak ditemukan di server.';
          } else if (statusCode == 500) {
            return data?['message'] ?? 'Terjadi kesalahan sistem internal di server. Silakan hubungi admin.';
          }
          return 'Terjadi kesalahan server ($statusCode). Silakan coba lagi.';
        case DioExceptionType.cancel:
          return 'Permintaan ke server dibatalkan.';
        case DioExceptionType.connectionError:
          return 'Gagal terhubung ke server. Pastikan server aktif dan Anda memiliki koneksi internet.';
        default:
          return 'Terjadi kesalahan jaringan yang tidak diketahui.';
      }
    }
    return error?.toString() ?? 'Terjadi kesalahan sistem yang tidak terduga.';
  }
}
