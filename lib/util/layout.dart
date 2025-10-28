import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Helper widget to ensure finite width constraints
class FillWidth extends StatelessWidget {
  const FillWidth({super.key, required this.child});
  final Widget child;
  
  @override
  Widget build(BuildContext context) => SizedBox(width: double.infinity, child: child);
}

/// Safe container for panels that handles constraint hygiene
class PanelContainer extends StatelessWidget {
  const PanelContainer({
    super.key,
    required this.child,
    this.minHeight = 220.0,
    this.maxHeight = 420.0,
  });
  
  final Widget child;
  final double minHeight;
  final double maxHeight;
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight.isFinite 
            ? constraints.maxHeight 
            : maxHeight;
        final constrainedHeight = availableHeight > maxHeight ? maxHeight : availableHeight;
        final finalHeight = constrainedHeight < minHeight ? minHeight : constrainedHeight;
        
        return SizedBox(
          height: finalHeight,
          child: SingleChildScrollView(
            child: child,
          ),
        );
      },
    );
  }
}

/// Responsive breakpoints for layout decisions
class LayoutBreakpoints {
  static const double mobile = 480;
  static const double tablet = 768;
  static const double desktop = 1024;
  
  static bool isMobile(BuildContext context) => 
      MediaQuery.of(context).size.width < mobile;
      
  static bool isTablet(BuildContext context) => 
      MediaQuery.of(context).size.width >= mobile && 
      MediaQuery.of(context).size.width < desktop;
      
  static bool isDesktop(BuildContext context) => 
      MediaQuery.of(context).size.width >= desktop;
}

/// Safe area wrapper with consistent padding
class SafePadding extends StatelessWidget {
  const SafePadding({
    super.key,
    required this.child,
    this.horizontal = 16.0,
    this.vertical = 8.0,
  });
  
  final Widget child;
  final double horizontal;
  final double vertical;
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontal,
        vertical: vertical,
      ),
      child: child,
    );
  }
}

/// Mobile-optimized knob grid layout
class KnobGrid extends StatelessWidget {
  const KnobGrid({
    super.key,
    required this.children,
    this.spacing = 12.0,
    this.runSpacing = 16.0,
    this.knobSize = 64.0,
  });
  
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final double knobSize;
  
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final effectiveKnobSize = isMobile ? knobSize * 0.85 : knobSize; // Smaller on mobile
    final effectiveSpacing = isMobile ? spacing * 0.8 : spacing;
    
    // Mobile: 2 columns, Desktop: 3-4 columns
    final crossAxisCount = isMobile ? 2 : (MediaQuery.of(context).size.width > 900 ? 4 : 3);
    final availableWidth = MediaQuery.of(context).size.width - 40; // Account for padding
    final itemWidth = (availableWidth - (effectiveSpacing * (crossAxisCount - 1))) / crossAxisCount;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: effectiveSpacing,
          runSpacing: isMobile ? 12 : runSpacing,
          alignment: WrapAlignment.center,
          children: children.map((child) => 
            SizedBox(
              width: math.min(itemWidth, effectiveKnobSize),
              height: effectiveKnobSize + (isMobile ? 20 : 28), // Much smaller height to fix overflow
              child: child,
            )
          ).toList(),
        );
      },
    );
  }
}

/// Canvas sizing utility
class CanvasSize {
  static double calculateCanvasSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Calculate based on available space
    final maxSize = math.min(screenWidth * 0.6, screenHeight * 0.4);
    
    if (LayoutBreakpoints.isMobile(context)) {
      return maxSize.clamp(150, 250);
    } else if (LayoutBreakpoints.isTablet(context)) {
      return maxSize.clamp(200, 280);
    } else {
      return maxSize.clamp(250, 320);
    }
  }
}