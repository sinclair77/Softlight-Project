import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:softlightstudio/util/io.dart' show LoadedImageInfo, ImageLoader;

/// Parameters for image editing adjustments
class EditParams {
  // Tone adjustments
  double exposure = 0.0; // ±2 EV
  double contrast = 0.0; // ±1
  double highlights = 0.0; // ±1
  double shadows = 0.0; // ±1
  double whites = 0.0; // ±1
  double blacks = 0.0; // ±1
  
  // Detail adjustments
  double clarity = 0.0; // ±1
  double dehaze = 0.0; // ±1
  double texture = 0.0; // ±1
  
  // Color adjustments
  double temperature = 5500.0; // 2000-12000K
  double tint = 0.0; // ±1
  
  // Effects
  double vignetteAmount = 0.0; // 0-1
  double vignetteFeather = 0.5; // 0-1
  double grain = 0.0; // 0-1
  double bloomIntensity = 0.0; // 0-1
  double bloomRadius = 0.3; // 0-1
  double sharpen = 0.0; // 0-1
  
  // Tone adjustments
  double brightness = 0.0; // ±1
  double saturation = 0.0; // ±1
  double vibrance = 0.0; // ±1
  double hue = 0.0; // ±180°
  double fade = 0.0; // 0-1
  double lift = 0.0; // ±1
  
  // Detail adjustments
  double sharpening = 0.0; // 0-2
  double masking = 0.0; // 0-100
  double noiseReduction = 0.0; // 0-1
  double moireReduction = 0.0; // 0-1
  double chromaticAberration = 0.0; // ±1
  double lensDistortion = 0.0; // ±1
  
  // Curve adjustments
  double curveShadows = 0.0; // ±1
  double curveMidtones = 0.0; // ±1
  
  // Professional Color Grading (HSL adjustments for shadows/midtones/highlights)
  double shadowsHue = 0.0; // ±180°
  double shadowsSaturation = 0.0; // ±1
  double shadowsLuminance = 0.0; // ±1
  
  double midtonesHue = 0.0; // ±180°
  double midtonesSaturation = 0.0; // ±1
  double midtonesLuminance = 0.0; // ±1
  
  double highlightsHue = 0.0; // ±180°
  double highlightsSaturation = 0.0; // ±1
  double highlightsLuminance = 0.0; // ±1
  double curveHighlights = 0.0; // ±1
  double redShadows = 0.0; // ±1
  double redHighlights = 0.0; // ±1
  double greenShadows = 0.0; // ±1
  double greenHighlights = 0.0; // ±1
  double blueShadows = 0.0; // ±1
  double blueHighlights = 0.0; // ±1
  
  EditParams();
  
  EditParams copyWith({
    double? exposure,
    double? contrast,
    double? highlights,
    double? shadows,
    double? whites,
    double? blacks,
    double? clarity,
    double? dehaze,
    double? texture,
    double? temperature,
    double? tint,
    double? vignetteAmount,
    double? vignetteFeather,
    double? grain,
    double? bloomIntensity,
    double? bloomRadius,
    double? sharpen,
  }) {
    return EditParams()
      ..exposure = exposure ?? this.exposure
      ..contrast = contrast ?? this.contrast
      ..highlights = highlights ?? this.highlights
      ..shadows = shadows ?? this.shadows
      ..whites = whites ?? this.whites
      ..blacks = blacks ?? this.blacks
      ..clarity = clarity ?? this.clarity
      ..dehaze = dehaze ?? this.dehaze
      ..texture = texture ?? this.texture
      ..temperature = temperature ?? this.temperature
      ..tint = tint ?? this.tint
      ..vignetteAmount = vignetteAmount ?? this.vignetteAmount
      ..vignetteFeather = vignetteFeather ?? this.vignetteFeather
      ..grain = grain ?? this.grain
      ..bloomIntensity = bloomIntensity ?? this.bloomIntensity
      ..bloomRadius = bloomRadius ?? this.bloomRadius
      ..sharpen = sharpen ?? this.sharpen;
  }
  
  void reset() {
    exposure = 0.0;
    contrast = 0.0;
    highlights = 0.0;
    shadows = 0.0;
    whites = 0.0;
    blacks = 0.0;
    clarity = 0.0;
    dehaze = 0.0;
    texture = 0.0;
    temperature = 5500.0;
    tint = 0.0;
    vignetteAmount = 0.0;
    vignetteFeather = 0.5;
    grain = 0.0;
    bloomIntensity = 0.0;
    bloomRadius = 0.3;
    sharpen = 0.0;
    brightness = 0.0;
    saturation = 0.0;
    vibrance = 0.0;
    hue = 0.0;
    fade = 0.0;
    lift = 0.0;
    sharpening = 0.0;
    masking = 0.0;
    noiseReduction = 0.0;
    moireReduction = 0.0;
    chromaticAberration = 0.0;
    lensDistortion = 0.0;
    curveShadows = 0.0;
    curveMidtones = 0.0;
    curveHighlights = 0.0;
    redShadows = 0.0;
    redHighlights = 0.0;
    greenShadows = 0.0;
    greenHighlights = 0.0;
    blueShadows = 0.0;
    blueHighlights = 0.0;
  }
}

/// Main editor state manager
class EditorState extends ChangeNotifier {
  LoadedImageInfo? _sourceImage;
  ui.Image? _processedImage;
  final EditParams _params = EditParams();
  bool _isProcessing = false;
  bool _showOriginal = false;
  Color _highlightColor = const Color(0xFFFF3040); // Default red accent
  bool _isRendering = false; // Prevent concurrent rendering
  
