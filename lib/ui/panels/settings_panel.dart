import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:softlightstudio/ui/glass.dart';
import 'package:softlightstudio/ui/theme.dart';
import 'package:softlightstudio/editor/editor_state.dart';
import 'package:softlightstudio/util/layout.dart';

class _AccentOption {
  const _AccentOption(this.label, this.color);

  final String label;
  final Color color;
}

const List<_AccentOption> _accentOptions = [
  _AccentOption('NOTHING RED', Color(0xFFFF4444)),
  _AccentOption('ELECTRIC BLUE', Color(0xFF3EA7FF)),
  _AccentOption('NEON VIOLET', Color(0xFF9C5BFF)),
  _AccentOption('CITRUS AMBER', Color(0xFFFFB547)),
  _AccentOption('MINT GREEN', Color(0xFF3EE6A1)),
];

/// Settings panel
class SettingsPanel extends StatelessWidget {
  const SettingsPanel({super.key, required this.onToggleTheme});

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
              Text('SETTINGS', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),

              // Theme toggle
              Row(
                children: [
                  const Text('Theme:'),
                  const SizedBox(width: 16),
                  GlassPillButton(
                    onPressed: onToggleTheme,
                    isSelected: true,
                    accentColor: editorState.highlightColor,
                    child: Text(isDark ? 'Dark' : 'Light'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Text(
                'ACCENT COLOR',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isDark
                      ? SoftlightTheme.gray300
                      : SoftlightTheme.gray700,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _accentOptions.map((option) {
                  final isSelected =
                      editorState.highlightColor.value == option.color.value;
                  return _AccentColorChip(
                    option: option,
                    isSelected: isSelected,
                    onSelected: () =>
                        editorState.setHighlightColor(option.color),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Reset all button
              Row(
                children: [
                  const Text('Adjustments:'),
                  const SizedBox(width: 16),
                  GlassPillButton(
                    onPressed: editorState.hasImage
                        ? editorState.resetAllParams
                        : null,
                    accentColor: editorState.highlightColor,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.refresh,
                          size: 16,
                          color: editorState.hasImage
                              ? (isDark
                                    ? SoftlightTheme.gray100
                                    : SoftlightTheme.gray800)
                              : SoftlightTheme.gray500,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'RESET ALL',
                          style: TextStyle(
                            color: editorState.hasImage
                                ? (isDark
                                      ? SoftlightTheme.gray100
                                      : SoftlightTheme.gray800)
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

class _AccentColorChip extends StatelessWidget {
  const _AccentColorChip({
    required this.option,
    required this.isSelected,
    required this.onSelected,
  });

  final _AccentOption option;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: option.color.withOpacity(isSelected ? 0.18 : 0.08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected
                ? option.color
                : (isDark ? SoftlightTheme.gray600 : SoftlightTheme.gray300),
            width: isSelected ? 1.2 : 0.6,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: option.color.withOpacity(0.28),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: option.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              option.label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? option.color
                    : (isDark
                          ? SoftlightTheme.gray200
                          : SoftlightTheme.gray800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
