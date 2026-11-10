part of '../miuix_widgets.dart';

/// Source values used by horizontal and vertical MIUIX dividers.
abstract final class MiuixDividerDefaults {
  /// Default line thickness in logical pixels.
  static const double thickness = .75;

  /// Resolves the active source `dividerLine` semantic color.
  static Color dividerColor(BuildContext context) {
    return MiuixSemanticColors.of(context)['dividerLine'];
  }
}

/// Horizontal divider matching MIUIX's measured 0.75dp canvas line.
///
/// This original package name is retained as an alias-like base so existing
/// applications keep compiling. [MiuixHorizontalDivider] exposes the exact
/// source component name.
class MiuixDivider extends StatelessWidget {
  /// Creates a horizontal divider.
  const MiuixDivider({
    super.key,
    this.indent = 0,
    this.endIndent = 0,
    this.thickness = MiuixDividerDefaults.thickness,
    this.color,
  });

  /// Leading inset compatibility adapter.
  final double indent;

  /// Trailing inset compatibility adapter.
  final double endIndent;

  /// Measured height and painted stroke width.
  final double thickness;

  /// Optional line color; defaults to MIUIX's semantic divider token.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final safeThickness = thickness.isFinite && thickness >= 0
        ? thickness
        : MiuixDividerDefaults.thickness;
    final safeIndent = indent.isFinite ? math.max(0.0, indent) : 0.0;
    final safeEndIndent = endIndent.isFinite ? math.max(0.0, endIndent) : 0.0;
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: safeIndent,
        end: safeEndIndent,
      ),
      child: SizedBox(
        width: double.infinity,
        height: safeThickness,
        child: CustomPaint(
          painter: _MiuixDividerPainter(
            color: color ?? MiuixDividerDefaults.dividerColor(context),
            thickness: safeThickness,
            devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
          ),
        ),
      ),
    );
  }
}

/// Source-named horizontal divider.
class MiuixHorizontalDivider extends MiuixDivider {
  /// Creates a horizontal divider.
  const MiuixHorizontalDivider({
    super.key,
    super.indent,
    super.endIndent,
    super.thickness,
    super.color,
  });
}

/// Vertical divider matching MIUIX's measured 0.75dp canvas line.
class MiuixVerticalDivider extends StatelessWidget {
  /// Creates a vertical divider.
  ///
  /// [thickness] is the source name. [width] remains a compatibility alias;
  /// when both are provided the source-named [thickness] takes precedence.
  const MiuixVerticalDivider({
    super.key,
    this.indent = 0,
    this.endIndent = 0,
    double? thickness,
    double? width,
    this.color,
  }) : thickness = thickness ?? width ?? MiuixDividerDefaults.thickness,
       width = thickness ?? width ?? MiuixDividerDefaults.thickness;

  /// Top inset compatibility adapter.
  final double indent;

  /// Bottom inset compatibility adapter.
  final double endIndent;

  /// Source-named line thickness.
  final double thickness;

  /// Compatibility alias for [thickness].
  final double width;

  /// Optional line color; defaults to MIUIX's semantic divider token.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final safeThickness = thickness.isFinite && thickness >= 0
        ? thickness
        : MiuixDividerDefaults.thickness;
    final safeIndent = indent.isFinite ? math.max(0.0, indent) : 0.0;
    final safeEndIndent = endIndent.isFinite ? math.max(0.0, endIndent) : 0.0;
    return Padding(
      padding: EdgeInsets.only(top: safeIndent, bottom: safeEndIndent),
      child: SizedBox(
        width: safeThickness,
        height: double.infinity,
        child: CustomPaint(
          painter: _MiuixDividerPainter(
            color: color ?? MiuixDividerDefaults.dividerColor(context),
            thickness: safeThickness,
            devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
            vertical: true,
          ),
        ),
      ),
    );
  }
}

