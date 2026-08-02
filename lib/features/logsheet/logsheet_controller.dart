import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/network/api_exception.dart';
import '../../core/utils/number_helper.dart';
import '../../data/local/hive_service.dart';
import '../../data/models/app_enums.dart';
import '../../data/models/logsheet_model.dart';
import '../../data/models/machine_model.dart';
import '../../data/models/unit_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/logsheet_repository.dart';
import '../location/location_service.dart';

class MachineDraftSnapshot {
  const MachineDraftSnapshot({
    this.localId = '',
    this.proofId = '',
    this.machineStatus,
    this.values = const {},
    this.notes = '',
    this.fieldCondition = '',
    this.selfiePath = '',
    this.machinePhotoPath = '',
    this.location,
  });

  final String localId;
  final String proofId;
  final MachineStatus? machineStatus;
  final Map<String, String> values;
  final String notes;
  final String fieldCondition;
  final String selfiePath;
  final String machinePhotoPath;
  final LocationValidationResult? location;

  MachineDraftSnapshot copyWith({
    String? localId,
    String? proofId,
    MachineStatus? machineStatus,
    Map<String, String>? values,
    String? notes,
    String? fieldCondition,
    String? selfiePath,
    String? machinePhotoPath,
    LocationValidationResult? location,
  }) {
    return MachineDraftSnapshot(
      localId: localId ?? this.localId,
      proofId: proofId ?? this.proofId,
      machineStatus: machineStatus ?? this.machineStatus,
      values: values ?? this.values,
      notes: notes ?? this.notes,
      fieldCondition: fieldCondition ?? this.fieldCondition,
      selfiePath: selfiePath ?? this.selfiePath,
      machinePhotoPath: machinePhotoPath ?? this.machinePhotoPath,
      location: location ?? this.location,
    );
  }

  factory MachineDraftSnapshot.fromLogsheet(LogsheetModel logsheet) {
    return MachineDraftSnapshot(
      localId: logsheet.localId,
      proofId: logsheet.proofId,
      machineStatus: logsheet.machineStatus,
      values: {
        'bebanMesin': logsheet.bebanMesin.toString(),
        'standKwh': logsheet.standKwh.toString(),
        'standBbm': logsheet.standBbm.toString(),
        'tekananOli': logsheet.tekananOli.toString(),
        'temperaturAir': logsheet.temperaturAir.toString(),
        'phasaR': logsheet.phasaR.toString(),
        'phasaS': logsheet.phasaS.toString(),
        'phasaT': logsheet.phasaT.toString(),
        'tegangan': logsheet.tegangan.toString(),
        'cosPhi': logsheet.cosPhi.toString(),
        'frequency': logsheet.frequency.toString(),
        'notes': logsheet.notes,
        'fieldCondition': logsheet.fieldCondition,
      },
      notes: logsheet.notes,
      fieldCondition: logsheet.fieldCondition,
      selfiePath: logsheet.selfiePhotoPath,
      machinePhotoPath: logsheet.machinePhotoPath,
      location: LocationValidationResult(
        latitude: logsheet.latitude,
        longitude: logsheet.longitude,
        accuracy: logsheet.locationAccuracy,
        distanceFromUnit: logsheet.distanceFromUnit,
        status: logsheet.locationStatus,
        gpsEnabled: true,
        permissionGranted: true,
        fullAddress: logsheet.unitName,
      ),
    );
  }
}

class LogsheetFormState {
  static const _unset = Object();

  const LogsheetFormState({
    this.selectedUnit,
    this.selectedMachine,
    this.machineStatus,
    this.selectedTimeSlot = '',
    this.selectedDate,
    this.values = const {},
    this.notes = '',
    this.fieldCondition = '',
    this.selfiePath = '',
    this.machinePhotoPath = '',
    this.location,
    this.sharedSelfiePath = '',
    this.sharedMachinePhotoPath = '',
    this.sharedLocation,
    this.machineSnapshots = const {},
    this.currentLocalId = '',
    this.currentProofId = '',
    this.sessionId = '',
    this.isEditMode = false,
    this.isSaving = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.submittingMachineLabel,
  });

