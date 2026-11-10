part of '../miuix_widgets.dart';

class _MiuixPerceptualColorSlider extends StatelessWidget {
  const _MiuixPerceptualColorSlider({
    required this.value,
    required this.onChanged,
    required this.colors,
    this.min = 0,
    this.max = 1,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
  });

  final double value;
  final ValueChanged<double>? onChanged;
  final List<Color> colors;
  final double min;
  final double max;
  final MiuixSliderHapticEffect hapticEffect;

  @override
  Widget build(BuildContext context) {
    final span = max - min;
    final normalized = span <= 0
        ? 0.0
        : ((_finiteOr(value, min) - min) / span).clamp(0.0, 1.0);
    return _MiuixHsvChannelSlider(
      value: normalized,
      colors: colors,
      onChanged: onChanged == null
          ? null
          : (next) => onChanged!(min + next * span),
      hapticEffect: hapticEffect,
    );
  }
}

/// Perceptually uniform OKHSV hue slider. Values are normalized to 0..1.
class MiuixOkHsvHueSlider extends StatelessWidget {
  const MiuixOkHsvHueSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
  });

  /// Creates a hue control with the source parameter names.
  const MiuixOkHsvHueSlider.source({
    super.key,
    required double currentH,
    required ValueChanged<double> onHueChanged,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
  }) : value = currentH,
       onChanged = onHueChanged;

  final double value;
  final ValueChanged<double>? onChanged;
  final MiuixSliderHapticEffect hapticEffect;

  @override
  Widget build(BuildContext context) {
    return _MiuixPerceptualColorSlider(
      value: value,
      onChanged: onChanged,
      hapticEffect: hapticEffect,
      colors: [
        for (var index = 0; index <= 36; index++)
          MiuixOkHsv(hue: index / 36, saturation: 1, value: 1).toColor(),
      ],
    );
  }
}

/// OKHSV saturation slider.
class MiuixOkHsvSaturationSlider extends StatelessWidget {
  const MiuixOkHsvSaturationSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.hue = 0,
    this.brightness = 1,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
  });

  /// Creates a saturation control with the source parameter names.
  const MiuixOkHsvSaturationSlider.source({
    super.key,
    required double currentH,
    required double currentS,
    required ValueChanged<double> onSaturationChanged,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
  }) : value = currentS,
       onChanged = onSaturationChanged,
       hue = currentH,
       brightness = 1;

  final double value;
  final ValueChanged<double>? onChanged;
  final double hue;
  final double brightness;
  final MiuixSliderHapticEffect hapticEffect;

  @override
  Widget build(BuildContext context) => _MiuixPerceptualColorSlider(
    value: value,
    onChanged: onChanged,
    hapticEffect: hapticEffect,
    colors: [
      MiuixOkHsv(hue: hue, saturation: 0, value: brightness).toColor(),
      MiuixOkHsv(hue: hue, saturation: 1, value: brightness).toColor(),
    ],
  );
}

/// OKHSV value/brightness slider.
class MiuixOkHsvValueSlider extends StatelessWidget {
  const MiuixOkHsvValueSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.hue = 0,
    this.saturation = 1,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
  });

  /// Creates a value control with the source parameter names.
  const MiuixOkHsvValueSlider.source({
    super.key,
    required double currentH,
    required double currentS,
    required double currentV,
    required ValueChanged<double> onValueChanged,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
  }) : value = currentV,
       onChanged = onValueChanged,
       hue = currentH,
       saturation = currentS;

  final double value;
  final ValueChanged<double>? onChanged;
  final double hue;
  final double saturation;
  final MiuixSliderHapticEffect hapticEffect;

  @override
  Widget build(BuildContext context) => _MiuixPerceptualColorSlider(
    value: value,
    onChanged: onChanged,
    hapticEffect: hapticEffect,
    colors: [
      Colors.black,
      MiuixOkHsv(hue: hue, saturation: saturation, value: 1).toColor(),
    ],
  );
}

/// OKHSV alpha slider with checkerboard transparency backing.
class MiuixOkHsvAlphaSlider extends StatelessWidget {
  const MiuixOkHsvAlphaSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.hue = 0,
    this.saturation = 1,
    this.brightness = 1,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
  });

  /// Creates an alpha control with the source parameter names.
  const MiuixOkHsvAlphaSlider.source({
    super.key,
    required double currentH,
    required double currentS,
    required double currentV,
    required double currentAlpha,
    required ValueChanged<double> onAlphaChanged,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
  }) : value = currentAlpha,
       onChanged = onAlphaChanged,
       hue = currentH,
       saturation = currentS,
       brightness = currentV;

  final double value;
  final ValueChanged<double>? onChanged;
  final double hue;
  final double saturation;
  final double brightness;
  final MiuixSliderHapticEffect hapticEffect;

  @override
  Widget build(BuildContext context) => _MiuixHsvAlphaSlider(
    value: value.clamp(0.0, 1.0),
    baseColor: MiuixOkHsv(
      hue: hue,
      saturation: saturation,
      value: brightness,
    ).toColor(),
    onChanged: onChanged,
    hapticEffect: hapticEffect,
  );
}

/// OKLab lightness slider.
