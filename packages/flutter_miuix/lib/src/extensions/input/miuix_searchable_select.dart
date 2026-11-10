import '../../icons/miuix_icon_theme.dart';
import 'dart:collection';

import 'package:flutter/foundation.dart' show setEquals;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../platform/miuix_haptics.dart';
import '../../theme/miuix_semantic_colors.dart';
import '../../theme/miuix_theme.dart';
import '../../widgets/miuix_widgets.dart';
import '../miuix_extension_icons.dart';

/// Typed option used by searchable single- and multi-select controls.
@immutable
class MiuixSearchableSelectOption<T extends Object> {
  /// Creates one searchable option.
  const MiuixSearchableSelectOption({
    required this.value,
    required this.label,
    this.searchText,
    this.icon,
    this.summary,
    this.enabled = true,
  });

  final T value;
  final String label;
  final String? searchText;
  final Widget? icon;
  final String? summary;
  final bool enabled;

  /// Case-insensitive text matched by the default filter.
  String get searchableText => '${searchText ?? ''} $label ${summary ?? ''}';
}

/// Selection state shared by searchable selects and combo boxes.
class MiuixSearchableSelectController<T extends Object> extends ChangeNotifier {
  /// Creates a controller with an optional initial selection.
  MiuixSearchableSelectController({Iterable<T> selected = const []})
    : _selected = Set<T>.of(selected);

  final Set<T> _selected;

  /// Immutable selected values.
  Set<T> get selected => UnmodifiableSetView<T>(_selected);

  /// First selected value for single-select consumers.
  T? get value => _selected.firstOrNull;

  /// Whether a value is selected.
  bool contains(T value) => _selected.contains(value);

  /// Replaces the single selected value.
  set value(T? next) {
    if (_selected.length <= 1 && _selected.firstOrNull == next) return;
    _selected
      ..clear()
      ..addAll(next == null ? <T>[] : <T>[next]);
    notifyListeners();
  }

  /// Replaces the complete selection.
  void setSelected(Iterable<T> values) {
    final next = Set<T>.of(values);
    if (setEquals(next, _selected)) return;
    _selected
      ..clear()
      ..addAll(next);
    notifyListeners();
  }

  /// Adds or removes a value.
  void toggle(T value) {
    if (!_selected.remove(value)) _selected.add(value);
    notifyListeners();
  }

  /// Clears every selected value.
  void clear() {
    if (_selected.isEmpty) return;
    _selected.clear();
    notifyListeners();
  }
}

/// Searchable-select colors separated from Material dropdown styling.
@immutable
class MiuixSearchableSelectColors {
  /// Creates a complete palette.
  const MiuixSearchableSelectColors({
    required this.background,
    required this.foreground,
    required this.secondaryForeground,
    required this.selectedBackground,
    required this.selectedForeground,
    required this.disabledForeground,
  });

  final Color background;
  final Color foreground;
  final Color secondaryForeground;
  final Color selectedBackground;
  final Color selectedForeground;
  final Color disabledForeground;
}

/// Defaults for searchable selection dialogs and triggers.
abstract final class MiuixSearchableSelectDefaults {
  /// Dialog and row geometry.
  static const double cornerRadius = 18;
  static const double maxDialogWidth = 520;
  static const double maxDialogHeight = 520;
  static const double minDialogHeight = 180;
  static const double rowExtent = 56;

  /// Resolves a content-fitting dialog height without allowing a short option
  /// list to expand into an almost full-screen panel.
  ///
  /// A row includes the declared content extent, the surface's vertical inset,
  /// and its outer separation. The search field and optional confirmation row
  /// are included before the value is clamped to the phone/desktop limit.
  static double dialogHeight({
    required int optionCount,
    required bool multiple,
  }) {
    final safeCount = optionCount.clamp(0, 1000000);
    const searchAndGap = 66.0;
    const completeRowExtent = rowExtent + 20;
    final footerExtent = multiple ? 68.0 : 0.0;
    return (searchAndGap + safeCount * completeRowExtent + footerExtent).clamp(
      minDialogHeight,
      maxDialogHeight,
    );
  }

  /// Resolves selection colors.
  static MiuixSearchableSelectColors colors(BuildContext context) {
    final semantic = MiuixSemanticColors.of(context);
    return MiuixSearchableSelectColors(
      background: semantic['secondaryContainer'],
      foreground: semantic['onSurface'],
      secondaryForeground: semantic['onSurfaceSecondary'],
      selectedBackground: semantic['primaryContainer'],
      selectedForeground: semantic['onPrimaryContainer'],
      disabledForeground: semantic['disabledOnSurface'],
    );
  }
}

