part of '../miuix_widgets.dart';

/// Normalizes public popup width input before it reaches BoxConstraints.
///
/// Width-boundary rules:
///
/// - 200dp is the documented component default and non-finite fallback.
/// - NaN cannot participate in min/max arithmetic and therefore uses fallback.
/// - Positive infinity is not a valid minimum inside a finite route surface.
/// - Negative infinity likewise cannot produce a meaningful intrinsic width.
/// - Finite negative values clamp to zero instead of creating invalid constraints.
/// - Zero remains a valid explicit request for content-driven minimum width.
/// - 288dp is the source list-popup maximum used by the surrounding surfaces.
/// - Normalizing here keeps ordinary, grouped, and cascading lists consistent.
/// - Release behavior must not depend on constructor asserts being enabled.
/// - The outer route may still apply a tighter maximum for a small safe window.
double _safeListPopupMinWidth(double value) {
  if (!value.isFinite) return 200;
  return value.clamp(0.0, 288.0).toDouble();
}

/// List popup surface that can be hosted in dialogs, sheets, or popovers.
class MiuixListPopup<T> extends StatefulWidget {
  /// Creates a list popup.
  const MiuixListPopup({
    super.key,
    required this.entries,
    required this.onSelected,
    this.groups = const [],
    this.minWidth = 200,
    this.allowMultipleSelection = false,
    this.sourceRows = false,
    this.dialogMode = false,
    this.colors,
    this.showSurface = true,
    this.glass = true,
  });

  /// Entries to display.
  final List<MiuixDropdownEntry<T>> entries;

  /// Optional independent entry groups separated by MIUIX dividers.
  final List<MiuixDropdownGroup<T>> groups;

  /// Minimum intrinsic popup width, capped by the source 288dp maximum.
  ///
  /// Localized labels can be shorter than the source strings. Callers that
  /// reproduce a translated reference UI may retain the original intrinsic
  /// width without inserting invisible text into the menu.
  final double minWidth;

  /// Whether each group may keep more than one checked entry.
  final bool allowMultipleSelection;

  /// Whether rows use the current source `DropdownImpl` geometry and colors.
  final bool sourceRows;

  /// Whether source rows use full-width dialog measurements.
  final bool dialogMode;

  /// Optional current-source dropdown color channels.
  final MiuixDropdownColors? colors;

  /// Whether this widget owns the rounded popup surface.
  ///
  /// Dialogs already own their outer surface, so their grouped lazy content
  /// sets this to false and lets selected row backgrounds reach the edges.
  final bool showSurface;

  /// Whether the owned popup surface samples the anchored page behind it.
  final bool glass;

  /// Selection callback.
  final ValueChanged<T> onSelected;

  @override
  State<MiuixListPopup<T>> createState() => _MiuixListPopupState<T>();
}

/// Keeps every popup group's active row visible while the popup remains open.
class _MiuixListPopupState<T> extends State<MiuixListPopup<T>> {
  late List<Set<T>> _selectedValues;

  List<MiuixDropdownGroup<T>> get _resolvedGroups {
    if (widget.groups.isEmpty) {
      return [MiuixDropdownGroup<T>(entries: widget.entries)];
    }
    // Current preference overloads discard empty DropdownEntry groups before
    // calculating enabled state, selected labels, dividers, and popup layout.
    return widget.groups
        .where((group) => group.entries.isNotEmpty)
        .toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    _syncSelectedValues();
  }

  @override
  void didUpdateWidget(covariant MiuixListPopup<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entries != widget.entries ||
        oldWidget.groups != widget.groups) {
      _syncSelectedValues();
    }
  }

  /// Reads the caller's initial selection once for each independent group.
  void _syncSelectedValues() {
    _selectedValues = _resolvedGroups
        .map<Set<T>>(
          (group) => group.entries
              .where((entry) => entry.selected)
              .map((entry) => entry.value)
              .toSet(),
        )
        .toList(growable: false);
  }

  /// Updates the check mark locally before notifying the owning preference.
  void _select(int groupIndex, MiuixDropdownEntry<T> entry) {
    final wasSelected = _selectedValues[groupIndex].contains(entry.value);
    setState(() {
      if (widget.allowMultipleSelection) {
        final values = _selectedValues[groupIndex];
        if (!values.remove(entry.value)) {
          values.add(entry.value);
        }
      } else {
        _selectedValues[groupIndex] = {entry.value};
      }
    });
    // Current DropdownPopup performs Confirm for every accepted row click,
    // including a re-tap of the selected value. The generic compatibility
    // surface retains its quieter state-boundary-only segment tick.
    if (widget.sourceRows) {
      unawaited(MiuixHaptics.perform(MiuixHapticType.confirm));
    } else if (widget.allowMultipleSelection || !wasSelected) {
      unawaited(MiuixHaptics.perform(MiuixHapticType.segmentTick));
    }
    widget.onSelected(entry.value);
  }

  /// Builds the exact DropdownImpl row, including the transparent check slot.
  ///
  /// Compose always measures the 20dp check image and its 12dp start padding,
  /// even for an unselected row whose check color is transparent. Reserving
  /// that slot is required for the same intrinsic popup width and text column.
  Widget _buildEntry(
    BuildContext context,
    int groupIndex,
    int entryIndex, {
    required bool isFirst,
    required bool isLast,
  }) {
    final group = _resolvedGroups[groupIndex];
    final entry = group.entries[entryIndex];
    final enabled = group.enabled && entry.enabled;
    final selected = _selectedValues[groupIndex].contains(entry.value);
    if (widget.sourceRows) {
      return MiuixDropdownImpl(
        text: entry.label,
        summary: entry.summary,
        icon: entry.icon,
        enabled: enabled,
        optionSize: group.entries.length,
        isSelected: selected,
        index: entryIndex,
        dialogMode: widget.dialogMode,
        isFirst: isFirst,
        isLast: isLast,
        colors: widget.colors,
        onSelectedIndexChange: (_) => _select(groupIndex, entry),
      );
    }
    return _MiuixMenuRow(
      enabled: enabled,
      icon: entry.icon,
      label: entry.label,
      summary: entry.summary,
      isFirst: isFirst,
      isLast: isLast,
      selected: selected,
      // DropdownImpl.kt leaves Text unconstrained vertically. Long labels wrap
      // within the 216dp text budget and therefore participate in the source
      // first-eight-row intrinsic viewport height.
      allowTextWrap: true,
      trailing: _MiuixDropdownCheck(
        color: selected
            ? Theme.of(context).colorScheme.primary
            : Colors.transparent,
      ),
      onTap: enabled ? () => _select(groupIndex, entry) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolvedGroups = _resolvedGroups;
    final rowCount = resolvedGroups.fold<int>(
      0,
      (total, group) => total + group.entries.length,
    );
    final scheme = Theme.of(context).colorScheme;
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final density = MediaQuery.devicePixelRatioOf(context);
    final dividerHorizontal = _miuixRoundLogicalDimension(20, density);
    final dividerVertical = _miuixRoundLogicalDimension(4, density);
    final dividerThickness = _miuixRoundLogicalDimension(1.5, density);
    // ListPopupColumn, rather than Flutter IntrinsicWidth, measures only the
    // first eight rows before clamping the result to the source 200..288dp
    // interval. Later long rows therefore scroll/truncate without silently
    // widening an already measured popup.
    final children = <Widget>[
      if (rowCount == 0)
        const _MiuixMenuRow(
          label: 'No actions',
          enabled: false,
          isFirst: true,
          isLast: true,
        )
      else
        for (
          var groupIndex = 0;
          groupIndex < resolvedGroups.length;
          groupIndex++
        ) ...[
          if (groupIndex > 0)
            Padding(
              // DropdownEntriesPopupContent.kt keeps group separators out of
              // the row padding: 20dp horizontal, 4dp vertical, 1.5dp thick.
              // Compose rounds all three dimensions before measuring. At the
              // 420dpi reference density this is 53px, 11px, and 4px, making
              // the complete separator placeable exactly 26px high.
              padding: EdgeInsets.symmetric(
                horizontal: dividerHorizontal,
                vertical: dividerVertical,
              ),
              child: MiuixHorizontalDivider(
                indent: 0,
                endIndent: 0,
                thickness: dividerThickness,
              ),
            ),
          for (
            var entryIndex = 0;
            entryIndex < resolvedGroups[groupIndex].entries.length;
            entryIndex++
          )
            _buildEntry(
              context,
              groupIndex,
              entryIndex,
              isFirst: groupIndex == 0 && entryIndex == 0,
              isLast:
                  groupIndex == resolvedGroups.length - 1 &&
                  entryIndex == resolvedGroups[groupIndex].entries.length - 1,
            ),
        ],
    ];
    final content = widget.dialogMode
        ? Column(mainAxisSize: MainAxisSize.min, children: children)
        : MiuixListPopupColumn(children: children);
    if (!widget.showSurface) {
      return content;
    }
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: _safeListPopupMinWidth(widget.minWidth),
        maxWidth: 288,
      ),
      child: MiuixSurface(
        padding: EdgeInsets.zero,
        radius: MiuixListPopupDefaults.cornerRadius,
        color: scheme.surfaceContainer,
        glass: widget.glass,
        glassBlur: hyperOs4.popupBlur,
        glassOpacity: hyperOs4.popupTintOpacity,
        glassOptics: MiuixGlassOptics.transient,
        showGlassSpecular: true,
        child: content,
      ),
    );
  }
}

