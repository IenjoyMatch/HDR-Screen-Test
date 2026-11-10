import 'package:flutter/material.dart';

import '../../platform/miuix_haptics.dart';
import '../../theme/miuix_theme.dart';
import '../../widgets/miuix_widgets.dart';

/// Immutable wall-clock time with optional seconds.
@immutable
class MiuixTimeValue {
  /// Creates a normalized 24-hour value.
  ///
  /// Dynamic application state can briefly cross a unit boundary while a
  /// picker is rebuilding. Normalize in every build mode so release callers
  /// never receive the debug-only behavior of constructor assertions.
  const MiuixTimeValue({required int hour, required int minute, int second = 0})
    : hour = hour % 24,
      minute = minute % 60,
      second = second % 60;

  /// Creates a value from Flutter's Material time model.
  factory MiuixTimeValue.fromTimeOfDay(TimeOfDay value) =>
      MiuixTimeValue(hour: value.hour, minute: value.minute);

  /// Hour in the inclusive 0 through 23 range.
  final int hour;

  /// Minute in the inclusive 0 through 59 range.
  final int minute;

  /// Second in the inclusive 0 through 59 range.
  final int second;

  /// Converts to Flutter's minute-precision model.
  TimeOfDay toTimeOfDay() => TimeOfDay(hour: hour, minute: minute);

  /// Returns a selectively replaced value.
  MiuixTimeValue copyWith({int? hour, int? minute, int? second}) =>
      MiuixTimeValue(
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
        second: second ?? this.second,
      );

  @override
  bool operator ==(Object other) =>
      other is MiuixTimeValue &&
      other.hour == hour &&
      other.minute == minute &&
      other.second == second;

  @override
  int get hashCode => Object.hash(hour, minute, second);
}

/// Externally observable value owner for [MiuixTimePicker].
class MiuixTimePickerController extends ChangeNotifier {
  /// Creates a controller at [value], defaulting to the current local time.
  MiuixTimePickerController({MiuixTimeValue? value})
    : _value =
          value ??
          MiuixTimeValue(
            hour: DateTime.now().hour,
            minute: DateTime.now().minute,
          );

  MiuixTimeValue _value;

  /// Current wall-clock value.
  MiuixTimeValue get value => _value;

  /// Replaces the current wall-clock value.
  set value(MiuixTimeValue next) {
    if (next == _value) return;
    _value = next;
    notifyListeners();
  }
}

/// Geometry and stepping defaults for [MiuixTimePicker].
abstract final class MiuixTimePickerDefaults {
  /// Default number of visible wheel entries.
  static const int visibleItemCount = 5;

  /// Default width of a numeric wheel.
  static const double wheelWidth = 82;

  /// Wider period wheel used by translated AM/PM labels.
  static const double periodWidth = 96;
}

/// Flat-wheel time picker composed from the upstream MIUIX number picker.
class MiuixTimePicker extends StatefulWidget {
  /// Creates an inline time picker.
  const MiuixTimePicker({
    super.key,
    this.controller,
    this.initialTime,
    this.use24HourFormat,
    this.minuteInterval = 1,
    this.secondInterval = 1,
    this.showSeconds = false,
    this.onChanged,
    this.glass = true,
  });

  /// Optional externally owned controller.
  final MiuixTimePickerController? controller;

  /// Initial time used by an internally owned controller.
  final MiuixTimeValue? initialTime;

  /// Overrides the platform's 12/24-hour preference when non-null.
  final bool? use24HourFormat;

  /// Legal minute increment.
  final int minuteInterval;

  /// Legal second increment.
  final int secondInterval;

  /// Whether a seconds wheel is displayed.
  final bool showSeconds;

  /// Called after any wheel changes the value.
  final ValueChanged<MiuixTimeValue>? onChanged;

  /// Whether the wheel group uses HyperOS 4 backdrop material.
  final bool glass;

