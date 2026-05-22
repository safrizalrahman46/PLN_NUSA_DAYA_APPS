import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/section_title.dart';
import '../../../data/models/app_enums.dart';

class ParameterInputSection extends StatefulWidget {
  const ParameterInputSection({
    super.key,
    required this.values,
    required this.machineStatus,
    required this.onChanged,
    required this.machineKey,
    required this.operatorFieldLabel,
  });

  final Map<String, String> values;
  final MachineStatus? machineStatus;
  final void Function(String key, String value) onChanged;
  final String machineKey;
  final String operatorFieldLabel;

  static const _numericKeys = [
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

  static const _textKeys = ['notes', 'fieldCondition'];

  static const allKeys = [..._numericKeys, ..._textKeys];

  @override
  State<ParameterInputSection> createState() => _ParameterInputSectionState();
}

class _ParameterInputSectionState extends State<ParameterInputSection> {
  final _controllers = <String, TextEditingController>{};

  @override
  void initState() {
    super.initState();
    for (final key in ParameterInputSection.allKeys) {
      _controllers[key] = TextEditingController(
        text: widget.values[key] ?? '',
      );
    }
  }

  @override
  void didUpdateWidget(ParameterInputSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.machineKey != oldWidget.machineKey) {
      for (final key in ParameterInputSection.allKeys) {
        final newText = widget.values[key] ?? '';
        final ctrl = _controllers[key];
        if (ctrl != null && ctrl.text != newText) {
          ctrl.text = newText;
          ctrl.selection = TextSelection.collapsed(offset: newText.length);
        }
      }
    } else {
      // Sync nilai dari luar (misal saat status gangguanRusak set semua ke '0')
      for (final key in ParameterInputSection._numericKeys) {
        final newText = widget.values[key] ?? '';
        final ctrl = _controllers[key];
        if (ctrl != null && ctrl.text != newText) {
          ctrl.text = newText;
          ctrl.selection = TextSelection.collapsed(offset: newText.length);
        }
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNumericLocked = widget.machineStatus == MachineStatus.gangguanRusak;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            title: 'Parameter Mesin',
            subtitle: isNumericLocked
                ? 'Status Gangguan-Rusak aktif. Parameter numerik dikunci ke 0.'
                : 'Input seluruh parameter operasional mesin',
          ),
          if (isNumericLocked) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.28),
                ),
              ),
              child: Text(
                'Nilai beban, konsumsi, tekanan, temperatur, elektrikal, dan frekuensi otomatis diisi 0 sampai status diubah kembali.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          _ParamGroup(
            title: 'Beban & Konsumsi',
            subtitle: '3 parameter',
            icon: Icons.bolt_rounded,
            color: AppColors.primary,
            fields: const [
              ('bebanMesin', 'Beban Mesin (kW)'),
              ('standKwh', 'Stand KWH (kWh)'),
              ('standBbm', 'Stand BBM (L)'),
            ],
            controllers: _controllers,
            readOnly: isNumericLocked,
            onChanged: widget.onChanged,
          ),
          const SizedBox(height: 16),
          _ParamGroup(
            title: 'Tekanan & Temperatur',
            subtitle: '2 parameter',
            icon: Icons.thermostat_rounded,
            color: AppColors.warning,
            fields: const [
              ('tekananOli', 'Tekanan Oli (bar)'),
              ('temperaturAir', 'Temperatur Air (°C)'),
            ],
            controllers: _controllers,
            readOnly: isNumericLocked,
            onChanged: widget.onChanged,
          ),
          const SizedBox(height: 16),
          _ParamGroup(
            title: 'Elektrikal',
            subtitle: '6 parameter',
            icon: Icons.electric_bolt_rounded,
            color: AppColors.accent,
            fields: const [
              ('phasaR', 'Phasa R (A)'),
              ('phasaS', 'Phasa S (A)'),
              ('phasaT', 'Phasa T (A)'),
              ('tegangan', 'Tegangan (V)'),
              ('cosPhi', 'Cos Phi'),
              ('frequency', 'Frequency (Hz)'),
            ],
            controllers: _controllers,
            readOnly: isNumericLocked,
            onChanged: widget.onChanged,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            context: context,
            controllerKey: 'notes',
            label: 'Catatan Operator *',
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            context: context,
            controllerKey: 'fieldCondition',
            label: '${widget.operatorFieldLabel} *',
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required String controllerKey,
    required String label,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: _controllers[controllerKey],
      maxLines: maxLines,
      onChanged: (value) => widget.onChanged(controllerKey, value),
      decoration: InputDecoration(labelText: label),
    );
  }
}

class _ParamGroup extends StatelessWidget {
  const _ParamGroup({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.fields,
    required this.controllers,
    required this.readOnly,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<(String, String)> fields;
  final Map<String, TextEditingController> controllers;
  final bool readOnly;
  final void Function(String key, String value) onChanged;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fieldWidth = (screenWidth - 40 - 36 - 8) / 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.70)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.28),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.textSoft),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: fields.map((field) {
            return SizedBox(
              width: screenWidth < 380 ? double.infinity : fieldWidth,
              child: TextFormField(
                controller: controllers[field.$1],
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                readOnly: readOnly,
                onChanged: readOnly ? null : (value) => onChanged(field.$1, value),
                decoration: InputDecoration(
                  labelText: field.$2,
                  suffixIcon: readOnly
                      ? const Icon(Icons.lock_outline_rounded, size: 16)
                      : null,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
