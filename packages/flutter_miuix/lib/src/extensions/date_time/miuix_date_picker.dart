import 'package:flutter/material.dart';

import '../../platform/miuix_haptics.dart';
import '../../theme/miuix_theme.dart';
import '../../widgets/miuix_widgets.dart';
import 'miuix_calendar.dart';

/// Available date-picker presentations.
enum MiuixDatePickerMode {
  /// A touch-friendly month grid.
  calendar,

  /// Three flat MIUIX number wheels.
  wheels,
}

/// Controlled date value shared by inline and dialog pickers.
class MiuixDatePickerController extends ChangeNotifier {
  /// Creates a controller with a normalized local date.
  MiuixDatePickerController({DateTime? value})
    : _value = MiuixCalendarController.dateOnly(value ?? DateTime.now());

  DateTime _value;

  /// Current date without time-of-day fields.
  DateTime get value => _value;

  /// Replaces the current date.
  set value(DateTime next) {
    final normalized = MiuixCalendarController.dateOnly(next);
    if (normalized == _value) return;
    _value = normalized;
    notifyListeners();
  }
}

/// Source-aligned geometry defaults for [MiuixDatePicker].
abstract final class MiuixDatePickerDefaults {
  /// Default number of visible rows in wheel mode.
  static const int visibleItemCount = 5;

  /// Width allocated to the year wheel.
  static const double yearWidth = 104;

  /// Width allocated to month and day wheels.
  static const double fieldWidth = 82;
}

/// Date-picker extension using a calendar or MIUIX flat wheels.
class MiuixDatePicker extends StatefulWidget {
  /// Creates an inline date picker.
  const MiuixDatePicker({
    super.key,
    this.controller,
    this.initialDate,
    this.minimumDate,
    this.maximumDate,
    this.mode = MiuixDatePickerMode.calendar,
    this.onChanged,
    this.selectableDayPredicate,
    this.glass = true,
  });

  /// Optional externally owned value controller.
  final MiuixDatePickerController? controller;

  /// Initial value used by the internally owned controller.
  final DateTime? initialDate;

  /// Earliest selectable date.
  final DateTime? minimumDate;

  /// Latest selectable date.
  final DateTime? maximumDate;

  /// Initial visual presentation.
  final MiuixDatePickerMode mode;

  /// Called after the selected date changes.
  final ValueChanged<DateTime>? onChanged;

  /// Additional application availability rule.
  final bool Function(DateTime date)? selectableDayPredicate;

  /// Whether calendar and wheel panels use HyperOS 4 backdrop material.
  final bool glass;

