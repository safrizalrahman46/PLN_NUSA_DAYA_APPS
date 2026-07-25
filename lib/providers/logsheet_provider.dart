import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/error_handler.dart';
import '../models/unit_model.dart';
import '../models/logsheet_format_model.dart';
import '../repositories/logsheet_repository.dart';
import 'auth_provider.dart';
import '../core/network/dio_client.dart';

// Repository Provider
final logsheetRepositoryProvider = Provider<LogsheetRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return LogsheetRepository(dioClient);
});

// Parameter class for fetching formats
class FormatParam {
  final String kdArea;
  final String kdUnit;
  final String? kdRegion;

  FormatParam({required this.kdArea, required this.kdUnit, this.kdRegion});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FormatParam &&
          runtimeType == other.runtimeType &&
          kdArea == other.kdArea &&
          kdUnit == other.kdUnit &&
          kdRegion == other.kdRegion;

  @override
  int get hashCode => kdArea.hashCode ^ kdUnit.hashCode ^ kdRegion.hashCode;
}

// FutureProvider for fetching units under a region/area
final unitsProvider = FutureProvider.autoDispose.family<List<UnitModel>, String?>((ref, kdArea) async {
  final repository = ref.watch(logsheetRepositoryProvider);
  final authState = ref.watch(authProvider);
  
  // Get user region
  final kdRegion = authState.value?.kdRegion ?? '05';
  
  try {
    return await repository.getUnits(kdRegion: kdRegion, kdArea: kdArea);
  } catch (e) {
    throw ErrorHandler.handle(e);
  }
});

// FutureProvider for fetching format details
final formatProvider = FutureProvider.autoDispose.family<LogsheetFormatModel, FormatParam>((ref, param) async {
  final repository = ref.watch(logsheetRepositoryProvider);
  try {
    return await repository.getFormat(
      kdArea: param.kdArea,
      kdUnit: param.kdUnit,
      kdRegion: param.kdRegion,
    );
  } catch (e) {
    throw ErrorHandler.handle(e);
  }
});

// StateNotifier for Submission status
class LogsheetSubmitNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final LogsheetRepository _repository;

  LogsheetSubmitNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<bool> submit({required String kdRegion, required String messageText}) async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.submitLogsheet(kdRegion: kdRegion, messageText: messageText);
      state = AsyncValue.data(result);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(ErrorHandler.handle(e), stack);
      return false;
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

// Global submit state provider
final logsheetSubmitProvider =
    StateNotifierProvider<LogsheetSubmitNotifier, AsyncValue<Map<String, dynamic>?>>((ref) {
  final repository = ref.watch(logsheetRepositoryProvider);
  return LogsheetSubmitNotifier(repository);
});
