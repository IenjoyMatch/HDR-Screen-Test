part of '../miuix_widgets.dart';

/// Shares one identity-stable expansion animation with every rail item.
///
/// Items listen to [progress] directly, avoiding a full inherited-widget
/// notification walk on every spring frame. This mirrors the source's layout-
/// phase state read: width and destination geometry move on the same timeline.
class _MiuixNavigationRailExpandScope extends InheritedWidget {
  const _MiuixNavigationRailExpandScope({
    required this.progress,
    required this.collapsedWidth,
    required super.child,
  });

  final Animation<double> progress;
  final double collapsedWidth;

  static _MiuixNavigationRailExpandScope? maybeOf(
    BuildContext context,
  ) => context
      .dependOnInheritedWidgetOfExactType<_MiuixNavigationRailExpandScope>();

  @override
  bool updateShouldNotify(_MiuixNavigationRailExpandScope oldWidget) =>
      !identical(progress, oldWidget.progress) ||
      collapsedWidth != oldWidget.collapsedWidth;
}

/// Stateful layout driver for the current expandable NavigationRail contract.
class _MiuixNavigationRailLayout extends StatefulWidget {
  const _MiuixNavigationRailLayout({required this.rail});

  final MiuixNavigationRail rail;

  @override
  State<_MiuixNavigationRailLayout> createState() =>
      _MiuixNavigationRailLayoutState();
}

