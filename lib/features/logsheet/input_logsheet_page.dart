import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/network/api_exception.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/app_loading.dart';
import '../../data/local/hive_service.dart';
import '../../data/models/app_enums.dart';
import '../../data/models/logsheet_model.dart';
import '../../data/models/machine_model.dart';
import '../../data/models/unit_model.dart';
import '../../data/repositories/machine_repository.dart';
import '../../data/repositories/unit_repository.dart';
import '../auth/auth_controller.dart';
import '../profile/settings_controller.dart';
import '../camera/camera_capture_page.dart';
import '../location/gps_validation_page.dart';
import '../location/location_service.dart';
import 'logsheet_controller.dart';
import 'submission_success_page.dart';
import 'widgets/gps_status_card.dart';
import 'widgets/machine_selector_card.dart';
import 'widgets/parameter_input_section.dart';
import 'widgets/photo_requirement_card.dart';
import 'widgets/submit_bottom_bar.dart';
import 'widgets/warning_parameter_card.dart';

final unitsProvider = FutureProvider<List<UnitModel>>((ref) {
  return ref.read(unitRepositoryProvider).getUnits();
});

final machinesProvider = FutureProvider.family<List<MachineModel>, String>((
  ref,
  unitId,
) {
  return ref.read(machineRepositoryProvider).getMachines(unitId);
});

class InputLogsheetPage extends ConsumerStatefulWidget {
  const InputLogsheetPage({
    super.key,
    this.initialUnitId,
    this.initialMachineId,
    this.initialLogsheet,
  });

  final String? initialUnitId;
  final String? initialMachineId;
  final LogsheetModel? initialLogsheet;

  static const _paramKeys = [
    ...LogsheetController.numericParameterKeys,
    ...LogsheetController.requiredTextKeys,
  ];

  @override
  ConsumerState<InputLogsheetPage> createState() => _InputLogsheetPageState();
}

class _InputLogsheetPageState extends ConsumerState<InputLogsheetPage> {
  bool _prefilledUnit = false;
  bool _prefilledMachine = false;
  bool _loadedExistingLogsheet = false;

