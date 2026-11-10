import '../../icons/miuix_icon_theme.dart';
import 'package:flutter/material.dart';

import '../../theme/miuix_semantic_colors.dart';
import '../../theme/miuix_theme.dart';
import '../miuix_extension_icons.dart';

/// Visual progress state for a timeline item.
enum MiuixTimelineItemState {
  /// A completed milestone.
  completed,

  /// The current active milestone.
  current,

  /// A future milestone.
  upcoming,

  /// A milestone that ended in an error.
  error,
}

/// Layout direction for [MiuixTimeline].
enum MiuixTimelineOrientation {
  /// Items flow from top to bottom.
  vertical,

  /// Items flow in the reading direction and may scroll horizontally.
  horizontal,
}

/// Immutable content model for one timeline milestone.
@immutable
class MiuixTimelineItem {
  /// Creates a timeline item.
  const MiuixTimelineItem({
    required this.title,
    this.subtitle,
    this.content,
    this.icon,
    this.state = MiuixTimelineItemState.upcoming,
  });

  /// Primary and optional secondary labels.
  final String title;
  final String? subtitle;

  /// Optional detailed body and marker replacement.
  final Widget? content;
  final Widget? icon;

  /// Progress state controlling marker and connector colors.
  final MiuixTimelineItemState state;
}

/// Theme colors for [MiuixTimeline].
@immutable
class MiuixTimelineColors {
  /// Creates a complete timeline palette.
  const MiuixTimelineColors({
    required this.active,
    required this.completed,
    required this.upcoming,
    required this.error,
    required this.foreground,
    required this.secondaryForeground,
  });

  /// State and text roles.
  final Color active;
  final Color completed;
  final Color upcoming;
  final Color error;
  final Color foreground;
  final Color secondaryForeground;
}

/// Geometry and palette defaults for timelines.
abstract final class MiuixTimelineDefaults {
  // HyperOS 4 timeline implementation contract:
  // - Authored item order remains the authoritative spatial sequence.
  // - Vertical and horizontal layouts share state color and marker behavior.
  // - Each public list index is the stable transition coordinate for a rebuild.
  // - Marker and adjacent connector color sample one shared animation value.
  // - Completed, current, upcoming, and error states use semantic color roles.
  // - State icon replacement combines opacity and scale around the same center.
  // - Current-title weight changes on the same process-state clock.
  // - Optional custom marker content participates in the identical transition.
  // - Marker extent and connector thickness remain stable during interpolation.
  // - A transition never inserts a rectangular marker background or shadow.
  // - Reduced motion replaces every in-flight state channel in one rebuild.
  // - Initial construction begins at the authored endpoint without entry noise.
  // - Reordering items is an application model change, not inferred identity.
  // - Horizontal content follows reading direction and retains local scrolling.
  // - Vertical shrink-wrap mode does not inherit route safe-area list padding.
  // - Non-shrink-wrap mode retains ordinary ListView ownership and physics.
  // - Titles, subtitles, and detail content preserve their visible hierarchy.
  // - A future item stays legible even when its marker uses a low-emphasis fill.
  // - Error state remains distinct from selection or theme-accent state.
  // - Animation changes presentation only; it never mutates authored item data.
  // - The process-state duration is project-calibrated and theme-overridable.
  // - This component does not pretend to implement system-level live islands.
  // - Connector layout never extends beyond the first or final authored item.
  // - Marker icon color remains readable throughout background interpolation.
  // - Switch-out content stays clipped to the marker's stable circular bounds.
  // - Long horizontal timelines remain locally scrollable instead of shrinking.
  // - Empty item collections build an empty, valid scroll composition.
  // - Theme changes retarget visible state without altering public models.
  // - Rebuild-time interpolation remains deterministic in widget tests.
  // - Every animated channel honors the same ambient MediaQuery policy.
  // - List semantics continue to expose visible title and supporting content.
  // - Process motion does not add focusable nodes or pointer recognizers.
  // - Marker transitions remain passive and cannot intercept list scrolling.
  // - Item detail widgets retain caller-owned state across color animation.
  // - Directionality affects layout without reversing authored process meaning.
  // - Text overflow behavior remains the responsibility of caller constraints.
  // - Connector paint uses ordinary semantic color interpolation, not opacity.
  // - The transition ends at exact theme colors without residual blending.
  // - Runtime motion policy can change independently of item state changes.
  // - Future identity APIs must remain additive and source compatible.
  // These constraints make state progress spatially continuous without
  // claiming unpublished Xiaomi marker geometry or timing constants.

