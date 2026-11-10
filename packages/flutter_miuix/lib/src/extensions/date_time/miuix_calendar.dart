import '../../icons/miuix_icon_theme.dart';
import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../platform/miuix_haptics.dart';
import '../../theme/miuix_semantic_colors.dart';
import '../../theme/miuix_theme.dart';
import '../../widgets/miuix_widgets.dart';
import '../miuix_extension_icons.dart';

/// Selection policies supported by [MiuixCalendar].
enum MiuixCalendarSelectionMode {
  /// At most one date is selected.
  single,

  /// Every tap independently toggles one date.
  multiple,

  /// Two taps form an inclusive start/end interval.
  range,
}

/// Immutable inclusive calendar range.
@immutable
class MiuixDateRange {
  /// Creates a normalized range whose [start] never follows [end].
  MiuixDateRange(DateTime first, DateTime last)
    : start = MiuixCalendarController.dateOnly(
        first.isAfter(last) ? last : first,
      ),
      end = MiuixCalendarController.dateOnly(
        first.isAfter(last) ? first : last,
      );

  /// First selected day, inclusive.
  final DateTime start;

  /// Last selected day, inclusive.
  final DateTime end;

  /// Whether [date] is contained by this range.
  bool contains(DateTime date) {
    final day = MiuixCalendarController.dateOnly(date);
    return !day.isBefore(start) && !day.isAfter(end);
  }

  @override
  bool operator ==(Object other) =>
      other is MiuixDateRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);
}

/// Read-only snapshot emitted after calendar navigation or selection.
@immutable
class MiuixCalendarState {
  /// Creates a calendar snapshot.
  MiuixCalendarState({
    required DateTime visibleMonth,
    Iterable<DateTime> selectedDates = const <DateTime>[],
    this.selectedRange,
    this.rangeSelectionPending = false,
  }) : visibleMonth = DateTime(visibleMonth.year, visibleMonth.month),
       selectedDates = UnmodifiableSetView<DateTime>(
         selectedDates.map(MiuixCalendarController.dateOnly).toSet(),
       );

  /// Month currently displayed, normalized to its first day.
  final DateTime visibleMonth;

  /// Dates selected by single- or multiple-selection mode.
  final Set<DateTime> selectedDates;

  /// Completed or in-progress range selection.
  final MiuixDateRange? selectedRange;

  /// Whether [selectedRange] currently contains only the first endpoint.
  final bool rangeSelectionPending;
}

/// Controller that makes calendar navigation and selection externally usable.
class MiuixCalendarController extends ChangeNotifier {
  /// Creates a controller with optional initial state.
  MiuixCalendarController({
    DateTime? visibleMonth,
    Iterable<DateTime> selectedDates = const <DateTime>[],
    MiuixDateRange? selectedRange,
    bool rangeSelectionPending = false,
  }) : _visibleMonth = _monthOnly(visibleMonth ?? DateTime.now()),
       _selectedDates = selectedDates.map(dateOnly).toSet(),
       _selectedRange = selectedRange,
       _rangeSelectionPending = selectedRange != null && rangeSelectionPending;

  DateTime _visibleMonth;
  Set<DateTime> _selectedDates;
  MiuixDateRange? _selectedRange;
  // Range-phase contract:
  // - A one-day inclusive range can represent two different interaction phases.
  // - It may be the first endpoint while the user is still choosing an end date.
  // - It may also be a fully confirmed range whose start and end are the same day.
  // - Endpoint equality alone cannot distinguish those states without information loss.
  // - `_rangeSelectionPending` therefore stores that phase independently from dates.
  // - Constructor-provided ranges are completed unless callers explicitly opt in.
  // - The first direct range tap creates one day and marks endpoint selection pending.
  // - The second direct range tap completes and normalizes the inclusive interval.
  // - A tap after any completed range begins a fresh pending range at the tapped day.
  // - This applies equally after completed one-day and multi-day ranges.
  // - Calendar month navigation never changes the range phase or selected endpoints.
  // - `MiuixCalendarState` exposes the phase in the same immutable state snapshot.
  // - Date-range composites can ignore navigation notifications with unchanged phase.
  // - `setRange` updates dates and phase atomically under one controller notification.
  // - Passing null through `setRange` clears both endpoint data and pending phase.
  // - `clearSelection` clears single, multiple, range, and phase state together.
  // - Switching to single selection always ends any former range interaction.
  // - Switching to multiple selection likewise ends any former range interaction.
  // - Selected dates and selected ranges remain mutually exclusive state channels.
  // - All incoming endpoints are normalized to local calendar dates by MiuixDateRange.
  // - No UTC conversion is introduced while stripping time-of-day information.
  // - A completed one-day range survives unrelated visible-month controller changes.
  // - Re-selecting after that navigation starts a new range instead of extending stale data.
  // - State listeners can differentiate a real endpoint update from month-only movement.
  // - Existing consumers that inspect only `selectedRange` remain source-compatible.
  // - The new phase field defaults false for manually constructed calendar snapshots.
  // - Controller equality checks include both range value and pending phase.
  // - Reapplying the same complete range emits no redundant controller notification.
  // - Reapplying the same dates with a different phase is a meaningful state update.
  // - Visual range painting continues to depend only on normalized inclusive dates.
  // - Endpoint UI emphasis may additionally depend on the explicit pending phase.
  // - Accessibility labels continue to describe actual dates rather than internal phase.
  // - Dialog confirmation remains allowed after one pending endpoint as a one-day value.
  // - Confirming it converts the external result into a normal completed MiuixDateRange.
  // - These semantics hold across Android touch and Windows pointer interaction.
  bool _rangeSelectionPending;

  /// Removes time-of-day information without using a UTC conversion.
  static DateTime dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static DateTime _monthOnly(DateTime value) =>
      DateTime(value.year, value.month);

  /// Current immutable state.
  MiuixCalendarState get state => MiuixCalendarState(
    visibleMonth: _visibleMonth,
    selectedDates: _selectedDates,
    selectedRange: _selectedRange,
    rangeSelectionPending: _rangeSelectionPending,
  );

  /// Month currently displayed.
  DateTime get visibleMonth => _visibleMonth;

