import 'dart:math' as math;

import 'package:intl/intl.dart';

import '../models/app_enums.dart';
import '../models/logsheet_model.dart';
import '../models/machine_model.dart';
import '../models/unit_model.dart';
import '../models/user_model.dart';
import 'master_machine_data.dart';

class DummyData {
  DummyData._();

  static const _knownUnitCoordinates =
      <String, ({double latitude, double longitude, String locationName})>{
        'PLTD KRAYAN': (
          latitude: 3.8742,
          longitude: 115.7312,
          locationName: 'Krayan, Kalimantan Utara',
        ),
        'PLTD TANAH MERAH': (
          latitude: 2.8227,
          longitude: 117.3748,
          locationName: 'Tanah Merah, Kalimantan Utara',
        ),
        'PLTD SEI MENGGARIS': (
          latitude: 3.5009,
          longitude: 117.2411,
          locationName: 'Sei Menggaris, Kalimantan Utara',
        ),
        'PLTD LONG PESO': (
          latitude: 2.9343,
          longitude: 116.7941,
          locationName: 'Long Peso, Kalimantan Utara',
        ),
        'PLTD LONG LAYU': (
          latitude: 3.5739,
          longitude: 115.7298,
          locationName: 'Long Layu, Kalimantan Utara',
        ),
        'PLTD PA UPAN': (
          latitude: 3.9113,
          longitude: 115.5524,
          locationName: 'Pa Upan, Kalimantan Utara',
        ),
      };

  static final List<UnitModel> units = List<UnitModel>.generate(
    unitMasterSeeds.length,
    (index) {
      final seed = unitMasterSeeds[index];
      final known = _knownUnitCoordinates[seed.unitName];
      return UnitModel(
        id: 'U${(index + 1).toString().padLeft(2, '0')}',
        name: seed.unitName,
        locationName:
            known?.locationName ??
            (seed.unitName == 'UP3 SAMARINDA'
                ? 'UP3 Samarinda - PLTD mobile'
                : 'UP3 ${seed.up3}'),
        latitude: known?.latitude ?? _generatedLatitude(index),
        longitude: known?.longitude ?? _generatedLongitude(index),
        radiusMeter: 225 + ((index % 4) * 25),
        status: 'active',
      );
    },
  );

  static final Map<String, String> _unitIdByName = {
    for (final unit in units) unit.name: unit.id,
  };

  static final List<MachineModel> machines = List<MachineModel>.generate(
    machineMasterSeeds.length,
    (index) {
      final seed = machineMasterSeeds[index];
      return MachineModel(
        id: 'M${(index + 1).toString().padLeft(3, '0')}',
        unitId: _requiredUnitId(seed.unitName),
        up3: seed.up3,
        machineName: seed.machineName,
        brand: seed.brand,
        machineType: seed.machineType,
        serialNumber: seed.serialNumber,
        generatorCode: seed.generatorCode,
        ownershipStatus: seed.ownershipStatus,
        performanceLabel: seed.performanceLabel,
        capacity: seed.capacity,
        availableCapacity: seed.availableCapacity,
        dispatchCapacity: seed.dispatchCapacity,
        status: parseMachineStatus(seed.conditionLabel).apiValue,
        conditionLabel: seed.conditionLabel,
      );
    },
  );