  final UnitModel? selectedUnit;
  final MachineModel? selectedMachine;
  final MachineStatus? machineStatus;
  final String selectedTimeSlot;
  final DateTime? selectedDate;
  final Map<String, String> values;
  final String notes;
  final String fieldCondition;
  final String selfiePath;
  final String machinePhotoPath;
  final LocationValidationResult? location;
  final String sharedSelfiePath;
  final String sharedMachinePhotoPath;
  final LocationValidationResult? sharedLocation;
  final Map<String, MachineDraftSnapshot> machineSnapshots;
  final String currentLocalId;
  final String currentProofId;
  final String sessionId;
  final bool isEditMode;
  final bool isSaving;
  final bool isSubmitting;
  final String? errorMessage;
  final String? submittingMachineLabel;

  List<String> get warnings => LogsheetController.buildWarnings(
    values: values,
    machineStatus: machineStatus,
  );

  bool get isUsingSharedSelfie =>
      sharedSelfiePath.isNotEmpty && selfiePath == sharedSelfiePath;

  bool get isUsingSharedMachinePhoto =>
      machineStatus != MachineStatus.gangguanRusak &&
      sharedMachinePhotoPath.isNotEmpty &&
      machinePhotoPath == sharedMachinePhotoPath;

  bool get isUsingSharedLocation =>
      location != null &&
      sharedLocation != null &&
      location!.latitude == sharedLocation!.latitude &&
      location!.longitude == sharedLocation!.longitude;

  LogsheetFormState copyWith({
    Object? selectedUnit = _unset,
    Object? selectedMachine = _unset,
    Object? machineStatus = _unset,
    String? selectedTimeSlot,
    DateTime? selectedDate,
    Map<String, String>? values,
    String? notes,
    String? fieldCondition,
    String? selfiePath,
    String? machinePhotoPath,
    Object? location = _unset,
    String? sharedSelfiePath,
    String? sharedMachinePhotoPath,
    Object? sharedLocation = _unset,
    Map<String, MachineDraftSnapshot>? machineSnapshots,
    String? currentLocalId,
    String? currentProofId,
    String? sessionId,
    bool? isEditMode,
    bool? isSaving,
    bool? isSubmitting,
    Object? errorMessage = _unset,
    bool clearError = false,
    Object? submittingMachineLabel = _unset,
  }) {
    return LogsheetFormState(
      selectedUnit: identical(selectedUnit, _unset)
          ? this.selectedUnit
          : selectedUnit as UnitModel?,
      selectedMachine: identical(selectedMachine, _unset)
          ? this.selectedMachine
          : selectedMachine as MachineModel?,
      machineStatus: identical(machineStatus, _unset)
          ? this.machineStatus
          : machineStatus as MachineStatus?,
      selectedTimeSlot: selectedTimeSlot ?? this.selectedTimeSlot,
      selectedDate: selectedDate ?? this.selectedDate,
      values: values ?? this.values,
      notes: notes ?? this.notes,
      fieldCondition: fieldCondition ?? this.fieldCondition,
      selfiePath: selfiePath ?? this.selfiePath,
      machinePhotoPath: machinePhotoPath ?? this.machinePhotoPath,
      location: identical(location, _unset)
          ? this.location
          : location as LocationValidationResult?,
      sharedSelfiePath: sharedSelfiePath ?? this.sharedSelfiePath,
      sharedMachinePhotoPath:
          sharedMachinePhotoPath ?? this.sharedMachinePhotoPath,
      sharedLocation: identical(sharedLocation, _unset)
          ? this.sharedLocation
          : sharedLocation as LocationValidationResult?,
      machineSnapshots: machineSnapshots ?? this.machineSnapshots,
      currentLocalId: currentLocalId ?? this.currentLocalId,
      currentProofId: currentProofId ?? this.currentProofId,
      sessionId: sessionId ?? this.sessionId,
      isEditMode: isEditMode ?? this.isEditMode,
      isSaving: isSaving ?? this.isSaving,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError
          ? null
          : identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      submittingMachineLabel: identical(submittingMachineLabel, _unset)
          ? this.submittingMachineLabel
          : submittingMachineLabel as String?,
    );
  }
}

