import 'dart:collection';

import 'package:flutter/foundation.dart' show setEquals;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../effects/miuix_effects.dart';
import '../../platform/miuix_haptics.dart';
import '../../theme/miuix_semantic_colors.dart';
import '../../theme/miuix_theme.dart';
import '../../widgets/miuix_widgets.dart';
import '../miuix_extension_icons.dart';

/// Builds a typed data-table cell.
typedef MiuixDataCellBuilder<T> = Widget Function(BuildContext context, T item);

/// Describes one sortable column in a [MiuixDataTable].
@immutable
class MiuixDataColumn<T> {
  /// Creates a typed column.
  const MiuixDataColumn({
    required this.id,
    required this.label,
    required this.cellBuilder,
    this.comparator,
    this.width = 160,
    this.numeric = false,
    this.tooltip,
  });

  /// Stable sort identifier and visible header.
  final String id;
  final String label;

  /// Cell renderer and optional local comparator.
  final MiuixDataCellBuilder<T> cellBuilder;
  final Comparator<T>? comparator;

  /// Fixed logical width keeps columns aligned while horizontally scrolling.
  final double width;

  /// Whether header and cell content align toward the numeric edge.
  final bool numeric;
  final String? tooltip;
}

/// Hoisted sorting and selection state for [MiuixDataTable].
class MiuixDataTableController extends ChangeNotifier {
  /// Creates data-table state.
  MiuixDataTableController({
    String? sortColumnId,
    bool sortAscending = true,
    Iterable<Object> selectedKeys = const <Object>[],
  }) : _sortColumnId = sortColumnId,
       _sortAscending = sortAscending,
       _selectedKeys = Set<Object>.of(selectedKeys);

  String? _sortColumnId;
  bool _sortAscending;
  final Set<Object> _selectedKeys;

  /// Active column and direction.
  String? get sortColumnId => _sortColumnId;
  bool get sortAscending => _sortAscending;

  /// Read-only selected key set.
  Set<Object> get selectedKeys => UnmodifiableSetView<Object>(_selectedKeys);

  /// Changes sorting, reversing direction when the same header is selected.
  void sortBy(String columnId, {bool? ascending}) {
    final nextAscending =
        ascending ?? (_sortColumnId == columnId ? !_sortAscending : true);
    if (_sortColumnId == columnId && _sortAscending == nextAscending) return;
    _sortColumnId = columnId;
    _sortAscending = nextAscending;
    notifyListeners();
  }

  /// Selects or deselects one stable row key.
  void setSelected(Object key, bool selected) {
    final changed = selected
        ? _selectedKeys.add(key)
        : _selectedKeys.remove(key);
    if (changed) notifyListeners();
  }

  /// Replaces the complete selection set.
  void setSelection(Iterable<Object> keys) {
    final next = Set<Object>.of(keys);
    if (setEquals(next, _selectedKeys)) return;
    _selectedKeys
      ..clear()
      ..addAll(next);
    notifyListeners();
  }

  /// Clears sorting without modifying selection.
  void clearSort() {
    if (_sortColumnId == null) return;
    _sortColumnId = null;
    notifyListeners();
  }
}

/// Semantic colors for the MIUIX data-table surface.
@immutable
class MiuixDataTableColors {
  /// Creates a complete palette.
  const MiuixDataTableColors({
    required this.surface,
    required this.headerSurface,
    required this.selectedSurface,
    required this.hoverSurface,
    required this.foreground,
    required this.secondaryForeground,
    required this.divider,
    required this.primary,
  });

  final Color surface;
  final Color headerSurface;
  final Color selectedSurface;
  final Color hoverSurface;
  final Color foreground;
  final Color secondaryForeground;
  final Color divider;
  final Color primary;
}