/// Coordinates the route-level Back contract of a two-level cascading popup.
///
/// The current MIUIX implementation treats a cascading popup as one route with
/// two navigation depths, rather than as two independently dismissible routes.
/// That distinction matters because Flutter can notify more than one scoped
/// pop callback for a single platform Back event. The controller therefore
/// exposes one atomic operation: consume Back by collapsing depth one when a
/// secondary list is visible, or report that the host may dismiss depth zero.
class MiuixCascadingPopupController extends ChangeNotifier {
  bool _secondaryExpanded = false;
  final _MiuixListPopupBackProgress _backExpandProgress =
      _MiuixListPopupBackProgress();

  /// Collapses a visible secondary menu and reports whether Back was consumed.
  bool collapseSecondary() {
    if (!_secondaryExpanded) {
      return false;
    }
    _secondaryExpanded = false;
    notifyListeners();
    return true;
  }

  void _setSecondaryExpanded(bool value) {
    if (_secondaryExpanded == value) {
      return;
    }
    _secondaryExpanded = value;
    notifyListeners();
  }

  void _finishSecondaryCollapse() => _backExpandProgress.update(0);

  @override
  void dispose() {
    _backExpandProgress.dispose();
    super.dispose();
  }
}

/// Exact current-source Folme spring used by cascading depth motion.
///
/// Source-to-Flutter conversion contract:
/// * Kotlin expresses this motion with damping ratio and response time.
/// * Flutter expresses it with mass, stiffness, and absolute damping.
/// * Unit mass is retained because the source helper normalizes its solver.
/// * Angular frequency is exactly `2 * pi / response`.
/// * Stiffness is the square of that angular frequency.
/// * Absolute damping is `2 * ratio * angularFrequency` for unit mass.
/// * Expansion uses damping ratio 0.99 rather than a critically damped 1.0.
/// * Expansion response is 0.45 seconds rather than a 450ms linear duration.
/// * Collapse uses damping ratio 0.95 and intentionally carries more velocity.
/// * Collapse response is 0.20 seconds rather than an ease-out curve.
/// * Retargeting passes the live controller velocity into SpringSimulation.
/// * A reversal therefore does not restart from a stationary sampled value.
/// * The unbounded controller preserves the source's tiny legal overshoot.
/// * Paint and clip consumers clamp only when mapping progress to geometry.
/// * The physical simulation itself remains unclamped for velocity continuity.
/// * Expansion and collapse use different SpringDescription instances.
/// * No fixed AnimationController duration participates in depth settling.
/// * Ticker tolerance decides completion just as the physical spring settles.
/// * Back during expansion retargets the same controller toward zero.
/// * Re-expansion during collapse retargets it toward one with live velocity.
/// * The displayed secondary remains mounted through collapse completion.
/// * A canceled TickerFuture is lifecycle control, not a runtime failure.
/// * Primary scale samples `1 - 0.05 * progress` from this same controller.
/// * Primary mask samples half window dim multiplied by the same progress.
/// * Secondary clipping and both arrow rotations share the identical sample.
/// * This prevents four nominally related implicit animations from drifting.
/// * A deterministic test protects the derived stiffness and damping values.
/// * A second deterministic test protects a non-endpoint 100ms clip frame.
/// * Android screenshots are reserved for settled geometry and visual paint.
/// * Process startup latency is never treated as reliable motion-frame timing.
/// * Changing either response requires updating source evidence and tests.
/// * Substituting an easing curve would violate velocity-preserving retargeting.
/// * Substituting milliseconds for response would also change the trajectory.
@visibleForTesting
SpringDescription debugMiuixCascadingSpring({required bool expanding}) {
  final response = expanding ? .45 : .2;
  final dampingRatio = expanding ? .99 : .95;
  final angularFrequency = 2 * math.pi / response;
  return SpringDescription.withDampingRatio(
    mass: 1,
    stiffness: angularFrequency * angularFrequency,
    ratio: dampingRatio,
  );
}

/// Current two-level cascading popup built from grouped dropdown entries.
///
/// This widget follows the public `CascadingListPopup` behavior introduced by
/// the current Compose MIUIX source. The following contract is deliberately
/// documented next to the implementation so future ports can be checked
/// against upstream behavior instead of preserving a convenient Flutter-only
/// interpretation:
///
/// Data and hierarchy:
///
/// * [groups] preserves every upstream `DropdownEntry` group boundary.
/// * A top-level row without children is a selectable primary leaf.
/// * A top-level row with children is a submenu trigger, not a selectable leaf.
/// * Cascading depth is limited to two; grandchildren are not rendered.
/// * A secondary list begins with a cloned parent row that acts as Back.
/// * Group dividers remain part of the measured primary popup content.
///
/// Selection:
///
/// * Each sibling list owns one visible check selection at a time.
/// * A leaf callback runs only after the local check state has been updated.
/// * Parent triggers never emit their value through [onSelected].
/// * Disabled leaves keep their row geometry but cannot change selection.
/// * The popup host decides whether a leaf selection closes the whole popup.
///
/// Geometry:
///
/// * Primary and secondary surfaces use the source 16dp corner radius.
/// * Width is constrained to the source 200dp to 288dp interval.
/// * Rows reuse the same leading, label, summary, and check slots as list popup.
/// * The selected check occupies a fixed 20dp trailing slot.
/// * Group separators use 20dp horizontal and 4dp vertical insets.
/// * Separator thickness is the source 1.5dp physical design value.
/// * The content grows from the top edge so the anchor does not jump vertically.
///
/// Motion:
///
/// * Expansion keeps the primary content alive while secondary content enters.
/// * The primary plane shrinks toward the source 0.95 scale.
/// * Secondary content expands with the current 0.45-second response.
/// * Collapse uses the shorter current 0.20-second response.
/// * The parent arrow rotates toward the submenu according to layout direction.
/// * Fade and scale are independent tracks and must not resize the popup first.
/// * A collapsed submenu remains composed until its exit motion settles.
///
/// Back and dismissal:
///
/// * Back at depth one collapses the submenu and keeps the popup visible.
/// * Back at depth zero delegates dismissal to the owning popup host.
/// * One physical Back event must never collapse and dismiss in the same frame.
/// * An outside tap at depth one follows the host's dismissal policy.
/// * Overlay and window hosts share content behavior but own separate routes.
/// * The optional [controller] bridges these rules to either host family.
///
/// Rendering and updates:
///
/// * Selected state is rebuilt when the caller supplies changed groups.
/// * Replacing the controller transfers listeners without losing menu depth.
/// * The content uses stable depth keys so transitions compare distinct planes.
/// * Theme colors are resolved during build and respond to theme changes.
/// * The submenu header inherits the parent's icon, label, and summary.
/// * Leading and trailing slots remain reserved when their paint is transparent.
///
/// Input and semantics:
///
/// * Touch, mouse, stylus, Enter, and Space share the same enabled row action.
/// * A submenu trigger exposes its navigation affordance in the trailing slot.
/// * A selected leaf exposes the same checked state as a normal dropdown row.
/// * Disabled rows remain discoverable but never advertise a tap action.
/// * Focus order follows visible row order after the depth transition completes.
/// * The cloned secondary header is the first focusable return action.
/// * Right-to-left layout mirrors the submenu direction and arrow rotation.
/// * Haptic feedback belongs to the icon trigger, matching the upstream wrapper.
///
/// Host integration:
///
/// * Overlay presentation requires the nearest [MiuixPopupHostScope].
/// * Root-overlay presentation resolves the outermost popup host deliberately.
/// * Window presentation resolves the root Navigator and its platform barrier.
/// * Both presentations keep the anchor [LayerLink] alive for their full route.
/// * Dismiss completion is reported after exit animation, not at request time.
/// * A disabled trigger neither vibrates nor inserts a popup route.
/// * Selection callbacks remain valid when the host chooses not to collapse.
/// * Reopening begins at primary depth even if the previous route closed at one.
///
/// Verification invariants:
///
/// * Primary leaf checks must update without reconstructing the popup route.
/// * Entering a submenu must leave exactly one popup barrier in the tree.
/// * One Back at secondary depth must preserve that barrier.
/// * A second Back must remove the barrier and return focus to the trigger.
/// * Switching groups must not retain a value absent from the new entry tree.
/// * Long localized labels may increase intrinsic width only up to 288dp.
/// * Empty groups are ignored without adding consecutive visual dividers.
/// * A popup containing only empty groups still has deterministic empty content.
/// * Theme changes while open repaint the surface, text, arrow, and check.
/// * The two visible planes must never both receive pointer events.
/// * Exit animation must not emit an additional selection callback.
/// * Replacing a controller must not leave a listener on the disposed instance.
/// * Disposing an open popup must release controller and animation listeners.
/// * Golden coverage should compare primary, secondary, selected, and disabled.
/// * Interaction coverage should exercise Back separately from outside dismissal.
/// * Android coverage should include predictive Back at both navigation depths.
/// * Desktop coverage should include Escape and click-outside dismissal.
///
/// Upstream constant ledger:
///
/// * Main spring damping ratio: `0.95`.
/// * Expansion spring damping ratio: `0.99`.
/// * Expansion spring response: `0.45s`.
/// * Collapse spring response: `0.20s`.
/// * Arrow expansion response: `0.20s`.
/// * Arrow collapse response: `0.30s`.
/// * Primary background scale while expanded: `0.95`.
/// * Initial route-enter scale: `0.15`.
/// * Popup corner radius: `16dp`.
/// * Default minimum width: `200dp`.
/// * Maximum local width: `288dp`.
/// * Dropdown check viewport: `20dp`.
/// * Group divider horizontal inset: `20dp`.
/// * Group divider vertical inset: `4dp`.
/// * Group divider stroke: `1.5dp`.
///
/// Porting notes:
///
/// * Compose animates the primary and secondary as overlapping placeables.
/// * Flutter retains the primary locally and inserts the secondary in the
///   captured root Overlay so neither plane replaces or constrains the other.
/// * [AnimatedSize] follows content height without moving the top anchor.
/// * The controller is intentionally presentation-neutral.
/// * It contains no Navigator or popup-host reference.
/// * The owning trigger creates one controller for each popup lifetime.
/// * A post-frame latch suppresses duplicate dismissal callbacks.
/// * That latch is reset after the current Back dispatch has completed.
/// * Selection state stores values, not row indexes, across group replacement.
/// * Sibling removal implements single selection within the visible list.
/// * Parent and child values may be the same type but represent different rows.
/// * Stable value equality is therefore part of the caller's data contract.
/// * Empty children identify a leaf; an empty label does not.
/// * Summary absence does not change the row's leading/trailing alignment.
/// * Transparent checks preserve measurement while suppressing paint.
/// * Custom-painted arrows avoid platform icon-family orientation drift.
/// * The arrow path uses rounded caps and joins like the source vector.
/// * The arrow is painted in a fixed 10dp by 16dp viewport.
/// * Its semantic color follows the summary role, not primary content color.
///
/// Keeping this contract explicit is important because the older local
/// [MiuixCascadingMenu] is an expanding accordion. It remains available for
/// compatibility, but it is not the source-equivalent two-plane popup used by
/// current icon cascading dropdown menus.
/// Stable source position used while a cascading popup is visible.
///
/// Current MIUIX deliberately keeps the menu hierarchy positional while the
/// popup is shown. Callers commonly rebuild immutable entry objects after a
/// selection changes; retaining an object reference would leave the detached
/// secondary plane rendering stale labels, summaries, and selected states.
@immutable
class _MiuixCascadingItemPosition {
  /// Creates a group-and-entry coordinate in the authored entry tree.
  const _MiuixCascadingItemPosition(this.groupIndex, this.itemIndex);

