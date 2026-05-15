import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/section_title.dart';

class ParameterInputSection extends StatelessWidget {
  const ParameterInputSection({
    super.key,
    required this.fields,
    required this.values,
    required this.onChanged,
  });

  final List<(String, String)> fields;
  final Map<String, String> values;
  final void Function(String key, String value) onChanged;

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = MediaQuery.of(context).size.width >= 700 ? 3 : 2;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            title: 'Parameter Mesin',
            subtitle: 'Input seluruh parameter operasional',
          ),
          const SizedBox(height: 16),
          GridView.builder(
            itemCount: fields.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.3,
            ),
            itemBuilder: (_, index) {
              final field = fields[index];
              return AppTextField(
                label: field.$2,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                initialValue: values[field.$1],
                onChanged: (value) => onChanged(field.$1, value),
              );
            },
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Catatan Operator',
            maxLines: 3,
            initialValue: values['notes'],
            onChanged: (value) => onChanged('notes', value),
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Kondisi Lapangan',
            maxLines: 2,
            initialValue: values['fieldCondition'],
            onChanged: (value) => onChanged('fieldCondition', value),
          ),
        ],
      ),
    );
  }
}