/// Paints the source line centered in its own measured extent.
///
/// Compose's canvas preserves fractional coverage on the final physical pixel.
/// Flutter's renderer can rasterize the same short line as two opaque pixels,
/// so the painter resolves full and fractional pixel coverage explicitly.
///
/// Measurement contract:
///
/// * [thickness] remains a logical-pixel value in the public widget API.
/// * The render box retains that exact logical width or height.
/// * The value is multiplied by [devicePixelRatio] only during painting.
/// * Whole physical pixels receive the unmodified semantic line color.
/// * A remaining physical fraction is represented by color alpha.
/// * The final partial pixel is one device pixel wide before compositing.
/// * Layout never rounds 0.75dp up to a full logical pixel.
/// * Navigation therefore measures its divider independently from its row.
///
/// Compositing contract:
///
/// * The fractional pixel blends with the surface already behind the painter.
/// * Alpha scaling preserves custom translucent divider colors as well.
/// * The original alpha is multiplied rather than replaced by coverage.
/// * Antialiasing is disabled because coverage is already computed explicitly.
/// * Opaque full pixels and fractional pixels use separate draw operations.
/// * No Material divider opacity is applied to the MIUIX semantic color.
/// * Light and dark schemes therefore retain their exact upstream tokens.
///
/// Density examples:
///
/// * At 1x, 0.75dp becomes one pixel with 75 percent color coverage.
/// * At 2x, 0.75dp becomes one full pixel plus one half-covered pixel.
/// * At 2.625x, it becomes one full pixel plus 0.96875 pixel coverage.
/// * Dark #393939 consequently blends to #373737 on that final black pixel.
/// * At 3x, it becomes two full pixels plus one quarter-covered pixel.
/// * Integer-thickness products have no fractional painting operation.
///
/// Axis contract:
///
/// * Horizontal dividers consume height and paint from their top edge.
/// * Vertical dividers consume width and paint from their leading edge.
/// * Insets are applied outside the painter by the corresponding widget.
/// * RTL changes horizontal inset direction but never line coverage.
/// * A zero thickness produces no painted pixels and retains zero extent.
/// * Invalid thickness and density inputs are normalized by their owners.
///
/// This explicit model is intentionally shared by both divider directions.
/// Keeping it in one painter prevents navigation, popup, and standalone lines
/// from acquiring different raster behavior on the same physical display.
class _MiuixDividerPainter extends CustomPainter {
  const _MiuixDividerPainter({
    required this.color,
    required this.thickness,
    required this.devicePixelRatio,
    this.vertical = false,
  });

  /// Semantic line color before fractional coverage is applied.
  final Color color;

  /// Logical source thickness.
  final double thickness;

  /// Active physical pixels per logical pixel.
  final double devicePixelRatio;

  /// Whether the line follows the vertical axis.
  final bool vertical;

  @override
  void paint(Canvas canvas, Size size) {
    final ratio = devicePixelRatio.isFinite && devicePixelRatio > 0
        ? devicePixelRatio
        : 1.0;
    final physicalThickness = thickness * ratio;
    final fullPixels = physicalThickness.floor();
    final remainder = physicalThickness - fullPixels;
    final fullExtent = fullPixels / ratio;
    final onePixel = 1 / ratio;
    final paint = Paint()
      ..color = color
      ..isAntiAlias = false;
    if (vertical) {
      if (fullPixels > 0) {
        canvas.drawRect(Rect.fromLTWH(0, 0, fullExtent, size.height), paint);
      }
      if (remainder > 0) {
        paint.color = color.withValues(alpha: color.a * remainder);
        canvas.drawRect(
          Rect.fromLTWH(fullExtent, 0, onePixel, size.height),
          paint,
        );
      }
    } else {
      if (fullPixels > 0) {
        canvas.drawRect(Rect.fromLTWH(0, 0, size.width, fullExtent), paint);
      }
      if (remainder > 0) {
        paint.color = color.withValues(alpha: color.a * remainder);
        canvas.drawRect(
          Rect.fromLTWH(0, fullExtent, size.width, onePixel),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MiuixDividerPainter oldDelegate) {
    return color != oldDelegate.color ||
        thickness != oldDelegate.thickness ||
        devicePixelRatio != oldDelegate.devicePixelRatio ||
        vertical != oldDelegate.vertical;
  }
}
