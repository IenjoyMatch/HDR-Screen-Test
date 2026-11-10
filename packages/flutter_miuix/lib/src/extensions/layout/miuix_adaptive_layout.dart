import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../effects/miuix_effects.dart';
import '../../platform/miuix_haptics.dart';
import '../../theme/miuix_semantic_colors.dart';
import '../../theme/miuix_theme.dart';
import '../../widgets/miuix_widgets.dart';

/// Navigation presentations selected by [MiuixAdaptiveScaffold].
enum MiuixAdaptiveNavigationMode {
  /// Resolve the presentation from the available logical width.
  automatic,

  /// Use the phone-oriented bottom navigation bar.
  bottom,

  /// Use the compact wide-screen navigation rail.
  rail,

  /// Keep a full navigation drawer beside page content.
  drawer,
}

/// Current responsive size class.
enum MiuixAdaptiveWindowClass { compact, medium, expanded }

/// Public responsive tokens shared by adaptive MIUIX layouts.
abstract final class MiuixAdaptiveLayoutDefaults {
  // HyperOS 4 adaptive-navigation implementation contract:
  // - Compact, medium, and expanded modes express one destination model.
  // - Drawer rows retain equal width regardless of localized label length.
  // - Selection background, icon, label, and weight share one motion sample.
  // - Selected-icon replacement preserves the same centered icon coordinate.
  // - Badges remain attached to the icon and do not affect row allocation.
  // - Navigation-rail tokens also govern the related expanded side surface.
  // - Reduced motion replaces every in-flight drawer selection channel.
  // - Disabled destinations remain visible but install no pointer action.
  // - Modal close behavior occurs only after an enabled destination selection.
  // - Safe-area padding remains configurable for embedded desktop panes.
  // - Breakpoints are project defaults and stay caller-overridable.
  // - Two reversed positive breakpoints preserve intent by sorting ascending.
  // - Equal, non-positive, or non-finite pairs restore both public defaults.
  // - A NaN or negative-infinite window remains in the compact size class.
  // - A positive-infinite desktop canvas resolves to the expanded class.
  // - Static helpers and the live scaffold share one normalization function.
  // - Resolved-mode callbacks publish transitions rather than rebuild counts.
  // - Multiple layouts in one frame collapse into the latest pending mode.
  // - Disposed scaffolds cannot deliver a delayed size-class notification.
  // - No breakpoint or drawer size is described as an unpublished Xiaomi value.
  // These constraints keep navigation state continuous across window classes.

  /// Width where a phone layout becomes a rail layout.
  static const double mediumBreakpoint = 600;

  /// Width where a rail becomes a permanently visible drawer.
  static const double expandedBreakpoint = 1200;

  /// Fixed navigation drawer width on an expanded window.
  static const double drawerWidth = 300;

  /// Modal drawer width, capped again by the current viewport.
  static const double modalDrawerWidth = 320;

  /// Resolves caller breakpoints into one finite ascending pair.
  ///
  /// Reversed positive values are sorted because their intent remains
  /// unambiguous. Equal, non-positive, or non-finite pairs restore the public
  /// defaults instead of producing Debug-only failures or unstable classes.
  static (double, double) normalizedBreakpoints(
    double medium,
    double expanded,
  ) {
    if (!medium.isFinite ||
        !expanded.isFinite ||
        medium <= 0 ||
        expanded <= 0 ||
        medium == expanded) {
      return (mediumBreakpoint, expandedBreakpoint);
    }
    return medium < expanded ? (medium, expanded) : (expanded, medium);
  }

  /// Resolves the package window class from a logical width.
  static MiuixAdaptiveWindowClass windowClassFor(
    double width, {
    double medium = mediumBreakpoint,
    double expanded = expandedBreakpoint,
  }) {
    final breakpoints = normalizedBreakpoints(medium, expanded);
    final resolvedWidth = width.isNaN || width == double.negativeInfinity
        ? 0.0
        : width;
    if (resolvedWidth >= breakpoints.$2) {
      return MiuixAdaptiveWindowClass.expanded;
    }
    if (resolvedWidth >= breakpoints.$1) {
      return MiuixAdaptiveWindowClass.medium;
    }
    return MiuixAdaptiveWindowClass.compact;
  }

