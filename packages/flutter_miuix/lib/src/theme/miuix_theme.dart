import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:libmonet/material_color_utilities.dart' as monet;

import 'hyperos4_tokens.dart';
import 'miuix_semantic_colors.dart';

const _miuixDefaultFixedKeyColor = Color(0xFF3482FF);
const _miuixFallbackDynamicKeyColor = Color(0xFF6750A4);

/// Supported color strategy values for [MiuixThemeData].
///
/// The names intentionally mirror the Kotlin MIUIX controller modes so apps can
/// migrate design decisions between Compose and Flutter with low friction.
enum MiuixColorMode {
  /// Follow the current platform brightness.
  system,

  /// Always use the light color palette.
  light,

  /// Always use the dark color palette.
  dark,

  /// Follow platform brightness while using a Monet-generated palette.
  monetSystem,

  /// Always use the light Monet-generated palette.
  monetLight,

  /// Always use the dark Monet-generated palette.
  monetDark,
}

/// Five global strengths for MIUIX liquid-glass surfaces.
///
/// Higher levels increase backdrop blur while reducing the surface tint
/// opacity, so content behind a supported component remains more visible.
enum MiuixGlassIntensity {
  /// Nearly opaque glass with half of the component's requested blur.
  subtle(blurScale: .50, opacityScale: 1.25),

  /// Restrained glass for dense or performance-sensitive interfaces.
  light(blurScale: .75, opacityScale: 1.12),

  /// Source-compatible default that preserves existing component values.
  standard(blurScale: 1, opacityScale: 1),

  /// Stronger blur with a more transparent surface tint.
  strong(blurScale: 1.35, opacityScale: .65),

  /// Most pronounced glass level with maximum backdrop visibility.
  ///
  /// A fifth-level surface must still expose the shapes and chroma below it.
  /// The previous 45% tint multiplier left pale MIUIX surfaces looking almost
  /// solid after the specular layer was composited, even though a backdrop
  /// filter was technically present.
  intense(blurScale: 2.25, opacityScale: .22);

  const MiuixGlassIntensity({
    required this.blurScale,
    required this.opacityScale,
  });

  /// Multiplier applied to a component's source blur radius.
  final double blurScale;

  /// Multiplier applied to a component's source tint opacity.
  final double opacityScale;

  /// Resolves a component blur value for this level.
  double resolveBlur(double sourceBlur) => math.max(0, sourceBlur * blurScale);

  /// Resolves and safely clamps a component surface opacity.
  double resolveOpacity(double sourceOpacity) =>
      (sourceOpacity * opacityScale).clamp(0.0, 1.0).toDouble();
}

/// Legacy Flutter color-source metadata.
///
/// This predates the current six-branch upstream controller and remains only
/// for source compatibility through [MiuixThemeController.schemeMode]. New
/// code should use [MiuixColorMode], which represents the actual MIUIX
/// `ColorSchemeMode` values.
enum MiuixColorSchemeMode {
  /// Use the built-in default seed palette.
  preset,

  /// Use a caller-provided seed color.
  custom,

  /// Follow platform dynamic color where an app wires it in.
  dynamic,
}

/// Palette style hint used by [MiuixThemeController].
///
/// The current implementation keeps this as semantic metadata so apps can
/// coordinate their own brand choices while widgets keep a consistent API.
enum MiuixThemePaletteStyle {
  /// Pastel system palette used by the source default.
  tonalSpot,

  /// Near-neutral palette with restrained chroma.
  neutral,

  /// High-chroma Material palette.
  vibrant,

  /// Medium-chroma palette with shifted supporting hues.
  expressive,

  /// Playful palette that rotates away from the seed hue.
  rainbow,

  /// Playful palette with a split complementary character.
  fruitSalad,

  /// Grayscale palette.
  monochrome,

  /// Palette that closely preserves the selected key color.
  fidelity,

  /// Content-derived palette close to fidelity.
  content,
}

/// Material color specification used by Monet palette generation.
enum MiuixThemeColorSpec {
  /// Material 2021 dynamic-color rules.
  spec2021,

  /// Material 2025 dynamic-color rules where supported upstream.
  spec2025,
}

/// Theme controller matching MIUIX's `ThemeController` color contract.
///
/// The source controller stores a fixed light/dark pair, an optional Monet key
/// color, palette metadata, and an optional system-brightness override. Flutter
/// additionally exposes mutation methods so one controller can drive a live
/// widget tree without being recreated by its owner.
class MiuixThemeController extends ChangeNotifier {
  /// Creates a source-equivalent controller.
  ///
  /// [platformDynamicLightColors] and [platformDynamicDarkColors] are the
  /// Flutter bridge for `platformDynamicColors`. When omitted, Monet modes with
  /// a null [keyColor] use MIUIX's cross-platform purple fallback.
  factory MiuixThemeController({
    MiuixColorMode colorSchemeMode = MiuixColorMode.system,
    ColorScheme? lightColors,
    ColorScheme? darkColors,
    Color? keyColor,
    MiuixThemeColorSpec colorSpec = MiuixThemeColorSpec.spec2021,
    MiuixThemePaletteStyle paletteStyle = MiuixThemePaletteStyle.tonalSpot,
    bool? isDark,
    ColorScheme? platformDynamicLightColors,
    ColorScheme? platformDynamicDarkColors,
    MiuixColorSchemeMode schemeMode = MiuixColorSchemeMode.preset,
    @Deprecated('Use colorSchemeMode instead.') MiuixColorMode? mode,
    @Deprecated('Use keyColor instead.') Color? seedColor,
  }) {
    // Current names win whenever they carry a non-default value. Deprecated
    // aliases remain useful only as fallbacks, keeping migration deterministic
    // in both debug and release instead of relying on stripped assertions.
    final resolvedMode = colorSchemeMode != MiuixColorMode.system
        ? colorSchemeMode
        : mode ?? colorSchemeMode;
    return MiuixThemeController._(
      colorSchemeMode: resolvedMode,
      lightColors: lightColors ?? _miuixLightScheme(_miuixDefaultFixedKeyColor),
      darkColors: darkColors ?? _miuixDarkScheme(_miuixDefaultFixedKeyColor),
      keyColor: keyColor ?? seedColor,
      colorSpec: colorSpec,
      paletteStyle: paletteStyle,
      isDark: isDark,
      platformDynamicLightColors: platformDynamicLightColors,
      platformDynamicDarkColors: platformDynamicDarkColors,
      schemeMode: schemeMode,
    );
  }

  MiuixThemeController._({
    required MiuixColorMode colorSchemeMode,
    required ColorScheme lightColors,
    required ColorScheme darkColors,
    required Color? keyColor,
    required MiuixThemeColorSpec colorSpec,
    required MiuixThemePaletteStyle paletteStyle,
    required bool? isDark,
    required ColorScheme? platformDynamicLightColors,
    required ColorScheme? platformDynamicDarkColors,
    required this.schemeMode,
  }) : _colorSchemeMode = colorSchemeMode,
       _lightColors = lightColors,
       _darkColors = darkColors,
       _keyColor = keyColor,
       _colorSpec = colorSpec,
       _paletteStyle = paletteStyle,
       _isDark = isDark,
       _platformDynamicLightColors = platformDynamicLightColors,
       _platformDynamicDarkColors = platformDynamicDarkColors {
    _data = _buildData();
  }