class _MiuixNavigationRailLayoutState extends State<_MiuixNavigationRailLayout>
    with SingleTickerProviderStateMixin {
  late final AnimationController _expandProgress;
  int _motionGeneration = 0;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _expandProgress = AnimationController.unbounded(
      vsync: this,
      value: widget.rail.state?.isExpanded == true ? 1 : 0,
    );
    widget.rail.state?.addListener(_animateToState);
  }

  @override
  void didUpdateWidget(covariant _MiuixNavigationRailLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.rail.state, widget.rail.state)) {
      oldWidget.rail.state?.removeListener(_animateToState);
      widget.rail.state?.addListener(_animateToState);
      if (widget.rail.state == null) {
        _expandProgress.value = 0;
      } else {
        _animateToState();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextReduceMotion = MediaQuery.disableAnimationsOf(context);
    if (nextReduceMotion == _reduceMotion) return;
    _reduceMotion = nextReduceMotion;
    if (_reduceMotion) {
      _expandProgress
        ..stop(canceled: true)
        ..value = widget.rail.state?.isExpanded == true ? 1 : 0;
    }
  }

  /// Runs every state change on the source's 0.35-response critical spring.
  void _animateToState() {
    final target = widget.rail.state?.isExpanded == true ? 1.0 : 0.0;
    final generation = ++_motionGeneration;
    if (_reduceMotion) {
      _expandProgress
        ..stop(canceled: true)
        ..value = target;
      return;
    }
    if ((_expandProgress.value - target).abs() < .001) {
      _expandProgress.value = target;
      return;
    }
    _expandProgress
        .animateWith(
          SpringSimulation(
            debugMiuixNavigationRailExpandSpring(),
            _expandProgress.value,
            target,
            // animateFloatAsState retargets from the live velocity. Keeping it
            // here prevents a rapid expand/collapse from stopping for a frame.
            _expandProgress.velocity,
            tolerance: const Tolerance(distance: .001, velocity: .001),
          ),
        )
        .whenCompleteOrCancel(() {
          // AnimationController stops once the simulation enters tolerance.
          // Compose animateFloatAsState then publishes its exact target; snap
          // only the latest run so an interrupted reversal remains continuous.
          if (mounted && generation == _motionGeneration) {
            _expandProgress.value = target;
          }
        });
  }

  @override
  void dispose() {
    widget.rail.state?.removeListener(_animateToState);
    _expandProgress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rail = widget.rail;
    final scheme = Theme.of(context).colorScheme;
    final miuixTheme = MiuixTheme.of(context);
    final hyperOs4 = miuixTheme.hyperOs4;
    final direction = Directionality.of(context);
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final safeSelected = rail.items.isEmpty
        ? -1
        : rail.selectedIndex.clamp(0, rail.items.length - 1);
    final safeMinWidth = rail.minWidth.isFinite && rail.minWidth >= 0
        ? rail.minWidth
        : MiuixNavigationRailDefaults.minWidth;
    final safeExpandedWidth = rail.expandedWidth.isFinite
        ? math.max(safeMinWidth, rail.expandedWidth)
        : math.max(safeMinWidth, MiuixNavigationRailDefaults.expandedWidth);

    // Source consumes vertical insets inside its opaque column. HyperOS 4
    // keeps those regions transparent and positions only the clipped glass
    // rail inside the safe window bounds.
    final topInset = rail.defaultWindowInsetsPadding && rail._source
        ? viewPadding.top
        : 0.0;
    final bottomInset = rail.defaultWindowInsetsPadding && rail._source
        ? viewPadding.bottom
        : 0.0;
    final startInset = rail.defaultWindowInsetsPadding
        ? direction == TextDirection.ltr
              ? viewPadding.left
              : viewPadding.right
        : 0.0;

    return ColoredBox(
      color: rail._source ? rail.color ?? scheme.surface : Colors.transparent,
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: rail._source ? startInset : 0,
        ),
        child: AnimatedBuilder(
          animation: _expandProgress,
          builder: (context, _) {
            final progress = rail.state == null
                ? 0.0
                : _expandProgress.value.clamp(0.0, 1.0);
            final rawWidth = rail.state != null
                ? _miuixLerpDouble(safeMinWidth, safeExpandedWidth, progress)
                : rail.extended
                ? MiuixNavigationRailDefaults.expandedWidth
                : safeMinWidth;
            final pixelRatio = MediaQuery.devicePixelRatioOf(context);
            final columnWidth = _miuixRoundLogicalDimension(
              rawWidth,
              pixelRatio,
            );

            Widget itemContent(Widget child) {
              Widget scoped = _MiuixNavigationRailDisplayModeScope(
                mode: rail.displayMode,
                child: child,
              );
              if (rail.state != null) {
                scoped = _MiuixNavigationRailExpandScope(
                  progress: _expandProgress,
                  collapsedWidth: safeMinWidth,
                  child: scoped,
                );
              }
              return scoped;
            }

            final railColumn = SizedBox(
              key: const ValueKey('navigation-rail-column'),
              width: columnWidth,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: topInset + MiuixNavigationRailDefaults.verticalPadding,
                  bottom:
                      bottomInset + MiuixNavigationRailDefaults.verticalPadding,
                ),
                child: Column(
                  children: [
                    if (rail.state != null) ...[
                      _MiuixNavigationRailExpandToggle(
                        state: rail.state!,
                        sourceStyle: rail._source,
                        progress: progress,
                        collapsedWidth: safeMinWidth,
                        columnWidth: columnWidth,
                        expandContentDescription: rail.expandContentDescription,
                        collapseContentDescription:
                            rail.collapseContentDescription,
                      ),
                      const SizedBox(
                        height: MiuixNavigationRailDefaults.headerSpacing,
                      ),
                    ],
                    if (rail.header != null) ...[
                      rail.header!,
                      const SizedBox(
                        height: MiuixNavigationRailDefaults.headerSpacing,
                      ),
                    ],
                    if (rail.sourceChildren != null)
                      for (final child in rail.sourceChildren!)
                        itemContent(child)
                    else
                      for (var index = 0; index < rail.items.length; index++)
                        itemContent(
                          _MiuixNavigationRailItem(
                            key: ValueKey('navigation-rail-item-$index'),
                            item: rail.items[index],
                            selected: index == safeSelected,
                            extended: rail.extended,
                            sourceStyle: rail._source,
                            sourceSemantics: false,
                            displayMode: rail.displayMode,
                            onTap: () {
                              if (!rail._source && index != safeSelected) {
                                unawaited(
                                  MiuixHaptics.perform(
                                    MiuixHapticType.segmentTick,
                                  ),
                                );
                              }
                              rail.onDestinationSelected?.call(index);
                            },
                          ),
                        ),
                  ],
                ),
              ),
            );

            // Directional Row placement keeps the divider between rail and
            // pager in both LTR and RTL, as Compose placeRelative does.
            final sourceSurface = Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                railColumn,
                if (rail.showDivider)
                  const MiuixVerticalDivider(
                    key: ValueKey('navigation-rail-divider'),
                  ),
              ],
            );
            if (rail._source) return sourceSurface;

            final margin = hyperOs4.navigationRailOuterMargin;
            final safeTop = rail.defaultWindowInsetsPadding
                ? viewPadding.top
                : 0.0;
            final safeBottom = rail.defaultWindowInsetsPadding
                ? viewPadding.bottom
                : 0.0;
            final localSurface = rail.glass
                ? MiuixGlass(
                    key: const ValueKey('navigation-rail-glass'),
                    blur: hyperOs4.navigationRailBlur,
                    opacity: hyperOs4.navigationRailTintOpacity,
                    color: rail.color ?? scheme.surfaceContainer,
                    radius: hyperOs4.navigationRailCornerRadius,
                    padding: EdgeInsets.zero,
                    border: rail.showDivider
                        ? BorderSide(color: scheme.outlineVariant, width: .75)
                        : null,
                    child: railColumn,
                  )
                : DecoratedBox(
                    key: const ValueKey('navigation-rail-solid-surface'),
                    decoration: ShapeDecoration(
                      color: rail.color ?? scheme.surfaceContainer,
                      shape: MiuixSquircleBorder(
                        borderRadius: BorderRadius.circular(
                          hyperOs4.navigationRailCornerRadius,
                        ),
                        side: rail.showDivider
                            ? BorderSide(
                                color: scheme.outlineVariant,
                                width: .75,
                              )
                            : BorderSide.none,
                      ),
                    ),
                    child: railColumn,
                  );
            return ColoredBox(
              color: Colors.transparent,
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                  startInset + margin,
                  safeTop + margin,
                  margin,
                  safeBottom + margin,
                ),
                child: localSurface,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Built-in Sidebar action shown whenever an expansion state is provided.
