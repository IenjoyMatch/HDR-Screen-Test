part of '../miuix_widgets.dart';

/// HSV color picker adapter.
class MiuixHsvColorPicker extends MiuixColorPicker {
  /// Creates an HSV color picker.
  const MiuixHsvColorPicker({
    super.key,
    required super.color,
    required super.onChanged,
    super.showPreview,
    super.hapticEffect,
  }) : super(colorSpace: MiuixColorSpace.hsv);

  /// Creates an HSV picker with the source callback name.
  const MiuixHsvColorPicker.source({
    super.key,
    required super.color,
    required ValueChanged<Color> onColorChanged,
    super.showPreview,
    super.hapticEffect,
  }) : super(onChanged: onColorChanged, colorSpace: MiuixColorSpace.hsv);
}

/// OKHSV color picker adapter.
class MiuixOkHsvColorPicker extends MiuixColorPicker {
  /// Creates an OKHSV color picker.
  const MiuixOkHsvColorPicker({
    super.key,
    required super.color,
    required super.onChanged,
    super.showPreview,
    super.hapticEffect,
  }) : super(colorSpace: MiuixColorSpace.okHsv);

  /// Creates an OKHSV picker with the source callback name.
  const MiuixOkHsvColorPicker.source({
    super.key,
    required super.color,
    required ValueChanged<Color> onColorChanged,
    super.showPreview,
    super.hapticEffect,
  }) : super(onChanged: onColorChanged, colorSpace: MiuixColorSpace.okHsv);
}

/// OKLab color picker adapter.
class MiuixOkLabColorPicker extends MiuixColorPicker {
  /// Creates an OKLab color picker.
  const MiuixOkLabColorPicker({
    super.key,
    required super.color,
    required super.onChanged,
    super.showPreview,
    super.hapticEffect,
  }) : super(colorSpace: MiuixColorSpace.okLab);

  /// Creates an OKLab picker with the source callback name.
  const MiuixOkLabColorPicker.source({
    super.key,
    required super.color,
    required ValueChanged<Color> onColorChanged,
    super.showPreview,
    super.hapticEffect,
  }) : super(onChanged: onColorChanged, colorSpace: MiuixColorSpace.okLab);
}

/// OKLCH color picker adapter.
class MiuixOkLchColorPicker extends MiuixColorPicker {
  /// Creates an OKLCH color picker.
  const MiuixOkLchColorPicker({
    super.key,
    required super.color,
    required super.onChanged,
    super.showPreview,
    super.hapticEffect,
  }) : super(colorSpace: MiuixColorSpace.okLch);

  /// Creates an OKLCH picker with the source callback name.
  const MiuixOkLchColorPicker.source({
    super.key,
    required super.color,
    required ValueChanged<Color> onColorChanged,
    super.showPreview,
    super.hapticEffect,
  }) : super(onChanged: onColorChanged, colorSpace: MiuixColorSpace.okLch);
}

/// Hue slider adapter for color pickers.
class MiuixHsvHueSlider extends StatelessWidget {
  /// Creates a hue slider.
  const MiuixHsvHueSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
  }) : _sourceCallbackIsNormalized = false;

  /// Creates a hue control with `HsvHueSlider`'s source names and units.
  const MiuixHsvHueSlider.source({
    super.key,
    required double currentHue,
    required ValueChanged<double> onHueChanged,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
  }) : value = currentHue,
       onChanged = onHueChanged,
       _sourceCallbackIsNormalized = true;

  /// Current hue in degrees from 0 through 360.
  final double value;

  /// Called with the new hue in degrees.
  final ValueChanged<double>? onChanged;

  /// Source feedback strategy.
  final MiuixSliderHapticEffect hapticEffect;

  final bool _sourceCallbackIsNormalized;

  @override
  Widget build(BuildContext context) => _MiuixHsvChannelSlider(
    value: (_finiteOr(value, 0) / 360).clamp(0.0, 1.0),
    colors: _hsvHueSliderColors(),
    onChanged: onChanged == null
        ? null
        : (next) => onChanged!(_sourceCallbackIsNormalized ? next : next * 360),
    hapticEffect: hapticEffect,
  );
}

