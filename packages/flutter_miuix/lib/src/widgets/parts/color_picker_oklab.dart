part of '../miuix_widgets.dart';

class MiuixOkLabLightnessSlider extends StatelessWidget {
  const MiuixOkLabLightnessSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.a = 0,
    this.b = 0,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
  });

  /// Creates a lightness control with the source parameter names.
  const MiuixOkLabLightnessSlider.source({
    super.key,
    required double currentL,
    required double currentA,
    required double currentB,
    required ValueChanged<double> onLightnessChanged,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
  }) : value = currentL,
       onChanged = onLightnessChanged,
       a = currentA,
       b = currentB;

  final double value;
  final ValueChanged<double>? onChanged;
  final double a;
  final double b;
  final MiuixSliderHapticEffect hapticEffect;

  @override
  Widget build(BuildContext context) => _MiuixPerceptualColorSlider(
    value: value,
    onChanged: onChanged,
    hapticEffect: hapticEffect,
    colors: [
      for (var index = 0; index <= 7; index++)
        MiuixOkLab(lightness: index / 7, a: a, b: b).toColor(),
    ],
  );
}

/// OKLab green-red A-channel slider in the -0.3..0.3 source range.
class MiuixOkLabAChannelSlider extends StatelessWidget {
  const MiuixOkLabAChannelSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.lightness = .7,
    this.b = 0,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
  });

  /// Creates an A-channel control with the source parameter names.
  const MiuixOkLabAChannelSlider.source({
    super.key,
    required double currentL,
    required double currentA,
    required double currentB,
    required ValueChanged<double> onAChanged,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
  }) : value = currentA,
       onChanged = onAChanged,
       lightness = currentL,
       b = currentB;

  final double value;
  final ValueChanged<double>? onChanged;
  final double lightness;
  final double b;
  final MiuixSliderHapticEffect hapticEffect;

  @override
  Widget build(BuildContext context) => _MiuixPerceptualColorSlider(
    value: value,
    min: -.3,
    max: .3,
    onChanged: onChanged,
    hapticEffect: hapticEffect,
    colors: [
      for (var index = 0; index <= 8; index++)
        MiuixOkLab(
          lightness: lightness,
          a: -.3 + .6 * index / 8,
          b: b,
        ).toColor(),
    ],
  );
}

/// OKLab blue-yellow B-channel slider in the -0.3..0.3 source range.
class MiuixOkLabBChannelSlider extends StatelessWidget {
  const MiuixOkLabBChannelSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.lightness = .7,
    this.a = 0,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
  });

  /// Creates a B-channel control with the source parameter names.
  const MiuixOkLabBChannelSlider.source({
    super.key,
    required double currentL,
    required double currentA,
    required double currentB,
    required ValueChanged<double> onBChanged,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
  }) : value = currentB,
       onChanged = onBChanged,
       lightness = currentL,
       a = currentA;

  final double value;
  final ValueChanged<double>? onChanged;
  final double lightness;
  final double a;
  final MiuixSliderHapticEffect hapticEffect;

  @override
  Widget build(BuildContext context) => _MiuixPerceptualColorSlider(
    value: value,
    min: -.3,
    max: .3,
    onChanged: onChanged,
    hapticEffect: hapticEffect,
    colors: [
      for (var index = 0; index <= 8; index++)
        MiuixOkLab(
          lightness: lightness,
          a: a,
          b: -.3 + .6 * index / 8,
        ).toColor(),
    ],
  );
}

/// OKLab alpha slider.
class MiuixOkLabAlphaSlider extends StatelessWidget {
  const MiuixOkLabAlphaSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.lightness = .7,
    this.a = 0,
    this.b = 0,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
  });

  /// Creates an alpha control with the source parameter names.
  const MiuixOkLabAlphaSlider.source({
    super.key,
    required double currentL,
    required double currentA,
    required double currentB,
    required double currentAlpha,
    required ValueChanged<double> onAlphaChanged,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
  }) : value = currentAlpha,
       onChanged = onAlphaChanged,
       lightness = currentL,
       a = currentA,
       b = currentB;

  final double value;
  final ValueChanged<double>? onChanged;
  final double lightness;
  final double a;
  final double b;
  final MiuixSliderHapticEffect hapticEffect;

  @override
  Widget build(BuildContext context) => _MiuixHsvAlphaSlider(
    value: value.clamp(0.0, 1.0),
    baseColor: MiuixOkLab(lightness: lightness, a: a, b: b).toColor(),
    onChanged: onChanged,
    hapticEffect: hapticEffect,
  );
}

/// OKLCH lightness slider.
