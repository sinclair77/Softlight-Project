import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:softlightstudio/editor/presets_manager.dart';
import 'package:softlightstudio/models/subscription_state.dart';
import 'package:softlightstudio/ui/theme.dart';
import 'package:softlightstudio/editor/editor_state.dart';
import 'package:softlightstudio/ui/knobs/knob.dart';
import 'package:softlightstudio/ui/onboarding_screen.dart';

import 'package:softlightstudio/ui/panels/presets_panel.dart';
import 'package:softlightstudio/ui/panels/export_panel.dart';
import 'package:softlightstudio/ui/panels/crop_panel.dart';
import 'package:softlightstudio/ui/panels/filters_panel.dart';
import 'package:softlightstudio/ui/panels/color_balance_panel.dart';
import 'package:softlightstudio/ui/panels/settings_panel.dart';
import 'package:softlightstudio/ui/histogram/draggable_histogram.dart';
import 'package:softlightstudio/ui/widgets/animated_toggle.dart';
import 'package:softlightstudio/ui/widgets/before_after_comparison.dart';
import 'package:softlightstudio/ui/widgets/rule_of_thirds_overlay.dart';
import 'package:softlightstudio/ui/widgets/nothing_progress_indicator.dart';
import 'package:softlightstudio/util/ui_debug_flags.dart';

class _PanelShortcut {
  const _PanelShortcut({
    required this.id,
    required this.icon,
    required this.label,
  });

  final String id;
  final IconData icon;
  final String label;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PresetsManager.instance.loadPresets();
  
  // Initialize subscription state
  final subscriptionState = SubscriptionState();
  await subscriptionState.initialize();
  
  runApp(SoftlightStudioApp(subscriptionState: subscriptionState));
}

class SoftlightStudioApp extends StatefulWidget {
  final SubscriptionState subscriptionState;
  
  const SoftlightStudioApp({super.key, required this.subscriptionState});

  @override
  State<SoftlightStudioApp> createState() => _SoftlightStudioAppState();
}

