import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:softlightstudio/ui/theme.dart';
import 'package:softlightstudio/editor/editor_state.dart';

/// Professional crop and rotate panel for mobile photo editing
class CropPanel extends StatefulWidget {
  const CropPanel({super.key});

  @override
  State<CropPanel> createState() => _CropPanelState();
}

class _CropPanelState extends State<CropPanel> {
  String _selectedAspectRatio = 'Free';
  double _rotationAngle = 0.0;
  double _straightenAngle = 0.0;
  bool _flipHorizontal = false;
  bool _flipVertical = false;

  final List<Map<String, dynamic>> _aspectRatios = [
    {'label': 'Free', 'ratio': null},
    {'label': '1:1', 'ratio': 1.0},
    {'label': '4:3', 'ratio': 4.0/3.0},
    {'label': '3:2', 'ratio': 3.0/2.0},
    {'label': '16:9', 'ratio': 16.0/9.0},
    {'label': '5:4', 'ratio': 5.0/4.0},
    {'label': '2:1', 'ratio': 2.0},
    {'label': '3:4', 'ratio': 3.0/4.0},
    {'label': '2:3', 'ratio': 2.0/3.0},
    {'label': '9:16', 'ratio': 9.0/16.0},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Consumer<EditorState>(
      builder: (context, editorState, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Aspect ratio presets
              _buildAspectRatioSection(isDark),
              const SizedBox(height: 24),
              
              // Rotation controls
              _buildRotationSection(isDark, editorState),
              const SizedBox(height: 24),
              
              // Flip controls
              _buildFlipSection(isDark, editorState),
              const SizedBox(height: 24),
              
              // Action buttons
              _buildActionButtons(isDark, editorState),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAspectRatioSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ASPECT RATIO',
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'CourierNew',
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: isDark ? SoftlightTheme.gray300 : SoftlightTheme.gray700,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _aspectRatios.length,
            itemBuilder: (context, index) {
              final aspectRatio = _aspectRatios[index];
              final isSelected = _selectedAspectRatio == aspectRatio['label'];
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedAspectRatio = aspectRatio['label'];
                  });
                  HapticFeedback.lightImpact();
                },
                child: Container(
                  width: 60,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? SoftlightTheme.gray700 : SoftlightTheme.gray100)
                        : (isDark ? SoftlightTheme.gray800 : SoftlightTheme.gray50),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? SoftlightTheme.accentRed
                          : (isDark ? SoftlightTheme.gray600 : SoftlightTheme.gray300),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Visual representation
                      Container(
                        width: aspectRatio['ratio'] == null ? 24 : 24,
                        height: aspectRatio['ratio'] == null 
                            ? 24.0
                            : (aspectRatio['ratio'] as double) > 1 
                                ? 24.0 / (aspectRatio['ratio'] as double)
                                : 24.0 * (aspectRatio['ratio'] as double),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? SoftlightTheme.accentRed
                              : (isDark ? SoftlightTheme.gray400 : SoftlightTheme.gray600),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        aspectRatio['label'],
                        style: TextStyle(
                          fontSize: 10,
                          fontFamily: 'CourierNew',
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? SoftlightTheme.accentRed
                              : (isDark ? SoftlightTheme.gray300 : SoftlightTheme.gray700),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRotationSection(bool isDark, EditorState editorState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ROTATION & STRAIGHTEN',
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'CourierNew',
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: isDark ? SoftlightTheme.gray300 : SoftlightTheme.gray700,
          ),
        ),
        const SizedBox(height: 16),
        
        // Quick rotation buttons
        Row(
          children: [
            _buildQuickRotateButton('90°', 90, isDark),
            const SizedBox(width: 12),
            _buildQuickRotateButton('180°', 180, isDark),
            const SizedBox(width: 12),
            _buildQuickRotateButton('270°', 270, isDark),
          ],
        ),
        const SizedBox(height: 16),
        
        // Fine rotation slider
        _buildSlider(
          'Rotation',
          _rotationAngle,
          -180.0,
          180.0,
          (value) {
            setState(() => _rotationAngle = value);
            editorState.updateParam('rotation', value);
          },
          isDark,
        ),
        
        // Straighten slider
        _buildSlider(
          'Straighten',
          _straightenAngle,
          -45.0,
          45.0,
          (value) {
            setState(() => _straightenAngle = value);
            editorState.updateParam('straighten', value);
          },
          isDark,
        ),
      ],
    );
  }

  Widget _buildQuickRotateButton(String label, double angle, bool isDark) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _rotationAngle = (_rotationAngle + angle) % 360;
          });
          HapticFeedback.mediumImpact();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? SoftlightTheme.gray800 : SoftlightTheme.gray100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? SoftlightTheme.gray600 : SoftlightTheme.gray300,
              width: 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'CourierNew',
              fontWeight: FontWeight.w600,
              color: isDark ? SoftlightTheme.gray200 : SoftlightTheme.gray800,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlipSection(bool isDark, EditorState editorState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FLIP',
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'CourierNew',
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: isDark ? SoftlightTheme.gray300 : SoftlightTheme.gray700,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildFlipButton(
              'Horizontal',
              Icons.flip,
              _flipHorizontal,
              () {
                setState(() => _flipHorizontal = !_flipHorizontal);
                editorState.updateParam('flipHorizontal', _flipHorizontal ? 1.0 : 0.0);
                HapticFeedback.lightImpact();
              },
              isDark,
            ),
            const SizedBox(width: 12),
            _buildFlipButton(
              'Vertical',
              Icons.flip,
              _flipVertical,
              () {
                setState(() => _flipVertical = !_flipVertical);
                editorState.updateParam('flipVertical', _flipVertical ? 1.0 : 0.0);
                HapticFeedback.lightImpact();
              },
              isDark,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFlipButton(String label, IconData icon, bool isActive, VoidCallback onTap, bool isDark) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isActive
                ? (isDark ? SoftlightTheme.gray700 : SoftlightTheme.gray200)
                : (isDark ? SoftlightTheme.gray800 : SoftlightTheme.gray100),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive
                  ? SoftlightTheme.accentRed
                  : (isDark ? SoftlightTheme.gray600 : SoftlightTheme.gray300),
              width: isActive ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 24,
                color: isActive
                    ? SoftlightTheme.accentRed
                    : (isDark ? SoftlightTheme.gray400 : SoftlightTheme.gray600),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'CourierNew',
                  fontWeight: FontWeight.w500,
                  color: isActive
                      ? SoftlightTheme.accentRed
                      : (isDark ? SoftlightTheme.gray300 : SoftlightTheme.gray700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, 
                     void Function(double) onChanged, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontFamily: 'CourierNew',
                fontWeight: FontWeight.w500,
                color: isDark ? SoftlightTheme.gray400 : SoftlightTheme.gray600,
              ),
            ),
            Text(
              '${value.toStringAsFixed(1)}°',
              style: TextStyle(
                fontSize: 11,
                fontFamily: 'CourierNew',
                fontWeight: FontWeight.w600,
                color: isDark ? SoftlightTheme.gray200 : SoftlightTheme.gray800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: SoftlightTheme.accentRed,
            inactiveTrackColor: isDark ? SoftlightTheme.gray600 : SoftlightTheme.gray300,
            thumbColor: SoftlightTheme.accentRed,
            overlayColor: SoftlightTheme.accentRed.withAlpha(50),
            trackHeight: 2,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildActionButtons(bool isDark, EditorState editorState) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            'Reset All',
            () {
              setState(() {
                _selectedAspectRatio = 'Free';
                _rotationAngle = 0.0;
                _straightenAngle = 0.0;
                _flipHorizontal = false;
                _flipVertical = false;
              });
              // Reset parameters in editor state
              editorState.updateParam('rotation', 0.0);
              editorState.updateParam('straighten', 0.0);
              editorState.updateParam('flipHorizontal', 0.0);
              editorState.updateParam('flipVertical', 0.0);
              HapticFeedback.mediumImpact();
            },
            isDark,
            isSecondary: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            'Apply Crop',
            () {
              // Apply crop with selected aspect ratio and transformations
              HapticFeedback.heavyImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Crop applied with $_selectedAspectRatio aspect ratio',
                    style: const TextStyle(fontFamily: 'CourierNew'),
                  ),
                  backgroundColor: SoftlightTheme.accentRed,
                ),
              );
            },
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, VoidCallback onTap, bool isDark, {bool isSecondary = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSecondary
              ? (isDark ? SoftlightTheme.gray800 : SoftlightTheme.gray100)
              : SoftlightTheme.accentRed,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSecondary
                ? (isDark ? SoftlightTheme.gray600 : SoftlightTheme.gray300)
                : SoftlightTheme.accentRed,
            width: 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'CourierNew',
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: isSecondary
                ? (isDark ? SoftlightTheme.gray200 : SoftlightTheme.gray800)
                : Colors.white,
          ),
        ),
      ),
    );
  }
}