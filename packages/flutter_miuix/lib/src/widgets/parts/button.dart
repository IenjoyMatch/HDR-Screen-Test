part of '../miuix_widgets.dart';

/// Immutable color contract used by [MiuixButton].
///
/// The four values map directly to `ButtonColors` in the upstream MIUIX
/// component. Keeping enabled and disabled pairs together prevents a caller
/// from changing only the painted surface while accidentally retaining an
/// unreadable inherited content color.
@immutable
class MiuixButtonColors {
  /// Creates an explicit button color set.
  const MiuixButtonColors({
    required this.color,
    required this.disabledColor,
    required this.contentColor,
    required this.disabledContentColor,
  });

  /// Enabled container color.
  final Color color;

  /// Disabled container color.
  final Color disabledColor;

  /// Enabled local content color.
  final Color contentColor;

  /// Disabled local content color.
  final Color disabledContentColor;

  /// Creates a value with independently replaced source color channels.
  MiuixButtonColors copyWith({
    Color? color,
    Color? disabledColor,
    Color? contentColor,
    Color? disabledContentColor,
  }) {
    return MiuixButtonColors(
      color: color ?? this.color,
      disabledColor: disabledColor ?? this.disabledColor,
      contentColor: contentColor ?? this.contentColor,
      disabledContentColor: disabledContentColor ?? this.disabledContentColor,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MiuixButtonColors &&
            other.color == color &&
            other.disabledColor == disabledColor &&
            other.contentColor == contentColor &&
            other.disabledContentColor == disabledContentColor;
  }

  @override
  int get hashCode =>
      Object.hash(color, disabledColor, contentColor, disabledContentColor);
}

/// Immutable source color contract used by [MiuixTextButton].
@immutable
class MiuixTextButtonColors {
  /// Creates an explicit text-button color set.
  const MiuixTextButtonColors({
    required this.color,
    required this.disabledColor,
    required this.textColor,
    required this.disabledTextColor,
  });

  /// Enabled container color.
  final Color color;

  /// Disabled container color.
  final Color disabledColor;

  /// Enabled label color.
  final Color textColor;

  /// Disabled label color.
  final Color disabledTextColor;

  /// Creates a value with independently replaced source color channels.
  MiuixTextButtonColors copyWith({
    Color? color,
    Color? disabledColor,
    Color? textColor,
    Color? disabledTextColor,
  }) {
    return MiuixTextButtonColors(
      color: color ?? this.color,
      disabledColor: disabledColor ?? this.disabledColor,
      textColor: textColor ?? this.textColor,
      disabledTextColor: disabledTextColor ?? this.disabledTextColor,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MiuixTextButtonColors &&
            other.color == color &&
            other.disabledColor == disabledColor &&
            other.textColor == textColor &&
            other.disabledTextColor == disabledTextColor;
  }

  @override
  int get hashCode =>
      Object.hash(color, disabledColor, textColor, disabledTextColor);
}

/// Source defaults and theme-resolved color factories for MIUIX buttons.
abstract final class MiuixButtonDefaults {
  /// Explicit MIUIX 1.0.9 minimum height for compatibility constructors.
  static const double legacyMinHeight = 40;

  /// Explicit MIUIX 1.0.9 corner radius for compatibility constructors.
  static const double legacyCornerRadius = 16;

  /// Explicit MIUIX 1.0.9 content inset for compatibility constructors.
  static const EdgeInsets legacyInsideMargin = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 13,
  );

  /// Default minimum width from `ButtonDefaults.MinWidth`.
  static const double minWidth = 58;

  /// Default minimum height from `ButtonDefaults.MinHeight`.
  static const double minHeight = 48;

  /// Android's accessibility and pointer target around the visual button.
  ///
  /// Compose's `clickable` modifier enforces this independently from the
  /// 40dp visual minimum, so compact buttons keep their measured geometry.
  static const double minimumInteractiveSize = 48;

  /// Default continuous-corner radius.
  static const double cornerRadius = 24;

