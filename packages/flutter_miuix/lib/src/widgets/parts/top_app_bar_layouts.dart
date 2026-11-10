part of '../miuix_widgets.dart';

/// Internal compact-title layout translated from upstream `TopAppBar.kt`.
///
/// This file intentionally contains only measurement and placement code.
/// Keeping it separate prevents the public widget and scroll controller from
/// becoming another oversized source file as parity details are added.
///
/// Source measurement contract:
///
/// - The navigation placeable is measured without minimum constraints.
/// - Its start padding belongs to the measured placeable width.
/// - The action row is measured without minimum constraints.
/// - Its end padding belongs to the measured placeable width.
/// - Plain/source actions retain one 40dp visual slot per item.
/// - HyperOS glass actions use independent 48dp circles with 8dp gaps.
/// - Every Android action exposes a 48dp interactive target.
/// - The final target extends 4dp into the trailing padding.
/// - The visible final icon remains 16dp from the trailing edge.
/// - The title is measured only after both side widths are known.
/// - Side widths are not replaced by their maximum.
/// - Asymmetric actions therefore reserve asymmetric title space.
/// - The available title width is full width minus both placeables.
/// - Upstream multiplies that result by exactly 0.9.
/// - The main title's 26dp padding is inside that maximum.
/// - The subtitle has no matching horizontal padding wrapper.
/// - Both text nodes still receive the same maximum constraint.
/// - Both text nodes are single-line and non-wrapping.
/// - Overflow is represented by an ellipsis.
///
/// Source vertical contract:
///
/// - A large bar uses the 52dp collapsed row as its center region.
/// - The center line of that row is therefore 26dp.
/// - A small bar uses a separate 50dp center region.
/// - Its center line is therefore 25dp.
/// - Navigation content is centered on the same line.
/// - Action content is centered on the same line.
/// - The compact main title is centered on the same line.
/// - A subtitle does not move that main-title center.
/// - The subtitle begins at the main title's bottom edge.
/// - No extra inter-line spacer is inserted.
/// - The subtitle contributes to the final surface height.
/// - The subtitle's source bottom padding is 8dp.
/// - A large bar without subtitle retains 4dp bottom padding.
/// - Consequently a collapsed large bar is 56dp, not 52dp.
/// - A default small bar without subtitle remains 52dp.
/// - A subtitle raises either compact result to about 62dp.
///
/// Source horizontal placement contract:
///
/// - Placement begins from the true window-centered title coordinate.
/// - A leading icon does not force an equal trailing inset.
/// - Multiple actions do not force an equal leading inset.
/// - The centered coordinate is kept when it clears both sides.
/// - Otherwise the title is clamped against the leading placeable.
/// - Otherwise it is clamped against the action placeable.
/// - The two collision branches are mutually exclusive upstream.
/// - The padded main-title placeable is what gets clamped.
/// - The subtitle is independently centered in the full window.
/// - The subtitle is not clamped to the main title's x coordinate.
/// - This is why a combined centered Column cannot match the source.
/// - This is also why a symmetric `max(sideWidth)` reserve is incorrect.
///
/// Source animation contract:
///
/// - Only the compact title and compact subtitle are animated.
/// - Navigation and actions stay fully opaque.
/// - Navigation and actions stay vertically stationary.
/// - Compact text appears after one-third collapse.
/// - Both text nodes share the same opacity.
/// - Both text nodes share the same vertical translation.
/// - The translation begins at 20 raw physical pixels.
/// - The translation finishes at zero.
/// - Showing uses the 0.3 second Folme response.
/// - Hiding uses the 0.15 second Folme response.
/// - The large title owns a separate inverse alpha.
/// - Layout remains stable while the paint animation runs.
///
/// Directionality contract:
///
/// - Compose uses `placeRelative` for all horizontal placement.
/// - Measurement itself is independent of text direction.
/// - Collision checks are performed in logical start coordinates.
/// - The final x coordinate is mirrored only once for RTL.
/// - `PositionedDirectional` performs the same conversion for icons.
/// - This preserves action ordering supplied by Flutter's Directionality.
/// - It also keeps the title collision rules identical in Arabic layouts.
///
/// Robustness contract:
///
/// - Missing leading content reserves zero width.
/// - Missing actions reserve only the configured end padding upstream.
/// - A zero remaining width is valid and must not assert.
/// - Narrow windows may reduce the text region to its padding.
/// - Custom title padding remains part of title measurement.
/// - Empty subtitle strings are normalized before reaching this file.
/// - Text scaling may increase measured title and subtitle heights.
/// - The parent surface clips overflow like Compose `clipToBounds`.
/// - Relayout occurs when any geometry input or direction changes.
/// - Pure color and opacity changes do not alter this delegate.
///
/// The explicit contracts above are regression documentation, not decorative
/// comments: each group corresponds to an upstream measurement or placement
/// branch whose accidental simplification has previously produced visible
/// pixel drift in the Android comparison captures.
class _MiuixCompactTopAppBarContent extends StatelessWidget {
  const _MiuixCompactTopAppBarContent({
    required this.title,
    required this.subtitle,
    required this.leading,
    required this.actions,
    required this.centerHeight,
    required this.titleStyle,
    required this.subtitleStyle,
    required this.titlePadding,
    required this.navigationIconPadding,
    required this.actionIconPadding,
    required this.actionStyle,
    required this.showActionSurfaces,
    required this.includeTopSafeArea,
    required this.animateTitle,
    required this.titleVisible,
  });