  /// Resolves the default navigation presentation for [width].
  static MiuixAdaptiveNavigationMode navigationModeFor(
    double width, {
    double medium = mediumBreakpoint,
    double expanded = expandedBreakpoint,
  }) {
    return switch (windowClassFor(width, medium: medium, expanded: expanded)) {
      MiuixAdaptiveWindowClass.compact => MiuixAdaptiveNavigationMode.bottom,
      MiuixAdaptiveWindowClass.medium => MiuixAdaptiveNavigationMode.rail,
      MiuixAdaptiveWindowClass.expanded => MiuixAdaptiveNavigationMode.drawer,
    };
  }
}

/// Project-calibrated geometry for readable content on expanded windows.
abstract final class MiuixAdaptiveContentFrameDefaults {
  /// Maximum width of one primary reading or settings plane.
  ///
  /// Xiaomi does not publish a universal desktop content width. This 1200dp
  /// value is a project calibration that prevents phone cards from being
  /// stretched across an entire maximized Windows canvas while preserving a
  /// generous tablet workspace.
  static const double maximumWidth = 1200;
}

/// Centers and width-limits one page plane on expanded window canvases.
///
/// This is intentionally separate from navigation selection. It can wrap the
/// body of [MiuixAdaptiveScaffold], a nested Navigator, or an individual page.
/// Below [maximumWidth] the child keeps the complete available width; above it
/// the child remains full-height and gains symmetric breathing room.
class MiuixAdaptiveContentFrame extends StatelessWidget {
  /// Creates a responsive content-width frame.
  const MiuixAdaptiveContentFrame({
    super.key,
    required this.child,
    this.maximumWidth = MiuixAdaptiveContentFrameDefaults.maximumWidth,
    this.alignment = Alignment.topCenter,
  });

  /// Page, Navigator, or other primary content plane.
  final Widget child;

  /// Largest logical width assigned to [child].
  ///
  /// Non-finite and non-positive values restore the project default so a
  /// malformed runtime preference cannot make the application disappear.
  final double maximumWidth;

  /// Placement of the constrained plane inside remaining viewport space.
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    final resolvedMaximum = maximumWidth.isFinite && maximumWidth > 0
        ? maximumWidth
        : MiuixAdaptiveContentFrameDefaults.maximumWidth;
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? math.max(0.0, constraints.maxWidth)
            : resolvedMaximum;
        final contentWidth = math.min(availableWidth, resolvedMaximum);
        final contentHeight = constraints.maxHeight.isFinite
            ? math.max(0.0, constraints.maxHeight)
            : null;
        return Align(
          alignment: alignment,
          child: SizedBox(
            width: contentWidth,
            height: contentHeight,
            child: child,
          ),
        );
      },
    );
  }
}

/// Drawer color roles separated from application page colors.
@immutable
class MiuixNavigationDrawerColors {
  /// Creates a complete drawer palette.
  const MiuixNavigationDrawerColors({
    required this.background,
    required this.foreground,
    required this.secondaryForeground,
    required this.selectedBackground,
    required this.selectedForeground,
    required this.divider,
  });

  /// Container and content roles.
  final Color background;
  final Color foreground;
  final Color secondaryForeground;
  final Color selectedBackground;
  final Color selectedForeground;
  final Color divider;

  /// Resolves drawer roles from MIUIX semantic colors.
  static MiuixNavigationDrawerColors of(BuildContext context) {
    final semantic = MiuixSemanticColors.of(context);
    return MiuixNavigationDrawerColors(
      background: semantic['surface'],
      foreground: semantic['onSurface'],
      secondaryForeground: semantic['onSurfaceSecondary'],
      selectedBackground: semantic['primaryContainer'],
      selectedForeground: semantic['onPrimaryContainer'],
      divider: semantic['dividerLine'],
    );
  }
}

/// MIUIX navigation drawer usable as a modal drawer or fixed side pane.
class MiuixNavigationDrawer extends StatelessWidget {
  /// Creates a floating HyperOS 4 drawer from the shared destination model.
  const MiuixNavigationDrawer({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.header,
    this.footer,
    this.width = MiuixAdaptiveLayoutDefaults.drawerWidth,
    this.glass = true,
    this.floating = true,
    this.outerMargin,
    this.cornerRadius,
    this.glassBlur,
    this.glassOpacity,
    this.showGlassSpecular = true,
    this.colors,
    this.closeOnSelection = false,
    this.defaultWindowInsetsPadding = true,
  });

