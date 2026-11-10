part of '../miuix_widgets.dart';

/// Source display modes for the MIUIX wide-screen navigation rail.
enum MiuixNavigationRailDisplayMode {
  /// Show a 28dp icon with a 12sp label.
  iconAndText,

  /// Show only the icon.
  iconOnly,

  /// Show only a 14sp label.
  textOnly,

  /// Keep every icon and reveal the label only for the selected destination.
  iconWithSelectedLabel,
}

/// Expansion values from current MIUIX `NavigationRailValue`.
enum MiuixNavigationRailValue {
  /// Keep the rail at its compact 80dp width.
  collapsed,

  /// Expand the rail to its 240dp icon-and-label presentation.
  expanded,
}

/// State holder controlling current expandable navigation rails.
///
/// Passing one instance to [MiuixNavigationRail] installs the built-in toggle
/// and switches destinations onto the source's continuous morphing layout.
/// Omitting it preserves the classic non-expandable rail.
class MiuixNavigationRailState extends ChangeNotifier {
  /// Creates a navigation rail state at [initialValue].
  MiuixNavigationRailState({
    MiuixNavigationRailValue initialValue = MiuixNavigationRailValue.collapsed,
  }) : _currentValue = initialValue;

  MiuixNavigationRailValue _currentValue;

  /// Current stable expansion target.
  MiuixNavigationRailValue get currentValue => _currentValue;

  /// Whether the target state is expanded.
  bool get isExpanded => _currentValue == MiuixNavigationRailValue.expanded;

  /// Animates the attached rail toward its expanded presentation.
  void expand() => _setValue(MiuixNavigationRailValue.expanded);

  /// Animates the attached rail toward its collapsed presentation.
  void collapse() => _setValue(MiuixNavigationRailValue.collapsed);

  /// Switches between [expanded] and [collapsed].
  void toggle() => _setValue(
    isExpanded
        ? MiuixNavigationRailValue.collapsed
        : MiuixNavigationRailValue.expanded,
  );

  void _setValue(MiuixNavigationRailValue value) {
    if (_currentValue == value) return;
    _currentValue = value;
    notifyListeners();
  }
}

/// Exact values exposed by upstream `NavigationRailDefaults`.
abstract final class MiuixNavigationRailDefaults {
  /// Default width of the rail column, excluding its optional divider.
  static const double minWidth = 80;

  /// Width of an expandable rail at its expanded rest state.
  static const double expandedWidth = 240;

  /// Vertical padding around the complete scrollable rail content.
  static const double verticalPadding = 24;

  /// Space inserted after a non-null header.
  static const double headerSpacing = 24;

  /// Width and height of every source icon.
  static const double iconSize = 28;

  /// Space between an icon and its visible label.
  static const double iconTextSpacing = 4;

  /// Vertical padding applied outside every destination.
  static const double itemVerticalPadding = 12;

  /// Font size of labels in icon-and-text modes.
  static const double labelFontSize = 12;

  /// Label size at the expanded endpoint.
  static const double expandedLabelFontSize = 16;

  /// Horizontal margin around each expanded destination pill.
  static const double expandedItemHorizontalMargin = 12;

  /// Smooth-corner radius of the selected destination pill.
  static const double expandedItemCornerRadius = 16;

  /// Vertical indicator padding around a collapsed icon.
  static const double collapsedIndicatorVerticalPadding = 4;

  /// Horizontal content inset keeping both endpoint icon baselines aligned.
  static const double expandedItemContentHorizontalPadding = 14;

  /// Vertical content padding inside the expanded destination pill.
  static const double expandedItemContentVerticalPadding = 14;

  /// Icon-to-label spacing at the expanded endpoint.
  static const double expandedItemIconTextSpacing = 16;

  /// Font size used by text-only mode.
  static const double textOnlyFontSize = 14;

  /// Extra vertical padding around a text-only label.
  static const double textOnlyVerticalPadding = 4;

  /// Selected destination alpha while pressed.
  static const double selectedPressedAlpha = .5;

