import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Professional export formats for mobile photo editing
enum ExportFormat {
  jpeg('JPEG', 'jpg', true),
  png('PNG', 'png', false),
  webp('WebP', 'webp', true),
  tiff('TIFF', 'tiff', false);

  const ExportFormat(this.displayName, this.extension, this.supportsQuality);
  final String displayName;
  final String extension;
  final bool supportsQuality;
}

/// Export quality presets
enum ExportQuality {
  low('Low (70%)', 0.7),
  medium('Medium (85%)', 0.85),
  high('High (95%)', 0.95),
  maximum('Maximum (100%)', 1.0),
  custom('Custom', 0.9);

  const ExportQuality(this.displayName, this.value);
  final String displayName;
  final double value;
}

/// Export size presets for social media and print
enum ExportSize {
  original('Original Size', 1.0),
  instagram('Instagram (1080×1080)', 1080 / 4000), // Assuming 4K original
  facebook('Facebook (2048×2048)', 2048 / 4000),
  twitter('Twitter (1200×1200)', 1200 / 4000),
  print4x6('Print 4×6" (1800×1200)', 1800 / 4000),
  print8x10('Print 8×10" (3000×2400)', 3000 / 4000),
  custom('Custom Size', 0.5);

  const ExportSize(this.displayName, this.scaleFactor);
  final String displayName;
  final double scaleFactor;
}

/// Professional export configuration
class ExportConfig {
  const ExportConfig({
    required this.format,
    required this.quality,
    required this.size,
    required this.preserveMetadata,
    required this.embedColorProfile,
    this.customQuality = 0.9,
    this.customWidth = 1920,
    this.customHeight = 1080,
  });

  final ExportFormat format;
  final ExportQuality quality;
  final ExportSize size;
  final bool preserveMetadata;
  final bool embedColorProfile;
  final double customQuality;
  final int customWidth;
  final int customHeight;

  ExportConfig copyWith({
    ExportFormat? format,
    ExportQuality? quality,
    ExportSize? size,
    bool? preserveMetadata,
    bool? embedColorProfile,
    double? customQuality,
    int? customWidth,
    int? customHeight,
  }) {
    return ExportConfig(
      format: format ?? this.format,
      quality: quality ?? this.quality,
      size: size ?? this.size,
      preserveMetadata: preserveMetadata ?? this.preserveMetadata,
      embedColorProfile: embedColorProfile ?? this.embedColorProfile,
      customQuality: customQuality ?? this.customQuality,
      customWidth: customWidth ?? this.customWidth,
      customHeight: customHeight ?? this.customHeight,
    );
  }
}

/// Professional export manager for mobile photo editing
class ExportManager {
  static const ExportManager _instance = ExportManager._internal();
  factory ExportManager() => _instance;
  const ExportManager._internal();

  /// Export image with professional configuration
  Future<ExportResult> exportImage({
    required ui.Image image,
    required ExportConfig config,
    String? filename,
  }) async {
    try {
      // Calculate final dimensions
      final originalWidth = image.width;
      final originalHeight = image.height;
      
      int finalWidth, finalHeight;
      
      if (config.size == ExportSize.custom) {
        finalWidth = config.customWidth;
        finalHeight = config.customHeight;
      } else if (config.size == ExportSize.original) {
        finalWidth = originalWidth;
        finalHeight = originalHeight;
      } else {
        final scaleFactor = config.size.scaleFactor.clamp(0.01, 10.0); // Prevent invalid scaling
        finalWidth = (originalWidth * scaleFactor).round().clamp(1, 16384); // Prevent 0 or huge sizes
        finalHeight = (originalHeight * scaleFactor).round().clamp(1, 16384); // Max 16K resolution
      }

      // Resize image if needed
      ui.Image finalImage = image;
      if (finalWidth != originalWidth || finalHeight != originalHeight) {
        finalImage = await _resizeImage(image, finalWidth, finalHeight);
      }

      // Convert to bytes based on format
      Uint8List bytes;
      switch (config.format) {
        case ExportFormat.jpeg:
          final quality = config.quality == ExportQuality.custom 
              ? config.customQuality 
              : config.quality.value;
          bytes = await _encodeImageAsJPEG(finalImage, quality);
          break;
        case ExportFormat.png:
          bytes = await _encodeImageAsPNG(finalImage);
          break;
        case ExportFormat.webp:
          final quality = config.quality == ExportQuality.custom 
              ? config.customQuality 
              : config.quality.value;
          bytes = await _encodeImageAsWebP(finalImage, quality);
          break;
        case ExportFormat.tiff:
          bytes = await _encodeImageAsTIFF(finalImage);
          break;
      }

      // Generate filename if not provided
      final exportFilename = filename ?? _generateFilename(config);

      // Create export result
      return ExportResult.success(
        bytes: bytes,
        filename: exportFilename,
        width: finalWidth,
        height: finalHeight,
        fileSize: bytes.length,
        config: config,
      );

    } catch (e) {
      return ExportResult.error(
        message: 'Export failed: ${e.toString()}',
        config: config,
      );
    }
  }

