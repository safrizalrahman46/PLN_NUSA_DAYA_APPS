import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../models/report_model.dart';
import '../providers/report_provider.dart';
import '../widgets/error_view.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedUnitCode;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: isDark ? ThemeData.dark() : ThemeData.light(),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String _formatDisplayDate(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = _formatDate(_selectedDate);
    final reportsAsync = ref.watch(reportsProvider(ReportsParam(
      tanggal: dateStr,
      kdUnit: _selectedUnitCode,
    )));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Laporan Logsheet',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : AppColors.text,
      ),
      body: Container(
        color: isDark ? AppColors.darkBackground : AppColors.background,
        child: Column(
          children: [
            // Date Picker Banner Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Card(
                elevation: 0,
                color: isDark ? AppColors.darkSurface : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.border.withValues(alpha: 0.5),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tanggal Laporan',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _formatDisplayDate(_selectedDate),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.calendar_today_rounded, size: 16, color: Colors.white),
                        label: const Text('Pilih', style: TextStyle(color: Colors.white)),
                        onPressed: () => _selectDate(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Report Lists
            Expanded(
              child: reportsAsync.when(
                data: (reports) {
                  if (reports.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_late_outlined,
                            size: 64,
                            color: isDark ? Colors.white30 : Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada laporan pada tanggal ini.',
                            style: TextStyle(
                              fontSize: 15,
                              color: isDark ? Colors.white54 : AppColors.textSoft,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final report = reports[index];
                      return _ReportUnitCard(
                        report: report,
                        tanggal: dateStr,
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                error: (err, stack) => ErrorView(
                  errorMessage: err.toString(),
                  onRetry: () => ref.invalidate(reportsProvider(ReportsParam(
                    tanggal: dateStr,
                    kdUnit: _selectedUnitCode,
                  ))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportUnitCard extends StatefulWidget {
  final ReportModel report;
  final String tanggal;

  const _ReportUnitCard({
    required this.report,
    required this.tanggal,
  });

  @override
  State<_ReportUnitCard> createState() => _ReportUnitCardState();
}

class _ReportUnitCardState extends State<_ReportUnitCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    final slots = report.logsheetPltd;
    final totalSlots = slots.length;
    final filledSlots = slots.values.where((s) => s.isDone).length;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: isDark ? AppColors.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.border.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // Unit Summary Row
          ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.factory_rounded, color: AppColors.primary),
            ),
            title: Text(
              report.namaUnit,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                'Terisi $filledSlots dari $totalSlots slot waktu',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            trailing: IconButton(
              icon: Icon(
                _isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                color: AppColors.primary,
              ),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
            ),
          ),
          
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih Slot Waktu Laporan:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Grid of 48 half-hour slots
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 2.2,
                    ),
                    itemCount: totalSlots,
                    itemBuilder: (context, index) {
                      final sortedKeys = slots.keys.toList()..sort();
                      final slotTime = sortedKeys[index];
                      final slot = slots[slotTime]!;

                      return _buildSlotChip(context, slotTime, slot, widget.tanggal, isDark);
                    },
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildSlotChip(
    BuildContext context,
    String time,
    LogsheetSlotStatus status,
    String tanggal,
    bool isDark,
  ) {
    final isDone = status.isDone;
    
    return Material(
      color: isDone
          ? AppColors.success.withValues(alpha: 0.15)
          : (isDark ? AppColors.darkBackground : Colors.grey[100]),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: isDone
            ? () {
                context.push(
                  '/reports/detail/${status.idBeban!}',
                  extra: {
                    'tanggal': tanggal,
                    'jam': '$time:00', // ensure format matches backend expected parameters
                  },
                );
              }
            : null, // Disabled if not done
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDone
                  ? AppColors.success.withValues(alpha: 0.5)
                  : (isDark ? AppColors.darkBorder : Colors.grey[300]!),
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                size: 12,
                color: isDone ? AppColors.success : Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                  color: isDone
                      ? AppColors.success
                      : (isDark ? Colors.white60 : Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
