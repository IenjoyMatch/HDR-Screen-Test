part of '../miuix_widgets.dart';

/// Logical popup placement after the provider has resolved safe bounds.
@immutable
class MiuixPopupLayoutPosition {
  /// Creates a popup placement descriptor.
  const MiuixPopupLayoutPosition({
    required this.showBelow,
    required this.showAbove,
    required this.isRightAligned,
  });

  /// Popup center is below the anchor center.
  final bool showBelow;

  /// Popup center is above the anchor center.
  final bool showAbove;

  /// Popup's trailing edge is closer to the anchor's trailing edge.
  final bool isRightAligned;

  @override
  bool operator ==(Object other) =>
      other is MiuixPopupLayoutPosition &&
      showBelow == other.showBelow &&
      showAbove == other.showAbove &&
      isRightAligned == other.isRightAligned;

  @override
  int get hashCode => Object.hash(showBelow, showAbove, isRightAligned);
}

/// Transform origin expressed with Compose-compatible zero-to-one fractions.
@immutable
class MiuixTransformOrigin {
  /// Creates a transform origin.
  const MiuixTransformOrigin(this.pivotFractionX, this.pivotFractionY);

  /// Horizontal pivot fraction.
  final double pivotFractionX;

  /// Vertical pivot fraction.
  final double pivotFractionY;

  /// Converts the fractions into Flutter's minus-one-to-one alignment.
  Alignment get alignment =>
      Alignment(pivotFractionX * 2 - 1, pivotFractionY * 2 - 1);

  @override
  bool operator ==(Object other) =>
      other is MiuixTransformOrigin &&
      pivotFractionX == other.pivotFractionX &&
      pivotFractionY == other.pivotFractionY;

  @override
  int get hashCode => Object.hash(pivotFractionX, pivotFractionY);
}

/// Returns a finite, non-negative transform origin like upstream
/// `safeTransformOrigin`.
MiuixTransformOrigin safeMiuixTransformOrigin(double x, double y) {
  final safeX = !x.isFinite || x < 0 ? 0.0 : x;
  final safeY = !y.isFinite || y < 0 ? 0.0 : y;
  return MiuixTransformOrigin(safeX, safeY);
}

/// Complete source layout result consumed by `ListPopupContent`.
///
/// Flutter does not expose Compose's `LocalWindowInfo`, so callers provide the
/// already inset [windowBounds] and the full [containerSize]. Keeping both
/// values separate preserves the upstream distinction between safe placement
/// bounds and window-relative transform origins.
@immutable
class MiuixListPopupLayoutInfo {
  /// Creates an immutable list-popup layout result.
  const MiuixListPopupLayoutInfo({
    required this.windowBounds,
    required this.popupMargin,
    required this.effectiveTransformOrigin,
    required this.localTransformOrigin,
    required this.popupLayoutPosition,
  });

  /// Safe window rectangle after system-bar and cutout insets.
  final Rect windowBounds;

  /// Provider margins resolved for the current direction.
  final EdgeInsets popupMargin;

  /// Window-relative origin used by the popup host.
  final MiuixTransformOrigin effectiveTransformOrigin;

  /// Popup-local origin used by scale and reveal transforms.
  final MiuixTransformOrigin localTransformOrigin;

  /// Actual above, below, middle, and trailing-edge placement.
  final MiuixPopupLayoutPosition popupLayoutPosition;
}

