import '../../icons/miuix_icon_theme.dart';
import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart' show setEquals;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../platform/miuix_haptics.dart';
import '../../theme/miuix_semantic_colors.dart';
import '../../theme/miuix_theme.dart';
import '../../widgets/miuix_widgets.dart';
import '../miuix_extension_icons.dart';

/// Immutable node consumed by [MiuixTreeView].
@immutable
class MiuixTreeNode<T extends Object> {
  /// Creates an eager or lazily loaded tree node.
  const MiuixTreeNode({
    required this.value,
    required this.label,
    this.children = const [],
    this.childrenLoader,
    this.icon,
    this.expandedIcon,
    this.trailing,
    this.enabled = true,
  });

  /// Stable identity and visible label.
  final T value;
  final String label;

  /// Eager children or an asynchronous child loader.
  final List<MiuixTreeNode<T>> children;
  final Future<List<MiuixTreeNode<T>>> Function()? childrenLoader;

  /// Optional content slots.
  final Widget? icon;
  final Widget? expandedIcon;
  final Widget? trailing;
  final bool enabled;

  /// Whether the row can expand now or after loading.
  bool get canExpand => children.isNotEmpty || childrenLoader != null;
}

/// Expansion and selection state for a typed tree.
class MiuixTreeController<T extends Object> extends ChangeNotifier {
  /// Creates a tree controller with optional initial state.
  MiuixTreeController({Iterable<T> expanded = const [], T? selected})
    : _expanded = Set<T>.of(expanded),
      _selected = selected;

  final Set<T> _expanded;
  T? _selected;

  /// Read-only expansion set and selected node value.
  Set<T> get expanded => UnmodifiableSetView<T>(_expanded);
  T? get selected => _selected;

  /// Whether one value is expanded.
  bool isExpanded(T value) => _expanded.contains(value);

  /// Selects a node, including null to clear selection.
  set selected(T? value) {
    if (_selected == value) return;
    _selected = value;
    notifyListeners();
  }

  /// Expands, collapses, or toggles one node.
  void expand(T value) {
    if (_expanded.add(value)) notifyListeners();
  }

  void collapse(T value) {
    if (_expanded.remove(value)) notifyListeners();
  }

  void toggle(T value) => isExpanded(value) ? collapse(value) : expand(value);

  /// Replaces the complete expansion set.
  void setExpanded(Iterable<T> values) {
    final next = Set<T>.of(values);
    if (setEquals(next, _expanded)) return;
    _expanded
      ..clear()
      ..addAll(next);
    notifyListeners();
  }
}

/// Color roles for a MIUIX tree.
@immutable
class MiuixTreeViewColors {
  /// Creates a complete tree palette.
  const MiuixTreeViewColors({
    required this.foreground,
    required this.secondaryForeground,
    required this.selectedBackground,
    required this.selectedForeground,
    required this.guide,
    required this.disabledForeground,
  });

  final Color foreground;
  final Color secondaryForeground;
  final Color selectedBackground;
  final Color selectedForeground;
  final Color guide;
  final Color disabledForeground;
}

/// Layout defaults for hierarchical collections.
abstract final class MiuixTreeViewDefaults {
  /// Row and nesting geometry.
  static const double rowExtent = 48;
  static const double indentation = 24;
  static const double cornerRadius = 15;

  /// Resolves semantic tree colors.
  static MiuixTreeViewColors colors(BuildContext context) {
    final semantic = MiuixSemanticColors.of(context);
    return MiuixTreeViewColors(
      foreground: semantic['onSurface'],
      secondaryForeground: semantic['onSurfaceSecondary'],
      selectedBackground: semantic['primaryContainer'],
      selectedForeground: semantic['onPrimaryContainer'],
      guide: semantic['dividerLine'],
      disabledForeground: semantic['disabledOnSurface'],
    );
  }
}

class _VisibleTreeNode<T extends Object> {
  const _VisibleTreeNode({
    required this.node,
    required this.depth,
    this.parent,
  });

