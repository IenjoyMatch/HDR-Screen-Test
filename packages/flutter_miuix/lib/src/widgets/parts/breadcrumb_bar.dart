part of '../miuix_widgets.dart';

/// One path segment displayed by [MiuixBreadcrumbBar].
@immutable
class MiuixBreadcrumbItem {
  /// Creates a breadcrumb item.
  const MiuixBreadcrumbItem({required this.path, this.text});

  /// Path segment used by [miuixJoinBreadcrumbPath].
  final String path;

  /// Optional display text; [path] is displayed when this is null.
  final String? text;

  /// Returns a copy with independently replaced fields.
  MiuixBreadcrumbItem copyWith({String? path, String? text}) {
    return MiuixBreadcrumbItem(
      path: path ?? this.path,
      text: text ?? this.text,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MiuixBreadcrumbItem &&
            other.path == path &&
            other.text == text;
  }

  @override
  int get hashCode => Object.hash(path, text);
}

/// Joins breadcrumb path segments using the requested separator.
String miuixJoinBreadcrumbPath(
  Iterable<MiuixBreadcrumbItem> items, {
  String separator = '/',
}) {
  return items.map((item) => item.path).join(separator);
}

/// Seven independently replaceable colors used by a breadcrumb bar.
@immutable
class MiuixBreadcrumbBarColors {
  /// Creates a breadcrumb color set.
  const MiuixBreadcrumbBarColors({
    required this.color,
    required this.highlightColor,
    required this.disabledColor,
    required this.separatorColor,
    required this.backgroundColor,
    required this.highlightBackgroundColor,
    required this.disabledBackgroundColor,
  });

  final Color color;
  final Color highlightColor;
  final Color disabledColor;
  final Color separatorColor;
  final Color backgroundColor;
  final Color highlightBackgroundColor;
  final Color disabledBackgroundColor;

  MiuixBreadcrumbBarColors copyWith({
    Color? color,
    Color? highlightColor,
    Color? disabledColor,
    Color? separatorColor,
    Color? backgroundColor,
    Color? highlightBackgroundColor,
    Color? disabledBackgroundColor,
  }) {
    return MiuixBreadcrumbBarColors(
      color: color ?? this.color,
      highlightColor: highlightColor ?? this.highlightColor,
      disabledColor: disabledColor ?? this.disabledColor,
      separatorColor: separatorColor ?? this.separatorColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      highlightBackgroundColor:
          highlightBackgroundColor ?? this.highlightBackgroundColor,
      disabledBackgroundColor:
          disabledBackgroundColor ?? this.disabledBackgroundColor,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MiuixBreadcrumbBarColors &&
            other.color == color &&
            other.highlightColor == highlightColor &&
            other.disabledColor == disabledColor &&
            other.separatorColor == separatorColor &&
            other.backgroundColor == backgroundColor &&
            other.highlightBackgroundColor == highlightBackgroundColor &&
            other.disabledBackgroundColor == disabledBackgroundColor;
  }

  @override
  int get hashCode => Object.hash(
    color,
    highlightColor,
    disabledColor,
    separatorColor,
    backgroundColor,
    highlightBackgroundColor,
    disabledBackgroundColor,
  );
}

/// Source metrics and palette defaults for [MiuixBreadcrumbBar].
abstract final class MiuixBreadcrumbBarDefaults {
  // Runtime width and highlight contract:
  // - Every segment receives one finite non-negative maximum width.
  // - Invalid current-style widths restore the 200dp HyperOS limit.
  // - Invalid source-style widths restore the former 160dp limit.
  // - A finite negative width clamps to the explicit zero-width request.
  // - Highlight centering measures the final constrained segment geometry.
  // - Dynamic list changes retain keys only for still-addressable indices.
  // - Empty lists expose no phantom highlighted segment or scroll request.
  // - Debug and Release therefore share the same constraint construction.

  /// Former MIUIX source geometry retained by `.source`.
  static const EdgeInsets insideMargin = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 8,
  );
  static const double itemHeight = 32;
  static const double itemHorizontalPadding = 10;
  static const double itemMaxWidth = 160;

