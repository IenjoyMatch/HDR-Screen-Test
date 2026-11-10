import '../../icons/miuix_icon_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../platform/miuix_haptics.dart';
import '../../theme/miuix_semantic_colors.dart';
import '../../theme/miuix_theme.dart';
import '../../widgets/miuix_widgets.dart';

/// Geometry defaults for reorderable MIUIX collections.
abstract final class MiuixReorderableListDefaults {
  // Reorderable collection interaction contract:
  // - Application data remains the only source of ordering truth.
  // - Every row must expose a stable key supplied by the application.
  // - A visual row index is resolved again after each application rebuild.
  // - Dragging never mutates the caller's list inside the component.
  // - The callback retains Flutter's pre-removal destination convention.
  // - Moving one row downward therefore reports target index plus one.
  // - Moving one row upward reports the visible target index directly.
  // - Keyboard movement uses exactly the same callback convention as drag.
  // - Accessibility increase maps to one logical downward movement.
  // - Accessibility decrease maps to one logical upward movement.
  // - The first row never advertises a decrease action.
  // - The last row never advertises an increase action.
  // - Boundary key presses stay unhandled so parent shortcuts may respond.
  // - Disabled handles do not enter the focus traversal order.
  // - Disabled handles do not join a drag gesture recognizer.
  // - Pointer contact requests focus before a desktop drag starts.
  // - Focus indication is confined to the authored handle target.
  // - Focus indication does not add a second row background.
  // - Direction-key repeats support deliberate multi-step reordering.
  // - Key-up events never produce duplicate reorder callbacks.
  // - A successful keyboard move emits one segment-tick haptic.
  // - A pointer drag begins with the long-press/lift haptic role.
  // - A completed pointer drag emits the confirmation haptic role.
  // - Keyboard moves preserve start/change/end callback ordering.
  // - The end callback receives the final visible item position.
  // - Header and footer widgets are outside the reorderable item indices.
  // - Safe-area padding is not inserted a second time by the list.
  // - Explicit caller padding always wins over the zero fallback.
  // - The caller's scroll controller remains externally owned.
  // - The caller's scroll physics are forwarded without substitution.
  // - Mobile defaults to a delayed drag to protect normal scrolling.
  // - Desktop defaults to immediate dragging from the explicit handle.
  // - The delayed policy remains individually overridable per handle.
  // - A standalone handle may provide explicit move callbacks.
  // - A list-owned handle discovers movement through inherited scope.
  // - The inherited scope carries behavior, not a copied item list.
  // - Scope updates propagate when item count or move closure changes.
  // - Item-count shrink immediately removes invalid boundary actions.
  // - Rebuilds never retain a stale item count in handle semantics.
  // - Lifted proxies follow the HyperOS 4 collection corner token.
  // - The source constructor preserves the previous fixed radius.
  // - Reduced-motion mode removes proxy easing without losing state.
  // - Proxy scale is deliberately subtle and cannot alter list geometry.
  // - Shadow belongs only to the lifted proxy, not the resting row.
  // - Row clipping and proxy clipping share the resolved corner shape.
  // - The minimum row target remains large enough for touch selection.
  // - The drag target remains independent from row content density.
  // - RTL does not reverse vertical up/down movement semantics.
  // - Reordering remains vertical even when the page can swipe sideways.
  // - Custom row content cannot accidentally become the index owner.
  // - The KeyedSubtree binds identity outside the custom item builder.
  // These are library behavior rules and project-derived visual values;
  // they are not unpublished Xiaomi measurements.
  // Handle validity and focus revocation contract:
  // - A public handle index may originate in persisted or asynchronously rebuilt UI.
  // - Release builds therefore cannot rely on an assertion to reject a negative index.
  // - Negative indices never create a Flutter drag-start listener.
  // - A scoped index at or beyond the current item count is equally non-draggable.
  // - Standalone positive indices remain valid because their host owns item count.
  // - Effective drag validity combines authored enabled state and legal index domain.
  // - The same effective value controls focus, cursor, semantics, and drag recognition.
  // - These channels cannot disagree about whether a handle is interactive.
  // - A non-draggable handle uses the basic cursor rather than a misleading grab cursor.
  // - Its icon uses the disabled semantic foreground in both brightness modes.
  // - Its increase and decrease semantic actions are both absent.
  // - Its Focus node cannot be requested through keyboard traversal.
  // - Runtime disablement explicitly unfocuses a handle that was already focused.
  // - The cached focus highlight is cleared in the same widget update.
  // - Subsequent key repeats therefore cannot move an item from a disabled target.
  // - Re-enabling restores capability only if the current index is still legal.
  // - Item-count shrink is observed through the inherited scope on the next build.
  // - A formerly last-valid index then loses drag and movement affordances together.
  // - Explicit standalone move callbacks do not override an illegal negative index.
  // - Explicit callbacks do override list-boundary inference for legal standalone use.
  // - Inside a list, scope boundaries suppress actions before callbacks are selected.
  // - An upward move is unavailable when target index would be negative.
  // - A downward move is unavailable when target reaches the current item count.
  // - Keyboard handlers return ignored when no effective action exists.
  // - This permits an ancestor shortcut to consume a boundary arrow if appropriate.
  // - Key-repeat handling is intentional while key-up remains ignored.
  // - Pointer focus requests occur only for an effectively draggable handle.
  // - Disabled pointer contact cannot leave a hidden focus owner in the tree.
  // - Semantics labels remain present so assistive technology can identify the control.
  // - The enabled flag communicates whether that identified control can currently act.
  // - Lift proxy geometry is resolved from finite public or finite theme radius.
  // - Non-finite public radius follows the collection-row theme role.
  // - Negative finite public radius clamps to zero before material clipping.
  // - Reduced motion samples the final lifted scale without autonomous easing.
  // - It does not remove elevation or identity needed to understand the dragged row.
  // - Custom proxy decorators deliberately replace only the visual proxy function.
  // - They do not replace reorder lifecycle callbacks or haptic publication.
  // - Keyboard movement calls start, reorder, then end synchronously in that order.
  // - Application synchronous rebuilds may retarget the keyed handle between repeats.
  // - Stable keys let Flutter retain focus on the same logical item after that rebuild.
  // - Duplicate keys remain invalid Flutter application input and are not rewritten.
  // - An empty item list produces no handle scope consumers and no reorder callbacks.
  // - Header and footer changes never alter the item index passed to application code.
  // - Shrink-wrap affects layout ownership but not reorder destination arithmetic.
  // - Explicit zero padding avoids inherited safe-area offsets inside composed pages.
  // - System gesture insets remain the responsibility of the containing page scaffold.
  // - These validity rules are behaviorally identical on Android and Windows.

