import 'package:flutter/material.dart';

/// Complete semantic color table used by Compose MIUIX 1.0.9.
///
/// Flutter's Material [ColorScheme] has fewer roles than MIUIX. Keeping the
/// source role names in a theme extension lets widgets and sample pages use
/// the missing disabled, variant, dimming, divider, and slider colors without
/// silently substituting unrelated Material roles.
@immutable
class MiuixSemanticColors extends ThemeExtension<MiuixSemanticColors> {
  /// Creates a semantic table from named source roles.
  const MiuixSemanticColors(this.values);

  /// Exact default light palette from Compose MIUIX 1.0.9.
  const MiuixSemanticColors.light()
    : values = const <String, Color>{
        'primary': Color(0xFF3482FF),
        'onPrimary': Color(0xFFFFFFFF),
        'primaryVariant': Color(0xFF3482FF),
        'onPrimaryVariant': Color(0xFFAECDFF),
        'error': Color(0xFFE94634),
        'onError': Color(0xFFFFFFFF),
        'errorContainer': Color(0xFFFDF6F4),
        'onErrorContainer': Color(0xFF410002),
        'disabledPrimary': Color(0xFFC2D9FF),
        'disabledOnPrimary': Color(0xFFF3F8FF),
        'disabledPrimaryButton': Color(0xFFC2D9FF),
        'disabledOnPrimaryButton': Color(0xFFFFFFFF),
        'disabledPrimarySlider': Color(0xFFB8CFF5),
        'primaryContainer': Color(0xFF5D9BFF),
        'onPrimaryContainer': Color(0xFFFFFFFF),
        'secondary': Color(0xFFE6E6E6),
        'onSecondary': Color(0xFFFFFFFF),
        'secondaryVariant': Color(0xFFF0F0F0),
        'onSecondaryVariant': Color(0xFF303030),
        'disabledSecondary': Color(0xFFF0F0F0),
        'disabledOnSecondary': Color(0xFFFCFCFC),
        'disabledSecondaryVariant': Color(0xFFF2F2F2),
        'disabledOnSecondaryVariant': Color(0xFFB2B2B2),
        'secondaryContainer': Color(0xFFF0F0F0),
        'onSecondaryContainer': Color(0xFFA9A9A9),
        'secondaryContainerVariant': Color(0xFFF0F0F0),
        'onSecondaryContainerVariant': Color(0xFFA8A8A8),
        'tertiaryContainer': Color(0xFFEAF2FF),
        'onTertiaryContainer': Color(0xFF3482FF),
        'tertiaryContainerVariant': Color(0xFFEAF2FF),
        'background': Color(0xFFFFFFFF),
        'onBackground': Color(0xFF000000),
        'onBackgroundVariant': Color(0xFF8C93B0),
        'surface': Color(0xFFF7F7F7),
        'onSurface': Color(0xFF000000),
        'surfaceVariant': Color(0xFFFFFFFF),
        'onSurfaceSecondary': Color(0xCC000000),
        'onSurfaceVariantSummary': Color(0x99000000),
        'onSurfaceVariantActions': Color(0x66000000),
        'disabledOnSurface': Color(0xFFB2B2B2),
        'surfaceContainer': Color(0xFFFFFFFF),
        'onSurfaceContainer': Color(0xFF000000),
        'onSurfaceContainerVariant': Color(0xFF959595),
        'surfaceContainerHigh': Color(0xFFE8E8E8),
        'onSurfaceContainerHigh': Color(0xFFA2A2A2),
        'surfaceContainerHighest': Color(0xFFE8E8E8),
        'onSurfaceContainerHighest': Color(0xFF000000),
        'outline': Color(0xFFD9D9D9),
        'dividerLine': Color(0xFFE0E0E0),
        'windowDimming': Color(0x4D000000),
        'sliderKeyPoint': Color(0x4DA3B3CD),
        'sliderKeyPointForeground': Color(0xFF6EB5FF),
        'sliderBackground': Color(0x0F000000),
      };