  /// Index in the complete group list, including empty groups.
  final int groupIndex;

  /// Index in the selected group's top-level entry list.
  final int itemIndex;

  @override
  bool operator ==(Object other) =>
      other is _MiuixCascadingItemPosition &&
      other.groupIndex == groupIndex &&
      other.itemIndex == itemIndex;

  @override
  int get hashCode => Object.hash(groupIndex, itemIndex);
}

class MiuixGroupedCascadingListPopup<T> extends StatefulWidget {
  /// Creates a current grouped cascading popup.
  const MiuixGroupedCascadingListPopup({
    super.key,
    required this.groups,
    required this.onSelected,
    this.minWidth = 200,
    this.controller,
  });

  /// Primary popup groups.
  final List<MiuixDropdownGroup<T>> groups;

  /// Called when a leaf is selected.
  final ValueChanged<T> onSelected;

  /// Source-clamped minimum popup width.
  final double minWidth;

  /// Optional controller used by the popup host's Back and outside-tap guard.
  final MiuixCascadingPopupController? controller;

  @override
  State<MiuixGroupedCascadingListPopup<T>> createState() =>
      _MiuixGroupedCascadingListPopupState<T>();
}

class _MiuixGroupedCascadingListPopupState<T>
    extends State<MiuixGroupedCascadingListPopup<T>>
    with SingleTickerProviderStateMixin {
  // Dual-plane implementation ledger, derived from CascadingListPopupLayout:
  //
  // Measurement and anchoring:
  // * The primary plane uses ListPopupColumn, never a maximum-width Column.
  // * Only the first eight placeables participate in intrinsic width.
  // * The result remains clamped to the source 200..288dp interval.
  // * A translated fixture may raise the minimum to retain source geometry.
  // * The secondary minimum is the measured primary surface width.
  // * Secondary content still performs its own intrinsic-width probe.
  // * The trigger row is sampled before any primary transform begins.
  // * Its rectangle is converted from global into root-Overlay coordinates.
  // * That rectangle stays frozen until collapse has fully settled.
  // * Leading edges align when the measured secondary fits the window.
  // * Overflow falls back to the opposite physical window edge.
  // * Vertical overflow follows the same below/above source preference.
  //
  // Plane ownership and paint:
  // * The primary content never leaves the popup-host entry at depth one.
  // * Its 0.95 transform originates at the popup's logical top-end corner.
  // * The depth mask is half of the semantic window-dimming alpha.
  // * The mask is clipped by the same 16dp primary surface shape.
  // * The secondary lives in the root Overlay above that masked plane.
  // * Captured inherited themes retain MIUIX fonts, colors, and line boxes.
  // * An Overlay entry avoids constraining secondary paint to primary height.
  // * The displayed parent outlives the logical expanded state during exit.
  // * The secondary therefore cannot disappear before its reverse animation.
  // * Updating a selected child explicitly rebuilds the detached Overlay entry.
  // * Disposing the popup synchronously removes every detached paint object.
  // * Reopening starts a new expansion from the unscaled frozen row geometry.
  //
  // Input, Back, and dismissal:
  // * Primary rows are blocked by the in-surface mask at depth one.
  // * Secondary rows remain the only active menu actions during expansion.
  // * Tapping the secondary header requests a one-level collapse.
  // * Tapping outside the secondary also collapses only one level.
  // * The owning popup barrier remains alive while depth one collapses.
  // * Controller state is changed before the route may process another Back.
  // * A physical Back cannot collapse depth one and dismiss depth zero together.
  // * Controller-driven collapse avoids notifying that controller recursively.
  // * Leaf selection updates its sibling check set before invoking the caller.
  // * The host still owns collapse-on-selection and final route dismissal.
  // * Disabled parent and leaf rows keep geometry without advertising actions.
  // * Exit completion never emits an extra selection callback.
  //
  // Animation and lifecycle:
  // * Expansion retains the source 450ms response window.
  // * Collapse retains the shorter source 200ms response window.
  // * Primary scale, primary mask, secondary scale, and alpha stay independent.
  // * The secondary controller reverses before its Overlay entry is removed.
  // * A new expansion cancels removal by restoring a non-null expanded parent.
  // * Group replacement resynchronizes selections and row geometry keys.
  // * Controller replacement transfers depth notification ownership safely.
  // * Root-overlay insertion happens only after all required boxes are measured.
  // * Missing or detached geometry aborts expansion instead of guessing offsets.
  // * Every asynchronous continuation checks mounted and current depth again.
  // * The animation controller is owned by exactly one popup State lifetime.
  // * No nested Navigator or second modal barrier is created for depth one.
  //
  // Current positional-state revision, from upstream commit a370b37:
  // * Expanded depth is an authored group/item coordinate, not an entry object.
  // * Exit-retained depth uses the same coordinate until its spring completes.
  // * Primary row GlobalKeys use that coordinate rather than application value.
  // * Duplicate values in different groups therefore cannot share an anchor.
  // * Identity is consulted only when converting a tapped current row to position.
  // * Every later read resolves the newest entry object from widget.groups.
  // * Immutable parent rebuilds may change label, summary, icon, and children.
  // * The open secondary plane must reflect all of those new object fields.
  // * Stable structure means group and item counts/order remain unchanged open.
  // * Empty groups retain their authored indices even though paint skips them.
  // * Filtering empty groups must never renumber the stored source coordinate.
  // * Stable coordinates retain their GlobalKey and frozen row geometry.
  // * Coordinates that cease to identify a submenu are removed defensively.
  // * An invalid coordinate never redirects depth to a neighboring entry.
  // * Selected-value state is independently rebuilt from every latest leaf.
  // * The detached OverlayEntry cannot be marked dirty during parent build.
  // * Its rebuild is therefore requested from a post-frame callback.
  // * That callback verifies State mounting and OverlayEntry identity again.
  // * A removed or replaced overlay ignores a stale scheduled rebuild safely.
  // * Parent and secondary updates may therefore occupy consecutive frames.
  // * No route dismissal or depth collapse occurs during a stable data refresh.
  // * The controller continues reporting depth one across that refresh.
  // * The arrow compares its row coordinate with displayedPosition.
  // * Object equality cannot accidentally rotate a rebuilt neighboring row.
  // * Header corner and morph geometry resolve against the latest parent object.
  // * Secondary child callbacks likewise capture the latest child collection.
  // * The regression rebuilds parent, summary, child, and selected state together.
  // * It proves every stale string disappears while two parent copies remain.
  // * It also proves controller collapse still consumes depth after the rebuild.
  //
  // Regression obligations:
  // * Primary width must match the native 573px Home sample at 420dpi.
  // * Primary content must remain discoverable while secondary content is open.
  // * Secondary left/top must equal the frozen trigger-row leading/top origin.
  // * Secondary width must be at least the unscaled primary width.
  // * One Back must remove secondary text while retaining primary text.
  // * A second Back remains the owning host's responsibility.
  // * Long labels may expand only until the 288dp source maximum.
  // * Low anchors must flip above without leaving the physical window.
  // * RTL must mirror the primary transform origin and leading-edge preference.
  // * Runtime evidence must include both settled planes, not only widget symbols.
  final GlobalKey _primaryGeometryKey = GlobalKey();
  final Map<_MiuixCascadingItemPosition, GlobalKey> _submenuRowKeys =
      <_MiuixCascadingItemPosition, GlobalKey>{};
  _MiuixCascadingItemPosition? _expandedPosition;
  _MiuixCascadingItemPosition? _displayedPosition;
  OverlayEntry? _secondaryOverlay;
  Rect? _secondaryAnchor;
  double _primaryWidth = 200;
  late final AnimationController _secondaryAnimation;
  late Set<T> _selectedValues;
  bool _reduceMotion = false;
  int _reducedMotionGeneration = 0;

  @override
  void initState() {
    super.initState();
    _secondaryAnimation = AnimationController.unbounded(vsync: this);
    _syncSelection();
    widget.controller?.addListener(_handleControllerChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion == _reduceMotion) {
      return;
    }
    _reduceMotion = reduceMotion;
    if (!_reduceMotion) {
      return;
    }

    // Inherited preferences may change while either expansion spring is
    // active. Stop it now, then publish the logical endpoint after this build
    // scope so detached Overlay listeners are never dirtied during layout.
    _secondaryAnimation.stop();
    final generation = ++_reducedMotionGeneration;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          !_reduceMotion ||
          generation != _reducedMotionGeneration) {
        return;
      }
      if (_expandedPosition != null) {
        _secondaryAnimation.value = 1;
        _secondaryOverlay?.markNeedsBuild();
      } else {
        _finishReducedSecondaryCollapse();
      }
    });
  }

  @override
  void didUpdateWidget(covariant MiuixGroupedCascadingListPopup<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.groups != widget.groups) {
      _syncSelection();
      // Keep keys for stable positions so the frozen row anchor survives an
      // immutable data rebuild. Remove only coordinates that no longer point
      // to a submenu in the new hierarchy.
      _submenuRowKeys.removeWhere((position, _) {
        final entry = _entryAt(position);
        return entry == null || entry.children.isEmpty;
      });
      _discardInvalidTrackedPositions();
      _scheduleSecondaryOverlayRebuild();
    }
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChange);
      widget.controller?.addListener(_handleControllerChange);
      widget.controller?._setSecondaryExpanded(_expanded != null);
    }
  }

  @override
  void dispose() {
    _reducedMotionGeneration++;
    widget.controller?.removeListener(_handleControllerChange);
    _secondaryOverlay?.remove();
    _secondaryOverlay = null;
    _secondaryAnimation.dispose();
    super.dispose();
  }

  void _handleControllerChange() {
    if (widget.controller?._secondaryExpanded == false &&
        _expandedPosition != null &&
        mounted) {
      unawaited(_collapseSecondary(notifyController: false));
    }
  }

  /// Resolves a source object to its authored position by strict identity.
  ///
  /// Identity is used only at the input edge. Persistent state stores the
  /// returned position and resolves the latest entry object on every rebuild.
  _MiuixCascadingItemPosition? _positionOf(MiuixDropdownEntry<T> entry) {
    for (var groupIndex = 0; groupIndex < widget.groups.length; groupIndex++) {
      final entries = widget.groups[groupIndex].entries;
      for (var itemIndex = 0; itemIndex < entries.length; itemIndex++) {
        if (identical(entries[itemIndex], entry)) {
          return _MiuixCascadingItemPosition(groupIndex, itemIndex);
        }
      }
    }
    return null;
  }

  /// Returns the newest immutable entry at [position], if it still exists.
  MiuixDropdownEntry<T>? _entryAt(_MiuixCascadingItemPosition? position) {
    if (position == null ||
        position.groupIndex < 0 ||
        position.groupIndex >= widget.groups.length) {
      return null;
    }
    final entries = widget.groups[position.groupIndex].entries;
    if (position.itemIndex < 0 || position.itemIndex >= entries.length) {
      return null;
    }
    return entries[position.itemIndex];
  }

  /// Current expanded entry resolved from the latest widget data.
  MiuixDropdownEntry<T>? get _expanded {
    final entry = _entryAt(_expandedPosition);
    return entry == null || entry.children.isEmpty ? null : entry;
  }

  /// Current exit-retained entry resolved from the latest widget data.
  MiuixDropdownEntry<T>? get _displayed {
    final entry = _entryAt(_displayedPosition);
    return entry == null || entry.children.isEmpty ? null : entry;
  }

  /// Drops depth state when a caller changes the visible hierarchy itself.
  ///
  /// Current MIUIX assumes stable structure while open, but it still clears an
  /// invalid coordinate safely rather than displaying an unrelated row.
  ///
  /// Structural-replacement invariants:
  ///
  /// * Positions are invalidated before the primary subtree rebuilds.
  /// * An item newly occupying the same index is never treated as expanded.
  /// * The detached overlay is retained only until the current frame ends.
  /// * Overlay removal never happens from inside `didUpdateWidget`.
  /// * Controller listeners are not notified during the parent's build phase.
  /// * Animation listeners are not driven during the parent's build phase.
  /// * A captured stale entry is removed even when this State is disposed.
  /// * A later replacement overlay is never removed by the stale callback.
  /// * A later user expansion is never reset by the stale callback.
  /// * The frozen anchor is discarded with its displayed position.
  /// * The current controller, rather than a detached old controller, is used.
  /// * Collapse progress resets only after the stale plane is detached.
  /// * Stable positions continue through the ordinary overlay-rebuild path.
  /// * Stable positions continue to resolve the newest immutable data objects.
  /// * Empty children invalidate a former parent just like row removal does.
  /// * Empty groups remain part of positional indexing, as in `_entryAt`.
  /// * Selection synchronization remains independent of depth cleanup.
  /// * The primary popup stays mounted throughout the secondary cleanup.
  /// * The owning popup route remains responsible for depth-zero dismissal.
  /// * A Back request after cleanup correctly reports that depth one is absent.
  /// * No unrelated row can inherit the discarded secondary selection state.
  /// * Post-frame cleanup is idempotent if the overlay was already detached.
  /// * Disposal remains responsible for whichever current overlay still exists.
  void _discardInvalidTrackedPositions() {
    final expandedWasInvalid = _expandedPosition != null && _expanded == null;
    final displayedWasInvalid =
        _displayedPosition != null && _displayed == null;
    if (!expandedWasInvalid && !displayedWasInvalid) {
      return;
    }

    // Clear positional state synchronously so the primary tree cannot render
    // the newly occupying row as selected during this rebuild. Overlay and
    // controller mutations are deliberately deferred: didUpdateWidget runs in
    // the build phase, where removing an OverlayEntry or notifying listeners
    // can otherwise request a second build before the first one has finished.
    if (expandedWasInvalid) {
      _expandedPosition = null;
    }
    OverlayEntry? staleOverlay;
    if (displayedWasInvalid) {
      _displayedPosition = null;
      staleOverlay = _secondaryOverlay;
      _secondaryOverlay = null;
      _secondaryAnchor = null;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // The stale entry is detached even if this State was disposed before the
      // callback; leaving it mounted would retain the complete popup subtree.
      if (staleOverlay?.mounted ?? false) {
        staleOverlay!.remove();
      }
      if (!mounted || _expandedPosition != null) {
        return;
      }
      if (expandedWasInvalid) {
        widget.controller?._setSecondaryExpanded(false);
      }
      if (displayedWasInvalid && _secondaryOverlay == null) {
        _secondaryAnimation.value = 0;
        widget.controller?._finishSecondaryCollapse();
      }
    });
  }

  /// Refreshes the detached secondary plane after the parent build completes.
  ///
  /// [didUpdateWidget] runs inside the primary tree's build scope. The root
  /// Overlay is not its descendant in that scope, so marking its entry dirty
  /// synchronously would violate Flutter's parent-before-child build rule.
  void _scheduleSecondaryOverlayRebuild() {
    final overlay = _secondaryOverlay;
    if (overlay == null) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !identical(overlay, _secondaryOverlay)) {
        return;
      }
      overlay.markNeedsBuild();
    });
  }

  void _expandSecondary(MiuixDropdownEntry<T> entry) {
    final position = _positionOf(entry);
    if (position == null) {
      return;
    }
    final rowBox = _submenuRowKeys[position]?.currentContext
        ?.findRenderObject();
    final primaryBox = _primaryGeometryKey.currentContext?.findRenderObject();
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    final overlayBox = overlay?.context.findRenderObject();
    if (rowBox is! RenderBox ||
        primaryBox is! RenderBox ||
        overlay == null ||
        overlayBox is! RenderBox ||
        !rowBox.hasSize ||
        !primaryBox.hasSize) {
      return;
    }

    // Freeze the source row before the primary surface begins its 0.95 scale.
    // CascadingListPopupLayout uses the same unscaled window-space rectangle,
    // preventing the secondary panel from drifting during expansion.
    final globalOrigin = rowBox.localToGlobal(Offset.zero);
    final overlayOrigin = overlayBox.globalToLocal(globalOrigin);
    _secondaryAnchor = overlayOrigin & rowBox.size;
    _primaryWidth = primaryBox.size.width;
    _displayedPosition = position;
    setState(() => _expandedPosition = position);
    widget.controller?._setSecondaryExpanded(true);
    _secondaryOverlay ??= OverlayEntry(
      builder: (overlayContext) {
        final secondary = _buildSecondaryOverlay(overlayContext);
        return InheritedTheme.capture(
          from: context,
          to: overlay.context,
        ).wrap(secondary);
      },
    );
    if (!_secondaryOverlay!.mounted) {
      overlay.insert(_secondaryOverlay!);
    } else {
      _secondaryOverlay!.markNeedsBuild();
    }
    _secondaryAnimation.value = 0;
    if (_reduceMotion) {
      _secondaryAnimation.value = 1;
    } else {
      unawaited(_animateSecondaryTo(1, expanding: true));
    }
  }

  TickerFuture _animateSecondaryTo(double target, {required bool expanding}) {
    return _secondaryAnimation.animateWith(
      SpringSimulation(
        debugMiuixCascadingSpring(expanding: expanding),
        _secondaryAnimation.value,
        target,
        _secondaryAnimation.velocity,
      ),
    );
  }

  Future<void> _collapseSecondary({bool notifyController = true}) async {
    if (_expandedPosition == null) {
      return;
    }
    setState(() => _expandedPosition = null);
    if (notifyController) {
      widget.controller?._setSecondaryExpanded(false);
    }
    if (_reduceMotion) {
      _reducedMotionGeneration++;
      _secondaryAnimation
        ..stop()
        ..value = 0;
      _finishReducedSecondaryCollapse();
      return;
    }
    try {
      await _animateSecondaryTo(0, expanding: false).orCancel;
    } on TickerCanceled {
      return;
    }
    if (!mounted || _expandedPosition != null) {
      return;
    }
    _secondaryOverlay?.remove();
    _secondaryOverlay = null;
    _displayedPosition = null;
    widget.controller?._finishSecondaryCollapse();
  }

  /// Removes an exit-retained secondary plane without autonomous movement.
  void _finishReducedSecondaryCollapse() {
    if (_expandedPosition != null) {
      return;
    }
    _secondaryOverlay?.remove();
    _secondaryOverlay = null;
    _displayedPosition = null;
    _secondaryAnchor = null;
    widget.controller?._finishSecondaryCollapse();
  }

  void _syncSelection() {
    _selectedValues = {
      for (final group in widget.groups)
        for (final entry in group.entries) ...[
          if (entry.selected) entry.value,
          for (final child in entry.children)
            if (child.selected) child.value,
        ],
    };
  }

  void _selectLeaf(
    MiuixDropdownEntry<T> entry,
    Iterable<MiuixDropdownEntry<T>> siblings,
  ) {
    setState(() {
      _selectedValues.removeAll(siblings.map((item) => item.value));
      _selectedValues.add(entry.value);
    });
    _secondaryOverlay?.markNeedsBuild();
    widget.onSelected(entry.value);
  }

  Widget _buildSecondaryOverlay(BuildContext context) {
    final parent = _displayed;
    final anchor = _secondaryAnchor;
    if (parent == null || anchor == null) {
      return const SizedBox.shrink();
    }
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _collapseSecondary,
          ),
        ),
        CustomSingleChildLayout(
          delegate: _MiuixCascadingSecondaryLayoutDelegate(
            anchor: anchor,
            minWidth: _primaryWidth,
          ),
          child: AnimatedBuilder(
            animation: widget.controller == null
                ? _secondaryAnimation
                : Listenable.merge([
                    _secondaryAnimation,
                    widget.controller!._backExpandProgress,
                  ]),
            builder: (context, _) {
              final progress = _secondaryAnimation.value.clamp(0.0, 1.0);
              return ClipPath(
                key: const ValueKey('miuix-cascading-secondary-clip'),
                clipper: _MiuixCascadingMorphClipper(
                  progress: progress,
                  anchorHeight: anchor.height,
                  anchorIsLast: _isLastPrimaryEntry(parent),
                ),
                child: MiuixSurface(
                  padding: EdgeInsets.zero,
                  radius: MiuixListPopupDefaults.cornerRadius,
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  glass: true,
                  child: _secondary(context, parent, progress),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  double get _clampedExpansion =>
      (_secondaryAnimation.value *
              (1 - (widget.controller?._backExpandProgress.progress ?? 0)))
          .clamp(0.0, 1.0);

  bool _isLastPrimaryEntry(MiuixDropdownEntry<T> entry) {
    final nonEmpty = widget.groups.where((group) => group.entries.isNotEmpty);
    final lastGroup = nonEmpty.isEmpty ? null : nonEmpty.last;
    return lastGroup != null && identical(lastGroup.entries.last, entry);
  }

  bool _isFirstPrimaryEntry(MiuixDropdownEntry<T> entry) {
    final nonEmpty = widget.groups.where((group) => group.entries.isNotEmpty);
    final firstGroup = nonEmpty.isEmpty ? null : nonEmpty.first;
    return firstGroup != null && identical(firstGroup.entries.first, entry);
  }

  // MorphHeaderRow does not replace the trigger with a freshly padded row.
  // It preserves the frozen trigger's text origin at progress zero, then moves
  // that content into the secondary popup's normal first-row inset.
  //
  // Source padding contract:
  // * A middle primary row contributes 12dp above and below its content.
  // * The first primary row already contributes the target 20dp top inset.
  // * The last primary row contributes 20dp below because it owns the corner.
  // * A secondary first row finishes with 20dp above and 12dp below.
  // * Only the differing insets alter the animated header's outer height.
  // * Text line metrics remain unchanged throughout the morph.
  // * Summary rows retain the same two-line intrinsic content measurement.
  // * The translation cancels the final 20dp inset at the starting frame.
  // * That translation reaches zero with the shared Folme spring sample.
  // * The trailing spacer keeps later child rows at their settled positions.
  // * Clipping hides the reserved portion until the header has grown into it.
  // * This avoids reflowing submenu leaves while the header is still moving.
  // * The fallback is used only before the frozen render box can be measured.
  ({double height, double finalHeight, double translationY})
  _morphHeaderGeometry(MiuixDropdownEntry<T> parent, double progress) {
    final metrics = debugMiuixDropdownMetrics(isFirst: true, isLast: false);
    final anchorHeight = _secondaryAnchor?.height ?? 0;
    final anchorTop = _isFirstPrimaryEntry(parent) ? 20.0 : 12.0;
    final anchorBottom = _isLastPrimaryEntry(parent) ? 20.0 : 12.0;
    final fallbackContentHeight = parent.summary == null
        ? metrics.textLineHeight
        : metrics.summaryTitleLineHeight + metrics.summaryLineHeight;
    final resolvedAnchorHeight = anchorHeight > 0
        ? anchorHeight
        : fallbackContentHeight + anchorTop + anchorBottom;
    final finalHeight =
        resolvedAnchorHeight + (20 - anchorTop) + (12 - anchorBottom);
    return (
      height:
          resolvedAnchorHeight +
          (finalHeight - resolvedAnchorHeight) * progress,
      finalHeight: finalHeight,
      translationY: (anchorTop - 20) * (1 - progress),
    );
  }

  Widget _animatedPrimary(BuildContext context) {
    final progress = _clampedExpansion;
    final expanded = _expanded;
    final dimColor = MiuixSemanticColors.of(context)['windowDimming'];
    return Transform.scale(
      key: const ValueKey('miuix-cascading-primary-transform'),
      scale: 1 - .05 * progress,
      alignment: Directionality.of(context) == TextDirection.ltr
          ? Alignment.topRight
          : Alignment.topLeft,
      child: SizedBox(
        key: _primaryGeometryKey,
        child: DecoratedBox(
          // CascadingMorphContent paints the elevation outside the content
          // clip, so the G2 surface must remain a child rather than clipping
          // this decoration. The shadow itself follows the source constants:
          // 18% black, a 24dp blur radius, and a 6dp downward displacement.
          // Keeping a plain 16dp outer outline also prevents the G2 path from
          // producing rectangular shadow shoulders at its clipped corners.
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              MiuixListPopupDefaults.cornerRadius,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x2E000000),
                blurRadius: 24,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: MiuixSurface(
            padding: EdgeInsets.zero,
            radius: MiuixListPopupDefaults.cornerRadius,
            color: Theme.of(context).colorScheme.surfaceContainer,
            glass: true,
            child: Stack(
              children: [
                _primary(context, progress),
                if (expanded != null)
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _collapseSecondary,
                      child: ColoredBox(
                        color: dimColor.withValues(
                          alpha: dimColor.a * .5 * progress,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: MiuixHorizontalDivider(indent: 0, endIndent: 0, thickness: 1.5),
    );
  }

  Widget _leafRow(
    BuildContext context,
    MiuixDropdownEntry<T> entry,
    Iterable<MiuixDropdownEntry<T>> siblings, {
    required bool isFirst,
    required bool isLast,
  }) {
    final selected = _selectedValues.contains(entry.value);
    return _MiuixMenuRow(
      enabled: entry.enabled,
      icon: entry.icon,
      label: entry.label,
      summary: entry.summary,
      isFirst: isFirst,
      isLast: isLast,
      selected: selected,
      trailing: _MiuixDropdownCheck(
        color: selected
            ? Theme.of(context).colorScheme.primary
            : Colors.transparent,
      ),
      onTap: entry.enabled ? () => _selectLeaf(entry, siblings) : null,
    );
  }

  Widget _primary(BuildContext context, double progress) {
    final groups = widget.groups
        .where((group) => group.entries.isNotEmpty)
        .toList(growable: false);
    // CascadingMorphContent.kt uses ListPopupColumn for the primary plane.
    // A plain Column lets the Flexible label row consume the complete 288dp
    // constraint, so short menus incorrectly render at their maximum width.
    return ConstrainedBox(
      key: const ValueKey('miuix-cascading-primary'),
      constraints: BoxConstraints(
        minWidth: _safeListPopupMinWidth(widget.minWidth),
      ),
      child: MiuixListPopupColumn(
        children: [
          for (
            var groupIndex = 0;
            groupIndex < groups.length;
            groupIndex++
          ) ...[
            if (groupIndex > 0) _divider(),
            for (
              var itemIndex = 0;
              itemIndex < groups[groupIndex].entries.length;
              itemIndex++
            )
              Builder(
                builder: (context) {
                  final entry = groups[groupIndex].entries[itemIndex];
                  final isFirst = groupIndex == 0 && itemIndex == 0;
                  final isLast =
                      groupIndex == groups.length - 1 &&
                      itemIndex == groups[groupIndex].entries.length - 1;
                  if (entry.children.isEmpty) {
                    return _leafRow(
                      context,
                      entry,
                      groups[groupIndex].entries,
                      isFirst: isFirst,
                      isLast: isLast,
                    );
                  }
                  final position = _positionOf(entry)!;
                  final rowKey = _submenuRowKeys.putIfAbsent(
                    position,
                    GlobalKey.new,
                  );
                  return KeyedSubtree(
                    key: rowKey,
                    child: _MiuixMenuRow(
                      enabled: entry.enabled,
                      icon: entry.icon,
                      label: entry.label,
                      summary: entry.summary,
                      isFirst: isFirst,
                      isLast: isLast,
                      trailing: Transform.rotate(
                        angle: position == _displayedPosition
                            ? -math.pi / 2 * progress
                            : 0,
                        child: _MiuixCascadingChevron(
                          color: MiuixSemanticColors.of(
                            context,
                          )['onSurfaceVariantSummary'],
                        ),
                      ),
                      onTap: entry.enabled
                          ? () => _expandSecondary(entry)
                          : null,
                    ),
                  );
                },
              ),
          ],
        ],
      ),
    );
  }

  Widget _secondary(
    BuildContext context,
    MiuixDropdownEntry<T> parent,
    double progress,
  ) {
    final header = _morphHeaderGeometry(parent, progress);
    // The secondary probe and visible plane also use ListPopupColumn upstream;
    // measure them independently so a short submenu can keep its own width.
    return ConstrainedBox(
      key: ValueKey('miuix-cascading-secondary-${parent.label}'),
      constraints: BoxConstraints(minWidth: _primaryWidth),
      child: MiuixListPopupColumn(
        children: [
          SizedBox(
            height: header.height,
            child: ClipRect(
              child: OverflowBox(
                alignment: Alignment.topCenter,
                minHeight: header.finalHeight,
                maxHeight: header.finalHeight,
                child: Transform.translate(
                  offset: Offset(0, header.translationY),
                  child: _MiuixMenuRow(
                    label: parent.label,
                    summary: parent.summary,
                    icon: parent.icon,
                    isFirst: true,
                    trailing: Transform.rotate(
                      angle: -math.pi / 2 * progress,
                      child: _MiuixCascadingChevron(
                        color: MiuixSemanticColors.of(
                          context,
                        )['onSurfaceVariantSummary'],
                      ),
                    ),
                    onTap: _collapseSecondary,
                  ),
                ),
              ),
            ),
          ),
          _divider(),
          for (var index = 0; index < parent.children.length; index++)
            _leafRow(
              context,
              parent.children[index],
              parent.children,
              isFirst: false,
              isLast: index == parent.children.length - 1,
            ),
          if (header.finalHeight > header.height)
            SizedBox(height: header.finalHeight - header.height),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // The overlay host owns the route-local Back registration. A second
    // PopScope here would receive the same rejected-pop broadcast and collapse
    // the submenu before the host's dismissal guard runs, causing one physical
    // Back event to dismiss both levels.
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: _safeListPopupMinWidth(widget.minWidth),
        maxWidth: 288,
      ),
      child: AnimatedBuilder(
        animation: widget.controller == null
            ? _secondaryAnimation
            : Listenable.merge([
                _secondaryAnimation,
                widget.controller!._backExpandProgress,
              ]),
        builder: (context, _) => _animatedPrimary(context),
      ),
    );
  }
}

/// Places a secondary cascading surface at its frozen primary-row anchor.
///
/// This mirrors `computeSecondaryRect`: use leading/top alignment when the
/// measured panel fits, fall back to the far window edge when it does not, and
/// keep the secondary at least as wide as the primary popup.
class _MiuixCascadingSecondaryLayoutDelegate extends SingleChildLayoutDelegate {
  const _MiuixCascadingSecondaryLayoutDelegate({
    required this.anchor,
    required this.minWidth,
  });

  final Rect anchor;
  final double minWidth;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final upper = math.min(288.0, constraints.maxWidth);
    final lower = math.min(minWidth, upper);
    return BoxConstraints(
      minWidth: lower,
      maxWidth: upper,
      maxHeight: constraints.maxHeight,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final left = anchor.left + childSize.width <= size.width
        ? anchor.left
        : anchor.right - childSize.width >= 0
        ? size.width - childSize.width
        : 0.0;
    final top = anchor.top + childSize.height <= size.height
        ? anchor.top
        : anchor.bottom - childSize.height >= 0
        ? anchor.bottom - childSize.height
        : math.max(0.0, size.height - childSize.height);
    return Offset(left, top);
  }

  @override
  bool shouldRelayout(
    covariant _MiuixCascadingSecondaryLayoutDelegate oldDelegate,
  ) => oldDelegate.anchor != anchor || oldDelegate.minWidth != minWidth;
}

/// Interpolates the secondary paint clip from its source row to its panel.
///
/// Clip geometry contract:
/// * The child is measured once at its final secondary-panel dimensions.
/// * Progress zero exposes only the frozen primary trigger-row height.
/// * Progress one exposes the complete measured secondary height.
/// * Intermediate bottoms use direct geometric interpolation of those heights.
/// * The left and right edges remain fixed at the measured secondary edges.
/// * A middle trigger begins with square top and bottom corners.
/// * Its four radii grow from zero to the source 16dp panel radius.
/// * A final-row trigger already shares the primary popup's rounded bottom.
/// * Its bottom radii therefore remain 16dp through the complete expansion.
/// * Its top radii still grow from zero because the row begins internally flat.
/// * The separately positioned panel starts at the frozen trigger-row origin.
/// * Clipping never changes the child's layout or accessibility measurements.
/// * Content below the animated bottom cannot paint or receive pointer input.
/// * The header is the first child and remains aligned with the source row.
/// * Header arrow rotation samples the same unclamped spring after clamping.
/// * Child rows exist from frame zero but remain outside the active clip.
/// * The source surface color is painted inside this single dynamic path.
/// * MiuixSurface supplies final G2/rounded clipping after the morph settles.
/// * The outer ClipPath handles the temporary nonuniform corner radii.
/// * Anti-aliasing remains enabled so rounded reveal edges do not staircase.
/// * Collapse reuses the same path in reverse without reconstructing content.
/// * A path is rebuilt only when progress, anchor height, or last-row status changes.
/// * Selection-state repaint does not alter the morph geometry.
/// * Translation cannot alter anchor height because the full row is measured.
/// * Fractional logical heights remain fractional until the raster boundary.
/// * Android physical-pixel comparison rounds only at evidence measurement.
/// * A low anchor may reposition the final panel above before this clip runs.
/// * In that case the clip still grows in the panel's own local coordinates.
/// * RTL positioning changes panel origin, not the local clip mathematics.
/// * Empty child lists never create this clip because they are primary leaves.
/// * Deeper grandchildren remain ignored according to the source depth limit.
/// * A zero-size panel produces an empty path rather than invented dimensions.
/// * The 16dp token comes directly from CascadingPopupCornerRadius.
/// * Replacing this with a uniform scale would move text and violate the morph.
/// * Replacing it with opacity would expose child rows before the source does.
/// * Golden coverage should include square start, intermediate, and settled radii.
/// * Runtime coverage should separately prove the final panel/window placement.
class _MiuixCascadingMorphClipper extends CustomClipper<Path> {
  const _MiuixCascadingMorphClipper({
    required this.progress,
    required this.anchorHeight,
    required this.anchorIsLast,
  });

  final double progress;
  final double anchorHeight;
  final bool anchorIsLast;

  @override
  Path getClip(Size size) {
    final bottom = anchorHeight + (size.height - anchorHeight) * progress;
    final topRadius = Radius.circular(16 * progress);
    final bottomRadius = Radius.circular(anchorIsLast ? 16 : 16 * progress);
    return Path()..addRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTRB(0, 0, size.width, bottom),
        topLeft: topRadius,
        topRight: topRadius,
        bottomLeft: bottomRadius,
        bottomRight: bottomRadius,
      ),
    );
  }

  @override
  bool shouldReclip(covariant _MiuixCascadingMorphClipper oldClipper) =>
      oldClipper.progress != progress ||
      oldClipper.anchorHeight != anchorHeight ||
      oldClipper.anchorIsLast != anchorIsLast;
}

class _MiuixCascadingChevron extends StatelessWidget {
  const _MiuixCascadingChevron({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(10, 16),
      painter: _MiuixCascadingChevronPainter(color),
    );
  }
}

class _MiuixCascadingChevronPainter extends CustomPainter {
  const _MiuixCascadingChevronPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(2.5, 2.5)
      ..lineTo(7.5, 8)
      ..lineTo(2.5, 13.5);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _MiuixCascadingChevronPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Exact 56-unit MIUIX basic Check path, painted into DropdownImpl's 20dp box.
class _MiuixDropdownCheck extends StatelessWidget {
  const _MiuixDropdownCheck({required this.color, this.size = 20});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => CustomPaint(
    key: ValueKey(
      color.a == 0
          ? 'miuix-dropdown-check-empty'
          : 'miuix-dropdown-check-selected',
    ),
    size: Size.square(size),
    painter: _MiuixDropdownCheckPainter(color),
  );
}

class _MiuixDropdownCheckPainter extends CustomPainter {
  const _MiuixDropdownCheckPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(46.8171, 18.1514)
      ..cubicTo(48.0496, 16.6624, 47.8417, 14.4561, 46.3527, 13.2235)
      ..cubicTo(44.8636, 11.991, 42.6573, 12.1989, 41.4247, 13.6879)
      ..lineTo(22.9535, 36.0031)
      ..lineTo(13.4007, 26.4502)
      ..cubicTo(12.0338, 25.0833, 9.8177, 25.0833, 8.4509, 26.4502)
      ..cubicTo(7.0841, 27.817, 7.0841, 30.0331, 8.4509, 31.3999)
      ..lineTo(20.7077, 43.6567)
      ..cubicTo(21.7243, 44.6733, 23.2108, 44.9338, 24.4682, 44.4381)
      ..cubicTo(25.0159, 44.2302, 25.5189, 43.8818, 25.9192, 43.3982)
      ..lineTo(46.8171, 18.1514)
      ..close();
    canvas.save();
    canvas.scale(size.width / 56, size.height / 56);
    canvas.drawPath(path, Paint()..color = color);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MiuixDropdownCheckPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Overlay-named list popup adapter.
class MiuixOverlayListPopup<T> extends MiuixListPopup<T> {
  /// Creates an overlay list popup.
  const MiuixOverlayListPopup({
    super.key,
    required super.entries,
    required super.onSelected,
  });

  /// Shows an anchored list inside the nearest Scaffold popup host.
  static Future<void> show<T>({
    required BuildContext context,
    List<MiuixDropdownEntry<T>> entries = const [],
    List<MiuixDropdownGroup<T>> groups = const [],
    required ValueChanged<T> onSelected,
    LayerLink? link,
    MiuixPopupAlignment alignment = MiuixPopupAlignment.bottomStart,
    bool renderInRootScaffold = true,
    bool closeOnSelection = true,
    bool allowMultipleSelection = false,
    double? maxHeight,
    MiuixDropdownColors? colors,
    bool sourceRows = false,
    VoidCallback? onDismissRequest,
    VoidCallback? onDismissFinished,
  }) {
    return _showMiuixDropdownMenu<T>(
      context: context,
      entries: entries,
      groups: groups,
      onSelected: onSelected,
      presentation: MiuixPopupPresentation.overlay,
      link: link,
      alignment: alignment,
      renderInRootScaffold: renderInRootScaffold,
      closeOnSelection: closeOnSelection,
      allowMultipleSelection: allowMultipleSelection,
      popupBuilder: (select) => _MiuixSourceDropdownPopupPlane<T>(
        entries: entries,
        groups: groups,
        onSelected: select,
        maxHeight: maxHeight,
        colors: colors,
        sourceRows: sourceRows,
        allowMultipleSelection: allowMultipleSelection,
      ),
      onDismissRequest: onDismissRequest,
      onDismissFinished: onDismissFinished,
    );
  }
}

/// Window-named list popup adapter.
class MiuixWindowListPopup<T> extends MiuixListPopup<T> {
  /// Creates a window list popup.
  const MiuixWindowListPopup({
    super.key,
    required super.entries,
    required super.onSelected,
  });

  /// Shows an anchored list in a root Navigator route.
  static Future<void> show<T>({
    required BuildContext context,
    List<MiuixDropdownEntry<T>> entries = const [],
    List<MiuixDropdownGroup<T>> groups = const [],
    required ValueChanged<T> onSelected,
    LayerLink? link,
    MiuixPopupAlignment alignment = MiuixPopupAlignment.bottomStart,
    bool closeOnSelection = true,
    bool allowMultipleSelection = false,
    double? maxHeight,
    MiuixDropdownColors? colors,
    bool sourceRows = false,
    VoidCallback? onDismissRequest,
    VoidCallback? onDismissFinished,
  }) {
    return _showMiuixDropdownMenu<T>(
      context: context,
      entries: entries,
      groups: groups,
      onSelected: onSelected,
      presentation: MiuixPopupPresentation.window,
      link: link,
      alignment: alignment,
      closeOnSelection: closeOnSelection,
      allowMultipleSelection: allowMultipleSelection,
      popupBuilder: (select) => _MiuixSourceDropdownPopupPlane<T>(
        entries: entries,
        groups: groups,
        onSelected: select,
        maxHeight: maxHeight,
        colors: colors,
        sourceRows: sourceRows,
        allowMultipleSelection: allowMultipleSelection,
      ),
      onDismissRequest: onDismissRequest,
      onDismissFinished: onDismissFinished,
    );
  }
}

class _MiuixSourceDropdownPopupPlane<T> extends StatelessWidget {
  const _MiuixSourceDropdownPopupPlane({
    required this.entries,
    required this.groups,
    required this.onSelected,
    required this.maxHeight,
    required this.colors,
    required this.sourceRows,
    required this.allowMultipleSelection,
  });

  final List<MiuixDropdownEntry<T>> entries;
  final List<MiuixDropdownGroup<T>> groups;
  final ValueChanged<T> onSelected;
  final double? maxHeight;
  final MiuixDropdownColors? colors;
  final bool sourceRows;
  final bool allowMultipleSelection;

  @override
  Widget build(BuildContext context) {
    final safeMaximum =
        maxHeight != null && maxHeight!.isFinite && maxHeight! > 0
        ? maxHeight!
        : double.infinity;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: safeMaximum),
      child: MiuixListPopup<T>(
        entries: entries,
        groups: groups,
        onSelected: onSelected,
        allowMultipleSelection: allowMultipleSelection,
        sourceRows: sourceRows,
        colors: colors,
      ),
    );
  }
}

/// Cascading menu item for two-level menus.
@immutable
class MiuixCascadingMenuItem<T> {
  /// Creates a cascading menu item.
  const MiuixCascadingMenuItem({
    required this.label,
    required this.children,
    this.icon,
  });

  /// Parent label.
  final String label;

  /// Optional icon.
  final Widget? icon;

  /// Child entries.
  final List<MiuixDropdownEntry<T>> children;
}

/// Simple two-level cascading menu.
class MiuixCascadingMenu<T> extends StatelessWidget {
  /// Creates a cascading menu.
  const MiuixCascadingMenu({
    super.key,
    required this.items,
    required this.onSelected,
  });

  /// Parent menu items.
  final List<MiuixCascadingMenuItem<T>> items;

  /// Selection callback.
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return MiuixSurface(
      padding: EdgeInsets.zero,
      radius: MiuixTheme.of(context).radius.md,
      glass: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (items.isEmpty)
            const _MiuixMenuRow(label: 'No actions', enabled: false)
          else
            for (final item in items)
              _MiuixCascadingSection<T>(item: item, onSelected: onSelected),
        ],
      ),
    );
  }
}

class _MiuixCascadingSection<T> extends StatefulWidget {
  const _MiuixCascadingSection({required this.item, required this.onSelected});

  final MiuixCascadingMenuItem<T> item;
  final ValueChanged<T> onSelected;

  @override
  State<_MiuixCascadingSection<T>> createState() =>
      _MiuixCascadingSectionState<T>();
}

class _MiuixCascadingSectionState<T> extends State<_MiuixCascadingSection<T>> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    const motion = Duration(milliseconds: 180);
    final childRows = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final child in widget.item.children)
          _MiuixMenuRow(
            enabled: child.enabled,
            icon: child.icon,
            label: child.label,
            indent: 32,
            onTap: child.enabled ? () => widget.onSelected(child.value) : null,
          ),
      ],
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MiuixMenuRow(
          icon: widget.item.icon,
          label: widget.item.label,
          onTap: () => setState(() => _expanded = !_expanded),
          trailing: _MiuixVerticalDisclosureArrow(
            key: const ValueKey('miuix-cascading-menu-arrow'),
            expanded: _expanded,
            color: MiuixSemanticColors.of(context)['onSurfaceVariantSummary'],
            duration: reduceMotion ? Duration.zero : motion,
          ),
        ),
        if (reduceMotion)
          if (_expanded) childRows else const SizedBox.shrink()
        else
          AnimatedCrossFade(
            duration: motion,
            crossFadeState: _expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: childRows,
            secondChild: const SizedBox.shrink(),
          ),
      ],
    );
  }
}