  /// Default internal padding from `ButtonDefaults.InsideMargin`.
  static const EdgeInsets insideMargin = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 14,
  );

  /// Resolves the ordinary or primary `ButtonColors` source factory.
  ///
  /// Optional values override only their matching source field. This is useful
  /// for branded buttons while retaining the MIUIX disabled-state contract.
  static MiuixButtonColors buttonColors(
    BuildContext context, {
    bool primary = false,
    Color? color,
    Color? disabledColor,
    Color? contentColor,
    Color? disabledContentColor,
  }) {
    final semantic = MiuixSemanticColors.of(context);
    // 强按钮仍保持原主色；禁用状态使用宿主提供的中性配对层。
    final layers = MiuixAccentLayers.maybeOf(context);
    return MiuixButtonColors(
      color: color ?? semantic[primary ? 'primary' : 'secondaryVariant'],
      disabledColor:
          disabledColor ??
          layers?.disabledFill ??
          semantic[primary
              ? 'disabledPrimaryButton'
              : 'disabledSecondaryVariant'],
      contentColor:
          contentColor ??
          semantic[primary ? 'onPrimary' : 'onSecondaryVariant'],
      disabledContentColor:
          disabledContentColor ??
          layers?.disabledForeground ??
          semantic[primary
              ? 'disabledOnPrimaryButton'
              : 'disabledOnSecondaryVariant'],
    );
  }

  /// Resolves the source-named primary `ButtonColors` factory.
  static MiuixButtonColors buttonColorsPrimary(
    BuildContext context, {
    Color? color,
    Color? disabledColor,
    Color? contentColor,
    Color? disabledContentColor,
  }) {
    return buttonColors(
      context,
      primary: true,
      color: color,
      disabledColor: disabledColor,
      contentColor: contentColor,
      disabledContentColor: disabledContentColor,
    );
  }

  /// Resolves the ordinary or primary `TextButtonColors` source factory.
  static MiuixTextButtonColors textButtonColors(
    BuildContext context, {
    bool primary = false,
    Color? color,
    Color? disabledColor,
    Color? textColor,
    Color? disabledTextColor,
  }) {
    final button = buttonColors(
      context,
      primary: primary,
      color: color,
      disabledColor: disabledColor,
      contentColor: textColor,
      disabledContentColor: disabledTextColor,
    );
    return MiuixTextButtonColors(
      color: button.color,
      disabledColor: button.disabledColor,
      textColor: button.contentColor,
      disabledTextColor: button.disabledContentColor,
    );
  }

  /// Resolves the source-named primary `TextButtonColors` factory.
  static MiuixTextButtonColors textButtonColorsPrimary(
    BuildContext context, {
    Color? color,
    Color? disabledColor,
    Color? textColor,
    Color? disabledTextColor,
  }) {
    return textButtonColors(
      context,
      primary: true,
      color: color,
      disabledColor: disabledColor,
      textColor: textColor,
      disabledTextColor: disabledTextColor,
    );
  }
}

/// MIUIX button with the complete v1.0.9 layout contract.
///
/// [label] is the convenient compatibility form used by the Flutter example.
/// [child] is the source-equivalent arbitrary Row content slot. When both
/// forms are supplied it wins; an omitted form becomes an empty label. This
/// deterministic fallback also applies in Release builds where assertions do
/// not protect values coming from decoded configuration or plugin bridges.
class MiuixButton extends StatelessWidget {
  /// Creates a MIUIX button.
  const MiuixButton({
    super.key,
    required this.onPressed,
    this.label,
    this.child,
    this.icon,
    this.enabled = true,
    this.filled = false,
    this.expand = false,
    this.colors,
    double? cornerRadius,
    this.minWidth = MiuixButtonDefaults.minWidth,
    this.minHeight = MiuixButtonDefaults.minHeight,
    this.insideMargin = MiuixButtonDefaults.insideMargin,
    this.showIndication = true,
  }) : _cornerRadius = cornerRadius;

