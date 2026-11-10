part of '../miuix_widgets.dart';

/// Step-based automatic text sizing equivalent to Compose [TextAutoSize].
///
/// The largest discrete font size that fits the incoming width, height,
/// wrapping, and line-count constraints is selected. Values are logical `sp`
/// equivalents and still pass through Flutter's active [TextScaler].
@immutable
class MiuixTextAutoSize {
  /// Creates a step-based automatic-size policy.
  const MiuixTextAutoSize({
    this.minFontSize = 12,
    this.maxFontSize = 112,
    this.stepGranularity = 1,
  });

  /// Smallest permitted logical font size.
  final double minFontSize;

  /// Largest permitted logical font size.
  final double maxFontSize;

  /// Distance between discrete candidate sizes.
  final double stepGranularity;

  @override
  bool operator ==(Object other) {
    return other is MiuixTextAutoSize &&
        other.minFontSize == minFontSize &&
        other.maxFontSize == maxFontSize &&
        other.stepGranularity == stepGranularity;
  }

  @override
  int get hashCode => Object.hash(minFontSize, maxFontSize, stepGranularity);
}

/// Layout information reported by [MiuixText.onTextLayout].
///
/// Compose returns a `TextLayoutResult`. Flutter does not expose the internal
/// `TextPainter` owned by `RenderParagraph`, so this stable public value
/// carries the corresponding observable geometry and line information.
@immutable
class MiuixTextLayoutResult {
  /// Creates an immutable text-layout result.
  const MiuixTextLayoutResult({
    required this.size,
    required this.lineMetrics,
    required this.didExceedMaxLines,
    required this.fontSize,
    required this.plainText,
  });

  /// Actual laid-out widget size, including a requested [MiuixText.minLines].
  final Size size;

  /// Paragraph line metrics when Flutter can measure the complete span tree.
  ///
  /// Rich text containing [WidgetSpan] still reports the actual [size], but
  /// leaves this list empty because placeholder baselines belong to the live
  /// render tree rather than a standalone `TextPainter`.
  final List<ui.LineMetrics> lineMetrics;

  /// Whether the paragraph exceeded its configured maximum line count.
  final bool didExceedMaxLines;

  /// Final logical font size selected after automatic sizing.
  final double fontSize;

  /// Plain-text representation used by accessibility and diagnostics.
  final String plainText;

  /// Number of measured text lines.
  int get lineCount => lineMetrics.length;
}

/// High-level HyperOS text component with explicit source compatibility.
///
/// The unnamed and [MiuixText.rich] constructors use the current HyperOS 4
/// body hierarchy. [MiuixText.source] and [MiuixText.sourceRich] preserve the
/// source `String` and `AnnotatedString` Main roles. Rich constructors accept
/// Flutter [InlineSpan] trees, including [WidgetSpan] inline content.
class MiuixText extends StatefulWidget {
  /// Creates a plain text paragraph using the HyperOS 4 body hierarchy.
  const MiuixText(
    this.data, {
    super.key,
    this.color,
    this.autoSize,
    this.fontSize,
    this.fontStyle,
    this.fontWeight,
    this.fontFamily,
    this.letterSpacing,
    this.textDecoration,
    this.textAlign,
    this.lineHeight,
    this.overflow = TextOverflow.clip,
    this.softWrap = true,
    this.maxLines,
    this.minLines = 1,
    this.onTextLayout,
    this.style,
    this.textDirection,
    this.locale,
    this.semanticsLabel,
    this.textWidthBasis = TextWidthBasis.parent,
    this.textHeightBehavior,
    this.strutStyle,
  }) : textSpan = null,
       _sourceStyle = false;

  /// Creates the former source `String` overload and its 17sp Main role.
  const MiuixText.source(
    this.data, {
    super.key,
    this.color,
    this.autoSize,
    this.fontSize,
    this.fontStyle,
    this.fontWeight,
    this.fontFamily,
    this.letterSpacing,
    this.textDecoration,
    this.textAlign,
    this.lineHeight,
    this.overflow = TextOverflow.clip,
    this.softWrap = true,
    this.maxLines,
    this.minLines = 1,
    this.onTextLayout,
    this.style,
    this.textDirection,
    this.locale,
    this.semanticsLabel,
    this.textWidthBasis = TextWidthBasis.parent,
    this.textHeightBehavior,
    this.strutStyle,
  }) : textSpan = null,
       _sourceStyle = true;