/// Geometry and color defaults for structured tabular data.
abstract final class MiuixDataTableDefaults {
  // HyperOS 4 data-table implementation contract:
  // - The complete table is one bounded information surface.
  // - Header and rows remain aligned through one declared column model.
  // - The header stays fixed while the row viewport scrolls vertically.
  // - Horizontal overflow moves header and rows on the same controller.
  // - A glass header remains translucent instead of hiding sampled content.
  // - Outer clipping and pointer geometry share one continuous radius.
  // - Row hover, focus, and selection use collection-state animation tokens.
  // - Keyboard positioning uses the autonomous collection-scroll clock.
  // - Reduced motion settles both row state and pending keyboard scrolling.
  // - The scrollbar lane never overlays the last data row or selection cell.
  // - Selection identity follows stable row keys rather than visual indices.
  // - Sorting never mutates the application-owned source list.
  // - Source construction preserves the audited former opaque geometry.
  // - Empty tables retain the same bounded surface unless replaced explicitly.
  // - Semantic progress, sorting, selection, and activation remain separable.
  // Token values are project calibration points, not private Xiaomi metrics.

  static const double headerHeight = 52;
  static const double rowHeight = 52;
  static const double checkboxWidth = 52;
  static const double cornerRadius = 20;
  static const double minimumWidth = 520;
  static const double defaultHeight = 420;

  /// Dedicated footer lane for a horizontal thumb on narrow viewports.
  ///
  /// Material's interactive scrollbar painter is inset from the viewport
  /// edge. A smaller padding still places that thumb over the final data row
  /// on Android, so this lane deliberately keeps data and scrolling chrome
  /// visually separate.
  static const double horizontalScrollbarLane = 32;

  /// Resolves table colors from the current MIUIX theme.
  static MiuixDataTableColors colors(BuildContext context) {
    final semantic = MiuixSemanticColors.of(context);
    return MiuixDataTableColors(
      surface: semantic['surface'],
      headerSurface: semantic['surfaceContainer'],
      selectedSurface: semantic['primaryContainer'],
      hoverSurface: semantic['surfaceContainerHigh'],
      foreground: semantic['onSurface'],
      secondaryForeground: semantic['onSurfaceSecondary'],
      divider: semantic['dividerLine'],
      primary: semantic['primary'],
    );
  }
}

/// Sortable, selectable, keyboard-aware MIUIX data table.
///
/// The header remains fixed while rows scroll vertically. The complete table
/// scrolls horizontally when its declared columns exceed the available width.
/// Selection and sorting can be hoisted through [MiuixDataTableController].
class MiuixDataTable<T> extends StatefulWidget {
  /// Creates a table over typed application items with local content glass.
  const MiuixDataTable({
    super.key,
    required this.items,
    required this.columns,
    required this.rowKey,
    this.controller,
    this.onSortChanged,
    this.onSelectionChanged,
    this.onRowActivated,
    this.selectable = false,
    this.multiSelect = true,
    this.showHeader = true,
    this.emptyState,
    this.height = MiuixDataTableDefaults.defaultHeight,
    this.shrinkWrapRows = false,
    this.minimumWidth = MiuixDataTableDefaults.minimumWidth,
    this.headerHeight = MiuixDataTableDefaults.headerHeight,
    this.rowHeight = MiuixDataTableDefaults.rowHeight,
    this.glass = true,
    this.cornerRadius = double.nan,
    this.colors,
  });

  /// Creates a table with the former fixed 20dp opaque outer surface.
  const MiuixDataTable.source({
    super.key,
    required this.items,
    required this.columns,
    required this.rowKey,
    this.controller,
    this.onSortChanged,
    this.onSelectionChanged,
    this.onRowActivated,
    this.selectable = false,
    this.multiSelect = true,
    this.showHeader = true,
    this.emptyState,
    this.height = MiuixDataTableDefaults.defaultHeight,
    this.shrinkWrapRows = false,
    this.minimumWidth = MiuixDataTableDefaults.minimumWidth,
    this.headerHeight = MiuixDataTableDefaults.headerHeight,
    this.rowHeight = MiuixDataTableDefaults.rowHeight,
    this.colors,
  }) : glass = false,
       cornerRadius = MiuixDataTableDefaults.cornerRadius;

  /// Source items, columns, and stable row identity.
  final List<T> items;
  final List<MiuixDataColumn<T>> columns;
  final Object Function(T item) rowKey;

  /// Optional hoisted table state.
  final MiuixDataTableController? controller;