  /// Minimum row target and drag-handle target.
  static const double minimumItemExtent = 52;
  static const double dragHandleExtent = 44;

  /// Radius and elevation used by the lifted proxy.
  static const double proxyRadius = 18;
  static const double proxyElevation = 8;

  /// Whether the current platform normally starts dragging after a hold.
  static bool get usesDelayedDrag =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
}

class _MiuixReorderScope extends InheritedWidget {
  const _MiuixReorderScope({
    required this.itemCount,
    required this.move,
    required super.child,
  });

  final int itemCount;
  final void Function(int index, int delta) move;

  static _MiuixReorderScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_MiuixReorderScope>();

  @override
  bool updateShouldNotify(_MiuixReorderScope oldWidget) =>
      itemCount != oldWidget.itemCount || move != oldWidget.move;
}

/// Standard MIUIX drag affordance for [MiuixReorderableList].
class MiuixDragHandle extends StatefulWidget {
  /// Creates a drag handle bound to one reorderable index.
  const MiuixDragHandle({
    super.key,
    required this.index,
    this.icon = const MiuixThemedIcon(Icons.drag_handle_rounded),
    this.enabled = true,
    this.delayed,
    this.semanticLabel = '拖动排序',
    this.onMoveUp,
    this.onMoveDown,
  });

  /// Reorderable child index and visual state.
  final int index;
  final Widget icon;
  final bool enabled;

  /// Overrides the Android/iOS delayed and desktop immediate default.
  final bool? delayed;
  final String semanticLabel;

  /// Optional standalone keyboard and accessibility move actions.
  ///
  /// Handles inside [MiuixReorderableList] resolve these automatically.
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;

  @override
  State<MiuixDragHandle> createState() => _MiuixDragHandleState();
}

class _MiuixDragHandleState extends State<MiuixDragHandle> {
  final FocusNode _focusNode = FocusNode(debugLabel: 'MiuixDragHandle');
  bool _focused = false;

  bool _canDrag(_MiuixReorderScope? scope) {
    if (!widget.enabled || widget.index < 0) return false;
    return scope == null || widget.index < scope.itemCount;
  }

