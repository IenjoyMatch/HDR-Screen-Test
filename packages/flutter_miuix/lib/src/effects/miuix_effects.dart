import '../icons/miuix_icon_interaction.dart';
import 'dart:async';
import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

import '../theme/miuix_semantic_colors.dart';
import '../theme/miuix_theme.dart';
import '../platform/miuix_haptics.dart';

/// Shared source constants for every squircle path and shader-backed surface.
abstract final class MiuixSquircleDefaults {
  static const double extension = 1.1;
  static const double extensionMin = 1;
  static const double extensionMax = 2;
}

/// Resolves the active subtree's squircle capability.
///
/// Flutter retains an equivalent CPU path fallback, so a missing runtime
/// shader does not force round-rect geometry as it does in the source module.
bool miuixIsSquircleEnabled(BuildContext context) =>
    MiuixTheme.of(context).enableSquircle;

/// Whether this runtime can compile arbitrary AGSL/SkSL source strings.
///
/// Flutter deliberately exposes build-time compiled [FragmentProgram] assets,
/// not the source module's `RuntimeShader(shaderString)` constructor. Returning
/// false is the exact capability answer; use
/// [miuixIsBundledFragmentShaderSupported] for package shader assets.
bool miuixIsRuntimeShaderSupported() => false;

/// Whether the renderer can apply a build-time compiled fragment shader.
bool miuixIsBundledFragmentShaderSupported() =>
    ImageFilter.isShaderFilterSupported;

/// Whether Flutter can express the source's RenderEffect effect graph.
///
/// Blur, color matrix, composition, and backdrop filtering are stable
/// ImageFilter operations on Flutter's supported renderers. Individual shader
/// filters still require [miuixIsBundledFragmentShaderSupported].
bool miuixIsRenderEffectSupported() => true;

/// Press feedback variants used by Miuix controls.
enum MiuixPressFeedbackType {
  /// Scale the child down while pressed.
  sink,

  /// Keep layout stable and only expose hover/press callbacks.
  none,

  /// Rotate the child subtly toward the pointer position while pressed.
  tilt,
}

/// Observable press state shared by source-compatible MIUIX controls.
///
/// Compose accepts a nullable `MutableInteractionSource` on controls such as
/// `TabRow`. Flutter owns its gesture recognizers inside [MiuixPressable], so
/// this small adapter publishes the same externally observable pressed state
/// without exposing framework-specific pointer events.
class MiuixInteractionSource extends ChangeNotifier {
  bool _pressed = false;
  bool _focused = false;

  /// Whether a pointer is currently pressing a connected control.
  bool get pressed => _pressed;

  /// Whether a connected focusable control currently owns focus.
  bool get focused => _focused;

  /// Publishes a new pressed state.
  void setPressed(bool value) {
    if (_pressed == value) {
      return;
    }
    _pressed = value;
    notifyListeners();
  }

  /// Publishes a new focus state.
  ///
  /// Compose uses the same `MutableInteractionSource` for press and focus
  /// interactions. Keeping both signals here lets source-compatible input
  /// fields expose the same observable state without leaking a [FocusNode].
  void setFocused(bool value) {
    if (_focused == value) {
      return;
    }
    _focused = value;
    notifyListeners();
  }
}

/// MIUIX indication descriptor used by source-compatible clickable controls.
///
/// A null descriptor disables indication, matching Compose's nullable
/// `Indication`. A descriptor with no explicit [color] resolves the current
/// theme's `onBackground`, just like `LocalIndication` inside `MiuixTheme`.
@immutable
class MiuixIndication {
  /// Creates the source rectangular indication.
  const MiuixIndication({this.color});

  /// Optional overlay color; null inherits the active MIUIX semantic color.
  final Color? color;

  /// Resolves the source theme-local color for painting.
  Color resolve(BuildContext context) =>
      color ?? MiuixSemanticColors.of(context)['onBackground'];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MiuixIndication && other.color == color;

  @override
  int get hashCode => color.hashCode;
}

/// Exact current-source spring for one MIUIX indication channel.
///
/// [hoverOrFocus] selects the slower hover/focus pair; false selects the
/// press/hold pair. The response-to-stiffness conversion is the same formula
/// used by `folmeSpring` in the authoritative Kotlin source.
@visibleForTesting
SpringDescription debugMiuixIndicationSpring({
  required bool entering,
  bool hoverOrFocus = false,
}) {
  final response = hoverOrFocus ? (entering ? .6 : .2) : (entering ? .2 : .35);
  final dampingRatio = entering ? 1.0 : (hoverOrFocus ? .96 : .95);
  final angularFrequency = 2 * math.pi / response;
  return SpringDescription.withDampingRatio(
    mass: 1,
    stiffness: angularFrequency * angularFrequency,
    ratio: dampingRatio,
  );
}

/// Exact spring used by MIUIX `SinkFeedback`.
@visibleForTesting
SpringDescription debugMiuixSinkSpring({
  double dampingRatio = .8,
  double stiffness = 600,
}) => SpringDescription.withDampingRatio(
  mass: 1,
  stiffness: stiffness,
  ratio: dampingRatio,
);

/// Exact spring used by MIUIX `TiltFeedback`.
@visibleForTesting
SpringDescription debugMiuixTiltSpring() =>
    SpringDescription.withDampingRatio(mass: 1, stiffness: 400, ratio: .6);

/// Flutter projective entry matching MIUIX's 12-density camera distance.
///
/// Android and Matrix4 use opposite camera-axis conventions. A positive entry
/// expands the far edge and then lets the outer clip disguise the tilt; the
/// negative entry makes the far edge recede like the source graphics layer.
@visibleForTesting
double debugMiuixTiltPerspective() => -.0012;

/// Resolves the quadrant pivot and ±8-degree rotation from the source node.
@visibleForTesting
({Alignment origin, double rotationXDegrees, double rotationYDegrees})
debugMiuixTiltTarget(Offset localPosition, Size size) {
  if (size.isEmpty) {
    return (origin: Alignment.center, rotationXDegrees: 0, rotationYDegrees: 0);
  }
  final pressOnLeft = localPosition.dx < size.width / 2;
  final pressOnTop = localPosition.dy < size.height / 2;
  return (
    // Compose uses the opposite corner as TransformOrigin.
    origin: Alignment(pressOnLeft ? 1 : -1, pressOnTop ? 1 : -1),
    rotationXDegrees: pressOnTop ? 8 : -8,
    rotationYDegrees: pressOnLeft ? -8 : 8,
  );
}

/// Blend operations supported by MIUIX texture-blur color layers.
///
/// Standard entries use native Skia operations. MIUIX's Lab and extended
/// entries are evaluated by the package runtime shader when Impeller supports
/// shader image filters, with a chroma-preserving Skia fallback elsewhere.
enum MiuixBlurBlendMode {
  clear,
  src,
  dst,

  /// Draw the source color over the blurred destination.
  srcOver,
  dstOver,
  srcIn,
  dstIn,
  srcOut,
  dstOut,
  srcAtop,
  dstAtop,
  xor,
  plus,
  modulate,

  /// Screen blend.
  screen,

  /// Multiply blend.
  multiply,

  /// Overlay blend.
  overlay,
  darken,
  lighten,

  /// Soft-light blend.
  softLight,

  /// Hard-light blend.
  hardLight,

  /// Color-dodge blend.
  colorDodge,

  /// Color-burn blend.
  colorBurn,

  difference,
  exclusion,
  hue,
  saturation,
  color,

  /// Linear-light source mode, rendered with portable hard light.
  linearLight,

  /// Greyscale linear-light source mode.
  linearLightWithGreyscale,

  /// Lab linear-light source mode.
  linearLightLab,

  /// Lab source color mode.
  lab,

  /// Lab lightening mode.
  labLightenWithGreyscale,

  /// Lab darkening mode.
  labDarkenWithGreyscale,

  /// MIUI difference mode.
  miDifference,

  /// MIUI color-dodge mode.
  miColorDodge,

  /// MIUI color-burn mode.
  miColorBurn,

  /// Additive lightening mode.
  plusLighter,

  /// Additive darkening mode.
  plusDarker,

  /// Luminosity blend.
  luminosity,

  /// Alpha blend whose mask resolves to the sampled backdrop red channel.
  alphaBlend,

  /// Saturation adjustment driven by [MiuixBlurColors.saturation].
  miSaturation,

  /// Brightness adjustment driven by [MiuixBlurColors.brightness].
  miBrightness,

  /// MIUIX luminance-curve adjustment.
  miLuminance,
}

/// One ordered color layer applied after backdrop blur.
@immutable
class MiuixBlendColorEntry {
  /// Creates a color and blend-operation pair.
  const MiuixBlendColorEntry(
    this.color, [
    this.mode = MiuixBlurBlendMode.srcOver,
  ]);

  /// Color, including the layer's source alpha.
  final Color color;

  /// Operation used to composite [color] over the blurred destination.
  final MiuixBlurBlendMode mode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MiuixBlendColorEntry &&
          other.color == color &&
          other.mode == mode;

  @override
  int get hashCode => Object.hash(color, mode);
}

/// Compatibility name retained for pre-source-model Flutter callers.
typedef MiuixBlurBlendEntry = MiuixBlendColorEntry;

/// Color configuration for blur and glass surfaces.
@immutable
class MiuixBlurColors {
  /// Creates a blur color set.
  const MiuixBlurColors({
    this.tint,
    this.border,
    this.highlight,
    this.opacity = 0.72,
    this.blendColors = const [],
    this.brightness = 0,
    this.contrast = 1,
    this.saturation = 1,
  });

  /// Optional surface tint.
  final Color? tint;

  /// Optional outline color.
  final Color? border;

  /// Optional highlight color.
  final Color? highlight;

  /// Tint opacity used by glass surfaces.
  final double opacity;

  /// Ordered MIUIX blend-color layers painted over the sampled backdrop.
  final List<MiuixBlendColorEntry> blendColors;

  /// Source brightness adjustment in the range -1 to 1.
  final double brightness;

  /// Source contrast multiplier, where 1 is neutral.
  final double contrast;

  /// Source saturation multiplier, where 1 is neutral.
  final double saturation;

  /// Returns a color recipe with selected source or compatibility fields.
  MiuixBlurColors copyWith({
    Color? tint,
    bool clearTint = false,
    Color? border,
    bool clearBorder = false,
    Color? highlight,
    bool clearHighlight = false,
    double? opacity,
    List<MiuixBlendColorEntry>? blendColors,
    double? brightness,
    double? contrast,
    double? saturation,
  }) => MiuixBlurColors(
    tint: clearTint ? null : tint ?? this.tint,
    border: clearBorder ? null : border ?? this.border,
    highlight: clearHighlight ? null : highlight ?? this.highlight,
    opacity: opacity ?? this.opacity,
    blendColors: blendColors ?? this.blendColors,
    brightness: brightness ?? this.brightness,
    contrast: contrast ?? this.contrast,
    saturation: saturation ?? this.saturation,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MiuixBlurColors &&
          other.tint == tint &&
          other.border == border &&
          other.highlight == highlight &&
          other.opacity == opacity &&
          listEquals(other.blendColors, blendColors) &&
          other.brightness == brightness &&
          other.contrast == contrast &&
          other.saturation == saturation;

  @override
  int get hashCode => Object.hash(
    tint,
    border,
    highlight,
    opacity,
    Object.hashAll(blendColors),
    brightness,
    contrast,
    saturation,
  );
}

/// Light position used by highlight effects.
@immutable
class MiuixLightPosition {
  /// Creates the source normalized three-dimensional light position.
  const MiuixLightPosition({this.dx = .5, this.dy = .5, this.z = -.5});

  /// Horizontal UV coordinate relative to the highlight bounds.
  final double dx;

  /// Vertical UV coordinate relative to the highlight bounds.
  final double dy;

  /// Signed depth; negative values light the inward-facing edge.
  final double z;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MiuixLightPosition &&
          other.dx == dx &&
          other.dy == dy &&
          other.z == z;

  @override
  int get hashCode => Object.hash(dx, dy, z);
}

/// One directional source contributing to a bloom highlight.
@immutable
class MiuixLightSource {
  const MiuixLightSource({
    required this.position,
    this.color = Colors.white,
    this.intensity = 1,
  });

  final MiuixLightPosition position;
  final Color color;
  final double intensity;

  MiuixLightSource copyWith({
    MiuixLightPosition? position,
    Color? color,
    double? intensity,
  }) => MiuixLightSource(
    position: position ?? this.position,
    color: color ?? this.color,
    intensity: intensity ?? this.intensity,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MiuixLightSource &&
          other.position == position &&
          other.color == color &&
          other.intensity == intensity;

  @override
  int get hashCode => Object.hash(position, color, intensity);
}

/// Pluggable edge-highlight style.
@immutable
abstract class MiuixHighlightStyle {
  const MiuixHighlightStyle();

  Color get color;
  BlendMode get blendMode;

  static const MiuixBloomStroke defaultStyle =
      MiuixBloomStroke.glassStrokeMiddleLight;
}

/// Rounded-rectangle bloom stroke with two directional light sources.
@immutable
class MiuixBloomStroke extends MiuixHighlightStyle {
  const MiuixBloomStroke({
    this.color = const Color(0x0DFFFFFF),
    this.blendMode = BlendMode.plus,
    this.innerBlurRadius = 2.8,
    this.primaryLight = const MiuixLightSource(
      position: MiuixLightPosition(),
      intensity: .4,
    ),
    this.secondaryLight = const MiuixLightSource(
      position: MiuixLightPosition(dy: .8),
      intensity: .25,
    ),
    this.dualPeak = false,
  });

  @override
  final Color color;
  @override
  final BlendMode blendMode;
  final double innerBlurRadius;
  final MiuixLightSource primaryLight;
  final MiuixLightSource secondaryLight;
  final bool dualPeak;

  static const glassStrokeBigLight = MiuixBloomStroke(
    innerBlurRadius: 3.5,
    primaryLight: MiuixLightSource(
      position: MiuixLightPosition(),
      intensity: .3,
    ),
    secondaryLight: MiuixLightSource(
      position: MiuixLightPosition(dy: .6),
      intensity: .2,
    ),
  );
  static const glassStrokeMiddleLight = MiuixBloomStroke();
  static const glassStrokeSmallLight = MiuixBloomStroke(
    innerBlurRadius: 2.6,
    primaryLight: MiuixLightSource(
      position: MiuixLightPosition(),
      intensity: .6,
    ),
    secondaryLight: MiuixLightSource(
      position: MiuixLightPosition(dy: .95),
      intensity: .35,
    ),
  );
  static const glassStrokeBigDark = MiuixBloomStroke(
    innerBlurRadius: 1.7,
    primaryLight: MiuixLightSource(
      position: MiuixLightPosition(),
      intensity: .4,
    ),
    secondaryLight: MiuixLightSource(
      position: MiuixLightPosition(dy: .6),
      intensity: .25,
    ),
  );
  static const glassStrokeMiddleDark = MiuixBloomStroke(
    color: Color(0x0FFFFFFF),
    innerBlurRadius: 2,
    primaryLight: MiuixLightSource(
      position: MiuixLightPosition(),
      intensity: .5,
    ),
  );
  static const glassStrokeSmallDark = MiuixBloomStroke(
    color: Color(0x14FFFFFF),
    innerBlurRadius: 2.3,
    primaryLight: MiuixLightSource(
      position: MiuixLightPosition(),
      intensity: .6,
    ),
    secondaryLight: MiuixLightSource(
      position: MiuixLightPosition(dy: .95, z: -.36),
      intensity: .25,
    ),
  );

