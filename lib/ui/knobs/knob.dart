import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:softlightstudio/ui/theme.dart';
import 'package:softlightstudio/editor/editor_state.dart';

/// Circular knob control for parameter adjustment
class ParameterKnob extends StatefulWidget {
  const ParameterKnob({
    super.key,
    required this.paramDef,
    required this.value,
    required this.onChanged,
    required this.onReset,
    required this.editorState,
    this.size = 64.0, // Smaller size to prevent overflow
  });
  
  final ParamDef paramDef;
  final double value;
  final ValueChanged<double> onChanged;
  final VoidCallback onReset;
  final EditorState editorState;
  final double size;
  
  @override
  State<ParameterKnob> createState() => _ParameterKnobState();
}

class _ParameterKnobState extends State<ParameterKnob>
    with TickerProviderStateMixin {
  bool _isDragging = false;
  bool _isFineMode = false;
  late AnimationController _breathingController;
  late AnimationController _rippleController;
  late AnimationController _glowController;
  final _valueController = TextEditingController();
  final _focusNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      duration: SoftlightTheme.breathingAnimation,
      vsync: this,
    );
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _breathingController.repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _breathingController.dispose();
    _rippleController.dispose();
    _glowController.dispose();
    _valueController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // TAPPABLE value display for direct input
        GestureDetector(
          onTap: _showValueEditor,
          child: AnimatedContainer(
            duration: SoftlightTheme.fastAnimation,
            height: 14, // Slightly taller for better tap target
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: _isDragging
                  ? widget.editorState.highlightColor.withOpacity(isDark ? 0.45 : 0.35)
                  : (isDark ? SoftlightTheme.gray800 : SoftlightTheme.gray200),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _isDragging
                    ? widget.editorState.highlightColor.withOpacity(0.7)
                    : (isDark ? SoftlightTheme.gray600 : SoftlightTheme.gray400),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _formatValue(widget.value),
                style: TextStyle(
                  fontSize: 9, // Slightly larger for better readability
                  fontFamily: 'Menlo',
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: _isDragging
                      ? SoftlightTheme.gray50.withOpacity(0.9)
                      : (isDark ? SoftlightTheme.gray100 : SoftlightTheme.gray900),
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 2),
        
        // Enhanced Nothing Clock-style Knob with premium interactions
        MouseRegion(
          onEnter: (_) => setState(() {
            _glowController.forward();
          }),
          onExit: (_) => setState(() {
            _glowController.reverse();
          }),
          child: GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            onTap: _onTap,
            onLongPress: _onLongPress,
            child: AnimatedBuilder(
            animation: _breathingController,
            builder: (context, child) {
              // Subtle breathing when not active, like Nothing UI
              final breathingScale = _isDragging ? 1.0 : 1.0 + (_breathingController.value * 0.01);
              return Transform.scale(
                scale: breathingScale,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: _isDragging
                        ? [
                            BoxShadow(
                              color: widget.editorState.highlightColor.withOpacity(0.35),
                              blurRadius: 18,
                              spreadRadius: 3,
                            ),
                            BoxShadow(
                              color: widget.editorState.highlightColor.withOpacity(0.25),
                              blurRadius: 8,
                              spreadRadius: 0,
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.18 : 0.06),
                              blurRadius: 3,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: CustomPaint(
                    painter: KnobPainter(
                      value: widget.value,
                      min: widget.paramDef.min,
                      max: widget.paramDef.max,
                      defaultValue: widget.paramDef.defaultValue,
                      isDark: isDark,
                      isDragging: _isDragging,
                      isFineMode: _isFineMode,
                      highlightColor: widget.editorState.highlightColor,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        ),
        
        const SizedBox(height: 2),
        
        // Nothing-style label - mobile optimized with full names
        SizedBox(
          width: widget.size * 1.4, // Wider to accommodate longer names
          child: Text(
            widget.paramDef.label.toUpperCase(),
            style: TextStyle(
              fontSize: 6, // Slightly smaller for longer names
              fontFamily: 'Courier New', // Typewriter for labels
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8, // Slightly tighter for readability
              color: isDark ? SoftlightTheme.gray500 : SoftlightTheme.gray600,
              height: 1.1, // Tighter line height
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.visible, // Allow text to show fully
            maxLines: 2, // Allow wrapping to 2 lines for longer names
          ),
        ),
      ],
    );
  }
  
  String _formatValue(double value) {
    if (widget.paramDef.unit == 'K') {
      return '${value.toInt()}${widget.paramDef.unit}';
    }
    return value.toStringAsFixed(widget.paramDef.precision) + widget.paramDef.unit;
  }
  
  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
    _rippleController.forward();
    HapticFeedback.lightImpact();
  }
  
  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    
    final delta = details.delta;
    final sensitivity = _isFineMode ? 0.1 : 0.5; // Much smoother base sensitivity
    
    // Smoother vertical drag with better precision
    double change = 0;
    
    // Primary: Vertical drag (more precise)
    if (delta.dy.abs() > 0.1) {
      change = -delta.dy * sensitivity * 0.003; // Much finer control
    }
    
    // Secondary: Horizontal drag for fine adjustments
    if (delta.dx.abs() > delta.dy.abs() && delta.dx.abs() > 0.1) {
      change = delta.dx * sensitivity * 0.002; // Even finer horizontal
    }
    
    if (change.abs() > 0.00001) { // Only update if meaningful change
      final range = widget.paramDef.max - widget.paramDef.min;
      final increment = change * range;
      final newValue = (widget.value + increment).clamp(
        widget.paramDef.min,
        widget.paramDef.max,
      );
      
      // Smooth interpolation for better feel
      if ((newValue - widget.value).abs() > 0.001) {
        widget.onChanged(newValue);
      }
    }
  }
  
  void _onPanEnd(DragEndDetails details) {
    _rippleController.reverse();
    setState(() {
      _isDragging = false;
    });
  }
  
  void _onTap() {
    HapticFeedback.lightImpact();
  }
  
  void _onLongPress() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isFineMode = !_isFineMode;
    });
  }
  
  void _showValueEditor() {
    // Set current value without units for editing
    final currentValue = widget.value;
    if (widget.paramDef.unit == 'K') {
      _valueController.text = currentValue.toInt().toString();
    } else {
      _valueController.text = currentValue.toStringAsFixed(widget.paramDef.precision);
    }
    
    HapticFeedback.lightImpact();
    
    showDialog<double>(
      context: context,
      barrierDismissible: true,
      builder: (context) => _ValueInputDialog(
        paramDef: widget.paramDef,
        controller: _valueController,
        focusNode: _focusNode,
        editorState: widget.editorState,
      ),
    ).then((value) {
      if (value != null) {
        widget.onChanged(value);
        HapticFeedback.lightImpact();
      }
    });
  }
}

