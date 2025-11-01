import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:softlightstudio/models/subscription_state.dart';
import 'package:softlightstudio/ui/theme.dart';

/// Onboarding flow screen
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  final List<OnboardingPage> _pages = [
    const OnboardingPage(
      icon: Icons.photo_library_outlined,
      title: 'PROFESSIONAL PHOTO EDITING',
      description:
          'Transform your photos with powerful editing tools designed for photographers and creators.',
      features: [
        'RAW image support up to hundreds of megapixels',
        'Real-time adjustments with instant preview',
        'Professional-grade filters and presets',
      ],
    ),
    const OnboardingPage(
      icon: Icons.tune,
      title: 'INTUITIVE CONTROLS',
      description:
          'Fine-tune every aspect of your photos with our intuitive interface and precise controls.',
      features: [
        'Long-press knobs for fine adjustment mode',
        'Comprehensive tone and color controls',
        'Advanced effects and detail enhancement',
      ],
    ),
    const OnboardingPage(
      icon: Icons.auto_awesome,
      title: 'POWERFUL FEATURES',
      description:
          'Everything you need to create stunning photos, from basic adjustments to advanced techniques.',
      features: [
        'Histogram and viewing options',
        'Before/after comparison slider',
        'Rule of thirds grid overlay',
      ],
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } else {
      _showSubscriptionDialog();
    }
  }

  void _showSubscriptionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const SubscriptionDialog(),
    );
    // No need to do anything here - the dialog handles completing onboarding
    // and the Consumer<SubscriptionState> in main.dart will automatically rebuild
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? SoftlightTheme.gray950 : SoftlightTheme.gray50,
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: List.generate(_pages.length, (index) {
                  return Expanded(
                    child: Container(
                      height: 3,
                      margin: EdgeInsets.only(
                        left: index == 0 ? 0 : 4,
                        right: index == _pages.length - 1 ? 0 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? SoftlightTheme.nothingRed
                            : (isDark
                                  ? SoftlightTheme.gray700
                                  : SoftlightTheme.gray300),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) => _pages[index],
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                      ),
                      child: Text(
                        'BACK',
                        style: TextStyle(
                          fontFamily: 'Courier New',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: isDark
                              ? SoftlightTheme.gray400
                              : SoftlightTheme.gray600,
                        ),
                      ),
                    ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SoftlightTheme.nothingRed,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1
                          ? 'GET STARTED'
                          : 'NEXT',
                      style: const TextStyle(
                        fontFamily: 'Courier New',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

/// Individual onboarding page
class OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final List<String> features;

  const OnboardingPage({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),

          // Icon
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: SoftlightTheme.nothingRed.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: SoftlightTheme.nothingRed.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              size: 64,
              color: SoftlightTheme.nothingRed,
            ),
          ),

          const SizedBox(height: 40),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Courier New',
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              color: isDark ? SoftlightTheme.white : SoftlightTheme.gray900,
            ),
          ),

          const SizedBox(height: 20),

          // Description
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Courier New',
              fontSize: 14,
              height: 1.6,
              color: isDark
                  ? SoftlightTheme.gray400
                  : SoftlightTheme.gray600,
            ),
          ),

          const SizedBox(height: 40),

          // Features
          ...features.map((feature) => _buildFeatureItem(feature, isDark)),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String feature, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: SoftlightTheme.nothingRed,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feature,
              style: TextStyle(
                fontFamily: 'Courier New',
                fontSize: 13,
                height: 1.5,
                color: isDark
                    ? SoftlightTheme.gray300
                    : SoftlightTheme.gray700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Subscription choice dialog
class SubscriptionDialog extends StatelessWidget {
  const SubscriptionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subscriptionState = context.read<SubscriptionState>();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: isDark
              ? SoftlightTheme.gray900.withOpacity(0.98)
              : SoftlightTheme.white.withOpacity(0.98),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? SoftlightTheme.gray700 : SoftlightTheme.gray200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.2),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SoftlightTheme.nothingRed.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.star_rounded,
                  size: 48,
                  color: SoftlightTheme.nothingRed,
                ),
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                'UNLOCK FULL POTENTIAL',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Courier New',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.8,
                  color: isDark ? SoftlightTheme.white : SoftlightTheme.gray900,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Choose how you want to experience Softlight Studio',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Courier New',
                  fontSize: 12,
                  height: 1.5,
                  color: isDark
                      ? SoftlightTheme.gray400
                      : SoftlightTheme.gray600,
                ),
              ),

              const SizedBox(height: 32),

              // Premium option
              _SubscriptionOption(
                icon: Icons.workspace_premium,
                title: 'GO PREMIUM',
                price: '\$4.99/month',
                features: const [
                  'Unlimited exports',
                  'All filters and presets',
                  'No ads or watermarks',
                  'Priority support',
                ],
                isPrimary: true,
                onTap: () async {
                  await subscriptionState
                      .setSubscriptionType(SubscriptionType.premium);
                  await subscriptionState.completeOnboarding();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),

              const SizedBox(height: 16),

              // Free with ads option
              _SubscriptionOption(
                icon: Icons.play_circle_outline,
                title: 'CONTINUE WITH ADS',
                price: 'Free',
                features: const [
                  'Basic editing features',
                  'Limited filters',
                  'Ad-supported experience',
                  'Community support',
                ],
                isPrimary: false,
                onTap: () async {
                  await subscriptionState
                      .setSubscriptionType(SubscriptionType.ads);
                  await subscriptionState.completeOnboarding();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubscriptionOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String price;
  final List<String> features;
  final bool isPrimary;
  final VoidCallback onTap;

  const _SubscriptionOption({
    required this.icon,
    required this.title,
    required this.price,
    required this.features,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isPrimary
              ? SoftlightTheme.nothingRed.withOpacity(0.12)
              : (isDark
                    ? SoftlightTheme.gray800.withOpacity(0.6)
                    : SoftlightTheme.gray100),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPrimary
                ? SoftlightTheme.nothingRed
                : (isDark ? SoftlightTheme.gray700 : SoftlightTheme.gray300),
            width: isPrimary ? 2 : 1,
          ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: SoftlightTheme.nothingRed.withOpacity(0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 28,
                  color: isPrimary
                      ? SoftlightTheme.nothingRed
                      : (isDark
                            ? SoftlightTheme.gray400
                            : SoftlightTheme.gray600),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Courier New',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: isPrimary
                              ? SoftlightTheme.nothingRed
                              : (isDark
                                    ? SoftlightTheme.white
                                    : SoftlightTheme.gray900),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        price,
                        style: TextStyle(
                          fontFamily: 'Courier New',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? SoftlightTheme.gray400
                              : SoftlightTheme.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...features.map(
              (feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: isPrimary
                          ? SoftlightTheme.nothingRed
                          : (isDark
                                ? SoftlightTheme.gray500
                                : SoftlightTheme.gray500),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: TextStyle(
                          fontFamily: 'Courier New',
                          fontSize: 11,
                          height: 1.4,
                          color: isDark
                              ? SoftlightTheme.gray400
                              : SoftlightTheme.gray700,
                        ),
                      ),
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