  /// Unselected destination alpha while pressed.
  static const double unselectedPressedAlpha = .6;

  /// Idle alpha of an unselected destination.
  static const double unselectedAlpha = .4;

  /// Safe fallback for a malformed HyperOS selection wash token.
  static const double selectionTintOpacity = .08;
}

/// Default `animateContentSize` spring used by rail destinations.
@visibleForTesting
SpringDescription debugMiuixNavigationRailSizeSpring() =>
    SpringDescription.withDampingRatio(mass: 1, stiffness: 400, ratio: 1);

/// Exact `folmeSpring(damping = 1, response = 0.35)` rail expansion spring.
@visibleForTesting
SpringDescription debugMiuixNavigationRailExpandSpring() {
  const response = .35;
  const angularFrequency = 2 * math.pi / response;
  return SpringDescription.withDampingRatio(
    mass: 1,
    stiffness: angularFrequency * angularFrequency,
    ratio: 1,
  );
}

/// Current `MiuixIndication` spring used by rail press enter or release.
@visibleForTesting
SpringDescription debugMiuixNavigationRailIndicationSpring({
  required bool entering,
}) {
  final response = entering ? .2 : .35;
  final frequency = 2 * math.pi / response;
  return SpringDescription.withDampingRatio(
    mass: 1,
    stiffness: frequency * frequency,
    ratio: entering ? 1 : .95,
  );
}

/// Inherited counterpart of upstream `LocalNavigationRailDisplayMode`.
class _MiuixNavigationRailDisplayModeScope extends InheritedWidget {
  const _MiuixNavigationRailDisplayModeScope({
    required this.mode,
    required super.child,
  });

  final MiuixNavigationRailDisplayMode mode;

  static MiuixNavigationRailDisplayMode of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<
              _MiuixNavigationRailDisplayModeScope
            >()
            ?.mode ??
        MiuixNavigationRailDisplayMode.iconAndText;
  }

  @override
  bool updateShouldNotify(_MiuixNavigationRailDisplayModeScope oldWidget) {
    return mode != oldWidget.mode;
  }
}

/// Adaptive side navigation for wide HyperOS 4 application layouts.
///
/// Source geometry is intentionally expressed as separate placeables:
///
/// - the rail column owns an 80dp default width;
/// - the optional divider is a following 0.75dp canvas;
/// - the divider therefore increases total occupied width to 80.75dp;
/// - the column owns 24dp vertical content padding;
/// - an optional header is followed by a separate 24dp spacer;
/// - every item owns 12dp vertical outer padding;
/// - the complete column scrolls when its content exceeds the window.
///
/// The earlier adapter used a half-dp decoration border inside an 80dp box.
/// That made the pager begin 0.75dp too early and painted the wrong semantic
/// color. Keeping [MiuixVerticalDivider] as a sibling follows the original
/// Compose Row measurement and preserves its density-aware fractional raster.
///
/// Source paint and interaction contract:
///
/// - the background is the opaque `surface` token;
/// - selected content uses `onSurfaceContainer`;
/// - unselected content uses that token at 0.4 alpha;
/// - selected pressed content uses 0.5 alpha;
/// - unselected pressed content uses 0.6 alpha;
/// - disabled destinations retain idle tint without accepting input;
/// - compact destinations do not paint a selection capsule;
/// - compact destinations do not scale or ripple on press;
/// - no tooltip is synthesized around the source item.
class MiuixNavigationRail extends StatelessWidget {
  /// Creates a local HyperOS 4 glass navigation rail.
  const MiuixNavigationRail({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.header,
    this.color,
    this.selectedContentColor,
    this.selectedBackgroundColor,
    this.showDivider = false,
    this.defaultWindowInsetsPadding = true,
    this.glass = true,
    this.state,
    this.extended = false,
    this.displayMode = MiuixNavigationRailDisplayMode.iconAndText,
    this.minWidth = MiuixNavigationRailDefaults.minWidth,
    this.expandedWidth = MiuixNavigationRailDefaults.expandedWidth,
    this.expandContentDescription = '展开导航栏',
    this.collapseContentDescription = '折叠导航栏',
  }) : sourceChildren = null,
       _source = false;