  /// Creates rich text using the HyperOS 4 body hierarchy.
  const MiuixText.rich(
    InlineSpan textSpan, {
    super.key,
    this.color,
    this.autoSize,
    this.fontSize,
    this.fontStyle,
    this.fontWeight,
    this.fontFamily,
    this.letterSpacing,
    this.textDecoration,
    this.textAlign,
    this.lineHeight,
    this.overflow = TextOverflow.clip,
    this.softWrap = true,
    this.maxLines,
    this.minLines = 1,
    this.onTextLayout,
    this.style,
    this.textDirection,
    this.locale,
    this.semanticsLabel,
    this.textWidthBasis = TextWidthBasis.parent,
    this.textHeightBehavior,
    this.strutStyle,
  }) : data = '',
       // A non-null positional parameter keeps parity with Text(AnnotatedString).
       // ignore: prefer_initializing_formals
       textSpan = textSpan,
       _sourceStyle = false;

  /// Creates the former rich `AnnotatedString` overload and Main text role.
  const MiuixText.sourceRich(
    InlineSpan textSpan, {
    super.key,
    this.color,
    this.autoSize,
    this.fontSize,
    this.fontStyle,
    this.fontWeight,
    this.fontFamily,
    this.letterSpacing,
    this.textDecoration,
    this.textAlign,
    this.lineHeight,
    this.overflow = TextOverflow.clip,
    this.softWrap = true,
    this.maxLines,
    this.minLines = 1,
    this.onTextLayout,
    this.style,
    this.textDirection,
    this.locale,
    this.semanticsLabel,
    this.textWidthBasis = TextWidthBasis.parent,
    this.textHeightBehavior,
    this.strutStyle,
  }) : data = '',
       // A non-null positional parameter keeps parity with Text(AnnotatedString).
       // ignore: prefer_initializing_formals
       textSpan = textSpan,
       _sourceStyle = true;

  /// Plain text for the unnamed constructor.
  ///
  /// The rich constructor retains an empty value here for source compatibility
  /// with callers that previously read the public [data] field.
  final String data;

  /// Rich Flutter span tree, corresponding to source `AnnotatedString`.
  final InlineSpan? textSpan;

  /// Explicit text color.
  ///
  /// Its precedence is explicit color, style color, local content color.
  final Color? color;

  /// Optional source-equivalent automatic-size policy.
  final MiuixTextAutoSize? autoSize;

  /// Explicit logical glyph size merged over [style].
  final double? fontSize;

  /// Explicit font variant merged over [style].
  final FontStyle? fontStyle;

  /// Explicit font weight merged over [style].
  final FontWeight? fontWeight;

  /// Explicit font-family name merged over [style].
  final String? fontFamily;

  /// Explicit logical letter spacing merged over [style].
  final double? letterSpacing;

  /// Explicit decoration merged over [style].
  final TextDecoration? textDecoration;

  /// Paragraph alignment.
  final TextAlign? textAlign;

  /// Flutter line-height multiplier merged over [style].
  final double? lineHeight;

  /// Visual overflow handling, defaulting to source `Clip`.
  final TextOverflow? overflow;

  /// Whether the paragraph may wrap at soft line breaks.
  final bool softWrap;

  /// Optional maximum line count; null represents source `Int.MAX_VALUE`.
  final int? maxLines;

  /// Minimum visible line count.
  final int minLines;

  /// Callback after a new text layout is installed in the render tree.
  final ValueChanged<MiuixTextLayoutResult>? onTextLayout;

  /// Base style, defaulting to the MIUIX `main` text role.
  final TextStyle? style;

  /// Optional Flutter text-direction adapter.
  final TextDirection? textDirection;

  /// Optional Flutter locale adapter.
  final Locale? locale;

  /// Optional Flutter accessibility-label adapter.
  final String? semanticsLabel;