  int _countFilledParams(Map<String, String> values) {
    return InputLogsheetPage._paramKeys
        .where((key) => (values[key] ?? '').trim().isNotEmpty)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;
    final form = ref.watch(logsheetControllerProvider);
    final controller = ref.read(logsheetControllerProvider.notifier);
    final units = ref.watch(unitsProvider);
    final hive = ref.read(hiveServiceProvider);
    final appSettings = ref.watch(appSettingsProvider);
    final machines = form.selectedUnit == null
        ? const AsyncValue<List<MachineModel>>.data([])
        : ref.watch(machinesProvider(form.selectedUnit!.id));
    final isBatchMode =
        widget.initialUnitId != null && widget.initialLogsheet == null;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('User belum tersedia')));
    }

    final filledCount = _countFilledParams(form.values);
    final machineItems = machines.valueOrNull ?? const <MachineModel>[];
    final completedMachines = controller.completedMachineCount(machineItems);
    final step1Done =
        form.selectedUnit != null &&
        form.selectedMachine != null &&
        form.machineStatus != null;
    final step2Done = filledCount >= InputLogsheetPage._paramKeys.length;
    final step3Done = form.location != null;
    final step4Done =
        form.selfiePath.isNotEmpty && form.machinePhotoPath.isNotEmpty;
    final gpsSessionLabel = form.sharedLocation == null
        ? 'Lokasi unit cukup diambil sekali. Setelah tersimpan, GPS akan dipakai ulang untuk mesin lain pada unit yang sama.'
        : form.isUsingSharedLocation
        ? 'Lokasi sesi unit ini sedang dipakai ulang. Tekan refresh jika ingin ambil GPS baru.'
        : 'Lokasi sesi unit sudah tersimpan dan siap dipakai ulang untuk mesin lain pada unit yang sama.';
    final selfieNote = form.sharedSelfiePath.isEmpty
        ? 'Selfie operator cukup sekali untuk seluruh mesin dalam unit ini.'
        : form.isUsingSharedSelfie
        ? 'Selfie operator dipakai ulang dari sesi unit ini.'
        : 'Selfie operator sudah tersimpan untuk sesi unit ini.';
    final machinePhotoNote = form.machineStatus == MachineStatus.gangguanRusak
        ? form.machinePhotoPath.isEmpty
            ? 'Status Gangguan-Rusak: ambil 1 foto khusus untuk mesin ini.'
            : 'Foto kerusakan mesin ini tersimpan khusus untuk mesin yang dipilih.'
        : form.sharedMachinePhotoPath.isEmpty
        ? 'Foto mesin umum cukup sekali dan bisa dipakai ulang untuk mesin lain pada unit ini.'
        : form.isUsingSharedMachinePhoto
        ? 'Foto mesin umum dipakai ulang dari sesi unit ini.'
        : 'Foto mesin umum sudah tersimpan untuk sesi unit ini.';
    final errorText = form.errorMessage;
    final isConnectionError =
        (errorText ?? '').toLowerCase().contains('koneksi') ||
        (errorText ?? '').toLowerCase().contains('server');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Logsheet'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      bottomNavigationBar: SubmitBottomBar(
        isSaving: form.isSaving,
        isSubmitting: form.isSubmitting,
        filledParams: filledCount,
        totalParams: InputLogsheetPage._paramKeys.length,
        warningCount: form.warnings.length,
        secondaryStatus: form.isSubmitting && form.submittingMachineLabel != null
            ? 'Mengirim ${form.submittingMachineLabel}...'
            : isBatchMode
                ? '$completedMachines/${machineItems.length} mesin siap submit'
                : null,
        submitLabel: isBatchMode ? 'Submit Semua Mesin' : 'Submit Logsheet',
        submitVisible: !isBatchMode || (machineItems.isNotEmpty && completedMachines == machineItems.length),
        onSaveDraft: () async {
          final result = await controller.saveDraft(user);
          if (!context.mounted || result == null) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(result.message)));
        },
        onSubmit: () async {
          if (isBatchMode) {
            if (machineItems.isEmpty || completedMachines != machineItems.length) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Tombol submit baru aktif setelah semua mesin pada unit ini lengkap.',
                  ),
                ),
              );
              return;
            }
            final results = await controller.submitAll(user, machineItems);
            if (!context.mounted || results.isEmpty) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute<void>(
                builder: (_) => SubmissionSuccessPage(
                  logsheet: results.last.logsheet,
                  synced: results.every((item) => item.synced),
                  submittedCount: results.length,
                ),
              ),
            );
            controller.reset();
            return;
          }

          final result = await controller.submit(user);
          if (!context.mounted || result == null) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute<void>(
              builder: (_) => SubmissionSuccessPage(
                logsheet: result.logsheet,
                synced: result.synced,
              ),
            ),
          );
          controller.reset();
        },
      ),
      body: units.when(
        data: (unitItems) {
          if (!_prefilledUnit && widget.initialLogsheet != null) {
            final target = unitItems.where((item) => item.id == widget.initialLogsheet!.unitId);
            if (target.isNotEmpty) {
              _prefilledUnit = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  controller.setUnit(target.first);
                }
              });
            }
          }

          if (!_prefilledUnit &&
              form.selectedUnit == null &&
              unitItems.isNotEmpty) {
            _prefilledUnit = true;
            UnitModel defaultUnit = unitItems.first;
            final preferredUnitId =
                widget.initialUnitId ??
                hive.settingsBox.get('last_selected_unit_id')?.toString() ??
                user.unitId;
            for (final item in unitItems) {
              if (item.id == preferredUnitId) {
                defaultUnit = item;
                break;
              }
            }
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                controller.setUnit(defaultUnit);
              }
            });
          }

          if (!_loadedExistingLogsheet &&
              widget.initialLogsheet != null &&
              form.selectedUnit != null &&
              machineItems.isNotEmpty) {
            final target = machineItems.where(
              (item) => item.id == widget.initialLogsheet!.machineId,
            );
            if (target.isNotEmpty) {
              _loadedExistingLogsheet = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  controller.loadExistingLogsheet(
                    logsheet: widget.initialLogsheet!,
                    unit: form.selectedUnit!,
                    machine: target.first,
                  );
                }
              });
            }
          }

          if (!_prefilledMachine &&
              widget.initialLogsheet == null &&
              form.selectedUnit != null &&
              form.selectedMachine == null &&
              machineItems.isNotEmpty) {
            _prefilledMachine = true;
            final candidateMachineIds = <String?>[
              widget.initialMachineId,
              hive.settingsBox
                  .get('last_selected_machine_${form.selectedUnit!.id}')
                  ?.toString(),
            ];
            MachineModel? defaultMachine;
            for (final candidate in candidateMachineIds) {
              if (candidate == null || candidate.isEmpty) {
                continue;
              }
              for (final item in machineItems) {
                if (item.id == candidate) {
                  defaultMachine = item;
                  break;
                }
              }
              if (defaultMachine != null) {
                break;
              }
            }
            if (defaultMachine != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  controller.setMachine(defaultMachine);
                }
              });
            }
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
            children: [
              _InputHeader(
                unitName: form.selectedUnit?.name ?? 'Pilih Unit',
                machineName: form.selectedMachine?.displayLabel,
              ),
              const SizedBox(height: 16),
              _FormStepper(
                steps: [
                  ('Unit & Status', step1Done),
                  ('Parameter', step2Done),
                  ('GPS', step3Done),
                  ('Foto', step4Done),
                ],
              ),
              const SizedBox(height: 16),
              if (widget.initialUnitId != null) ...[
                GlassCard(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accent.withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderColor: AppColors.accent.withValues(alpha: 0.35),
                  child: const Row(
                    children: [
                      Icon(Icons.flash_on_rounded, color: AppColors.accent),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Mode cepat aktif. Unit sebelumnya dipertahankan agar operator bisa langsung lanjut input mesin berikutnya.',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (widget.initialLogsheet != null) ...[
                GlassCard(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.highlight.withValues(alpha: 0.16),
                      Colors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderColor: AppColors.highlight.withValues(alpha: 0.35),
                  child: const Row(
                    children: [
                      Icon(Icons.edit_rounded, color: AppColors.highlight),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Mode edit aktif. Draft, pending, gagal sync, atau data ditolak dapat diperbarui dari halaman ini.',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (errorText != null) ...[
                AppErrorState(
                  title: isConnectionError
                      ? 'Sinkronisasi belum berhasil'
                      : 'Periksa data logsheet',
                  message: errorText,
                  helperText: isConnectionError
                      ? 'Data pada form tetap aman. Jika koneksi belum stabil, simpan atau kirim ulang saat jaringan membaik.'
                      : 'Pastikan semua field wajib, status mesin, dan bukti pendukung sudah sesuai.',
                ),
                const SizedBox(height: 12),
              ],
              MachineSelectorCard(
                operatorName: user.name,
                selectedUnit: form.selectedUnit,
                selectedMachine: form.selectedMachine,
                machineStatus: form.machineStatus,
                units: unitItems,
                machines: machines,
                onUnitChanged: (value) {
                  _prefilledMachine = false;
                  if (value != null) {
                    hive.settingsBox.put('last_selected_unit_id', value.id);
                  }
                  controller.setUnit(value);
                },
                onMachineChanged: (value) {
                  if (value != null && form.selectedUnit != null) {
                    hive.settingsBox.put(
                      'last_selected_machine_${form.selectedUnit!.id}',
                      value.id,
                    );
                  }
                  controller.setMachine(value);
                },
                onMachineStatusChanged: controller.setMachineStatus,
              ),
              const SizedBox(height: 16),
              ParameterInputSection(
                values: form.values,
                machineStatus: form.machineStatus,
                machineKey: form.selectedMachine?.id ?? 'empty',
                operatorFieldLabel: appSettings.operatorFieldLabel,
                onChanged: controller.setValue,
              ),
              const SizedBox(height: 16),
              GpsStatusCard(
                result: form.location,
                sessionLabel: gpsSessionLabel,
                onValidate: () async {
                  if (form.selectedUnit == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pilih unit terlebih dahulu.'),
                      ),
                    );
                    return;
                  }
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute<LocationValidationResult>(
                      builder: (_) =>
                          GpsValidationPage(unit: form.selectedUnit!),
                    ),
                  );
                  if (result != null) controller.setLocation(result);
                },
              ),
              const SizedBox(height: 16),
              PhotoRequirementCard(
                selfiePath: form.selfiePath,
                machinePhotoPath: form.machinePhotoPath,
                selfieNote: selfieNote,
                machineNote: machinePhotoNote,
                onCaptureSelfie: () async {
                  final path = await Navigator.push<String>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CameraCapturePage(
                        photoType: 'Absen petugas',
                        operatorName: user.name,
                        unitName: form.selectedUnit?.name ?? user.unitName,
                        locationLabel: form.location == null
                            ? '-'
                            : '${form.location!.latitude.toStringAsFixed(5)}, ${form.location!.longitude.toStringAsFixed(5)}',
                      ),
                    ),
                  );
                  if (path != null) controller.setSelfie(path);
                },
                onCaptureMachine: () async {
                  final path = await Navigator.push<String>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CameraCapturePage(
                        photoType: 'Foto mesin',
                        operatorName: user.name,
                        unitName: form.selectedUnit?.name ?? user.unitName,
                        locationLabel: form.location == null
                            ? '-'
                            : '${form.location!.latitude.toStringAsFixed(5)}, ${form.location!.longitude.toStringAsFixed(5)}',
                      ),
                    ),
                  );
                  if (path != null) controller.setMachinePhoto(path);
                },
              ),
              const SizedBox(height: 16),
              WarningParameterCard(warnings: form.warnings),
              if (isBatchMode && machineItems.isNotEmpty) ...[
                const SizedBox(height: 12),
                GlassCard(
                  child: Row(
                    children: [
                      const Icon(Icons.fact_check_rounded, color: AppColors.success),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '$completedMachines dari ${machineItems.length} mesin sudah lengkap. Submit akhir hanya muncul ketika semua mesin selesai.',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
        loading: () => const AppLoading(),
        error: (error, _) => AppErrorState(
          message: ApiException.fromObject(error).message,
        ),
      ),
    );
  }
}