  /// Creates the former edge-attached opaque rectangular drawer.
  const MiuixNavigationDrawer.source({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.header,
    this.footer,
    this.width = MiuixAdaptiveLayoutDefaults.drawerWidth,
    this.colors,
    this.closeOnSelection = false,
    this.defaultWindowInsetsPadding = true,
  }) : glass = false,
       floating = false,
       outerMargin = 0,
       cornerRadius = 0,
       glassBlur = null,
       glassOpacity = null,
       showGlassSpecular = false;

  /// Destinations and current selection.
  final List<MiuixNavigationItem> items;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  /// Optional content placed before and after the destination list.
  final Widget? header;
  final Widget? footer;

  /// Drawer geometry and appearance.
  final double width;
  final bool glass;
  final bool floating;
  final double? outerMargin;
  final double? cornerRadius;
  final double? glassBlur;
  final double? glassOpacity;
  final bool showGlassSpecular;
  final MiuixNavigationDrawerColors? colors;

  /// Whether a modal drawer asks its enclosing route to close after selection.
  final bool closeOnSelection;

  /// Whether status and bottom system insets are consumed by the drawer.
  final bool defaultWindowInsetsPadding;

  void _select(BuildContext context, int index) {
    if (!items[index].enabled) return;
    onDestinationSelected(index);
    MiuixHaptics.perform(MiuixHapticType.confirm);
    if (closeOnSelection && Navigator.maybeOf(context)?.canPop() == true) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = colors ?? MiuixNavigationDrawerColors.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final resolvedMargin = floating
        ? _adaptiveNonNegative(outerMargin, hyperOs4.navigationRailOuterMargin)
        : 0.0;
    final resolvedRadius = _adaptiveNonNegative(
      cornerRadius,
      floating ? hyperOs4.navigationRailCornerRadius : 0,
    );
    final safeWidth = width.isFinite
        ? width.clamp(240.0, 420.0).toDouble()
        : MiuixAdaptiveLayoutDefaults.drawerWidth;
    final selected = items.isEmpty
        ? -1
        : selectedIndex.clamp(0, items.length - 1);
    final content = SizedBox(
      width: safeWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ?header,
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = index == selected;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: TweenAnimationBuilder<double>(
                    // A destination keeps its logical index while selection
                    // retargets. Changing accessibility policy replaces the
                    // in-flight material sample with its exact endpoint.
                    key: ValueKey<Object>((
                      'miuix-navigation-drawer-row',
                      index,
                      reduceMotion,
                    )),
                    tween: Tween<double>(end: isSelected ? 1 : 0),
                    duration: reduceMotion
                        ? Duration.zero
                        : hyperOs4.navigationRailMotion,
                    curve: Curves.easeOutCubic,
                    builder: (context, selectionProgress, _) {
                      final background = Color.lerp(
                        Colors.transparent,
                        palette.selectedBackground,
                        selectionProgress,
                      )!;
                      final iconColor = Color.lerp(
                        palette.secondaryForeground,
                        palette.selectedForeground,
                        selectionProgress,
                      )!;
                      final labelColor = Color.lerp(
                        palette.foreground,
                        palette.selectedForeground,
                        selectionProgress,
                      )!;
                      return Semantics(
                        button: true,
                        selected: isSelected,
                        enabled: item.enabled,
                        label: item.label,
                        child: MiuixSurface(
                          key: ValueKey<Object>((
                            'miuix-navigation-drawer-surface',
                            index,
                          )),
                          onTap: item.enabled
                              ? () => _select(context, index)
                              : null,
                          radius: hyperOs4.navigationRailItemCornerRadius,
                          color: background,
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            16,
                            12,
                            14,
                            12,
                          ),
                          child: Row(
                            children: <Widget>[
                              IconTheme(
                                data: IconThemeData(color: iconColor, size: 24),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: <Widget>[
                                    AnimatedSwitcher(
                                      key: ValueKey<Object>((
                                        'miuix-navigation-drawer-icon',
                                        reduceMotion,
                                      )),
                                      duration: reduceMotion
                                          ? Duration.zero
                                          : hyperOs4.navigationRailMotion,
                                      switchInCurve: Curves.easeOutCubic,
                                      switchOutCurve: Curves.easeInCubic,
                                      child: KeyedSubtree(
                                        key: ValueKey<bool>(isSelected),
                                        child: isSelected
                                            ? (item.selectedIcon ?? item.icon)
                                            : item.icon,
                                      ),
                                    ),
                                    if (item.badge != null)
                                      PositionedDirectional(
                                        top: -6,
                                        end: -8,
                                        child: item.badge!,
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  item.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: labelColor,
                                        fontWeight: FontWeight.lerp(
                                          FontWeight.w500,
                                          FontWeight.w600,
                                          selectionProgress,
                                        ),
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          if (footer != null) ...<Widget>[
            Divider(height: 1, color: palette.divider),
            footer!,
          ],
        ],
      ),
    );
    final insetContent = defaultWindowInsetsPadding
        ? SafeArea(left: false, right: false, child: content)
        : content;
    final panel = glass
        ? MiuixGlass(
            key: const ValueKey('miuix-navigation-drawer-panel'),
            blur: glassBlur ?? hyperOs4.navigationRailBlur,
            opacity: glassOpacity ?? hyperOs4.navigationRailTintOpacity,
            color: palette.background,
            radius: resolvedRadius,
            padding: EdgeInsets.zero,
            showSpecular: showGlassSpecular,
            child: insetContent,
          )
        : MiuixSurface(
            key: const ValueKey('miuix-navigation-drawer-panel'),
            color: palette.background,
            radius: resolvedRadius,
            child: insetContent,
          );
    // A Scaffold body commonly supplies a tight full-window width. The
    // direction-aware outer Row releases only the drawer's horizontal axis,
    // keeping its authored panel width while stretching it to usable height.
    // Remaining width stays transparent and available to the page layer.
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          key: const ValueKey('miuix-navigation-drawer-outer'),
          padding: EdgeInsets.all(resolvedMargin),
          child: panel,
        ),
      ],
    );
  }
}

/// Responsive MIUIX page shell for Android, tablets, and Windows.
class MiuixAdaptiveScaffold extends StatefulWidget {
  /// Creates an adaptive navigation shell around one application body.
  const MiuixAdaptiveScaffold({
    super.key,
    required this.body,
    required this.items,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.topBar,
    this.navigationMode = MiuixAdaptiveNavigationMode.automatic,
    this.mediumBreakpoint = MiuixAdaptiveLayoutDefaults.mediumBreakpoint,
    this.expandedBreakpoint = MiuixAdaptiveLayoutDefaults.expandedBreakpoint,
    this.drawerHeader,
    this.drawerFooter,
    this.railHeader,
    this.glassNavigation = true,
    this.floatingBottomNavigation = true,
    this.floatingDrawer = true,
    this.backgroundColor,
    this.floatingActionButton,
    this.snackbarHost,
    this.onResolvedModeChanged,
  });

  /// Main content and navigation contract.
  final Widget body;
  final List<MiuixNavigationItem> items;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  /// Shared scaffold regions.
  final PreferredSizeWidget? topBar;
  final Widget? floatingActionButton;
  final Widget? snackbarHost;
  final Color? backgroundColor;

  /// Responsive policy and breakpoint overrides.
  final MiuixAdaptiveNavigationMode navigationMode;
  final double mediumBreakpoint;
  final double expandedBreakpoint;

  /// Optional navigation decorations.
  final Widget? drawerHeader;
  final Widget? drawerFooter;
  final Widget? railHeader;
  final bool glassNavigation;

  /// Leaves transparent content-visible clearance around the wide drawer.
  final bool floatingDrawer;

  /// Uses the HyperOS 4 local floating capsule on compact windows.
  ///
  /// Set this to false only while migrating a page that still requires the
  /// legacy full-width bottom navigation layout.
  final bool floatingBottomNavigation;

  /// Reports the mode used for the current layout pass.
  final ValueChanged<MiuixAdaptiveNavigationMode>? onResolvedModeChanged;

  @override
  State<MiuixAdaptiveScaffold> createState() => _MiuixAdaptiveScaffoldState();
}

class _MiuixAdaptiveScaffoldState extends State<MiuixAdaptiveScaffold> {
  MiuixAdaptiveNavigationMode? _reportedMode;
  MiuixAdaptiveNavigationMode? _pendingMode;

  MiuixAdaptiveNavigationMode _resolve(double width) {
    if (widget.navigationMode != MiuixAdaptiveNavigationMode.automatic) {
      return widget.navigationMode;
    }
    return MiuixAdaptiveLayoutDefaults.navigationModeFor(
      width,
      medium: widget.mediumBreakpoint,
      expanded: widget.expandedBreakpoint,
    );
  }

  /// Publishes only a newly resolved mode and collapses same-frame rebuilds.
  void _scheduleModeReport(MiuixAdaptiveNavigationMode mode) {
    if (widget.onResolvedModeChanged == null) {
      _pendingMode = null;
      return;
    }
    if (_reportedMode == mode || _pendingMode == mode) return;
    _pendingMode = mode;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _pendingMode != mode) return;
      _pendingMode = null;
      if (_reportedMode == mode) return;
      _reportedMode = mode;
      widget.onResolvedModeChanged?.call(mode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mode = _resolve(constraints.maxWidth);
        _scheduleModeReport(mode);
        final bottomBar = mode != MiuixAdaptiveNavigationMode.bottom
            ? null
            : widget.floatingBottomNavigation
            ? MiuixFloatingNavigationBar(
                items: widget.items,
                selectedIndex: widget.selectedIndex,
                onDestinationSelected: widget.onDestinationSelected,
                glass: widget.glassNavigation,
                displayMode: MiuixFloatingNavigationBarDisplayMode.iconAndText,
              )
            : MiuixNavigationBar(
                items: widget.items,
                selectedIndex: widget.selectedIndex,
                onDestinationSelected: widget.onDestinationSelected,
                glass: widget.glassNavigation,
              );
        final Widget adaptiveBody = switch (mode) {
          MiuixAdaptiveNavigationMode.bottom => widget.body,
          MiuixAdaptiveNavigationMode.rail => Row(
            children: <Widget>[
              MiuixNavigationRail(
                items: widget.items,
                selectedIndex: widget.selectedIndex,
                onDestinationSelected: widget.onDestinationSelected,
                header: widget.railHeader,
              ),
              Expanded(child: widget.body),
            ],
          ),
          MiuixAdaptiveNavigationMode.drawer => Row(
            children: <Widget>[
              MiuixNavigationDrawer(
                items: widget.items,
                selectedIndex: widget.selectedIndex,
                onDestinationSelected: widget.onDestinationSelected,
                header: widget.drawerHeader,
                footer: widget.drawerFooter,
                glass: widget.glassNavigation,
                floating: widget.floatingDrawer,
              ),
              Expanded(child: widget.body),
            ],
          ),
          MiuixAdaptiveNavigationMode.automatic => widget.body,
        };
        return MiuixScaffold(
          topBar: widget.topBar,
          body: adaptiveBody,
          bottomBar: bottomBar,
          floatingActionButton: widget.floatingActionButton,
          snackbarHost: widget.snackbarHost,
          backgroundColor: widget.backgroundColor,
        );
      },
    );
  }
}

double _adaptiveNonNegative(double? value, double fallback) =>
    value != null && value.isFinite && value >= 0 ? value : fallback;

/// Direction used by a [MiuixSplitView].
enum MiuixSplitViewDirection { horizontal, vertical }

/// Mutable divider state shared by split and resizable pane widgets.
class MiuixSplitViewController extends ChangeNotifier {
  /// Creates a controller with the desired leading-pane extent.
  MiuixSplitViewController({double primaryExtent = 320})
    : _primaryExtent = primaryExtent;