  MiuixBloomStroke copyWith({
    Color? color,
    BlendMode? blendMode,
    double? innerBlurRadius,
    MiuixLightSource? primaryLight,
    MiuixLightSource? secondaryLight,
    bool? dualPeak,
  }) => MiuixBloomStroke(
    color: color ?? this.color,
    blendMode: blendMode ?? this.blendMode,
    innerBlurRadius: innerBlurRadius ?? this.innerBlurRadius,
    primaryLight: primaryLight ?? this.primaryLight,
    secondaryLight: secondaryLight ?? this.secondaryLight,
    dualPeak: dualPeak ?? this.dualPeak,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MiuixBloomStroke &&
          other.color == color &&
          other.blendMode == blendMode &&
          other.innerBlurRadius == innerBlurRadius &&
          other.primaryLight == primaryLight &&
          other.secondaryLight == secondaryLight &&
          other.dualPeak == dualPeak;

  @override
  int get hashCode => Object.hash(
    color,
    blendMode,
    innerBlurRadius,
    primaryLight,
    secondaryLight,
    dualPeak,
  );
}

/// Highlight configuration for glass and liquid-like panels.
@immutable
class MiuixHighlight {
  /// Creates a highlight description.
  const MiuixHighlight({
    this.color = const Color(0x0DFFFFFF),
    this.blur = 2.8,
    this.position = const MiuixLightPosition(),
    this.primaryIntensity = .4,
    this.secondaryPosition = const MiuixLightPosition(dy: .8),
    this.secondaryColor = Colors.white,
    this.secondaryIntensity = .25,
    this.width = .8,
    this.alpha = 1,
    this.style,
  });

  /// Source large-container highlight for a light color scheme.
  static const glassStrokeBigLight = MiuixHighlight(
    blur: 3.5,
    primaryIntensity: .3,
    secondaryPosition: MiuixLightPosition(dy: .6),
    secondaryIntensity: .2,
    style: MiuixBloomStroke.glassStrokeBigLight,
  );

  /// Source medium-container highlight for a light color scheme.
  static const glassStrokeMiddleLight = MiuixHighlight(
    style: MiuixBloomStroke.glassStrokeMiddleLight,
  );

  /// Source small-container highlight for a light color scheme.
  static const glassStrokeSmallLight = MiuixHighlight(
    blur: 2.6,
    primaryIntensity: .6,
    secondaryPosition: MiuixLightPosition(dy: .95),
    secondaryIntensity: .35,
    style: MiuixBloomStroke.glassStrokeSmallLight,
  );

  /// Source large-container highlight for a dark color scheme.
  static const glassStrokeBigDark = MiuixHighlight(
    blur: 1.7,
    primaryIntensity: .4,
    secondaryPosition: MiuixLightPosition(dy: .6),
    secondaryIntensity: .25,
    style: MiuixBloomStroke.glassStrokeBigDark,
  );

  /// Source medium-container highlight for a dark color scheme.
  static const glassStrokeMiddleDark = MiuixHighlight(
    color: Color(0x0FFFFFFF),
    blur: 2,
    primaryIntensity: .5,
    style: MiuixBloomStroke.glassStrokeMiddleDark,
  );

  /// Source small-container highlight for a dark color scheme.
  static const glassStrokeSmallDark = MiuixHighlight(
    color: Color(0x14FFFFFF),
    blur: 2.3,
    primaryIntensity: .6,
    secondaryPosition: MiuixLightPosition(dy: .95, z: -.36),
    secondaryIntensity: .25,
    style: MiuixBloomStroke.glassStrokeSmallDark,
  );

  /// Highlight color.
  final Color color;

  /// Softness applied by the painter.
  final double blur;

  /// Where the virtual light source sits.
  final MiuixLightPosition position;

  /// Source multiplier for the primary directional light.
  final double primaryIntensity;

  /// Position of the secondary directional light.
  final MiuixLightPosition secondaryPosition;

  /// Color of the secondary directional light.
  final Color secondaryColor;

  /// Source multiplier for the secondary directional light.
  final double secondaryIntensity;

  /// Width of the source's outer stroke band.
  final double width;

  /// Overall highlight-opacity multiplier.
  final double alpha;

  /// Canonical source shading model.
  ///
  /// When omitted, the legacy flattened fields above are losslessly projected
  /// to a [MiuixBloomStroke], preserving existing Flutter call sites.
  final MiuixHighlightStyle? style;

  /// Effective style consumed by the renderer.
  MiuixHighlightStyle get resolvedStyle =>
      style ??
      MiuixBloomStroke(
        color: color,
        innerBlurRadius: blur,
        primaryLight: MiuixLightSource(
          position: position,
          color: color,
          intensity: primaryIntensity,
        ),
        secondaryLight: MiuixLightSource(
          position: secondaryPosition,
          color: secondaryColor,
          intensity: secondaryIntensity,
        ),
      );

  /// Returns a copy with selected highlight parameters replaced.
  MiuixHighlight copyWith({
    Color? color,
    double? blur,
    MiuixLightPosition? position,
    double? primaryIntensity,
    MiuixLightPosition? secondaryPosition,
    Color? secondaryColor,
    double? secondaryIntensity,
    double? width,
    double? alpha,
    MiuixHighlightStyle? style,
  }) {
    final changesLegacyStyle =
        color != null ||
        blur != null ||
        position != null ||
        primaryIntensity != null ||
        secondaryPosition != null ||
        secondaryColor != null ||
        secondaryIntensity != null;
    return MiuixHighlight(
      color: color ?? this.color,
      blur: blur ?? this.blur,
      position: position ?? this.position,
      primaryIntensity: primaryIntensity ?? this.primaryIntensity,
      secondaryPosition: secondaryPosition ?? this.secondaryPosition,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      secondaryIntensity: secondaryIntensity ?? this.secondaryIntensity,
      width: width ?? this.width,
      alpha: alpha ?? this.alpha,
      style: style ?? (changesLegacyStyle ? null : this.style),
    );
  }
}

/// Backdrop abstraction used by glass and popup adapters.
///
/// MIUIX has a richer Compose backdrop pipeline. Flutter apps can pass this
/// object to keep blur/tint values together without coupling to widget details.
@immutable
class MiuixBackdrop {
  /// Creates backdrop effect data.
  const MiuixBackdrop({
    this.blur = 20,
    this.blurY,
    this.noise = 0,
    this.brightness = 0,
    this.contrast = 1,
    this.saturation = 1,
    this.colors = const MiuixBlurColors(),
    this.highlight,
    this.effects = const [],
    this.enabled = true,
  });

  /// MIUIX blur radius in logical pixels (the source API's dp unit).
  ///
  /// The source runtime converts this radius to a Gaussian sigma with a 0.45
  /// coefficient before sampling. Compose first converts dp to physical pixels;
  /// Flutter's filter accepts logical pixels, so the density factors cancel.
  final double blur;

  /// Optional vertical blur radius in logical pixels.
  ///
  /// When null, [blur] is used on both axes. This mirrors the source scope's
  /// `blur(radiusX, radiusY = radiusX)` contract without changing existing
  /// isotropic recipes.
  final double? blurY;

  /// Fine grain strength from 0 to 0.1.
  final double noise;

  /// Brightness adjustment from -1 to 1.
  final double brightness;

  /// Contrast multiplier, where 1 is neutral.
  final double contrast;

  /// Saturation multiplier, where 1 is neutral.
  final double saturation;

  /// Tint and border colors.
  final MiuixBlurColors colors;

  /// Optional highlight effect.
  final MiuixHighlight? highlight;

  /// Ordered image effects applied after the built-in texture-blur recipe.
  ///
  /// Flutter cannot compile an arbitrary AGSL string at runtime. Callers can
  /// instead supply an engine [ImageFilter], including one backed by a
  /// precompiled [FragmentShader]. Entries retain source call order: the first
  /// filter consumes the texture recipe, and each following filter consumes
  /// the preceding result.
  final List<ImageFilter> effects;

  /// Whether backdrop rendering is active.
  final bool enabled;

  /// Returns a backdrop recipe with selected values replaced.
  MiuixBackdrop copyWith({
    double? blur,
    double? blurY,
    bool clearBlurY = false,
    double? noise,
    double? brightness,
    double? contrast,
    double? saturation,
    MiuixBlurColors? colors,
    MiuixHighlight? highlight,
    List<ImageFilter>? effects,
    bool? enabled,
  }) {
    return MiuixBackdrop(
      blur: blur ?? this.blur,
      blurY: clearBlurY ? null : blurY ?? this.blurY,
      noise: noise ?? this.noise,
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
      saturation: saturation ?? this.saturation,
      colors: colors ?? this.colors,
      highlight: highlight ?? this.highlight,
      effects: effects ?? this.effects,
      enabled: enabled ?? this.enabled,
    );
  }
}

/// Source constants shared by texture and progressive blur effects.
abstract final class MiuixBlurDefaults {
  /// Default texture-blur radius.
  static const double blurRadius = 20;

  /// Default texture-blur dithering strength.
  static const double noiseCoefficient = .0045;

  /// Progressive blur is noise-free by default.
  static const double progressiveNoiseCoefficient = 0;

  /// Largest radius accepted by the current source effect.
  static const double maxBlurRadius = 150;

  /// Creates the source blur-color value object.
  static MiuixBlurColors blurColors({
    List<MiuixBlendColorEntry> blendColors = const [],
    double brightness = 0,
    double contrast = 1,
    double saturation = 1,
  }) => MiuixBlurColors(
    blendColors: blendColors,
    brightness: brightness,
    contrast: contrast,
    saturation: saturation,
  );
}

/// Direction and falloff band for a source progressive blur.
@immutable
class MiuixProgressiveBlur {
  /// Creates a progressive blur description.
  const MiuixProgressiveBlur({
    this.angle = 90,
    this.startFraction = 0,
    this.endFraction = 1,
    this.curve = 1,
  });

  /// Blur is strongest at the top and clear at the bottom.
  static const top = MiuixProgressiveBlur();

  /// Blur is strongest at the bottom and clear at the top.
  static const bottom = MiuixProgressiveBlur(angle: 270);

  /// Blur is strongest at the left and clear at the right.
  static const left = MiuixProgressiveBlur(angle: 0);

  /// Blur is strongest at the right and clear at the left.
  static const right = MiuixProgressiveBlur(angle: 180);

  /// Clockwise direction in degrees from the positive horizontal axis.
  final double angle;

  /// Projected position at which blur remains fully strong.
  final double startFraction;

  /// Projected position at which blur reaches zero.
  final double endFraction;

  /// Positive power exponent shaping the transition between both endpoints.
  final double curve;

  /// Returns a source-style copy with independently replaced fields.
  MiuixProgressiveBlur copyWith({
    double? angle,
    double? startFraction,
    double? endFraction,
    double? curve,
  }) {
    return MiuixProgressiveBlur(
      angle: angle ?? this.angle,
      startFraction: startFraction ?? this.startFraction,
      endFraction: endFraction ?? this.endFraction,
      curve: curve ?? this.curve,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MiuixProgressiveBlur &&
            other.angle == angle &&
            other.startFraction == startFraction &&
            other.endFraction == endFraction &&
            other.curve == curve;
  }

  @override
  int get hashCode => Object.hash(angle, startFraction, endFraction, curve);
}

/// Backdrop whose blur and post-processing fade along a source gradient.
///
/// The current source composites Gaussian levels at 100%, 40%, and 13% of the
/// requested sigma before reaching a pixel-sharp end. Flutter does not expose
/// the source's multi-child runtime shader, so this adapter paints those same
/// levels from weakest to strongest and uses the identical smoothstep/power
/// masks. Incremental sigmas preserve each target variance on the full-strength
/// plateaus even though Flutter's backdrop filters are evaluated in sequence.
class MiuixProgressiveLayerBackdrop extends StatelessWidget {
  /// Creates a progressive texture-blur layer.
  const MiuixProgressiveLayerBackdrop({
    super.key,
    required this.child,
    this.backdrop = const MiuixBackdrop(
      blur: MiuixBlurDefaults.blurRadius,
      noise: MiuixBlurDefaults.progressiveNoiseCoefficient,
    ),
    this.gradient = MiuixProgressiveBlur.top,
    this.radius = 0,
  });

  /// Ordinary foreground content, painted above the masked blur.
  final Widget child;

  /// Maximum-strength blur, colors, noise, and highlight configuration.
  final MiuixBackdrop backdrop;

  /// Direction and power falloff of the blur.
  final MiuixProgressiveBlur gradient;

  /// Clip radius of the effect region.
  final double radius;

  static const _levelFractions = <double>[.13, .4, 1];

  /// Builds the source `PROGRESSIVE_LEVEL_MASK_SHADER` alpha ramp.
  ///
  /// [level] and [slope] map directly to the shader uniforms. The three blur
  /// levels use `(3,3)`, `(2,3)`, and `(1,3)`; the folded post-effect pass uses
  /// `(1,1)`. Sixty-four linear segments keep the CPU-created Flutter gradient
  /// within sub-pixel alpha error of the analytic shader on the 420-dpi sample.
  (List<double>, List<Color>) _mask({
    required double level,
    required double slope,
  }) {
    final rawStart = gradient.startFraction.isFinite
        ? gradient.startFraction.clamp(0.0, 1.0)
        : 0.0;
    final rawEnd = gradient.endFraction.isFinite
        ? gradient.endFraction.clamp(0.0, 1.0)
        : 1.0;
    final end = rawEnd == rawStart
        ? (rawStart == 1 ? 0.999999 : rawStart + .000001)
        : rawEnd;
    final curve = gradient.curve.isFinite && gradient.curve > 0
        ? gradient.curve
        : 1.0;
    final samples = <double>{
      for (var index = 0; index <= 64; index++) index / 64,
      rawStart,
      end,
    }.toList()..sort();
    final colors = <Color>[];
    for (final position in samples) {
      final raw = ((position - rawStart) / (end - rawStart)).clamp(0.0, 1.0);
      final smoothRaw = raw * raw * (3 - 2 * raw);
      final curvedRaw = math.pow(smoothRaw, curve).toDouble();
      final unclamped = level - curvedRaw * slope;
      final weight = unclamped.clamp(0.0, 1.0);
      final smoothWeight = weight * weight * (3 - 2 * weight);
      colors.add(Colors.white.withValues(alpha: smoothWeight));
    }
    return (samples, colors);
  }

