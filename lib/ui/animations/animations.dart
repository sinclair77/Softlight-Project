import 'package:flutter/material.dart';
import 'package:softlightstudio/ui/theme.dart';

/// Nothing OS-inspired animation utilities and configurations
/// 
/// This file contains animation helpers, custom curves, and transitions
/// that create the signature smooth and flowing Nothing OS aesthetic.

// ============================================================================
// ANIMATION CURVES - Nothing OS Signature Feel
// ============================================================================

/// Nothing OS signature easing curves
class NothingCurves {
  /// Smooth deceleration - perfect for elements entering view
  static const Curve entrance = Curves.easeOutCubic;
  
  /// Smooth acceleration - perfect for elements exiting view
  static const Curve exit = Curves.easeInCubic;
  
  /// Balanced curve for bidirectional animations
  static const Curve standard = Curves.easeInOutCubic;
  
  /// Springy, bouncy curve for playful interactions
  static const Curve spring = Curves.elasticOut;
  
  /// Sharp and responsive for quick interactions
  static const Curve sharp = Curves.easeOutExpo;
  
  /// Smooth and fluid for continuous animations
  static const Curve smooth = Curves.easeInOutQuart;
}

// ============================================================================
// ANIMATION DURATIONS - Consistent Timing Across App
// ============================================================================

/// Standard animation durations following Nothing OS principles
class NothingDurations {
  /// Ultra-fast - for immediate feedback (hover, tap down)
  static const Duration instant = Duration(milliseconds: 100);
  
  /// Fast - for quick UI state changes
  static const Duration fast = Duration(milliseconds: 150);
  
  /// Standard - for most UI transitions
  static const Duration standard = Duration(milliseconds: 240);
  
  /// Medium - for panel transitions and modals
  static const Duration medium = Duration(milliseconds: 300);
  
  /// Slow - for page transitions and major UI changes
  static const Duration slow = Duration(milliseconds: 400);
  
  /// Breathing - for ambient, subtle animations
  static const Duration breathing = Duration(milliseconds: 600);
}

// ============================================================================
// CUSTOM PAGE TRANSITIONS
// ============================================================================

/// Smooth fade and slide page transition - Nothing OS style
class NothingPageTransition extends PageRouteBuilder {
  final Widget page;
  final Duration duration;
  final Curve curve;
  
  NothingPageTransition({
    required this.page,
    this.duration = NothingDurations.medium,
    this.curve = NothingCurves.entrance,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Fade transition
            final fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: curve,
            ));
            
            // Subtle slide from bottom
            final slideAnimation = Tween<Offset>(
              begin: const Offset(0.0, 0.03),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: curve,
            ));
            
            // Subtle scale
            final scaleAnimation = Tween<double>(
              begin: 0.97,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: curve,
            ));
            
            return FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(
                position: slideAnimation,
                child: ScaleTransition(
                  scale: scaleAnimation,
                  child: child,
                ),
              ),
            );
          },
        );
}

// ============================================================================
// CUSTOM ANIMATED WIDGETS
// ============================================================================

/// Animated widget that smoothly fades and scales in
class NothingFadeIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  
  const NothingFadeIn({
    super.key,
    required this.child,
    this.duration = NothingDurations.standard,
    this.delay = Duration.zero,
    this.curve = NothingCurves.entrance,
  });
  
  @override
  State<NothingFadeIn> createState() => _NothingFadeInState();
}

class _NothingFadeInState extends State<NothingFadeIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    
    // Start animation after delay
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Smooth animated switcher with Nothing OS transition style
class NothingSwitcher extends StatelessWidget {
  final Widget child;
  final Duration duration;
  
  const NothingSwitcher({
    super.key,
    required this.child,
    this.duration = NothingDurations.standard,
  });
  
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: NothingCurves.entrance,
      switchOutCurve: NothingCurves.exit,
      transitionBuilder: (child, animation) {
        // Combine fade, scale, and subtle slide
        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(animation);
        
        final scaleAnimation = Tween<double>(
          begin: 0.96,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: NothingCurves.entrance,
        ));
        
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0.0, 0.02),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: NothingCurves.entrance,
        ));
        
        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: SlideTransition(
              position: slideAnimation,
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}

/// Staggered animation for list items - smooth cascade effect
class NothingStaggeredList extends StatelessWidget {
  final List<Widget> children;
  final Duration itemDelay;
  final Axis direction;
  
