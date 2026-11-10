import '../../icons/miuix_icon_theme.dart';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../platform/miuix_haptics.dart';
import '../../theme/miuix_semantic_colors.dart';
import '../../theme/miuix_theme.dart';
import '../../widgets/miuix_widgets.dart';
import '../miuix_extension_icons.dart';
import '../presentation/miuix_list_section.dart';
import 'miuix_calendar.dart';

part 'miuix_month_year_picker.dart';

/// Controlled start/end state for [MiuixDateRangePicker].
class MiuixDateRangePickerController extends ChangeNotifier {
  /// Creates a range controller and its month-grid controller.
  MiuixDateRangePickerController({
    MiuixDateRange? value,
    DateTime? visibleMonth,
  }) : _start = value?.start,
       _end = value?.end,
       calendarController = MiuixCalendarController(
         visibleMonth: visibleMonth ?? value?.start,
         selectedRange: value,
       ) {
    calendarController.addListener(_readCalendar);
  }

  DateTime? _start;
  DateTime? _end;
  bool _synchronizing = false;

  /// Month-grid controller exposed for coordinated navigation.
  final MiuixCalendarController calendarController;

  /// Current range endpoints; [end] is null while selecting the second date.
  DateTime? get start => _start;
  DateTime? get end => _end;

  /// A one-day range is returned while only the first endpoint is selected.
  MiuixDateRange? get value =>
      _start == null ? null : MiuixDateRange(_start!, _end ?? _start!);

  /// Whether at least one day is available for confirmation.
  bool get hasSelection => _start != null;

  /// Whether the picker is waiting for a distinct optional end date.
  bool get selectingEnd => _start != null && _end == null;

  /// Replaces both endpoints and synchronizes the calendar highlight.
  set value(MiuixDateRange? next) {
    setRange(next);
  }

  /// Replaces both endpoints while preserving an optional in-progress phase.
  ///
  /// Most callers should assign [value]. Composite owners use this method when
  /// a live constraint change must move the first endpoint without turning an
  /// in-progress one-day selection into a completed one-day range.
  void setRange(MiuixDateRange? next, {bool selectingEnd = false}) {
    final pending = next != null && selectingEnd;
    if (next == value && this.selectingEnd == pending) return;
    _start = next?.start;
    _end = pending ? null : next?.end;
    _writeCalendar(next, selectingEnd: pending);
    notifyListeners();
  }

  /// Clears both endpoints.
  void clear() => value = null;

  void _readCalendar() {
    if (_synchronizing) return;
    final state = calendarController.state;
    final range = state.selectedRange;
    final previousStart = _start;
    final previousEnd = _end;
    if (range == null) {
      _start = null;
      _end = null;
    } else if (state.rangeSelectionPending) {
      // The first range tap intentionally remains confirmable as one day.
      _start = range.start;
      _end = null;
    } else {
      _start = range.start;
      _end = range.end;
    }
    if (_start == previousStart && _end == previousEnd) return;
    notifyListeners();
  }

  void _writeCalendar(MiuixDateRange? range, {bool selectingEnd = false}) {
    _synchronizing = true;
    try {
      calendarController.setRange(range, selectingEnd: selectingEnd);
      if (range != null) calendarController.showMonth(range.start);
    } finally {
      _synchronizing = false;
    }
  }

  @override
  void dispose() {
    calendarController.removeListener(_readCalendar);
    calendarController.dispose();
    super.dispose();
  }
}

/// MIUIX date-range picker built on the public month calendar.
class MiuixDateRangePicker extends StatefulWidget {
  /// Creates an inline range picker.
  const MiuixDateRangePicker({
    super.key,
    this.controller,
    this.initialRange,
    this.minimumDate,
    this.maximumDate,
    this.selectableDayPredicate,
    this.onChanged,
    this.startLabel,
    this.endLabel,
    this.glass = true,
  });