  /// Wraps one backdrop pass in the source band mask.
  Widget _maskedLayer({
    required Alignment direction,
    required double level,
    required double slope,
    required Widget child,
    required Key key,
  }) {
    final (stops, colors) = _mask(level: level, slope: slope);
    return ShaderMask(
      key: key,
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment(-direction.x, -direction.y),
        end: direction,
        colors: colors,
        stops: stops,
      ).createShader(bounds),
      child: child,
    );
  }

  /// Creates a blur-only pass; color controls are folded into a separate ramp.
  Widget _blurLevel({
    required Alignment direction,
    required double logicalSigmaX,
    required double logicalSigmaY,
    required double level,
    required Key key,
  }) {
    return _maskedLayer(
      direction: direction,
      level: level,
      slope: 3,
      key: key,
      child: BackdropFilter(
        // ShaderMask already owns the required saveLayer. Source-over lets the
        // filtered backdrop survive that layer on Skia; `src` clears it before
        // the destination-in gradient is applied and produces a sharp image.
        blendMode: BlendMode.srcOver,
        filter: ImageFilter.blur(sigmaX: logicalSigmaX, sigmaY: logicalSigmaY),
        child: const SizedBox.expand(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!backdrop.enabled) return child;
    final angle = gradient.angle.isFinite ? gradient.angle : 90.0;
    final radians = angle * math.pi / 180;
    final direction = Alignment(math.cos(radians), math.sin(radians));
    final maximumSigmaX = _miuixSourceBlurSigma(backdrop.blur);
    final maximumSigmaY = _miuixSourceBlurSigma(
      backdrop.blurY ?? backdrop.blur,
    );
    final weakSigmaX = maximumSigmaX * _levelFractions[0];
    final weakSigmaY = maximumSigmaY * _levelFractions[0];
    final middleScale = math.sqrt(
      _levelFractions[1] * _levelFractions[1] -
          _levelFractions[0] * _levelFractions[0],
    );
    final strongScale = math.sqrt(
      _levelFractions[2] * _levelFractions[2] -
          _levelFractions[1] * _levelFractions[1],
    );
    final middleSigmaX = maximumSigmaX * middleScale;
    final middleSigmaY = maximumSigmaY * middleScale;
    final strongSigmaX = maximumSigmaX * strongScale;
    final strongSigmaY = maximumSigmaY * strongScale;
    final postBackdrop = MiuixBackdrop(
      blur: 0,
      noise: backdrop.noise,
      brightness: backdrop.brightness,
      contrast: backdrop.contrast,
      saturation: backdrop.saturation,
      colors: backdrop.colors,
      highlight: backdrop.highlight,
      effects: backdrop.effects,
    );
    final hasPostEffect =
        backdrop.noise > 0 ||
        backdrop.brightness != 0 ||
        backdrop.contrast != 1 ||
        backdrop.saturation != 1 ||
        backdrop.colors.blendColors.isNotEmpty ||
        backdrop.colors.tint == null ||
        (backdrop.colors.tint?.a ?? 0) > 0 ||
        backdrop.highlight != null ||
        backdrop.effects.isNotEmpty;
    final postEffectLayer = hasPostEffect
        ? Positioned.fill(
            child: _maskedLayer(
              direction: direction,
              level: 1,
              slope: 1,
              key: const ValueKey('miuix-progressive-post-effect-mask'),
              child: MiuixLayerBackdrop(
                backdrop: postBackdrop,
                radius: radius,
                padding: EdgeInsets.zero,
                child: const SizedBox.expand(),
              ),
            ),
          )
        : null;
    final stack = Stack(
      fit: StackFit.passthrough,
      children: [
        Positioned.fill(
          child: _blurLevel(
            direction: direction,
            logicalSigmaX: weakSigmaX,
            logicalSigmaY: weakSigmaY,
            level: 3,
            key: const ValueKey('miuix-progressive-blur-level-13'),
          ),
        ),
        Positioned.fill(
          child: _blurLevel(
            direction: direction,
            logicalSigmaX: middleSigmaX,
            logicalSigmaY: middleSigmaY,
            level: 2,
            key: const ValueKey('miuix-progressive-blur-level-40'),
          ),
        ),
        Positioned.fill(
          child: _blurLevel(
            direction: direction,
            logicalSigmaX: strongSigmaX,
            logicalSigmaY: strongSigmaY,
            level: 1,
            key: const ValueKey('miuix-progressive-blur-level-100'),
          ),
        ),
        ?postEffectLayer,
        child,
      ],
    );
    final fallback = radius <= 0
        ? stack
        : ClipRRect(borderRadius: BorderRadius.circular(radius), child: stack);
    if (!ImageFilter.isShaderFilterSupported ||
        (maximumSigmaX <= 0 && maximumSigmaY <= 0)) {
      return fallback;
    }
    return _MiuixProgressiveRuntimeBackdrop(
      maximumSigmaX: maximumSigmaX,
      maximumSigmaY: maximumSigmaY,
      gradient: gradient,
      radius: radius,
      postEffectLayer: postEffectLayer,
      fallback: fallback,
      child: child,
    );
  }
}

/// Loads and configures the source variable-radius Gaussian runtime effect.
class _MiuixProgressiveRuntimeBackdrop extends StatefulWidget {
  const _MiuixProgressiveRuntimeBackdrop({
    required this.maximumSigmaX,
    required this.maximumSigmaY,
    required this.gradient,
    required this.radius,
    required this.postEffectLayer,
    required this.fallback,
    required this.child,
  });

  final double maximumSigmaX;
  final double maximumSigmaY;
  final MiuixProgressiveBlur gradient;
  final double radius;
  final Widget? postEffectLayer;
  final Widget fallback;
  final Widget child;

  @override
  State<_MiuixProgressiveRuntimeBackdrop> createState() =>
      _MiuixProgressiveRuntimeBackdropState();
}

class _MiuixProgressiveRuntimeBackdropState
    extends State<_MiuixProgressiveRuntimeBackdrop> {
  static Future<FragmentProgram?>? _programFuture;
  FragmentShader? _horizontalShader;
  FragmentShader? _verticalShader;

  @override
  void initState() {
    super.initState();
    _ensureProgram();
  }

  Future<void> _ensureProgram() async {
    _programFuture ??= _loadProgram();
    final program = await _programFuture;
    if (!mounted || program == null) return;
    setState(() {
      _horizontalShader = program.fragmentShader();
      _verticalShader = program.fragmentShader();
    });
  }

  static Future<FragmentProgram?> _loadProgram() async {
    const asset = 'shaders/miuix_progressive_blur.frag';
    try {
      return await FragmentProgram.fromAsset('packages/flutter_miuix/$asset');
    } catch (packageError) {
      try {
        return await FragmentProgram.fromAsset(asset);
      } catch (rootError) {
        debugPrint(
          'Miuix progressive blur shader failed to load: '
          '$packageError; $rootError',
        );
        return null;
      }
    }
  }

  void _configureShader(FragmentShader shader, {required bool horizontal}) {
    final angle = widget.gradient.angle.isFinite ? widget.gradient.angle : 90.0;
    final radians = angle * math.pi / 180;
    final maximumSigma = horizontal
        ? widget.maximumSigmaX
        : widget.maximumSigmaY;
    final maximumRadius = (2 * maximumSigma - 1).clamp(0.0, 48.0);
    final start = widget.gradient.startFraction.isFinite
        ? widget.gradient.startFraction.clamp(0.0, 1.0)
        : 0.0;
    final end = widget.gradient.endFraction.isFinite
        ? widget.gradient.endFraction.clamp(0.0, 1.0)
        : 1.0;
    final curve = widget.gradient.curve.isFinite
        ? widget.gradient.curve.clamp(.05, 20.0)
        : 1.0;
    // Float slots 0-1 are reserved by ImageFilter.shader for u_size.
    shader
      ..setFloat(2, horizontal ? 1 : 0)
      ..setFloat(3, horizontal ? 0 : 1)
      ..setFloat(4, maximumRadius)
      ..setFloat(5, math.cos(radians))
      ..setFloat(6, math.sin(radians))
      ..setFloat(7, start)
      ..setFloat(8, end)
      ..setFloat(9, curve)
      // The source loop shader disables jitter; noise is a separate full-
      // resolution post pass and is handled by MiuixLayerBackdrop above.
      ..setFloat(10, 0);
  }

  @override
  void dispose() {
    _horizontalShader?.dispose();
    _verticalShader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final horizontal = _horizontalShader;
    final vertical = _verticalShader;
    if (horizontal == null || vertical == null) return widget.fallback;
    _configureShader(horizontal, horizontal: true);
    _configureShader(vertical, horizontal: false);
    final filter = ImageFilter.compose(
      outer: ImageFilter.shader(vertical),
      inner: ImageFilter.shader(horizontal),
    );
    final stack = Stack(
      fit: StackFit.passthrough,
      children: [
        Positioned.fill(
          child: BackdropFilter(
            key: const ValueKey('miuix-progressive-runtime-filter'),
            filter: filter,
            child: const SizedBox.expand(),
          ),
        ),
        ?widget.postEffectLayer,
        widget.child,
      ],
    );
    if (widget.radius <= 0) return stack;
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius),
      child: stack,
    );
  }
}

// TextureEffect.kt defines the public radius in dp. The source multiplies it
// by density and then by BLUR_RADIUS_TO_SIGMA (0.45). Flutter's blur sigma is
// expressed in logical pixels and is scaled by the engine at raster time, so
// multiplying and dividing by density cancel exactly.
double _miuixSourceBlurSigma(double logicalRadius) {
  final radius = logicalRadius.isFinite ? math.max(0, logicalRadius) : 0.0;
  return radius * .45;
}

/// Returns the source dp-to-logical-pixel blur conversion for regression tests.
@visibleForTesting
double debugMiuixSourceBlurSigma(double logicalRadius) =>
    _miuixSourceBlurSigma(logicalRadius);

String? _miuixHighlightShaderAsset(MiuixHighlight highlight) {
  final style = highlight.resolvedStyle;
  if (style is! MiuixBloomStroke) return null;
  return style.dualPeak
      ? 'shaders/miuix_bloom_stroke_dual.frag'
      : 'shaders/miuix_bloom_stroke.frag';
}

/// Returns the built-in highlight shader selected by [highlight].
@visibleForTesting
String? debugMiuixHighlightShaderAsset(MiuixHighlight highlight) =>
    _miuixHighlightShaderAsset(highlight);

/// Paints MIUIX's runtime-shader BloomStroke above arbitrary [child] content.
///
/// This focused renderer is useful when a component already owns its blur or
/// refraction pipeline and only needs the source two-light specular layer.
/// [MiuixLayerBackdrop] uses the same shader internally for complete backdrop
/// surfaces. Unsupported renderers retain the documented gradient fallback.
class MiuixHighlightOverlay extends StatefulWidget {
  /// Creates a non-interactive source highlight above [child].
  const MiuixHighlightOverlay({
    super.key,
    required this.highlight,
    required this.radius,
    required this.child,
  });

  /// Two-light stroke, blur, intensity, and opacity configuration.
  final MiuixHighlight highlight;

  /// Rounded-rectangle corner radius used by the source SDF.
  final double radius;

  /// Ordinary component content painted below the highlight.
  final Widget child;

  @override
  State<MiuixHighlightOverlay> createState() => _MiuixHighlightOverlayState();
}

class _MiuixHighlightOverlayState extends State<MiuixHighlightOverlay> {
  // Every instance needs its own mutable FragmentShader, but all instances can
  // share the immutable compiled FragmentProgram and asynchronous load.
  static final Map<String, Future<FragmentProgram?>> _programFutures = {};
  static final Map<String, FragmentProgram> _programs = {};
  FragmentShader? _shader;
  String? _shaderAsset;

  @override
  void initState() {
    super.initState();
    _ensureShader();
  }

  @override
  void didUpdateWidget(covariant MiuixHighlightOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    final requiredAsset = _miuixHighlightShaderAsset(widget.highlight);
    if (_shaderAsset != requiredAsset) {
      _shader?.dispose();
      _shader = null;
      _shaderAsset = null;
      _ensureShader();
    }
  }

  Future<void> _ensureShader() async {
    final asset = _miuixHighlightShaderAsset(widget.highlight);
    if (asset == null) return;
    final cached = _programs[asset];
    if (cached != null) {
      _shader = cached.fragmentShader();
      _shaderAsset = asset;
      return;
    }
    final program = await (_programFutures[asset] ??= _loadProgram(asset));
    if (!mounted ||
        program == null ||
        asset != _miuixHighlightShaderAsset(widget.highlight)) {
      return;
    }
    _programs[asset] = program;
    setState(() {
      _shader = program.fragmentShader();
      _shaderAsset = asset;
    });
  }

  static Future<FragmentProgram?> _loadProgram(String asset) async {
    try {
      return await FragmentProgram.fromAsset('packages/flutter_miuix/$asset');
    } catch (_) {
      // Root package tests expose the shader without a package namespace.
      try {
        return await FragmentProgram.fromAsset(asset);
      } catch (_) {
        return null;
      }
    }
  }

