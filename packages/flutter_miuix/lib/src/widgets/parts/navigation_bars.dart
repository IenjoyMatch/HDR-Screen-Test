// Modified for HDR Screen Test: optional size-aware capsule geometry.
part of '../miuix_widgets.dart';

/// Public source metrics used by [MiuixNavigationBar].
abstract final class MiuixNavigationBarDefaults {
  static const double itemHeight = 64;
  static const double iconSize = 26;
  static const double labelFontSize = 12;
  static const double iconTopPadding = 8;
  static const double bottomPadding = 8;
  static const double selectedPressedAlpha = .5;
  static const double unselectedPressedAlpha = .6;
  static const double unselectedAlpha = .4;
}

/// Public source metrics used by [MiuixFloatingNavigationBar].
abstract final class MiuixFloatingNavigationBarDefaults {
  static const double horizontalOutsidePadding = 36;
  static const double shadowElevation = 1;
  static const double horizontalPadding = 12;
  static const double itemSpacing = 12;
  static const double iconSize = 28;
  static const double iconPadding = 10;
  static const double selectedPressedAlpha = .5;
  static const double unselectedPressedAlpha = .6;
  static const double unselectedAlpha = .4;
}

/// Source-compatible display modes for regular MIUIX navigation items.
enum MiuixNavigationBarDisplayMode {
  /// Keep both the 26dp icon and the 12sp label visible.
  iconAndText,

  /// Center the icon and hide every label.
  iconOnly,

  /// Center the 14sp label and hide every icon.
  textOnly,

  /// Keep icons visible and reveal only the selected item's label.
  iconWithSelectedLabel,
}

/// Source display modes for MIUIX's distinct floating navigation component.
enum MiuixFloatingNavigationBarDisplayMode {
  /// Show a 24dp icon with a 12sp label below it.
  iconAndText,

  /// Show only the source 28dp icon.
  iconOnly,

  /// Show only a 14sp label.
  textOnly,

  /// Keep icons visible and reveal only the selected item's label.
  iconWithSelectedLabel,
}

/// Horizontal placement of a [MiuixFloatingNavigationBar].
enum MiuixFloatingNavigationBarAlignment {
  /// Align the floating surface to the leading edge.
  start,

  /// Center the floating surface.
  center,

  /// Align the floating surface to the trailing edge.
  end,
}

/// Full-width navigation bar using HyperOS 4 glass defaults.
class MiuixNavigationBar extends StatelessWidget {
  /// Creates a regular navigation bar with a 64dp item row.
  ///
  /// When [showDivider] is true, the source's separate 0.75dp divider is
  /// measured above that row rather than painted inside its bounds.
  const MiuixNavigationBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.displayMode = MiuixNavigationBarDisplayMode.iconAndText,
    this.color,
    this.glass = true,
    this.showDivider = false,
    this.defaultWindowInsetsPadding = true,
    this.selectedIndicatorColor,
  });

  /// Destination list; the original component supports two to five items.
  final List<MiuixNavigationItem> items;

  /// Current selected destination.
  final int selectedIndex;

  /// Selection callback.
  final ValueChanged<int> onDestinationSelected;

  /// Icon and label visibility mode.
  final MiuixNavigationBarDisplayMode displayMode;

  /// Optional surface color.
  final Color? color;

  /// Whether the bar samples and blurs page content behind its surface.
  final bool glass;

  /// Whether to draw the source divider above the bar.
  final bool showDivider;

  /// Whether to apply the bottom system inset.
  final bool defaultWindowInsetsPadding;

  /// Optional selected-item indicator color.
  ///
  /// When non-null, the selected destination paints a rounded pill indicator
  /// and tints its icon/label with this color instead of the source
  /// on-surface-container tint. This mirrors legado's floating bottom bar
  /// selection treatment while staying disabled (source default) by null.
  final Color? selectedIndicatorColor;

  @override
  Widget build(BuildContext context) {
    return _MiuixNavigationInsetsBuilder(
      builder: (context, nativeInsets) =>
          _buildWithInsets(context, nativeInsets),
    );
  }

  Widget _buildWithInsets(
    BuildContext context,
    MiuixWindowInsets? nativeInsets,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final safeSelected = items.isEmpty
        ? -1
        : selectedIndex.clamp(0, items.length - 1);
    final content = SizedBox(
      height: MiuixNavigationBarDefaults.itemHeight,
      child: Row(
        children: [
          for (var index = 0; index < items.length; index++)
            Expanded(
              child: _MiuixNavigationBarItem(
                item: items[index],
                selected: index == safeSelected,
                displayMode: displayMode,
                onTap: () {
                  if (index != safeSelected) {
                    unawaited(
                      MiuixHaptics.perform(MiuixHapticType.segmentTick),
                    );
                  }
                  onDestinationSelected(index);
                },
                indicatorColor: selectedIndicatorColor,
              ),
            ),
        ],
      ),
    );
    final mediaBottom = MediaQuery.paddingOf(context).bottom;
    // NavigationBar.kt deliberately ignores the actual iOS safe-area value
    // and inserts 20dp. Every other platform consumes navigationBars only.
    // Before Android's native split-inset event arrives, MediaQuery provides a
    // synchronous launch-frame fallback with the same ordinary-phone value.
    final navigationBottom = defaultTargetPlatform == TargetPlatform.iOS
        ? 20.0
        : nativeInsets?.navigationBarBottom ?? mediaBottom;
    final captionBottom = defaultWindowInsetsPadding
        ? nativeInsets?.captionBarBottom ?? 0.0
        : 0.0;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return KeyedSubtree(
      key: const ValueKey('navigation-bar-caption-inset-animation'),
      child: TweenAnimationBuilder<double>(
        // Replacing the animation state is intentional: changing duration to
        // zero alone does not settle a tween whose logical endpoint is stable.
        key: ValueKey(reduceMotion),
        tween: Tween<double>(end: captionBottom),
        duration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 300),
        curve: Curves.linear,
        builder: (context, animatedCaptionBottom, _) {
          // NavigationBar.kt places HorizontalDivider as the first child of its
          // Column. It contributes 0.75dp to measured height while leaving the
          // 64dp item row unchanged. The following spacer is a distinct layout
          // node because the source adds navigation and caption insets after the
          // item row rather than shrinking or lifting its destinations.
          final barContent = Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showDivider)
                const MiuixHorizontalDivider(
                  key: ValueKey('navigation-bar-divider'),
                ),
              content,
              if (defaultWindowInsetsPadding)
                GestureDetector(
                  key: const ValueKey('navigation-bar-bottom-inset'),
                  behavior: HitTestBehavior.opaque,
                  onTap: () {},
                  child: SizedBox(
                    height: navigationBottom + animatedCaptionBottom,
                  ),
                ),
            ],
          );
          if (glass) {
            return MiuixGlass(
              key: const ValueKey('navigation-bar-glass'),
              blur: hyperOs4.appBarBlur,
              opacity: hyperOs4.appBarTintOpacity,
              color: color ?? scheme.surface,
              radius: 0,
              padding: EdgeInsets.zero,
              showSpecular: true,
              optics: MiuixGlassOptics.navigation,
              child: barContent,
            );
          }
          return DecoratedBox(
            decoration: BoxDecoration(color: color ?? scheme.surface),
            child: barContent,
          );
        },
      ),
    );
  }
}

class _MiuixNavigationBarItem extends StatefulWidget {
  const _MiuixNavigationBarItem({
    required this.item,
    required this.selected,
    required this.displayMode,
    required this.onTap,
    this.indicatorColor,
  });

  final MiuixNavigationItem item;
  final bool selected;
  final MiuixNavigationBarDisplayMode displayMode;
  final VoidCallback onTap;
  final Color? indicatorColor;

  @override
  State<_MiuixNavigationBarItem> createState() =>
      _MiuixNavigationBarItemState();
}

