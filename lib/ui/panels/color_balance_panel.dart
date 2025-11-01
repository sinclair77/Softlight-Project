import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:softlightstudio/ui/theme.dart';
import 'package:softlightstudio/editor/editor_state.dart';

/// Color Balance panel with DaVinci Resolve-style color wheels
class ColorBalancePanel extends StatefulWidget {
  const ColorBalancePanel({
    super.key,
    required this.editorState,
  });

  final EditorState editorState;

  @override
  State<ColorBalancePanel> createState() => _ColorBalancePanelState();
}

class _ColorBalancePanelState extends State<ColorBalancePanel> {
  String _selectedTone = 'shadows';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SoftlightTheme.gray900.withAlpha(240),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SoftlightTheme.gray700,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Text(
                'COLOR BALANCE',
                style: TextStyle(
                  fontFamily: 'CourierNew',
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _resetToDefaults,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: SoftlightTheme.gray800,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: SoftlightTheme.gray600),
                  ),
                  child: Text(
                    'RESET',
                    style: TextStyle(
                      fontFamily: 'CourierNew',
                      fontSize: 10,
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // DaVinci Resolve-style color wheels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildColorWheel('SHADOWS', 'shadows', Colors.blue),
              _buildColorWheel('MIDTONES', 'midtones', Colors.green),
              _buildColorWheel('HIGHLIGHTS', 'highlights', Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  void _resetToDefaults() {
    // Reset all color grading parameters
    widget.editorState.updateParam('shadowsHue', 0.0);
    widget.editorState.updateParam('shadowsSaturation', 0.0);
    widget.editorState.updateParam('shadowsLuminance', 0.0);
    
    widget.editorState.updateParam('midtonesHue', 0.0);
    widget.editorState.updateParam('midtonesSaturation', 0.0);
    widget.editorState.updateParam('midtonesLuminance', 0.0);
    
    widget.editorState.updateParam('highlightsHue', 0.0);
    widget.editorState.updateParam('highlightsSaturation', 0.0);
    widget.editorState.updateParam('highlightsLuminance', 0.0);
    
    HapticFeedback.mediumImpact();
    setState(() {});
  }

  Widget _buildColorWheel(String label, String tone, Color toneColor) {
    final isSelected = _selectedTone == tone;
    
    // Get HSL values for this tonal range
    final hue = tone == 'shadows' ? widget.editorState.params.shadowsHue :
               tone == 'midtones' ? widget.editorState.params.midtonesHue :
               widget.editorState.params.highlightsHue;
    final saturation = tone == 'shadows' ? widget.editorState.params.shadowsSaturation :
                      tone == 'midtones' ? widget.editorState.params.midtonesSaturation :
                      widget.editorState.params.highlightsSaturation;
    
    // Convert HSL to position on color wheel (160x160 wheel)
    final wheelRadius = 80.0; // Half of 160px wheel (center point)
    final maxRadius = 70.0; // Max distance from center (updated to match interaction)
    
    // FORCE dots to center when no adjustment is made
    double dotX, dotY;
    if (saturation < 0.01 && hue.abs() < 1.0) {
      // Perfect center when no color grading applied
      dotX = wheelRadius;
      dotY = wheelRadius;
    } else {
      // Calculate position based on HSL values
      // Account for the dead zone in saturation calculation
      final effectiveSaturation = saturation * 0.857; // (maxRadius - 10) / maxRadius
      final distance = effectiveSaturation * maxRadius + (saturation > 0 ? 10.0 : 0);
      final hueRad = hue * math.pi / 180.0; // Convert degrees to radians
      
      // Calculate actual pixel position from center of wheel
      dotX = wheelRadius + (distance * math.cos(hueRad));
      dotY = wheelRadius + (distance * math.sin(hueRad));
    }
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTone = tone;
        });
        HapticFeedback.selectionClick();
      },
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'CourierNew',
              fontSize: 10,
              color: isSelected ? toneColor : Colors.white60,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          
          // DaVinci Resolve-style color wheel
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? toneColor : SoftlightTheme.gray600,
                width: isSelected ? 3 : 2,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: toneColor.withAlpha(100),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ] : [
                BoxShadow(
                  color: Colors.black.withAlpha(100),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(80),
              child: Stack(
                children: [
                  // Color wheel gradient background
                  CustomPaint(
                    size: const Size(160, 160),
                    painter: _ColorWheelPainter(
                      isSelected: isSelected,
                      toneColor: toneColor,
                    ),
                  ),
                  
                  // Full-wheel gesture detector
                  Positioned.fill(
                    child: GestureDetector(
                      onTapDown: (details) {
                        setState(() {
                          _selectedTone = tone;
                        });
                        _updateColorWheelValue(details.localPosition, tone);
                        HapticFeedback.selectionClick();
                      },
                      onPanStart: (details) {
                        setState(() {
                          _selectedTone = tone;
                        });
                        _updateColorWheelValue(details.localPosition, tone);
                        HapticFeedback.selectionClick();
                      },
                      onPanUpdate: (details) {
                        _updateColorWheelValue(details.localPosition, tone);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                  
                  // Accurate draggable control point
                  Positioned(
                    left: dotX - 10, // Center the 20px dot
                    top: dotY - 10,  // Center the 20px dot
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: isSelected ? toneColor : Colors.grey,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(200),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                          if (isSelected)
                            BoxShadow(
                              color: toneColor.withAlpha(150),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Value display
          const SizedBox(height: 6),
          Text(
            'H:${hue.toStringAsFixed(0)}° S:${(saturation * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              fontFamily: 'CourierNew',
              fontSize: 9,
              color: isSelected ? toneColor : Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _updateColorWheelValue(Offset localPosition, String tone) {
    // Accurate color wheel interaction (160x160 wheel)
    final wheelRadius = 80.0; // Wheel center point (160/2)
    final maxRadius = 70.0; // Max distance for interaction (slightly increased)
    
    // Calculate offset from center of wheel
    final deltaX = localPosition.dx - wheelRadius;
    final deltaY = localPosition.dy - wheelRadius;
    
    // Calculate distance from center
    final rawDistance = math.sqrt(deltaX * deltaX + deltaY * deltaY);
    
    // Clamp distance to max radius for better edge handling
    final clampedDistance = rawDistance.clamp(0.0, maxRadius);
    
    // Calculate angle (hue) in degrees (-180 to 180)
    final angle = math.atan2(deltaY, deltaX) * 180.0 / math.pi;
    final hue = angle.clamp(-180.0, 180.0);
    
    // Calculate saturation (0 at center, 1 at max radius)
    // Add dead zone at center for easier reset to neutral
    final saturation = clampedDistance < 10.0 
        ? 0.0 
        : ((clampedDistance - 10.0) / (maxRadius - 10.0)).clamp(0.0, 1.0);
    
    // Update HSL parameters for the selected tonal range
    switch (tone) {
      case 'shadows':
        widget.editorState.updateParam('shadowsHue', hue);
        widget.editorState.updateParam('shadowsSaturation', saturation);
        break;
      case 'midtones':
        widget.editorState.updateParam('midtonesHue', hue);
        widget.editorState.updateParam('midtonesSaturation', saturation);
        break;
      case 'highlights':
        widget.editorState.updateParam('highlightsHue', hue);
        widget.editorState.updateParam('highlightsSaturation', saturation);
        break;
    }
    
    setState(() {});
    HapticFeedback.lightImpact();
  }
}

class _ColorWheelPainter extends CustomPainter {
  final bool isSelected;
  final Color toneColor;
  
  _ColorWheelPainter({
    required this.isSelected,
    required this.toneColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Draw the color wheel background with DaVinci-style color zones
    final wheelPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          const Color(0xFFFF0000), // Red
          const Color(0xFFFF7F00), // Orange
          const Color(0xFFFFFF00), // Yellow
          const Color(0xFF7FFF00), // Yellow-Green
          const Color(0xFF00FF00), // Green
          const Color(0xFF00FF7F), // Green-Cyan
          const Color(0xFF00FFFF), // Cyan
          const Color(0xFF007FFF), // Cyan-Blue
          const Color(0xFF0000FF), // Blue
          const Color(0xFF7F00FF), // Blue-Magenta
          const Color(0xFFFF00FF), // Magenta
          const Color(0xFFFF007F), // Magenta-Red
          const Color(0xFFFF0000), // Red (complete circle)
        ],
        stops: const [
          0.0, 0.083, 0.167, 0.25, 0.333, 0.417, 
          0.5, 0.583, 0.667, 0.75, 0.833, 0.917, 1.0
        ],
        center: Alignment.center,
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    
    canvas.drawCircle(center, radius - 2, wheelPaint);
    
    // Draw saturation gradient (from center to edge)
    final saturationPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withAlpha(200),
          Colors.transparent,
        ],
        stops: const [0.0, 0.7],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    
    canvas.drawCircle(center, radius - 2, saturationPaint);
    
    // Draw center neutral zone
    final centerPaint = Paint()
      ..color = Colors.grey.withAlpha(120);
    canvas.drawCircle(center, 16, centerPaint);
    
    // Draw inner neutral ring
    final neutralRingPaint = Paint()
      ..color = Colors.white.withAlpha(40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, 16, neutralRingPaint);
    
    // Draw selection highlight if active
    if (isSelected) {
      // Outer glow effect
      final glowPaint = Paint()
        ..color = toneColor.withAlpha(60)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(center, radius - 4, glowPaint);
      
      // Selection border
      final borderPaint = Paint()
        ..color = toneColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(center, radius - 2, borderPaint);
    }
    
    // Draw grid lines like DaVinci
    final gridPaint = Paint()
      ..color = Colors.white.withAlpha(30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    
    // Draw cross lines
    canvas.drawLine(
      Offset(center.dx - radius + 8, center.dy),
      Offset(center.dx + radius - 8, center.dy),
      gridPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius + 8),
      Offset(center.dx, center.dy + radius - 8),
      gridPaint,
    );
    
    // Draw concentric circles for saturation reference
    for (double r = radius * 0.3; r < radius; r += radius * 0.25) {
      canvas.drawCircle(center, r, gridPaint);
    }
    
    // Draw hue tick marks around the edge
    final tickPaint = Paint()
      ..color = Colors.white.withAlpha(80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    // Major tick marks every 30 degrees (12 total)
    for (int i = 0; i < 12; i++) {
      final angle = i * 30.0 * math.pi / 180.0;
      final startX = center.dx + (radius - 10) * math.cos(angle);
      final startY = center.dy + (radius - 10) * math.sin(angle);
      final endX = center.dx + (radius - 4) * math.cos(angle);
      final endY = center.dy + (radius - 4) * math.sin(angle);
      
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), tickPaint);
    }
    
    // Minor tick marks every 15 degrees (additional 12)
    final minorTickPaint = Paint()
      ..color = Colors.white.withAlpha(50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    for (int i = 0; i < 24; i++) {
      if (i % 2 == 1) { // Only odd numbers (between major ticks)
        final angle = i * 15.0 * math.pi / 180.0;
        final startX = center.dx + (radius - 7) * math.cos(angle);
        final startY = center.dy + (radius - 7) * math.sin(angle);
        final endX = center.dx + (radius - 4) * math.cos(angle);
        final endY = center.dy + (radius - 4) * math.sin(angle);
        
        canvas.drawLine(Offset(startX, startY), Offset(endX, endY), minorTickPaint);
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}