  /// Moves to an arbitrary month.
  void showMonth(DateTime month) {
    final normalized = _monthOnly(month);
    if (normalized == _visibleMonth) return;
    _visibleMonth = normalized;
    notifyListeners();
  }

  /// Moves by [delta] calendar months.
  void addMonths(int delta) =>
      showMonth(DateTime(_visibleMonth.year, _visibleMonth.month + delta));

  /// Clears every selection channel.
  void clearSelection() {
    if (_selectedDates.isEmpty && _selectedRange == null) return;
    _selectedDates = <DateTime>{};
    _selectedRange = null;
    _rangeSelectionPending = false;
    notifyListeners();
  }

  /// Replaces an inclusive range and its explicit endpoint-selection phase.
  void setRange(MiuixDateRange? range, {bool selectingEnd = false}) {
    final pending = range != null && selectingEnd;
    if (_selectedDates.isEmpty &&
        _selectedRange == range &&
        _rangeSelectionPending == pending) {
      return;
    }
    _selectedDates = <DateTime>{};
    _selectedRange = range;
    _rangeSelectionPending = pending;
    notifyListeners();
  }

  /// Applies a user selection according to [mode].
  void select(DateTime value, MiuixCalendarSelectionMode mode) {
    final date = dateOnly(value);
    switch (mode) {
      case MiuixCalendarSelectionMode.single:
        _selectedDates = <DateTime>{date};
        _selectedRange = null;
        _rangeSelectionPending = false;
      case MiuixCalendarSelectionMode.multiple:
        _selectedRange = null;
        _rangeSelectionPending = false;
        _selectedDates = Set<DateTime>.of(_selectedDates);
        if (!_selectedDates.remove(date)) _selectedDates.add(date);
      case MiuixCalendarSelectionMode.range:
        _selectedDates = <DateTime>{};
        final current = _selectedRange;
        if (current == null || !_rangeSelectionPending) {
          _selectedRange = MiuixDateRange(date, date);
          _rangeSelectionPending = true;
        } else {
          _selectedRange = MiuixDateRange(current.start, date);
          _rangeSelectionPending = false;
        }
    }
    notifyListeners();
  }
}

/// Theme colors for [MiuixCalendar].
@immutable
class MiuixCalendarColors {
  /// Creates a complete calendar palette.
  const MiuixCalendarColors({
    required this.background,
    required this.foreground,
    required this.secondaryForeground,
    required this.selectedBackground,
    required this.selectedForeground,
    required this.rangeBackground,
    required this.disabledForeground,
    this.rangeForeground,
  });

  /// Calendar surface.
  final Color background;

  /// Primary date and month text.
  final Color foreground;

  /// Weekday and out-of-month text.
  final Color secondaryForeground;

  /// Selected day fill.
  final Color selectedBackground;

  /// Selected day text.
  final Color selectedForeground;

  /// Interior range fill.
  final Color rangeBackground;

  /// Text used by dates inside a selected interval.
  final Color? rangeForeground;

  /// Disabled day text.
  final Color disabledForeground;
}

/// Geometry and color defaults for calendar extensions.
abstract final class MiuixCalendarDefaults {
  /// Height and width of one compact day target.
  ///
  /// Slightly taller than the original 44 so apps can overlay a lunar
  /// subtitle without clipping the day number.
  static const double dayExtent = 56;

  /// Continuous corner used by the calendar panel.
  static const double cornerRadius = 24;

  /// Resolves light, dark, and dynamic MIUIX semantic roles.
  static MiuixCalendarColors colors(BuildContext context) {
    final semantic = MiuixSemanticColors.of(context);
    return MiuixCalendarColors(
      background: semantic['surfaceVariant'],
      foreground: semantic['onSurface'],
      secondaryForeground: semantic['onSurfaceSecondary'],
      selectedBackground: semantic['primary'],
      selectedForeground: semantic['onPrimary'],
      rangeBackground: semantic['tertiaryContainer'],
      rangeForeground: semantic['onTertiaryContainer'],
      disabledForeground: semantic['disabledOnSurface'],
    );
  }
}

/// Month calendar extension with MIUIX styling, motion, and haptics.
///
/// This is intentionally documented as a flutter_miuix extension because the
/// current upstream component catalog does not publish a standalone calendar.
/// The widget remains controlled when [controller] is supplied and owns a
/// private controller otherwise.
class MiuixCalendar extends StatefulWidget {
  /// Creates a month calendar.
  const MiuixCalendar({
    super.key,
    this.controller,
    this.initialVisibleMonth,
    this.initialSelectedDate,
    this.selectionMode = MiuixCalendarSelectionMode.single,
    this.firstWeekday = DateTime.monday,
    this.minimumDate,
    this.maximumDate,
    this.selectableDayPredicate,
    this.onChanged,
    this.colors,
    this.showAdjacentMonthDays = true,
    this.showHeader = true,
    this.glass = true,
    this.cornerRadius,
    this.glassBlur,
    this.glassOpacity,
    this.dayAdornmentBuilder,
    this.dayForegroundBuilder,
    this.dayBackgroundBuilder,
    this.monthHeaderBuilder,
    this.hyperOsDayStyles = true,
    this.dayExtent,
    this.dayCornerRadius = 22,
    this.dayMargin = EdgeInsets.zero,
    this.dayHighlightMargin,
    this.fullCellSelection = false,
    this.dayNumberAlignment = Alignment.center,
  });

  /// Optional externally owned controller.
  final MiuixCalendarController? controller;

  /// Initial month used only by the internally owned controller.
  final DateTime? initialVisibleMonth;

  /// Initial single selection used only by the internal controller.
  final DateTime? initialSelectedDate;

  /// Selection behavior.
  final MiuixCalendarSelectionMode selectionMode;

  /// First weekday using [DateTime.monday] through [DateTime.sunday].
  ///
  /// Values outside that interval are wrapped into the seven-day cycle. This
  /// keeps Debug and Release behavior identical when a persisted preference or
  /// a platform calendar setting supplies an unchecked integer.
  final int firstWeekday;

  /// Earliest selectable day.
  final DateTime? minimumDate;

  /// Latest selectable day.
  final DateTime? maximumDate;

  /// Additional application-specific availability rule.
  final bool Function(DateTime date)? selectableDayPredicate;

