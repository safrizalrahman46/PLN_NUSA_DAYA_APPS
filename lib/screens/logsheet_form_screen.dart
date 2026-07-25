import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/logsheet_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/error_view.dart';

class LogsheetFormScreen extends ConsumerStatefulWidget {
  final String kdArea;
  final String namaArea;
  final String kdUnit;
  final String namaUnit;

  const LogsheetFormScreen({
    super.key,
    required this.kdArea,
    required this.namaArea,
    required this.kdUnit,
    required this.namaUnit,
  });

  @override
  ConsumerState<LogsheetFormScreen> createState() => _LogsheetFormScreenState();
}

class _LogsheetFormScreenState extends ConsumerState<LogsheetFormScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authProvider).value;
    final kdRegion = user?.kdRegion ?? '05';

    final success = await ref.read(logsheetSubmitProvider.notifier).submit(
          kdRegion: kdRegion,
          messageText: _textController.text,
        );

    if (success && mounted) {
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
            SizedBox(width: 8),
            Text('Laporan Terkirim'),
          ],
        ),
        content: const Text(
          'Logsheet PLTD berhasil disimpan dan dikirimkan ke server DIGIKIT.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/dashboard');
            },
            child: const Text('Ke Dashboard'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.pop(context);
              context.go('/reports');
            },
            child: const Text('Lihat Riwayat Laporan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value;
    final kdRegion = user?.kdRegion ?? '05';
    
    // Watch format data
    final formatAsync = ref.watch(formatProvider(FormatParam(
      kdArea: widget.kdArea,
      kdUnit: widget.kdUnit,
      kdRegion: kdRegion,
    )));

    final submitState = ref.watch(logsheetSubmitProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Listen to submission errors
    ref.listen<AsyncValue<Map<String, dynamic>?>>(logsheetSubmitProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.namaUnit,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: isDark ? Colors.white : AppColors.text,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.info_outline_rounded), text: 'Daftar Mesin'),
            Tab(icon: Icon(Icons.edit_document), text: 'Input Laporan'),
          ],
        ),
      ),
      body: Container(
        color: isDark ? AppColors.darkBackground : AppColors.background,
        child: formatAsync.when(
          data: (formatData) {
            // Auto populate text area if empty
            if (_textController.text.isEmpty && formatData.format != null) {
              _textController.text = formatData.format!.text;
            }

            return TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: Daftar Mesin
                ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: formatData.format?.mesin.length ?? 0,
                  itemBuilder: (context, index) {
                    final mesin = formatData.format!.mesin[index];
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
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                  child: Text(
                                    '${mesin.nomor}',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    mesin.namaMesin,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            _buildInfoRow('ID Mesin', mesin.idMesin, isDark),
                            _buildInfoRow('Serial Number (S/N)', mesin.sn, isDark),
                            _buildInfoRow('Daya Terpasang (DT)', '${mesin.dt} kW', isDark),
                            _buildInfoRow('Bahan Bakar', mesin.kdJenisBahanBakar, isDark),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // TAB 2: Input Form
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Helper Actions bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Sunting Laporan Logsheet',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  tooltip: 'Salin Templat',
                                  icon: const Icon(Icons.copy_all_rounded, color: AppColors.primary),
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: _textController.text));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Format templat disalin')),
                                    );
                                  },
                                ),
                                IconButton(
                                  tooltip: 'Reset Templat',
                                  icon: const Icon(Icons.restore_rounded, color: AppColors.highlight),
                                  onPressed: () {
                                    if (formatData.format != null) {
                                      setState(() {
                                        _textController.text = formatData.format!.text;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Main Multiline text area
                        Expanded(
                          child: TextFormField(
                            controller: _textController,
                            maxLines: null,
                            minLines: 15,
                            keyboardType: TextInputType.multiline,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13,
                              height: 1.4,
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Teks laporan logsheet tidak boleh kosong';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: isDark ? AppColors.darkSurface : Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark ? AppColors.darkBorder : AppColors.border.withValues(alpha: 0.5),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Submission buttons
                        CustomButton(
                          text: 'Submit Logsheet',
                          isLoading: submitState.isLoading,
                          onPressed: _handleSubmit,
                        ),
                      ],
                    ),
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
            onRetry: () => ref.invalidate(formatProvider(FormatParam(
              kdArea: widget.kdArea,
              kdUnit: widget.kdUnit,
              kdRegion: kdRegion,
            ))),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white60 : AppColors.textSoft,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