final logsheetControllerProvider =
    StateNotifierProvider<LogsheetController, LogsheetFormState>((ref) {
      return LogsheetController(
        ref.read(logsheetRepositoryProvider),
        ref.read(hiveServiceProvider),
      );
    });

class LogsheetController extends StateNotifier<LogsheetFormState> {
  LogsheetController(this._repository, this._hiveService)
    : super(const LogsheetFormState());

  static const numericParameterKeys = [
    'bebanMesin',
    'standKwh',
    'standBbm',
    'tekananOli',
    'temperaturAir',
    'phasaR',
    'phasaS',
    'phasaT',
    'tegangan',
    'cosPhi',
    'frequency',
  ];

  static const requiredTextKeys = ['notes', 'fieldCondition'];

  static const _baseRequiredFieldLabels = {
    'bebanMesin': 'Beban mesin',
    'standKwh': 'Stand KWH',
    'standBbm': 'Stand BBM',
    'tekananOli': 'Tekanan oli',
    'temperaturAir': 'Temperatur air',
    'phasaR': 'Phasa R',
    'phasaS': 'Phasa S',
    'phasaT': 'Phasa T',
    'tegangan': 'Tegangan',
    'cosPhi': 'Cos Phi',
    'frequency': 'Frekuensi',
    'notes': 'Catatan operator',
  };

  final LogsheetRepository _repository;
  final HiveService _hiveService;
  final _uuid = const Uuid();

  static List<String> buildWarnings({
    required Map<String, String> values,
    required MachineStatus? machineStatus,
  }) {
    if (machineStatus == MachineStatus.gangguanRusak) {
      return const [
        'Status mesin Gangguan-Rusak aktif. Semua parameter numerik otomatis diisi 0.',
      ];
    }

    final list = <String>[];
    final frequency = NumberHelper.parse(values['frequency']);
    final voltage = NumberHelper.parse(values['tegangan']);
    final temp = NumberHelper.parse(values['temperaturAir']);
    final oil = NumberHelper.parse(values['tekananOli']);
    final beban = NumberHelper.parse(values['bebanMesin']);
    final phasaR = NumberHelper.parse(values['phasaR']);
    final phasaS = NumberHelper.parse(values['phasaS']);
    final phasaT = NumberHelper.parse(values['phasaT']);

    if (frequency != 0 && (frequency < 49.5 || frequency > 50.5)) {
      list.add('Frekuensi berada di luar rentang 49.5 - 50.5 Hz.');
    }
    if (voltage == 0) {
      list.add('Tegangan masih kosong atau bernilai 0.');
    }
    if (temp > 90) {
      list.add('Temperatur air terlalu tinggi.');
    }
    if (oil > 0 && oil < 2.5) {
      list.add('Tekanan oli terlalu rendah.');
    }
    if ((phasaR - phasaS).abs() > 10 || (phasaS - phasaT).abs() > 10) {
      list.add('Phasa R/S/T tidak seimbang.');
    }
    if (beban == 0) {
      list.add('Beban mesin belum diisi.');
    }
    return list;
  }

