part of '../miuix_widgets.dart';

/// Source constants and color resolution for the current MIUIX badge.
abstract final class MiuixBadgeDefaults {
  /// Diameter of an icon-only status dot.
  static const double size = 6;

  /// Minimum diameter of a badge containing content.
  static const double largeSize = 16;

  /// Horizontal padding added only when a badge has content.
  static const double contentHorizontalPadding = 4;

  /// Source error color used by the badge container.
  static Color containerColor(BuildContext context) {
    return MiuixSemanticColors.of(context)['error'];
  }

  /// Source on-error color inherited by badge content.
  static Color contentColor(BuildContext context) {
    return MiuixSemanticColors.of(context)['onError'];
  }
}

/// Compose's percent-based CircleShape is an oval for square bounds and a
/// stadium for wider bounds. Flutter's BoxShape.circle always inscribes a
/// circle, while StadiumBorder rasterizes a square slightly differently from
/// drawOval at fractional density, so the source behavior needs both paths.
class _MiuixBadgeShape extends ShapeBorder {
  const _MiuixBadgeShape();

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  ShapeBorder scale(double t) => this;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect, textDirection: textDirection);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    if ((rect.width - rect.height).abs() < .01) {
      return Path()..addOval(rect);
    }
    final radius = Radius.circular(math.min(rect.width, rect.height) / 2);
    return Path()..addRRect(RRect.fromRectAndRadius(rect, radius));
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}
}

/// MIUIX status badge.
///
/// The unnamed constructor preserves the package's older combined
/// anchor-and-badge convenience. Use [MiuixBadge.source] as the direct
/// counterpart of the current upstream `Badge` content surface.
class MiuixBadge extends StatelessWidget {
  /// Creates the historical combined anchor-and-badge convenience.
  const MiuixBadge({
    super.key,
    required Widget child,
    this.label,
    this.visible = true,
  }) : _anchor = child,
       content = null,
       containerColor = null,
       contentColor = null,
       _source = false;

  /// Creates the current source `Badge` surface.
  const MiuixBadge.source({
    super.key,
    this.content,
    this.containerColor,
    this.contentColor,
  }) : _anchor = null,
       label = null,
       visible = true,
       _source = true;

  /// Optional content rendered in a source badge.
  final Widget? content;

  /// Optional source container-color override.
  final Color? containerColor;

  /// Optional source content-color override.
  final Color? contentColor;

  /// Compatibility label used by the combined convenience constructor.
  final String? label;

  /// Whether the compatibility badge is visible.
  final bool visible;

  final Widget? _anchor;
  final bool _source;

  /// Compatibility anchor exposed by the historical constructor.
  ///
  /// Source badges return their content so structural tooling can continue to
  /// inspect the widget without depending on its private construction mode.
  Widget get child => _anchor ?? content ?? const SizedBox.shrink();

  /// Whether this source badge contains a text/content slot.
  bool get hasSourceContent => content != null;

  @override
  Widget build(BuildContext context) {
    if (_source) {
      return _MiuixBadgeSurface(
        content: content,
        containerColor:
            containerColor ?? MiuixBadgeDefaults.containerColor(context),
        contentColor: contentColor ?? MiuixBadgeDefaults.contentColor(context),
      );
    }
    if (!visible) {
      return _anchor!;
    }
    final sourceBadge = _MiuixBadgeSurface(
      content: label == null ? null : Text(label!),
      containerColor:
          containerColor ?? MiuixBadgeDefaults.containerColor(context),
      contentColor: contentColor ?? MiuixBadgeDefaults.contentColor(context),
    );
    return MiuixBadgedBox.source(badge: sourceBadge, child: _anchor!);
  }
}

class _MiuixBadgeSurface extends StatelessWidget {
  const _MiuixBadgeSurface({
    required this.content,
    required this.containerColor,
    required this.contentColor,
  });

  final Widget? content;
  final Color containerColor;
  final Color contentColor;

