import '../../icons/miuix_icon_theme.dart';
import 'package:flutter/material.dart';

import '../../theme/miuix_semantic_colors.dart';
import '../../theme/miuix_theme.dart';
import '../../widgets/miuix_widgets.dart';

/// Common empty-state meanings with suitable default iconography.
enum MiuixEmptyStateType {
  /// A collection contains no items yet.
  empty,

  /// A query produced no matches.
  noResults,

  /// Network content is temporarily unavailable.
  offline,

  /// An operation failed and may be retried.
  error,

  /// Access is intentionally restricted.
  restricted,
}

/// Palette for [MiuixEmptyStateView].
@immutable
class MiuixEmptyStateColors {
  /// Creates an empty-state palette.
  const MiuixEmptyStateColors({
    required this.icon,
    required this.title,
    required this.message,
  });

  /// Icon, title, and explanatory text roles.
  final Color icon;
  final Color title;
  final Color message;
}

/// Standardized empty-state geometry and semantics.
abstract final class MiuixEmptyStateDefaults {
  // HyperOS 4 empty-state implementation contract:
  // - Empty content remains part of the page, not an implicit modal overlay.
  // - The complete composition keeps a readable maximum line width.
  // - Compact mode changes spacing and icon scale without changing semantics.
  // - The title remains the primary announcement for every state category.
  // - Optional explanatory text is merged into the live-region label once.
  // - Recovery actions remain ordinary caller-provided accessible controls.
  // - Glass is opt-in because many empty pages need no additional container.
  // - An enabled glass surface samples only behind its clipped silhouette.
  // - The inline-surface token family owns its blur, tint, and corner radius.
  // - Default tint follows a semantic role and is never fully transparent.
  // - This contrast mask prevents complex scene content from washing out text.
  // - A caller may override tint without bypassing blur or global intensity.
  // - Global glass strength scales the complete material configuration.
  // - Disabling component glass yields a readable semantic solid endpoint.
  // - The surface adds no rectangular backing outside continuous corners.
  // - Centering occurs outside the glass and does not enlarge its painted area.
  // - Default icon selection communicates state without replacing visible text.
  // - Custom icon content inherits the same semantic size and color role.
  // - Light and dark themes resolve all content roles independently.
  // - The live-region switch remains controlled by the public announce option.
  // - No fixed Xiaomi dp or unpublished material constant is claimed here.
  // - Message absence does not leave a redundant semantic punctuation suffix.
  // - Action wrapping keeps each caller-owned control's native hit rectangle.
  // - Text scaling may increase height while the readable width remains capped.
  // - Surface material never changes the order of icon, copy, and actions.
  // - The same component remains valid on Android and resizable Windows views.
  // - Background blur remains a local visual effect, not a system-window claim.
  // - Explicit tint alpha is preserved by the common glass implementation.
  // - Testing can address the glass layer through one deterministic key.
  // These rules preserve content-first hierarchy and readable local material
  // while retaining the existing source-compatible empty-state API.
  //
  // Shared base/view geometry contract:
  // - MiuixEmptyState and MiuixEmptyStateView read the same standard tokens.
  // - A token change therefore cannot move only one of the two public views.
  // - Standard width limits copy without forcing the composition to fill it.
  // - Center remains the visual anchor on both compact and wide windows.
  // - Standard outer padding belongs inside the readable-width constraint.
  // - The standard icon extent applies through IconTheme inheritance.
  // - A caller icon with an explicit size intentionally keeps that explicit size.
  // - The icon-to-title gap is independent from title typography metrics.
  // - The message gap appears only when explanatory copy is present.
  // - The action gap appears only when at least one action is present.
  // - Missing optional slots do not leave empty spacing nodes in the layout.
  // - Base geometry overrides affect only the selected MiuixEmptyState instance.
  // - Theme tokens remain the shared mechanism for application-wide calibration.
  // - The typed view retains its compact 16dp content-padding branch.
  // - Compact mode retains its smaller icon and title/action gaps by design.
  // - Compact message spacing still follows the shared message token.
  // - The typed view may opt into local inline glass without becoming modal.
  // - The base view stays surface-free and content-first by default.
  // - A page may wrap either view in its own surface without double painting.
  // - Neither standard path inserts an opaque full-window background.
  // - Both paths preserve caller-owned action hit targets and focus behavior.
  // - Both paths keep icon, title, message, and action in reading order.
  // - Both paths merge title and message into one announcement label.
  // - A null message never produces trailing punctuation in that label.
  // - The base announce flag controls liveRegion without hiding visible semantics.
  // - The typed announce flag retains the same accessible policy.
  // - Source construction disables announcements unless explicitly requested.
  // - Source construction preserves the former 20dp outer padding.
  // - Source construction preserves the former 52dp inherited icon theme.
  // - Its default inbox icon preserves the former explicit 56dp override.
  // - Source construction preserves the former 10dp icon-to-title gap.
  // - Source construction preserves the former 6dp title-to-message gap.
  // - Source construction preserves the former 10dp gap before one action.
  // - Source construction intentionally retains unconstrained readable width.
  // - Source compatibility does not become the default for new call sites.
  // - The standard constructor is the default HyperOS 4 migration endpoint.
  // - Token defaults are project calibration values, not Xiaomi private constants.
  // - Public documentation identifies that evidence boundary explicitly.
  // - Tests lock every standard default and every retained source measurement.
  // - Tests also verify that both public views consume customized token values.
  // - A deterministic content key exposes the base width constraint to tests.
  // - Deterministic spacing keys distinguish optional vertical rhythm nodes.
  // - The icon-theme key verifies inherited size without inspecting glyph pixels.
  // - Golden review remains necessary for typography and optical centering.
  // - Geometry tests do not by themselves prove pixel-level visual parity.
  // - Android review must include font scaling and gesture-navigation insets.
  // - Windows review must include narrow resizing and keyboard focus traversal.
  // - Long localized copy may grow vertically but remains width constrained.
  // - Caller actions may wrap only in the typed two-action view.
  // - The base single action retains its own intrinsic layout behavior.
  // - Neither path truncates title or explanatory copy by default.
  // - Semantic color roles resolve independently for light and dark themes.
  // - Changing glass strength cannot alter any empty-state geometry token.
  // - Reduced-motion policy has no layout effect because empty states are static.
  // - Future animated illustrations must add an explicit reduced-motion branch.
  // - Future geometry changes must update base, typed view, docs, and tests together.