  /// Resize image to target dimensions
  Future<ui.Image> _resizeImage(ui.Image image, int width, int height) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    final paint = Paint()
      ..filterQuality = FilterQuality.high
      ..isAntiAlias = true;

    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      paint,
    );

    final picture = recorder.endRecording();
    return await picture.toImage(width, height);
  }

  /// Encode image as JPEG with quality
  Future<Uint8List> _encodeImageAsJPEG(ui.Image image, double quality) async {
    // Flutter's ui.Image doesn't support JPEG encoding directly
    // So we use PNG format but with proper error messaging
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception('Failed to encode image data');
    }
    
    // Note: This returns PNG data since Flutter doesn't support JPEG encoding
    // In production, you'd use packages like 'image' for proper JPEG encoding
    debugPrint('Warning: JPEG export returning PNG format due to Flutter limitations');
    return byteData.buffer.asUint8List();
  }

  /// Encode image as PNG
  Future<Uint8List> _encodeImageAsPNG(ui.Image image) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception('Failed to encode image data');
    }
    return byteData.buffer.asUint8List();
  }

  /// Encode image as WebP with quality
  Future<Uint8List> _encodeImageAsWebP(ui.Image image, double quality) async {
    // WebP encoding would require native implementation
    // For now, fallback to PNG
    return await _encodeImageAsPNG(image);
  }

  /// Encode image as TIFF
  Future<Uint8List> _encodeImageAsTIFF(ui.Image image) async {
    // TIFF encoding would require native implementation
    // For now, fallback to PNG
    return await _encodeImageAsPNG(image);
  }

  /// Generate filename based on export configuration
  String _generateFilename(ExportConfig config) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final formatName = config.format.displayName.toLowerCase();
    final sizeName = config.size.displayName.replaceAll(' ', '_').toLowerCase();
    return 'photo_${formatName}_${sizeName}_$timestamp.${config.format.extension}';
  }

  /// Get estimated file size before export
  int estimateFileSize({
    required int width,
    required int height,
    required ExportConfig config,
  }) {
    final pixelCount = width * height;
    
    switch (config.format) {
      case ExportFormat.jpeg:
        final quality = config.quality == ExportQuality.custom 
            ? config.customQuality 
            : config.quality.value;
        return (pixelCount * 3 * quality * 0.1).round(); // Rough estimate
      case ExportFormat.png:
        return (pixelCount * 4 * 1.2).round(); // RGBA with compression
      case ExportFormat.webp:
        final quality = config.quality == ExportQuality.custom 
            ? config.customQuality 
            : config.quality.value;
        return (pixelCount * 3 * quality * 0.08).round(); // Better compression
      case ExportFormat.tiff:
        return (pixelCount * 4 * 1.5).round(); // Uncompressed RGBA
    }
  }

  /// Get supported formats for device
  List<ExportFormat> getSupportedFormats() {
    return [
      ExportFormat.jpeg,
      ExportFormat.png,
      ExportFormat.webp, // May require native support
      // ExportFormat.tiff, // Uncomment when native support added
    ];
  }
}

/// Result of an export operation
class ExportResult {
  const ExportResult._({
    required this.isSuccess,
    required this.config,
    this.bytes,
    this.filename,
    this.width,
    this.height,
    this.fileSize,
    this.errorMessage,
  });

  final bool isSuccess;
  final ExportConfig config;
  final Uint8List? bytes;
  final String? filename;
  final int? width;
  final int? height;
  final int? fileSize;
  final String? errorMessage;

  factory ExportResult.success({
    required Uint8List bytes,
    required String filename,
    required int width,
    required int height,
    required int fileSize,
    required ExportConfig config,
  }) {
    return ExportResult._(
      isSuccess: true,
      config: config,
      bytes: bytes,
      filename: filename,
      width: width,
      height: height,
      fileSize: fileSize,
    );
  }

  factory ExportResult.error({
    required String message,
    required ExportConfig config,
  }) {
    return ExportResult._(
      isSuccess: false,
      config: config,
      errorMessage: message,
    );
  }

  String get fileSizeFormatted {
    if (fileSize == null) return 'Unknown';
    
    final size = fileSize!;
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}