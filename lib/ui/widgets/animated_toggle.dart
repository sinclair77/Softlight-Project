import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:softlightstudio/ui/theme.dart';

/// Animated toggle switch with Nothing OS styling
class AnimatedToggleSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;
  final Color? activeColor;

  const AnimatedToggleSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.activeColor,
  });

  @override
  State<AnimatedToggleSwitch> createState() => _AnimatedToggleSwitchState();
}

class _AnimatedToggleSwitchState extends State<AnimatedToggleSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _thumbAnimation;
  late Animation<Color?> _trackColorAnimation;
  late Animation<Color?> _thumbColorAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _thumbAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    final activeColor = widget.activeColor ?? SoftlightTheme.accentRed;
    
    _trackColorAnimation = ColorTween(
      begin: SoftlightTheme.gray700,
      end: activeColor.withAlpha(150),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _thumbColorAnimation = ColorTween(
      begin: SoftlightTheme.gray400,
      end: activeColor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    if (widget.value) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AnimatedToggleSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update color animations if activeColor changed
    if (widget.activeColor != oldWidget.activeColor) {
      final activeColor = widget.activeColor ?? SoftlightTheme.accentRed;
      
      _trackColorAnimation = ColorTween(
        begin: SoftlightTheme.gray700,
        end: activeColor.withAlpha(150),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));

      _thumbColorAnimation = ColorTween(
        begin: SoftlightTheme.gray400,
        end: activeColor,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
    }
    
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    widget.onChanged(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.label.isNotEmpty) ...[
            Text(
              widget.label,
              style: const TextStyle(
                fontFamily: 'Courier New',
                fontSize: 11,
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(width: 12),
          ],
          SizedBox(
            width: 44,
            height: 24,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(44, 24),
                  painter: _TogglePainter(
                    thumbPosition: _thumbAnimation.value,
                    trackColor: _trackColorAnimation.value ?? SoftlightTheme.gray700,
                    thumbColor: _thumbColorAnimation.value ?? SoftlightTheme.gray400,
                    isPressed: _isPressed,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the animated toggle switch
class _TogglePainter extends CustomPainter {
  final double thumbPosition;
  final Color trackColor;
  final Color thumbColor;
  final bool isPressed;

  _TogglePainter({
    required this.thumbPosition,
    required this.trackColor,
    required this.thumbColor,
    required this.isPressed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = thumbPosition > 0.1 ? thumbColor.withAlpha(100) : SoftlightTheme.gray600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final thumbPaint = Paint()
      ..color = thumbColor
      ..style = PaintingStyle.fill;

    final thumbBorderPaint = Paint()
      ..color = thumbColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw track glow when active
    if (thumbPosition > 0.1) {
      final glowPaint = Paint()
        ..color = thumbColor.withAlpha(30)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      
      final glowRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(-2, -2, size.width + 4, size.height + 4),
        Radius.circular((size.height + 4) / 2),
      );
      canvas.drawRRect(glowRect, glowPaint);
    }

    // Draw track
    final trackRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(size.height / 2),
    );
    canvas.drawRRect(trackRect, trackPaint);
    canvas.drawRRect(trackRect, borderPaint);

    // Calculate thumb position
    final thumbSize = size.height - 4; // 2px margin on each side
    final thumbRadius = thumbSize / 2;
    final thumbTravel = size.width - thumbSize - 4; // Account for margins
    final thumbX = 2 + (thumbTravel * thumbPosition) + thumbRadius;
    final thumbY = size.height / 2;
    
    final thumbScale = isPressed ? 1.1 : 1.0;

    // Draw thumb glow when active
    if (thumbPosition > 0.1) {
      final thumbGlowPaint = Paint()
        ..color = thumbColor.withAlpha(80)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(
        Offset(thumbX, thumbY),
        (thumbRadius * thumbScale) + 3,
        thumbGlowPaint,
      );
    }

    // Draw thumb shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withAlpha(60)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(
      Offset(thumbX + 1, thumbY + 1),
      thumbRadius * thumbScale,
      shadowPaint,
    );

    // Draw thumb
    canvas.drawCircle(
      Offset(thumbX, thumbY),
      thumbRadius * thumbScale,
      thumbPaint,
    );
    canvas.drawCircle(
      Offset(thumbX, thumbY),
      thumbRadius * thumbScale,
      thumbBorderPaint,
    );

    // Draw inner dot when active
    if (thumbPosition > 0.5) {
      final dotPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(thumbX, thumbY),
        2.5,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_TogglePainter oldDelegate) {
    return thumbPosition != oldDelegate.thumbPosition ||
           trackColor != oldDelegate.trackColor ||
           thumbColor != oldDelegate.thumbColor ||
           isPressed != oldDelegate.isPressed;
  }
}