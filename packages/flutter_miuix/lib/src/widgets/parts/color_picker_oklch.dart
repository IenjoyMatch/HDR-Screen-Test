part of '../miuix_widgets.dart';

class MiuixOkLchLightnessSlider extends StatelessWidget {
  const MiuixOkLchLightnessSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.chroma = .2,
    this.hue = 0,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
  });

  /// Creates a lightness control with the source parameter names and units.
  const MiuixOkLchLightnessSlider.source({
    super.key,
    required double currentL,
    required double currentC,
    required double currentH,
    required ValueChanged<double> onLightnessChanged,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
  }) : value = currentL,
       onChanged = onLightnessChanged,
       chroma = currentC * .4,
       hue = currentH * 360;

  final double value;
  final ValueChanged<double>? onChanged;
  final double chroma;
  final double hue;
  final MiuixSliderHapticEffect hapticEffect;

  @override
  Widget build(BuildContext context) => _MiuixPerceptualColorSlider(
    value: value,
    onChanged: onChanged,
    hapticEffect: hapticEffect,
    colors: [
      MiuixOkLch(lightness: 0, chroma: chroma, hue: hue).toColor(),
      MiuixOkLch(lightness: 1, chroma: chroma, hue: hue).toColor(),
    ],
  );
}

/// OKLCH chroma slider. Public values are normalized to 0..1.
class MiuixOkLchChromaSlider extends StatelessWidget {
  const MiuixOkLchChromaSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.lightness = .7,
    this.hue = 0,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
  });

  /// Creates a chroma control with the source parameter names and units.
  const MiuixOkLchChromaSlider.source({
    super.key,
    required double currentL,
    required double currentC,
    required double currentH,
    required ValueChanged<double> onChromaChanged,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
  }) : value = currentC,
       onChanged = onChromaChanged,
       lightness = currentL,
       hue = currentH * 360;

  final double value;
  final ValueChanged<double>? onChanged;
  final double lightness;
  final double hue;
  final MiuixSliderHapticEffect hapticEffect;

  @override
  Widget build(BuildContext context) => _MiuixPerceptualColorSlider(
    value: value,
    onChanged: onChanged,
    hapticEffect: hapticEffect,
    colors: [
      MiuixOkLch(lightness: lightness, chroma: 0, hue: hue).toColor(),
      MiuixOkLch(lightness: lightness, chroma: .4, hue: hue).toColor(),
    ],
  );
}

/// OKLCH hue slider. Public values are normalized to 0..1.
class MiuixOkLchHueSlider extends StatelessWidget {
  const MiuixOkLchHueSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.lightness = .7,
    this.chroma = .2,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
  });

  /// Creates a hue control with the source parameter names and units.
  const MiuixOkLchHueSlider.source({
    super.key,
    required double currentL,
    required double currentC,
    required double currentH,
    required ValueChanged<double> onHueChanged,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
  }) : value = currentH,
       onChanged = onHueChanged,
       lightness = currentL,
       chroma = currentC * .4;

  final double value;
  final ValueChanged<double>? onChanged;
  final double lightness;
  final double chroma;
  final MiuixSliderHapticEffect hapticEffect;

  @override
  Widget build(BuildContext context) => _MiuixPerceptualColorSlider(
    value: value,
    onChanged: onChanged,
    hapticEffect: hapticEffect,
    colors: [
      for (var index = 0; index <= 36; index++)
        MiuixOkLch(
          lightness: lightness,
          chroma: chroma,
          hue: index * 10,
        ).toColor(),
    ],
  );
}

/// OKLCH alpha slider.
class MiuixOkLchAlphaSlider extends StatelessWidget {
  const MiuixOkLchAlphaSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.lightness = .7,
    this.chroma = .2,
    this.hue = 0,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
  });

  /// Creates an alpha control with the source parameter names and units.
  const MiuixOkLchAlphaSlider.source({
    super.key,
    required double currentL,
    required double currentC,
    required double currentH,
    required double currentAlpha,
    required ValueChanged<double> onAlphaChanged,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
  }) : value = currentAlpha,
       onChanged = onAlphaChanged,
       lightness = currentL,
       chroma = currentC * .4,
       hue = currentH * 360;

  final double value;
  final ValueChanged<double>? onChanged;
  final double lightness;
  final double chroma;
  final double hue;
  final MiuixSliderHapticEffect hapticEffect;

  @override
  Widget build(BuildContext context) => _MiuixHsvAlphaSlider(
    value: value.clamp(0.0, 1.0),
    baseColor: MiuixOkLch(
      lightness: lightness,
      chroma: chroma,
      hue: hue,
    ).toColor(),
    onChanged: onChanged,
    hapticEffect: hapticEffect,
  );
}
