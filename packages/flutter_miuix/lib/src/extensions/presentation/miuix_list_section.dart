import 'package:flutter/material.dart';

import '../../theme/miuix_semantic_colors.dart';
import '../../theme/miuix_theme.dart';
import '../../widgets/miuix_widgets.dart';

/// Theme colors for [MiuixListSection].
@immutable
class MiuixListSectionColors {
  /// Creates a grouped-list palette.
  const MiuixListSectionColors({
    required this.background,
    required this.title,
    required this.footer,
    required this.divider,
  });

  /// Surface and metadata roles.
  final Color background;
  final Color title;
  final Color footer;
  final Color divider;
}

/// Geometry and color defaults for grouped lists.
abstract final class MiuixListSectionDefaults {
  // HyperOS 4 grouped-list implementation contract:
  // - A section is one information group, not one card per child row.
  // - Children retain caller-owned height, interaction, and semantics.
  // - Optional dividers remain weak, inset, and absent at outer edges.
  // - Title and footer sit outside the shared surface hierarchy.
  // - The settings-group token owns the complete outer corner geometry.
  // - Optional glass samples only behind the group's clipped silhouette.
  // - Content-surface blur and tint remain controlled by global intensity.
  // - Disabling glass resolves the same group to a readable solid surface.
  // - No rectangular shadow or fill is introduced around rounded corners.
  // - Empty sections remain structurally valid and retain optional metadata.
  // - Light and dark palettes resolve every role through semantic colors.
  // - Existing public geometry constants remain available for compatibility.
  // These are project implementation rules rather than unpublished Xiaomi dp.

  /// Continuous outer corner radius.
  static const double cornerRadius = 18;

  /// Horizontal item inset used by separators.
  static const double horizontalInset = 16;

  /// Resolves semantic colors from the active MIUIX theme.
  static MiuixListSectionColors colors(BuildContext context) {
    final semantic = MiuixSemanticColors.of(context);
    return MiuixListSectionColors(
      background: semantic['surfaceVariant'],
      title: semantic['onSurface'],
      footer: semantic['onSurfaceSecondary'],
      divider: semantic['dividerLine'],
    );
  }
}

/// Reusable grouped list container with consistent dividers and metadata.
class MiuixListSection extends StatelessWidget {
  /// Creates a HyperOS 4 grouped list section.
  const MiuixListSection({
    super.key,
    required this.children,
    this.title,
    this.footer,
    this.showDividers = true,
    this.glass = true,
    this.glassBlur,
    this.glassOpacity,
    this.showGlassSpecular = true,
    this.cornerRadius = double.nan,
    this.colors,
  });

  /// Creates the former opaque 18dp grouped-list surface.
  const MiuixListSection.source({
    super.key,
    required this.children,
    this.title,
    this.footer,
    this.showDividers = true,
    this.colors,
  }) : glass = false,
       glassBlur = null,
       glassOpacity = null,
       showGlassSpecular = false,
       cornerRadius = MiuixListSectionDefaults.cornerRadius;

  /// Ordered row widgets.
  final List<Widget> children;

  /// Optional title and footer.
  final String? title;
  final String? footer;

  /// Whether inset dividers separate rows.
  final bool showDividers;

  /// Whether the group participates in the package glass system.
  final bool glass;

  /// Optional content-material and continuous-corner overrides.
  final double? glassBlur;
  final double? glassOpacity;
  final bool showGlassSpecular;
  final double cornerRadius;

  /// Optional palette override.
  final MiuixListSectionColors? colors;

  @override
  Widget build(BuildContext context) {
    final palette = colors ?? MiuixListSectionDefaults.colors(context);
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final radius = cornerRadius.isFinite
        ? cornerRadius.clamp(0.0, double.infinity).toDouble()
        : hyperOs4.settingsGroupCornerRadius;
    final rows = <Widget>[];
    for (var index = 0; index < children.length; index++) {
      if (index > 0 && showDividers) {
        rows.add(
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: MiuixListSectionDefaults.horizontalInset,
            ),
            child: Divider(height: 1, thickness: 1, color: palette.divider),
          ),
        );
      }
      rows.add(children[index]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (title != null)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
            child: Text(
              title!,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: palette.title,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        MiuixSurface(
          key: const ValueKey('miuix-list-section-surface'),
          color: palette.background,
          radius: radius,
          glass: glass,
          glassBlur: glassBlur ?? hyperOs4.contentSurfaceBlur,
          glassOpacity: glassOpacity ?? hyperOs4.contentSurfaceTintOpacity,
          showGlassSpecular: showGlassSpecular,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: rows,
          ),
        ),
        if (footer != null)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 0),
            child: Text(
              footer!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: palette.footer),
            ),
          ),
      ],
    );
  }
}
