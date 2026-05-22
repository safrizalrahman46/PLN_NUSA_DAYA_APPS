import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../local/hive_service.dart';
import '../local/local_logsheet_datasource.dart';
import '../models/logsheet_model.dart';
import '../models/retention_log_model.dart';

final retentionRepositoryProvider = Provider<RetentionRepository>((ref) {
  return RetentionRepository(
    ref.read(hiveServiceProvider),
    ref.read(localLogsheetDatasourceProvider),
  );
});

class RetentionRepository {
  RetentionRepository(this._hiveService, this._localDatasource);

  final HiveService _hiveService;
  final LocalLogsheetDatasource _localDatasource;
  final _uuid = const Uuid();

  int get retentionYears =>
      _hiveService.settingsBox.get('retention_years', defaultValue: 5) as int;

  Future<void> setRetentionYears(int years) async {
    await _hiveService.settingsBox.put('retention_years', years);
  }

  Future<List<LogsheetModel>> getArchiveCandidates() async {
    final cutOff = DateTime.now().subtract(Duration(days: 365 * retentionYears));
    final all = await _localDatasource.fetchAll();
    return all.where((item) => item.submittedAt.isBefore(cutOff)).toList();
  }

  Future<List<LogsheetModel>> getArchivedItems() async {
    final values = _hiveService.archiveBox.values
        .whereType<Map>()
        .map((item) => LogsheetModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    values.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    return values;
  }

  Future<void> archiveExpired() async {
    final candidates = await getArchiveCandidates();
    if (candidates.isEmpty) return;
    for (final item in candidates) {
      await _hiveService.archiveBox.put(
        item.localId,
        item.copyWith(archivedAt: DateTime.now()).toJson(),
      );
      await _localDatasource.delete(item.localId);
    }
    await _saveLog(
      RetentionLogModel(
        id: _uuid.v4(),
        createdAt: DateTime.now(),
        action: 'archive_expired',
        affectedCount: candidates.length,
        note: 'Arsip otomatis untuk data lebih dari $retentionYears tahun.',
      ),
    );
  }

  Future<List<RetentionLogModel>> getRetentionLogs() async {
    final items = _hiveService.retentionLogBox.values
        .whereType<Map>()
        .map(
          (item) => RetentionLogModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  Future<void> saveExportLog(String fileName, int count) async {
    await _saveLog(
      RetentionLogModel(
        id: _uuid.v4(),
        createdAt: DateTime.now(),
        action: 'export_archive',
        affectedCount: count,
        fileName: fileName,
      ),
    );
  }

  Future<void> _saveLog(RetentionLogModel item) async {
    await _hiveService.retentionLogBox.put(item.id, item.toJson());
  }
}
