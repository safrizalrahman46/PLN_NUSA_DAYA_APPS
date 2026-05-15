import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/widgets/app_button.dart';
import '../profile/settings_controller.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _controller = PageController();
  var _index = 0;

  final _items = const [
    (
      'Digital Logsheet PLTD',
      'Input laporan operasional mesin secara cepat dan terstruktur.',
      Icons.description_outlined,
    ),
    (
      'GPS & Foto Bukti',
      'Validasi lokasi operator dan dokumentasi mesin langsung dari aplikasi.',
      Icons.location_on_outlined,
    ),
    (
      'Offline First',
      'Tetap bisa input laporan meskipun jaringan tidak stabil, data akan tersinkron otomatis.',
      Icons.cloud_off_outlined,
    ),
  ];

  Future<void> _finish() async {
    await ref.read(appSettingsProvider.notifier).setOnboardingSeen();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final item = _items[_index];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _finish,
                    child: const Text(
                      'Lewati',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _items.length,
                    onPageChanged: (value) => setState(() => _index = value),
                    itemBuilder: (_, index) {
                      final page = _items[index];
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(36),
                            ),
                            child: Icon(page.$3, size: 72, color: Colors.white),
                          ),
                          const SizedBox(height: 36),
                          Text(
                            page.$1,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.displayMedium
                                ?.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            page.$2,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: Colors.white70),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _items.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _index == index ? 28 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _index == index ? Colors.white : Colors.white54,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: _index == _items.length - 1
                      ? 'Mulai Sekarang'
                      : 'Berikutnya',
                  onPressed: () {
                    if (_index == _items.length - 1) {
                      _finish();
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  item.$1,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.white54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
