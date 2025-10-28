import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:softlightstudio/ui/theme.dart';

/// Professional library panel for photo organization
class LibraryPanel extends StatefulWidget {
  const LibraryPanel({super.key});

  @override
  State<LibraryPanel> createState() => _LibraryPanelState();
}

class _LibraryPanelState extends State<LibraryPanel> {
  bool _isGridView = true;
  bool _isSelectionMode = false;
  final Set<int> _selectedPhotos = <int>{};

  // Mock photo data for professional demo
  final List<Map<String, dynamic>> _photos = List.generate(24, (index) {
    final random = math.Random(index);
    return {
      'id': index,
      'name': 'IMG_${(1000 + index).toString()}.${index % 3 == 0 ? 'RAF' : index % 2 == 0 ? 'CR3' : 'jpg'}',
      'date': DateTime.now().subtract(Duration(days: random.nextInt(90))),
      'size': '${(2.5 + random.nextDouble() * 10).toStringAsFixed(1)} MB',
      'rating': random.nextInt(6), // 0-5 stars
      'isEdited': random.nextBool(),
      'type': index % 3 == 0 ? 'RAW' : index % 2 == 0 ? 'RAW' : 'JPEG',
    };
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        // Header with view toggle and selection mode
        _buildHeader(isDark),
        
        // Selection toolbar (shown when in selection mode)
        if (_isSelectionMode) _buildSelectionToolbar(isDark),
        
        // Photos grid/list
        Expanded(
          child: _buildPhotosList(isDark),
        ),
        
        // Import button
        _buildImportButton(isDark),
      ],
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? SoftlightTheme.gray700 : SoftlightTheme.gray200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'LIBRARY',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'CourierNew',
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              color: isDark ? SoftlightTheme.gray200 : SoftlightTheme.gray800,
            ),
          ),
          Row(
            children: [
              // View toggle
              GestureDetector(
                onTap: () {
                  setState(() => _isGridView = !_isGridView);
                  HapticFeedback.lightImpact();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? SoftlightTheme.gray800 : SoftlightTheme.gray100,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDark ? SoftlightTheme.gray600 : SoftlightTheme.gray300,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    _isGridView ? Icons.view_list : Icons.grid_view,
                    size: 18,
                    color: isDark ? SoftlightTheme.gray300 : SoftlightTheme.gray700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              
              // Selection mode toggle
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isSelectionMode = !_isSelectionMode;
                    if (!_isSelectionMode) _selectedPhotos.clear();
                  });
                  HapticFeedback.lightImpact();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _isSelectionMode
                        ? SoftlightTheme.accentRed
                        : (isDark ? SoftlightTheme.gray800 : SoftlightTheme.gray100),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _isSelectionMode
                          ? SoftlightTheme.accentRed
                          : (isDark ? SoftlightTheme.gray600 : SoftlightTheme.gray300),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'SELECT',
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'CourierNew',
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: _isSelectionMode
                          ? Colors.white
                          : (isDark ? SoftlightTheme.gray300 : SoftlightTheme.gray700),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionToolbar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: SoftlightTheme.accentRed.withAlpha(20),
        border: Border(
          bottom: BorderSide(
            color: SoftlightTheme.accentRed.withAlpha(50),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            '${_selectedPhotos.length} SELECTED',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'CourierNew',
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: SoftlightTheme.accentRed,
            ),
          ),
          const Spacer(),
          _buildToolbarButton('DELETE', Icons.delete),
          const SizedBox(width: 8),
          _buildToolbarButton('EXPORT', Icons.share),
        ],
      ),
    );
  }

  Widget _buildToolbarButton(String label, IconData icon) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$label ${_selectedPhotos.length} photos',
              style: const TextStyle(fontFamily: 'CourierNew'),
            ),
            backgroundColor: SoftlightTheme.accentRed,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: SoftlightTheme.accentRed),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontFamily: 'CourierNew',
                fontWeight: FontWeight.w600,
                color: SoftlightTheme.accentRed,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotosList(bool isDark) {
    if (_isGridView) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.0,
        ),
        itemCount: _photos.length,
        itemBuilder: (context, index) => _buildPhotoTile(_photos[index], isDark),
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _photos.length,
        itemBuilder: (context, index) => _buildPhotoListItem(_photos[index], isDark),
      );
    }
  }

  Widget _buildPhotoTile(Map<String, dynamic> photo, bool isDark) {
    final isSelected = _selectedPhotos.contains(photo['id']);
    
    return GestureDetector(
      onTap: () {
        if (_isSelectionMode) {
          setState(() {
            if (isSelected) {
              _selectedPhotos.remove(photo['id']);
            } else {
              _selectedPhotos.add(photo['id']);
            }
          });
          HapticFeedback.lightImpact();
        } else {
          // Open for editing
          HapticFeedback.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening ${photo['name']} for editing',
                  style: const TextStyle(fontFamily: 'CourierNew')),
              backgroundColor: SoftlightTheme.accentRed,
            ),
          );
        }
      },
      onLongPress: () {
        if (!_isSelectionMode) {
          setState(() {
            _isSelectionMode = true;
            _selectedPhotos.add(photo['id']);
          });
          HapticFeedback.mediumImpact();
        }
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? SoftlightTheme.accentRed
                    : (isDark ? SoftlightTheme.gray600 : SoftlightTheme.gray300),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.grey[400],
                child: Icon(
                  Icons.image,
                  size: 32,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
          
          // File type badge
          Positioned(
            top: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: photo['type'] == 'RAW' ? Colors.green : Colors.blue,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                photo['type'],
                style: const TextStyle(
                  fontSize: 8,
                  fontFamily: 'CourierNew',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          // Selection indicator
          if (_isSelectionMode)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isSelected ? SoftlightTheme.accentRed : Colors.white70,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? SoftlightTheme.accentRed : Colors.grey,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                    : null,
              ),
            ),
          
          // Edited indicator
          if (photo['isEdited'])
            Positioned(
              bottom: 6,
              right: 6,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: SoftlightTheme.accentRed,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhotoListItem(Map<String, dynamic> photo, bool isDark) {
    final isSelected = _selectedPhotos.contains(photo['id']);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected
            ? SoftlightTheme.accentRed.withAlpha(20)
            : (isDark ? SoftlightTheme.gray800 : SoftlightTheme.gray50),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected
              ? SoftlightTheme.accentRed
              : (isDark ? SoftlightTheme.gray600 : SoftlightTheme.gray200),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Thumbnail
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.image, size: 20, color: Colors.grey[600]),
          ),
          const SizedBox(width: 12),
          
          // Photo info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  photo['name'],
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'CourierNew',
                    fontWeight: FontWeight.w600,
                    color: isDark ? SoftlightTheme.gray200 : SoftlightTheme.gray800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${photo['size']} • ${_formatDate(photo['date'])}',
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'CourierNew',
                    color: isDark ? SoftlightTheme.gray400 : SoftlightTheme.gray600,
                  ),
                ),
              ],
            ),
          ),
          
          // Selection indicator
          if (_isSelectionMode)
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? SoftlightTheme.accentRed : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? SoftlightTheme.accentRed : Colors.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
        ],
      ),
    );
  }

  Widget _buildImportButton(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.heavyImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Import photos from device',
                  style: TextStyle(fontFamily: 'CourierNew')),
              backgroundColor: SoftlightTheme.accentRed,
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: SoftlightTheme.accentRed,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate, size: 20, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'IMPORT PHOTOS',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'CourierNew',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}