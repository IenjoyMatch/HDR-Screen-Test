import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'miuix_effects.dart';

/// Paints a sampled MIUIX backdrop only through the glyphs of [text].
///
/// The original Compose API applies `textureBlur` to text with
/// `BlendMode.DstIn`: the text alpha becomes a mask while the glyph fill is
/// replaced by the blurred background. Flutter has no synchronous text-path
/// API, so this widget rasterizes the glyph alpha once per text/style/size and
/// feeds that mask to [ShaderMask]. The backdrop itself remains live, meaning
/// animated content behind the text continues to move without re-rasterizing
/// the glyphs.
class MiuixForegroundBlurText extends StatefulWidget {
  /// Creates foreground blur text.
  const MiuixForegroundBlurText({
    super.key,
    required this.text,
    required this.style,
    required this.backdrop,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.textDirection,
    this.width,
    this.fillWidth = true,
    this.fallbackGradient,
  });

  /// Text whose alpha is used as the foreground mask.
  final String text;

  /// Typography used to shape and rasterize the mask.
  final TextStyle style;

  /// Blur, noise, color adjustment, and blend layers sampled behind the text.
  final MiuixBackdrop backdrop;

  /// Horizontal alignment used while laying out the glyph mask.
  final TextAlign textAlign;

  /// Optional maximum number of lines.
  final int? maxLines;

  /// Optional explicit direction; otherwise inherited from [Directionality].
  final TextDirection? textDirection;

  /// Optional fixed logical width. By default the available width is used.
  final double? width;

  /// Whether an unspecified [width] expands to the available width.
  final bool fillWidth;

  /// Optional sampled-color fallback for backends without shader image
  /// filters. The glyph mask remains exact; only MIUIX's extended color blend
  /// is replaced. Callers can derive this gradient from their known backdrop.
  final Gradient? fallbackGradient;

  @override
  State<MiuixForegroundBlurText> createState() =>
      _MiuixForegroundBlurTextState();
}

class _MiuixForegroundBlurTextState extends State<MiuixForegroundBlurText> {
  ui.Image? _mask;
  Size? _maskSize;
  TextStyle? _maskStyle;
  String? _maskText;
  TextAlign? _maskAlignment;
  TextDirection? _maskDirection;
  int? _maskMaxLines;
  double? _maskPixelRatio;
  bool _rasterScheduled = false;

  @override
  void dispose() {
    _mask?.dispose();
    super.dispose();
  }

  bool _matchesMask(
    Size size,
    TextDirection direction,
    double pixelRatio,
    TextStyle style,
  ) {
    return _mask != null &&
        _maskSize == size &&
        _maskStyle == style &&
        _maskText == widget.text &&
        _maskAlignment == widget.textAlign &&
        _maskDirection == direction &&
        _maskMaxLines == widget.maxLines &&
        _maskPixelRatio == pixelRatio;
  }

  TextPainter _textPainter(TextDirection direction, TextStyle style) {
    return TextPainter(
      text: TextSpan(
        text: widget.text,
        style: style.copyWith(color: Colors.white),
      ),
      textAlign: widget.textAlign,
      textDirection: direction,
      maxLines: widget.maxLines,
    );
  }