class _MiuixNavigationRailExpandToggle extends StatelessWidget {
  const _MiuixNavigationRailExpandToggle({
    required this.state,
    required this.sourceStyle,
    required this.progress,
    required this.collapsedWidth,
    required this.columnWidth,
    required this.expandContentDescription,
    required this.collapseContentDescription,
  });

  final MiuixNavigationRailState state;
  final bool sourceStyle;
  final double progress;
  final double collapsedWidth;
  final double columnWidth;
  final String expandContentDescription;
  final String collapseContentDescription;

  @override
  Widget build(BuildContext context) {
    const buttonSize =
        MiuixNavigationRailDefaults.iconSize +
        MiuixNavigationRailDefaults.expandedItemContentHorizontalPadding * 2;
    final collapsedX = (collapsedWidth - buttonSize) / 2;
    const expandedX = MiuixNavigationRailDefaults.expandedItemHorizontalMargin;
    final x = _miuixLerpDouble(collapsedX, expandedX, progress);
    final sidebar = MiuixExtendedIconCatalog.find('Sidebar');
    return SizedBox(
      key: const ValueKey('navigation-rail-expand-toggle-slot'),
      width: columnWidth,
      height: buttonSize,
      child: Stack(
        children: [
          PositionedDirectional(
            start: x,
            top: 0,
            child: sourceStyle
                ? MiuixIconButton.source(
                    key: const ValueKey('navigation-rail-expand-toggle'),
                    onPressed: state.toggle,
                    minWidth: buttonSize,
                    minHeight: buttonSize,
                    contentColor: MiuixSemanticColors.of(
                      context,
                    )['onSurfaceContainer'],
                    icon: MiuixThemedIcon(
                      sidebar?.regular ?? MiuixIcons.basic.sidebar,
                      size: MiuixNavigationRailDefaults.iconSize,
                      semanticLabel: state.isExpanded
                          ? collapseContentDescription
                          : expandContentDescription,
                    ),
                  )
                : MiuixIconButton(
                    key: const ValueKey('navigation-rail-expand-toggle'),
                    onPressed: state.toggle,
                    minWidth: buttonSize,
                    minHeight: buttonSize,
                    contentColor: Theme.of(context).colorScheme.onSurface,
                    icon: MiuixThemedIcon(
                      sidebar?.regular ?? MiuixIcons.basic.sidebar,
                      size: MiuixNavigationRailDefaults.iconSize,
                      semanticLabel: state.isExpanded
                          ? collapseContentDescription
                          : expandContentDescription,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Current source destination morph used only when the rail owns a state.
class _MiuixExpandableNavigationRailItem extends StatelessWidget {
  const _MiuixExpandableNavigationRailItem({
    required this.info,
    required this.item,
    required this.selected,
    required this.sourceStyle,
    required this.indication,
    required this.onTap,
    required this.onPressedChanged,
    required this.pressed,
  });

  final _MiuixNavigationRailExpandScope info;
  final MiuixNavigationItem item;
  final bool selected;
  final bool sourceStyle;
  final Animation<double> indication;
  final VoidCallback onTap;
  final ValueChanged<bool> onPressedChanged;
  final bool pressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([info.progress, indication]),
      builder: (context, _) {
        final progress = info.progress.value.clamp(0.0, 1.0);
        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final theme = Theme.of(context);
            final scheme = Theme.of(context).colorScheme;
            // 显式前景与普通侧栏共用同一来源，不在展开后恢复另一种主色。
            final supplied = _MiuixNavigationRailColors.maybeOf(context);
            // 展开动画消费同一主题层，不在终点换回实色主按钮样式。
            final layers = sourceStyle
                ? null
                : MiuixAccentLayers.maybeOf(context);
            final tint = selected && supplied?.foreground != null
                ? supplied!.foreground!
                : sourceStyle
                ? MiuixSemanticColors.of(context)['onSurfaceContainer']
                : selected
                ? layers?.navigationForeground ?? scheme.primary
                // 折叠与展开必须使用同一未选前景，动画不能恢复低对比灰字。
                // 该角色已由宿主按实际表面校准，渲染时不再降低透明度。
                : layers?.navigationUnselectedForeground ??
                      scheme.onSurfaceVariant;
            final fontSize = _miuixLerpDouble(
              MiuixNavigationRailDefaults.labelFontSize,
              MiuixNavigationRailDefaults.expandedLabelFontSize,
              progress,
            );
            final labelStyle = theme.textTheme.labelSmall?.copyWith(
              color: tint,
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
            );
            final painter = TextPainter(
              text: TextSpan(text: item.label, style: labelStyle),
              // 使用实际字号测量完整标签，不能只扩大绘制字体却保留单行高度。
              textScaler: MediaQuery.textScalerOf(context),
              textDirection: Directionality.of(context),
            );
            const margin =
                MiuixNavigationRailDefaults.expandedItemHorizontalMargin;
            const leadingInset = MiuixNavigationRailDefaults
                .expandedItemContentHorizontalPadding;
            const expandedSpacing =
                MiuixNavigationRailDefaults.expandedItemIconTextSpacing;
            const iconSize = MiuixNavigationRailDefaults.iconSize;
            final expandedLabelMax = math.max(
              0.0,
              width -
                  2 * margin -
                  2 * leadingInset -
                  iconSize -
                  expandedSpacing,
            );
            final labelMax = _miuixLerpDouble(
              supplied?.background == null && layers == null
                  ? width
                  : math.max(0, width - 16),
              expandedLabelMax,
              progress,
            );
            painter.layout(maxWidth: labelMax);
            final labelWidth = painter.width;
            final labelHeight = painter.height;
            const topPad = MiuixNavigationRailDefaults.itemVerticalPadding;
            const collapsedSpacing =
                MiuixNavigationRailDefaults.iconTextSpacing;
            const collapsedIndicatorPad =
                MiuixNavigationRailDefaults.collapsedIndicatorVerticalPadding;
            const expandedVerticalPad =
                MiuixNavigationRailDefaults.expandedItemContentVerticalPadding;
            final collapsedHeight =
                topPad +
                iconSize +
                collapsedIndicatorPad * 2 +
                collapsedSpacing +
                labelHeight +
                topPad;
            final expandedHeight =
                expandedVerticalPad * 2 + math.max(iconSize, labelHeight);
            final height = _miuixLerpDouble(
              collapsedHeight,
              expandedHeight,
              progress,
            );

            final collapsedIconX = (info.collapsedWidth - iconSize) / 2;
            const expandedIconX = margin + leadingInset;
            final iconX = _miuixLerpDouble(
              collapsedIconX,
              expandedIconX,
              progress,
            );
            final iconY = _miuixLerpDouble(
              topPad + collapsedIndicatorPad,
              (height - iconSize) / 2,
              progress,
            );
            final indicatorPad = _miuixLerpDouble(
              collapsedIndicatorPad,
              expandedVerticalPad,
              progress,
            );
            // 显式背景必须覆盖完整标签，白字不能落到胶囊外的浅色画布。
            final explicitBackground =
                supplied?.background != null || layers != null;
            final indicatorHeight = explicitBackground
                ? height
                : iconSize + indicatorPad * 2;
            final indicatorY = explicitBackground ? 0.0 : iconY - indicatorPad;
            final indicatorX = _miuixLerpDouble(
              explicitBackground ? 8 : collapsedIconX - leadingInset,
              margin,
              progress,
            );
            final indicatorWidth = _miuixLerpDouble(
              explicitBackground
                  ? math.max(0, width - 16)
                  : iconSize + leadingInset * 2,
              width - margin * 2,
              progress,
            );
            final collapsedLabelX =
                collapsedIconX + iconSize / 2 - labelWidth / 2;
            const expandedLabelX =
                margin + leadingInset + iconSize + expandedSpacing;
            final labelX = math.max(
              0.0,
              _miuixLerpDouble(collapsedLabelX, expandedLabelX, progress),
            );
            const collapsedLabelY =
                topPad +
                iconSize +
                collapsedIndicatorPad * 2 +
                collapsedSpacing;
            final labelY = _miuixLerpDouble(
              collapsedLabelY,
              (height - labelHeight) / 2,
              progress,
            );

            final indicatorBase = selected
                ? supplied?.background ??
                      layers?.navigationFill ??
                      (sourceStyle
                          ? theme.colorScheme.surfaceContainerHigh
                          : theme.colorScheme.primaryContainer.withValues(
                              alpha: .72,
                            ))
                : Colors.transparent;
            final indicatorColor = Color.alphaBlend(
              MiuixSemanticColors.of(context)['onBackground'].withValues(
                alpha: indication.value.clamp(0.0, .1),
              ),
              indicatorBase,
            );
            final physicalIconX =
                Directionality.of(context) == TextDirection.ltr
                ? iconX
                : width - iconX - iconSize;
            final visual = SizedBox(
              key: const ValueKey('navigation-rail-expandable-item-visual'),
              width: width,
              height: height,
              child: Stack(
                // Compose Box/Layout does not clip badge overflow. badgeBounds
                // moves only top/end overflow inward; start/bottom overflow
                // remains paintable.
                clipBehavior: Clip.none,
                children: [
                  PositionedDirectional(
                    start: indicatorX,
                    top: indicatorY,
                    width: math.max(0, indicatorWidth),
                    height: math.max(0, indicatorHeight),
                    child: DecoratedBox(
                      key: const ValueKey(
                        'navigation-rail-expandable-indicator',
                      ),
                      decoration: ShapeDecoration(
                        color: indicatorColor,
                        shape: MiuixSquircleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(
                              sourceStyle
                                  ? MiuixNavigationRailDefaults
                                        .expandedItemCornerRadius
                                  : MiuixTheme.of(
                                      context,
                                    ).hyperOs4.navigationRailItemCornerRadius,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    start: iconX,
                    top: iconY,
                    width: iconSize,
                    height: iconSize,
                    // Upstream measures NavigationItemIcon with constraints
                    // whose minimum width and height are both zero, then
                    // positions the resulting 28dp anchor. Positioned gives
                    // its child tight constraints, so this explicit loose
                    // measurement boundary reproduces the source Layout and
                    // keeps a 16dp content badge from stretching to 28dp.
                    child: UnconstrainedBox(
                      child: _miuixNavigationIconWithBadge(
                        badge: item.badge,
                        sourceBounds: Rect.fromLTRB(
                          -physicalIconX,
                          -iconY,
                          width - physicalIconX,
                          double.infinity,
                        ),
                        icon: SizedBox.square(
                          dimension: iconSize,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: IconTheme(
                              data: IconThemeData(color: tint, size: iconSize),
                              child: sourceStyle
                                  ? item.icon
                                  : selected
                                  ? item.selectedIcon ?? item.icon
                                  : item.icon,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    start: labelX,
                    top: labelY,
                    width: labelWidth,
                    height: labelHeight,
                    child: Text(
                      item.label,
                      // 自然换行与上方 TextPainter 使用同一字号和宽度。
                      softWrap: true,
                      style: labelStyle,
                    ),
                  ),
                ],
              ),
            );
            final gesture = GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: item.enabled ? onTap : null,
              onTapDown: item.enabled ? (_) => onPressedChanged(true) : null,
              onTapUp: item.enabled ? (_) => onPressedChanged(false) : null,
              onTapCancel: item.enabled ? () => onPressedChanged(false) : null,
              child: MiuixIconInteraction(
                navigation: true,
                enabled: item.enabled,
                pressed: pressed,
                selected: selected,
                child: visual,
              ),
            );
            return Semantics(
              button: true,
              selected: selected,
              enabled: item.enabled,
              label: item.label,
              child: gesture,
            );
          },
        );
      },
    );
  }
}

double _miuixLerpDouble(double begin, double end, double t) =>
    begin + (end - begin) * t;
