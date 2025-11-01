import 'package:flutter/material.dart';
import 'package:softlightstudio/ui/theme.dart';
import 'package:softlightstudio/ui/animations/animations.dart';
import 'dart:math' as math;

/// Nothing OS-inspired loading indicator
class NothingLoadingIndicator extends StatefulWidget {
  final double size;
  final Color? color;
  final double strokeWidth;
  
  const NothingLoadingIndicator({
    super.key,
    this.size = 32.0,
    this.color,
    this.strokeWidth = 2.5,
  });
  
  @override
  State<NothingLoadingIndicator> createState() => _NothingLoadingIndicatorState();
}

class _NothingLoadingIndicatorState extends State<NothingLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
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
            painter: _NothingLoadingPainter(
              animation: _controller.value,
              color: color,
              strokeWidth: widget.strokeWidth,
            ),
          );
        },
      ),
    );
  }
}

class _NothingLoadingPainter extends CustomPainter {
  final double animation;
  final Color color;
  final double strokeWidth;
  
  _NothingLoadingPainter({
    required this.animation,
    required this.color,
    required this.strokeWidth,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    
    // Main rotating arc
    final startAngle = animation * 2 * math.pi;
    final sweepAngle = math.pi * 0.75;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
    
    // Trailing glow effect
    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = strokeWidth + 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * 0.5,
      false,
      glowPaint,
    );
  }
  
  @override
  bool shouldRepaint(_NothingLoadingPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

/// Processing overlay with Nothing OS styling
class NothingProcessingOverlay extends StatelessWidget {
  final bool isProcessing;
  final String? message;
  final Widget child;
  
  const NothingProcessingOverlay({
    super.key,
    required this.isProcessing,
    this.message,
    required this.child,
  });
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Stack(
      children: [
        child,
        if (isProcessing)
          AnimatedOpacity(
            duration: NothingDurations.standard,
            opacity: isProcessing ? 1.0 : 0.0,
            child: Container(
              color: (isDark ? Colors.black : Colors.white).withOpacity(0.75),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const NothingLoadingIndicator(size: 48),
                    if (message != null) ...[
                      const SizedBox(height: 20),
                      Text(
                        message!,
                        style: TextStyle(
                          fontFamily: 'Courier New',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          color: isDark ? SoftlightTheme.gray200 : SoftlightTheme.gray800,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Pulsing dot indicator - minimal and elegant
class NothingPulsingDot extends StatefulWidget {
  final double size;
  final Color? color;
  
  const NothingPulsingDot({
    super.key,
    this.size = 8.0,
    this.color,
  });
  
  @override
  State<NothingPulsingDot> createState() => _NothingPulsingDotState();
}

class _NothingPulsingDotState extends State<NothingPulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: NothingDurations.breathing,
      vsync: this,
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.4,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? SoftlightTheme.accentRed;
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Three-dot loading animation - playful and minimal
class NothingThreeDotsLoader extends StatefulWidget {
  final double size;
  final Color? color;
  
  const NothingThreeDotsLoader({
    super.key,
    this.size = 8.0,
    this.color,
  });
  
  @override
  State<NothingThreeDotsLoader> createState() => _NothingThreeDotsLoaderState();
}

class _NothingThreeDotsLoaderState extends State<NothingThreeDotsLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
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
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final delay = index * 0.2;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.size * 0.4),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final value = (_controller.value - delay) % 1.0;
              final scale = 1.0 + (math.sin(value * 2 * math.pi) * 0.5);
              final opacity = 0.4 + (math.sin(value * 2 * math.pi) * 0.6);
              
              return Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

/// Skeleton loader for content placeholder
class NothingSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  
  const NothingSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return NothingShimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? SoftlightTheme.gray800 : SoftlightTheme.gray200,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}