  double _primaryExtent;
  bool _collapsed = false;

  /// Current requested primary extent in logical pixels.
  double get primaryExtent => _primaryExtent;

  /// Whether the primary pane is collapsed.
  bool get collapsed => _collapsed;

  /// Updates the requested primary pane extent.
  set primaryExtent(double value) {
    if (!value.isFinite || (_primaryExtent - value).abs() < .01) return;
    _primaryExtent = value;
    _collapsed = false;
    notifyListeners();
  }

  /// Collapses the primary pane without discarding its last extent.
  void collapse() {
    if (_collapsed) return;
    _collapsed = true;
    notifyListeners();
  }

  /// Restores the primary pane to its previous extent.
  void expand() {
    if (!_collapsed) return;
    _collapsed = false;
    notifyListeners();
  }

  /// Switches between collapsed and expanded states.
  void toggle() => _collapsed ? expand() : collapse();
}

/// Defaults for master-detail and resizable pane layouts.
abstract final class MiuixSplitViewDefaults {
  // Split-view interaction contract:
  // - The primary pane always occupies logical start or logical top.
  // - Horizontal pointer delta mirrors under right-to-left directionality.
  // - Vertical pointer delta is independent from text direction.
  // - Horizontal layouts install only left and right keyboard shortcuts.
  // - Vertical layouts install only up and down keyboard shortcuts.
  // - Accessibility increase always means a larger primary pane.
  // - Accessibility decrease always means a smaller primary pane.
  // - A non-resizable divider is visual decoration rather than a control.
  // - Decorative dividers do not form a TalkBack traversal stop.
  // - Decorative dividers do not expose slider increment actions.
  // - Collapsed layouts remove the divider and its complete semantics.
  // - A controller replacement ends the old direct-manipulation sample.
  // - A direction change ends the old axis-specific drag sample.
  // - Disabling resizing ends the old direct-manipulation sample.
  // - Caller-owned controllers are never disposed by the split view.
  // - Internally owned controllers are released during replacement/disposal.
  // - The external controller remains the desired, unconstrained size owner.
  // - Host shrink may temporarily project that desire to a smaller extent.
  // - Host growth reapplies the retained desired extent where legal.
  // - The secondary minimum takes priority in an inconsistent compact host.
  // - Clamp intervals are made ordered before Dart numeric clamping.
  // - Hidden visual dividers reserve no unexplained layout thickness.
  // - Pointer changes publish only actual constrained extent differences.
  // - Keyboard changes share the same constraint and callback path.
  // - Edge haptics emit once per arrival rather than once per pointer frame.
  // - Direct manipulation removes animation lag under the live pointer.
  // - Programmatic controller changes retain inline-surface motion.
  // - Reduced-motion mode resolves every geometry change immediately.
  // - Fixed dividers retain an ordinary basic mouse cursor.
  // - Adjustable horizontal dividers expose a column-resize cursor.
  // - Adjustable vertical dividers expose a row-resize cursor.
  // - Primary content is removed from layout at a true zero extent.
  // - Secondary content remains present throughout collapse and resize.
  // These rules are reusable behavior, not unpublished Xiaomi measurements.