  /// Marker diameter and connector thickness.
  static const double markerExtent = 24;
  static const double connectorWidth = 3;

  /// Width of one horizontal milestone.
  static const double horizontalItemWidth = 184;

  /// Resolves semantic colors for the current theme.
  static MiuixTimelineColors colors(BuildContext context) {
    final semantic = MiuixSemanticColors.of(context);
    return MiuixTimelineColors(
      active: semantic['primary'],
      completed: semantic['primary'],
      upcoming: semantic['surfaceContainerHigh'],
      error: semantic['error'],
      foreground: semantic['onSurface'],
      secondaryForeground: semantic['onSurfaceSecondary'],
    );
  }
}

/// Structured vertical or horizontal event timeline.
class MiuixTimeline extends StatelessWidget {
  // Public geometry contract:
  // - NaN is an internal sentinel for a theme-owned calibration value.
  // - Every finite caller value remains an explicit geometry override.
  // - Negative explicit values are sanitized before reaching RenderBox.
  // - Marker extent changes the circle only, not its semantic milestone role.
  // - Connector width applies equally to vertical width and horizontal height.
  // - Horizontal item width defines scrolling cadence, not viewport width.
  // - Source construction stores finite legacy values and bypasses new tokens.
  // - Geometry changes never alter authored item state or ordering.
  // - Theme changes can rebuild geometry without recreating caller item models.
  // - Empty timelines remain valid for every calibrated geometry combination.
  // - Explicit dimensions are logical pixels and retain Flutter scaling rules.
  // - Icon optical size stays independent from the outer marker calibration.
  // - Text spacing stays stable while marker and connector sizes are calibrated.
  // - No geometry value is described as official Xiaomi dp without evidence.

  /// Creates a timeline.
  const MiuixTimeline({
    super.key,
    required this.items,
    this.orientation = MiuixTimelineOrientation.vertical,
    this.colors,
    this.shrinkWrap = true,
    this.markerExtent = double.nan,
    this.connectorWidth = double.nan,
    this.horizontalItemWidth = double.nan,
  });

  /// Creates a timeline with the former fixed 24/3/184dp geometry.
  const MiuixTimeline.source({
    super.key,
    required this.items,
    this.orientation = MiuixTimelineOrientation.vertical,
    this.colors,
    this.shrinkWrap = true,
  }) : markerExtent = MiuixTimelineDefaults.markerExtent,
       connectorWidth = MiuixTimelineDefaults.connectorWidth,
       horizontalItemWidth = MiuixTimelineDefaults.horizontalItemWidth;

  /// Ordered milestone models.
  final List<MiuixTimelineItem> items;

  /// Layout direction.
  final MiuixTimelineOrientation orientation;

  /// Optional palette override.
  final MiuixTimelineColors? colors;

  /// Whether the vertical list adopts its content height.
  final bool shrinkWrap;

  /// Marker, connector, and horizontal-item geometry overrides.
  final double markerExtent;
  final double connectorWidth;
  final double horizontalItemWidth;

  Color _stateColor(MiuixTimelineColors colors, MiuixTimelineItemState state) =>
      switch (state) {
        MiuixTimelineItemState.completed => colors.completed,
        MiuixTimelineItemState.current => colors.active,
        MiuixTimelineItemState.upcoming => colors.upcoming,
        MiuixTimelineItemState.error => colors.error,
      };