  late MiuixThemeData _data;
  MiuixColorMode _colorSchemeMode;
  ColorScheme _lightColors;
  ColorScheme _darkColors;
  Color? _keyColor;
  MiuixThemeColorSpec _colorSpec;
  MiuixThemePaletteStyle _paletteStyle;
  bool? _isDark;
  ColorScheme? _platformDynamicLightColors;
  ColorScheme? _platformDynamicDarkColors;

  /// Current resolved Miuix theme data.
  MiuixThemeData get data => _data;

  /// Source color-scheme mode.
  MiuixColorMode get colorSchemeMode => _colorSchemeMode;

  /// Fixed light scheme used by System and Light modes.
  ColorScheme get lightColors => _lightColors;

  /// Fixed dark scheme used by System and Dark modes.
  ColorScheme get darkColors => _darkColors;

  /// Optional Monet key color; null requests platform dynamic colors.
  Color? get keyColor => _keyColor;

  /// Requested Material color specification.
  MiuixThemeColorSpec get colorSpec => _colorSpec;

  /// Requested Monet palette family.
  MiuixThemePaletteStyle get paletteStyle => _paletteStyle;

  /// Optional override for System and MonetSystem brightness.
  bool? get isDark => _isDark;

  /// Current color scheme source.
  ///
  /// This is a legacy Flutter metadata extension. Source parity is represented
  /// by [colorSchemeMode] and [keyColor].
  MiuixColorSchemeMode schemeMode;

  /// Resolves the scheme using the same branch table as `currentColors()`.
  ColorScheme currentColors(Brightness platformBrightness) =>
      _data.schemeFor(platformBrightness);

  /// Replaces the entire theme object.
  void setTheme(MiuixThemeData data) {
    _data = data;
    _useSchemeSemanticColors = data.useSchemeSemanticColors;
    _colorSchemeMode = data.mode;
    _lightColors = data.lightScheme;
    _darkColors = data.darkScheme;
    _keyColor = data.isDynamicColor ? data.seedColor : null;
    _colorSpec = data.colorSpec;
    _paletteStyle = data.paletteStyle;
    _isDark = switch (data.brightnessOverride) {
      Brightness.dark => true,
      Brightness.light => false,
      null => null,
    };
    notifyListeners();
  }

  /// Updates only the light/dark/dynamic mode.
  void setMode(MiuixColorMode mode) {
    _colorSchemeMode = mode;
    _rebuild();
  }

  /// Updates the optional Monet key color.
  ///
  /// As in the source controller, this has no visual effect in non-Monet modes.
  void setKeyColor(Color? color) {
    _keyColor = color;
    _rebuild();
  }

  /// Legacy non-null alias for [setKeyColor].
  void setSeedColor(Color color) => setKeyColor(color);

  /// Rebuilds generated palettes with a source-equivalent palette style.
  void setPaletteStyle(MiuixThemePaletteStyle value) {
    _paletteStyle = value;
    _rebuild();
  }

  /// Rebuilds generated palettes with the selected Material color spec.
  void setColorSpec(MiuixThemeColorSpec value) {
    _colorSpec = value;
    _rebuild();
  }

  /// Replaces the source fixed light and dark schemes.
  void setFixedColors({ColorScheme? lightColors, ColorScheme? darkColors}) {
    _lightColors = lightColors ?? _lightColors;
    _darkColors = darkColors ?? _darkColors;
    _rebuild();
  }

  /// Updates the explicit System/MonetSystem darkness override.
  void setIsDark(bool? value) {
    _isDark = value;
    _rebuild();
  }

  /// Supplies the latest platform dynamic schemes used for a null key color.
  void setPlatformDynamicColors({
    ColorScheme? lightColors,
    ColorScheme? darkColors,
  }) {
    _platformDynamicLightColors = lightColors;
    _platformDynamicDarkColors = darkColors;
    _rebuild();
  }

  // 仅由显式 setTheme 更新；旧控制器默认仍使用原生语义色。
  bool _useSchemeSemanticColors = false;

  void _rebuild() {
    _data = _buildData();
    notifyListeners();
  }

  MiuixThemeData _buildData() {
    final dynamic = switch (_colorSchemeMode) {
      MiuixColorMode.monetSystem ||
      MiuixColorMode.monetLight ||
      MiuixColorMode.monetDark => true,
      _ => false,
    };
    final generatedSeed = _keyColor ?? _miuixFallbackDynamicKeyColor;
    final lightScheme = dynamic
        ? _keyColor == null
              ? _platformDynamicLightColors ??
                    _miuixMonetScheme(
                      generatedSeed,
                      Brightness.light,
                      _paletteStyle,
                      _colorSpec,
                    )
              : _miuixMonetScheme(
                  generatedSeed,
                  Brightness.light,
                  _paletteStyle,
                  _colorSpec,
                )
        : _lightColors;
    final darkScheme = dynamic
        ? _keyColor == null
              ? _platformDynamicDarkColors ??
                    _miuixMonetScheme(
                      generatedSeed,
                      Brightness.dark,
                      _paletteStyle,
                      _colorSpec,
                    )
              : _miuixMonetScheme(
                  generatedSeed,
                  Brightness.dark,
                  _paletteStyle,
                  _colorSpec,
                )
        : _darkColors;
    return MiuixThemeData(
      useSchemeSemanticColors: _useSchemeSemanticColors,
      mode: _colorSchemeMode,
      seedColor: dynamic ? generatedSeed : _miuixDefaultFixedKeyColor,
      paletteStyle: _paletteStyle,
      colorSpec: _colorSpec,
      lightScheme: lightScheme,
      darkScheme: darkScheme,
      textTheme: _defaultTextTheme(),
      brightnessOverride: switch (_isDark) {
        true => Brightness.dark,
        false => Brightness.light,
        null => null,
      },
    );
  }

  /// Cycles between light and dark while leaving system/dynamic untouched.
  void toggleBrightness() {
    final next = _data.mode == MiuixColorMode.dark
        ? MiuixColorMode.light
        : MiuixColorMode.dark;
    setMode(next);
  }
}

/// Color space selector used by color picker adapters.
enum MiuixColorSpace {
  /// Classic HSV color space.
  hsv,

  /// MIUIX OKHSV color space.
  okHsv,

  /// OKLab perceptual color space.
  okLab,

  /// OKLCH perceptual cylindrical color space.
  okLch,
}

/// Simple HSV value object for Flutter-side color adapters.
@immutable
class MiuixHsv {
  /// Creates an HSV color value.
  const MiuixHsv({
    required this.hue,
    required this.saturation,
    required this.value,
    this.alpha = 1,
  });

  /// Hue in degrees.
  final double hue;

