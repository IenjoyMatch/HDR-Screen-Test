import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../effects/miuix_effects.dart';
import '../../platform/miuix_haptics.dart';
import '../../theme/miuix_semantic_colors.dart';
import '../../theme/miuix_theme.dart';
import '../../widgets/miuix_widgets.dart';

/// One typed action in a [MiuixContextMenu].
@immutable
class MiuixContextMenuItem<T> {
  /// Creates a context-menu action.
  const MiuixContextMenuItem({
    required this.value,
    required this.label,
    this.icon,
    this.enabled = true,
    this.destructive = false,
    this.separatorBefore = false,
  });

  /// Value returned when this action is accepted.
  final T value;

  /// Visible action label and optional leading icon.
  final String label;
  final Widget? icon;

  /// Interaction and visual roles.
  final bool enabled;
  final bool destructive;
  final bool separatorBefore;
}

/// Theme colors for context menus.
@immutable
class MiuixContextMenuColors {
  /// Creates a complete context-menu palette.
  const MiuixContextMenuColors({
    required this.background,
    required this.foreground,
    required this.disabledForeground,
    required this.destructive,
    required this.divider,
  });

  /// Popup and action roles.
  final Color background;
  final Color foreground;
  final Color disabledForeground;
  final Color destructive;
  final Color divider;
}

/// Geometry and palette defaults for [MiuixContextMenu].
abstract final class MiuixContextMenuDefaults {
  // HyperOS 4 context-menu implementation contract:
  // - The ordinary entry is a local sampled-glass popup, not a solid card.
  // - Its width follows authored content between theme-owned safe bounds.
  // - Its height follows the action count until the usable window is reached.
  // - Overflow then scrolls inside the clipped panel instead of leaving screen.
  // - Placement is computed from the final child size, never an estimate.
  // - Both axes remain inside the safe-area-local window margin.
  // - Short menus therefore do not inherit the height of the complete screen.
  // - The opening transform retains spatial continuity at the trigger edge.
  // - Reduced motion installs the final route frame immediately.
  // - Opening and successful selection retain distinct haptic roles.
  // - Disabled actions remain visible but publish no tap callback.
  // - Destructive actions resolve through the semantic error channel.
  // - Dividers are weak and inset from the glass silhouette in the new style.
  // - Popup blur, tint, corner, and geometry remain locally theme-overridable.
  // - Global five-level glass intensity still modifies the supplied material.
  // - The source entry remains fixed, opaque, and geometrically unchanged.
  // These are project-calibrated implementation rules derived from the public
  // design specification, not unpublished Xiaomi developer measurements.

  /// Legacy fixed width and action height retained by `.source` APIs.
  static const double sourceWidth = 220;
  static const double sourceItemHeight = 48;

  /// Legacy fixed corner, edge margin, and content geometry.
  static const double sourceCornerRadius = 18;
  static const double sourceScreenMargin = 12;
  static const double sourceHorizontalPadding = 14;
  static const double sourceIconSpacing = 12;
  static const double sourceVerticalPadding = 6;
  static const double sourceShadowElevation = 14;

  /// Backward-compatible names for the former fixed public defaults.
  static const double width = sourceWidth;
  static const double itemHeight = sourceItemHeight;
  static const double cornerRadius = sourceCornerRadius;
  static const double screenMargin = sourceScreenMargin;

  /// Resolves the current theme roles.
  static MiuixContextMenuColors colors(BuildContext context) {
    final semantic = MiuixSemanticColors.of(context);
    return MiuixContextMenuColors(
      background: semantic['surfaceVariant'],
      foreground: semantic['onSurface'],
      disabledForeground: semantic['disabledOnSurface'],
      destructive: semantic['error'],
      divider: semantic['dividerLine'],
    );
  }
}

/// Observable route owner for programmatic context-menu use.
class MiuixContextMenuController extends ChangeNotifier {
  bool _isOpen = false;
  bool _disposed = false;

  /// Whether a menu opened by this controller is currently visible.
  bool get isOpen => _isOpen;

