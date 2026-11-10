part of '../miuix_widgets.dart';

/// Defaults from MIUIX v1.0.9 `SmallTitleDefaults`.
abstract final class MiuixSmallTitleDefaults {
  /// Default source inside margin: 28dp horizontally and 8dp vertically.
  static const EdgeInsets insideMargin = EdgeInsets.symmetric(
    horizontal: 28,
    vertical: 8,
  );

  /// Project-calibrated inset for HyperOS 4 content-group headings.
  static const EdgeInsets hyperOs4InsideMargin = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 10,
  );
}

/// Small title label for grouped lists and secondary sections.
///
/// This is the direct Flutter counterpart of `SmallTitle.kt`: it applies the
/// caller-equivalent outer widget constraints first, then source inside
/// padding, and finally the MIUIX subtitle text role.
class MiuixSmallTitle extends StatelessWidget {
  /// Creates a HyperOS 4 content-group heading.
  const MiuixSmallTitle(
    this.title, {
    super.key,
    this.textColor,
    this.insideMargin,
    this.textStyle,
  }) : _sourceStyle = false;

  /// Creates the former 14sp bold title with 28×8dp source padding.
  const MiuixSmallTitle.source(
    this.title, {
    super.key,
    this.textColor,
    this.insideMargin,
    this.textStyle,
  }) : _sourceStyle = true;

  /// Title text.
  final String title;

  /// Source-name alias retained alongside the existing [title] field.
  String get text => title;

  /// Optional title color, defaulting to `onBackgroundVariant`.
  final Color? textColor;

  /// Optional source-compatible padding around the label.
  ///
  /// Null resolves to [MiuixSmallTitleDefaults.insideMargin].
  final EdgeInsetsGeometry? insideMargin;

  /// Optional typography override merged after the selected visual baseline.
  final TextStyle? textStyle;

  final bool _sourceStyle;

  @override
  Widget build(BuildContext context) {
    final semantic = MiuixSemanticColors.of(context);
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final padding = _miuixRoundedInsets(
      context,
      insideMargin ??
          (_sourceStyle
              ? MiuixSmallTitleDefaults.insideMargin
              : MiuixSmallTitleDefaults.hyperOs4InsideMargin),
    );
    final foreground =
        textColor ??
        textStyle?.color ??
        (_sourceStyle
            ? semantic['onBackgroundVariant']
            : semantic['onSurfaceSecondary']);
    final baseline = Theme.of(context).textTheme.titleSmall?.copyWith(
      // Compose uses onBackgroundVariant, not Material's unrelated
      // onSurfaceVariant role, for grouped-list section labels.
      color: foreground,
      fontSize: _sourceStyle ? 14 : 15,
      height: _sourceStyle ? 1.16 : 1.2,
      fontWeight: _sourceStyle ? FontWeight.w700 : FontWeight.w600,
      letterSpacing: 0,
    );
    final style = baseline?.merge(textStyle).copyWith(color: foreground);
    final fontSize = MediaQuery.textScalerOf(
      context,
    ).scale(style?.fontSize ?? (_sourceStyle ? 14 : 15));
    // Text scaling is applied before physical rounding for the same reason
    // Compose converts `sp` through scaledDensity before measuring Text. This
    // keeps accessibility font sizes responsive instead of freezing the label
    // at the default 43px line box used by the reference emulator. Rounding
    // only the minimum line height also lets a wrapped title grow naturally.
    final sourceLineHeight = _miuixRoundLogicalDimension(
      fontSize * (style?.height ?? (_sourceStyle ? 1.16 : 1.2)),
      pixelRatio,
    );
    return Padding(
      // SmallTitleDefaults.InsideMargin is PaddingValues(28.dp, 8.dp).
      // Compose resolves every padding edge and the text placeable to integer
      // physical pixels before adding them. Keep those stages separate so a
      // 2.625-density Android screen measures 21 + 43 + 21 = 85px rather than
      // Flutter's former 84px combined result. The minimum remains flexible
      // so accessibility scaling and exceptionally long labels can grow.
      padding: padding,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: sourceLineHeight),
        child: MiuixText(
          title,
          color: foreground,
          style: style,
          // Android's Chinese fallback font has a taller natural line box
          // than the upstream 14sp subtitle role. Compose still measures the
          // declared role as one 43px line at 420dpi, so force that strut for
          // every translated line while allowing ordinary soft wrapping.
          strutStyle: StrutStyle(
            fontSize: style?.fontSize ?? (_sourceStyle ? 14 : 15),
            height: sourceLineHeight / fontSize,
            forceStrutHeight: true,
          ),
        ),
      ),
    );
  }
}
