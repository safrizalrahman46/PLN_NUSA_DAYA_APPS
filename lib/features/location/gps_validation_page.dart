import 'dart:async';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

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
  StreamSubscription<LocationValidationResult>? _subscription;
  final List<LatLng> _trailPoints = <LatLng>[];
  var _loading = true;
  var _starting = false;

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _startTracking() async {
    if (_starting) {
      return;
    }
    _starting = true;
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
      _starting = false;
      return;
    }

    await _subscription?.cancel();
    _trailPoints.clear();
    _subscription = _service.watchValidation(widget.unit).listen((result) {
      if (!mounted) {
        return;
      }
      setState(() {
        _result = result;
        _loading = false;
        if (result.latitude != 0 && result.longitude != 0) {
          final point = LatLng(result.latitude, result.longitude);
          final isDuplicate =
              _trailPoints.isNotEmpty &&
              _trailPoints.last.latitude == point.latitude &&
              _trailPoints.last.longitude == point.longitude;
          if (!isDuplicate) {
            _trailPoints.add(point);
            if (_trailPoints.length > 30) {
              _trailPoints.removeAt(0);
            }
          }
        }
      });
    });
    _starting = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Validasi GPS')),
      body: _loading
          ? const AppLoading(label: 'Mengambil lokasi realtime...')
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                GpsMapPlaceholder(
                  unit: widget.unit,
                  result: _result,
                  trailPoints: _trailPoints,
                ),
                const SizedBox(height: 16),
                GpsValidationCard(unit: widget.unit, result: _result!),
                const SizedBox(height: 16),
                OverflowBar(
                  spacing: 12,
                  overflowSpacing: 12,
                  alignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width < 360
                          ? double.infinity
                          : 170,
                      child: AppButton(
                        label: 'Refresh Lokasi',
                        onPressed: _startTracking,
                        type: AppButtonType.outlined,
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width < 360
                          ? double.infinity
                          : 170,
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
