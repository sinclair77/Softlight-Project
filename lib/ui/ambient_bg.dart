import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Ambient background with dot grid, scanlines, and subtle vignette
class AmbientBackground extends StatefulWidget {
  const AmbientBackground({
    super.key,
    required this.child,
    this.dotSpacing = 24.0,
    this.dotOpacity = 0.15,
    this.scanlineOpacity = 0.08,
    this.vignetteOpacity = 0.3,
    this.animate = true,
  });
  
  final Widget child;
  final double dotSpacing;
  final double dotOpacity;
  final double scanlineOpacity;
  final double vignetteOpacity;
  final bool animate;
  
  @override
  State<AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<AmbientBackground>
    with TickerProviderStateMixin {
  late AnimationController _sweepController;
  
  @override
  void initState() {
    super.initState();
    _sweepController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    
    if (widget.animate) {
      _sweepController.repeat();
    }
  }
  
  @override
  void dispose() {
    _sweepController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Stack(
      children: [
        // Base background - Pure Nothing OS black/white
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
          ),
        ),
        
        // Animated dot grid and effects
        if (widget.animate)
          AnimatedBuilder(
            animation: _sweepController,
            builder: (context, child) {
              return CustomPaint(
                painter: AmbientPainter(
                  dotSpacing: widget.dotSpacing,
                  dotOpacity: widget.dotOpacity,
                  scanlineOpacity: widget.scanlineOpacity,
                  vignetteOpacity: widget.vignetteOpacity,
                  sweepProgress: _sweepController.value,
                  isDark: isDark,
                ),
                size: Size.infinite,
              );
            },
          )
        else
          CustomPaint(
            painter: AmbientPainter(
              dotSpacing: widget.dotSpacing,
              dotOpacity: widget.dotOpacity,
              scanlineOpacity: widget.scanlineOpacity,
              vignetteOpacity: widget.vignetteOpacity,
              sweepProgress: 0.0,
              isDark: isDark,
            ),
            size: Size.infinite,
          ),
        
        // Child content
        widget.child,
      ],
    );
  }
}

class AmbientPainter extends CustomPainter {
  AmbientPainter({
    required this.dotSpacing,
    required this.dotOpacity,
    required this.scanlineOpacity,
    required this.vignetteOpacity,
    required this.sweepProgress,
    required this.isDark,
  });
  
  final double dotSpacing;
  final double dotOpacity;
  final double scanlineOpacity;
  final double vignetteOpacity;
  final double sweepProgress;
  final bool isDark;
  
  @override
  void paint(Canvas canvas, Size size) {
    _paintDotGrid(canvas, size);
    _paintScanlines(canvas, size);
    _paintVignette(canvas, size);
    _paintSweep(canvas, size);
  }
  
  void _paintDotGrid(Canvas canvas, Size size) {
    // Nothing OS precise dot matrix - smaller, more uniform spacing
    final dotColor = isDark ? Colors.white : Colors.black;
    final paint = Paint()
      ..color = dotColor.withOpacity(isDark ? 0.25 : 0.3) // Much more visible
      ..style = PaintingStyle.fill
      ..isAntiAlias = false; // Sharp, pixel-perfect dots
    
    // Nothing OS uses very precise 24px grid spacing (more visible)
    final gridSpacing = 24.0;
    final dotSize = 2.0; // More visible dots
    
    // Calculate grid offset to center the pattern
    final offsetX = (size.width % gridSpacing) / 2;
    final offsetY = (size.height % gridSpacing) / 2;
    
    // Draw perfect grid matrix
    for (double x = offsetX; x < size.width; x += gridSpacing) {
      for (double y = offsetY; y < size.height; y += gridSpacing) {
        // Draw as tiny squares for pixel-perfect precision
        canvas.drawRect(
          Rect.fromLTWH(x - dotSize/2, y - dotSize/2, dotSize, dotSize),
          paint,
        );
      }
    }
    
    // Add subtle secondary grid for depth (Nothing OS layering)
    final secondaryPaint = Paint()
      ..color = dotColor.withOpacity(isDark ? 0.03 : 0.05)
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;
    
    final secondarySpacing = gridSpacing * 2; // 32px secondary grid
    for (double x = offsetX; x < size.width; x += secondarySpacing) {
      for (double y = offsetY; y < size.height; y += secondarySpacing) {
        canvas.drawRect(
          Rect.fromLTWH(x - 0.5, y - 0.5, 1.0, 1.0),
          secondaryPaint,
        );
      }
    }
  }
  
  void _paintScanlines(Canvas canvas, Size size) {
    // Nothing OS uses very subtle scan lines, almost imperceptible
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withOpacity(isDark ? 0.02 : 0.03)
      ..strokeWidth = 0.3
      ..isAntiAlias = false; // Keep lines sharp
    
    // Wider spacing for more subtle effect
    for (double y = 0; y < size.height; y += 8) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }
  
  void _paintVignette(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.max(size.width, size.height) * 0.8;
    
    final gradient = RadialGradient(
      colors: [
        Colors.transparent,
        (isDark ? Colors.black : Colors.white).withOpacity(vignetteOpacity),
      ],
      stops: const [0.3, 1.0],
    );
    
    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius));
    
    canvas.drawRect(Offset.zero & size, paint);
  }
  
  void _paintSweep(Canvas canvas, Size size) {
    if (sweepProgress == 0.0) return;
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.max(size.width, size.height) * 1.5;
    final angle = sweepProgress * 2 * math.pi;
    
    // Subtle sweep effect
    final sweepGradient = RadialGradient(
      center: Alignment(
        math.cos(angle) * 0.3,
        math.sin(angle) * 0.3,
      ),
      colors: [
        (isDark ? Colors.white : Colors.black).withOpacity(0.02),
        Colors.transparent,
      ],
      stops: const [0.0, 0.8],
    );
    
    final paint = Paint()
      ..shader = sweepGradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..blendMode = BlendMode.overlay;
    
    canvas.drawCircle(center, radius, paint);
  }
  
  @override
  bool shouldRepaint(AmbientPainter oldDelegate) {
    return oldDelegate.sweepProgress != sweepProgress ||
           oldDelegate.isDark != isDark;
  }
}

/// Noise texture painter for micro-details
class NoisePainter extends CustomPainter {
  NoisePainter({
    required this.opacity,
    required this.seed,
    this.scale = 1.0,
  });
  
  final double opacity;
  final int seed;
  final double scale;
  
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(seed);
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..style = PaintingStyle.fill;
    
    final grainSize = 2.0 * scale;
    final density = 0.3;
    
    for (int i = 0; i < (size.width * size.height * density / (grainSize * grainSize)); i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      
      if (random.nextDouble() < 0.5) {
        canvas.drawRect(
          Rect.fromLTWH(x, y, grainSize, grainSize),
          paint,
        );
      }
    }
  }
  
  @override
  bool shouldRepaint(NoisePainter oldDelegate) {
    return oldDelegate.seed != seed || 
           oldDelegate.opacity != opacity ||
           oldDelegate.scale != scale;
  }
}