  /// State callbacks.
  final void Function(String columnId, bool ascending)? onSortChanged;
  final ValueChanged<Set<Object>>? onSelectionChanged;
  final ValueChanged<T>? onRowActivated;

  /// Selection policy and header visibility.
  final bool selectable;
  final bool multiSelect;
  final bool showHeader;

  final Widget? emptyState;
  final double height;

  /// Shrinks the viewport to the header and currently available rows.
  ///
  /// This is useful inside a page-level scroll view. Large datasets retain
  /// [height] as their maximum and continue scrolling inside the table.
  final bool shrinkWrapRows;
  final double minimumWidth;
  final double headerHeight;
  final double rowHeight;
  final bool glass;
  final double cornerRadius;
  final MiuixDataTableColors? colors;

  @override
  State<MiuixDataTable<T>> createState() => _MiuixDataTableState<T>();
}

class _MiuixDataTableState<T> extends State<MiuixDataTable<T>> {
  late MiuixDataTableController _controller;
  late bool _ownsController;
  final ScrollController _vertical = ScrollController();
  final ScrollController _horizontal = ScrollController();
  final FocusNode _focusNode = FocusNode(debugLabel: 'MiuixDataTable');
  int _focusedRow = 0;
  // Keyboard-focus identity contract:
  // - `_focusedRow` is a transient visual position, not durable identity.
  // - `_focusedRowKey` is the caller-authored stable identity of the row.
  // - Pointer focus records both position and key in the same state update.
  // - Keyboard movement resolves the key against the latest sorted item list.
  // - Sorting must keep focus on the same key even when its index changes.
  // - External controller sorting follows exactly the same rule as header taps.
  // - Activation resolves identity again immediately before invoking callbacks.
  // - Selection therefore targets the focused data item, not the former index.
  // - Row rendering compares the stable key whenever one has been established.
  // - Before first focus, the legacy initial visual position remains row zero.
  // - Removing rows may make the previous key impossible to resolve.
  // - In that case the previous numeric neighborhood is clamped into the list.
  // - The surviving row immediately becomes the new stable focus identity.
  // - Shrinking to an empty list clears both index and key safely.
  // - Growing again starts from row zero until a new focus action occurs.
  // - Reordering without sorting is handled by the same key lookup.
  // - Duplicate row keys remain invalid application input and are ambiguous.
  // - `rowKey` is expected to be stable and side-effect free during a build.
  // - Multi-selection state remains independently owned by the controller.
  // - Sorting never rewrites selection keys or focused keys.
  // - Focus normalization performs no callback and no haptic feedback.
  // - It may update private fields during build because it derives cached state.
  // - It never calls setState from build and cannot schedule a recursive frame.
  // - Scroll targets continue to use the resolved current numeric position.
  // - Reduced motion changes scroll settlement, not focused-row identity.
  // - Mouse hover is visual-only and does not replace keyboard focus identity.
  // - A row tap still requests the table's shared FocusNode after recording key.
  // - Header interaction may sort while the existing row focus remains valid.
  // - Enter and Space share `_activateFocused` and therefore the same resolution.
  // - Arrow Up and Down share `_moveFocus` and update key atomically.
  // - Tests focus item 3, sort it from index zero to index two, then activate.
  // - A positional implementation activates item 1 and fails that regression.
  // - Tests also remove the focused last row and inspect the surviving focus fill.
  // - Compile success alone cannot demonstrate stable identity across rebuilds.
  // - Golden images alone cannot demonstrate which item Enter will activate.
  // - Controller-listener rebuilds must preserve this key before sorting paint.
  // - Widget data rebuilds must normalize a missing key before row construction.
  // - Future pagination work must not discard focus merely because a page moves.
  // - Future virtualization must retain key resolution for mounted visible rows.
  // - Any change back to index-only focus would reintroduce the confirmed defect.
  Object? _focusedRowKey;
  bool _reduceMotion = false;
  double? _keyboardScrollTarget;
  int _motionPreferenceGeneration = 0;

