import 'package:flutter/material.dart';

import '../../platform/miuix_haptics.dart';
import '../../theme/miuix_theme.dart';
import '../../widgets/miuix_widgets.dart';

/// Externally observable duration owner for [MiuixDurationPicker].
class MiuixDurationPickerController extends ChangeNotifier {
  /// Creates a controller with a non-negative duration.
  MiuixDurationPickerController({Duration value = Duration.zero})
    : _value = value.isNegative ? Duration.zero : value;

  Duration _value;

  /// Current non-negative duration.
  Duration get value => _value;

  /// Replaces the duration, clamping negative input to zero.
  set value(Duration next) {
    final normalized = next.isNegative ? Duration.zero : next;
    if (normalized == _value) return;
    _value = normalized;
    notifyListeners();
  }
}

/// Geometry and range defaults for [MiuixDurationPicker].
abstract final class MiuixDurationPickerDefaults {
  /// Default largest selectable day count.
  static const int maximumDays = 365;

  /// Default wheel width.
  static const double wheelWidth = 82;

  /// Default visible wheel rows.
  static const int visibleItemCount = 5;

  /// Resolves the extension's locale-aware dialog and unit labels.
  ///
  /// Flutter's Material localization contract has no duration-specific
  /// labels. Keep the two package/example languages explicit and use English
  /// as the stable fallback for other locales until an application overrides
  /// the public strings.
  static MiuixDurationPickerLabels labels(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'zh'
        ? const MiuixDurationPickerLabels(
            dialogTitle: '选择时长',
            day: '天',
            hour: '时',
            minute: '分',
            second: '秒',
          )
        : const MiuixDurationPickerLabels(
            dialogTitle: 'Select duration',
            day: 'd',
            hour: 'h',
            minute: 'min',
            second: 's',
          );
  }
}

/// Locale-aware default strings used by [MiuixDurationPicker].
@immutable
class MiuixDurationPickerLabels {
  /// Creates a complete duration-picker label set.
  const MiuixDurationPickerLabels({
    required this.dialogTitle,
    required this.day,
    required this.hour,
    required this.minute,
    required this.second,
  });

  /// Dialog title and compact unit suffixes.
  final String dialogTitle;
  final String day;
  final String hour;
  final String minute;
  final String second;
}

/// Multi-column MIUIX duration picker for days through seconds.
class MiuixDurationPicker extends StatefulWidget {
  /// Creates an inline duration picker.
  const MiuixDurationPicker({
    super.key,
    this.controller,
    this.initialDuration = Duration.zero,
    this.maximumDays = MiuixDurationPickerDefaults.maximumDays,
    this.showDays = true,
    this.showHours = true,
    this.showMinutes = true,
    this.showSeconds = false,
    this.minuteInterval = 1,
    this.secondInterval = 1,
    this.onChanged,
    this.dayLabel,
    this.hourLabel,
    this.minuteLabel,
    this.secondLabel,
    this.glass = true,
  });

  /// Optional externally owned controller.
  final MiuixDurationPickerController? controller;

  /// Initial value used by the internal controller.
  final Duration initialDuration;

  /// Largest selectable day count.
  final int maximumDays;

  /// Whether each unit column is visible.
  final bool showDays;
  final bool showHours;
  final bool showMinutes;
  final bool showSeconds;

  /// Minute and second increments.
  final int minuteInterval;
  final int secondInterval;

  /// Called after the duration changes.
  final ValueChanged<Duration>? onChanged;

  /// Optional localized unit labels appended to values.
  ///
  /// Null uses [MiuixDurationPickerDefaults.labels]. Pass an empty string to
  /// deliberately render an unlabeled numeric wheel.
  final String? dayLabel;
  final String? hourLabel;
  final String? minuteLabel;
  final String? secondLabel;

  /// Whether the wheel group uses HyperOS 4 backdrop material.
  final bool glass;