  /// Flutter paragraph-width strategy.
  final TextWidthBasis textWidthBasis;

  /// Optional Flutter line-box behavior.
  final TextHeightBehavior? textHeightBehavior;

  /// Optional Flutter strut used when a source component owns an exact line box.
  ///
  /// Compose measures component typography against its declared text role. A
  /// forced strut is useful for translated CJK labels whose platform fallback
  /// font would otherwise enlarge a single source line on Android.
  final StrutStyle? strutStyle;

  final bool _sourceStyle;

  @override
  State<MiuixText> createState() => _MiuixTextState();
}

class _MiuixTextState extends State<MiuixText> {
  final GlobalKey _layoutKey = GlobalKey();
  _MiuixTextReportSignature? _lastReport;
  List<PlaceholderDimensions>? _placeholderDimensions;
  int _reportGeneration = 0;
  int _placeholderGeneration = 0;

  /// Runtime-safe line floor used by both measurement and live layout.
  int get _effectiveMinLines => math.max(1, widget.minLines);

  /// A maximum below the line floor is raised to the same deterministic floor.
  int? get _effectiveMaxLines {
    final requested = widget.maxLines;
    return requested == null ? null : math.max(_effectiveMinLines, requested);
  }

  /// Invalid explicit typography falls back to the merged theme role.
  double? get _effectiveFontSize {
    final requested = widget.fontSize;
    return requested != null && requested.isFinite && requested >= 0
        ? requested
        : null;
  }

  /// Flutter requires a finite, positive line-height multiplier.
  double? get _effectiveLineHeight {
    final requested = widget.lineHeight;
    return requested != null && requested.isFinite && requested > 0
        ? requested
        : null;
  }

