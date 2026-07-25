import 'dart:convert' show utf8;
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/utils/file_exporter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_exception.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_loading.dart';
import '../../core/widgets/glass_card.dart';
import '../../data/models/app_enums.dart';
import '../../data/models/user_model.dart';
import '../../data/models/logsheet_model.dart';
import '../../data/repositories/error_log_repository.dart';
import '../../data/repositories/logsheet_repository.dart';
import '../../data/repositories/machine_repository.dart';
import '../../data/repositories/retention_repository.dart';
import '../../data/repositories/unit_repository.dart';
import '../../data/dummy/dummy_data.dart';
import '../errors/error_log_page.dart';
import '../logsheet/input_logsheet_page.dart';
import '../notifications/notification_page.dart';
import '../reports/report_page.dart';
import '../supervisor/logsheet_approval_page.dart';
import '../supervisor/admin_management_page.dart';
import 'retention_settings_page.dart';

final adminDashboardCountsProvider = FutureProvider((ref) async {
  final history = await ref.read(logsheetRepositoryProvider).getHistory();
  final errors = await ref.read(errorLogRepositoryProvider).getAll();
  final retention = await ref.read(retentionRepositoryProvider).getArchiveCandidates();
  final units = await ref.read(unitRepositoryProvider).getUnits();
  final machines = await ref.read(machineRepositoryProvider).getAllMachines();
  return {
    'history': history,
    'users': DummyData.users.length,
    'units': units.length,
    'machines': machines.length,
    'reports': history.length,
    'pending': history.where((item) => item.syncStatus != SyncStatus.synced).length,
    'errors': errors.length,
    'retention': retention.length,
  };
});

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key, required this.user});

  final UserModel? user;

  Future<void> _downloadCsv(
    BuildContext context,
    String title,
    String csvContent,
    String filename,
  ) async {
    try {
      final bytes = utf8.encode(csvContent);
      await saveAndShareFile(
        bytes: Uint8List.fromList(bytes),
        filename: filename,
        mimeType: 'text/csv',
        shareText: 'Download Data Grafik: $title',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data $title berhasil diexport!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal export data: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counts = ref.watch(adminDashboardCountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.rate_review_rounded),
            tooltip: 'Persetujuan Logsheet',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const LogsheetApprovalPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: counts.when(
        data: (data) {
          final List<LogsheetModel> history = data['history'] as List<LogsheetModel>? ?? <LogsheetModel>[];

          return ListView(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              MediaQuery.of(context).padding.bottom + 108,
            ),
            children: [
              GlassCard(
                gradient: AppColors.heroGradient,
                borderColor: Colors.transparent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.isSuperadmin == true
                          ? 'Selamat datang, ${user?.name ?? 'Superadmin'} 🛡️'
                          : 'Selamat datang, ${user?.name ?? 'Admin'}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user?.isSuperadmin == true
                          ? 'Anda memiliki akses penuh ke seluruh sistem — input logsheet, kelola user, approval, laporan, dan konfigurasi sistem.'
                          : 'Kelola master data, laporan, retensi, dan log error PLN Nusa Daya dari satu panel.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.92),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _MetricTile(label: 'User', value: '${data['users']}'),
                  _MetricTile(label: 'Unit', value: '${data['units']}', color: AppColors.success),
                  _MetricTile(label: 'Mesin', value: '${data['machines']}', color: AppColors.accent),
                  _MetricTile(label: 'Laporan', value: '${data['reports']}', color: AppColors.highlight),
                  _MetricTile(label: 'Pending', value: '${data['pending']}', color: AppColors.warning),
                  _MetricTile(label: 'Error', value: '${data['errors']}', color: AppColors.danger),
                  _MetricTile(label: 'Retensi', value: '${data['retention']}', color: AppColors.textSoft),
                ],
              ),
              const SizedBox(height: 16),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aksi Admin',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        FilledButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => const LogsheetApprovalPage(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.rate_review_rounded),
                          label: const Text('Approval Logsheet'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => const AdminManagementPage(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.dataset_rounded),
                          label: const Text('Master Data'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => const ReportPage(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.bar_chart_rounded),
                          label: const Text('Laporan'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => const ErrorLogPage(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.bug_report_rounded),
                          label: const Text('Log Error'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => const RetentionSettingsPage(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.archive_rounded),
                          label: const Text('Retensi Data'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => const NotificationPage(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.notifications_active_rounded),
                          label: const Text('Notifikasi'),
                        ),
                        if (user?.isSuperadmin == true) ...[
                          FilledButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) => const InputLogsheetPage(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit_note_rounded),
                            label: const Text('Input Logsheet'),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.highlight,
                              foregroundColor: AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              DonutChart(
                synced: history.where((x) => x.syncStatus == SyncStatus.synced).length.toDouble(),
                pending: history.where((x) => x.syncStatus == SyncStatus.pendingSync).length.toDouble(),
                failed: history.where((x) => x.syncStatus == SyncStatus.failed).length.toDouble(),
                onDownload: () {
                  final synced = history.where((x) => x.syncStatus == SyncStatus.synced).length;
                  final pending = history.where((x) => x.syncStatus == SyncStatus.pendingSync).length;
                  final failed = history.where((x) => x.syncStatus == SyncStatus.failed).length;
                  final csv = 'Status,Jumlah\n'
                      'Synced,$synced\n'
                      'Pending,$pending\n'
                      'Failed/Draft,$failed\n';
                  _downloadCsv(context, 'Status Sinkronisasi Logsheet', csv, 'Status_Sinkronisasi_Logsheet.csv');
                },
              ),
              const SizedBox(height: 16),
              YamazumiChart(
                history: history,
                onDownload: () {
                  final Map<String, List<LogsheetModel>> unitGroups = {};
                  for (final record in history) {
                    unitGroups.putIfAbsent(record.unitName, () => []).add(record);
                  }
                  var csv = 'Unit PLTD,Tepat Waktu,Terlambat,Abnormal,Total Laporan\n';
                  for (final entry in unitGroups.entries) {
                    final name = entry.key;
                    final list = entry.value;
                    final onTime = list.where((x) => x.reportStatus == ReportStatus.onTime).length;
                    final late = list.where((x) => x.reportStatus == ReportStatus.late).length;
                    final abnormal = list.where((x) => x.reportStatus == ReportStatus.abnormal).length;
                    csv += '$name,$onTime,$late,$abnormal,${list.length}\n';
                  }
                  _downloadCsv(context, 'Yamazumi Performa Unit', csv, 'Yamazumi_Performa_Unit.csv');
                },
              ),
              const SizedBox(height: 16),
              SubmissionsTrendChart(
                history: history,
                onDownload: () {
                  final now = DateTime.now();
                  var csv = 'Tanggal,Hari,Jumlah Laporan\n';
                  for (int i = 0; i < 7; i++) {
                    final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i));
                    final key = DateFormat('yyyy-MM-dd').format(day);
                    final dayLabel = DateFormat('EEEE', 'id_ID').format(day);
                    final count = history.where((x) => DateFormat('yyyy-MM-dd').format(x.submittedAt) == key).length;
                    csv += '$key,$dayLabel,$count\n';
                  }
                  _downloadCsv(context, 'Tren Laporan 7 Hari', csv, 'Tren_Laporan_7_Hari.csv');
                },
              ),
            ],
          );
        },
        loading: () => const AppLoading(),
        error: (error, _) => AppErrorState(message: ApiException.fromObject(error).message),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    this.color = AppColors.primary,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width < 700 ? (MediaQuery.of(context).size.width - 52) / 2 : 170,
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSoft)),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class DonutChart extends StatelessWidget {
  final double synced;
  final double pending;
  final double failed;
  final VoidCallback onDownload;

  const DonutChart({
    super.key,
    required this.synced,
    required this.pending,
    required this.failed,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final total = synced + pending + failed;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Status Sinkronisasi Logsheet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.file_download_rounded),
                tooltip: 'Download Data Donut Chart',
                onPressed: onDownload,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CustomPaint(
                  painter: DonutChartPainter(
                    synced: synced,
                    pending: pending,
                    failed: failed,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${total.toInt()}',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          'Total',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LegendItem(
                      color: AppColors.success,
                      label: 'Synced',
                      value: '${synced.toInt()} (${total > 0 ? (synced / total * 100).toStringAsFixed(1) : 0}%)',
                    ),
                    const SizedBox(height: 8),
                    _LegendItem(
                      color: AppColors.warning,
                      label: 'Pending',
                      value: '${pending.toInt()} (${total > 0 ? (pending / total * 100).toStringAsFixed(1) : 0}%)',
                    ),
                    const SizedBox(height: 8),
                    _LegendItem(
                      color: AppColors.danger,
                      label: 'Failed/Draft',
                      value: '${failed.toInt()} (${total > 0 ? (failed / total * 100).toStringAsFixed(1) : 0}%)',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final double synced;
  final double pending;
  final double failed;

  DonutChartPainter({
    required this.synced,
    required this.pending,
    required this.failed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double total = synced + pending + failed;
    if (total == 0) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: (size.width - 22) / 2,
    );

    double startAngle = -math.pi / 2;

    // Draw Synced segment
    if (synced > 0) {
      paint.color = AppColors.success;
      final sweepAngle = (synced / total) * 2 * math.pi;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }

    // Draw Pending segment
    if (pending > 0) {
      paint.color = AppColors.warning;
      final sweepAngle = (pending / total) * 2 * math.pi;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }

    // Draw Failed/Draft segment
    if (failed > 0) {
      paint.color = AppColors.danger;
      final sweepAngle = (failed / total) * 2 * math.pi;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class YamazumiChart extends StatelessWidget {
  final List<LogsheetModel> history;
  final VoidCallback onDownload;

  const YamazumiChart({
    super.key,
    required this.history,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    // Group reports by Unit
    final Map<String, List<LogsheetModel>> unitGroups = {};
    for (final record in history) {
      unitGroups.putIfAbsent(record.unitName, () => []).add(record);
    }

    // Sort by total reports descending and take top 5
    final sortedUnits = unitGroups.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));
    final topUnits = sortedUnits.take(5).toList();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Yamazumi Chart (Penyebaran Status Per Unit)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.file_download_rounded),
                tooltip: 'Download Data Yamazumi Chart',
                onPressed: onDownload,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Menampilkan 5 Unit PLTD dengan volume laporan terbesar',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: topUnits.map((entry) {
              final unitName = entry.key;
              final list = entry.value;
              final int total = list.length;

              final onTime = list.where((x) => x.reportStatus == ReportStatus.onTime).length;
              final late = list.where((x) => x.reportStatus == ReportStatus.late).length;
              final abnormal = list.where((x) => x.reportStatus == ReportStatus.abnormal).length;

              return _YamazumiBar(
                label: unitName.replaceAll('PLTD ', '').replaceAll('ULD ', ''),
                total: total,
                onTime: onTime,
                late: late,
                abnormal: abnormal,
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItemMini(color: AppColors.primary, label: 'Tepat Waktu'),
              const SizedBox(width: 16),
              _LegendItemMini(color: AppColors.warning, label: 'Terlambat'),
              const SizedBox(width: 16),
              _LegendItemMini(color: AppColors.danger, label: 'Abnormal'),
            ],
          ),
        ],
      ),
    );
  }
}

class _YamazumiBar extends StatelessWidget {
  final String label;
  final int total;
  final int onTime;
  final int late;
  final int abnormal;

  const _YamazumiBar({
    required this.label,
    required this.total,
    required this.onTime,
    required this.late,
    required this.abnormal,
  });

  @override
  Widget build(BuildContext context) {
    const double maxBarHeight = 160.0;
    
    // Determine heights proportionally
    final double onTimeHeight = total > 0 ? (onTime / total) * maxBarHeight : 0;
    final double lateHeight = total > 0 ? (late / total) * maxBarHeight : 0;
    final double abnormalHeight = total > 0 ? (abnormal / total) * maxBarHeight : 0;

    return Column(
      children: [
        Text(
          '$total',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 24,
          height: maxBarHeight,
          decoration: BoxDecoration(
            color: AppColors.backgroundSoft,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            verticalDirection: VerticalDirection.up,
            children: [
              if (onTimeHeight > 0)
                Container(
                  width: 24,
                  height: onTimeHeight,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(6),
                      bottomRight: Radius.circular(6),
                    ),
                  ),
                ),
              if (lateHeight > 0)
                Container(
                  width: 24,
                  height: lateHeight,
                  color: AppColors.warning,
                ),
              if (abnormalHeight > 0)
                Container(
                  width: 24,
                  height: abnormalHeight,
                  decoration: const BoxDecoration(
                    color: AppColors.danger,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 55,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class SubmissionsTrendChart extends StatelessWidget {
  final List<LogsheetModel> history;
  final VoidCallback onDownload;

  const SubmissionsTrendChart({
    super.key,
    required this.history,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    // Generate dates for the last 7 days
    final now = DateTime.now();
    final List<DateTime> last7Days = List.generate(7, (i) {
      return DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i));
    });

    final Map<String, int> dailyCounts = {};
    for (final day in last7Days) {
      final key = DateFormat('yyyy-MM-dd').format(day);
      dailyCounts[key] = 0;
    }

    for (final record in history) {
      final key = DateFormat('yyyy-MM-dd').format(record.submittedAt);
      if (dailyCounts.containsKey(key)) {
        dailyCounts[key] = dailyCounts[key]! + 1;
      }
    }

    final dataPoints = last7Days.map((day) {
      final key = DateFormat('yyyy-MM-dd').format(day);
      return dailyCounts[key]!;
    }).toList();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tren Pelaporan Logsheet (7 Hari Terakhir)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.file_download_rounded),
                tooltip: 'Download Data Tren Chart',
                onPressed: onDownload,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            width: double.infinity,
            child: CustomPaint(
              painter: LineChartPainter(dataPoints: dataPoints),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: last7Days.map((day) {
              return Text(
                DateFormat('E', 'id_ID').format(day),
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<int> dataPoints;

  LineChartPainter({required this.dataPoints});

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final maxVal = dataPoints.reduce(math.max);
    final double divisor = maxVal == 0 ? 1.0 : maxVal.toDouble();

    final paintLine = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final paintArea = Paint()
      ..style = PaintingStyle.fill;

    final path = Path();
    final areaPath = Path();

    final double widthSegment = size.width / (dataPoints.length - 1);

    for (int i = 0; i < dataPoints.length; i++) {
      final double x = i * widthSegment;
      final double y = size.height - (dataPoints[i] / divisor) * (size.height - 10) - 5;

      if (i == 0) {
        path.moveTo(x, y);
        areaPath.moveTo(x, size.height);
        areaPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        areaPath.lineTo(x, y);
      }

      if (i == dataPoints.length - 1) {
        areaPath.lineTo(x, size.height);
        areaPath.close();
      }
    }

    // Draw gradient area below line
    final shader = LinearGradient(
      colors: [AppColors.primary.withValues(alpha: 0.35), Colors.transparent],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    paintArea.shader = shader;

    canvas.drawPath(areaPath, paintArea);
    canvas.drawPath(path, paintLine);

    // Draw nodes
    final paintNode = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;
    final paintNodeBorder = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int i = 0; i < dataPoints.length; i++) {
      final double x = i * widthSegment;
      final double y = size.height - (dataPoints[i] / divisor) * (size.height - 10) - 5;

      canvas.drawCircle(Offset(x, y), 5.0, paintNode);
      canvas.drawCircle(Offset(x, y), 5.0, paintNodeBorder);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textSoft,
              ),
        ),
      ],
    );
  }
}

class _LegendItemMini extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItemMini({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