  const NothingStaggeredList({
    super.key,
    required this.children,
    this.itemDelay = const Duration(milliseconds: 50),
    this.direction = Axis.vertical,
  });
  
  @override
  Widget build(BuildContext context) {
    return direction == Axis.vertical
        ? Column(
            children: _buildStaggeredChildren(),
          )
        : Row(
            children: _buildStaggeredChildren(),
          );
  }
  
  List<Widget> _buildStaggeredChildren() {
    return List.generate(children.length, (index) {
      return NothingFadeIn(
        delay: itemDelay * index,
        child: children[index],
      );
    });
  }
}

// ============================================================================
// ANIMATED BUTTON WITH PRESS EFFECTS
// ============================================================================

/// Interactive button with smooth press animations
class NothingButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? pressedColor;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  
  const NothingButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.pressedColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });
  
  @override
  State<NothingButton> createState() => _NothingButtonState();
}

class _NothingButtonState extends State<NothingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: NothingDurations.instant,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: NothingCurves.sharp,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }
  
  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onPressed?.call();
  }
  
  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = widget.backgroundColor ??
        (isDark ? SoftlightTheme.gray800 : SoftlightTheme.gray200);
    final pressedColor = widget.pressedColor ??
        (isDark ? SoftlightTheme.gray700 : SoftlightTheme.gray300);
    
    return GestureDetector(
      onTapDown: widget.onPressed != null ? _onTapDown : null,
      onTapUp: widget.onPressed != null ? _onTapUp : null,
      onTapCancel: widget.onPressed != null ? _onTapCancel : null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: NothingDurations.instant,
              curve: NothingCurves.sharp,
              padding: widget.padding,
              decoration: BoxDecoration(
                color: _isPressed ? pressedColor : backgroundColor,
                borderRadius: widget.borderRadius,
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// SHIMMER LOADING ANIMATION
// ============================================================================

/// Shimmer effect for loading states - Nothing OS style
class NothingShimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color? baseColor;
  final Color? highlightColor;
  
  const NothingShimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.baseColor,
    this.highlightColor,
  });
  
  @override
  State<NothingShimmer> createState() => _NothingShimmerState();
}

class _NothingShimmerState extends State<NothingShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = widget.baseColor ??
        (isDark ? SoftlightTheme.gray800 : SoftlightTheme.gray200);
    final highlightColor = widget.highlightColor ??
        (isDark ? SoftlightTheme.gray700 : SoftlightTheme.gray300);
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

// ============================================================================
// RIPPLE EFFECT WIDGET
// ============================================================================

/// Ripple animation effect for interactions
class NothingRipple extends StatefulWidget {
  final Widget child;
  final Color? rippleColor;
  final VoidCallback? onTap;
  
  const NothingRipple({
    super.key,
    required this.child,
    this.rippleColor,
    this.onTap,
  });
  
  @override
  State<NothingRipple> createState() => _NothingRippleState();
}

class _NothingRippleState extends State<NothingRipple>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _radiusAnimation;
  late Animation<double> _opacityAnimation;
  Offset? _tapPosition;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: NothingDurations.medium,
      vsync: this,
    );
    
    _radiusAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: NothingCurves.entrance,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.3,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _handleTap(TapDownDetails details) {
    setState(() {
      _tapPosition = details.localPosition;
    });
    _controller.forward(from: 0.0);
    widget.onTap?.call();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTap,
      child: CustomPaint(
        painter: _RipplePainter(
          animation: _controller,
          tapPosition: _tapPosition,
          color: widget.rippleColor ?? SoftlightTheme.accentRed,
          radius: _radiusAnimation.value,
          opacity: _opacityAnimation.value,
        ),
        child: widget.child,
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  final Animation<double> animation;
  final Offset? tapPosition;
  final Color color;
  final double radius;
  final double opacity;
  
  _RipplePainter({
    required this.animation,
    required this.tapPosition,
    required this.color,
    required this.radius,
    required this.opacity,
  }) : super(repaint: animation);
  
  @override
  void paint(Canvas canvas, Size size) {
    if (tapPosition == null) return;
    
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.fill;
    
    final maxRadius = size.width > size.height ? size.width : size.height;
    canvas.drawCircle(
      tapPosition!,
      maxRadius * radius,
      paint,
    );
  }
  
  @override
  bool shouldRepaint(_RipplePainter oldDelegate) {
    return oldDelegate.radius != radius || oldDelegate.opacity != opacity;
  }
}