  /// Saturation from 0 to 1.
  final double saturation;

  /// Value from 0 to 1.
  final double value;

  /// Alpha from 0 to 1.
  final double alpha;

  /// Creates an HSV adapter from a Flutter color.
  factory MiuixHsv.fromColor(Color color) {
    final hsv = HSVColor.fromColor(color);
    return MiuixHsv(
      hue: hsv.hue,
      saturation: hsv.saturation,
      value: hsv.value,
      alpha: hsv.alpha,
    );
  }

  /// Converts the adapter back to Flutter [Color].
  Color toColor() {
    return HSVColor.fromAHSV(alpha, hue, saturation, value).toColor();
  }
}

/// Perceptually uniform OKHSV value using the same transforms as MIUIX.
class MiuixOkHsv extends MiuixHsv {
  /// Creates an OKHSV value. Hue is normalized to 0..1.
  const MiuixOkHsv({
    required super.hue,
    required super.saturation,
    required super.value,
    super.alpha,
  });

  /// Converts an sRGB color to OKHSV.
  factory MiuixOkHsv.fromColor(Color color) {
    final values = _srgbToOkHsv(color.r, color.g, color.b);
    return MiuixOkHsv(
      hue: values.$1,
      saturation: values.$2,
      value: values.$3,
      alpha: color.a,
    );
  }

  @override
  Color toColor() {
    final rgb = _okHsvToSrgb(hue, saturation, value);
    return _colorFromChannels(rgb.$1, rgb.$2, rgb.$3, alpha);
  }
}

/// OKLab value object used by color tooling adapters.
@immutable
class MiuixOkLab {
  /// Creates an OKLab color value.
  const MiuixOkLab({
    required this.lightness,
    required this.a,
    required this.b,
    this.alpha = 1,
  });

  /// Perceptual lightness channel.
  final double lightness;

  /// Green-red opponent channel.
  final double a;

  /// Blue-yellow opponent channel.
  final double b;

  /// Alpha from 0 to 1.
  final double alpha;

  /// Converts an sRGB color to OKLab.
  factory MiuixOkLab.fromColor(Color color) {
    final lab = _rgbToOkLab(color.r, color.g, color.b);
    return MiuixOkLab(lightness: lab.$1, a: lab.$2, b: lab.$3, alpha: color.a);
  }

  /// Converts this OKLab value to a clipped sRGB color.
  Color toColor() {
    final rgb = _okLabToRgb(lightness, a, b);
    return _colorFromChannels(rgb.$1, rgb.$2, rgb.$3, alpha);
  }
}

/// OKLCH value object used by color tooling adapters.
@immutable
class MiuixOkLch {
  /// Creates an OKLCH color value.
  const MiuixOkLch({
    required this.lightness,
    required this.chroma,
    required this.hue,
    this.alpha = 1,
  });

  /// Perceptual lightness channel.
  final double lightness;

  /// Chroma channel.
  final double chroma;

  /// Hue in degrees.
  final double hue;

  /// Alpha from 0 to 1.
  final double alpha;

  /// Converts an sRGB color to OKLCH.
  factory MiuixOkLch.fromColor(Color color) {
    final lab = MiuixOkLab.fromColor(color);
    final chroma = math.sqrt(lab.a * lab.a + lab.b * lab.b);
    var hue = math.atan2(lab.b, lab.a) * 180 / math.pi;
    if (hue < 0) {
      hue += 360;
    }
    return MiuixOkLch(
      lightness: lab.lightness,
      chroma: chroma.clamp(0.0, .4),
      hue: hue,
      alpha: color.a,
    );
  }

  /// Converts this OKLCH value to a clipped sRGB color.
  Color toColor() {
    final radians = hue * math.pi / 180;
    return MiuixOkLab(
      lightness: lightness.clamp(0.0, 1.0),
      a: chroma.clamp(0.0, .4) * math.cos(radians),
      b: chroma.clamp(0.0, .4) * math.sin(radians),
      alpha: alpha,
    ).toColor();
  }
}

Color _colorFromChannels(double r, double g, double b, double alpha) {
  int channel(double value) => (value.clamp(0.0, 1.0) * 255).round();
  return Color.fromARGB(channel(alpha), channel(r), channel(g), channel(b));
}

double _cbrt(double value) {
  if (value == 0) {
    return 0;
  }
  return value.isNegative
      ? -math.pow(-value, 1 / 3).toDouble()
      : math.pow(value, 1 / 3).toDouble();
}

(double, double, double) _rgbToOkLab(double r, double g, double b) {
  final l = _cbrt(.4122214708 * r + .5363325363 * g + .0514459929 * b);
  final m = _cbrt(.2119034982 * r + .6806995451 * g + .1073969566 * b);
  final s = _cbrt(.0883024619 * r + .2817188376 * g + .6299787005 * b);
  return (
    .2104542553 * l + .7936177850 * m - .0040720468 * s,
    1.9779984951 * l - 2.4285922050 * m + .4505937099 * s,
    .0259040371 * l + .7827717662 * m - .8086757660 * s,
  );
}

(double, double, double) _okLabToRgb(double lightness, double a, double b) {
  final lRoot = lightness + .3963377774 * a + .2158037573 * b;
  final mRoot = lightness - .1055613458 * a - .0638541728 * b;
  final sRoot = lightness - .0894841775 * a - 1.2914855480 * b;
  final l = lRoot * lRoot * lRoot;
  final m = mRoot * mRoot * mRoot;
  final s = sRoot * sRoot * sRoot;
  return (
    (4.0767416621 * l - 3.3077115913 * m + .2309699292 * s).clamp(0.0, 1.0),
    (-1.2684380046 * l + 2.6097574011 * m - .3413193965 * s).clamp(0.0, 1.0),
    (-.0041960863 * l - .7034186147 * m + 1.7076147010 * s).clamp(0.0, 1.0),
  );
}

double _srgbTransfer(double value) {
  return value <= .0031308
      ? 12.92 * value
      : 1.055 * math.pow(value, 1 / 2.4) - .055;
}

double _srgbTransferInverse(double value) {
  return value > .04045
      ? math.pow((value + .055) / 1.055, 2.4).toDouble()
      : value / 12.92;
}

(double, double, double) _linearSrgbToOkLab(double r, double g, double b) {
  return _rgbToOkLab(r, g, b);
}

(double, double, double) _okLabToLinearSrgb(
  double lightness,
  double a,
  double b,
) {
  final lRoot = lightness + .3963377774 * a + .2158037573 * b;
  final mRoot = lightness - .1055613458 * a - .0638541728 * b;
  final sRoot = lightness - .0894841775 * a - 1.291485548 * b;
  final l = lRoot * lRoot * lRoot;
  final m = mRoot * mRoot * mRoot;
  final s = sRoot * sRoot * sRoot;
  return (
    4.0767416621 * l - 3.3077115913 * m + .2309699292 * s,
    -1.2684380046 * l + 2.6097574011 * m - .3413193965 * s,
    -.0041960863 * l - .7034186147 * m + 1.707614701 * s,
  );
}