  /// Default leading-pane dimensions.
  static const double primaryExtent = 320;
  static const double minimumPrimaryExtent = 220;
  static const double minimumSecondaryExtent = 280;

  /// Visual divider and pointer hit-target dimensions.
  static const double dividerThickness = .75;
  static const double dividerHitExtent = 12;

  /// Keyboard movement step for an accessible divider.
  static const double keyboardStep = 24;
}

/// Resizable MIUIX master-detail layout with touch and keyboard control.
class MiuixSplitView extends StatefulWidget {
  /// Creates a split view whose primary pane occupies the logical start/top.
  const MiuixSplitView({
    super.key,
    required this.primary,
    required this.secondary,
    this.controller,
    this.direction = MiuixSplitViewDirection.horizontal,
    this.initialPrimaryExtent = MiuixSplitViewDefaults.primaryExtent,
    this.minimumPrimaryExtent = MiuixSplitViewDefaults.minimumPrimaryExtent,
    this.maximumPrimaryExtent = double.infinity,
    this.minimumSecondaryExtent = MiuixSplitViewDefaults.minimumSecondaryExtent,
    this.resizable = true,
    this.showDivider = true,
    this.onExtentChanged,
  });

  /// Pane content.
  final Widget primary;
  final Widget secondary;

  /// Optional externally owned divider state.
  final MiuixSplitViewController? controller;
  final MiuixSplitViewDirection direction;