  /// Opens a menu and returns the selected typed value.
  Future<T?> show<T>({
    required BuildContext context,
    required Offset position,
    required List<MiuixContextMenuItem<T>> items,
    MiuixContextMenuColors? colors,
  }) async {
    if (_disposed || _isOpen) return null;
    _isOpen = true;
    notifyListeners();
    try {
      return await MiuixContextMenu.show<T>(
        context: context,
        position: position,
        items: items,
        colors: colors,
      );
    } finally {
      _isOpen = false;
      // A controller can be owned by a page that disappears while its root
      // popup route is still reversing. ChangeNotifier rejects notifications
      // after dispose, so completion becomes state-only in that situation.
      if (!_disposed) notifyListeners();
    }
  }

  /// Opens the former fixed-width opaque context menu.
  Future<T?> showSource<T>({
    required BuildContext context,
    required Offset position,
    required List<MiuixContextMenuItem<T>> items,
    MiuixContextMenuColors? colors,
  }) async {
    if (_disposed || _isOpen) return null;
    _isOpen = true;
    notifyListeners();
    try {
      return await MiuixContextMenu.showSource<T>(
        context: context,
        position: position,
        items: items,
        colors: colors,
      );
    } finally {
      _isOpen = false;
      if (!_disposed) notifyListeners();
    }
  }

  /// Closes the nearest open menu route.
  void close(BuildContext context) =>
      Navigator.of(context, rootNavigator: true).maybePop();

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// Floating context menu used by long-press and secondary-click regions.
class MiuixContextMenu<T> extends StatelessWidget {
  /// Creates a content-fitting HyperOS 4 context-menu panel.
  const MiuixContextMenu({
    super.key,
    required this.items,
    required this.onSelected,
    this.colors,
    this.glass = true,
    this.glassBlur,
    this.glassOpacity,
    this.showGlassSpecular = true,
    this.minWidth,
    this.maxWidth,
    this.maxHeight,
    this.itemHeight,
    this.horizontalPadding,
    this.iconSpacing,
    this.verticalPadding,
    this.cornerRadius,
    this.shadowElevation,
    this.insetDividers = true,
    this.rowColor = Colors.transparent,
  });

  /// Creates the former 220dp-wide opaque context-menu panel.
  const MiuixContextMenu.source({
    super.key,
    required this.items,
    required this.onSelected,
    this.colors,
  }) : glass = false,
       glassBlur = null,
       glassOpacity = null,
       showGlassSpecular = false,
       minWidth = MiuixContextMenuDefaults.sourceWidth,
       maxWidth = MiuixContextMenuDefaults.sourceWidth,
       maxHeight = null,
       itemHeight = MiuixContextMenuDefaults.sourceItemHeight,
       horizontalPadding = MiuixContextMenuDefaults.sourceHorizontalPadding,
       iconSpacing = MiuixContextMenuDefaults.sourceIconSpacing,
       verticalPadding = MiuixContextMenuDefaults.sourceVerticalPadding,
       cornerRadius = MiuixContextMenuDefaults.sourceCornerRadius,
       shadowElevation = MiuixContextMenuDefaults.sourceShadowElevation,
       insetDividers = false,
       rowColor = null;

  /// Ordered typed menu actions.
  final List<MiuixContextMenuItem<T>> items;

  /// Called after an enabled action is tapped.
  final ValueChanged<T> onSelected;

  /// Optional palette override.
  final MiuixContextMenuColors? colors;

  /// Material policy for the complete popup panel.
  final bool glass;
  final double? glassBlur;
  final double? glassOpacity;
  final bool showGlassSpecular;

  /// Optional content-fitting width and window-height constraints.
  final double? minWidth;
  final double? maxWidth;
  final double? maxHeight;

  /// Optional action and panel geometry overrides.
  final double? itemHeight;
  final double? horizontalPadding;
  final double? iconSpacing;
  final double? verticalPadding;
  final double? cornerRadius;
  final double? shadowElevation;

  /// Whether separators align with the row content instead of the outer edge.
  final bool insetDividers;

  /// Optional action-row fill; null retains the former Surface default.
  final Color? rowColor;