/// Searchable MIUIX select supporting one or many typed values.
class MiuixSearchableSelect<T extends Object> extends StatefulWidget {
  /// Creates a searchable trigger that opens a package dialog.
  const MiuixSearchableSelect({
    super.key,
    required this.options,
    this.controller,
    this.initialSelected = const [],
    this.multiple = false,
    this.maximumSelection,
    this.label,
    this.placeholder = '请选择',
    this.searchHint = '搜索',
    this.emptyMessage = '没有匹配的选项',
    this.enabled = true,
    this.clearable = true,
    this.onChanged,
    this.optionFilter,
    this.glass = true,
    this.glassBlur,
    this.glassOpacity,
    this.showGlassSpecular = true,
    this.cornerRadius = double.nan,
    this.colors,
  });

  /// Creates the former fixed 18dp opaque searchable-select field.
  const MiuixSearchableSelect.source({
    super.key,
    required this.options,
    this.controller,
    this.initialSelected = const [],
    this.multiple = false,
    this.maximumSelection,
    this.label,
    this.placeholder = '请选择',
    this.searchHint = '搜索',
    this.emptyMessage = '没有匹配的选项',
    this.enabled = true,
    this.clearable = true,
    this.onChanged,
    this.optionFilter,
    this.colors,
  }) : glass = false,
       glassBlur = null,
       glassOpacity = null,
       showGlassSpecular = false,
       cornerRadius = MiuixSearchableSelectDefaults.cornerRadius;

  /// Available options and selection state.
  final List<MiuixSearchableSelectOption<T>> options;
  final MiuixSearchableSelectController<T>? controller;
  final Iterable<T> initialSelected;
  final bool multiple;
  final int? maximumSelection;

  /// Visible labels and behavior.
  final String? label;
  final String placeholder;
  final String searchHint;
  final String emptyMessage;
  final bool enabled;
  final bool clearable;

  /// Selection and filtering callbacks.
  final ValueChanged<Set<T>>? onChanged;
  final bool Function(MiuixSearchableSelectOption<T> option, String query)?
  optionFilter;

  /// Trigger-field material and continuous-corner overrides.
  final bool glass;
  final double? glassBlur;
  final double? glassOpacity;
  final bool showGlassSpecular;
  final double cornerRadius;
  final MiuixSearchableSelectColors? colors;

  @override
  State<MiuixSearchableSelect<T>> createState() =>
      _MiuixSearchableSelectState<T>();
}

