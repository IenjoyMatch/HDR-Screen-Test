import 'package:flutter/foundation.dart';

/// Project-calibrated tokens for the HyperOS 4 application design language.
///
/// Xiaomi's public HyperOS 4 site demonstrates the material and layout but
/// does not publish developer-facing dp values. These values are therefore
/// explicit project calibration points, not claims about private Xiaomi
/// constants. Keeping them together makes screenshot calibration auditable and
/// prevents individual widgets from drifting toward unrelated legacy metrics.
@immutable
class MiuixHyperOs4Tokens {
  /// Creates the default HyperOS 4 application token set.
  const MiuixHyperOs4Tokens({
    this.appBarBlur = 28,
    this.appBarTintOpacity = .58,
    this.progressiveAppBarBlur = 18,
    this.progressiveAppBarTintOpacity = .24,
    this.sliverAppBarExpandedHeight = 104,
    this.sliverAppBarExpandedSubtitleHeight = 126,
    this.sliverAppBarCollapsedHeight = 56,
    this.sliverAppBarCollapsedSubtitleHeight = 62,
    this.sliverAppBarSnapMotion = const Duration(milliseconds: 260),
    // Clearer HyperOS dock: less Gaussian milk, lower base tint so the
    // five-level controller (esp. intense) stays genuinely translucent.
    this.floatingNavigationBlur = 12,
    this.floatingNavigationTintOpacity = .38,
    this.floatingNavigationHeight = 58,
    this.floatingNavigationItemHeight = 52,
    this.floatingNavigationTwoItemWidth = 104,
    this.floatingNavigationThreeItemWidth = 88,
    this.floatingNavigationFourItemWidth = 74,
    this.floatingNavigationFiveItemWidth = 68,
    this.floatingNavigationItemSpacing = 0,
    this.floatingNavigationHorizontalPadding = 6,
    this.floatingNavigationCornerRadius = 29,
    this.floatingNavigationBottomMargin = 16,
    this.floatingNavigationSelectionInset = 2,
    this.floatingNavigationSelectionHeight = 52,
    this.floatingNavigationDragSelectionInset = 2,
    this.floatingNavigationContentSpacing = 5,
    this.floatingNavigationMotion = const Duration(milliseconds: 380),
    this.navigationRailBlur = 24,
    this.navigationRailTintOpacity = .56,
    this.navigationRailCornerRadius = 32,
    this.navigationRailOuterMargin = 12,
    this.navigationRailItemHeight = 54,
    this.navigationRailItemCornerRadius = 22,
    this.navigationRailSelectionTintOpacity = .08,
    this.navigationRailMotion = const Duration(milliseconds: 380),
    this.contentSurfaceBlur = 24,
    this.contentSurfaceTintOpacity = .68,
    this.cardCornerRadius = 20,
    this.searchBlur = 18,
    this.searchTintOpacity = .62,
    this.searchHeight = 48,
    this.popupBlur = 24,
    this.popupTintOpacity = .66,
    this.popupCornerRadius = 20,
    this.dialogBlur = 30,
    this.dialogTintOpacity = .68,
    this.dialogCornerRadius = 32,
    this.bottomSheetBlur = 28,
    this.bottomSheetTintOpacity = .70,
    this.bottomSheetCornerRadius = 32,
    this.buttonMinHeight = 48,
    this.buttonCornerRadius = 24,
    this.iconButtonSize = 44,
    this.textFieldCornerRadius = 20,
    this.settingsGroupCornerRadius = 20,
    this.snackbarBlur = 24,
    this.snackbarTintOpacity = .72,
    this.snackbarCornerRadius = 24,
    this.calendarBlur = 20,
    this.calendarTintOpacity = .64,
    this.calendarCornerRadius = 24,
    this.pickerBlur = 20,
    this.pickerTintOpacity = .60,
    this.pickerCornerRadius = 24,
    this.pickerStageMotion = const Duration(milliseconds: 380),
    this.segmentedControlBlur = 18,
    this.segmentedControlTintOpacity = .60,
    this.segmentedControlHeight = 44,
    this.segmentedControlCornerRadius = 22,
    this.segmentedControlMotion = const Duration(milliseconds: 380),
    this.floatingToolbarBlur = 24,
    this.floatingToolbarTintOpacity = .60,
    this.floatingToolbarCornerRadius = 50,
    this.floatingActionButtonBlur = 24,
    this.floatingActionButtonTintOpacity = .58,
    this.chipBlur = 18,
    this.chipTintOpacity = .56,
    this.chipMotion = const Duration(milliseconds: 280),
    this.inputStateMotion = const Duration(milliseconds: 280),
    this.selectionSurfaceMotion = const Duration(milliseconds: 320),
    this.selectionControlMotion = const Duration(milliseconds: 280),
    this.collectionRowMotion = const Duration(milliseconds: 140),
    this.collectionScrollMotion = const Duration(milliseconds: 180),
    this.collectionRowCornerRadius = 18,
    this.treeExpansionMotion = const Duration(milliseconds: 280),
    this.swipeActionMotion = const Duration(milliseconds: 320),
    this.contextMenuMotion = const Duration(milliseconds: 260),
    this.contextMenuMinWidth = 200,
    this.contextMenuMaxWidth = 288,
    this.contextMenuItemHeight = 52,
    this.contextMenuHorizontalPadding = 16,
    this.contextMenuIconSpacing = 12,
    this.contextMenuVerticalPadding = 6,
    this.contextMenuScreenMargin = 12,
    this.contextMenuShadowElevation = 8,
    this.skeletonMotion = const Duration(milliseconds: 1350),
    this.skeletonCornerRadius = 12,
    this.carouselPageMotion = const Duration(milliseconds: 420),
    this.carouselIndicatorGap = 10,
    this.pageIndicatorMotion = const Duration(milliseconds: 380),
    this.pageIndicatorDotSize = 6,
    this.pageIndicatorActiveWidth = 16,
    this.pageIndicatorSpacing = 2.5,
    this.progressLinearHeight = 6,
    this.progressCircularSize = 30,
    this.progressCircularStrokeWidth = 4,
    this.progressInfiniteSize = 20,
    this.progressInfiniteStrokeWidth = 2,
    this.progressOrbitingDotSize = 2,
    this.progressLinearMotion = const Duration(milliseconds: 1250),
    this.progressCircularRotationMotion = const Duration(milliseconds: 1000),
    this.progressCircularSweepMotion = const Duration(milliseconds: 1600),
    this.progressOrbitMotion = const Duration(milliseconds: 800),
    this.pullRefreshIndicatorSize = 20,
    this.pullRefreshSettleMotion = const Duration(milliseconds: 400),
    this.pullRefreshCompleteMotion = const Duration(milliseconds: 200),
    this.pullRefreshOrbitMotion = const Duration(milliseconds: 800),
    this.formSectionHorizontalPadding = 16,
    this.formSectionVerticalPadding = 12,
    this.formFieldContentSpacing = 8,
    this.formErrorSpacing = 6,
    this.formDividerExtent = 25,
    this.formFieldGap = 16,
    this.dataTableHeaderTintOpacity = .52,
    this.timelineMarkerExtent = 24,
    this.timelineConnectorWidth = 3,
    this.timelineHorizontalItemWidth = 184,
    this.emptyStateMaximumWidth = 360,
    this.emptyStatePadding = 24,
    this.emptyStateIconSize = 64,
    this.emptyStateTitleSpacing = 14,
    this.emptyStateMessageSpacing = 6,
    this.emptyStateActionSpacing = 18,
    this.inlineSurfaceBlur = 20,
    this.inlineSurfaceTintOpacity = .62,
    this.inlineSurfaceCornerRadius = 20,
    this.inlineSurfaceMotion = const Duration(milliseconds: 360),
    this.processStateMotion = const Duration(milliseconds: 360),
  });

