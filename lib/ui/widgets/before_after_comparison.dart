import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:softlightstudio/ui/theme.dart';

/// Professional before/after comparison modes
enum ComparisonMode {
  split('Split View', Icons.view_column_rounded),
  sideBySide('Side by Side', Icons.view_carousel_rounded),
  overlay('Overlay', Icons.layers_rounded),
  none('Full Image', Icons.photo_rounded);

  const ComparisonMode(this.displayName, this.icon);
  final String displayName;
  final IconData icon;
}

/// Professional before/after comparison widget for mobile photo editing
class BeforeAfterComparison extends StatefulWidget {
  const BeforeAfterComparison({
    super.key,
    required this.originalImage,
    required this.processedImage,
  });

  final Widget originalImage;
  final Widget processedImage;

  @override
  State<BeforeAfterComparison> createState() => _BeforeAfterComparisonState();
}

class _BeforeAfterComparisonState extends State<BeforeAfterComparison> 
    with TickerProviderStateMixin {
  ComparisonMode _mode = ComparisonMode.none;
  double _splitPosition = 0.5;
  bool _showingOriginal = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main comparison view
        Positioned.fill(
          child: _buildComparisonView(),
        ),
        
        // Control panel
        Positioned(
          top: 16,
          right: 16,
          child: _ComparisonControls(
            mode: _mode,
            onModeChanged: (mode) {
              setState(() {
                _mode = mode;
              });
              HapticFeedback.lightImpact();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonView() {
    switch (_mode) {
      case ComparisonMode.split:
        return _buildSplitView();
      case ComparisonMode.sideBySide:
        return _buildSideBySideView();
      case ComparisonMode.overlay:
        return _buildOverlayView();
      case ComparisonMode.none:
        return widget.processedImage;
    }
  }

  Widget _buildSplitView() {
    return GestureDetector(
      onPanUpdate: (details) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final localPosition = box.globalToLocal(details.globalPosition);
        final newPosition = localPosition.dx / box.size.width;
        
        setState(() {
          _splitPosition = newPosition.clamp(0.1, 0.9);
        });
      },
      child: Stack(
        children: [
          // Original image (left side)
          Positioned.fill(
            child: ClipRect(
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: _splitPosition,
                  child: widget.originalImage,
                ),
              ),
            ),
          ),
          
          // Processed image (right side)
          Positioned.fill(
            child: ClipRect(
              child: Align(
                alignment: Alignment.centerRight,
                child: FractionallySizedBox(
                  widthFactor: 1 - _splitPosition,
                  child: widget.processedImage,
                ),
              ),
            ),
          ),
          
          // Split line with handle
          Positioned(
            left: MediaQuery.of(context).size.width * _splitPosition - 1,
            top: 0,
            bottom: 0,
            child: _SplitHandle(
              onPositionChanged: (newPosition) {
                setState(() {
                  _splitPosition = newPosition;
                });
              },
            ),
          ),
          
          // Labels
          Positioned(
            bottom: 20,
            left: 20,
            child: _ComparisonLabel(
              text: 'BEFORE',
              visible: _splitPosition > 0.2,
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: _ComparisonLabel(
              text: 'AFTER',
              visible: _splitPosition < 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideBySideView() {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              const _ComparisonLabel(text: 'BEFORE', visible: true),
              const SizedBox(height: 8),
              Expanded(child: widget.originalImage),
            ],
          ),
        ),
        Container(
          width: 2,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          color: SoftlightTheme.accentRed.withOpacity(0.6),
        ),
        Expanded(
          child: Column(
            children: [
              const _ComparisonLabel(text: 'AFTER', visible: true),
              const SizedBox(height: 8),
              Expanded(child: widget.processedImage),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverlayView() {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _showingOriginal = true;
        });
        _fadeController.forward();
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        setState(() {
          _showingOriginal = false;
        });
        _fadeController.reverse();
      },
      onTapCancel: () {
        setState(() {
          _showingOriginal = false;
        });
        _fadeController.reverse();
      },
      child: Stack(
        children: [
          widget.processedImage,
          FadeTransition(
            opacity: _fadeAnimation,
            child: widget.originalImage,
          ),
          
          // Tap instruction
          if (!_showingOriginal)
            const Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: _ComparisonLabel(
                text: 'HOLD TO SEE ORIGINAL',
                visible: true,
                center: true,
              ),
            ),
          
          if (_showingOriginal)
            const Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: _ComparisonLabel(
                text: 'BEFORE',
                visible: true,
                center: true,
              ),
            ),
        ],
      ),
    );
  }
}

/// Split handle widget for the split view
class _SplitHandle extends StatelessWidget {
  const _SplitHandle({
    required this.onPositionChanged,
  });

  final ValueChanged<double> onPositionChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        final RenderBox? parentBox = context.findRenderObject()?.parent as RenderBox?;
        if (parentBox != null) {
          final localPosition = parentBox.globalToLocal(details.globalPosition);
          final newPosition = localPosition.dx / parentBox.size.width;
          onPositionChanged(newPosition.clamp(0.1, 0.9));
        }
      },
      child: Container(
        width: 2,
        decoration: BoxDecoration(
          color: SoftlightTheme.accentRed,
          boxShadow: [
            BoxShadow(
              color: SoftlightTheme.accentRed.withOpacity(0.4),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: 24,
            height: 40,
            decoration: BoxDecoration(
              color: SoftlightTheme.accentRed,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: SoftlightTheme.white,
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.drag_handle_rounded,
              color: SoftlightTheme.white,
              size: 16,
            ),
          ),
        ),
      ),
    );
  }
}

/// Comparison label widget
class _ComparisonLabel extends StatelessWidget {
  const _ComparisonLabel({
    required this.text,
    required this.visible,
    this.center = false,
  });

  final String text;
  final bool visible;
  final bool center;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: SoftlightTheme.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SoftlightTheme.accentRed.withOpacity(0.6),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontFamily: 'Courier New',
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: SoftlightTheme.white,
        ),
        textAlign: center ? TextAlign.center : TextAlign.left,
      ),
    );
  }
}

/// Comparison controls panel
class _ComparisonControls extends StatelessWidget {
  const _ComparisonControls({
    required this.mode,
    required this.onModeChanged,
  });

  final ComparisonMode mode;
  final ValueChanged<ComparisonMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: (isDark ? SoftlightTheme.black : SoftlightTheme.white)
            .withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? SoftlightTheme.gray700 : SoftlightTheme.gray300,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: ComparisonMode.values.map((comparisonMode) {
          final isSelected = mode == comparisonMode;
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: GestureDetector(
              onTap: () => onModeChanged(comparisonMode),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? SoftlightTheme.accentRed.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  comparisonMode.icon,
                  size: 20,
                  color: isSelected
                      ? SoftlightTheme.accentRed
                      : (isDark ? SoftlightTheme.gray400 : SoftlightTheme.gray600),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}