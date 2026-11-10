part of '../miuix_widgets.dart';

/// Most recent static-squircle resource error, exposed for diagnostics/tests.
///
/// A null value means either resources loaded or the loader has not run yet.
Object? debugMiuixSquircleLastLoadError;

TargetPlatform? _miuixSquircleResourcePlatform;
Future<_MiuixSquircleShaderResources?>? _miuixSquircleResourcesFuture;
_MiuixSquircleShaderResources? _miuixSquircleLoadedResources;

Future<_MiuixSquircleShaderResources?> _miuixSquircleResources() {
  final platform = defaultTargetPlatform;
  if (_miuixSquircleResourcePlatform != platform) {
    _miuixSquircleResourcePlatform = platform;
    _miuixSquircleResourcesFuture = null;
    _miuixSquircleLoadedResources = null;
  }
  final loaded = _miuixSquircleLoadedResources;
  if (loaded != null) return Future.value(loaded);
  return _miuixSquircleResourcesFuture ??= _MiuixSquircleShaderResources.load()
      .then((resources) {
        if (_miuixSquircleResourcePlatform == platform) {
          _miuixSquircleLoadedResources = resources;
        }
        return resources;
      });
}

/// Preloads the static squircle SDF before an application's first frame.
///
/// Returns false when the current platform follows the upstream rounded-rect
/// fallback or when the shader backend cannot load. Applications may safely
/// ignore the result; awaiting it avoids a rounded-to-squircle first-frame
/// transition on supported platforms.
Future<bool> preloadMiuixSquircleShader() async {
  return await _miuixSquircleResources() != null;
}

/// A fill-and-clip surface backed by MIUIX's current baked squircle SDF.
///
/// The source uses this rendering path for Card, Button, IconButton, Dialog,
/// and other static continuous-corner containers. Android enables it from API
/// 33, matching AGSL availability upstream; Windows enables it through the
/// Flutter runtime-shader backend. Any load failure falls back to the source's
/// ordinary rounded rectangle rather than inventing a third silhouette.
class MiuixSquircleSurface extends StatefulWidget {
  /// Creates a source-equivalent static squircle surface.
  const MiuixSquircleSurface({
    super.key,
    required this.child,
    required this.color,
    required this.borderRadius,
    this.enabled = true,
  });

  /// Content painted above the fill and inside the mask.
  final Widget child;

  /// Color painted behind [child].
  final Color color;

  /// Per-corner source radius before MIUIX's 1.1 tile extension.
  final BorderRadius borderRadius;

  /// Whether the current MIUIX theme enables continuous corners.
  final bool enabled;

  @override
  State<MiuixSquircleSurface> createState() => _MiuixSquircleSurfaceState();
}

/// Paints a static MIUIX squircle behind content without clipping that content.
///
/// Upstream `squircleBackground` is a draw-behind modifier, unlike
/// `squircleSurface`, which masks both fill and content. Tabs, text fields,
/// tooltips, snackbars, and floating navigation use this non-clipping form so
/// icons, focus rings, and popup arrows may paint outside the filled outline.
class MiuixSquircleBackground extends StatefulWidget {
  /// Creates a source-equivalent draw-behind squircle.
  const MiuixSquircleBackground({
    super.key,
    required this.child,
    required this.color,
    required this.borderRadius,
    this.enabled = true,
  });

  /// Content painted after the background mask is complete.
  final Widget child;

  /// Background fill.
  final Color color;

  /// Per-corner source radius.
  final BorderRadius borderRadius;

  /// Whether the current theme enables the SDF path.
  final bool enabled;

  @override
  State<MiuixSquircleBackground> createState() =>
      _MiuixSquircleBackgroundState();
}

class _MiuixSquircleBackgroundState extends State<MiuixSquircleBackground> {
  _MiuixSquircleShaderResources? _resources;

  @override
  void initState() {
    super.initState();
    _resources = _miuixSquircleLoadedResources;
    if (_resources == null) _ensureResources();
  }

  Future<void> _ensureResources() async {
    if (!widget.enabled) return;
    final resources = await _miuixSquircleResources();
    if (!mounted || resources == null) return;
    setState(() => _resources = resources);
  }

  @override
  void didUpdateWidget(covariant MiuixSquircleBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.enabled && widget.enabled && _resources == null) {
      _ensureResources();
    }
  }

  @override
  Widget build(BuildContext context) {
    final resources = _resources;
    if (!widget.enabled || resources == null) {
      return DecoratedBox(
        key: const ValueKey('miuix-squircle-background-rounded-fallback'),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: widget.borderRadius,
        ),
        child: widget.child,
      );
    }
    return _MiuixSdfSurfaceRenderWidget(
      key: const ValueKey('miuix-squircle-sdf-background'),
      program: resources.program,
      sdfImage: resources.sdfImage,
      color: widget.color,
      borderRadius: widget.borderRadius,
      textDirection: Directionality.of(context),
      pixelRatio: MediaQuery.devicePixelRatioOf(context),
      clipChild: false,
      child: widget.child,
    );
  }
}

