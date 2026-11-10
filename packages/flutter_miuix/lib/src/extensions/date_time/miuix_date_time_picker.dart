import 'package:flutter/material.dart';

import '../../platform/miuix_haptics.dart';
import '../../theme/miuix_theme.dart';
import '../../widgets/miuix_widgets.dart';
import 'miuix_calendar.dart';
import 'miuix_date_picker.dart';
import 'miuix_time_picker.dart';

/// Active stage shown by [MiuixDateTimePicker].
enum MiuixDateTimePickerStage {
  /// Select the calendar date.
  date,

  /// Select the wall-clock time.
  time,
}

/// Controller for an inline or modal date-time picker.
class MiuixDateTimePickerController extends ChangeNotifier {
  /// Creates a controller with local date-time semantics.
  MiuixDateTimePickerController({DateTime? value})
    : _value = value ?? DateTime.now();

  DateTime _value;

  /// Current local date and time.
  DateTime get value => _value;

  /// Replaces the complete date-time value.
  set value(DateTime next) {
    if (next == _value) return;
    _value = next;
    notifyListeners();
  }
}

/// Layout defaults for [MiuixDateTimePicker].
abstract final class MiuixDateTimePickerDefaults {
  /// Previous fixed duration retained for explicit compatibility tests.
  static const Duration legacyStageAnimationDuration = Duration(
    milliseconds: 320,
  );

  /// Animation used when switching between date and time stages.
  static const Duration stageAnimationDuration = Duration(milliseconds: 380);
}

/// Two-stage date and time picker built from package-level MIUIX controls.
class MiuixDateTimePicker extends StatefulWidget {
  /// Creates an inline picker.
  const MiuixDateTimePicker({
    super.key,
    this.controller,
    this.initialDateTime,
    this.minimumDate,
    this.maximumDate,
    this.initialStage = MiuixDateTimePickerStage.date,
    this.datePickerMode = MiuixDatePickerMode.calendar,
    this.use24HourFormat,
    this.minuteInterval = 1,
    this.showSeconds = false,
    this.onChanged,
    this.glass = true,
  });

  /// Optional externally owned value controller.
  final MiuixDateTimePickerController? controller;

  /// Initial value used by the internal controller.
  final DateTime? initialDateTime;

  /// Earliest and latest selectable calendar dates.
  final DateTime? minimumDate;
  final DateTime? maximumDate;

  /// Stage shown on first build.
  final MiuixDateTimePickerStage initialStage;

  /// Calendar or wheel presentation for the date stage.
  final MiuixDatePickerMode datePickerMode;

  /// Optional 12/24-hour override.
  final bool? use24HourFormat;

  /// Legal minute increment.
  final int minuteInterval;

  /// Whether the time stage includes seconds.
  final bool showSeconds;

  /// Called after the complete date-time value changes.
  final ValueChanged<DateTime>? onChanged;

  /// Whether the stage selector and child picker panels use backdrop material.
  final bool glass;

  /// Opens a modal two-stage picker and returns the confirmed value.
  static Future<DateTime?> show({
    required BuildContext context,
    DateTime? initialDateTime,
    DateTime? minimumDate,
    DateTime? maximumDate,
    MiuixDatePickerMode datePickerMode = MiuixDatePickerMode.calendar,
    bool? use24HourFormat,
    int minuteInterval = 1,
    bool showSeconds = false,
    String? title,
    bool glass = true,
  }) {
    final controller = MiuixDateTimePickerController(value: initialDateTime);
    final localizations = MaterialLocalizations.of(context);
    final navigator = Navigator.of(context, rootNavigator: true);
    return MiuixDialog.show<DateTime>(
      context: context,
      title: title ?? localizations.datePickerHelpText,
      content: Flexible(
        fit: FlexFit.loose,
        child: SingleChildScrollView(
          child: MiuixDateTimePicker(
            controller: controller,
            minimumDate: minimumDate,
            maximumDate: maximumDate,
            datePickerMode: datePickerMode,
            use24HourFormat: use24HourFormat,
            minuteInterval: minuteInterval,
            showSeconds: showSeconds,
            glass: glass,
          ),
        ),
      ),
      actions: <Widget>[
        MiuixTextButton(
          label: localizations.cancelButtonLabel,
          onPressed: navigator.pop,
        ),
        MiuixButton(
          label: localizations.okButtonLabel,
          filled: true,
          onPressed: () {
            MiuixHaptics.perform(MiuixHapticType.confirm);
            navigator.pop(controller.value);
          },
        ),
      ],
    ).whenComplete(controller.dispose);
  }

  @override
  State<MiuixDateTimePicker> createState() => _MiuixDateTimePickerState();
}

