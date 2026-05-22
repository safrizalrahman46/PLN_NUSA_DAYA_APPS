import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/sync_feedback.dart';
import '../../core/network/network_info.dart';
import '../../data/repositories/logsheet_repository.dart';
import '../profile/settings_controller.dart';

class SyncState {
  const SyncState({
    this.isSyncing = false,
    this.lastMessage,
    this.lastRunAt,
    this.started = false,
    this.tone = SyncMessageTone.neutral,
  });

  final bool isSyncing;
  final String? lastMessage;
  final DateTime? lastRunAt;
  final bool started;
  final SyncMessageTone tone;

  SyncState copyWith({
    bool? isSyncing,
    String? lastMessage,
    DateTime? lastRunAt,
    bool? started,
    SyncMessageTone? tone,
  }) {
    return SyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      lastMessage: lastMessage ?? this.lastMessage,
      lastRunAt: lastRunAt ?? this.lastRunAt,
      started: started ?? this.started,
      tone: tone ?? this.tone,
    );
  }
}

final syncServiceProvider = StateNotifierProvider<SyncService, SyncState>((
  ref,
) {
  return SyncService(
    ref,
    ref.read(logsheetRepositoryProvider),
    ref.read(networkInfoProvider),
  );
});

class SyncService extends StateNotifier<SyncState> {
  SyncService(this._ref, this._repository, this._networkInfo)
    : super(const SyncState());

  final Ref _ref;
  final LogsheetRepository _repository;
  final NetworkInfo _networkInfo;
  StreamSubscription<bool>? _subscription;

  void start() {
    if (state.started) return;
    state = state.copyWith(started: true);
    unawaited(_syncOnStartupIfNeeded());
    _subscription = _networkInfo.onConnectivityChanged.listen((connected) {
      final autoSync = _ref.read(appSettingsProvider).autoSync;
      if (connected && autoSync) {
        unawaited(syncPending());
      }
    });
  }

  Future<void> _syncOnStartupIfNeeded() async {
    final autoSync = _ref.read(appSettingsProvider).autoSync;
    if (!autoSync) {
      return;
    }

    final connected = await _networkInfo.isConnected;
    if (connected) {
      await syncPending();
    }
  }

  Future<void> syncPending({String? localId}) async {
    if (state.isSyncing) return;
    state = state.copyWith(
      isSyncing: true,
      tone: SyncMessageTone.neutral,
    );
    final result = await _repository.syncPendingLogsheets(localId: localId);
    state = state.copyWith(
      isSyncing: false,
      lastRunAt: DateTime.now(),
      lastMessage: result.message,
      tone: result.tone,
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