  /// Opens a position-aware menu route.
  static Future<T?> show<T>({
    required BuildContext context,
    required Offset position,
    required List<MiuixContextMenuItem<T>> items,
    MiuixContextMenuColors? colors,
    bool barrierDismissible = true,
    bool glass = true,
    double? glassBlur,
    double? glassOpacity,
    bool showGlassSpecular = true,
    double? minWidth,
    double? maxWidth,
    double? itemHeight,
    double? horizontalPadding,
    double? iconSpacing,
    double? verticalPadding,
    double? cornerRadius,
    double? screenMargin,
    double? shadowElevation,
  }) => _show<T>(
    context: context,
    position: position,
    items: items,
    colors: colors,
    barrierDismissible: barrierDismissible,
    sourceStyle: false,
    glass: glass,
    glassBlur: glassBlur,
    glassOpacity: glassOpacity,
    showGlassSpecular: showGlassSpecular,
    minWidth: minWidth,
    maxWidth: maxWidth,
    itemHeight: itemHeight,
    horizontalPadding: horizontalPadding,
    iconSpacing: iconSpacing,
    verticalPadding: verticalPadding,
    cornerRadius: cornerRadius,
    screenMargin: screenMargin,
    shadowElevation: shadowElevation,
  );

  /// Opens the former fixed-width opaque context-menu route.
  static Future<T?> showSource<T>({
    required BuildContext context,
    required Offset position,
    required List<MiuixContextMenuItem<T>> items,
    MiuixContextMenuColors? colors,
    bool barrierDismissible = true,
  }) => _show<T>(
    context: context,
    position: position,
    items: items,
    colors: colors,
    barrierDismissible: barrierDismissible,
    sourceStyle: true,
    glass: false,
    showGlassSpecular: false,
  );