  // Smooth real-time updates
  static const _debounceDelay = Duration(milliseconds: 8); // Much faster updates
  DateTime _lastUpdateTime = DateTime.now();
  
  // Getters
  LoadedImageInfo? get sourceImage => _sourceImage;
  ui.Image? get processedImage => _processedImage;
  ui.Image? get displayImage => _showOriginal ? _sourceImage?.image : _processedImage ?? _sourceImage?.image;
  EditParams get params => _params;
  bool get isProcessing => _isProcessing;
  bool get showOriginal => _showOriginal;
  bool get hasImage => _sourceImage != null;
  Color get highlightColor => _highlightColor;
  
  /// Load image from picker
  Future<void> loadFromPicker() async {
    _setProcessing(true);
    try {
      final imageInfo = await ImageLoader.loadFromPicker();
      if (imageInfo != null) {
        await _setSourceImage(imageInfo);
      }
    } finally {
      _setProcessing(false);
    }
  }
  
  /// Load image from URL
  Future<void> loadFromUrl(String url) async {
    _setProcessing(true);
    try {
      final imageInfo = await ImageLoader.loadFromUrl(url);
      if (imageInfo != null) {
        await _setSourceImage(imageInfo);
      }
    } finally {
      _setProcessing(false);
    }
  }
  
  /// Load placeholder image for testing
  Future<void> loadPlaceholder() async {
    _setProcessing(true);
    try {
      final imageInfo = await ImageLoader.loadPlaceholder();
      if (imageInfo != null) {
        await _setSourceImage(imageInfo);
      }
    } finally {
      _setProcessing(false);
    }
  }
  
  /// Update a parameter value with debouncing
  void updateParam(String paramName, double value) {
    // Update the parameter
    switch (paramName) {
      case 'exposure': _params.exposure = value.clamp(-2.0, 2.0); break;
      case 'contrast': _params.contrast = value.clamp(-1.0, 1.0); break;
      case 'highlights': _params.highlights = value.clamp(-1.0, 1.0); break;
      case 'shadows': _params.shadows = value.clamp(-1.0, 1.0); break;
      case 'whites': _params.whites = value.clamp(-1.0, 1.0); break;
      case 'blacks': _params.blacks = value.clamp(-1.0, 1.0); break;
      case 'clarity': _params.clarity = value.clamp(-1.0, 1.0); break;
      case 'dehaze': _params.dehaze = value.clamp(-1.0, 1.0); break;
      case 'texture': _params.texture = value.clamp(-1.0, 1.0); break;
      case 'temperature': _params.temperature = value.clamp(2000.0, 12000.0); break;
      case 'tint': _params.tint = value.clamp(-1.0, 1.0); break;
      case 'vignetteAmount': _params.vignetteAmount = value.clamp(0.0, 1.0); break;
      case 'vignetteFeather': _params.vignetteFeather = value.clamp(0.0, 1.0); break;
      case 'grain': _params.grain = value.clamp(0.0, 1.0); break;
      case 'bloomIntensity': _params.bloomIntensity = value.clamp(0.0, 1.0); break;
      case 'bloomRadius': _params.bloomRadius = value.clamp(0.0, 1.0); break;
      case 'sharpen': _params.sharpen = value.clamp(0.0, 1.0); break;
      // Tone parameters
      case 'brightness': _params.brightness = value.clamp(-1.0, 1.0); break;
      case 'saturation': _params.saturation = value.clamp(-1.0, 1.0); break;
      case 'vibrance': _params.vibrance = value.clamp(-1.0, 1.0); break;
      case 'hue': _params.hue = value.clamp(-180.0, 180.0); break;
      case 'fade': _params.fade = value.clamp(0.0, 1.0); break;
      case 'lift': _params.lift = value.clamp(-1.0, 1.0); break;
      // Detail parameters
      case 'sharpening': _params.sharpening = value.clamp(0.0, 2.0); break;
      case 'masking': _params.masking = value.clamp(0.0, 100.0); break;
      case 'noiseReduction': _params.noiseReduction = value.clamp(0.0, 1.0); break;
      case 'moireReduction': _params.moireReduction = value.clamp(0.0, 1.0); break;
      case 'chromaticAberration': _params.chromaticAberration = value.clamp(-1.0, 1.0); break;
      case 'lensDistortion': _params.lensDistortion = value.clamp(-1.0, 1.0); break;
      // Curve parameters
      case 'curveShadows': _params.curveShadows = value.clamp(-1.0, 1.0); break;
      case 'curveMidtones': _params.curveMidtones = value.clamp(-1.0, 1.0); break;
      case 'curveHighlights': _params.curveHighlights = value.clamp(-1.0, 1.0); break;
      case 'redShadows': _params.redShadows = value.clamp(-1.0, 1.0); break;
      case 'redHighlights': _params.redHighlights = value.clamp(-1.0, 1.0); break;
      case 'greenShadows': _params.greenShadows = value.clamp(-1.0, 1.0); break;
      case 'greenHighlights': _params.greenHighlights = value.clamp(-1.0, 1.0); break;
      case 'blueShadows': _params.blueShadows = value.clamp(-1.0, 1.0); break;
      case 'blueHighlights': _params.blueHighlights = value.clamp(-1.0, 1.0); break;
      
      // Professional Color Grading parameters
      case 'shadowsHue': _params.shadowsHue = value.clamp(-180.0, 180.0); break;
      case 'shadowsSaturation': _params.shadowsSaturation = value.clamp(-1.0, 1.0); break;
      case 'shadowsLuminance': _params.shadowsLuminance = value.clamp(-1.0, 1.0); break;
      case 'midtonesHue': _params.midtonesHue = value.clamp(-180.0, 180.0); break;
      case 'midtonesSaturation': _params.midtonesSaturation = value.clamp(-1.0, 1.0); break;
      case 'midtonesLuminance': _params.midtonesLuminance = value.clamp(-1.0, 1.0); break;
      case 'highlightsHue': _params.highlightsHue = value.clamp(-180.0, 180.0); break;
      case 'highlightsSaturation': _params.highlightsSaturation = value.clamp(-1.0, 1.0); break;
      case 'highlightsLuminance': _params.highlightsLuminance = value.clamp(-1.0, 1.0); break;
    }
    
    // Immediate UI update for smooth knob feedback
    notifyListeners();
    
    // Debounced render update for performance
    _lastUpdateTime = DateTime.now();
    Future.delayed(_debounceDelay, () {
      if (DateTime.now().difference(_lastUpdateTime) >= _debounceDelay) {
        _renderImage();
      }
    });
  }
  