/// Nothing OS Clock-style knob painter
class KnobPainter extends CustomPainter {
  KnobPainter({
    required this.value,
    required this.min,
    required this.max,
    required this.defaultValue,
    required this.isDark,
    required this.isDragging,
    required this.isFineMode,
    required this.highlightColor,
  });
  
  final double value;
  final double min;
  final double max;
  final double defaultValue;
  final bool isDark;
  final bool isDragging;
  final bool isFineMode;
  final Color highlightColor;
  
  // Check if knob is adjusted from default
  bool get isAdjusted => (value - defaultValue).abs() > 0.001;
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Normalize value (0.0 to 1.0)
    final normalizedValue = (value - min) / (max - min);
    
    // Calculate angle (12 o'clock to full circle, like Nothing clock)
    final currentAngle = -math.pi / 2 + (normalizedValue * 2 * math.pi);
    
    _drawClockFace(canvas, center, radius);
    _drawReferenceTick(canvas, center, radius, currentAngle); // Big prominent tick at value position
    _drawCenterDot(canvas, center);
    
    if (isFineMode) {
      _drawFineModeRing(canvas, center, radius);
    }
  }
  
  void _drawClockFace(Canvas canvas, Offset center, double radius) {
    // Nothing OS style: Perfect circle with subtle border
    // Main face - light up when adjusted from default
    Color faceColor;
    
    if (isDragging) {
      faceColor = highlightColor.withOpacity(isDark ? 0.35 : 0.3);
    } else if (isAdjusted) {
      // Subtle glow when adjusted from default
      faceColor = isDark 
          ? highlightColor.withOpacity(0.15) // Subtle glow in dark mode
          : highlightColor.withOpacity(0.08); // Subtle glow in light mode
    } else {
      // Default neutral color
      faceColor = isDark ? SoftlightTheme.gray900 : SoftlightTheme.gray50;
    }
    
    final facePaint = Paint()
      ..color = faceColor
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius * 0.9, facePaint);
    
    // Enhanced border for adjusted knobs
    Color borderColor;
    double borderWidth = 0.5;
    
    if (isDragging) {
      borderColor = highlightColor.withOpacity(0.9);
      borderWidth = 1.0;
    } else if (isAdjusted) {
      // Subtle highlight border when adjusted
      borderColor = highlightColor.withOpacity(0.4);
      borderWidth = 1.0;
    } else {
      borderColor = isDark ? SoftlightTheme.gray700 : SoftlightTheme.gray300;
    }
    
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    
    canvas.drawCircle(center, radius * 0.9, borderPaint);
  }
  
  void _drawReferenceTick(Canvas canvas, Offset center, double radius, double angle) {
    // BIG prominent tick mark at the current value position
    final outerRadius = radius * 0.85; // Start from outer edge
    final innerRadius = radius * 0.6; // Go deeper into circle
    
    // Calculate tick position at current angle
    final tickStart = Offset(
      center.dx + math.cos(angle) * outerRadius,
      center.dy + math.sin(angle) * outerRadius,
    );
    final tickEnd = Offset(
      center.dx + math.cos(angle) * innerRadius,
      center.dy + math.sin(angle) * innerRadius,
    );
    
    Color tickColor;
    double tickWidth = 4.0;
    
    if (isDragging) {
      tickColor = highlightColor.withOpacity(0.85);
      tickWidth = 4.5;
    } else if (isAdjusted) {
      // Highlight color when adjusted from default
      tickColor = highlightColor.withOpacity(0.8);
      tickWidth = 4.2;
    } else {
      // Subtle when at default
      tickColor = isDark ? SoftlightTheme.gray600 : SoftlightTheme.gray400;
      tickWidth = 3.0;
    }
    
    final tickPaint = Paint()
      ..color = tickColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = tickWidth
      ..strokeCap = StrokeCap.round;
    
    canvas.drawLine(tickStart, tickEnd, tickPaint);
    
    // Add a circle at the outer end for extra prominence
    final dotPaint = Paint()
      ..color = tickColor
      ..style = PaintingStyle.fill;
    
    final dotSize = isAdjusted ? 3.5 : 2.8; // Softer prominence
    canvas.drawCircle(tickStart, dotSize, dotPaint);
  }

  void _drawCenterDot(Canvas canvas, Offset center) {
    // Nothing clock style: Minimal center dot
    final centerPaint = Paint()
      ..color = isDragging
          ? highlightColor.withOpacity(0.9)
          : (isDark ? SoftlightTheme.gray500 : SoftlightTheme.gray600)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, 1.0, centerPaint);
  }
  
  void _drawFineModeRing(Canvas canvas, Offset center, double radius) {
    // Fine mode: Outer ring like Nothing's selection states
    final ringPaint = Paint()
      ..color = highlightColor.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    canvas.drawCircle(center, radius * 0.95, ringPaint);
  }
  
  @override
  bool shouldRepaint(KnobPainter oldDelegate) {
    return oldDelegate.value != value ||
           oldDelegate.defaultValue != defaultValue ||
           oldDelegate.isDragging != isDragging ||
           oldDelegate.isFineMode != isFineMode ||
           oldDelegate.isDark != isDark;
  }
}