class _SoftlightStudioAppState extends State<SoftlightStudioApp> {
  bool isDarkMode = true; // Start with dark mode for Nothing OS feel

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => EditorState()),
        ChangeNotifierProvider.value(value: widget.subscriptionState),
      ],
      child: Consumer<EditorState>(
        builder: (context, editorState, child) {
          final accent = editorState.highlightColor;
          return AnimatedTheme(
            data: isDarkMode
                ? SoftlightTheme.buildDarkTheme(accent: accent)
                : SoftlightTheme.buildLightTheme(accent: accent),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: MaterialApp(
              title: 'Softlight Studio',
              debugShowCheckedModeBanner: false,
              theme: isDarkMode
                  ? SoftlightTheme.buildDarkTheme(accent: accent)
                  : SoftlightTheme.buildLightTheme(accent: accent),
              home: Consumer<SubscriptionState>(
                builder: (context, subscriptionState, child) {
                  if (!subscriptionState.onboardingCompleted) {
                    return const OnboardingScreen();
                  }
                  return HomePage(onToggleTheme: toggleTheme);
                },
              ),
              builder: (context, child) {
                // Ensure fonts are loaded and provide fallback
                return MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(1.0)),
                  child: child ?? Container(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _DesktopSettingsDialog extends StatefulWidget {
  const _DesktopSettingsDialog({required this.onToggleTheme});

  final VoidCallback onToggleTheme;

  @override
  State<_DesktopSettingsDialog> createState() => _DesktopSettingsDialogState();
}

class _DesktopSettingsDialogState extends State<_DesktopSettingsDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 280),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleClose() async {
    await _controller.reverse();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.85, end: 1.0).animate(_scaleAnimation),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 48),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 620),
            decoration: BoxDecoration(
              color: isDark
                  ? SoftlightTheme.gray900.withAlpha(245)
                  : SoftlightTheme.white.withAlpha(245),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isDark ? SoftlightTheme.gray700 : SoftlightTheme.gray200,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.35 : 0.2),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12, right: 12),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          splashRadius: 18,
                          tooltip: 'Close settings',
                          icon: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: isDark
                                ? SoftlightTheme.gray400
                                : SoftlightTheme.gray600,
                          ),
                          onPressed: _handleClose,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SettingsPanel(onToggleTheme: widget.onToggleTheme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const HomePage({super.key, required this.onToggleTheme});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedPanel = 'develop'; // develop, color, effects, detail
  bool _isMobilePanelOpen = false;

  static const List<_PanelShortcut> _panelShortcuts = [
    _PanelShortcut(id: 'presets', icon: Icons.auto_awesome, label: 'Presets'),
    _PanelShortcut(id: 'crop', icon: Icons.crop, label: 'Crop'),
    _PanelShortcut(
      id: 'filters',
      icon: Icons.filter_alt_outlined,
      label: 'Filters',
    ),
    _PanelShortcut(id: 'develop', icon: Icons.tune, label: 'Develop'),
    _PanelShortcut(id: 'color', icon: Icons.palette_outlined, label: 'Color'),
    _PanelShortcut(id: 'effects', icon: Icons.blur_on, label: 'Effects'),
    _PanelShortcut(id: 'detail', icon: Icons.grain, label: 'Detail'),
  ];

  // Viewing options state
  bool _showHistogram = false;
  bool _showHighlightPeaking = false;
  bool _showGridView = false;
  bool _showBeforeAfter = false;

  void _showViewingOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (context) => _buildViewingOptionsPanel(),
    );
  }

  void _openMobilePanel(String panelId) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedPanel == panelId && _isMobilePanelOpen) {
        _isMobilePanelOpen = false;
      } else {
        _selectedPanel = panelId;
        _isMobilePanelOpen = true;
      }
    });
  }

  void _closeMobilePanel() {
    if (_isMobilePanelOpen) {
      setState(() => _isMobilePanelOpen = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = context.watch<EditorState>().highlightColor;

    return Scaffold(
      backgroundColor: isDark ? SoftlightTheme.gray950 : SoftlightTheme.gray50,
      body: SafeArea(
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return Consumer<EditorState>(
                  builder: (context, editorState, child) {
                    final useCompactLayout = constraints.maxWidth < 900;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildNothingHeader(isDark, accentColor),
                        Expanded(
                          child: useCompactLayout
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          16,
                                          16,
                                          16,
                                          16,
                                        ),
                                        child: _buildImageArea(editorState, isDark),
                                      ),
                                    ),
                                    AnimatedSize(
                                      duration: const Duration(milliseconds: 260),
                                      curve: Curves.easeOutCubic,
                                      child: _isMobilePanelOpen
                                          ? Padding(
                                              padding: const EdgeInsets.fromLTRB(
                                                12,
                                                0,
                                                12,
                                                12,
                                              ),
                                              child: _buildMobilePanel(
                                                editorState,
                                                isDark,
                                              ),
                                            )
                                          : const SizedBox.shrink(),
                                    ),
                                    _buildMobileBottomBar(isDark, accentColor),
                                  ],
                                )
                              : Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    16,
                                    16,
                                    16,
                                  ),
                                  child: LayoutBuilder(
                                    builder: (context, layoutConstraints) {
                                      const spacing = 16.0;
                                      const minImageHeight = 280.0;
                                      const minPanelHeight = 200.0;
                                      const maxPanelHeight = 520.0;

                                      if (!layoutConstraints.maxHeight.isFinite) {
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            Expanded(
                                              child: _buildImageArea(editorState, isDark),
                                            ),
                                            const SizedBox(height: spacing),
                                            Align(
                                              alignment: Alignment.center,
                                              child: ConstrainedBox(
                                                constraints: const BoxConstraints(
                                                  maxWidth: 720,
                                                  maxHeight: maxPanelHeight,
                                                ),
                                                child: _buildEditingPanel(
                                                  editorState,
                                                  isDark,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }

                                      final availableHeight = math.max(
                                        0.0,
                                        layoutConstraints.maxHeight - spacing,
                                      );

                                      double panelHeight = math.min(
                                        maxPanelHeight,
                                        availableHeight * 0.35,
                                      );
                                      double imageHeight = availableHeight - panelHeight;

                                      if (imageHeight < minImageHeight) {
                                        imageHeight = math.min(minImageHeight, availableHeight);
                                        panelHeight = math.max(0.0, availableHeight - imageHeight);
                                      }

                                      if (panelHeight < minPanelHeight &&
                                          availableHeight > minImageHeight + minPanelHeight) {
                                        panelHeight = minPanelHeight;
                                        imageHeight = availableHeight - panelHeight;
                                      }

                                      if (panelHeight <= 0.0) {
                                        return SizedBox(
                                          height: availableHeight,
                                          child: _buildImageArea(editorState, isDark),
                                        );
                                      }

                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          SizedBox(
                                            height: imageHeight,
                                            child: _buildImageArea(editorState, isDark),
                                          ),
                                          const SizedBox(height: spacing),
                                          SizedBox(
                                            height: panelHeight,
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: ConstrainedBox(
                                                constraints: const BoxConstraints(
                                                  maxWidth: 720,
                                                  maxHeight: maxPanelHeight,
                                                ),
                                                child: _buildEditingPanel(
                                                  editorState,
                                                  isDark,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            if (showLayoutDebugging)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFE53935), Color(0xFFD81B60)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'UI DEBUG MODE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontFamily: 'Courier New',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Check the console for overflow warnings.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontFamily: 'Courier New',
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

  Widget _buildNothingHeader(bool isDark, Color accent) {
    return Consumer<SubscriptionState>(
      builder: (context, subscriptionState, child) {
        return Container(
          height: 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [SoftlightTheme.gray800, SoftlightTheme.gray900]
                  : [SoftlightTheme.white, SoftlightTheme.gray50],
            ),
            border: Border(
              bottom: BorderSide(
                color: isDark ? SoftlightTheme.gray800 : SoftlightTheme.gray200,
                width: 0.33,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'SOFTLIGHT STUDIO',
                      style: TextStyle(
                        fontFamily: 'Courier New',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? SoftlightTheme.white
                            : SoftlightTheme.gray900,
                        letterSpacing: 2.8,
                      ),
                    ),
                    if (subscriptionState.isPremium) ...[
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: SoftlightTheme.nothingRed.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: SoftlightTheme.nothingRed.withOpacity(0.4),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.workspace_premium,
                              size: 12,
                              color: SoftlightTheme.nothingRed,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'PRO',
                              style: TextStyle(
                                fontFamily: 'Courier New',
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: SoftlightTheme.nothingRed,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const Spacer(),
            // Export button
            IconButton(
              icon: Icon(
                Icons.share_outlined,
                size: 20,
                color: isDark ? SoftlightTheme.gray400 : SoftlightTheme.gray600,
              ),
              onPressed: () => _showExportDialog(context),
            ),
            // Eye icon for viewing options
            IconButton(
              icon: Icon(
                Icons.visibility_outlined,
                size: 20,
                color: isDark ? SoftlightTheme.gray400 : SoftlightTheme.gray600,
              ),
              onPressed: _showViewingOptions,
            ),
            // Settings button
            IconButton(
              icon: Icon(
                Icons.settings_outlined,
                size: 20,
                color: isDark ? SoftlightTheme.gray400 : SoftlightTheme.gray600,
              ),
              onPressed: () => _showSettingsDialog(context),
            ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageArea(EditorState editorState, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: const Alignment(-0.6, -0.7),
          end: const Alignment(0.6, 0.7),
          colors: isDark
              ? [
                  SoftlightTheme.gray700,
                  SoftlightTheme.gray800,
                  SoftlightTheme.gray900,
                ]
              : [
                  SoftlightTheme.white,
                  SoftlightTheme.gray50,
                  SoftlightTheme.gray100,
                ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? SoftlightTheme.gray700.withOpacity(0.8)
              : SoftlightTheme.gray300.withOpacity(0.8),
          width: 0.5,
        ),
      ),
      child: editorState.hasImage
          ? _buildImageDisplay(editorState)
          : _buildImagePlaceholder(editorState, isDark),
    );
  }

  Widget _buildImageDisplay(EditorState editorState) {
    final displayImage = editorState.displayImage;
    final originalImage = editorState.sourceImage?.image;
    final processedImage = editorState.processedImage;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget buildImageContent() {
      if (displayImage == null) {
        return const Center(child: CircularProgressIndicator());
      }

      final imageWidth = displayImage.width.toDouble();
      final imageHeight = displayImage.height.toDouble();

      final baseContent = _showBeforeAfter && originalImage != null && processedImage != null
          ? BeforeAfterComparison(
              originalImage: RawImage(image: originalImage, fit: BoxFit.cover),
              processedImage: RawImage(
                image: processedImage,
                fit: BoxFit.cover,
              ),
            )
          : RawImage(image: displayImage, fit: BoxFit.cover);

      return LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth.isFinite ? constraints.maxWidth : imageWidth;
          final maxHeight = constraints.maxHeight.isFinite ? constraints.maxHeight : imageHeight;

          double scale = math.min(
            maxWidth / imageWidth,
            maxHeight / imageHeight,
          );

          if (!scale.isFinite || scale <= 0) {
            scale = 1.0;
          }

          final fittedWidth = imageWidth * scale;
          final fittedHeight = imageHeight * scale;

          return Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: fittedWidth,
              height: fittedHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  baseContent,
                  if (_showGridView)
                    IgnorePointer(
                      child: RuleOfThirdsOverlay(
                        color: editorState.highlightColor,
                        opacity: isDark ? 0.55 : 0.4,
                        lineWidth: 1.2,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: isDark
                  ? SoftlightTheme.gray950.withOpacity(0.6)
                  : SoftlightTheme.gray50,
              child: Center(child: buildImageContent()),
            ),
          ),
          if (editorState.isProcessing)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: NothingProgressIndicator(
                  color: editorState.highlightColor,
                ),
              ),
            ),
          if (displayImage != null)
            Positioned(top: 16, right: 16, child: _buildBeforeAfterButton()),
          DraggableHistogram(
            image: displayImage,
            isVisible: _showHistogram,
            onClose: () => setState(() => _showHistogram = false),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder(EditorState editorState, bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final accent = editorState.highlightColor;
        final maxWidth = constraints.maxWidth.isFinite
            ? math.min(constraints.maxWidth, 520.0)
            : 520.0;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark
                              ? SoftlightTheme.gray700.withOpacity(0.22)
                              : SoftlightTheme.gray200.withOpacity(0.45),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? SoftlightTheme.gray600
                                : SoftlightTheme.gray300,
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.photo_library_outlined,
                          size: 52,
                          color: accent,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Welcome to Softlight Studio',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Courier New',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.8,
                          color: isDark
                              ? SoftlightTheme.gray100
                              : SoftlightTheme.gray800,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => editorState.loadFromPicker(),
                            icon: const Icon(Icons.upload_file, size: 20),
                            label: const Text('CHOOSE A PHOTO'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              textStyle: const TextStyle(
                                fontFamily: 'Courier New',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: () => editorState.loadPlaceholder(),
                            icon: const Icon(Icons.auto_awesome, size: 18),
                            label: const Text('TRY A DEMO IMAGE'),
                            style: TextButton.styleFrom(
                              foregroundColor: isDark
                                  ? SoftlightTheme.gray200
                                  : SoftlightTheme.gray700,
                              textStyle: const TextStyle(
                                fontFamily: 'Courier New',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildOnboardingTip(
                            icon: Icons.upload,
                            text: 'Supports RAW up to hundreds of megapixels.',
                            isDark: isDark,
                            accent: accent,
                          ),
                          _buildOnboardingTip(
                            icon: Icons.tune,
                            text: 'Long-press a knob to enter fine adjustment mode.',
                            isDark: isDark,
                            accent: accent,
                          ),
                          _buildOnboardingTip(
                            icon: Icons.visibility,
                            text: 'Use the viewing options to toggle grids and before/after.',
                            isDark: isDark,
                            accent: accent,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOnboardingTip({
    required IconData icon,
    required String text,
    required bool isDark,
    required Color accent,
  }) {
    return Container(
      constraints: const BoxConstraints(minWidth: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? SoftlightTheme.gray800.withOpacity(0.6)
            : SoftlightTheme.gray100.withOpacity(0.8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? SoftlightTheme.gray700 : SoftlightTheme.gray300,
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Courier New',
                fontSize: 11,
                height: 1.4,
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

  /// Editing panel with Nothing OS styling, used for both draggable sheet and desktop layout
  Widget _buildEditingPanel(
    EditorState editorState,
    bool isDark, {
    ScrollController? scrollController,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? SoftlightTheme.gray900.withAlpha(245)
            : SoftlightTheme.white.withAlpha(245),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: isDark ? SoftlightTheme.gray700 : SoftlightTheme.gray200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 150 : 90),
            blurRadius: 30,
            offset: const Offset(0, -12),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? SoftlightTheme.gray600 : SoftlightTheme.gray400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildEditingTabs(isDark),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: _buildEditingContent(editorState, isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobilePanel(EditorState editorState, bool isDark) {
    final accent = editorState.highlightColor;
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? SoftlightTheme.gray900.withOpacity(0.95)
            : Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? SoftlightTheme.gray700 : SoftlightTheme.gray200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.32 : 0.18),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  _panelTitle(_selectedPanel),
                  style: TextStyle(
                    fontFamily: 'Courier New',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.4,
                    color: isDark
                        ? SoftlightTheme.white
                        : SoftlightTheme.gray900,
                  ),
                ),
                const Spacer(),
                IconButton(
                  splashRadius: 20,
                  icon: Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: isDark
                        ? SoftlightTheme.gray400
                        : SoftlightTheme.gray600,
                  ),
                  onPressed: _closeMobilePanel,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  // Enhanced fade and slide transition
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.05, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      )),
                      child: child,
                    ),
                  );
                },
                child: SingleChildScrollView(
                  key: ValueKey<String>('mobile-$_selectedPanel'),
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildPanelBody(_selectedPanel, editorState, isDark),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileBottomBar(bool isDark, Color accent) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
        child: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? SoftlightTheme.gray900.withOpacity(0.9)
                  : Colors.white.withOpacity(0.94),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark ? SoftlightTheme.gray700 : SoftlightTheme.gray200,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.35 : 0.2),
                  blurRadius: 22,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _panelShortcuts.map((shortcut) {
                  final isSelected =
                      _selectedPanel == shortcut.id && _isMobilePanelOpen;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => _openMobilePanel(shortcut.id),
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        tween: Tween<double>(begin: 1.0, end: isSelected ? 1.0 : 1.0),
                        builder: (context, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOutCubic,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected ? accent : Colors.transparent,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: isSelected
                                      ? accent
                                      : (isDark
                                            ? SoftlightTheme.gray700
                                            : SoftlightTheme.gray300),
                                  width: isSelected ? 1.0 : 0.7,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: accent.withOpacity(0.35),
                                          blurRadius: 14,
                                          offset: const Offset(0, 8),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeOutCubic,
                                    child: Icon(
                                      shortcut.icon,
                                      size: 18,
                                      color: isSelected
                                          ? SoftlightTheme.white
                                          : (isDark
                                                ? SoftlightTheme.gray300
                                                : SoftlightTheme.gray600),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeOutCubic,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontFamily: 'Courier New',
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.2,
                                      color: isSelected
                                          ? SoftlightTheme.white
                                          : (isDark
                                                ? SoftlightTheme.gray400
                                                : SoftlightTheme.gray700),
                                    ),
                                    child: Text(shortcut.label.toUpperCase()),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditingTabs(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildTabButton('PRESETS', 'presets', isDark),
          _buildTabButton('CROP', 'crop', isDark),
          _buildTabButton('FILTERS', 'filters', isDark),
          _buildTabButton('DEVELOP', 'develop', isDark),
          _buildTabButton('COLOR', 'color', isDark),
          _buildTabButton('EFFECTS', 'effects', isDark),
          _buildTabButton('DETAIL', 'detail', isDark),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, String value, bool isDark) {
    final isSelected = _selectedPanel == value;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: () => setState(() => _selectedPanel = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          constraints: const BoxConstraints(minWidth: 96),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? SoftlightTheme.gray700 : SoftlightTheme.gray100)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? (isDark ? SoftlightTheme.gray600 : SoftlightTheme.gray300)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              style: TextStyle(
                fontSize: 11,
                fontFamily: 'Courier New',
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                letterSpacing: 1.2,
                color: isSelected
                    ? (isDark ? Colors.white : SoftlightTheme.gray900)
                    : (isDark
                          ? SoftlightTheme.gray400
                          : SoftlightTheme.gray600),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditingContent(EditorState editorState, bool isDark) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (Widget child, Animation<double> animation) {
        // Enhanced fade and scale transition
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey<String>(_selectedPanel),
        child: _buildPanelBody(_selectedPanel, editorState, isDark),
      ),
    );
  }

  String _panelTitle(String panelId) {
    switch (panelId) {
      case 'presets':
        return 'PRESETS';
      case 'crop':
        return 'CROP';
      case 'filters':
        return 'FILTERS';
      case 'color':
        return 'COLOR';
      case 'effects':
        return 'EFFECTS';
      case 'detail':
        return 'DETAIL';
      case 'develop':
      default:
        return 'DEVELOP';
    }
  }

  Widget _buildPanelBody(String panelId, EditorState editorState, bool isDark) {
    switch (panelId) {
      case 'presets':
        return const PresetsPanel();
      case 'crop':
        return const CropPanel();
      case 'filters':
        return const FiltersPanel();
      case 'color':
        return _buildColorPanel(editorState, isDark);
      case 'effects':
        return _buildEffectsPanel(editorState, isDark);
      case 'detail':
        return _buildDetailPanel(editorState, isDark);
      case 'develop':
      default:
        return _buildDevelopPanel(editorState, isDark);
    }
  }

  Widget _buildBeforeAfterButton() {
    final isActive = _showBeforeAfter;
    final accent = context.read<EditorState>().highlightColor;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _showBeforeAfter = !_showBeforeAfter);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? accent.withOpacity(0.9)
              : SoftlightTheme.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? accent : SoftlightTheme.gray600,
            width: 0.6,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.22),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.compare_arrows_rounded, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              isActive ? 'COMPARING' : 'COMPARE',
              style: const TextStyle(
                fontSize: 9,
                fontFamily: 'Courier New',
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDevelopPanel(EditorState editorState, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildKnobSection(
          title: 'TONE',
          knobs: [
            _buildMobileKnob('EXP', 'exposure', -2.0, 2.0, editorState),
            _buildMobileKnob('CON', 'contrast', -1.0, 1.0, editorState),
            _buildMobileKnob('HI', 'highlights', -1.0, 1.0, editorState),
            _buildMobileKnob('SH', 'shadows', -1.0, 1.0, editorState),
          ],
          isDark: isDark,
        ),
        _buildKnobSection(
          title: 'COLOR',
          knobs: [
            _buildMobileKnob(
              'TEMP',
              'temperature',
              2000.0,
              12000.0,
              editorState,
            ),
            _buildMobileKnob('TINT', 'tint', -1.0, 1.0, editorState),
            _buildMobileKnob('SAT', 'saturation', -1.0, 1.0, editorState),
            _buildMobileKnob('VIB', 'vibrance', -1.0, 1.0, editorState),
          ],
          isDark: isDark,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildEffectsPanel(EditorState editorState, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildKnobSection(
          title: 'EFFECTS',
          knobs: [
            _buildMobileKnob('CLARITY', 'clarity', -1.0, 1.0, editorState),
            _buildMobileKnob('DEHAZE', 'dehaze', -1.0, 1.0, editorState),
            _buildMobileKnob(
              'VIGNETTE',
              'vignetteAmount',
              0.0,
              1.0,
              editorState,
            ),
            _buildMobileKnob('GRAIN', 'grain', 0.0, 1.0, editorState),
          ],
          isDark: isDark,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildDetailPanel(EditorState editorState, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildKnobSection(
          title: 'DETAIL',
          knobs: [
            _buildMobileKnob('SHARP', 'sharpening', 0.0, 2.0, editorState),
            _buildMobileKnob('NOISE', 'noiseReduction', 0.0, 1.0, editorState),
            _buildMobileKnob('TEXTURE', 'texture', -1.0, 1.0, editorState),
            _buildMobileKnob('BLOOM', 'bloomIntensity', 0.0, 1.0, editorState),
          ],
          isDark: isDark,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildColorPanel(EditorState editorState, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ColorBalancePanel(editorState: editorState),
        const SizedBox(height: 20),
        _buildKnobSection(
          title: 'COLOR GRADING',
          knobs: [
            _buildMobileKnob('HUE', 'hue', -180.0, 180.0, editorState),
            _buildMobileKnob('SAT', 'saturation', -1.0, 1.0, editorState),
            _buildMobileKnob('BRT', 'brightness', -1.0, 1.0, editorState),
            _buildMobileKnob('VIB', 'vibrance', -1.0, 1.0, editorState),
          ],
          isDark: isDark,
        ),
        _buildKnobSection(
          title: 'COLOR BALANCE',
          knobs: [
            _buildMobileKnob(
              'TEMP',
              'temperature',
              2000.0,
              12000.0,
              editorState,
            ),
            _buildMobileKnob('TINT', 'tint', -1.0, 1.0, editorState),
            _buildMobileKnob('R/S', 'redShadows', -1.0, 1.0, editorState),
            _buildMobileKnob('G/S', 'greenShadows', -1.0, 1.0, editorState),
          ],
          isDark: isDark,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildKnobSection({
    required String title,
    required List<Widget> knobs,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 12, top: 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'Courier New',
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: isDark ? SoftlightTheme.gray300 : SoftlightTheme.gray700,
              ),
            ),
          ),
          Row(children: knobs.map((knob) => Expanded(child: knob)).toList()),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMobileKnob(
    String label,
    String param,
    double min,
    double max,
    EditorState editorState,
  ) {
    return Consumer<EditorState>(
      builder: (context, state, child) {
        double value;
        switch (param) {
          case 'exposure':
            value = state.params.exposure;
            break;
          case 'contrast':
            value = state.params.contrast;
            break;
          case 'highlights':
            value = state.params.highlights;
            break;
          case 'shadows':
            value = state.params.shadows;
            break;
          case 'temperature':
            value = state.params.temperature;
            break;
          case 'tint':
            value = state.params.tint;
            break;
          case 'saturation':
            value = state.params.saturation;
            break;
          case 'vibrance':
            value = state.params.vibrance;
            break;
          case 'clarity':
            value = state.params.clarity;
            break;
          case 'dehaze':
            value = state.params.dehaze;
            break;
          case 'vignetteAmount':
            value = state.params.vignetteAmount;
            break;
          case 'grain':
            value = state.params.grain;
            break;
          case 'sharpening':
            value = state.params.sharpening;
            break;
          case 'noiseReduction':
            value = state.params.noiseReduction;
            break;
          case 'texture':
            value = state.params.texture;
            break;
          case 'bloomIntensity':
            value = state.params.bloomIntensity;
            break;
          case 'hue':
            value = state.params.hue;
            break;
          case 'brightness':
            value = state.params.brightness;
            break;
          case 'redShadows':
            value = state.params.redShadows;
            break;
          case 'greenShadows':
            value = state.params.greenShadows;
            break;
          default:
            value = 0.0;
        }

        // Create a parameter definition for the knob
        final paramDef = ParamDef(
          name: param,
          label: label,
          min: min,
          max: max,
          defaultValue: 0.0,
          precision: 2,
          unit: param == 'temperature' ? 'K' : '',
        );

        return ParameterKnob(
          paramDef: paramDef,
          value: value,
          onChanged: (newValue) => state.updateParam(param, newValue),
          onReset: () => state.resetParam(param),
          editorState: state,
          size: 55.0, // Smaller for mobile
        );
      },
    );
  }

  Widget _buildViewingOptionsPanel() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: const Alignment(-0.3, -0.4),
          end: const Alignment(0.3, 0.4),
          colors: isDark
              ? [
                  SoftlightTheme.gray800,
                  SoftlightTheme.gray900,
                  SoftlightTheme.gray950,
                ]
              : [
                  SoftlightTheme.white,
                  SoftlightTheme.gray50,
                  SoftlightTheme.gray100,
                ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(
          color: isDark ? SoftlightTheme.gray700 : SoftlightTheme.gray300,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? SoftlightTheme.gray600 : SoftlightTheme.gray400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.visibility_outlined,
                  size: 18,
                  color: isDark
                      ? SoftlightTheme.gray400
                      : SoftlightTheme.gray600,
                ),
                const SizedBox(width: 8),
                Text(
                  'VIEWING OPTIONS',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Courier New',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: isDark
                        ? SoftlightTheme.white
                        : SoftlightTheme.gray900,
                  ),
                ),
              ],
            ),
          ),

          // Viewing options
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildViewingOption(
                    'Histogram',
                    'Show RGB histogram overlay',
                    _showHistogram,
                    (value) => setState(() => _showHistogram = value),
                    isDark,
                  ),
                  _buildViewingOption(
                    'Highlight Peaking',
                    'Show overexposed areas',
                    _showHighlightPeaking,
                    (value) => setState(() => _showHighlightPeaking = value),
                    isDark,
                  ),
                  _buildViewingOption(
                    'Grid View',
                    'Show rule of thirds grid',
                    _showGridView,
                    (value) => setState(() => _showGridView = value),
                    isDark,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewingOption(
    String title,
    String description,
    bool value,
    ValueChanged<bool> onChanged,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Courier New',
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: isDark
                        ? SoftlightTheme.white
                        : SoftlightTheme.gray900,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'Courier New',
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.5,
                    color: isDark
                        ? SoftlightTheme.gray400
                        : SoftlightTheme.gray600,
                  ),
                ),
              ],
            ),
          ),
          Consumer<EditorState>(
            builder: (context, editorState, child) => AnimatedToggleSwitch(
              value: value,
              onChanged: onChanged,
              label: '',
              activeColor: editorState.highlightColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Show export dialog
  void _showExportDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const ExportPanel(),
    );
  }

  /// Show settings dialog
  void _showSettingsDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final useDesktopDialog =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.macOS ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.windows);

    if (useDesktopDialog) {
      showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(isDark ? 0.45 : 0.25),
        builder: (dialogContext) =>
            _DesktopSettingsDialog(onToggleTheme: widget.onToggleTheme),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildModalSettingsPanel(),
    );
  }

  Widget _buildModalSettingsPanel() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: isDark
            ? SoftlightTheme.gray900.withAlpha(250)
            : SoftlightTheme.white.withAlpha(250),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(
          color: isDark ? SoftlightTheme.gray700 : SoftlightTheme.gray200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 150 : 80),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? SoftlightTheme.gray600 : SoftlightTheme.gray400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SafeArea(
              top: false,
              bottom: true,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                child: SettingsPanel(onToggleTheme: widget.onToggleTheme),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