  /// Creates the explicit MIUIX 1.0.9 geometry for compatibility work.
  const MiuixButton.source({
    super.key,
    required this.onPressed,
    this.label,
    this.child,
    this.icon,
    this.enabled = true,
    this.filled = false,
    this.expand = false,
    this.colors,
    double cornerRadius = MiuixButtonDefaults.legacyCornerRadius,
    this.minWidth = MiuixButtonDefaults.minWidth,
    this.minHeight = MiuixButtonDefaults.legacyMinHeight,
    this.insideMargin = MiuixButtonDefaults.legacyInsideMargin,
    this.showIndication = true,
  }) : _cornerRadius = cornerRadius;

  /// Compatibility text label.
  final String? label;

  /// Source-equivalent arbitrary content.
  final Widget? child;

  /// Optional leading icon for the label convenience form.
  final Widget? icon;

  /// Callback invoked by an enabled button.
  final VoidCallback? onPressed;

  /// Whether the source surface installs its click behavior.
  ///
  /// A null [onPressed] also disables activation for Flutter compatibility.
  final bool enabled;

  /// Compatibility shortcut selecting the primary source color factory.
  final bool filled;

  /// Whether a loose horizontal parent is filled.
  ///
  /// This adapter is intentionally outside the source component contract; it
  /// preserves the original Flutter package's convenient full-width form.
  final bool expand;

  /// Explicit enabled and disabled source color pairs.
  final MiuixButtonColors? colors;

  /// Continuous-corner radius.
  double get cornerRadius => _cornerRadius ?? MiuixButtonDefaults.cornerRadius;
  final double? _cornerRadius;

  /// Minimum complete button width, including [insideMargin].
  final double minWidth;

  /// Minimum complete button height, including [insideMargin].
  final double minHeight;

  /// Padding inside the surface and outside its Row content.
  final EdgeInsetsGeometry insideMargin;

  /// Whether the source indication is installed.
  ///
  /// This is the Flutter equivalent of passing a non-null `Indication`.
  final bool showIndication;