  void setUnit(UnitModel? unit) {
    final sameUnit = unit?.id == state.selectedUnit?.id;
    state = state.copyWith(
      selectedUnit: unit,
      selectedMachine: null,
      machineStatus: null,
      values: const {},
      notes: '',
      fieldCondition: '',
      selfiePath: '',
      machinePhotoPath: '',
      location: null,
      sharedSelfiePath: sameUnit ? state.sharedSelfiePath : '',
      sharedMachinePhotoPath: sameUnit ? state.sharedMachinePhotoPath : '',
      sharedLocation: sameUnit ? state.sharedLocation : null,
      currentLocalId: '',
      currentProofId: '',
      sessionId: unit == null
          ? ''
          : sameUnit && state.sessionId.isNotEmpty
          ? state.sessionId
          : _uuid.v4(),
      machineSnapshots: sameUnit ? state.machineSnapshots : const {},
      isEditMode: false,
      clearError: true,
    );
  }

  void setMachine(MachineModel? machine) {
    final snapshots = _snapshotsWithCurrent();
    if (machine == null) {
      state = state.copyWith(
        machineSnapshots: snapshots,
        selectedMachine: null,
        machineStatus: null,
        values: const {},
        notes: '',
        fieldCondition: '',
        selfiePath: '',
        machinePhotoPath: '',
        location: null,
        currentLocalId: '',
        currentProofId: '',
        clearError: true,
      );
      return;
    }

    final snapshot = snapshots[machine.id];
    final nextStatus = snapshot?.machineStatus ??
        parseMachineStatus(
          machine.conditionLabel.isEmpty ? machine.status : machine.conditionLabel,
        );
    final values = Map<String, String>.from(snapshot?.values ?? const {});
    if (nextStatus == MachineStatus.gangguanRusak) {
      for (final key in numericParameterKeys) {
        values[key] = values[key]?.trim().isNotEmpty == true ? values[key]! : '0';
      }
    }

    state = state.copyWith(
      machineSnapshots: snapshots,
      selectedMachine: machine,
      machineStatus: nextStatus,
      values: values,
      notes: snapshot?.notes ?? values['notes'] ?? '',
      fieldCondition: snapshot?.fieldCondition ?? values['fieldCondition'] ?? '',
      selfiePath: snapshot?.selfiePath ?? state.sharedSelfiePath,
      machinePhotoPath: snapshot?.machinePhotoPath ??
          (nextStatus == MachineStatus.gangguanRusak
              ? ''
              : state.sharedMachinePhotoPath),
      location: snapshot?.location ?? state.sharedLocation,
      currentLocalId: snapshot?.localId ?? '',
      currentProofId: snapshot?.proofId ?? '',
      clearError: true,
    );
    _syncCurrentSnapshot();
  }

  void loadExistingLogsheet({
    required LogsheetModel logsheet,
    required UnitModel unit,
    required MachineModel machine,
  }) {
    final snapshot = MachineDraftSnapshot.fromLogsheet(logsheet);
    state = state.copyWith(
      selectedUnit: unit,
      selectedMachine: machine,
      machineStatus: snapshot.machineStatus,
      values: snapshot.values,
      notes: snapshot.notes,
      fieldCondition: snapshot.fieldCondition,
      selfiePath: snapshot.selfiePath,
      machinePhotoPath: snapshot.machinePhotoPath,
      location: snapshot.location,
      sharedSelfiePath: snapshot.selfiePath,
      sharedMachinePhotoPath:
          snapshot.machineStatus == MachineStatus.gangguanRusak
          ? ''
          : snapshot.machinePhotoPath,
      sharedLocation: snapshot.location,
      currentLocalId: snapshot.localId,
      currentProofId: snapshot.proofId,
      sessionId: logsheet.sessionId.isEmpty ? _uuid.v4() : logsheet.sessionId,
      machineSnapshots: {machine.id: snapshot},
      isEditMode: true,
      clearError: true,
    );
  }

  void setValue(String key, String value) {
    if (state.machineStatus == MachineStatus.gangguanRusak &&
        numericParameterKeys.contains(key)) {
      return;
    }
    final values = Map<String, String>.from(state.values)..[key] = value;
    state = state.copyWith(values: values, clearError: true);
    _syncCurrentSnapshot();
  }

