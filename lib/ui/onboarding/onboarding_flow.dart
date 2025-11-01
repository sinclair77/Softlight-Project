import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:softlightstudio/ui/theme.dart';

/// Metadata for each onboarding slide.
class _OnboardingSlide {
  const _OnboardingSlide({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

const List<_OnboardingSlide> _slides = [
  _OnboardingSlide(
    title: 'Tap + to import a photo',
    subtitle: 'Upload RAW, JPEG, or use the demo image to explore the tools.',
    icon: Icons.add_photo_alternate_outlined,
  ),
  _OnboardingSlide(
    title: 'Use panels to edit',
    subtitle: 'Develop, Color, Effects, and Detail panels give you pro controls.',
    icon: Icons.tune,
  ),
  _OnboardingSlide(
    title: 'Compare your results',
    subtitle: 'Toggle Compare for before/after and open the histogram overlay.',
    icon: Icons.compare_arrows_rounded,
  ),
];

/// Displays the onboarding flow as a modal overlay.
Future<void> showOnboardingFlow(BuildContext context) {
  HapticFeedback.lightImpact();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _OnboardingSheet(),
  );
}

class _OnboardingSheet extends StatefulWidget {
  const _OnboardingSheet();

  @override
  State<_OnboardingSheet> createState() => _OnboardingSheetState();
}

class _OnboardingSheetState extends State<_OnboardingSheet> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? SoftlightTheme.gray900.withOpacity(0.96)
              : SoftlightTheme.white.withOpacity(0.96),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark ? SoftlightTheme.gray700 : SoftlightTheme.gray200,
            width: 0.6,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.35 : 0.2),
              blurRadius: 28,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: SoftlightTheme.accentRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'WELCOME TO SOFTLIGHT',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'CourierNew',
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.8,
                        color:
                            isDark ? SoftlightTheme.white : SoftlightTheme.gray900,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: isDark
                            ? SoftlightTheme.gray400
                            : SoftlightTheme.gray600,
                      ),
                      splashRadius: 20,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _slides.length,
                    onPageChanged: (index) => setState(() => _currentIndex = index),
                    itemBuilder: (context, index) {
                      final slide = _slides[index];
                      return _OnboardingCard(slide: slide);
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_slides.length, (index) {
                    final isActive = index == _currentIndex;
                    return AnimatedContainer(
                      duration: SoftlightTheme.mediumAnimation,
                      curve: Curves.easeOutCubic,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 6,
                      width: isActive ? 22 : 8,
                      decoration: BoxDecoration(
                        color: isActive
                            ? SoftlightTheme.accentRed
                            : (isDark
                                ? SoftlightTheme.gray600
                                : SoftlightTheme.gray300),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_currentIndex == _slides.length - 1) {
                      Navigator.pop(context);
                      return;
                    }
                    _controller.nextPage(
                      duration: SoftlightTheme.mediumAnimation,
                      curve: Curves.easeOutCubic,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: SoftlightTheme.accentRed,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _currentIndex == _slides.length - 1 ? 'GET STARTED' : 'NEXT',
                    style: const TextStyle(
                      fontFamily: 'CourierNew',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'SKIP',
                    style: TextStyle(
                      fontFamily: 'CourierNew',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingCard extends StatelessWidget {
  const _OnboardingCard({required this.slide});

  final _OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? SoftlightTheme.gray850 : SoftlightTheme.gray50,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark ? SoftlightTheme.gray700 : SoftlightTheme.gray200,
            width: 0.6,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: SoftlightTheme.accentRed.withOpacity(0.16),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                slide.icon,
                color: SoftlightTheme.accentRed,
                size: 24,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              slide.title,
              style: TextStyle(
                fontFamily: 'CourierNew',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: isDark ? SoftlightTheme.white : SoftlightTheme.gray900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              slide.subtitle,
              style: TextStyle(
                fontFamily: 'system',
                fontSize: 12,
                height: 1.45,
                color: isDark ? SoftlightTheme.gray300 : SoftlightTheme.gray600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