  /// Exact default dark palette from Compose MIUIX 1.0.9.
  const MiuixSemanticColors.dark()
    : values = const <String, Color>{
        'primary': Color(0xFF277AF7),
        'onPrimary': Color(0xFFFFFFFF),
        'primaryVariant': Color(0xFF0073DD),
        'onPrimaryVariant': Color(0xFF99C7F1),
        'error': Color(0xFFF12522),
        'onError': Color(0xFFFFFFFF),
        'errorContainer': Color(0xFF2E0603),
        'onErrorContainer': Color(0xFFFFDAD6),
        'disabledPrimary': Color(0xFF253E64),
        'disabledOnPrimary': Color(0xFF677993),
        'disabledPrimaryButton': Color(0xFF253E64),
        'disabledOnPrimaryButton': Color(0xFF677893),
        'disabledPrimarySlider': Color(0xFF44587C),
        'primaryContainer': Color(0xFF338FE4),
        'onPrimaryContainer': Color(0xFFFFFFFF),
        'secondary': Color(0xFF505050),
        'onSecondary': Color(0xFFFFFFFF),
        'secondaryVariant': Color(0xFF434343),
        'onSecondaryVariant': Color(0xFFD9D9D9),
        'disabledSecondary': Color(0xFF3F3F3F),
        'disabledOnSecondary': Color(0xFF797979),
        'disabledSecondaryVariant': Color(0xFF404040),
        'disabledOnSecondaryVariant': Color(0xFF707170),
        'secondaryContainer': Color(0xFF434343),
        'onSecondaryContainer': Color(0xFF7C7C7C),
        'secondaryContainerVariant': Color(0xFF4F4F4F),
        'onSecondaryContainerVariant': Color(0xFF959595),
        'tertiaryContainer': Color(0xFF2B3B54),
        'onTertiaryContainer': Color(0xFF4788FF),
        'tertiaryContainerVariant': Color(0xFF505050),
        'background': Color(0xFF242424),
        'onBackground': Color(0xE6FFFFFF),
        'onBackgroundVariant': Color(0xFF787E96),
        'surface': Color(0xFF000000),
        'onSurface': Color(0xFFF2F2F2),
        'surfaceVariant': Color(0xFF242424),
        'onSurfaceSecondary': Color(0xCCFFFFFF),
        'onSurfaceVariantSummary': Color(0x80FFFFFF),
        'onSurfaceVariantActions': Color(0x66FFFFFF),
        'disabledOnSurface': Color(0xFF666666),
        'surfaceContainer': Color(0xFF242424),
        'onSurfaceContainer': Color(0xE6FFFFFF),
        'onSurfaceContainerVariant': Color(0xFF737373),
        'surfaceContainerHigh': Color(0xFF242424),
        'onSurfaceContainerHigh': Color(0xFF666666),
        'surfaceContainerHighest': Color(0xFF2D2D2D),
        'onSurfaceContainerHighest': Color(0xFFE9E9E9),
        'outline': Color(0xFF404040),
        'dividerLine': Color(0xFF393939),
        'windowDimming': Color(0x99000000),
        'sliderKeyPoint': Color(0x4D7A8AA6),
        'sliderKeyPointForeground': Color(0xFF5DAAFF),
        'sliderBackground': Color(0x26FFFFFF),
      };

