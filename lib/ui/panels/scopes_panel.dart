import 'package:flutter/material.dart';
import 'package:softlightstudio/ui/theme.dart';
import 'package:softlightstudio/util/layout.dart';

/// Scopes panel with histogram display
class ScopesPanel extends StatelessWidget {
  const ScopesPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return SafePadding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SCOPES',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          
          // Histogram placeholder
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: SoftlightTheme.gray800.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: SoftlightTheme.gray600.withOpacity(0.5),
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.insights_outlined,
                    size: 32,
                    color: SoftlightTheme.gray500,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'HISTOGRAM PLACEHOLDER',
                    style: TextStyle(
                      color: SoftlightTheme.gray500,
                      fontSize: 10,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Text(
                    'Real-time histogram coming in future update',
                    style: TextStyle(
                      color: SoftlightTheme.gray600,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}