  void setMachineStatus(MachineStatus? status) {
    final values = Map<String, String>.from(state.values);
    var nextMachinePhotoPath = state.machinePhotoPath;
    final wasGangguan = state.machineStatus == MachineStatus.gangguanRusak;
    if (status == MachineStatus.gangguanRusak) {
      for (final key in numericParameterKeys) {
        values[key] = '0';
      }
      nextMachinePhotoPath = '';
    } else if (wasGangguan) {
      for (final key in numericParameterKeys) {
        if ((values[key] ?? '').trim() == '0') {
          values[key] = '';
        }
      }
    } else if (status != null &&
        nextMachinePhotoPath.isEmpty &&
        state.sharedMachinePhotoPath.isNotEmpty) {
      nextMachinePhotoPath = state.sharedMachinePhotoPath;
    }
    state = state.copyWith(
      machineStatus: status,
      values: values,
      machinePhotoPath: nextMachinePhotoPath,
      clearError: true,
    );
    _syncCurrentSnapshot();
  }

  void setNotes(String value) {
    state = state.copyWith(notes: value);
    _syncCurrentSnapshot();
  }

  void setFieldCondition(String value) {
    state = state.copyWith(fieldCondition: value);
    _syncCurrentSnapshot();
  }

  void setSelfie(String path) {
    final snapshots = _copySharedSelfieToSnapshots(path);
    state = state.copyWith(
      selfiePath: path,
      sharedSelfiePath: path,
      machineSnapshots: snapshots,
      clearError: true,
    );
  }

  void setMachinePhoto(String path) {
    if (state.machineStatus == MachineStatus.gangguanRusak) {
      state = state.copyWith(machinePhotoPath: path, clearError: true);
      _syncCurrentSnapshot();
      return;
    }

    final snapshots = _copySharedMachinePhotoToSnapshots(path);
    state = state.copyWith(
      machinePhotoPath: path,
      sharedMachinePhotoPath: path,
      machineSnapshots: snapshots,
      clearError: true,
    );
  }

  void setLocation(LocationValidationResult value) {
    final snapshots = _copySharedLocationToSnapshots(value);
    state = state.copyWith(
      location: value,
      sharedLocation: value,
      machineSnapshots: snapshots,
      clearError: true,
    );
  }

  void setTimeSlot(String timeSlot) {
    state = state.copyWith(selectedTimeSlot: timeSlot, clearError: true);
  }

  void setDate(DateTime date) {
    state = state.copyWith(selectedDate: date, clearError: true);
  }

  String? validateForDraft() {
    if (state.selectedUnit == null) return 'Unit wajib dipilih';
    if (state.selectedMachine == null) return 'Mesin wajib dipilih';
    if (state.machineStatus == null) return 'Status mesin wajib dipilih';
    return null;
  }

  String? validate() {
    final draftValidation = validateForDraft();
    if (draftValidation != null) {
      return draftValidation;
    }
    return validateSnapshot(_currentSnapshotOrNull());
  }

  String? validateSnapshot(
    MachineDraftSnapshot? snapshot, {
    bool requireAttachments = false,
  }) {
    if (snapshot == null) return 'Data mesin belum tersedia';
    if (snapshot.machineStatus == null) return 'Status mesin wajib dipilih';

    for (final key in [...numericParameterKeys, ...requiredTextKeys]) {
      if ((snapshot.values[key] ?? '').trim().isEmpty) {
        return '${_requiredFieldLabel(key)} wajib diisi';
      }
    }
    // Attachments (Photos & GPS) are optional per field feedback so submission is never blocked
    if (requireAttachments) {
      if (snapshot.selfiePath.isEmpty && snapshot.machinePhotoPath.isEmpty) {
        // Optional notice if needed, but not blocking
      }
    }
    return null;
  }