class _MiuixSquircleSurfaceState extends State<MiuixSquircleSurface> {
  _MiuixSquircleShaderResources? _resources;

  @override
  void initState() {
    super.initState();
    _resources = _miuixSquircleLoadedResources;
    if (_resources == null) _ensureResources();
  }

  Future<void> _ensureResources() async {
    if (!widget.enabled) return;
    final resources = await _miuixSquircleResources();
    if (!mounted || resources == null) return;
    setState(() => _resources = resources);
  }

  @override
  void didUpdateWidget(covariant MiuixSquircleSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.enabled && widget.enabled && _resources == null) {
      _ensureResources();
    }
  }

  Widget _fallback() {
    final shape = RoundedRectangleBorder(borderRadius: widget.borderRadius);
    return ClipPath(
      key: const ValueKey('miuix-squircle-rounded-fallback'),
      clipper: ShapeBorderClipper(shape: shape),
      child: ColoredBox(color: widget.color, child: widget.child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resources = _resources;
    if (!widget.enabled || resources == null) return _fallback();
    return _MiuixSdfSurfaceRenderWidget(
      key: const ValueKey('miuix-squircle-sdf-surface'),
      program: resources.program,
      sdfImage: resources.sdfImage,
      color: widget.color,
      borderRadius: widget.borderRadius,
      textDirection: Directionality.of(context),
      pixelRatio: MediaQuery.devicePixelRatioOf(context),
      clipChild: true,
      child: widget.child,
    );
  }
}

class _MiuixSquircleShaderResources {
  const _MiuixSquircleShaderResources({
    required this.program,
    required this.sdfImage,
  });

  final ui.FragmentProgram program;
  final ui.Image sdfImage;

  static Future<_MiuixSquircleShaderResources?> load() async {
    // Compose's Android RuntimeShader implementation is Tiramisu-only. Query
    // the package plugin before allocating GPU resources so API 32 and below
    // use the exact RoundedCornerShape fallback.
    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        const channel = MethodChannel('flutter_miuix/platform');
        final sdk = await channel.invokeMethod<int>('sdkInt');
        if (sdk == null || sdk < 33) {
          debugMiuixSquircleLastLoadError = StateError(
            'Android SDK $sdk does not support the source runtime shader.',
          );
          return null;
        }
      } catch (error) {
        // Widget tests and apps without the Android plugin have no channel.
        debugMiuixSquircleLastLoadError = error;
        return null;
      }
    }

    const shaderAsset = 'shaders/miuix_squircle_mask.frag';
    const imageAsset = 'assets/squircle/miuix_squircle_sdf.png';
    try {
      final program = await _loadProgram(shaderAsset);
      final bytes = await _loadAsset(imageAsset);
      final codec = await ui.instantiateImageCodec(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
      );
      final frame = await codec.getNextFrame();
      codec.dispose();
      debugMiuixSquircleLastLoadError = null;
      return _MiuixSquircleShaderResources(
        program: program,
        sdfImage: frame.image,
      );
    } catch (error) {
      debugMiuixSquircleLastLoadError = error;
      debugPrint('MIUIX squircle SDF failed to load: $error');
      return null;
    }
  }

  static Future<ui.FragmentProgram> _loadProgram(String asset) async {
    try {
      return await ui.FragmentProgram.fromAsset(
        'packages/flutter_miuix/$asset',
      );
    } catch (_) {
      return ui.FragmentProgram.fromAsset(asset);
    }
  }

  static Future<ByteData> _loadAsset(String asset) async {
    try {
      return await rootBundle.load('packages/flutter_miuix/$asset');
    } catch (_) {
      return rootBundle.load(asset);
    }
  }
}

class _MiuixSdfSurfaceRenderWidget extends SingleChildRenderObjectWidget {
  const _MiuixSdfSurfaceRenderWidget({
    super.key,
    required this.program,
    required this.sdfImage,
    required this.color,
    required this.borderRadius,
    required this.textDirection,
    required this.pixelRatio,
    required this.clipChild,
    required super.child,
  });

  final ui.FragmentProgram program;
  final ui.Image sdfImage;
  final Color color;
  final BorderRadius borderRadius;
  final TextDirection textDirection;
  final double pixelRatio;
  final bool clipChild;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderMiuixSdfSurface(
      program: program,
      sdfImage: sdfImage,
      color: color,
      borderRadius: borderRadius,
      textDirection: textDirection,
      pixelRatio: pixelRatio,
      clipChild: clipChild,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderMiuixSdfSurface renderObject,
  ) {
    renderObject
      ..color = color
      ..borderRadius = borderRadius
      ..textDirection = textDirection
      ..pixelRatio = pixelRatio
      ..clipChild = clipChild;
  }
}