  /// Opens a modal date picker and returns the confirmed value.
  static Future<DateTime?> show({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? minimumDate,
    DateTime? maximumDate,
    MiuixDatePickerMode mode = MiuixDatePickerMode.calendar,
    bool Function(DateTime date)? selectableDayPredicate,
    String? title,
    bool glass = true,
  }) {
    final controller = MiuixDatePickerController(value: initialDate);
    final localizations = MaterialLocalizations.of(context);
    final navigator = Navigator.of(context, rootNavigator: true);
    return MiuixDialog.show<DateTime>(
      context: context,
      title: title ?? localizations.datePickerHelpText,
      content: Flexible(
        fit: FlexFit.loose,
        child: SingleChildScrollView(
          child: MiuixDatePicker(
            controller: controller,
            minimumDate: minimumDate,
            maximumDate: maximumDate,
            mode: mode,
            selectableDayPredicate: selectableDayPredicate,
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
  State<MiuixDatePicker> createState() => _MiuixDatePickerState();
}

class _MiuixDatePickerState extends State<MiuixDatePicker> {
  late MiuixDatePickerController _controller;
  late MiuixCalendarController _calendarController;
  late bool _ownsController;
  late MiuixDatePickerMode _mode;

  ({DateTime minimum, DateTime maximum}) get _range {
    // Date-only normalization belongs at the widget boundary because callers
    // may provide values with arbitrary time-of-day and time-zone fields.
    // The picker deliberately compares calendar dates, not elapsed instants.
    //
    // Accepting reversed endpoints is also intentional. Preference data can
    // arrive asynchronously, so minimum and maximum are sometimes rebuilt in
    // separate frames. A temporary reversal must not crash or empty the UI.
    //
    // Keeping this policy in one getter means wheels, calendar cells, live
    // controller replacement, and externally-authored values all observe the
    // same inclusive interval.
    final first = MiuixCalendarController.dateOnly(
      widget.minimumDate ?? DateTime(1900),
    );
    final second = MiuixCalendarController.dateOnly(
      widget.maximumDate ?? DateTime(2100, 12, 31),
    );
    // Range-bearing MIUIX controls accept endpoints in either order. Keeping
    // this invariant here prevents wheel clamps and calendar navigation from
    // receiving an invalid lower/upper pair after a live configuration change.
    return first.isAfter(second)
        ? (minimum: second, maximum: first)
        : (minimum: first, maximum: second);
  }

  DateTime get _minimum => _range.minimum;

  DateTime get _maximum => _range.maximum;

  DateTime _clampToRange(DateTime candidate) {
    // Controller values are public mutable state. Clamp at every ingress point
    // rather than assuming only taps inside this widget can update the value.
    // Returning a canonical date also avoids false changes caused solely by a
    // different hour, minute, second, or millisecond component.
    final normalized = MiuixCalendarController.dateOnly(candidate);
    final range = _range;
    if (normalized.isBefore(range.minimum)) return range.minimum;
    if (normalized.isAfter(range.maximum)) return range.maximum;
    return normalized;
  }

  @override
  void initState() {
    super.initState();
    _mode = widget.mode;
    _attachController();
  }

  void _attachController() {
    // Normalize before listening so attachment never publishes a synthetic
    // onChanged event. The corrected value is still immediately observable by
    // the caller-owned controller and by the calendar created just below.
    _ownsController = widget.controller == null;
    _controller =
        widget.controller ??
        MiuixDatePickerController(value: widget.initialDate);
    _controller.value = _clampToRange(_controller.value);
    _controller.addListener(_handleValueChanged);
    _calendarController = MiuixCalendarController(
      visibleMonth: _controller.value,
      selectedDates: <DateTime>[_controller.value],
    );
  }

  @override
  void didUpdateWidget(MiuixDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode != widget.mode) _mode = widget.mode;
    if (oldWidget.controller != widget.controller) {
      _controller.removeListener(_handleValueChanged);
      _calendarController.dispose();
      if (_ownsController) _controller.dispose();
      _attachController();
      return;
    }
    if (oldWidget.minimumDate != widget.minimumDate ||
        oldWidget.maximumDate != widget.maximumDate) {
      // A live range update has two valid outcomes: move an out-of-range value
      // to the nearest boundary, or retain the value while rebuilding enabled
      // cells. Both paths are required; only reacting to a changed controller
      // value leaves the calendar with stale navigation constraints.
      final clamped = _clampToRange(_controller.value);
      if (clamped != _controller.value) {
        _controller.value = clamped;
      } else {
        // The visible selection is unchanged, but Calendar still needs a
        // rebuild so its enabled days and navigation limits use the new range.
        setState(() {});
      }
    }
  }

  void _handleValueChanged() {
    if (!mounted) return;
    final value = _controller.value;
    _calendarController
      ..showMonth(value)
      ..clearSelection()
      ..select(value, MiuixCalendarSelectionMode.single);
    setState(() {});
    widget.onChanged?.call(value);
  }

  void _setValue(DateTime candidate) {
    final value = _clampToRange(candidate);
    if (!(widget.selectableDayPredicate?.call(value) ?? true)) return;
    _controller.value = value;
  }

  int _daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

  Widget _buildWheels(BuildContext context) {
    final value = _controller.value;
    final maxDay = _daysInMonth(value.year, value.month);

    Widget wheel({
      required double width,
      required int value,
      required int min,
      required int max,
      required ValueChanged<int> onChanged,
      String Function(int)? label,
    }) {
      return SizedBox(
        width: width,
        child: MiuixNumberPicker(
          value: value.clamp(min, max),
          min: min,
          max: max,
          visibleItemCount: MiuixDatePickerDefaults.visibleItemCount,
          label: label,
          onChanged: onChanged,
        ),
      );
    }

    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    return MiuixSurface(
      glass: widget.glass,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      radius: hyperOs4.pickerCornerRadius,
      glassBlur: hyperOs4.pickerBlur,
      glassOpacity: hyperOs4.pickerTintOpacity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          wheel(
            width: MiuixDatePickerDefaults.yearWidth,
            value: value.year,
            min: _minimum.year,
            max: _maximum.year,
            onChanged: (year) => _setValue(
              DateTime(
                year,
                value.month,
                value.day.clamp(1, _daysInMonth(year, value.month)),
              ),
            ),
          ),
          wheel(
            width: MiuixDatePickerDefaults.fieldWidth,
            value: value.month,
            min: 1,
            max: 12,
            // Numeric month labels remain compact in both Chinese and English;
            // formatMonthYear also includes the synthetic year in some locales.
            label: (month) => month.toString().padLeft(2, '0'),
            onChanged: (month) => _setValue(
              DateTime(
                value.year,
                month,
                value.day.clamp(1, _daysInMonth(value.year, month)),
              ),
            ),
          ),
          wheel(
            width: MiuixDatePickerDefaults.fieldWidth,
            value: value.day.clamp(1, maxDay),
            min: 1,
            max: maxDay,
            onChanged: (day) =>
                _setValue(DateTime(value.year, value.month, day)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_handleValueChanged);
    _calendarController.dispose();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: MiuixTextButton(
            label: _mode == MiuixDatePickerMode.calendar
                ? localizations.inputDateModeButtonLabel
                : localizations.calendarModeButtonLabel,
            onPressed: () {
              setState(() {
                _mode = _mode == MiuixDatePickerMode.calendar
                    ? MiuixDatePickerMode.wheels
                    : MiuixDatePickerMode.calendar;
              });
              MiuixHaptics.perform(MiuixHapticType.toggleOn);
            },
          ),
        ),
        AnimatedSwitcher(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : MiuixTheme.of(context).hyperOs4.pickerStageMotion,
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: _mode == MiuixDatePickerMode.calendar
              ? MiuixCalendar(
                  key: const ValueKey<String>('calendar'),
                  dayExtent: 48,
                  controller: _calendarController,
                  minimumDate: _minimum,
                  maximumDate: _maximum,
                  selectableDayPredicate: widget.selectableDayPredicate,
                  glass: widget.glass,
                  onChanged: (state) {
                    if (state.selectedDates.isNotEmpty) {
                      _setValue(state.selectedDates.first);
                    }
                  },
                )
              : KeyedSubtree(
                  key: const ValueKey<String>('wheels'),
                  child: _buildWheels(context),
                ),
        ),
      ],
    );
  }
}
