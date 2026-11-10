import 'package:flutter/widgets.dart';

/// Interaction metadata for opt-in application icon motion. This scope never
/// changes hit testing, semantics, callbacks or the default MIUIX appearance.
class MiuixIconInteraction extends InheritedWidget {
  const MiuixIconInteraction({
    super.key,
    required super.child,
    this.enabled = true,
    this.pressed = false,
    this.selected = false,
    this.activation = 0,
    this.navigation = false,
  });

  final bool enabled;
  final bool pressed;
  final bool selected;

  /// Increments only after a successful activation, never on gesture cancel.
  final int activation;

  /// Navigation selection owns its animation independently of page entrance.
  final bool navigation;

  static MiuixIconInteraction? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MiuixIconInteraction>();

  @override
  bool updateShouldNotify(MiuixIconInteraction oldWidget) =>
      enabled != oldWidget.enabled ||
      pressed != oldWidget.pressed ||
      selected != oldWidget.selected ||
      activation != oldWidget.activation ||
      navigation != oldWidget.navigation;
}