  /// Called after navigation and selection changes.
  final ValueChanged<MiuixCalendarState>? onChanged;

  /// Optional palette override.
  final MiuixCalendarColors? colors;

  /// Whether leading and trailing cells show adjacent month dates.
  final bool showAdjacentMonthDays;

  /// Whether month navigation is displayed.
  final bool showHeader;

  /// Whether the calendar samples the content behind its local panel.
  final bool glass;

  /// Optional panel geometry and material overrides.
  final double? cornerRadius;
  final double? glassBlur;
  final double? glassOpacity;

  /// Optional application-owned badges rendered above the standard day cell.
  ///
  /// The returned widget is visual-only and cannot intercept calendar input.
  final MiuixCalendarDayAdornmentBuilder? dayAdornmentBuilder;

  /// Optional override for the day-number color (weekends, festivals, …).
  ///
  /// Returning null keeps the built-in selected / disabled / in-month rules.
  final Color? Function(
    DateTime date,
    bool selected,
    bool enabled,
    bool inMonth,
  )?
  dayForegroundBuilder;

  /// Optional per-day cell fill (holiday tint, make-up workday gray, …).
  ///
  /// Returning null keeps the built-in HyperOS today/selection paints.
  final Color? Function(
    DateTime date, {
    required bool selected,
    required bool enabled,
    required bool inMonth,
    required bool isToday,
  })?
  dayBackgroundBuilder;

  /// Optional custom month header (e.g. "9月 · 9天前").
  final Widget Function(BuildContext context, DateTime month)?
  monthHeaderBuilder;

  /// HyperOS/Xiaomi day paints: today = solid primary, selected = outline.
  ///
  /// When false the calendar keeps the older solid-primary selected circle.
  final bool hyperOsDayStyles;

  /// Optional row height for compact pickers; defaults to the lunar-friendly
  /// calendar height. Bounded hosts may shrink rows down to a 44dp target.
  final double? dayExtent;

  /// Optional insets for HyperOS today/selected emphasis only.
  /// Allows the emphasis to contain a number and lunar label while leaving
  /// room for corner badges and record dots. Holiday fills use [dayMargin].
  /// Null or invalid values preserve the full-cell highlight. Range painting
  /// remains connected and does not use this single-day emphasis.
  final EdgeInsets? dayHighlightMargin;

  /// Select the entire day with a tinted outline and emphasize today by text.
  /// Opt-in for calendars with badges/lunar labels inside the date tile.
  /// Range selection keeps its connected geometry; [dayHighlightMargin] is
  /// ignored in this mode. The paint fills the column, inset by [dayMargin].
  final bool fullCellSelection;

  /// Number position within the day, independent of decoration and hit bounds.
  final AlignmentGeometry dayNumberAlignment;

  /// Corner radius of an individual day background, including holiday fills.
  /// Connected range endpoints retain their range geometry.
  final double dayCornerRadius;

  /// Insets of the painted day background within its full-size touch target.
  /// Horizontal insets are ignored for connected range selections.
  final EdgeInsets dayMargin;

  @override
  State<MiuixCalendar> createState() => _MiuixCalendarState();
}

