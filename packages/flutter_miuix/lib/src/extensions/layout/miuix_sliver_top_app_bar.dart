import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show FloatingHeaderSnapConfiguration;

import '../../theme/miuix_theme.dart';
import '../../widgets/miuix_widgets.dart';

/// Defaults for a MIUIX top app bar hosted by a sliver scroll view.
abstract final class MiuixSliverTopAppBarDefaults {
  // Runtime sliver-geometry contract:
  // - Invalid title-area heights restore the active theme defaults.
  // - Expanded title height never resolves below collapsed title height.
  // - Invalid bottom-slot height and expanded padding resolve to zero.
  // - Negative finite bottom-slot geometry clamps to zero.
  // - Header min and max extents are always finite and monotonically ordered.
  // - Snap configuration exists only for a genuinely floating header.
  // - Reduced motion retains the same endpoint with a zero-duration snap.
  // - Resolved bottom geometry is forwarded unchanged to the box top bar.
  // - Safe-area inset remains additive and independent from title geometry.
  // - Debug and Release construct the same sliver delegate for bad inputs.

  /// HyperOS 4 project-calibrated expanded title heights.
  static const double expandedHeight = 104;
  static const double expandedSubtitleHeight = 126;

  /// HyperOS 4 project-calibrated collapsed title-area heights.
  static const double collapsedHeight = 56;
  static const double collapsedSubtitleHeight = 62;

  /// Former MIUIX source geometry retained by `.source`.
  static const double legacyExpandedHeight = 94;
  static const double legacyExpandedSubtitleHeight = 114;
  static const double legacyCollapsedHeight = 56;
  static const double legacyCollapsedSubtitleHeight = 62;
}

/// A real sliver form of [MiuixTopAppBar].
///
/// It participates in `CustomScrollView` geometry rather than overlaying a
/// normal box above the body. The compact title, large-title fade, bottom
/// content, and progressive glass reveal are driven by the sliver's exact
/// shrink offset through the public direct-collapse bridge on the top bar.
class MiuixSliverTopAppBar extends StatefulWidget {
  /// Creates a large MIUIX sliver header.
  const MiuixSliverTopAppBar({
    super.key,
    required this.title,
    this.largeTitle,
    this.subtitle,
    this.leading,
    this.actions,
    this.pinned = true,
    this.floating = false,
    this.snap = false,
    this.expandedHeight,
    this.collapsedHeight,
    this.color,
    this.glass = true,
    this.blurStyle = MiuixTopAppBarBlurStyle.gradient,
    this.titleColor,
    this.largeTitleColor,
    this.subtitleColor,
    this.defaultWindowInsetsPadding = true,
    this.titlePadding = 26,
    this.navigationIconPadding = 16,
    this.actionIconPadding = 16,
    this.bottomContent,
    this.bottomContentHeight = 0,
    this.bottomContentExpandedTopPadding = 0,
  });

  /// Creates the former source-height sliver header.
  const MiuixSliverTopAppBar.source({
    super.key,
    required this.title,
    this.largeTitle,
    this.subtitle,
    this.leading,
    this.actions,
    this.pinned = true,
    this.floating = false,
    this.snap = false,
    double? expandedHeight,
    double? collapsedHeight,
    this.color,
    this.glass = true,
    this.blurStyle = MiuixTopAppBarBlurStyle.progressive,
    this.titleColor,
    this.largeTitleColor,
    this.subtitleColor,
    this.defaultWindowInsetsPadding = true,
    this.titlePadding = 26,
    this.navigationIconPadding = 16,
    this.actionIconPadding = 16,
    this.bottomContent,
    this.bottomContentHeight = 0,
    this.bottomContentExpandedTopPadding = 0,
  }) : expandedHeight =
           expandedHeight ??
           (subtitle == null || subtitle == ''
               ? MiuixSliverTopAppBarDefaults.legacyExpandedHeight
               : MiuixSliverTopAppBarDefaults.legacyExpandedSubtitleHeight),
       collapsedHeight =
           collapsedHeight ??
           (subtitle == null || subtitle == ''
               ? MiuixSliverTopAppBarDefaults.legacyCollapsedHeight
               : MiuixSliverTopAppBarDefaults.legacyCollapsedSubtitleHeight);

  /// Main title content.
  final String title;
  final String? largeTitle;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;

  /// Sliver persistence and re-entry policy.
  final bool pinned;
  final bool floating;
  final bool snap;

  /// Optional source title-area height overrides, excluding system inset.
  final double? expandedHeight;
  final double? collapsedHeight;

  /// Surface and glass styling forwarded to [MiuixTopAppBar].
  final Color? color;
  final bool glass;
  final MiuixTopAppBarBlurStyle blurStyle;
  final Color? titleColor;
  final Color? largeTitleColor;
  final Color? subtitleColor;

  /// Safe-area and slot geometry.
  final bool defaultWindowInsetsPadding;
  final double titlePadding;
  final double navigationIconPadding;
  final double actionIconPadding;
  final Widget? bottomContent;
  final double bottomContentHeight;
  final double bottomContentExpandedTopPadding;

  @override
  State<MiuixSliverTopAppBar> createState() => _MiuixSliverTopAppBarState();
}