  @override
  Widget build(BuildContext context) {
    final resolvedColors =
        colors ?? MiuixButtonDefaults.buttonColors(context, primary: filled);
    final effectiveEnabled = enabled && onPressed != null;
    final foreground = effectiveEnabled
        ? resolvedColors.contentColor
        : resolvedColors.disabledContentColor;
    // Arbitrary source content has explicit precedence. Keeping the fallback
    // here, rather than only in the example, protects every library consumer.
    final content =
        child ??
        _MiuixButtonLabelContent(
          label: label ?? '',
          icon: icon,
          color: foreground,
          // 便捷标签与文字按钮共用自然换行；有限宽度和大字号不能裁掉操作名称。
          // 任意 child 仍由调用者负责布局，这一设置不改变其内容契约。
          allowWrapping: true,
        );
    final button = _MiuixButtonSurface(
      content: content,
      onPressed: onPressed,
      enabled: effectiveEnabled,
      colors: resolvedColors,
      cornerRadius:
          _cornerRadius ?? MiuixTheme.of(context).hyperOs4.buttonCornerRadius,
      minWidth: minWidth,
      minHeight: minHeight,
      insideMargin: insideMargin,
      showIndication: showIndication,
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Text-only adapter matching the upstream `TextButton` overload.
class MiuixTextButton extends StatelessWidget {
  /// Creates a source-style text button.
  const MiuixTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.enabled = true,
    this.colors,
    double? cornerRadius,
    this.minWidth = MiuixButtonDefaults.minWidth,
    this.minHeight = MiuixButtonDefaults.minHeight,
    this.insideMargin = MiuixButtonDefaults.insideMargin,
    this.textStyle,
    this.showIndication = true,
  }) : _cornerRadius = cornerRadius;

  /// Creates the explicit MIUIX 1.0.9 text-button geometry.
  const MiuixTextButton.source({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.enabled = true,
    this.colors,
    double cornerRadius = MiuixButtonDefaults.legacyCornerRadius,
    this.minWidth = MiuixButtonDefaults.minWidth,
    this.minHeight = MiuixButtonDefaults.legacyMinHeight,
    this.insideMargin = MiuixButtonDefaults.legacyInsideMargin,
    this.textStyle,
    this.showIndication = true,
  }) : _cornerRadius = cornerRadius;

  /// Source text.
  final String label;

  /// Callback invoked by an enabled button.
  final VoidCallback? onPressed;

  /// Compatibility leading icon.
  ///
  /// The upstream TextButton is text-only, but keeping this optional adapter
  /// avoids breaking applications built against earlier Flutter releases.
  final Widget? icon;

  /// Whether the source surface installs its click behavior.
  final bool enabled;

  /// Explicit enabled and disabled text-button colors.
  final MiuixTextButtonColors? colors;

  /// Continuous-corner radius.
  double get cornerRadius => _cornerRadius ?? MiuixButtonDefaults.cornerRadius;
  final double? _cornerRadius;

  /// Minimum complete width.
  final double minWidth;

  /// Minimum complete height.
  final double minHeight;

  /// Padding around the label.
  final EdgeInsetsGeometry insideMargin;

  /// Optional text style forwarded by the current source `TextButton` API.
  ///
  /// A null value uses the MIUIX button typography. An explicit style keeps
  /// its own color when supplied and otherwise inherits the resolved enabled
  /// or disabled content color from the button surface.
  final TextStyle? textStyle;

  /// Whether the source indication is installed.
  final bool showIndication;

  @override
  Widget build(BuildContext context) {
    final textColors = colors ?? MiuixButtonDefaults.textButtonColors(context);
    final buttonColors = MiuixButtonColors(
      color: textColors.color,
      disabledColor: textColors.disabledColor,
      contentColor: textColors.textColor,
      disabledContentColor: textColors.disabledTextColor,
    );
    final effectiveEnabled = enabled && onPressed != null;
    final foreground = effectiveEnabled
        ? textColors.textColor
        : textColors.disabledTextColor;
    return _MiuixButtonSurface(
      content: _MiuixButtonLabelContent(
        label: label,
        icon: icon,
        color: foreground,
        textStyle: textStyle,
        allowWrapping: true,
      ),
      onPressed: onPressed,
      enabled: effectiveEnabled,
      colors: buttonColors,
      cornerRadius:
          _cornerRadius ?? MiuixTheme.of(context).hyperOs4.buttonCornerRadius,
      minWidth: minWidth,
      minHeight: minHeight,
      insideMargin: insideMargin,
      showIndication: showIndication,
    );
  }
}

/// Builds only the compatibility label; arbitrary content remains untouched.
class _MiuixButtonLabelContent extends StatelessWidget {
  const _MiuixButtonLabelContent({
    required this.label,
    required this.color,
    this.icon,
    this.textStyle,
    this.allowWrapping = false,
  });