  String _requiredFieldLabel(String key) {
    if (key == 'fieldCondition') {
      return _operatorFieldLabel.toLowerCase();
    }
    return _baseRequiredFieldLabels[key] ?? 'Field';
  }

  String get _operatorFieldLabel {
    final raw = _hiveService.settingsBox.get(
      'operator_field_label',
      defaultValue: 'Nama Petugas Operator',
    );
    return raw?.toString().trim().isNotEmpty == true
        ? raw.toString().trim()
        : 'Nama Petugas Operator';
  }

  int completedMachineCount(List<MachineModel> machines) {
    final snapshots = _snapshotsWithCurrent();
    var count = 0;
    for (final machine in machines) {
      final snapshot = snapshots[machine.id];
      if (validateSnapshot(snapshot) == null) {
        count++;
      }
    }
    return count;
  }

  bool isMachineReady(String machineId) {
    final snapshot = _snapshotsWithCurrent()[machineId];
    return validateSnapshot(snapshot) == null;
  }

  LogsheetModel buildLogsheet(UserModel user) {
    final machine = state.selectedMachine!;
    final snapshot = _currentSnapshotOrNull()!;
    return _buildLogsheetForSnapshot(user, machine, snapshot);
  }

  LogsheetModel _buildLogsheetForSnapshot(
    UserModel user,
    MachineModel machine,
    MachineDraftSnapshot snapshot,
  ) {
    final now = DateTime.now();
    final values = snapshot.values;
    final reportStatus = snapshot.machineStatus == MachineStatus.gangguanRusak ||
            buildWarnings(values: values, machineStatus: snapshot.machineStatus)
                .isNotEmpty
        ? ReportStatus.abnormal
        : now.minute > 10
        ? ReportStatus.late
        : ReportStatus.onTime;

    final date = state.selectedDate ?? now;
    final timeSlot = state.selectedTimeSlot.isNotEmpty
        ? state.selectedTimeSlot
        : '${now.hour.toString().padLeft(2, '0')}:00';
    final timeParts = timeSlot.split(':');
    final hour = timeParts.length >= 2 ? int.tryParse(timeParts[0]) ?? now.hour : now.hour;
    final minute = timeParts.length >= 2 ? int.tryParse(timeParts[1]) ?? 0 : 0;
    final targetSubmittedAt = DateTime(date.year, date.month, date.day, hour, minute);

    return LogsheetModel(
      id: '',
      localId: snapshot.localId.isEmpty ? _uuid.v4() : snapshot.localId,
      proofId: snapshot.proofId,
      operatorId: user.id,
      operatorName: user.name,
      unitId: state.selectedUnit!.id,
      unitName: state.selectedUnit!.name,
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
      machineStatus: snapshot.machineStatus ?? MachineStatus.operasi,
      bebanMesin: NumberHelper.parse(values['bebanMesin']),
      standKwh: NumberHelper.parse(values['standKwh']),
      standBbm: NumberHelper.parse(values['standBbm']),
      tekananOli: NumberHelper.parse(values['tekananOli']),
      temperaturAir: NumberHelper.parse(values['temperaturAir']),
      phasaR: NumberHelper.parse(values['phasaR']),
      phasaS: NumberHelper.parse(values['phasaS']),
      phasaT: NumberHelper.parse(values['phasaT']),
      tegangan: NumberHelper.parse(values['tegangan']),
      cosPhi: NumberHelper.parse(values['cosPhi']),
      frequency: NumberHelper.parse(values['frequency']),
      notes: values['notes'] ?? snapshot.notes,
      selfiePhotoPath: snapshot.selfiePath,
      machinePhotoPath: snapshot.machinePhotoPath,
      latitude: snapshot.location?.latitude ?? 0,
      longitude: snapshot.location?.longitude ?? 0,
      locationAccuracy: snapshot.location?.accuracy ?? 0,
      distanceFromUnit: snapshot.location?.distanceFromUnit ?? 0,
      locationStatus: snapshot.location?.status ?? LocationStatus.unknown,
      submittedAt: targetSubmittedAt,
      syncStatus: SyncStatus.draft,
      reportStatus: reportStatus,
      abnormalNotes: buildWarnings(
        values: values,
        machineStatus: snapshot.machineStatus,
      ).join(' '),
      createdAt: now,
      updatedAt: now,
      fieldCondition: values['fieldCondition'] ?? snapshot.fieldCondition,
      sessionId: state.sessionId,
      approvalStatus: ApprovalStatus.pendingReview,
      rejectionReason: '',
      lastEditedBy: user.name,
      lastEditedAt: snapshot.localId.isEmpty ? null : now,
    );
  }

