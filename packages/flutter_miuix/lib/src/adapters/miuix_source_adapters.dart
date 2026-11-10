import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../effects/miuix_effects.dart';
import '../widgets/miuix_widgets.dart';

/// Source-level adapters for public MIUIX functions that are not standalone
/// Flutter widgets in the main catalog.
///
/// MIUIX exposes several public helpers for Compose layout scopes, popup
/// internals, color conversion, and implementation details. Flutter does not
/// need identical low-level primitives, but keeping named adapters makes source
/// migration explicit and lets the parity scripts check those entry points.

/// Flutter-side color wrapper for MIUIX color helper entry points.
@immutable
class MiuixColor {
  /// Creates a color adapter.
  const MiuixColor(this.value);

  /// Wrapped Flutter color.
  final Color value;

  /// Creates a color from an ARGB integer.
  factory MiuixColor.fromARGB32(int value) {
    return MiuixColor(Color(value));
  }
}

/// Immutable Flutter adapter for the source backdrop effect scope.
///
/// The unnamed constructor remains a complete backdrop widget. Chain methods
/// return a new scope so configuration keeps Flutter widget immutability while
/// retaining the source's left-to-right effect vocabulary.
class MiuixBackdropEffectScope extends MiuixLayerBackdrop {
  /// Creates a backdrop scope.
  const MiuixBackdropEffectScope({
    super.key,
    required super.child,
    super.backdrop,
    super.radius,
    super.padding,
  });

  MiuixBackdropEffectScope _withBackdrop(MiuixBackdrop value) {
    return MiuixBackdropEffectScope(
      key: key,
      backdrop: value,
      radius: radius,
      padding: padding,
      child: child,
    );
  }

  /// Replaces the horizontal and vertical blur radii.
  MiuixBackdropEffectScope blur(double radiusX, [double? radiusY]) {
    return _withBackdrop(
      backdrop.copyWith(
        blur: radiusX,
        blurY: radiusY,
        clearBlurY: radiusY == null,
      ),
    );
  }

  /// Registers full-resolution noise when [coefficient] is positive.
  MiuixBackdropEffectScope noiseDither(double coefficient) {
    if (!coefficient.isFinite || coefficient <= 0) return this;
    return _withBackdrop(backdrop.copyWith(noise: coefficient));
  }

  /// Replaces the source tint, outline, opacity, and ordered blend layers.
  MiuixBackdropEffectScope blendColors(MiuixBlurColors colors) {
    return _withBackdrop(
      backdrop.copyWith(
        colors: colors,
        brightness: colors.brightness,
        contrast: colors.contrast,
        saturation: colors.saturation,
      ),
    );
  }

  /// Replaces brightness, contrast, and saturation controls.
  MiuixBackdropEffectScope colorControls({
    double brightness = 0,
    double contrast = 1,
    double saturation = 1,
  }) {
    return _withBackdrop(
      backdrop.copyWith(
        brightness: brightness,
        contrast: contrast,
        saturation: saturation,
      ),
    );
  }

  /// Appends an arbitrary engine image effect to the ordered chain.
  ///
  /// A shader effect must be supplied as `ImageFilter.shader` from a
  /// precompiled Flutter fragment program; Flutter does not compile AGSL text
  /// dynamically like the Compose runtime.
  MiuixBackdropEffectScope effect(ImageFilter value) {
    return _withBackdrop(
      backdrop.copyWith(effects: [...backdrop.effects, value]),
    );
  }

  /// Switches this scope to the source progressive variable-radius pipeline.
  MiuixProgressiveBackdropEffectScope progressiveBlur(
    double radiusX, {
    double? radiusY,
    MiuixProgressiveBlur gradient = MiuixProgressiveBlur.top,
  }) {
    return MiuixProgressiveBackdropEffectScope(
      key: key,
      backdrop: backdrop.copyWith(
        blur: radiusX,
        blurY: radiusY,
        clearBlurY: radiusY == null,
      ),
      gradient: gradient,
      radius: radius ?? 0,
      child: padding == null ? child : Padding(padding: padding!, child: child),
    );
  }