  @override
  void didUpdateWidget(covariant MiuixText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onTextLayout != widget.onTextLayout) {
      _lastReport = null;
    }
    if (oldWidget.textSpan != widget.textSpan) {
      _placeholderDimensions = null;
    }
  }

  /// Applies shared color precedence and individually merged text arguments.
  TextStyle _resolveStyle(BuildContext context) {
    final theme = Theme.of(context);
    final localColor = DefaultTextStyle.of(context).style.color;
    final baseline = widget._sourceStyle
        ? theme.textTheme.bodyLarge
        : theme.textTheme.bodyMedium;
    final sourceMain =
        baseline ??
        TextStyle(
          fontSize: widget._sourceStyle ? 17 : 16,
          height: 1.16,
          fontWeight: FontWeight.w400,
        );
    // Keep the calibrated MIUIX/platform font fallbacks when callers supply a
    // partial TextStyle such as only fontSize. This is the Flutter equivalent
    // of BasicText resolving unspecified typeface fields through the platform.
    final base = widget.style == null
        ? sourceMain
        : sourceMain.merge(widget.style);
    final resolvedColor =
        widget.color ??
        // LocalTextStyles.main carries no color in the source. Material
        // ThemeData eagerly injects onSurface into body roles, so count a
        // color only when the caller actually supplied the style parameter.
        widget.style?.color ??
        localColor ??
        theme.colorScheme.onSurface;
    return base.copyWith(
      inherit: false,
      color: resolvedColor,
      fontSize: _effectiveFontSize,
      fontStyle: widget.fontStyle,
      fontWeight: widget.fontWeight,
      fontFamily: widget.fontFamily,
      letterSpacing: widget.letterSpacing,
      decoration: widget.textDecoration,
      height: _effectiveLineHeight,
    );
  }

  /// Adds MIUIX primary/underline defaults only to otherwise unstyled links.
  InlineSpan _resolveRichLinks(InlineSpan span, Color primary) {
    if (span is! TextSpan) return span;
    final children = span.children
        ?.map((child) => _resolveRichLinks(child, primary))
        .toList(growable: false);
    final isUnstyledLink =
        span.recognizer != null &&
        span.style?.color == null &&
        span.style?.decoration == null;
    final linkStyle = isUnstyledLink
        ? (span.style ?? const TextStyle()).copyWith(
            color: primary,
            decoration: TextDecoration.underline,
          )
        : span.style;
    return TextSpan(
      text: span.text,
      children: children,
      style: linkStyle,
      recognizer: span.recognizer,
      mouseCursor: span.mouseCursor,
      onEnter: span.onEnter,
      onExit: span.onExit,
      semanticsLabel: span.semanticsLabel,
      semanticsIdentifier: span.semanticsIdentifier,
      locale: span.locale,
      spellOut: span.spellOut,
    );
  }

  /// Returns a standalone span tree suitable for TextPainter measurement.
  InlineSpan _measurementSpan(TextStyle style, InlineSpan? richSpan) {
    if (richSpan == null) return TextSpan(text: widget.data, style: style);
    return TextSpan(style: style, children: <InlineSpan>[richSpan]);
  }

  /// Measures a candidate while tolerating live WidgetSpan placeholders.
  _MiuixMeasuredText? _measure({
    required InlineSpan span,
    required TextStyle style,
    required BoxConstraints constraints,
    required TextDirection direction,
    required TextScaler scaler,
  }) {
    final maxWidth = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : double.infinity;
    final painter = TextPainter(
      text: span,
      textAlign: widget.textAlign ?? TextAlign.start,
      textDirection: direction,
      textScaler: scaler,
      maxLines: _effectiveMaxLines,
      ellipsis: widget.overflow == TextOverflow.ellipsis ? '\u2026' : null,
      locale: widget.locale,
      textWidthBasis: widget.textWidthBasis,
      textHeightBehavior: widget.textHeightBehavior,
      strutStyle: widget.strutStyle,
    );
    try {
      painter.setPlaceholderDimensions(_placeholderDimensions);
      painter.layout(maxWidth: widget.softWrap ? maxWidth : double.infinity);
      final preferredLineHeight = painter.preferredLineHeight;
      final minimumHeight = preferredLineHeight * _effectiveMinLines;
      final measuredSize = Size(
        painter.width,
        math.max(painter.height, minimumHeight),
      );
      final result = _MiuixMeasuredText(
        size: measuredSize,
        lineMetrics: painter.computeLineMetrics(),
        didExceedMaxLines: painter.didExceedMaxLines,
        preferredLineHeight: preferredLineHeight,
      );
      painter.dispose();
      return result;
    } on Object {
      // TextPainter requires live placeholder dimensions for WidgetSpan.
      // RichText supplies those through RenderParagraph; its real size is
      // captured from _layoutKey after layout instead.
      painter.dispose();
      return null;
    }
  }

  /// Chooses the greatest discrete automatic-size candidate that fits.
  double _resolveAutomaticFontSize({
    required TextStyle baseStyle,
    required InlineSpan? richSpan,
    required BoxConstraints constraints,
    required TextDirection direction,
    required TextScaler scaler,
  }) {
    final policy = widget.autoSize;
    if (policy == null) {
      return baseStyle.fontSize ?? (widget._sourceStyle ? 17 : 16);
    }
    final minimum = policy.minFontSize.isFinite && policy.minFontSize > 0
        ? policy.minFontSize
        : 12.0;
    final authoredMaximum =
        policy.maxFontSize.isFinite && policy.maxFontSize >= minimum
        ? policy.maxFontSize
        : math.max(minimum, 112.0);
    final range = authoredMaximum - minimum;
    final maximum = range.isFinite ? authoredMaximum : math.max(minimum, 112.0);
    final step = policy.stepGranularity.isFinite && policy.stepGranularity > 0
        ? policy.stepGranularity
        : 1.0;
    final stepCount = ((maximum - minimum) / step).floor();
    var low = 0;
    var high = stepCount;
    var best = minimum;
    while (low <= high) {
      final middle = low + ((high - low) >> 1);
      final candidate = minimum + middle * step;
      final style = baseStyle.copyWith(fontSize: candidate);
      final measured = _measure(
        span: _measurementSpan(style, richSpan),
        style: style,
        constraints: constraints,
        direction: direction,
        scaler: scaler,
      );
      // WidgetSpan dimensions are available only in the live paragraph.
      // Use the largest candidate rather than incorrectly shrinking based on
      // a placeholder-free surrogate.
      if (measured == null) return maximum;
      final widthFits =
          !constraints.hasBoundedWidth ||
          measured.size.width <= constraints.maxWidth + 1e-7;
      final heightFits =
          !constraints.hasBoundedHeight ||
          measured.size.height <= constraints.maxHeight + 1e-7;
      final fits = widthFits && heightFits && !measured.didExceedMaxLines;
      if (fits) {
        best = candidate;
        low = middle + 1;
      } else {
        high = middle - 1;
      }
    }
    return best;
  }

  /// Finds the live paragraph below this widget's minimum-line wrapper.
  RenderParagraph? _findRenderParagraph(RenderObject root) {
    if (root is RenderParagraph) return root;
    RenderParagraph? result;
    root.visitChildren((child) {
      result ??= _findRenderParagraph(child);
    });
    return result;
  }

  /// Collects WidgetSpan definitions in RenderParagraph preorder.
  void _collectWidgetSpans(InlineSpan span, List<WidgetSpan> result) {
    if (span is WidgetSpan) {
      result.add(span);
      return;
    }
    if (span is TextSpan) {
      for (final child in span.children ?? const <InlineSpan>[]) {
        _collectWidgetSpans(child, result);
      }
    }
  }

  /// Reads live inline-child sizes so TextPainter can reproduce rich layout.
  ///
  /// Flutter deliberately ignores WidgetSpan dimensions in a standalone
  /// TextPainter. RenderParagraph already owns the authoritative child boxes,
  /// so a second layout pass can feed those public dimensions back into the
  /// source-equivalent auto-size and layout-result calculations.
  void _schedulePlaceholderCapture(InlineSpan? richSpan) {
    if (richSpan == null ||
        (widget.autoSize == null && widget.onTextLayout == null)) {
      return;
    }
    final spans = <WidgetSpan>[];
    _collectWidgetSpans(richSpan, spans);
    if (spans.isEmpty) return;
    final generation = ++_placeholderGeneration;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || generation != _placeholderGeneration) return;
      final root = _layoutKey.currentContext?.findRenderObject();
      if (root == null) return;
      final paragraph = _findRenderParagraph(root);
      if (paragraph == null) return;
      final children = <RenderBox>[];
      paragraph.visitChildren((child) {
        if (child is RenderBox) children.add(child);
      });
      if (children.length != spans.length) return;
      final dimensions = <PlaceholderDimensions>[
        for (var index = 0; index < spans.length; index++)
          PlaceholderDimensions(
            size: children[index].size,
            alignment: spans[index].alignment,
            baseline: spans[index].baseline,
            baselineOffset:
                spans[index].alignment == ui.PlaceholderAlignment.baseline
                ? children[index].getDistanceToBaseline(
                        spans[index].baseline ?? TextBaseline.alphabetic,
                      ) ??
                      children[index].size.height
                : null,
          ),
      ];
      if (listEquals(_placeholderDimensions, dimensions)) return;
      setState(() => _placeholderDimensions = dimensions);
    });
  }

  /// Reports after layout so callback size equals the live paragraph wrapper.
  void _scheduleLayoutReport({
    required _MiuixMeasuredText? measured,
    required double fontSize,
    required String plainText,
  }) {
    final callback = widget.onTextLayout;
    if (callback == null) return;
    final generation = ++_reportGeneration;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || generation != _reportGeneration) return;
      final renderObject = _layoutKey.currentContext?.findRenderObject();
      final actualSize = renderObject is RenderBox && renderObject.hasSize
          ? renderObject.size
          : measured?.size ?? Size.zero;
      final result = MiuixTextLayoutResult(
        size: actualSize,
        lineMetrics: measured?.lineMetrics ?? const <ui.LineMetrics>[],
        didExceedMaxLines: measured?.didExceedMaxLines ?? false,
        fontSize: fontSize,
        plainText: plainText,
      );
      final signature = _MiuixTextReportSignature.fromResult(result);
      if (_lastReport == signature) return;
      _lastReport = signature;
      callback(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    final direction = widget.textDirection ?? Directionality.of(context);
    final scaler = MediaQuery.textScalerOf(context);
    final baseStyle = _resolveStyle(context);
    final richSpan = widget.textSpan == null
        ? null
        : _resolveRichLinks(
            widget.textSpan!,
            Theme.of(context).colorScheme.primary,
          );
    final plainText = richSpan?.toPlainText() ?? widget.data;

    return LayoutBuilder(
      builder: (context, constraints) {
        final selectedFontSize = _resolveAutomaticFontSize(
          baseStyle: baseStyle,
          richSpan: richSpan,
          constraints: constraints,
          direction: direction,
          scaler: scaler,
        );
        final effectiveStyle = baseStyle.copyWith(fontSize: selectedFontSize);
        final measurement = _measure(
          span: _measurementSpan(effectiveStyle, richSpan),
          style: effectiveStyle,
          constraints: constraints,
          direction: direction,
          scaler: scaler,
        );
        final text = richSpan == null
            ? Text(
                widget.data,
                style: effectiveStyle,
                textAlign: widget.textAlign,
                textDirection: direction,
                locale: widget.locale,
                softWrap: widget.softWrap,
                overflow: widget.overflow ?? TextOverflow.clip,
                maxLines: _effectiveMaxLines,
                semanticsLabel: widget.semanticsLabel,
                textWidthBasis: widget.textWidthBasis,
                textHeightBehavior: widget.textHeightBehavior,
                strutStyle: widget.strutStyle,
              )
            : Text.rich(
                richSpan,
                style: effectiveStyle,
                textAlign: widget.textAlign,
                textDirection: direction,
                locale: widget.locale,
                softWrap: widget.softWrap,
                overflow: widget.overflow ?? TextOverflow.clip,
                maxLines: _effectiveMaxLines,
                semanticsLabel: widget.semanticsLabel,
                textWidthBasis: widget.textWidthBasis,
                textHeightBehavior: widget.textHeightBehavior,
                strutStyle: widget.strutStyle,
              );
        final minimumHeight =
            (measurement?.preferredLineHeight ??
                scaler.scale(
                      effectiveStyle.fontSize ??
                          (widget._sourceStyle ? 17 : 16),
                    ) *
                    (effectiveStyle.height ?? 1)) *
            _effectiveMinLines;
        final result = ConstrainedBox(
          key: _layoutKey,
          constraints: BoxConstraints(minHeight: minimumHeight),
          child: text,
        );
        _scheduleLayoutReport(
          measured: measurement,
          fontSize: selectedFontSize,
          plainText: plainText,
        );
        _schedulePlaceholderCapture(richSpan);
        return result;
      },
    );
  }
}

