import 'package:intl/intl.dart';

import '../models/app_enums.dart';
import '../models/logsheet_model.dart';
import '../models/machine_model.dart';
import '../models/unit_model.dart';
import '../models/user_model.dart';

class DummyData {
  DummyData._();

  static final List<
    ({String name, String locationName, double latitude, double longitude})
  >
  _fixedUnitSeeds = [
    (
      name: 'PLTD KRAYAN',
      locationName: 'Krayan, Kalimantan Utara',
      latitude: 3.8742,
      longitude: 115.7312,
    ),
    (
      name: 'PLTD TANAH MERAH',
      locationName: 'Tanah Merah, Kalimantan Utara',
      latitude: 2.8227,
      longitude: 117.3748,
    ),
    (
      name: 'PLTD SEI MENGGARIS',
      locationName: 'Sei Menggaris, Kalimantan Utara',
      latitude: 3.5009,
      longitude: 117.2411,
    ),
    (
      name: 'PLTD LONG PESO',
      locationName: 'Long Peso, Kalimantan Utara',
      latitude: 2.9343,
      longitude: 116.7941,
    ),
    (
      name: 'PLTD LONG LAYU',
      locationName: 'Long Layu, Kalimantan Utara',
      latitude: 3.5739,
      longitude: 115.7298,
    ),
    (
      name: 'PLTD PA UPAN',
      locationName: 'Pa Upan, Kalimantan Utara',
      latitude: 3.9113,
      longitude: 115.5524,
    ),
  ];

  static final List<String> _generatedUnitNames = [
    'PLTD BATU AMPAR',
    'PLTD BIDUK-BIDUK',
    'PLTD DATAH BILANG',
    'PLTD KAYAN HULU',
    'PLTD LONG BAGUN',
    'PLTD LONG APARI',
    'PLTD MARATUA',
    'PLTD MUARA WAHAU',
    'PLTD SANGKULIRANG',
    'PLTD TELUK PANDAN',
    'PLTD SANDARAN',
    'PLTD MUARA BENGKAL',
    'PLTD MUARA ANCALONG',
    'PLTD MUARA KAMAN',
    'PLTD KONGEB',
    'PLTD TABANG',
    'PLTD TULIN ONSOI',
    'PLTD MENTARANG',
    'PLTD MALINAU KOTA',
    'PLTD SESAYAP',
    'PLTD SEBATIK',
    'PLTD NUNUKAN',
    'PLTD TANJUNG SELOR',
    'PLTD TARAKAN',
    'PLTD SAMARINDA HULU',
    'PLTD BONTANG KUALA',
    'PLTD BERAU PESISIR',
    'PLTD PASER UTARA',
    'PLTD PENAJAM',
    'PLTD KUTAI BARAT',
    'PLTD KUTAI TIMUR',
    'PLTD MAHAKAM ULU',
    'PLTD LONG IRAM',
    'PLTD MUARA PAHU',
  ];

  static final List<UnitModel> units = [
    ...List<UnitModel>.generate(_fixedUnitSeeds.length, (index) {
      final seed = _fixedUnitSeeds[index];
      return UnitModel(
        id: 'U${(index + 1).toString().padLeft(2, '0')}',
        name: seed.name,
        locationName: seed.locationName,
        latitude: seed.latitude,
        longitude: seed.longitude,
        radiusMeter: 250 + ((index % 3) * 25),
        status: 'active',
      );
    }),
    ...List<UnitModel>.generate(_generatedUnitNames.length, (index) {
      final overallIndex = index + _fixedUnitSeeds.length;
      final latitude = 0.45 + ((overallIndex % 8) * 0.42);
      final longitude = 116.05 + ((overallIndex % 10) * 0.23);
      final region = overallIndex.isEven
          ? 'Kalimantan Timur'
          : 'Kalimantan Utara';
      return UnitModel(
        id: 'U${(overallIndex + 1).toString().padLeft(2, '0')}',
        name: _generatedUnitNames[index],
        locationName:
            '${_generatedUnitNames[index].replaceFirst('PLTD ', '')}, $region',
        latitude: latitude,
        longitude: longitude,
        radiusMeter: 225 + ((overallIndex % 4) * 25),
        status: 'active',
      );
    }),
  ];

  static final List<MachineModel> machines = List<MachineModel>.generate(
    units.length * 5,
    (index) {
      final unit = units[index ~/ 5];
      final unitIndex = index ~/ 5;
      final machineNo = (index % 5) + 1;
      final brand = _machineBrandFor(machineNo);
      return MachineModel(
        id: 'M${(index + 1).toString().padLeft(3, '0')}',
        unitId: unit.id,
        serialNumber:
            '$brand-${unit.id}-SN${machineNo.toString().padLeft(2, '0')}',
        capacity: _machineCapacityFor(unitIndex, machineNo),
        status: machineNo == 5 && unitIndex.isOdd ? 'standby' : 'active',
      );
    },
  );