  void _scheduleMask(
    Size size,
    TextDirection direction,
    double pixelRatio,
    TextStyle style,
  ) {
    if (_rasterScheduled || _matchesMask(size, direction, pixelRatio, style)) {
      return;
    }
    _rasterScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final painter = _textPainter(direction, style)
        ..layout(minWidth: size.width, maxWidth: size.width);
      final recorder = ui.PictureRecorder();
      // Keep the mask image in logical coordinates. ShaderMask is rasterized
      // by the engine at the target DPR, so a physical-pixel image would need
      // a backend-sensitive local matrix and produced solid bars at 3x.
      final canvas = Canvas(recorder);
      painter.paint(canvas, Offset.zero);
      final picture = recorder.endRecording();
      final image = await picture.toImage(
        size.width.ceil().clamp(1, 1 << 20),
        size.height.ceil().clamp(1, 1 << 20),
      );
      picture.dispose();
      if (!mounted) {
        image.dispose();
        return;
      }
      final oldMask = _mask;
      setState(() {
        _mask = image;
        _maskSize = size;
        _maskStyle = style;
        _maskText = widget.text;
        _maskAlignment = widget.textAlign;
        _maskDirection = direction;
        _maskMaxLines = widget.maxLines;
        _maskPixelRatio = pixelRatio;
        _rasterScheduled = false;
      });
      oldMask?.dispose();
    });
  }

  Widget _buildForWidth(
    double logicalWidth,
    TextDirection direction,
    double pixelRatio,
    TextStyle style,
  ) {
    final painter = _textPainter(direction, style)
      ..layout(minWidth: logicalWidth, maxWidth: logicalWidth);
    final size = Size(logicalWidth, painter.height);
    if (!widget.backdrop.enabled) {
      return SizedBox(
        width: size.width,
        child: Text(
          widget.text,
          style: widget.style,
          textAlign: widget.textAlign,
          maxLines: widget.maxLines,
          textDirection: direction,
        ),
      );
    }
    final fallbackGradient = widget.fallbackGradient;
    if (fallbackGradient != null && !ui.ImageFilter.isShaderFilterSupported) {
      // Keep the complete string in one paragraph. Splitting it into a
      // differently colored TextSpan per character disables cross-span
      // kerning (the source About title became seven physical pixels wider at
      // 420 dpi). Apply the measured fallback after shaping, just as Compose
      // applies DstIn to one text mask.
      return SizedBox(
        width: size.width,
        height: size.height,
        child: ShaderMask(
          key: const ValueKey('miuix-foreground-blur-mask'),
          blendMode: BlendMode.srcIn,
          shaderCallback: fallbackGradient.createShader,
          child: Text(
            widget.text,
            style: style.copyWith(color: Colors.white),
            textAlign: widget.textAlign,
            maxLines: widget.maxLines,
            textDirection: direction,
          ),
        ),
      );
    }
    _scheduleMask(size, direction, pixelRatio, style);
    final mask = _matchesMask(size, direction, pixelRatio, style)
        ? _mask
        : null;
    final Widget backdrop;
    backdrop = MiuixLayerBackdrop(
      backdrop: widget.backdrop,
      radius: 0,
      padding: EdgeInsets.zero,
      child: SizedBox(width: size.width, height: size.height),
    );
    if (mask == null) {
      return SizedBox(
        width: size.width,
        height: size.height,
        child: Opacity(opacity: 0, child: backdrop),
      );
    }
    return SizedBox(
      width: size.width,
      height: size.height,
      child: ShaderMask(
        key: const ValueKey('miuix-foreground-blur-mask'),
        blendMode: BlendMode.dstIn,
        shaderCallback: (_) => ui.ImageShader(
          mask,
          TileMode.decal,
          TileMode.decal,
          Matrix4.identity().storage,
        ),
        child: backdrop,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final direction = widget.textDirection ?? Directionality.of(context);
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final inheritedStyle = DefaultTextStyle.of(context).style;
    final resolvedStyle = widget.style.inherit
        ? inheritedStyle.merge(widget.style)
        : widget.style;
    if (widget.width case final width?) {
      return _buildForWidth(width, direction, pixelRatio, resolvedStyle);
    }
    if (!widget.fillWidth) {
      final naturalPainter = _textPainter(direction, resolvedStyle)..layout();
      return _buildForWidth(
        naturalPainter.width,
        direction,
        pixelRatio,
        resolvedStyle,
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth.isFinite) {
          return _buildForWidth(
            constraints.maxWidth,
            direction,
            pixelRatio,
            resolvedStyle,
          );
        }
        final naturalPainter = _textPainter(direction, resolvedStyle)..layout();
        return _buildForWidth(
          naturalPainter.width,
          direction,
          pixelRatio,
          resolvedStyle,
        );
      },
    );
  }
}