  static final List<UserModel> users = [
    UserModel(
      id: 'OP1',
      name: 'Rahman Safrizal',
      username: 'operator',
      role: UserRole.operator,
      unitId: _requiredUnitId('PLTD KRAYAN'),
      unitName: 'PLTD KRAYAN',
      token: 'token-operator',
    ),
    UserModel(
      id: 'OP2',
      name: 'Operator Krayan',
      username: 'operator.krayan',
      role: UserRole.operator,
      unitId: _requiredUnitId('PLTD KRAYAN'),
      unitName: 'PLTD KRAYAN',
      token: 'token-operator-krayan',
    ),
    UserModel(
      id: 'OP3',
      name: 'Operator Tanah Merah',
      username: 'operator.tanahmerah',
      role: UserRole.operator,
      unitId: _requiredUnitId('PLTD TANAH MERAH'),
      unitName: 'PLTD TANAH MERAH',
      token: 'token-operator-tmr',
    ),
    UserModel(
      id: 'OP4',
      name: 'Operator Long Peso',
      username: 'operator.longpeso',
      role: UserRole.operator,
      unitId: _requiredUnitId('PLTD LONG PESO'),
      unitName: 'PLTD LONG PESO',
      token: 'token-operator-longpeso',
    ),
    UserModel(
      id: 'OP5',
      name: 'Operator Long Layu',
      username: 'operator.longlayu',
      role: UserRole.operator,
      unitId: _requiredUnitId('PLTD LONG LAYU'),
      unitName: 'PLTD LONG LAYU',
      token: 'token-operator-longlayu',
    ),
    UserModel(
      id: 'OP6',
      name: 'Operator Site 07',
      username: 'operator.site07',
      role: UserRole.operator,
      unitId: _requiredUnitId('PLTD BATU AMPAR'),
      unitName: 'PLTD BATU AMPAR',
      token: 'token-operator-site07',
    ),
    UserModel(
      id: 'SP1',
      name: 'Teddy',
      username: 'supervisor',
      role: UserRole.supervisor,
      unitId: _requiredUnitId('PLTD TANAH MERAH'),
      unitName: 'PLTD TANAH MERAH',
      token: 'token-supervisor',
    ),
    UserModel(
      id: 'AD1',
      name: 'Admin AMC OPKIT UP KAL 3',
      username: 'admin',
      role: UserRole.admin,
      unitId: _requiredUnitId('PLTD SEI MENGGARIS'),
      unitName: 'PLTD SEI MENGGARIS',
      token: 'token-admin',
    ),
    UserModel(
      id: 'SA1',
      name: 'Superadmin PLN Nusa Daya',
      username: 'superadmin',
      role: UserRole.superadmin,
      unitId: 'ALL',
      unitName: 'Semua Unit PLTD',
      token: 'token-superadmin',
    ),
  ];

  static List<MachineModel> machinesByUnit(String unitId) =>
      machines.where((item) => item.unitId == unitId).toList();