  @override
  void dispose() {
    _shader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              key: ValueKey(
                _shader == null
                    ? 'miuix-highlight-overlay-fallback'
                    : 'miuix-highlight-overlay-runtime',
              ),
              painter: _MiuixBackdropHighlightPainter(
                highlight: widget.highlight,
                radius: widget.radius,
                shader: _shader,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget adapter for MIUIX LayerBackdrop.
///
/// This complete surface combines blur, texture-color processing, noise,
/// optional BloomStroke highlighting, clipping, padding, and ordinary content.
class MiuixLayerBackdrop extends StatefulWidget {
  /// Creates a layer backdrop around [child].
  const MiuixLayerBackdrop({
    super.key,
    required this.child,
    this.backdrop = const MiuixBackdrop(),
    this.radius,
    this.padding,
  });

  /// Content drawn above the backdrop.
  final Widget child;

  /// Backdrop effect data.
  final MiuixBackdrop backdrop;

  /// Optional corner radius.
  final double? radius;

  /// Optional inner padding.
  final EdgeInsetsGeometry? padding;

  @override
  State<MiuixLayerBackdrop> createState() => _MiuixLayerBackdropState();
}

class _MiuixLayerBackdropState extends State<MiuixLayerBackdrop> {
  static Future<FragmentProgram?>? _standardProgramFuture;
  static Future<FragmentProgram?>? _logoProgramFuture;
  static Future<FragmentProgram?>? _arithmeticProgramFuture;
  static Future<FragmentProgram?>? _labProgramFuture;
  static Future<FragmentProgram?>? _extendedProgramFuture;
  static final Map<String, Future<FragmentProgram?>> _highlightProgramFutures =
      {};
  static final Map<String, FragmentProgram> _highlightPrograms = {};
  FragmentShader? _blendShader;
  String? _blendShaderAsset;
  FragmentShader? _highlightShader;
  String? _highlightShaderAsset;

  @override
  void initState() {
    super.initState();
    _ensureBlendShader();
    _ensureHighlightShader();
  }

  @override
  void didUpdateWidget(covariant MiuixLayerBackdrop oldWidget) {
    super.didUpdateWidget(oldWidget);
    final requiredAsset = _blendShaderAssetFor(
      widget.backdrop.colors.blendColors,
    );
    if (_blendShader != null && _blendShaderAsset != requiredAsset) {
      _blendShader?.dispose();
      _blendShader = null;
      _blendShaderAsset = null;
    }
    if (_blendShader == null && widget.backdrop.colors.blendColors.isNotEmpty) {
      _ensureBlendShader();
    }
    final requiredHighlightAsset = widget.backdrop.highlight == null
        ? null
        : _miuixHighlightShaderAsset(widget.backdrop.highlight!);
    if (_highlightShaderAsset != requiredHighlightAsset) {
      _highlightShader?.dispose();
      _highlightShader = null;
      _highlightShaderAsset = null;
    }
    if (_highlightShader == null && widget.backdrop.highlight != null) {
      _ensureHighlightShader();
    }
  }

  Future<void> _ensureBlendShader() async {
    if (_blendShader != null ||
        widget.backdrop.colors.blendColors.isEmpty ||
        !_canUseMiuixBlendShader(widget.backdrop.colors.blendColors) ||
        !ImageFilter.isShaderFilterSupported) {
      return;
    }
    final asset = _blendShaderAssetFor(widget.backdrop.colors.blendColors);
    final future = switch (asset) {
      'shaders/miuix_texture_blend_standard.frag' =>
        _standardProgramFuture ??= _loadBlendProgram(asset),
      'shaders/miuix_texture_blend_logo.frag' =>
        _logoProgramFuture ??= _loadBlendProgram(asset),
      'shaders/miuix_texture_blend_arithmetic.frag' =>
        _arithmeticProgramFuture ??= _loadBlendProgram(asset),
      'shaders/miuix_texture_blend_lab.frag' =>
        _labProgramFuture ??= _loadBlendProgram(asset),
      _ => _extendedProgramFuture ??= _loadBlendProgram(asset),
    };
    final program = await future;
    if (!mounted || program == null) return;
    setState(() {
      _blendShader = program.fragmentShader();
      _blendShaderAsset = asset;
    });
  }

  static Future<FragmentProgram?> _loadBlendProgram(String asset) async {
    try {
      return await FragmentProgram.fromAsset('packages/flutter_miuix/$asset');
    } catch (_) {
      // Root package tests use the unprefixed key while consuming apps use the
      // package-qualified asset key.
      try {
        return await FragmentProgram.fromAsset(asset);
      } catch (_) {
        return null;
      }
    }
  }

  Future<void> _ensureHighlightShader() async {
    final highlight = widget.backdrop.highlight;
    if (_highlightShader != null || highlight == null) return;
    final asset = _miuixHighlightShaderAsset(highlight);
    if (asset == null) return;
    final cachedProgram = _highlightPrograms[asset];
    if (cachedProgram != null) {
      _highlightShader = cachedProgram.fragmentShader();
      _highlightShaderAsset = asset;
      return;
    }
    final program = await (_highlightProgramFutures[asset] ??=
        _loadHighlightProgram(asset));
    if (!mounted ||
        program == null ||
        widget.backdrop.highlight == null ||
        asset != _miuixHighlightShaderAsset(widget.backdrop.highlight!)) {
      return;
    }
    _highlightPrograms[asset] = program;
    setState(() {
      _highlightShader = program.fragmentShader();
      _highlightShaderAsset = asset;
    });
  }

  static Future<FragmentProgram?> _loadHighlightProgram(String asset) async {
    try {
      return await FragmentProgram.fromAsset('packages/flutter_miuix/$asset');
    } catch (_) {
      try {
        return await FragmentProgram.fromAsset(asset);
      } catch (_) {
        return null;
      }
    }
  }

  @override
  void dispose() {
    _blendShader?.dispose();
    _highlightShader?.dispose();
    super.dispose();
  }

  ImageFilter? _textureFilter(double logicalSigmaX, double logicalSigmaY) {
    final shader = _blendShader;
    final entries = widget.backdrop.colors.blendColors;
    if (shader == null ||
        entries.isEmpty ||
        !_canUseMiuixBlendShader(entries)) {
      return null;
    }

    // The engine owns float slots 0-1 for the input texture size. Remaining
    // slots follow the fragment shader declarations exactly.
    shader.setFloat(2, entries.length.clamp(0, 8).toDouble());
    for (var index = 0; index < 8; index++) {
      final offset = 3 + index * 4;
      if (index < entries.length) {
        final entry = entries[index];
        final alpha = entry.color.a;
        // The upstream shader receives premultiplied layer colors and
        // unpremultiplies custom modes before dispatch.
        shader
          ..setFloat(offset, entry.color.r * alpha)
          ..setFloat(offset + 1, entry.color.g * alpha)
          ..setFloat(offset + 2, entry.color.b * alpha)
          ..setFloat(offset + 3, alpha);
      } else {
        shader
          ..setFloat(offset, 0)
          ..setFloat(offset + 1, 0)
          ..setFloat(offset + 2, 0)
          ..setFloat(offset + 3, 0);
      }
    }
    for (var index = 0; index < 8; index++) {
      shader.setFloat(
        35 + index,
        index < entries.length ? _sourceBlendMode(entries[index].mode) : 3,
      );
    }
    // The last three uniforms deliberately live inside the accelerated
    // texture filter instead of wrapping its output in ColorFiltered.
    // MIUIX adjusts the sampled backdrop before applying its ordered blend
    // colors; reversing that order changes contrast-sensitive blend modes.
    // Keep these indices synchronized with miuix_texture_blend.frag whenever
    // either the blend entry capacity or shader uniform declarations change.
    // Brightness is an additive signed value, while contrast and saturation
    // are non-negative multipliers whose neutral value is exactly one.
    shader
      ..setFloat(43, widget.backdrop.brightness.clamp(-1.0, 1.0))
      ..setFloat(44, widget.backdrop.contrast.clamp(0.0, 3.0))
      ..setFloat(45, widget.backdrop.saturation.clamp(0.0, 3.0));
    try {
      return ImageFilter.compose(
        outer: ImageFilter.shader(shader),
        inner: ImageFilter.blur(sigmaX: logicalSigmaX, sigmaY: logicalSigmaY),
      );
    } on UnsupportedError {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final backdrop = widget.backdrop;
    final tint = backdrop.colors.tint ?? scheme.surface;
    final logicalSigmaX = _miuixSourceBlurSigma(backdrop.blur);
    final logicalSigmaY = _miuixSourceBlurSigma(
      backdrop.blurY ?? backdrop.blur,
    );
    final acceleratedFilter = _textureFilter(logicalSigmaX, logicalSigmaY);
    final baseFilter =
        acceleratedFilter ??
        (logicalSigmaX != logicalSigmaY
            ? ImageFilter.blur(sigmaX: logicalSigmaX, sigmaY: logicalSigmaY)
            : null);
    final fallbackBlendEntries = acceleratedFilter == null
        ? backdrop.colors.blendColors
        : const <MiuixBlurBlendEntry>[];
    final hasColorControls =
        backdrop.brightness != 0 ||
        backdrop.contrast != 1 ||
        backdrop.saturation != 1;
    final content = Stack(
      fit: StackFit.passthrough,
      children: [
        // DrawBackdropModifier applies full-resolution noise after its effect
        // chain, then draws ordinary component content above that backdrop.
        // Keeping noise first prevents it from dirtying labels and icons.
        if (backdrop.noise > 0)
          Positioned.fill(
            key: const ValueKey('miuix-blur-noise-layer'),
            child: IgnorePointer(
              child: CustomPaint(painter: _MiuixNoisePainter(backdrop.noise)),
            ),
          ),
        widget.child,
        if (backdrop.highlight case final highlight?)
          Positioned.fill(
            child: IgnorePointer(
              child: KeyedSubtree(
                key: const ValueKey('miuix-backdrop-highlight'),
                child: CustomPaint(
                  key: ValueKey(
                    _highlightShader == null
                        ? 'miuix-backdrop-highlight-fallback'
                        : 'miuix-backdrop-highlight-runtime',
                  ),
                  painter: _MiuixBackdropHighlightPainter(
                    highlight: highlight,
                    radius: widget.radius ?? 18,
                    shader: _highlightShader,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
    final border = backdrop.colors.border == null
        ? BorderSide(
            color: scheme.outlineVariant.withValues(alpha: .14),
            width: .5,
          )
        : BorderSide(color: backdrop.colors.border!, width: .5);
    final innerDecoration = BoxDecoration(
      // Preserve an explicitly transparent texture-blur tint. Replacing its
      // alpha with .06 introduced a black wash absent from MIUIX.
      // BackdropFilter needs a painted child for its sampled pixels to
      // participate in an outer DstIn ShaderMask. A one-alpha sentinel is
      // visually transparent but keeps foreground-blur glyphs alive on Skia;
      // an actual tint retains its requested alpha semantics.
      color: tint.a == 0
          ? const Color(0x01000000)
          : tint.withValues(alpha: tint.a * 0.06),
      borderRadius: BorderRadius.circular(widget.radius ?? 18),
    );
    Widget glass = MiuixGlass(
      blur: logicalSigmaX,
      opacity: backdrop.colors.opacity,
      radius: widget.radius,
      padding: widget.padding,
      imageFilter: baseFilter,
      enabled: backdrop.enabled,
      useGlobalIntensity: false,
      showSpecular: false,
      border: border,
      child: DecoratedBox(decoration: innerDecoration, child: content),
    );
    if (fallbackBlendEntries.isNotEmpty || backdrop.effects.isNotEmpty) {
      final theme = MiuixTheme.of(context);
      final effectiveRadius = widget.radius ?? theme.radius.lg;
      final ShapeBorder shape = theme.enableSquircle
          ? MiuixSquircleBorder(
              borderRadius: BorderRadius.circular(effectiveRadius),
            )
          : RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(effectiveRadius),
            );
      Widget filteredBackground = MiuixGlass(
        blur: logicalSigmaX,
        opacity: backdrop.colors.opacity,
        radius: widget.radius,
        padding: EdgeInsets.zero,
        imageFilter: baseFilter,
        enabled: backdrop.enabled,
        useGlobalIntensity: false,
        showSpecular: false,
        border: border,
        child: DecoratedBox(
          decoration: innerDecoration,
          child: const SizedBox.expand(),
        ),
      );
      if (hasColorControls && acceleratedFilter == null) {
        filteredBackground = ColorFiltered(
          key: const ValueKey('miuix-blur-color-controls'),
          colorFilter: ColorFilter.matrix(_miuixBackdropColorMatrix(backdrop)),
          child: filteredBackground,
        );
      }
      // A child CustomPaint cannot blend against BackdropFilter's sampled
      // pixels on Skia because they live in a preceding engine layer. Apply
      // native color filters to a background-only blur layer instead, then
      // paint the component content above it so glyphs remain unaffected.
      for (final entry in fallbackBlendEntries) {
        filteredBackground = ColorFiltered(
          colorFilter: ColorFilter.mode(
            entry.color,
            _fallbackBlendMode(entry.mode),
          ),
          child: filteredBackground,
        );
      }
      // Custom effects consume the completed source texture recipe but never
      // the component's labels or icons. Flutter's ImageFiltered is used here
      // rather than nesting another BackdropFilter: it preserves call order
      // for the shader-unavailable color/blend fallback and avoids sampling
      // the window twice.
      for (var index = 0; index < backdrop.effects.length; index++) {
        filteredBackground = ImageFiltered(
          key: ValueKey('miuix-backdrop-custom-effect-$index'),
          imageFilter: backdrop.effects[index],
          child: filteredBackground,
        );
      }
      glass = ClipPath(
        clipper: ShapeBorderClipper(shape: shape),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            Positioned.fill(
              child: KeyedSubtree(
                key: const ValueKey('miuix-blur-blend-layers'),
                child: filteredBackground,
              ),
            ),
            Padding(
              padding: widget.padding ?? EdgeInsets.all(theme.spacing.lg),
              child: content,
            ),
          ],
        ),
      );
    }
    if (!hasColorControls ||
        acceleratedFilter != null ||
        fallbackBlendEntries.isNotEmpty ||
        backdrop.effects.isNotEmpty) {
      return glass;
    }
    return ColorFiltered(
      key: const ValueKey('miuix-blur-color-controls'),
      colorFilter: ColorFilter.matrix(_miuixBackdropColorMatrix(backdrop)),
      child: glass,
    );
  }
}

ImageFilter _composeMiuixBackdropEffects(
  ImageFilter base,
  List<ImageFilter> effects,
) {
  var result = base;
  for (final effect in effects) {
    result = ImageFilter.compose(outer: effect, inner: result);
  }
  return result;
}

/// Builds the portable part of a backdrop's ordered image-effect chain.
///
/// Shader-backed blend colors are loaded by [MiuixLayerBackdrop] at runtime;
/// this helper exposes the blur and caller-supplied portion for direct tests.
@visibleForTesting
ImageFilter debugMiuixBackdropImageFilter(MiuixBackdrop backdrop) {
  final sigmaX = _miuixSourceBlurSigma(backdrop.blur);
  final sigmaY = _miuixSourceBlurSigma(backdrop.blurY ?? backdrop.blur);
  return _composeMiuixBackdropEffects(
    ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
    backdrop.effects,
  );
}

double _sourceBlendMode(MiuixBlurBlendMode mode) {
  return switch (mode) {
    MiuixBlurBlendMode.clear => 0,
    MiuixBlurBlendMode.src => 1,
    MiuixBlurBlendMode.dst => 2,
    MiuixBlurBlendMode.srcOver => 3,
    MiuixBlurBlendMode.dstOver => 4,
    MiuixBlurBlendMode.srcIn => 5,
    MiuixBlurBlendMode.dstIn => 6,
    MiuixBlurBlendMode.srcOut => 7,
    MiuixBlurBlendMode.dstOut => 8,
    MiuixBlurBlendMode.srcAtop => 9,
    MiuixBlurBlendMode.dstAtop => 10,
    MiuixBlurBlendMode.xor => 11,
    MiuixBlurBlendMode.plus => 12,
    MiuixBlurBlendMode.modulate => 13,
    MiuixBlurBlendMode.screen => 14,
    MiuixBlurBlendMode.overlay => 15,
    MiuixBlurBlendMode.darken => 16,
    MiuixBlurBlendMode.lighten => 17,
    MiuixBlurBlendMode.colorDodge => 18,
    MiuixBlurBlendMode.colorBurn => 19,
    MiuixBlurBlendMode.hardLight => 20,
    MiuixBlurBlendMode.softLight => 21,
    MiuixBlurBlendMode.difference => 22,
    MiuixBlurBlendMode.exclusion => 23,
    MiuixBlurBlendMode.multiply => 24,
    MiuixBlurBlendMode.hue => 25,
    MiuixBlurBlendMode.saturation => 26,
    MiuixBlurBlendMode.color => 27,
    MiuixBlurBlendMode.linearLight => 100,
    MiuixBlurBlendMode.linearLightWithGreyscale => 101,
    MiuixBlurBlendMode.miDifference => 102,
    MiuixBlurBlendMode.labLightenWithGreyscale => 103,
    MiuixBlurBlendMode.labDarkenWithGreyscale => 105,
    MiuixBlurBlendMode.lab => 106,
    MiuixBlurBlendMode.linearLightLab => 107,
    MiuixBlurBlendMode.miColorDodge => 118,
    MiuixBlurBlendMode.miColorBurn => 119,
    MiuixBlurBlendMode.plusDarker => 120,
    MiuixBlurBlendMode.plusLighter => 121,
    MiuixBlurBlendMode.luminosity => 28,
    MiuixBlurBlendMode.alphaBlend => 200,
    MiuixBlurBlendMode.miSaturation => 201,
    MiuixBlurBlendMode.miBrightness => 202,
    MiuixBlurBlendMode.miLuminance => 203,
  };
}

/// Returns the authoritative Skia/custom numeric code for [mode].
@visibleForTesting
int debugMiuixBlurBlendModeValue(MiuixBlurBlendMode mode) =>
    _sourceBlendMode(mode).toInt();

bool _canUseMiuixBlendShader(List<MiuixBlurBlendEntry> entries) {
  const directlyImplementedStandardModes = {
    MiuixBlurBlendMode.srcOver,
    MiuixBlurBlendMode.screen,
    MiuixBlurBlendMode.overlay,
    MiuixBlurBlendMode.colorDodge,
    MiuixBlurBlendMode.colorBurn,
    MiuixBlurBlendMode.hardLight,
    MiuixBlurBlendMode.softLight,
    MiuixBlurBlendMode.multiply,
    MiuixBlurBlendMode.luminosity,
  };
  final modesAreImplemented = entries.every((entry) {
    final raw = _sourceBlendMode(entry.mode);
    return raw >= 100 || directlyImplementedStandardModes.contains(entry.mode);
  });
  if (!modesAreImplemented) return false;
  final containsControlMode = entries.any(
    (entry) => _sourceBlendMode(entry.mode) >= 200,
  );
  return !containsControlMode ||
      _blendShaderAssetFor(entries) ==
          'shaders/miuix_texture_blend_arithmetic.frag';
}

/// Whether the runtime shader has an exact dispatch for every requested mode.
@visibleForTesting
bool debugCanUseMiuixBlendShader(List<MiuixBlurBlendEntry> entries) =>
    _canUseMiuixBlendShader(entries);

bool _requiresExtendedBlendShader(List<MiuixBlurBlendEntry> entries) {
  return entries.any((entry) => _sourceBlendMode(entry.mode) > 28);
}

String _blendShaderAssetFor(List<MiuixBlurBlendEntry> entries) {
  if (!_requiresExtendedBlendShader(entries)) {
    return 'shaders/miuix_texture_blend_standard.frag';
  }
  final modes = entries.map((entry) => _sourceBlendMode(entry.mode).toInt());
  // ForegroundBlurDemo's light Logo token starts with ColorBurn (19), while
  // its dark token starts with ColorDodge (18). Both share the following
  // LinearLight (100) and Lab (106) layers and therefore use the same lean
  // specialization instead of the register-heavy catch-all shader.
  if (modes.every(const {18, 19, 100, 106}.contains)) {
    return 'shaders/miuix_texture_blend_logo.frag';
  }
  // Every non-Lab custom mode used by the source sample can be compiled in a
  // much smaller arithmetic program. The included standard modes are exactly
  // those paired with PlusLighter/PlusDarker by ColorBlendToken.
  if (modes.every(
    const {
      3,
      15,
      18,
      19,
      28,
      100,
      101,
      102,
      118,
      119,
      120,
      121,
      200,
      201,
      202,
      203,
    }.contains,
  )) {
    return 'shaders/miuix_texture_blend_arithmetic.frag';
  }
  if (modes.every(const {103, 105, 106, 107}.contains)) {
    return 'shaders/miuix_texture_blend_lab.frag';
  }
  return 'shaders/miuix_texture_blend.frag';
}

/// Returns the source-style shader specialization selected for an entry list.
@visibleForTesting
String debugMiuixBlendShaderAsset(List<MiuixBlurBlendEntry> entries) =>
    _blendShaderAssetFor(entries);

BlendMode _fallbackBlendMode(MiuixBlurBlendMode mode) {
  return switch (mode) {
    MiuixBlurBlendMode.clear => BlendMode.clear,
    MiuixBlurBlendMode.src => BlendMode.src,
    MiuixBlurBlendMode.dst => BlendMode.dst,
    MiuixBlurBlendMode.srcOver => BlendMode.srcOver,
    MiuixBlurBlendMode.dstOver => BlendMode.dstOver,
    MiuixBlurBlendMode.srcIn => BlendMode.srcIn,
    MiuixBlurBlendMode.dstIn => BlendMode.dstIn,
    MiuixBlurBlendMode.srcOut => BlendMode.srcOut,
    MiuixBlurBlendMode.dstOut => BlendMode.dstOut,
    MiuixBlurBlendMode.srcAtop => BlendMode.srcATop,
    MiuixBlurBlendMode.dstAtop => BlendMode.dstATop,
    MiuixBlurBlendMode.xor => BlendMode.xor,
    MiuixBlurBlendMode.plus => BlendMode.plus,
    MiuixBlurBlendMode.modulate => BlendMode.modulate,
    MiuixBlurBlendMode.screen => BlendMode.screen,
    MiuixBlurBlendMode.overlay => BlendMode.overlay,
    MiuixBlurBlendMode.darken => BlendMode.darken,
    MiuixBlurBlendMode.lighten => BlendMode.lighten,
    MiuixBlurBlendMode.colorDodge => BlendMode.colorDodge,
    MiuixBlurBlendMode.colorBurn => BlendMode.colorBurn,
    MiuixBlurBlendMode.hardLight => BlendMode.hardLight,
    MiuixBlurBlendMode.softLight => BlendMode.softLight,
    MiuixBlurBlendMode.difference => BlendMode.difference,
    MiuixBlurBlendMode.exclusion => BlendMode.exclusion,
    MiuixBlurBlendMode.multiply => BlendMode.multiply,
    MiuixBlurBlendMode.hue => BlendMode.hue,
    MiuixBlurBlendMode.saturation => BlendMode.saturation,
    MiuixBlurBlendMode.color => BlendMode.color,
    MiuixBlurBlendMode.linearLight => BlendMode.hardLight,
    MiuixBlurBlendMode.linearLightWithGreyscale => BlendMode.softLight,
    MiuixBlurBlendMode.linearLightLab => BlendMode.hardLight,
    MiuixBlurBlendMode.lab => BlendMode.color,
    MiuixBlurBlendMode.labLightenWithGreyscale => BlendMode.lighten,
    MiuixBlurBlendMode.labDarkenWithGreyscale => BlendMode.darken,
    MiuixBlurBlendMode.miDifference => BlendMode.difference,
    MiuixBlurBlendMode.miColorDodge => BlendMode.colorDodge,
    MiuixBlurBlendMode.miColorBurn => BlendMode.colorBurn,
    MiuixBlurBlendMode.plusLighter => BlendMode.plus,
    MiuixBlurBlendMode.plusDarker => BlendMode.darken,
    MiuixBlurBlendMode.luminosity => BlendMode.luminosity,
    MiuixBlurBlendMode.alphaBlend => BlendMode.srcOver,
    MiuixBlurBlendMode.miSaturation => BlendMode.saturation,
    MiuixBlurBlendMode.miBrightness => BlendMode.srcOver,
    MiuixBlurBlendMode.miLuminance => BlendMode.luminosity,
  };
}

// Produces the closest matrix fallback for engines without shader filters.
// The accelerated path above is source-exact: brightness runs in gamma-2.2
// linear space, then contrast and Rec.709 saturation run in sRGB. A 4x5 color
// matrix cannot express that nonlinear brightness conversion, but keeping the
// same control order and current luma coefficients avoids the older hue shift.
List<double> _miuixBackdropColorMatrix(MiuixBackdrop backdrop) {
  final saturation = backdrop.saturation.clamp(0.0, 3.0);
  final contrast = backdrop.contrast.clamp(0.0, 3.0);
  final brightness = backdrop.brightness.clamp(-1.0, 1.0);
  const red = .2126;
  const green = .7152;
  const blue = .0722;
  final inverse = 1 - saturation;
  final offset = 255 * (.5 - contrast * .5 + brightness);
  return [
    (red * inverse + saturation) * contrast,
    green * inverse * contrast,
    blue * inverse * contrast,
    0,
    offset,
    red * inverse * contrast,
    (green * inverse + saturation) * contrast,
    blue * inverse * contrast,
    0,
    offset,
    red * inverse * contrast,
    green * inverse * contrast,
    (blue * inverse + saturation) * contrast,
    0,
    offset,
    0,
    0,
    0,
    1,
    0,
  ];
}

/// Returns the documented non-shader fallback matrix for regression tests.
@visibleForTesting
List<double> debugMiuixBackdropColorMatrix(MiuixBackdrop backdrop) =>
    _miuixBackdropColorMatrix(backdrop);

class _MiuixNoisePainter extends CustomPainter {
  const _MiuixNoisePainter(this.strength);

  final double strength;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }
    final random = math.Random(0x4D495549);
    final count = math.max(24, (size.width * size.height / 180).round());
    final paint = Paint()..strokeWidth = 1;
    for (var index = 0; index < count; index++) {
      final light = random.nextBool();
      paint.color = (light ? Colors.white : Colors.black).withValues(
        alpha: strength.clamp(0.0, .1) * (.35 + random.nextDouble() * .65),
      );
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        .5,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MiuixNoisePainter oldDelegate) {
    return strength != oldDelegate.strength;
  }
}

/// Exact Flutter runtime-shader adapter for MIUIX's single-peak BloomStroke.
///
/// The shader owns the rounded-rectangle SDF, hemispheric rim normal, flat
/// 0.8dp stroke, two directional lights, and additive composition used by the
/// current source. A narrow gradient-stroke fallback remains available while
/// a platform asynchronously compiles the fragment program.
class _MiuixBackdropHighlightPainter extends CustomPainter {
  const _MiuixBackdropHighlightPainter({
    required this.highlight,
    required this.radius,
    required this.shader,
  });

  final MiuixHighlight highlight;
  final double radius;
  final FragmentShader? shader;

  static (double, double, double) _direction(MiuixLightPosition position) {
    final x = position.dx - .5;
    final y = position.dy - .7;
    final z = position.z;
    final length = math.max(math.sqrt(x * x + y * y + z * z), .000001);
    return (x / length, y / length, z / length);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || highlight.width <= 0 || highlight.alpha <= 0) return;
    final style = highlight.resolvedStyle;
    final bloom = style is MiuixBloomStroke ? style : null;
    final effect = shader;
    if (effect == null || bloom == null) {
      _paintFallback(canvas, size);
      return;
    }

    final corner = radius.clamp(0.0, size.shortestSide / 2);
    final strokeWidth = highlight.width.clamp(0.0, size.shortestSide / 2);
    final innerBlur = math.max(0.0, bloom.innerBlurRadius);
    final primary = _direction(bloom.primaryLight.position);
    final secondary = _direction(bloom.secondaryLight.position);
    final primaryAxisLength = math.sqrt(
      primary.$1 * primary.$1 + primary.$2 * primary.$2,
    );
    final secondaryAxisLength = math.sqrt(
      secondary.$1 * secondary.$1 + secondary.$2 * secondary.$2,
    );
    final primaryAlpha = bloom.primaryLight.color.a;
    final secondaryAlpha = bloom.secondaryLight.color.a;

    effect
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, corner)
      ..setFloat(3, corner)
      ..setFloat(4, corner)
      ..setFloat(5, corner)
      ..setFloat(6, strokeWidth)
      ..setFloat(7, innerBlur)
      ..setFloat(8, innerBlur * innerBlur)
      ..setFloat(9, highlight.alpha.clamp(0.0, 1.0))
      ..setFloat(10, bloom.color.r)
      ..setFloat(11, bloom.color.g)
      ..setFloat(12, bloom.color.b)
      ..setFloat(13, 1)
      ..setFloat(14, bloom.color.a)
      ..setFloat(15, primary.$1)
      ..setFloat(16, primary.$2)
      ..setFloat(17, primary.$3)
      ..setFloat(18, bloom.primaryLight.color.r)
      ..setFloat(19, bloom.primaryLight.color.g)
      ..setFloat(20, bloom.primaryLight.color.b)
      ..setFloat(21, 1)
      ..setFloat(22, primaryAlpha * math.max(0, bloom.primaryLight.intensity))
      ..setFloat(23, secondary.$1)
      ..setFloat(24, secondary.$2)
      ..setFloat(25, secondary.$3)
      ..setFloat(26, bloom.secondaryLight.color.r)
      ..setFloat(27, bloom.secondaryLight.color.g)
      ..setFloat(28, bloom.secondaryLight.color.b)
      ..setFloat(29, 1)
      ..setFloat(
        30,
        secondaryAlpha * math.max(0, bloom.secondaryLight.intensity),
      )
      ..setFloat(
        31,
        primaryAxisLength > .001 ? primary.$1 / primaryAxisLength : 0,
      )
      ..setFloat(
        32,
        primaryAxisLength > .001 ? primary.$2 / primaryAxisLength : -1,
      )
      ..setFloat(
        33,
        secondaryAxisLength > .001 ? secondary.$1 / secondaryAxisLength : 0,
      )
      ..setFloat(
        34,
        secondaryAxisLength > .001 ? secondary.$2 / secondaryAxisLength : 1,
      );
    canvas.saveLayer(Offset.zero & size, Paint()..blendMode = bloom.blendMode);
    canvas.drawRect(Offset.zero & size, Paint()..shader = effect);
    canvas.restore();
  }

  void _paintFallback(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(highlight.width / 2);
    if (rect.isEmpty) return;
    final style = highlight.resolvedStyle;
    final bloom = style is MiuixBloomStroke ? style : null;
    final position = bloom?.primaryLight.position ?? const MiuixLightPosition();
    final start = Alignment(
      (position.dx * 2 - 1).clamp(-1.0, 1.0),
      (position.dy * 2 - 1).clamp(-1.0, 1.0),
    );
    final alpha = (style.color.a * highlight.alpha).clamp(0.0, 1.0);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = highlight.width
      ..blendMode = style.blendMode
      ..shader = LinearGradient(
        begin: start,
        end: Alignment(-start.x, -start.y),
        colors: [
          style.color.withValues(alpha: alpha),
          style.color.withValues(alpha: alpha * .2),
          Colors.transparent,
        ],
      ).createShader(rect)
      ..maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        bloom?.innerBlurRadius ?? 0,
      );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _MiuixBackdropHighlightPainter oldDelegate) {
    return oldDelegate.highlight != highlight ||
        oldDelegate.radius != radius ||
        oldDelegate.shader != shader;
  }
}

/// A G2-style continuous-corner border matching MIUIX `SquirclePath`.
///
/// MIUIX starts each corner farther along the straight edge than a circular
/// rounded rectangle, then uses a cubic Bézier with a 0.643 control ratio.
/// Corner tiles are clamped to half the shorter laid-out dimension.
class MiuixSquircleBorder extends ShapeBorder {
  /// Creates a MIUIX smooth-corner border.
  const MiuixSquircleBorder({
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.side = BorderSide.none,
  });

  /// Radius used by the approximated continuous corner.
  final BorderRadius borderRadius;

  /// Optional outline side.
  final BorderSide side;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    final inset = side.width;
    final innerRect = rect.deflate(inset);
    if (innerRect.isEmpty) {
      return Path();
    }
    final resolved = borderRadius.resolve(textDirection);
    return _MiuixSquirclePath.build(
      innerRect,
      _subtractRadius(resolved, inset),
    );
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return _MiuixSquirclePath.build(rect, borderRadius.resolve(textDirection));
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side == BorderSide.none || side.width == 0) {
      return;
    }
    final centerRect = rect.deflate(side.width / 2);
    if (centerRect.isEmpty) {
      return;
    }
    final resolved = borderRadius.resolve(textDirection);
    final path = _MiuixSquirclePath.build(
      centerRect,
      _subtractRadius(resolved, side.width / 2),
    );
    canvas.drawPath(path, side.toPaint());
  }

  @override
  ShapeBorder scale(double t) {
    return MiuixSquircleBorder(
      borderRadius: borderRadius * t,
      side: side.scale(t),
    );
  }

  static BorderRadius _subtractRadius(BorderRadius value, double amount) {
    Radius subtract(Radius radius) => Radius.elliptical(
      math.max(0, radius.x - amount),
      math.max(0, radius.y - amount),
    );
    return BorderRadius.only(
      topLeft: subtract(value.topLeft),
      topRight: subtract(value.topRight),
      bottomRight: subtract(value.bottomRight),
      bottomLeft: subtract(value.bottomLeft),
    );
  }
}

/// A size-aware G2 capsule matching MIUIX `SmoothCapsuleShape`.
///
/// Unlike a squircle with one fixed radius, a capsule recalculates its radius
/// as half of the shorter laid-out dimension. This matters for arbitrary
/// content slots: a 60dp floating button and a 120-by-64 extended button must
/// both keep fully rounded ends without the caller predicting their final size.
class MiuixCapsuleBorder extends ShapeBorder {
  /// Creates a smooth capsule outline.
  const MiuixCapsuleBorder({this.side = BorderSide.none});

  /// Optional painted outline.
  final BorderSide side;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  /// Builds the same equal-radius path used by the source capsule.
  Path _path(Rect rect) {
    if (rect.isEmpty) return Path();
    final radius = math.min(rect.width, rect.height) / 2;
    return _MiuixSquirclePath.build(
      rect,
      BorderRadius.all(Radius.circular(radius)),
    );
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return _path(rect.deflate(side.width));
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return _path(rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side == BorderSide.none || side.width == 0) return;
    final centerRect = rect.deflate(side.width / 2);
    if (centerRect.isEmpty) return;
    canvas.drawPath(_path(centerRect), side.toPaint());
  }

  @override
  ShapeBorder scale(double t) {
    return MiuixCapsuleBorder(side: side.scale(t));
  }
}

/// Direct Flutter port of current MIUIX `SquirclePath.addSquircleRect`.
///
/// The upstream squircle module now uses a 1.1-radius corner tile and a fixed
/// 0.643 cubic control ratio. Each tile is clamped to half the shorter side;
/// unlike the retired SmoothCornerPath implementation there is no
/// radius-dependent interpolation back toward a circular control point.
class _MiuixSquirclePath {
  const _MiuixSquirclePath._();

  static const double _controlPoint = .643;

  static Path build(Rect rect, BorderRadius radius) {
    final path = Path();
    if (rect.isEmpty) {
      return path;
    }
    final width = rect.width;
    final height = rect.height;
    final maximumTile = math.min(width, height) / 2;
    double tile(Radius corner) => math
        .max(
          0.0,
          math.min(corner.x, corner.y) * MiuixSquircleDefaults.extension,
        )
        .clamp(0.0, maximumTile)
        .toDouble();
    final topLeft = tile(radius.topLeft);
    final topRight = tile(radius.topRight);
    final bottomRight = tile(radius.bottomRight);
    final bottomLeft = tile(radius.bottomLeft);
    if (topLeft == 0 && topRight == 0 && bottomRight == 0 && bottomLeft == 0) {
      return path..addRect(rect);
    }
    final left = rect.left;
    final top = rect.top;
    final right = rect.right;
    final bottom = rect.bottom;
    path.moveTo(left + topLeft, top);
    path.lineTo(right - topRight, top);
    _corner(path, right - topRight, top, right, top, right, top + topRight);
    path.lineTo(right, bottom - bottomRight);
    _corner(
      path,
      right,
      bottom - bottomRight,
      right,
      bottom,
      right - bottomRight,
      bottom,
    );
    path.lineTo(left + bottomLeft, bottom);
    _corner(
      path,
      left + bottomLeft,
      bottom,
      left,
      bottom,
      left,
      bottom - bottomLeft,
    );
    path.lineTo(left, top + topLeft);
    _corner(path, left, top + topLeft, left, top, left + topLeft, top);
    return path..close();
  }

  static void _corner(
    Path path,
    double startX,
    double startY,
    double cornerX,
    double cornerY,
    double endX,
    double endY,
  ) {
    path.cubicTo(
      startX + (cornerX - startX) * _controlPoint,
      startY + (cornerY - startY) * _controlPoint,
      endX + (cornerX - endX) * _controlPoint,
      endY + (cornerY - endY) * _controlPoint,
      endX,
      endY,
    );
  }
}

/// Clips its child with the same continuous-corner path as MIUIX Shapes.
///
/// Use this when an image, glass layer, or custom painted child needs the same
/// corner language as cards and popups.
class MiuixSquircleClip extends StatelessWidget {
  /// Creates a squircle clipper widget.
  const MiuixSquircleClip({super.key, required this.child, this.radius});

  /// Content to clip.
  final Widget child;

  /// Optional corner radius. The theme medium radius is used when omitted.
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final theme = MiuixTheme.of(context);
    final themeRadius = theme.radius.md.isFinite
        ? math.max(0.0, theme.radius.md)
        : 0.0;
    final requestedRadius = radius ?? themeRadius;
    final resolvedRadius = requestedRadius.isFinite
        ? math.max(0.0, requestedRadius)
        : themeRadius;
    return ClipPath(
      clipper: ShapeBorderClipper(
        shape: MiuixSquircleBorder(
          borderRadius: BorderRadius.circular(resolvedRadius),
        ),
      ),
      child: child,
    );
  }
}

/// Optical recipe layered over a glass backdrop.
///
/// [navigation] is a project-calibrated interpretation of the clearer glass
/// direction shown in Apple's iOS 27 material: high strengths reduce tint
/// much more than they increase Gaussian blur, retain backdrop chroma, and
/// describe the surface with opposing bright and dark edges. The values are
/// inferred visual parameters rather than Apple-published measurements.
@immutable
class MiuixGlassOptics {
  /// Creates an optical glass recipe.
  const MiuixGlassOptics({
    required this.blurScales,
    required this.opacityScales,
    required this.edgeHighlightAlpha,
    required this.edgeShadowAlpha,
    this.edgeWidth = 1,
  });

