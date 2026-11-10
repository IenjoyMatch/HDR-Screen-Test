part of '../miuix_widgets.dart';

/// Public defaults from the current MIUIX `SurfaceDefaults` object.
abstract final class MiuixSurfaceDefaults {
  /// Source default shape: an unrounded rectangle.
  static const ShapeBorder shape = RoundedRectangleBorder();

  /// Source default shadow elevation in logical pixels.
  static const double shadowElevation = 0;
}

/// Base surface widget with the MIUIX v1.0.9 layout and interaction order.
///
/// The source has non-clickable and clickable overloads. A non-null [onTap] or
/// [onLongPress] selects the interactive Flutter branch; [enabled] then
/// controls whether that branch installs pointer actions and indication.
class MiuixSurface extends StatelessWidget {
  /// Creates a MIUIX surface.
  const MiuixSurface({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.contentColor,
    this.shape,
    this.radius,
    this.border,
    this.shadowElevation = MiuixSurfaceDefaults.shadowElevation,
    this.glass = false,
    this.glassBlur,
    this.glassOpacity,
    this.glassOptics,
    this.showGlassSpecular = true,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.feedbackType = MiuixPressFeedbackType.none,
    this.holdDown = false,
    this.showIndication = true,
    this.indication = const MiuixIndication(),
    this.interactionSource,
  });

  /// Creates a surface with the current upstream parameter defaults.
  ///
  /// The ordinary constructor retains the package's HyperOS 4 shape routing;
  /// this source form explicitly selects MIUIX's rectangular, non-glass,
  /// zero-elevation primitive while preserving optional click semantics.
  factory MiuixSurface.source({
    Key? key,
    required Widget content,
    ShapeBorder shape = MiuixSurfaceDefaults.shape,
    Color? color,
    Color? contentColor,
    BorderSide? border,
    double shadowElevation = MiuixSurfaceDefaults.shadowElevation,
    VoidCallback? onClick,
    bool enabled = true,
    MiuixInteractionSource? interactionSource,
    MiuixIndication? indication = const MiuixIndication(),
  }) {
    return MiuixSurface(
      key: key,
      shape: shape,
      color: color,
      contentColor: contentColor,
      border: border,
      shadowElevation: shadowElevation,
      glass: false,
      showGlassSpecular: false,
      onTap: onClick,
      enabled: enabled,
      showIndication: indication != null,
      indication: indication,
      interactionSource: interactionSource,
      child: content,
    );
  }

  /// Surface content.
  final Widget child;

  /// Optional source-external content padding.
  ///
  /// This is a Flutter package extension. The upstream primitive expects
  /// callers to put padding in [child].
  final EdgeInsetsGeometry? padding;

  /// Optional caller-modifier margin outside paint and interaction.
  ///
  /// This is a Flutter package extension representing an outer Compose
  /// padding modifier. Its empty area must not become clickable.
  final EdgeInsetsGeometry? margin;

  /// Container color, defaulting to the MIUIX surface token.
  final Color? color;

  /// Locally inherited Text/Icon color.
  final Color? contentColor;

  /// Exact source shape.
  ///
  /// When supplied this takes precedence over the radius compatibility API.
  final ShapeBorder? shape;

  /// Compatibility radius used to create the current global MIUIX shape.
  final double? radius;

  /// Optional border stroke.
  final BorderSide? border;

  /// Source shadow elevation in logical pixels.
  final double shadowElevation;

  /// Enables the package's optional glass rendering extension.
  final bool glass;

  /// Optional role-specific backdrop sigma for this glass surface.
  final double? glassBlur;

  /// Optional role-specific standard tint opacity for this glass surface.
  final double? glassOpacity;

  /// Optional role-specific blur, tint, and optical-edge progression.
  final MiuixGlassOptics? glassOptics;

  /// Whether this glass surface paints its clipped edge reflection.
  final bool showGlassSpecular;

  /// Optional tap callback selecting the clickable source overload.
  final VoidCallback? onTap;

  /// Optional long-press compatibility callback.
  final VoidCallback? onLongPress;

  /// Whether an interactive surface accepts input.
  final bool enabled;