  static UserModel? authenticate(String username, String password) {
    if (password.trim() != '123') return null;
    try {
      return users.firstWhere(
        (user) => user.username == username.trim().toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  static String generateProofId(DateTime time) {
    final formatter = DateFormat('yyMMddHHmm');
    return 'NP-PLTD-${formatter.format(time)}-${time.millisecond.toString().padLeft(3, '0')}';
  }

  static List<LogsheetModel> seedLogsheets() {
    final now = DateTime.now();
    final operatorUsers = users.where((item) => item.isOperator).toList();

    return List<LogsheetModel>.generate(160, (index) {
      final unit = units[index % units.length];
      final machineList = machinesByUnit(unit.id);
      final machine = machineList[index % machineList.length];
      final matchingOperators = operatorUsers
          .where((item) => item.unitName == unit.name)
          .toList();
      final operator = matchingOperators.isNotEmpty
          ? matchingOperators[index % matchingOperators.length]
          : operatorUsers[(index ~/ 4) % operatorUsers.length];
      final submittedAt = now.subtract(
        Duration(days: index ~/ 24, hours: index % 24),
      );
      final machineStatus = parseMachineStatus(machine.conditionLabel);
      final isGangguan = machineStatus == MachineStatus.gangguanRusak;
      final capacityKw = _parseCapacityKw(machine.capacity);
      final double frequency = isGangguan
          ? 0
          : machineStatus == MachineStatus.standby
          ? 49.65 + ((index % 4) * 0.08)
          : 49.82 + ((index % 5) * 0.07);
      final double tegangan = isGangguan
          ? 0
          : machineStatus == MachineStatus.standby
          ? 360 + ((index * 2) % 16)
          : 380 + ((index * 3) % 36);
      final double bebanMesin = isGangguan
          ? 0
          : machineStatus == MachineStatus.standby
          ? _standbyLoad(capacityKw, index)
          : _operatingLoad(capacityKw, index);
      final abnormal =
          isGangguan ||
          frequency > 50.5 ||
          frequency < 49.4 ||
          tegangan == 0 ||
          index % 19 == 0;
      final reportStatus = abnormal
          ? ReportStatus.abnormal
          : (index % 8 == 0 ? ReportStatus.late : ReportStatus.onTime);
      final syncStatus = index % 11 == 0
          ? SyncStatus.pendingSync
          : index % 17 == 0
          ? SyncStatus.failed
          : SyncStatus.synced;
      final locationStatus = index % 21 == 0
          ? LocationStatus.outsideArea
          : index % 37 == 0
          ? LocationStatus.gpsOff
          : LocationStatus.valid;

      return LogsheetModel(
        id: 'remote-$index',
        localId: 'local-$index',
        proofId: generateProofId(submittedAt),
        operatorId: operator.id,
        operatorName: operator.name,
        unitId: unit.id,
        unitName: unit.name,
        machineId: machine.id,
        machineUp3: machine.up3,
        machineName: machine.machineName,
        machineBrand: machine.brand,
        machineType: machine.machineType,
        serialNumber: machine.serialNumber,
        machineGeneratorCode: machine.generatorCode,
        machineOwnershipStatus: machine.ownershipStatus,
        machinePerformanceLabel: machine.performanceLabel,
        machineInstalledCapacity: machine.capacity,
        machineAvailableCapacity: machine.availableCapacity,
        machineDispatchCapacity: machine.dispatchCapacity,
        machineConditionLabel: machine.conditionLabel,
        machineStatus: machineStatus,
        bebanMesin: bebanMesin,
        standKwh: isGangguan ? 0 : 10000 + (index * 143),
        standBbm: isGangguan ? 0 : 1800 + (index * 21),
        tekananOli: isGangguan
            ? 0
            : machineStatus == MachineStatus.standby
            ? 1.4 + ((index % 5) * 0.18)
            : 2.2 + ((index % 6) * 0.35),
        temperaturAir: isGangguan
            ? 0
            : machineStatus == MachineStatus.standby
            ? 48 + ((index % 4) * 2)
            : 72 + ((index % 8) * 3),
        phasaR: isGangguan
            ? 0
            : machineStatus == MachineStatus.standby
            ? (148 + (index % 12)).toDouble()
            : (175 + (index % 30)).toDouble(),
        phasaS: isGangguan
            ? 0
            : machineStatus == MachineStatus.standby
            ? (146 + (index % 12)).toDouble()
            : (173 + (index % 28)).toDouble(),
        phasaT: isGangguan
            ? 0
            : machineStatus == MachineStatus.standby
            ? (145 + (index % 12)).toDouble()
            : (171 + (index % 26)).toDouble(),
        tegangan: tegangan.toDouble(),
        cosPhi: isGangguan
            ? 0
            : machineStatus == MachineStatus.standby
            ? 0.52 + ((index % 4) * 0.04)
            : 0.78 + ((index % 5) * 0.04),
        frequency: frequency,
        notes: isGangguan
            ? 'Mesin mengalami gangguan/rusak dan menunggu tindak lanjut tim site.'
            : machineStatus == MachineStatus.standby
            ? 'Mesin standby sesuai master data pembangkit dan siap dioperasikan bila diperlukan.'
            : 'Operasi berjalan normal sesuai jadwal laporan.',
        selfiePhotoPath: '',
        machinePhotoPath: '',
        latitude:
            unit.latitude +
            (locationStatus == LocationStatus.outsideArea ? 0.008 : 0.0002),
        longitude:
            unit.longitude +
            (locationStatus == LocationStatus.outsideArea ? 0.008 : 0.0002),
        locationAccuracy: locationStatus == LocationStatus.gpsOff
            ? 0
            : 8 + (index % 8),
        distanceFromUnit: locationStatus == LocationStatus.outsideArea
            ? 650
            : 55 + (index % 120),
        locationStatus: locationStatus,
        submittedAt: submittedAt,
        syncStatus: syncStatus,
        reportStatus: reportStatus,
        abnormalNotes: isGangguan
            ? 'Status mesin Gangguan-Rusak. Parameter numerik otomatis tercatat 0.'
            : abnormal
            ? 'Frekuensi/tegangan atau indikator operasi berada di luar batas aman.'
            : '',
        createdAt: submittedAt,
        updatedAt: submittedAt,
        fieldCondition: isGangguan
            ? 'Unit perlu penanganan gangguan dan inspeksi lanjutan.'
            : machineStatus == MachineStatus.standby
            ? 'Mesin standby dan siap operasi sesuai kebutuhan sistem.'
            : 'Aman terkendali.',
        syncErrorMessage: syncStatus == SyncStatus.failed
            ? 'Koneksi API timeout saat sinkronisasi.'
            : null,
      );
    });
  }

  static Map<String, Map<String, String>> heatmap(DateTime date) {
    final slots = List<String>.generate(
      24,
      (index) => '${index.toString().padLeft(2, '0')}:00',
    );
    final data = <String, Map<String, String>>{};
    for (var unitIndex = 0; unitIndex < units.length; unitIndex++) {
      data[units[unitIndex].id] = {
        for (var hourIndex = 0; hourIndex < slots.length; hourIndex++)
          slots[hourIndex]: _heatValue(unitIndex, hourIndex),
      };
    }
    return data;
  }

  static String _heatValue(int unitIndex, int hourIndex) {
    if (hourIndex < 4) return 'inactive';
    final mix = (unitIndex * 7 + hourIndex) % 10;
    if (mix == 0) return 'warning';
    if (mix == 1 || mix == 2) return 'missing';
    return 'submitted';
  }

  static List<Map<String, dynamic>> notifications() {
    final now = DateTime.now();
    return [
      {
        'title': 'Operator belum submit',
        'description':
            'PLTD BATU AMPAR belum mengirim laporan jam ${DateFormat('HH:00').format(now)}.',
        'time': now.subtract(const Duration(minutes: 8)),
        'priority': 'tinggi',
        'read': false,
        'type': 'missing',
      },
      {
        'title': 'Parameter abnormal',
        'description':
            'Frekuensi di PLTD KRAYAN berada di luar rentang normal dan perlu observasi.',
        'time': now.subtract(const Duration(minutes: 40)),
        'priority': 'tinggi',
        'read': false,
        'type': 'abnormal',
      },
      {
        'title': 'GPS di luar area',
        'description':
            'Satu laporan dari PLTD LONG APARI terdeteksi di luar radius lokasi unit.',
        'time': now.subtract(const Duration(hours: 1, minutes: 15)),
        'priority': 'sedang',
        'read': false,
        'type': 'gps',
      },
      {
        'title': 'Sinkronisasi berhasil',
        'description':
            '12 logsheet offline berhasil terkirim ke server monitoring.',
        'time': now.subtract(const Duration(hours: 2)),
        'priority': 'sedang',
        'read': true,
        'type': 'sync',
      },
    ];
  }

  static String _requiredUnitId(String unitName) {
    final unitId = _unitIdByName[unitName];
    if (unitId == null) {
      throw StateError('Unit master tidak ditemukan untuk $unitName');
    }
    return unitId;
  }

  static double _generatedLatitude(int index) =>
      0.55 + ((index % 9) * 0.34) + ((index ~/ 9) * 0.06);

  static double _generatedLongitude(int index) =>
      115.85 + ((index % 8) * 0.24) + ((index ~/ 8) * 0.08);

  static double _parseCapacityKw(String capacity) {
    final numeric = capacity.replaceAll(RegExp(r'[^0-9]'), '');
    if (numeric.isEmpty) {
      return 100;
    }
    return double.tryParse(numeric) ?? 100;
  }

  static double _operatingLoad(double capacityKw, int index) {
    final baseLoad = capacityKw * 0.74;
    final variation = math.max(capacityKw * 0.06, 4);
    return double.parse(
      (baseLoad + ((index % 5) * variation * 0.35)).toStringAsFixed(2),
    );
  }

  static double _standbyLoad(double capacityKw, int index) {
    final baseLoad = capacityKw * 0.22;
    final variation = math.max(capacityKw * 0.04, 3);
    return double.parse(
      (baseLoad + ((index % 4) * variation * 0.28)).toStringAsFixed(2),
    );
  }
}
