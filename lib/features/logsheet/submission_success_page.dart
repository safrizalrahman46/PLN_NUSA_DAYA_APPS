import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/dummy/dummy_data.dart';
import '../../data/models/logsheet_model.dart';
import '../dashboard/operator_shell_page.dart';
import '../history/history_page.dart';
import 'input_logsheet_page.dart';

class SubmissionSuccessPage extends StatelessWidget {
  const SubmissionSuccessPage({
    super.key,
    required this.logsheet,
    required this.synced,
  });

  final LogsheetModel logsheet;
  final bool synced;

  @override
  Widget build(BuildContext context) {
    final unitMachines = DummyData.machinesByUnit(logsheet.unitId);
    final currentMachineIndex = unitMachines.indexWhere(
      (item) => item.id == logsheet.machineId,
    );
    final nextMachine =
        currentMachineIndex >= 0 &&
            currentMachineIndex < unitMachines.length - 1
        ? unitMachines[currentMachineIndex + 1]
        : null;

    final narrow = MediaQuery.of(context).size.width < 420;

    return Scaffold(
      appBar: AppBar(title: const Text('Bukti Pengiriman')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AppCard(
            child: Column(
              children: [
                Icon(
                  synced
                      ? Icons.check_circle_rounded
                      : Icons.cloud_upload_rounded,
                  size: 76,
                  color: synced ? Colors.green : Colors.orange,
                ),
                const SizedBox(height: 16),
                Text(
                  synced
                      ? 'Logsheet Berhasil Dikirim'
                      : 'Logsheet Disimpan Offline',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  logsheet.proofId,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 12),
                StatusBadge.sync(logsheet.syncStatus),
                const SizedBox(height: 18),
                Text(
                  '${logsheet.operatorName} • ${logsheet.unitName} • ${logsheet.serialNumber}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Lat ${logsheet.latitude.toStringAsFixed(6)} | Lng ${logsheet.longitude.toStringAsFixed(6)}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                narrow
                    ? Column(
                        children: [
                          _Thumb(
                            path: logsheet.selfiePhotoPath,
                            label: 'Selfie',
                          ),
                          const SizedBox(height: 12),
                          _Thumb(
                            path: logsheet.machinePhotoPath,
                            label: 'Mesin',
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: _Thumb(
                              path: logsheet.selfiePhotoPath,
                              label: 'Selfie',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _Thumb(
                              path: logsheet.machinePhotoPath,
                              label: 'Mesin',
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (nextMachine != null) ...[
            AppButton(
              label: 'Lanjut ke ${nextMachine.serialNumber.split('-').last}',
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InputLogsheetPage(
                      initialUnitId: logsheet.unitId,
                      initialMachineId: nextMachine.id,
                    ),
                  ),
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: 10),
          ],
          AppButton(
            label: 'Input Logsheet Baru',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const InputLogsheetPage()),
                (route) => false,
              );
            },
          ),
          const SizedBox(height: 10),
          AppButton(
            label: 'Lihat Riwayat',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HistoryPage()),
                (route) => false,
              );
            },
            type: AppButtonType.outlined,
          ),
          const SizedBox(height: 10),
          AppButton(
            label: 'Kembali ke Dashboard',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const OperatorShellPage()),
                (route) => false,
              );
            },
            type: AppButtonType.tonal,
          ),
        ],
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.path, required this.label});

  final String path;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: path.isEmpty
                ? Container(color: Colors.black12)
                : Image.file(File(path), fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 6),
        Text(label),
      ],
    );
  }
}