double _toe(double value) {
  const k1 = .206;
  const k2 = .03;
  const k3 = (1 + k1) / (1 + k2);
  final term = k3 * value - k1;
  return .5 * (term + math.sqrt(term * term + 4 * k2 * k3 * value));
}

double _toeInverse(double value) {
  const k1 = .206;
  const k2 = .03;
  const k3 = (1 + k1) / (1 + k2);
  return (value * value + k1 * value) / (k3 * (value + k2));
}

double _computeMaxSaturation(double a, double b) {
  late double k0, k1, k2, k3, k4, wl, wm, ws;
  if (-1.88170328 * a - .80936493 * b > 1) {
    k0 = 1.19086277;
    k1 = 1.76576728;
    k2 = .59662641;
    k3 = .75515197;
    k4 = .56771245;
    wl = 4.0767416621;
    wm = -3.3077115913;
    ws = .2309699292;
  } else if (1.81444104 * a - 1.19445276 * b > 1) {
    k0 = .73956515;
    k1 = -.45954404;
    k2 = .08285427;
    k3 = .1254107;
    k4 = .14503204;
    wl = -1.2684380046;
    wm = 2.6097574011;
    ws = -.3413193965;
  } else {
    k0 = 1.35733652;
    k1 = -.00915799;
    k2 = -1.1513021;
    k3 = -.50559606;
    k4 = .00692167;
    wl = -.0041960863;
    wm = -.7034186147;
    ws = 1.707614701;
  }
  var saturation = k0 + k1 * a + k2 * b + k3 * a * a + k4 * a * b;
  final kl = .3963377774 * a + .2158037573 * b;
  final km = -.1055613458 * a - .0638541728 * b;
  final ks = -.0894841775 * a - 1.291485548 * b;
  final lRoot = 1 + saturation * kl;
  final mRoot = 1 + saturation * km;
  final sRoot = 1 + saturation * ks;
  final l = lRoot * lRoot * lRoot;
  final m = mRoot * mRoot * mRoot;
  final s = sRoot * sRoot * sRoot;
  final l1 = 3 * kl * lRoot * lRoot;
  final m1 = 3 * km * mRoot * mRoot;
  final s1 = 3 * ks * sRoot * sRoot;
  final l2 = 6 * kl * kl * lRoot;
  final m2 = 6 * km * km * mRoot;
  final s2 = 6 * ks * ks * sRoot;
  final f = wl * l + wm * m + ws * s;
  final f1 = wl * l1 + wm * m1 + ws * s1;
  final f2 = wl * l2 + wm * m2 + ws * s2;
  saturation -= (f * f1) / (f1 * f1 - .5 * f * f2);
  return saturation;
}

(double, double) _getStMax(double a, double b) {
  final saturation = _computeMaxSaturation(a, b);
  final rgb = _okLabToLinearSrgb(1, saturation * a, saturation * b);
  final maximum = math.max(rgb.$1, math.max(rgb.$2, rgb.$3));
  final lCusp = _cbrt(1 / maximum);
  final cCusp = lCusp * saturation;
  return (cCusp / lCusp, cCusp / (1 - lCusp));
}

(double, double, double) _srgbToOkHsv(double r, double g, double b) {
  final lab = _linearSrgbToOkLab(
    _srgbTransferInverse(r),
    _srgbTransferInverse(g),
    _srgbTransferInverse(b),
  );
  final chroma = math.sqrt(lab.$2 * lab.$2 + lab.$3 * lab.$3);
  if (chroma < 1e-9 || lab.$1 < 1e-9) {
    return (0, 0, _toe(lab.$1).clamp(0.0, 1.0));
  }
  final a = lab.$2 / chroma;
  final bAxis = lab.$3 / chroma;
  final hue = .5 + (.5 * math.atan2(-lab.$3, -lab.$2)) / math.pi;
  final st = _getStMax(a, bAxis);
  const s0 = .5;
  final k = 1 - s0 / st.$1;
  final t = st.$2 / (chroma + lab.$1 * st.$2);
  final lv = t * lab.$1;
  final cv = t * chroma;
  final lvToe = _toeInverse(lv);
  final cvToe = cv * lvToe / lv;
  final scaleRgb = _okLabToLinearSrgb(lvToe, a * cvToe, bAxis * cvToe);
  final scaleMax = math.max(scaleRgb.$1, math.max(scaleRgb.$2, scaleRgb.$3));
  final scaleL = _cbrt(1 / math.max(scaleMax, 1e-9));
  final l = _toe(lab.$1 / scaleL);
  final value = l / lv;
  final saturation = ((s0 + st.$2) * cv) / (st.$2 * s0 + st.$2 * k * cv);
  return ((hue % 1 + 1) % 1, saturation.clamp(0.0, 1.0), value.clamp(0.0, 1.0));
}

(double, double, double) _okHsvToSrgb(
  double hue,
  double saturation,
  double value,
) {
  final h = (hue % 1 + 1) % 1;
  final s = saturation.clamp(0.0, 1.0);
  final v = value.clamp(0.0, 1.0);
  if (v <= 0) {
    return (0, 0, 0);
  }
  final a = math.cos(2 * math.pi * h);
  final b = math.sin(2 * math.pi * h);
  final st = _getStMax(a, b);
  const s0 = .5;
  final k = 1 - s0 / st.$1;
  final denominator = s0 + st.$2 - st.$2 * k * s;
  final lv = 1 - s * s0 / denominator;
  final cv = s * st.$2 * s0 / denominator;
  var lightness = v * lv;
  var chroma = v * cv;
  final lvToe = _toeInverse(lv);
  final cvToe = lv == 0 ? 0 : cv * lvToe / lv;
  final newLightness = _toeInverse(lightness);
  chroma = lightness == 0 ? 0 : chroma * newLightness / lightness;
  lightness = newLightness;
  final scaleRgb = _okLabToLinearSrgb(lvToe, a * cvToe, b * cvToe);
  final scaleMax = math.max(scaleRgb.$1, math.max(scaleRgb.$2, scaleRgb.$3));
  final scaleL = _cbrt(1 / math.max(scaleMax, 1e-9));
  lightness *= scaleL;
  chroma *= scaleL;
  final rgb = _okLabToLinearSrgb(lightness, chroma * a, chroma * b);
  return (
    _srgbTransfer(rgb.$1).clamp(0.0, 1.0),
    _srgbTransfer(rgb.$2).clamp(0.0, 1.0),
    _srgbTransfer(rgb.$3).clamp(0.0, 1.0),
  );
}

/// Motion tokens shared by Miuix widgets.
///
/// Flutter exposes animation primitives directly, so this class keeps durations
/// and curves centralized instead of hard-coding them inside individual widgets.
@immutable
class MiuixMotionTokens {
  /// Creates a motion token set.
  const MiuixMotionTokens({
    this.fast = const Duration(milliseconds: 110),
    this.normal = const Duration(milliseconds: 200),
    this.slow = const Duration(milliseconds: 320),
    this.emphasized = Curves.easeOutCubic,
    this.decelerate = Curves.easeOutQuart,
    this.accelerate = Curves.easeInCubic,
  });