  /// Navigation-specific clear-glass profile for app bars and bottom tabs.
  static const navigation = MiuixGlassOptics(
    blurScales: [.72, .86, 1, 1.12, 1.24],
    opacityScales: [1.30, 1.14, 1, .55, .16],
    edgeHighlightAlpha: .28,
    edgeShadowAlpha: .13,
  );

  /// Clear but readable optical profile for temporary application layers.
  ///
  /// Menus, dialogs, sheets, tooltips, and snackbars share this role so a
  /// fifth-level setting does not produce unrelated amounts of haze in each
  /// component. Values are calibrated from HyperOS application imagery and
  /// runtime captures; Xiaomi does not publish these material multipliers.
  ///
  /// The profile belongs on the one widget that owns the transient surface.
  /// Callers must clip that owner to the popup shape before applying blur;
  /// the modal barrier remains a dimming layer rather than frosted material.
  /// Route pages and secondary screens are deliberately outside this role.
  ///
  /// Level one keeps the strongest tint so text remains readable when blur is
  /// weak. Higher levels progressively expose more of the content behind the
  /// popup while increasing blur, which avoids a milky opaque final level.
  /// Edge light and shade are intentionally gentler than navigation glass:
  /// temporary surfaces should separate from content without looking raised
  /// like a persistent floating control.
  ///
  /// A composed popup must not wrap this profile in another [MiuixGlass].
  /// Doing so doubles backdrop sampling and creates an opaque nested outline.
  static const transient = MiuixGlassOptics(
    blurScales: [.75, .90, 1, 1.10, 1.20],
    opacityScales: [1.15, .95, .82, .52, .18],
    edgeHighlightAlpha: .22,
    edgeShadowAlpha: .10,
    edgeWidth: .75,
  );