class _MiuixSearchableSelectState<T extends Object>
    extends State<MiuixSearchableSelect<T>> {
  // Search-dialog operation contract:
  // - A dialog result belongs to the exact trigger operation that opened it.
  // - Each opening receives a monotonically increasing local generation.
  // - Opening a newer dialog invalidates any older unresolved result.
  // - Replacing the selection controller invalidates the open operation.
  // - Replacing options invalidates results authored from the old option set.
  // - Switching single/multiple mode invalidates the old selection shape.
  // - Changing the maximum invalidates results using the former limit.
  // - Changing the filter invalidates the visible old selection universe.
  // - Disabling the trigger invalidates and rejects an outstanding result.
  // - Pure theme changes do not invalidate a logically equivalent dialog.
  // - A stale result never writes into a newly attached controller.
  // - A stale result never publishes through a newly supplied callback.
  // - An unmounted trigger rejects every late dialog completion.
  // - Cancellation remains a null result and performs no state mutation.
  // - The controller captured at opening supplies initial selection.
  // - Only an identical controller may receive the accepted result.
  // - Controller disposal remains governed by explicit ownership state.
  // - The modal route may animate closed after its result is invalidated.
  // - Invalidating an operation does not forcibly pop a user-visible route.
  // - A valid result updates controller state before publishing outward.
  // - Multi-select returns an immutable snapshot through public callbacks.
  // - Single-select and multi-select share the same stale-result barrier.
  // Dynamic option and controlled-selection contract:
  // - Selected values must correspond to a currently available option value.
  // - Disabled options remain available and may retain an existing selection.
  // - Removing an option removes its stale value from controller selection.
  // - Reordering options never changes the logical selected-value set.
  // - Duplicate option values contribute one canonical selected value.
  // - Single mode retains at most one available value.
  // - The retained single value follows current visible option order.
  // - Multiple mode observes a normalized positive maximum selection count.
  // - Null maximum remains unlimited.
  // - Zero and negative maximum values fall back to one.
  // - Shrinking a maximum retains the earliest available selected options.
  // - Expanding a maximum never recreates values removed by an earlier limit.
  // - Initial internal selection is normalized before listener attachment.
  // - Initial caller-owned controller state follows the same path.
  // - Attachment correction intentionally does not invoke onChanged.
  // - Later external controller writes are normalized by the listener.
  // - A recursion guard suppresses the nested correction notification.
  // - The widget rebuilds once from the final legal controller state.
  // - Programmatic correction does not masquerade as a user selection event.
  // - Controller listeners outside this widget still observe the correction.
  // - Live option replacement invalidates any dialog from the old universe.
  // - The new option universe is reconciled before another dialog opens.
  // - A stale dialog result can never reintroduce a removed value.
  // - Empty options clear selection and disable opening the trigger.
  // - Trigger text and semantic value read the same legal option projection.
  // - Clear remains a deliberate user action and publishes one empty snapshot.
  // - Search filtering never removes values from durable selection by itself.
  // - Filtered rows remain a transient dialog presentation concern.
  // - ComboBox inherits every rule through the shared implementation.
  // - These rules apply equally to glass and source presentation constructors.
  // - Tests cover stale removal, mode reduction, maximum shrink, and callbacks.
  // - Device validation remains required for physical IME and keyboard timing.
  // These rules prevent route timing from changing application ownership.

  late MiuixSearchableSelectController<T> _controller;
  late bool _ownsController;
  int _dialogGeneration = 0;
  bool _normalizingSelection = false;

  int? get _selectionLimit {
    if (!widget.multiple) return 1;
    final maximum = widget.maximumSelection;
    if (maximum == null) return null;
    return maximum < 1 ? 1 : maximum;
  }

  Set<T> _legalSelection() {
    final selected = _controller.selected;
    final limit = _selectionLimit;
    final legal = <T>{};
    for (final option in widget.options) {
      if (!selected.contains(option.value)) continue;
      legal.add(option.value);
      if (limit != null && legal.length >= limit) break;
    }
    return legal;
  }

  void _normalizeSelection() {
    final legal = _legalSelection();
    if (setEquals(legal, _controller.selected)) return;
    _normalizingSelection = true;
    try {
      _controller.setSelected(legal);
    } finally {
      _normalizingSelection = false;
    }
  }

  @override
  void initState() {
    super.initState();
    _attachController();
  }

  void _attachController() {
    _ownsController = widget.controller == null;
    _controller =
        widget.controller ??
        MiuixSearchableSelectController<T>(selected: widget.initialSelected);
    _normalizeSelection();
    _controller.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(MiuixSearchableSelect<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final dialogContractChanged =
        oldWidget.controller != widget.controller ||
        oldWidget.options != widget.options ||
        oldWidget.multiple != widget.multiple ||
        oldWidget.maximumSelection != widget.maximumSelection ||
        oldWidget.optionFilter != widget.optionFilter ||
        oldWidget.enabled != widget.enabled;
    if (dialogContractChanged) _dialogGeneration++;
    if (oldWidget.controller != widget.controller) {
      _controller.removeListener(_rebuild);
      if (_ownsController) _controller.dispose();
      _attachController();
      return;
    }
    if (oldWidget.options != widget.options ||
        oldWidget.multiple != widget.multiple ||
        oldWidget.maximumSelection != widget.maximumSelection) {
      _normalizeSelection();
    }
  }

  void _rebuild() {
    if (!mounted || _normalizingSelection) return;
    _normalizeSelection();
    setState(() {});
  }

  List<MiuixSearchableSelectOption<T>> get _selectedOptions => widget.options
      .where((option) => _controller.contains(option.value))
      .toList(growable: false);

  void _publish() {
    widget.onChanged?.call(Set<T>.unmodifiable(_controller.selected));
  }

  Future<void> _open() async {
    if (!widget.enabled || widget.options.isEmpty) return;
    final generation = ++_dialogGeneration;
    final openingController = _controller;
    final result = await MiuixDialog.show<Set<T>>(
      context: context,
      title: widget.label ?? widget.placeholder,
      maxWidth: MiuixSearchableSelectDefaults.maxDialogWidth,
      content: _MiuixSearchableSelectDialog<T>(
        options: widget.options,
        initialSelected: openingController.selected,
        multiple: widget.multiple,
        maximumSelection: widget.maximumSelection,
        searchHint: widget.searchHint,
        emptyMessage: widget.emptyMessage,
        optionFilter: widget.optionFilter,
        colors: widget.colors,
      ),
    );
    if (!mounted ||
        result == null ||
        generation != _dialogGeneration ||
        !identical(_controller, openingController) ||
        !widget.enabled) {
      return;
    }
    openingController.setSelected(result);
    _publish();
  }

  @override
  void dispose() {
    _controller.removeListener(_rebuild);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette =
        widget.colors ?? MiuixSearchableSelectDefaults.colors(context);
    final selected = _selectedOptions;
    final selectedText = selected.map((option) => option.label).join('、');
    final hasSelection = selected.isNotEmpty;
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final radius = widget.cornerRadius.isFinite && widget.cornerRadius >= 0
        ? widget.cornerRadius
        : hyperOs4.textFieldCornerRadius;
    final trigger = Semantics(
      button: true,
      enabled: widget.enabled,
      label: widget.label,
      value: hasSelection ? selectedText : widget.placeholder,
      child: MiuixSurface(
        key: const ValueKey('miuix-searchable-select-trigger'),
        onTap: widget.enabled ? _open : null,
        radius: radius,
        color: palette.background,
        glass: widget.glass,
        glassBlur: widget.glassBlur ?? hyperOs4.contentSurfaceBlur,
        glassOpacity: widget.glassOpacity ?? hyperOs4.contentSurfaceTintOpacity,
        showGlassSpecular: widget.showGlassSpecular,
        padding: const EdgeInsetsDirectional.fromSTEB(16, 11, 8, 11),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (widget.label != null)
                    Text(
                      widget.label!,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: palette.secondaryForeground,
                      ),
                    ),
                  Text(
                    hasSelection ? selectedText : widget.placeholder,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: widget.enabled
                          ? hasSelection
                                ? palette.foreground
                                : palette.secondaryForeground
                          : palette.disabledForeground,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.clearable && hasSelection && widget.enabled)
              MiuixIconButton(
                icon: MiuixThemedIcon(MiuixExtensionGlyphs.close),
                tooltip: '清除选择',
                onPressed: () {
                  _controller.clear();
                  _publish();
                },
              )
            else
              const Padding(
                padding: EdgeInsets.all(12),
                child: MiuixExtensionChevron(
                  direction: MiuixExtensionChevronDirection.down,
                ),
              ),
          ],
        ),
      ),
    );
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.arrowDown, alt: true):
            ActivateIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _open();
              return null;
            },
          ),
        },
        child: Focus(child: trigger),
      ),
    );
  }
}