  /// Short feedback transitions such as press and hover states.
  final Duration fast;

  /// Standard component state transitions.
  final Duration normal;

  /// Larger surface and route-like transitions.
  final Duration slow;

  /// Default expressive easing for HyperOS-like movement.
  final Curve emphasized;

  /// Deceleration curve used when content settles.
  final Curve decelerate;

  /// Acceleration curve used when content exits.
  final Curve accelerate;
}

/// Radius tokens used by the component library.
///
/// Xiaomi UI surfaces often use continuous-looking rounded corners. Flutter
/// cannot express a true system squircle through [BorderRadius] alone, but these
/// radii keep defaults visually consistent.
@immutable
class MiuixRadiusTokens {
  /// Creates radius tokens.
  const MiuixRadiusTokens({
    this.xs = 5,
    this.sm = 8,
    this.md = 14,
    this.lg = 20,
    this.xl = 28,
    this.full = 999,
  });

  /// Extra-small rounded controls.
  final double xs;

  /// Small rounded controls.
  final double sm;

  /// Medium cards and fields.
  final double md;

  /// Large popups and containers.
  final double lg;

  /// Extra-large sheets and floating bars.
  final double xl;

  /// Pill-shaped controls.
  final double full;
}

/// Spacing tokens used by Miuix layouts.
///
/// Keeping spacing in a first-class token object makes every component tunable
/// without forcing downstream apps to fork widgets.
@immutable
class MiuixSpacingTokens {
  /// Creates spacing tokens.
  const MiuixSpacingTokens({
    this.xs = 4,
    this.sm = 8,
    this.md = 10,
    this.lg = 14,
    this.xl = 20,
    this.xxl = 28,
  });

  /// Tiny spacing.
  final double xs;

  /// Small spacing.
  final double sm;

  /// Medium spacing.
  final double md;

  /// Large spacing.
  final double lg;

  /// Extra-large spacing.
  final double xl;

  /// Section spacing.
  final double xxl;
}

/// Complete theme data consumed by the Miuix Flutter widgets.
///
/// The class wraps Flutter's [ThemeData] rather than replacing it. This keeps
/// the library compatible with Material, Cupertino, and third-party widgets.
@immutable
class MiuixThemeData extends ThemeExtension<MiuixThemeData> {
  /// Creates a complete Miuix theme object.
  const MiuixThemeData({
    required this.mode,
    required this.seedColor,
    required this.paletteStyle,
    required this.colorSpec,
    required this.lightScheme,
    required this.darkScheme,
    required this.textTheme,
    this.brightnessOverride,
    this.motion = const MiuixMotionTokens(),
    this.radius = const MiuixRadiusTokens(),
    this.spacing = const MiuixSpacingTokens(),
    this.hyperOs4 = const MiuixHyperOs4Tokens(),
    this.enableGlass = true,
    this.glassIntensity = MiuixGlassIntensity.standard,
    this.enableSquircle = true,
    this.useSchemeSemanticColors = false,
  });

  /// Builds the default Miuix theme from a seed color.
  factory MiuixThemeData.defaults({
    MiuixColorMode mode = MiuixColorMode.system,
    Color seedColor = const Color(0xFF3482FF),
    MiuixThemePaletteStyle paletteStyle = MiuixThemePaletteStyle.tonalSpot,
    MiuixThemeColorSpec colorSpec = MiuixThemeColorSpec.spec2021,
  }) {
    final monet = switch (mode) {
      MiuixColorMode.monetSystem ||
      MiuixColorMode.monetLight ||
      MiuixColorMode.monetDark => true,
      _ => false,
    };
    return MiuixThemeData(
      mode: mode,
      seedColor: seedColor,
      paletteStyle: paletteStyle,
      colorSpec: colorSpec,
      lightScheme: monet
          ? _miuixMonetScheme(
              seedColor,
              Brightness.light,
              paletteStyle,
              colorSpec,
            )
          : _miuixLightScheme(_miuixDefaultFixedKeyColor),
      darkScheme: monet
          ? _miuixMonetScheme(
              seedColor,
              Brightness.dark,
              paletteStyle,
              colorSpec,
            )
          : _miuixDarkScheme(_miuixDefaultFixedKeyColor),
      textTheme: _defaultTextTheme(),
    );
  }

  /// Current color mode.
  final MiuixColorMode mode;

  /// Seed color used by generated palettes.
  final Color seedColor;

  /// Dynamic palette family selected for Monet modes.
  final MiuixThemePaletteStyle paletteStyle;

  /// Material color-generation specification selected by the caller.
  final MiuixThemeColorSpec colorSpec;

  /// Light color scheme.
  final ColorScheme lightScheme;

  /// Dark color scheme.
  final ColorScheme darkScheme;

  /// Text styles used by Miuix widgets.
  final TextTheme textTheme;

  /// Optional source `isDark` override for System and MonetSystem modes.
  final Brightness? brightnessOverride;

  /// Shared motion tokens.
  final MiuixMotionTokens motion;

  /// Shared radius tokens.
  final MiuixRadiusTokens radius;

  /// Shared spacing tokens.
  final MiuixSpacingTokens spacing;

  /// HyperOS 4 application-layout and soft-glass calibration tokens.
  final MiuixHyperOs4Tokens hyperOs4;

  /// Enables glass effects by default where widgets support them.
  final bool enableGlass;

  /// Global blur and transparency strength for supported glass surfaces.
  final MiuixGlassIntensity glassIntensity;

  /// Enables squircle-like shapes by default where widgets support them.
  final bool enableSquircle;

  /// 使用调用方显式 ColorScheme 的语义色，不要求启用 Monet。
  /// 默认 false 保留原生固定色表兼容；自定义原色主题可显式开启。
  final bool useSchemeSemanticColors;

  /// Resolves the color scheme for a platform brightness.
  ColorScheme schemeFor(Brightness platformBrightness) {
    final systemBrightness = brightnessOverride ?? platformBrightness;
    return switch (mode) {
      MiuixColorMode.light || MiuixColorMode.monetLight => lightScheme,
      MiuixColorMode.dark || MiuixColorMode.monetDark => darkScheme,
      MiuixColorMode.monetSystem || MiuixColorMode.system =>
        systemBrightness == Brightness.dark ? darkScheme : lightScheme,
    };
  }

  /// Whether this data represents one of the three source Monet modes.
  bool get isDynamicColor => switch (mode) {
    MiuixColorMode.monetSystem ||
    MiuixColorMode.monetLight ||
    MiuixColorMode.monetDark => true,
    _ => false,
  };