  /// Divider constraints.
  final double initialPrimaryExtent;
  final double minimumPrimaryExtent;
  final double maximumPrimaryExtent;
  final double minimumSecondaryExtent;
  final bool resizable;
  final bool showDivider;

  /// Reports the constrained extent after pointer or keyboard movement.
  final ValueChanged<double>? onExtentChanged;

  @override
  State<MiuixSplitView> createState() => _MiuixSplitViewState();
}

class _MiuixSplitViewState extends State<MiuixSplitView> {
  late MiuixSplitViewController _controller;
  late bool _ownsController;
  bool _announcedMinimum = false;
  bool _announcedMaximum = false;
  bool _draggingDivider = false;

  @override
  void initState() {
    super.initState();
    _attachController();
  }

  void _attachController() {
    _ownsController = widget.controller == null;
    _controller =
        widget.controller ??
        MiuixSplitViewController(primaryExtent: widget.initialPrimaryExtent);
    _controller.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(MiuixSplitView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _controller.removeListener(_rebuild);
      if (_ownsController) _controller.dispose();
      _attachController();
      _draggingDivider = false;
    }
    if (oldWidget.direction != widget.direction ||
        oldWidget.resizable != widget.resizable) {
      _draggingDivider = false;
    }
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  void _setDividerDragging(bool value) {
    if (_draggingDivider == value || !mounted) return;
    setState(() => _draggingDivider = value);
  }

  @override
  void dispose() {
    _controller.removeListener(_rebuild);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  double _constrain(double requested, double total) {
    // Split constraints can become temporarily inconsistent while a desktop
    // window is being resized: the new total extent may arrive before a parent
    // rebuild supplies smaller pane minima. Layout must still produce a frame.
    //
    // The primary pane yields first because the secondary minimum expresses a
    // content requirement. Once the host grows again, the controller's desired
    // extent is re-applied through the same authored min/max constraints.
    //
    // Divider thickness participates only when it is painted. Reserving hidden
    // divider space would create an unexplained gap and a different drag range.
    final visualDivider = widget.showDivider
        ? MiuixSplitViewDefaults.dividerThickness
        : 0.0;
    // A compact host can be narrower than the authored secondary minimum.
    // Treat that as a zero-width primary pane instead of constructing an
    // inverted clamp range and throwing during layout.
    final availableMaximum = math.max(
      0.0,
      total - widget.minimumSecondaryExtent - visualDivider,
    );
    final configuredMaximum = widget.maximumPrimaryExtent.isFinite
        ? widget.maximumPrimaryExtent
        : availableMaximum;
    final maximum = configuredMaximum.clamp(0.0, availableMaximum).toDouble();
    // Clamp the minimum after the maximum is made feasible. Dart's num.clamp
    // requires an ordered interval, so this ordering is part of crash safety,
    // not merely equivalent arithmetic.
    final minimum = widget.minimumPrimaryExtent.clamp(0.0, maximum).toDouble();
    return requested.clamp(minimum, maximum).toDouble();
  }

  void _changeBy(double delta, double total) {
    if (!widget.resizable || _controller.collapsed) return;
    final current = _constrain(_controller.primaryExtent, total);
    final next = _constrain(current + delta, total);
    if ((next - current).abs() < .01) return;
    _controller.primaryExtent = next;
    widget.onExtentChanged?.call(next);

    // Haptic feedback is emitted once at each edge, not for every drag frame.
    final atMinimum = next <= widget.minimumPrimaryExtent + .01;
    final atMaximum = next >= _constrain(double.infinity, total) - .01;
    if (atMinimum && !_announcedMinimum || atMaximum && !_announcedMaximum) {
      MiuixHaptics.perform(MiuixHapticType.gestureThresholdActivate);
    }
    _announcedMinimum = atMinimum;
    _announcedMaximum = atMaximum;
  }

  Widget _divider(BuildContext context, double total) {
    final horizontal = widget.direction == MiuixSplitViewDirection.horizontal;
    final color = MiuixSemanticColors.of(context)['dividerLine'];
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final adjustable = widget.resizable && !_controller.collapsed;
    final shortcuts = horizontal
        ? <ShortcutActivator, Intent>{
            const SingleActivator(LogicalKeyboardKey.arrowLeft):
                const _MoveSplitDividerIntent(-1),
            const SingleActivator(LogicalKeyboardKey.arrowRight):
                const _MoveSplitDividerIntent(1),
          }
        : <ShortcutActivator, Intent>{
            const SingleActivator(LogicalKeyboardKey.arrowUp):
                const _MoveSplitDividerIntent(-1),
            const SingleActivator(LogicalKeyboardKey.arrowDown):
                const _MoveSplitDividerIntent(1),
          };
    return Semantics(
      // The adjustable divider must form its own accessibility boundary.
      // Without a container Android merges the slider role upward with the
      // surrounding section and announces unrelated navigation, titles, and
      // body content as one window-sized SeekBar.
      container: adjustable,
      excludeSemantics: adjustable,
      label: adjustable ? '调整分栏大小' : null,
      slider: adjustable,
      enabled: adjustable,
      value: adjustable
          ? '${_constrain(_controller.primaryExtent, total).round()}'
          : null,
      increasedValue: adjustable ? '增大主面板' : null,
      decreasedValue: adjustable ? '减小主面板' : null,
      onIncrease: adjustable
          ? () => _changeBy(MiuixSplitViewDefaults.keyboardStep, total)
          : null,
      onDecrease: adjustable
          ? () => _changeBy(-MiuixSplitViewDefaults.keyboardStep, total)
          : null,
      child: Shortcuts(
        shortcuts: shortcuts,
        child: Actions(
          actions: <Type, Action<Intent>>{
            _MoveSplitDividerIntent: CallbackAction<_MoveSplitDividerIntent>(
              onInvoke: (intent) {
                var sign = intent.sign;
                if (horizontal && rtl) sign = -sign;
                _changeBy(sign * MiuixSplitViewDefaults.keyboardStep, total);
                return null;
              },
            ),
          },
          child: Focus(
            canRequestFocus: adjustable,
            child: MouseRegion(
              cursor: !widget.resizable
                  ? SystemMouseCursors.basic
                  : horizontal
                  ? SystemMouseCursors.resizeColumn
                  : SystemMouseCursors.resizeRow,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragStart: horizontal && widget.resizable
                    ? (_) => _setDividerDragging(true)
                    : null,
                onHorizontalDragUpdate: horizontal && widget.resizable
                    ? (details) {
                        final direction = rtl ? -1.0 : 1.0;
                        _changeBy(details.delta.dx * direction, total);
                      }
                    : null,
                onHorizontalDragEnd: horizontal && widget.resizable
                    ? (_) => _setDividerDragging(false)
                    : null,
                onHorizontalDragCancel: horizontal && widget.resizable
                    ? () => _setDividerDragging(false)
                    : null,
                onVerticalDragStart: !horizontal && widget.resizable
                    ? (_) => _setDividerDragging(true)
                    : null,
                onVerticalDragUpdate: !horizontal && widget.resizable
                    ? (details) => _changeBy(details.delta.dy, total)
                    : null,
                onVerticalDragEnd: !horizontal && widget.resizable
                    ? (_) => _setDividerDragging(false)
                    : null,
                onVerticalDragCancel: !horizontal && widget.resizable
                    ? () => _setDividerDragging(false)
                    : null,
                child: SizedBox(
                  width: horizontal
                      ? MiuixSplitViewDefaults.dividerHitExtent
                      : null,
                  height: horizontal
                      ? null
                      : MiuixSplitViewDefaults.dividerHitExtent,
                  child: Center(
                    child: ColoredBox(
                      color: widget.showDivider ? color : Colors.transparent,
                      child: SizedBox(
                        width: horizontal
                            ? MiuixSplitViewDefaults.dividerThickness
                            : double.infinity,
                        height: horizontal
                            ? double.infinity
                            : MiuixSplitViewDefaults.dividerThickness,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontal =
            widget.direction == MiuixSplitViewDirection.horizontal;
        final total = horizontal ? constraints.maxWidth : constraints.maxHeight;
        if (!total.isFinite || total <= 0) {
          return horizontal
              ? Row(children: <Widget>[Expanded(child: widget.secondary)])
              : Column(children: <Widget>[Expanded(child: widget.secondary)]);
        }
        final extent = _controller.collapsed
            ? 0.0
            : _constrain(_controller.primaryExtent, total);
        final reduceMotion = MediaQuery.disableAnimationsOf(context);
        final directMotion = _draggingDivider || reduceMotion;
        final primary = AnimatedContainer(
          // Pointer resizing follows the divider one-for-one. Programmatic
          // extent changes and collapse/expand retain the polished transition.
          key: ValueKey<bool>(directMotion),
          duration: directMotion
              ? Duration.zero
              : MiuixTheme.of(context).hyperOs4.inlineSurfaceMotion,
          curve: Curves.easeOutCubic,
          width: horizontal ? extent : null,
          height: horizontal ? null : extent,
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(),
          child: extent == 0 ? const SizedBox.shrink() : widget.primary,
        );
        final children = <Widget>[
          primary,
          if (!_controller.collapsed) _divider(context, total),
          Expanded(child: widget.secondary),
        ];
        return horizontal
            ? Row(children: children)
            : Column(children: children);
      },
    );
  }
}

/// Convenience name for a two-pane resizable workspace.
class MiuixResizablePane extends MiuixSplitView {
  /// Creates a horizontal resizable pane.
  const MiuixResizablePane({
    super.key,
    required super.primary,
    required super.secondary,
    super.controller,
    super.initialPrimaryExtent,
    super.minimumPrimaryExtent,
    super.maximumPrimaryExtent,
    super.minimumSecondaryExtent,
    super.resizable,
    super.showDivider,
    super.onExtentChanged,
  }) : super(direction: MiuixSplitViewDirection.horizontal);
}

class _MoveSplitDividerIntent extends Intent {
  const _MoveSplitDividerIntent(this.sign);

  final int sign;
}