  final MiuixTreeNode<T> node;
  final int depth;
  final T? parent;
}

/// Typed, keyboard-navigable MIUIX tree with asynchronous child loading.
class MiuixTreeView<T extends Object> extends StatefulWidget {
  /// Creates a tree from root nodes.
  const MiuixTreeView({
    super.key,
    required this.nodes,
    this.controller,
    this.onSelected,
    this.onExpansionChanged,
    this.nodeBuilder,
    this.emptyState,
    this.indentation = MiuixTreeViewDefaults.indentation,
    this.shrinkWrap = true,
    this.physics,
    this.colors,
    this.rowCornerRadius = double.nan,
  });

  /// Creates the former fixed-15dp tree-row geometry.
  const MiuixTreeView.source({
    super.key,
    required this.nodes,
    this.controller,
    this.onSelected,
    this.onExpansionChanged,
    this.nodeBuilder,
    this.emptyState,
    this.indentation = MiuixTreeViewDefaults.indentation,
    this.shrinkWrap = true,
    this.physics,
    this.colors,
  }) : rowCornerRadius = MiuixTreeViewDefaults.cornerRadius;

  /// Root data and optional externally owned controller.
  final List<MiuixTreeNode<T>> nodes;
  final MiuixTreeController<T>? controller;

  /// Selection and expansion callbacks.
  final ValueChanged<T?>? onSelected;
  final void Function(T value, bool expanded)? onExpansionChanged;

  /// Optional row content override after the disclosure affordance.
  final Widget Function(
    BuildContext context,
    MiuixTreeNode<T> node,
    bool selected,
    bool expanded,
  )?
  nodeBuilder;

  final Widget? emptyState;
  final double indentation;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final MiuixTreeViewColors? colors;

  /// Selection-row shape; NaN follows the collection-row theme role.
  final double rowCornerRadius;

  @override
  State<MiuixTreeView<T>> createState() => _MiuixTreeViewState<T>();
}