  /// Project-calibrated HyperOS 4 inline geometry.
  static const EdgeInsets hyperOs4InsideMargin = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 6,
  );
  static const double hyperOs4ItemHeight = 36;
  static const double hyperOs4ItemHorizontalPadding = 12;
  static const double hyperOs4ItemMaxWidth = 200;

  static MiuixBreadcrumbBarColors colors(
    BuildContext context, {
    Color? color,
    Color? highlightColor,
    Color? disabledColor,
    Color? separatorColor,
    Color? backgroundColor,
    Color? highlightBackgroundColor,
    Color? disabledBackgroundColor,
  }) {
    final semantic = MiuixSemanticColors.of(context);
    final onBackground = semantic['onBackground'];
    final primary = semantic['primary'];
    return MiuixBreadcrumbBarColors(
      color: color ?? onBackground.withValues(alpha: .55),
      highlightColor: highlightColor ?? primary,
      disabledColor: disabledColor ?? semantic['disabledOnSecondaryVariant'],
      separatorColor: separatorColor ?? semantic['onSurfaceVariantActions'],
      backgroundColor: backgroundColor ?? onBackground.withValues(alpha: .10),
      highlightBackgroundColor:
          highlightBackgroundColor ?? primary.withValues(alpha: .20),
      disabledBackgroundColor:
          disabledBackgroundColor ?? semantic['disabledSecondaryVariant'],
    );
  }

  /// Resolves the quieter hierarchy used inside one HyperOS 4 bar material.
  static MiuixBreadcrumbBarColors hyperOs4Colors(BuildContext context) {
    final semantic = MiuixSemanticColors.of(context);
    return MiuixBreadcrumbBarColors(
      color: semantic['onSurfaceSecondary'],
      highlightColor: semantic['onPrimaryContainer'],
      disabledColor: semantic['disabledOnSurface'],
      separatorColor: semantic['onSurfaceVariantActions'],
      backgroundColor: Colors.transparent,
      highlightBackgroundColor: semantic['primaryContainer'],
      disabledBackgroundColor: Colors.transparent,
    );
  }
}

/// Horizontally scrolling MIUIX breadcrumb navigation.
class MiuixBreadcrumbBar extends StatefulWidget {
  const MiuixBreadcrumbBar({
    super.key,
    required this.items,
    required this.onItemClick,
    this.highlightIndex,
    this.enabled = true,
    this.colors,
    this.insideMargin = MiuixBreadcrumbBarDefaults.hyperOs4InsideMargin,
    this.itemMaxWidth = MiuixBreadcrumbBarDefaults.hyperOs4ItemMaxWidth,
    this.glass = true,
    this.backgroundColor,
    this.glassBlur,
    this.glassOpacity,
    this.showGlassSpecular = true,
    this.cornerRadius = double.nan,
    this.scrollController,
    this.interactionSource,
    this.indication = const MiuixIndication(),
  }) : _sourceStyle = false;

  /// Creates the former independently filled 32dp breadcrumb capsules.
  const MiuixBreadcrumbBar.source({
    super.key,
    required this.items,
    required this.onItemClick,
    this.highlightIndex,
    this.enabled = true,
    this.colors,
    this.insideMargin = MiuixBreadcrumbBarDefaults.insideMargin,
    this.itemMaxWidth = MiuixBreadcrumbBarDefaults.itemMaxWidth,
    this.scrollController,
    this.interactionSource,
    this.indication = const MiuixIndication(),
  }) : glass = false,
       backgroundColor = null,
       glassBlur = null,
       glassOpacity = null,
       showGlassSpecular = false,
       cornerRadius = 0,
       _sourceStyle = true;

  final List<MiuixBreadcrumbItem> items;
  final ValueChanged<int> onItemClick;
  final int? highlightIndex;
  final bool enabled;
  final MiuixBreadcrumbBarColors? colors;
  final EdgeInsetsGeometry insideMargin;
  final double itemMaxWidth;