  /// Backdrop sigma for a fully revealed top application bar.
  final double appBarBlur;

  /// Standard-level tint opacity for a top application bar.
  final double appBarTintOpacity;

  /// Backdrop sigma for the scroll-revealed top-edge material.
  final double progressiveAppBarBlur;

  /// Standard-level tint opacity for progressive top glass.
  final double progressiveAppBarTintOpacity;

  /// Expanded title-area height of a standard SliverTopAppBar.
  ///
  /// The 104dp project calibration leaves the first content row clearly below
  /// the large title before scrolling. It is not a published Xiaomi metric.
  final double sliverAppBarExpandedHeight;

  /// Expanded title-area height when a supporting subtitle is present.
  final double sliverAppBarExpandedSubtitleHeight;

  /// Collapsed title-area height of the standard large-title sliver.
  final double sliverAppBarCollapsedHeight;

  /// Collapsed title-area height when a subtitle remains visible.
  final double sliverAppBarCollapsedSubtitleHeight;

  /// Duration of autonomous floating sliver-app-bar snap settlement.
  final Duration sliverAppBarSnapMotion;

  /// Backdrop sigma for floating navigation surfaces.
  final double floatingNavigationBlur;

  /// Standard-level tint opacity for floating navigation surfaces.
  final double floatingNavigationTintOpacity;