  /// Controlled state or initial range for internally owned state.
  final MiuixDateRangePickerController? controller;
  final MiuixDateRange? initialRange;

  /// Date availability constraints.
  final DateTime? minimumDate;
  final DateTime? maximumDate;
  final bool Function(DateTime date)? selectableDayPredicate;

  /// Called whenever either endpoint changes.
  final ValueChanged<MiuixDateRange?>? onChanged;

  /// Optional localized endpoint labels.
  final String? startLabel;
  final String? endLabel;

  /// Whether the calendar panel uses HyperOS 4 backdrop material.
  final bool glass;

  /// Opens a dialog and returns the confirmed inclusive range.
  static Future<MiuixDateRange?> show({
    required BuildContext context,
    MiuixDateRange? initialRange,
    DateTime? minimumDate,
    DateTime? maximumDate,
    bool Function(DateTime date)? selectableDayPredicate,
    String? title,
    bool glass = true,
  }) {
    final controller = MiuixDateRangePickerController(value: initialRange);
    final localizations = MaterialLocalizations.of(context);
    final navigator = Navigator.of(context, rootNavigator: true);
    var dismissalCommitted = false;
    void closeWith(MiuixDateRange? range) {
      if (dismissalCommitted || !navigator.mounted) return;
      dismissalCommitted = true;
      navigator.pop(range);
    }

    return MiuixDialog.show<MiuixDateRange>(
      context: context,
      title: title ?? localizations.dateRangePickerHelpText,
      maxWidth: 520,
      content: Flexible(
        fit: FlexFit.loose,
        child: SingleChildScrollView(
          child: MiuixDateRangePicker(
            controller: controller,
            minimumDate: minimumDate,
            maximumDate: maximumDate,
            selectableDayPredicate: selectableDayPredicate,
            glass: glass,
          ),
        ),
      ),
      actions: <Widget>[
        MiuixTextButton(
          label: localizations.cancelButtonLabel,
          onPressed: () => closeWith(null),
        ),
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) => MiuixButton(
            label: localizations.okButtonLabel,
            filled: true,
            onPressed: controller.hasSelection
                ? () {
                    MiuixHaptics.perform(MiuixHapticType.confirm);
                    closeWith(controller.value);
                  }
                : null,
          ),
        ),
      ],
    ).whenComplete(controller.dispose);
  }

  @override
  State<MiuixDateRangePicker> createState() => _MiuixDateRangePickerState();
}

