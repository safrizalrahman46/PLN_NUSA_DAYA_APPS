import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/number_helper.dart';
import '../../data/models/app_enums.dart';
import '../../data/models/logsheet_model.dart';
import '../../data/models/machine_model.dart';
import '../../data/models/unit_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/logsheet_repository.dart';
import '../location/location_service.dart';

class LogsheetFormState {
  const LogsheetFormState({
    this.selectedUnit,
    this.selectedMachine,
    this.values = const {},
    this.notes = '',
    this.fieldCondition = '',
    this.selfiePath = '',
    this.machinePhotoPath = '',
    this.location,
    this.isSaving = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final UnitModel? selectedUnit;
  final MachineModel? selectedMachine;
  final Map<String, String> values;
  final String notes;
  final String fieldCondition;
  final String selfiePath;
  final String machinePhotoPath;
  final LocationValidationResult? location;
  final bool isSaving;
  final bool isSubmitting;
  final String? errorMessage;

  List<String> get warnings {
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

  LogsheetFormState copyWith({
    UnitModel? selectedUnit,
    MachineModel? selectedMachine,
    Map<String, String>? values,
    String? notes,
    String? fieldCondition,
    String? selfiePath,
    String? machinePhotoPath,
    LocationValidationResult? location,
    bool? isSaving,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LogsheetFormState(
      selectedUnit: selectedUnit ?? this.selectedUnit,
      selectedMachine: selectedMachine ?? this.selectedMachine,
      values: values ?? this.values,
      notes: notes ?? this.notes,
      fieldCondition: fieldCondition ?? this.fieldCondition,
      selfiePath: selfiePath ?? this.selfiePath,
      machinePhotoPath: machinePhotoPath ?? this.machinePhotoPath,
      location: location ?? this.location,
      isSaving: isSaving ?? this.isSaving,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final logsheetControllerProvider =
    StateNotifierProvider<LogsheetController, LogsheetFormState>((ref) {
      return LogsheetController(ref.read(logsheetRepositoryProvider));
    });

class LogsheetController extends StateNotifier<LogsheetFormState> {
  LogsheetController(this._repository) : super(const LogsheetFormState());

  final LogsheetRepository _repository;
  final _uuid = const Uuid();

  void setUnit(UnitModel? unit) {
    state = state.copyWith(
      selectedUnit: unit,
      selectedMachine: null,
      clearError: true,
    );
  }

  void setMachine(MachineModel? machine) {
    state = state.copyWith(selectedMachine: machine, clearError: true);
  }

  void setValue(String key, String value) {
    final values = Map<String, String>.from(state.values)..[key] = value;
    state = state.copyWith(values: values, clearError: true);
  }

  void setNotes(String value) => state = state.copyWith(notes: value);
  void setFieldCondition(String value) =>
      state = state.copyWith(fieldCondition: value);
  void setSelfie(String path) =>
      state = state.copyWith(selfiePath: path, clearError: true);
  void setMachinePhoto(String path) =>
      state = state.copyWith(machinePhotoPath: path, clearError: true);
  void setLocation(LocationValidationResult value) =>
      state = state.copyWith(location: value, clearError: true);

  String? validate() {
    if (state.selectedUnit == null) return 'Unit wajib dipilih';
    if (state.selectedMachine == null) return 'Mesin wajib dipilih';
    const keys = [
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
    for (final key in keys) {
      if ((state.values[key] ?? '').trim().isEmpty) {
        return 'Semua parameter wajib diisi';
      }
    }
    if (state.selfiePath.isEmpty) return 'Foto selfie operator wajib diambil';
    if (state.machinePhotoPath.isEmpty) return 'Foto mesin wajib diambil';
    if (state.location == null) return 'Lokasi GPS wajib diambil';
    return null;
  }

  LogsheetModel buildLogsheet(UserModel user) {
    final now = DateTime.now();
    final reportStatus = state.warnings.isNotEmpty
        ? ReportStatus.abnormal
        : now.minute > 10
        ? ReportStatus.late
        : ReportStatus.onTime;

    return LogsheetModel(
      id: '',
      localId: _uuid.v4(),
      proofId: '',
      operatorId: user.id,
      operatorName: user.name,
      unitId: state.selectedUnit!.id,
      unitName: state.selectedUnit!.name,
      machineId: state.selectedMachine!.id,
      serialNumber: state.selectedMachine!.serialNumber,
      bebanMesin: NumberHelper.parse(state.values['bebanMesin']),
      standKwh: NumberHelper.parse(state.values['standKwh']),
      standBbm: NumberHelper.parse(state.values['standBbm']),
      tekananOli: NumberHelper.parse(state.values['tekananOli']),
      temperaturAir: NumberHelper.parse(state.values['temperaturAir']),
      phasaR: NumberHelper.parse(state.values['phasaR']),
      phasaS: NumberHelper.parse(state.values['phasaS']),
      phasaT: NumberHelper.parse(state.values['phasaT']),
      tegangan: NumberHelper.parse(state.values['tegangan']),
      cosPhi: NumberHelper.parse(state.values['cosPhi']),
      frequency: NumberHelper.parse(state.values['frequency']),
      notes: (state.values['notes'] ?? state.notes),
      selfiePhotoPath: state.selfiePath,
      machinePhotoPath: state.machinePhotoPath,
      latitude: state.location?.latitude ?? 0,
      longitude: state.location?.longitude ?? 0,
      locationAccuracy: state.location?.accuracy ?? 0,
      distanceFromUnit: state.location?.distanceFromUnit ?? 0,
      locationStatus: state.location?.status ?? LocationStatus.unknown,
      submittedAt: now,
      syncStatus: SyncStatus.draft,
      reportStatus: reportStatus,
      abnormalNotes: state.warnings.join(' '),
      createdAt: now,
      updatedAt: now,
      fieldCondition: (state.values['fieldCondition'] ?? state.fieldCondition),
    );
  }

  Future<SubmissionResult?> saveDraft(UserModel user) async {
    try {
      state = state.copyWith(isSaving: true, clearError: true);
      final result = await _repository.saveDraft(buildLogsheet(user));
      state = state.copyWith(isSaving: false);
      return result;
    } catch (error) {
      state = state.copyWith(isSaving: false, errorMessage: error.toString());
      return null;
    }
  }

  Future<SubmissionResult?> submit(UserModel user) async {
    final validation = validate();
    if (validation != null) {
      state = state.copyWith(errorMessage: validation);
      return null;
    }

    try {
      state = state.copyWith(isSubmitting: true, clearError: true);
      final result = await _repository.submit(buildLogsheet(user));
      state = state.copyWith(isSubmitting: false);
      return result;
    } catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: error.toString(),
      );
      return null;
    }
  }

  void reset() => state = const LogsheetFormState();
}