  /// Minimum visible height of the complete floating navigation capsule.
  final double floatingNavigationHeight;

  /// Equal interaction height assigned to every destination.
  ///
  /// The 52dp project calibration preserves a comfortable semantic target
  /// around the visibly lower selection regions observed in Xiaomi's
  /// file-manager and contacts posters. It is not an unpublished Xiaomi
  /// design token.
  final double floatingNavigationItemHeight;

  /// Equal destination width for a two-item capsule.
  final double floatingNavigationTwoItemWidth;

  /// Equal destination width for a three-item capsule.
  final double floatingNavigationThreeItemWidth;

  /// Equal destination width for a four-item capsule.
  final double floatingNavigationFourItemWidth;

  /// Equal destination width for a five-or-more-item capsule.
  final double floatingNavigationFiveItemWidth;

  /// Gap between equal destination regions.
  ///
  /// HyperOS 4 destinations form one continuous row. Their semantic hit
  /// regions meet at the midpoint; only the moving selection material makes
  /// the active destination visible as an individual capsule.
  final double floatingNavigationItemSpacing;

  /// Inner horizontal inset on both capsule edges.
  final double floatingNavigationHorizontalPadding;

  /// Continuous corner calibration for the floating navigation capsule.
  final double floatingNavigationCornerRadius;

  /// Visual gap above a platform safe area or window edge.
  final double floatingNavigationBottomMargin;

  /// Horizontal inset from an item region to its moving selection surface.
  ///
  /// Xiaomi does not publish this dp value. The two-dp project calibration
  /// keeps adjacent selection surfaces visually separate without collapsing
  /// the selected state into a narrow icon backdrop.
  final double floatingNavigationSelectionInset;

  /// Visible height of the moving selection capsule.
  ///
  /// This is intentionally independent from the 52dp hit region and 58dp
  /// outer glass surface. The 52dp project calibration leaves a three-dp
  /// vertical inset on each edge, so the selected material follows the outer
  /// capsule instead of shrinking into a small icon backdrop. Xiaomi does not
  /// publish this value; it is calibrated from official-app imagery.
  final double floatingNavigationSelectionHeight;

  /// Extra inset applied to every edge while the selector is dragged.
  ///
  /// Xiaomi does not publish this interaction value. The two-dp project
  /// calibration deliberately makes the directly manipulated slider smaller
  /// than the settled selected capsule instead of copying iOS expansion.
  final double floatingNavigationDragSelectionInset;

  /// Vertical gap between icon and label in a combined destination.
  ///
  /// The five-dp project calibration keeps the complete icon-label group
  /// inside the near-full selection surface. Xiaomi does not publish this
  /// value.
  final double floatingNavigationContentSpacing;

  /// Duration of the continuous selection-surface transition.
  final Duration floatingNavigationMotion;

  /// Backdrop sigma for the local wide-window navigation surface.
  final double navigationRailBlur;

  /// Tint opacity for the local wide-window navigation surface.
  final double navigationRailTintOpacity;