class _MiuixCalendarState extends State<MiuixCalendar> {
  // Visible-month range ownership contract:
  // - Date bounds constrain navigation as well as individual day selection.
  // - Both endpoints are interpreted as local calendar dates.
  // - Their time-of-day fields never affect the first or last visible month.
  // - Reversed endpoints are accepted and sorted like other range controls.
  // - A missing endpoint leaves navigation open in that direction.
  // - Initial internal state is normalized before the first rendered frame.
  // - An external controller is corrected before this widget begins listening.
  // - That attachment correction does not synthesize widget onChanged output.
  // - Later external showMonth calls are normalized through the same function.
  // - One guard absorbs the controller's nested correction notification.
  // - The outer notification then publishes exactly one final calendar state.
  // - Dynamic bounds reuse the existing controller instead of replacing it.
  // - A bounds update clamps only when the visible month actually became stale.
  // - Selected dates and range-selection phase remain controller-owned.
  // - Reaching the first month disables only backward navigation.
  // - Reaching the last month disables only forward navigation.
  // - A one-month interval disables both navigation actions.
  // - Disabled navigation performs neither controller writes nor haptics.
  // - Header buttons, drag release, and programmatic updates share one clamp.
  // - Horizontal gesture ownership therefore cannot bypass date constraints.
  // - Month comparison uses canonical first-of-month DateTime values.
  // - No elapsed-duration or UTC conversion is introduced by normalization.
  // - The visible grid can still show adjacent dates outside the interval.
  // - Those adjacent cells remain disabled through the existing day predicate.
  // - Reduced motion changes animation timing, never the resolved month.
  // - Controller replacement detaches the old listener before normalization.
  // - Caller-owned controllers are observed and corrected but never disposed.
  // - Internally owned controllers remain disposed with the widget State.
  // - Tests cover initial, external, first-month, and last-month behavior.
  // - Physical swipe behavior still requires Android and Windows runtime checks.
  // Calendar accessibility contract at the same boundary:
  // - An unavailable previous or next month exposes no button action callback.
  // - The existing tooltip remains the localized accessible action name.
  // - Day nodes continue exposing full localized dates instead of bare numbers.
  // - Range interior days retain selected semantics as an inclusive interval.
  // - Disabled adjacent days keep their nodes readable but non-actionable.
  // - Range correction never moves accessibility focus to a hidden month itself.
  // - Rebuilds retain the same controller identity for assistive technologies.
  // - Header animation keys use the final canonical visible month.
  // - A programmatic invalid month cannot leave stale enabled header actions.
  // - A valid controller notification retains its ordinary single rebuild path.
  late MiuixCalendarController _controller;
  late bool _ownsController;
  bool _normalizingVisibleMonth = false;
  // Keyboard interaction uses one focus node around the complete grid rather
  // than forty-two independent nodes. This keeps Tab traversal concise while
  // arrow keys still expose a focused day through child semantics.
  // Detailed month-grid keyboard and accessibility invariants:
  // - The calendar surface is the sole grid-level hardware-keyboard stop.
  // - Header navigation buttons remain independent ordinary button stops.
  // - Entering the grid never chooses a date as a side effect.
  // - The first key movement resolves an anchor only when one is required.
  // - An already focused enabled date remains the preferred anchor.
  // - A selected range uses its ending endpoint as the preferred anchor.
  // - A single or multiple selection uses an enabled selected date.
  // - Selection-set iteration never deliberately chooses a disabled anchor.
  // - An anchor from another month is ignored for the visible grid.
  // - The fallback scans only the finite days of the visible month.
  // - The fallback never crosses into a later month for availability.
  // - A disabled first day advances only within that same month.
  // - A completely disabled month yields no keyboard anchor.
  // - A completely disabled month also rejects focus requests.
  // - Pointer and semantics nodes remain readable in a disabled month.
  // - Arrow Left is chronological previous in left-to-right layouts.
  // - Arrow Right is chronological next in left-to-right layouts.
  // - Both horizontal meanings reverse in right-to-left layouts.
  // - Vertical arrows always retain chronological row order.
  // - Arrow Up subtracts seven local calendar days.
  // - Arrow Down adds seven local calendar days.
  // - Calendar constructors move days across month boundaries.
  // - No UTC conversion is introduced for local-date navigation.
  // - A direct disabled arrow target stops movement immediately.
  // - The calendar does not skip an unknown run of disabled days.
  // - That bounded policy prevents surprising availability jumps.
  // - Crossing a month boundary updates focus and visible month.
  // - The candidate month passes through normalized bounds first.
  // - An out-of-range candidate cannot be rescued into another day.
  // - Accepted day movement emits one segment-tick haptic.
  // - Rejected day movement emits no write and no haptic.
  // - Page Up requests the same day in the previous month.
  // - Page Down requests the same day in the next month.
  // - Shorter target months clamp to their final local day.
  // - A clamped page target must still pass the day predicate.
  // - A rejected page target leaves focus and month unchanged.
  // - Accepted page movement uses the month-move haptic role.
  // - Page movement publishes the normal navigation callback once.
  // - Direction movement changes only the ephemeral focus anchor.
  // - Direction movement never mutates selectedDates by itself.
  // - Direction movement never mutates selectedRange by itself.
  // - Enter selects the resolved anchor through normal policy.
  // - Space selects the resolved anchor through the same path.
  // - Single mode replaces the controller's selected-date set.
  // - Multiple mode toggles the focused date through the controller.
  // - Range mode starts or completes the explicit endpoint phase.
  // - Keyboard activation uses the pointer confirmation haptic.
  // - Pointer activation requests focus before publishing selection.
  // - The pointer date becomes the keyboard anchor in that action.
  // - Disabled pointer cells still expose no tap callback.
  // - Adjacent-month cells focus only when rendered and enabled.
  // - The focused semantic flag belongs to one rendered day.
  // - It appears only while the composite FocusNode has focus.
  // - Selection and focus remain separate semantic concepts.
  // - Moving focus never clears the selected semantic flag.
  // - A selected day may remain selected while another is focused.
  // - Full localized dates remain every cell's semantic label.
  // - Bare numerals remain visual descendants of that label.
  // - Header tooltips retain localized month-action names.
  // - Bound-disabled header buttons expose no action callback.
  // - Keyboard Page actions obey the same header bounds.
  // - External month writes can invalidate the prior focus anchor.
  // - Such invalidation resolves lazily on the next key action.
  // - Lazy resolution avoids unsolicited assistive-focus movement.
  // - Controller selection can establish a new preferred anchor.
  // - Controller replacement retains the single FocusNode identity.
  // - Replacement never disposes a caller-owned controller.
  // - Widget disposal always disposes its private FocusNode.
  // - Focus disposal follows controller-listener detachment.
  // - Rebuilds read text direction before rebuilding shortcuts.
  // - Runtime direction changes therefore update key meanings.
  // - Reduced motion changes visuals but not shortcut outcomes.
  // - Keyboard focus is intentionally absent from persisted state.
  // - Tests cover disabled direct movement without scanning.
  // - Tests cover focus-only row movement before activation.
  // - Tests cover Enter selection after focus movement.
  // - Tests cover Page Down before Space activation.
  // - Tests cover right-to-left horizontal mirroring.
  // - Runtime checks remain required for focus-ring appearance.
  // - Runtime checks remain required for physical haptic feel.
  // - These are behavior rules, not unpublished Xiaomi metrics.
  final FocusNode _focusNode = FocusNode(debugLabel: 'MiuixCalendar');
  DateTime? _keyboardDate;
  DateTime? _pressedDay;

  /// Normalizes arbitrary public input to DateTime's Monday-through-Sunday
  /// numbering without relying on constructor assertions.
  int get _safeFirstWeekday =>
      ((widget.firstWeekday - DateTime.monday) % 7) + DateTime.monday;

  ({DateTime? minimum, DateTime? maximum}) get _monthBounds {
    var minimum = widget.minimumDate == null
        ? null
        : MiuixCalendarController._monthOnly(widget.minimumDate!);
    var maximum = widget.maximumDate == null
        ? null
        : MiuixCalendarController._monthOnly(widget.maximumDate!);
    if (minimum != null && maximum != null && minimum.isAfter(maximum)) {
      final swap = minimum;
      minimum = maximum;
      maximum = swap;
    }
    return (minimum: minimum, maximum: maximum);
  }

  DateTime _clampVisibleMonth(DateTime candidate) {
    final month = MiuixCalendarController._monthOnly(candidate);
    final bounds = _monthBounds;
    if (bounds.minimum case final minimum? when month.isBefore(minimum)) {
      return minimum;
    }
    if (bounds.maximum case final maximum? when month.isAfter(maximum)) {
      return maximum;
    }
    return month;
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
        MiuixCalendarController(
          visibleMonth: widget.initialVisibleMonth,
          selectedDates: widget.initialSelectedDate == null
              ? const <DateTime>[]
              : <DateTime>[widget.initialSelectedDate!],
        );
    // Range limits constrain navigation as well as individual day taps. Apply
    // them before attaching this widget's listener so the first frame never
    // exposes an unreachable month or publishes a synthetic onChanged event.
    _controller.showMonth(_clampVisibleMonth(_controller.visibleMonth));
    _controller.addListener(_handleControllerChanged);
  }