  /// Creates Flutter [ThemeData] from Miuix tokens.
  ThemeData materialTheme(Brightness platformBrightness) {
    final scheme = schemeFor(platformBrightness);
    // Fixed themes must expose the source MIUIX semantic table verbatim. A
    // Material ColorScheme cannot represent every MIUIX role and, in
    // particular, its onSecondary value is unsuitable for the white switch
    // thumb used by the original light palette. Only generated Monet palettes
    // should derive their semantic roles from the resolved scheme.
    // 自定义 ColorScheme 与莫奈是不同来源，不能为了使用前者而强制重新调色。
    final semanticColors = useSchemeSemanticColors || isDynamicColor
        ? MiuixSemanticColors.fromScheme(scheme)
        : scheme.brightness == Brightness.dark
        ? const MiuixSemanticColors.dark()
        : const MiuixSemanticColors.light();
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius.md),
    );
    final filledButtonStyle = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(58, 40)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      ),
      shape: WidgetStatePropertyAll(buttonShape),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return semanticColors['disabledPrimaryButton'];
        }
        return semanticColors['primary'];
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return semanticColors['disabledOnPrimaryButton'];
        }
        return semanticColors['onPrimary'];
      }),
      textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
      overlayColor: WidgetStatePropertyAll(
        scheme.onPrimary.withValues(alpha: 0.08),
      ),
      elevation: const WidgetStatePropertyAll(0),
      surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
      shadowColor: const WidgetStatePropertyAll(Colors.transparent),
    );
    final textButtonStyle = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(58, 40)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      ),
      shape: WidgetStatePropertyAll(buttonShape),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return semanticColors['disabledSecondaryVariant'];
        }
        return semanticColors['secondaryVariant'];
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return semanticColors['disabledOnSecondaryVariant'];
        }
        return semanticColors['onSecondaryVariant'];
      }),
      textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
      overlayColor: WidgetStatePropertyAll(
        semanticColors['onSecondaryVariant'].withValues(alpha: 0.08),
      ),
      elevation: const WidgetStatePropertyAll(0),
      surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
      shadowColor: const WidgetStatePropertyAll(Colors.transparent),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      textTheme: textTheme.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        centerTitle: true,
        toolbarHeight: 52,
        titleTextStyle: textTheme.displaySmall?.copyWith(
          color: scheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -.3,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.9),
        thickness: 0.5,
        space: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(style: filledButtonStyle),
      textButtonTheme: TextButtonThemeData(style: textButtonStyle),
      sliderTheme: SliderThemeData(
        trackHeight: 28,
        activeTrackColor: scheme.primary,
        inactiveTrackColor: scheme.outlineVariant.withValues(alpha: 0.32),
        thumbColor: scheme.onPrimary,
        overlayColor: Colors.transparent,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
        overlayShape: SliderComponentShape.noOverlay,
        trackShape: const RoundedRectSliderTrackShape(),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius.lg),
        ),
        margin: EdgeInsets.zero,
      ),
      extensions: <ThemeExtension<dynamic>>[this, semanticColors],
    );
  }

  @override
  MiuixThemeData copyWith({
    MiuixColorMode? mode,
    Color? seedColor,
    MiuixThemePaletteStyle? paletteStyle,
    MiuixThemeColorSpec? colorSpec,
    ColorScheme? lightScheme,
    ColorScheme? darkScheme,
    TextTheme? textTheme,
    Brightness? brightnessOverride,
    bool clearBrightnessOverride = false,
    MiuixMotionTokens? motion,
    MiuixRadiusTokens? radius,
    MiuixSpacingTokens? spacing,
    MiuixHyperOs4Tokens? hyperOs4,
    bool? enableGlass,
    MiuixGlassIntensity? glassIntensity,
    bool? enableSquircle,
    bool? useSchemeSemanticColors,
  }) {
    return MiuixThemeData(
      mode: mode ?? this.mode,
      seedColor: seedColor ?? this.seedColor,
      paletteStyle: paletteStyle ?? this.paletteStyle,
      colorSpec: colorSpec ?? this.colorSpec,
      lightScheme: lightScheme ?? this.lightScheme,
      darkScheme: darkScheme ?? this.darkScheme,
      textTheme: textTheme ?? this.textTheme,
      brightnessOverride: clearBrightnessOverride
          ? null
          : brightnessOverride ?? this.brightnessOverride,
      motion: motion ?? this.motion,
      radius: radius ?? this.radius,
      spacing: spacing ?? this.spacing,
      hyperOs4: hyperOs4 ?? this.hyperOs4,
      enableGlass: enableGlass ?? this.enableGlass,
      glassIntensity: glassIntensity ?? this.glassIntensity,
      enableSquircle: enableSquircle ?? this.enableSquircle,
      useSchemeSemanticColors:
          useSchemeSemanticColors ?? this.useSchemeSemanticColors,
    );
  }

  @override
  MiuixThemeData lerp(ThemeExtension<MiuixThemeData>? other, double t) {
    if (other is! MiuixThemeData) {
      return this;
    }
    return MiuixThemeData(
      mode: t < 0.5 ? mode : other.mode,
      seedColor: Color.lerp(seedColor, other.seedColor, t) ?? seedColor,
      paletteStyle: t < 0.5 ? paletteStyle : other.paletteStyle,
      colorSpec: t < 0.5 ? colorSpec : other.colorSpec,
      lightScheme: ColorScheme.lerp(lightScheme, other.lightScheme, t),
      darkScheme: ColorScheme.lerp(darkScheme, other.darkScheme, t),
      textTheme: TextTheme.lerp(textTheme, other.textTheme, t),
      brightnessOverride: t < 0.5
          ? brightnessOverride
          : other.brightnessOverride,
      motion: t < 0.5 ? motion : other.motion,
      radius: t < 0.5 ? radius : other.radius,
      spacing: t < 0.5 ? spacing : other.spacing,
      hyperOs4: t < 0.5 ? hyperOs4 : other.hyperOs4,
      enableGlass: t < 0.5 ? enableGlass : other.enableGlass,
      glassIntensity: t < 0.5 ? glassIntensity : other.glassIntensity,
      enableSquircle: t < 0.5 ? enableSquircle : other.enableSquircle,
      useSchemeSemanticColors: t < 0.5
          ? useSchemeSemanticColors
          : other.useSchemeSemanticColors,
    );
  }
}

