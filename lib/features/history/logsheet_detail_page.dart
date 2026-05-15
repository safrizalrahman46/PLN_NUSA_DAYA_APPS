import 'package:flutter/material.dart';

import '../../core/utils/date_helper.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
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
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  logsheet.proofId,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    StatusBadge.sync(logsheet.syncStatus),
                    StatusBadge.location(logsheet.locationStatus),
                    StatusBadge.report(logsheet.reportStatus),
                  ],
                ),
                const SizedBox(height: 16),
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
                  value: '${logsheet.locationAccuracy.toStringAsFixed(1)} m',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Parameter Mesin',
                  style: Theme.of(context).textTheme.titleLarge,
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
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Download PDF',
                  onPressed: () =>
                      _snack(context, 'Download PDF dummy dijalankan.'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
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
            onPressed: () => _snack(context, 'Resync dummy dijalankan.'),
            type: AppButtonType.tonal,
          ),
        ],
      ),
    );
  }

  void _snack(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
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
