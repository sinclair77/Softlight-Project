import 'package:flutter/services.dart';
import 'package:softlightstudio/editor/editor_state.dart';

/// Professional preset categories for photo editing
enum PresetCategory {
  portrait('Portrait', 'Person-focused adjustments'),
  landscape('Landscape', 'Nature and outdoor scenes'),
  street('Street', 'Urban and documentary'),
  film('Film Emulation', 'Classic film looks'),
  creative('Creative', 'Artistic and stylized'),
  bw('Black & White', 'Monochrome conversions'),
  wedding('Wedding', 'Event and celebration'),
  custom('Custom', 'User-created presets');

  const PresetCategory(this.displayName, this.description);
  final String displayName;
  final String description;
}

/// A single preset with parameter adjustments
class Preset {
  const Preset({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.adjustments,
    this.isFavorite = false,
    this.isBuiltIn = true,
    this.thumbnailPath,
  });

  final String id;
  final String name;
  final PresetCategory category;
  final String description;
  final Map<String, double> adjustments;
  final bool isFavorite;
  final bool isBuiltIn;
  final String? thumbnailPath;

  Preset copyWith({
    String? id,
    String? name,
    PresetCategory? category,
    String? description,
    Map<String, double>? adjustments,
    bool? isFavorite,
    bool? isBuiltIn,
    String? thumbnailPath,
  }) {
    return Preset(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      adjustments: adjustments ?? this.adjustments,
      isFavorite: isFavorite ?? this.isFavorite,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    );
  }
}

/// Professional presets manager for mobile photo editing
class PresetsManager {
  PresetsManager._();
  static final PresetsManager instance = PresetsManager._();