  DateTime? _firstEnabledDateInMonth(DateTime month) {
    final dayCount = DateTime(month.year, month.month + 1, 0).day;
    for (var day = 1; day <= dayCount; day++) {
      final candidate = DateTime(month.year, month.month, day);
      if (_isEnabled(candidate)) return candidate;
    }
    return null;
  }

  DateTime? _resolvedKeyboardDate() {
    final month = _controller.visibleMonth;
    final current = _keyboardDate;
    if (current != null &&
        current.year == month.year &&
        current.month == month.month &&
        _isEnabled(current)) {
      return current;
    }
    final state = _controller.state;
    final selected = switch (widget.selectionMode) {
      MiuixCalendarSelectionMode.range => state.selectedRange?.end,
      _ => state.selectedDates.where(_isEnabled).firstOrNull,
    };
    if (selected != null &&
        selected.year == month.year &&
        selected.month == month.month &&
        _isEnabled(selected)) {
      return selected;
    }
    return _firstEnabledDateInMonth(month);
  }

  void _moveKeyboardByDays(int delta) {
    final current = _resolvedKeyboardDate();
    if (current == null) return;
    final candidate = DateTime(
      current.year,
      current.month,
      current.day + delta,
    );
    if (!_isEnabled(candidate)) return;
    final targetMonth = _clampVisibleMonth(candidate);
    if (targetMonth.year != candidate.year ||
        targetMonth.month != candidate.month) {
      return;
    }
    setState(() => _keyboardDate = candidate);
    if (targetMonth != _controller.visibleMonth) {
      _controller.showMonth(targetMonth);
    }
    MiuixHaptics.perform(MiuixHapticType.segmentTick);
  }

  void _moveKeyboardByMonths(int delta) {
    final current = _resolvedKeyboardDate();
    if (current == null) return;
    final requestedMonth = DateTime(current.year, current.month + delta);
    final targetMonth = _clampVisibleMonth(requestedMonth);
    if (targetMonth == _controller.visibleMonth) return;
    final targetDay = math.min(
      current.day,
      DateTime(targetMonth.year, targetMonth.month + 1, 0).day,
    );
    final candidate = DateTime(targetMonth.year, targetMonth.month, targetDay);
    if (!_isEnabled(candidate)) return;
    setState(() => _keyboardDate = candidate);
    _controller.showMonth(targetMonth);
    MiuixHaptics.perform(MiuixHapticType.textHandleMove);
  }

  void _selectKeyboardDate() {
    final date = _resolvedKeyboardDate();
    if (date == null) return;
    setState(() => _keyboardDate = date);
    _select(date);
  }

  void _activateDay(DateTime date) {
    if (!_isEnabled(date)) return;
    _focusNode.requestFocus();
    setState(() => _keyboardDate = date);
    _select(date);
  }