/// Resolves the platform-neutral equivalent of
/// `rememberListPopupLayoutInfo`.
MiuixListPopupLayoutInfo resolveMiuixListPopupLayoutInfo({
  required MiuixPopupAlignment alignment,
  required MiuixPopupPositionProvider popupPositionProvider,
  required Rect parentBounds,
  required Size popupContentSize,
  required Size containerSize,
  required Rect windowBounds,
  required TextDirection textDirection,
}) {
  final margin = popupPositionProvider.margins;
  final requestedEnd = switch (alignment) {
    MiuixPopupAlignment.end ||
    MiuixPopupAlignment.topEnd ||
    MiuixPopupAlignment.bottomEnd => true,
    _ => false,
  };
  final rightAligned = textDirection == TextDirection.rtl
      ? !requestedEnd
      : requestedEnd;
  final predictedX = rightAligned
      ? parentBounds.right - margin.right
      : parentBounds.left + margin.left;
  final predictedAbove =
      alignment == MiuixPopupAlignment.bottomStart ||
      alignment == MiuixPopupAlignment.bottomEnd;
  final predictedY = predictedAbove
      ? parentBounds.top - margin.bottom
      : parentBounds.bottom + margin.bottom;
  final predictedOrigin = safeMiuixTransformOrigin(
    predictedX / containerSize.width,
    predictedY / containerSize.height,
  );

  if (popupContentSize.isEmpty) {
    final position = MiuixPopupLayoutPosition(
      showBelow: false,
      showAbove: false,
      isRightAligned: rightAligned,
    );
    return MiuixListPopupLayoutInfo(
      windowBounds: windowBounds,
      popupMargin: margin,
      effectiveTransformOrigin: predictedOrigin,
      localTransformOrigin: _miuixLocalPopupTransformOrigin(position),
      popupLayoutPosition: position,
    );
  }

  final offset = popupPositionProvider.calculatePosition(
    anchorBounds: parentBounds,
    windowBounds: windowBounds,
    textDirection: textDirection,
    popupContentSize: popupContentSize,
    popupMargin: margin,
    alignment: alignment,
  );
  final popupCenterY = offset.dy + popupContentSize.height / 2;
  final anchorCenterY = parentBounds.top + parentBounds.height / 2;
  final distanceLeft = (offset.dx - parentBounds.left).abs();
  final distanceRight =
      (offset.dx + popupContentSize.width - parentBounds.right).abs();
  final position = MiuixPopupLayoutPosition(
    showBelow: popupCenterY > anchorCenterY,
    showAbove: popupCenterY < anchorCenterY,
    isRightAligned: distanceRight < distanceLeft,
  );
  final middle = !position.showBelow && !position.showAbove;
  final cornerX = position.isRightAligned
      ? offset.dx + popupContentSize.width
      : offset.dx;
  final cornerY = middle
      ? offset.dy + popupContentSize.height / 2
      : position.showBelow
      ? offset.dy
      : offset.dy + popupContentSize.height;
  return MiuixListPopupLayoutInfo(
    windowBounds: windowBounds,
    popupMargin: margin,
    effectiveTransformOrigin: safeMiuixTransformOrigin(
      cornerX / containerSize.width,
      cornerY / containerSize.height,
    ),
    localTransformOrigin: _miuixLocalPopupTransformOrigin(position),
    popupLayoutPosition: position,
  );
}

/// Platform-neutral counterpart of MIUIX `PopupPositionProvider`.
abstract interface class MiuixPopupPositionProvider {
  /// Resolves the popup's top-left coordinate in window space.
  Offset calculatePosition({
    required Rect anchorBounds,
    required Rect windowBounds,
    required TextDirection textDirection,
    required Size popupContentSize,
    required EdgeInsets popupMargin,
    required MiuixPopupAlignment alignment,
  });

  /// Extra popup margins.
  EdgeInsets get margins;
}

/// Exact default measurements and motion used by list popups.
abstract final class MiuixListPopupDefaults {
  /// At most eight rows participate in intrinsic width.
  static const maxItemsForWidth = 8;

  /// At most eight rows participate in intrinsic minimum height.
  static const maxItemsForHeight = 8;

  /// Intrinsic popup width bounds.
  static const minWidth = 200.0;
  static const maxWidth = 288.0;

  /// Popup surface corner radius.
  ///
  /// The legacy source radius remains available for explicit compatibility;
  /// new popup surfaces use the calibrated HyperOS 4 continuous corner.
  static const legacyCornerRadius = 16.0;
  static const cornerRadius = 20.0;

  /// Fraction/reset spring tokens from ListPopup.kt.
  static const fractionDampingRatio = .82;
  static const fractionStiffness = 362.5;
  static const fractionVisibilityThreshold = .0001;

  /// Independent alpha and dim clocks.
  static const alphaEnterDuration = Duration(milliseconds: 200);
  static const alphaExitDuration = Duration(milliseconds: 150);
  static const dimEnterDuration = Duration(milliseconds: 300);
  static const dimExitDuration = Duration(milliseconds: 150);

  /// Window used to sample the physical spring through its visibility and
  /// velocity thresholds.
  static const fractionDuration = Duration(milliseconds: 620);

  /// Standard dropdown provider.
  static const MiuixPopupPositionProvider dropdownPositionProvider =
      _MiuixDefaultPopupPositionProvider(
        positioning: MiuixPopupPositioning.dropdown,
      );