  /// Compact main title kept mounted during large-title expansion.
  final String title;

  /// Normalized non-empty compact subtitle, when supplied.
  final String? subtitle;

  /// Optional navigation placeable at the logical start edge.
  final Widget? leading;

  /// Optional source-spaced or HyperOS circular actions at the logical end.
  final List<Widget>? actions;

  /// Source center region: 52dp for large and 50dp for small bars.
  final double centerHeight;

  /// Source 20sp medium compact-title style.
  final TextStyle? titleStyle;

  /// Source 14sp regular supporting-title style.
  final TextStyle? subtitleStyle;

  /// Padding measured inside the compact main-title placeable.
  final double titlePadding;

  /// Start padding measured with the navigation placeable.
  final double navigationIconPadding;

  /// End padding measured with the action-row placeable.
  final double actionIconPadding;

  /// Material surrounding the compact action row.
  final MiuixTopAppBarActionStyle actionStyle;

  /// Large-title actions share the title backdrop; compact actions have circles.
  final bool showActionSurfaces;

  /// Whether the title surface owns the Android status-bar inset.
  final bool includeTopSafeArea;

  /// Whether large-bar compact text receives the Folme transition.
  final bool animateTitle;

  /// Whether collapse has crossed the upstream one-third threshold.
  final bool titleVisible;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Preserve distinct source placeable widths. Replacing these with one
        // symmetric side limit would shift titles whenever action count is not
        // balanced by a leading widget.
        final actionCount = actions?.length ?? 0;
        final actionWidth = actionCount == 0
            ? 0.0
            : _MiuixTopBarActions.widthFor(actionCount, actionStyle) +
                  actionIconPadding -
                  4;
        final leadingWidth = leading == null ? 0.0 : 40 + navigationIconPadding;
        final targetOffset = _miuixTopBarTouchTargetOffset(
          context,
          centerHeight: centerHeight,
          includeTopSafeArea: includeTopSafeArea,
        );
        final actionTargetInsets = _miuixTopBarActionTargetInsets(
          context,
          actionIconPadding: actionIconPadding,
        );