  /// Applies the standard texture-blur preset in one operation.
  MiuixBackdropEffectScope textureBlurEffect({
    required double blurRadiusX,
    double? blurRadiusY,
    double noiseCoefficient = MiuixBlurDefaults.noiseCoefficient,
    MiuixBlurColors colors = const MiuixBlurColors(),
    double? brightness,
    double? contrast,
    double? saturation,
  }) {
    final clampedX = _clampMiuixSourceBlurRadius(blurRadiusX);
    final requestedY = blurRadiusY ?? blurRadiusX;
    final clampedY = _clampMiuixSourceBlurRadius(requestedY);
    return _withBackdrop(
      backdrop.copyWith(
        blur: clampedX,
        blurY: clampedY,
        noise: noiseCoefficient.isFinite && noiseCoefficient > 0
            ? noiseCoefficient
            : backdrop.noise,
        brightness: brightness ?? colors.brightness,
        contrast: contrast ?? colors.contrast,
        saturation: saturation ?? colors.saturation,
        colors: colors,
      ),
    );
  }

  /// Applies the progressive texture-blur preset in one operation.
  MiuixProgressiveBackdropEffectScope progressiveTextureBlurEffect({
    required double blurRadiusX,
    double? blurRadiusY,
    MiuixProgressiveBlur gradient = MiuixProgressiveBlur.top,
    double noiseCoefficient = MiuixBlurDefaults.progressiveNoiseCoefficient,
    MiuixBlurColors colors = const MiuixBlurColors(),
    double? brightness,
    double? contrast,
    double? saturation,
  }) {
    final requestedY = blurRadiusY ?? blurRadiusX;
    return MiuixProgressiveBackdropEffectScope(
      key: key,
      backdrop: backdrop.copyWith(
        blur: _clampMiuixSourceBlurRadius(blurRadiusX),
        blurY: _clampMiuixSourceBlurRadius(requestedY),
        noise: noiseCoefficient.isFinite && noiseCoefficient > 0
            ? noiseCoefficient
            : backdrop.noise,
        brightness: brightness ?? colors.brightness,
        contrast: contrast ?? colors.contrast,
        saturation: saturation ?? colors.saturation,
        colors: colors,
      ),
      gradient: gradient,
      radius: radius ?? 0,
      child: padding == null ? child : Padding(padding: padding!, child: child),
    );
  }
}

/// Progressive result of a [MiuixBackdropEffectScope] chain.
///
/// It remains immutable and keeps the same post-effect vocabulary, allowing a
/// custom filter to be appended after `progressiveBlur` just like the source
/// receiver scope.
class MiuixProgressiveBackdropEffectScope
    extends MiuixProgressiveLayerBackdrop {
  /// Creates a progressive effect scope.
  const MiuixProgressiveBackdropEffectScope({
    super.key,
    required super.child,
    super.backdrop,
    super.gradient,
    super.radius,
  });

  MiuixProgressiveBackdropEffectScope _withBackdrop(MiuixBackdrop value) {
    return MiuixProgressiveBackdropEffectScope(
      key: key,
      backdrop: value,
      gradient: gradient,
      radius: radius,
      child: child,
    );
  }

  /// Registers full-resolution noise when [coefficient] is positive.
  MiuixProgressiveBackdropEffectScope noiseDither(double coefficient) {
    if (!coefficient.isFinite || coefficient <= 0) return this;
    return _withBackdrop(backdrop.copyWith(noise: coefficient));
  }

  /// Replaces the source tint, outline, opacity, and ordered blend layers.
  MiuixProgressiveBackdropEffectScope blendColors(MiuixBlurColors colors) {
    return _withBackdrop(
      backdrop.copyWith(
        colors: colors,
        brightness: colors.brightness,
        contrast: colors.contrast,
        saturation: colors.saturation,
      ),
    );
  }

  /// Replaces brightness, contrast, and saturation controls.
  MiuixProgressiveBackdropEffectScope colorControls({
    double brightness = 0,
    double contrast = 1,
    double saturation = 1,
  }) {
    return _withBackdrop(
      backdrop.copyWith(
        brightness: brightness,
        contrast: contrast,
        saturation: saturation,
      ),
    );
  }

  /// Appends an arbitrary engine effect after the progressive recipe.
  MiuixProgressiveBackdropEffectScope effect(ImageFilter value) {
    return _withBackdrop(
      backdrop.copyWith(effects: [...backdrop.effects, value]),
    );
  }

  /// Replaces the progressive radii and gradient without losing post effects.
  MiuixProgressiveBackdropEffectScope progressiveBlur(
    double radiusX, {
    double? radiusY,
    MiuixProgressiveBlur? gradient,
  }) {
    return MiuixProgressiveBackdropEffectScope(
      key: key,
      backdrop: backdrop.copyWith(
        blur: radiusX,
        blurY: radiusY,
        clearBlurY: radiusY == null,
      ),
      gradient: gradient ?? this.gradient,
      radius: radius,
      child: child,
    );
  }
}