  VoidCallback? _moveAction(int delta, _MiuixReorderScope? scope) {
    if (!_canDrag(scope)) return null;
    final explicit = delta < 0 ? widget.onMoveUp : widget.onMoveDown;
    if (explicit != null) return explicit;
    if (scope == null) return null;
    final target = widget.index + delta;
    if (target < 0 || target >= scope.itemCount) return null;
    return () => scope.move(widget.index, delta);
  }

  void _invoke(VoidCallback action) {
    action();
    MiuixHaptics.perform(MiuixHapticType.segmentTick);
  }

  @override
  void didUpdateWidget(MiuixDragHandle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled && !widget.enabled) {
      _focusNode.unfocus();
      _focused = false;
    }
  }

  KeyEventResult _handleKey(
    KeyEvent event,
    VoidCallback? moveUp,
    VoidCallback? moveDown,
  ) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final action = event.logicalKey == LogicalKeyboardKey.arrowUp
        ? moveUp
        : event.logicalKey == LogicalKeyboardKey.arrowDown
        ? moveDown
        : null;
    if (action == null) return KeyEventResult.ignored;
    _invoke(action);
    return KeyEventResult.handled;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = _MiuixReorderScope.maybeOf(context);
    final canDrag = _canDrag(scope);
    final moveUp = _moveAction(-1, scope);
    final moveDown = _moveAction(1, scope);
    final semantic = MiuixSemanticColors.of(context);
    final color = canDrag
        ? MiuixSemanticColors.of(context)['onSurfaceSecondary']
        : MiuixSemanticColors.of(context)['disabledOnSurface'];
    final handle = Semantics(
      label: widget.semanticLabel,
      button: true,
      enabled: canDrag,
      onDecrease: moveUp == null ? null : () => _invoke(moveUp),
      onIncrease: moveDown == null ? null : () => _invoke(moveDown),
      child: Focus(
        focusNode: _focusNode,
        canRequestFocus: canDrag,
        onFocusChange: (value) => setState(() => _focused = value),
        onKeyEvent: (node, event) => _handleKey(event, moveUp, moveDown),
        child: Listener(
          onPointerDown: canDrag ? (_) => _focusNode.requestFocus() : null,
          child: MouseRegion(
            cursor: canDrag
                ? SystemMouseCursors.grab
                : SystemMouseCursors.basic,
            child: AnimatedContainer(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : MiuixTheme.of(context).hyperOs4.collectionRowMotion,
              decoration: BoxDecoration(
                color: _focused
                    ? semantic['tertiaryContainer']
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              width: MiuixReorderableListDefaults.dragHandleExtent,
              height: MiuixReorderableListDefaults.dragHandleExtent,
              child: Center(
                child: IconTheme(
                  data: IconThemeData(color: color, size: 22),
                  child: widget.icon,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    if (!canDrag) return handle;
    return (widget.delayed ?? MiuixReorderableListDefaults.usesDelayedDrag)
        ? ReorderableDelayedDragStartListener(
            index: widget.index,
            child: handle,
          )
        : ReorderableDragStartListener(index: widget.index, child: handle);
  }
}

/// Reorderable list with MIUIX lift motion, haptics, and desktop handles.
class MiuixReorderableList<T> extends StatelessWidget {
  /// Creates a reorderable view from application-owned items.
  const MiuixReorderableList({
    super.key,
    required this.items,
    required this.itemKey,
    required this.itemBuilder,
    required this.onReorder,
    this.header,
    this.footer,
    this.padding,
    this.scrollController,
    this.physics,
    this.shrinkWrap = false,
    this.buildDefaultDragHandles = false,
    this.proxyDecorator,
    this.onReorderStart,
    this.onReorderEnd,
    this.proxyCornerRadius = double.nan,
  });

  /// Creates a reorderable list with the former fixed-18dp lift proxy.
  const MiuixReorderableList.source({
    super.key,
    required this.items,
    required this.itemKey,
    required this.itemBuilder,
    required this.onReorder,
    this.header,
    this.footer,
    this.padding,
    this.scrollController,
    this.physics,
    this.shrinkWrap = false,
    this.buildDefaultDragHandles = false,
    this.proxyDecorator,
    this.onReorderStart,
    this.onReorderEnd,
  }) : proxyCornerRadius = MiuixReorderableListDefaults.proxyRadius;

  /// Ordered application data and stable key extractor.
  final List<T> items;
  final Key Function(T item) itemKey;

  /// Builds a row and reports the original data index.
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// Receives Flutter's old/new index contract.
  final ReorderCallback onReorder;

  /// Optional scroll and decoration configuration.
  final Widget? header;
  final Widget? footer;
  final EdgeInsets? padding;
  final ScrollController? scrollController;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final bool buildDefaultDragHandles;
  final ReorderItemProxyDecorator? proxyDecorator;

  /// Lifted-proxy shape; NaN follows the collection-row theme role.
  final double proxyCornerRadius;

  /// Optional lifecycle callbacks in addition to built-in haptics.
  final void Function(int index)? onReorderStart;
  final void Function(int index)? onReorderEnd;

  Widget _defaultProxy(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final reduceMotion = MediaQuery.disableAnimationsOf(context);
        final eased = reduceMotion
            ? 1.0
            : Curves.easeOutCubic.transform(animation.value);
        final radius = proxyCornerRadius.isFinite
            ? proxyCornerRadius.clamp(0.0, double.infinity).toDouble()
            : MiuixTheme.of(context).hyperOs4.collectionRowCornerRadius;
        return Transform.scale(
          scale: 1 + .015 * eased,
          child: Material(
            color: Colors.transparent,
            elevation: MiuixReorderableListDefaults.proxyElevation * eased,
            shadowColor: Colors.black26,
            borderRadius: BorderRadius.circular(radius),
            clipBehavior: Clip.antiAlias,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    void moveFromHandle(int index, int delta) {
      final target = index + delta;
      if (index < 0 ||
          index >= items.length ||
          target < 0 ||
          target >= items.length) {
        return;
      }
      // Flutter's downward destination is expressed before removal, hence the
      // extra one. The application receives the exact same contract as drag.
      final flutterDestination = delta > 0 ? target + 1 : target;
      onReorderStart?.call(index);
      onReorder(index, flutterDestination);
      onReorderEnd?.call(target);
    }

    return _MiuixReorderScope(
      itemCount: items.length,
      move: moveFromHandle,
      child: ReorderableListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) => KeyedSubtree(
          key: itemKey(items[index]),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: MiuixReorderableListDefaults.minimumItemExtent,
            ),
            child: itemBuilder(context, items[index], index),
          ),
        ),
        onReorderItem: onReorder,
        onReorderStart: (index) {
          MiuixHaptics.perform(MiuixHapticType.longPress);
          onReorderStart?.call(index);
        },
        onReorderEnd: (index) {
          MiuixHaptics.perform(MiuixHapticType.confirm);
          onReorderEnd?.call(index);
        },
        proxyDecorator: proxyDecorator ?? _defaultProxy,
        buildDefaultDragHandles: buildDefaultDragHandles,
        header: header,
        footer: footer,
        // Reusable collection views live inside pages that already consume the
        // system insets. Preserve an explicit caller value, otherwise avoid the
        // ScrollView fallback that inserts the route safe area a second time.
        padding: padding ?? EdgeInsets.zero,
        scrollController: scrollController,
        primary: false,
        physics: physics,
        shrinkWrap: shrinkWrap,
      ),
    );
  }
}

/// Rounded row helper for reorderable settings and content lists.
class MiuixReorderableItem extends StatelessWidget {
  /// Creates a row with an optional standard trailing drag handle.
  const MiuixReorderableItem({
    super.key,
    required this.child,
    this.index,
    this.enabled = true,
    this.showHandle = true,
    this.color,
    this.cornerRadius = double.nan,
  });

  /// Creates the former fixed-18dp compatibility row.
  const MiuixReorderableItem.source({
    super.key,
    required this.child,
    this.index,
    this.enabled = true,
    this.showHandle = true,
    this.color,
  }) : cornerRadius = MiuixReorderableListDefaults.proxyRadius;

  final Widget child;
  final int? index;
  final bool enabled;
  final bool showHandle;
  final Color? color;
  final double cornerRadius;

  @override
  Widget build(BuildContext context) {
    final semantic = MiuixSemanticColors.of(context);
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final radius = cornerRadius.isFinite
        ? cornerRadius.clamp(0.0, double.infinity).toDouble()
        : hyperOs4.collectionRowCornerRadius;
    return MiuixSurface(
      key: const ValueKey('miuix-reorderable-item-surface'),
      radius: radius,
      color: color ?? semantic['surfaceVariant'],
      padding: const EdgeInsetsDirectional.only(start: 16),
      child: Row(
        children: <Widget>[
          Expanded(child: child),
          if (showHandle && index != null)
            MiuixDragHandle(index: index!, enabled: enabled),
        ],
      ),
    );
  }
}
