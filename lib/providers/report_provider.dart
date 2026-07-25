import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/error_handler.dart';
import '../models/report_model.dart';
import '../models/report_detail_model.dart';
import '../repositories/report_repository.dart';
import 'auth_provider.dart';
import '../core/network/dio_client.dart';

// Repository Provider
final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ReportRepository(dioClient);
});

// Parameter class for reports list
class ReportsParam {
  final String tanggal; // format YYYY-MM-DD
  final String? kdUnit;

  ReportsParam({required this.tanggal, this.kdUnit});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportsParam &&
          runtimeType == other.runtimeType &&
          tanggal == other.tanggal &&
          kdUnit == other.kdUnit;

  @override
  int get hashCode => tanggal.hashCode ^ kdUnit.hashCode;
}

// Parameter class for report details
class ReportDetailParam {
  final String idBebanUld;
  final String tanggal;
  final String jam;

  ReportDetailParam({
    required this.idBebanUld,
    required this.tanggal,
    required this.jam,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportDetailParam &&
          runtimeType == other.runtimeType &&
          idBebanUld == other.idBebanUld &&
          tanggal == other.tanggal &&
          jam == other.jam;

  @override
  int get hashCode => idBebanUld.hashCode ^ tanggal.hashCode ^ jam.hashCode;
}

// FutureProvider for reports list
final reportsProvider = FutureProvider.autoDispose.family<List<ReportModel>, ReportsParam>((ref, param) async {
  final repository = ref.watch(reportRepositoryProvider);
  final authState = ref.watch(authProvider);
  
  final kdRegion = authState.value?.kdRegion ?? '05';

  try {
    return await repository.getReports(
      kdRegion: kdRegion,
      tanggal: param.tanggal,
      kdUnit: param.kdUnit,
    );
  } catch (e) {
    throw ErrorHandler.handle(e);
  }
});

// FutureProvider for report detail
final reportDetailProvider = FutureProvider.autoDispose.family<ReportDetailModel, ReportDetailParam>((ref, param) async {
  final repository = ref.watch(reportRepositoryProvider);
  final authState = ref.watch(authProvider);
  
  final kdRegion = authState.value?.kdRegion ?? '05';

  try {
    return await repository.getReportDetail(
      idBebanUld: param.idBebanUld,
      kdRegion: kdRegion,
      tanggal: param.tanggal,
      jam: param.jam,
    );
  } catch (e) {
    throw ErrorHandler.handle(e);
  }
});
