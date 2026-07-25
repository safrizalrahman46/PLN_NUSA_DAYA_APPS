import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_config.dart';
import '../../core/network/dio_client.dart';
import '../models/unit_model.dart';
import '../remote/unit_api.dart';

final unitRepositoryProvider = Provider<UnitRepository>((ref) {
  return UnitRepository(UnitApi(ref.read(dioProvider)));
});

class UnitRepository {
  UnitRepository(this._api);

  final UnitApi _api;

  Future<List<UnitModel>> getUnits({String kdRegion = AppConfig.kdRegion}) =>
      _api.getUnits(kdRegion: kdRegion);
}
