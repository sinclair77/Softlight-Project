import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Image loading utilities for all platforms
class ImageLoader {
  
  /// Load image from file picker with RAW support
  static Future<LoadedImageInfo?> loadFromPicker() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          // Standard formats
          'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'tiff', 'tif',
          // RAW formats
          'raw', 'cr2', 'cr3', 'nef', 'dng', 'arw', 'orf', 'rw2', 'pef', 
          'srw', 'x3f', 'raf', 'rwl', 'iiq', '3fr', 'dcr', 'kdc', 'mef',
          'mos', 'mrw', 'nrw', 'ptx', 'pxn', 'r3d', 'rw2', 'rwz'
        ],
        allowMultiple: false,
        withData: true,
        withReadStream: true,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final bytes = await _resolveFileBytes(file);
        if (bytes != null) {
          return await _loadImageFromBytes(bytes, file.name);
        }
        debugPrint('Selected file "${file.name}" had no in-memory bytes or stream.');
      }
      return null;
    } catch (e) {
      debugPrint('Error loading image from picker: $e');
      return null;
    }
  }
  
  /// Load image from URL (web/desktop)
  static Future<LoadedImageInfo?> loadFromUrl(String url) async {
    try {
      final bytes = await NetworkAssetBundle(Uri.parse(url)).load(url);
      final filename = url.split('/').last;
      return await _loadImageFromBytes(bytes.buffer.asUint8List(), filename);
    } catch (e) {
      debugPrint('Error loading image from URL: $e');
      return null;
    }
  }
  
  /// Load placeholder image for testing
  static Future<LoadedImageInfo?> loadPlaceholder() async {
    try {
      final bytes = await rootBundle.load('assets/placeholder.jpg');
      return await _loadImageFromBytes(bytes.buffer.asUint8List(), 'placeholder.jpg');
    } catch (e) {
      // If no placeholder asset, create a simple colored rectangle
      return _createPlaceholderImage();
    }
  }
  
  /// Internal method to decode image from bytes
  static Future<LoadedImageInfo> _loadImageFromBytes(Uint8List bytes, String filename) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    
    return LoadedImageInfo(
      image: frame.image,
      bytes: bytes,
      filename: filename,
      width: frame.image.width,
      height: frame.image.height,
    );
  }
  
  /// Create a simple placeholder image programmatically
  static Future<LoadedImageInfo> _createPlaceholderImage() async {
    const width = 800.0;
    const height = 600.0;
    
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = const Color(0xFF2A2A2A);
    
    // Draw background
    canvas.drawRect(const Rect.fromLTWH(0, 0, width, height), paint);
    
    // Draw grid pattern
    paint.color = const Color(0xFF4A4A4A);
    paint.strokeWidth = 1;
    
    for (double i = 0; i <= width; i += 50) {
      canvas.drawLine(Offset(i, 0), Offset(i, height), paint);
    }
    for (double i = 0; i <= height; i += 50) {
      canvas.drawLine(Offset(0, i), Offset(width, i), paint);
    }
    
    // Add visible text
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'DEMO IMAGE\n800×600',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 48,
          fontWeight: FontWeight.bold,
          fontFamily: 'CourierNew',
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(
      (width - textPainter.width) / 2,
      (height - textPainter.height) / 2,
    ));
    
    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    
    // Create proper dummy bytes for image
    final bytes = Uint8List.fromList(List.generate(width.toInt() * height.toInt() * 4, (i) {
      final pixel = i ~/ 4;
      final component = i % 4;
      final x = pixel % width.toInt();
      final y = pixel ~/ width.toInt();
      
      // Create checkerboard pattern
      final checker = ((x ~/ 50) + (y ~/ 50)) % 2 == 0;
      if (component == 3) return 255; // Alpha
      return checker ? 60 : 100; // RGB
    }));
    
    return LoadedImageInfo(
      image: image,
      bytes: bytes,
      filename: 'placeholder.jpg',
      width: width.toInt(),
      height: height.toInt(),
    );
  }

  /// Resolve bytes for a [PlatformFile], supporting large desktop imports.
  static Future<Uint8List?> _resolveFileBytes(PlatformFile file) async {
    final directBytes = file.bytes;
    if (directBytes != null && directBytes.isNotEmpty) {
      return directBytes;
    }

    final stream = file.readStream;
    if (stream != null) {
      final builder = BytesBuilder(copy: false);
      await for (final chunk in stream) {
        if (chunk.isNotEmpty) {
          builder.add(chunk);
        }
      }
      final collected = builder.takeBytes();
      if (collected.isNotEmpty) {
        return collected;
      }
    }

    return null;
  }
}

/// Container for loaded image data
class LoadedImageInfo {
  const LoadedImageInfo({
    required this.image,
    required this.bytes,
    required this.filename,
    required this.width,
    required this.height,
  });
  
  final ui.Image image;
  final Uint8List bytes;
  final String filename;
  final int width;
  final int height;
  
  /// Get display resolution text
  String get resolutionText => '$width×$height';
  
  /// Get file info text
  String get fileInfoText => '$filename • $resolutionText';
}

/// Drag and drop handler for web platform
class ImageDropHandler extends StatefulWidget {
  const ImageDropHandler({
    super.key,
    required this.child,
    required this.onImageDropped,
  });
  
  final Widget child;
  final Function(LoadedImageInfo) onImageDropped;
  
  @override
  State<ImageDropHandler> createState() => _ImageDropHandlerState();
}

class _ImageDropHandlerState extends State<ImageDropHandler> {
  @override
  Widget build(BuildContext context) {
    // For now, just return the child - drag & drop will be enhanced later
    return widget.child;
  }
}

/// URL input dialog for web/desktop
class UrlInputDialog extends StatefulWidget {
  const UrlInputDialog({super.key});
  
  @override
  State<UrlInputDialog> createState() => _UrlInputDialogState();
}

class _UrlInputDialogState extends State<UrlInputDialog> {
  final _controller = TextEditingController();
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Load Image from URL'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'https://example.com/image.jpg',
              labelText: 'Image URL',
            ),
            autofocus: true,
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text('Load'),
        ),
      ],
    );
  }
  
  void _submit() {
    final url = _controller.text.trim();
    if (url.isEmpty) return;
    Navigator.pop(context, url);
  }
}