  // Public table geometry contract:
  // - Every table and column extent must be finite and strictly positive.
  // - Valid caller-authored dimensions are retained exactly.
  // - Zero, negative, NaN, and infinite values use role-specific defaults.
  // - Table height provides the same bound in fixed and shrink-wrap modes.
  // - Header layout and content-height arithmetic share `_safeHeaderHeight`.
  // - Row layout, itemExtent, and keyboard offsets share `_safeRowHeight`.
  // - Horizontal overflow and cell layout share `_safeColumnWidth`.
  // - Minimum width is normalized before it becomes a clamp lower bound.
  // - A bad column cannot poison the sum for every later column.
  // - Runtime safety therefore remains present when release removes asserts.
  // - Normalization does not mutate the caller-owned column models.
  // - Dynamic geometry changes are sampled together during the next build.
  // - Focus identity remains key-based and independent from these dimensions.
  // - Selection callbacks remain unchanged by geometry normalization.
  // - Source and HyperOS constructors use the same behavioral boundary.
  // Selection publication and viewport contract:
  // - `selectable` enables row selection independently from multiplicity policy.
  // - `multiSelect` controls whether more than one row may remain selected.
  // - A single-select header preserves the checkbox lane only for column alignment.
  // - That lane exposes no select-all checkbox or actionable semantics.
  // - Row checkboxes remain visible so the single selected row is still explicit.
  // - Selecting a new row in single mode atomically replaces the previous key set.
  // - Deselecting that selected row may still produce an empty valid selection.
  // - Multi-select headers operate only over rows in the current table model.
  // - Selection keys outside the model remain controller-owned for future paging.
  // - Header select-all deliberately replaces, rather than unions, the key set.
  // - Header clear likewise clears every controller selection, including off-page keys.
  // - Each callback receives an immutable point-in-time Set snapshot.
  // - A later controller mutation cannot rewrite a Set retained by application code.
  // - The controller getter itself remains a read-only live view for direct observers.
  // - Row checkbox contact records the same stable keyboard focus key as row contact.
  // - It requests table focus before publishing the selection change.
  // - Subsequent arrow navigation therefore continues from the checkbox's row.
  // - Selection haptics identify toggle direction for row and header operations.
  // - Non-selectable row activation uses confirmation feedback exactly once.
  // - Keyboard activation and double-click route through the same activation helper.
  // - A missing activation callback emits neither callback nor confirmation feedback.
  // - Keyboard scrolling is an ensure-visible operation, not row-to-top scrolling.
  // - A fully visible focused row leaves the current scroll offset unchanged.
  // - A row above the viewport aligns its top with the viewport's top edge.
  // - A row below the viewport aligns its bottom with the viewport's bottom edge.
  // - The resulting target is clamped to the current ScrollPosition extent.
  // - Header height is excluded because the vertical list viewport starts below it.
  // - Horizontal scrollbar reservation is likewise outside that vertical position.
  // - Multiple rapid keys replace the current animation with the newest target.
  // - `_keyboardScrollTarget` records that logical newest target for policy changes.
  // - Enabling reduced motion jumps to the target most recently requested.
  // - A zero or negative theme scroll duration also resolves by immediate jump.
  // - Invalid motion tokens never reach ScrollController.animateTo assertions.
  // - Animation completion clears only the target belonging to that completion.
  // - A canceled older animation cannot clear a newer identical focus identity.
  // - Sorting during scroll retains focus by key and recomputes future row geometry.
  // - Data shrink clamps a missing key before the next activation can run.
  // - Data growth never moves a still-present stable focused key.
  // - Pointer hover remains separate from both controller selection and keyboard focus.
  // - These rules preserve desktop density without making Android touch rows jump.
  double _safePositiveDimension(double value, double fallback) =>
      value.isFinite && value > 0 ? value : fallback;

  double get _safeHeight => _safePositiveDimension(
    widget.height,
    MiuixDataTableDefaults.defaultHeight,
  );
  double get _safeMinimumWidth => _safePositiveDimension(
    widget.minimumWidth,
    MiuixDataTableDefaults.minimumWidth,
  );
  double get _safeHeaderHeight => _safePositiveDimension(
    widget.headerHeight,
    MiuixDataTableDefaults.headerHeight,
  );
  double get _safeRowHeight => _safePositiveDimension(
    widget.rowHeight,
    MiuixDataTableDefaults.rowHeight,
  );
  double _safeColumnWidth(MiuixDataColumn<T> column) =>
      _safePositiveDimension(column.width, 160);

