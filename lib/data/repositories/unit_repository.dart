import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_config.dart';
import '../../core/network/dio_client.dart';
import '../models/unit_model.dart';
import '../remote/unit_api.dart';

import '../dummy/dummy_data.dart';

final unitRepositoryProvider = Provider<UnitRepository>((ref) {
  return UnitRepository(UnitApi(ref.read(dioProvider)));
});

class UnitRepository {
  UnitRepository(this._api);

  final UnitApi _api;

  Future<List<UnitModel>> getUnits({String kdRegion = AppConfig.kdRegion}) async {
    try {
      final items = await _api.getUnits(kdRegion: kdRegion);
      if (items.isNotEmpty) return items;
      return DummyData.units;
    } catch (_) {
      return DummyData.units;
    }
  }
}
