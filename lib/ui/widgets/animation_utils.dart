import 'package:flutter/material.dart';

/// Enhanced AnimatedSwitcher with smooth fade and scale transitions
class SmoothAnimatedSwitcher extends StatelessWidget {
  const SmoothAnimatedSwitcher({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 280),
    this.reverseDuration,
    this.switchInCurve = Curves.easeOutCubic,
    this.switchOutCurve = Curves.easeInCubic,
    this.transitionBuilder,
  });

  final Widget child;
  final Duration duration;
  final Duration? reverseDuration;
  final Curve switchInCurve;
  final Curve switchOutCurve;
  final AnimatedSwitcherTransitionBuilder? transitionBuilder;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      reverseDuration: reverseDuration,
      switchInCurve: switchInCurve,
      switchOutCurve: switchOutCurve,
      transitionBuilder: transitionBuilder ?? _defaultTransitionBuilder,
      child: child,
    );
  }

  Widget _defaultTransitionBuilder(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.92, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: switchInCurve),
        ),
        child: child,
      ),
    );
  }
}

/// Slide and fade page transition
class SlideAndFadePageTransition extends PageRouteBuilder {
  final Widget page;
  final AxisDirection direction;

  SlideAndFadePageTransition({
    required this.page,
    this.direction = AxisDirection.left,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            Offset begin;
            switch (direction) {
              case AxisDirection.left:
                begin = const Offset(1.0, 0.0);
                break;
              case AxisDirection.right:
                begin = const Offset(-1.0, 0.0);
                break;
              case AxisDirection.up:
                begin = const Offset(0.0, 1.0);
                break;
              case AxisDirection.down:
                begin = const Offset(0.0, -1.0);
                break;
            }

            const end = Offset.zero;
            final slideTween = Tween(begin: begin, end: end);
            final fadeTween = Tween<double>(begin: 0.0, end: 1.0);

            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            return SlideTransition(
              position: slideTween.animate(curvedAnimation),
              child: FadeTransition(
                opacity: fadeTween.animate(curvedAnimation),
                child: child,
              ),
            );
          },
        );
}

/// Scale and fade page transition (for modals)
class ScaleAndFadePageTransition extends PageRouteBuilder {
  final Widget page;

  ScaleAndFadePageTransition({
    required this.page,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 280),
          reverseTransitionDuration: const Duration(milliseconds: 220),
          opaque: false,
          barrierColor: Colors.black54,
          barrierDismissible: true,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final scaleTween = Tween<double>(begin: 0.85, end: 1.0);
            final fadeTween = Tween<double>(begin: 0.0, end: 1.0);

            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            return ScaleTransition(
              scale: scaleTween.animate(curvedAnimation),
              child: FadeTransition(
                opacity: fadeTween.animate(curvedAnimation),
                child: child,
              ),
            );
          },
        );
}

/// Spring physics scroll behavior for smooth scrolling
class SpringScrollPhysics extends ScrollPhysics {
  const SpringScrollPhysics({super.parent});

  @override
  SpringScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SpringScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 50,
        stiffness: 100,
        damping: 15,
      );
}

/// Staggered animation for list items
class StaggeredListAnimation extends StatelessWidget {
  const StaggeredListAnimation({
    super.key,
    required this.index,
    required this.child,
    this.delay = const Duration(milliseconds: 50),
  });

  final int index;
  final Widget child;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final delayedValue = (value - (index * 0.1)).clamp(0.0, 1.0);
        
        return Opacity(
          opacity: delayedValue,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - delayedValue)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Animated theme color transition
class AnimatedThemeColor extends ImplicitlyAnimatedWidget {
  const AnimatedThemeColor({
    super.key,
    required this.color,
    required this.builder,
    super.duration = const Duration(milliseconds: 300),
    super.curve = Curves.easeOutCubic,
  });

  final Color color;
  final Widget Function(BuildContext context, Color color) builder;

  @override
  AnimatedWidgetBaseState<AnimatedThemeColor> createState() =>
      _AnimatedThemeColorState();
}

class _AnimatedThemeColorState
    extends AnimatedWidgetBaseState<AnimatedThemeColor> {
  ColorTween? _colorTween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _colorTween = visitor(
      _colorTween,
      widget.color,
      (dynamic value) => ColorTween(begin: value as Color),
    ) as ColorTween?;
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _colorTween?.evaluate(animation) ?? widget.color);
  }
}

/// Smooth hover scale animation
class HoverScaleAnimation extends StatefulWidget {
  const HoverScaleAnimation({
    super.key,
    required this.child,
    this.scale = 1.05,
    this.duration = const Duration(milliseconds: 150),
    this.curve = Curves.easeOutCubic,
  });

  final Widget child;
  final double scale;
  final Duration duration;
  final Curve curve;

  @override
  State<HoverScaleAnimation> createState() => _HoverScaleAnimationState();
}

class _HoverScaleAnimationState extends State<HoverScaleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scale).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovering = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovering = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Ripple animation for button presses
class RippleAnimation extends StatefulWidget {
  const RippleAnimation({
    super.key,
    required this.child,
    this.onTap,
    this.color,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color? color;

  @override
  State<RippleAnimation> createState() => _RippleAnimationState();
}

class _RippleAnimationState extends State<RippleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward(from: 0);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                if (_animation.value == 0) return const SizedBox.shrink();
                
                return CustomPaint(
                  painter: _RipplePainter(
                    progress: _animation.value,
                    color: widget.color ?? Colors.white.withOpacity(0.3),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  final double progress;
  final Color color;

  _RipplePainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = (size.width > size.height ? size.width : size.height) * 0.7;
    final radius = maxRadius * progress;

    final paint = Paint()
      ..color = color.withOpacity((1 - progress) * color.opacity)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_RipplePainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}