  /// Largest readable message width.
  static const double maximumWidth = 360;

  /// Default icon size.
  static const double iconSize = 64;

  /// Resolves theme-aware colors.
  static MiuixEmptyStateColors colors(BuildContext context) {
    final semantic = MiuixSemanticColors.of(context);
    return MiuixEmptyStateColors(
      icon: semantic['onSurfaceContainerVariant'],
      title: semantic['onSurface'],
      message: semantic['onSurfaceSecondary'],
    );
  }

  /// Resolves a familiar icon without requiring Material layout primitives.
  static IconData icon(MiuixEmptyStateType type) => switch (type) {
    MiuixEmptyStateType.empty => Icons.inbox_outlined,
    MiuixEmptyStateType.noResults => Icons.search_off_rounded,
    MiuixEmptyStateType.offline => Icons.cloud_off_outlined,
    MiuixEmptyStateType.error => Icons.error_outline_rounded,
    MiuixEmptyStateType.restricted => Icons.lock_outline_rounded,
  };
}

/// Standard package-level empty-state view.
///
/// [MiuixEmptyState] remains source-compatible for existing applications;
/// this extension adds explicit state types, semantic announcement, and a
/// secondary action while retaining the same visual hierarchy.
class MiuixEmptyStateView extends StatelessWidget {
  /// Creates a standardized empty state.
  const MiuixEmptyStateView({
    super.key,
    required this.title,
    this.message,
    this.type = MiuixEmptyStateType.empty,
    this.icon,
    this.primaryAction,
    this.secondaryAction,
    this.colors,
    this.compact = false,
    this.glass = false,
    this.glassColor,
    this.announce = true,
  });

  /// User-facing summary and optional explanation.
  final String title;
  final String? message;

  /// Semantic state used by the default icon.
  final MiuixEmptyStateType type;

  /// Optional replacement icon widget.
  final Widget? icon;

  /// Primary and optional secondary recovery actions.
  final Widget? primaryAction;
  final Widget? secondaryAction;

  /// Optional theme override.
  final MiuixEmptyStateColors? colors;

  /// Dense layout, optional glass container, and live-region policy.
  final bool compact;
  final bool glass;

  /// Optional tint for the clipped glass surface.
  ///
  /// Null follows the current semantic secondary-container role so the
  /// material retains readable contrast over changing scene content.
  final Color? glassColor;
  final bool announce;

  @override
  Widget build(BuildContext context) {
    final palette = colors ?? MiuixEmptyStateDefaults.colors(context);
    final semantic = MiuixSemanticColors.of(context);
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final content = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: hyperOs4.emptyStateMaximumWidth),
      child: Padding(
        padding: EdgeInsets.all(compact ? 16 : hyperOs4.emptyStatePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconTheme(
              data: IconThemeData(
                color: palette.icon,
                size: compact ? 48 : hyperOs4.emptyStateIconSize,
              ),
              child: icon ?? MiuixThemedIcon(MiuixEmptyStateDefaults.icon(type)),
            ),
            SizedBox(height: compact ? 10 : hyperOs4.emptyStateTitleSpacing),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: palette.title,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (message != null) ...<Widget>[
              SizedBox(height: hyperOs4.emptyStateMessageSpacing),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: palette.message,
                  height: 1.35,
                ),
              ),
            ],
            if (primaryAction != null || secondaryAction != null) ...<Widget>[
              SizedBox(height: compact ? 14 : hyperOs4.emptyStateActionSpacing),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: <Widget>[?secondaryAction, ?primaryAction],
              ),
            ],
          ],
        ),
      ),
    );
    return Semantics(
      container: true,
      liveRegion: announce,
      label: message == null ? title : '$title. $message',
      child: Center(
        child: glass
            ? MiuixSurface(
                key: const ValueKey('miuix-empty-state-glass'),
                radius: hyperOs4.inlineSurfaceCornerRadius,
                color: glassColor ?? semantic['secondaryContainer'],
                glass: true,
                glassBlur: hyperOs4.inlineSurfaceBlur,
                glassOpacity: hyperOs4.inlineSurfaceTintOpacity,
                child: content,
              )
            : content,
      ),
    );
  }
}
