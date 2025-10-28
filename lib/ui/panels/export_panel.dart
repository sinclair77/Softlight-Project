import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:softlightstudio/ui/theme.dart';

/// Professional export panel for mobile photo editing
class ExportPanel extends StatefulWidget {
  const ExportPanel({super.key});

  @override
  State<ExportPanel> createState() => _ExportPanelState();
}

class _ExportPanelState extends State<ExportPanel> {
  String _selectedFormat = 'JPEG';
  String _selectedQuality = 'High';
  String _selectedSize = 'Original';
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: 380,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.file_download_outlined,
                color: isDark ? SoftlightTheme.white : SoftlightTheme.gray900,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'EXPORT SETTINGS',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'CourierNew',
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: isDark ? SoftlightTheme.white : SoftlightTheme.gray900,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Format selection
          _buildSection('FORMAT', [
            _buildOptionRow('JPEG', _selectedFormat == 'JPEG', () {
              setState(() => _selectedFormat = 'JPEG');
              HapticFeedback.lightImpact();
            }),
            _buildOptionRow('PNG', _selectedFormat == 'PNG', () {
              setState(() => _selectedFormat = 'PNG');
              HapticFeedback.lightImpact();
            }),
            _buildOptionRow('WebP', _selectedFormat == 'WebP', () {
              setState(() => _selectedFormat = 'WebP');
              HapticFeedback.lightImpact();
            }),
          ], isDark),
          
          const SizedBox(height: 20),
          
          // Quality selection
          _buildSection('QUALITY', [
            _buildOptionRow('High (95%)', _selectedQuality == 'High', () {
              setState(() => _selectedQuality = 'High');
              HapticFeedback.lightImpact();
            }),
            _buildOptionRow('Medium (80%)', _selectedQuality == 'Medium', () {
              setState(() => _selectedQuality = 'Medium');
              HapticFeedback.lightImpact();
            }),
            _buildOptionRow('Low (60%)', _selectedQuality == 'Low', () {
              setState(() => _selectedQuality = 'Low');
              HapticFeedback.lightImpact();
            }),
          ], isDark),
          
          const SizedBox(height: 20),
          
          // Size selection
          _buildSection('SIZE', [
            _buildOptionRow('Original', _selectedSize == 'Original', () {
              setState(() => _selectedSize = 'Original');
              HapticFeedback.lightImpact();
            }),
            _buildOptionRow('Instagram (1080×1080)', _selectedSize == 'Instagram', () {
              setState(() => _selectedSize = 'Instagram');
              HapticFeedback.lightImpact();
            }),
            _buildOptionRow('Web (1920×1080)', _selectedSize == 'Web', () {
              setState(() => _selectedSize = 'Web');
              HapticFeedback.lightImpact();
            }),
          ], isDark),
          
          const Spacer(),
          
          // Export button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                _showExportDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: SoftlightTheme.accentRed,
                foregroundColor: SoftlightTheme.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.file_download_rounded, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'EXPORT IMAGE',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'CourierNew',
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
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
  
  Widget _buildSection(String title, List<Widget> options, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontFamily: 'CourierNew',
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: isDark ? SoftlightTheme.gray400 : SoftlightTheme.gray600,
          ),
        ),
        const SizedBox(height: 8),
        ...options,
      ],
    );
  }
  
  Widget _buildOptionRow(String label, bool isSelected, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? SoftlightTheme.accentRed.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected 
                ? SoftlightTheme.accentRed.withOpacity(0.5)
                : (isDark ? SoftlightTheme.gray700 : SoftlightTheme.gray300),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected 
                      ? SoftlightTheme.accentRed
                      : (isDark ? SoftlightTheme.gray500 : SoftlightTheme.gray400),
                  width: 2,
                ),
                color: isSelected 
                    ? SoftlightTheme.accentRed
                    : Colors.transparent,
              ),
              child: isSelected 
                  ? Icon(
                      Icons.check,
                      size: 10,
                      color: SoftlightTheme.white,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontFamily: 'CourierNew',
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: isSelected
                    ? SoftlightTheme.accentRed
                    : (isDark ? SoftlightTheme.gray200 : SoftlightTheme.gray800),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Image'),
        content: Text('Export as $_selectedFormat with $_selectedQuality quality at $_selectedSize size?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Image exported as $_selectedFormat'),
                  backgroundColor: SoftlightTheme.accentRed,
                ),
              );
            },
            child: const Text('EXPORT'),
          ),
        ],
      ),
    );
  }
}