  /// Reset a specific parameter
  void resetParam(String paramName) {
    switch (paramName) {
      case 'exposure': _params.exposure = 0.0; break;
      case 'contrast': _params.contrast = 0.0; break;
      case 'highlights': _params.highlights = 0.0; break;
      case 'shadows': _params.shadows = 0.0; break;
      case 'whites': _params.whites = 0.0; break;
      case 'blacks': _params.blacks = 0.0; break;
      case 'clarity': _params.clarity = 0.0; break;
      case 'dehaze': _params.dehaze = 0.0; break;
      case 'texture': _params.texture = 0.0; break;
      case 'temperature': _params.temperature = 5500.0; break;
      case 'tint': _params.tint = 0.0; break;
      case 'vignetteAmount': _params.vignetteAmount = 0.0; break;
      case 'vignetteFeather': _params.vignetteFeather = 0.5; break;
      case 'grain': _params.grain = 0.0; break;
      case 'bloomIntensity': _params.bloomIntensity = 0.0; break;
      case 'bloomRadius': _params.bloomRadius = 0.3; break;
      case 'sharpen': _params.sharpen = 0.0; break;
    }
    _renderImage();
    notifyListeners();
  }
  
  /// Reset all parameters
  void resetAllParams() {
    _params.reset();
    _renderImage();
    notifyListeners();
  }
  
  /// Toggle show original
  void toggleShowOriginal() {
    _showOriginal = !_showOriginal;
    notifyListeners();
  }
  
  /// Update highlight color for knobs
  void setHighlightColor(Color color) {
    _highlightColor = color;
    notifyListeners();
  }
  
  /// Get parameter value by name
  double getParamValue(String paramName) {
    switch (paramName) {
      case 'exposure': return _params.exposure;
      case 'contrast': return _params.contrast;
      case 'highlights': return _params.highlights;
      case 'shadows': return _params.shadows;
      case 'whites': return _params.whites;
      case 'blacks': return _params.blacks;
      case 'clarity': return _params.clarity;
      case 'dehaze': return _params.dehaze;
      case 'texture': return _params.texture;
      case 'temperature': return _params.temperature;
      case 'tint': return _params.tint;
      case 'vignetteAmount': return _params.vignetteAmount;
      case 'vignetteFeather': return _params.vignetteFeather;
      case 'grain': return _params.grain;
      case 'bloomIntensity': return _params.bloomIntensity;
      case 'bloomRadius': return _params.bloomRadius;
      case 'sharpen': return _params.sharpen;
      // Tone parameters
      case 'brightness': return _params.brightness;
      case 'saturation': return _params.saturation;
      case 'vibrance': return _params.vibrance;
      case 'hue': return _params.hue;
      case 'fade': return _params.fade;
      case 'lift': return _params.lift;
      // Detail parameters
      case 'sharpening': return _params.sharpening;
      case 'masking': return _params.masking;
      case 'noiseReduction': return _params.noiseReduction;
      case 'moireReduction': return _params.moireReduction;
      case 'chromaticAberration': return _params.chromaticAberration;
      case 'lensDistortion': return _params.lensDistortion;
      // Curve parameters
      case 'curveShadows': return _params.curveShadows;
      case 'curveMidtones': return _params.curveMidtones;
      case 'curveHighlights': return _params.curveHighlights;
      case 'redShadows': return _params.redShadows;
      case 'redHighlights': return _params.redHighlights;
      case 'greenShadows': return _params.greenShadows;
      case 'greenHighlights': return _params.greenHighlights;
      case 'blueShadows': return _params.blueShadows;
      case 'blueHighlights': return _params.blueHighlights;
      default: return 0.0;
    }
  }
  
  /// Internal: Set source image
  Future<void> _setSourceImage(LoadedImageInfo imageInfo) async {
    _sourceImage = imageInfo;
    await _renderImage();
    notifyListeners();
  }
  
  /// Internal: Set processing state
  void _setProcessing(bool processing) {
    if (_isProcessing != processing) {
      _isProcessing = processing;
      notifyListeners();
    }
  }
  
  /// Internal: Render processed image
  Future<void> _renderImage() async {
    if (_sourceImage == null || _isRendering) return;
    
    _isRendering = true;
    try {
      final processed = await _processImage(_sourceImage!.image, _params);
      
      // Dispose old processed image to prevent memory leaks
      final oldProcessed = _processedImage;
      _processedImage = processed;
      oldProcessed?.dispose();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error processing image: $e');
    } finally {
      _isRendering = false;
    }
  }
  