  static final List<UserModel> users = [
    const UserModel(
      id: 'OP1',
      name: 'Rahman Safrizal',
      username: 'operator',
      role: UserRole.operator,
      unitId: 'U01',
      unitName: 'PLTD KRAYAN',
      token: 'token-operator',
    ),
    const UserModel(
      id: 'OP2',
      name: 'Operator Krayan',
      username: 'operator.krayan',
      role: UserRole.operator,
      unitId: 'U01',
      unitName: 'PLTD KRAYAN',
      token: 'token-operator-krayan',
    ),
    const UserModel(
      id: 'OP3',
      name: 'Operator Tanah Merah',
      username: 'operator.tanahmerah',
      role: UserRole.operator,
      unitId: 'U02',
      unitName: 'PLTD TANAH MERAH',
      token: 'token-operator-tmr',
    ),
    const UserModel(
      id: 'OP4',
      name: 'Operator Long Peso',
      username: 'operator.longpeso',
      role: UserRole.operator,
      unitId: 'U04',
      unitName: 'PLTD LONG PESO',
      token: 'token-operator-longpeso',
    ),
    const UserModel(
      id: 'OP5',
      name: 'Operator Long Layu',
      username: 'operator.longlayu',
      role: UserRole.operator,
      unitId: 'U05',
      unitName: 'PLTD LONG LAYU',
      token: 'token-operator-longlayu',
    ),
    const UserModel(
      id: 'OP6',
      name: 'Operator Site 07',
      username: 'operator.site07',
      role: UserRole.operator,
      unitId: 'U07',
      unitName: 'PLTD BATU AMPAR',
      token: 'token-operator-site07',
    ),
    const UserModel(
      id: 'SP1',
      name: 'Teddy',
      username: 'supervisor',
      role: UserRole.supervisor,
      unitId: 'U02',
      unitName: 'PLTD TANAH MERAH',
      token: 'token-supervisor',
    ),
    const UserModel(
      id: 'AD1',
      name: 'Admin AMC OPKIT UP KAL 3',
      username: 'admin',
      role: UserRole.admin,
      unitId: 'U03',
      unitName: 'PLTD SEI MENGGARIS',
      token: 'token-admin',
    ),
    const UserModel(
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
    return 'PLTD-${formatter.format(time)}-${time.millisecond.toString().padLeft(3, '0')}';
  }

  static List<LogsheetModel> seedLogsheets() {
    final now = DateTime.now();
    final operatorUsers = users.where((item) => item.isOperator).toList();

    return List<LogsheetModel>.generate(160, (index) {
      final unit = units[index % units.length];
      final machineList = machinesByUnit(unit.id);
      final machine = machineList[index % machineList.length];
      final operator = operatorUsers[(index ~/ 4) % operatorUsers.length];
      final submittedAt = now.subtract(
        Duration(days: index ~/ 24, hours: index % 24),
      );
      final frequency = 49.35 + ((index % 7) * 0.21);
      final tegangan = index % 19 == 0 ? 0 : 380 + ((index * 3) % 36);
      final abnormal =
          frequency > 50.5 ||
          frequency < 49.5 ||
          tegangan == 0 ||
          index % 13 == 0;
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
        serialNumber: machine.serialNumber,
        bebanMesin: 650 + ((index * 17) % 980),
        standKwh: 10000 + (index * 143),
        standBbm: 1800 + (index * 21),
        tekananOli: 2.2 + ((index % 6) * 0.35),
        temperaturAir: 72 + ((index % 8) * 3),
        phasaR: (175 + (index % 30)).toDouble(),
        phasaS: (173 + (index % 28)).toDouble(),
        phasaT: (171 + (index % 26)).toDouble(),
        tegangan: tegangan.toDouble(),
        cosPhi: 0.78 + ((index % 5) * 0.04),
        frequency: frequency,
        notes: abnormal
            ? 'Perlu pengecekan parameter dan koordinasi ke supervisor.'
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
        abnormalNotes: abnormal
            ? 'Frekuensi/tegangan atau indikator operasi berada di luar batas aman.'
            : '',
        createdAt: submittedAt,
        updatedAt: submittedAt,
        fieldCondition: abnormal
            ? 'Perlu observasi lanjutan dan pengecekan site.'
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
            'Satu laporan dari PLTD LONG BAGUN terdeteksi di luar radius lokasi unit.',
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

  static String _machineBrandFor(int machineNo) {
    const brands = ['CAT3516', 'MTU16V', 'CUMMINS', 'YANMAR', 'PERKINS'];
    return brands[(machineNo - 1) % brands.length];
  }

  static String _machineCapacityFor(int unitIndex, int machineNo) {
    const capacities = ['800 kW', '900 kW', '1.2 MW', '1.5 MW', '2.0 MW'];
    return capacities[(unitIndex + machineNo - 1) % capacities.length];
  }
}