double _clampMiuixSourceBlurRadius(double value) {
  return value.isFinite
      ? value.clamp(0.0, MiuixBlurDefaults.maxBlurRadius)
      : 0.0;
}

/// Drawing scope marker for MIUIX highlight helpers.
@immutable
class MiuixDrawScope {
  /// Creates a drawing scope marker.
  const MiuixDrawScope({this.size = Size.zero});

  /// Logical drawing size.
  final Size size;
}

/// Drawing transform marker for MIUIX highlight helpers.
@immutable
class MiuixDrawTransform {
  /// Creates a drawing transform marker.
  const MiuixDrawTransform({this.rotation = 0, this.scale = 1});

  /// Rotation in radians.
  final double rotation;

  /// Scale multiplier.
  final double scale;
}

/// Floating navigation item adapter.
class MiuixFloatingNavigationBarItem extends MiuixNavigationItem {
  /// Creates a floating navigation item.
  const MiuixFloatingNavigationBarItem({
    required super.icon,
    required super.label,
    super.selectedIcon,
    super.badge,
    super.layoutLabel,
    super.enabled,
  });
}

/// Renders the popup and dialog states owned by the current [MiuixScaffold].
///
/// The unnamed no-child form matches upstream `MiuixPopupHost()`: it is a
/// visual host slot and does not create another popup state scope. Supplying
/// [child], or using [MiuixPopupHost.scope], retains the package's historical
/// standalone nested-scope adapter.
class MiuixPopupHost extends StatefulWidget {
  /// Creates the source host renderer.
  ///
  /// [child] is optional only for backward compatibility. New standalone
  /// scope call sites should use [MiuixPopupHost.scope] explicitly.
  const MiuixPopupHost({super.key, this.child});

  /// Creates an independently scoped host around [child].
  // The field remains nullable because the source constructor has no child.
  const MiuixPopupHost.scope({super.key, required Widget child})
    // ignore: prefer_initializing_formals
    : child = child;

  /// Compatibility subtree, or null for the source renderer.
  final Widget? child;

  @override
  State<MiuixPopupHost> createState() => _MiuixPopupHostState();
}

class _MiuixPopupHostState extends State<MiuixPopupHost> {
  MiuixPopupHostController? _controller;
  MiuixPopupHostController? _parent;