/// Builds the Material dynamic palette used by MIUIX Monet modes.
///
/// The upstream sample uses MaterialKolor rather than Flutter's bundled color
/// utilities because the latter does not expose the Material 2025 role
/// algorithm. `libmonet` is a Dart port of the same dynamic-color algorithms,
/// including the source fallback rule for variants that only support 2021.
ColorScheme _miuixMonetScheme(
  Color seedColor,
  Brightness brightness,
  MiuixThemePaletteStyle paletteStyle,
  MiuixThemeColorSpec colorSpec,
) {
  final variant = switch (paletteStyle) {
    MiuixThemePaletteStyle.tonalSpot => monet.Variant.tonalSpot,
    MiuixThemePaletteStyle.neutral => monet.Variant.neutral,
    MiuixThemePaletteStyle.vibrant => monet.Variant.vibrant,
    MiuixThemePaletteStyle.expressive => monet.Variant.expressive,
    MiuixThemePaletteStyle.rainbow => monet.Variant.rainbow,
    MiuixThemePaletteStyle.fruitSalad => monet.Variant.fruitSalad,
    MiuixThemePaletteStyle.monochrome => monet.Variant.monochrome,
    MiuixThemePaletteStyle.fidelity => monet.Variant.fidelity,
    MiuixThemePaletteStyle.content => monet.Variant.content,
  };
  final specVersion = switch (colorSpec) {
    MiuixThemeColorSpec.spec2021 => monet.SpecVersion.spec2021,
    MiuixThemeColorSpec.spec2025 => monet.SpecVersion.spec2025,
  };

  // DynamicScheme applies the same graceful 2025-to-2021 fallback matrix as
  // ThemeController.kt: only tonal spot, neutral, vibrant, and expressive keep
  // the requested 2025 spec. Every other variant resolves to 2021 internally.
  final scheme = monet.DynamicScheme.fromPalettesOrKeyColors(
    sourceColorHct: monet.Hct.fromInt(seedColor.toARGB32()),
    isDark: brightness == Brightness.dark,
    contrastLevel: 0,
    variant: variant,
    platform: monet.Platform.phone,
    specVersion: specVersion,
  );
  Color role(int argb) => Color(argb);

  // Populate every Flutter role explicitly. MIUIX later maps this table to its
  // own 53 semantic roles, so leaving an optional field to ColorScheme's
  // nearest-role fallback would visibly change generated controls and pages.
  return ColorScheme(
    brightness: brightness,
    primary: role(scheme.primary),
    onPrimary: role(scheme.onPrimary),
    primaryContainer: role(scheme.primaryContainer),
    onPrimaryContainer: role(scheme.onPrimaryContainer),
    primaryFixed: role(scheme.primaryFixed),
    primaryFixedDim: role(scheme.primaryFixedDim),
    onPrimaryFixed: role(scheme.onPrimaryFixed),
    onPrimaryFixedVariant: role(scheme.onPrimaryFixedVariant),
    secondary: role(scheme.secondary),
    onSecondary: role(scheme.onSecondary),
    secondaryContainer: role(scheme.secondaryContainer),
    onSecondaryContainer: role(scheme.onSecondaryContainer),
    secondaryFixed: role(scheme.secondaryFixed),
    secondaryFixedDim: role(scheme.secondaryFixedDim),
    onSecondaryFixed: role(scheme.onSecondaryFixed),
    onSecondaryFixedVariant: role(scheme.onSecondaryFixedVariant),
    tertiary: role(scheme.tertiary),
    onTertiary: role(scheme.onTertiary),
    tertiaryContainer: role(scheme.tertiaryContainer),
    onTertiaryContainer: role(scheme.onTertiaryContainer),
    tertiaryFixed: role(scheme.tertiaryFixed),
    tertiaryFixedDim: role(scheme.tertiaryFixedDim),
    onTertiaryFixed: role(scheme.onTertiaryFixed),
    onTertiaryFixedVariant: role(scheme.onTertiaryFixedVariant),
    error: role(scheme.error),
    onError: role(scheme.onError),
    errorContainer: role(scheme.errorContainer),
    onErrorContainer: role(scheme.onErrorContainer),
    surface: role(scheme.surface),
    onSurface: role(scheme.onSurface),
    surfaceDim: role(scheme.surfaceDim),
    surfaceBright: role(scheme.surfaceBright),
    surfaceContainerLowest: role(scheme.surfaceContainerLowest),
    surfaceContainerLow: role(scheme.surfaceContainerLow),
    surfaceContainer: role(scheme.surfaceContainer),
    surfaceContainerHigh: role(scheme.surfaceContainerHigh),
    surfaceContainerHighest: role(scheme.surfaceContainerHighest),
    onSurfaceVariant: role(scheme.onSurfaceVariant),
    outline: role(scheme.outline),
    outlineVariant: role(scheme.outlineVariant),
    shadow: role(scheme.shadow),
    scrim: role(scheme.scrim),
    inverseSurface: role(scheme.inverseSurface),
    onInverseSurface: role(scheme.inverseOnSurface),
    inversePrimary: role(scheme.inversePrimary),
    surfaceTint: role(scheme.surfaceTint),
    // Flutter deprecated these aliases, but the original MIUIX mapping still
    // consumes the independently generated Material roles.
    // ignore: deprecated_member_use
    background: role(scheme.background),
    // ignore: deprecated_member_use
    onBackground: role(scheme.onBackground),
    // ignore: deprecated_member_use
    surfaceVariant: role(scheme.surfaceVariant),
  );
}

/// Builds the light MIUIX color scheme from source constants.
ColorScheme _miuixLightScheme(Color seedColor) {
  // These assignments are a direct projection of Colors.kt lightColorScheme.
  // Material exposes extra container tiers that MIUIX does not; map those
  // tiers onto the nearest exact MIUIX surface instead of retaining generated
  // seed colors. This keeps both Material interoperability and source pixels.
  return ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.light,
  ).copyWith(
    primary: seedColor,
    onPrimary: const Color(0xFFFFFFFF),
    primaryContainer: const Color(0xFF5D9BFF),
    onPrimaryContainer: const Color(0xFFFFFFFF),
    secondary: const Color(0xFFE6E6E6),
    onSecondary: const Color(0xFFFFFFFF),
    secondaryContainer: const Color(0xFFF0F0F0),
    onSecondaryContainer: const Color(0xFFA9A9A9),
    tertiaryContainer: const Color(0xFFEAF2FF),
    onTertiaryContainer: seedColor,
    error: const Color(0xFFE94634),
    onError: const Color(0xFFFFFFFF),
    errorContainer: const Color(0xFFFDF6F4),
    onErrorContainer: const Color(0xFF410002),
    surface: const Color(0xFFF7F7F7),
    onSurface: const Color(0xFF000000),
    surfaceDim: const Color(0xFFF7F7F7),
    surfaceBright: const Color(0xFFF7F7F7),
    surfaceContainerLowest: const Color(0xFFFFFFFF),
    surfaceContainerLow: const Color(0xFFFFFFFF),
    surfaceContainer: const Color(0xFFFFFFFF),
    onSurfaceVariant: const Color(0x99000000),
    surfaceContainerHigh: const Color(0xFFE8E8E8),
    surfaceContainerHighest: const Color(0xFFE8E8E8),
    outline: const Color(0xFFD9D9D9),
    outlineVariant: const Color(0xFFE0E0E0),
    surfaceTint: Colors.transparent,
  );
}