  /// Five ordered blur multipliers, from subtle through intense.
  final List<double> blurScales;

  /// Five ordered tint multipliers, from subtle through intense.
  final List<double> opacityScales;

  /// Alpha of the bright top/leading optical edge.
  final double edgeHighlightAlpha;

  /// Alpha of the dark bottom/trailing optical edge.
  final double edgeShadowAlpha;

  /// Width of the optical boundary inside the glass silhouette.
  final double edgeWidth;

  /// Resolves a component blur without letting level five erase structure.
  double resolveBlur(double source, MiuixGlassIntensity intensity) =>
      math.max(0, source * blurScales[intensity.index]);

  /// Resolves tint so stronger glass progresses toward clearer material.
  double resolveOpacity(double source, MiuixGlassIntensity intensity) =>
      (source * opacityScales[intensity.index]).clamp(0.0, 1.0);
}

/// Glass blur panel used by popups, floating navigation, and control tiles.
///
/// It uses Flutter's [BackdropFilter] and therefore works on every Flutter
/// platform, though complex blur stacks should still be profiled on low-end
/// Android devices and Web.
class MiuixGlass extends StatefulWidget {
  /// Creates a glass panel.
  const MiuixGlass({
    super.key,
    required this.child,
    this.blur = 20,
    this.opacity = 0.72,
    this.color,
    this.radius,
    this.borderRadius,
    this.shape,
    this.padding,
    this.border,
    this.enabled = true,
    this.useGlobalIntensity = true,
    this.showSpecular = true,
    this.interactiveLight = true,
    this.interactiveLightColor,
    this.imageFilter,
    this.optics,
    this.blendMode = BlendMode.srcOver,
  });

  /// Content rendered above the glass surface.
  final Widget child;

  /// Sigma value used for the blur filter.
  final double blur;

  /// Surface opacity applied over the blurred backdrop.
  final double opacity;

  /// Optional tint color; defaults to the current surface semantic color.
  final Color? color;

  /// Optional corner radius.
  final double? radius;

  /// Optional non-uniform radius, such as a top-only bottom-sheet shape.
  final BorderRadius? borderRadius;

  /// Optional exact clipping shape.
  ///
  /// This takes precedence over [radius] and [borderRadius]. It lets circular,
  /// stadium, and caller-defined floating surfaces sample the backdrop using
  /// the same silhouette used by their shadow and pointer indication.
  final ShapeBorder? shape;

  /// Optional inner padding.
  final EdgeInsetsGeometry? padding;

  /// Optional border painted over the glass.
  final BorderSide? border;

  /// Whether the blur is active.
  final bool enabled;

  /// Whether the theme's five-level strength scales [blur] and [opacity].
  ///
  /// Component glass uses the global setting. Explicit texture-blur previews
  /// disable it so their numeric controls continue to represent source values.
  final bool useGlobalIntensity;

  /// Whether to paint the directional liquid-glass reflection layer.
  final bool showSpecular;

  /// Whether pointer contact creates a local soft-light response.
  ///
  /// The listener observes events already targeted at [child]; it does not add
  /// an independent tap target or compete in the gesture arena.
  final bool interactiveLight;

  /// Optional color for the contact light; defaults to a readable soft white.
  final Color? interactiveLightColor;

  /// Optional complete backdrop filter. Texture blur uses this to compose the
  /// source blur with MIUIX's extended blend-mode shader.
  final ImageFilter? imageFilter;

  /// Optional material-specific optical treatment.
  ///
  /// Navigation surfaces use [MiuixGlassOptics.navigation]. Other components
  /// retain the established neutral glass recipe unless they opt in.
  final MiuixGlassOptics? optics;

  /// Backdrop compositing mode used by the engine layer.
  ///
  /// Ordinary panels retain Flutter's source-over default. Bars painted after
  /// a route body may select [BlendMode.src] to avoid double composition in a
  /// transition or opacity saveLayer.
  final BlendMode blendMode;

  @override
  State<MiuixGlass> createState() => _MiuixGlassState();
}

class _MiuixGlassState extends State<MiuixGlass> {
  Offset? _lightPosition;
  bool _lightActive = false;

  void _activateLight(PointerEvent event) {
    if (!mounted || !widget.interactiveLight) return;
    setState(() {
      _lightPosition = event.localPosition;
      _lightActive = true;
    });
  }

  void _moveLight(PointerEvent event) {
    if (!mounted || !widget.interactiveLight || !_lightActive) return;
    setState(() => _lightPosition = event.localPosition);
  }

  void _releaseLight(PointerEvent event) {
    if (!mounted || !widget.interactiveLight) return;
    setState(() {
      _lightPosition = event.localPosition;
      _lightActive = false;
    });
  }