  /// Material overrides for the complete standard breadcrumb bar.
  final bool glass;
  final Color? backgroundColor;
  final double? glassBlur;
  final double? glassOpacity;
  final bool showGlassSpecular;
  final double cornerRadius;
  final ScrollController? scrollController;

  /// Optional interaction observer shared by every breadcrumb destination.
  final MiuixInteractionSource? interactionSource;

  /// Nullable source indication; null keeps items clickable without overlay.
  final MiuixIndication? indication;

  final bool _sourceStyle;

  int get effectiveHighlightIndex => highlightIndex ?? items.length - 1;

  @override
  State<MiuixBreadcrumbBar> createState() => _MiuixBreadcrumbBarState();
}

class _MiuixBreadcrumbBarState extends State<MiuixBreadcrumbBar>
    with SingleTickerProviderStateMixin {
  static final SpringDescription _highlightScrollSpring =
      SpringDescription.withDampingRatio(mass: 1, stiffness: 1500, ratio: 1);

  late ScrollController _controller;
  late final AnimationController _scrollMotion;
  final Map<int, GlobalKey> _itemKeys = <int, GlobalKey>{};
  bool _positionedOnce = false;
  bool _scrollScheduled = false;
  bool _applyingMotion = false;
  bool _reduceMotion = false;
  int _motionGeneration = 0;

  @override
  void initState() {
    super.initState();
    _controller = widget.scrollController ?? ScrollController();
    _controller.addListener(_handleScrollChange);
    _scrollMotion = AnimationController.unbounded(vsync: this)
      ..addListener(_applyAnimatedScroll);
    _scheduleHighlightScroll(animate: false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion == _reduceMotion) {
      return;
    }
    _reduceMotion = reduceMotion;
    if (!_reduceMotion) {
      return;
    }

    // Automatic centering is decorative motion. Cancel an active spring and
    // recompute its logical endpoint after inherited-widget building ends.
    // Direct pointer, wheel, and touch scrolling remain owned by the viewport.
    _motionGeneration++;
    _scrollMotion.stop();
    _scheduleHighlightScroll(animate: false);
  }

  @override
  void didUpdateWidget(covariant MiuixBreadcrumbBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      _motionGeneration++;
      _scrollMotion.stop();
      _controller.removeListener(_handleScrollChange);
      if (oldWidget.scrollController == null) {
        _controller.dispose();
      }
      _controller = widget.scrollController ?? ScrollController();
      _controller.addListener(_handleScrollChange);
      _positionedOnce = false;
    }
    if (oldWidget.effectiveHighlightIndex != widget.effectiveHighlightIndex ||
        !listEquals(oldWidget.items, widget.items)) {
      _scheduleHighlightScroll(animate: _positionedOnce);
    }
  }

  @override
  void dispose() {
    _motionGeneration++;
    _scrollMotion
      ..removeListener(_applyAnimatedScroll)
      ..dispose();
    _controller.removeListener(_handleScrollChange);
    if (widget.scrollController == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _scheduleHighlightScroll({required bool animate}) {
    if (_scrollScheduled) return;
    _scrollScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollScheduled = false;
      if (!mounted) return;
      _scrollHighlightIntoCenter(animate: animate);
    });
  }

  void _scrollHighlightIntoCenter({required bool animate}) {
    final index = widget.effectiveHighlightIndex;
    if (index < 0 || index >= widget.items.length) return;
    if (!_controller.hasClients) {
      _scheduleHighlightScroll(animate: animate);
      return;
    }
    final itemContext = _itemKeys[index]?.currentContext;
    final itemBox = itemContext?.findRenderObject();
    if (itemBox is! RenderBox || !itemBox.hasSize) {
      return;
    }
    // Compose records positionInRoot(), then adds the current ScrollState.
    // Keep that root-space origin (including an enclosing horizontal inset):
    // subtracting the viewport origin looks more mathematically centered, but
    // visibly differs from the source example whenever the bar starts at x>0.
    final itemX = itemBox.localToGlobal(Offset.zero).dx + _controller.offset;
    final target =
        (itemX -
                (_controller.position.viewportDimension - itemBox.size.width) /
                    2)
            .clamp(0.0, math.max(0.0, _controller.position.maxScrollExtent))
            .toDouble();
    // Compose performs this calculation in physical pixels and passes
    // `targetScroll.toInt()` to ScrollState. Reproduce that truncation instead
    // of leaving a fractional logical offset that can blur every later item.
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final sourceTarget = (target * pixelRatio).truncateToDouble() / pixelRatio;
    if (animate && !_reduceMotion) {
      final carriedVelocity = _scrollMotion.isAnimating
          ? _scrollMotion.velocity
          : 0.0;
      final generation = ++_motionGeneration;
      _scrollMotion.value = _controller.offset;
      final simulation = SpringSimulation(
        _highlightScrollSpring,
        _scrollMotion.value,
        sourceTarget,
        carriedVelocity,
      );
      // Compose's Float spring uses a 0.01 physical-pixel visibility threshold.
      // Its derived velocity threshold is 62.5 times that distance threshold.
      simulation.tolerance = Tolerance(
        distance: .01 / pixelRatio,
        velocity: .625 / pixelRatio,
      );
      _scrollMotion.animateWith(simulation).whenCompleteOrCancel(() {
        if (!mounted || generation != _motionGeneration) return;
        _jumpTo(sourceTarget);
      });
    } else {
      _motionGeneration++;
      _scrollMotion.stop();
      _jumpTo(sourceTarget);
    }
    _positionedOnce = true;
  }

  /// Applies one source spring frame without fighting a detached scroll view.
  void _applyAnimatedScroll() {
    if (!_controller.hasClients) return;
    final position = _controller.position;
    final offset = _scrollMotion.value.clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if ((position.pixels - offset).abs() <= 1e-10) return;
    _jumpTo(offset);
  }

  /// Cancels programmatic centering when a drag or another scroll owner wins.
  void _handleScrollChange() {
    if (_applyingMotion || !_scrollMotion.isAnimating) return;
    _motionGeneration++;
    _scrollMotion.stop();
  }

  void _jumpTo(double offset) {
    if (!_controller.hasClients) return;
    _applyingMotion = true;
    try {
      _controller.jumpTo(offset);
    } finally {
      _applyingMotion = false;
    }
  }

  GlobalKey _keyFor(int index) {
    return _itemKeys.putIfAbsent(
      index,
      () => GlobalKey(debugLabel: 'miuix-breadcrumb-$index'),
    );
  }

  void _activate(int index) {
    if (!widget.enabled) return;
    if (!widget._sourceStyle && index != widget.effectiveHighlightIndex) {
      MiuixHaptics.perform(MiuixHapticType.segmentTick);
    }
    widget.onItemClick(index);
  }

  @override
  Widget build(BuildContext context) {
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final semantic = MiuixSemanticColors.of(context);
    final colors =
        widget.colors ??
        (widget._sourceStyle
            ? MiuixBreadcrumbBarDefaults.colors(context)
            : MiuixBreadcrumbBarDefaults.hyperOs4Colors(context));
    final highlight = widget.effectiveHighlightIndex;
    final itemHeight = widget._sourceStyle
        ? MiuixBreadcrumbBarDefaults.itemHeight
        : MiuixBreadcrumbBarDefaults.hyperOs4ItemHeight;
    final itemHorizontalPadding = widget._sourceStyle
        ? MiuixBreadcrumbBarDefaults.itemHorizontalPadding
        : MiuixBreadcrumbBarDefaults.hyperOs4ItemHorizontalPadding;
    final fallbackItemMaxWidth = widget._sourceStyle
        ? MiuixBreadcrumbBarDefaults.itemMaxWidth
        : MiuixBreadcrumbBarDefaults.hyperOs4ItemMaxWidth;
    final itemMaxWidth = widget.itemMaxWidth.isFinite
        ? math.max(0, widget.itemMaxWidth).toDouble()
        : fallbackItemMaxWidth;
    final children = <Widget>[];
    for (var index = 0; index < widget.items.length; index++) {
      if (index > 0) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: CustomPaint(
              key: ValueKey('miuix-breadcrumb-separator-$index'),
              size: const Size(10, 16),
              painter: _MiuixBreadcrumbArrowPainter(
                color: widget.enabled
                    ? colors.separatorColor
                    : colors.disabledColor,
                textDirection: Directionality.of(context),
              ),
            ),
          ),
        );
      }
      final highlighted = highlight >= 0 && index == highlight;
      final item = widget.items[index];
      children.add(
        KeyedSubtree(
          key: _keyFor(index),
          child: _MiuixBreadcrumbSegment(
            text: item.text ?? item.path,
            highlighted: highlighted,
            enabled: widget.enabled,
            colors: colors,
            itemMaxWidth: itemMaxWidth,
            itemHeight: itemHeight,
            itemHorizontalPadding: itemHorizontalPadding,
            animateSelection: !widget._sourceStyle,
            interactionSource: widget.interactionSource,
            indication: widget.indication,
            onTap: () => _activate(index),
          ),
        ),
      );
    }
    _scheduleHighlightScroll(animate: _positionedOnce);
    final direction = Directionality.of(context);
    final sourceMargin = widget.insideMargin.resolve(direction);
    final minimumTargetHeight = _miuixRoundLogicalDimension(
      48,
      MediaQuery.devicePixelRatioOf(context),
    );
    final verticalOverlap = math.max(
      0.0,
      (minimumTargetHeight - itemHeight) / 2,
    );
    final layoutMargin = EdgeInsets.fromLTRB(
      sourceMargin.left,
      math.max(0.0, sourceMargin.top - verticalOverlap),
      sourceMargin.right,
      math.max(0.0, sourceMargin.bottom - verticalOverlap),
    );
    final scroller = SingleChildScrollView(
      key: const ValueKey('miuix-breadcrumb-scroller'),
      controller: _controller,
      scrollDirection: Axis.horizontal,
      // Compose's 48dp minimum target occupies the default eight-dp visual
      // margin without increasing the BreadcrumbBar's measured 48dp height.
      padding: layoutMargin,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      ),
    );
    if (widget._sourceStyle) return scroller;
    return MiuixSurface(
      key: const ValueKey('miuix-breadcrumb-bar-surface'),
      radius: widget.cornerRadius.isFinite
          ? widget.cornerRadius.clamp(0.0, double.infinity).toDouble()
          : hyperOs4.inlineSurfaceCornerRadius,
      color: widget.backgroundColor ?? semantic['surfaceContainer'],
      glass: widget.glass,
      glassBlur: widget.glassBlur ?? hyperOs4.inlineSurfaceBlur,
      glassOpacity: widget.glassOpacity ?? hyperOs4.inlineSurfaceTintOpacity,
      showGlassSpecular: widget.showGlassSpecular,
      child: scroller,
    );
  }
}