@immutable
class _MiuixMeasuredText {
  const _MiuixMeasuredText({
    required this.size,
    required this.lineMetrics,
    required this.didExceedMaxLines,
    required this.preferredLineHeight,
  });

  final Size size;
  final List<ui.LineMetrics> lineMetrics;
  final bool didExceedMaxLines;
  final double preferredLineHeight;
}

@immutable
class _MiuixTextReportSignature {
  const _MiuixTextReportSignature({
    required this.size,
    required this.lineCount,
    required this.didExceedMaxLines,
    required this.fontSize,
    required this.plainText,
  });

  factory _MiuixTextReportSignature.fromResult(MiuixTextLayoutResult result) {
    return _MiuixTextReportSignature(
      size: result.size,
      lineCount: result.lineCount,
      didExceedMaxLines: result.didExceedMaxLines,
      fontSize: result.fontSize,
      plainText: result.plainText,
    );
  }

  final Size size;
  final int lineCount;
  final bool didExceedMaxLines;
  final double fontSize;
  final String plainText;

  @override
  bool operator ==(Object other) {
    return other is _MiuixTextReportSignature &&
        other.size == size &&
        other.lineCount == lineCount &&
        other.didExceedMaxLines == didExceedMaxLines &&
        other.fontSize == fontSize &&
        other.plainText == plainText;
  }

  @override
  int get hashCode =>
      Object.hash(size, lineCount, didExceedMaxLines, fontSize, plainText);
}
