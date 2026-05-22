import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../local/hive_service.dart';
import '../models/app_enums.dart';
import '../models/error_log_model.dart';
import '../models/user_model.dart';

final errorLogRepositoryProvider = Provider<ErrorLogRepository>((ref) {
  return ErrorLogRepository(ref.read(hiveServiceProvider));
});

class ErrorLogRepository {
  ErrorLogRepository(this._hiveService);

  final HiveService _hiveService;
  final _uuid = const Uuid();

  Future<void> save(ErrorLogModel log) async {
    await _hiveService.errorLogBox.put(log.id, log.toJson());
  }

  Future<ErrorLogModel> logException({
    required Object error,
    StackTrace? stackTrace,
    required String page,
    UserModel? user,
    String source = 'app',
    String? detail,
    Map<String, dynamic> metadata = const {},
  }) async {
    final model = ErrorLogModel(
      id: _uuid.v4(),
      createdAt: DateTime.now(),
      page: page,
      errorType: error.runtimeType.toString(),
      message: error.toString(),
      detail: detail ?? error.toString(),
      userId: user?.id ?? '',
      userName: user?.name ?? '',
      role: user?.role ?? UserRole.operator,
      stackTrace: stackTrace?.toString() ?? '',
      source: source,
      metadata: metadata,
    );
    await save(model);
    return model;
  }

  Future<List<ErrorLogModel>> getAll() async {
    final items = _hiveService.errorLogBox.values
        .whereType<Map>()
        .map((item) => ErrorLogModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  Future<ErrorLogModel?> getById(String id) async {
    final raw = _hiveService.errorLogBox.get(id);
    if (raw is Map) {
      return ErrorLogModel.fromJson(Map<String, dynamic>.from(raw));
    }
    return null;
  }

  Future<void> updateStatus(String id, ErrorLogStatus status) async {
    final existing = await getById(id);
    if (existing == null) return;
    await save(existing.copyWith(status: status));
  }

  static void installGlobalHandlers() {
    FlutterError.onError = (details) async {
      FlutterError.presentError(details);
      final model = ErrorLogModel(
        id: const Uuid().v4(),
        createdAt: DateTime.now(),
        page: details.library ?? 'global',
        errorType: details.exception.runtimeType.toString(),
        message: details.exceptionAsString(),
        detail: details.context?.toDescription() ?? details.exceptionAsString(),
        stackTrace: details.stack?.toString() ?? '',
        source: 'flutter_error',
      );
      await HiveService.instance.errorLogBox.put(model.id, model.toJson());
    };

    PlatformDispatcher.instance.onError = (error, stackTrace) {
      final model = ErrorLogModel(
        id: const Uuid().v4(),
        createdAt: DateTime.now(),
        page: 'platform_dispatcher',
        errorType: error.runtimeType.toString(),
        message: error.toString(),
        detail: error.toString(),
        stackTrace: stackTrace.toString(),
        source: 'platform_dispatcher',
      );
      HiveService.instance.errorLogBox.put(model.id, model.toJson());
      return false;
    };
  }
}