  final String label;
  final Color color;
  final Widget? icon;
  final TextStyle? textStyle;
  final bool allowWrapping;

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
      color: color,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      fontSize: 17,
    );
    final resolvedTextStyle =
        textStyle?.copyWith(color: textStyle?.color ?? color) ??
        defaultTextStyle;
    final ratio = MediaQuery.devicePixelRatioOf(context);
    final scaledFontSize = MediaQuery.textScalerOf(
      context,
    ).scale(resolvedTextStyle?.fontSize ?? 17);
    final sourceLineHeight = _miuixCeilLogicalDimension(
      scaledFontSize * (resolvedTextStyle?.height ?? 1.16),
      ratio,
    );
    final labelText = Text(
      label,
      maxLines: allowWrapping ? null : 1,
      overflow: allowWrapping ? TextOverflow.clip : TextOverflow.ellipsis,
      softWrap: allowWrapping,
      style: resolvedTextStyle,
    );
    if (allowWrapping) {
      if (icon == null) {
        if (textStyle != null) return labelText;
        // Flutter rounds RenderParagraph height in logical pixels, while
        // Compose rounds the complete paragraph in physical pixels. This
        // proxy keeps the real Text child and derives the default multi-line
        // placeable height from the source line role and measured line count.
        return _MiuixButtonTextLineBox(
          text: label,
          style: resolvedTextStyle ?? const TextStyle(fontSize: 17),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
          pixelRatio: ratio,
          child: labelText,
        );
      }
      // 图标占用自身宽度，文字只使用父按钮剩余的有限宽度。
      // loose 约束仍保留短标签的自然宽度，长标签则按实际空间换行。
      // 不能把 Text 当作无界非弹性子项，否则窄屏和大字号会溢出。
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconTheme(
            data: IconThemeData(color: color, size: 16),
            child: icon!,
          ),
          const SizedBox(width: 6),
          Flexible(child: labelText),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          IconTheme(
            data: IconThemeData(color: color, size: 16),
            child: icon!,
          ),
          const SizedBox(width: 6),
        ],
        SizedBox(
          height: sourceLineHeight,
          child: Center(child: labelText),
        ),
      ],
    );
  }
}

/// Retains Compose's physical-pixel paragraph height around a Flutter Text.
///
/// The child remains a normal [Text] so selection, semantics, tests, and font
/// fallback all stay in Flutter's paragraph implementation. Only the outer
/// layout height is corrected after measuring how many lines the same style
/// creates at the available width.
class _MiuixButtonTextLineBox extends SingleChildRenderObjectWidget {
  const _MiuixButtonTextLineBox({
    required this.text,
    required this.style,
    required this.textDirection,
    required this.textScaler,
    required this.pixelRatio,
    required super.child,
  });

  final String text;
  final TextStyle style;
  final TextDirection textDirection;
  final TextScaler textScaler;
  final double pixelRatio;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderMiuixButtonTextLineBox(
      text: text,
      style: style,
      textDirection: textDirection,
      textScaler: textScaler,
      pixelRatio: pixelRatio,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderMiuixButtonTextLineBox renderObject,
  ) {
    renderObject
      ..text = text
      ..style = style
      ..textDirection = textDirection
      ..textScaler = textScaler
      ..pixelRatio = pixelRatio;
  }
}

class _RenderMiuixButtonTextLineBox extends RenderShiftedBox {
  _RenderMiuixButtonTextLineBox({
    required String text,
    required TextStyle style,
    required TextDirection textDirection,
    required TextScaler textScaler,
    required double pixelRatio,
  }) : _text = text,
       _style = style,
       _textDirection = textDirection,
       _textScaler = textScaler,
       _pixelRatio = pixelRatio,
       super(null);

  String _text;
  TextStyle _style;
  TextDirection _textDirection;
  TextScaler _textScaler;
  double _pixelRatio;

  set text(String value) {
    if (_text == value) return;
    _text = value;
    markNeedsLayout();
  }

