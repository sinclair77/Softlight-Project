import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:softlightstudio/ui/theme.dart';
import 'package:softlightstudio/editor/editor_state.dart';

/// 2D pad editor for intuitive color grading adjustments
class CurveEditor extends StatefulWidget {
  const CurveEditor({
    super.key,
    required this.editorState,
  });

  final EditorState editorState;

  @override
  State<CurveEditor> createState() => _CurveEditorState();
}

class _CurveEditorState extends State<CurveEditor> {
  String _selectedCurve = 'rgb'; // rgb, red, green, blue
  Offset _controlPosition = const Offset(0.5, 0.5); // Center position (0,0 to 1,1)
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _updateControlPositionFromParams(); // Initialize with current parameter values
  }

  void _resetControlPosition() {
    _controlPosition = const Offset(0.5, 0.5); // Reset to center
    _updateParameters();
  }

  void _updateParameters() {
    // Map X and Y position to parameter adjustments
    // X axis (left-right): Shadows to Highlights
    // Y axis (up-down): Lift to Gain
    
    final x = _controlPosition.dx; // 0 = left (shadows), 1 = right (highlights) 
    final y = 1.0 - _controlPosition.dy; // Invert Y so up = positive
    
    // Map to shadow/highlight range (-1 to +1)
    final shadowAdjust = (x - 0.5) * 2.0; // -1 to +1
    final highlightAdjust = (y - 0.5) * 2.0; // -1 to +1
    
    if (_selectedCurve == 'rgb') {
      widget.editorState.updateParam('curveShadows', shadowAdjust);
      widget.editorState.updateParam('curveHighlights', highlightAdjust);
    } else if (_selectedCurve == 'red') {
      widget.editorState.updateParam('redShadows', shadowAdjust);
      widget.editorState.updateParam('redHighlights', highlightAdjust);
    } else if (_selectedCurve == 'green') {
      widget.editorState.updateParam('greenShadows', shadowAdjust);
      widget.editorState.updateParam('greenHighlights', highlightAdjust);
    } else if (_selectedCurve == 'blue') {
      widget.editorState.updateParam('blueShadows', shadowAdjust);
      widget.editorState.updateParam('blueHighlights', highlightAdjust);
    }
    
    setState(() {});
  }

  Color _getCurveColor() {
    switch (_selectedCurve) {
      case 'red':
        return Colors.red.shade400;
      case 'green':
        return Colors.green.shade400;
      case 'blue':
        return Colors.blue.shade400;
      default:
        return SoftlightTheme.accentRed;
    }
  }

  double _getShadowValue() {
    switch (_selectedCurve) {
      case 'red':
        return widget.editorState.params.redShadows;
      case 'green':
        return widget.editorState.params.greenShadows;
      case 'blue':
        return widget.editorState.params.blueShadows;
      default:
        return widget.editorState.params.curveShadows;
    }
  }

  double _getHighlightValue() {
    switch (_selectedCurve) {
      case 'red':
        return widget.editorState.params.redHighlights;
      case 'green':
        return widget.editorState.params.greenHighlights;
      case 'blue':
        return widget.editorState.params.blueHighlights;
      default:
        return widget.editorState.params.curveHighlights;
    }
  }

  void _updateControlPositionFromParams() {
    final shadowValue = _getShadowValue();
    final highlightValue = _getHighlightValue();
    
    // Map parameter values back to control position
    final x = (shadowValue / 2.0) + 0.5; // Convert from -1/+1 to 0/1
    final y = 1.0 - ((highlightValue / 2.0) + 0.5); // Invert Y axis
    
    _controlPosition = Offset(x.clamp(0.0, 1.0), y.clamp(0.0, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 480, // Fixed height to prevent overflow
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: SoftlightTheme.gray700, width: 1),
      ),
      child: Column(
        children: [
          // Channel selector - improved spacing and button design
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: SoftlightTheme.gray700)),
            ),
            child: Row(
              children: [
                _buildChannelButton('RGB', 'rgb'),
                const SizedBox(width: 12),
                _buildChannelButton('R', 'red'),
                const SizedBox(width: 12),
                _buildChannelButton('G', 'green'),
                const SizedBox(width: 12),
                _buildChannelButton('B', 'blue'),
                const Spacer(),
                GestureDetector(
                  onTap: _resetControlPosition,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: SoftlightTheme.gray700),
                      color: Colors.black,
                    ),
                    child: const Text(
                      'RESET',
                      style: TextStyle(
                        fontFamily: 'Courier New',
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 2D Control Pad - improved padding for axis labels
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(40, 20, 20, 30), // More space for labels
              child: AspectRatio(
                aspectRatio: 1.0,
                child: GestureDetector(
                  onPanStart: (details) {
                    _isDragging = true;
                    _updateControlPosition(details.localPosition);
                  },
                  onPanUpdate: (details) {
                    if (_isDragging) {
                      _updateControlPosition(details.localPosition);
                    }
                  },
                  onPanEnd: (details) {
                    _isDragging = false;
                    HapticFeedback.lightImpact();
                  },
                  onTapUp: (details) {
                    _updateControlPosition(details.localPosition);
                    HapticFeedback.lightImpact();
                  },
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _Control2DPainter(
                      controlPosition: _controlPosition,
                      isDragging: _isDragging,
                      curveColor: _getCurveColor(),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Parameter display - improved spacing and readability
          Container(
            height: 80,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: SoftlightTheme.gray700)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'SHADOWS',
                        style: TextStyle(
                          fontFamily: 'Courier New',
                          fontSize: 11,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${(_getShadowValue() * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontFamily: 'Courier New',
                          fontSize: 16,
                          color: _getCurveColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: SoftlightTheme.gray700,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'HIGHLIGHTS',
                        style: TextStyle(
                          fontFamily: 'Courier New',
                          fontSize: 11,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${(_getHighlightValue() * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontFamily: 'Courier New',
                          fontSize: 16,
                          color: _getCurveColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelButton(String label, String channel) {
    final isSelected = _selectedCurve == channel;
    final color = channel == 'red' ? Colors.red.shade400 :
                  channel == 'green' ? Colors.green.shade400 :
                  channel == 'blue' ? Colors.blue.shade400 :
                  SoftlightTheme.accentRed;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCurve = channel;
          _updateControlPositionFromParams();
        });
        HapticFeedback.selectionClick();
      },
      child: Container(
        width: 38,
        height: 28,
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(25) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : SoftlightTheme.gray700,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Courier New',
              fontSize: 11,
              color: isSelected ? color : Colors.white70,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  void _updateControlPosition(Offset localPosition) {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    // Get the gesture detector's size
    final size = renderBox.size;
    
    // Account for new padding: left=40, top=20, right=20, bottom=30
    final actualWidth = size.width - 60; // 40 + 20
    final actualHeight = size.height - 50; // 20 + 30
    final actualSize = math.min(actualWidth, actualHeight);
    
    final offsetX = 40.0; // left padding
    final offsetY = 20.0; // top padding
    
    // Convert local position to normalized coordinates (0,0 to 1,1)
    final normalizedX = ((localPosition.dx - offsetX) / actualSize).clamp(0.0, 1.0);
    final normalizedY = ((localPosition.dy - offsetY) / actualSize).clamp(0.0, 1.0);
    
    _controlPosition = Offset(normalizedX, normalizedY);
    _updateParameters();
  }
}

/// Custom painter for 2D control pad with square area and draggable circle
class _Control2DPainter extends CustomPainter {
  const _Control2DPainter({
    required this.controlPosition,
    required this.isDragging,
    required this.curveColor,
  });

  final Offset controlPosition;
  final bool isDragging;
  final Color curveColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SoftlightTheme.gray700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final squareSize = math.min(size.width, size.height);
    final rect = Rect.fromLTWH(0, 0, squareSize, squareSize);

    // Draw main square border
    canvas.drawRect(rect, paint);

    // Draw grid lines
    paint.color = SoftlightTheme.gray700.withAlpha(60);
    for (int i = 1; i < 5; i++) {
      final pos = squareSize * (i / 5);
      // Vertical lines
      canvas.drawLine(Offset(pos, 0), Offset(pos, squareSize), paint);
      // Horizontal lines
      canvas.drawLine(Offset(0, pos), Offset(squareSize, pos), paint);
    }

    // Draw center cross
    paint.color = SoftlightTheme.gray700.withAlpha(80);
    paint.strokeWidth = 0.5;
    final center = squareSize * 0.5;
    canvas.drawLine(Offset(center, 0), Offset(center, squareSize), paint);
    canvas.drawLine(Offset(0, center), Offset(squareSize, center), paint);

    // Draw axis labels
    final textPaint = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    // X-axis labels (Shadows/Highlights) - better positioning
    textPaint.text = const TextSpan(
      text: 'SHADOWS',
      style: TextStyle(
        fontFamily: 'Courier New',
        fontSize: 9,
        color: Colors.grey,
        fontWeight: FontWeight.bold,
      ),
    );
    textPaint.layout();
    textPaint.paint(canvas, Offset(20, squareSize + 8));

    textPaint.text = const TextSpan(
      text: 'HIGHLIGHTS',
      style: TextStyle(
        fontFamily: 'Courier New',
        fontSize: 9,
        color: Colors.grey,
        fontWeight: FontWeight.bold,
      ),
    );
    textPaint.layout();
    textPaint.paint(canvas, Offset(squareSize - textPaint.width - 20, squareSize + 8));

    // Y-axis labels (rotated) - positioned better to avoid overlap
    canvas.save();
    canvas.translate(-25, squareSize / 2);
    canvas.rotate(-math.pi / 2);
    textPaint.text = const TextSpan(
      text: 'LIFT',
      style: TextStyle(
        fontFamily: 'Courier New',
        fontSize: 9,
        color: Colors.grey,
        fontWeight: FontWeight.bold,
      ),
    );
    textPaint.layout();
    textPaint.paint(canvas, Offset(-textPaint.width / 2, -8));
    canvas.restore();

    canvas.save();
    canvas.translate(-25, squareSize / 2);
    canvas.rotate(-math.pi / 2);
    textPaint.text = const TextSpan(
      text: 'GAIN',
      style: TextStyle(
        fontFamily: 'Courier New',
        fontSize: 9,
        color: Colors.grey,
        fontWeight: FontWeight.bold,
      ),
    );
    textPaint.layout();
    textPaint.paint(canvas, Offset(textPaint.width / 2, -8));
    canvas.restore();

    // Calculate circle position
    final circleX = controlPosition.dx * squareSize;
    final circleY = controlPosition.dy * squareSize;
    final circleCenter = Offset(circleX, circleY);

    // Draw connection lines to edges (showing current values)
    paint.color = curveColor.withAlpha(100);
    paint.strokeWidth = 1;
    canvas.drawLine(Offset(circleX, 0), Offset(circleX, squareSize), paint);
    canvas.drawLine(Offset(0, circleY), Offset(squareSize, circleY), paint);

    // Draw control circle
    final circlePaint = Paint()
      ..color = curveColor.withAlpha(isDragging ? 200 : 150)
      ..style = PaintingStyle.fill;

    final circleStroke = Paint()
      ..color = curveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = isDragging ? 3 : 2;

    final circleRadius = isDragging ? 12.0 : 10.0;

    // Outer glow when dragging
    if (isDragging) {
      final glowPaint = Paint()
        ..color = curveColor.withAlpha(50)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(circleCenter, circleRadius + 8, glowPaint);
    }

    canvas.drawCircle(circleCenter, circleRadius, circlePaint);
    canvas.drawCircle(circleCenter, circleRadius, circleStroke);

    // Draw inner dot
    final innerDot = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(circleCenter, 2, innerDot);
  }

  @override
  bool shouldRepaint(covariant _Control2DPainter oldDelegate) {
    return oldDelegate.controlPosition != controlPosition ||
           oldDelegate.isDragging != isDragging ||
           oldDelegate.curveColor != curveColor;
  }
}