  /// Opens a modal time picker and returns the confirmed value.
  static Future<MiuixTimeValue?> show({
    required BuildContext context,
    MiuixTimeValue? initialTime,
    bool? use24HourFormat,
    int minuteInterval = 1,
    int secondInterval = 1,
    bool showSeconds = false,
    String? title,
    bool glass = true,
  }) {
    final controller = MiuixTimePickerController(value: initialTime);
    final localizations = MaterialLocalizations.of(context);
    final navigator = Navigator.of(context, rootNavigator: true);
    return MiuixDialog.show<MiuixTimeValue>(
      context: context,
      title: title ?? localizations.timePickerDialHelpText,
      content: Flexible(
        fit: FlexFit.loose,
        child: SingleChildScrollView(
          child: MiuixTimePicker(
            controller: controller,
            use24HourFormat: use24HourFormat,
            minuteInterval: minuteInterval,
            secondInterval: secondInterval,
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
  State<MiuixTimePicker> createState() => _MiuixTimePickerState();
}

class _MiuixTimePickerState extends State<MiuixTimePicker> {
  late MiuixTimePickerController _controller;
  late bool _ownsController;

  @override
  void initState() {
    super.initState();
    _attachController();
  }

  void _attachController() {
    _ownsController = widget.controller == null;
    _controller =
        widget.controller ??
        MiuixTimePickerController(value: widget.initialTime);
    _controller.addListener(_handleChanged);
  }

  @override
  void didUpdateWidget(MiuixTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    _controller.removeListener(_handleChanged);
    if (_ownsController) _controller.dispose();
    _attachController();
  }

  void _handleChanged() {
    if (!mounted) return;
    setState(() {});
    widget.onChanged?.call(_controller.value);
  }

  void _update(MiuixTimeValue value) => _controller.value = value;

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  Widget _wheel({
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
    int step = 1,
    double width = MiuixTimePickerDefaults.wheelWidth,
    String Function(int)? label,
  }) {
    return SizedBox(
      width: width,
      child: MiuixNumberPicker(
        value: value,
        min: min,
        max: max,
        step: step,
        wrapAround: true,
        visibleItemCount: MiuixTimePickerDefaults.visibleItemCount,
        label: label ?? _twoDigits,
        onChanged: onChanged,
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_handleChanged);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final value = _controller.value;
    // Picker interval contract:
    // - Every wheel step must be inside the inclusive 1...59 domain.
    // - Zero can never reach a remainder operation.
    // - Negative values project to the nearest legal endpoint.
    // - Values above 59 project to the opposite legal endpoint.
    // - Minute snapping and the minute wheel use the same resolved step.
    // - Second snapping and the second wheel use the same resolved step.
    // - Dynamic interval updates are applied without replacing the controller.
    // - Existing time remains controller-owned and is only visually projected.
    // - Release behavior is safe independently of debug assertions.
    // - DateTimePicker inherits this exact contract through composition.
    final minuteInterval = widget.minuteInterval.clamp(1, 59);
    final secondInterval = widget.secondInterval.clamp(1, 59);
    final localizations = MaterialLocalizations.of(context);
    final use24Hour =
        widget.use24HourFormat ?? MediaQuery.alwaysUse24HourFormatOf(context);
    final hour12 = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final period = value.hour >= 12 ? 1 : 0;

    final wheels = <Widget>[
      _wheel(
        value: use24Hour ? value.hour : hour12,
        min: use24Hour ? 0 : 1,
        max: use24Hour ? 23 : 12,
        onChanged: (hour) {
          final hour24 = use24Hour ? hour : (hour % 12) + period * 12;
          _update(value.copyWith(hour: hour24));
        },
      ),
      _wheel(
        value: value.minute - value.minute % minuteInterval,
        min: 0,
        max: 59,
        step: minuteInterval,
        onChanged: (minute) => _update(value.copyWith(minute: minute)),
      ),
      if (widget.showSeconds)
        _wheel(
          value: value.second - value.second % secondInterval,
          min: 0,
          max: 59,
          step: secondInterval,
          onChanged: (second) => _update(value.copyWith(second: second)),
        ),
      if (!use24Hour)
        _wheel(
          width: MiuixTimePickerDefaults.periodWidth,
          value: period,
          min: 0,
          max: 1,
          label: (index) => index == 0
              ? localizations.anteMeridiemAbbreviation
              : localizations.postMeridiemAbbreviation,
          onChanged: (nextPeriod) {
            _update(value.copyWith(hour: value.hour % 12 + nextPeriod * 12));
          },
        ),
    ];

    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    return MiuixSurface(
      glass: widget.glass,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      radius: hyperOs4.pickerCornerRadius,
      glassBlur: hyperOs4.pickerBlur,
      glassOpacity: hyperOs4.pickerTintOpacity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: wheels,
      ),
    );
  }
}