class _MiuixTreeViewState<T extends Object> extends State<MiuixTreeView<T>> {
  late MiuixTreeController<T> _controller;
  late bool _ownsController;
  final Map<T, List<MiuixTreeNode<T>>> _loadedChildren =
      <T, List<MiuixTreeNode<T>>>{};
  final Map<T, Future<List<MiuixTreeNode<T>>> Function()> _loadedLoaders =
      <T, Future<List<MiuixTreeNode<T>>> Function()>{};
  final Set<T> _loading = <T>{};
  final Map<T, Object> _loadErrors = <T, Object>{};
  // Lazy-loading lifecycle contract:
  // - A value is the application's stable node identity.
  // - A loader function is the identity of one authored data-source request.
  // - A token is the identity of one concrete invocation of that loader.
  // - Stable value equality alone never authorizes an asynchronous writeback.
  // - Replacing a node may retain its value while changing its data source.
  // - Such a replacement invalidates the invocation that started before it.
  // - An invalidated success cannot populate `_loadedChildren`.
  // - An invalidated failure cannot populate `_loadErrors`.
  // - An invalidated completion cannot expand the replacement node.
  // - An invalidated finally block cannot clear a newer loading indicator.
  // - A current success stores an immutable child snapshot.
  // - A current failure leaves the node collapsed and exposes retry state.
  // - Retrying allocates a new token even when the loader function is stable.
  // - Only the newest token for a value can clear that value's busy state.
  // - Removing a node cancels its logical request without canceling its Future.
  // - Dart Futures are not forcibly canceled because callers may share them.
  // - Completion after widget disposal performs no state or controller writes.
  // - Controller replacement does not by itself rewrite the authored tree.
  // - Eager children still bypass this complete asynchronous state machine.
  // - Loaded descendants participate when locating a currently authored node.
  // - A visited set protects malformed cyclic application data during lookup.
  // - Loader identity uses `identical`, not equality overloaded by user data.
  // - Node labels and presentation changes do not invalidate a stable loader.
  // - The visible AnimatedList is reset only after invalidation is recorded.
  // - This ordering prevents one frame of a stale spinner on the new node.
  // - Expansion callbacks are emitted only for the current successful load.
  // - Haptics likewise belong only to the surviving expansion operation.
  // - The cache remains keyed by value after a successful stable invocation.
  // - Applications that need refresh can replace the node with a new loader.
  // - Tests cover replacement before completion and a successful fresh retry.
  // - A passing compile-only test would not prove these temporal guarantees.
  // - These rules apply identically in Android and Windows event loops.
  // - Reduced-motion policy changes only animation, never request ownership.
  // - Keyboard expansion routes through `_toggle` and shares the same guards.
  // - Pointer expansion routes through `_toggle` and shares the same guards.
  // - No callback is published from a request whose ownership was revoked.
  // - Future edits must preserve token comparison in success, error, and final.
  // - Clearing only `_loading` is insufficient because old success could write.
  // - Comparing only mounted is insufficient because the widget may be reused.
  // - Comparing only value is insufficient because data sources can be swapped.
  // Completed-cache and keyboard contract:
  // - A completed lazy child list retains the exact loader identity that produced it.
  // - Rebuilding a node with the same value does not alone authorize cache reuse.
  // - Reuse requires the current loader function to be identical to the producer.
  // - Replacing a lazy node with eager children therefore clears its lazy cache.
  // - Replacing it with a different loader clears cache before the visible list resets.
  // - Removing a cached parent may make cached descendants unreachable afterward.
  // - Invalidation consequently walks to a fixed point instead of using one snapshot.
  // - Each pass observes the tree after removals made by the preceding pass.
  // - Loader errors are scoped to the same node value and current loader generation.
  // - A replacement removes stale error state along with stale child state.
  // - Successful retry replaces error presentation with one immutable child snapshot.
  // - Controller replacement revokes active requests before attaching the new owner.
  // - A late request cannot expand or notify through that replacement controller.
  // - Already completed cache may remain when its authored loader remains current.
  // - Expansion state itself always belongs to the currently attached controller.
  // - Vertical keyboard movement operates over the current flattened visible tree.
  // - Disabled rows remain visible but do not consume a keyboard selection step.
  // - Movement from no selection starts at the first enabled row in its direction.
  // - Movement stops at boundaries instead of wrapping to the opposite tree edge.
  // - A requested multi-step move counts enabled nodes, not physical row indices.
  // - Pointer selection requests tree focus before publishing controller selection.
  // - Disclosure pointer activation requests the same tree focus ownership.
  // - This lets subsequent arrow keys continue from the pointer-selected row.
  // - A disabled node exposes no actionable disclosure callback or enabled semantics.
  // - External controller state may still contain disabled values without crashing.
  // - Such external state cannot use keyboard activation to expand a disabled node.
  // - Left-collapse routes through `_toggle` rather than mutating the controller alone.
  // - Thus pointer and keyboard collapse publish the same callback and haptic role.
  // - Right-expand likewise shares loading, retry, callback, and haptic ownership.
  // - Right on an expanded branch may select its first visible direct child.
  // - If that child is disabled, selection remains on the current enabled endpoint.
  // - Up or Down can still move past that disabled child to later enabled content.
  // - Loading disclosure is disabled visually while the current request is pending.
  // - A repeated pointer activation therefore cannot start an overlapping loader.
  // - Programmatic expansion during loading does not grant stale request ownership.
  // - AnimatedList state mirrors only `_visible`, never an independently flattened list.
  // - Structural application reorder resets that state instead of faking branch motion.
  // - Expansion insertion/removal continues to use the calibrated tree motion token.
  // - Reduced motion replaces the AnimatedList so no partial row remains sampled.
  // - Stable node values remain required for controller expansion and selection identity.
  // - Duplicate values are ambiguous application data even when rendering is tolerated.
  // - Eager child lists follow Flutter's immutable widget-configuration convention.
  // - Custom node builders receive selected and expanded state from one build snapshot.
  // - Row geometry normalization remains independent from loader and keyboard state.
  // - Nested trees do not inherit route safe-area padding already consumed by a page.
  // - Empty trees expose the supplied empty state without creating a dormant list focus.
  // - Disposal removes controller listeners before releasing privately owned controllers.
  // - External controllers and their expansion state always remain caller-owned.
  // - These invariants are shared by Android touch and Windows keyboard interaction.
  final Map<T, Object> _loadTokens = <T, Object>{};
  final Map<T, Future<List<MiuixTreeNode<T>>> Function()> _activeLoaders =
      <T, Future<List<MiuixTreeNode<T>>> Function()>{};
  final FocusNode _focusNode = FocusNode(debugLabel: 'MiuixTreeView');
  GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late List<_VisibleTreeNode<T>> _visible;
  bool _reduceMotion = false;
  Duration _treeMotion = const Duration(milliseconds: 280);

