import 'package:flutter/material.dart';

/// Simple rule-of-thirds overlay for guiding composition.
class RuleOfThirdsOverlay extends StatelessWidget {
  const RuleOfThirdsOverlay({
    super.key,
    required this.color,
    this.opacity = 0.5,
    this.lineWidth = 1.0,
  });

  final Color color;
  final double opacity;
  final double lineWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(
        painter: _RuleOfThirdsPainter(
          color: color,
          opacity: opacity,
          lineWidth: lineWidth,
        ),
      ),
    );
  }
}

class _RuleOfThirdsPainter extends CustomPainter {
  const _RuleOfThirdsPainter({
    required this.color,
    required this.opacity,
    required this.lineWidth,
  });

  final Color color;
  final double opacity;
  final double lineWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity.clamp(0.0, 1.0))
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke;

    final thirdWidth = size.width / 3;
    final thirdHeight = size.height / 3;

    // Vertical lines
    for (int i = 1; i < 3; i++) {
      final dx = thirdWidth * i;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), paint);
    }

    // Horizontal lines
    for (int i = 1; i < 3; i++) {
      final dy = thirdHeight * i;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RuleOfThirdsPainter oldDelegate) {
    return color != oldDelegate.color ||
        opacity != oldDelegate.opacity ||
        lineWidth != oldDelegate.lineWidth;
  }
}