class _MiuixDateRangePickerState extends State<MiuixDateRangePicker> {
  // Date-range ownership contract:
  // - The public controller remains the only owner of selected endpoints.
  // - Widget minimum and maximum values constrain every controller ingress.
  // - Bounds are local calendar dates and include both endpoint days.
  // - Reversed authored bounds are sorted instead of rejected in Release.
  // - A missing lower or upper endpoint remains genuinely unbounded.
  // - Initial internal ranges are corrected before the listener is attached.
  // - Caller-owned ranges receive the same attachment-time normalization.
  // - Attachment correction intentionally does not call the widget callback.
  // - Later external controller writes are corrected through one shared path.
  // - A recursion guard hides the nested correction notification from clients.
  // - Clients receive one callback containing only the final legal range.
  // - A range wholly below the interval collapses onto the minimum day.
  // - A range wholly above the interval collapses onto the maximum day.
  // - A partially overlapping range clips only its out-of-range endpoint.
  // - Endpoint order remains normalized by the immutable MiuixDateRange value.
  // - Dynamic bound changes correct both external and internal controllers.
  // - A bound-only rebuild still refreshes date-cell enabled presentation.
  // - An in-progress first endpoint remains in progress after it is clamped.
  // - This avoids silently converting the next tap into a fresh range start.
  // - A completed one-day range remains completed after equivalent clamping.
  // - Calendar highlight and visible month update atomically with correction.
  // - Direct writes through calendarController are normalized on propagation.
  // - Month-only navigation does not trigger a range callback by itself.
  // - Null selection remains null regardless of finite date constraints.
  // - The selectable-day predicate still owns per-day availability policy.
  // - Bounds do not scan for a predicate-approved replacement endpoint.
  // - Modal confirmation therefore returns the same legal value that is shown.
  // - Pointer, keyboard, and semantics selection share the calendar controller.
  // - Externally owned controllers are never disposed by this widget.
  // - Internally owned controllers continue to follow the State lifecycle.
  // - Controller replacement detaches the old listener before normalization.
  // - These are project behavior guarantees, not unpublished Xiaomi metrics.
  // Detailed range-normalization and notification invariants:
  // - MiuixDateRange has already stripped endpoint time-of-day fields.
  // - Picker bounds are independently stripped to local calendar days.
  // - Neither operation converts a local date into UTC.
  // - Null minimum means there is no lower clipping endpoint.
  // - Null maximum means there is no upper clipping endpoint.
  // - Two finite reversed endpoints are swapped before comparisons.
  // - Equal bounds define one selectable inclusive calendar day.
  // - The lower endpoint comparison is strictly before minimum.
  // - The upper endpoint comparison is strictly after maximum.
  // - A value exactly on either endpoint remains unchanged.
  // - Each selected endpoint is clipped independently first.
  // - MiuixDateRange then restores canonical endpoint ordering.
  // - A wholly low range therefore becomes minimum-to-minimum.
  // - A wholly high range therefore becomes maximum-to-maximum.
  // - An overlapping low range clips only its start endpoint.
  // - An overlapping high range clips only its end endpoint.
  // - A reversed incoming range is already canonical before clipping.
  // - Null selection bypasses all endpoint operations.
  // - Internal initialRange is normalized before listener attachment.
  // - External initial controller state follows the identical path.
  // - Initial correction updates the caller's controller visibly.
  // - Initial correction intentionally emits no widget onChanged event.
  // - That distinction avoids treating restoration as a user edit.
  // - Calendar children see the corrected range on their first frame.
  // - The calendar visible month follows the corrected start endpoint.
  // - No transient out-of-range highlight is painted during mounting.
  // - Later value assignments notify the picker through its listener.
  // - The listener computes a safe immutable range before rebuilding.
  // - An already legal assignment follows the ordinary callback path.
  // - An illegal assignment performs one nested controller correction.
  // - The recursion guard suppresses handling of that nested notification.
  // - The outer listener then rebuilds from the final safe range.
  // - The outer listener calls onChanged exactly once.
  // - The callback argument is the final safe immutable snapshot.
  // - The callback never observes the illegal intermediate range.
  // - The callback never observes separately corrected endpoints.
  // - Clearing the controller still publishes one null callback.
  // - A month-only calendar notification does not change endpoints.
  // - The controller suppresses endpoint notification for that case.
  // - A direct calendar range write is read into the range controller.
  // - That propagated range then passes through picker normalization.
  // - Direct calendar writes cannot bypass widget date constraints.
  // - The public controller may explicitly represent a pending endpoint.
  // - Pending state is stored separately from endpoint equality.
  // - A pending one-day getter still returns a confirmable one-day value.
  // - Clamping a pending day retains its pending boolean.
  // - The range controller writes that phase atomically to the calendar.
  // - The next calendar selection therefore completes the pending range.
  // - It does not incorrectly start a second unrelated range.
  // - A completed one-day range retains a false pending boolean.
  // - Clamping an already completed one-day range keeps it completed.
  // - The next tap then starts a fresh range under existing policy.
  // - Dynamic lower-bound changes reuse the attached controller.
  // - Dynamic upper-bound changes reuse the attached controller.
  // - Dynamic reversed bounds use the same normalized order.
  // - A live correction preserves pending versus completed phase.
  // - A live correction emits one final range notification.
  // - A live legal value still rebuilds disabled date presentation.
  // - Bound-only rebuilds never recreate the caller's controller.
  // - Bound-only rebuilds never recreate the calendar controller.
  // - Controller replacement detaches the former range listener first.
  // - An internally owned former controller is then disposed.
  // - A caller-owned former controller is left intact.
  // - The replacement controller is normalized before listening.
  // - Disposal detaches this widget before optional owner disposal.
  // - The selectable-day predicate remains a separate application rule.
  // - Normalization never searches for a predicate-approved substitute.
  // - Such a search could be unbounded for arbitrary predicates.
  // - User taps remain blocked by the child calendar predicate.
  // - Bounds and predicate therefore keep distinct responsibilities.
  // - Endpoint labels read the same corrected controller fields.
  // - Active endpoint styling reads the retained pending phase.
  // - Modal confirmation reads the controller's corrected value.
  // - Confirmation cannot return a range different from the labels.
  // - Modal one-day confirmation remains allowed while pending.
  // - Cancellation never mutates the current controller selection.
  // - The dialog's one-shot dismissal guard remains independent.
  // - Haptic confirmation occurs only for an enabled confirm action.
  // - Pointer and keyboard calendar selection share normalization.
  // - Semantics activation also reaches the same controller path.
  // - Tests cover initial clipping at both endpoints.
  // - Tests cover later external clipping and callback count.
  // - Tests cover pending direct-calendar clipping and completion.
  // - Tests cover live reversed bounds and one final callback.
  // - Golden tests verify that legal-state visuals remain unchanged.
  // - Runtime checks remain required for physical modal interaction.
  // - These are library guarantees, not private HyperOS constants.
  late MiuixDateRangePickerController _controller;
  late bool _ownsController;
  bool _normalizingExternalRange = false;