/// Builds the dark MIUIX color scheme from source constants.
ColorScheme _miuixDarkScheme(Color seedColor) {
  // Dark Colors.kt uses black for the base surface and 0x242424 for every
  // ordinary container tier. Preserve that deliberate contrast; Material's
  // generated blue-gray tiers make dark cards visibly unlike the source.
  return ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.dark,
  ).copyWith(
    primary: const Color(0xFF277AF7),
    onPrimary: const Color(0xFFFFFFFF),
    primaryContainer: const Color(0xFF338FE4),
    onPrimaryContainer: const Color(0xFFFFFFFF),
    secondary: const Color(0xFF505050),
    onSecondary: const Color(0xFFFFFFFF),
    secondaryContainer: const Color(0xFF434343),
    onSecondaryContainer: const Color(0xFF7C7C7C),
    tertiaryContainer: const Color(0xFF2B3B54),
    onTertiaryContainer: const Color(0xFF4788FF),
    error: const Color(0xFFF12522),
    onError: const Color(0xFFFFFFFF),
    errorContainer: const Color(0xFF2E0603),
    onErrorContainer: const Color(0xFFFFDAD6),
    surface: const Color(0xFF000000),
    onSurface: const Color(0xFFF2F2F2),
    surfaceDim: const Color(0xFF000000),
    surfaceBright: const Color(0xFF242424),
    surfaceContainerLowest: const Color(0xFF000000),
    surfaceContainerLow: const Color(0xFF242424),
    surfaceContainer: const Color(0xFF242424),
    onSurfaceVariant: const Color(0x80FFFFFF),
    surfaceContainerHigh: const Color(0xFF242424),
    surfaceContainerHighest: const Color(0xFF2D2D2D),
    outline: const Color(0xFF404040),
    outlineVariant: const Color(0xFF393939),
    surfaceTint: Colors.transparent,
  );
}

/// App-level theme wrapper for Miuix widgets.
///
/// Use this instead of a raw [MaterialApp.theme] when the app should inherit
/// Miuix defaults automatically.
class MiuixTheme extends StatelessWidget {
  /// Creates a theme wrapper.
  const MiuixTheme({
    super.key,
    required this.child,
    this.data,
    this.controller,
  });

  /// The subtree that receives the theme.
  final Widget child;

  /// Optional explicit theme data.
  final MiuixThemeData? data;

  /// Optional source-equivalent controller that rebuilds this subtree.
  final MiuixThemeController? controller;

  /// Returns the nearest [MiuixThemeData] or the default token set.
  static MiuixThemeData of(BuildContext context) {
    return Theme.of(context).extension<MiuixThemeData>() ??
        MiuixThemeData.defaults();
  }

  /// Returns the source controller mode, or null for the direct data overload.
  static MiuixColorMode? colorSchemeModeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_MiuixThemeSourceScope>()
      ?.colorSchemeMode;

  /// Matches upstream `MiuixTheme.isDynamicColor`.
  static bool isDynamicColorOf(BuildContext context) {
    return switch (colorSchemeModeOf(context)) {
      MiuixColorMode.monetSystem ||
      MiuixColorMode.monetLight ||
      MiuixColorMode.monetDark => true,
      _ => false,
    };
  }

  @override
  Widget build(BuildContext context) {
    final activeController = controller;
    // A live controller is the stateful overload and therefore owns the theme
    // when both fields arrive during a configuration migration.
    if (activeController == null) {
      return _buildResolvedTheme(
        context,
        data ?? MiuixThemeData.defaults(),
        null,
      );
    }
    return AnimatedBuilder(
      animation: activeController,
      builder: (context, _) => _buildResolvedTheme(
        context,
        activeController.data,
        activeController.colorSchemeMode,
      ),
    );
  }

  Widget _buildResolvedTheme(
    BuildContext context,
    MiuixThemeData resolved,
    MiuixColorMode? sourceMode,
  ) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    return _MiuixThemeSourceScope(
      colorSchemeMode: sourceMode,
      child: Theme(data: resolved.materialTheme(brightness), child: child),
    );
  }
}

class _MiuixThemeSourceScope extends InheritedWidget {
  const _MiuixThemeSourceScope({
    required this.colorSchemeMode,
    required super.child,
  });

  final MiuixColorMode? colorSchemeMode;

  @override
  bool updateShouldNotify(_MiuixThemeSourceScope oldWidget) =>
      colorSchemeMode != oldWidget.colorSchemeMode;
}

/// Builds the default text theme used by Miuix.
///
/// The sizes follow the MIUIX documentation closely while remaining native
/// Flutter [TextTheme] values for interoperability.
TextTheme _defaultTextTheme() {
  // Keep the example's localized labels readable on every target. Android
  // normally resolves Noto Sans CJK, while Windows and Apple platforms use
  // their native CJK UI fonts before falling back to the generic sans face.
  //
  // Compose leaves most MIUIX line heights unspecified, so the platform font
  // metrics settle at approximately 1.16 em on the Android reference device.
  // Material's generated 2021 typography instead contributes heights around
  // 1.4 em when a partial TextStyle is merged into ThemeData. That difference
  // is structural: a title plus summary makes BasicComponent about 7dp taller,
  // and every SmallTitle pushes the following card farther down the page.
  //
  // Give every mapped MIUIX role the measured source line box. Components that
  // intentionally use another metric, such as the 1.2-em Paragraph role, keep
  // specifying it locally. Compose also leaves letter spacing at zero; writing
  // that value explicitly prevents ThemeData from merging Material 3 tracking
  // into otherwise partial styles. These defaults are especially important
  // for Chinese: selecting a CJK fallback must change glyphs without changing
  // the original Compose layout geometry.
  const sourceLineHeight = 1.16;
  const fallback = <String>[
    'Noto Sans SC',
    'Noto Sans CJK SC',
    'Microsoft YaHei',
    'PingFang SC',
    'sans-serif',
  ];
  return const TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      height: sourceLineHeight,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      fontFamilyFallback: fallback,
    ),
    displayMedium: TextStyle(
      fontSize: 24,
      height: sourceLineHeight,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      fontFamilyFallback: fallback,
    ),
    displaySmall: TextStyle(
      fontSize: 20,
      height: sourceLineHeight,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      fontFamilyFallback: fallback,
    ),
    headlineMedium: TextStyle(
      fontSize: 18,
      height: sourceLineHeight,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      fontFamilyFallback: fallback,
    ),
    titleLarge: TextStyle(
      fontSize: 17,
      height: sourceLineHeight,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      fontFamilyFallback: fallback,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      height: sourceLineHeight,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      fontFamilyFallback: fallback,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      height: sourceLineHeight,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      fontFamilyFallback: fallback,
    ),
    bodyLarge: TextStyle(
      fontSize: 17,
      height: sourceLineHeight,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      fontFamilyFallback: fallback,
    ),
    bodyMedium: TextStyle(
      fontSize: 16,
      height: sourceLineHeight,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      fontFamilyFallback: fallback,
    ),
    bodySmall: TextStyle(
      fontSize: 14,
      height: sourceLineHeight,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      fontFamilyFallback: fallback,
    ),
    labelLarge: TextStyle(
      fontSize: 17,
      height: sourceLineHeight,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      fontFamilyFallback: fallback,
    ),
    labelMedium: TextStyle(
      fontSize: 13,
      height: sourceLineHeight,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      fontFamilyFallback: fallback,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      height: sourceLineHeight,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      fontFamilyFallback: fallback,
    ),
  );
}