class _MiuixDateTimePickerState extends State<MiuixDateTimePicker> {
  // Composite date-time value ownership contract:
  // - The public controller owns one complete local DateTime value.
  // - The date child projects only year, month, and day from that value.
  // - The time child projects only hour, minute, and optional second.
  // - Minimum and maximum constrain calendar dates, not elapsed instants.
  // - Bounds are normalized to date-only values before comparison.
  // - Reversed bounds are accepted and sorted into one inclusive range.
  // - A stale initial date is corrected before child controllers are created.
  // - This prevents DatePicker from writing into its parent during first mount.
  // - Attachment correction does not emit the widget's onChanged callback.
  // - External controller writes are clamped through the same date projection.
  // - A recursion guard absorbs the controller's nested correction callback.
  // - Consumers receive one callback containing the final legal DateTime.
  // - Dynamic bound changes retain the active controller and picker stage.
  // - Clamping changes only date fields and preserves authored wall-clock time.
  // - Date-wheel edits preserve hour, minute, second, and subsecond fields.
  // - Time-wheel edits preserve year, month, day, and subsecond fields.
  // - Milliseconds and microseconds are never silently rounded by composition.
  // - The seconds wheel remains intentionally whole-second precision itself.
  // - Minute and second interval normalization remains child-picker owned.
  // - Switching stages does not create or dispose replacement value owners.
  // - Child synchronization compares values before publishing controller writes.
  // - Externally owned controllers are listened to but never disposed here.
  // - Internally owned controllers follow the parent State lifecycle.
  // - Controller replacement detaches both children before attaching the next.
  // - Reduced motion affects only the stage transition, not value correction.
  // - Tests cover lower and upper clamping plus complete time-field retention.
  // Composite accessibility and display contract:
  // - The date tab label is formatted from the same corrected controller value.
  // - The time tab label never presents the discarded out-of-range date.
  // - Twelve- and twenty-four-hour formatting remain presentation-only choices.
  // - Stage semantics continue coming from the shared MIUIX TabBar component.
  // - Value normalization does not force an unsolicited stage transition.
  // - A corrected date reaches both visible labels in the same widget frame.
  // - Date and time children never announce two intermediate correction values.
  // - Modal confirmation therefore returns the value already shown to the user.
  // - Keyboard and semantics edits pass through the same child-controller path.
  // - Subsecond preservation applies equally to pointer and semantic changes.
  late MiuixDateTimePickerController _controller;
  late MiuixDatePickerController _dateController;
  late MiuixTimePickerController _timeController;
  late MiuixDateTimePickerStage _stage;
  late bool _ownsController;
  bool _normalizingExternalValue = false;

  ({DateTime minimum, DateTime maximum}) get _dateRange {
    final first = MiuixCalendarController.dateOnly(
      widget.minimumDate ?? DateTime(1900),
    );
    final second = MiuixCalendarController.dateOnly(
      widget.maximumDate ?? DateTime(2100, 12, 31),
    );
    return first.isAfter(second)
        ? (minimum: second, maximum: first)
        : (minimum: first, maximum: second);
  }

  DateTime _clampDateTime(DateTime candidate) {
    final day = MiuixCalendarController.dateOnly(candidate);
    final range = _dateRange;
    final safeDay = day.isBefore(range.minimum)
        ? range.minimum
        : day.isAfter(range.maximum)
        ? range.maximum
        : day;
    if (safeDay == day) return candidate;
    // Date bounds are inclusive calendar-day limits. Preserve the wall-clock
    // fields so clamping a restored date does not unexpectedly reset its time.
    return DateTime(
      safeDay.year,
      safeDay.month,
      safeDay.day,
      candidate.hour,
      candidate.minute,
      candidate.second,
      candidate.millisecond,
      candidate.microsecond,
    );
  }

  @override
  void initState() {
    super.initState();
    _stage = widget.initialStage;
    _attachController();
  }

  void _attachController() {
    _ownsController = widget.controller == null;
    _controller =
        widget.controller ??
        MiuixDateTimePickerController(value: widget.initialDateTime);
    // Normalize before listeners and child controllers are created. Otherwise
    // DatePicker would correct the shared date during its own mount and cause
    // a composite-controller writeback in the middle of the first build.
    _controller.value = _clampDateTime(_controller.value);
    _controller.addListener(_handleExternalChanged);
    _createChildControllers(_controller.value);
  }

  void _createChildControllers(DateTime value) {
    _dateController = MiuixDatePickerController(value: value)
      ..addListener(_handleDateChanged);
    _timeController = MiuixTimePickerController(
      value: MiuixTimeValue(
        hour: value.hour,
        minute: value.minute,
        second: value.second,
      ),
    )..addListener(_handleTimeChanged);
  }

