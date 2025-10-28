import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:softlightstudio/ui/theme.dart';
import 'package:softlightstudio/editor/editor_state.dart';

/// Professional filters panel with industry-standard looks and film emulations
class FiltersPanel extends StatefulWidget {
  const FiltersPanel({super.key});

  @override
  State<FiltersPanel> createState() => _FiltersPanelState();
}

class _FiltersPanelState extends State<FiltersPanel> {
  String _selectedCategory = 'Film';
  String _selectedFilter = '';
  double _filterIntensity = 100.0;

  final Map<String, List<Map<String, dynamic>>> _filterCategories = {
    'Film': [
      {'name': 'Kodak Portra 400', 'description': 'Warm skin tones, smooth highlights', 'premium': false},
      {'name': 'Fuji Pro 400H', 'description': 'Pastel colors, dreamy highlights', 'premium': false},
      {'name': 'Kodak Ektar 100', 'description': 'Vibrant colors, fine grain', 'premium': false},
      {'name': 'Ilford HP5+', 'description': 'Classic B&W contrast', 'premium': true},
      {'name': 'Kodak Tri-X 400', 'description': 'Iconic B&W grain', 'premium': true},
      {'name': 'Cinestill 800T', 'description': 'Tungsten balanced, halation', 'premium': true},
    ],
    'B&W': [
      {'name': 'Classic Mono', 'description': 'Clean black and white', 'premium': false},
      {'name': 'High Contrast', 'description': 'Dramatic shadows', 'premium': false},
      {'name': 'Soft Mono', 'description': 'Gentle gradations', 'premium': false},
      {'name': 'Zone System', 'description': 'Ansel Adams inspired', 'premium': true},
      {'name': 'Infrared', 'description': 'Ethereal IR effect', 'premium': true},
      {'name': 'Selenium Toned', 'description': 'Archival warmth', 'premium': true},
    ],
    'Vintage': [
      {'name': '1970s Fade', 'description': 'Lifted blacks, warm highlights', 'premium': false},
      {'name': 'Polaroid SX-70', 'description': 'Instant film look', 'premium': false},
      {'name': 'Cross Process', 'description': 'Color shifts, contrast', 'premium': false},
      {'name': 'Lomography', 'description': 'Vignette, color casts', 'premium': true},
      {'name': 'Daguerreotype', 'description': '1800s metallic plate', 'premium': true},
    ],
    'Cinema': [
      {'name': 'Blockbuster', 'description': 'Orange & teal grade', 'premium': false},
      {'name': 'Film Noir', 'description': 'High contrast B&W', 'premium': false},
      {'name': 'Sci-Fi Blue', 'description': 'Cool cyberpunk tones', 'premium': false},
      {'name': 'Apocalypse Now', 'description': 'Desaturated war film', 'premium': true},
      {'name': 'Blade Runner', 'description': 'Neon noir aesthetic', 'premium': true},
      {'name': 'Mad Max Fury', 'description': 'Desert orange grade', 'premium': true},
    ],
    'Creative': [
      {'name': 'Neon Dreams', 'description': 'Vibrant synthwave', 'premium': false},
      {'name': 'Autumn Glow', 'description': 'Warm fall colors', 'premium': false},
      {'name': 'Arctic Blue', 'description': 'Cold winter tones', 'premium': false},
      {'name': 'Cyberpunk', 'description': 'Magenta & cyan', 'premium': true},
      {'name': 'Vaporwave', 'description': '80s aesthetic', 'premium': true},
      {'name': 'Dystopian', 'description': 'Desaturated future', 'premium': true},
    ],
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Consumer<EditorState>(
      builder: (context, editorState, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCategoryTabs(isDark),
            if (_selectedFilter.isNotEmpty)
              _buildIntensityControl(isDark, editorState),
            SizedBox(
              height: 300,
              child: _buildFiltersList(isDark, editorState),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryTabs(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filterCategories.keys.map((category) {
            final isSelected = _selectedCategory == category;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                  _selectedFilter = ''; // Reset selection when changing category
                });
                HapticFeedback.lightImpact();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? SoftlightTheme.gray700 : SoftlightTheme.gray100)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? SoftlightTheme.accentRed
                        : (isDark ? SoftlightTheme.gray600 : SoftlightTheme.gray300),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  category.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'CourierNew',
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    letterSpacing: 1.2,
                    color: isSelected
                        ? SoftlightTheme.accentRed
                        : (isDark ? SoftlightTheme.gray300 : SoftlightTheme.gray700),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildIntensityControl(bool isDark, EditorState editorState) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? SoftlightTheme.gray800 : SoftlightTheme.gray50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? SoftlightTheme.gray600 : SoftlightTheme.gray200,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'FILTER INTENSITY',
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'CourierNew',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: isDark ? SoftlightTheme.gray300 : SoftlightTheme.gray700,
                ),
              ),
              Text(
                '${_filterIntensity.toInt()}%',
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'CourierNew',
                  fontWeight: FontWeight.bold,
                  color: SoftlightTheme.accentRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: SoftlightTheme.accentRed,
              inactiveTrackColor: isDark ? SoftlightTheme.gray600 : SoftlightTheme.gray300,
              thumbColor: SoftlightTheme.accentRed,
              overlayColor: SoftlightTheme.accentRed.withAlpha(50),
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: _filterIntensity,
              min: 0.0,
              max: 200.0,
              onChanged: (value) {
                setState(() => _filterIntensity = value);
                editorState.updateParam('filterIntensity', value / 100.0);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersList(bool isDark, EditorState editorState) {
    final filters = _filterCategories[_selectedCategory] ?? [];
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filters.length,
      itemBuilder: (context, index) {
        final filter = filters[index];
        final isSelected = _selectedFilter == filter['name'];
        final isPremium = filter['premium'] as bool;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = isSelected ? '' : filter['name'];
              });
              
              if (!isSelected) {
                // Apply filter effect (use index as identifier)
                editorState.updateParam('filterIndex', index.toDouble());
                editorState.updateParam('filterIntensity', _filterIntensity / 100.0);
                HapticFeedback.mediumImpact();
              } else {
                // Remove filter
                editorState.updateParam('filterIndex', -1.0);
                HapticFeedback.lightImpact();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? SoftlightTheme.gray700 : SoftlightTheme.gray100)
                    : (isDark ? SoftlightTheme.gray800 : SoftlightTheme.gray50),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? SoftlightTheme.accentRed
                      : (isDark ? SoftlightTheme.gray600 : SoftlightTheme.gray200),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  // Filter preview (colored circle)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getFilterPreviewColor(filter['name']),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? SoftlightTheme.gray600 : SoftlightTheme.gray300,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        isSelected ? Icons.check : Icons.camera_alt,
                        size: 20,
                        color: isSelected ? Colors.white : Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Filter info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              filter['name'],
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'CourierNew',
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? SoftlightTheme.accentRed
                                    : (isDark ? SoftlightTheme.gray200 : SoftlightTheme.gray800),
                              ),
                            ),
                            if (isPremium) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD700),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'PRO',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontFamily: 'CourierNew',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          filter['description'],
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'CourierNew',
                            color: isDark ? SoftlightTheme.gray400 : SoftlightTheme.gray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getFilterPreviewColor(String filterName) {
    // Return representative colors for different filters
    switch (filterName) {
      case 'Kodak Portra 400': return const Color(0xFFE8C4A0);
      case 'Fuji Pro 400H': return const Color(0xFFF0E6D2);
      case 'Kodak Ektar 100': return const Color(0xFFFF6B35);
      case 'Ilford HP5+': return const Color(0xFF666666);
      case 'Kodak Tri-X 400': return const Color(0xFF333333);
      case 'Cinestill 800T': return const Color(0xFF4A90E2);
      case 'Classic Mono': return const Color(0xFF808080);
      case 'High Contrast': return const Color(0xFF000000);
      case 'Soft Mono': return const Color(0xFFC0C0C0);
      case 'Zone System': return const Color(0xFF404040);
      case 'Infrared': return const Color(0xFFFFE0E0);
      case 'Selenium Toned': return const Color(0xFFD2B48C);
      case '1970s Fade': return const Color(0xFFDEB887);
      case 'Polaroid SX-70': return const Color(0xFFE6E6FA);
      case 'Cross Process': return const Color(0xFF32CD32);
      case 'Lomography': return const Color(0xFF8B0000);
      case 'Daguerreotype': return const Color(0xFFE5E4E2);
      case 'Blockbuster': return const Color(0xFFFF8C00);
      case 'Film Noir': return const Color(0xFF2F2F2F);
      case 'Sci-Fi Blue': return const Color(0xFF0080FF);
      case 'Apocalypse Now': return const Color(0xFF8B7D6B);
      case 'Blade Runner': return const Color(0xFFFF1493);
      case 'Mad Max Fury': return const Color(0xFFFF4500);
      case 'Neon Dreams': return const Color(0xFFFF00FF);
      case 'Autumn Glow': return const Color(0xFFCD853F);
      case 'Arctic Blue': return const Color(0xFF87CEEB);
      case 'Cyberpunk': return const Color(0xFF9400D3);
      case 'Vaporwave': return const Color(0xFFFF69B4);
      case 'Dystopian': return const Color(0xFF696969);
      default: return const Color(0xFF808080);
    }
  }
}