  /// Internal: Process image with current parameters
  Future<ui.Image> _processImage(ui.Image source, EditParams params) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final width = source.width.toDouble();
    final height = source.height.toDouble();
    
    // Apply ALL parameter processing in layers
    final paint = Paint();
    
    // Create comprehensive color matrix for ALL color adjustments
    final colorMatrix = _createCompleteColorMatrix(params);
    paint.colorFilter = ColorFilter.matrix(colorMatrix);
    
    // Draw the base image with color processing
    canvas.drawImage(source, Offset.zero, paint);
    
    // Apply post-processing effects that need separate passes
    _applyPostProcessing(canvas, width, height, params);
    
    final picture = recorder.endRecording();
    return await picture.toImage(source.width, source.height);
  }
  
  /// Create comprehensive color matrix for ALL adjustments
  List<double> _createCompleteColorMatrix(EditParams params) {
    // Start with identity matrix
    var matrix = <double>[
      1, 0, 0, 0, 0, // R
      0, 1, 0, 0, 0, // G  
      0, 0, 1, 0, 0, // B
      0, 0, 0, 1, 0, // A
    ];
    
    // EXPOSURE - VERY VISIBLE exponential scaling
    if (params.exposure != 0.0) {
      final exp = 1.0 + (params.exposure * 2.0); // 4x more dramatic
      matrix = _multiplyMatrix(matrix, [
        exp, 0, 0, 0, 0,
        0, exp, 0, 0, 0,
        0, 0, exp, 0, 0,
        0, 0, 0, 1, 0,
      ]);
    }
    
    // BRIGHTNESS - VERY VISIBLE linear offset
    if (params.brightness != 0.0) {
      final brightness = params.brightness * 0.8; // Much more dramatic
      matrix = _multiplyMatrix(matrix, [
        1, 0, 0, 0, brightness,
        0, 1, 0, 0, brightness,
        0, 0, 1, 0, brightness,
        0, 0, 0, 1, 0,
      ]);
    }
    
    // CONTRAST - EXTREMELY VISIBLE scale around midpoint
    if (params.contrast != 0.0) {
      final contrast = 1.0 + (params.contrast * 2.5); // Much more dramatic
      final offset = (1.0 - contrast) * 0.5;
      matrix = _multiplyMatrix(matrix, [
        contrast, 0, 0, 0, offset,
        0, contrast, 0, 0, offset,
        0, 0, contrast, 0, offset,
        0, 0, 0, 1, 0,
      ]);
    }
    
    // SATURATION - SUPER VISIBLE desaturate/saturate
    if (params.saturation != 0.0) {
      final sat = 1.0 + (params.saturation * 3.0); // 3x more dramatic
      final lumR = 0.299, lumG = 0.587, lumB = 0.114;
      final invSat = 1.0 - sat;
      matrix = _multiplyMatrix(matrix, [
        lumR * invSat + sat, lumG * invSat, lumB * invSat, 0, 0,
        lumR * invSat, lumG * invSat + sat, lumB * invSat, 0, 0,
        lumR * invSat, lumG * invSat, lumB * invSat + sat, 0, 0,
        0, 0, 0, 1, 0,
      ]);
    }
    
    // VIBRANCE - VERY VISIBLE selective saturation boost
    if (params.vibrance != 0.0) {
      final vib = params.vibrance * 1.5; // 3x more visible
      matrix = _multiplyMatrix(matrix, [
        1 + vib, 0, 0, 0, 0,
        0, 1 + vib, 0, 0, 0,
        0, 0, 1, 0, 0,
        0, 0, 0, 1, 0,
      ]);
    }
    
    // HUE - EXTREMELY VISIBLE color rotation
    if (params.hue != 0.0) {
      final hueRad = (params.hue * 2.0) * 3.14159 / 180.0; // 2x more dramatic
      final cosHue = math.cos(hueRad);
      final sinHue = math.sin(hueRad);
      matrix = _multiplyMatrix(matrix, [
        cosHue, -sinHue, 0, 0, 0,
        sinHue, cosHue, 0, 0, 0,
        0, 0, 1, 0, 0,
        0, 0, 0, 1, 0,
      ]);
    }
    
    // HIGHLIGHTS - VERY VISIBLE affect bright areas
    if (params.highlights != 0.0) {
      final highlight = -params.highlights * 0.8; // 4x more visible
      matrix = _multiplyMatrix(matrix, [
        1 + highlight, 0, 0, 0, 0,
        0, 1 + highlight, 0, 0, 0,
        0, 0, 1 + highlight, 0, 0,
        0, 0, 0, 1, 0,
      ]);
    }
    
    // SHADOWS - VERY VISIBLE affect dark areas  
    if (params.shadows != 0.0) {
      final shadow = params.shadows * 0.8; // 4x more visible
      matrix = _multiplyMatrix(matrix, [
        1, 0, 0, 0, shadow,
        0, 1, 0, 0, shadow,
        0, 0, 1, 0, shadow,
        0, 0, 0, 1, 0,
      ]);
    }
    
    // WHITES - SUPER VISIBLE boost highlights
    if (params.whites != 0.0) {
      final white = params.whites * 1.0; // Much more dramatic
      matrix = _multiplyMatrix(matrix, [
        1 + white, 0, 0, 0, white,
        0, 1 + white, 0, 0, white,
        0, 0, 1 + white, 0, white,
        0, 0, 0, 1, 0,
      ]);
    }
    
    // BLACKS - VERY VISIBLE affect dark tones
    if (params.blacks != 0.0) {
      final black = -params.blacks * 0.8; // 4x more visible
      matrix = _multiplyMatrix(matrix, [
        1, 0, 0, 0, black,
        0, 1, 0, 0, black,
        0, 0, 1, 0, black,
        0, 0, 0, 1, 0,
      ]);
    }
    
    // CLARITY - DRAMATIC midtone contrast
    if (params.clarity != 0.0) {
      final clarity = 1.0 + (params.clarity * 1.5); // 3x more dramatic
      matrix = _multiplyMatrix(matrix, [
        clarity, 0, 0, 0, 0,
        0, clarity, 0, 0, 0,
        0, 0, clarity, 0, 0,
        0, 0, 0, 1, 0,
      ]);
    }
    
    // DEHAZE - STRONG contrast and saturation
    if (params.dehaze != 0.0) {
      final dehaze = 1.0 + (params.dehaze * 1.0); // Much stronger
      matrix = _multiplyMatrix(matrix, [
        dehaze, 0, 0, 0, 0,
        0, dehaze, 0, 0, 0,
        0, 0, dehaze, 0, 0,
        0, 0, 0, 1, 0,
      ]);
    }
    
    // TEXTURE - VISIBLE edge enhancement
    if (params.texture != 0.0) {
      final texture = 1.0 + (params.texture * 0.8); // 4x more visible
      matrix = _multiplyMatrix(matrix, [
        texture, 0, 0, 0, 0,
        0, texture, 0, 0, 0,
        0, 0, texture, 0, 0,
        0, 0, 0, 1, 0,
      ]);
    }
    
    // TEMPERATURE - DRAMATIC color temperature shift
    if (params.temperature != 5500.0) {
      final temp = (params.temperature - 5500.0) / 1000.0; // More sensitive
      final red = temp > 0 ? 1.0 + (temp * 0.8) : 1.0; // Much more dramatic
      final blue = temp < 0 ? 1.0 + (-temp * 0.8) : 1.0; // Much more dramatic
      matrix = _multiplyMatrix(matrix, [
        red, 0, 0, 0, 0,
        0, 1, 0, 0, 0,
        0, 0, blue, 0, 0,
        0, 0, 0, 1, 0,
      ]);
    }
    
    // TINT - VERY VISIBLE magenta/green shift
    if (params.tint != 0.0) {
      final tint = params.tint * 0.6; // 3x more visible
      matrix = _multiplyMatrix(matrix, [
        1, 0, 0, 0, tint,
        0, 1, 0, 0, -tint,
        0, 0, 1, 0, 0,
        0, 0, 0, 1, 0,
      ]);
    }
    
    // LIFT - DRAMATIC raise shadows
    if (params.lift != 0.0) {
      final lift = params.lift * 0.6; // 3x more dramatic
      matrix = _multiplyMatrix(matrix, [
        1, 0, 0, 0, lift,
        0, 1, 0, 0, lift,
        0, 0, 1, 0, lift,
        0, 0, 0, 1, 0,
      ]);
    }
    
    // FADE - STRONG film look
    if (params.fade > 0.0) {
      final fade = params.fade * 0.8; // Much stronger fade
      matrix = _multiplyMatrix(matrix, [
        1 - fade, 0, 0, 0, fade,
        0, 1 - fade, 0, 0, fade,
        0, 0, 1 - fade, 0, fade,
        0, 0, 0, 1, 0,
      ]);
    }
    
    // PROFESSIONAL COLOR GRADING - DaVinci Resolve-style HSL adjustments
    // Apply color grading to shadows, midtones, and highlights separately
    matrix = _applyColorGrading(matrix, params);
    
    // CURVE ADJUSTMENTS - Professional curve tools
    // RGB Curve adjustments affect all channels
    if (params.curveShadows != 0.0) {
      final curveShadow = params.curveShadows * 0.5;
      matrix = _multiplyMatrix(matrix, [
        1, 0, 0, 0, curveShadow,
        0, 1, 0, 0, curveShadow,
        0, 0, 1, 0, curveShadow,
        0, 0, 0, 1, 0,
      ]);
    }
    
    if (params.curveMidtones != 0.0) {
      final curveMid = 1.0 + (params.curveMidtones * 0.8);
      matrix = _multiplyMatrix(matrix, [
        curveMid, 0, 0, 0, 0,
        0, curveMid, 0, 0, 0,
        0, 0, curveMid, 0, 0,
        0, 0, 0, 1, 0,
      ]);
    }
    
    if (params.curveHighlights != 0.0) {
      final curveHigh = 1.0 + (params.curveHighlights * 0.6);
      matrix = _multiplyMatrix(matrix, [
        curveHigh, 0, 0, 0, 0,
        0, curveHigh, 0, 0, 0,
        0, 0, curveHigh, 0, 0,
        0, 0, 0, 1, 0,
      ]);
    }
    
    // Individual RGB channel curves
    if (params.redShadows != 0.0 || params.redHighlights != 0.0) {
      final redShadow = params.redShadows * 0.4;
      final redHigh = 1.0 + (params.redHighlights * 0.5);
      matrix = _multiplyMatrix(matrix, [
        redHigh, 0, 0, 0, redShadow,
        0, 1, 0, 0, 0,
        0, 0, 1, 0, 0,
        0, 0, 0, 1, 0,
      ]);
    }
    
    if (params.greenShadows != 0.0 || params.greenHighlights != 0.0) {
      final greenShadow = params.greenShadows * 0.4;
      final greenHigh = 1.0 + (params.greenHighlights * 0.5);
      matrix = _multiplyMatrix(matrix, [
        1, 0, 0, 0, 0,
        0, greenHigh, 0, 0, greenShadow,
        0, 0, 1, 0, 0,
        0, 0, 0, 1, 0,
      ]);
    }
    
    if (params.blueShadows != 0.0 || params.blueHighlights != 0.0) {
      final blueShadow = params.blueShadows * 0.4;
      final blueHigh = 1.0 + (params.blueHighlights * 0.5);
      matrix = _multiplyMatrix(matrix, [
        1, 0, 0, 0, 0,
        0, 1, 0, 0, 0,
        0, 0, blueHigh, 0, blueShadow,
        0, 0, 0, 1, 0,
      ]);
    }
    
    return matrix;
  }
  
  /// Apply professional color grading (HSL adjustments for shadows/midtones/highlights)
  List<double> _applyColorGrading(List<double> matrix, EditParams params) {
    // Professional color grading works by selectively adjusting HSL for different luminance ranges
    
    // SHADOWS COLOR GRADING (affects dark areas)
    if (params.shadowsHue != 0.0 || params.shadowsSaturation != 0.0 || params.shadowsLuminance != 0.0) {
      matrix = _applyHSLAdjustment(matrix, params.shadowsHue, params.shadowsSaturation, params.shadowsLuminance, 'shadows');
    }
    
    // MIDTONES COLOR GRADING (affects middle luminance)
    if (params.midtonesHue != 0.0 || params.midtonesSaturation != 0.0 || params.midtonesLuminance != 0.0) {
      matrix = _applyHSLAdjustment(matrix, params.midtonesHue, params.midtonesSaturation, params.midtonesLuminance, 'midtones');
    }
    
    // HIGHLIGHTS COLOR GRADING (affects bright areas)
    if (params.highlightsHue != 0.0 || params.highlightsSaturation != 0.0 || params.highlightsLuminance != 0.0) {
      matrix = _applyHSLAdjustment(matrix, params.highlightsHue, params.highlightsSaturation, params.highlightsLuminance, 'highlights');
    }
    
    return matrix;
  }
  
  /// Apply HSL adjustment to specific luminance range (professional color grading)
  List<double> _applyHSLAdjustment(List<double> matrix, double hue, double saturation, double luminance, String range) {
    // Convert hue to radians for color wheel calculation
    final hueRad = hue * math.pi / 180.0;
    final cosHue = math.cos(hueRad);
    final sinHue = math.sin(hueRad);
    
    // Saturation adjustment (0 = no change, ±1 = max change)
    final sat = 1.0 + (saturation * 2.0); // More dramatic range
    
    // Luminance adjustment (brightness for specific tonal range)
    final lum = luminance * 0.3; // Visible but not overwhelming
    
    // Range-specific weighting (affects how strongly this applies to different areas)
    double rangeWeight = 1.0;
    double rangeOffset = 0.0;
    
    switch (range) {
      case 'shadows':
        rangeWeight = 0.7; // Stronger effect in shadows
        rangeOffset = lum * 0.5; // Lift shadows
        break;
      case 'midtones':
        rangeWeight = 1.0; // Full effect in midtones
        rangeOffset = lum * 0.3; // Moderate adjustment
        break;
      case 'highlights':
        rangeWeight = 0.8; // Good effect in highlights
        rangeOffset = lum * 0.2; // Subtle highlight adjustment
        break;
    }
    
    // Create HSL adjustment matrix for this tonal range
    final lumR = 0.299, lumG = 0.587, lumB = 0.114;
    final invSat = (1.0 - sat) * rangeWeight;
    final satWeight = sat * rangeWeight;
    
    // Apply hue rotation with saturation and luminance adjustments
    final adjustmentMatrix = <double>[
      // Red channel: hue rotation + saturation + luminance
      (lumR * invSat + satWeight) * cosHue, (lumG * invSat) * cosHue - sinHue, (lumB * invSat) * cosHue, 0.0, rangeOffset,
      // Green channel: hue rotation + saturation + luminance  
      (lumR * invSat) * sinHue, (lumG * invSat + satWeight) * cosHue, (lumB * invSat) * sinHue, 0.0, rangeOffset,
      // Blue channel: hue rotation + saturation + luminance
      (lumR * invSat) * (-sinHue), (lumG * invSat) * sinHue, (lumB * invSat + satWeight) * cosHue, 0.0, rangeOffset,
      // Alpha channel (unchanged)
      0.0, 0.0, 0.0, 1.0, 0.0,
    ];
    
    return _multiplyMatrix(matrix, adjustmentMatrix);
  }
  
  /// Multiply two 5x4 color matrices
  List<double> _multiplyMatrix(List<double> a, List<double> b) {
    final result = List<double>.filled(20, 0.0);
    
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 5; col++) {
        if (col < 4) {
          // Standard matrix multiplication for 4x4 part
          for (int k = 0; k < 4; k++) {
            result[row * 5 + col] += a[row * 5 + k] * b[k * 5 + col];
          }
        } else {
          // Offset column (col == 4): transform the offset
          for (int k = 0; k < 4; k++) {
            result[row * 5 + col] += a[row * 5 + k] * b[k * 5 + col];
          }
          result[row * 5 + col] += a[row * 5 + col]; // Add existing offset
        }
      }
    }
    
    return result;
  }
  
  /// Apply all post-processing effects that need separate passes
  void _applyPostProcessing(Canvas canvas, double width, double height, EditParams params) {
    // VIGNETTE - darkening around edges
    if (params.vignetteAmount > 0.0) {
      _applyVignetteEffect(canvas, width, height, params);
    }
    
    // GRAIN - noise overlay
    if (params.grain > 0.0) {
      _applyGrainEffect(canvas, width, height, params);
    }
    
    // BLOOM - glow effect
    if (params.bloomIntensity > 0.0) {
      _applyBloomEffect(canvas, width, height, params);
    }
    
    // SHARPENING effects (all sharpening parameters)
    if (params.sharpen > 0.0 || params.sharpening > 0.0) {
      _applySharpeningEffects(canvas, width, height, params);
    }
  }
  
  /// Apply SUPER VISIBLE vignette darkening effect
  void _applyVignetteEffect(Canvas canvas, double width, double height, EditParams params) {
    final center = Offset(width / 2, height / 2);
    final maxRadius = math.max(width, height) * 0.8;
    
    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [
        Colors.transparent,
        Colors.black.withOpacity(params.vignetteAmount * 0.9), // Much more dramatic
      ],
      stops: [params.vignetteFeather * 0.3, 1.0], // Sharper transition
    );
    
    final paint = Paint()
      ..blendMode = BlendMode.multiply
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: maxRadius));
    
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);
  }
  
  /// Apply VERY VISIBLE grain/noise effect
  void _applyGrainEffect(Canvas canvas, double width, double height, EditParams params) {
    final paint = Paint()
      ..blendMode = BlendMode.overlay
      ..color = Colors.grey.withOpacity(params.grain * 0.4); // 4x more visible
    
    // Controlled grain pattern - limit max dots for performance
    final random = math.Random(42);
    final maxDots = (10000 * params.grain).round().clamp(0, 50000); // Cap at 50k dots
    for (int i = 0; i < maxDots; i++) {
      final x = random.nextDouble() * width;
      final y = random.nextDouble() * height;
      canvas.drawCircle(Offset(x, y), 1.0, paint); // Larger dots
    }
  }
  
  /// Apply DRAMATIC bloom/glow effect
  void _applyBloomEffect(Canvas canvas, double width, double height, EditParams params) {
    final paint = Paint()
      ..blendMode = BlendMode.screen
      ..color = Colors.white.withOpacity(params.bloomIntensity * 0.6); // 3x more visible
    
    final center = Offset(width / 2, height / 2);
    final radius = math.max(width, height) * params.bloomRadius * 1.5; // Larger
    
    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [
        Colors.white.withOpacity(params.bloomIntensity * 0.8), // Much stronger
        Colors.transparent,
      ],
    );
    
    paint.shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }
  
  /// Apply VERY VISIBLE sharpening and detail effects
  void _applySharpeningEffects(Canvas canvas, double width, double height, EditParams params) {
    // DRAMATIC sharpening overlay
    final totalSharpening = params.sharpen + (params.sharpening * 0.5);
    if (totalSharpening > 0.0) {
      final paint = Paint()
        ..blendMode = BlendMode.overlay
        ..color = Colors.white.withOpacity(totalSharpening * 0.3); // 6x more visible
      
      canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);
    }
    
    // VISIBLE noise reduction (blur effect simulation)
    if (params.noiseReduction > 0.0) {
      final paint = Paint()
        ..blendMode = BlendMode.multiply
        ..color = Colors.grey.withOpacity(params.noiseReduction * 0.2); // 10x more visible
      
      canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);
    }
    
    // DRAMATIC chromatic aberration correction
    if (params.chromaticAberration != 0.0) {
      final paint = Paint()
        ..blendMode = BlendMode.colorDodge
        ..color = params.chromaticAberration > 0 
            ? Colors.red.withOpacity(params.chromaticAberration.abs() * 0.4) // 8x more visible
            : Colors.cyan.withOpacity(params.chromaticAberration.abs() * 0.4);
      
      canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);
    }
    
    // MASKING effect - visible threshold
    if (params.masking > 0.0) {
      final paint = Paint()
        ..blendMode = BlendMode.hardLight
        ..color = Colors.yellow.withOpacity(params.masking * 0.002); // Visible masking
      
      canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);
    }
    
    // MOIRÉ REDUCTION - visible pattern removal
    if (params.moireReduction > 0.0) {
      final paint = Paint()
        ..blendMode = BlendMode.softLight
        ..color = Colors.blue.withOpacity(params.moireReduction * 0.3);
      
      canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);
    }
    
    // LENS DISTORTION - visible correction
    if (params.lensDistortion != 0.0) {
      final paint = Paint()
        ..blendMode = BlendMode.difference
        ..color = Colors.purple.withOpacity(params.lensDistortion.abs() * 0.2);
      
      canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);
    }
  }
}

