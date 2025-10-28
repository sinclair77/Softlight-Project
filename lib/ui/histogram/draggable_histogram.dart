import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:softlightstudio/ui/theme.dart';

/// Draggable histogram overlay that can be moved around the screen
class DraggableHistogram extends StatefulWidget {
  final ui.Image? image;
  final VoidCallback? onClose;
  final bool isVisible;

  const DraggableHistogram({
    super.key,
    this.image,
    this.onClose,
    this.isVisible = false,
  });

  @override
  State<DraggableHistogram> createState() => _DraggableHistogramState();
}

class _DraggableHistogramState extends State<DraggableHistogram>
    with SingleTickerProviderStateMixin {
  Offset _position = const Offset(20, 20);
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  List<int> _redHistogram = [];
  List<int> _greenHistogram = [];
  List<int> _blueHistogram = [];
  List<int> _luminanceHistogram = [];
  bool _isComputing = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));

    if (widget.isVisible) {
      _fadeController.forward();
    }
  }

  @override
  void didUpdateWidget(DraggableHistogram oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _fadeController.forward();
        if (widget.image != null) {
          _computeHistogram();
        }
      } else {
        _fadeController.reverse();
      }
    }
    
    if (widget.image != oldWidget.image && widget.image != null) {
      _computeHistogram();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _computeHistogram() async {
    if (_isComputing || widget.image == null) return;
    
    setState(() {
      _isComputing = true;
    });

    try {
      // Get image data
      final byteData = await widget.image!.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (byteData == null) return;
      
      final pixels = byteData.buffer.asUint8List();
      
      // Initialize histogram arrays
      final red = List.filled(256, 0);
      final green = List.filled(256, 0);
      final blue = List.filled(256, 0);
      final luminance = List.filled(256, 0);
      
      // Process pixels (RGBA format)
      for (int i = 0; i < pixels.length; i += 4) {
        final r = pixels[i];
        final g = pixels[i + 1];
        final b = pixels[i + 2];
        
        red[r]++;
        green[g]++;
        blue[b]++;
        
        // Calculate luminance (standard formula)
        final lum = ((0.299 * r + 0.587 * g + 0.114 * b).round()).clamp(0, 255);
        luminance[lum]++;
      }
      
      if (mounted) {
        setState(() {
          _redHistogram = red;
          _greenHistogram = green;
          _blueHistogram = blue;
          _luminanceHistogram = luminance;
          _isComputing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isComputing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();
    
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          );
        },
        child: _buildHistogramContainer(context),
      ),
    );
  }

  Widget _buildHistogramContainer(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _position += details.delta;
          final screenSize = MediaQuery.of(context).size;
          _position = Offset(
            _position.dx.clamp(0, math.max(0.0, screenSize.width - 280)),
            _position.dy.clamp(0, math.max(0.0, screenSize.height - 200)),
          );
        });
      },
      child: Container(
        width: 280,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(220),
          border: Border.all(color: SoftlightTheme.gray700),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(100),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: SoftlightTheme.gray700),
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(7),
                  topRight: Radius.circular(7),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.drag_handle,
                    color: SoftlightTheme.gray400,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'HISTOGRAM',
                    style: TextStyle(
                      fontFamily: 'Courier New',
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Spacer(),
                  if (widget.onClose != null)
                    GestureDetector(
                      onTap: widget.onClose,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.close,
                          color: SoftlightTheme.gray400,
                          size: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: _isComputing
                  ? const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: SoftlightTheme.accentRed,
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(12),
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: _HistogramPainter(
                          redHistogram: _redHistogram,
                          greenHistogram: _greenHistogram,
                          blueHistogram: _blueHistogram,
                          luminanceHistogram: _luminanceHistogram,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for drawing the histogram
class _HistogramPainter extends CustomPainter {
  final List<int> redHistogram;
  final List<int> greenHistogram;
  final List<int> blueHistogram;
  final List<int> luminanceHistogram;

  _HistogramPainter({
    required this.redHistogram,
    required this.greenHistogram,
    required this.blueHistogram,
    required this.luminanceHistogram,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (redHistogram.isEmpty) return;

    final width = size.width;
    final height = size.height;
    
    // Find max values for normalization
    final maxRed = redHistogram.reduce(math.max);
    final maxGreen = greenHistogram.reduce(math.max);
    final maxBlue = blueHistogram.reduce(math.max);
    final maxLum = luminanceHistogram.reduce(math.max);
    final globalMax = math.max(math.max(maxRed, maxGreen), math.max(maxBlue, maxLum));
    
    if (globalMax == 0) return;

    // Draw background grid
    final gridPaint = Paint()
      ..color = SoftlightTheme.gray700.withAlpha(60)
      ..strokeWidth = 0.5;

    for (int i = 1; i < 4; i++) {
      final y = height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }

    for (int i = 1; i < 4; i++) {
      final x = width * i / 4;
      canvas.drawLine(Offset(x, 0), Offset(x, height), gridPaint);
    }

    // Draw histograms
    _drawHistogram(canvas, size, luminanceHistogram, Colors.white.withAlpha(100), globalMax);
    _drawHistogram(canvas, size, redHistogram, Colors.red.withAlpha(150), globalMax);
    _drawHistogram(canvas, size, greenHistogram, Colors.green.withAlpha(150), globalMax);
    _drawHistogram(canvas, size, blueHistogram, Colors.blue.withAlpha(150), globalMax);
  }

  void _drawHistogram(Canvas canvas, Size size, List<int> histogram, Color color, int maxValue) {
    if (histogram.isEmpty || maxValue == 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    final path = Path();
    final barWidth = size.width / 256;

    for (int i = 0; i < histogram.length; i++) {
      final normalizedHeight = (histogram[i] / maxValue) * size.height;
      final x = i * barWidth;
      final y = size.height - normalizedHeight;
      
      if (i == 0) {
        path.moveTo(x, size.height);
        path.lineTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    path.lineTo(size.width, size.height);
    path.close();

    // Fill the histogram
    paint.style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
    
    // Draw the outline
    paint.style = PaintingStyle.stroke;
    paint.color = color.withAlpha(255);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_HistogramPainter oldDelegate) {
    return redHistogram != oldDelegate.redHistogram ||
           greenHistogram != oldDelegate.greenHistogram ||
           blueHistogram != oldDelegate.blueHistogram ||
           luminanceHistogram != oldDelegate.luminanceHistogram;
  }
}