  @override
  Widget build(BuildContext context) {
    final hasContent = content != null;
    final authoredSize = hasContent
        ? MiuixBadgeDefaults.largeSize
        : MiuixBadgeDefaults.size;
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final size = _miuixRoundLogicalDimension(authoredSize, pixelRatio);
    final horizontalPadding = _miuixRoundLogicalDimension(
      MiuixBadgeDefaults.contentHorizontalPadding,
      pixelRatio,
    );
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: size, minHeight: size),
      child: DecoratedBox(
        // Compose CircleShape is a 50-percent RoundedCornerShape: a square is
        // circular, while long content expands into a stadium. BoxShape.circle
        // instead inscribes a circle and leaves long labels outside the fill.
        decoration: ShapeDecoration(
          color: containerColor,
          shape: const _MiuixBadgeShape(),
        ),
        child: hasContent
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Center(
                  widthFactor: 1,
                  heightFactor: 1,
                  child: DefaultTextStyle.merge(
                    style: TextStyle(
                      color: contentColor,
                      fontSize: 11,
                      height: 16 / 11,
                      // Android SkParagraph advances the same short Roboto
                      // label about one pixel farther than Compose at 420dpi.
                      // The uniform tracking correction preserves one-digit
                      // 16dp badges and restores the source 70px `99+` pill.
                      letterSpacing: -0.12,
                      fontWeight: FontWeight.normal,
                    ),
                    child: IconTheme(
                      data: IconThemeData(color: contentColor, size: 11),
                      child: content!,
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

/// Positions a badge over an anchor without allowing it to affect layout.
class MiuixBadgedBox extends StatelessWidget {
  /// Creates the historical alignment/offset compatibility layout.
  const MiuixBadgedBox({
    super.key,
    required this.child,
    required this.badge,
    this.alignment = Alignment.topRight,
    this.offset = Offset.zero,
    this.unanchoredAlignment = Alignment.center,
  }) : _source = false;

  /// Creates the current source `BadgedBox` layout.
  const MiuixBadgedBox.source({
    super.key,
    required this.badge,
    required this.child,
  }) : alignment = Alignment.topRight,
       offset = Offset.zero,
       unanchoredAlignment = Alignment.center,
       _source = true;

  /// Anchor whose measured size owns the complete layout.
  final Widget child;

  /// Badge painted over the logical top-end corner.
  final Widget badge;

  /// Compatibility alignment.
  final AlignmentGeometry alignment;

  /// Compatibility translation.
  final Offset offset;

  /// Compatibility alignment retained for API stability.
  final Alignment unanchoredAlignment;

  final bool _source;

  @override
  Widget build(BuildContext context) {
    if (_source) {
      return _MiuixBadgedBoxLayout(
        textDirection: Directionality.of(context),
        pixelRatio: MediaQuery.devicePixelRatioOf(context),
        badge: badge,
        anchor: child,
      );
    }
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned.fill(
          child: Align(
            alignment: alignment,
            child: Transform.translate(offset: offset, child: badge),
          ),
        ),
      ],
    );
  }
}

/// Adds a source badge to an already size-constrained navigation icon.
///
/// Keeping the badge outside the anchor's icon sizing box is important: a
/// FittedBox around the complete pair would shrink the badge along with the
/// glyph, while upstream `NavigationItemIcon` lets it paint past the anchor.
Widget _miuixNavigationIconWithBadge({
  required Widget icon,
  required Widget? badge,
  Rect? sourceBounds,
}) => badge == null
    ? icon
    : _MiuixBadgedBoxLayout(
        textDirection: null,
        pixelRatio: null,
        sourceBounds: sourceBounds,
        badge: badge,
        anchor: icon,
      );

class _MiuixBadgedBoxLayout extends MultiChildRenderObjectWidget {
  _MiuixBadgedBoxLayout({
    this.textDirection,
    this.pixelRatio,
    this.sourceBounds,
    required Widget badge,
    required Widget anchor,
  }) : super(
         children: [
           _MiuixBadgedBoxSlot(
             slot: _MiuixBadgedBoxSlotType.anchor,
             child: anchor,
           ),
           _MiuixBadgedBoxSlot(
             slot: _MiuixBadgedBoxSlotType.badge,
             child: badge,
           ),
         ],
       );

  /// Optional owner-provided values are used by navigation adapters that are
  /// built outside the public MiuixBadgedBox widget.
  final TextDirection? textDirection;
  final double? pixelRatio;

  /// Source `badgeBounds()` rectangle in the anchor's local coordinates.
  ///
  /// Only the top and logical-end edges participate in placement. The start
  /// and bottom edges remain paint-overflow capable, exactly like Badge.kt.
  final Rect? sourceBounds;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderMiuixBadgedBox(
      textDirection: textDirection ?? Directionality.of(context),
      pixelRatio: pixelRatio ?? MediaQuery.devicePixelRatioOf(context),
      sourceBounds: sourceBounds,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderMiuixBadgedBox renderObject,
  ) {
    renderObject.textDirection = textDirection ?? Directionality.of(context);
    renderObject.pixelRatio =
        pixelRatio ?? MediaQuery.devicePixelRatioOf(context);
    renderObject.sourceBounds = sourceBounds;
  }
}

enum _MiuixBadgedBoxSlotType { anchor, badge }

class _MiuixBadgedBoxParentData extends ContainerBoxParentData<RenderBox> {
  _MiuixBadgedBoxSlotType? slot;
}

class _MiuixBadgedBoxSlot extends ParentDataWidget<_MiuixBadgedBoxParentData> {
  const _MiuixBadgedBoxSlot({required this.slot, required super.child});

  final _MiuixBadgedBoxSlotType slot;

  @override
  void applyParentData(RenderObject renderObject) {
    final data = renderObject.parentData! as _MiuixBadgedBoxParentData;
    if (data.slot != slot) {
      data.slot = slot;
      final parent = renderObject.parent;
      if (parent is RenderObject) {
        parent.markNeedsLayout();
      }
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => _MiuixBadgedBoxLayout;
}

class _RenderMiuixBadgedBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _MiuixBadgedBoxParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _MiuixBadgedBoxParentData> {
  _RenderMiuixBadgedBox({
    required TextDirection textDirection,
    required double pixelRatio,
    Rect? sourceBounds,
  }) : _textDirection = textDirection,
       _pixelRatio = pixelRatio,
       _sourceBounds = sourceBounds;

  TextDirection _textDirection;
  double _pixelRatio;
  Rect? _sourceBounds;

  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsLayout();
  }

  set pixelRatio(double value) {
    if (_pixelRatio == value) return;
    _pixelRatio = value;
    markNeedsLayout();
  }

  set sourceBounds(Rect? value) {
    if (_sourceBounds == value) return;
    _sourceBounds = value;
    markNeedsLayout();
  }

  RenderBox? _childFor(_MiuixBadgedBoxSlotType slot) {
    RenderBox? child = firstChild;
    while (child != null) {
      final data = child.parentData! as _MiuixBadgedBoxParentData;
      if (data.slot == slot) return child;
      child = data.nextSibling;
    }
    return null;
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _MiuixBadgedBoxParentData) {
      child.parentData = _MiuixBadgedBoxParentData();
    }
  }

  @override
  void performLayout() {
    final anchor = _childFor(_MiuixBadgedBoxSlotType.anchor)!;
    final badge = _childFor(_MiuixBadgedBoxSlotType.badge)!;
    // Badge.kt copies the incoming constraints and clears only minHeight. The
    // minimum width is deliberately retained: a directly constrained
    // BadgedBox therefore constrains its badge too. Navigation owners that
    // need a natural-width badge must measure the complete icon pair loosely,
    // as the current expandable rail Layout does upstream.
    badge.layout(constraints.copyWith(minHeight: 0), parentUsesSize: true);
    anchor.layout(constraints, parentUsesSize: true);
    size = anchor.size;

    final anchorData = anchor.parentData! as _MiuixBadgedBoxParentData;
    anchorData.offset = Offset.zero;

    final dotSize = _miuixRoundLogicalDimension(
      MiuixBadgeDefaults.size,
      _pixelRatio,
    );
    final hasContent = badge.size.width > dotSize;
    final horizontalOffset = _miuixRoundLogicalDimension(
      hasContent ? 12 : 6,
      _pixelRatio,
    );
    final verticalOffset = _miuixRoundLogicalDimension(
      hasContent ? 14 : 6,
      _pixelRatio,
    );
    final logicalX = anchor.size.width - horizontalOffset;
    var physicalX = _textDirection == TextDirection.ltr
        ? logicalX
        : anchor.size.width - logicalX - badge.size.width;
    var badgeY = -badge.size.height + verticalOffset;

    // NavigationBar.kt and NavigationRail.kt install badgeBounds() on the
    // complete destination. Badge.kt reads those rulers in BadgedBox-local
    // coordinates and moves only the badge toward the inside. It does not
    // clip start/bottom overflow or change the anchor-owned layout size.
    if (_sourceBounds case final bounds?) {
      badgeY = math.max(badgeY, bounds.top);
      if (_textDirection == TextDirection.ltr) {
        physicalX = math.min(physicalX, bounds.right - badge.size.width);
      } else {
        physicalX = math.max(physicalX, bounds.left);
      }
    }
    final badgeData = badge.parentData! as _MiuixBadgedBoxParentData;
    badgeData.offset = Offset(physicalX, badgeY);
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    final anchor = _childFor(_MiuixBadgedBoxSlotType.anchor);
    return anchor?.getDistanceToActualBaseline(baseline);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}