/// Overlay-named cascading menu adapter.
class MiuixOverlayCascadingListPopup<T> extends MiuixCascadingMenu<T> {
  /// Creates an overlay cascading list popup.
  const MiuixOverlayCascadingListPopup({
    super.key,
    required super.items,
    required super.onSelected,
  });

  /// Shows cascading content inside the nearest Scaffold popup host.
  static Future<void> show<T>({
    required BuildContext context,
    required List<MiuixCascadingMenuItem<T>> items,
    required ValueChanged<T> onSelected,
    LayerLink? link,
    bool renderInRootScaffold = true,
  }) {
    final host = MiuixPopupHostScope.maybeOf(context);
    final target = renderInRootScaffold ? host?.root : host;
    late final MiuixCascadingMenu<T> popup;
    popup = MiuixCascadingMenu<T>(
      items: items,
      onSelected: (value) {
        target?.dismissTop();
        onSelected(value);
      },
    );
    return _showMiuixOverlayPopupSurface<void>(
      context: context,
      child: popup,
      maxWidth: 360,
      link: link,
      renderInRootScaffold: renderInRootScaffold,
    );
  }
}

/// Window-named cascading menu adapter.
class MiuixWindowCascadingListPopup<T> extends MiuixCascadingMenu<T> {
  /// Creates a window cascading list popup.
  const MiuixWindowCascadingListPopup({
    super.key,
    required super.items,
    required super.onSelected,
  });