  @override
  void initState() {
    super.initState();
    _attachController();
    _visible = _flatten();
  }

  void _attachController() {
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? MiuixTreeController<T>();
    _controller.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(MiuixTreeView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _invalidateActiveLoads();
      _controller.removeListener(_rebuild);
      if (_ownsController) _controller.dispose();
      _attachController();
      _resetVisibleList();
    } else if (oldWidget.nodes != widget.nodes) {
      _invalidateReplacedLoads();
      _resetVisibleList();
    }
  }

  MiuixTreeNode<T>? _findCurrentNode(T value) {
    final visited = <T>{};
    MiuixTreeNode<T>? visit(List<MiuixTreeNode<T>> nodes) {
      for (final node in nodes) {
        if (node.value == value) return node;
        if (!visited.add(node.value)) continue;
        final nested = visit(_childrenOf(node));
        if (nested != null) return nested;
      }
      return null;
    }

    return visit(widget.nodes);
  }

  void _invalidateReplacedLoads() {
    // A loader Future belongs to the exact node definition that started it.
    // Reusing only the value would let a late result from an old data source
    // populate a replacement node with the same stable application key.
    // Cached children retain the loader identity that produced them. Walk to
    // a fixed point because invalidating a replaced parent may make cached
    // descendants unreachable on the next pass.
    var removed = true;
    while (removed) {
      removed = false;
      final values = <T>{..._activeLoaders.keys, ..._loadedLoaders.keys};
      for (final value in values) {
        final expected = _activeLoaders[value] ?? _loadedLoaders[value];
        final current = _findCurrentNode(value);
        if (current != null &&
            expected != null &&
            identical(current.childrenLoader, expected)) {
          continue;
        }
        _loadTokens.remove(value);
        _activeLoaders.remove(value);
        _loadedLoaders.remove(value);
        _loadedChildren.remove(value);
        _loading.remove(value);
        _loadErrors.remove(value);
        removed = true;
      }
    }
  }

  void _invalidateActiveLoads() {
    final active = _activeLoaders.keys.toList(growable: false);
    for (final value in active) {
      _loadTokens.remove(value);
      _loading.remove(value);
      _loadErrors.remove(value);
    }
    _activeLoaders.clear();
  }

  void _rebuild() {
    if (!mounted) return;
    _syncVisibleList(_flatten());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final treeMotion = MiuixTheme.of(context).hyperOs4.treeExpansionMotion;
    if (reduceMotion != _reduceMotion) {
      _reduceMotion = reduceMotion;
      // Replacing AnimatedList discards any internal insertion/removal sample
      // and publishes the controller's current logical branch set immediately.
      _resetVisibleList();
    }
    _treeMotion = treeMotion;
  }

  void _resetVisibleList() {
    _visible = _flatten();
    _listKey = GlobalKey<AnimatedListState>();
  }