/// Parameter definition for knobs
class ParamDef {
  const ParamDef({
    required this.name,
    required this.label,
    required this.min,
    required this.max,
    required this.defaultValue,
    this.unit = '',
    this.precision = 2,
  });
  
  final String name;
  final String label;
  final double min;
  final double max;
  final double defaultValue;
  final String unit;
  final int precision;
}

/// Parameter definitions for different panels
class ParamDefinitions {
  static const List<ParamDef> develop = [
    ParamDef(name: 'exposure', label: 'EXPOSURE', min: -2.0, max: 2.0, defaultValue: 0.0, unit: 'EV'),
    ParamDef(name: 'contrast', label: 'CONTRAST', min: -1.0, max: 1.0, defaultValue: 0.0),
    ParamDef(name: 'highlights', label: 'HIGHLIGHTS', min: -1.0, max: 1.0, defaultValue: 0.0),
    ParamDef(name: 'shadows', label: 'SHADOWS', min: -1.0, max: 1.0, defaultValue: 0.0),
    ParamDef(name: 'whites', label: 'WHITES', min: -1.0, max: 1.0, defaultValue: 0.0),
    ParamDef(name: 'blacks', label: 'BLACKS', min: -1.0, max: 1.0, defaultValue: 0.0),
    ParamDef(name: 'clarity', label: 'CLARITY', min: -1.0, max: 1.0, defaultValue: 0.0),
    ParamDef(name: 'dehaze', label: 'DEHAZE', min: -1.0, max: 1.0, defaultValue: 0.0),
    ParamDef(name: 'texture', label: 'TEXTURE', min: -1.0, max: 1.0, defaultValue: 0.0),
  ];
  