  set style(TextStyle value) {
    if (_style == value) return;
    _style = value;
    markNeedsLayout();
  }

  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsLayout();
  }

  set textScaler(TextScaler value) {
    if (_textScaler == value) return;
    _textScaler = value;
    markNeedsLayout();
  }

  set pixelRatio(double value) {
    if (_pixelRatio == value) return;
    _pixelRatio = value;
    markNeedsLayout();
  }

  TextPainter _layoutPainter(double maxWidth) {
    final painter = TextPainter(
      text: TextSpan(text: _text, style: _style),
      textDirection: _textDirection,
      textScaler: _textScaler,
    );
    painter.layout(
      maxWidth: maxWidth.isFinite ? math.max(0, maxWidth) : double.infinity,
    );
    return painter;
  }

  double _sourceHeight(double maxWidth) {
    final painter = _layoutPainter(maxWidth);
    final lineCount = math.max(1, painter.computeLineMetrics().length);
    final scaledFontSize = _textScaler.scale(_style.fontSize ?? 17);
    final authoredHeight = scaledFontSize * (_style.height ?? 1.16) * lineCount;
    return (authoredHeight * _pixelRatio).ceil() / _pixelRatio;
  }

  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      size = constraints.smallest;
      return;
    }
    child.layout(constraints.loosen(), parentUsesSize: true);
    size = constraints.constrain(
      Size(child.size.width, _sourceHeight(constraints.maxWidth)),
    );
    final childData = child.parentData! as BoxParentData;
    childData.offset = Offset(
      (size.width - child.size.width) / 2,
      (size.height - child.size.height) / 2,
    );
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final painter = _layoutPainter(constraints.maxWidth);
    return constraints.constrain(
      Size(painter.width, _sourceHeight(constraints.maxWidth)),
    );
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return _layoutPainter(double.infinity).minIntrinsicWidth;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return _layoutPainter(double.infinity).maxIntrinsicWidth;
  }

  @override
  double computeMinIntrinsicHeight(double width) => _sourceHeight(width);

  @override
  double computeMaxIntrinsicHeight(double width) => _sourceHeight(width);

  @override
  void paint(PaintingContext context, Offset offset) {
    final child = this.child;
    if (child == null) return;
    final childData = child.parentData! as BoxParentData;
    context.paintChild(child, offset + childData.offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final child = this.child;
    if (child == null) return false;
    final childData = child.parentData! as BoxParentData;
    return result.addWithPaintOffset(
      offset: childData.offset,
      position: position,
      hitTest: (result, transformed) =>
          child.hitTest(result, position: transformed),
    );
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    final childData = child.parentData! as BoxParentData;
    transform.translateByDouble(childData.offset.dx, childData.offset.dy, 0, 1);
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    final child = this.child;
    if (child == null) return null;
    final childBaseline = child.getDistanceToActualBaseline(baseline);
    if (childBaseline == null) return null;
    final childData = child.parentData! as BoxParentData;
    return childBaseline + childData.offset.dy;
  }
}

/// Shared Surface/Row implementation used by both public button overloads.
class _MiuixButtonSurface extends StatefulWidget {
  const _MiuixButtonSurface({
    required this.content,
    required this.onPressed,
    required this.enabled,
    required this.colors,
    required this.cornerRadius,
    required this.minWidth,
    required this.minHeight,
    required this.insideMargin,
    required this.showIndication,
  });

  final Widget content;
  final VoidCallback? onPressed;
  final bool enabled;
  final MiuixButtonColors colors;
  final double cornerRadius;
  final double minWidth;
  final double minHeight;
  final EdgeInsetsGeometry insideMargin;
  final bool showIndication;

  @override
  State<_MiuixButtonSurface> createState() => _MiuixButtonSurfaceState();
}

class _MiuixButtonSurfaceState extends State<_MiuixButtonSurface> {
  bool _outsidePressed = false;

  /// Keeps malformed runtime geometry finite without changing valid zeroes.
  double _safeDimension(double value, double fallback) {
    if (!value.isFinite) return fallback;
    return math.max(0, value);
  }

  void _setOutsidePressed(bool value) {
    if (!mounted || _outsidePressed == value) return;
    setState(() => _outsidePressed = value);
  }