  static Future<T?> _show<T>({
    required BuildContext context,
    required Offset position,
    required List<MiuixContextMenuItem<T>> items,
    required MiuixContextMenuColors? colors,
    required bool barrierDismissible,
    required bool sourceStyle,
    required bool glass,
    required bool showGlassSpecular,
    double? glassBlur,
    double? glassOpacity,
    double? minWidth,
    double? maxWidth,
    double? itemHeight,
    double? horizontalPadding,
    double? iconSpacing,
    double? verticalPadding,
    double? cornerRadius,
    double? screenMargin,
    double? shadowElevation,
  }) {
    MiuixHaptics.perform(MiuixHapticType.contextClick);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final transitionDuration = reduceMotion
        ? Duration.zero
        : MiuixTheme.of(context).hyperOs4.contextMenuMotion;
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.transparent,
      transitionDuration: transitionDuration,
      pageBuilder: (routeContext, animation, secondaryAnimation) {
        final safePadding = MediaQuery.paddingOf(routeContext);
        final hyperOs4 = MiuixTheme.of(routeContext).hyperOs4;
        final resolvedMargin = sourceStyle
            ? MiuixContextMenuDefaults.sourceScreenMargin
            : _finiteNonNegative(
                screenMargin,
                hyperOs4.contextMenuScreenMargin,
              );
        return SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableHeight = math.max(
                0.0,
                constraints.maxHeight - resolvedMargin * 2,
              );
              final panel = sourceStyle
                  ? MiuixContextMenu<T>.source(
                      items: items,
                      colors: colors,
                      onSelected: (value) {
                        MiuixHaptics.perform(MiuixHapticType.confirm);
                        Navigator.of(routeContext).pop(value);
                      },
                    )
                  : MiuixContextMenu<T>(
                      items: items,
                      colors: colors,
                      glass: glass,
                      glassBlur: glassBlur,
                      glassOpacity: glassOpacity,
                      showGlassSpecular: showGlassSpecular,
                      minWidth: minWidth,
                      maxWidth: maxWidth,
                      maxHeight: availableHeight,
                      itemHeight: itemHeight,
                      horizontalPadding: horizontalPadding,
                      iconSpacing: iconSpacing,
                      verticalPadding: verticalPadding,
                      cornerRadius: cornerRadius,
                      shadowElevation: shadowElevation,
                      onSelected: (value) {
                        MiuixHaptics.perform(MiuixHapticType.confirm);
                        Navigator.of(routeContext).pop(value);
                      },
                    );
              return CustomSingleChildLayout(
                delegate: _MiuixContextMenuLayoutDelegate(
                  anchor: position - Offset(safePadding.left, safePadding.top),
                  screenMargin: resolvedMargin,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: availableHeight),
                  child: panel,
                ),
              );
            },
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: sourceStyle ? Curves.easeOutBack : Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: sourceStyle ? .88 : .94,
              end: 1,
            ).animate(curved),
            alignment: Directionality.of(context) == TextDirection.ltr
                ? Alignment.topLeft
                : Alignment.topRight,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = colors ?? MiuixContextMenuDefaults.colors(context);
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final resolvedMinWidth = _finitePositive(
      minWidth,
      hyperOs4.contextMenuMinWidth,
    );
    final resolvedMaxWidth = math.max(
      resolvedMinWidth,
      _finitePositive(maxWidth, hyperOs4.contextMenuMaxWidth),
    );
    final resolvedItemHeight = _finitePositive(
      itemHeight,
      hyperOs4.contextMenuItemHeight,
    );
    final resolvedHorizontalPadding = _finiteNonNegative(
      horizontalPadding,
      hyperOs4.contextMenuHorizontalPadding,
    );
    final resolvedIconSpacing = _finiteNonNegative(
      iconSpacing,
      hyperOs4.contextMenuIconSpacing,
    );
    final resolvedVerticalPadding = _finiteNonNegative(
      verticalPadding,
      hyperOs4.contextMenuVerticalPadding,
    );
    final resolvedCornerRadius = _finiteNonNegative(
      cornerRadius,
      hyperOs4.popupCornerRadius,
    );
    final resolvedShadow = _finiteNonNegative(
      shadowElevation,
      hyperOs4.contextMenuShadowElevation,
    );
    final children = <Widget>[];
    for (final item in items) {
      if (item.separatorBefore) {
        final divider = Divider(
          height: 1,
          thickness: 1,
          color: palette.divider,
        );
        children.add(
          insetDividers
              ? Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: resolvedHorizontalPadding,
                  ),
                  child: divider,
                )
              : divider,
        );
      }
      final foreground = !item.enabled
          ? palette.disabledForeground
          : item.destructive
          ? palette.destructive
          : palette.foreground;
      children.add(
        MiuixSurface(
          onTap: item.enabled ? () => onSelected(item.value) : null,
          enabled: item.enabled,
          color: rowColor,
          feedbackType: MiuixPressFeedbackType.sink,
          contentColor: foreground,
          child: SizedBox(
            height: resolvedItemHeight,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: resolvedHorizontalPadding,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (item.icon != null) ...<Widget>[
                    item.icon!,
                    SizedBox(width: resolvedIconSpacing),
                  ],
                  Flexible(
                    child: Text(
                      item.label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: foreground),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    final content = SingleChildScrollView(
      key: const ValueKey('miuix-context-menu-scroll'),
      primary: false,
      padding: EdgeInsets.symmetric(vertical: resolvedVerticalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: resolvedMinWidth,
        maxWidth: resolvedMaxWidth,
        maxHeight: maxHeight == null
            ? double.infinity
            : _finitePositive(maxHeight, double.infinity),
      ),
      child: IntrinsicWidth(
        child: MiuixSurface(
          key: const ValueKey('miuix-context-menu-surface'),
          color: palette.background,
          radius: resolvedCornerRadius,
          shadowElevation: resolvedShadow,
          glass: glass,
          glassBlur: glassBlur ?? hyperOs4.popupBlur,
          glassOpacity: glassOpacity ?? hyperOs4.popupTintOpacity,
          glassOptics: MiuixGlassOptics.transient,
          showGlassSpecular: showGlassSpecular,
          child: content,
        ),
      ),
    );
  }
}

double _finitePositive(double? value, double fallback) =>
    value != null && value.isFinite && value > 0 ? value : fallback;

double _finiteNonNegative(double? value, double fallback) =>
    value != null && value.isFinite && value >= 0 ? value : fallback;

class _MiuixContextMenuLayoutDelegate extends SingleChildLayoutDelegate {
  const _MiuixContextMenuLayoutDelegate({
    required this.anchor,
    required this.screenMargin,
  });

  final Offset anchor;
  final double screenMargin;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.loose(
      Size(
        math.max(0, constraints.maxWidth - screenMargin * 2),
        math.max(0, constraints.maxHeight - screenMargin * 2),
      ),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final maximumX = math.max(
      screenMargin,
      size.width - childSize.width - screenMargin,
    );
    final maximumY = math.max(
      screenMargin,
      size.height - childSize.height - screenMargin,
    );
    return Offset(
      anchor.dx.clamp(screenMargin, maximumX).toDouble(),
      anchor.dy.clamp(screenMargin, maximumY).toDouble(),
    );
  }

  @override
  bool shouldRelayout(_MiuixContextMenuLayoutDelegate oldDelegate) =>
      oldDelegate.anchor != anchor || oldDelegate.screenMargin != screenMargin;
}

/// Adds long-press and mouse secondary-click activation to [child].
class MiuixContextMenuRegion<T> extends StatefulWidget {
  /// Creates a context-menu activation region.
  const MiuixContextMenuRegion({
    super.key,
    required this.items,
    required this.child,
    this.controller,
    this.onSelected,
    this.enabled = true,
    this.colors,
    this.sourceStyle = false,
  });

  /// Menu actions and wrapped content.
  final List<MiuixContextMenuItem<T>> items;
  final Widget child;

  /// Optional route controller and selection callback.
  final MiuixContextMenuController? controller;
  final ValueChanged<T>? onSelected;

  /// Whether activation gestures are installed.
  final bool enabled;

  /// Optional menu palette.
  final MiuixContextMenuColors? colors;

  /// Whether activation opens the explicit legacy opaque route.
  final bool sourceStyle;

  @override
  State<MiuixContextMenuRegion<T>> createState() =>
      _MiuixContextMenuRegionState<T>();
}

class _MiuixContextMenuRegionState<T> extends State<MiuixContextMenuRegion<T>> {
  // Context menus intentionally snapshot their visible actions for one short
  // invocation. The owning region can nevertheless rebuild before the route
  // future completes, so returning a snapshot value is a separate operation
  // from publishing it to the current callback owner. The generation rejects
  // results from a replaced action/controller contract; the final membership
  // check also covers rows disabled or removed before pointer-up dispatch.
  //
  // Snapshot region invariants:
  //
  // - Visible labels and row geometry belong to the opening invocation.
  // - Theme changes may repaint through inherited route dependencies.
  // - Action-list replacement invalidates the pending typed result.
  // - Controller replacement invalidates the route ownership contract.
  // - Disabling the region invalidates every outstanding result.
  // - Switching source material invalidates the outstanding route family.
  // - Merely replacing onSelected keeps a still-valid action publishable.
  // - The latest callback is read only after current membership validation.
  // - Disabled current actions are never accepted through an old enabled row.
  // - Removed current actions are never accepted through an old visible row.
  // - Duplicate typed values remain valid if one current action is enabled.
  // - Route dismissal is completed by the menu before its Future resolves.
  // - A disposed region drops the result regardless of action membership.
  // - Each new invocation invalidates a previous invocation from this region.
  // - Long press and secondary click therefore share one ownership sequence.
  // - The generation is State-local and cannot leak between sibling regions.
  // - No route animation is restarted by an ordinary parent rebuild.
  // - Tests exercise both disposal and same-State action replacement races.
  int _menuGeneration = 0;

  @override
  void didUpdateWidget(covariant MiuixContextMenuRegion<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items ||
        oldWidget.controller != widget.controller ||
        oldWidget.enabled != widget.enabled ||
        oldWidget.sourceStyle != widget.sourceStyle) {
      _menuGeneration++;
    }
  }

  Future<void> _open(BuildContext context, Offset position) async {
    if (!widget.enabled || widget.items.isEmpty) return;
    final generation = ++_menuGeneration;
    final value = widget.sourceStyle
        ? widget.controller == null
              ? await MiuixContextMenu.showSource<T>(
                  context: context,
                  position: position,
                  items: widget.items,
                  colors: widget.colors,
                )
              : await widget.controller!.showSource<T>(
                  context: context,
                  position: position,
                  items: widget.items,
                  colors: widget.colors,
                )
        : widget.controller == null
        ? await MiuixContextMenu.show<T>(
            context: context,
            position: position,
            items: widget.items,
            colors: widget.colors,
          )
        : await widget.controller!.show<T>(
            context: context,
            position: position,
            items: widget.items,
            colors: widget.colors,
          );
    // The root menu may outlive a nested page or conditionally rendered
    // trigger. A completed selection must not call back into that dead owner.
    if (!mounted || value == null || generation != _menuGeneration) return;
    final currentAction = widget.items.any(
      (item) => item.enabled && item.value == value,
    );
    if (widget.enabled && currentAction) widget.onSelected?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onLongPressStart: widget.enabled
          ? (details) => _open(context, details.globalPosition)
          : null,
      onSecondaryTapDown: widget.enabled
          ? (details) => _open(context, details.globalPosition)
          : null,
      child: widget.child,
    );
  }
}