  /// Creates the original arbitrary-content `NavigationRail` parameter form.
  const MiuixNavigationRail.source({
    super.key,
    this.header,
    this.color,
    this.showDivider = true,
    this.defaultWindowInsetsPadding = true,
    this.state,
    this.minWidth = MiuixNavigationRailDefaults.minWidth,
    this.expandedWidth = MiuixNavigationRailDefaults.expandedWidth,
    this.expandContentDescription = '展开导航栏',
    this.collapseContentDescription = '折叠导航栏',
    MiuixNavigationRailDisplayMode mode =
        MiuixNavigationRailDisplayMode.iconAndText,
    required List<Widget> children,
  }) : items = const [],
       selectedIndex = -1,
       onDestinationSelected = null,
       extended = false,
       displayMode = mode,
       sourceChildren = children,
       glass = false,
       selectedContentColor = null,
       selectedBackgroundColor = null,
       _source = true;

  /// Creates the old MIUIX data-driven rail for pixel migration work.
  ///
  /// Unlike [source], this accepts [MiuixNavigationItem] values. It exists so
  /// applications can retain the previous opaque 80dp/240dp layout explicitly
  /// while the ordinary constructor advances to the HyperOS 4 default.
  const MiuixNavigationRail.sourceItems({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.header,
    this.color,
    this.showDivider = true,
    this.defaultWindowInsetsPadding = true,
    this.state,
    this.extended = false,
    this.displayMode = MiuixNavigationRailDisplayMode.iconAndText,
    this.minWidth = MiuixNavigationRailDefaults.minWidth,
    this.expandedWidth = MiuixNavigationRailDefaults.expandedWidth,
    this.expandContentDescription = '展开导航栏',
    this.collapseContentDescription = '折叠导航栏',
  }) : sourceChildren = null,
       glass = false,
       selectedContentColor = null,
       selectedBackgroundColor = null,
       _source = true;

  /// Destination list.
  final List<MiuixNavigationItem> items;

  /// Current selected index.
  final int selectedIndex;

  /// Selection callback.
  final ValueChanged<int>? onDestinationSelected;

  /// Arbitrary source content slots, normally [MiuixNavigationRailItem]s.
  final List<Widget>? sourceChildren;

  /// Optional source header, usually a logo or floating action button.
  final Widget? header;

  /// Rail background; defaults to the exact opaque surface token.
  final Color? color;

  /// 显式选中前景；与 [selectedBackgroundColor] 配对使用，默认沿用主题。
  final Color? selectedContentColor;

  /// 显式选中填充，不自动添加透明度；空值保留默认玻璃选中态。
  /// 指定时覆盖图标和标签的完整点击单元，确保黑白主题标签也可读。
  final Color? selectedBackgroundColor;

  /// Whether to append the source 0.75dp vertical divider.
  final bool showDivider;

  /// Whether to consume status-bar and logical-start window insets.
  ///
  /// The source consumes status bars vertically and cutout/navigation bars on
  /// the start side. It does not consume the ordinary bottom gesture inset.
  final bool defaultWindowInsetsPadding;

  /// Whether the ordinary rail samples content behind its clipped surface.
  ///
  /// This only changes the HyperOS 4 constructor. Source constructors remain
  /// opaque because their purpose is visual compatibility with MIUIX.
  final bool glass;

  /// Optional source state; non-null enables the built-in expandable rail.
  final MiuixNavigationRailState? state;

  /// Whether to show the legacy extended compatibility presentation.
  ///
  /// Upstream v1.0.9 exposes only the compact rail plus [displayMode].
  /// This flag remains so existing Flutter consumers are not broken.
  final bool extended;

  /// Icon and label visibility mode.
  final MiuixNavigationRailDisplayMode displayMode;

  /// Source minimum column width.
  final double minWidth;

  /// Expanded width, coerced to at least [minWidth].
  final double expandedWidth;