  /// Optional package feedback extension.
  ///
  /// The source default remains [MiuixPressFeedbackType.none].
  final MiuixPressFeedbackType feedbackType;

  /// Whether an existing interactive branch remains visually held.
  ///
  /// This mirrors the source HoldDownInteraction path used while a child
  /// dialog or popup is still visible. It does not by itself select the
  /// clickable overload when both callbacks are null.
  final bool holdDown;

  /// Whether the interactive overload installs LocalIndication.
  final bool showIndication;

  /// Nullable source indication; null disables the clickable overlay.
  final MiuixIndication? indication;

  /// Optional externally observable source interaction channel.
  final MiuixInteractionSource? interactionSource;

  /// Resolves the compatibility radius through the global G2 preference.
  ShapeBorder _resolveShape(BuildContext context) {
    if (shape != null) return shape!;
    final requestedRadius = radius ?? 0;
    final effectiveRadius = requestedRadius.isFinite
        ? math.max(0.0, requestedRadius)
        : 0.0;
    final corners = BorderRadius.circular(effectiveRadius);
    return MiuixTheme.of(context).enableSquircle
        ? MiuixSquircleBorder(borderRadius: corners)
        : RoundedRectangleBorder(borderRadius: corners);
  }

  /// Publishes the upstream LocalContentColor equivalent.
  Widget _withContentColor({
    required Widget content,
    required Color foreground,
  }) {
    return _MiuixContentColor(
      color: foreground,
      child: DefaultTextStyle.merge(
        style: TextStyle(color: foreground),
        child: IconTheme.merge(
          data: IconThemeData(color: foreground),
          child: content,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final miuixTheme = MiuixTheme.of(context);
    final hyperOs4 = miuixTheme.hyperOs4;
    final requestedRadius = radius ?? 0;
    final safeRadius = requestedRadius.isFinite
        ? math.max(0.0, requestedRadius)
        : 0.0;
    final effectiveShape = _resolveShape(context);
    final surfaceColor = color ?? scheme.surface;
    final foreground = contentColor ?? scheme.onSurface;
    final effectivePadding = padding == null
        ? EdgeInsets.zero
        : _miuixRoundedInsets(context, padding!);
    final effectiveMargin = margin == null
        ? null
        : _miuixRoundedInsets(context, margin!);
    final safeElevation = shadowElevation.isFinite
        ? math.max(0.0, shadowElevation)
        : 0.0;

    // Surface.kt lets the Box propagate incoming minimum constraints. Flutter
    // DecoratedBox and Padding already forward those constraints, so no
    // Material container or minimum interactive size belongs in this branch.
    final content = _withContentColor(
      foreground: foreground,
      content: Padding(padding: effectivePadding, child: child),
    );
    final usesStaticSquircle = !glass && shape == null && radius != null;
    final fillAndContent = glass
        ? MiuixGlass(
            radius: safeRadius,
            padding: EdgeInsets.zero,
            blur: glassBlur ?? hyperOs4.contentSurfaceBlur,
            opacity: glassOpacity ?? hyperOs4.contentSurfaceTintOpacity,
            color: surfaceColor,
            optics: glassOptics,
            showSpecular: showGlassSpecular,
            // The radius compatibility path lets MiuixGlass own its existing
            // border shader/path. Arbitrary shapes use the generic painter
            // below because the glass primitive cannot represent them.
            border: shape == null ? border : null,
            child: content,
          )
        : ColoredBox(color: surfaceColor, child: content);

    Widget staticSquircle(Widget child) => MiuixSquircleSurface(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(safeRadius),
      enabled: miuixTheme.enableSquircle,
      child: child,
    );

    // Surface.kt has exactly two overloads: the ordinary branch and a branch
    // that requires a click callback. `holdDown` is only an interaction state
    // for an already-interactive compatibility branch; treating it as an
    // action creates a focusable, hoverable empty button that source does not
    // have. Card owns its separate callback-free held-motion adapter.
    final interactive = onTap != null || onLongPress != null;
    Widget result;
    if (!interactive) {
      // MiuixGlass already owns the same global G2 clip for its radius-based
      // compatibility path. Re-clipping that layer darkens translucent corner
      // pixels. An explicit arbitrary shape still requires this outer clip.
      final clippedSurface = usesStaticSquircle
          ? staticSquircle(content)
          : glass && shape == null
          ? fillAndContent
          : _MiuixSurfaceClip(
              clipper: ShapeBorderClipper(shape: effectiveShape),
              child: fillAndContent,
            );
      // Compose sets mergeDescendants=false and marks an ordinary Surface as
      // an accessibility traversal group. A container with explicit children
      // is Flutter's nearest public semantics representation of that contract.
      result = Semantics(
        container: true,
        explicitChildNodes: true,
        child: clippedSurface,
      );
    } else {
      final interactionEnabled = enabled;
      final pressable = MiuixPressable(
        onTap: interactionEnabled ? onTap : null,
        onLongPress: interactionEnabled ? onLongPress : null,
        feedbackType: feedbackType,
        holdDown: holdDown,
        showIndication: interactionEnabled && showIndication,
        indication: indication,
        interactionSource: interactionSource,
        // LocalIndication is clipped by the same exact Shape passed to
        // Surface. Using borderRadius here silently reverted G2 to an RRect.
        shape: effectiveShape,
        // MiuixGlass already clips its backdrop filter to this silhouette.
        // The pressable clips only its indication instead of antialiasing the
        // complete translucent edge a second time.
        contentAlreadyClipped: glass,
        // Card.kt and the other radius-based static surfaces use the baked
        // SDF for fill, content, and indication as one layer. The source shape
        // remains available above for shadows, borders, and API inspection.
        contentClipBuilder: usesStaticSquircle ? staticSquircle : null,
        // This is the only clip in the interactive branch. Clipping both this
        // child and MiuixPressable would antialias the same edge twice.
        child: usesStaticSquircle ? content : fillAndContent,
      );
      result = Semantics(enabled: interactionEnabled, child: pressable);
    }

    // Modifier.border precedes clip/background/clickable and paints after its
    // child. Keep it outside the single interaction clip so the indication
    // cannot wash over the source stroke.
    if (border != null &&
        border!.style != BorderStyle.none &&
        !(glass && shape == null)) {
      result = CustomPaint(
        foregroundPainter: _MiuixSurfaceBorderPainter(
          shape: effectiveShape,
          side: border!,
          textDirection: Directionality.of(context),
        ),
        child: result,
      );
    }
    // Compose creates a graphics layer only for positive elevation. This
    // transparent outer decoration carries the shadow without putting it
    // inside the shape clip used by content and indication.
    if (safeElevation > 0) {
      result = DecoratedBox(
        decoration: ShapeDecoration(
          color: Colors.transparent,
          shape: effectiveShape,
          shadows: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: .20),
              blurRadius: safeElevation * 2,
              offset: Offset(0, safeElevation / 2),
            ),
          ],
        ),
        child: result,
      );
    }
    // The caller's outer padding/margin precedes `.surface().clickable()` in
    // the Compose modifier chain. Keep it outside MiuixPressable so taps in
    // that transparent area do not activate the surface.
    return Container(
      margin: effectiveMargin,
      child: MiuixSurfaceTheme.wrapSurface(
        context,
        effectiveShape,
        surfaceColor,
        result,
      ),
    );
  }
}

/// Paints Compose's separate BorderStroke inside any Flutter ShapeBorder.
///
/// ShapeBorder has no general copyWith(side:) API. Painting a doubled stroke
/// while clipping it to the outer path produces the same fully-inside border
/// and works for caller-defined shapes as well as the built-in G2 outline.
class _MiuixSurfaceBorderPainter extends CustomPainter {
  const _MiuixSurfaceBorderPainter({
    required this.shape,
    required this.side,
    required this.textDirection,
  });

  final ShapeBorder shape;
  final BorderSide side;
  final TextDirection textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final path = shape.getOuterPath(rect, textDirection: textDirection);
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
  bool shouldRepaint(covariant _MiuixSurfaceBorderPainter oldDelegate) {
    return oldDelegate.shape != shape ||
        oldDelegate.side != side ||
        oldDelegate.textDirection != textDirection;
  }
}