  /// Shows cascading content in a root Navigator route.
  static Future<void> show<T>({
    required BuildContext context,
    required List<MiuixCascadingMenuItem<T>> items,
    required ValueChanged<T> onSelected,
    LayerLink? link,
  }) {
    final navigator = Navigator.maybeOf(context, rootNavigator: true);
    return _showMiuixWindowPopupSurface<void>(
      context: context,
      maxWidth: 360,
      link: link,
      child: MiuixCascadingMenu<T>(
        items: items,
        onSelected: (value) {
          if (navigator?.mounted == true && navigator!.canPop()) {
            navigator.pop();
          }
          onSelected(value);
        },
      ),
    );
  }
}

/// Icon-triggered cascading dropdown menu.
class MiuixIconCascadingDropdownMenu<T> extends StatefulWidget {
  /// Creates an icon cascading menu.
  const MiuixIconCascadingDropdownMenu({
    super.key,
    required this.icon,
    this.items = const [],
    this.groups = const [],
    required this.onSelected,
    this.tooltip,
    this.presentation = MiuixPopupPresentation.window,
    this.enabled = true,
    this.onExpandedChange,
    this.renderInRootScaffold = true,
    this.collapseOnSelection = true,
    this.minWidth = 200,
  });

  /// Trigger icon.
  final Widget icon;