  void _syncVisibleList(List<_VisibleTreeNode<T>> target) {
    final listState = _listKey.currentState;
    if (listState == null) {
      setState(() {
        _visible = target;
        _listKey = GlobalKey<AnimatedListState>();
      });
      return;
    }
    final targetValues = target.map((entry) => entry.node.value).toSet();
    final duration = _reduceMotion ? Duration.zero : _treeMotion;
    for (var index = _visible.length - 1; index >= 0; index--) {
      if (targetValues.contains(_visible[index].node.value)) continue;
      final removed = _visible.removeAt(index);
      listState.removeItem(
        index,
        (context, animation) => _animatedRow(context, removed, animation),
        duration: duration,
      );
    }
    for (var index = 0; index < target.length; index++) {
      final targetEntry = target[index];
      if (index < _visible.length &&
          _visible[index].node.value == targetEntry.node.value) {
        _visible[index] = targetEntry;
        continue;
      }
      final laterIndex = _visible.indexWhere(
        (entry) => entry.node.value == targetEntry.node.value,
        index,
      );
      if (laterIndex >= 0) {
        // Arbitrary application data reordering is not a tree expansion. Reset
        // atomically instead of emitting misleading remove/insert branch motion.
        setState(() {
          _visible = target;
          _listKey = GlobalKey<AnimatedListState>();
        });
        return;
      }
      _visible.insert(index, targetEntry);
      listState.insertItem(index, duration: duration);
    }
    setState(() {});
  }

  List<MiuixTreeNode<T>> _childrenOf(MiuixTreeNode<T> node) =>
      _loadedChildren[node.value] ?? node.children;

  List<_VisibleTreeNode<T>> _flatten() {
    final result = <_VisibleTreeNode<T>>[];
    void visit(List<MiuixTreeNode<T>> nodes, int depth, T? parent) {
      for (final node in nodes) {
        result.add(
          _VisibleTreeNode<T>(node: node, depth: depth, parent: parent),
        );
        if (_controller.isExpanded(node.value)) {
          visit(_childrenOf(node), depth + 1, node.value);
        }
      }
    }

    visit(widget.nodes, 0, null);
    return result;
  }

  Future<void> _toggle(MiuixTreeNode<T> node) async {
    if (!node.enabled || !node.canExpand) return;
    if (_controller.isExpanded(node.value)) {
      _controller.collapse(node.value);
      widget.onExpansionChanged?.call(node.value, false);
      MiuixHaptics.perform(MiuixHapticType.toggleOff);
      return;
    }
    if (node.childrenLoader != null &&
        !_loadedChildren.containsKey(node.value)) {
      if (_loading.contains(node.value)) return;
      final loader = node.childrenLoader!;
      final token = Object();
      _loadTokens[node.value] = token;
      _activeLoaders[node.value] = loader;
      setState(() {
        _loading.add(node.value);
        _loadErrors.remove(node.value);
      });
      try {
        final children = await loader();
        if (!mounted ||
            !identical(_loadTokens[node.value], token) ||
            !identical(_findCurrentNode(node.value)?.childrenLoader, loader)) {
          return;
        }
        _loadedChildren[node.value] = List<MiuixTreeNode<T>>.unmodifiable(
          children,
        );
        _loadedLoaders[node.value] = loader;
      } catch (error) {
        if (!mounted || !identical(_loadTokens[node.value], token)) return;
        _loadErrors[node.value] = error;
        return;
      } finally {
        if (mounted && identical(_loadTokens[node.value], token)) {
          setState(() {
            _loadTokens.remove(node.value);
            _activeLoaders.remove(node.value);
            _loading.remove(node.value);
          });
        }
      }
    }
    _controller.expand(node.value);
    widget.onExpansionChanged?.call(node.value, true);
    MiuixHaptics.perform(MiuixHapticType.toggleOn);
  }

