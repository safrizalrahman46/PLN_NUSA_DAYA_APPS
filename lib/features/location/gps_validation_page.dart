import 'package:flutter/material.dart';

import '../../core/permissions/permission_service.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_loading.dart';
import '../../data/models/app_enums.dart';
import '../../data/models/unit_model.dart';
import 'location_service.dart';
import 'widgets/gps_map_placeholder.dart';
import 'widgets/gps_validation_card.dart';

class GpsValidationPage extends StatefulWidget {
  const GpsValidationPage({super.key, required this.unit});

  final UnitModel unit;

  @override
  State<GpsValidationPage> createState() => _GpsValidationPageState();
}

class _GpsValidationPageState extends State<GpsValidationPage> {
  final _service = LocationService();
  LocationValidationResult? _result;
  var _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final granted = await PermissionService().ensureLocationPermission(context);
    if (!granted) {
      setState(() {
        _loading = false;
        _result = const LocationValidationResult(
          latitude: 0,
          longitude: 0,
          accuracy: 0,
          distanceFromUnit: 0,
          status: LocationStatus.permissionDenied,
          gpsEnabled: true,
          permissionGranted: false,
        );
      });
      return;
    }
    final result = await _service.validate(widget.unit);
    if (!mounted) return;
    setState(() {
      _result = result;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Validasi GPS')),
      body: _loading
          ? const AppLoading(label: 'Mengambil lokasi...')
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                GpsMapPlaceholder(unitName: widget.unit.name),
                const SizedBox(height: 16),
                GpsValidationCard(unit: widget.unit, result: _result!),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Refresh Lokasi',
                        onPressed: _load,
                        type: AppButtonType.outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        label: 'Gunakan Lokasi',
                        onPressed: () => Navigator.pop(context, _result),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