class _MiuixSearchableSelectDialog<T extends Object> extends StatefulWidget {
  const _MiuixSearchableSelectDialog({
    required this.options,
    required this.initialSelected,
    required this.multiple,
    required this.maximumSelection,
    required this.searchHint,
    required this.emptyMessage,
    required this.optionFilter,
    required this.colors,
  });

  final List<MiuixSearchableSelectOption<T>> options;
  final Set<T> initialSelected;
  final bool multiple;
  final int? maximumSelection;
  final String searchHint;
  final String emptyMessage;
  final bool Function(MiuixSearchableSelectOption<T>, String)? optionFilter;
  final MiuixSearchableSelectColors? colors;

  @override
  State<_MiuixSearchableSelectDialog<T>> createState() =>
      _MiuixSearchableSelectDialogState<T>();
}

class _MiuixSearchableSelectDialogState<T extends Object>
    extends State<_MiuixSearchableSelectDialog<T>> {
  // Search-dialog keyboard contract:
  //
  // - The editable search field remains the primary focus owner.
  // - The same FocusNode intercepts option-navigation keys before text editing.
  // - Printable keys and horizontal cursor keys remain owned by EditableText.
  // - Arrow Down moves to the next enabled visible option.
  // - Arrow Up moves to the previous enabled visible option.
  // - Page Down advances by five enabled visible options.
  // - Page Up retreats by five enabled visible options.
  // - Movement clamps at collection boundaries instead of wrapping unexpectedly.
  // - A missing highlight enters from the directionally nearest boundary.
  // - Disabled rows remain visible but never become the keyboard target.
  // - Enter and numpad Enter activate the currently highlighted enabled row.
  // - Escape dismisses the dialog without publishing a selection result.
  // - Single selection completes and pops immediately after activation.
  // - Multiple selection toggles locally and keeps the search field focused.
  // - The OK action is the only multiple-selection commit boundary.
  // - The Cancel action and route dismissal discard the local selection draft.
  // - Highlight identity is stored by option value rather than list index.
  // - Filtering therefore retains a surviving logical option after reordering.
  // - A filtered-out highlight projects to the first enabled visible option.
  // - An empty or fully disabled result set clears the highlight.
  // - Pointer activation first synchronizes highlight, then follows selection.
  // - Selection and highlight use related but visibly distinct tint strengths.
  // - Semantics exposes selected and focused states independently.
  // - Search-field autofocus occurs only after the dialog's first layout frame.
  // - Navigator remains responsible for restoring the trigger focus on close.
  // - Pending autofocus checks mounted and canRequestFocus before requesting.
  // - Scroll work is also deferred until ListView dimensions are available.
  // - A highlighted row already inside the viewport does not move the list.
  // - A row above the viewport aligns its leading edge with the viewport.
  // - A row below the viewport aligns its trailing edge with the viewport.
  // - Scroll targets clamp to the controller's current legal extent.
  // - Reduced motion uses jumpTo and creates no autonomous animation frames.
  // - Ordinary motion uses the public HyperOS selection-surface duration.
  // - A zero theme duration is treated as an immediate jump.
  // - Repeated arrow keys retarget the active ScrollPosition safely.
  // - Disposing the dialog releases both FocusNode and ScrollController.
  // - The option snapshot remains owned by the exact dialog operation.
  // - Parent option replacement invalidates the result at the trigger boundary.
  // - A stale dialog can finish visually but cannot mutate a new controller.
  // - A stale dialog cannot publish through a replacement callback.
  // - Non-positive maximumSelection falls back to one in Release mode.
  // - Existing selected values can still be removed when already over a limit.
  // - Attempting another value at the limit leaves the draft unchanged.
  // - Query normalization remains case-insensitive unless a filter is supplied.
  // - Custom filtering receives the normalized lowercase trimmed query.
  // - Row animation keys combine stable value identity and motion policy.
  // - Runtime reduced motion discards an in-flight row-color midpoint.
  // - These rules apply to both SearchableSelect and ComboBox facades.
  // - Widget tests exercise disabled-first, filtering, commit, and focus return.
  // - Device tests remain necessary for physical keyboard and IME coexistence.
  late final Set<T> _selected = Set<T>.of(widget.initialSelected);
  final TextEditingController _query = TextEditingController();
  late final FocusNode _searchFocusNode;
  final ScrollController _optionsScrollController = ScrollController();
  T? _highlightedValue;

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode(
      debugLabel: 'MiuixSearchableSelect.search',
      onKeyEvent: _handleSearchKeyEvent,
    );
    final visible = _visibleOptions();
    _highlightedValue = visible
        .where((option) => option.enabled)
        .map((option) => option.value)
        .firstOrNull;
    // A keyboard-opened combo box must be ready for both typing and option
    // traversal without requiring a second Tab press. Delaying until layout
    // also keeps dialog route focus restoration under Navigator ownership.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _searchFocusNode.canRequestFocus) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  List<MiuixSearchableSelectOption<T>> _visibleOptions() =>
      widget.options.where(_matches).toList(growable: false);

  int? get _safeMaximumSelection {
    final maximum = widget.maximumSelection;
    if (maximum == null) return null;
    // The public constructor documents a positive limit, but Release builds do
    // not execute asserts. Falling back to one keeps an invalid persisted value
    // deterministic instead of silently making every unselected row inert.
    return maximum < 1 ? 1 : maximum;
  }

  void _normalizeHighlight(List<MiuixSearchableSelectOption<T>> visible) {
    final current = _highlightedValue;
    if (current != null &&
        visible.any((option) => option.enabled && option.value == current)) {
      return;
    }
    _highlightedValue = visible
        .where((option) => option.enabled)
        .map((option) => option.value)
        .firstOrNull;
  }

  void _handleQueryChanged(String _) {
    setState(() => _normalizeHighlight(_visibleOptions()));
    _scheduleHighlightedRowVisibility();
  }

  void _moveHighlight(int delta) {
    final visible = _visibleOptions();
    final enabled = visible.where((option) => option.enabled).toList();
    if (enabled.isEmpty) {
      if (_highlightedValue != null) setState(() => _highlightedValue = null);
      return;
    }
    final current = enabled.indexWhere(
      (option) => option.value == _highlightedValue,
    );
    final next = current < 0
        ? delta < 0
              ? enabled.length - 1
              : 0
        : (current + delta).clamp(0, enabled.length - 1);
    if (enabled[next].value == _highlightedValue) return;
    setState(() => _highlightedValue = enabled[next].value);
    _scheduleHighlightedRowVisibility();
  }

  void _scheduleHighlightedRowVisibility() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_optionsScrollController.hasClients) return;
      final visible = _visibleOptions();
      final index = visible.indexWhere(
        (option) => option.value == _highlightedValue,
      );
      if (index < 0) return;
      const rowExtent = MiuixSearchableSelectDefaults.rowExtent + 20;
      final position = _optionsScrollController.position;
      final rowTop = index * rowExtent;
      final rowBottom = rowTop + rowExtent;
      var target = position.pixels;
      if (rowTop < position.pixels) {
        target = rowTop;
      } else if (rowBottom > position.pixels + position.viewportDimension) {
        target = rowBottom - position.viewportDimension;
      }
      target = target.clamp(position.minScrollExtent, position.maxScrollExtent);
      if ((target - position.pixels).abs() <= .5) return;
      final reduceMotion = MediaQuery.disableAnimationsOf(context);
      final duration = MiuixTheme.of(context).hyperOs4.selectionSurfaceMotion;
      if (reduceMotion || duration <= Duration.zero) {
        _optionsScrollController.jumpTo(target);
      } else {
        _optionsScrollController.animateTo(
          target,
          duration: duration,
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  KeyEventResult _handleSearchKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _moveHighlight(1);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _moveHighlight(-1);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.pageDown) {
      _moveHighlight(5);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.pageUp) {
      _moveHighlight(-5);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter) {
      final visible = _visibleOptions();
      final option = visible
          .where(
            (candidate) =>
                candidate.enabled && candidate.value == _highlightedValue,
          )
          .firstOrNull;
      if (option == null) return KeyEventResult.ignored;
      _select(option);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.maybeOf(context)?.maybePop();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  bool _matches(MiuixSearchableSelectOption<T> option) {
    final query = _query.text.trim().toLowerCase();
    if (query.isEmpty) return true;
    return widget.optionFilter?.call(option, query) ??
        option.searchableText.toLowerCase().contains(query);
  }

  void _select(MiuixSearchableSelectOption<T> option) {
    if (!option.enabled) return;
    if (!widget.multiple) {
      Navigator.of(context).pop(<T>{option.value});
      MiuixHaptics.perform(MiuixHapticType.confirm);
      return;
    }
    setState(() {
      if (!_selected.remove(option.value)) {
        final maximum = _safeMaximumSelection;
        if (maximum == null || _selected.length < maximum) {
          _selected.add(option.value);
        }
      }
    });
    MiuixHaptics.perform(
      _selected.contains(option.value)
          ? MiuixHapticType.toggleOn
          : MiuixHapticType.toggleOff,
    );
  }

  @override
  void dispose() {
    _query.dispose();
    _searchFocusNode.dispose();
    _optionsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette =
        widget.colors ?? MiuixSearchableSelectDefaults.colors(context);
    final visible = _visibleOptions();
    _normalizeHighlight(visible);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final panel = SizedBox(
      height: MiuixSearchableSelectDefaults.dialogHeight(
        optionCount: visible.length,
        multiple: widget.multiple,
      ),
      child: Column(
        children: <Widget>[
          MiuixTextField(
            controller: _query,
            focusNode: _searchFocusNode,
            hint: widget.searchHint,
            singleLine: true,
            leadingIcon: MiuixThemedIcon(MiuixExtensionGlyphs.search),
            trailingIcon: _query.text.isEmpty
                ? null
                : MiuixIconButton(
                    icon: MiuixThemedIcon(MiuixExtensionGlyphs.close),
                    tooltip: '清除搜索',
                    onPressed: () => setState(_query.clear),
                  ),
            onChanged: _handleQueryChanged,
          ),
          const SizedBox(height: 10),
          Expanded(
            child: visible.isEmpty
                ? Center(
                    child: Text(
                      widget.emptyMessage,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: palette.secondaryForeground,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _optionsScrollController,
                    primary: false,
                    padding: EdgeInsets.zero,
                    itemCount: visible.length,
                    itemBuilder: (context, index) {
                      final option = visible[index];
                      final selected = _selected.contains(option.value);
                      final highlighted =
                          option.enabled && option.value == _highlightedValue;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: TweenAnimationBuilder<double>(
                          // A policy key discards an in-flight color sample
                          // when accessibility requests a direct endpoint.
                          // Stable option identity retains normal retargeting.
                          key: ValueKey<(T, bool)>((
                            option.value,
                            reduceMotion,
                          )),
                          tween: Tween<double>(
                            end: selected
                                ? 1
                                : highlighted
                                ? .38
                                : 0,
                          ),
                          duration: reduceMotion
                              ? Duration.zero
                              : hyperOs4.collectionRowMotion,
                          curve: Curves.easeOutCubic,
                          builder: (context, selectionProgress, _) {
                            final foreground = !option.enabled
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
                              selected: selected,
                              focused: highlighted,
                              child: MiuixSurface(
                                key: ValueKey<(String, T)>((
                                  'miuix-searchable-option',
                                  option.value,
                                )),
                                onTap: option.enabled
                                    ? () {
                                        setState(
                                          () =>
                                              _highlightedValue = option.value,
                                        );
                                        _select(option);
                                      }
                                    : null,
                                radius: hyperOs4.collectionRowCornerRadius,
                                color: background,
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                  12,
                                  8,
                                  12,
                                  8,
                                ),
                                child: SizedBox(
                                  height:
                                      MiuixSearchableSelectDefaults.rowExtent,
                                  child: Row(
                                    children: <Widget>[
                                      if (option.icon != null) ...<Widget>[
                                        IconTheme(
                                          data: IconThemeData(
                                            color: foreground,
                                          ),
                                          child: option.icon!,
                                        ),
                                        const SizedBox(width: 12),
                                      ],
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              option.label,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.copyWith(
                                                    color: foreground,
                                                    fontWeight: selected
                                                        ? FontWeight.w600
                                                        : null,
                                                  ),
                                            ),
                                            if (option.summary != null)
                                              Text(
                                                option.summary!,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: palette
                                                          .secondaryForeground,
                                                    ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      if (selected)
                                        MiuixThemedIcon(
                                          MiuixExtensionGlyphs.confirm,
                                          color: foreground,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
          if (widget.multiple) ...<Widget>[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                MiuixTextButton(
                  label: MaterialLocalizations.of(context).cancelButtonLabel,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 8),
                MiuixButton(
                  label: MaterialLocalizations.of(context).okButtonLabel,
                  filled: true,
                  onPressed: () {
                    Navigator.of(context).pop(Set<T>.of(_selected));
                    MiuixHaptics.perform(MiuixHapticType.confirm);
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
    // Filtering changes the desired content height. HyperOS motion keeps the
    // dialog anchored while its lower edge settles instead of teleporting.
    // Reduced motion deliberately skips the wrapper so a runtime policy
    // change cannot leave an AnimatedSize at an intermediate sample.
    if (reduceMotion) return panel;
    return AnimatedSize(
      key: const ValueKey('miuix-searchable-select-panel-size'),
      duration: hyperOs4.selectionSurfaceMotion,
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: panel,
    );
  }
}

/// Single-selection facade with familiar desktop combo-box semantics.
class MiuixComboBox<T extends Object> extends MiuixSearchableSelect<T> {
  /// Creates a single-selection searchable combo box.
  const MiuixComboBox({
    super.key,
    required super.options,
    super.controller,
    super.initialSelected = const [],
    super.label,
    super.placeholder,
    super.searchHint,
    super.emptyMessage,
    super.enabled,
    super.clearable,
    super.onChanged,
    super.optionFilter,
    super.glass,
    super.glassBlur,
    super.glassOpacity,
    super.showGlassSpecular,
    super.cornerRadius,
    super.colors,
  }) : super(multiple: false, maximumSelection: 1);

  /// Creates the combo-box facade with the former opaque trigger field.
  const MiuixComboBox.source({
    super.key,
    required super.options,
    super.controller,
    super.initialSelected = const [],
    super.label,
    super.placeholder,
    super.searchHint,
    super.emptyMessage,
    super.enabled,
    super.clearable,
    super.onChanged,
    super.optionFilter,
    super.colors,
  }) : super.source(multiple: false, maximumSelection: 1);
}
