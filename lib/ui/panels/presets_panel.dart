import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:softlightstudio/ui/theme.dart';
import 'package:softlightstudio/editor/editor_state.dart';
import 'package:softlightstudio/editor/presets_manager.dart';
import 'package:softlightstudio/ui/animations/animations.dart';

/// Professional presets panel for mobile photo editing
class PresetsPanel extends StatefulWidget {
  const PresetsPanel({super.key});

  @override
  State<PresetsPanel> createState() => _PresetsPanelState();
}

class _PresetsPanelState extends State<PresetsPanel> with TickerProviderStateMixin {
  PresetCategory selectedCategory = PresetCategory.portrait;
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: NothingDurations.medium,
      vsync: this,
    );
    _slideAnimation = CurvedAnimation(
      parent: _slideController,
      curve: NothingCurves.entrance,
    );
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final editorState = Provider.of<EditorState>(context);

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(_slideAnimation),
      child: Container(
        height: 380,
        decoration: BoxDecoration(
          color: isDark ? SoftlightTheme.gray900 : SoftlightTheme.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: isDark ? SoftlightTheme.gray800 : SoftlightTheme.gray200,
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, -5),
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
            
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Text(
                    'PROFESSIONAL PRESETS',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'CourierNew',
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: isDark ? SoftlightTheme.white : SoftlightTheme.gray900,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDark ? SoftlightTheme.gray400 : SoftlightTheme.gray600,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            
            // Category tabs
            Container(
              height: 48,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: PresetCategory.values.length - 1, // Exclude custom
                itemBuilder: (context, index) {
                  final category = PresetCategory.values[index];
                  final isSelected = selectedCategory == category;
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _CategoryTab(
                      category: category,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          selectedCategory = category;
                        });
                        HapticFeedback.lightImpact();
                      },
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Presets grid
            Expanded(
              child: _PresetsGrid(
                category: selectedCategory,
                editorState: editorState,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Category tab widget
class _CategoryTab extends StatelessWidget {
  const _CategoryTab({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final PresetCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: SoftlightTheme.fastAnimation,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? SoftlightTheme.accentRed
              : (isDark ? SoftlightTheme.gray800 : SoftlightTheme.gray100),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? SoftlightTheme.accentRed
                : (isDark ? SoftlightTheme.gray700 : SoftlightTheme.gray300),
            width: 0.5,
          ),
        ),
        child: Text(
          category.displayName.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontFamily: 'CourierNew',
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: isSelected
                ? SoftlightTheme.white
                : (isDark ? SoftlightTheme.gray300 : SoftlightTheme.gray700),
          ),
        ),
      ),
    );
  }
}

/// Presets grid widget
class _PresetsGrid extends StatelessWidget {
  const _PresetsGrid({
    required this.category,
    required this.editorState,
  });

  final PresetCategory category;
  final EditorState editorState;

  @override
  Widget build(BuildContext context) {
    final presets = PresetsManager.instance.getPresetsByCategory(category);

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemCount: presets.length,
      itemBuilder: (context, index) {
        final preset = presets[index];
        return _PresetCard(
          preset: preset,
          onTap: () {
            PresetsManager.instance.applyPreset(preset, editorState);
            Navigator.pop(context);
          },
        );
      },
    );
  }
}

/// Individual preset card
class _PresetCard extends StatefulWidget {
  const _PresetCard({
    required this.preset,
    required this.onTap,
  });

  final Preset preset;
  final VoidCallback onTap;

  @override
  State<_PresetCard> createState() => _PresetCardState();
}

class _PresetCardState extends State<_PresetCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: SoftlightTheme.fastAnimation,
        transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
        decoration: BoxDecoration(
          color: isDark ? SoftlightTheme.gray800 : SoftlightTheme.gray50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isPressed
                ? SoftlightTheme.accentRed
                : (isDark ? SoftlightTheme.gray700 : SoftlightTheme.gray200),
            width: _isPressed ? 1.5 : 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isPressed ? 0.1 : 0.05),
              blurRadius: _isPressed ? 8 : 4,
              offset: Offset(0, _isPressed ? 4 : 2),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preset name
              Text(
                widget.preset.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'CourierNew',
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: isDark ? SoftlightTheme.white : SoftlightTheme.gray900,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              // Category indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: SoftlightTheme.accentRed.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.preset.category.displayName.toUpperCase(),
                  style: TextStyle(
                    fontSize: 8,
                    fontFamily: 'CourierNew',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: SoftlightTheme.accentRed,
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Description
              Text(
                widget.preset.description,
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'system',
                  fontWeight: FontWeight.w400,
                  color: isDark ? SoftlightTheme.gray400 : SoftlightTheme.gray600,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 8),
              
              // Apply button
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: SoftlightTheme.accentRed.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'APPLY',
                      style: TextStyle(
                        fontSize: 8,
                        fontFamily: 'CourierNew',
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: SoftlightTheme.accentRed,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.touch_app_rounded,
                    size: 16,
                    color: isDark ? SoftlightTheme.gray500 : SoftlightTheme.gray400,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}