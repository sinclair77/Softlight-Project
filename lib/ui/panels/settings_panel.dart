import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:softlightstudio/ui/glass.dart';
import 'package:softlightstudio/ui/theme.dart';
import 'package:softlightstudio/editor/editor_state.dart';
import 'package:softlightstudio/util/layout.dart';

/// Settings panel
class SettingsPanel extends StatelessWidget {
  const SettingsPanel({
    super.key,
    required this.onToggleTheme,
  });
  
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Consumer<EditorState>(
      builder: (context, editorState, child) {
        return SafePadding(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SETTINGS',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              
              // Theme toggle
              Row(
                children: [
                  const Text('Theme:'),
                  const SizedBox(width: 16),
                  GlassPillButton(
                    onPressed: onToggleTheme,
                    isSelected: true,
                    child: Text(isDark ? 'Dark' : 'Light'),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Reset all button
              Row(
                children: [
                  const Text('Adjustments:'),
                  const SizedBox(width: 16),
                  GlassPillButton(
                    onPressed: editorState.hasImage ? editorState.resetAllParams : null,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.refresh,
                          size: 16,
                          color: editorState.hasImage 
                              ? (isDark ? SoftlightTheme.gray100 : SoftlightTheme.gray800)
                              : SoftlightTheme.gray500,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'RESET ALL',
                          style: TextStyle(
                            color: editorState.hasImage 
                                ? (isDark ? SoftlightTheme.gray100 : SoftlightTheme.gray800)
                                : SoftlightTheme.gray500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // App info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: SoftlightTheme.gray800.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: SoftlightTheme.gray600.withOpacity(0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SOFTLIGHT STUDIO',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: SoftlightTheme.gray400,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Phase 1 • Nothing OS-inspired photo editor',
                      style: TextStyle(
                        color: SoftlightTheme.gray500,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Real-time image adjustments\n• Monochrome UI with red accents\n• Cross-platform Flutter app',
                      style: TextStyle(
                        color: SoftlightTheme.gray600,
                        fontSize: 10,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}