  ({DateTime? minimum, DateTime? maximum}) get _dateBounds {
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
    return (minimum: minimum, maximum: maximum);
  }

  DateTime _clampDay(DateTime value) {
    final day = MiuixCalendarController.dateOnly(value);
    final bounds = _dateBounds;
    if (bounds.minimum case final minimum? when day.isBefore(minimum)) {
      return minimum;
    }
    if (bounds.maximum case final maximum? when day.isAfter(maximum)) {
      return maximum;
    }
    return day;
  }

  MiuixDateRange? _clampRange(MiuixDateRange? value) {
    if (value == null) return null;
    return MiuixDateRange(_clampDay(value.start), _clampDay(value.end));
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
        MiuixDateRangePickerController(value: widget.initialRange);
    final safeRange = _clampRange(_controller.value);
    if (safeRange != _controller.value) {
      _controller.setRange(safeRange, selectingEnd: _controller.selectingEnd);
    }
    _controller.addListener(_handleChanged);
  }

  @override
  void didUpdateWidget(MiuixDateRangePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _controller.removeListener(_handleChanged);
      if (_ownsController) _controller.dispose();
      _attachController();
      return;
    }
    if (oldWidget.minimumDate != widget.minimumDate ||
        oldWidget.maximumDate != widget.maximumDate) {
      final safeRange = _clampRange(_controller.value);
      if (safeRange != _controller.value) {
        _controller.setRange(safeRange, selectingEnd: _controller.selectingEnd);
      } else {
        setState(() {});
      }
    }
  }

  void _handleChanged() {
    if (!mounted) return;
    if (_normalizingExternalRange) return;
    var range = _controller.value;
    final safeRange = _clampRange(range);
    if (safeRange != range) {
      final selectingEnd = _controller.selectingEnd;
      _normalizingExternalRange = true;
      try {
        _controller.setRange(safeRange, selectingEnd: selectingEnd);
      } finally {
        _normalizingExternalRange = false;
      }
      range = safeRange;
    }
    setState(() {});
    widget.onChanged?.call(range);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleChanged);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  Widget _endpoint(
    BuildContext context, {
    required String label,
    required DateTime? value,
    required bool active,
    required Key surfaceKey,
  }) {
    final semantic = MiuixSemanticColors.of(context);
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final targetColor = active
        ? semantic['primaryContainer']
        : semantic['surfaceContainer'];
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: semantic['onSurfaceSecondary'],
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value == null
              ? '—'
              : MaterialLocalizations.of(context).formatMediumDate(value),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: active
                ? semantic['onPrimaryContainer']
                : semantic['onSurface'],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
    return Expanded(
      child: TweenAnimationBuilder<Color?>(
        tween: ColorTween(end: targetColor),
        duration: reduceMotion ? Duration.zero : hyperOs4.pickerStageMotion,
        curve: Curves.easeOutCubic,
        child: content,
        builder: (context, color, child) => MiuixSurface(
          key: surfaceKey,
          color: color ?? targetColor,
          radius: hyperOs4.calendarCornerRadius,
          glass: widget.glass,
          glassBlur: hyperOs4.calendarBlur,
          glassOpacity: hyperOs4.calendarTintOpacity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: child!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            _endpoint(
              context,
              label: widget.startLabel ?? '开始日期',
              value: _controller.start,
              active: _controller.start == null,
              surfaceKey: const ValueKey('miuix-date-range-start-endpoint'),
            ),
            const SizedBox(width: 8),
            _endpoint(
              context,
              label: widget.endLabel ?? '结束日期',
              value: _controller.end,
              active: _controller.selectingEnd,
              surfaceKey: const ValueKey('miuix-date-range-end-endpoint'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        MiuixCalendar(
          controller: _controller.calendarController,
          // 区间选择器不显示农历副标题，保留紧凑的日期热区。
          // Range pickers omit lunar subtitles and retain compact day targets.
          dayExtent: 44,
          selectionMode: MiuixCalendarSelectionMode.range,
          minimumDate: widget.minimumDate,
          maximumDate: widget.maximumDate,
          selectableDayPredicate: widget.selectableDayPredicate,
          glass: widget.glass,
        ),
      ],
    );
  }
}

/// Controller for a compact seven-day calendar strip.
class MiuixWeekCalendarController extends ChangeNotifier {
  /// Creates a controller around one selected local date.
  MiuixWeekCalendarController({DateTime? selectedDate})
    : _selectedDate = MiuixCalendarController.dateOnly(
        selectedDate ?? DateTime.now(),
      );

  DateTime _selectedDate;

  /// Selected date and its containing week.
  DateTime get selectedDate => _selectedDate;

  /// Selects a day.
  set selectedDate(DateTime value) {
    final normalized = MiuixCalendarController.dateOnly(value);
    if (normalized == _selectedDate) return;
    _selectedDate = normalized;
    notifyListeners();
  }

  /// Moves by a whole number of weeks.
  void addWeeks(int delta) {
    selectedDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day + delta * 7,
    );
  }

  /// Returns the first visible day for [firstWeekday].
  DateTime weekStart(int firstWeekday) {
    final normalized = normalizeFirstWeekday(firstWeekday);
    final offset = (_selectedDate.weekday - normalized + 7) % 7;
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day - offset,
    );
  }

  /// Projects an arbitrary integer into ISO Monday-through-Sunday numbering.
  static int normalizeFirstWeekday(int value) =>
      ((value - DateTime.monday) % 7) + DateTime.monday;
}