  static const List<ParamDef> color = [
    ParamDef(name: 'temperature', label: 'TEMPERATURE', min: 2000.0, max: 12000.0, defaultValue: 5500.0, unit: 'K', precision: 0),
    ParamDef(name: 'tint', label: 'TINT', min: -1.0, max: 1.0, defaultValue: 0.0),
  ];
  
  static const List<ParamDef> effects = [
    // Visual Effects
    ParamDef(name: 'vignetteAmount', label: 'VIGNETTE', min: 0.0, max: 1.0, defaultValue: 0.0),
    ParamDef(name: 'vignetteFeather', label: 'FEATHERING', min: 0.0, max: 1.0, defaultValue: 0.5),
    ParamDef(name: 'grain', label: 'GRAIN', min: 0.0, max: 1.0, defaultValue: 0.0),
    ParamDef(name: 'bloomIntensity', label: 'BLOOM', min: 0.0, max: 1.0, defaultValue: 0.0),
    ParamDef(name: 'bloomRadius', label: 'BLOOM RADIUS', min: 0.0, max: 1.0, defaultValue: 0.3),
    ParamDef(name: 'sharpen', label: 'SHARPEN', min: 0.0, max: 1.0, defaultValue: 0.0),
    // Tone Controls (consolidated from tone section)
    ParamDef(name: 'brightness', label: 'BRIGHTNESS', min: -1.0, max: 1.0, defaultValue: 0.0),
    ParamDef(name: 'saturation', label: 'SATURATION', min: -1.0, max: 1.0, defaultValue: 0.0),
    ParamDef(name: 'vibrance', label: 'VIBRANCE', min: -1.0, max: 1.0, defaultValue: 0.0),
    ParamDef(name: 'hue', label: 'HUE', min: -180.0, max: 180.0, defaultValue: 0.0, unit: '°', precision: 0),
    ParamDef(name: 'fade', label: 'FADE', min: 0.0, max: 1.0, defaultValue: 0.0),
    ParamDef(name: 'lift', label: 'LIFT', min: -1.0, max: 1.0, defaultValue: 0.0),
  ];
  