/// Saturation slider adapter for color pickers.
class MiuixHsvSaturationSlider extends StatelessWidget {
  /// Creates a saturation slider.
  const MiuixHsvSaturationSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.currentHue = 0,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
  });

  /// Creates a saturation control with the source parameter names.
  const MiuixHsvSaturationSlider.source({
    super.key,
    required this.currentHue,
    required double currentSaturation,
    required ValueChanged<double> onSaturationChanged,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
  }) : value = currentSaturation,
       onChanged = onSaturationChanged;

  /// Current saturation from 0 through 1.
  final double value;

  /// Called with the new saturation.
  final ValueChanged<double>? onChanged;

  /// Hue in degrees used to construct the source gradient.
  final double currentHue;

  /// Source feedback strategy.
  final MiuixSliderHapticEffect hapticEffect;

  @override
  Widget build(BuildContext context) {
    final hue = _finiteOr(currentHue, 0) % 360;
    return _MiuixHsvChannelSlider(
      value: value,
      colors: [
        HSVColor.fromAHSV(1, hue, 0, 1).toColor(),
        HSVColor.fromAHSV(1, hue, 1, 1).toColor(),
      ],
      onChanged: onChanged,
      hapticEffect: hapticEffect,
    );
  }
}

/// Value slider adapter for color pickers.
class MiuixHsvValueSlider extends StatelessWidget {
  /// Creates a value slider.
  const MiuixHsvValueSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.currentHue = 0,
    this.currentSaturation = 1,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
  });

  /// Creates a value control with the source parameter names.
  const MiuixHsvValueSlider.source({
    super.key,
    required this.currentHue,
    required this.currentSaturation,
    required double currentValue,
    required ValueChanged<double> onValueChanged,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
  }) : value = currentValue,
       onChanged = onValueChanged;

  /// Current brightness/value from 0 through 1.
  final double value;

  /// Called with the new brightness/value.
  final ValueChanged<double>? onChanged;

  /// Hue in degrees used to construct the source gradient.
  final double currentHue;

  /// Saturation used to construct the source gradient.
  final double currentSaturation;

  /// Source feedback strategy.
  final MiuixSliderHapticEffect hapticEffect;

  @override
  Widget build(BuildContext context) => _MiuixHsvChannelSlider(
    value: value,
    colors: [
      Colors.black,
      HSVColor.fromAHSV(
        1,
        _finiteOr(currentHue, 0) % 360,
        _finiteOr(currentSaturation, 1).clamp(0.0, 1.0),
        1,
      ).toColor(),
    ],
    onChanged: onChanged,
    hapticEffect: hapticEffect,
  );
}

/// Alpha slider adapter for color pickers.
class MiuixHsvAlphaSlider extends StatelessWidget {
  /// Creates an alpha slider.
  const MiuixHsvAlphaSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.currentHue = 0,
    this.currentSaturation = 1,
    this.currentValue = 1,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
  });

  /// Creates an alpha control with the source parameter names.
  const MiuixHsvAlphaSlider.source({
    super.key,
    required this.currentHue,
    required this.currentSaturation,
    required this.currentValue,
    required double currentAlpha,
    required ValueChanged<double> onAlphaChanged,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
  }) : value = currentAlpha,
       onChanged = onAlphaChanged;

  /// Current alpha from 0 through 1.
  final double value;

  /// Called with the new alpha.
  final ValueChanged<double>? onChanged;

  /// Hue in degrees used to construct the source gradient.
  final double currentHue;

  /// Saturation used to construct the source gradient.
  final double currentSaturation;

  /// Brightness/value used to construct the source gradient.
  final double currentValue;

  /// Source feedback strategy.
  final MiuixSliderHapticEffect hapticEffect;

  @override
  Widget build(BuildContext context) => _MiuixHsvAlphaSlider(
    value: value.clamp(0.0, 1.0),
    baseColor: HSVColor.fromAHSV(
      1,
      _finiteOr(currentHue, 0) % 360,
      _finiteOr(currentSaturation, 1).clamp(0.0, 1.0),
      _finiteOr(currentValue, 1).clamp(0.0, 1.0),
    ).toColor(),
    onChanged: onChanged,
    hapticEffect: hapticEffect,
  );
}