  /// Builds every MIUIX role from a generated or platform color scheme.
  factory MiuixSemanticColors.fromScheme(ColorScheme scheme) {
    final dark = scheme.brightness == Brightness.dark;
    final fallback = dark
        ? const MiuixSemanticColors.dark().values
        : const MiuixSemanticColors.light().values;
    // MonetMapping.kt flattens translucent disabled roles over their actual
    // surface before exposing the MIUIX palette. Reproduce that mapping here
    // instead of copying similarly named Material roles, whose meanings differ
    // for secondary switches, fixed primary colors, and surface variants.
    Color opaqueOver(Color foreground, Color background) =>
        Color.alphaBlend(foreground, background).withValues(alpha: 1);
    final surface = scheme.surface;
    // The upstream Monet mapping still consumes these distinct Material roles
    // even though Flutter now labels them deprecated aliases. Generated
    // palettes can assign values that differ from the nearest container role.
    // ignore: deprecated_member_use
    final background = scheme.background;
    // ignore: deprecated_member_use
    final onBackground = scheme.onBackground;
    // ignore: deprecated_member_use
    final surfaceVariant = scheme.surfaceVariant;
    final surfaceContainerHigh = scheme.surfaceContainerHigh;
    // Role groups below intentionally follow the order of the upstream Colors
    // constructor. Keeping that order makes future source-version diffs
    // mechanical: reviewers can compare one contiguous group at a time.
    //
    // Primary roles use Material fixed roles for MIUIX's Variant pair.
    // Disabled primary colors are flattened because MIUIX Colors stores
    // concrete colors, not a foreground plus an opacity instruction.
    //
    // Secondary MIUIX controls are neutral. Their enabled track and thumb map
    // to outlineVariant and outline, not Material's chromatic secondary pair.
    // This is why a generated switch remains neutral under a Monet palette.
    //
    // Container variants deliberately use the highest surface container and
    // onSurfaceVariant. These roles drive dropdown summaries and disabled
    // preference content, so substituting secondaryContainer changes visible
    // contrast throughout the component library.
    //
    // Surface summary and action roles are opaque in generated MIUIX themes.
    // Alpha is resolved over the corresponding source surface before storage,
    // matching ensureOpaqueOver in MonetMapping.kt.
    //
    // Slider and dimming roles finish the mapping. Dimming intentionally keeps
    // alpha because it is itself an overlay, while sliderBackground is an
    // already-composited surface color.
    final values = Map<String, Color>.of(fallback)
      ..addAll(<String, Color>{
        'primary': scheme.primary,
        'onPrimary': scheme.onPrimary,
        'primaryVariant': scheme.primaryFixed,
        'onPrimaryVariant': scheme.onPrimaryFixed,
        'error': scheme.error,
        'onError': scheme.onError,
        'errorContainer': scheme.errorContainer,
        'onErrorContainer': scheme.onErrorContainer,
        'disabledPrimary': opaqueOver(
          scheme.primary.withValues(alpha: .38),
          surface,
        ),
        'disabledOnPrimary': opaqueOver(
          scheme.onPrimary.withValues(alpha: .38),
          opaqueOver(scheme.primary.withValues(alpha: .38), surface),
        ),
        'disabledPrimaryButton': opaqueOver(
          scheme.primary.withValues(alpha: .38),
          surface,
        ),
        'disabledOnPrimaryButton': opaqueOver(
          scheme.onPrimary.withValues(alpha: .6),
          opaqueOver(scheme.primary.withValues(alpha: .38), surface),
        ),
        'disabledPrimarySlider': opaqueOver(
          scheme.primary.withValues(alpha: .38),
          surface,
        ),
        'primaryContainer': scheme.primaryContainer,
        'onPrimaryContainer': scheme.onPrimaryContainer,
        'secondary': scheme.outlineVariant,
        'onSecondary': scheme.outline,
        'secondaryVariant': surfaceContainerHigh,
        'onSecondaryVariant': scheme.onSurface,
        'disabledSecondary': opaqueOver(
          scheme.outlineVariant.withValues(alpha: .5),
          surface,
        ),
        'disabledOnSecondary': opaqueOver(
          scheme.onSurface.withValues(alpha: .38),
          opaqueOver(scheme.outlineVariant.withValues(alpha: .5), surface),
        ),
        'disabledSecondaryVariant': opaqueOver(
          surfaceContainerHigh.withValues(alpha: .6),
          surface,
        ),
        'disabledOnSecondaryVariant': opaqueOver(
          scheme.onSurface.withValues(alpha: .38),
          opaqueOver(surfaceContainerHigh.withValues(alpha: .6), surface),
        ),
        'secondaryContainer': scheme.secondaryContainer,
        'onSecondaryContainer': scheme.onSecondaryContainer,
        'secondaryContainerVariant': scheme.surfaceContainerHighest,
        'onSecondaryContainerVariant': scheme.onSurfaceVariant,
        'tertiaryContainer': scheme.tertiaryContainer,
        'onTertiaryContainer': scheme.onTertiaryContainer,
        'tertiaryContainerVariant': scheme.onTertiaryContainer,
        'background': background,
        'onBackground': onBackground,
        'onBackgroundVariant': scheme.primary,
        'surface': surface,
        'onSurface': scheme.onSurface,
        'surfaceVariant': surfaceVariant,
        'onSurfaceSecondary': opaqueOver(
          scheme.onSurface.withValues(alpha: .8),
          surface,
        ),
        'onSurfaceVariantSummary': scheme.onSurfaceVariant,
        'onSurfaceVariantActions': scheme.onSurfaceVariant,
        'disabledOnSurface': scheme.onSurface,
        'surfaceContainer': scheme.surfaceContainer,
        'onSurfaceContainer': scheme.onSurface,
        'onSurfaceContainerVariant': scheme.onSurfaceVariant,
        'surfaceContainerHigh': surfaceContainerHigh,
        'onSurfaceContainerHigh': opaqueOver(
          scheme.onSurface.withValues(alpha: .8),
          surfaceContainerHigh,
        ),
        'surfaceContainerHighest': scheme.surfaceContainerHighest,
        'onSurfaceContainerHighest': scheme.onSurface,
        'outline': scheme.outline,
        'dividerLine': scheme.outlineVariant,
        'windowDimming': Colors.black.withValues(alpha: dark ? .6 : .3),
        'sliderKeyPoint': scheme.primary,
        'sliderKeyPointForeground': surfaceContainerHigh,
        'sliderBackground': opaqueOver(
          scheme.primary.withValues(alpha: .2),
          surface,
        ),
      });
    return MiuixSemanticColors(Map<String, Color>.unmodifiable(values));
  }

  /// Values in original MIUIX declaration and sample display order.
  final Map<String, Color> values;

  /// Reads a semantic role and fails early when a caller misspells its name.
  Color operator [](String role) {
    final color = values[role];
    if (color == null) {
      // A transparent fallback hides the affected control and makes a typo
      // look like a rendering defect. Keep the documented failure identical
      // in Debug, Profile, and Release so the invalid role remains diagnosable.
      throw ArgumentError.value(
        role,
        'role',
        'Unknown MIUIX semantic color role',
      );
    }
    return color;
  }

  /// Returns the nearest semantic palette or derives one from Material roles.
  static MiuixSemanticColors of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<MiuixSemanticColors>() ??
        MiuixSemanticColors.fromScheme(theme.colorScheme);
  }

  @override
  MiuixSemanticColors copyWith({Map<String, Color>? values}) {
    return MiuixSemanticColors(values ?? this.values);
  }

  @override
  MiuixSemanticColors lerp(MiuixSemanticColors? other, double t) {
    if (other == null) return this;
    final roles = <String>{...values.keys, ...other.values.keys};
    return MiuixSemanticColors(
      Map<String, Color>.unmodifiable({
        for (final role in roles)
          role:
              Color.lerp(values[role], other.values[role], t) ??
              other.values[role] ??
              values[role]!,
      }),
    );
  }
}
