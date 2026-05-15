import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_loading.dart';
import '../../data/local/hive_service.dart';
import '../../data/models/machine_model.dart';
import '../../data/models/unit_model.dart';
import '../../data/repositories/machine_repository.dart';
import '../../data/repositories/unit_repository.dart';
import '../auth/auth_controller.dart';
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
  });

  final String? initialUnitId;
  final String? initialMachineId;

  static const _fields = [
    ('bebanMesin', 'Beban Mesin'),
    ('standKwh', 'Stand KWH'),
    ('standBbm', 'Stand BBM'),
    ('tekananOli', 'Tekanan Oli'),
    ('temperaturAir', 'Temperatur Air'),
    ('phasaR', 'Phasa R'),
    ('phasaS', 'Phasa S'),
    ('phasaT', 'Phasa T'),
    ('tegangan', 'Tegangan'),
    ('cosPhi', 'Cos Phi'),
    ('frequency', 'Frequency'),
  ];

  @override
  ConsumerState<InputLogsheetPage> createState() => _InputLogsheetPageState();
}

class _InputLogsheetPageState extends ConsumerState<InputLogsheetPage> {
  bool _prefilledUnit = false;
  bool _prefilledMachine = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;
    final form = ref.watch(logsheetControllerProvider);
    final controller = ref.read(logsheetControllerProvider.notifier);
    final units = ref.watch(unitsProvider);
    final hive = ref.read(hiveServiceProvider);
    final machines = form.selectedUnit == null
        ? const AsyncValue<List<MachineModel>>.data([])
        : ref.watch(machinesProvider(form.selectedUnit!.id));

    if (user == null) {
      return const Scaffold(body: Center(child: Text('User belum tersedia')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Input Logsheet')),
      bottomNavigationBar: SubmitBottomBar(
        isSaving: form.isSaving,
        isSubmitting: form.isSubmitting,
        onSaveDraft: () async {
          final result = await controller.saveDraft(user);
          if (!context.mounted || result == null) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(result.message)));
        },
        onSubmit: () async {
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

          final machineItems = machines.valueOrNull ?? const <MachineModel>[];
          if (!_prefilledMachine &&
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
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            children: [
              if (widget.initialUnitId != null) ...[
                const AppCard(
                  child: Row(
                    children: [
                      Icon(Icons.flash_on_rounded, color: Colors.blue),
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
              if (form.errorMessage != null) ...[
                AppErrorState(message: form.errorMessage!),
                const SizedBox(height: 12),
              ],
              MachineSelectorCard(
                operatorName: user.name,
                selectedUnit: form.selectedUnit,
                selectedMachine: form.selectedMachine,
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
              ),
              const SizedBox(height: 16),
              ParameterInputSection(
                fields: InputLogsheetPage._fields,
                values: form.values,
                onChanged: controller.setValue,
              ),
              const SizedBox(height: 16),
              PhotoRequirementCard(
                selfiePath: form.selfiePath,
                machinePhotoPath: form.machinePhotoPath,
                onCaptureSelfie: () async {
                  final path = await Navigator.push<String>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CameraCapturePage(
                        photoType: 'Selfie operator',
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
              GpsStatusCard(
                result: form.location,
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
              WarningParameterCard(warnings: form.warnings),
            ],
          );
        },
        loading: () => const AppLoading(),
        error: (error, _) => AppErrorState(message: error.toString()),
      ),
    );
  }
}
