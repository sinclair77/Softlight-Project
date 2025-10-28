import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Nothing OS-inspired design system - Authentic Nothing aesthetics
class SoftlightTheme {
  // Nothing OS signature colors - exact matches from the reference
  static const Color accentRed = Color(0xFFFF4444);  // Nothing's precise red
  static const Color accentYellow = Color(0xFFFFCC02);
  static const Color accentWhite = Color(0xFFFFFFFF);
  
  // Pure monochrome grayscale palette - Nothing OS precision
  static const Color black = Color(0xFF000000);
  static const Color gray950 = Color(0xFF050505);
  static const Color gray900 = Color(0xFF0F0F0F);
  static const Color gray850 = Color(0xFF171717);
  static const Color gray800 = Color(0xFF1F1F1F);
  static const Color gray750 = Color(0xFF272727);
  static const Color gray700 = Color(0xFF2F2F2F);
  static const Color gray650 = Color(0xFF373737);
  static const Color gray600 = Color(0xFF404040);
  static const Color gray550 = Color(0xFF484848);
  static const Color gray500 = Color(0xFF505050);
  static const Color gray450 = Color(0xFF585858);
  static const Color gray400 = Color(0xFF606060);
  static const Color gray350 = Color(0xFF686868);
  static const Color gray300 = Color(0xFF707070);
  static const Color gray250 = Color(0xFF787878);
  static const Color gray200 = Color(0xFF808080);
  static const Color gray150 = Color(0xFF888888);
  static const Color gray100 = Color(0xFF909090);
  static const Color gray50 = Color(0xFF989898);
  static const Color white = Color(0xFFFFFFFF);
  
  // Animation curves and durations
  static const Curve easeOutCubic = Curves.easeOutCubic;
  static const Duration fastAnimation = Duration(milliseconds: 120);
  static const Duration mediumAnimation = Duration(milliseconds: 180);
  static const Duration slowAnimation = Duration(milliseconds: 220);
  static const Duration breathingAnimation = Duration(milliseconds: 400);
  
  // Typography - Nothing OS with futuristic typewriter feel
  static const String primaryFamily = 'CourierNew';
  static const String monoFamily = 'CourierNew';
  static const String typewriterFamily = 'CourierNew';
  static const String futureFamily = 'CourierNew';
  static const String fallbackFont = 'Courier';
  
  static TextTheme _buildTextTheme(bool isDark) {
    final baseColor = isDark ? white : black;
    final mutedColor = isDark ? gray300 : gray700;
    final labelColor = isDark ? gray200 : gray800;
    
    const fontFallbacks = ['Courier New', 'Courier', 'monospace'];
    
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: primaryFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 28,
        fontWeight: FontWeight.w200,
        color: baseColor,
        letterSpacing: -0.8,
        height: 1.1,
      ),
      displayMedium: TextStyle(
        fontFamily: primaryFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 24,
        fontWeight: FontWeight.w300,
        color: baseColor,
        letterSpacing: -0.4,
        height: 1.2,
      ),
      displaySmall: TextStyle(
        fontFamily: primaryFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 20,
        fontWeight: FontWeight.w400,
        color: baseColor,
        letterSpacing: -0.2,
        height: 1.3,
      ),
      headlineLarge: TextStyle(
        fontFamily: primaryFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: baseColor,
        letterSpacing: 0,
        height: 1.3,
      ),
      headlineMedium: TextStyle(
        fontFamily: primaryFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: baseColor,
        letterSpacing: 0,
        height: 1.4,
      ),
      headlineSmall: TextStyle(
        fontFamily: primaryFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: baseColor,
        letterSpacing: 0,
        height: 1.4,
      ),
      titleLarge: TextStyle(
        fontFamily: typewriterFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: labelColor,
        letterSpacing: 1.8,
        height: 1.1,
      ),
      titleMedium: TextStyle(
        fontFamily: typewriterFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: labelColor,
        letterSpacing: 2.0,
        height: 1.1,
      ),
      titleSmall: TextStyle(
        fontFamily: typewriterFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: labelColor,
        letterSpacing: 2.2,
        height: 1.1,
      ),
      bodyLarge: TextStyle(
        fontFamily: primaryFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: baseColor,
        letterSpacing: 0,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontFamily: primaryFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: mutedColor,
        letterSpacing: 0,
        height: 1.4,
      ),
      bodySmall: TextStyle(
        fontFamily: primaryFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: mutedColor,
        letterSpacing: 0.2,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        fontFamily: futureFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: labelColor,
        letterSpacing: 1.4,
        height: 1.1,
      ),
      labelMedium: TextStyle(
        fontFamily: futureFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 9,
        fontWeight: FontWeight.w600,
        color: labelColor,
        letterSpacing: 1.6,
        height: 1.1,
      ),
      labelSmall: TextStyle(
        fontFamily: futureFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 8,
        fontWeight: FontWeight.w600,
        color: mutedColor,
        letterSpacing: 1.8,
        height: 1.1,
      ),
    );
  }
  
  static ThemeData buildDarkTheme() {
    final colorScheme = ColorScheme.dark(
      primary: accentRed,
      onPrimary: white,
      secondary: gray600,
      onSecondary: gray100,
      error: accentRed,
      onError: white,
      surface: gray900,
      onSurface: gray100,
      outline: gray600,
      outlineVariant: gray700,
    );
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(true),
      scaffoldBackgroundColor: black,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: _buildTextTheme(true).titleLarge,
        iconTheme: const IconThemeData(color: gray100),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: gray900.withOpacity(0.95),
        selectedItemColor: accentRed,
        unselectedItemColor: gray500,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentRed,
          foregroundColor: white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: gray100,
          side: const BorderSide(color: gray600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: accentRed,
        inactiveTrackColor: gray700,
        thumbColor: accentRed,
        overlayColor: accentRed.withOpacity(0.2),
        trackHeight: 2,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
      ),
    );
  }
  
  static ThemeData buildLightTheme() {
    final colorScheme = ColorScheme.light(
      primary: accentRed,
      onPrimary: white,
      secondary: gray400,
      onSecondary: gray800,
      error: accentRed,
      onError: white,
      surface: white,
      onSurface: gray800,
      outline: gray300,
      outlineVariant: gray200,
    );
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(false),
      scaffoldBackgroundColor: gray50,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: _buildTextTheme(false).titleLarge,
        iconTheme: const IconThemeData(color: gray800),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: white.withOpacity(0.95),
        selectedItemColor: accentRed,
        unselectedItemColor: gray400,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentRed,
          foregroundColor: white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: gray800,
          side: const BorderSide(color: gray300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: accentRed,
        inactiveTrackColor: gray200,
        thumbColor: accentRed,
        overlayColor: accentRed.withOpacity(0.2),
        trackHeight: 2,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
      ),
    );
  }
}

