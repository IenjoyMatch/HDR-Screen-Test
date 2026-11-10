part of '../miuix_widgets.dart';

/// Public source and HyperOS defaults used by [MiuixFloatingActionButton].
abstract final class MiuixFloatingActionButtonDefaults {
  // Runtime content and geometry contract:
  // - Arbitrary child content takes precedence over convenience icon/label.
  // - Label-only actions remain valid and omit the absent icon gap.
  // - Missing content retains a measurable empty action surface.
  // - Non-finite minimum dimensions restore the public 60dp defaults.
  // - Finite negative minimum dimensions clamp to an explicit zero.
  // - Non-finite and non-positive elevations produce no projection.
  // - One resolved shape owns shadow, glass, clip, indication, and hit input.
  // - Debug and Release accept identical dynamically decoded values.

  /// Default minimum width in logical pixels.
  static const double minWidth = 60;

  /// Default minimum height in logical pixels.
  static const double minHeight = 60;

  /// Default graphics-layer shadow elevation in logical pixels.
  static const double shadowElevation = 4;
}

/// Floating action button matching MIUIX's source surface contract.
///
/// The upstream component is a clickable `CircleShape` surface with a 60dp
/// minimum size and 4dp elevation. Compose's percentage-based circle becomes
/// a stadium only when arbitrary content makes the surface non-square.
class MiuixFloatingActionButton extends StatelessWidget {
  /// Creates a HyperOS 4 floating action with local backdrop material.
  const MiuixFloatingActionButton({
    super.key,
    this.icon,
    this.child,
    required this.onPressed,
    this.label,
    this.shape,
    this.containerColor,
    this.contentColor,
    this.shadowElevation = MiuixFloatingActionButtonDefaults.shadowElevation,
    this.minWidth = MiuixFloatingActionButtonDefaults.minWidth,
    this.minHeight = MiuixFloatingActionButtonDefaults.minHeight,
    this.glass = true,
    this.glassBlur,
    this.glassOpacity,
    this.showGlassSpecular = true,
  }) : _source = false;

  /// Creates the opaque MIUIX 1.0.9 floating-action surface explicitly.
  const MiuixFloatingActionButton.source({
    super.key,
    this.icon,
    this.child,
    required this.onPressed,
    this.label,
    this.shape,
    this.containerColor,
    this.contentColor,
    this.shadowElevation = MiuixFloatingActionButtonDefaults.shadowElevation,
    this.minWidth = MiuixFloatingActionButtonDefaults.minWidth,
    this.minHeight = MiuixFloatingActionButtonDefaults.minHeight,
  }) : glass = false,
       glassBlur = null,
       glassOpacity = null,
       showGlassSpecular = false,
       _source = true;

  /// Convenience icon displayed inside the source-sized content box.
  ///
  /// Use [child] instead when the content is not an icon.
  final Widget? icon;

  /// Arbitrary source-style content.
  ///
  /// This mirrors the Compose content slot and takes precedence over the
  /// icon convenience layout.
  final Widget? child;

  /// Optional Flutter convenience label placed beside [icon].
  ///
  /// MIUIX itself exposes arbitrary [child] content rather than a separate
  /// extended variant. This adapter retains the older package API while still
  /// using the source 60dp minimum height and percentage circle shape.
  final String? label;

  /// Press callback.
  ///
  /// Upstream requires a callback. A nullable value is retained as a Flutter
  /// compatibility adapter for disabled application states.
  final VoidCallback? onPressed;

  /// Optional exact source or custom surface shape.
  final ShapeBorder? shape;

  /// Optional container color; defaults to MIUIX `primary`.
  final Color? containerColor;

  /// Optional inherited icon/text color.
  ///
  /// The source `Surface` supplies `onSurface`. Its example explicitly passes
  /// `onPrimary` to the link icon.
  final Color? contentColor;

  /// Source shadow elevation in logical pixels.
  ///
  /// Every nonpositive value disables projection, matching `Surface.kt`.
  /// Negative values are intentionally accepted rather than normalized.
  final double shadowElevation;

  /// Minimum source surface width.
  final double minWidth;

  /// Minimum source surface height.
  final double minHeight;

  /// Whether the floating silhouette samples the content behind it.
  final bool glass;

  /// Optional role-specific backdrop sigma and tint opacity.
  final double? glassBlur;
  final double? glassOpacity;