  /// Accessible action announced by the built-in collapsed toggle.
  final String expandContentDescription;

  /// Accessible action announced by the built-in expanded toggle.
  final String collapseContentDescription;

  /// Selects the exact legacy geometry and surface contract.
  final bool _source;

  @override
  Widget build(BuildContext context) => _MiuixNavigationRailColors(
    foreground: selectedContentColor,
    background: selectedBackgroundColor,
    child: _MiuixNavigationRailLayout(rail: this),
  );
}

/// Source `NavigationRailItem` widget.
///
/// Unlike [MiuixNavigationItem], this is rendered content with controlled
/// selection and click behavior. Its mode comes from the nearest
/// [MiuixNavigationRail.source], matching the source composition local.
class MiuixNavigationRailItem extends StatelessWidget {
  /// Creates one source rail destination.
  const MiuixNavigationRailItem({
    super.key,
    required this.selected,
    required this.onClick,
    required this.icon,
    required this.label,
    this.enabled = true,
    this.badge,
  });

  /// Whether the destination is selected.
  final bool selected;

  /// Invoked after a completed enabled tap.
  final VoidCallback onClick;

  /// Source icon artwork.
  final Widget icon;

  /// Visible label and icon description.
  final String label;

  /// Whether pointer interaction is accepted.
  final bool enabled;

  /// Optional source badge painted against the icon.
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    return _MiuixNavigationRailItem(
      item: MiuixNavigationItem(
        icon: icon,
        label: label,
        enabled: enabled,
        badge: badge,
      ),
      selected: selected,
      extended: false,
      sourceStyle: true,
      sourceSemantics: true,
      displayMode: _MiuixNavigationRailDisplayModeScope.of(context),
      onTap: onClick,
    );
  }
}

/// One source rail destination with pointer-driven tint feedback.
///
/// MIUIX changes tint only while a pointer is held:
///
/// - selected idle alpha is 1.0;
/// - unselected idle alpha is 0.4;
/// - selected pressed alpha is 0.5;
/// - unselected pressed alpha is 0.6.
///
/// No sink scale, ripple, tooltip, or selected background is added to the
/// compact source branch. The legacy extended branch retains its old selected
/// container solely for Flutter API compatibility.
class _MiuixNavigationRailItem extends StatefulWidget {
  const _MiuixNavigationRailItem({
    super.key,
    required this.item,
    required this.selected,
    required this.extended,
    required this.sourceStyle,
    required this.sourceSemantics,
    required this.displayMode,
    required this.onTap,
  });

  /// Shared navigation destination.
  final MiuixNavigationItem item;

  /// Whether this is the active destination.
  final bool selected;

  /// Whether to render the non-source compatibility branch.
  final bool extended;

  /// Whether this item retains the current MIUIX source paint contract.
  final bool sourceStyle;

  /// Whether to preserve the source Image-only accessibility contract.
  final bool sourceSemantics;

  /// Current source display mode.
  final MiuixNavigationRailDisplayMode displayMode;

  /// Callback invoked after a completed enabled tap.
  final VoidCallback onTap;

  @override
  State<_MiuixNavigationRailItem> createState() =>
      _MiuixNavigationRailItemState();
}