  static final List<Preset> builtInPresets = [
    // Portrait Presets
    Preset(
      id: 'portrait_natural',
      name: 'Natural Portrait',
      category: PresetCategory.portrait,
      description: 'Soft, flattering adjustments for portrait photography',
      adjustments: {
        'exposure': 0.1,
        'contrast': 0.1,
        'highlights': -0.2,
        'shadows': 0.15,
        'clarity': -0.1,
        'vibrance': 0.05,
        'saturation': -0.05,
        'temperature': 5600,
        'tint': 0.02,
      },
    ),
    
    Preset(
      id: 'portrait_dramatic',
      name: 'Dramatic Portrait',
      category: PresetCategory.portrait,
      description: 'High contrast with enhanced details',
      adjustments: {
        'exposure': 0.05,
        'contrast': 0.3,
        'highlights': -0.4,
        'shadows': 0.25,
        'clarity': 0.2,
        'vibrance': 0.1,
        'saturation': -0.1,
        'temperature': 5400,
        'dehaze': 0.1,
      },
    ),

    // Landscape Presets
    Preset(
      id: 'landscape_vivid',
      name: 'Vivid Landscape',
      category: PresetCategory.landscape,
      description: 'Enhanced colors and clarity for landscapes',
      adjustments: {
        'exposure': 0.0,
        'contrast': 0.15,
        'highlights': -0.3,
        'shadows': 0.2,
        'clarity': 0.25,
        'vibrance': 0.25,
        'saturation': 0.1,
        'temperature': 5800,
        'dehaze': 0.15,
      },
    ),

    Preset(
      id: 'landscape_moody',
      name: 'Moody Landscape',
      category: PresetCategory.landscape,
      description: 'Dark, atmospheric look for dramatic scenes',
      adjustments: {
        'exposure': -0.2,
        'contrast': 0.2,
        'highlights': -0.5,
        'shadows': 0.1,
        'clarity': 0.1,
        'vibrance': 0.0,
        'saturation': -0.15,
        'temperature': 5200,
        'vignetteAmount': 0.15,
      },
    ),

    // Street Photography
    Preset(
      id: 'street_classic',
      name: 'Classic Street',
      category: PresetCategory.street,
      description: 'Timeless look for urban photography',
      adjustments: {
        'exposure': 0.0,
        'contrast': 0.1,
        'highlights': -0.15,
        'shadows': 0.1,
        'clarity': 0.05,
        'vibrance': 0.05,
        'saturation': -0.1,
        'temperature': 5500,
      },
    ),

    Preset(
      id: 'street_gritty',
      name: 'Gritty Street',
      category: PresetCategory.street,
      description: 'High contrast, urban documentary style',
      adjustments: {
        'exposure': -0.1,
        'contrast': 0.25,
        'highlights': -0.3,
        'shadows': 0.2,
        'clarity': 0.3,
        'vibrance': -0.05,
        'saturation': -0.2,
        'temperature': 5300,
        'grain': 0.1,
      },
    ),

    // Film Emulation
    Preset(
      id: 'film_kodak_portra',
      name: 'Kodak Portra',
      category: PresetCategory.film,
      description: 'Warm, creamy film emulation',
      adjustments: {
        'exposure': 0.1,
        'contrast': -0.05,
        'highlights': -0.1,
        'shadows': 0.05,
        'clarity': -0.05,
        'vibrance': 0.1,
        'saturation': -0.05,
        'temperature': 5800,
        'tint': 0.05,
        'grain': 0.03,
      },
    ),

    Preset(
      id: 'film_fuji_velvia',
      name: 'Fuji Velvia',
      category: PresetCategory.film,
      description: 'Saturated, punchy slide film look',
      adjustments: {
        'exposure': 0.05,
        'contrast': 0.2,
        'highlights': -0.2,
        'shadows': 0.1,
        'clarity': 0.1,
        'vibrance': 0.3,
        'saturation': 0.2,
        'temperature': 5600,
      },
    ),

    // Black & White
    Preset(
      id: 'bw_classic',
      name: 'Classic B&W',
      category: PresetCategory.bw,
      description: 'Timeless black and white conversion',
      adjustments: {
        'exposure': 0.0,
        'contrast': 0.15,
        'highlights': -0.2,
        'shadows': 0.15,
        'clarity': 0.1,
        'vibrance': -1.0, // Desaturated
        'saturation': -1.0,
        'temperature': 5500,
      },
    ),

    Preset(
      id: 'bw_dramatic',
      name: 'Dramatic B&W',
      category: PresetCategory.bw,
      description: 'High contrast monochrome',
      adjustments: {
        'exposure': 0.0,
        'contrast': 0.4,
        'highlights': -0.4,
        'shadows': 0.3,
        'clarity': 0.25,
        'vibrance': -1.0,
        'saturation': -1.0,
        'temperature': 5500,
        'vignetteAmount': 0.1,
      },
    ),

    // Creative
    Preset(
      id: 'creative_vintage',
      name: 'Vintage',
      category: PresetCategory.creative,
      description: 'Warm, faded vintage look',
      adjustments: {
        'exposure': 0.1,
        'contrast': -0.1,
        'highlights': -0.3,
        'shadows': 0.2,
        'clarity': -0.1,
        'vibrance': -0.1,
        'saturation': -0.3,
        'temperature': 6200,
        'tint': 0.1,
        'vignetteAmount': 0.2,
        'grain': 0.08,
      },
    ),

    Preset(
      id: 'creative_cyberpunk',
      name: 'Cyberpunk',
      category: PresetCategory.creative,
      description: 'Futuristic neon aesthetic',
      adjustments: {
        'exposure': -0.1,
        'contrast': 0.3,
        'highlights': -0.2,
        'shadows': 0.1,
        'clarity': 0.2,
        'vibrance': 0.4,
        'saturation': 0.1,
        'temperature': 4800,
        'tint': -0.1,
        'shadowsHue': 240.0, // Blue shadows
        'highlightsHue': 60.0, // Yellow highlights
      },
    ),
  ];

  List<Preset> get allPresets => [...builtInPresets];

  List<Preset> getPresetsByCategory(PresetCategory category) {
    return allPresets.where((preset) => preset.category == category).toList();
  }

  Preset? getPresetById(String id) {
    try {
      return allPresets.firstWhere((preset) => preset.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Apply a preset to the editor state
  void applyPreset(Preset preset, EditorState editorState) {
    HapticFeedback.mediumImpact();
    
    // Apply all adjustments from the preset
    preset.adjustments.forEach((parameter, value) {
      editorState.updateParam(parameter, value);
    });
  }
}