  /// Opens a modal duration picker and returns the confirmed duration.
  static Future<Duration?> show({
    required BuildContext context,
    Duration initialDuration = Duration.zero,
    int maximumDays = MiuixDurationPickerDefaults.maximumDays,
    bool showDays = true,
    bool showHours = true,
    bool showMinutes = true,
    bool showSeconds = false,
    String? title,
    bool glass = true,
  }) {
    final controller = MiuixDurationPickerController(value: initialDuration);
    final localizations = MaterialLocalizations.of(context);
    final labels = MiuixDurationPickerDefaults.labels(context);
    final navigator = Navigator.of(context, rootNavigator: true);
    return MiuixDialog.show<Duration>(
      context: context,
      title: title ?? labels.dialogTitle,
      content: Flexible(
        fit: FlexFit.loose,
        child: SingleChildScrollView(
          child: MiuixDurationPicker(
            controller: controller,
            maximumDays: maximumDays,
            showDays: showDays,
            showHours: showHours,
            showMinutes: showMinutes,
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
  State<MiuixDurationPicker> createState() => _MiuixDurationPickerState();
}

class _MiuixDurationPickerState extends State<MiuixDurationPicker> {
  late MiuixDurationPickerController _controller;
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
        MiuixDurationPickerController(value: widget.initialDuration);
    _controller.addListener(_handleChanged);
  }

  @override
  void didUpdateWidget(MiuixDurationPicker oldWidget) {
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

  void _replace({int? days, int? hours, int? minutes, int? seconds}) {
    final current = _controller.value;
    final currentDays = current.inDays;
    final currentHours = current.inHours.remainder(24);
    final currentMinutes = current.inMinutes.remainder(60);
    final currentSeconds = current.inSeconds.remainder(60);
    _controller.value = Duration(
      days: days ?? currentDays,
      hours: hours ?? currentHours,
      minutes: minutes ?? currentMinutes,
      seconds: seconds ?? currentSeconds,
    );
  }

  Widget _wheel({
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
    int step = 1,
    String? unit,
  }) {
    return SizedBox(
      width: MiuixDurationPickerDefaults.wheelWidth,
      child: MiuixNumberPicker(
        value: value,
        min: min,
        max: max,
        step: step,
        visibleItemCount: MiuixDurationPickerDefaults.visibleItemCount,
        label: (number) =>
            unit == null ? number.toString().padLeft(2, '0') : '$number$unit',
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
    final maximumDays = widget.maximumDays.clamp(0, 365000);
    final minuteInterval = widget.minuteInterval.clamp(1, 59);
    final secondInterval = widget.secondInterval.clamp(1, 59);
    final labels = MiuixDurationPickerDefaults.labels(context);
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    // A remotely supplied preference can disable every optional unit at once.
    // Keep one useful minute column instead of producing an empty glass pill;
    // this is also deterministic in release where assertions are absent.
    final showFallbackMinutes =
        !widget.showDays &&
        !widget.showHours &&
        !widget.showMinutes &&
        !widget.showSeconds;
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
        children: <Widget>[
          if (widget.showDays)
            _wheel(
              value: value.inDays.clamp(0, maximumDays),
              min: 0,
              max: maximumDays,
              unit: widget.dayLabel ?? labels.day,
              onChanged: (days) => _replace(days: days),
            ),
          if (widget.showHours)
            _wheel(
              value: value.inHours.remainder(24),
              min: 0,
              max: 23,
              unit: widget.hourLabel ?? labels.hour,
              onChanged: (hours) => _replace(hours: hours),
            ),
          if (widget.showMinutes || showFallbackMinutes)
            _wheel(
              value:
                  value.inMinutes.remainder(60) -
                  value.inMinutes.remainder(60) % minuteInterval,
              min: 0,
              max: 59,
              step: minuteInterval,
              unit: widget.minuteLabel ?? labels.minute,
              onChanged: (minutes) => _replace(minutes: minutes),
            ),
          if (widget.showSeconds)
            _wheel(
              value:
                  value.inSeconds.remainder(60) -
                  value.inSeconds.remainder(60) % secondInterval,
              min: 0,
              max: 59,
              step: secondInterval,
              unit: widget.secondLabel ?? labels.second,
              onChanged: (seconds) => _replace(seconds: seconds),
            ),
        ],
      ),
    );
  }
}
