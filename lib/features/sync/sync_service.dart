import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/network_info.dart';
import '../../data/repositories/logsheet_repository.dart';
import '../profile/settings_controller.dart';

class SyncState {
  const SyncState({
    this.isSyncing = false,
    this.lastMessage,
    this.lastRunAt,
    this.started = false,
  });

  final bool isSyncing;
  final String? lastMessage;
  final DateTime? lastRunAt;
  final bool started;

  SyncState copyWith({
    bool? isSyncing,
    String? lastMessage,
    DateTime? lastRunAt,
    bool? started,
  }) {
    return SyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      lastMessage: lastMessage ?? this.lastMessage,
      lastRunAt: lastRunAt ?? this.lastRunAt,
      started: started ?? this.started,
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
    _subscription = _networkInfo.onConnectivityChanged.listen((connected) {
      final autoSync = _ref.read(appSettingsProvider).autoSync;
      if (connected && autoSync) {
        syncPending();
      }
    });
  }

  Future<void> syncPending() async {
    if (state.isSyncing) return;
    state = state.copyWith(isSyncing: true);
    final count = await _repository.syncPendingLogsheets();
    state = state.copyWith(
      isSyncing: false,
      lastRunAt: DateTime.now(),
      lastMessage: count == 0
          ? 'Tidak ada data yang perlu disinkronkan.'
          : '$count logsheet berhasil disinkronkan.',
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