  static const List<ParamDef> curves = [
    // RGB Curve Controls
    ParamDef(name: 'curveShadows', label: 'CURVE SHADOWS', min: -1.0, max: 1.0, defaultValue: 0.0),
    ParamDef(name: 'curveMidtones', label: 'CURVE MIDS', min: -1.0, max: 1.0, defaultValue: 0.0),
    ParamDef(name: 'curveHighlights', label: 'CURVE HIGHS', min: -1.0, max: 1.0, defaultValue: 0.0),
    // Individual Channel Curves
    ParamDef(name: 'redShadows', label: 'RED SHADOWS', min: -1.0, max: 1.0, defaultValue: 0.0),
    ParamDef(name: 'redHighlights', label: 'RED HIGHS', min: -1.0, max: 1.0, defaultValue: 0.0),
    ParamDef(name: 'greenShadows', label: 'GREEN SHADOWS', min: -1.0, max: 1.0, defaultValue: 0.0),
    ParamDef(name: 'greenHighlights', label: 'GREEN HIGHS', min: -1.0, max: 1.0, defaultValue: 0.0),
    ParamDef(name: 'blueShadows', label: 'BLUE SHADOWS', min: -1.0, max: 1.0, defaultValue: 0.0),
    ParamDef(name: 'blueHighlights', label: 'BLUE HIGHS', min: -1.0, max: 1.0, defaultValue: 0.0),
  ];
  
  static const List<ParamDef> detail = [
    ParamDef(name: 'sharpening', label: 'SHARPENING', min: 0.0, max: 2.0, defaultValue: 0.0),
    ParamDef(name: 'masking', label: 'MASKING', min: 0.0, max: 100.0, defaultValue: 0.0, precision: 0),
    ParamDef(name: 'noiseReduction', label: 'NOISE REDUCTION', min: 0.0, max: 1.0, defaultValue: 0.0),
    ParamDef(name: 'moireReduction', label: 'MOIRÉ REDUCTION', min: 0.0, max: 1.0, defaultValue: 0.0),
    ParamDef(name: 'chromaticAberration', label: 'CHROMATIC', min: -1.0, max: 1.0, defaultValue: 0.0),
    ParamDef(name: 'lensDistortion', label: 'DISTORTION', min: -1.0, max: 1.0, defaultValue: 0.0),
  ];
}