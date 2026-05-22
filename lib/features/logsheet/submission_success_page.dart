import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/models/app_enums.dart';
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
    this.submittedCount = 1,
  });

  final LogsheetModel logsheet;
  final bool synced;
  final int submittedCount;

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
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final headerColor = synced ? AppColors.success : AppColors.warning;
    final headerColorDark = synced
        ? const Color(0xFF0D7A34)
        : const Color(0xFFB45309);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bukti Pengiriman'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPadding + 24),
        children: [
          // Hero header
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [headerColorDark, headerColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Stack(
              children: [
                // Decorative orb
                Positioned(
                  right: -30,
                  top: -30,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.18),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GlassCard(
                        padding: const EdgeInsets.all(14),
                        borderRadius: 999,
                        sigmaX: 12,
                        sigmaY: 12,
                        borderColor: Colors.white.withValues(alpha: 0.35),
                        child: Icon(
                          synced
                              ? Icons.check_circle_rounded
                              : Icons.cloud_upload_rounded,
                          size: 36,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        synced
                            ? submittedCount > 1
                                  ? '$submittedCount Logsheet Berhasil Diproses'
                                  : 'Logsheet Berhasil Dikirim'
                            : submittedCount > 1
                            ? '$submittedCount Logsheet Masuk Pending Upload'
                            : 'Logsheet Masuk Pending Upload',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        submittedCount > 1
                            ? 'Batch sesi ${logsheet.sessionId.isEmpty ? logsheet.proofId : logsheet.sessionId}'
                            : logsheet.proofId,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Stat chips row
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _StatChip(
                            label: 'Status',
                            value: synced ? 'Synced' : 'Pending Upload',
                          ),
                          _StatChip(
                            label: 'Operasi',
                            value: logsheet.machineStatus.label,
                          ),
                          _StatChip(
                            label: 'Sync',
                            value: switch (logsheet.syncStatus) {
                              SyncStatus.synced => 'Synced',
                              SyncStatus.pendingSync => 'Pending',
                              SyncStatus.pendingEdit => 'Pending Edit',
                              SyncStatus.failed => 'Gagal',
                              SyncStatus.draft => 'Draft',
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Info card
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informasi Laporan',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.person_rounded,
                  color: AppColors.primary,
                  label: 'Operator',
                  value: logsheet.operatorName,
                ),
                _InfoRow(
                  icon: Icons.location_city_rounded,
                  color: AppColors.accent,
                  label: 'Unit',
                  value: logsheet.unitName,
                ),
                _InfoRow(
                  icon: Icons.settings_rounded,
                  color: AppColors.highlight,
                  label: 'Mesin',
                  value: logsheet.machineDisplayName,
                ),
                if (logsheet.machineIdentity.isNotEmpty)
                  _InfoRow(
                    icon: Icons.memory_rounded,
                    color: AppColors.accent,
                    label: 'Detail Mesin',
                    value: logsheet.machineIdentity,
                  ),
                if (logsheet.machineCapacityInfo.isNotEmpty)
                  _InfoRow(
                    icon: Icons.bolt_rounded,
                    color: AppColors.primary,
                    label: 'Kapasitas Master',
                    value: logsheet.machineCapacityInfo,
                  ),
                if (logsheet.machineMasterInfo.isNotEmpty)
                  _InfoRow(
                    icon: Icons.fact_check_rounded,
                    color: AppColors.accent,
                    label: 'Info Master',
                    value: logsheet.machineMasterInfo,
                  ),
                _InfoRow(
                  icon: Icons.tune_rounded,
                  color: AppColors.warning,
                  label: 'Status Mesin',
                  value: logsheet.machineStatus.label,
                ),
                _InfoRow(
                  icon: Icons.pin_drop_rounded,
                  color: AppColors.success,
                  label: 'GPS',
                  value:
                      'Lat ${logsheet.latitude.toStringAsFixed(5)}, Lng ${logsheet.longitude.toStringAsFixed(5)}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Photos
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusBadge.machine(logsheet.machineStatus),
                const SizedBox(height: 10),
                Text(
                  'Foto Bukti',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                narrow
                    ? Column(
                        children: [
                          _Thumb(
                            path: logsheet.selfiePhotoPath,
                            label: 'Absen Petugas',
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
                              label: 'Absen Petugas',
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
          const SizedBox(height: 20),
          if (submittedCount == 1 && nextMachine != null) ...[
            AppButton(
              label: 'Lanjut ke ${nextMachine.shortLabel}',
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

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      borderRadius: 12,
      sigmaX: 8,
      sigmaY: 8,
      borderColor: Colors.white.withValues(alpha: 0.28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.textSoft),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
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

class _Thumb extends StatelessWidget {
  const _Thumb({required this.path, required this.label});

  final String path;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 1,
            child: path.isEmpty
                ? Container(
                    color: AppColors.border,
                    child: const Icon(
                      Icons.image_not_supported_rounded,
                      color: AppColors.textSoft,
                    ),
                  )
                : Image.file(File(path), fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