/// Value input dialog
class _ValueInputDialog extends StatefulWidget {
  const _ValueInputDialog({
    required this.paramDef,
    required this.controller,
    required this.focusNode,
    required this.editorState,
  });
  
  final ParamDef paramDef;
  final TextEditingController controller;
  final FocusNode focusNode;
  final EditorState editorState;
  
  @override
  State<_ValueInputDialog> createState() => _ValueInputDialogState();
}

class _ValueInputDialogState extends State<_ValueInputDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.focusNode.requestFocus();
      widget.controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: widget.controller.text.length,
      );
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AlertDialog(
      backgroundColor: isDark ? SoftlightTheme.gray900 : SoftlightTheme.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isDark ? SoftlightTheme.gray700 : SoftlightTheme.gray300,
          width: 0.5,
        ),
      ),
      title: Text(
        widget.paramDef.label,
        style: TextStyle(
          fontFamily: 'Courier New',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: isDark ? SoftlightTheme.white : SoftlightTheme.gray900,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            style: TextStyle(
              fontFamily: 'Menlo',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: isDark ? SoftlightTheme.white : SoftlightTheme.gray900,
            ),
            decoration: InputDecoration(
              labelText: 'Enter Value',
              labelStyle: TextStyle(
                fontFamily: 'Courier New',
                fontSize: 12,
                letterSpacing: 0.8,
                color: isDark ? SoftlightTheme.gray400 : SoftlightTheme.gray600,
              ),
              suffixText: widget.paramDef.unit.isNotEmpty ? widget.paramDef.unit : null,
              suffixStyle: TextStyle(
                fontFamily: 'Menlo',
                fontSize: 12,
                color: isDark ? SoftlightTheme.gray500 : SoftlightTheme.gray500,
              ),
              hintText: '${widget.paramDef.min} to ${widget.paramDef.max}',
              hintStyle: TextStyle(
                fontFamily: 'Menlo',
                fontSize: 14,
                color: isDark ? SoftlightTheme.gray600 : SoftlightTheme.gray400,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  color: isDark ? SoftlightTheme.gray700 : SoftlightTheme.gray300,
                  width: 0.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  color: widget.editorState.highlightColor,
                  width: 1.0,
                ),
              ),
            ),
            onSubmitted: (value) => _submitValue(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: isDark ? SoftlightTheme.gray400 : SoftlightTheme.gray600,
          ),
          child: Text(
            'CANCEL',
            style: TextStyle(
              fontFamily: 'Courier New',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ),
        TextButton(
          onPressed: _submitValue,
          style: TextButton.styleFrom(
            foregroundColor: widget.editorState.highlightColor,
          ),
          child: Text(
            'SET',
            style: TextStyle(
              fontFamily: 'Courier New',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ],
    );
  }
  
  void _submitValue() {
    final text = widget.controller.text.trim();
    final value = double.tryParse(text);
    
    if (value != null) {
      final clampedValue = value.clamp(widget.paramDef.min, widget.paramDef.max);
      Navigator.pop(context, clampedValue);
    } else {
      Navigator.pop(context);
    }
  }
}