  void _select(MiuixTreeNode<T> node) {
    if (!node.enabled) return;
    _controller.selected = node.value;
    widget.onSelected?.call(node.value);
    MiuixHaptics.perform(MiuixHapticType.confirm);
  }

  void _moveSelection(int delta) {
    final visible = _flatten();
    if (visible.isEmpty || delta == 0) return;
    final current = visible.indexWhere(
      (entry) => entry.node.value == _controller.selected,
    );
    final direction = delta < 0 ? -1 : 1;
    var index = current < 0 ? (direction > 0 ? -1 : visible.length) : current;
    for (var remaining = delta.abs(); remaining > 0; remaining--) {
      int? candidate;
      for (
        var next = index + direction;
        next >= 0 && next < visible.length;
        next += direction
      ) {
        if (visible[next].node.enabled) {
          candidate = next;
          break;
        }
      }
      if (candidate == null) break;
      index = candidate;
    }
    if (index >= 0 && index < visible.length) _select(visible[index].node);
  }

  void _handleHorizontal(bool towardEnd) {
    final visible = _flatten();
    final entry = visible.cast<_VisibleTreeNode<T>?>().firstWhere(
      (candidate) => candidate?.node.value == _controller.selected,
      orElse: () => null,
    );
    if (entry == null) return;
    if (towardEnd) {
      if (entry.node.canExpand && !_controller.isExpanded(entry.node.value)) {
        unawaited(_toggle(entry.node));
      } else {
        final index = visible.indexOf(entry);
        if (index + 1 < visible.length &&
            visible[index + 1].parent == entry.node.value) {
          _select(visible[index + 1].node);
        }
      }
    } else if (_controller.isExpanded(entry.node.value)) {
      unawaited(_toggle(entry.node));
    } else if (entry.parent != null) {
      final parent = visible.firstWhere(
        (candidate) => candidate.node.value == entry.parent,
      );
      _select(parent.node);
    }
  }