class _MiuixSliverTopAppBarState extends State<MiuixSliverTopAppBar>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final hasSubtitle = widget.subtitle?.isNotEmpty == true;
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final defaultExpanded = (hasSubtitle
        ? hyperOs4.sliverAppBarExpandedSubtitleHeight
        : hyperOs4.sliverAppBarExpandedHeight);
    final defaultCollapsed = (hasSubtitle
        ? hyperOs4.sliverAppBarCollapsedSubtitleHeight
        : hyperOs4.sliverAppBarCollapsedHeight);
    final authoredCollapsed = widget.collapsedHeight;
    final collapsed =
        authoredCollapsed != null &&
            authoredCollapsed.isFinite &&
            authoredCollapsed > 0
        ? authoredCollapsed
        : defaultCollapsed;
    final authoredExpanded = widget.expandedHeight;
    final safeExpanded =
        authoredExpanded != null &&
            authoredExpanded.isFinite &&
            authoredExpanded > 0
        ? authoredExpanded
        : defaultExpanded;
    final expanded = math.max(collapsed, safeExpanded).toDouble();
    final bottomContentHeight = widget.bottomContentHeight.isFinite
        ? math.max(0, widget.bottomContentHeight).toDouble()
        : 0.0;
    final bottomExpandedTopPadding =
        widget.bottomContentExpandedTopPadding.isFinite
        ? math.max(0, widget.bottomContentExpandedTopPadding).toDouble()
        : 0.0;
    final minimum = topInset + collapsed + bottomContentHeight;
    final maximum =
        topInset + expanded + bottomContentHeight + bottomExpandedTopPadding;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final snapMotion = reduceMotion
        ? Duration.zero
        : hyperOs4.sliverAppBarSnapMotion;
    return SliverPersistentHeader(
      pinned: widget.pinned,
      floating: widget.floating,
      delegate: _MiuixTopAppBarSliverDelegate(
        widget: widget,
        vsync: this,
        minExtent: minimum,
        maxExtent: maximum < minimum ? minimum : maximum,
        expandedTitleHeight: expanded,
        collapsedTitleHeight: collapsed,
        bottomContentHeight: bottomContentHeight,
        bottomContentExpandedTopPadding: bottomExpandedTopPadding,
        snapMotion: snapMotion,
      ),
    );
  }
}

class _MiuixTopAppBarSliverDelegate extends SliverPersistentHeaderDelegate {
  _MiuixTopAppBarSliverDelegate({
    required this.widget,
    required this.vsync,
    required this.minExtent,
    required this.maxExtent,
    required this.expandedTitleHeight,
    required this.collapsedTitleHeight,
    required this.bottomContentHeight,
    required this.bottomContentExpandedTopPadding,
    required this.snapMotion,
  });

  final MiuixSliverTopAppBar widget;
  @override
  final TickerProvider vsync;
  @override
  final double minExtent;
  @override
  final double maxExtent;
  final double expandedTitleHeight;
  final double collapsedTitleHeight;
  final double bottomContentHeight;
  final double bottomContentExpandedTopPadding;
  final Duration snapMotion;

  @override
  FloatingHeaderSnapConfiguration? get snapConfiguration =>
      widget.snap && widget.floating
      ? FloatingHeaderSnapConfiguration(
          curve: Curves.easeOutCubic,
          duration: snapMotion,
        )
      : null;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final range = maxExtent - minExtent;
    final fraction = range <= 0 ? 1.0 : (shrinkOffset / range).clamp(0.0, 1.0);
    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.topCenter,
        minHeight: 0,
        maxHeight: maxExtent,
        child: MiuixTopAppBar(
          title: widget.title,
          largeTitle: widget.largeTitle,
          subtitle: widget.subtitle,
          leading: widget.leading,
          actions: widget.actions,
          large: true,
          collapseFraction: fraction,
          color: widget.color,
          glass: widget.glass,
          blurStyle: widget.blurStyle,
          titleColor: widget.titleColor,
          largeTitleColor: widget.largeTitleColor,
          subtitleColor: widget.subtitleColor,
          defaultWindowInsetsPadding: widget.defaultWindowInsetsPadding,
          titlePadding: widget.titlePadding,
          navigationIconPadding: widget.navigationIconPadding,
          actionIconPadding: widget.actionIconPadding,
          expandedHeight: expandedTitleHeight,
          collapsedTitleAreaHeight: collapsedTitleHeight,
          bottomContent: widget.bottomContent,
          bottomContentHeight: bottomContentHeight,
          bottomContentExpandedTopPadding: bottomContentExpandedTopPadding,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _MiuixTopAppBarSliverDelegate oldDelegate) {
    return widget != oldDelegate.widget ||
        minExtent != oldDelegate.minExtent ||
        maxExtent != oldDelegate.maxExtent ||
        expandedTitleHeight != oldDelegate.expandedTitleHeight ||
        collapsedTitleHeight != oldDelegate.collapsedTitleHeight ||
        bottomContentHeight != oldDelegate.bottomContentHeight ||
        bottomContentExpandedTopPadding !=
            oldDelegate.bottomContentExpandedTopPadding ||
        snapMotion != oldDelegate.snapMotion;
  }
}