  /// Context-menu provider.
  static const MiuixPopupPositionProvider contextMenuPositionProvider =
      _MiuixDefaultPopupPositionProvider(
        positioning: MiuixPopupPositioning.contextMenu,
      );
}

class _MiuixDefaultPopupPositionProvider implements MiuixPopupPositionProvider {
  const _MiuixDefaultPopupPositionProvider({required this.positioning});

  final MiuixPopupPositioning positioning;

  @override
  EdgeInsets get margins => positioning == MiuixPopupPositioning.dropdown
      ? const EdgeInsets.symmetric(vertical: 8)
      : const EdgeInsets.symmetric(horizontal: 20);

  bool _alignEnd(MiuixPopupAlignment alignment, TextDirection textDirection) {
    final requestedEnd = switch (alignment) {
      MiuixPopupAlignment.end ||
      MiuixPopupAlignment.topEnd ||
      MiuixPopupAlignment.bottomEnd => true,
      _ => false,
    };
    return textDirection == TextDirection.rtl ? !requestedEnd : requestedEnd;
  }

  @override
  Offset calculatePosition({
    required Rect anchorBounds,
    required Rect windowBounds,
    required TextDirection textDirection,
    required Size popupContentSize,
    required EdgeInsets popupMargin,
    required MiuixPopupAlignment alignment,
  }) {
    final endAligned = _alignEnd(alignment, textDirection);
    late final double requestedX;
    late final double requestedY;
    if (positioning == MiuixPopupPositioning.contextMenu) {
      requestedX = endAligned
          ? anchorBounds.right - popupContentSize.width - popupMargin.right
          : anchorBounds.left + popupMargin.left;
      requestedY = switch (alignment) {
        MiuixPopupAlignment.topStart ||
        MiuixPopupAlignment.topEnd => anchorBounds.bottom + popupMargin.top,
        MiuixPopupAlignment.bottomStart || MiuixPopupAlignment.bottomEnd =>
          anchorBounds.top - popupContentSize.height - popupMargin.bottom,
        _ => _adaptiveY(
          anchorBounds,
          windowBounds,
          popupContentSize,
          popupMargin,
        ),
      };
    } else {
      requestedX = endAligned
          ? anchorBounds.right - popupContentSize.width - popupMargin.right
          : anchorBounds.left + popupMargin.left;
      requestedY = _adaptiveY(
        anchorBounds,
        windowBounds,
        popupContentSize,
        popupMargin,
      );
    }
    final maxX = math.max(
      windowBounds.left,
      windowBounds.right - popupContentSize.width - popupMargin.right,
    );
    final minY = math.min(
      windowBounds.top + popupMargin.top,
      windowBounds.bottom - popupContentSize.height - popupMargin.bottom,
    );
    final maxY =
        windowBounds.bottom - popupContentSize.height - popupMargin.bottom;
    return Offset(
      requestedX.clamp(windowBounds.left, maxX).toDouble(),
      requestedY.clamp(minY, maxY).toDouble(),
    );
  }

  double _adaptiveY(Rect anchor, Rect window, Size popup, EdgeInsets margin) {
    if (window.bottom - anchor.bottom > popup.height) {
      return anchor.bottom + margin.bottom;
    }
    if (anchor.top - window.top > popup.height) {
      return anchor.top - popup.height - margin.top;
    }
    return anchor.top + anchor.height / 2 - popup.height / 2;
  }
}

/// Source `ListPopupColumn`: width is the widest of only the first eight
/// children, clamped to 200–288dp, while every child is laid out in the column.
class MiuixListPopupColumn extends StatelessWidget {
  /// Creates a source list-popup column.
  const MiuixListPopupColumn({
    super.key,
    required this.children,
    this.controller,
  });

  /// Popup rows.
  final List<Widget> children;

  /// Optional vertical scroll controller.
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return _MiuixPopupIntrinsicViewport(
      child: SingleChildScrollView(
        controller: controller,
        // PopupHost owns an independent LazyColumn scroll state in Compose.
        // A vertical Flutter ScrollView otherwise inherits the route's
        // PrimaryScrollController when no controller is supplied. Keep the
        // optional caller controller, but never borrow the page position.
        primary: false,
        physics: const ClampingScrollPhysics(),
        child: _MiuixListPopupColumnLayout(children: children),
      ),
    );
  }
}