  Widget _row(
    BuildContext context,
    _VisibleTreeNode<T> entry,
    MiuixTreeViewColors palette,
  ) {
    final node = entry.node;
    final selected = node.value == _controller.selected;
    final expanded = _controller.isExpanded(node.value);
    final loading = _loading.contains(node.value);
    final error = _loadErrors[node.value];
    final content = widget.nodeBuilder?.call(context, node, selected, expanded);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    // Tree row geometry contract:
    // - Depth remains structural data and is never rewritten.
    // - Finite positive indentation preserves the caller's hierarchy rhythm.
    // - Zero intentionally aligns descendants with their parent.
    // - Negative indentation cannot move children outside the leading edge.
    // - Non-finite indentation uses the stable 24dp source default.
    // - Row radius never receives a non-finite theme or public value.
    // - Padding and surface geometry resolve in the same build snapshot.
    // - Keyboard and pointer selection are unaffected by visual normalization.
    final themeRowRadius = hyperOs4.collectionRowCornerRadius.isFinite
        ? hyperOs4.collectionRowCornerRadius.clamp(0.0, double.infinity)
        : 0.0;
    final rowRadius = widget.rowCornerRadius.isFinite
        ? widget.rowCornerRadius.clamp(0.0, double.infinity).toDouble()
        : themeRowRadius.toDouble();
    final indentation = widget.indentation.isFinite
        ? widget.indentation.clamp(0.0, double.infinity).toDouble()
        : MiuixTreeViewDefaults.indentation;
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: entry.depth * indentation,
        top: 2,
        bottom: 2,
      ),
      child: TweenAnimationBuilder<double>(
        // Policy identity discards an in-flight sample when reduced motion is
        // enabled, while stable node identity still permits normal retargeting.
        key: ValueKey<(T, bool)>((node.value, reduceMotion)),
        tween: Tween<double>(end: selected ? 1 : 0),
        duration: reduceMotion ? Duration.zero : hyperOs4.collectionRowMotion,
        curve: Curves.easeOutCubic,
        builder: (context, selectionProgress, _) {
          final foreground = !node.enabled
              ? palette.disabledForeground
              : Color.lerp(
                  palette.foreground,
                  palette.selectedForeground,
                  selectionProgress,
                )!;
          final background = Color.lerp(
            Colors.transparent,
            palette.selectedBackground,
            selectionProgress,
          )!;
          return Semantics(
            button: true,
            selected: selected,
            enabled: node.enabled,
            expanded: node.canExpand ? expanded : null,
            label: node.label,
            child: MiuixSurface(
              key: ValueKey<Object>(('miuix-tree-row', node.value)),
              radius: rowRadius,
              color: background,
              onTap: node.enabled
                  ? () {
                      _focusNode.requestFocus();
                      _select(node);
                    }
                  : null,
              padding: const EdgeInsetsDirectional.only(end: 12),
              child: MiuixTreeRowLayout(
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      width: 40,
                      child: node.canExpand
                          ? MiuixIconButton(
                              icon: loading
                                  ? const SizedBox.square(
                                      dimension: 18,
                                      child: MiuixInfiniteProgressIndicator(),
                                    )
                                  : error != null
                                  ? MiuixThemedIcon(
                                      MiuixExtensionGlyphs.refresh,
                                    )
                                  : expanded
                                  ? const MiuixExtensionChevron(
                                      direction:
                                          MiuixExtensionChevronDirection.down,
                                    )
                                  : MiuixThemedIcon(
                                      MiuixExtensionGlyphs.chevronForward,
                                    ),
                              onPressed: node.enabled && !loading
                                  ? () {
                                      _focusNode.requestFocus();
                                      unawaited(_toggle(node));
                                    }
                                  : null,
                              tooltip: error != null
                                  ? '重试加载'
                                  : expanded
                                  ? '折叠'
                                  : '展开',
                            )
                          : null,
                    ),
                    if (node.icon != null ||
                        node.expandedIcon != null) ...<Widget>[
                      IconTheme(
                        data: IconThemeData(color: foreground, size: 22),
                        child: expanded
                            ? (node.expandedIcon ?? node.icon!)
                            : (node.icon ?? node.expandedIcon!),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ],
                ),
                content:
                    content ??
                    Text(
                      node.label,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: foreground,
                        fontWeight: selected ? FontWeight.w600 : null,
                      ),
                    ),
                trailing: node.trailing,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _animatedRow(
    BuildContext context,
    _VisibleTreeNode<T> entry,
    Animation<double> animation,
  ) {
    final palette = widget.colors ?? MiuixTreeViewDefaults.colors(context);
    return SizeTransition(
      sizeFactor: animation,
      alignment: AlignmentDirectional.topCenter,
      child: FadeTransition(
        opacity: animation,
        child: _row(context, entry, palette),
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_rebuild);
    if (_ownsController) _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.nodes.isEmpty) {
      return widget.emptyState ??
          const MiuixEmptyState(title: '没有层级内容', message: '这里还没有可以显示的节点。');
    }
    final visible = _flatten();
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.arrowUp): _TreeMoveIntent(-1),
        SingleActivator(LogicalKeyboardKey.arrowDown): _TreeMoveIntent(1),
        SingleActivator(LogicalKeyboardKey.arrowLeft): _TreeHorizontalIntent(
          false,
        ),
        SingleActivator(LogicalKeyboardKey.arrowRight): _TreeHorizontalIntent(
          true,
        ),
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _TreeMoveIntent: CallbackAction<_TreeMoveIntent>(
            onInvoke: (intent) {
              _moveSelection(intent.delta);
              return null;
            },
          ),
          _TreeHorizontalIntent: CallbackAction<_TreeHorizontalIntent>(
            onInvoke: (intent) {
              _handleHorizontal(rtl ? !intent.towardEnd : intent.towardEnd);
              return null;
            },
          ),
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              final selected = visible.cast<_VisibleTreeNode<T>?>().firstWhere(
                (entry) => entry?.node.value == _controller.selected,
                orElse: () => null,
              );
              if (selected != null) unawaited(_toggle(selected.node));
              return null;
            },
          ),
        },
        child: Focus(
          focusNode: _focusNode,
          child: AnimatedList(
            key: _listKey,
            // A nested shrink-wrapped ListView otherwise consumes the route's
            // MediaQuery safe-area padding. That creates a large blank band
            // above and below a small tree even though the parent page already
            // handles system insets.
            primary: false,
            padding: EdgeInsets.zero,
            shrinkWrap: widget.shrinkWrap,
            physics:
                widget.physics ??
                (widget.shrinkWrap
                    ? const NeverScrollableScrollPhysics()
                    : null),
            initialItemCount: _visible.length,
            itemBuilder: (context, index, animation) =>
                _animatedRow(context, _visible[index], animation),
          ),
        ),
      ),
    );
  }
}

