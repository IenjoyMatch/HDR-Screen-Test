part of '../miuix_widgets.dart';

/// MIUIX color picker supporting HSV, OKHSV, OKLab, and OKLCH.
class MiuixColorPicker extends StatefulWidget {
  /// Creates a color picker.
  const MiuixColorPicker({
    super.key,
    required this.color,
    required this.onChanged,
    this.colorSpace = MiuixColorSpace.hsv,
    this.showPreview = true,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
  });

  /// Creates a picker with the parameter names used by `ColorPicker.kt`.
  const MiuixColorPicker.source({
    super.key,
    required this.color,
    required ValueChanged<Color> onColorChanged,
    this.colorSpace = MiuixColorSpace.hsv,
    this.showPreview = true,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
  }) : onChanged = onColorChanged;

  /// Current color.
  final Color color;

  /// Change callback.
  final ValueChanged<Color> onChanged;

  /// Color space used by the channel controls.
  final MiuixColorSpace colorSpace;

  /// Whether the selected-color capsule is visible.
  final bool showPreview;

  /// Source slider feedback strategy shared by all four channels.
  final MiuixSliderHapticEffect hapticEffect;

  @override
  State<MiuixColorPicker> createState() => _MiuixColorPickerState();
}

class _MiuixColorPickerState extends State<MiuixColorPicker> {
  late double _channel1;
  late double _channel2;
  late double _channel3;
  late double _alpha;
  late int _lastExternalColor;

  @override
  void initState() {
    super.initState();
    _syncFromExternalColor();
  }

  @override
  void didUpdateWidget(covariant MiuixColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    final external = widget.color.toARGB32();
    final internal = _selectedColor.toARGB32();
    if (oldWidget.colorSpace != widget.colorSpace ||
        (external != _lastExternalColor && external != internal)) {
      _syncFromExternalColor();
    } else if (external == internal) {
      _lastExternalColor = external;
    }
  }

  Color get _selectedColor {
    return switch (widget.colorSpace) {
      MiuixColorSpace.hsv => HSVColor.fromAHSV(
        _alpha,
        _channel1 * 360,
        _channel2,
        _channel3,
      ).toColor(),
      MiuixColorSpace.okHsv => MiuixOkHsv(
        hue: _channel1,
        saturation: _channel2,
        value: _channel3,
        alpha: _alpha,
      ).toColor(),
      MiuixColorSpace.okLab => MiuixOkLab(
        lightness: _channel1,
        a: _channel2 * .6 - .3,
        b: _channel3 * .6 - .3,
        alpha: _alpha,
      ).toColor(),
      MiuixColorSpace.okLch => MiuixOkLch(
        lightness: _channel2,
        chroma: _channel3 * .4,
        hue: _channel1 * 360,
        alpha: _alpha,
      ).toColor(),
    };
  }

  void _syncFromExternalColor() {
    switch (widget.colorSpace) {
      case MiuixColorSpace.hsv:
        final hsv = HSVColor.fromColor(widget.color);
        _channel1 = (_finiteOr(hsv.hue, 0) / 360).clamp(0.0, 1.0);
        _channel2 = _finiteOr(hsv.saturation, 0).clamp(0.0, 1.0);
        _channel3 = _finiteOr(hsv.value, 0).clamp(0.0, 1.0);
      case MiuixColorSpace.okHsv:
        final ok = MiuixOkHsv.fromColor(widget.color);
        _channel1 = _finiteOr(ok.hue, 0).clamp(0.0, 1.0);
        _channel2 = _finiteOr(ok.saturation, 0).clamp(0.0, 1.0);
        _channel3 = _finiteOr(ok.value, 0).clamp(0.0, 1.0);
      case MiuixColorSpace.okLab:
        final ok = MiuixOkLab.fromColor(widget.color);
        _channel1 = _finiteOr(ok.lightness, 0).clamp(0.0, 1.0);
        _channel2 = ((_finiteOr(ok.a, 0) + .3) / .6).clamp(0.0, 1.0);
        _channel3 = ((_finiteOr(ok.b, 0) + .3) / .6).clamp(0.0, 1.0);
      case MiuixColorSpace.okLch:
        final ok = MiuixOkLch.fromColor(widget.color);
        _channel1 = (_finiteOr(ok.hue, 0) / 360).clamp(0.0, 1.0);
        _channel2 = _finiteOr(ok.lightness, 0).clamp(0.0, 1.0);
        _channel3 = (_finiteOr(ok.chroma, 0) / .4).clamp(0.0, 1.0);
    }
    _alpha = _finiteOr(widget.color.a, 1).clamp(0.0, 1.0);
    _lastExternalColor = widget.color.toARGB32();
  }

  void _update({double? first, double? second, double? third, double? alpha}) {
    final nextFirst = _finiteOr(first ?? _channel1, _channel1).clamp(0.0, 1.0);
    final nextSecond = _finiteOr(
      second ?? _channel2,
      _channel2,
    ).clamp(0.0, 1.0);
    final nextThird = _finiteOr(third ?? _channel3, _channel3).clamp(0.0, 1.0);
    final nextAlpha = _finiteOr(alpha ?? _alpha, _alpha).clamp(0.0, 1.0);
    if (nextFirst == _channel1 &&
        nextSecond == _channel2 &&
        nextThird == _channel3 &&
        nextAlpha == _alpha) {
      return;
    }
    setState(() {
      _channel1 = nextFirst;
      _channel2 = nextSecond;
      _channel3 = nextThird;
      _alpha = nextAlpha;
    });
    final color = _selectedColor;
    _lastExternalColor = color.toARGB32();
    if (color.toARGB32() != widget.color.toARGB32()) {
      widget.onChanged(color);
    }
  }