  Future<SubmissionResult?> saveDraft(UserModel user) async {
    final validation = validateForDraft();
    if (validation != null) {
      state = state.copyWith(errorMessage: validation);
      return null;
    }

    try {
      state = state.copyWith(isSaving: true, clearError: true);
      final previous = state.currentLocalId.isEmpty
          ? null
          : await _repository.getByLocalId(state.currentLocalId);
      final result = await _repository.saveDraft(
        buildLogsheet(user),
        previous: previous,
        editor: user,
      );
      _applySavedLogsheet(result.logsheet);
      state = state.copyWith(isSaving: false);
      return result;
    } catch (error) {
      final apiError = ApiException.fromObject(
        error,
        fallbackMessage: 'Draft belum berhasil disimpan.',
      );
      state = state.copyWith(
        isSaving: false,
        errorMessage: apiError.message,
      );
      return null;
    }
  }

  Future<List<SubmissionResult>> submitAll(
    UserModel user,
    List<MachineModel> machines,
  ) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    final results = <SubmissionResult>[];
    final snapshots = _snapshotsWithCurrent();
    String? firstError;

    for (final machine in machines) {
      final snapshot = snapshots[machine.id];
      final validation = validateSnapshot(snapshot);
      if (snapshot == null || validation != null) {
        firstError ??= validation ?? 'Data mesin ${machine.shortLabel} belum lengkap';
        continue;
      }

      try {
        state = state.copyWith(submittingMachineLabel: machine.shortLabel);
        final previous = snapshot.localId.isEmpty
            ? null
            : await _repository.getByLocalId(snapshot.localId);
        final result = await _repository.submit(
          _buildLogsheetForSnapshot(user, machine, snapshot),
          previous: previous,
          editor: user,
        );
        results.add(result);
        snapshots[machine.id] = MachineDraftSnapshot.fromLogsheet(result.logsheet);
      } catch (error) {
        final apiError = ApiException.fromObject(
          error,
          fallbackMessage: 'Mesin ${machine.shortLabel} gagal diproses.',
        );
        firstError ??= apiError.message;
      }
    }