  bool get _ownsScope => widget.child != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _synchronizeOwnedController();
  }

  @override
  void didUpdateWidget(covariant MiuixPopupHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.child == null) != (widget.child == null)) {
      _synchronizeOwnedController();
    }
  }

  void _synchronizeOwnedController() {
    if (!_ownsScope) {
      _controller?.dispose();
      _controller = null;
      _parent = null;
      return;
    }
    final parent = MiuixPopupHostScope.maybeOf(context);
    if (_controller == null || parent != _parent) {
      _controller?.dispose();
      _parent = parent;
      _controller = MiuixPopupHostController(parent: parent);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.child;
    if (child == null) {
      // Scaffold supplies the state scope outside its complete layout. The
      // source host only paints that controller's entries in the popup slot.
      final controller = MiuixPopupHostScope.maybeOf(context);
      return controller == null
          ? const SizedBox.shrink()
          : MiuixPopupHostView(controller: controller);
    }

    final controller = _controller!;
    return MiuixPopupHostScope(
      controller: controller,
      child: Stack(
        children: [
          child,
          Positioned.fill(
            child: controller.parent == null
                ? MiuixPopupHostView(controller: controller)
                : ClipRect(
                    key: const ValueKey('miuix-popup-host-clip'),
                    child: MiuixPopupHostView(controller: controller),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Modifier adapter for source migration.
@immutable
class MiuixModifier {
  /// Creates a modifier adapter.
  const MiuixModifier([this.builder]);

  /// Optional widget transform.
  final Widget Function(Widget child)? builder;

  /// Applies the modifier to a child.
  Widget apply(Widget child) {
    return builder?.call(child) ?? child;
  }
}

/// Path adapter used by squircle and shape migration code.
@immutable
class MiuixPath {
  /// Creates a path adapter.
  const MiuixPath(this.path);

  /// Wrapped Flutter path.
  final Path path;
}

/// Overlay dropdown dialog adapter.
class MiuixOverlayDropdownDialog<T> extends MiuixOverlayListPopup<T> {
  /// Creates an overlay dropdown dialog.
  const MiuixOverlayDropdownDialog({
    super.key,
    required super.entries,
    required super.onSelected,
  });

  /// Shows the current grouped dropdown content in a Scaffold overlay dialog.
  static Future<void> show<S>({
    required BuildContext context,
    required String title,
    required String dialogButtonString,
    List<MiuixDropdownEntry<S>> entries = const [],
    List<MiuixDropdownGroup<S>> groups = const [],
    required ValueChanged<S> onSelected,
    MiuixDropdownColors? dropdownColors,
    bool renderInRootScaffold = true,
    bool? collapseOnSelection,
    Widget Function(Widget child)? surfaceBuilder,
    VoidCallback? onDismissRequest,
    VoidCallback? onDismissFinished,
  }) {
    return _showMiuixSourceDropdownDialog<S>(
      context: context,
      title: title,
      dialogButtonString: dialogButtonString,
      entries: entries,
      groups: groups,
      onSelected: onSelected,
      dropdownColors: dropdownColors,
      presentation: MiuixPopupPresentation.overlay,
      renderInRootScaffold: renderInRootScaffold,
      collapseOnSelection: collapseOnSelection,
      surfaceBuilder: surfaceBuilder,
      onDismissRequest: onDismissRequest,
      onDismissFinished: onDismissFinished,
    );
  }
}

/// Overlay dropdown popup adapter.
class MiuixOverlayDropdownPopup<T> extends MiuixOverlayListPopup<T> {
  /// Creates an overlay dropdown popup.
  const MiuixOverlayDropdownPopup({
    super.key,
    required super.entries,
    required super.onSelected,
  });

  /// Shows the current source rows in the nearest Scaffold popup host.
  static Future<void> show<S>({
    required BuildContext context,
    List<MiuixDropdownEntry<S>> entries = const [],
    List<MiuixDropdownGroup<S>> groups = const [],
    required ValueChanged<S> onSelected,
    LayerLink? link,
    MiuixPopupAlignment alignment = MiuixPopupAlignment.end,
    double? maxHeight,
    MiuixDropdownColors? dropdownColors,
    bool renderInRootScaffold = true,
    bool? collapseOnSelection,
    VoidCallback? onDismissRequest,
    VoidCallback? onDismissFinished,
  }) {
    return MiuixOverlayListPopup.show<S>(
      context: context,
      entries: entries,
      groups: groups,
      onSelected: onSelected,
      link: link,
      alignment: alignment,
      maxHeight: maxHeight,
      colors: dropdownColors,
      sourceRows: true,
      renderInRootScaffold: renderInRootScaffold,
      closeOnSelection:
          collapseOnSelection ?? _singleMiuixDropdownGroup(entries, groups),
      onDismissRequest: onDismissRequest,
      onDismissFinished: onDismissFinished,
    );
  }
}

/// Window dropdown dialog adapter.
class MiuixWindowDropdownDialog<T> extends MiuixWindowListPopup<T> {
  /// Creates a window dropdown dialog.
  const MiuixWindowDropdownDialog({
    super.key,
    required super.entries,
    required super.onSelected,
  });

  /// Shows the current grouped dropdown content in a root window dialog.
  static Future<void> show<S>({
    required BuildContext context,
    required String title,
    required String dialogButtonString,
    List<MiuixDropdownEntry<S>> entries = const [],
    List<MiuixDropdownGroup<S>> groups = const [],
    required ValueChanged<S> onSelected,
    MiuixDropdownColors? dropdownColors,
    bool? collapseOnSelection,
    Widget Function(Widget child)? surfaceBuilder,
    VoidCallback? onDismissRequest,
    VoidCallback? onDismissFinished,
  }) {
    return _showMiuixSourceDropdownDialog<S>(
      context: context,
      title: title,
      dialogButtonString: dialogButtonString,
      entries: entries,
      groups: groups,
      onSelected: onSelected,
      dropdownColors: dropdownColors,
      presentation: MiuixPopupPresentation.window,
      renderInRootScaffold: true,
      collapseOnSelection: collapseOnSelection,
      surfaceBuilder: surfaceBuilder,
      onDismissRequest: onDismissRequest,
      onDismissFinished: onDismissFinished,
    );
  }
}

/// Window dropdown popup adapter.
class MiuixWindowDropdownPopup<T> extends MiuixWindowListPopup<T> {
  /// Creates a window dropdown popup.
  const MiuixWindowDropdownPopup({
    super.key,
    required super.entries,
    required super.onSelected,
  });

  /// Shows the current source rows in a root Navigator popup route.
  static Future<void> show<S>({
    required BuildContext context,
    List<MiuixDropdownEntry<S>> entries = const [],
    List<MiuixDropdownGroup<S>> groups = const [],
    required ValueChanged<S> onSelected,
    LayerLink? link,
    MiuixPopupAlignment alignment = MiuixPopupAlignment.end,
    double? maxHeight,
    MiuixDropdownColors? dropdownColors,
    bool? collapseOnSelection,
    VoidCallback? onDismissRequest,
    VoidCallback? onDismissFinished,
  }) {
    return MiuixWindowListPopup.show<S>(
      context: context,
      entries: entries,
      groups: groups,
      onSelected: onSelected,
      link: link,
      alignment: alignment,
      maxHeight: maxHeight,
      colors: dropdownColors,
      sourceRows: true,
      closeOnSelection:
          collapseOnSelection ?? _singleMiuixDropdownGroup(entries, groups),
      onDismissRequest: onDismissRequest,
      onDismissFinished: onDismissFinished,
    );
  }
}

bool _singleMiuixDropdownGroup<S>(
  List<MiuixDropdownEntry<S>> entries,
  List<MiuixDropdownGroup<S>> groups,
) {
  final visibleGroupCount =
      groups.where((group) => group.entries.isNotEmpty).length +
      (entries.isEmpty ? 0 : 1);
  return visibleGroupCount <= 1;
}

Future<void> _showMiuixSourceDropdownDialog<S>({
  required BuildContext context,
  required String title,
  required String dialogButtonString,
  required List<MiuixDropdownEntry<S>> entries,
  required List<MiuixDropdownGroup<S>> groups,
  required ValueChanged<S> onSelected,
  required MiuixDropdownColors? dropdownColors,
  required MiuixPopupPresentation presentation,
  required bool renderInRootScaffold,
  required bool? collapseOnSelection,
  required Widget Function(Widget child)? surfaceBuilder,
  required VoidCallback? onDismissRequest,
  required VoidCallback? onDismissFinished,
}) {
  final host = MiuixPopupHostScope.maybeOf(context);
  final overlayHost = renderInRootScaffold ? host?.root : host;
  final navigator = Navigator.maybeOf(context, rootNavigator: true);
  final closeOnSelection =
      collapseOnSelection ?? _singleMiuixDropdownGroup(entries, groups);

  void dismiss() {
    if (presentation == MiuixPopupPresentation.overlay) {
      overlayHost?.dismissTop();
    } else if (navigator?.mounted == true && navigator!.canPop()) {
      navigator.pop();
    }
  }

  void select(S value) {
    onSelected(value);
    if (closeOnSelection) dismiss();
  }

  Widget contentBuilder(BuildContext context) {
    return Flexible(
      fit: FlexFit.loose,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            fit: FlexFit.loose,
            child: SingleChildScrollView(
              child: MiuixListPopup<S>(
                entries: entries,
                groups: groups,
                onSelected: select,
                sourceRows: true,
                dialogMode: true,
                colors:
                    dropdownColors ??
                    MiuixDropdownDefaults.dialogColors(context),
                showSurface: false,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(
              start: 24,
              top: 12,
              end: 24,
            ),
            child: SizedBox(
              width: double.infinity,
              child: MiuixTextButton(
                label: dialogButtonString,
                minHeight: 50,
                onPressed: dismiss,
              ),
            ),
          ),
        ],
      ),
    );
  }

  final content = Builder(builder: contentBuilder);
  return presentation == MiuixPopupPresentation.overlay
      ? MiuixOverlayDialog.show<void>(
          context: context,
          title: title,
          content: content,
          insideMargin: const EdgeInsets.symmetric(vertical: 24),
          renderInRootScaffold: renderInRootScaffold,
          surfaceBuilder: surfaceBuilder,
          onDismissRequest: onDismissRequest,
          onDismissFinished: onDismissFinished,
        )
      : MiuixWindowDialog.show<void>(
          context: context,
          title: title,
          content: content,
          insideMargin: const EdgeInsets.symmetric(vertical: 24),
          surfaceBuilder: surfaceBuilder,
          onDismissRequest: onDismissRequest,
          onDismissFinished: onDismissFinished,
        );
}

/// Radio button alias matching the MIUIX source name.
class MiuixRadioButton<T> extends MiuixRadio<T> {
  /// Creates a radio button.
  const MiuixRadioButton({
    super.key,
    required super.value,
    required super.groupValue,
    required super.onChanged,
    super.enabled,
    super.colors,
  });

  /// Creates the source `selected` plus direct `onClick` API.
  static MiuixRadioButton<bool> source({
    Key? key,
    required bool selected,
    required VoidCallback? onClick,
    bool enabled = true,
    MiuixRadioButtonColors? colors,
  }) {
    return MiuixRadioButton<bool>(
      key: key,
      value: true,
      groupValue: selected,
      enabled: enabled,
      colors: colors,
      onChanged: onClick == null ? null : (_) => onClick(),
    );
  }
}

/// Row scope marker for navigation item migration.
@immutable
class MiuixRowScope {
  /// Creates a row scope marker.
  const MiuixRowScope();
}

/// Runtime shader descriptor.
@immutable
class MiuixRuntimeShader {
  /// Creates a runtime shader descriptor.
  const MiuixRuntimeShader({required this.name, this.source});

  /// Shader name or asset key.
  final String name;

  /// Optional shader source.
  final String? source;
}

/// Tab row alias matching MIUIX source naming.
class MiuixTabRow extends MiuixTabBar {
  /// Creates a HyperOS 4 glass tab row.
  const MiuixTabRow({
    super.key,
    required super.tabs,
    super.controller,
    super.selectedTabIndex,
    super.onTabSelected,
    super.onTap,
    super.colors,
    super.minWidth,
    super.maxWidth,
    super.height,
    super.cornerRadius,
    super.itemSpacing,
    super.contentAlignment,
    super.interactionSource,
    super.showIndication,
    super.glass,
    super.glassBlur,
    super.glassOpacity,
  });

  /// Creates the previous MIUIX 1.0.9 ordinary tab row explicitly.
  const MiuixTabRow.source({
    super.key,
    required super.tabs,
    super.controller,
    super.selectedTabIndex,
    super.onTabSelected,
    super.onTap,
    super.colors,
    super.minWidth,
    super.maxWidth,
    super.height,
    super.cornerRadius,
    super.itemSpacing,
    super.contentAlignment,
    super.interactionSource,
    super.showIndication,
    super.glass,
    super.glassBlur,
    super.glassOpacity,
  }) : super.source();
}

/// Contoured tab row alias.
class MiuixTabRowWithContour extends MiuixTabBar {
  /// Creates a HyperOS 4 glass tab row through the contour API.
  const MiuixTabRowWithContour({
    super.key,
    required super.tabs,
    super.controller,
    super.selectedTabIndex,
    super.onTabSelected,
    super.onTap,
    super.colors,
    super.minWidth,
    super.maxWidth,
    super.height,
    super.cornerRadius,
    super.itemSpacing,
    super.contentAlignment,
    super.interactionSource,
    super.showIndication,
    super.glass,
    super.glassBlur,
    super.glassOpacity,
  }) : super.contour();

  /// Creates the previous MIUIX 1.0.9 contoured tab row explicitly.
  const MiuixTabRowWithContour.source({
    super.key,
    required super.tabs,
    super.controller,
    super.selectedTabIndex,
    super.onTabSelected,
    super.onTap,
    super.colors,
    super.minWidth,
    super.maxWidth,
    super.height,
    super.cornerRadius,
    super.itemSpacing,
    super.contentAlignment,
    super.interactionSource,
    super.showIndication,
    super.glass,
    super.glassBlur,
    super.glassOpacity,
  }) : super.contourSource();
}

/// Tooltip scope marker for source migration.
@immutable
class MiuixTooltipScope {
  /// Creates a tooltip scope marker.
  const MiuixTooltipScope();
}