  List<Color> _firstChannelColors() {
    return switch (widget.colorSpace) {
      MiuixColorSpace.hsv => _hsvHueSliderColors(),
      MiuixColorSpace.okHsv => [
        for (var index = 0; index <= 36; index++)
          MiuixOkHsv(hue: index / 36, saturation: 1, value: 1).toColor(),
      ],
      MiuixColorSpace.okLab => [
        for (var index = 0; index <= 7; index++)
          MiuixOkLab(
            lightness: index / 7,
            a: _channel2 * .6 - .3,
            b: _channel3 * .6 - .3,
          ).toColor(),
      ],
      MiuixColorSpace.okLch => [
        for (var index = 0; index <= 36; index++)
          MiuixOkLch(
            lightness: _channel2,
            chroma: _channel3 * .4,
            hue: index * 10,
          ).toColor(),
      ],
    };
  }

  List<Color> _secondChannelColors() {
    return switch (widget.colorSpace) {
      MiuixColorSpace.hsv => [
        HSVColor.fromAHSV(1, _channel1 * 360, 0, 1).toColor(),
        HSVColor.fromAHSV(1, _channel1 * 360, 1, 1).toColor(),
      ],
      MiuixColorSpace.okHsv => [
        MiuixOkHsv(hue: _channel1, saturation: 0, value: _channel3).toColor(),
        MiuixOkHsv(hue: _channel1, saturation: 1, value: _channel3).toColor(),
      ],
      MiuixColorSpace.okLab => [
        for (var index = 0; index <= 8; index++)
          MiuixOkLab(
            lightness: _channel1,
            a: -.3 + .6 * index / 8,
            b: _channel3 * .6 - .3,
          ).toColor(),
      ],
      MiuixColorSpace.okLch => [
        MiuixOkLch(
          lightness: 0,
          chroma: _channel3 * .4,
          hue: _channel1 * 360,
        ).toColor(),
        MiuixOkLch(
          lightness: 1,
          chroma: _channel3 * .4,
          hue: _channel1 * 360,
        ).toColor(),
      ],
    };
  }

  List<Color> _thirdChannelColors() {
    return switch (widget.colorSpace) {
      MiuixColorSpace.hsv => [
        Colors.black,
        HSVColor.fromAHSV(1, _channel1 * 360, _channel2, 1).toColor(),
      ],
      MiuixColorSpace.okHsv => [
        Colors.black,
        MiuixOkHsv(hue: _channel1, saturation: _channel2, value: 1).toColor(),
      ],
      MiuixColorSpace.okLab => [
        for (var index = 0; index <= 8; index++)
          MiuixOkLab(
            lightness: _channel1,
            a: _channel2 * .6 - .3,
            b: -.3 + .6 * index / 8,
          ).toColor(),
      ],
      MiuixColorSpace.okLch => [
        MiuixOkLch(
          lightness: _channel2,
          chroma: 0,
          hue: _channel1 * 360,
        ).toColor(),
        MiuixOkLch(
          lightness: _channel2,
          chroma: .4,
          hue: _channel1 * 360,
        ).toColor(),
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _selectedColor;
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final sourceSliderHeight = _miuixRoundLogicalDimension(26, pixelRatio);
    final sourceSpacing = _miuixRoundLogicalDimension(12, pixelRatio);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showPreview) ...[
          _miuixColorShapeClip(
            context,
            clipKey: const ValueKey('miuix-color-picker-preview-clip'),
            radius: sourceSliderHeight / 2,
            child: SizedBox(
              height: sourceSliderHeight,
              child: DecoratedBox(decoration: BoxDecoration(color: color)),
            ),
          ),
          SizedBox(height: sourceSpacing),
        ],
        _MiuixHsvChannelSlider(
          sliderKey: const ValueKey('miuix-color-picker-hue-slider'),
          value: _channel1,
          colors: _firstChannelColors(),
          onChanged: (value) => _update(first: value),
          hapticEffect: widget.hapticEffect,
        ),
        SizedBox(height: sourceSpacing),
        _MiuixHsvChannelSlider(
          sliderKey: const ValueKey('miuix-color-picker-saturation-slider'),
          value: _channel2,
          colors: _secondChannelColors(),
          onChanged: (value) => _update(second: value),
          hapticEffect: widget.hapticEffect,
        ),
        SizedBox(height: sourceSpacing),
        _MiuixHsvChannelSlider(
          sliderKey: const ValueKey('miuix-color-picker-value-slider'),
          value: _channel3,
          colors: _thirdChannelColors(),
          onChanged: (value) => _update(third: value),
          hapticEffect: widget.hapticEffect,
        ),
        SizedBox(height: sourceSpacing),
        _MiuixHsvAlphaSlider(
          value: _alpha,
          baseColor: color.withValues(alpha: 1),
          onChanged: (value) => _update(alpha: value),
          hapticEffect: widget.hapticEffect,
        ),
      ],
    );
  }
}

List<Color> _hsvHueSliderColors() {
  return [
    for (final hue in const [0.0, 60.0, 120.0, 180.0, 240.0, 300.0, 360.0])
      HSVColor.fromAHSV(1, hue, 1, 1).toColor(),
  ];
}