  @override
  void initState() {
    super.initState();
    _attachController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextReduceMotion = MediaQuery.disableAnimationsOf(context);
    if (nextReduceMotion == _reduceMotion) return;
    _reduceMotion = nextReduceMotion;
    final generation = ++_motionPreferenceGeneration;
    final target = _keyboardScrollTarget;
    if (!nextReduceMotion || target == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          !_reduceMotion ||
          generation != _motionPreferenceGeneration ||
          !_vertical.hasClients) {
        return;
      }
      final settled = target
          .clamp(0, _vertical.position.maxScrollExtent)
          .toDouble();
      _vertical.jumpTo(settled);
    });
  }

  void _attachController() {
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? MiuixDataTableController();
    _controller.addListener(_rebuild);
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(MiuixDataTable<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    _controller.removeListener(_rebuild);
    if (_ownsController) _controller.dispose();
    _attachController();
  }

  List<T> get _sortedItems {
    final result = List<T>.of(widget.items);
    final id = _controller.sortColumnId;
    if (id == null) return result;
    final column = widget.columns.cast<MiuixDataColumn<T>?>().firstWhere(
      (candidate) => candidate?.id == id,
      orElse: () => null,
    );
    if (column?.comparator == null) return result;
    result.sort(column!.comparator);
    return _controller.sortAscending ? result : result.reversed.toList();
  }

  void _normalizeFocusedRow(List<T> items) {
    if (items.isEmpty) {
      _focusedRow = 0;
      _focusedRowKey = null;
      return;
    }
    final keyedIndex = _focusedRowKey == null
        ? -1
        : items.indexWhere((item) => widget.rowKey(item) == _focusedRowKey);
    if (keyedIndex >= 0) {
      _focusedRow = keyedIndex;
      return;
    }
    _focusedRow = _focusedRow.clamp(0, items.length - 1);
    // Preserve the previous positional neighborhood when the focused row was
    // removed, but immediately assign the replacement's stable identity so a
    // later sort cannot silently transfer focus again.
    if (_focusedRowKey != null) {
      _focusedRowKey = widget.rowKey(items[_focusedRow]);
    }
  }

  double get _contentWidth {
    final columns = widget.columns.fold<double>(
      0,
      (sum, column) => sum + _safeColumnWidth(column),
    );
    return columns +
        (widget.selectable ? MiuixDataTableDefaults.checkboxWidth : 0);
  }

  void _sort(MiuixDataColumn<T> column) {
    if (column.comparator == null) return;
    _controller.sortBy(column.id);
    widget.onSortChanged?.call(column.id, _controller.sortAscending);
    MiuixHaptics.perform(MiuixHapticType.segmentTick);
  }

  Set<Object> get _selectionSnapshot =>
      Set<Object>.unmodifiable(_controller.selectedKeys);

  void _publishSelection() {
    widget.onSelectionChanged?.call(_selectionSnapshot);
  }

  void _select(T item, bool selected) {
    final key = widget.rowKey(item);
    if (!widget.multiSelect && selected) {
      _controller.setSelection(<Object>{key});
    } else {
      _controller.setSelected(key, selected);
    }
    _publishSelection();
    MiuixHaptics.perform(
      selected ? MiuixHapticType.toggleOn : MiuixHapticType.toggleOff,
    );
  }

  void _moveFocus(int delta) {
    final items = _sortedItems;
    if (items.isEmpty) return;
    final keyedIndex = _focusedRowKey == null
        ? -1
        : items.indexWhere((item) => widget.rowKey(item) == _focusedRowKey);
    final current = keyedIndex >= 0
        ? keyedIndex
        : _focusedRow.clamp(0, items.length - 1);
    setState(() {
      _focusedRow = (current + delta).clamp(0, items.length - 1);
      _focusedRowKey = widget.rowKey(items[_focusedRow]);
    });
    if (_vertical.hasClients) {
      final position = _vertical.position;
      final rowTop = _focusedRow * _safeRowHeight;
      final rowBottom = rowTop + _safeRowHeight;
      final viewportTop = position.pixels;
      final viewportBottom = viewportTop + position.viewportDimension;
      double? requested;
      if (rowTop < viewportTop) {
        requested = rowTop;
      } else if (rowBottom > viewportBottom) {
        requested = rowBottom - position.viewportDimension;
      }
      if (requested == null) return;
      final target = requested.clamp(0, position.maxScrollExtent).toDouble();
      _keyboardScrollTarget = target;
      final duration = MiuixTheme.of(context).hyperOs4.collectionScrollMotion;
      if (_reduceMotion || duration <= Duration.zero) {
        _vertical.jumpTo(target);
        _keyboardScrollTarget = null;
      } else {
        final pending = _vertical.animateTo(
          target,
          duration: duration,
          curve: Curves.easeOutCubic,
        );
        pending.whenComplete(() {
          if (_keyboardScrollTarget == target) {
            _keyboardScrollTarget = null;
          }
        });
      }
    }
  }

  void _activateFocused() {
    final items = _sortedItems;
    if (items.isEmpty) return;
    final keyedIndex = _focusedRowKey == null
        ? -1
        : items.indexWhere((item) => widget.rowKey(item) == _focusedRowKey);
    _focusedRow = keyedIndex >= 0
        ? keyedIndex
        : _focusedRow.clamp(0, items.length - 1);
    final item = items[_focusedRow];
    _focusedRowKey = widget.rowKey(item);
    if (widget.selectable) {
      final key = widget.rowKey(item);
      _select(item, !_controller.selectedKeys.contains(key));
    } else {
      _activateItem(item);
    }
  }

  void _activateItem(T item) {
    final callback = widget.onRowActivated;
    if (callback == null) return;
    callback(item);
    MiuixHaptics.perform(MiuixHapticType.confirm);
  }

  Widget _checkboxCell({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SizedBox(
      width: MiuixDataTableDefaults.checkboxWidth,
      child: Center(
        child: MiuixCheckbox(
          value: value,
          onChanged: (next) => onChanged(next ?? false),
        ),
      ),
    );
  }

  Widget _columnCell(MiuixDataColumn<T> column, Widget child) {
    return SizedBox(
      width: _safeColumnWidth(column),
      child: Align(
        alignment: column.numeric
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: child,
        ),
      ),
    );
  }

  Widget _header(MiuixDataTableColors colors, List<T> items) {
    // Header contract:
    // - Select-all reflects only rows currently present in the sorted model.
    // - Sorting changes state through the shared controller before callbacks.
    // - A non-sortable column never advertises button semantics.
    // - Numeric columns align labels toward the locale-aware numeric edge.
    // - The active direction glyph is supplemental to the spoken header label.
    // - Glass mode retains a readable tint without hiding sampled backdrop.
    // - Solid mode preserves the complete semantic header-surface color.
    // - Header height stays independent from row height customization.
    // - Fixed column widths remain identical between header and row builders.
    // - Long labels ellipsize instead of changing the declared table geometry.
    final selectedCount = items
        .where((item) => _controller.selectedKeys.contains(widget.rowKey(item)))
        .length;
    final allSelected = items.isNotEmpty && selectedCount == items.length;
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final headerColor = widget.glass
        ? colors.headerSurface.withValues(
            alpha: hyperOs4.dataTableHeaderTintOpacity,
          )
        : colors.headerSurface;
    return Container(
      key: const ValueKey('miuix-data-table-header'),
      height: _safeHeaderHeight,
      color: headerColor,
      child: Row(
        children: <Widget>[
          if (widget.selectable)
            widget.multiSelect
                ? _checkboxCell(
                    value: allSelected,
                    onChanged: (selected) {
                      _controller.setSelection(
                        selected ? items.map(widget.rowKey) : const <Object>[],
                      );
                      _publishSelection();
                      MiuixHaptics.perform(
                        selected
                            ? MiuixHapticType.toggleOn
                            : MiuixHapticType.toggleOff,
                      );
                    },
                  )
                : const SizedBox(width: MiuixDataTableDefaults.checkboxWidth),
          for (final column in widget.columns)
            _columnCell(
              column,
              Semantics(
                button: column.comparator != null,
                label: column.label,
                child: MiuixPressable(
                  onTap: column.comparator == null ? null : () => _sort(column),
                  feedbackType: MiuixPressFeedbackType.none,
                  showIndication: column.comparator != null,
                  child: SizedBox.expand(
                    child: Row(
                      mainAxisAlignment: column.numeric
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            column.label,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: colors.foreground,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        if (_controller.sortColumnId == column.id) ...<Widget>[
                          const SizedBox(width: 4),
                          MiuixExtensionChevron(
                            direction: _controller.sortAscending
                                ? MiuixExtensionChevronDirection.up
                                : MiuixExtensionChevronDirection.down,
                            size: 17,
                            color: colors.primary,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _row(T item, int index, MiuixDataTableColors colors) {
    final key = widget.rowKey(item);
    final selected = _controller.selectedKeys.contains(key);
    return _HoverTableRow(
      height: _safeRowHeight,
      selected: selected,
      focused:
          (_focusedRowKey == null
              ? index == _focusedRow
              : key == _focusedRowKey) &&
          _focusNode.hasFocus,
      colors: colors,
      onTap: () {
        setState(() {
          _focusedRow = index;
          _focusedRowKey = key;
        });
        _focusNode.requestFocus();
        if (widget.selectable) _select(item, !selected);
      },
      onDoubleTap: widget.onRowActivated == null
          ? null
          : () => _activateItem(item),
      child: Row(
        children: <Widget>[
          if (widget.selectable)
            _checkboxCell(
              value: selected,
              onChanged: (value) {
                setState(() {
                  _focusedRow = index;
                  _focusedRowKey = key;
                });
                _focusNode.requestFocus();
                _select(item, value);
              },
            ),
          for (final column in widget.columns)
            _columnCell(column, column.cellBuilder(context, item)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_rebuild);
    if (_ownsController) _controller.dispose();
    _vertical.dispose();
    _horizontal.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Root layout contract:
    // - Explicit emptyState may replace the table before focus is introduced.
    // - Otherwise an empty collection retains header and bounded empty content.
    // - Outer glass, clipping, and pointer bounds share one resolved radius.
    // - The horizontal scrollbar receives a dedicated non-data footer lane.
    // - The vertical list removes ambient padding and is never primary.
    // - Shrink-wrap mode caps content rather than disabling internal scrolling.
    // - Header and rows move together under one horizontal scroll controller.
    // - Keyboard focus survives sorting because stable keys own selection.
    // - Theme calibration never mutates caller-provided sizes or column models.
    // - Controller ownership remains explicit across widget replacement.
    // - Surface material is resolved once for a coherent rendered snapshot.
    // - Nested page scrolling cannot claim the table's horizontal thumb drag.
    final colors = widget.colors ?? MiuixDataTableDefaults.colors(context);
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final themeRadius = hyperOs4.cardCornerRadius.isFinite
        ? hyperOs4.cardCornerRadius.clamp(0.0, double.infinity).toDouble()
        : 0.0;
    final radius = widget.cornerRadius.isFinite
        ? widget.cornerRadius.clamp(0.0, double.infinity).toDouble()
        : themeRadius;
    final items = _sortedItems;
    _normalizeFocusedRow(items);
    if (items.isEmpty && widget.emptyState != null) return widget.emptyState!;
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.arrowUp): _TableMoveIntent(-1),
        SingleActivator(LogicalKeyboardKey.arrowDown): _TableMoveIntent(1),
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _TableMoveIntent: CallbackAction<_TableMoveIntent>(
            onInvoke: (intent) {
              _moveFocus(intent.delta);
              return null;
            },
          ),
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _activateFocused();
              return null;
            },
          ),
        },
        child: Focus(
          focusNode: _focusNode,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = _contentWidth.clamp(
                _safeMinimumWidth,
                double.infinity,
              );
              final resolvedWidth = constraints.maxWidth.isFinite
                  ? width.clamp(constraints.maxWidth, double.infinity)
                  : width;
              final availableWidth = constraints.maxWidth.isFinite
                  ? constraints.maxWidth
                  : resolvedWidth;
              final hasHorizontalOverflow = resolvedWidth > availableWidth + .5;
              // Scrollbar paints over its scrollable by design. Reserve a
              // footer lane so the horizontal thumb never crosses the final
              // data row or its selection control.
              final horizontalScrollbarExtent = hasHorizontalOverflow
                  ? MiuixDataTableDefaults.horizontalScrollbarLane
                  : 0.0;
              final contentHeight =
                  (widget.showHeader ? _safeHeaderHeight : 0) +
                  items.length * _safeRowHeight;
              final resolvedHeight = widget.shrinkWrapRows
                  ? (contentHeight + horizontalScrollbarExtent).clamp(
                      0.0,
                      _safeHeight,
                    )
                  : _safeHeight;
              final scrollbarTheme = ScrollbarTheme.of(context).copyWith(
                thumbColor: WidgetStatePropertyAll<Color>(
                  colors.secondaryForeground.withValues(alpha: .32),
                ),
                thickness: const WidgetStatePropertyAll<double>(3),
                radius: const Radius.circular(99),
                crossAxisMargin: 2,
                mainAxisMargin: 8,
              );
              return MiuixSurface(
                key: const ValueKey('miuix-data-table-surface'),
                radius: radius,
                color: colors.surface,
                glass: widget.glass,
                glassBlur: hyperOs4.contentSurfaceBlur,
                glassOpacity: hyperOs4.contentSurfaceTintOpacity,
                child: SizedBox(
                  height: resolvedHeight,
                  child: ScrollbarTheme(
                    data: scrollbarTheme,
                    child: Scrollbar(
                      controller: _horizontal,
                      thumbVisibility: hasHorizontalOverflow,
                      trackVisibility: false,
                      scrollbarOrientation: ScrollbarOrientation.bottom,
                      child: SingleChildScrollView(
                        controller: _horizontal,
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: resolvedWidth,
                          child: Padding(
                            padding: EdgeInsets.only(
                              bottom: horizontalScrollbarExtent,
                            ),
                            child: Column(
                              children: <Widget>[
                                if (widget.showHeader) _header(colors, items),
                                Expanded(
                                  child: items.isEmpty
                                      ? const MiuixEmptyState(
                                          title: '没有数据',
                                          message: '这里还没有可显示的记录。',
                                        )
                                      : Scrollbar(
                                          controller: _vertical,
                                          child: ListView.builder(
                                            controller: _vertical,
                                            primary: false,
                                            padding: EdgeInsets.zero,
                                            itemExtent: _safeRowHeight,
                                            itemCount: items.length,
                                            itemBuilder: (context, index) =>
                                                _row(
                                                  items[index],
                                                  index,
                                                  colors,
                                                ),
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HoverTableRow extends StatefulWidget {
  const _HoverTableRow({
    required this.height,
    required this.selected,
    required this.focused,
    required this.colors,
    required this.onTap,
    required this.onDoubleTap,
    required this.child,
  });

  final double height;
  final bool selected;
  final bool focused;
  final MiuixDataTableColors colors;
  final VoidCallback onTap;
  final VoidCallback? onDoubleTap;
  final Widget child;

  @override
  State<_HoverTableRow> createState() => _HoverTableRowState();
}

class _HoverTableRowState extends State<_HoverTableRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final background = widget.selected
        ? widget.colors.selectedSurface
        : _hovered || widget.focused
        ? widget.colors.hoverSurface
        : Colors.transparent;
    return Semantics(
      selected: widget.selected,
      button: true,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          onDoubleTap: widget.onDoubleTap,
          child: AnimatedContainer(
            key: ValueKey<bool>(MediaQuery.disableAnimationsOf(context)),
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : MiuixTheme.of(context).hyperOs4.collectionRowMotion,
            height: widget.height,
            decoration: BoxDecoration(
              color: background,
              border: Border(bottom: BorderSide(color: widget.colors.divider)),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class _TableMoveIntent extends Intent {
  const _TableMoveIntent(this.delta);
  final int delta;
}
