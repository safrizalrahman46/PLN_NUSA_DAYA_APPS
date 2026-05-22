import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class ReportDonutChart extends StatefulWidget {
  const ReportDonutChart({
    super.key,
    required this.success,
    required this.pending,
    required this.late,
    required this.abnormal,
  });

  final int success;
  final int pending;
  final int late;
  final int abnormal;

  @override
  State<ReportDonutChart> createState() => _ReportDonutChartState();
}

class _ReportDonutChartState extends State<ReportDonutChart> {
  int _touchedIndex = -1;

  static const _labels = ['Sukses', 'Pending', 'Terlambat', 'Abnormal'];
  static const _colors = [
    AppColors.success,
    AppColors.warning,
    AppColors.highlight,
    AppColors.danger,
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total =
        widget.success + widget.pending + widget.late + widget.abnormal;

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 58,
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event,
                        PieTouchResponse? response) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            response == null ||
                            response.touchedSection == null) {
                          _touchedIndex = -1;
                          return;
                        }
                        _touchedIndex =
                            response.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  sections: _buildSections(total),
                ),
              ),
              // Center overlay
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    total.toString(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppColors.text,
                        ),
                  ),
                  Text(
                    'Laporan',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSoft,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Legend
        Wrap(
          spacing: 10,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: List.generate(4, (i) {
            final count = _countAt(i);
            final highlighted = i == _touchedIndex;
            return _LegendItem(
              label: _labels[i],
              count: count,
              color: _colors[i],
              highlighted: highlighted,
            );
          }),
        ),
      ],
    );
  }

  int _countAt(int index) => switch (index) {
        0 => widget.success,
        1 => widget.pending,
        2 => widget.late,
        _ => widget.abnormal,
      };

  List<PieChartSectionData> _buildSections(int total) {
    if (total == 0) {
      return [
        PieChartSectionData(
          value: 1,
          color: Colors.grey.shade300,
          title: '',
          radius: 28,
        ),
      ];
    }

    final values = [
      widget.success,
      widget.pending,
      widget.late,
      widget.abnormal,
    ];

    return List.generate(4, (i) {
      final isTouched = i == _touchedIndex;
      return PieChartSectionData(
        // use 0.001 for zero so index always maps to category
        value: values[i] == 0 ? 0.001 : values[i].toDouble(),
        color: _colors[i],
        title: '',
        radius: isTouched ? 36 : 28,
      );
    });
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.label,
    required this.count,
    required this.color,
    required this.highlighted,
  });

  final String label;
  final int count;
  final Color color;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: highlighted ? color.withValues(alpha: 0.14) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: highlighted
            ? Border.all(color: color.withValues(alpha: 0.40))
            : Border.all(color: Colors.transparent),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: highlighted
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.55),
                        blurRadius: 6,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$label  $count',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight:
                      highlighted ? FontWeight.w700 : FontWeight.w500,
                  color: highlighted
                      ? color
                      : Theme.of(context).textTheme.bodySmall?.color,
                ),
          ),
        ],
      ),
    );
  }
}