class _MiuixBreadcrumbSegment extends StatelessWidget {
  const _MiuixBreadcrumbSegment({
    required this.text,
    required this.highlighted,
    required this.enabled,
    required this.colors,
    required this.itemMaxWidth,
    required this.itemHeight,
    required this.itemHorizontalPadding,
    required this.animateSelection,
    required this.interactionSource,
    required this.indication,
    required this.onTap,
  });

  final String text;
  final bool highlighted;
  final bool enabled;
  final MiuixBreadcrumbBarColors colors;
  final double itemMaxWidth;
  final double itemHeight;
  final double itemHorizontalPadding;
  final bool animateSelection;
  final MiuixInteractionSource? interactionSource;
  final MiuixIndication? indication;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final targetBackground = !enabled
        ? colors.disabledBackgroundColor
        : highlighted
        ? colors.highlightBackgroundColor
        : colors.backgroundColor;
    final targetForeground = !enabled
        ? colors.disabledColor
        : highlighted
        ? colors.highlightColor
        : colors.color;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final motion = MiuixTheme.of(context).hyperOs4.collectionRowMotion;
    final visual = TweenAnimationBuilder<double>(
      key: ValueKey<Object>((text, reduceMotion, animateSelection)),
      tween: Tween<double>(end: highlighted ? 1 : 0),
      duration: !animateSelection || reduceMotion ? Duration.zero : motion,
      curve: Curves.easeOutCubic,
      builder: (context, selectionProgress, _) {
        final background = !enabled
            ? targetBackground
            : Color.lerp(
                colors.backgroundColor,
                colors.highlightBackgroundColor,
                selectionProgress,
              )!;
        final foreground = !enabled
            ? targetForeground
            : Color.lerp(
                colors.color,
                colors.highlightColor,
                selectionProgress,
              )!;
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: itemMaxWidth),
          child: SizedBox(
            height: itemHeight,
            child: MiuixSurface(
              key: ValueKey<Object>(('miuix-breadcrumb-segment', text)),
              color: background,
              contentColor: foreground,
              shape: const StadiumBorder(),
              padding: EdgeInsets.symmetric(horizontal: itemHorizontalPadding),
              enabled: enabled,
              onTap: enabled ? onTap : null,
              showIndication: enabled && indication != null,
              indication: indication,
              interactionSource: interactionSource,
              child: Center(
                widthFactor: 1,
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 14,
                    // Android's Flutter shaper advances the same Roboto glyphs a
                    // fraction farther than Compose. This source-device
                    // compensation keeps short capsules on the same physical
                    // pixel widths without changing the documented 14sp size.
                    // The same compensation is retained for both weights. A
                    // weight-specific or per-label contraction makes Flutter's
                    // visible capsule one pixel narrower even though Compose's
                    // accessibility placeable can report a different rounded
                    // width for the medium face.
                    letterSpacing: -0.12,
                    fontWeight: FontWeight.lerp(
                      FontWeight.w400,
                      animateSelection ? FontWeight.w600 : FontWeight.w500,
                      selectionProgress,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    return _MiuixBreadcrumbTouchTarget(
      enabled: enabled,
      semanticLabel: text,
      textDirection: Directionality.of(context),
      minimumHeight: _miuixRoundLogicalDimension(
        48,
        MediaQuery.devicePixelRatioOf(context),
      ),
      onTap: onTap,
      child: ExcludeSemantics(child: visual),
    );
  }
}

/// Expands pointer and semantic height without changing the 32dp placeable.
///
/// Compose's clickable modifier applies Android's 48dp minimum interactive
/// component enforcement after measuring the capsule. The extra eight dp on
/// each side overlap BreadcrumbBar's vertical inside margin and therefore do
/// not increase either the row height or neighboring item spacing.
class _MiuixBreadcrumbTouchTarget extends SingleChildRenderObjectWidget {
  const _MiuixBreadcrumbTouchTarget({
    required this.enabled,
    required this.semanticLabel,
    required this.textDirection,
    required this.minimumHeight,
    required this.onTap,
    required super.child,
  });

  final bool enabled;
  final String semanticLabel;
  final TextDirection textDirection;
  final double minimumHeight;
  final VoidCallback onTap;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderMiuixBreadcrumbTouchTarget(
      enabled: enabled,
      semanticLabel: semanticLabel,
      textDirection: textDirection,
      minimumHeight: minimumHeight,
      onTap: onTap,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderMiuixBreadcrumbTouchTarget renderObject,
  ) {
    renderObject
      ..enabled = enabled
      ..semanticLabel = semanticLabel
      ..textDirection = textDirection
      ..minimumHeight = minimumHeight
      ..onTap = onTap;
  }
}

class _RenderMiuixBreadcrumbTouchTarget extends RenderProxyBox {
  _RenderMiuixBreadcrumbTouchTarget({
    required bool enabled,
    required String semanticLabel,
    required TextDirection textDirection,
    required double minimumHeight,
    required VoidCallback onTap,
  }) : _enabled = enabled,
       _semanticLabel = semanticLabel,
       _textDirection = textDirection,
       _minimumHeight = minimumHeight,
       _onTap = onTap {
    _outsideTapRecognizer = TapGestureRecognizer(debugOwner: this)
      ..onTap = onTap;
  }

  bool _enabled;
  String _semanticLabel;
  TextDirection _textDirection;
  double _minimumHeight;
  VoidCallback _onTap;
  late final TapGestureRecognizer _outsideTapRecognizer;

  bool get enabled => _enabled;
  set enabled(bool value) {
    if (_enabled == value) return;
    _enabled = value;
    markNeedsSemanticsUpdate();
  }

  String get semanticLabel => _semanticLabel;
  set semanticLabel(String value) {
    if (_semanticLabel == value) return;
    _semanticLabel = value;
    markNeedsSemanticsUpdate();
  }

  TextDirection get textDirection => _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsSemanticsUpdate();
  }

  double get minimumHeight => _minimumHeight;
  set minimumHeight(double value) {
    if (_minimumHeight == value) return;
    _minimumHeight = value;
    markNeedsSemanticsUpdate();
  }

  VoidCallback get onTap => _onTap;
  set onTap(VoidCallback value) {
    if (_onTap == value) return;
    _onTap = value;
    _outsideTapRecognizer.onTap = value;
    markNeedsSemanticsUpdate();
  }

  Rect get _interactiveBounds => Rect.fromCenter(
    center: size.center(Offset.zero),
    width: size.width,
    height: math.max(size.height, minimumHeight),
  );

  Offset get _childOffset =>
      Offset(0, child == null ? 0 : (size.height - child!.size.height) / 2);

  @override
  void performLayout() {
    final currentChild = child;
    if (currentChild == null) {
      size = constraints.smallest;
      return;
    }
    currentChild.layout(constraints.loosen(), parentUsesSize: true);
    size = constraints.constrain(
      Size(
        currentChild.size.width,
        math.max(currentChild.size.height, minimumHeight),
      ),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final currentChild = child;
    if (currentChild != null) {
      context.paintChild(currentChild, offset + _childOffset);
    }
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    transform.translateByDouble(_childOffset.dx, _childOffset.dy, 0, 1);
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!enabled || child == null || !_interactiveBounds.contains(position)) {
      return false;
    }
    final visualPosition = position - _childOffset;
    if ((Offset.zero & child!.size).contains(visualPosition)) {
      return child!.hitTest(result, position: visualPosition);
    }
    // The visual MiuixSurface deliberately remains 32dp tall, so only the
    // eight-dp bands above and below need this render object's recognizer.
    result.add(BoxHitTestEntry(this, position));
    return true;
  }

  @override
  void handleEvent(PointerEvent event, covariant BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _outsideTapRecognizer.addPointer(event);
    }
  }

  @override
  Rect get semanticBounds => _interactiveBounds;

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config
      ..isSemanticBoundary = true
      ..label = semanticLabel
      ..textDirection = textDirection;
    if (enabled) {
      config
        ..isButton = true
        ..isEnabled = true
        ..onTap = onTap;
    }
  }

  @override
  void dispose() {
    _outsideTapRecognizer.dispose();
    super.dispose();
  }
}

class _MiuixBreadcrumbArrowPainter extends CustomPainter {
  const _MiuixBreadcrumbArrowPainter({
    required this.color,
    required this.textDirection,
  });

  final Color color;
  final TextDirection textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    final sx = size.width / 10;
    final sy = size.height / 16;
    if (textDirection == TextDirection.rtl) {
      canvas.translate(size.width, 0);
      canvas.scale(-sx, sy);
    } else {
      canvas.scale(sx, sy);
    }
    final path = Path()
      ..moveTo(1.65, 1.469)
      ..cubicTo(1.929, 1.19, 2.381, 1.19, 2.66, 1.469)
      ..lineTo(8.721, 7.53)
      ..cubicTo(9, 7.809, 9, 8.261, 8.721, 8.54)
      ..lineTo(2.66, 14.601)
      ..cubicTo(2.381, 14.88, 1.929, 14.88, 1.65, 14.601)
      ..cubicTo(1.371, 14.322, 1.371, 13.87, 1.65, 13.591)
      ..lineTo(7.205, 8.035)
      ..lineTo(1.65, 2.479)
      ..cubicTo(1.371, 2.2, 1.371, 1.748, 1.65, 1.469)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MiuixBreadcrumbArrowPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.textDirection != textDirection;
  }
}