/// Applies Compose's `height(IntrinsicSize.Min)` before vertical scrolling.
///
/// The scroll viewport asks the column for its minimum intrinsic height. That
/// column deliberately sums only the first eight children, while its ordinary
/// layout still contains every row. The result is a scrollable eight-item
/// viewport instead of a menu that expands through the navigation bar.
class _MiuixPopupIntrinsicViewport extends SingleChildRenderObjectWidget {
  const _MiuixPopupIntrinsicViewport({required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderMiuixPopupIntrinsicViewport();
}

class _RenderMiuixPopupIntrinsicViewport extends RenderProxyBox {
  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      size = constraints.smallest;
      return;
    }

    // Resolve width first because wrapping changes the first-eight-row height.
    // This reproduces ListPopupColumn's source order: widest of the first eight,
    // clamped to 200..288dp, then minimum intrinsic height at that exact width.
    final intrinsicWidth = constraints.constrainWidth(
      child.getMaxIntrinsicWidth(constraints.maxHeight),
    );
    final intrinsicHeight = constraints.constrainHeight(
      child.getMinIntrinsicHeight(intrinsicWidth),
    );
    child.layout(
      BoxConstraints(
        minWidth: intrinsicWidth,
        maxWidth: intrinsicWidth,
        maxHeight: intrinsicHeight,
      ),
      parentUsesSize: true,
    );
    size = constraints.constrain(child.size);
  }
}

class _MiuixListPopupColumnLayout extends MultiChildRenderObjectWidget {
  const _MiuixListPopupColumnLayout({required super.children});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderMiuixListPopupColumn();
}

class _MiuixPopupColumnParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderMiuixListPopupColumn extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _MiuixPopupColumnParentData>,
        RenderBoxContainerDefaultsMixin<
          RenderBox,
          _MiuixPopupColumnParentData
        > {
  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _MiuixPopupColumnParentData) {
      child.parentData = _MiuixPopupColumnParentData();
    }
  }

  Iterable<RenderBox> get _firstWidthChildren sync* {
    var child = firstChild;
    var count = 0;
    while (child != null && count < MiuixListPopupDefaults.maxItemsForWidth) {
      yield child;
      child = (child.parentData! as _MiuixPopupColumnParentData).nextSibling;
      count++;
    }
  }

  double _intrinsicWidth(double height) {
    var width = 0.0;
    for (final child in _firstWidthChildren) {
      width = math.max(width, child.getMaxIntrinsicWidth(height));
    }
    return width.clamp(
      MiuixListPopupDefaults.minWidth,
      MiuixListPopupDefaults.maxWidth,
    );
  }

  @override
  double computeMinIntrinsicWidth(double height) => _intrinsicWidth(height);

  @override
  double computeMaxIntrinsicWidth(double height) => _intrinsicWidth(height);

  @override
  double computeMinIntrinsicHeight(double width) {
    var height = 0.0;
    var child = firstChild;
    var count = 0;
    while (child != null && count < MiuixListPopupDefaults.maxItemsForHeight) {
      // Source popup rows publish their measured text-driven minimum height.
      // Asking for that intrinsic value preserves SpinnerItemImpl's fractional
      // title/summary line boxes; a dry layout rounds each nested text subtree
      // separately and adds 1.2dp per rich row at the reference density.
      height += child.getMinIntrinsicHeight(width);
      child = (child.parentData! as _MiuixPopupColumnParentData).nextSibling;
      count++;
    }
    return height;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    var height = 0.0;
    var child = firstChild;
    while (child != null) {
      height += child.getMaxIntrinsicHeight(width);
      child = (child.parentData! as _MiuixPopupColumnParentData).nextSibling;
    }
    return height;
  }

  @override
  void performLayout() {
    final width = constraints.constrainWidth(
      _intrinsicWidth(constraints.maxHeight),
    );
    final childConstraints = BoxConstraints.tightFor(width: width);
    var y = 0.0;
    var child = firstChild;
    while (child != null) {
      child.layout(childConstraints, parentUsesSize: true);
      final parentData = child.parentData! as _MiuixPopupColumnParentData;
      parentData.offset = Offset(0, y);
      y += child.size.height;
      child = parentData.nextSibling;
    }
    size = constraints.constrain(Size(width, y));
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}
