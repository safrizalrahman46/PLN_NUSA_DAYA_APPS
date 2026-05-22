import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_enums.dart';
import '../models/logsheet_model.dart';
import 'hive_service.dart';

final localLogsheetDatasourceProvider = Provider<LocalLogsheetDatasource>((
  ref,
) {
  return LocalLogsheetDatasource(ref.read(hiveServiceProvider));
});

class LocalLogsheetDatasource {
  LocalLogsheetDatasource(this._hiveService);

  final HiveService _hiveService;

  Future<void> save(LogsheetModel model) async {
    await _hiveService.logsheetBox.put(model.localId, model.toJson());
  }

  Future<List<LogsheetModel>> fetchAll() async {
    final values = _hiveService.logsheetBox.values
        .whereType<Map>()
        .map((json) => LogsheetModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
    values.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    return values;
  }

  Future<List<LogsheetModel>> fetchPending() async {
    final all = await fetchAll();
    return all.where((item) {
      return item.syncStatus == SyncStatus.pendingSync ||
          item.syncStatus == SyncStatus.pendingEdit ||
          item.syncStatus == SyncStatus.failed ||
          item.syncStatus == SyncStatus.draft;
    }).toList();
  }

  Future<LogsheetModel?> getByLocalId(String localId) async {
    final raw = _hiveService.logsheetBox.get(localId);
    if (raw is Map) {
      return LogsheetModel.fromJson(Map<String, dynamic>.from(raw));
    }
    return null;
  }

  Future<void> delete(String localId) async {
    await _hiveService.logsheetBox.delete(localId);
  }
}