class _TreeMoveIntent extends Intent {
  const _TreeMoveIntent(this.delta);
  final int delta;
}

class _TreeHorizontalIntent extends Intent {
  const _TreeHorizontalIntent(this.towardEnd);
  final bool towardEnd;
}

/// 树形列表的自适应内容和操作布局。
/// 标题与说明由调用方提供，控件只安排可用宽度和自然高度。
/// 同步目录和异步树复用此布局，避免各自隐藏大字号内容。
class MiuixTreeRowLayout extends StatelessWidget {
  /// 最低行高保持原树行节奏，长文字可以继续向下展开。
  /// leading 用于展开键与图标，trailing 用于操作按钮。
  const MiuixTreeRowLayout({
    super.key,
    this.leading,
    required this.content,
    this.trailing,
  });

  /// 前导区不拉伸，保留原来的点击范围。
  final Widget? leading;

  /// 内容获得剩余宽度，不设置行数或省略号。
  final Widget content;

  /// 窄屏大字时移到内容下方，不遮挡或挤掉标题。
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, bounds) {
      // 这是排版阈值，不参与任务或奖励的操作资格。
      // 字号放大时提高同排所需宽度，普通宽度保持紧凑。
      final scale = MediaQuery.textScalerOf(context).scale(16) / 16;
      // 阈值是本库排版选择，不宣称为系统官方尺寸。
      // 没有尾部操作时无需生成空的第二行。
      final stacked = trailing != null && bounds.maxWidth < 280 * scale;
      return ConstrainedBox(
        // 原行高作为下限，不再把大字号和多行内容裁进固定高度。
        // 图标与控件仍按原点击范围布局，不通过缩字适配。
        constraints: const BoxConstraints(
          minHeight: MiuixTreeViewDefaults.rowExtent,
        ),
        // 纵向内边距同时服务单排与双排，避免状态切换时顶边跳动。
        // 图标、标题与按钮仍由原组件各自处理点击和焦点。
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            // 无固定最大高度，列表会为真实多行内容分配空间。
            // 普通短行仍由最低行高维持原有节奏。
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // leading 只占其自然宽度，不随正文一起伸展。
              // 操作换行时前导图标继续与标题属于同一内容行。
              Row(
                children: [
                  ?leading,
                  // 标题列获得实际剩余宽度，换行由内容组件决定。
                  // 不能在公共行布局中强加最大行数。
                  Expanded(child: content),
                  // 同排时保留文字与操作的明确间隔。
                  if (!stacked && trailing != null)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 8),
                      child: trailing!,
                    ),
                ],
              ),
              if (stacked)
                Padding(
                  // 纵排操作靠行尾，标题和全部说明继续自然换行。
                  // RTL 使用方向对齐，不把按钮固定到物理右侧。
                  padding: const EdgeInsets.only(top: 8),
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    // 对齐只影响位置，不包裹额外手势或语义层。
                    child: trailing,
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}
