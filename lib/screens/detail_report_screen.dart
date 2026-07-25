import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../providers/report_provider.dart';
import '../widgets/error_view.dart';

class DetailReportScreen extends ConsumerWidget {
  final String idBebanUld;
  final String tanggal;
  final String jam;

  const DetailReportScreen({
    super.key,
    required this.idBebanUld,
    required this.tanggal,
    required this.jam,
  });

  String _getStatusText(String status) {
    switch (status) {
      case '01':
        return 'OPERASI';
      case '02':
        return 'STANDBY';
      case '03':
        return 'GANGGUAN';
      case '04':
        return 'PEMELIHARAAN';
      default:
        return 'UNKNOWN';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '01':
        return AppColors.success;
      case '02':
        return AppColors.warning;
      case '03':
      case '04':
        return AppColors.danger;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(reportDetailProvider(ReportDetailParam(
      idBebanUld: idBebanUld,
      tanggal: tanggal,
      jam: jam,
    )));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Laporan Beban',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : AppColors.text,
      ),
      body: Container(
        color: isDark ? AppColors.darkBackground : AppColors.background,
        child: detailAsync.when(
          data: (detail) {
            final uld = detail.bebanUld;
            final machines = detail.bebanMesin;

            return Column(
              children: [
                // Header Summary Card
                if (uld != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    child: Card(
                      elevation: 0,
                      color: AppColors.primary.withValues(alpha: 0.08),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              uld.namaUnit,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildSummaryItem('Tanggal', uld.tanggal, Icons.calendar_today_rounded, isDark),
                                _buildSummaryItem('Waktu / Jam', uld.jam, Icons.access_time_rounded, isDark),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Machines Operational List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    itemCount: machines.length,
                    itemBuilder: (context, index) {
                      final m = machines[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 20),
                        elevation: 0,
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isDark ? AppColors.darkBorder : AppColors.border.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Machine title & status pill
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      m.namaMesin,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(m.kdStatus).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _getStatusText(m.kdStatus),
                                      style: TextStyle(
                                        color: _getStatusColor(m.kdStatus),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'S/N: ${m.noSeri}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              const Divider(height: 28),

                              // Grid Parameters
                              GridView.count(
                                crossAxisCount: 2,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                childAspectRatio: 2.8,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                children: [
                                  _buildParamItem('Daya Mampu', '${m.dayaMampu} kW', isDark),
                                  _buildParamItem('Beban Aktual', m.beban != null ? '${m.beban} kW' : '-', isDark),
                                  _buildParamItem('Stand KWh', m.standKwh != null ? '${m.standKwh}' : '-', isDark),
                                  _buildParamItem('Stand BBM', m.standBbm != null ? '${m.standBbm} L' : '-', isDark),
                                  _buildParamItem('Jam Kerja Mesin', m.jkm != null ? '${m.jkm} jam' : '-', isDark),
                                  _buildParamItem('Tekanan Oli', m.tekOli != null ? '${m.tekOli} bar' : '-', isDark),
                                  _buildParamItem('Temp Air Pendingin', m.temAir != null ? '${m.temAir} °C' : '-', isDark),
                                  _buildParamItem('Tegangan', m.teg != null ? '${m.teg} V' : '-', isDark),
                                ],
                              ),
                              const Divider(height: 32),
                              
                              // Electrical Currents
                              const Text(
                                'Arus Phasa (Ampere)',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildPhasaItem('R', m.arusR, isDark),
                                  _buildPhasaItem('S', m.arusS, isDark),
                                  _buildPhasaItem('T', m.arusT, isDark),
                                ],
                              ),
                              const Divider(height: 32),

                              // Operator & Keterangan
                              _buildFooterRow('Keterangan', m.keterangan, isDark),
                              if (m.operatorName != null) ...[
                                const SizedBox(height: 8),
                                _buildFooterRow('Operator', m.operatorName!, isDark),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          error: (err, stack) => ErrorView(
            errorMessage: err.toString(),
            onRetry: () => ref.invalidate(reportDetailProvider(ReportDetailParam(
              idBebanUld: idBebanUld,
              tanggal: tanggal,
              jam: jam,
            ))),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildParamItem(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPhasaItem(String phase, double? val, bool isDark) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBackground : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Text(
              'Fase $phase',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              val != null ? '$val A' : '-',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterRow(String label, String value, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : AppColors.text,
            ),
          ),
        ),
      ],
    );
  }
}