  /// Continuous corner calibration for the complete navigation rail.
  final double navigationRailCornerRadius;

  /// Transparent clearance between the rail and the window/content edges.
  final double navigationRailOuterMargin;

  /// Minimum interaction height of one compact rail destination.
  final double navigationRailItemHeight;

  /// Continuous corner calibration for a selected rail destination.
  final double navigationRailItemCornerRadius;

  /// Primary-color wash behind a selected rail destination.
  ///
  /// The low project-calibrated opacity preserves primary icon and label
  /// contrast on both light and dark local glass. Xiaomi does not publish a
  /// universal rail-selection opacity.
  final double navigationRailSelectionTintOpacity;

  /// Duration of rail selection and display-mode transitions.
  final Duration navigationRailMotion;

  /// Backdrop sigma for reusable cards and generic glass surfaces.
  final double contentSurfaceBlur;

  /// Standard tint opacity for reusable cards and generic glass surfaces.
  final double contentSurfaceTintOpacity;

  /// Default continuous corner calibration for standalone information cards.
  final double cardCornerRadius;

  /// Backdrop sigma for the low-height search capsule.
  final double searchBlur;

  /// Standard tint opacity for the low-height search capsule.
  final double searchTintOpacity;

  /// Painted and interactive height of the default search capsule.
  final double searchHeight;

  /// Backdrop sigma for anchored popup and dropdown surfaces.
  final double popupBlur;

  /// Standard tint opacity for anchored popup and dropdown surfaces.
  final double popupTintOpacity;

  /// Continuous corner calibration for anchored popup surfaces.
  final double popupCornerRadius;

  /// Backdrop sigma for modal dialog surfaces.
  final double dialogBlur;

  /// Standard tint opacity for modal dialog surfaces.
  final double dialogTintOpacity;

  /// Continuous corner calibration for modal dialog surfaces.
  final double dialogCornerRadius;

  /// Backdrop sigma for content-driven bottom sheets.
  final double bottomSheetBlur;

  /// Standard tint opacity for content-driven bottom sheets.
  final double bottomSheetTintOpacity;

  /// Top-corner calibration for content-driven bottom sheets.
  final double bottomSheetCornerRadius;

  /// Minimum painted height of a standard HyperOS 4 action button.
  final double buttonMinHeight;

  /// Continuous corner calibration for standard action buttons.
  final double buttonCornerRadius;

  /// Painted square size of a compact icon action.
  final double iconButtonSize;

  /// Continuous corner calibration for editable fields.
  final double textFieldCornerRadius;

  /// Continuous corner calibration for a complete settings section.
  final double settingsGroupCornerRadius;

  /// Backdrop sigma for transient message surfaces.
  final double snackbarBlur;

  /// Tint opacity for transient message surfaces.
  final double snackbarTintOpacity;

  /// Continuous corner calibration for transient message surfaces.
  final double snackbarCornerRadius;

  /// Backdrop sigma for inline month, week, and range calendars.
  final double calendarBlur;

  /// Tint opacity for inline calendar panels.
  final double calendarTintOpacity;

  /// Continuous corner calibration for inline calendar panels.
  final double calendarCornerRadius;

  /// Backdrop sigma for wheel-based date and time panels.
  final double pickerBlur;

  /// Tint opacity for wheel-based date and time panels.
  final double pickerTintOpacity;

  /// Continuous corner calibration for wheel-based picker panels.
  final double pickerCornerRadius;

  /// Continuous transition duration between picker representations.
  final Duration pickerStageMotion;

  /// Backdrop sigma for compact option groups.
  final double segmentedControlBlur;

  /// Tint opacity for compact option groups.
  final double segmentedControlTintOpacity;

  /// Painted height of the complete segmented-control capsule.
  final double segmentedControlHeight;

  /// Continuous corner calibration for segmented-control capsules.
  final double segmentedControlCornerRadius;

  /// Duration of the shared selection-surface movement.
  final Duration segmentedControlMotion;

  /// Backdrop sigma for local floating action toolbars.
  final double floatingToolbarBlur;

