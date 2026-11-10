import 'package:flutter/widgets.dart';

/// Optional surface artwork around existing content, without changing interaction.
/// Implementations must preserve the child's size, focus and semantics.
typedef MiuixSurfaceDecorator =
    Widget Function(
      BuildContext context,
      ShapeBorder shape,
      Color color,
      Widget child,
    );

/// Captures an application's surface treatment into menus and popup routes.
/// Without this scope MIUIX paints its original surfaces unchanged.
class MiuixSurfaceTheme extends InheritedTheme {
  const MiuixSurfaceTheme({
    super.key,
    required this.decorate,
    required super.child,
  });
  final MiuixSurfaceDecorator decorate;
  static Widget wrapSurface(
    BuildContext context,
    ShapeBorder shape,
    Color color,
    Widget child,
  ) =>
      context.dependOnInheritedWidgetOfExactType<MiuixSurfaceTheme>()?.decorate(
        context,
        shape,
        color,
        child,
      ) ??
      child;
  @override
  bool updateShouldNotify(MiuixSurfaceTheme oldWidget) =>
      decorate != oldWidget.decorate;
  @override
  Widget wrap(BuildContext context, Widget child) =>
      MiuixSurfaceTheme(decorate: decorate, child: child);
}
