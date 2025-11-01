import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:softlightstudio/ui/theme.dart';

/// Subtle animated-style tech texture overlay inspired by Nothing OS.
/// Adds diagonal circuitry lines and micro dots with very low opacity so it
/// can sit on top of interactive UI without overpowering content.
class TechTextureOverlay extends StatelessWidget {
  const TechTextureOverlay({
    super.key,
    required this.isDark,
    required this.accent,
    this.opacity = 0.06,
  });

  final bool isDark;
  final Color accent;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _TechTexturePainter(
          isDark: isDark,
          accent: accent,
          opacity: opacity,
        ),
      ),
    );
  }
}

class _TechTexturePainter extends CustomPainter {
  const _TechTexturePainter({
    required this.isDark,
    required this.accent,
    required this.opacity,
  });

  final bool isDark;
  final Color accent;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }

    final baseColor = (isDark ? SoftlightTheme.gray200 : SoftlightTheme.gray700)
        .withOpacity(opacity * 0.35);
    final accentColor = accent.withOpacity(opacity * 0.6);

    final baseLinePaint = Paint()
      ..color = baseColor
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;

    final accentLinePaint = Paint()
      ..color = accentColor
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 2);

    final dotPaint = Paint()
      ..color = baseColor.withOpacity(0.65)
      ..style = PaintingStyle.fill;

    final step = 34.0;
    final hypotenuse = math.sqrt(size.width * size.width + size.height * size.height);

    // Draw gentle diagonal guide lines.
    for (double offset = -size.height; offset < size.width; offset += step) {
      final start = Offset(offset, 0);
      final end = Offset(offset + size.height, size.height);
      canvas.drawLine(start, end, baseLinePaint);
    }

    // Accent sweep lines give the reflective shimmer direction.
    for (double offset = 0; offset < hypotenuse; offset += step * 2.2) {
      final start = Offset(offset - size.height * 0.3, size.height);
      final end = Offset(offset + size.height * 0.2, 0);
      canvas.drawLine(start, end, accentLinePaint);
    }

    // Micro-dot matrix pattern for subtle circuitry feel.
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        canvas.drawCircle(Offset(x + 6, y + 6), 0.7, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TechTexturePainter oldDelegate) {
    return oldDelegate.isDark != isDark ||
        oldDelegate.opacity != opacity ||
        oldDelegate.accent != accent;
  }
}