  /// Tint opacity for local floating action toolbars.
  final double floatingToolbarTintOpacity;

  /// Capsule radius for local floating action toolbars.
  final double floatingToolbarCornerRadius;

  /// Backdrop sigma for a standalone floating primary action.
  ///
  /// Xiaomi does not publish this value as a developer token. The default is
  /// a project calibration kept separate from toolbar and navigation glass so
  /// applications can tune the compact circular surface independently.
  final double floatingActionButtonBlur;

  /// Tint opacity for a standalone floating primary action.
  final double floatingActionButtonTintOpacity;

  /// Backdrop sigma for low-height filter and action capsules.
  final double chipBlur;

  /// Tint opacity for low-height filter and action capsules.
  final double chipTintOpacity;

  /// Duration of chip selection and semantic-color transitions.
  final Duration chipMotion;

  /// Duration of focus, validation, and active-cell input transitions.
  ///
  /// Xiaomi does not publish an application motion token for these states.
  /// The default is a project calibration kept separate from chip motion so
  /// applications can tune editable controls without changing filter pills.
  final Duration inputStateMotion;

  /// Duration of content-fitting selection-panel size transitions.
  ///
  /// Xiaomi does not publish a searchable-panel timing token. This
  /// project-calibrated channel keeps filtering changes continuous without
  /// coupling a large panel resize to the shorter row-highlight transition.
  final Duration selectionSurfaceMotion;

  /// Duration of autonomous rating-fill and rotary-value transitions.
  ///
  /// Direct manipulation deliberately bypasses this clock so the visible
  /// value follows the pointer. Xiaomi does not publish a matching duration;
  /// the default is an explicit project calibration for programmatic changes.
  final Duration selectionControlMotion;

  /// Duration of hover, focus, and selection tint changes in dense rows.
  final Duration collectionRowMotion;

  /// Duration of autonomous keyboard positioning inside data collections.
  final Duration collectionScrollMotion;

  /// Continuous corner radius used by interactive collection rows.
  final double collectionRowCornerRadius;

  /// Duration of autonomous tree-branch insertion and removal.
  final Duration treeExpansionMotion;

  /// Duration of autonomous swipe-action opening and closing settlement.
  final Duration swipeActionMotion;

  /// Duration of the anchored context-menu entrance and exit transition.
  final Duration contextMenuMotion;

  /// Minimum content-fitting width of an anchored context menu.
  ///
  /// Xiaomi does not publish this value. The 200dp lower bound is shared with
  /// the package popup family so short labels remain comfortably actionable.
  final double contextMenuMinWidth;

  /// Maximum content-fitting width of an anchored context menu.
  ///
  /// The 288dp project calibration prevents long labels from turning a local
  /// action surface into a near-full-width phone panel.
  final double contextMenuMaxWidth;

  /// Interaction height of one context-menu action.
  final double contextMenuItemHeight;

  /// Horizontal content inset inside one context-menu action.
  final double contextMenuHorizontalPadding;

  /// Gap between an optional action icon and its label.
  final double contextMenuIconSpacing;

  /// Vertical inset around the complete context-menu action group.
  final double contextMenuVerticalPadding;

  /// Safe visual distance between a context menu and the usable window edge.
  final double contextMenuScreenMargin;

  /// Soft shadow calibration beneath the local glass panel.
  final double contextMenuShadowElevation;

  /// Duration of one autonomous skeleton highlight traversal.
  final Duration skeletonMotion;

  /// Continuous corner calibration for rectangular loading placeholders.
  final double skeletonCornerRadius;

  /// Duration of autonomous carousel page movement.
  final Duration carouselPageMotion;

  /// Vertical gap between carousel pages and their local page indicator.
  final double carouselIndicatorGap;

  /// Duration of standalone and carousel page-indicator interpolation.
  final Duration pageIndicatorMotion;

  /// Diameter of an inactive page-indicator dot.
  final double pageIndicatorDotSize;

  /// Width of the active page-indicator capsule.
  final double pageIndicatorActiveWidth;