class _MiuixNavigationRailItemState extends State<_MiuixNavigationRailItem>
    with SingleTickerProviderStateMixin {
  /// Transient source pointer state.
  bool _pressed = false;

  /// Exact rectangular `MiuixIndication` alpha used by current rail items.
  late final AnimationController _sourceIndication;

  /// Positive source indication that a release must allow to finish first.
  TickerFuture? _positiveIndicationAnimation;

  /// Invalidates a queued release when newer pointer input takes ownership.
  int _indicationRevision = 0;

  /// Cached accessibility preference used by pointer and size animations.
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    // Eager creation matters: a lazy initializer first read from `dispose`
    // would ask TickerMode for an ancestor after this element was deactivated.
    _sourceIndication = AnimationController.unbounded(vsync: this);
  }

  @override
  void didUpdateWidget(covariant _MiuixNavigationRailItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.enabled && !widget.item.enabled) {
      _pressed = false;
      _sourceIndication
        ..stop()
        ..value = 0;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextReduceMotion = MediaQuery.disableAnimationsOf(context);
    if (nextReduceMotion == _reduceMotion) return;
    _reduceMotion = nextReduceMotion;
    if (_reduceMotion) {
      _sourceIndication
        ..stop(canceled: true)
        ..value = _pressed ? .1 : 0;
    }
  }

  /// Updates tint without introducing an unrelated scale animation.
  void _setPressed(bool value) {
    if (_pressed != value && mounted) {
      setState(() => _pressed = value);
      final revision = ++_indicationRevision;
      if (_reduceMotion) {
        _sourceIndication
          ..stop(canceled: true)
          ..value = value ? .1 : 0;
        return;
      }
      if (value) {
        final carriedVelocity = _sourceIndication.velocity;
        _sourceIndication.stop(canceled: true);
        _positiveIndicationAnimation = _sourceIndication.animateWith(
          SpringSimulation(
            debugMiuixNavigationRailIndicationSpring(entering: true),
            _sourceIndication.value,
            .1,
            carriedVelocity,
            tolerance: const Tolerance(distance: .0001, velocity: .0001),
          ),
        );
        return;
      }
      final positiveAnimation = _positiveIndicationAnimation;
      () async {
        try {
          // Current MiuixIndication joins the press-enter job before running
          // PressExit, so even a short tap reaches the authored 10% overlay.
          await positiveAnimation?.orCancel;
        } catch (_) {
          // A newer press deliberately cancels this queued rest transition.
        }
        if (!mounted || revision != _indicationRevision || _pressed) return;
        _sourceIndication.animateWith(
          SpringSimulation(
            debugMiuixNavigationRailIndicationSpring(entering: false),
            _sourceIndication.value,
            0,
            _sourceIndication.velocity,
            tolerance: const Tolerance(distance: .0001, velocity: .0001),
          ),
        );
      }();
    }
  }

  @override
  void dispose() {
    _sourceIndication.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expandInfo = _MiuixNavigationRailExpandScope.maybeOf(context);
    if (!widget.extended && expandInfo != null) {
      return _MiuixExpandableNavigationRailItem(
        info: expandInfo,
        item: widget.item,
        selected: widget.selected,
        sourceStyle: widget.sourceStyle,
        indication: _sourceIndication,
        onTap: widget.onTap,
        onPressedChanged: _setPressed,
        pressed: _pressed,
      );
    }
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final semanticBase = MiuixSemanticColors.of(context)['onSurfaceContainer'];
    final supplied = _MiuixNavigationRailColors.maybeOf(context);
    // 普通侧栏和底部胶囊共用配对层，source 仍保留历史语义。
    final layers = widget.sourceStyle
        ? null
        : MiuixAccentLayers.maybeOf(context);
    final selectedContent =
        supplied?.foreground ??
        layers?.navigationForeground ??
        (theme.brightness == Brightness.dark
            ? scheme.onPrimaryContainer
            : scheme.primary);
    final base = widget.selected && supplied?.foreground != null
        ? supplied!.foreground!
        : widget.sourceStyle
        ? semanticBase
        : widget.selected
        ? selectedContent
        : layers?.navigationUnselectedForeground ?? scheme.onSurfaceVariant;
    // 已校准的可用文字不能再乘旧的未选透明度，否则会退回禁用灰字。
    // 未安装角色扩展的宿主仍保留原有样式及按压反馈。
    final calibratedInk =
        !widget.selected && layers?.navigationUnselectedForeground != null;
    // Current state-null NavigationRailItem has one medium-weight tint and a
    // rectangular MiuixIndication. Preserve the old alpha/weight behavior only
    // for the explicit Flutter compatibility display modes/data constructor.
    final sourceCurrentClassic =
        widget.sourceSemantics &&
        widget.displayMode == MiuixNavigationRailDisplayMode.iconAndText;
    final tint = sourceCurrentClassic || calibratedInk
        ? base
        : _pressed
        ? base.withValues(
            alpha: widget.selected
                ? MiuixNavigationRailDefaults.selectedPressedAlpha
                : MiuixNavigationRailDefaults.unselectedPressedAlpha,
          )
        : widget.selected
        ? base
        : base.withValues(alpha: MiuixNavigationRailDefaults.unselectedAlpha);
    Widget buildCurrentIcon({double? sourceItemWidth}) {
      const iconSize = MiuixNavigationRailDefaults.iconSize;
      final iconAnchor = SizedBox.square(
        dimension: iconSize,
        child: FittedBox(
          fit: BoxFit.contain,
          child: IconTheme(
            data: IconThemeData(color: tint, size: iconSize),
            // NavigationRail.kt accepts one ImageVector and tints that same
            // vector for every state. Do not substitute a bottom-bar selected
            // glyph here.
            child: widget.sourceStyle
                ? widget.item.icon
                : widget.selected
                ? widget.item.selectedIcon ?? widget.item.icon
                : widget.item.icon,
          ),
        ),
      );
      final sourceBounds = sourceItemWidth == null
          ? null
          : Rect.fromLTRB(
              -(sourceItemWidth - iconSize) / 2,
              -MiuixNavigationRailDefaults.itemVerticalPadding,
              (sourceItemWidth + iconSize) / 2,
              double.infinity,
            );
      return _miuixNavigationIconWithBadge(
        icon: MiuixIconInteraction(
          navigation: true,
          enabled: widget.item.enabled,
          pressed: _pressed,
          selected: widget.selected,
          child: iconAnchor,
        ),
        badge: widget.item.badge,
        sourceBounds: sourceBounds,
      );
    }

    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: tint,
      fontSize: widget.displayMode == MiuixNavigationRailDisplayMode.textOnly
          ? MiuixNavigationRailDefaults.textOnlyFontSize
          : MiuixNavigationRailDefaults.labelFontSize,
      fontWeight: sourceCurrentClassic
          ? FontWeight.w500
          : widget.selected
          ? widget.sourceStyle
                ? FontWeight.w700
                : FontWeight.w600
          : FontWeight.w400,
    );
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final selectionTintOpacity =
        hyperOs4.navigationRailSelectionTintOpacity.isFinite
        ? hyperOs4.navigationRailSelectionTintOpacity.clamp(0.0, 1.0)
        : MiuixNavigationRailDefaults.selectionTintOpacity;
    final itemMotion = _reduceMotion
        ? Duration.zero
        : hyperOs4.navigationRailMotion;
    final sourceOuterPadding = EdgeInsets.symmetric(
      horizontal: widget.extended ? 12 : 0,
      vertical: MiuixNavigationRailDefaults.itemVerticalPadding,
    );
    const hyperOuterPadding = EdgeInsets.symmetric(horizontal: 8, vertical: 4);
    final gesture = GestureDetector(
      excludeFromSemantics: widget.sourceSemantics,
      behavior: HitTestBehavior.opaque,
      onTap: widget.item.enabled ? widget.onTap : null,
      onTapDown: widget.item.enabled ? (_) => _setPressed(true) : null,
      onTapUp: widget.item.enabled ? (_) => _setPressed(false) : null,
      onTapCancel: widget.item.enabled ? () => _setPressed(false) : null,
      child: Padding(
        padding: widget.sourceStyle ? sourceOuterPadding : hyperOuterPadding,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // The current source applies badgeBounds() before its vertical
            // item padding. Convert the full destination top/end into the
            // centered icon's local coordinates. The historical extended rail
            // is a Flutter-only compatibility branch and remains unbounded.
            final currentIcon = buildCurrentIcon(
              sourceItemWidth: !widget.extended && constraints.maxWidth.isFinite
                  ? constraints.maxWidth
                  : null,
            );
            final content = widget.extended
                ? _buildExtendedContent(
                    context,
                    currentIcon: currentIcon,
                    tint: tint,
                  )
                : _buildSourceContent(
                    currentIcon: currentIcon,
                    labelStyle: labelStyle,
                  );
            return SizedBox(
              width: double.infinity,
              child: _MiuixRailAnimateContentSize(
                enabled: !_reduceMotion,
                child: AnimatedContainer(
                  key: widget.sourceStyle
                      ? null
                      : const ValueKey('navigation-rail-item-surface'),
                  duration: widget.sourceStyle
                      ? _reduceMotion
                            ? Duration.zero
                            : const Duration(milliseconds: 180)
                      : itemMotion,
                  curve: widget.sourceStyle
                      ? Curves.easeOutCubic
                      : Curves.fastOutSlowIn,
                  constraints: BoxConstraints(
                    minHeight: widget.sourceStyle
                        ? widget.extended
                              ? 56
                              : 0
                        : hyperOs4.navigationRailItemHeight,
                    minWidth: widget.extended ? 216 : 0,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.extended ? 14 : 0,
                    vertical: widget.extended ? 14 : 0,
                  ),
                  decoration: widget.sourceStyle
                      ? BoxDecoration(
                          color: widget.selected && widget.extended
                              ? scheme.surfaceContainerHigh
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(15),
                        )
                      : ShapeDecoration(
                          color: widget.selected
                              ? supplied?.background ??
                                    layers?.navigationFill ??
                                    scheme.primary.withValues(
                                      alpha: selectionTintOpacity,
                                    )
                              : Colors.transparent,
                          shape: MiuixSquircleBorder(
                            borderRadius: BorderRadius.circular(
                              hyperOs4.navigationRailItemCornerRadius,
                            ),
                          ),
                        ),
                  child: content,
                ),
              ),
            );
          },
        ),
      ),
    );
    final interactive = sourceCurrentClassic
        ? AnimatedBuilder(
            animation: _sourceIndication,
            child: gesture,
            builder: (context, child) => Stack(
              fit: StackFit.passthrough,
              children: [
                child!,
                Positioned.fill(
                  child: IgnorePointer(
                    child: ColoredBox(
                      key: const ValueKey('navigation-rail-source-indication'),
                      color: MiuixSemanticColors.of(context)['onBackground']
                          .withValues(
                            alpha: _sourceIndication.value.clamp(0.0, .1),
                          ),
                    ),
                  ),
                ),
              ],
            ),
          )
        : gesture;
    return Semantics(
      button: true,
      selected: widget.selected,
      enabled: widget.item.enabled,
      label: widget.item.label,
      child: interactive,
    );
  }

  /// Builds the four exact structural branches from NavigationRail.kt.
  Widget _buildSourceContent({
    required Widget currentIcon,
    required TextStyle? labelStyle,
  }) {
    return switch (widget.displayMode) {
      MiuixNavigationRailDisplayMode.iconAndText => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          currentIcon,
          const SizedBox(height: MiuixNavigationRailDefaults.iconTextSpacing),
          Text(
            widget.item.label,
            textAlign: TextAlign.center,
            style: labelStyle,
          ),
        ],
      ),
      MiuixNavigationRailDisplayMode.iconOnly => currentIcon,
      MiuixNavigationRailDisplayMode.textOnly => Padding(
        padding: const EdgeInsets.symmetric(
          vertical: MiuixNavigationRailDefaults.textOnlyVerticalPadding,
        ),
        child: Text(
          widget.item.label,
          textAlign: TextAlign.center,
          style: labelStyle,
        ),
      ),
      MiuixNavigationRailDisplayMode.iconWithSelectedLabel => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          currentIcon,
          if (widget.selected) ...[
            const SizedBox(height: MiuixNavigationRailDefaults.iconTextSpacing),
            Text(
              widget.item.label,
              textAlign: TextAlign.center,
              style: labelStyle,
            ),
          ],
        ],
      ),
    };
  }

  /// Preserves the historical 240dp Flutter-only compatibility layout.
  Widget _buildExtendedContent(
    BuildContext context, {
    required Widget currentIcon,
    required Color tint,
  }) {
    return Row(
      children: [
        SizedBox(width: 30, height: 28, child: Center(child: currentIcon)),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            widget.item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: tint,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

/// Spring-sized clip matching Compose `Modifier.animateContentSize()`.
///
/// The child adopts its new content immediately. Only the parent measurement
/// interpolates from the currently displayed size to the new target, clipping
/// the child during the transition. This differs from [AnimatedSize], whose
/// duration and cubic curve cannot represent Compose's spring.
class _MiuixRailAnimateContentSize extends StatefulWidget {
  const _MiuixRailAnimateContentSize({
    required this.enabled,
    required this.child,
  });

  /// Whether target-size changes should retain their authored spring.
  final bool enabled;

  final Widget child;

  @override
  State<_MiuixRailAnimateContentSize> createState() =>
      _MiuixRailAnimateContentSizeState();
}

class _MiuixRailAnimateContentSizeState
    extends State<_MiuixRailAnimateContentSize>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress;

  @override
  void initState() {
    super.initState();
    _progress = AnimationController.unbounded(vsync: this, value: 1);
  }

  void _startSizeSpring() {
    _progress.value = 0;
    _progress.animateWith(
      SpringSimulation(
        debugMiuixNavigationRailSizeSpring(),
        0,
        1,
        0,
        tolerance: const Tolerance(distance: .01, velocity: .01),
      ),
    );
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return _MiuixRailAnimatedSizeRenderWidget(
      progress: _progress,
      onTargetChanged: _startSizeSpring,
      child: widget.child,
    );
  }
}

class _MiuixRailAnimatedSizeRenderWidget extends SingleChildRenderObjectWidget {
  const _MiuixRailAnimatedSizeRenderWidget({
    required this.progress,
    required this.onTargetChanged,
    required super.child,
  });

  final Animation<double> progress;
  final VoidCallback onTargetChanged;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderMiuixRailAnimatedSize(progress, onTargetChanged);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderMiuixRailAnimatedSize renderObject,
  ) {
    renderObject
      ..progress = progress
      ..onTargetChanged = onTargetChanged;
  }
}

class _RenderMiuixRailAnimatedSize extends RenderProxyBox {
  _RenderMiuixRailAnimatedSize(this._progress, this.onTargetChanged);

  Animation<double> _progress;
  VoidCallback onTargetChanged;
  Size _fromSize = Size.zero;
  Size _targetSize = Size.zero;
  bool _initialized = false;
  bool _callbackScheduled = false;

  set progress(Animation<double> value) {
    if (identical(value, _progress)) {
      return;
    }
    if (attached) {
      _progress.removeListener(markNeedsLayout);
    }
    _progress = value;
    if (attached) {
      _progress.addListener(markNeedsLayout);
    }
    markNeedsLayout();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _progress.addListener(markNeedsLayout);
  }

  @override
  void detach() {
    _progress.removeListener(markNeedsLayout);
    super.detach();
  }

  @override
  void performLayout() {
    child?.layout(constraints, parentUsesSize: true);
    final childSize = child?.size ?? constraints.smallest;
    if (!_initialized) {
      _initialized = true;
      _fromSize = childSize;
      _targetSize = childSize;
    } else if (childSize != _targetSize) {
      _fromSize = size;
      _targetSize = childSize;
      if (!_callbackScheduled) {
        _callbackScheduled = true;
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _callbackScheduled = false;
          if (attached) {
            onTargetChanged();
          }
        });
      }
    }
    size = constraints.constrain(
      Size.lerp(_fromSize, _targetSize, _progress.value.clamp(0.0, 1.0))!,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null || size.isEmpty) {
      return;
    }
    context.pushClipRect(
      needsCompositing,
      offset,
      Offset.zero & size,
      super.paint,
    );
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    if (!(Offset.zero & size).contains(position)) {
      return false;
    }
    return super.hitTestChildren(result, position: position);
  }
}
