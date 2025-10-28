import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:softlightstudio/ui/theme.dart';
import 'package:softlightstudio/ui/ambient_bg.dart';

/// Glass surface with backdrop blur and subtle styling
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.tintOverride,
    this.borderRadius = 16.0,
    this.padding,
    this.margin,
  });
  
  final Widget child;
  final double? tintOverride;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Nothing OS precise backdrop blur
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: isDark ? 8.0 : 6.0, // More subtle blur for precision
                  sigmaY: isDark ? 8.0 : 6.0,
                ),
                child: Container(color: Colors.transparent),
              ),
            ),
            
            // Nothing OS tint - very precise opacity
            Positioned.fill(
              child: ColoredBox(
                color: isDark 
                    ? SoftlightTheme.black.withOpacity(0.75)  // Deep black base
                    : SoftlightTheme.white.withOpacity(0.85), // Clean white base
              ),
            ),
            
            // Nothing OS micro-texture (very subtle)
            Positioned.fill(
              child: CustomPaint(
                painter: NoisePainter(
                  opacity: isDark ? 0.008 : 0.004, // Almost imperceptible
                  seed: 42,
                  scale: 0.5, // Finer grain
                ),
              ),
            ),
            
            // Nothing OS border - minimal and precise
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(
                    color: isDark 
                        ? SoftlightTheme.gray600.withOpacity(0.4)
                        : SoftlightTheme.gray300.withOpacity(0.6),
                    width: 0.33, // Nothing uses very thin borders
                  ),
                ),
              ),
            ),
            
            // Nothing OS subtle inner glow
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark ? [
                      SoftlightTheme.white.withOpacity(0.04), // Very subtle highlight
                      Colors.transparent,
                      SoftlightTheme.black.withOpacity(0.08), // Subtle shadow
                    ] : [
                      SoftlightTheme.white.withOpacity(0.6),
                      Colors.transparent,
                      SoftlightTheme.gray200.withOpacity(0.3),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),
            
            // Content
            if (padding != null)
              Positioned.fill(
                child: Padding(
                  padding: padding!,
                  child: child,
                ),
              )
            else
              child,
          ],
        ),
      ),
    );
  }
}

/// Glass pill button
class GlassPillButton extends StatelessWidget {
  const GlassPillButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isSelected = false,
    this.width,
    this.height = 32.0,
  });
  
  final VoidCallback? onPressed;
  final Widget child;
  final bool isSelected;
  final double? width;
  final double height;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return SizedBox(
      width: width,
      height: height,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          backgroundColor: isSelected 
              ? SoftlightTheme.accentRed.withOpacity(0.15)
              : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(height / 2),
            side: BorderSide(
              color: isSelected 
                  ? SoftlightTheme.accentRed.withOpacity(0.5)
                  : (isDark ? SoftlightTheme.gray600 : SoftlightTheme.gray300),
              width: 0.5,
            ),
          ),
        ),
        child: DefaultTextStyle(
          style: theme.textTheme.labelMedium!.copyWith(
            color: isSelected 
                ? SoftlightTheme.accentRed
                : (isDark ? SoftlightTheme.gray100 : SoftlightTheme.gray800),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Glass icon button
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.isSelected = false,
    this.size = 40.0,
  });
  
  final VoidCallback? onPressed;
  final IconData icon;
  final bool isSelected;
  final double size;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(size / 2),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(size / 2),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected 
                  ? SoftlightTheme.accentRed.withOpacity(0.15)
                  : Colors.transparent,
              border: Border.all(
                color: isSelected 
                    ? SoftlightTheme.accentRed.withOpacity(0.5)
                    : (isDark ? SoftlightTheme.gray600 : SoftlightTheme.gray300),
                width: 0.5,
              ),
            ),
            child: Icon(
              icon,
              size: size * 0.5,
              color: isSelected 
                  ? SoftlightTheme.accentRed
                  : (isDark ? SoftlightTheme.gray100 : SoftlightTheme.gray800),
            ),
          ),
        ),
      ),
    );
  }
}

/// Glass card for content areas
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = 20.0,
  });
  
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  
  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      child: child,
    );
  }
}

/// Glass toolbar/bottom navigation
class GlassToolbar extends StatelessWidget {
  const GlassToolbar({
    super.key,
    required this.children,
    this.height = 64.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });
  
  final List<Widget> children;
  final double height;
  final EdgeInsetsGeometry padding;
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: GlassSurface(
        borderRadius: 0,
        padding: padding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: children,
        ),
      ),
    );
  }
}