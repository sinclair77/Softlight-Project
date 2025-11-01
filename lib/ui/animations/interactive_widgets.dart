import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:softlightstudio/ui/theme.dart';
import 'package:softlightstudio/ui/animations/animations.dart';

/// Enhanced icon button with smooth hover and press animations
class NothingIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? color;
  final Color? hoverColor;
  final String? tooltip;
  
  const NothingIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 20.0,
    this.color,
    this.hoverColor,
    this.tooltip,
  });
  
  @override
  State<NothingIconButton> createState() => _NothingIconButtonState();
}

class _NothingIconButtonState extends State<NothingIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;
  bool _isPressed = false;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: NothingDurations.instant,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: NothingCurves.sharp,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      setState(() => _isPressed = true);
      _controller.forward();
      HapticFeedback.lightImpact();
    }
  }
  
  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onPressed?.call();
  }
  
  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = widget.color ??
        (isDark ? SoftlightTheme.gray400 : SoftlightTheme.gray600);
    final hoverColor = widget.hoverColor ?? SoftlightTheme.accentRed;
    
    Widget button = GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: widget.onPressed != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: NothingDurations.fast,
                curve: NothingCurves.entrance,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _isHovered
                      ? hoverColor.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  widget.icon,
                  size: widget.size,
                  color: _isHovered ? hoverColor : defaultColor,
                ),
              ),
            );
          },
        ),
      ),
    );
    
    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }
    
    return button;
  }
}

/// Smooth animated chip with press and hover effects
class NothingChip extends StatefulWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Color? selectedColor;
  final IconData? icon;
  
  const NothingChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.selectedColor,
    this.icon,
  });
  
  @override
  State<NothingChip> createState() => _NothingChipState();
}

class _NothingChipState extends State<NothingChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;
  bool _isHovered = false;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: NothingDurations.instant,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: NothingCurves.sharp,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      setState(() => _isPressed = true);
      _controller.forward();
      HapticFeedback.selectionClick();
    }
  }
  
  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onTap?.call();
  }
  
  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedColor = widget.selectedColor ?? SoftlightTheme.accentRed;
    
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: widget.onTap != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: NothingDurations.fast,
                curve: NothingCurves.entrance,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: widget.selected
                      ? selectedColor
                      : (_isHovered
                          ? (isDark
                              ? SoftlightTheme.gray800
                              : SoftlightTheme.gray200)
                          : (isDark
                              ? SoftlightTheme.gray850
                              : SoftlightTheme.gray100)),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.selected
                        ? selectedColor
                        : (isDark
                            ? SoftlightTheme.gray700
                            : SoftlightTheme.gray300),
                    width: widget.selected ? 1.5 : 0.5,
                  ),
                  boxShadow: widget.selected
                      ? [
                          BoxShadow(
                            color: selectedColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        size: 14,
                        color: widget.selected
                            ? Colors.white
                            : (isDark
                                ? SoftlightTheme.gray300
                                : SoftlightTheme.gray700),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'Courier New',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                        color: widget.selected
                            ? Colors.white
                            : (isDark
                                ? SoftlightTheme.gray200
                                : SoftlightTheme.gray800),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Smooth card with hover elevation effect
class NothingCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final bool elevated;
  
  const NothingCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.elevated = false,
  });
  
  @override
  State<NothingCard> createState() => _NothingCardState();
}

class _NothingCardState extends State<NothingCard> {
  bool _isHovered = false;
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: NothingDurations.standard,
          curve: NothingCurves.entrance,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: isDark ? SoftlightTheme.gray900 : SoftlightTheme.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered
                  ? (isDark ? SoftlightTheme.gray600 : SoftlightTheme.gray300)
                  : (isDark ? SoftlightTheme.gray800 : SoftlightTheme.gray200),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  _isHovered ? (isDark ? 0.4 : 0.15) : (isDark ? 0.2 : 0.08),
                ),
                blurRadius: _isHovered ? 20 : 10,
                offset: Offset(0, _isHovered ? 8 : 4),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Smooth toggle button with scale animation
class NothingToggleButton extends StatefulWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData? icon;
  
  const NothingToggleButton({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.icon,
  });
  
  @override
  State<NothingToggleButton> createState() => _NothingToggleButtonState();
}

class _NothingToggleButtonState extends State<NothingToggleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: NothingDurations.instant,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: NothingCurves.sharp,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _handleTap() {
    _controller.forward().then((_) => _controller.reverse());
    HapticFeedback.selectionClick();
    widget.onChanged(!widget.value);
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: NothingDurations.standard,
              curve: NothingCurves.entrance,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: widget.value
                    ? SoftlightTheme.accentRed
                    : (isDark ? SoftlightTheme.gray800 : SoftlightTheme.gray200),
                borderRadius: BorderRadius.circular(12),
                boxShadow: widget.value
                    ? [
                        BoxShadow(
                          color: SoftlightTheme.accentRed.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      size: 16,
                      color: widget.value
                          ? Colors.white
                          : (isDark
                              ? SoftlightTheme.gray400
                              : SoftlightTheme.gray600),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'Courier New',
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: widget.value
                          ? Colors.white
                          : (isDark
                              ? SoftlightTheme.gray300
                              : SoftlightTheme.gray700),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
