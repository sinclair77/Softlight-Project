import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:softlightstudio/ui/theme.dart';

/// Nothing OS styled circular progress indicator with smooth animations
class NothingProgressIndicator extends StatefulWidget {
  const NothingProgressIndicator({
    super.key,
    this.size = 40.0,
    this.color,
    this.strokeWidth = 3.0,
  });

  final double size;
  final Color? color;
  final double strokeWidth;

  @override
  State<NothingProgressIndicator> createState() => _NothingProgressIndicatorState();
}

class _NothingProgressIndicatorState extends State<NothingProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? SoftlightTheme.accentRed;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _NothingProgressPainter(
              progress: _controller.value,
              color: color,
              strokeWidth: widget.strokeWidth,
            ),
          );
        },
      ),
    );
  }
}

class _NothingProgressPainter extends CustomPainter {
  _NothingProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = color.withAlpha(30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Animated arc
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw glow effect
    final glowPaint = Paint()
      ..color = color.withAlpha(80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 2
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final sweepAngle = 2 * math.pi * 0.75; // 75% of circle
    final startAngle = 2 * math.pi * progress - math.pi / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      glowPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );

    // Draw dot at the end
    final dotAngle = startAngle + sweepAngle;
    final dotX = center.dx + radius * math.cos(dotAngle);
    final dotY = center.dy + radius * math.sin(dotAngle);
    
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(dotX, dotY), strokeWidth / 2, dotPaint);
  }

  @override
  bool shouldRepaint(_NothingProgressPainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

/// Linear progress indicator with Nothing OS styling
class NothingLinearProgress extends StatefulWidget {
  const NothingLinearProgress({
    super.key,
    this.value,
    this.color,
    this.height = 4.0,
  });

  final double? value;
  final Color? color;
  final double height;

  @override
  State<NothingLinearProgress> createState() => _NothingLinearProgressState();
}

class _NothingLinearProgressState extends State<NothingLinearProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    
    if (widget.value == null) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(NothingLinearProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == null && !_controller.isAnimating) {
      _controller.repeat();
    } else if (widget.value != null && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? SoftlightTheme.accentRed;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.height / 2),
        child: Stack(
          children: [
            // Background
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? SoftlightTheme.gray800
                    : SoftlightTheme.gray200,
                borderRadius: BorderRadius.circular(widget.height / 2),
              ),
            ),
            
            // Progress
            if (widget.value != null)
              FractionallySizedBox(
                widthFactor: widget.value!.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(widget.height / 2),
                    boxShadow: [
                      BoxShadow(
                        color: color.withAlpha(100),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              )
            else
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.3,
                    child: Transform.translate(
                      offset: Offset(
                        MediaQuery.of(context).size.width * 
                            (_controller.value * 2.3 - 0.3),
                        0,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              color.withAlpha(0),
                              color,
                              color.withAlpha(0),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(widget.height / 2),
                          boxShadow: [
                            BoxShadow(
                              color: color.withAlpha(100),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
