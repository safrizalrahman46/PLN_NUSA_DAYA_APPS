import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/date_helper.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/models/logsheet_model.dart';

class LogsheetDetailPage extends StatelessWidget {
  const LogsheetDetailPage({
    super.key,
    required this.logsheet,
    this.title = 'Detail Logsheet',
  });

  final LogsheetModel logsheet;
  final String title;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor:
                isDark ? AppColors.darkBackground : AppColors.primaryDark,
            foregroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                decoration: BoxDecoration(
                  gradient: isDark
                      ? AppColors.darkGradient
                      : AppColors.heroGradient,
                ),
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
                              AppColors.auroraCyan.withValues(alpha: 0.20),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  _HeaderChip(
                                    icon: Icons.business_rounded,
                                    label: logsheet.unitName,
                                  ),
                                  const SizedBox(width: 8),
                                  _HeaderChip(
                                    icon: Icons.settings_rounded,
                                    label: logsheet.serialNumber
                                        .split('-')
                                        .last,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  StatusBadge.sync(logsheet.syncStatus),
                                  StatusBadge.location(logsheet.locationStatus),
                                  StatusBadge.report(logsheet.reportStatus),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPadding + 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(
                        icon: Icons.info_outline_rounded,
                        color: AppColors.primary,
                        title: 'Identitas Laporan',
                      ),
                      const SizedBox(height: 14),
                      Text(
                        logsheet.proofId,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 14),
                      _DetailRow(label: 'Operator', value: logsheet.operatorName),
                      _DetailRow(label: 'Unit', value: logsheet.unitName),
                      _DetailRow(label: 'Mesin', value: logsheet.serialNumber),
                      _DetailRow(
                        label: 'Waktu Submit',
                        value: DateHelper.formatFull(logsheet.submittedAt),
                      ),
                      _DetailRow(
                        label: 'Latitude',
                        value: logsheet.latitude.toStringAsFixed(6),
                      ),
                      _DetailRow(
                        label: 'Longitude',
                        value: logsheet.longitude.toStringAsFixed(6),
                      ),
                      _DetailRow(
                        label: 'Akurasi',
                        value:
                            '${logsheet.locationAccuracy.toStringAsFixed(1)} m',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(
                        icon: Icons.speed_rounded,
                        color: AppColors.accent,
                        title: 'Parameter Mesin',
                      ),
                      const SizedBox(height: 14),
                      _DetailRow(
                        label: 'Beban Mesin',
                        value: logsheet.bebanMesin.toStringAsFixed(2),
                      ),
                      _DetailRow(
                        label: 'Stand KWH',
                        value: logsheet.standKwh.toStringAsFixed(2),
                      ),
                      _DetailRow(
                        label: 'Stand BBM',
                        value: logsheet.standBbm.toStringAsFixed(2),
                      ),
                      _DetailRow(
                        label: 'Tekanan Oli',
                        value: logsheet.tekananOli.toStringAsFixed(2),
                      ),
                      _DetailRow(
                        label: 'Temperatur Air',
                        value: logsheet.temperaturAir.toStringAsFixed(2),
                      ),
                      _DetailRow(
                        label: 'Phasa R/S/T',
                        value:
                            '${logsheet.phasaR.toStringAsFixed(0)} / ${logsheet.phasaS.toStringAsFixed(0)} / ${logsheet.phasaT.toStringAsFixed(0)}',
                      ),
                      _DetailRow(
                        label: 'Tegangan',
                        value: logsheet.tegangan.toStringAsFixed(2),
                      ),
                      _DetailRow(
                        label: 'Cos Phi',
                        value: logsheet.cosPhi.toStringAsFixed(2),
                      ),
                      _DetailRow(
                        label: 'Frekuensi',
                        value: logsheet.frequency.toStringAsFixed(2),
                      ),
                      _DetailRow(
                        label: 'Catatan',
                        value: logsheet.notes.isEmpty ? '-' : logsheet.notes,
                      ),
                      _DetailRow(
                        label: 'Kondisi Lapangan',
                        value: logsheet.fieldCondition.isEmpty
                            ? '-'
                            : logsheet.fieldCondition,
                      ),
                      _DetailRow(
                        label: 'Abnormal Notes',
                        value: logsheet.abnormalNotes.isEmpty
                            ? '-'
                            : logsheet.abnormalNotes,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                OverflowBar(
                  spacing: 10,
                  overflowSpacing: 10,
                  alignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width < 380
                          ? double.infinity
                          : (MediaQuery.of(context).size.width - 50) / 2,
                      child: AppButton(
                        label: 'Download PDF',
                        onPressed: () =>
                            _snack(context, 'Download PDF dummy dijalankan.'),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width < 380
                          ? double.infinity
                          : (MediaQuery.of(context).size.width - 50) / 2,
                      child: AppButton(
                        label: 'Share Report',
                        onPressed: () =>
                            _snack(context, 'Share report dummy dijalankan.'),
                        type: AppButtonType.outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                AppButton(
                  label: 'Resync',
                  onPressed: () =>
                      _snack(context, 'Resync dummy dijalankan.'),
                  type: AppButtonType.tonal,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _snack(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      borderRadius: 999,
      sigmaX: 8,
      sigmaY: 8,
      borderColor: Colors.white.withValues(alpha: 0.28),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.85)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.color,
    required this.title,
  });

  final IconData icon;
  final Color color;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.of(context).size.width < 380;

    if (narrow) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.titleMedium),
          ),
        ],
      ),
    );
  }
}
