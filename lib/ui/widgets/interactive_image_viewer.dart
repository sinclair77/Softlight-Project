import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

/// Professional gesture-controlled image viewer for mobile photo editing
class InteractiveImageViewer extends StatefulWidget {
  const InteractiveImageViewer({
    super.key,
    required this.image,
    this.onDoubleTap,
    this.onLongPress,
    this.onGesture,
    this.minScale = 0.5,
    this.maxScale = 5.0,
  });

  final ui.Image image;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final Function(InteractiveImageGesture)? onGesture;
  final double minScale;
  final double maxScale;

  @override
  State<InteractiveImageViewer> createState() => _InteractiveImageViewerState();
}

class _InteractiveImageViewerState extends State<InteractiveImageViewer>
    with TickerProviderStateMixin {
  late TransformationController _transformationController;
  late AnimationController _animationController;
  
  double _scale = 1.0;
  double _rotation = 0.0;
  
  bool _isInteracting = false;
  int _pointerCount = 0;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _handleDoubleTap,
      onLongPress: _handleLongPress,
      child: Listener(
        onPointerDown: _onPointerDown,
        onPointerUp: _onPointerUp,
        child: InteractiveViewer(
          transformationController: _transformationController,
          minScale: widget.minScale,
          maxScale: widget.maxScale,
          onInteractionStart: _onInteractionStart,
          onInteractionUpdate: _onInteractionUpdate,
          onInteractionEnd: _onInteractionEnd,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: RawImage(
                image: widget.image,
                fit: BoxFit.contain,
                alignment: Alignment.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onPointerDown(PointerDownEvent event) {
    _pointerCount++;
  }

  void _onPointerUp(PointerUpEvent event) {
    _pointerCount--;
    if (_pointerCount == 0) {
      _isInteracting = false;
    }
  }

  void _onInteractionStart(ScaleStartDetails details) {
    _isInteracting = true;
    HapticFeedback.lightImpact();
    
    final gesture = InteractiveImageGesture.start(
      position: details.localFocalPoint,
      scale: _scale,
      rotation: _rotation,
    );
    widget.onGesture?.call(gesture);
  }

  void _onInteractionUpdate(ScaleUpdateDetails details) {
    if (!_isInteracting) return;
    
    setState(() {
      _scale = (_scale * details.scale).clamp(widget.minScale, widget.maxScale);
      _rotation += details.rotation;
    });
    
    // Haptic feedback for scale thresholds
    if (_scale >= widget.maxScale - 0.1 || _scale <= widget.minScale + 0.1) {
      HapticFeedback.lightImpact();
    }
    
    final gesture = InteractiveImageGesture.update(
      position: details.localFocalPoint,
      scale: _scale,
      rotation: _rotation,
      velocity: details.scale,
    );
    widget.onGesture?.call(gesture);
  }

  void _onInteractionEnd(ScaleEndDetails details) {
    _isInteracting = false;
    
    // Snap to fit if scale is too small
    if (_scale < 0.8) {
      _animateToFit();
    }
    
    // Normalize rotation to nearest 90 degrees if close
    final normalizedRotation = (_rotation * 180 / math.pi) % 360;
    if (normalizedRotation.abs() < 15 || (normalizedRotation - 90).abs() < 15 ||
        (normalizedRotation - 180).abs() < 15 || (normalizedRotation - 270).abs() < 15) {
      final targetRotation = (normalizedRotation / 90).round() * 90;
      _animateRotationTo(targetRotation * math.pi / 180);
    }
    
    final gesture = InteractiveImageGesture.end(
      position: details.velocity.pixelsPerSecond,
      scale: _scale,
      rotation: _rotation,
    );
    widget.onGesture?.call(gesture);
  }

  void _handleDoubleTap() {
    HapticFeedback.mediumImpact();
    
    if (_scale > 1.5) {
      // Zoom out to fit
      _animateToFit();
    } else {
      // Zoom in to 2x
      _animateToScale(2.0);
    }
    
    widget.onDoubleTap?.call();
  }

  void _handleLongPress() {
    HapticFeedback.heavyImpact();
    widget.onLongPress?.call();
  }

  void _animateToFit() {
    final targetMatrix = Matrix4.identity();

    _animationController.forward(from: 0).then((_) {
      _transformationController.value = targetMatrix;
      setState(() {
        _scale = 1.0;
        _rotation = 0.0;
      });
    });
  }

  void _animateToScale(double targetScale) {
    final targetMatrix = Matrix4.identity()..scale(targetScale);
    


    _animationController.forward(from: 0).then((_) {
      _transformationController.value = targetMatrix;
      setState(() {
        _scale = targetScale;
      });
    });
  }

  void _animateRotationTo(double targetRotation) {
    setState(() {
      _rotation = targetRotation;
    });
    HapticFeedback.lightImpact();
  }
}

/// Gesture information for image interactions
class InteractiveImageGesture {
  const InteractiveImageGesture._({
    required this.type,
    required this.position,
    required this.scale,
    required this.rotation,
    this.velocity = 0.0,
  });

  final InteractiveImageGestureType type;
  final Offset position;
  final double scale;
  final double rotation;
  final double velocity;

  factory InteractiveImageGesture.start({
    required Offset position,
    required double scale,
    required double rotation,
  }) {
    return InteractiveImageGesture._(
      type: InteractiveImageGestureType.start,
      position: position,
      scale: scale,
      rotation: rotation,
    );
  }

  factory InteractiveImageGesture.update({
    required Offset position,
    required double scale,
    required double rotation,
    required double velocity,
  }) {
    return InteractiveImageGesture._(
      type: InteractiveImageGestureType.update,
      position: position,
      scale: scale,
      rotation: rotation,
      velocity: velocity,
    );
  }

  factory InteractiveImageGesture.end({
    required Offset position,
    required double scale,
    required double rotation,
  }) {
    return InteractiveImageGesture._(
      type: InteractiveImageGestureType.end,
      position: position,
      scale: scale,
      rotation: rotation,
    );
  }
}

enum InteractiveImageGestureType {
  start,
  update,
  end,
}

/// Gesture shortcuts overlay for professional photo editing
class GestureShortcutsOverlay extends StatefulWidget {
  const GestureShortcutsOverlay({
    super.key,
    required this.onShortcut,
    this.isVisible = false,
  });

  final Function(GestureShortcut) onShortcut;
  final bool isVisible;

  @override
  State<GestureShortcutsOverlay> createState() => _GestureShortcutsOverlayState();
}

class _GestureShortcutsOverlayState extends State<GestureShortcutsOverlay>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(GestureShortcutsOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _fadeController.forward();
      } else {
        _fadeController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shortcuts = [
      GestureShortcut.reset('Reset Zoom', Icons.zoom_out_map_rounded),
      GestureShortcut.rotate('Rotate 90°', Icons.rotate_90_degrees_ccw_rounded),
      GestureShortcut.flip('Flip Horizontal', Icons.flip_rounded),
      GestureShortcut.crop('Crop Tool', Icons.crop_rounded),
      GestureShortcut.compare('Compare', Icons.compare_arrows_rounded),
    ];

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 0.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'GESTURE SHORTCUTS',
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'Courier New',
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ...shortcuts.map((shortcut) => _buildShortcutItem(shortcut)),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcutItem(GestureShortcut shortcut) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onShortcut(shortcut);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              shortcut.icon,
              size: 20,
              color: Colors.white.withOpacity(0.9),
            ),
            const SizedBox(width: 12),
            Text(
              shortcut.label,
              style: TextStyle(
                fontSize: 11,
                fontFamily: 'Courier New',
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gesture shortcut actions for photo editing
class GestureShortcut {
  const GestureShortcut._({
    required this.type,
    required this.label,
    required this.icon,
  });

  final GestureShortcutType type;
  final String label;
  final IconData icon;

  factory GestureShortcut.reset(String label, IconData icon) {
    return GestureShortcut._(
      type: GestureShortcutType.reset,
      label: label,
      icon: icon,
    );
  }

  factory GestureShortcut.rotate(String label, IconData icon) {
    return GestureShortcut._(
      type: GestureShortcutType.rotate,
      label: label,
      icon: icon,
    );
  }

  factory GestureShortcut.flip(String label, IconData icon) {
    return GestureShortcut._(
      type: GestureShortcutType.flip,
      label: label,
      icon: icon,
    );
  }

  factory GestureShortcut.crop(String label, IconData icon) {
    return GestureShortcut._(
      type: GestureShortcutType.crop,
      label: label,
      icon: icon,
    );
  }

  factory GestureShortcut.compare(String label, IconData icon) {
    return GestureShortcut._(
      type: GestureShortcutType.compare,
      label: label,
      icon: icon,
    );
  }
}

enum GestureShortcutType {
  reset,
  rotate,
  flip,
  crop,
  compare,
}