/// Theme extension for glass effects and custom properties
class SoftlightThemeExtension extends ThemeExtension<SoftlightThemeExtension> {
  final Color glassBackground;
  final Color glassBorder;
  final Color canvasBorder;
  final double glassBlur;
  final double glassTint;
  
  const SoftlightThemeExtension({
    required this.glassBackground,
    required this.glassBorder,
    required this.canvasBorder,
    required this.glassBlur,
    required this.glassTint,
  });
  
  static const SoftlightThemeExtension dark = SoftlightThemeExtension(
    glassBackground: SoftlightTheme.gray900,
    glassBorder: SoftlightTheme.gray700,
    canvasBorder: SoftlightTheme.gray600,
    glassBlur: 12.0,
    glassTint: 0.16,
  );
  
  static const SoftlightThemeExtension light = SoftlightThemeExtension(
    glassBackground: SoftlightTheme.white,
    glassBorder: SoftlightTheme.gray200,
    canvasBorder: SoftlightTheme.gray300,
    glassBlur: 12.0,
    glassTint: 0.88,
  );
  
  @override
  SoftlightThemeExtension copyWith({
    Color? glassBackground,
    Color? glassBorder,
    Color? canvasBorder,
    double? glassBlur,
    double? glassTint,
  }) {
    return SoftlightThemeExtension(
      glassBackground: glassBackground ?? this.glassBackground,
      glassBorder: glassBorder ?? this.glassBorder,
      canvasBorder: canvasBorder ?? this.canvasBorder,
      glassBlur: glassBlur ?? this.glassBlur,
      glassTint: glassTint ?? this.glassTint,
    );
  }
  
  @override
  SoftlightThemeExtension lerp(SoftlightThemeExtension? other, double t) {
    if (other == null) return this;
    return SoftlightThemeExtension(
      glassBackground: Color.lerp(glassBackground, other.glassBackground, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      canvasBorder: Color.lerp(canvasBorder, other.canvasBorder, t)!,
      glassBlur: lerpDouble(glassBlur, other.glassBlur, t) ?? glassBlur,
      glassTint: lerpDouble(glassTint, other.glassTint, t) ?? glassTint,
    );
  }
}

double? lerpDouble(double? a, double? b, double t) {
  if (a == null && b == null) return null;
  a ??= 0.0;
  b ??= 0.0;
  return a + (b - a) * t;
}