class _RenderMiuixSdfSurface extends RenderProxyBox {
  _RenderMiuixSdfSurface({
    required ui.FragmentProgram program,
    required this.sdfImage,
    required Color color,
    required BorderRadius borderRadius,
    required TextDirection textDirection,
    required double pixelRatio,
    required bool clipChild,
  }) : _color = color,
       _borderRadius = borderRadius,
       _textDirection = textDirection,
       _pixelRatio = pixelRatio,
       _clipChild = clipChild,
       _shader = program.fragmentShader();

  static const double _halfRange = .125;
  static const double _blendThresholdRatio = math.pi / 4;
  static const double _bitmapSize = 512;

  final ui.Image sdfImage;
  final ui.FragmentShader _shader;
  Color _color;
  BorderRadius _borderRadius;
  TextDirection _textDirection;
  double _pixelRatio;
  bool _clipChild;

  set color(Color value) {
    if (_color == value) return;
    _color = value;
    markNeedsPaint();
  }

  set borderRadius(BorderRadius value) {
    if (_borderRadius == value) return;
    _borderRadius = value;
    markNeedsPaint();
  }

  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsPaint();
  }

  set pixelRatio(double value) {
    if (_pixelRatio == value) return;
    _pixelRatio = value;
    markNeedsPaint();
  }

  set clipChild(bool value) {
    if (_clipChild == value) return;
    _clipChild = value;
    markNeedsPaint();
  }

  List<double> _cornerTiles() {
    final resolved = _borderRadius.resolve(_textDirection);
    double radius(Radius value) => math.min(value.x, value.y);
    return <double>[
      radius(resolved.topLeft) * MiuixSquircleDefaults.extension,
      radius(resolved.topRight) * MiuixSquircleDefaults.extension,
      radius(resolved.bottomRight) * MiuixSquircleDefaults.extension,
      radius(resolved.bottomLeft) * MiuixSquircleDefaults.extension,
    ];
  }

  void _configureShader() {
    final halfMin = math.min(size.width, size.height) / 2;
    final threshold = halfMin * _blendThresholdRatio;
    final blendRange = halfMin - threshold;
    final requestedTiles = _cornerTiles();
    final effective = requestedTiles
        .map((value) => value.clamp(0.0, halfMin).toDouble())
        .toList(growable: false);
    final halfRanges = effective
        .map((value) => value * _halfRange)
        .toList(growable: false);
    final weights = requestedTiles
        .map((value) {
          if (blendRange <= 0) return 1.0;
          return ((value - threshold) / blendRange).clamp(0.0, 1.0).toDouble();
        })
        .toList(growable: false);

    _shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height);
    for (var index = 0; index < 4; index++) {
      _shader
        ..setFloat(2 + index, effective[index])
        ..setFloat(6 + index, halfRanges[index])
        ..setFloat(10 + index, weights[index]);
    }
    _shader
      ..setFloat(14, _bitmapSize)
      ..setFloat(15, _pixelRatio.isFinite && _pixelRatio > 0 ? _pixelRatio : 1)
      ..setImageSampler(0, sdfImage, filterQuality: FilterQuality.low);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (size.isEmpty) return;
    _configureShader();
    final canvas = context.canvas;
    final bounds = Offset.zero & size;
    // Paint only the SDF fill inside the translated local layer. Passing a
    // zero child offset while the raw Canvas is translated is not valid for a
    // retained/composited child: PaintingContext can promote that child to an
    // OffsetLayer whose origin then remains at the window's (0, 0). Dialogs
    // containing GridView/AnimatedSwitcher exposed the result as content
    // painted hundreds of pixels above its semantics and hit-test bounds.
    canvas
      ..save()
      ..translate(offset.dx, offset.dy)
      ..saveLayer(bounds, Paint())
      ..drawRect(bounds, Paint()..color = _color)
      ..drawRect(
        bounds,
        Paint()
          ..shader = _shader
          ..blendMode = BlendMode.dstIn,
      )
      ..restore()
      ..restore();

    final currentChild = child;
    if (currentChild == null) return;
    if (!_clipChild) {
      // The child must always receive the render object's real parent-space
      // offset, even when it owns a repaint boundary or platform layer.
      context.paintChild(currentChild, offset);
      return;
    }

    // PaintingContext's clip layer keeps retained child layers aligned and
    // clipped. The fill still uses the exact baked SDF; this vector path is
    // needed only for child pixels at the outermost continuous corner.
    final clipPath = MiuixSquircleBorder(
      borderRadius: _borderRadius,
    ).getOuterPath(bounds, textDirection: _textDirection);
    context.pushClipPath(needsCompositing, offset, bounds, clipPath, (
      childContext,
      childOffset,
    ) {
      childContext.paintChild(currentChild, childOffset);
    }, clipBehavior: Clip.antiAlias);
  }

  @override
  void dispose() {
    _shader.dispose();
    super.dispose();
  }
}