  @override
  void didUpdateWidget(covariant _MiuixButtonSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled && _outsidePressed) {
      _outsidePressed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final background = widget.enabled
        ? widget.colors.color
        : widget.colors.disabledColor;
    final foreground = widget.enabled
        ? widget.colors.contentColor
        : widget.colors.disabledContentColor;
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final safeMinWidth = _safeDimension(
      widget.minWidth,
      MiuixButtonDefaults.minWidth,
    );
    final safeMinHeight = _safeDimension(
      widget.minHeight,
      MiuixButtonDefaults.minHeight,
    );
    final safeCornerRadius = _safeDimension(
      widget.cornerRadius,
      MiuixButtonDefaults.cornerRadius,
    );
    final sourceMinWidth = _miuixRoundLogicalDimension(
      safeMinWidth,
      pixelRatio,
    );
    final sourceMinHeight = _miuixRoundLogicalDimension(
      safeMinHeight,
      pixelRatio,
    );
    final radius = BorderRadius.circular(safeCornerRadius);
    final ShapeBorder shape = MiuixTheme.of(context).enableSquircle
        ? MiuixSquircleBorder(borderRadius: radius)
        : RoundedRectangleBorder(borderRadius: radius);
    final buttonPadding = _miuixRoundedInsets(context, widget.insideMargin);
    final pressable = MiuixPressable(
      onTap: widget.enabled ? widget.onPressed : null,
      // Button.kt gives Surface and LocalIndication the same miuixShape.
      shape: shape,
      contentClipBuilder: (child) => MiuixSquircleSurface(
        color: background,
        borderRadius: radius,
        enabled: MiuixTheme.of(context).enableSquircle,
        child: child,
      ),
      feedbackType: MiuixPressFeedbackType.none,
      holdDown: _outsidePressed,
      showIndication: widget.enabled && widget.showIndication,
      child: DecoratedBox(
        key: const ValueKey('miuix-button-surface'),
        decoration: ShapeDecoration(color: background, shape: shape),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: sourceMinWidth,
            minHeight: sourceMinHeight,
          ),
          child: Padding(
            // Compose's Row centers its one logical content group and passes
            // the remaining finite width to Text. Align reproduces that
            // behavior while still supporting intrinsic dialog measurement.
            padding: buttonPadding,
            child: DefaultTextStyle.merge(
              style: TextStyle(color: foreground),
              child: IconTheme.merge(
                data: IconThemeData(color: foreground),
                child: Align(
                  alignment: Alignment.center,
                  widthFactor: 1,
                  heightFactor: 1,
                  child: widget.content,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return _MiuixButtonTouchTarget(
      enabled: widget.enabled,
      minimumSize: _miuixRoundLogicalDimension(
        MiuixButtonDefaults.minimumInteractiveSize,
        pixelRatio,
      ),
      onTap: widget.onPressed,
      onTapDown: () => _setOutsidePressed(true),
      onTapUp: () => _setOutsidePressed(false),
      onTapCancel: () => _setOutsidePressed(false),
      child: MiuixSurfaceTheme.wrapSurface(
        context,
        shape,
        background,
        pressable,
      ),
    );
  }
}

/// Bridges Compose's non-layout-affecting minimum interactive component size.
///
/// The ordinary child continues to own pointers inside the painted surface.
/// Only the narrow band outside that surface is handled here, avoiding two tap
/// recognizers competing for the same pointer while retaining the 48dp target.
class _MiuixButtonTouchTarget extends SingleChildRenderObjectWidget {
  const _MiuixButtonTouchTarget({
    required this.enabled,
    required this.minimumSize,
    required this.onTap,
    required this.onTapDown,
    required this.onTapUp,
    required this.onTapCancel,
    required super.child,
  });

  final bool enabled;
  final double minimumSize;
  final VoidCallback? onTap;
  final VoidCallback onTapDown;
  final VoidCallback onTapUp;
  final VoidCallback onTapCancel;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderMiuixButtonTouchTarget(
      enabled: enabled,
      minimumSize: minimumSize,
      onTap: onTap,
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      onTapCancel: onTapCancel,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderMiuixButtonTouchTarget renderObject,
  ) {
    renderObject
      ..enabled = enabled
      ..minimumSize = minimumSize
      ..onTap = onTap
      ..onTapDown = onTapDown
      ..onTapUp = onTapUp
      ..onTapCancel = onTapCancel;
  }
}

class _RenderMiuixButtonTouchTarget extends RenderProxyBox {
  _RenderMiuixButtonTouchTarget({
    required bool enabled,
    required double minimumSize,
    required VoidCallback? onTap,
    required VoidCallback onTapDown,
    required VoidCallback onTapUp,
    required VoidCallback onTapCancel,
  }) : _enabled = enabled,
       _minimumSize = minimumSize,
       _onTap = onTap,
       _onTapDown = onTapDown,
       _onTapUp = onTapUp,
       _onTapCancel = onTapCancel {
    _tapRecognizer = TapGestureRecognizer(debugOwner: this);
    _syncRecognizer();
  }

  late final TapGestureRecognizer _tapRecognizer;
  bool _enabled;
  double _minimumSize;
  VoidCallback? _onTap;
  VoidCallback _onTapDown;
  VoidCallback _onTapUp;
  VoidCallback _onTapCancel;

  bool get enabled => _enabled;
  set enabled(bool value) {
    if (_enabled == value) return;
    _enabled = value;
    _syncRecognizer();
    markNeedsSemanticsUpdate();
  }

  double get minimumSize => _minimumSize;
  set minimumSize(double value) {
    if (_minimumSize == value) return;
    _minimumSize = value;
    markNeedsSemanticsUpdate();
  }

  VoidCallback? get onTap => _onTap;
  set onTap(VoidCallback? value) {
    if (_onTap == value) return;
    _onTap = value;
    _syncRecognizer();
    markNeedsSemanticsUpdate();
  }

  VoidCallback get onTapDown => _onTapDown;
  set onTapDown(VoidCallback value) {
    if (_onTapDown == value) return;
    _onTapDown = value;
    _syncRecognizer();
  }

  VoidCallback get onTapUp => _onTapUp;
  set onTapUp(VoidCallback value) {
    if (_onTapUp == value) return;
    _onTapUp = value;
    _syncRecognizer();
  }

  VoidCallback get onTapCancel => _onTapCancel;
  set onTapCancel(VoidCallback value) {
    if (_onTapCancel == value) return;
    _onTapCancel = value;
    _syncRecognizer();
  }

  Rect get _interactiveBounds => Rect.fromCenter(
    center: size.center(Offset.zero),
    width: math.max(size.width, minimumSize),
    height: math.max(size.height, minimumSize),
  );

  void _syncRecognizer() {
    _tapRecognizer
      ..onTap = enabled ? _onTap : null
      ..onTapDown = enabled ? (_) => _onTapDown() : null
      ..onTapUp = enabled ? (_) => _onTapUp() : null
      ..onTapCancel = enabled ? _onTapCancel : null;
  }

  void _handleGlobalPointer(PointerEvent event) {
    if (event is! PointerDownEvent || !enabled || !attached || size.isEmpty) {
      return;
    }
    final localPosition = globalToLocal(event.position);
    if (!size.contains(localPosition) &&
        _interactiveBounds.contains(localPosition)) {
      // Flutter ancestors normally stop hit testing at their own measured
      // bounds. Compose's minimum interactive target is allowed to extend
      // beyond those bounds, so the render bridge joins the gesture arena from
      // the global pointer route only for the non-painted expansion band.
      _tapRecognizer.addPointer(event);
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (size.contains(position)) {
      // Let MiuixPressable retain its native hover, focus, and pointer state
      // for the painted portion of the button.
      return hitTestChildren(result, position: position);
    }
    // The global pointer route below owns the expansion. Returning false here
    // also prevents a permissive ancestor from registering a duplicate tap.
    return false;
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    GestureBinding.instance.pointerRouter.addGlobalRoute(_handleGlobalPointer);
  }

  @override
  void detach() {
    GestureBinding.instance.pointerRouter.removeGlobalRoute(
      _handleGlobalPointer,
    );
    super.detach();
  }

  @override
  Rect get semanticBounds => _interactiveBounds;

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config
      ..isSemanticBoundary = true
      ..isMergingSemanticsOfDescendants = true
      ..isButton = true
      ..isEnabled = enabled;
    if (enabled && _onTap != null) {
      config.onTap = _onTap;
    }
  }

  @override
  void dispose() {
    _tapRecognizer.dispose();
    super.dispose();
  }
}