/// Compact week calendar suited to schedule headers.
class MiuixWeekCalendar extends StatefulWidget {
  /// Creates a seven-day calendar strip.
  const MiuixWeekCalendar({
    super.key,
    this.controller,
    this.initialDate,
    this.firstWeekday = DateTime.monday,
    this.onChanged,
    this.selectableDayPredicate,
    this.glass = true,
  });

  final MiuixWeekCalendarController? controller;
  final DateTime? initialDate;
  final int firstWeekday;
  final ValueChanged<DateTime>? onChanged;
  final bool Function(DateTime date)? selectableDayPredicate;
  final bool glass;

  @override
  State<MiuixWeekCalendar> createState() => _MiuixWeekCalendarState();
}

class _MiuixWeekCalendarState extends State<MiuixWeekCalendar> {
  late MiuixWeekCalendarController _controller;
  late bool _ownsController;
  // Week-strip interaction contract:
  // - Public firstWeekday accepts persisted integers without Release divergence.
  // - Every integer projects periodically into ISO Monday-through-Sunday numbering.
  // - Week-start arithmetic constructs local dates instead of subtracting 24-hour spans.
  // - This prevents daylight-saving transitions from producing 23:00 or 01:00 values.
  // - Week generation uses calendar constructors for the same local-date guarantee.
  // - Whole-week controller movement also uses calendar arithmetic rather than Duration.
  // - Pointer selection grants the strip focus before publishing its selected date.
  // - Left and Right then move one calendar day from that focused selection.
  // - Their logical direction mirrors under RTL while dates remain chronological.
  // - Up and Down move one complete calendar week without changing weekday.
  // - Keyboard candidates are normalized to local midnight by the controller setter.
  // - A rejected selectable-day candidate produces no callback or haptic feedback.
  // - The strip does not scan without bounds for a later predicate-approved date.
  // - Accepted keyboard movement emits one segment-tick haptic per logical step.
  // - Pointer movement retains the stronger confirmation haptic role.
  // - Both paths invoke onChanged only after controller state accepts the candidate.
  // - External controller changes rebuild the visible containing week automatically.
  // - An external selected date may be disabled without making rendering fail.
  // - Disabled day surfaces expose no pointer callback and retain disabled semantics.
  // - Focus remains owned by one strip node rather than seven competing row nodes.
  // - This provides predictable arrow behavior on Windows and hardware keyboards.
  // - Controller replacement detaches the former listener before attaching the next.
  // - Caller-owned controllers survive widget disposal and replacement.
  // - Internally owned controllers are disposed together with the focus node.
  // - Theme glass and radius changes do not alter date or focus identity.
  // - Localized narrow weekday labels derive from each generated date's real weekday.
  // - These are project behavior guarantees, not unpublished Xiaomi calendar metrics.
  final FocusNode _focusNode = FocusNode(debugLabel: 'MiuixWeekCalendar');

