import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  final info = NetworkInfo();
  ref.onDispose(info.dispose);
  return info;
});

final networkStatusProvider = StreamProvider<bool>((ref) {
  return ref.read(networkInfoProvider).onConnectivityChanged;
});

class NetworkInfo {
  NetworkInfo() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _handleConnectivityChanged,
    );
    unawaited(_refreshInitialStatus());
  }

  final Connectivity _connectivity = Connectivity();
  final _controller = StreamController<bool>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _debounceTimer;
  bool? _lastStatus;
  DateTime? _lastProbeAt;

  Future<bool> get isConnected async {
    final lastProbeAt = _lastProbeAt;
    if (_lastStatus != null &&
        lastProbeAt != null &&
        DateTime.now().difference(lastProbeAt) < const Duration(seconds: 5)) {
      return _lastStatus!;
    }

    try {
      final result = await _connectivity.checkConnectivity().timeout(
        const Duration(milliseconds: 1500),
        onTimeout: () => [ConnectivityResult.none],
      );
      final connected = await _resolveConnectivity(result);
      _emitIfChanged(connected, force: true);
      return connected;
    } catch (_) {
      _emitIfChanged(false, force: true);
      return false;
    }
  }

  Stream<bool> get onConnectivityChanged async* {
    if (_lastStatus != null) {
      yield _lastStatus!;
    }
    yield* _controller.stream.distinct();
  }

  Future<void> _refreshInitialStatus() async {
    try {
      final result = await _connectivity.checkConnectivity().timeout(
        const Duration(milliseconds: 1500),
        onTimeout: () => [ConnectivityResult.none],
      );
      final connected = await _resolveConnectivity(result);
      _emitIfChanged(connected, force: true);
    } catch (_) {
      _emitIfChanged(false, force: true);
    }
  }

  void _handleConnectivityChanged(List<ConnectivityResult> result) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 700), () async {
      final connected = await _resolveConnectivity(result);
      _emitIfChanged(connected, force: true);
    });
  }

  Future<bool> _resolveConnectivity(List<ConnectivityResult> result) async {
    if (!result.any((item) => item != ConnectivityResult.none)) {
      return false;
    }
    return true;
  }

  void _emitIfChanged(bool connected, {bool force = false}) {
    _lastProbeAt = DateTime.now();
    if (!force && _lastStatus == connected) {
      return;
    }
    _lastStatus = connected;
    if (!_controller.isClosed) {
      _controller.add(connected);
    }
  }

  void dispose() {
    _debounceTimer?.cancel();
    _connectivitySubscription?.cancel();
    _controller.close();
  }
}
