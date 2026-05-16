import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/widgets/app_brand_logo.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/glass_card.dart';
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
    final isLast = _index == _items.length - 1;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: Stack(
          children: [
            // Aurora orbs
            Positioned(
              top: -50,
              right: -40,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.auroraCyan.withValues(alpha: 0.26),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -70,
              left: -30,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.auroraViolet.withValues(alpha: 0.20),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
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
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 340),
                            child: Column(
                              key: ValueKey(index),
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GlassCard(
                                  padding: const EdgeInsets.all(24),
                                  borderRadius: 44,
                                  sigmaX: 12,
                                  sigmaY: 12,
                                  borderColor:
                                      Colors.white.withValues(alpha: 0.30),
                                  child: SizedBox(
                                    width: 140,
                                    height: 140,
                                    child: Center(
                                      child: index == 0
                                          ? const AppBrandLogo.full(width: 128)
                                          : Icon(
                                              page.$3,
                                              size: 80,
                                              color: Colors.white,
                                            ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 30),
                                Text(
                                  page.$1,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.displayMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Text(
                                    page.$2,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(color: Colors.white70),
                                  ),
                                ),
                              ],
                            ),
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
                          width: _index == index ? 30 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color:
                                _index == index ? Colors.white : Colors.white54,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    AppButton(
                      label: isLast ? 'Mulai Sekarang' : 'Berikutnya',
                      type: AppButtonType.glass,
                      onPressed: () {
                        if (isLast) {
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
          ],
        ),
      ),
    );
  }
}