class _MiuixNavigationBarItemState extends State<_MiuixNavigationBarItem>
    with SingleTickerProviderStateMixin {
  // Upstream selection motion lasts 300 ms and affects only the selected-label
  // layout; tint and typography switch immediately with the selected state.
  late final AnimationController _selection;
  bool _reduceMotion = false;

  // Press alpha is transient and deliberately independent of selection motion.
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _selection = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: widget.selected ? 1 : 0,
    )..addListener(_rebuild);
  }

  @override
  void didUpdateWidget(covariant _MiuixNavigationBarItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      // FastOutSlowIn is the exact MIUIX tween used to raise the icon and reveal
      // the label in iconWithSelectedLabel mode.
      final target = widget.selected ? 1.0 : 0.0;
      if (_reduceMotion) {
        _selection
          ..stop(canceled: true)
          ..value = target;
      } else {
        _selection.animateTo(
          target,
          // Compose starts a fresh 300ms TweenSpec from the currently sampled
          // value whenever animateDpAsState receives another target. Omitting
          // duration here makes AnimationController scale the time by remaining
          // distance, so a quick reversal snaps to rest much too early.
          duration: const Duration(milliseconds: 300),
          curve: Curves.fastOutSlowIn,
        );
      }
    }
    if (oldWidget.item.enabled && !widget.item.enabled) {
      _pressed = false;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextReduceMotion = MediaQuery.disableAnimationsOf(context);
    if (nextReduceMotion == _reduceMotion) return;
    _reduceMotion = nextReduceMotion;
    if (_reduceMotion) {
      _selection
        ..stop(canceled: true)
        ..value = widget.selected ? 1 : 0;
    }
  }

  @override
  void dispose() {
    _selection
      ..removeListener(_rebuild)
      ..dispose();
    super.dispose();
  }

  void _rebuild() {
    if (mounted) {
      setState(() {});
    }
  }

  void _setPressed(bool value) {
    if (_pressed != value && mounted) {
      setState(() => _pressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    // NavigationBarDefaults uses onSurfaceContainer for every destination.
    // When a selected indicator color is supplied, selected items use it
    // instead so legado-style primary selection is opt-in.
    final baseTint = MiuixSemanticColors.of(context)['onSurfaceContainer'];
    final selectedTint = widget.indicatorColor ?? baseTint;

    // The controller value already includes the configured easing curve; it
    // must not be transformed a second time during layout.
    final progress = _selection.value;
    final normalTint = widget.selected
        ? selectedTint
        : baseTint.withValues(
            alpha: MiuixNavigationBarDefaults.unselectedAlpha,
          );
    // Source press alpha is .5 for selected and .6 for unselected items.
    final pressedTint = baseTint.withValues(
      alpha: widget.selected
          ? MiuixNavigationBarDefaults.selectedPressedAlpha
          : MiuixNavigationBarDefaults.unselectedPressedAlpha,
    );
    final tint = _pressed ? pressedTint : normalTint;

    // Selected indicator pill: rounded background behind the selected item.
    // Height/radius mirror legado's AppNavigationBarItem indicator.
    final hasIndicator = widget.indicatorColor != null && widget.selected;

    return Semantics(
      button: true,
      selected: widget.selected,
      enabled: widget.item.enabled,
      label: widget.item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.item.enabled ? widget.onTap : null,
        onTapDown: widget.item.enabled ? (_) => _setPressed(true) : null,
        onTapUp: widget.item.enabled ? (_) => _setPressed(false) : null,
        onTapCancel: widget.item.enabled ? () => _setPressed(false) : null,
        child: SizedBox(
          height: MiuixNavigationBarDefaults.itemHeight,
          child: LayoutBuilder(
            builder: (context, constraints) => Stack(
              alignment: Alignment.center,
              children: [
                // 选中指示器铺在内容下层。
                if (hasIndicator)
                  _indicator(context, itemWidth: constraints.maxWidth),
                MiuixIconInteraction(
                  navigation: true,
                  enabled: widget.item.enabled,
                  pressed: _pressed,
                  selected: widget.selected,
                  child: _buildMode(
                    context,
                    progress,
                    tint,
                    itemWidth: constraints.maxWidth,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 选中项 primary 胶囊指示器（对应 legado AppNavigationBarItem）。
  Widget _indicator(BuildContext context, {required double itemWidth}) {
    final indicatorColor = widget.indicatorColor!;
    final showLabel =
        widget.displayMode == MiuixNavigationBarDisplayMode.iconAndText ||
        widget.displayMode ==
            MiuixNavigationBarDisplayMode.iconWithSelectedLabel;
    final height = showLabel ? 36.0 : 42.0;
    return Container(
      key: const ValueKey('navigation-bar-selection-indicator'),
      width: (itemWidth - 24).clamp(58.0, double.infinity),
      height: height,
      decoration: BoxDecoration(
        color: indicatorColor.withValues(alpha: .055),
        borderRadius: BorderRadius.circular(22),
      ),
    );
  }

  Widget _buildMode(
    BuildContext context,
    double progress,
    Color tint, {
    required double itemWidth,
  }) {
    // MIUIX changes display modes structurally; it does not cross-fade or retain
    // the previous icon/text branch.
    return switch (widget.displayMode) {
      MiuixNavigationBarDisplayMode.iconOnly => Center(
        child: _buildIcon(tint, itemWidth: itemWidth, iconTop: 19),
      ),
      MiuixNavigationBarDisplayMode.textOnly => Center(
        child: Text(
          widget.item.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: tint,
            fontSize: 14,
            fontWeight: widget.selected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
      MiuixNavigationBarDisplayMode.iconAndText => Column(
        children: [
          const SizedBox(height: 8),
          _buildIcon(tint, itemWidth: itemWidth, iconTop: 8),
          // NavigationBar.kt lays Text immediately after the 26dp image. Its
          // paragraph contributes a small font-leading offset, represented by
          // this 1dp gap for Flutter's tighter CJK line box. The old Spacer
          // consumed the row's remaining 10dp and painted every label about
          // 23 physical pixels too low on the 420-dpi reference device.
          const SizedBox(height: 1),
          _buildLabel(context, tint),
          const SizedBox(height: 8),
        ],
      ),
      MiuixNavigationBarDisplayMode.iconWithSelectedLabel => Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            // The icon moves from 19 dp to 8 dp while the label fades in.
            top: ui.lerpDouble(19, 8, progress),
            child: _buildIcon(
              tint,
              itemWidth: itemWidth,
              iconTop: ui.lerpDouble(19, 8, progress)!,
            ),
          ),
          Positioned(
            // Compose places the label after the animated icon placeable, so
            // both move together from the centered icon-only layout to the
            // selected icon-and-label layout. Pinning the label to the bottom
            // kept it stationary and substantially below the source baseline.
            top: ui.lerpDouble(19, 8, progress)! + 27,
            left: 4,
            right: 4,
            child: Opacity(
              opacity: progress,
              child: _buildLabel(context, tint),
            ),
          ),
        ],
      ),
    };
  }

  Widget _buildIcon(
    Color tint, {
    required double itemWidth,
    required double iconTop,
  }) {
    const anchorSize = MiuixNavigationBarDefaults.iconSize;
    final anchor = SizedBox(
      width: anchorSize,
      height: anchorSize,
      child: IconTheme(
        data: IconThemeData(
          color: tint,
          size: MiuixNavigationBarDefaults.iconSize,
        ),
        child: widget.selected
            ? (widget.item.selectedIcon ?? widget.item.icon)
            : widget.item.icon,
      ),
    );
    return _miuixNavigationIconWithBadge(
      icon: anchor,
      badge: widget.item.badge,
      // badgeBounds() belongs to the complete 64dp destination. Convert that
      // rectangle into the centered icon anchor's coordinates so BadgedBox can
      // clamp its top and logical-end rulers without clipping start overflow.
      sourceBounds: Rect.fromLTRB(
        -(itemWidth - anchorSize) / 2,
        -iconTop,
        (itemWidth + anchorSize) / 2,
        double.infinity,
      ),
    );
  }

  Widget _buildLabel(BuildContext context, Color tint) {
    return Text(
      widget.item.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: tint,
        fontSize: MiuixNavigationBarDefaults.labelFontSize,
        height: 1,
        fontWeight: widget.selected ? FontWeight.w700 : FontWeight.w400,
      ),
    );
  }
}

/// HyperOS 4 floating navigation bar with equal destinations.
///
/// The full-width host stays transparent. Only the local capsule owns glass,
/// clipping, outline, selection material, and its shape-conforming shadow.
/// This is the critical edge-to-edge distinction: page pixels remain visible
/// and interactive around the capsule rather than being covered by a hidden
/// rectangular bottom-bar layer.
class MiuixFloatingNavigationBar extends StatelessWidget {
  /// Fixed radius used by the source drop shadow when elevation is enabled.
  static const double sourceShadowRadius = 10;

  /// Fixed opacity used by the source drop shadow when elevation is enabled.
  static const double sourceShadowOpacity = .2;

  /// Creates the source floating navigation surface.
  const MiuixFloatingNavigationBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    this.onSelected,
    this.onDestinationSelected,
    this.color,
    this.cornerRadius = double.nan,
    this.capsule = false,
    this.displayMode = MiuixFloatingNavigationBarDisplayMode.iconAndText,
    this.alignment = MiuixFloatingNavigationBarAlignment.center,
    this.horizontalOutsidePadding = 20,
    this.bottomMargin = double.nan,
    this.shadowElevation = MiuixFloatingNavigationBarDefaults.shadowElevation,
    this.showDivider = false,
    this.glass = true,
    this.defaultWindowInsetsPadding = true,
    this.itemExtent = double.nan,
    this.itemWidth = double.nan,
    this.itemHeight = double.nan,
    this.selectionHeight = double.nan,
    this.selectionHorizontalInset = double.nan,
    this.dragEnabled = true,
    this.dragSelectionInset = double.nan,
    this.selectedIndicatorColor,
    this.selectedBackgroundColor,
    this.unselectedContentColor,
    this.backgroundOpacity,
  });

  /// Destination list.
  final List<MiuixNavigationItem> items;

  /// Current selected destination.
  final int selectedIndex;

  /// Backward-compatible selection callback.
  final ValueChanged<int>? onSelected;

  /// Selection callback using the regular navigation naming.
  final ValueChanged<int>? onDestinationSelected;

  /// Surface color, defaulting to `surfaceContainer`.
  final Color? color;

  /// Optional capsule radius override.
  ///
  /// The default NaN sentinel resolves through the HyperOS 4 theme token.
  final double cornerRadius;

  /// Use size-aware continuous capsule outlines for the surface and selection.
  final bool capsule;

  /// Icon and label visibility mode from the current source component.
  final MiuixFloatingNavigationBarDisplayMode displayMode;

  /// Placement within the full-width host.
  final MiuixFloatingNavigationBarAlignment alignment;

  /// Outside inset applied only on the aligned edge.
  final double horizontalOutsidePadding;

  /// Optional visual gap above the platform safe area or window edge.
  ///
  /// The default NaN sentinel resolves through the HyperOS 4 theme token.
  /// Use a smaller finite value when an application wants the capsule to sit
  /// closer to Android's gesture handle without changing its touch geometry.
  final double bottomMargin;

  /// Source graphics-layer elevation used to derive the capsule shadow.
  final double shadowElevation;

  /// Whether to draw the 0.75dp outline around the surface.
  final bool showDivider;

  /// Whether the source surface uses the global liquid-glass treatment.
  final bool glass;

  /// Whether to account for navigation and caption-bar insets.
  final bool defaultWindowInsetsPadding;

  /// Optional square extent assigned to every destination.
  ///
  /// Retained for compatibility. New layouts should set [itemWidth] and
  /// [itemHeight] independently so a destination is not forced back to a
  /// square. The default NaN sentinel resolves both axes from theme tokens.
  final double itemExtent;

  /// Optional destination width override, independent from its height.
  final double itemWidth;

  /// Optional destination height override, independent from its width.
  final double itemHeight;

  /// Optional visible height of the moving selected capsule.
  final double selectionHeight;

  /// Optional horizontal inset of the selected capsule inside each item.
  final double selectionHorizontalInset;

  /// Whether direct horizontal dragging can select another destination.
  final bool dragEnabled;

  /// Extra inset applied to all selector edges only while dragging.
  ///
  /// The default NaN sentinel resolves through the HyperOS 4 theme token.
  final double dragSelectionInset;

  /// Optional selected-item indicator color (legado-style primary selection).
  ///
  /// When non-null: the selection pill uses this hue at a soft fill alpha,
  /// and the selected icon/label tint to this color at full strength. Null
  /// uses the shared translucent lens and readable theme accent.
  final Color? selectedIndicatorColor;

  /// Independent selection fill, including its alpha. The surrounding glass
  /// opacity never weakens this layer or the selected foreground tint.
  final Color? selectedBackgroundColor;

  /// Optional resting icon/label color, independent of the selected tint.
  final Color? unselectedContentColor;

  /// Optional final glass tint opacity, before multiplying [color]'s alpha.
  /// Overrides global tint scaling while retaining the global blur strength.
  /// Use a readable backing over busy content; null keeps the theme recipe.
  final double? backgroundOpacity;

  @override
  Widget build(BuildContext context) {
    return _MiuixNavigationInsetsBuilder(
      builder: (context, nativeInsets) =>
          _buildWithInsets(context, nativeInsets),
    );
  }

  Widget _buildWithInsets(
    BuildContext context,
    MiuixWindowInsets? nativeInsets,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final mediaPadding = MediaQuery.paddingOf(context);
    final miuixTheme = MiuixTheme.of(context);
    final hyperOs4 = miuixTheme.hyperOs4;
    // The surface keeps one visual margin above the safe region. The safe
    // region itself remains transparent so Android's gesture bar is never
    // painted as part of the navigation capsule.
    // Host safety can include rounded corners or waterfall edges beyond the
    // system navigation strip. Never replace that larger safe area.
    final systemBottom = math.max(
      nativeInsets?.navigationBarBottom ?? 0,
      mediaPadding.bottom,
    );
    final effectiveBottomMargin = bottomMargin.isFinite
        ? math.max(0.0, bottomMargin)
        : hyperOs4.floatingNavigationBottomMargin;
    final bottomPadding = switch (defaultTargetPlatform) {
      TargetPlatform.iOS => effectiveBottomMargin,
      _ => effectiveBottomMargin + systemBottom,
    };
    final captionBottom = defaultWindowInsetsPadding
        ? nativeInsets?.captionBarBottom ?? 0.0
        : 0.0;
    final safeSelected = items.isEmpty
        ? -1
        : selectedIndex.clamp(0, items.length - 1);
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final sourceSurfaceMinHeight = _miuixRoundLogicalDimension(
      hyperOs4.floatingNavigationHeight,
      pixelRatio,
    );
    final sourceItemSpacing = _miuixRoundLogicalDimension(
      hyperOs4.floatingNavigationItemSpacing,
      pixelRatio,
    );
    final sourceHorizontalPadding = _miuixRoundLogicalDimension(
      hyperOs4.floatingNavigationHorizontalPadding,
      pixelRatio,
    );
    final upperShadowPaintExtent = _MiuixFloatingShadowPaintScope.maybeOf(
      context,
    );
    final explicitItemExtent = itemExtent.isFinite
        ? itemExtent.clamp(48.0, 96.0).toDouble()
        : null;
    // HyperOS 4 gives every destination a count-dependent fixed width. Visible
    // or layout-only labels must never enlarge a particular item or the whole
    // capsule; long localized labels scale down inside that stable region.
    final minimumItemWidth = hyperOs4.floatingNavigationItemWidth(items.length);
    final explicitItemWidth = itemWidth.isFinite
        ? itemWidth.clamp(48.0, 160.0).toDouble()
        : explicitItemExtent;
    final explicitItemHeight = itemHeight.isFinite
        ? itemHeight.clamp(48.0, 96.0).toDouble()
        : explicitItemExtent;
    final safeItemWidth = explicitItemWidth ?? minimumItemWidth;
    // 所有目的地按最长真实标签预留相同高度，选中加粗不会改变整排基线。
    final labelHeight = _floatingNavigationLabelHeight(
      context,
      items,
      math.max(1, safeItemWidth - 8),
      displayMode,
    );
    final labelFont =
        displayMode == MiuixFloatingNavigationBarDisplayMode.textOnly
        ? 14.0
        : 12.0;
    // 基线同样向外取整，普通字号不因不足一像素的误差抬高整条胶囊。
    final baseLabelHeight = (labelFont * 1.16 * pixelRatio).ceil() / pixelRatio;
    final captionExtra = math.max(0.0, labelHeight - baseLabelHeight);
    // 两倍字号与长中文只增加高度，不再用 FittedBox 缩小文字。
    final requiredHeight =
        displayMode == MiuixFloatingNavigationBarDisplayMode.iconOnly
        ? 48.0
        : displayMode == MiuixFloatingNavigationBarDisplayMode.textOnly
        ? labelHeight + 28
        : 24 + hyperOs4.floatingNavigationContentSpacing + labelHeight + 8;
    final safeItemHeight = math.max(
      explicitItemHeight ?? hyperOs4.floatingNavigationItemHeight,
      requiredHeight,
    );
    final safeSelectionInset = selectionHorizontalInset.isFinite
        ? selectionHorizontalInset.clamp(0.0, safeItemWidth / 2).toDouble()
        : hyperOs4.floatingNavigationSelectionInset;
    final safeSelectionHeight = selectionHeight.isFinite
        ? selectionHeight.clamp(0.0, safeItemHeight).toDouble()
        : hyperOs4.floatingNavigationSelectionHeight + captionExtra;
    final sourceDragSelectionInset = dragSelectionInset.isFinite
        ? dragSelectionInset
        : hyperOs4.floatingNavigationDragSelectionInset;
    final safeDragSelectionInset = sourceDragSelectionInset
        .clamp(0.0, safeSelectionHeight / 2)
        .toDouble();
    final effectiveCornerRadius = cornerRadius.isFinite
        ? math.max(0.0, cornerRadius)
        : hyperOs4.floatingNavigationCornerRadius;
    // One material recipe for every caller: the lens is distinct without a
    // second opaque panel. Hue-preserving contrast avoids gray active labels.
    final panelColor = color ?? scheme.surface;
    // 成对层次优先于默认推导，显式组件参数仍保留最高优先级。
    final accentLayers = MiuixAccentLayers.maybeOf(context);
    final resolvedPanelOpacity = MiuixGlassOptics.navigation.resolveOpacity(
      // 先解析一次全局档位，后续只做可读性约束，不再次乘强度。
      accentLayers?.navigationPanelOpacity ??
          hyperOs4.floatingNavigationTintOpacity,
      miuixTheme.glassIntensity,
    );
    // 应用提供的成对色依赖最低衬底，强玻璃不能再把它乘到近乎透明。
    // 显式组件覆盖仍优先；没有扩展的调用保持原五档材质契约。
    final panelOpacity =
        // 显式覆盖属于调用者契约，仍允许其独立决定最终透明度。
        backgroundOpacity ??
        (accentLayers == null
            ? resolvedPanelOpacity
            : math.max(
                // 成对颜色的最低背景只可增加，不能被最高玻璃档削弱。
                accentLayers.navigationPanelOpacity,
                resolvedPanelOpacity,
              ));
    final lensColor =
        selectedBackgroundColor ??
        accentLayers?.navigationFill ??
        (selectedIndicatorColor == null
            ? Color.lerp(
                panelColor,
                scheme.primary,
                // 无宿主角色时同样保留明确选中染色，避免浅色镜片消失。
                // 仅局部镜片加深，外壳材质与宿主显式覆盖保持独立。
                scheme.brightness == Brightness.dark ? .40 : .44,
              )!.withValues(
                alpha: scheme.brightness == Brightness.dark ? .78 : .80,
              )
            : selectedIndicatorColor!.withValues(
                alpha: scheme.brightness == Brightness.dark ? .22 : .14,
              ));
    final accentColor =
        selectedIndicatorColor ??
        accentLayers?.navigationForeground ??
        _floatingNavigationAccent(
          scheme.primary,
          lensColor,
          panelColor.withValues(alpha: panelOpacity * panelColor.a),
          scheme.brightness,
        );
    final content = _MiuixFloatingNavigationContent(
      items: items,
      selectedIndex: safeSelected,
      // A configuration-driven preview may intentionally omit callbacks.
      // Keep it renderable in release; controlled selection remains fixed and
      // taps become inert until the owner supplies either callback spelling.
      onSelected: onDestinationSelected ?? onSelected,
      displayMode: displayMode,
      itemWidth: safeItemWidth,
      itemHeight: safeItemHeight,
      labelHeight: labelHeight,
      itemSpacing: sourceItemSpacing,
      surfaceHeight: sourceSurfaceMinHeight + captionExtra,
      selectionInset: safeSelectionInset,
      selectionHeight: capsule
          ? math.max(
              0.0,
              math.max(sourceSurfaceMinHeight + captionExtra, safeItemHeight) -
                  2 * (sourceHorizontalPadding + safeSelectionInset),
            )
          : safeSelectionHeight,
      capsule: capsule,
      surfaceCornerRadius: effectiveCornerRadius,
      dragEnabled: dragEnabled && (onDestinationSelected ?? onSelected) != null,
      dragSelectionInset: safeDragSelectionInset,
      contentSpacing: hyperOs4.floatingNavigationContentSpacing,
      selectionDuration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : hyperOs4.floatingNavigationMotion,
      selectedIndicatorColor: accentColor,
      selectedBackgroundColor: lensColor,
      // 未选项仍可操作，使用校准中性前景而不是禁用灰字。
      unselectedContentColor:
          // 宿主未给新角色时保留旧方案，避免破坏既有第三方调用。
          unselectedContentColor ??
          accentLayers?.navigationUnselectedForeground ??
          scheme.onSurfaceVariant,
    );
    final safeElevation = shadowElevation.isFinite
        ? math.max(0.0, shadowElevation)
        : 0.0;
    final Widget bar;
    ShapeBorder navigationShape([BorderSide side = BorderSide.none]) => capsule
        ? MiuixCapsuleBorder(side: side)
        : miuixTheme.enableSquircle
        ? MiuixSquircleBorder(
            borderRadius: BorderRadius.circular(effectiveCornerRadius),
            side: side,
          )
        : RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(effectiveCornerRadius),
            side: side,
          );
    if (glass) {
      bar = DecoratedBox(
        key: const ValueKey('floating-navigation-surface'),
        decoration: ShapeDecoration(shape: navigationShape()),
        child: MiuixGlass(
          key: const ValueKey('floating-navigation-glass'),
          // HyperOS 4 uses a softer, more translucent floating material. The
          // five-level controller scales this complete calibrated recipe.
          // 已解析的配方直接交给玻璃，未提供扩展时继续由玻璃处理档位。
          // 两条路径都只缩放一次模糊，不改变导航命中区或布局。
          blur: backgroundOpacity == null && accentLayers == null
              ? hyperOs4.floatingNavigationBlur
              : MiuixGlassOptics.navigation.resolveBlur(
                  hyperOs4.floatingNavigationBlur,
                  miuixTheme.glassIntensity,
                ),
          // 已在上面处理强度与可读下限；MiuixGlass不能再缩放第二次。
          // 模糊强度仍随全局档位变化，不以完全实底替代玻璃。
          opacity: accentLayers != null
              ? panelOpacity
              : backgroundOpacity?.clamp(0.0, 1.0) ??
                    hyperOs4.floatingNavigationTintOpacity,
          useGlobalIntensity: backgroundOpacity == null && accentLayers == null,
          // 关闭重复缩放不等于强制打开玻璃，系统／主题的禁用仍生效。
          enabled: miuixTheme.enableGlass,
          color: panelColor,
          radius: effectiveCornerRadius,
          shape: capsule ? navigationShape() : null,
          padding: EdgeInsets.symmetric(horizontal: sourceHorizontalPadding),
          showSpecular: true,
          optics: MiuixGlassOptics.navigation,
          border: showDivider
              ? BorderSide(color: scheme.outlineVariant, width: .75)
              : null,
          child: content,
        ),
      );
    } else {
      final shape = navigationShape(
        showDivider
            ? BorderSide(color: scheme.outlineVariant, width: .75)
            : BorderSide.none,
      );
      final paddedContent = Padding(
        // Each horizontal edge is an independent Compose padding node.
        padding: EdgeInsets.symmetric(horizontal: sourceHorizontalPadding),
        child: content,
      );
      bar = KeyedSubtree(
        key: const ValueKey('floating-navigation-surface'),
        child: miuixTheme.enableSquircle && !capsule
            ? DecoratedBox(
                // The SDF owns the fill. ShapeDecoration retains only the
                // optional source divider above that exact background.
                decoration: ShapeDecoration(shape: shape),
                child: MiuixSquircleBackground(
                  color: color ?? scheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(effectiveCornerRadius),
                  child: paddedContent,
                ),
              )
            : DecoratedBox(
                decoration: ShapeDecoration(
                  color: color ?? scheme.surfaceContainer,
                  shape: shape,
                ),
                child: paddedContent,
              ),
      );
    }
    final paintedBar = safeElevation > 0
        ? CustomPaint(
            key: const ValueKey('floating-navigation-shadow'),
            painter: _MiuixFloatingNavigationShadowPainter(
              shape: navigationShape(),
              textDirection: Directionality.of(context),
              topInset: upperShadowPaintExtent,
            ),
            child: upperShadowPaintExtent > 0
                ? Padding(
                    padding: EdgeInsets.only(top: upperShadowPaintExtent),
                    child: bar,
                  )
                : bar,
          )
        : bar;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return KeyedSubtree(
      key: const ValueKey('floating-navigation-caption-inset-animation'),
      child: TweenAnimationBuilder<double>(
        // A policy-keyed state guarantees that enabling reduced motion during
        // an active native-inset transition publishes the endpoint at once.
        key: ValueKey(reduceMotion),
        tween: Tween<double>(end: captionBottom),
        duration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 300),
        curve: Curves.linear,
        builder: (context, animatedCaptionBottom, _) => Padding(
          padding: EdgeInsetsDirectional.only(
            start: alignment == MiuixFloatingNavigationBarAlignment.start
                ? horizontalOutsidePadding
                : 0,
            end: alignment == MiuixFloatingNavigationBarAlignment.end
                ? horizontalOutsidePadding
                : 0,
            // Both inset modifiers precede the surface background in the source,
            // so they move the capsule instead of extending its visible fill.
            bottom: bottomPadding + animatedCaptionBottom,
          ),
          // A Row fills only the horizontal axis while retaining the bar's
          // intrinsic height. Align would also expand vertically under Scaffold's
          // loose bottom-bar constraints and could consume the whole body area.
          child: Row(
            mainAxisAlignment: switch (alignment) {
              MiuixFloatingNavigationBarAlignment.start =>
                MainAxisAlignment.start,
              MiuixFloatingNavigationBarAlignment.center =>
                MainAxisAlignment.center,
              MiuixFloatingNavigationBarAlignment.end => MainAxisAlignment.end,
            },
            children: [paintedBar],
          ),
        ),
      ),
    );
  }
}

Color _floatingNavigationAccent(
  Color accent,
  Color lens,
  Color panel,
  Brightness brightness,
) {
  final backgrounds = [
    Color.alphaBlend(lens, Color.alphaBlend(panel, Colors.black)),
    Color.alphaBlend(lens, Color.alphaBlend(panel, Colors.white)),
  ];
  final hsl = HSLColor.fromColor(accent);
  final end = brightness == Brightness.dark ? 1.0 : 0.0;
  for (var step = 0; step <= 100; step++) {
    final candidate = hsl
        .withLightness(hsl.lightness + (end - hsl.lightness) * step / 100)
        .toColor();
    final foreground = candidate.computeLuminance();
    if (backgrounds.every((background) {
      final value = background.computeLuminance();
      return (math.max(foreground, value) + .05) /
              (math.min(foreground, value) + .05) >=
          4.5;
    })) {
      return candidate;
    }
  }
  return hsl.withLightness(end).toColor();
}

class _MiuixFloatingNavigationContent extends StatefulWidget {
  const _MiuixFloatingNavigationContent({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    required this.displayMode,
    required this.itemWidth,
    required this.itemHeight,
    required this.labelHeight,
    required this.itemSpacing,
    required this.surfaceHeight,
    required this.selectionInset,
    required this.selectionHeight,
    required this.capsule,
    required this.surfaceCornerRadius,
    required this.dragEnabled,
    required this.dragSelectionInset,
    required this.contentSpacing,
    required this.selectionDuration,
    this.selectedIndicatorColor,
    this.selectedBackgroundColor,
    this.unselectedContentColor,
  });

  final List<MiuixNavigationItem> items;
  final int selectedIndex;
  final ValueChanged<int>? onSelected;
  final MiuixFloatingNavigationBarDisplayMode displayMode;
  final double itemWidth;
  final double itemHeight;
  final double labelHeight;
  final double itemSpacing;
  final double surfaceHeight;
  final double selectionInset;
  final double selectionHeight;
  final bool capsule;
  final double surfaceCornerRadius;
  final bool dragEnabled;
  final double dragSelectionInset;
  final double contentSpacing;
  final Duration selectionDuration;
  final Color? selectedIndicatorColor;
  final Color? selectedBackgroundColor;
  final Color? unselectedContentColor;

  @override
  State<_MiuixFloatingNavigationContent> createState() =>
      _MiuixFloatingNavigationContentState();
}

class _MiuixFloatingNavigationContentState
    extends State<_MiuixFloatingNavigationContent>
    with TickerProviderStateMixin {
  late final AnimationController _position;
  late final AnimationController _pickup;
  late final AnimationController _deformation;
  Duration? _lastDragTimestamp;
  var _dragging = false;
  var _held = false;
  int? _pointer;
  double _pointerStart = 0;
  int? _settleTarget;
  double _pickupOffset = 0;
  var _dragGrabOffset = 0.0;
  var _lastDragIndex = -1;

  int get _safeSelected => widget.items.isEmpty
      ? -1
      : widget.selectedIndex.clamp(0, widget.items.length - 1);

  double get _visualPosition => _position.value + _pickupOffset * _pickup.value;

  double get _itemPitch => widget.itemWidth + widget.itemSpacing;

  @override
  void initState() {
    super.initState();
    _position = AnimationController.unbounded(
      vsync: this,
      value: math.max(0, _safeSelected).toDouble(),
    );
    _pickup = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
    );
    _deformation = AnimationController.unbounded(vsync: this);
  }

  @override
  void didUpdateWidget(covariant _MiuixFloatingNavigationContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    final selected = _safeSelected;
    if (selected < 0) {
      _dragging = false;
      _held = false;
      _pointer = null;
      _dragGrabOffset = 0;
      _lastDragIndex = -1;
      _pickup.stop();
      _pickup.value = 0;
      _deformation
        ..stop()
        ..value = 0;
      _position
        ..stop()
        ..value = 0;
      return;
    }
    if (_dragging) {
      // A destination list may shrink while a pointer is held. Keep the live
      // thumb inside the new equal-width domain and discard an index that no
      // longer exists instead of leaving the state permanently in drag mode.
      _position.value = _position.value.clamp(0.0, widget.items.length - 1.0);
      _lastDragIndex = _position.value.round().clamp(
        0,
        widget.items.length - 1,
      );
      return;
    }
    if (oldWidget.selectedIndex != widget.selectedIndex ||
        oldWidget.items.length != widget.items.length) {
      if (_settleTarget != selected || !_position.isAnimating) {
        _settleTo(selected, velocity: _position.velocity);
      }
    }
  }

  @override
  void dispose() {
    _position.dispose();
    _pickup.dispose();
    _deformation.dispose();
    super.dispose();
  }

  SpringDescription get _selectionSpring =>
      const SpringDescription(mass: 1, stiffness: 430, damping: 32);

  // Only the lens deforms; pointer tracking and destination hit areas stay fixed.
  void _relaxDeformation({double impulse = 0}) {
    if (MediaQuery.disableAnimationsOf(context) ||
        widget.selectionDuration == Duration.zero) {
      _deformation
        ..stop()
        ..value = 0;
      return;
    }
    _deformation.animateWith(
      SpringSimulation(
        const SpringDescription(mass: 1, stiffness: 200, damping: 22),
        _deformation.value.clamp(-.15, 1.0),
        0,
        impulse.clamp(0.0, 24.0),
        tolerance: const Tolerance(distance: .001, velocity: .001),
      ),
    );
  }

  void _settleTo(int index, {double velocity = 0}) {
    final target = index.clamp(0, math.max(0, widget.items.length - 1));
    _settleTarget = target.toInt();
    final current = _visualPosition;
    _pickup.stop();
    _pickup.value = 0;
    _position.stop();
    _position.value = current;
    if (MediaQuery.disableAnimationsOf(context) ||
        widget.selectionDuration == Duration.zero) {
      _position.value = target.toDouble();
      return;
    }
    _position.animateWith(
      SpringSimulation(
        _selectionSpring,
        _position.value,
        target.toDouble(),
        velocity.clamp(-10.0, 10.0),
        tolerance: const Tolerance(distance: .001, velocity: .001),
      ),
    );
  }

  double _logicalPositionAt(double physicalX) {
    if (_itemPitch <= 0 || widget.items.isEmpty) return _position.value;
    final contentWidth =
        widget.itemWidth * widget.items.length +
        widget.itemSpacing * math.max(0, widget.items.length - 1);
    final logicalX = Directionality.of(context) == TextDirection.ltr
        ? physicalX
        : contentWidth - physicalX;
    return (logicalX - widget.itemWidth / 2) / _itemPitch;
  }

  void _handleDragStart(DragStartDetails details) {
    if (!mounted) return;
    if (!widget.dragEnabled || _safeSelected < 0 || !_held) return;
    _position.stop();
    // Capture once: a touch on another item joins the finger continuously.
    // Subsequent pointer samples remain direct, never restarting a spring.
    final current = _visualPosition;
    _pickup.stop();
    final origin = _pointerStart.round().clamp(0, widget.items.length - 1);
    _dragGrabOffset = _pointerStart - origin;
    _position.value = origin.toDouble();
    _pickupOffset = current - origin;
    _pickup.value = MediaQuery.disableAnimationsOf(context) ? 0 : 1;
    if (_pickup.value > 0) _pickup.animateTo(0, curve: Curves.easeOutCubic);
    _lastDragIndex = _position.value.round().clamp(0, widget.items.length - 1);
    _lastDragTimestamp = details.sourceTimeStamp;
    setState(() => _dragging = true);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!mounted) return;
    if (!_dragging || widget.items.isEmpty) return;
    final next =
        (_logicalPositionAt(details.localPosition.dx) - _dragGrabOffset).clamp(
          0.0,
          widget.items.length - 1.0,
        );
    final elapsed =
        details.sourceTimeStamp != null && _lastDragTimestamp != null
        ? (details.sourceTimeStamp! - _lastDragTimestamp!).inMicroseconds /
              1000000
        : 1 / 60;
    final speed = (next - _position.value).abs() / math.max(1 / 120, elapsed);
    _lastDragTimestamp = details.sourceTimeStamp;
    _relaxDeformation(impulse: speed * 3);
    _position.value = next;
    final crossed = next.round().clamp(0, widget.items.length - 1);
    if (crossed != _lastDragIndex && widget.items[crossed].enabled) {
      _lastDragIndex = crossed;
      unawaited(MiuixHaptics.perform(MiuixHapticType.segmentTick));
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!mounted) return;
    if (!_dragging || widget.items.isEmpty) return;
    final direction = Directionality.of(context) == TextDirection.ltr ? 1 : -1;
    final velocity = _itemPitch <= 0
        ? 0.0
        : direction * (details.primaryVelocity ?? 0) / _itemPitch;
    // Commit the nearest actual slot. Velocity affects settlement, never the
    // destination, so a fast release cannot select a tab outside the finger.
    var target = _position.value.round().clamp(0, widget.items.length - 1);
    if (!widget.items[target].enabled) target = _safeSelected;
    setState(() => _dragging = false);
    _relaxDeformation();
    _settleTo(target, velocity: velocity);
    if (target != _safeSelected) widget.onSelected?.call(target);
  }

  void _handleDragCancel() {
    if (!mounted) return;
    if (!_dragging) return;
    setState(() => _dragging = false);
    _relaxDeformation();
    if (_safeSelected >= 0) _settleTo(_safeSelected);
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (!mounted) return;
    if (_pointer != null || widget.items.isEmpty || widget.onSelected == null) {
      return;
    }
    final position = _logicalPositionAt(event.localPosition.dx);
    final index = position.round().clamp(0, widget.items.length - 1);
    if (!widget.items[index].enabled) return;
    _pointer = event.pointer;
    _pointerStart = position;
    setState(() => _held = true);
  }

  void _handlePointerUp(PointerEvent event) {
    if (!mounted) return;
    if (event.pointer != _pointer) return;
    _pointer = null;
    setState(() => _held = false);
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    if (!mounted) return;
    if (event.pointer != _pointer) return;
    _handleDragCancel();
    _handlePointerUp(event);
  }

  void _handleItemPressed(int index) {
    if (!mounted) return;
    if (widget.onSelected == null) return;
    if (index != _safeSelected) {
      unawaited(MiuixHaptics.perform(MiuixHapticType.segmentTick));
    }
    _settleTo(index, velocity: _position.velocity);
    widget.onSelected?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    final selectedIndex = _safeSelected;
    final displayMode = widget.displayMode;
    final itemWidth = widget.itemWidth;
    final itemHeight = widget.itemHeight;
    final itemSpacing = widget.itemSpacing;
    final surfaceHeight = widget.surfaceHeight;
    final selectionInset = widget.selectionInset;
    final selectionHeight = widget.selectionHeight;
    final surfaceCornerRadius = widget.surfaceCornerRadius;
    final contentSpacing = widget.contentSpacing;
    final itemCount = items.length;
    final contentWidth = itemCount == 0
        ? 0.0
        : itemWidth * itemCount + itemSpacing * math.max(0, itemCount - 1);
    final contentHeight = math.max(surfaceHeight, itemHeight);
    final scheme = Theme.of(context).colorScheme;
    final theme = MiuixTheme.of(context);
    final customIndicator = widget.selectedIndicatorColor;
    // Soft primary pill + solid primary icon: readable on clear glass without
    // looking like a loud Material NavigationBar.
    final indicatorColor =
        widget.selectedBackgroundColor ??
        (customIndicator == null
            ? (scheme.brightness == Brightness.light
                  ? scheme.surfaceContainerHighest.withValues(alpha: .28)
                  : scheme.onSurface.withValues(alpha: .12))
            : customIndicator.withValues(
                alpha: scheme.brightness == Brightness.light ? .14 : .22,
              ));
    final selectedTint = customIndicator;
    Widget contentRow(double position, double engagement) => Positioned.fill(
      child: Row(
        key: const ValueKey('floating-navigation-content-row'),
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < items.length; index++) ...[
            if (index > 0) SizedBox(width: itemSpacing),
            _MiuixFloatingNavigationBarItem(
              key: ValueKey('floating-navigation-item-$index'),
              selected: selectedIndex == index,
              selectionProgress: items[index].enabled
                  ? (1 - (position - index).abs()).clamp(0.0, 1.0)
                  : 0,
              engagement: engagement,
              enabled: items[index].enabled,
              onPressed: () => _handleItemPressed(index),
              icon: items[index].icon,
              selectedIcon: items[index].selectedIcon,
              badge: items[index].badge,
              label: items[index].label,
              layoutLabel: items[index].layoutLabel,
              displayMode: displayMode,
              itemWidth: itemWidth,
              itemHeight: itemHeight,
              labelHeight: widget.labelHeight,
              contentSpacing: contentSpacing,
              indicatorColor: selectedTint,
              unselectedColor: widget.unselectedContentColor,
            ),
          ],
        ],
      ),
    );
    final shrinkDuration =
        widget.selectionDuration == Duration.zero ||
            MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 140);
    return Listener(
      onPointerDown: _handlePointerDown,
      onPointerUp: _handlePointerUp,
      onPointerCancel: _handlePointerCancel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        dragStartBehavior: DragStartBehavior.down,
        onHorizontalDragStart: widget.dragEnabled ? _handleDragStart : null,
        onHorizontalDragUpdate: widget.dragEnabled ? _handleDragUpdate : null,
        onHorizontalDragEnd: widget.dragEnabled ? _handleDragEnd : null,
        onHorizontalDragCancel: widget.dragEnabled ? _handleDragCancel : null,
        child: TweenAnimationBuilder<double>(
          key: const ValueKey('floating-navigation-drag-size-animation'),
          tween: Tween<double>(
            end: _dragging || _held ? widget.dragSelectionInset : 0,
          ),
          duration: shrinkDuration,
          curve: Curves.easeOutCubic,
          builder: (context, dragInset, _) {
            // Direct manipulation uses a smaller slider than the settled state.
            // Applying one inset to every edge keeps the shrunken outline
            // concentric instead of scaling it around an imprecise transform.
            final indicatorWidth = math.max(
              0.0,
              itemWidth - selectionInset * 2 - dragInset * 2,
            );
            final indicatorHeight = math.max(
              0.0,
              selectionHeight.clamp(0.0, contentHeight) - dragInset * 2,
            );
            final indicatorTop = (contentHeight - indicatorHeight) / 2;
            final indicatorRadius = math.min(
              indicatorHeight / 2,
              math.max(0.0, surfaceCornerRadius - indicatorTop),
            );
            final indicatorShape = widget.capsule
                ? const MiuixCapsuleBorder()
                : theme.enableSquircle
                ? MiuixSquircleBorder(
                    borderRadius: BorderRadius.circular(indicatorRadius),
                    side: BorderSide.none,
                  )
                : RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(indicatorRadius),
                    side: BorderSide.none,
                  );
            return AnimatedBuilder(
              animation: Listenable.merge([_position, _pickup, _deformation]),
              builder: (context, _) {
                // A fast release may briefly overshoot its spring endpoint. The
                // slider stays inside the first and last destinations while the
                // controller retains that velocity for visible settlement.
                final visualPosition = _visualPosition.clamp(
                  0.0,
                  math.max(0, itemCount - 1).toDouble(),
                );
                final reducedMotion =
                    MediaQuery.disableAnimationsOf(context) ||
                    widget.selectionDuration == Duration.zero;
                final engagement = widget.dragSelectionInset == 0
                    ? 0.0
                    : (dragInset / widget.dragSelectionInset).clamp(0.0, 1.0);
                final travelStretch = _dragging || !_position.isAnimating
                    ? 0.0
                    : (_position.velocity.abs() / 16).clamp(0.0, 1.0);
                final stretch = reducedMotion
                    ? 0.0
                    : math.max(
                        _deformation.isAnimating
                            ? _deformation.value.clamp(-.15, 1.0)
                            : 0.0,
                        travelStretch,
                      );
                // Leave equal room on both sides at the ends of the bar so the
                // animated lens never pulls away from the pointer or clips.
                final center = visualPosition * _itemPitch + itemWidth / 2;
                final availableWidth =
                    2 * math.min(center, contentWidth - center);
                final width = math.min(
                  availableWidth,
                  indicatorWidth +
                      math.min(16.0, indicatorWidth * .22) * stretch,
                );
                final height = indicatorHeight * (1 - .065 * stretch);
                final start =
                    (visualPosition * (itemWidth + itemSpacing) +
                            selectionInset +
                            dragInset -
                            (width - indicatorWidth) / 2)
                        .clamp(0.0, math.max(0.0, contentWidth - width));
                return SizedBox(
                  width: contentWidth,
                  height: contentHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      if (selectedIndex >= 0)
                        PositionedDirectional(
                          key: const ValueKey(
                            'floating-navigation-selection-indicator',
                          ),
                          start: start.toDouble(),
                          top: (contentHeight - height) / 2,
                          width: width.toDouble(),
                          height: height,
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: ShapeDecoration(
                                color: indicatorColor,
                                shape: indicatorShape,
                              ),
                            ),
                          ),
                        ),
                      contentRow(
                        visualPosition,
                        reducedMotion ? 0 : engagement,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// Supplies the latest split Android insets without delaying first layout.
///
/// A nullable sample is intentional: before the EventChannel emits, callers
/// use MediaQuery for the navigation-bar value. Once a native sample arrives,
/// even an explicit zero must replace that fallback because MediaQuery may be
/// carrying a caption bar or another combined system-safe region.
class _MiuixNavigationInsetsBuilder extends StatelessWidget {
  const _MiuixNavigationInsetsBuilder({required this.builder});

  final Widget Function(BuildContext, MiuixWindowInsets?) builder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MiuixWindowInsets>(
      stream: MiuixWindowInsetsObserver.events,
      builder: (context, snapshot) => builder(context, snapshot.data),
    );
  }
}

/// Paints the source zero-offset halo before the opaque or glass capsule.
///
/// Flutter's ShapeDecoration shadow was clipped to the lower half when this
/// widget occupied a bottom-bar layer. Drawing the same path explicitly keeps
/// the 10dp blur symmetric and prevents any rectangular corner fill.
///
/// The painter receives the same [ShapeBorder] as the visible surface. This is
/// important when squircle rendering is enabled: painting a rounded rectangle
/// shadow around a squircle would leave a dark rectangular-looking wedge near
/// each corner even if the foreground capsule itself were correct.
///
/// [topInset] reserves canvas space above the surface only when the enclosing
/// scaffold can expose it. The path begins at that inset, so the surface and
/// shadow keep their native screen position while the blur expands equally in
/// both vertical directions.
///
/// A zero offset is deliberate. MIUIX uses a centered halo for this component,
/// not Material elevation's downward-biased key shadow. The public elevation
/// value acts as an enable gate; it does not scale the source blur radius.
class _MiuixFloatingNavigationShadowPainter extends CustomPainter {
  const _MiuixFloatingNavigationShadowPainter({
    required this.shape,
    required this.textDirection,
    required this.topInset,
  });

  final ShapeBorder shape;
  final TextDirection textDirection;
  final double topInset;

  @override
  void paint(Canvas canvas, Size size) {
    final path = shape.getOuterPath(
      Rect.fromLTWH(0, topInset, size.width, size.height - topInset),
      textDirection: textDirection,
    );
    final paint = BoxShadow(
      color: Colors.black.withValues(
        alpha: MiuixFloatingNavigationBar.sourceShadowOpacity,
      ),
      blurRadius: MiuixFloatingNavigationBar.sourceShadowRadius,
    ).toPaint();
    // 透明玻璃不能覆盖实心投影：只保留轮廓外的阴影，避免底色发灰。
    // Transparent glass exposes a filled shadow, so exclude the capsule
    // interior before painting the halo. Match the surface's exact path.
    canvas.save();
    canvas.clipPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(
          path.getBounds().inflate(
            MiuixFloatingNavigationBar.sourceShadowRadius * 3,
          ),
        ),
        path,
      ),
    );
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MiuixFloatingNavigationShadowPainter oldDelegate) {
    return oldDelegate.shape != shape ||
        oldDelegate.textDirection != textDirection ||
        oldDelegate.topInset != topInset;
  }
}

/// Marks the full-window scaffold path that can reserve upper shadow paint.
///
/// The scope avoids coupling the navigation component to a particular scaffold
/// implementation. Outside [MiuixScaffold] the bar remains usable and simply
/// paints within the bounds its parent provides. Inside the scaffold it learns
/// how much extra canvas was reserved above the measured capsule.
///
/// This inherited value is intentionally a logical-pixel extent rather than a
/// boolean. Custom animated wrappers can forward the exact source radius, while
/// the iOS-like extension can explicitly request zero without being mistaken
/// for the standard MIUIX shadow pipeline.
///
/// Only descendants that read [maybeOf] rebuild when the extent changes. The
/// popup, snackbar, and page layers remain independent of this paint detail.
class _MiuixFloatingShadowPaintScope extends InheritedWidget {
  const _MiuixFloatingShadowPaintScope({
    required this.paintExtent,
    required super.child,
  });

  final double paintExtent;

  static double maybeOf(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<
              _MiuixFloatingShadowPaintScope
            >()
            ?.paintExtent ??
        0;
  }

  @override
  bool updateShouldNotify(_MiuixFloatingShadowPaintScope oldWidget) {
    return oldWidget.paintExtent != paintExtent;
  }
}

// 使用最终文字和真实字号测量，不再用隐藏的英文标签冒充中文宽高。
double _floatingNavigationLabelHeight(
  BuildContext context,
  List<MiuixNavigationItem> items,
  double width,
  MiuixFloatingNavigationBarDisplayMode mode,
) {
  if (mode == MiuixFloatingNavigationBarDisplayMode.iconOnly) return 0;
  final fontSize = mode == MiuixFloatingNavigationBarDisplayMode.textOnly
      ? 14.0
      : 12.0;
  final style = (Theme.of(context).textTheme.labelMedium ?? const TextStyle())
      .copyWith(fontSize: fontSize, fontWeight: FontWeight.w700, height: 1.16);
  var height = MediaQuery.textScalerOf(context).scale(fontSize) * 1.16;
  for (final item in items) {
    // 按最大字重测量，拖动预览中的加粗动画也不会突然多出一行。
    final painter = TextPainter(
      text: TextSpan(text: item.label, style: style),
      textScaler: MediaQuery.textScalerOf(context),
      textDirection: Directionality.of(context),
    )..layout(maxWidth: width);
    height = math.max(height, painter.height);
    painter.dispose();
  }
  // 向外取整到物理像素，避免小数密度把最后一行裁掉一部分。
  final ratio = MediaQuery.devicePixelRatioOf(context);
  return (height * ratio).ceil() / ratio;
}

class _MiuixFloatingNavigationBarItem extends StatefulWidget {
  const _MiuixFloatingNavigationBarItem({
    super.key,
    required this.selected,
    required this.selectionProgress,
    required this.engagement,
    required this.enabled,
    required this.onPressed,
    required this.icon,
    this.selectedIcon,
    required this.badge,
    required this.label,
    required this.layoutLabel,
    required this.displayMode,
    required this.itemWidth,
    required this.itemHeight,
    required this.labelHeight,
    required this.contentSpacing,
    this.indicatorColor,
    this.unselectedColor,
  });

  final bool selected;
  final double selectionProgress;
  final double engagement;
  final bool enabled;
  final VoidCallback onPressed;
  final Widget icon;
  final Widget? selectedIcon;
  final Widget? badge;
  final String label;
  final String? layoutLabel;
  final MiuixFloatingNavigationBarDisplayMode displayMode;
  final double itemWidth;
  final double itemHeight;
  final double labelHeight;
  final double contentSpacing;
  final Color? indicatorColor;
  final Color? unselectedColor;

  @override
  State<_MiuixFloatingNavigationBarItem> createState() =>
      _MiuixFloatingNavigationBarItemState();
}

class _MiuixFloatingNavigationBarItemState
    extends State<_MiuixFloatingNavigationBarItem> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value && mounted) {
      setState(() => _pressed = value);
    }
  }

  @override
  void didUpdateWidget(covariant _MiuixFloatingNavigationBarItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled && !widget.enabled) {
      _pressed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final base = MiuixSemanticColors.of(context)['onSurfaceContainer'];
    final accent = widget.indicatorColor;
    // 视觉预览跟随镜片，语义选中状态仍保持已提交页面。
    // Visual emphasis follows the lens; semantics keep the committed page.
    final resting =
        widget.unselectedColor ??
        base.withValues(
          alpha: MiuixFloatingNavigationBarDefaults.unselectedAlpha,
        );
    final tint = Color.lerp(resting, accent ?? base, widget.selectionProgress)!;
    return Semantics(
      button: true,
      selected: widget.selected,
      enabled: widget.enabled,
      label: widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.enabled ? widget.onPressed : null,
        onTapDown: widget.enabled ? (_) => _setPressed(true) : null,
        onTapUp: widget.enabled ? (_) => _setPressed(false) : null,
        onTapCancel: widget.enabled ? () => _setPressed(false) : null,
        child: AnimatedScale(
          scale: MediaQuery.disableAnimationsOf(context)
              ? 1
              : (_pressed ? .97 : 1),
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 90),
          child: MiuixIconInteraction(
            navigation: true,
            enabled: widget.enabled,
            pressed: _pressed,
            selected: widget.selected,
            child: _buildMode(context, tint),
          ),
        ),
      ),
    );
  }

  Widget _buildMode(BuildContext context, Color tint) {
    final selectedWeight = FontWeight.lerp(
      FontWeight.w400,
      FontWeight.w700,
      widget.selectionProgress,
    );
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    Widget stableLabel({required double fontSize}) {
      final style = Theme.of(context).textTheme.labelMedium?.copyWith(
        color: tint,
        fontSize: fontSize,
        fontWeight: selectedWeight,
        height: 1.16,
      );
      // 全文自然换行，颜色动画与文字测量共用相同字体和行高。
      return Text(
        widget.label,
        style: style,
        textAlign: TextAlign.center,
        softWrap: true,
      );
    }

    final iconOnlyPadding = _miuixRoundLogicalDimension(
      MiuixFloatingNavigationBarDefaults.iconPadding,
      pixelRatio,
    );
    final iconOnlySize = _miuixRoundLogicalDimension(
      MiuixFloatingNavigationBarDefaults.iconSize,
      pixelRatio,
    );
    final iconTextSize = _miuixRoundLogicalDimension(24, pixelRatio);
    final textVerticalPadding = _miuixRoundLogicalDimension(14, pixelRatio);
    final textHorizontalPadding = _miuixRoundLogicalDimension(2, pixelRatio);
    Widget navigationIcon(
      double size, {
      required double iconTop,
      double? iconStart,
    }) {
      final icon = widget.selectionProgress >= .5
          ? widget.selectedIcon ?? widget.icon
          : widget.icon;
      final anchor = IconTheme(
        data: IconThemeData(color: tint, size: size),
        child: SizedBox.square(dimension: size, child: icon),
      );
      // Badge bounds are expressed from the icon's real position inside the
      // complete destination. Combined tabs center their icon horizontally,
      // while the explicit vertical origin keeps a tall badge inside the item.
      final centeredStart = (widget.itemWidth - size) / 2;
      final logicalStart = iconStart ?? centeredStart;
      final physicalStart = Directionality.of(context) == TextDirection.ltr
          ? logicalStart
          : widget.itemWidth - logicalStart - size;
      return _miuixNavigationIconWithBadge(
        icon: anchor,
        badge: widget.badge,
        // FloatingNavigationBarItem installs badgeBounds() on the complete
        // item Column, while NavigationItemIcon remains centered within it.
        sourceBounds: Rect.fromLTRB(
          -physicalStart,
          -iconTop,
          widget.itemWidth - physicalStart,
          double.infinity,
        ),
      );
    }

    Widget iconOnlyContent() => Padding(
      padding: EdgeInsets.all(iconOnlyPadding),
      child: navigationIcon(
        iconOnlySize,
        iconTop: (widget.itemHeight - iconOnlySize) / 2,
      ),
    );

    Widget iconAndTextContent() => Builder(
      builder: (context) {
        final labelHeight = widget.labelHeight;
        final contentHeight =
            iconTextSize + widget.contentSpacing + labelHeight;
        final contentTop = (widget.itemHeight - contentHeight) / 2;
        return SizedBox(
          key: const ValueKey('floating-navigation-vertical-content'),
          width: math.max(0, widget.itemWidth - 8),
          height: contentHeight,
          // HyperOS 4 combined destinations place the label below the icon.
          // Both nodes stay centered so localization cannot shift an item.
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              navigationIcon(iconTextSize, iconTop: contentTop),
              SizedBox(
                key: const ValueKey('floating-navigation-content-spacing'),
                height: widget.contentSpacing,
              ),
              SizedBox(
                width: math.max(0, widget.itemWidth - 8),
                height: labelHeight,
                // 多行与单行标签共用第一行基线，不在预留高度中上下漂移。
                child: Align(
                  alignment: Alignment.topCenter,
                  child: stableLabel(fontSize: 12),
                ),
              ),
            ],
          ),
        );
      },
    );

    return SizedBox(
      width: widget.itemWidth,
      height: widget.itemHeight,
      child: Center(
        child: switch (widget.displayMode) {
          MiuixFloatingNavigationBarDisplayMode.iconOnly => iconOnlyContent(),
          MiuixFloatingNavigationBarDisplayMode.iconAndText =>
            iconAndTextContent(),
          MiuixFloatingNavigationBarDisplayMode.iconWithSelectedLabel =>
            widget.selected ? iconAndTextContent() : iconOnlyContent(),
          MiuixFloatingNavigationBarDisplayMode.textOnly => Padding(
            padding: EdgeInsets.symmetric(
              vertical: textVerticalPadding,
              horizontal: textHorizontalPadding,
            ),
            child: Center(child: stableLabel(fontSize: 14)),
          ),
        },
      ),
    );
  }
}