    final selectedMachine = state.selectedMachine;
    if (selectedMachine != null && snapshots[selectedMachine.id] != null) {
      final current = snapshots[selectedMachine.id]!;
      state = state.copyWith(
        machineSnapshots: snapshots,
        currentLocalId: current.localId,
        currentProofId: current.proofId,
        isSubmitting: false,
        errorMessage: firstError,
        submittingMachineLabel: null,
      );
    } else {
      state = state.copyWith(
        machineSnapshots: snapshots,
        isSubmitting: false,
        errorMessage: firstError,
        submittingMachineLabel: null,
      );
    }
    return results;
  }

  Future<SubmissionResult?> submit(UserModel user) async {
    final validation = validate();
    if (validation != null) {
      state = state.copyWith(errorMessage: validation);
      return null;
    }

    try {
      state = state.copyWith(isSubmitting: true, clearError: true);
      final previous = state.currentLocalId.isEmpty
          ? null
          : await _repository.getByLocalId(state.currentLocalId);
      final result = await _repository.submit(
        buildLogsheet(user),
        previous: previous,
        editor: user,
      );
      _applySavedLogsheet(result.logsheet);
      state = state.copyWith(isSubmitting: false);
      return result;
    } catch (error) {
      final apiError = ApiException.fromObject(
        error,
        fallbackMessage: 'Logsheet belum berhasil dikirim.',
      );
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: apiError.message,
      );
      return null;
    }
  }

  void reset() => state = const LogsheetFormState();

  MachineDraftSnapshot? _currentSnapshotOrNull() {
    if (state.selectedMachine == null) return null;
    return MachineDraftSnapshot(
      localId: state.currentLocalId,
      proofId: state.currentProofId,
      machineStatus: state.machineStatus,
      values: state.values,
      notes: state.notes,
      fieldCondition: state.fieldCondition,
      selfiePath: state.selfiePath,
      machinePhotoPath: state.machinePhotoPath,
      location: state.location,
    );
  }

  Map<String, MachineDraftSnapshot> _snapshotsWithCurrent() {
    final snapshots = Map<String, MachineDraftSnapshot>.from(state.machineSnapshots);
    if (state.selectedMachine != null) {
      snapshots[state.selectedMachine!.id] = _currentSnapshotOrNull()!;
    }
    return snapshots;
  }

  void _syncCurrentSnapshot() {
    if (state.selectedMachine == null) return;
    final snapshots = Map<String, MachineDraftSnapshot>.from(state.machineSnapshots)
      ..[state.selectedMachine!.id] = _currentSnapshotOrNull()!;
    state = state.copyWith(machineSnapshots: snapshots);
  }

  Map<String, MachineDraftSnapshot> _copySharedSelfieToSnapshots(String path) {
    final snapshots = _snapshotsWithCurrent();
    return snapshots.map(
      (key, snapshot) => MapEntry(key, snapshot.copyWith(selfiePath: path)),
    );
  }

  Map<String, MachineDraftSnapshot> _copySharedMachinePhotoToSnapshots(
    String path,
  ) {
    final snapshots = _snapshotsWithCurrent();
    return snapshots.map((key, snapshot) {
      if (snapshot.machineStatus == MachineStatus.gangguanRusak) {
        return MapEntry(key, snapshot);
      }
      return MapEntry(key, snapshot.copyWith(machinePhotoPath: path));
    });
  }

  Map<String, MachineDraftSnapshot> _copySharedLocationToSnapshots(
    LocationValidationResult value,
  ) {
    final snapshots = _snapshotsWithCurrent();
    return snapshots.map(
      (key, snapshot) => MapEntry(key, snapshot.copyWith(location: value)),
    );
  }

  void _applySavedLogsheet(LogsheetModel logsheet) {
    final snapshot = MachineDraftSnapshot.fromLogsheet(logsheet);
    final machineId = logsheet.machineId;
    final snapshots = Map<String, MachineDraftSnapshot>.from(state.machineSnapshots)
      ..[machineId] = snapshot;
    if (state.selectedMachine?.id == machineId) {
      state = state.copyWith(
        machineSnapshots: snapshots,
        currentLocalId: snapshot.localId,
        currentProofId: snapshot.proofId,
        machineStatus: snapshot.machineStatus,
        values: snapshot.values,
        notes: snapshot.notes,
        fieldCondition: snapshot.fieldCondition,
        selfiePath: snapshot.selfiePath,
        machinePhotoPath: snapshot.machinePhotoPath,
        location: snapshot.location,
        sharedSelfiePath: snapshot.selfiePath.isEmpty
            ? state.sharedSelfiePath
            : snapshot.selfiePath,
        sharedMachinePhotoPath:
            snapshot.machineStatus == MachineStatus.gangguanRusak ||
                snapshot.machinePhotoPath.isEmpty
            ? state.sharedMachinePhotoPath
            : snapshot.machinePhotoPath,
        sharedLocation: snapshot.location ?? state.sharedLocation,
      );
      return;
    }
    state = state.copyWith(machineSnapshots: snapshots);
  }
}