  void _cancelLight(PointerEvent event) {
    if (!mounted || !widget.interactiveLight || !_lightActive) return;
    setState(() => _lightActive = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = MiuixTheme.of(context);
    final scheme = Theme.of(context).colorScheme;
    final effectiveRadius = widget.radius ?? theme.radius.lg;
    final effectiveBorderRadius =
        widget.borderRadius ?? BorderRadius.circular(effectiveRadius);
    final intensity = theme.glassIntensity;
    // TextureBlur/LayerBackdrop owns an explicit enable switch and disables
    // global intensity scaling. It must therefore keep rendering even when
    // the unrelated application-wide liquid-glass option is off. Ordinary
    // component glass still follows the global enable flag.
    final glassEnabled =
        widget.enabled && (!widget.useGlobalIntensity || theme.enableGlass);
    final effectiveOpacity = glassEnabled
        ? (widget.useGlobalIntensity
              ? widget.optics?.resolveOpacity(widget.opacity, intensity) ??
                    intensity.resolveOpacity(widget.opacity)
              : widget.opacity)
        : 1.0;
    final effectiveBlur = widget.useGlobalIntensity
        ? widget.optics?.resolveBlur(widget.blur, intensity) ??
              intensity.resolveBlur(widget.blur)
        : widget.blur;
    final tint = widget.color ?? scheme.surface;
    final explicitShape = widget.shape;
    final ShapeBorder shape =
        explicitShape ??
        (theme.enableSquircle
            ? MiuixSquircleBorder(
                borderRadius: effectiveBorderRadius,
                side: widget.border ?? BorderSide.none,
              )
            : RoundedRectangleBorder(
                borderRadius: effectiveBorderRadius,
                side: widget.border ?? BorderSide.none,
              ));
    final decoration = ShapeDecoration(
      // Preserve an explicitly supplied tint alpha. This lets callers request
      // a blur-only transparent layer without accidentally turning
      // `Colors.transparent` into an opaque black surface.
      color: tint.withValues(alpha: tint.a * effectiveOpacity),
      shape: shape,
    );
    Widget tintedContent = DecoratedBox(
      decoration: decoration,
      child: Padding(
        padding: widget.padding ?? EdgeInsets.all(theme.spacing.lg),
        child: widget.child,
      ),
    );
    // ShapeBorder has no generic copyWith(side:) API. An explicit arbitrary
    // silhouette therefore receives its requested stroke as a separate
    // foreground pass, still clipped to the exact same outer path.
    if (explicitShape != null &&
        widget.border != null &&
        widget.border!.style != BorderStyle.none) {
      tintedContent = CustomPaint(
        foregroundPainter: _MiuixGlassShapeBorderPainter(
          shape: explicitShape,
          side: widget.border!,
          textDirection: Directionality.of(context),
        ),
        child: tintedContent,
      );
    }
    if (!glassEnabled) {
      return tintedContent;
    }

    // A plain blur plus a tint that matches the page becomes visually
    // indistinguishable from an opaque panel on MIUIX's pale surfaces. Real
    // texture blur retains chroma and adds a directional edge reflection. The
    // two lightweight layers below reproduce those cues without drawing over
    // the component's content or changing its hit-test geometry.
    final level = intensity.index / (MiuixGlassIntensity.values.length - 1);
    // A specular edge should describe the glass, not repaint the whole panel.
    // Keeping this restrained is especially important at level five: a broad
    // 24% white wash made the transparent surface look opaque on the example's
    // nearly white settings page.
    final highlightAlpha = level <= .5
        ? .10 + level * .14
        : lerpDouble(.17, .12, (level - .5) * 2)!;
    final highlightSide = BorderSide(
      color: scheme.onSurface.withValues(alpha: .025 + level * .025),
      width: .5,
    );
    final highlightShape =
        explicitShape ??
        (theme.enableSquircle
            ? MiuixSquircleBorder(
                borderRadius: effectiveBorderRadius,
                side: highlightSide,
              )
            : RoundedRectangleBorder(
                borderRadius: effectiveBorderRadius,
                side: highlightSide,
              ));
    Widget specular;
    if (widget.optics case final optics?) {
      // Clear navigation glass uses edge refraction rather than a broad white
      // wash. The center remains genuinely transparent while a bright leading
      // edge and darker trailing edge separate it from complex page content.
      specular = CustomPaint(
        key: const ValueKey('miuix-glass-specular-highlight'),
        foregroundPainter: _MiuixGlassOpticalEdgePainter(
          shape: shape,
          textDirection: Directionality.of(context),
          highlightAlpha: optics.edgeHighlightAlpha,
          shadowAlpha: optics.edgeShadowAlpha,
          width: optics.edgeWidth,
          darkMode: scheme.brightness == Brightness.dark,
        ),
      );
    } else {
      specular = DecoratedBox(
        key: const ValueKey('miuix-glass-specular-highlight'),
        decoration: ShapeDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0, .42, 1],
            colors: [
              Colors.white.withValues(alpha: highlightAlpha),
              Colors.white.withValues(alpha: highlightAlpha * .12),
              (scheme.brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black)
                  .withValues(alpha: highlightAlpha * .16),
            ],
          ),
          shape: highlightShape,
        ),
      );
    }
    if (explicitShape != null) {
      specular = CustomPaint(
        foregroundPainter: _MiuixGlassShapeBorderPainter(
          shape: explicitShape,
          side: highlightSide,
          textDirection: Directionality.of(context),
        ),
        child: specular,
      );
    }
    final glassContent = Stack(
      fit: StackFit.passthrough,
      children: [
        tintedContent,
        if (widget.showSpecular)
          Positioned.fill(child: IgnorePointer(child: specular)),
        if (widget.interactiveLight && _lightPosition != null)
          Positioned.fill(
            child: IgnorePointer(
              child: TweenAnimationBuilder<double>(
                key: const ValueKey('miuix-glass-interactive-light'),
                tween: Tween<double>(end: _lightActive ? 1 : 0),
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : theme.motion.fast,
                curve: Curves.easeOutCubic,
                builder: (context, opacity, _) => CustomPaint(
                  painter: _MiuixGlassTouchLightPainter(
                    position: _lightPosition!,
                    opacity: opacity,
                    color: widget.interactiveLightColor ?? Colors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
    final filteredGlass = ClipPath(
      clipper: ShapeBorderClipper(shape: shape),
      child: BackdropFilter(
        key: const ValueKey('miuix-glass-backdrop-filter'),
        blendMode: widget.blendMode,
        filter:
            widget.imageFilter ??
            ImageFilter.blur(sigmaX: effectiveBlur, sigmaY: effectiveBlur),
        child: glassContent,
      ),
    );
    if (!mounted || !widget.interactiveLight) return filteredGlass;
    return Listener(
      behavior: HitTestBehavior.deferToChild,
      onPointerDown: _activateLight,
      onPointerMove: _moveLight,
      onPointerUp: _releaseLight,
      onPointerCancel: _cancelLight,
      child: filteredGlass,
    );
  }
}

/// Paints opposing optical edges without tinting the glass center.
///
/// The double-width stroke is clipped to the exact surface path, so rounded
/// floating navigation never recreates a rectangular shadow outside its pill.
class _MiuixGlassOpticalEdgePainter extends CustomPainter {
  const _MiuixGlassOpticalEdgePainter({
    required this.shape,
    required this.textDirection,
    required this.highlightAlpha,
    required this.shadowAlpha,
    required this.width,
    required this.darkMode,
  });

  final ShapeBorder shape;
  final TextDirection textDirection;
  final double highlightAlpha;
  final double shadowAlpha;
  final double width;
  final bool darkMode;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || width <= 0) return;
    final bounds = Offset.zero & size;
    final path = shape.getOuterPath(bounds, textDirection: textDirection);
    final shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      stops: const [0, .42, .72, 1],
      colors: [
        Colors.white.withValues(alpha: highlightAlpha),
        Colors.white.withValues(alpha: highlightAlpha * .36),
        (darkMode ? Colors.white : Colors.black).withValues(
          alpha: shadowAlpha * .35,
        ),
        (darkMode ? Colors.white : Colors.black).withValues(alpha: shadowAlpha),
      ],
    ).createShader(bounds);
    canvas.save();
    canvas.clipPath(path);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width * 2
        ..shader = shader
        ..isAntiAlias = true,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MiuixGlassOpticalEdgePainter oldDelegate) =>
      oldDelegate.shape != shape ||
      oldDelegate.textDirection != textDirection ||
      oldDelegate.highlightAlpha != highlightAlpha ||
      oldDelegate.shadowAlpha != shadowAlpha ||
      oldDelegate.width != width ||
      oldDelegate.darkMode != darkMode;
}

/// Paints a stroke inside an arbitrary glass silhouette.
///
/// Drawing at double width under the outer-path clip keeps the requested
/// logical stroke completely inside, matching the radius-based decorations.
class _MiuixGlassShapeBorderPainter extends CustomPainter {
  const _MiuixGlassShapeBorderPainter({
    required this.shape,
    required this.side,
    required this.textDirection,
  });

  final ShapeBorder shape;
  final BorderSide side;
  final TextDirection textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final path = shape.getOuterPath(
      Offset.zero & size,
      textDirection: textDirection,
    );
    final paint = Paint()
      ..color = side.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = side.width == 0 ? 0 : side.width * 2;
    canvas
      ..save()
      ..clipPath(path)
      ..drawPath(path, paint)
      ..restore();
  }

  @override
  bool shouldRepaint(covariant _MiuixGlassShapeBorderPainter oldDelegate) {
    return oldDelegate.shape != shape ||
        oldDelegate.side != side ||
        oldDelegate.textDirection != textDirection;
  }
}

class _MiuixGlassTouchLightPainter extends CustomPainter {
  const _MiuixGlassTouchLightPainter({
    required this.position,
    required this.opacity,
    required this.color,
  });

  final Offset position;
  final double opacity;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0 || size.isEmpty) return;
    final radius = math.max(52.0, size.shortestSide * 1.15);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: .18 * opacity),
          color.withValues(alpha: .055 * opacity),
          Colors.transparent,
        ],
        stops: const [0, .42, 1],
      ).createShader(Rect.fromCircle(center: position, radius: radius));
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(_MiuixGlassTouchLightPainter oldDelegate) =>
      oldDelegate.position != position ||
      oldDelegate.opacity != opacity ||
      oldDelegate.color != color;
}

/// Press feedback wrapper with sink and optional tilt-like scaling.
///
/// The widget centralizes a common MIUI interaction pattern: controls visually
/// settle downward while pressed, then spring back quickly.
class MiuixPressable extends StatefulWidget {
  /// Creates a press feedback wrapper.
  const MiuixPressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scale = 0.94,
    this.sinkDampingRatio = .8,
    this.sinkStiffness = 600,
    this.borderRadius,
    this.shape,
    this.contentClipBuilder,
    this.contentAlreadyClipped = false,
    this.feedbackType = MiuixPressFeedbackType.sink,
    this.holdDown = false,
    this.showIndication = false,
    this.indication = const MiuixIndication(),
    this.feedbackOnly = false,
    this.pointerInputEnabled = true,
    this.interactionSource,
  });

  /// Content that receives feedback.
  final Widget child;

  /// Tap callback.
  final VoidCallback? onTap;

  /// Optional long-press callback.
  final VoidCallback? onLongPress;

  /// Pressed scale.
  final double scale;

  /// Damping ratio used by sink feedback.
  final double sinkDampingRatio;

  /// Spring stiffness used by sink feedback.
  final double sinkStiffness;

  /// Optional material ripple radius.
  final BorderRadius? borderRadius;

  /// Optional exact clip shape for the content and pressed indication.
  ///
  /// MIUIX components commonly use a continuous-corner `miuixShape` rather
  /// than a circular rounded rectangle. When supplied, this takes precedence
  /// over [borderRadius] so the interaction layer shares the painted outline.
  final ShapeBorder? shape;

  /// Optional source-specific clip applied to content and indication together.
  ///
  /// Static MIUIX squircles use a baked-SDF mask rather than a [ShapeBorder].
  /// Supplying this builder lets those components retain the exact mask while
  /// keeping press/sink transforms in the same order as the source modifier.
  final Widget Function(Widget child)? contentClipBuilder;

  /// Whether [child] already owns the exact component silhouette clip.
  ///
  /// Backdrop glass must clip its filter internally. Setting this keeps the
  /// content from being antialiased a second time while still clipping the
  /// optional pressed indication to [shape] or [borderRadius].
  final bool contentAlreadyClipped;

  /// Feedback style used while the control is pressed.
  final MiuixPressFeedbackType feedbackType;

  /// Whether feedback remains held independently of the pointer lifecycle.
  ///
  /// MIUIX preferences use this while a child dialog remains visible.
  final bool holdDown;

  /// Whether to paint the MIUIX pressed indication over the child.
  final bool showIndication;

  /// Nullable source indication; null removes the overlay entirely.
  final MiuixIndication? indication;

  /// Whether pointer presses animate feedback without adding a tap action.
  ///
  /// Source controls such as a read-only Checkbox still install `pressable`
  /// outside their optional toggleable modifier. This mode preserves that
  /// indication while keeping accessibility semantics non-interactive.
  final bool feedbackOnly;

  /// Whether this wrapper creates pointer, hover, focus, or keyboard input.
  ///
  /// This is distinct from [holdDown]. Compose can attach a `pressable`
  /// modifier to a Card solely so `HoldDownObserver` drives Sink or Tilt,
  /// while omitting `combinedClickable` when both callbacks are null. In that
  /// branch the held animation remains visible, but a real pointer must not
  /// manufacture an empty click target or start another press animation.
  final bool pointerInputEnabled;

  /// Optional source-compatible observer for pointer press state.
  final MiuixInteractionSource? interactionSource;

  @override
  State<MiuixPressable> createState() => _MiuixPressableState();
}

/// Identifies which source interaction channel selected the next spring.
enum _MiuixIndicationChange {
  pressEnter,
  pressExit,
  hoverEnter,
  hoverExit,
  focusEnter,
  focusExit,
  holdEnter,
  holdExit,
}