  /// Optional trigger tooltip.
  final String? tooltip;

  /// Cascading menu items.
  final List<MiuixCascadingMenuItem<T>> items;

  /// Current grouped entries; rows with children become submenu triggers.
  final List<MiuixDropdownGroup<T>> groups;

  /// Selection callback.
  final ValueChanged<T> onSelected;

  /// Popup route family used by this trigger.
  final MiuixPopupPresentation presentation;

  /// Whether the icon trigger can open the menu.
  final bool enabled;

  /// Called when popup expansion starts or finishes.
  final ValueChanged<bool>? onExpandedChange;

  /// Whether Overlay presentation uses the outermost Scaffold host.
  final bool renderInRootScaffold;

  /// Whether selecting a leaf dismisses the popup.
  final bool collapseOnSelection;

  /// Current source minimum popup width.
  final double minWidth;

  @override
  State<MiuixIconCascadingDropdownMenu<T>> createState() =>
      _MiuixIconCascadingDropdownMenuState<T>();
}

class _MiuixIconCascadingDropdownMenuState<T>
    extends State<MiuixIconCascadingDropdownMenu<T>> {
  // Both anchors outlive ordinary parent rebuilds. A LayerLink created inside
  // build disconnects an active follower as soon as inherited state, locale,
  // theme, or an unrelated sibling causes this trigger to rebuild.
  final LayerLink _legacyLink = LayerLink();
  final MiuixCascadingPopupController _cascadingController =
      MiuixCascadingPopupController();
  bool _suppressRepeatedDismiss = false;
  bool _legacyExpanded = false;
  // Legacy cascading snapshot contract:
  //
  // - The opening item tree supplies the visible primary and secondary rows.
  // - The opening presentation supplies the route that must be dismissed.
  // - The opening root-host flag supplies the exact Overlay host to dismiss.
  // - The latest item tree alone authorizes a returned leaf value.
  // - The latest callback alone receives an authorized leaf value.
  // - Dismissal occurs even when authorization rejects a stale leaf.
  // - Disabled current children cannot be selected through an old route row.
  // - Unrelated rebuilds retain validity, anchoring, and interaction continuity.
  // - A changed item identity invalidates the outstanding snapshot result.
  // - Current grouped APIs use their separate live-content revision contract.
  int _legacyGeneration = 0;

  @override
  void didUpdateWidget(covariant MiuixIconCascadingDropdownMenu<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The legacy items surface is a route snapshot. Invalidate only changes
    // that alter which route and actions own its eventual result; unrelated
    // parent rebuilds keep the existing menu useful and preserve its anchor.
    if (oldWidget.items != widget.items ||
        oldWidget.enabled != widget.enabled ||
        oldWidget.presentation != widget.presentation ||
        oldWidget.renderInRootScaffold != widget.renderInRootScaffold) {
      _legacyGeneration++;
    }
  }

  bool _isCurrentLegacyValue(T value) => widget.items.any(
    (item) =>
        item.children.any((entry) => entry.enabled && entry.value == value),
  );

  bool _canDismissCascading() {
    if (_cascadingController.collapseSecondary()) {
      // Flutter may invoke both the route-local history callback and the
      // scoped route callback for one physical Back event. Keep the
      // just-collapsed primary popup alive through that frame.
      _suppressRepeatedDismiss = true;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) _suppressRepeatedDismiss = false;
      });
      return false;
    }
    return !_suppressRepeatedDismiss;
  }

  Future<void> _openLegacy(BuildContext context) async {
    if (_legacyExpanded || !widget.enabled || widget.items.isEmpty) return;
    final generation = ++_legacyGeneration;
    final navigator = Navigator.maybeOf(context, rootNavigator: true);
    final host = MiuixPopupHostScope.maybeOf(context);
    final openingPresentation = widget.presentation;
    final openingRootHost = widget.renderInRootScaffold;
    setState(() => _legacyExpanded = true);
    widget.onExpandedChange?.call(true);
    final popup = MiuixCascadingMenu<T>(
      items: widget.items,
      onSelected: (value) {
        // Dismiss the route that actually rendered the snapshot even if its
        // value has become stale. Publishing and dismissal are deliberately
        // separate: stale content must neither mutate the new owner nor leave
        // an apparently actionable but inert menu stranded on screen.
        if (openingPresentation == MiuixPopupPresentation.overlay) {
          (openingRootHost ? host?.root : host)?.dismissTop();
        } else if (navigator?.mounted == true && navigator!.canPop()) {
          navigator.pop();
        }
        if (!mounted ||
            generation != _legacyGeneration ||
            !_isCurrentLegacyValue(value)) {
          return;
        }
        widget.onSelected(value);
      },
    );
    try {
      if (widget.presentation == MiuixPopupPresentation.overlay) {
        await _showMiuixOverlayPopupSurface<void>(
          context: context,
          maxWidth: 360,
          link: _legacyLink,
          renderInRootScaffold: widget.renderInRootScaffold,
          child: popup,
        );
      } else {
        await _showMiuixWindowPopupSurface<void>(
          context: context,
          maxWidth: 360,
          link: _legacyLink,
          child: popup,
        );
      }
    } finally {
      // The Future can finish after the trigger route was removed. Avoid
      // dispatching callbacks into an already disposed owner in that case.
      if (mounted) {
        setState(() => _legacyExpanded = false);
        widget.onExpandedChange?.call(false);
      }
    }
  }

  @override
  void dispose() {
    _cascadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.groups.isNotEmpty) {
      Widget menu = MiuixDropdownMenuButton<T>(
        entries: const [],
        groups: widget.groups,
        onSelected: widget.onSelected,
        presentation: widget.presentation,
        enabled: widget.enabled,
        onExpandedChange: widget.onExpandedChange,
        renderInRootScaffold: widget.renderInRootScaffold,
        alignment: MiuixPopupAlignment.bottomEnd,
        collapseOnSelection: widget.collapseOnSelection,
        popupMinWidth: widget.minWidth,
        popupBuilder: (select) => MiuixGroupedCascadingListPopup<T>(
          groups: widget.groups,
          onSelected: select,
          minWidth: widget.minWidth,
          controller: _cascadingController,
        ),
        canDismiss: _canDismissCascading,
        cascadingController: _cascadingController,
        triggerBuilder: (context, onPressed, expanded) => MiuixIconButton(
          onPressed: onPressed == null
              ? null
              : () {
                  unawaited(MiuixHaptics.perform(MiuixHapticType.contextClick));
                  onPressed();
                },
          enabled: widget.enabled,
          holdDownState: expanded,
          icon: widget.icon,
        ),
      );
      final message = widget.tooltip;
      if (message != null && message.isNotEmpty) {
        menu = MiuixTooltip(message: message, child: menu);
      }
      return menu;
    }
    return CompositedTransformTarget(
      link: _legacyLink,
      child: MiuixPressable(
        onTap: widget.enabled && widget.items.isNotEmpty && !_legacyExpanded
            ? () => unawaited(_openLegacy(context))
            : null,
        feedbackType: MiuixPressFeedbackType.none,
        showIndication: widget.enabled && widget.items.isNotEmpty,
        child: AnimatedOpacity(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 160),
          opacity: widget.enabled ? 1 : .38,
          child: MiuixTooltip(
            message: widget.tooltip ?? '',
            child: IconTheme.merge(
              data: IconThemeData(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              child: widget.icon,
            ),
          ),
        ),
      ),
    );
  }
}

/// Overlay-named icon cascading dropdown menu.
class MiuixOverlayIconCascadingDropdownMenu<T>
    extends MiuixIconCascadingDropdownMenu<T> {
  /// Creates an overlay icon cascading dropdown menu.
  const MiuixOverlayIconCascadingDropdownMenu({
    super.key,
    required super.icon,
    super.items,
    super.groups,
    required super.onSelected,
    super.tooltip,
    super.enabled,
    super.onExpandedChange,
    super.renderInRootScaffold,
    super.collapseOnSelection,
    super.minWidth,
  }) : super(presentation: MiuixPopupPresentation.overlay);
}

/// Window-named icon cascading dropdown menu.
class MiuixWindowIconCascadingDropdownMenu<T>
    extends MiuixIconCascadingDropdownMenu<T> {
  /// Creates a window icon cascading dropdown menu.
  const MiuixWindowIconCascadingDropdownMenu({
    super.key,
    required super.icon,
    super.items,
    super.groups,
    required super.onSelected,
    super.tooltip,
    super.enabled,
    super.onExpandedChange,
    super.collapseOnSelection,
    super.minWidth,
  }) : super(presentation: MiuixPopupPresentation.window);
}