class _FormStepper extends StatelessWidget {
  const _FormStepper({required this.steps});

  /// Each entry: (label, isDone)
  final List<(String, bool)> steps;

  @override
  Widget build(BuildContext context) {
    // First incomplete step is the "active" one
    int activeIndex = steps.indexWhere((s) => !s.$2);
    if (activeIndex == -1) activeIndex = steps.length - 1;

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            if (i > 0)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 13),
                  child: Container(
                    height: 1.5,
                    color: steps[i - 1].$2
                        ? AppColors.primary.withValues(alpha: 0.45)
                        : AppColors.border,
                  ),
                ),
              ),
            _StepNode(
              number: i + 1,
              label: steps[i].$1,
              isDone: steps[i].$2,
              isActive: i == activeIndex,
            ),
          ],
        ],
      ),
    );
  }
}

class _StepNode extends StatelessWidget {
  const _StepNode({
    required this.number,
    required this.label,
    required this.isDone,
    required this.isActive,
  });

  final int number;
  final String label;
  final bool isDone;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final showFilled = isDone || isActive;
    final textColor = (isDone || isActive)
        ? AppColors.primary
        : AppColors.textSoft;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: showFilled
                ? LinearGradient(
                    colors: isDone
                        ? [AppColors.success, const Color(0xFF34D399)]
                        : [AppColors.primary, AppColors.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            border: showFilled
                ? null
                : Border.all(color: AppColors.border, width: 1.5),
          ),
          alignment: Alignment.center,
          child: isDone
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
              : Text(
                  '$number',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isActive ? Colors.white : AppColors.textSoft,
                  ),
                ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }
}

class _InputHeader extends StatelessWidget {
  const _InputHeader({required this.unitName, this.machineName});

  final String unitName;
  final String? machineName;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');

    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0A3D8E), Color(0xFF0A6FD8), AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.30),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.auroraCyan.withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.edit_note_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        unitName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      if (machineName != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          machineName!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        color: Colors.white,
                        size: 13,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '$hour:$minute',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
