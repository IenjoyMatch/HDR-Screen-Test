import 'package:flutter/widgets.dart';

/// Optional application artwork resolver. Unresolved icons retain their source.
typedef MiuixIconResolver = IconData Function(IconData icon);

/// Optional independent vector/raster artwork. Returning null keeps the glyph.
/// The supplied icon retains the caller's sizing, tint and accessibility data.
typedef MiuixIconBuilder = Widget? Function(BuildContext context, Icon icon);

/// Captured by popup routes so application icon styles also reach controls.
class MiuixIconTheme extends InheritedTheme {
  /// Provides an opt-in resolver without changing default MIUIX artwork.
  const MiuixIconTheme({
    super.key,
    required this.resolve,
    this.builder,
    required super.child,
  });

  /// Maps a semantic source glyph to application artwork.
  final MiuixIconResolver resolve;

  /// Optional artwork replacement, captured by popup routes with this theme.
  final MiuixIconBuilder? builder;

  /// Resolves an icon through the nearest application scope, when installed.
  static IconData resolveOf(BuildContext context, IconData icon) =>
      context.dependOnInheritedWidgetOfExactType<MiuixIconTheme>()?.resolve(
        icon,
      ) ??
      icon;

  @override
  bool updateShouldNotify(MiuixIconTheme oldWidget) =>
      resolve != oldWidget.resolve || builder != oldWidget.builder;

  @override
  Widget wrap(BuildContext context, Widget child) =>
      MiuixIconTheme(resolve: resolve, builder: builder, child: child);
}

/// Flutter-compatible icon primitive that participates in [MiuixIconTheme].
/// Dimensions, accessibility, text direction and inherited tint are preserved.
class MiuixThemedIcon extends StatelessWidget {
  /// Creates an optionally themed icon; null retains Flutter's empty slot.
  const MiuixThemedIcon(
    this.icon, {
    super.key,
    this.size,
    this.fill,
    this.weight,
    this.grade,
    this.opticalSize,
    this.color,
    this.shadows,
    this.semanticLabel,
    this.textDirection,
    this.applyTextScaling,
    this.blendMode,
    this.fontWeight,
  });

  /// Original semantic glyph.
  final IconData? icon;

  /// Flutter icon size.
  final double? size;

  /// Variable font fill.
  final double? fill;

  /// Variable font weight.
  final double? weight;

  /// Variable font grade.
  final double? grade;

  /// Variable font optical size.
  final double? opticalSize;

  /// Explicit foreground; otherwise inherited.
  final Color? color;

  /// Optional icon shadows.
  final List<Shadow>? shadows;

  /// Accessibility description.
  final String? semanticLabel;

  /// Optional layout direction.
  final TextDirection? textDirection;

  /// Whether the icon follows text scaling.
  final bool? applyTextScaling;

  /// Compositing mode.
  final BlendMode? blendMode;

  /// Static font weight.
  final FontWeight? fontWeight;

  @override
  Widget build(BuildContext context) {
    final source = Icon(
      icon,
      size: size,
      fill: fill,
      weight: weight,
      grade: grade,
      opticalSize: opticalSize,
      color: color,
      shadows: shadows,
      semanticLabel: semanticLabel,
      textDirection: textDirection,
      applyTextScaling: applyTextScaling,
      blendMode: blendMode,
      fontWeight: fontWeight,
    );
    final theme = context.dependOnInheritedWidgetOfExactType<MiuixIconTheme>();
    final artwork = theme?.builder?.call(context, source);
    if (artwork != null) return artwork;
    return Icon(
      icon == null ? null : theme?.resolve(icon!) ?? icon,
      size: size,
      fill: fill,
      weight: weight,
      grade: grade,
      opticalSize: opticalSize,
      color: color,
      shadows: shadows,
      semanticLabel: semanticLabel,
      textDirection: textDirection,
      applyTextScaling: applyTextScaling,
      blendMode: blendMode,
      fontWeight: fontWeight,
    );
  }
}