        // The transition wraps both compact text nodes because Compose applies
        // the same graphics-layer values to the title and small subtitle.
        final titleContent = _MiuixCompactTitleLayout(
          title: title,
          subtitle: subtitle,
          centerHeight: centerHeight,
          titleStyle: titleStyle,
          subtitleStyle: subtitleStyle,
          titlePadding: titlePadding,
          leadingWidth: leadingWidth,
          actionWidth: actionWidth,
        );
        return Stack(
          children: [
            if (leading != null)
              PositionedDirectional(
                start: navigationIconPadding,
                top: (centerHeight - 40) / 2,
                width: 40,
                height: 40,
                child: _MiuixIconButtonTargetOffset(
                  offset: targetOffset,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      if (showActionSurfaces &&
                          actionStyle == MiuixTopAppBarActionStyle.glass)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: OverflowBox(
                              minWidth: 44,
                              maxWidth: 44,
                              minHeight: 44,
                              maxHeight: 44,
                              child: MiuixGlass(
                                key: const ValueKey(
                                  'top-app-bar-glass-leading',
                                ),
                                blur: MiuixTheme.of(
                                  context,
                                ).hyperOs4.appBarBlur,
                                opacity: MiuixTheme.of(
                                  context,
                                ).hyperOs4.appBarTintOpacity,
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainer,
                                shape: const CircleBorder(),
                                padding: EdgeInsets.zero,
                                optics: MiuixGlassOptics.navigation,
                                child: const SizedBox.expand(),
                              ),
                            ),
                          ),
                        ),
                      _MiuixIconButtonGlassContext(
                        selectedBackgroundColor: showActionSurfaces
                            ? Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: .14)
                            : Colors.transparent,
                        selectedContentColor: Theme.of(
                          context,
                        ).colorScheme.primary,
                        child: leading!,
                      ),
                    ],
                  ),
                ),
              ),
            Positioned.fill(
              child: animateTitle
                  ? _MiuixCompactTitleTransition(
                      visible: titleVisible,
                      child: titleContent,
                    )
                  : titleContent,
            ),
            if (actions case final actionWidgets?)
              PositionedDirectional(
                // The 48dp semantic target extends 4dp beyond each 40dp visual
                // slot. Reducing the positional end by 4dp leaves the visible
                // icon at the source's configured 16dp edge distance.
                end: actionIconPadding - 4,
                top: (centerHeight - 48) / 2,
                child: _MiuixTopBarActions(
                  targetOffset: targetOffset,
                  targetInsets: actionTargetInsets,
                  style: actionStyle,
                  showSurfaces: showActionSurfaces,
                  children: actionWidgets,
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Reproduces Compose's forward rounding of fractional touch-bound origins.
///
/// The visual icon remains on its independently rounded 40dp placeable. Only
/// the Android interaction rectangle receives this sub-logical-pixel offset.
Offset _miuixTopBarTouchTargetOffset(
  BuildContext context, {
  required double centerHeight,
  required bool includeTopSafeArea,
}) {
  final pixelRatio = MediaQuery.devicePixelRatioOf(context);
  final safeTop = includeTopSafeArea
      ? MediaQuery.viewPaddingOf(context).top
      : 0.0;
  // Both the expanded leading target and the 48dp action target begin at the
  // center-row origin minus 24dp, despite their different visual placeables.
  final physicalTop = (safeTop + centerHeight / 2 - 24) * pixelRatio;
  final liesOnPhysicalPixel =
      (physicalTop - physicalTop.roundToDouble()).abs() < 1e-6;
  if (liesOnPhysicalPixel || pixelRatio <= 0) {
    return Offset.zero;
  }
  return Offset(0, 1 / pixelRatio);
}

/// Keeps the trailing action target inside Compose's rounded pixel origin.
///
/// Flutter rounds semantic starts and ends outward. Compose advances both
/// fractional coordinates. At 420dpi only the physical left edge therefore
/// needs to move inward; the right edge, visual center, and popup anchor are
/// already exact.
EdgeInsets _miuixTopBarActionTargetInsets(
  BuildContext context, {
  required double actionIconPadding,
}) {
  final pixelRatio = MediaQuery.devicePixelRatioOf(context);
  if (pixelRatio <= 0) {
    return EdgeInsets.zero;
  }
  final width = MediaQuery.sizeOf(context).width;
  final physicalTargetLeft =
      (width - (actionIconPadding - 4) - 48) * pixelRatio;
  final liesOnPhysicalPixel =
      (physicalTargetLeft - physicalTargetLeft.roundToDouble()).abs() < 1e-6;
  if (liesOnPhysicalPixel) {
    return EdgeInsets.zero;
  }
  return EdgeInsets.only(left: 1 / pixelRatio);
}

/// Identifiers used by the compact text multi-child layout.
enum _MiuixCompactTitleSlot { title, subtitle }

/// Builds the two independently positioned compact text placeables.
class _MiuixCompactTitleLayout extends StatelessWidget {
  const _MiuixCompactTitleLayout({
    required this.title,
    required this.subtitle,
    required this.centerHeight,
    required this.titleStyle,
    required this.subtitleStyle,
    required this.titlePadding,
    required this.leadingWidth,
    required this.actionWidth,
  });

  /// Main compact title.
  final String title;

  /// Optional compact subtitle.
  final String? subtitle;

  /// Vertical center region inherited from the bar variant.
  final double centerHeight;

  /// Main title style.
  final TextStyle? titleStyle;

  /// Supporting title style.
  final TextStyle? subtitleStyle;

  /// Internal main-title horizontal padding.
  final double titlePadding;

  /// Complete leading placeable reservation.
  final double leadingWidth;

  /// Complete trailing placeable reservation.
  final double actionWidth;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      LayoutId(
        id: _MiuixCompactTitleSlot.title,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: titlePadding),
          child: Text(
            title,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: titleStyle,
          ),
        ),
      ),
      if (subtitle case final supportingText?)
        LayoutId(
          id: _MiuixCompactTitleSlot.subtitle,
          child: Text(
            supportingText,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: subtitleStyle,
          ),
        ),
    ];
    return CustomMultiChildLayout(
      delegate: _MiuixCompactTitleLayoutDelegate(
        centerHeight: centerHeight,
        leadingWidth: leadingWidth,
        actionWidth: actionWidth,
        textDirection: Directionality.of(context),
      ),
      children: children,
    );
  }
}