  Widget _marker(
    BuildContext context,
    int index,
    MiuixTimelineItem item,
    MiuixTimelineColors colors,
    Color background,
    Duration motion,
    bool reduceMotion,
    double resolvedMarkerExtent,
  ) {
    final defaultIcon = switch (item.state) {
      MiuixTimelineItemState.completed => MiuixExtensionGlyphs.confirm,
      MiuixTimelineItemState.current => Icons.circle,
      MiuixTimelineItemState.upcoming => Icons.circle_outlined,
      MiuixTimelineItemState.error => MiuixExtensionGlyphs.close,
    };
    return Container(
      key: ValueKey<Object>(('miuix-timeline-marker', index)),
      width: resolvedMarkerExtent,
      height: resolvedMarkerExtent,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: AnimatedSwitcher(
        key: ValueKey<Object>(('miuix-timeline-marker-icon', reduceMotion)),
        duration: reduceMotion ? Duration.zero : motion,
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: .82, end: 1).animate(animation),
            child: child,
          ),
        ),
        child: IconTheme(
          key: ValueKey<MiuixTimelineItemState>(item.state),
          data: IconThemeData(
            color: item.state == MiuixTimelineItemState.upcoming
                ? colors.secondaryForeground
                : Colors.white,
            size: 15,
          ),
          child: item.icon ?? MiuixThemedIcon(defaultIcon),
        ),
      ),
    );
  }

  Widget _textBlock(
    BuildContext context,
    MiuixTimelineItem item,
    MiuixTimelineColors colors,
    Duration motion,
    bool reduceMotion,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AnimatedDefaultTextStyle(
          key: ValueKey<Object>(('miuix-timeline-title', reduceMotion)),
          duration: reduceMotion ? Duration.zero : motion,
          curve: Curves.easeOutCubic,
          style: (Theme.of(context).textTheme.titleSmall ?? const TextStyle())
              .copyWith(
                color: colors.foreground,
                fontWeight: item.state == MiuixTimelineItemState.current
                    ? FontWeight.w600
                    : null,
              ),
          child: Text(item.title),
        ),
        if (item.subtitle != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              item.subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.secondaryForeground,
              ),
            ),
          ),
        if (item.content != null)
          Padding(padding: const EdgeInsets.only(top: 8), child: item.content!),
      ],
    );
  }

  Widget _verticalItem(
    BuildContext context,
    int index,
    MiuixTimelineColors colors,
    Color lineColor,
    Duration motion,
    bool reduceMotion,
    double resolvedMarkerExtent,
    double resolvedConnectorWidth,
  ) {
    // Vertical composition contract:
    // - The first item has no incoming connector above its marker.
    // - The final item has no outgoing connector below its marker.
    // - Intermediate connectors meet the marker through stable expanded lanes.
    // - Intrinsic height lets the connector follow caller-owned detail content.
    // - The marker column remains distinct from the flexible text column.
    // - Detail content expands row height without moving the marker center.
    // - Connector tint is the same interpolated state sample as the marker.
    // - Nested ListView padding remains zero inside already-inset pages.
    // - Shrink-wrap policy changes scrolling ownership, not milestone layout.
    // - Passive rows introduce no gesture recognizer or focus target.
    // - Directionality affects the text lane without reversing item chronology.
    // - Semantic text remains available throughout presentation interpolation.
    final item = items[index];
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            width: 32,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: index == 0
                      ? const SizedBox.shrink()
                      : Container(
                          key: ValueKey<Object>((
                            'miuix-timeline-connector-before',
                            index,
                          )),
                          width: resolvedConnectorWidth,
                          color: lineColor,
                        ),
                ),
                _marker(
                  context,
                  index,
                  item,
                  colors,
                  lineColor,
                  motion,
                  reduceMotion,
                  resolvedMarkerExtent,
                ),
                Expanded(
                  child: index == items.length - 1
                      ? const SizedBox.shrink()
                      : Container(
                          key: ValueKey<Object>((
                            'miuix-timeline-connector-after',
                            index,
                          )),
                          width: resolvedConnectorWidth,
                          color: lineColor,
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 20),
              child: _textBlock(context, item, colors, motion, reduceMotion),
            ),
          ),
        ],
      ),
    );
  }

  Widget _horizontalItem(
    BuildContext context,
    int index,
    MiuixTimelineColors colors,
    Color lineColor,
    Duration motion,
    bool reduceMotion,
    double resolvedMarkerExtent,
    double resolvedConnectorWidth,
    double resolvedHorizontalItemWidth,
  ) {
    // Horizontal composition contract:
    // - Every item owns one equal theme-calibrated scrolling segment.
    // - Incoming and outgoing connectors split the segment around the marker.
    // - The first and final blank connector lanes preserve marker alignment.
    // - Text remains inside directional segment padding below the marker row.
    // - Long timelines scroll locally instead of compressing milestone content.
    // - Connector thickness is identical to the vertical orientation value.
    // - Marker state and title emphasis use the same animation endpoint.
    // - Reduced motion rebuilds exact colors before the next rendered frame.
    // - Custom content keeps caller state while the surrounding tint changes.
    // - The local horizontal viewport never becomes a primary page controller.
    // - Segment width changes do not modify public item identity or ordering.
    // - No transparent rectangular surface is added around circular markers.
    final item = items[index];
    return SizedBox(
      key: ValueKey<Object>(('miuix-timeline-item', index)),
      width: resolvedHorizontalItemWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: index == 0
                    ? const SizedBox.shrink()
                    : Container(
                        key: ValueKey<Object>((
                          'miuix-timeline-connector-before',
                          index,
                        )),
                        height: resolvedConnectorWidth,
                        color: lineColor,
                      ),
              ),
              _marker(
                context,
                index,
                item,
                colors,
                lineColor,
                motion,
                reduceMotion,
                resolvedMarkerExtent,
              ),
              Expanded(
                child: index == items.length - 1
                    ? const SizedBox.shrink()
                    : Container(
                        key: ValueKey<Object>((
                          'miuix-timeline-connector-after',
                          index,
                        )),
                        height: resolvedConnectorWidth,
                        color: lineColor,
                      ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: _textBlock(context, item, colors, motion, reduceMotion),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = colors ?? MiuixTimelineDefaults.colors(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final motion = MiuixTheme.of(context).hyperOs4.processStateMotion;
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final resolvedMarkerExtent = markerExtent.isFinite
        ? markerExtent.clamp(0.0, double.infinity).toDouble()
        : hyperOs4.timelineMarkerExtent;
    final resolvedConnectorWidth = connectorWidth.isFinite
        ? connectorWidth.clamp(0.0, double.infinity).toDouble()
        : hyperOs4.timelineConnectorWidth;
    final resolvedHorizontalItemWidth = horizontalItemWidth.isFinite
        ? horizontalItemWidth.clamp(0.0, double.infinity).toDouble()
        : hyperOs4.timelineHorizontalItemWidth;

    Widget animatedItem(int index, {required bool horizontal}) {
      final target = _stateColor(palette, items[index].state);
      return TweenAnimationBuilder<Color?>(
        // Index is the public model's stable coordinate. The accessibility
        // policy bit replaces any partially sampled state at runtime.
        key: ValueKey<Object>((
          'miuix-timeline-state-motion',
          index,
          reduceMotion,
        )),
        tween: ColorTween(end: target),
        duration: reduceMotion ? Duration.zero : motion,
        curve: Curves.easeOutCubic,
        builder: (context, animatedColor, _) => horizontal
            ? _horizontalItem(
                context,
                index,
                palette,
                animatedColor ?? target,
                motion,
                reduceMotion,
                resolvedMarkerExtent,
                resolvedConnectorWidth,
                resolvedHorizontalItemWidth,
              )
            : _verticalItem(
                context,
                index,
                palette,
                animatedColor ?? target,
                motion,
                reduceMotion,
                resolvedMarkerExtent,
                resolvedConnectorWidth,
              ),
      );
    }

    if (orientation == MiuixTimelineOrientation.horizontal) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List<Widget>.generate(
            items.length,
            (index) => animatedItem(index, horizontal: true),
          ),
        ),
      );
    }
    return ListView.builder(
      primary: false,
      padding: EdgeInsets.zero,
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      itemCount: items.length,
      itemBuilder: (context, index) => animatedItem(index, horizontal: false),
    );
  }
}