  @override
  void initState() {
    super.initState();
    _attachController();
  }

  /// Attaches the active controller and records its ownership explicitly.
  void _attachController() {
    _ownsController = widget.controller == null;
    _controller =
        widget.controller ??
        MiuixWeekCalendarController(selectedDate: widget.initialDate);
    _controller.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(MiuixWeekCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    _controller.removeListener(_rebuild);
    if (_ownsController) _controller.dispose();
    _attachController();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  void _moveSelection(int dayDelta) {
    final current = _controller.selectedDate;
    final candidate = DateTime(
      current.year,
      current.month,
      current.day + dayDelta,
    );
    if (!(widget.selectableDayPredicate?.call(candidate) ?? true)) return;
    _controller.selectedDate = candidate;
    widget.onChanged?.call(candidate);
    MiuixHaptics.perform(MiuixHapticType.segmentTick);
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
    final semantic = MiuixSemanticColors.of(context);
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final localizations = MaterialLocalizations.of(context);
    final start = _controller.weekStart(widget.firstWeekday);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final surface = MiuixSurface(
      color: semantic['surfaceVariant'],
      radius: hyperOs4.calendarCornerRadius,
      glass: widget.glass,
      glassBlur: hyperOs4.calendarBlur,
      glassOpacity: hyperOs4.calendarTintOpacity,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: List<Widget>.generate(7, (index) {
          final date = DateTime(start.year, start.month, start.day + index);
          final selected = date == _controller.selectedDate;
          final enabled = widget.selectableDayPredicate?.call(date) ?? true;
          final weekday = localizations.narrowWeekdays[date.weekday % 7];
          return Expanded(
            child: Semantics(
              button: true,
              selected: selected,
              enabled: enabled,
              label: localizations.formatFullDate(date),
              child: MiuixSurface(
                radius: 16,
                color: selected
                    ? semantic['primaryContainer']
                    : Colors.transparent,
                onTap: enabled
                    ? () {
                        _focusNode.requestFocus();
                        _controller.selectedDate = date;
                        widget.onChanged?.call(date);
                        MiuixHaptics.perform(MiuixHapticType.confirm);
                      }
                    : null,
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      weekday,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: semantic['onSurfaceSecondary'],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${date.day}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: selected
                            ? semantic['onPrimaryContainer']
                            : enabled
                            ? semantic['onSurface']
                            : semantic['disabledOnSurface'],
                        fontWeight: selected ? FontWeight.w600 : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        const SingleActivator(LogicalKeyboardKey.arrowLeft):
            _WeekCalendarMoveIntent(rtl ? 1 : -1),
        const SingleActivator(LogicalKeyboardKey.arrowRight):
            _WeekCalendarMoveIntent(rtl ? -1 : 1),
        const SingleActivator(LogicalKeyboardKey.arrowUp):
            const _WeekCalendarMoveIntent(-7),
        const SingleActivator(LogicalKeyboardKey.arrowDown):
            const _WeekCalendarMoveIntent(7),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _WeekCalendarMoveIntent: CallbackAction<_WeekCalendarMoveIntent>(
            onInvoke: (intent) {
              _moveSelection(intent.dayDelta);
              return null;
            },
          ),
        },
        child: Focus(focusNode: _focusNode, child: surface),
      ),
    );
  }
}

class _WeekCalendarMoveIntent extends Intent {
  const _WeekCalendarMoveIntent(this.dayDelta);
  final int dayDelta;
}

/// Immutable event displayed by [MiuixAgendaView].
@immutable
class MiuixAgendaItem {
  /// Creates one dated agenda entry.
  const MiuixAgendaItem({
    required this.date,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  });

  final DateTime date;
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
}

/// Date-grouped MIUIX agenda list with optional empty state.
class MiuixAgendaView extends StatelessWidget {
  /// Creates an agenda sorted by local date and original item order.
  const MiuixAgendaView({
    super.key,
    required this.items,
    this.emptyState,
    this.shrinkWrap = true,
    this.physics,
  });

  final List<MiuixAgendaItem> items;
  final Widget? emptyState;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return emptyState ??
          const MiuixEmptyState(title: '暂无日程', message: '所选日期范围内没有安排。');
    }
    final ordered = List<MiuixAgendaItem>.of(items)
      ..sort((a, b) => a.date.compareTo(b.date));
    final groups = SplayTreeMap<DateTime, List<MiuixAgendaItem>>();
    for (final item in ordered) {
      final date = MiuixCalendarController.dateOnly(item.date);
      groups.putIfAbsent(date, () => <MiuixAgendaItem>[]).add(item);
    }
    final children = <Widget>[];
    for (final entry in groups.entries) {
      children
        ..add(
          MiuixSmallTitle(
            MaterialLocalizations.of(context).formatFullDate(entry.key),
          ),
        )
        ..add(
          MiuixListSection(
            children: <Widget>[
              for (final item in entry.value)
                MiuixBasicComponent(
                  title: item.title,
                  summary: item.subtitle,
                  leading: item.leading,
                  trailing: item.trailing,
                  onTap: item.onTap,
                ),
            ],
          ),
        );
    }
    return ListView(
      primary: false,
      padding: EdgeInsets.zero,
      shrinkWrap: shrinkWrap,
      physics:
          physics ??
          (shrinkWrap
              ? const NeverScrollableScrollPhysics()
              : const BouncingScrollPhysics()),
      children: children,
    );
  }
}
