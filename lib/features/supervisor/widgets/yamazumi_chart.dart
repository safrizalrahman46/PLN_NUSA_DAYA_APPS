import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class YamazumiChart extends StatelessWidget {
  const YamazumiChart({super.key, required this.rows});

  /// Each row from getReportRows(): {unit, tepatWaktu, terlambat, abnormal, jumlah, ...}
  final List<Map<String, dynamic>> rows;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSoft = isDark ? Colors.white54 : AppColors.textSoft;

    // Top 8 units by total reports, descending
    final sorted = rows.toList()
      ..sort((a, b) {
        final ta = (a['jumlah'] as int? ?? 0);
        final tb = (b['jumlah'] as int? ?? 0);
        return tb.compareTo(ta);
      });
    final display = sorted.take(8).toList();

    if (display.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(child: Text('Tidak ada data laporan')),
      );
    }

    // Compute per-bar totals and maxY
    int overallMax = 0;
    for (final row in display) {
      final t = (row['tepatWaktu'] as int? ?? 0) +
          (row['terlambat'] as int? ?? 0) +
          (row['abnormal'] as int? ?? 0);
      if (t > overallMax) overallMax = t;
    }
    final maxY = max(overallMax, 1).toDouble() * 1.25;
    final interval = max(1, (maxY / 4).ceil()).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Legend
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: const [
            _YamazumiLegendDot(label: 'Tepat Waktu', color: AppColors.success),
            _YamazumiLegendDot(label: 'Terlambat', color: AppColors.warning),
            _YamazumiLegendDot(label: 'Abnormal', color: AppColors.danger),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 260,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    if (groupIndex >= display.length) return null;
                    final row = display[groupIndex];
                    final unit = _abbrev(row['unit'].toString());
                    final onTime = row['tepatWaktu'] as int? ?? 0;
                    final late = row['terlambat'] as int? ?? 0;
                    final abnormal = row['abnormal'] as int? ?? 0;
                    return BarTooltipItem(
                      '$unit\n',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                      children: [
                        TextSpan(
                          text: 'Tepat: $onTime  Lambat: $late  Abnormal: $abnormal',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: interval,
                    getTitlesWidget: (value, meta) {
                      if (value == 0) return const SizedBox.shrink();
                      return Text(
                        value.toInt().toString(),
                        style: TextStyle(fontSize: 10, color: textSoft),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 56,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= display.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Transform.rotate(
                          angle: -0.55,
                          child: Text(
                            _abbrev(display[index]['unit'].toString()),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: textSoft,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: interval,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.07),
                  strokeWidth: 1,
                  dashArray: [4, 4],
                ),
              ),
              barGroups: display.asMap().entries.map((entry) {
                final index = entry.key;
                final row = entry.value;
                final onTime =
                    (row['tepatWaktu'] as int? ?? 0).toDouble();
                final late =
                    (row['terlambat'] as int? ?? 0).toDouble();
                final abnormal =
                    (row['abnormal'] as int? ?? 0).toDouble();
                final total = onTime + late + abnormal;

                if (total == 0) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: 0,
                        width: 18,
                        color: Colors.transparent,
                      ),
                    ],
                  );
                }

                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: total,
                      width: 18,
                      color: Colors.transparent,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(5),
                        topRight: Radius.circular(5),
                      ),
                      rodStackItems: [
                        BarChartRodStackItem(
                          0,
                          onTime,
                          AppColors.success,
                        ),
                        BarChartRodStackItem(
                          onTime,
                          onTime + late,
                          AppColors.warning,
                        ),
                        BarChartRodStackItem(
                          onTime + late,
                          total,
                          AppColors.danger,
                        ),
                      ],
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  static String _abbrev(String name) {
    final stripped = name.replaceFirst('PLTD ', '');
    return stripped.length > 10 ? stripped.substring(0, 10) : stripped;
  }
}

class _YamazumiLegendDot extends StatelessWidget {
  const _YamazumiLegendDot({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.50),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