  @override
  void didUpdateWidget(MiuixCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _controller.removeListener(_handleControllerChanged);
      if (_ownsController) _controller.dispose();
      _attachController();
      return;
    }
    if (oldWidget.minimumDate != widget.minimumDate ||
        oldWidget.maximumDate != widget.maximumDate) {
      final safeMonth = _clampVisibleMonth(_controller.visibleMonth);
      if (safeMonth != _controller.visibleMonth) {
        _controller.showMonth(safeMonth);
      }
    }
  }

  void _handleControllerChanged() {
    if (!mounted) return;
    if (_normalizingVisibleMonth) return;
    final safeMonth = _clampVisibleMonth(_controller.visibleMonth);
    if (safeMonth != _controller.visibleMonth) {
      // Externally owned controllers remain legal when applications restore a
      // stale month. Suppress the nested notification and publish one final,
      // range-valid state to this widget's callback below.
      _normalizingVisibleMonth = true;
      try {
        _controller.showMonth(safeMonth);
      } finally {
        _normalizingVisibleMonth = false;
      }
    }
    setState(() {});
    widget.onChanged?.call(_controller.state);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChanged);
    if (_ownsController) _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool _isEnabled(DateTime date) {
    final day = MiuixCalendarController.dateOnly(date);
    var minimum = widget.minimumDate == null
        ? null
        : MiuixCalendarController.dateOnly(widget.minimumDate!);
    var maximum = widget.maximumDate == null
        ? null
        : MiuixCalendarController.dateOnly(widget.maximumDate!);
    if (minimum != null && maximum != null && minimum.isAfter(maximum)) {
      final swap = minimum;
      minimum = maximum;
      maximum = swap;
    }
    if (minimum != null && day.isBefore(minimum)) return false;
    if (maximum != null && day.isAfter(maximum)) return false;
    return widget.selectableDayPredicate?.call(day) ?? true;
  }

  bool _isSelected(DateTime date) {
    final state = _controller.state;
    return state.selectedDates.contains(date) ||
        (state.selectedRange?.contains(date) ?? false);
  }

  bool _isRangeInterior(DateTime date) {
    final range = _controller.state.selectedRange;
    return range != null &&
        date.isAfter(range.start) &&
        date.isBefore(range.end);
  }

  void _select(DateTime date) {
    if (!_isEnabled(date)) return;
    _controller.select(date, widget.selectionMode);
    MiuixHaptics.perform(MiuixHapticType.confirm);
  }

  void _moveMonth(int delta) {
    final current = _controller.visibleMonth;
    final target = _clampVisibleMonth(
      DateTime(current.year, current.month + delta),
    );
    if (target == current) return;
    _controller.showMonth(target);
    MiuixHaptics.perform(MiuixHapticType.textHandleMove);
  }

  bool _canMoveMonth(int delta) {
    final current = _controller.visibleMonth;
    return _clampVisibleMonth(DateTime(current.year, current.month + delta)) !=
        current;
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors ?? MiuixCalendarDefaults.colors(context);
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final month = _controller.visibleMonth;
    final localizations = MaterialLocalizations.of(context);
    final weekdays = localizations.narrowWeekdays;
    final firstWeekday = _safeFirstWeekday;
    final orderedWeekdays = List<String>.generate(7, (index) {
      // Flutter stores narrow weekdays Sunday-first while DateTime is
      // Monday-first; modulo conversion preserves localized labels.
      final dateWeekday = (firstWeekday - 1 + index) % 7 + 1;
      final sundayFirstIndex = dateWeekday % 7;
      return weekdays[sundayFirstIndex];
    });
    final firstOffset = (month.weekday - firstWeekday + 7) % 7;
    final gridStart = month.subtract(Duration(days: firstOffset));
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final lastDay = DateTime(month.year, month.month, daysInMonth);
    final lastOffset = (lastDay.weekday - firstWeekday + 7) % 7;
    final trailingDays = 6 - lastOffset;
    final coveredDays = firstOffset + daysInMonth + trailingDays;
    // Only render weeks that include at least one day of the visible month.
    // A trailing week that is entirely next month is dropped (Xiaomi calendar).
    final gridCellCount = ((coveredDays + 6) ~/ 7) * 7;

    // 按实际字形与系统缩放测量，不能用固定日期格挤压双位数。
    final scaler = MediaQuery.textScalerOf(context);
    final numberStyle = DefaultTextStyle.of(context).style.merge(
      Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
    );
    Size textSize(
      String value,
      TextStyle style, {
      double width = double.infinity,
    }) {
      final painter = TextPainter(
        text: TextSpan(text: value, style: style),
        textDirection: Directionality.of(context),
        textScaler: scaler,
      )..layout(maxWidth: width);
      return painter.size;
    }

    final numberSize = textSize('30', numberStyle);
    final weekStyle = DefaultTextStyle.of(
      context,
    ).style.merge(Theme.of(context).textTheme.labelMedium);
    final weekdayHeight = math.max(
      32.0,
      textSize(orderedWeekdays.join(), weekStyle).height + 8,
    );
    // 大字号无法铺满七列时横向阅读，表头与格子始终一起移动。
    // 月份标题与导航按钮留在外层，仍能随时切月。
    Widget readableGrid(double width, Widget child) => LayoutBuilder(
      builder: (context, constraints) {
        final grid = SizedBox(width: width, child: child);
        return width > constraints.maxWidth + .1
            ? SingleChildScrollView(
                key: const ValueKey('calendar-readable-grid'),
                scrollDirection: Axis.horizontal,
                child: grid,
              )
            : grid;
      },
    );

    Widget content(double cellExtent, double gridWidth) => Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (widget.showHeader)
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Row(
              children: <Widget>[
                MiuixIconButton(
                  tooltip: localizations.previousMonthTooltip,
                  onPressed: _canMoveMonth(-1) ? () => _moveMonth(-1) : null,
                  icon: MiuixThemedIcon(MiuixExtensionGlyphs.chevronBackward),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: reduceMotion
                        ? Duration.zero
                        : hyperOs4.pickerStageMotion,
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: Builder(
                      key: ValueKey<DateTime>(month),
                      builder: (context) {
                        if (widget.monthHeaderBuilder case final builder?) {
                          return builder(context, month);
                        }
                        return Text(
                          localizations.formatMonthYear(month),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: colors.foreground,
                                fontWeight: FontWeight.w600,
                              ),
                        );
                      },
                    ),
                  ),
                ),
                MiuixIconButton(
                  tooltip: localizations.nextMonthTooltip,
                  onPressed: _canMoveMonth(1) ? () => _moveMonth(1) : null,
                  icon: MiuixThemedIcon(MiuixExtensionGlyphs.chevronForward),
                ),
              ],
            ),
          ),
        readableGrid(
          gridWidth,
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: orderedWeekdays
                    .map(
                      (label) => Expanded(
                        child: SizedBox(
                          height: weekdayHeight,
                          child: Center(
                            child: Text(
                              label,
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(color: colors.secondaryForeground),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              GridView.builder(
                // A nested calendar must not consume the route's status/navigation
                // padding. Without an explicit zero value, GridView can inherit the
                // primary scroll view and insert a large blank band above row one.
                padding: EdgeInsets.zero,
                primary: false,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisExtent: cellExtent,
                ),
                itemCount: gridCellCount,
                itemBuilder: (context, index) {
                  final date = gridStart.add(Duration(days: index));
                  final inMonth =
                      date.year == month.year && date.month == month.month;
                  final enabled =
                      _isEnabled(date) &&
                      (inMonth || widget.showAdjacentMonthDays);
                  final selected = _isSelected(date);
                  final isToday =
                      MiuixCalendarController.dateOnly(DateTime.now()) ==
                      MiuixCalendarController.dateOnly(date);
                  final rangeInterior = _isRangeInterior(date);
                  final range = _controller.state.selectedRange;
                  final rangeSelected = range?.contains(date) ?? false;
                  final completedRange =
                      range != null && range.start != range.end;
                  final rangeStart = completedRange && range.start == date;
                  final rangeEnd = completedRange && range.end == date;
                  final fullCell = widget.fullCellSelection && !rangeSelected;
                  final BorderRadiusGeometry dayRadius = rangeInterior
                      ? BorderRadius.zero
                      : rangeStart
                      ? const BorderRadiusDirectional.only(
                          topStart: Radius.circular(22),
                          bottomStart: Radius.circular(22),
                        )
                      : rangeEnd
                      ? const BorderRadiusDirectional.only(
                          topEnd: Radius.circular(22),
                          bottomEnd: Radius.circular(22),
                        )
                      : BorderRadius.circular(widget.dayCornerRadius);
                  final Color? customDayFill = widget.dayBackgroundBuilder
                      ?.call(
                        date,
                        selected: selected,
                        enabled: enabled,
                        inMonth: inMonth,
                        isToday: isToday,
                      );
                  final Color dayFill;
                  final BoxBorder? dayBorder;
                  if (rangeInterior) {
                    dayFill = colors.rangeBackground;
                    dayBorder = null;
                  } else if (rangeStart || rangeEnd) {
                    // 区间端点保持实心，单日选择仍使用 HyperOS 描边。
                    // Range endpoints remain solid; single-day selection is outlined.
                    dayFill = colors.selectedBackground;
                    dayBorder = null;
                  } else if (fullCell) {
                    final tint = colors.selectedBackground.withValues(
                      alpha: _pressedDay == date
                          ? .18
                          : selected
                          ? .10
                          : 0,
                    );
                    dayFill = Color.alphaBlend(
                      tint,
                      customDayFill ?? Colors.transparent,
                    );
                    dayBorder = Border.all(
                      color: selected
                          ? colors.selectedBackground
                          : Colors.transparent,
                      width: 1.8,
                    );
                  } else if (!widget.hyperOsDayStyles) {
                    dayFill = selected
                        ? colors.selectedBackground
                        : Colors.transparent;
                    dayBorder = null;
                  } else if (customDayFill != null) {
                    // Holiday / workday cells keep their tint; selection becomes a
                    // primary outline so today's solid chip remains unique.
                    dayFill = customDayFill;
                    dayBorder = selected && !isToday
                        ? Border.all(
                            color: colors.selectedBackground,
                            width: 1.8,
                          )
                        : null;
                  } else if (isToday) {
                    dayFill = colors.selectedBackground;
                    dayBorder = null;
                  } else if (selected) {
                    dayFill = Colors.transparent;
                    dayBorder = Border.all(
                      color: colors.selectedBackground,
                      width: 1.8,
                    );
                  } else {
                    dayFill = Colors.transparent;
                    dayBorder = null;
                  }
                  final builtInForeground = !enabled
                      ? colors.disabledForeground
                      : rangeInterior
                      ? colors.rangeForeground ?? colors.foreground
                      : widget.hyperOsDayStyles
                      ? (isToday ||
                                (selected && customDayFill != null && isToday)
                            ? colors.selectedForeground
                            : selected
                            ? colors.selectedBackground
                            : isToday
                            ? colors.selectedForeground
                            : inMonth
                            ? colors.foreground
                            : colors.secondaryForeground)
                      : selected
                      ? colors.selectedForeground
                      : inMonth
                      ? colors.foreground
                      : colors.secondaryForeground;
                  // HyperOS: today always reads as white-on-primary; selected
                  // non-today keeps a dark number inside the outline.
                  final hyperOsForeground = widget.hyperOsDayStyles
                      ? (isToday
                            ? colors.selectedForeground
                            : selected
                            ? colors.selectedBackground
                            : inMonth
                            ? colors.foreground
                            : colors.secondaryForeground)
                      : null;
                  final foreground = fullCell
                      ? !enabled
                            ? colors.disabledForeground
                            : isToday
                            ? colors.selectedBackground
                            : widget.dayForegroundBuilder?.call(
                                    date,
                                    selected,
                                    enabled,
                                    inMonth,
                                  ) ??
                                  (selected
                                      ? colors.selectedBackground
                                      : inMonth
                                      ? colors.foreground
                                      : colors.secondaryForeground)
                      : (rangeStart || rangeEnd) && enabled
                      ? colors.selectedForeground
                      : rangeInterior && enabled
                      ? colors.rangeForeground ?? colors.foreground
                      : (enabled && !selected && !isToday
                                ? widget.dayForegroundBuilder?.call(
                                    date,
                                    selected,
                                    enabled,
                                    inMonth,
                                  )
                                : null) ??
                            hyperOsForeground ??
                            builtInForeground;
                  final highlightMargin = widget.dayHighlightMargin;
                  final separateHighlight =
                      !fullCell &&
                      widget.hyperOsDayStyles &&
                      !rangeSelected &&
                      highlightMargin != null &&
                      highlightMargin.isNonNegative &&
                      highlightMargin.horizontal.isFinite &&
                      highlightMargin.vertical.isFinite;
                  return Semantics(
                    button: true,
                    selected: selected,
                    focused:
                        _focusNode.hasFocus &&
                        _keyboardDate != null &&
                        date == _keyboardDate,
                    enabled: enabled,
                    label: localizations.formatFullDate(date),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: enabled ? () => _activateDay(date) : null,
                      onTapDown: enabled && fullCell
                          ? (_) => setState(() => _pressedDay = date)
                          : null,
                      onTapUp: enabled && fullCell
                          ? (_) => setState(() => _pressedDay = null)
                          : null,
                      onTapCancel: enabled && fullCell
                          ? () => setState(() => _pressedDay = null)
                          : null,
                      child: LayoutBuilder(
                        builder: (context, constraints) => Center(
                          child: SizedBox(
                            width: rangeSelected || fullCell
                                ? constraints.maxWidth
                                : math.min(
                                    math.max(
                                      MiuixCalendarDefaults.dayExtent,
                                      numberSize.width + 8,
                                    ),
                                    constraints.maxWidth,
                                  ),
                            // Keep the paint/adornment plane in sync with the
                            // resolved row height, including larger accessible rows.
                            height: math.min(cellExtent, constraints.maxHeight),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // Only inset the paint; lunar labels and corner
                                // badges retain their space at larger text scales.
                                Padding(
                                  padding: rangeSelected
                                      ? EdgeInsets.only(
                                          top: widget.dayMargin.top,
                                          bottom: widget.dayMargin.bottom,
                                        )
                                      : widget.dayMargin,
                                  child: AnimatedContainer(
                                    key: fullCell
                                        ? ValueKey(
                                            'calendar-highlight-${date.year}-${date.month}-${date.day}',
                                          )
                                        : null,
                                    duration: reduceMotion
                                        ? Duration.zero
                                        : fullCell
                                        ? const Duration(milliseconds: 180)
                                        : hyperOs4.pickerStageMotion,
                                    curve: Curves.easeOutCubic,
                                    decoration: BoxDecoration(
                                      color: separateHighlight
                                          ? customDayFill ?? Colors.transparent
                                          : dayFill,
                                      border: separateHighlight
                                          ? null
                                          : dayBorder,
                                      borderRadius: dayRadius,
                                    ),
                                  ),
                                ),
                                if (separateHighlight && (isToday || selected))
                                  Padding(
                                    padding: highlightMargin,
                                    child: AnimatedContainer(
                                      key: ValueKey(
                                        'calendar-highlight-${date.year}-${date.month}-${date.day}',
                                      ),
                                      duration: reduceMotion
                                          ? Duration.zero
                                          : hyperOs4.pickerStageMotion,
                                      curve: Curves.easeOutCubic,
                                      decoration: BoxDecoration(
                                        color: isToday
                                            ? colors.selectedBackground
                                            : Colors.transparent,
                                        border: isToday
                                            ? null
                                            : Border.all(
                                                color:
                                                    colors.selectedBackground,
                                                width: 1.8,
                                              ),
                                        borderRadius: dayRadius,
                                      ),
                                    ),
                                  ),
                                Align(
                                  alignment: widget.dayNumberAlignment,
                                  child: Text(
                                    widget.showAdjacentMonthDays || inMonth
                                        ? '${date.day}'
                                        : '',
                                    maxLines: 1,
                                    softWrap: false,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: foreground,
                                          fontWeight:
                                              (selected || isToday) &&
                                                  widget.hyperOsDayStyles
                                              ? FontWeight.w700
                                              : selected
                                              ? FontWeight.w600
                                              : null,
                                        ),
                                  ),
                                ),
                                if (widget.dayAdornmentBuilder
                                    case final builder?)
                                  IgnorePointer(
                                    child: builder(
                                      context,
                                      date,
                                      selected,
                                      enabled,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );

    final rtl = Directionality.of(context) == TextDirection.rtl;
    final surface = MiuixSurface(
      color: colors.background,
      radius: widget.cornerRadius ?? hyperOs4.calendarCornerRadius,
      glass: widget.glass,
      glassBlur: widget.glassBlur ?? hyperOs4.calendarBlur,
      glassOpacity: widget.glassOpacity ?? hyperOs4.calendarTintOpacity,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: GestureDetector(
          onHorizontalDragEnd: (details) {
            final velocity = details.primaryVelocity ?? 0;
            if (velocity.abs() < 180) return;
            _moveMonth(velocity < 0 ? 1 : -1);
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              final requested = widget.dayExtent;
              final configured = requested != null && requested.isFinite
                  ? math.max(44.0, requested)
                  : MiuixCalendarDefaults.dayExtent;
              final minimumExtent = math.max(
                44.0,
                numberSize.height + widget.dayMargin.vertical + 8,
              );
              final preferred = math.max(configured, minimumExtent);
              // 标题自然换行；仅在受限高度计算滚动空间时测量默认标题。
              final titleStyle = DefaultTextStyle.of(context).style.merge(
                Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              );
              final titleHeight = textSize(
                localizations.formatMonthYear(month),
                titleStyle,
                width: math.max(1.0, constraints.maxWidth - 96),
              ).height;
              final headerHeight =
                  (widget.showHeader ? math.max(52.0, titleHeight) : 0.0) +
                  weekdayHeight;
              final rows = gridCellCount / 7;
              final available = constraints.hasBoundedHeight
                  ? (constraints.maxHeight - headerHeight) / rows
                  : preferred;
              final extent = math.min(
                preferred,
                math.max(minimumExtent, available),
              );
              final child = content(
                extent,
                math.max(constraints.maxWidth, (numberSize.width + 8) * 7),
              );
              // 小窗口保持可达的日期热区，空间不足时允许纵向滚动。
              // Preserve day targets and scroll vertically in very short hosts.
              return constraints.hasBoundedHeight &&
                      extent * rows + headerHeight > constraints.maxHeight
                  ? SingleChildScrollView(child: child)
                  : child;
            },
          ),
        ),
      ),
    );
    // Calendar keyboard contract:
    // - Tab enters one composite focus stop instead of every visible date.
    // - A pointer-selected day becomes the subsequent keyboard anchor.
    // - Left and Right mirror under RTL to follow the visual grid direction.
    // - Up and Down move exactly one rendered calendar row.
    // - Page Up and Page Down preserve the day number where the month permits.
    // - Month movement never bypasses normalized minimum or maximum bounds.
    // - A disabled target is a no-op rather than an unbounded predicate scan.
    // - Enter and Space select through the same controller and haptic path.
    // - Direction movement changes focus only; it does not silently select.
    // - Child semantics expose the one currently keyboard-focused date.
    // - External month navigation lazily resolves a legal anchor on next input.
    // - A month with no enabled dates remains readable but cannot take focus.
    // - Reduced motion does not alter logical focus or keyboard outcomes.
    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        const SingleActivator(LogicalKeyboardKey.arrowLeft):
            _CalendarDayMoveIntent(rtl ? 1 : -1),
        const SingleActivator(LogicalKeyboardKey.arrowRight):
            _CalendarDayMoveIntent(rtl ? -1 : 1),
        const SingleActivator(LogicalKeyboardKey.arrowUp):
            const _CalendarDayMoveIntent(-7),
        const SingleActivator(LogicalKeyboardKey.arrowDown):
            const _CalendarDayMoveIntent(7),
        const SingleActivator(LogicalKeyboardKey.pageUp):
            const _CalendarMonthMoveIntent(-1),
        const SingleActivator(LogicalKeyboardKey.pageDown):
            const _CalendarMonthMoveIntent(1),
        const SingleActivator(LogicalKeyboardKey.enter):
            const _CalendarSelectIntent(),
        const SingleActivator(LogicalKeyboardKey.space):
            const _CalendarSelectIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _CalendarDayMoveIntent: CallbackAction<_CalendarDayMoveIntent>(
            onInvoke: (intent) {
              _moveKeyboardByDays(intent.delta);
              return null;
            },
          ),
          _CalendarMonthMoveIntent: CallbackAction<_CalendarMonthMoveIntent>(
            onInvoke: (intent) {
              _moveKeyboardByMonths(intent.delta);
              return null;
            },
          ),
          _CalendarSelectIntent: CallbackAction<_CalendarSelectIntent>(
            onInvoke: (_) {
              _selectKeyboardDate();
              return null;
            },
          ),
        },
        child: Focus(
          focusNode: _focusNode,
          canRequestFocus: _firstEnabledDateInMonth(month) != null,
          child: surface,
        ),
      ),
    );
  }
}

class _CalendarDayMoveIntent extends Intent {
  const _CalendarDayMoveIntent(this.delta);
  final int delta;
}

class _CalendarMonthMoveIntent extends Intent {
  const _CalendarMonthMoveIntent(this.delta);
  final int delta;
}

class _CalendarSelectIntent extends Intent {
  const _CalendarSelectIntent();
}

/// Builds optional content above a calendar day without replacing the MIUIX
/// selection, motion, semantics, or input behavior of the day cell itself.
typedef MiuixCalendarDayAdornmentBuilder =
    Widget? Function(
      BuildContext context,
      DateTime date,
      bool selected,
      bool enabled,
    );