/// Performs the upstream compact-title measurement and collision algorithm.
class _MiuixCompactTitleLayoutDelegate extends MultiChildLayoutDelegate {
  _MiuixCompactTitleLayoutDelegate({
    required this.centerHeight,
    required this.leadingWidth,
    required this.actionWidth,
    required this.textDirection,
  });

  /// Source compact-row center region.
  final double centerHeight;

  /// Logical-start placeable width.
  final double leadingWidth;

  /// Logical-end placeable width.
  final double actionWidth;

  /// Direction used to reproduce Compose `placeRelative`.
  final TextDirection textDirection;

  @override
  void performLayout(Size size) {
    // Compose measures both compact text nodes against the same 90% maximum,
    // while only the main title owns the horizontal 26dp internal padding.
    final remainingWidth = math.max(
      0.0,
      size.width - leadingWidth - actionWidth,
    );
    final titleConstraints = BoxConstraints(
      maxWidth: remainingWidth * MiuixTopAppBar.titleMaxWidthFraction,
      maxHeight: size.height,
    );
    final titleSize = layoutChild(
      _MiuixCompactTitleSlot.title,
      titleConstraints,
    );

    // Begin at the true center, then reproduce the source's ordered collision
    // branches. Working in start coordinates keeps the math direction-neutral.
    var titleStart = (size.width - titleSize.width) / 2;
    if (titleStart < leadingWidth) {
      titleStart = leadingWidth;
    } else if (titleStart + titleSize.width > size.width - actionWidth) {
      titleStart = size.width - actionWidth - titleSize.width;
    }
    final titleTop = centerHeight / 2 - titleSize.height / 2;
    positionChild(
      _MiuixCompactTitleSlot.title,
      Offset(_relativeX(size.width, titleStart, titleSize.width), titleTop),
    );

    // The supporting line is centered in the complete window and begins at
    // the title's bottom. It deliberately does not inherit the clamped x.
    if (hasChild(_MiuixCompactTitleSlot.subtitle)) {
      final subtitleSize = layoutChild(
        _MiuixCompactTitleSlot.subtitle,
        titleConstraints,
      );
      final subtitleStart = (size.width - subtitleSize.width) / 2;
      positionChild(
        _MiuixCompactTitleSlot.subtitle,
        Offset(
          _relativeX(size.width, subtitleStart, subtitleSize.width),
          centerHeight / 2 + titleSize.height / 2,
        ),
      );
    }
  }

  /// Converts one logical-start coordinate to Flutter's physical-left axis.
  double _relativeX(double width, double start, double childWidth) {
    return textDirection == TextDirection.ltr
        ? start
        : width - start - childWidth;
  }

  @override
  bool shouldRelayout(covariant _MiuixCompactTitleLayoutDelegate oldDelegate) {
    // Text itself triggers child layout; only delegate-owned geometry belongs
    // in this comparison.
    return centerHeight != oldDelegate.centerHeight ||
        leadingWidth != oldDelegate.leadingWidth ||
        actionWidth != oldDelegate.actionWidth ||
        textDirection != oldDelegate.textDirection;
  }
}