  /// Whether enabled glass paints its restrained directional edge light.
  final bool showGlassSpecular;

  /// Distinguishes the exact source color fallback from the new default.
  final bool _source;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final textTheme = Theme.of(context).textTheme;
    final enabled = onPressed != null;
    final foreground =
        contentColor ?? (_source ? scheme.onSurface : scheme.onPrimary);
    final background = containerColor ?? scheme.primary;
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final safeMinWidth = minWidth.isFinite
        ? math.max(0, minWidth).toDouble()
        : MiuixFloatingActionButtonDefaults.minWidth;
    final safeMinHeight = minHeight.isFinite
        ? math.max(0, minHeight).toDouble()
        : MiuixFloatingActionButtonDefaults.minHeight;
    final safeShadowElevation = shadowElevation.isFinite
        ? math.max(0, shadowElevation).toDouble()
        : 0.0;
    // Compose defaultMinSize resolves each Dp constraint to an integer
    // physical pixel. At 420dpi the 60dp defaults are therefore 158px, not
    // Flutter's fractional 157.5px layout.
    final effectiveMinWidth = _miuixRoundLogicalDimension(
      safeMinWidth,
      pixelRatio,
    );
    final effectiveMinHeight = _miuixRoundLogicalDimension(
      safeMinHeight,
      pixelRatio,
    );
    // FloatingActionButton.kt defaults directly to Compose CircleShape. That
    // is a 50-percent RoundedCornerShape and is independent of MIUIX's smooth
    // corner preference, so Flutter's StadiumBorder is the exact counterpart.
    final effectiveShape = shape ?? const StadiumBorder();
    final effectiveChild =
        child ??
        (label == null
            ? icon ?? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ?icon,
                    if (icon != null) const SizedBox(width: 10),
                    Text(
                      label!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelLarge?.copyWith(
                        color: foreground,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ));
    final interactiveContent = MiuixPressable(
      onTap: onPressed,
      shape: effectiveShape,
      feedbackType: MiuixPressFeedbackType.none,
      showIndication: enabled,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: effectiveMinWidth,
          minHeight: effectiveMinHeight,
        ),
        // FloatingActionButton.kt puts arbitrary content in a Box whose
        // contentAlignment is Center. The previous Flutter adapter centered
        // only its convenience icon; a direct small child was laid out at
        // the upper-leading corner of the 60dp minimum surface.
        child: Align(
          alignment: Alignment.center,
          widthFactor: 1,
          heightFactor: 1,
          child: _MiuixContentColor(
            color: foreground,
            child: IconTheme(
              data: IconThemeData(color: foreground, size: 24),
              child: DefaultTextStyle.merge(
                style: TextStyle(color: foreground),
                child: effectiveChild,
              ),
            ),
          ),
        ),
      ),
    );

    // Only the action silhouette owns blur/tint/specular. Its surrounding
    // Stack or Scaffold region stays transparent, so content remains visible
    // around a circular button and through an extended capsule's cut corners.
    final fill = glass
        ? MiuixGlass(
            key: const ValueKey('miuix-floating-action-button-glass'),
            blur: glassBlur ?? hyperOs4.floatingActionButtonBlur,
            opacity: glassOpacity ?? hyperOs4.floatingActionButtonTintOpacity,
            color: background,
            shape: effectiveShape,
            padding: EdgeInsets.zero,
            showSpecular: showGlassSpecular,
            child: interactiveContent,
          )
        : DecoratedBox(
            key: const ValueKey('miuix-floating-action-button-fill'),
            decoration: ShapeDecoration(
              color: background,
              shape: effectiveShape,
            ),
            child: interactiveContent,
          );
    // Shadow and fill share the exact ShapeBorder. Keeping projection outside
    // the clipped glass prevents both a rectangular halo and clipped blur.
    final button = DecoratedBox(
      key: const ValueKey('miuix-floating-action-button-surface'),
      decoration: ShapeDecoration(
        color: Colors.transparent,
        shape: effectiveShape,
        shadows: safeShadowElevation <= 0
            ? const <BoxShadow>[]
            : <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: .20),
                  blurRadius: safeShadowElevation * 2,
                  offset: Offset(0, safeShadowElevation / 2),
                ),
              ],
      ),
      child: fill,
    );
    return Semantics(button: true, enabled: enabled, child: button);
  }
}