  /// Horizontal space on each side of one indicator item.
  final double pageIndicatorSpacing;

  /// Height of a linear progress track.
  final double progressLinearHeight;

  /// Diameter of a circular progress track.
  final double progressCircularSize;

  /// Stroke width of a circular progress track.
  final double progressCircularStrokeWidth;

  /// Diameter of the compact orbit loading indicator.
  final double progressInfiniteSize;

  /// Stroke width of the compact orbit loading indicator.
  final double progressInfiniteStrokeWidth;

  /// Radius of the dot moving around the compact orbit indicator.
  final double progressOrbitingDotSize;

  /// Duration of one autonomous indeterminate linear traversal.
  final Duration progressLinearMotion;

  /// Duration of one circular-indicator rotation.
  final Duration progressCircularRotationMotion;

  /// Duration of one circular-indicator sweep expansion cycle.
  final Duration progressCircularSweepMotion;

  /// Duration of one compact loading-dot orbit.
  final Duration progressOrbitMotion;

  /// Diameter of the pull-to-refresh feedback ring.
  final double pullRefreshIndicatorSize;

  /// Project-calibrated spring period for autonomous refresh settlement.
  final Duration pullRefreshSettleMotion;

  /// Duration of the successful-refresh collapse.
  final Duration pullRefreshCompleteMotion;

  /// Duration of one refresh-ring revolution.
  final Duration pullRefreshOrbitMotion;

  /// Horizontal content inset inside a grouped form surface.
  final double formSectionHorizontalPadding;

  /// Vertical content inset inside a grouped form surface.
  final double formSectionVerticalPadding;

  /// Gap between field metadata and the owned input control.
  final double formFieldContentSpacing;

  /// Gap above a validation error message.
  final double formErrorSpacing;

  /// Complete vertical extent reserved by an inter-field divider.
  final double formDividerExtent;

  /// Gap between fields when dividers are disabled.
  final double formFieldGap;

  /// Header overlay opacity when a data table uses content glass.
  final double dataTableHeaderTintOpacity;

  /// Diameter of a passive timeline milestone marker.
  final double timelineMarkerExtent;

  /// Thickness of a passive timeline connector.
  final double timelineConnectorWidth;

  /// Stable width of one horizontally scrolling timeline milestone.
  final double timelineHorizontalItemWidth;

  /// Maximum readable width of a centered empty-state composition.
  final double emptyStateMaximumWidth;

  /// Outer content padding of a standard empty state.
  final double emptyStatePadding;

  /// Semantic icon extent of a standard empty state.
  final double emptyStateIconSize;

  /// Gap between the state icon and primary title.
  final double emptyStateTitleSpacing;

  /// Gap between primary title and optional explanatory copy.
  final double emptyStateMessageSpacing;

  /// Gap before an optional recovery action.
  final double emptyStateActionSpacing;

  /// Backdrop sigma for alerts, banners, and expandable page sections.
  final double inlineSurfaceBlur;

  /// Tint opacity for alerts, banners, and expandable page sections.
  final double inlineSurfaceTintOpacity;

  /// Continuous corner calibration for inline application surfaces.
  final double inlineSurfaceCornerRadius;

  /// Duration of inline surface expansion and disclosure movement.
  final Duration inlineSurfaceMotion;

  /// Duration of process-marker, connector, and step-content transitions.
  ///
  /// This project-calibrated channel keeps one logical process change on a
  /// shared timeline without claiming an unpublished Xiaomi constant.
  final Duration processStateMotion;

  /// Minimum equal destination width for the current number of destinations.
  ///
  /// Fewer destinations receive a wider stable target. The official contacts
  /// and file-manager captures show roughly two-to-one selected capsules for
  /// three-item groups; five-item navigation narrows only enough to fit a
  /// 360dp phone while keeping every destination wider than it is tall.
  double floatingNavigationItemWidth(int count) => switch (count) {
    <= 2 => floatingNavigationTwoItemWidth,
    3 => floatingNavigationThreeItemWidth,
    4 => floatingNavigationFourItemWidth,
    _ => floatingNavigationFiveItemWidth,
  };
}