class _MiuixPressableState extends State<MiuixPressable>
    with TickerProviderStateMixin {
  bool _pressed = false;
  bool _hovered = false;
  bool _focused = false;
  Alignment _tiltOrigin = Alignment.center;
  double _tiltTargetX = 0;
  double _tiltTargetY = 0;
  late final AnimationController _sinkController;
  late final AnimationController _tiltXController;
  late final AnimationController _tiltYController;
  late final AnimationController _indicationController;
  late final Listenable _motion;
  TickerFuture? _positiveIndicationAnimation;
  int _indicationRevision = 0;
  bool _reduceMotion = false;

  bool get _visuallyPressed => _pressed || widget.holdDown;

  /// Sums the four independent alpha channels from `MiuixIndication.kt`.
  double get _indicationTarget {
    if (!widget.showIndication || widget.indication == null) return 0;
    return (_hovered ? .06 : 0) +
        (_focused ? .08 : 0) +
        (_pressed && !widget.holdDown ? .10 : 0) +
        (widget.holdDown ? .10 : 0);
  }

  @override
  void initState() {
    super.initState();
    _sinkController = AnimationController.unbounded(
      vsync: this,
      // SinkFeedbackNode owns an Animatable whose initial value is 1. A
      // pre-held Card receives HoldDownInteraction only after attachment, so
      // it must travel through the spring instead of appearing at the final
      // scale in frame one.
      value: 1,
    );
    _tiltXController = AnimationController.unbounded(vsync: this);
    _tiltYController = AnimationController.unbounded(vsync: this);
    _indicationController = AnimationController.unbounded(vsync: this);
    _motion = Listenable.merge([
      _sinkController,
      _tiltXController,
      _tiltYController,
    ]);
    // HoldDownObserver emits only after the press-feedback and indication
    // nodes attach. Reproduce that ordering for both channels.
    if (widget.holdDown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          if (widget.feedbackType != MiuixPressFeedbackType.none) {
            _syncFeedback();
          }
          if (widget.showIndication && widget.indication != null) {
            _syncIndication(_MiuixIndicationChange.holdEnter);
          }
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant MiuixPressable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.interactionSource, widget.interactionSource)) {
      if (_pressed) {
        oldWidget.interactionSource?.setPressed(false);
        widget.interactionSource?.setPressed(true);
      }
    }
    if (oldWidget.feedbackType != widget.feedbackType ||
        oldWidget.holdDown != widget.holdDown ||
        oldWidget.scale != widget.scale ||
        oldWidget.sinkDampingRatio != widget.sinkDampingRatio ||
        oldWidget.sinkStiffness != widget.sinkStiffness) {
      _syncFeedback();
    }
    final indicationAvailabilityChanged =
        oldWidget.showIndication != widget.showIndication ||
        (oldWidget.indication == null) != (widget.indication == null);
    if (indicationAvailabilityChanged && _indicationTarget == 0) {
      _indicationRevision++;
      _indicationController
        ..stop(canceled: true)
        ..value = 0;
    } else if (oldWidget.holdDown != widget.holdDown) {
      _syncIndication(
        widget.holdDown
            ? _MiuixIndicationChange.holdEnter
            : _MiuixIndicationChange.holdExit,
      );
    } else if (indicationAvailabilityChanged && _indicationTarget > 0) {
      _syncIndication(
        _pressed
            ? _MiuixIndicationChange.pressEnter
            : _hovered || _focused
            ? _MiuixIndicationChange.hoverEnter
            : _MiuixIndicationChange.holdEnter,
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextReduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (nextReduceMotion == _reduceMotion) return;
    _reduceMotion = nextReduceMotion;
    if (_reduceMotion) {
      // A system accessibility change can arrive while a spring is moving.
      // Stop every channel and publish the current logical state immediately
      // instead of allowing old momentum to continue after motion is disabled.
      _snapFeedbackToState();
      _snapIndicationToState();
    }
  }

  @override
  void dispose() {
    if (_pressed) {
      widget.interactionSource?.setPressed(false);
    }
    _sinkController.dispose();
    _tiltXController.dispose();
    _tiltYController.dispose();
    _indicationController.dispose();
    super.dispose();
  }

  void _springTo(
    AnimationController controller,
    double target,
    SpringDescription spring,
  ) {
    if (_reduceMotion) {
      controller
        ..stop(canceled: true)
        ..value = target;
      return;
    }
    // Compose Animatable.animateTo carries the live velocity when a new target
    // interrupts the current spring. Resetting it to zero creates a visible
    // cusp on a quick press/release or when a tilt target changes in flight.
    controller.animateWith(
      SpringSimulation(spring, controller.value, target, controller.velocity),
    );
  }

  void _syncFeedback() {
    final sinkTarget =
        widget.feedbackType == MiuixPressFeedbackType.sink && _visuallyPressed
        ? widget.scale
        : 1.0;
    _springTo(
      _sinkController,
      sinkTarget,
      debugMiuixSinkSpring(
        dampingRatio: widget.sinkDampingRatio,
        stiffness: widget.sinkStiffness,
      ),
    );

    final keepTilt =
        widget.feedbackType == MiuixPressFeedbackType.tilt && _visuallyPressed;
    _springTo(
      _tiltXController,
      keepTilt ? _tiltTargetX : 0,
      debugMiuixTiltSpring(),
    );
    _springTo(
      _tiltYController,
      keepTilt ? _tiltTargetY : 0,
      debugMiuixTiltSpring(),
    );
  }

  /// Resolves all transform channels without creating an animation frame.
  void _snapFeedbackToState() {
    final sinkTarget =
        widget.feedbackType == MiuixPressFeedbackType.sink && _visuallyPressed
        ? widget.scale
        : 1.0;
    final keepTilt =
        widget.feedbackType == MiuixPressFeedbackType.tilt && _visuallyPressed;
    _sinkController
      ..stop(canceled: true)
      ..value = sinkTarget;
    _tiltXController
      ..stop(canceled: true)
      ..value = keepTilt ? _tiltTargetX : 0;
    _tiltYController
      ..stop(canceled: true)
      ..value = keepTilt ? _tiltTargetY : 0;
  }

  /// Resolves the additive indication channels without a spring or fade.
  void _snapIndicationToState() {
    _indicationRevision++;
    _positiveIndicationAnimation = null;
    _indicationController
      ..stop(canceled: true)
      ..value = _indicationTarget;
  }

  /// Runs the four-spring state machine from current `MiuixIndication.kt`.
  ///
  /// MIUIX lets a positive transition finish before it starts the final fade
  /// to zero. New positive states cancel that pending rest transition, which
  /// also keeps hover, focus, press, and hold-down additive.
  void _syncIndication(_MiuixIndicationChange change) {
    final target = _indicationTarget;
    final revision = ++_indicationRevision;
    if (_reduceMotion) {
      _positiveIndicationAnimation = null;
      _indicationController
        ..stop(canceled: true)
        ..value = target;
      return;
    }
    final hoverOrFocus = switch (change) {
      _MiuixIndicationChange.hoverEnter ||
      _MiuixIndicationChange.hoverExit ||
      _MiuixIndicationChange.focusEnter ||
      _MiuixIndicationChange.focusExit => true,
      _ => false,
    };
    final entering = switch (change) {
      _MiuixIndicationChange.pressEnter ||
      _MiuixIndicationChange.hoverEnter ||
      _MiuixIndicationChange.focusEnter ||
      _MiuixIndicationChange.holdEnter => true,
      _ => false,
    };
    final spring = debugMiuixIndicationSpring(
      entering: entering,
      hoverOrFocus: hoverOrFocus,
    );
    final waitsForPositive =
        change == _MiuixIndicationChange.pressExit ||
        change == _MiuixIndicationChange.holdExit ||
        target == 0;
    if (!waitsForPositive) {
      final carriedVelocity = _indicationController.velocity;
      _indicationController.stop(canceled: true);
      _positiveIndicationAnimation = _indicationController.animateWith(
        SpringSimulation(
          spring,
          _indicationController.value,
          target,
          carriedVelocity,
          tolerance: const Tolerance(distance: .0001, velocity: .0001),
        ),
      );
      return;
    }
    final positiveAnimation = _positiveIndicationAnimation;
    () async {
      try {
        await positiveAnimation?.orCancel;
      } catch (_) {
        // A newer positive state intentionally cancels this pending rest.
      }
      if (!mounted ||
          revision != _indicationRevision ||
          _indicationTarget != target) {
        return;
      }
      _indicationController.animateWith(
        SpringSimulation(
          spring,
          _indicationController.value,
          target,
          _indicationController.velocity,
          tolerance: const Tolerance(distance: .0001, velocity: .0001),
        ),
      );
    }();
  }

  void _setPressed(bool value) {
    if (_pressed != value) {
      setState(() => _pressed = value);
      widget.interactionSource?.setPressed(value);
      _syncFeedback();
      _syncIndication(
        value
            ? _MiuixIndicationChange.pressEnter
            : _MiuixIndicationChange.pressExit,
      );
    }
  }

  void _setHovered(bool value) {
    if (_hovered != value) {
      setState(() => _hovered = value);
      _syncIndication(
        value
            ? _MiuixIndicationChange.hoverEnter
            : _MiuixIndicationChange.hoverExit,
      );
    }
  }

  void _setFocused(bool value) {
    if (_focused != value) {
      setState(() => _focused = value);
      _syncIndication(
        value
            ? _MiuixIndicationChange.focusEnter
            : _MiuixIndicationChange.focusExit,
      );
    }
  }

  // Converts the pointer position into the small two-axis rotation used by
  // MIUIX tilt feedback. Values remain normalized so the visual result is
  // independent of the card's concrete size.
  //
  // Keep this helper position-based instead of TapDownDetails-based because a
  // long press owns a second gesture lifecycle. When Flutter's long-press
  // recognizer wins, the competing tap recognizer first reports onTapCancel
  // and then onLongPressStart. Reapplying the source pivot at that transition
  // is what keeps MIUIX tilt visible for the entire hold.
  void _setTiltAt(Offset localPosition) {
    if (widget.feedbackType != MiuixPressFeedbackType.tilt) {
      return;
    }
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize || box.size.isEmpty) {
      return;
    }
    final target = debugMiuixTiltTarget(localPosition, box.size);
    setState(() {
      _tiltOrigin = target.origin;
      _tiltTargetX = target.rotationXDegrees;
      _tiltTargetY = target.rotationYDegrees;
    });
    _springTo(
      _tiltXController,
      target.rotationXDegrees,
      debugMiuixTiltSpring(),
    );
    _springTo(
      _tiltYController,
      target.rotationYDegrees,
      debugMiuixTiltSpring(),
    );
  }

  int _iconActivation = 0;

  void _activateIcon() {
    setState(() => _iconActivation++);
  }

  void _handleLongPress() {
    // Compose combinedClickable enables LongPress haptics by default. Dispatch
    // it when the recognizer wins, before invoking the owner's long-click.
    unawaited(MiuixHaptics.perform(MiuixHapticType.longPress));
    _activateIcon();
    widget.onLongPress?.call();
  }

  void _releaseFeedback() {
    _setPressed(false);
  }

  void _cancelFeedback() {
    setState(() {
      _tiltOrigin = Alignment.center;
      _tiltTargetX = 0;
      _tiltTargetY = 0;
    });
    _releaseFeedback();
  }

  @override
  Widget build(BuildContext context) {
    Widget? indicationLayer;
    if (widget.showIndication && widget.indication != null) {
      indicationLayer = IgnorePointer(
        child: FadeTransition(
          key: const ValueKey('miuix-press-indication'),
          // The four source springs animate additive hover, focus, press, and
          // hold channels through one shared alpha value.
          opacity: _indicationController,
          child: ColoredBox(color: widget.indication!.resolve(context)),
        ),
      );
      if (widget.contentAlreadyClipped) {
        indicationLayer = widget.shape != null
            ? ClipPath(
                clipper: ShapeBorderClipper(shape: widget.shape!),
                child: indicationLayer,
              )
            : widget.borderRadius != null
            ? ClipRRect(
                borderRadius: widget.borderRadius!,
                child: indicationLayer,
              )
            : indicationLayer;
      }
    }
    final indicatedChild = Stack(
      fit: StackFit.passthrough,
      children: [
        MiuixIconInteraction(
          enabled:
              widget.pointerInputEnabled &&
              (widget.onTap != null || widget.onLongPress != null),
          pressed: _pressed || widget.holdDown,
          activation: _iconActivation,
          child: widget.child,
        ),
        if (indicationLayer != null) Positioned.fill(child: indicationLayer),
      ],
    );
    // Compose orders Card's `pressable` modifier outside its shape clip. The
    // card is clipped first and that already-rounded layer is then rotated, so
    // tilted corners may paint a few pixels beyond the untransformed bounds.
    // Clipping after Transform instead cuts those pixels off and shortens the
    // held card compared with the source.
    // A ShapeBorder path is required for source components that opt into G2
    // smooth rounding. ClipRRect remains the compatibility path for existing
    // callers that only provide a conventional BorderRadius.
    final sourceClippedChild = widget.contentAlreadyClipped
        ? indicatedChild
        : widget.contentClipBuilder != null
        ? widget.contentClipBuilder!(indicatedChild)
        : widget.shape != null
        ? ClipPath(
            clipper: ShapeBorderClipper(shape: widget.shape!),
            child: indicatedChild,
          )
        : widget.borderRadius == null
        ? indicatedChild
        : ClipRRect(borderRadius: widget.borderRadius!, child: indicatedChild);
    final feedbackChild = AnimatedBuilder(
      animation: _motion,
      child: sourceClippedChild,
      builder: (context, child) {
        Widget transformed = Transform.scale(
          key: const ValueKey('miuix-sink-transform'),
          scale: widget.feedbackType == MiuixPressFeedbackType.sink
              ? _sinkController.value
              : 1,
          transformHitTests: false,
          child: child,
        );
        if (widget.feedbackType == MiuixPressFeedbackType.tilt) {
          final transform = Matrix4.identity()
            ..setEntry(3, 2, debugMiuixTiltPerspective())
            ..rotateX(_tiltXController.value * math.pi / 180)
            ..rotateY(_tiltYController.value * math.pi / 180);
          transformed = Transform(
            key: const ValueKey('miuix-tilt-transform'),
            alignment: _tiltOrigin,
            transform: transform,
            transformHitTests: false,
            child: transformed,
          );
        }
        return transformed;
      },
    );
    final enabled =
        widget.pointerInputEnabled &&
        (widget.onTap != null ||
            widget.onLongPress != null ||
            widget.showIndication ||
            widget.feedbackOnly ||
            widget.feedbackType != MiuixPressFeedbackType.none);
    final effectiveTap = widget.onTap != null
        ? () {
            _activateIcon();
            widget.onTap!();
          }
        : (enabled && !widget.feedbackOnly ? () {} : null);
    final gesture = GestureDetector(
      behavior: HitTestBehavior.opaque,
      // Compose's interactive Card installs an empty click action when only
      // indication is requested, so the surface still enters pressed state.
      excludeFromSemantics:
          widget.feedbackOnly &&
          widget.onTap == null &&
          widget.onLongPress == null,
      onTap: effectiveTap ?? (widget.feedbackOnly ? () {} : null),
      onLongPress: widget.onLongPress == null ? null : _handleLongPress,
      onTapDown: enabled
          ? (details) {
              _setPressed(true);
              _setTiltAt(details.localPosition);
            }
          : null,
      onTapCancel: enabled
          ? () {
              // A long-press recognizer cancels the competing tap recognizer
              // before it reports start. Keep the surface pressed across that
              // hand-off; onLongPressCancel still releases it when a parent
              // scroll gesture actually wins.
              if (widget.onLongPress == null) {
                _cancelFeedback();
              }
            }
          : null,
      onTapUp: enabled ? (_) => _releaseFeedback() : null,
      // GestureDetector represents tap and long press with competing
      // recognizers. The tap recognizer's cancellation must not terminate the
      // visual feedback after the long press has actually been accepted.
      onLongPressStart: widget.onLongPress == null
          ? null
          : (details) {
              _setPressed(true);
              _setTiltAt(details.localPosition);
            },
      onLongPressEnd: widget.onLongPress == null
          ? null
          : (_) => _releaseFeedback(),
      onLongPressCancel: widget.onLongPress == null ? null : _cancelFeedback,
      child: feedbackChild,
    );
    final focusable = FocusableActionDetector(
      enabled: enabled && !widget.feedbackOnly,
      onFocusChange: _setFocused,
      shortcuts: effectiveTap == null
          ? const <ShortcutActivator, Intent>{}
          : const <ShortcutActivator, Intent>{
              SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
              SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
            },
      actions: effectiveTap == null
          ? const <Type, Action<Intent>>{}
          : <Type, Action<Intent>>{
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (_) {
                  effectiveTap();
                  return null;
                },
              ),
            },
      child: gesture,
    );
    return MouseRegion(
      onEnter: enabled ? (_) => _setHovered(true) : null,
      onExit: enabled ? (_) => _setHovered(false) : null,
      child: focusable,
    );
  }
}