  @override
  void didUpdateWidget(MiuixDateTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _detachChildControllers();
      _controller.removeListener(_handleExternalChanged);
      if (_ownsController) _controller.dispose();
      _attachController();
      return;
    }
    if (oldWidget.minimumDate != widget.minimumDate ||
        oldWidget.maximumDate != widget.maximumDate) {
      final safeValue = _clampDateTime(_controller.value);
      if (safeValue != _controller.value) _controller.value = safeValue;
    }
  }

  void _handleDateChanged() {
    final date = _dateController.value;
    final old = _controller.value;
    _controller.value = DateTime(
      date.year,
      date.month,
      date.day,
      old.hour,
      old.minute,
      old.second,
      old.millisecond,
      old.microsecond,
    );
  }

  void _handleTimeChanged() {
    final time = _timeController.value;
    final old = _controller.value;
    _controller.value = DateTime(
      old.year,
      old.month,
      old.day,
      time.hour,
      time.minute,
      time.second,
      old.millisecond,
      old.microsecond,
    );
  }

  void _handleExternalChanged() {
    if (!mounted) return;
    if (_normalizingExternalValue) return;
    var value = _controller.value;
    final safeValue = _clampDateTime(value);
    if (safeValue != value) {
      _normalizingExternalValue = true;
      try {
        _controller.value = safeValue;
      } finally {
        _normalizingExternalValue = false;
      }
      value = safeValue;
    }
    final date = MiuixCalendarController.dateOnly(value);
    if (_dateController.value != date) _dateController.value = date;
    final time = MiuixTimeValue(
      hour: value.hour,
      minute: value.minute,
      second: value.second,
    );
    if (_timeController.value != time) _timeController.value = time;
    setState(() {});
    widget.onChanged?.call(value);
  }

  void _detachChildControllers() {
    _dateController
      ..removeListener(_handleDateChanged)
      ..dispose();
    _timeController
      ..removeListener(_handleTimeChanged)
      ..dispose();
  }

  @override
  void dispose() {
    _detachChildControllers();
    _controller.removeListener(_handleExternalChanged);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final value = _controller.value;
    final dateLabel = localizations.formatMediumDate(value);
    final timeLabel = localizations.formatTimeOfDay(
      TimeOfDay(hour: value.hour, minute: value.minute),
      alwaysUse24HourFormat:
          widget.use24HourFormat ?? MediaQuery.alwaysUse24HourFormatOf(context),
    );

    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final scheme = Theme.of(context).colorScheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        MiuixSurface(
          glass: widget.glass,
          color: scheme.surfaceContainerLow,
          radius: hyperOs4.pickerCornerRadius,
          glassBlur: hyperOs4.pickerBlur,
          glassOpacity: hyperOs4.pickerTintOpacity,
          padding: const EdgeInsets.all(3),
          child: MiuixTabBar(
            tabs: <String>[dateLabel, timeLabel],
            selectedTabIndex: _stage.index,
            onTabSelected: (index) => _setStage(
              index == 0
                  ? MiuixDateTimePickerStage.date
                  : MiuixDateTimePickerStage.time,
            ),
            minWidth: 100,
            maxWidth: 180,
            height: 44,
            cornerRadius: 22,
            itemSpacing: 4,
            colors: MiuixTabRowDefaults.tabRowColors(context).copyWith(
              backgroundColor: Colors.transparent,
              selectedBackgroundColor: scheme.primaryContainer,
              selectedContentColor: scheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: reduceMotion ? Duration.zero : hyperOs4.pickerStageMotion,
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: .985, end: 1).animate(animation),
              child: child,
            ),
          ),
          child: _stage == MiuixDateTimePickerStage.date
              ? MiuixDatePicker(
                  key: const ValueKey<String>('date'),
                  controller: _dateController,
                  minimumDate: widget.minimumDate,
                  maximumDate: widget.maximumDate,
                  mode: widget.datePickerMode,
                  glass: widget.glass,
                  onChanged: (_) {},
                )
              : MiuixTimePicker(
                  key: const ValueKey<String>('time'),
                  controller: _timeController,
                  use24HourFormat: widget.use24HourFormat,
                  minuteInterval: widget.minuteInterval,
                  showSeconds: widget.showSeconds,
                  glass: widget.glass,
                  onChanged: (_) {},
                ),
        ),
      ],
    );
  }

  void _setStage(MiuixDateTimePickerStage stage) {
    if (_stage == stage) return;
    setState(() => _stage = stage);
    MiuixHaptics.perform(MiuixHapticType.toggleOn);
  }
}
