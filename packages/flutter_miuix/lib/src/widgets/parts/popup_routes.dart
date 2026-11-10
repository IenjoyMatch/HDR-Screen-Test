part of '../miuix_widgets.dart';

/// Removes non-finite public popup translations before layout arithmetic.
Offset _miuixSafePopupOffset(Offset value) =>
    Offset(value.dx.isFinite ? value.dx : 0, value.dy.isFinite ? value.dy : 0);

/// Normalizes a public anchor rectangle into finite, non-negative geometry.
Rect? _miuixSafePopupAnchorRect(Rect? value) {
  if (value == null ||
      !value.left.isFinite ||
      !value.top.isFinite ||
      !value.right.isFinite ||
      !value.bottom.isFinite) {
    return null;
  }
  return Rect.fromLTRB(
    value.left,
    value.top,
    math.max(value.left, value.right),
    math.max(value.top, value.bottom),
  );
}

/// Preserves finite expansion/shrink insets and drops poisoned axes.
EdgeInsets _miuixSafePopupAnchorInsets(EdgeInsets value) => EdgeInsets.fromLTRB(
  value.left.isFinite ? value.left : 0,
  value.top.isFinite ? value.top : 0,
  value.right.isFinite ? value.right : 0,
  value.bottom.isFinite ? value.bottom : 0,
);

class _MiuixPopupLayoutDelegate extends SingleChildLayoutDelegate {
  const _MiuixPopupLayoutDelegate({
    required this.anchorRect,
    required this.alignment,
    required this.positioning,
    required this.textDirection,
    required this.safePadding,
    required this.devicePixelRatio,
    this.placementBounds,
    this.onLayoutPositionChanged,
  });

  final Rect anchorRect;
  final MiuixPopupAlignment alignment;
  final MiuixPopupPositioning positioning;
  final TextDirection textDirection;
  final EdgeInsets safePadding;
  final double devicePixelRatio;
  final ValueChanged<MiuixPopupLayoutPosition>? onLayoutPositionChanged;
  // Optional safe-window rectangle expressed in the popup host's local space.
  // Root window routes can derive it from their own size; nested Scaffold
  // hosts need the translated global bounds supplied by MiuixPopupHostView.
  final Rect? placementBounds;

  double get _verticalMargin =>
      positioning == MiuixPopupPositioning.dropdown ? 8 : 0;

  double get _horizontalMargin =>
      positioning == MiuixPopupPositioning.contextMenu ? 20 : 0;

  /// Converts Flutter logical geometry to the integer pixels used by the
  /// source PopupPositionProvider before doing its midpoint arithmetic.
  int _physicalPixels(double logicalPixels) =>
      (logicalPixels * devicePixelRatio).round();

  /// Returns the logical coordinate Flutter needs for final placement.
  ///
  /// Keeping this conversion at the boundary means every intermediate sum or
  /// division still follows Kotlin's integer behavior. It also prevents the
  /// overlay and separate-window paths from applying density rounding twice.
  /// The returned double remains suitable for subpixel Flutter composition.
  double _logicalPixels(int physicalPixels) =>
      physicalPixels / devicePixelRatio;

  bool get _alignEnd {
    final requestedEnd = switch (alignment) {
      MiuixPopupAlignment.end ||
      MiuixPopupAlignment.topEnd ||
      MiuixPopupAlignment.bottomEnd => true,
      _ => false,
    };
    return textDirection == TextDirection.rtl ? !requestedEnd : requestedEnd;
  }

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final placementHeight =
        placementBounds?.height ?? constraints.maxHeight - safePadding.vertical;
    final availableHeight = math.max(
      0.0,
      placementHeight - _verticalMargin * 2,
    );
    return BoxConstraints(maxHeight: availableHeight);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final bounds =
        placementBounds ??
        Rect.fromLTRB(
          safePadding.left,
          safePadding.top,
          size.width - safePadding.right,
          size.height - safePadding.bottom,
        );
    final safeLeft = bounds.left;
    final windowTop = bounds.top;
    final safeRight = bounds.right;
    final windowBottom = bounds.bottom;
    final safeTop = windowTop + _verticalMargin;
    final safeBottom = windowBottom - _verticalMargin;

    // Dropdowns retain Flutter's exact composited horizontal edge. Context
    // menus reproduce Compose's IntOffset math because their 20dp margin can
    // land on a half physical pixel at Android's fractional densities.
    final horizontalMarginPixels = _physicalPixels(_horizontalMargin);
    final requestedX = positioning == MiuixPopupPositioning.contextMenu
        ? _logicalPixels(
            _alignEnd
                ? _physicalPixels(anchorRect.right) -
                      _physicalPixels(childSize.width) -
                      horizontalMarginPixels
                : _physicalPixels(anchorRect.left) + horizontalMarginPixels,
          )
        : _alignEnd
        ? anchorRect.right - childSize.width
        : anchorRect.left;
    final maxX = math.max(
      safeLeft,
      positioning == MiuixPopupPositioning.contextMenu
          ? _logicalPixels(
              _physicalPixels(safeRight) -
                  _physicalPixels(childSize.width) -
                  horizontalMarginPixels,
            )
          : safeRight - childSize.width,
    );
    final x = requestedX.clamp(safeLeft, maxX).toDouble();

    final marginPixels = _physicalPixels(_verticalMargin);
    final anchorTopPixels = _physicalPixels(anchorRect.top);
    final anchorHeightPixels = _physicalPixels(anchorRect.height);
    final childHeightPixels = _physicalPixels(childSize.height);
    final below = _logicalPixels(
      _physicalPixels(anchorRect.bottom) + marginPixels,
    );
    final above = _logicalPixels(
      anchorTopPixels - childHeightPixels - marginPixels,
    );
    // Kotlin Int division truncates each half independently. Reproducing that
    // order avoids a one-physical-pixel drift for odd anchor/popup extents.
    final centered = _logicalPixels(
      anchorTopPixels + anchorHeightPixels ~/ 2 - childHeightPixels ~/ 2,
    );
    final availableBelow = windowBottom - anchorRect.bottom;
    final availableAbove = anchorRect.top - windowTop;
    final requestedY = positioning == MiuixPopupPositioning.contextMenu
        ? switch (alignment) {
            MiuixPopupAlignment.bottomStart || MiuixPopupAlignment.bottomEnd =>
              _logicalPixels(_physicalPixels(anchorRect.bottom)),
            MiuixPopupAlignment.topStart || MiuixPopupAlignment.topEnd =>
              _logicalPixels(anchorTopPixels - childHeightPixels),
            _ =>
              availableBelow > childSize.height
                  ? below
                  : availableAbove > childSize.height
                  ? above
                  : centered,
          }
        : availableBelow > childSize.height
        ? below
        : availableAbove > childSize.height
        ? above
        : centered;
    final maxY = math.max(safeTop, safeBottom - childSize.height);
    final y = requestedY.clamp(safeTop, maxY).toDouble();
    final popupCenterY = y + childSize.height / 2;
    final anchorCenterY = anchorRect.top + anchorRect.height / 2;
    final distanceLeft = (x - anchorRect.left).abs();
    final distanceRight = (x + childSize.width - anchorRect.right).abs();
    final resolvedPosition = MiuixPopupLayoutPosition(
      showBelow: popupCenterY > anchorCenterY,
      showAbove: popupCenterY < anchorCenterY,
      isRightAligned: distanceRight < distanceLeft,
    );
    if (onLayoutPositionChanged != null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        onLayoutPositionChanged?.call(resolvedPosition);
      });
    }
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(covariant _MiuixPopupLayoutDelegate oldDelegate) {
    return anchorRect != oldDelegate.anchorRect ||
        alignment != oldDelegate.alignment ||
        positioning != oldDelegate.positioning ||
        textDirection != oldDelegate.textDirection ||
        safePadding != oldDelegate.safePadding ||
        placementBounds != oldDelegate.placementBounds ||
        onLayoutPositionChanged != oldDelegate.onLayoutPositionChanged ||
        devicePixelRatio != oldDelegate.devicePixelRatio;
  }
}

/// Rebuilds only an anchored route's placement when its trigger moves.
//
// Root-window anchor lifecycle:
//
// - showGeneralDialog installs content in the root Navigator overlay.
// - Trigger rectangles arrive in application-global logical coordinates.
// - The root overlay can have an origin different from Offset.zero.
// - Every sample is therefore converted through the current overlay RenderBox.
// - The initial converted rectangle avoids a blank or centered opening frame.
// - The provider is consulted after later layout-producing application frames.
// - ScrollController jumps are visible on the next pumped frame.
// - Window resize and display-scale changes update the overlay transform first.
// - Keyboard inset changes can both move the trigger and shrink placement bounds.
// - Null means the trigger cannot currently supply trustworthy geometry.
// - The route then uses its linked fallback if one exists.
// - A subsequent non-null sample restores rectangle-based safe placement.
// - Only this small StatefulWidget rebuilds for anchor movement.
// - Popup content State and selection state remain mounted.
// - Route transition animation continues uninterrupted across position changes.
// - Layout-side changes update the animation transform origin independently.
// - Predictive Back progress is not reset by placement rebuilds.
// - The provider is never invoked synchronously from the trigger's build method.
// - Post-frame invocation avoids querying a partially laid-out RenderObject.
// - The callback chain never requests an application frame.
// - It therefore stops naturally when no scrolling or animation is happening.
// - mounted guards make pending callbacks harmless after route disposal.
// - Rect equality suppresses builds caused only by unrelated frames.
// - Local conversion uses both corners so scaled overlays remain correct.
// - A detached overlay temporarily returns the global rectangle as fallback.
// - Public callers do not need to know which Navigator hosts the popup.
// - Overlay-hosted menus use the equivalent controller-side conversion contract.
// - Tests exercise moving anchors for both presentation modes.
// - Focus restoration remains Navigator-owned after the route is dismissed.
// - Device verification must additionally cover rotation and split-screen moves.
class _MiuixLiveWindowAnchor extends StatefulWidget {
  const _MiuixLiveWindowAnchor({
    required this.initialRect,
    required this.provider,
    required this.builder,
  });

  final Rect? initialRect;
  final _MiuixPopupAnchorRectProvider provider;
  final Widget Function(BuildContext context, Rect? anchorRect) builder;

  @override
  State<_MiuixLiveWindowAnchor> createState() => _MiuixLiveWindowAnchorState();
}

class _MiuixLiveWindowAnchorState extends State<_MiuixLiveWindowAnchor> {
  // This cache is intentionally nullable. Treating null as the previous value
  // would leave an orphaned menu painted at a stale coordinate while its trigger
  // is reparented. The builder decides whether null means linked fallback or an
  // unanchored center surface, preserving the caller's original route contract.
  Rect? _anchorRect;
  bool _sampleScheduled = false;

  @override
  void initState() {
    super.initState();
    _anchorRect = widget.initialRect;
  }

  Rect? _resolveLocalRect() {
    final global = widget.provider();
    if (global == null) return null;
    final overlay = Navigator.maybeOf(
      context,
      rootNavigator: true,
    )?.overlay?.context.findRenderObject();
    if (overlay is! RenderBox || !overlay.attached) return global;
    return Rect.fromPoints(
      overlay.globalToLocal(global.topLeft),
      overlay.globalToLocal(global.bottomRight),
    );
  }

  void _scheduleSample() {
    if (_sampleScheduled) return;
    _sampleScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sampleScheduled = false;
      if (!mounted) return;
      final next = _resolveLocalRect();
      if (next != _anchorRect) setState(() => _anchorRect = next);
      // This does not request a frame. It waits for scrolling, resizing,
      // keyboard insets, or another application-produced frame.
      _scheduleSample();
    });
  }

  @override
  Widget build(BuildContext context) {
    _scheduleSample();
    return widget.builder(context, _anchorRect);
  }
}

Future<T?> _showMiuixWindowPopupSurface<T>({
  required BuildContext context,
  required Widget child,
  double maxWidth = 320,
  LayerLink? link,
  Rect? anchorRect,
  _MiuixPopupAnchorRectProvider? anchorRectProvider,
  MiuixPopupAlignment alignment = MiuixPopupAlignment.bottomStart,
  MiuixPopupPositioning positioning = MiuixPopupPositioning.dropdown,
  Offset popupAnchorOffset = Offset.zero,
  bool enableWindowDim = true,
  MiuixCascadingPopupController? cascadingController,
  bool Function()? canDismiss,
  VoidCallback? onDismissRequest,
  VoidCallback? onDismissFinished,
}) {
  if (!context.mounted) {
    return Future<T?>.value();
  }
  final routeTheme = Theme.of(context);
  final navigator = Navigator.maybeOf(context, rootNavigator: true);
  final overlayRenderObject = navigator?.overlay?.context.findRenderObject();
  final localAnchorRect =
      anchorRect != null &&
          overlayRenderObject is RenderBox &&
          overlayRenderObject.attached
      ? Rect.fromPoints(
          overlayRenderObject.globalToLocal(anchorRect.topLeft),
          overlayRenderObject.globalToLocal(anchorRect.bottomRight),
        )
      : anchorRect;
  var dismissRequested = false;
  final backProgress = _MiuixListPopupBackProgress();
  void requestDismiss() {
    if (!dismissRequested) {
      dismissRequested = true;
      onDismissRequest?.call();
    }
  }

  return showGeneralDialog<T>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    // ListPopup owns the independently timed 300/150ms dim layer. Leaving the
    // route barrier transparent prevents Flutter's route-wide fade from
    // stretching that layer across the 620ms fraction spring.
    barrierColor: Colors.transparent,
    transitionDuration: MiuixListPopupDefaults.fractionDuration,
    pageBuilder: (context, animation, secondaryAnimation) {
      final constrained = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      );
      var layoutPosition = _miuixPredictedPopupLayoutPosition(
        alignment,
        Directionality.of(context),
      );
      return StatefulBuilder(
        builder: (context, setRouteState) {
          final animatedSurface = _MiuixAnimatedListPopupSurface(
            animation: animation,
            position: layoutPosition,
            backProgress: backProgress,
            child: constrained,
          );
          Widget anchoredPopup(Rect? resolvedAnchorRect) {
            if (resolvedAnchorRect != null) {
              return CustomSingleChildLayout(
                delegate: _MiuixPopupLayoutDelegate(
                  anchorRect: resolvedAnchorRect,
                  alignment: alignment,
                  positioning: positioning,
                  textDirection: Directionality.of(context),
                  safePadding: MediaQuery.paddingOf(context),
                  devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
                  onLayoutPositionChanged: (position) {
                    if (position != layoutPosition) {
                      setRouteState(() => layoutPosition = position);
                    }
                  },
                ),
                child: animatedSurface,
              );
            }
            if (link == null) return Center(child: animatedSurface);
            return _MiuixAdaptivePopupFollower(
              link: link,
              targetAnchor: _miuixPopupAnchors(context, alignment).target,
              followerAnchor: _miuixPopupAnchors(context, alignment).follower,
              offset: _miuixPopupOffset(alignment) + popupAnchorOffset,
              child: animatedSurface,
            );
          }

          final popup = anchorRectProvider == null
              ? anchoredPopup(localAnchorRect)
              : _MiuixLiveWindowAnchor(
                  initialRect: localAnchorRect,
                  provider: anchorRectProvider,
                  builder: (context, anchor) => anchoredPopup(anchor),
                );
          final themedSurface = Theme(
            data: routeTheme,
            child: Material(
              type: MaterialType.transparency,
              child: AnimatedBuilder(
                animation: animation,
                child: popup,
                builder: (context, popup) => AnimatedBuilder(
                  animation: backProgress,
                  builder: (context, _) {
                    final progress = _miuixListPopupProgress(animation);
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            if (canDismiss?.call() == false) return;
                            requestDismiss();
                            Navigator.of(context, rootNavigator: true).pop();
                          },
                          child: enableWindowDim
                              ? Opacity(
                                  opacity: (progress.dim * backProgress.value)
                                      .clamp(0.0, 1.0),
                                  child: ColoredBox(
                                    color: MiuixSemanticColors.of(
                                      context,
                                    )['windowDimming'],
                                  ),
                                )
                              : const SizedBox.expand(),
                        ),
                        popup!,
                      ],
                    );
                  },
                ),
              ),
            ),
          );
          Widget guardedSurface(bool depthCanPop) => PopScope<Object?>(
            // A dismissal guard applies to every route exit, including the
            // Android button-Back path. Previously only the outside barrier
            // consulted it, so an otherwise locked popup could still vanish
            // through Navigator.popRoute.
            canPop:
                depthCanPop &&
                // A cascading canDismiss callback collapses depth one as a
                // side effect. Never evaluate it while merely rebuilding
                // PopScope; its depth controller is the authoritative guard.
                (cascadingController != null || (canDismiss?.call() ?? true)),
            onPopInvokedWithResult: (didPop, result) {
              // PopScope 拒绝会广播给所有监听器，保护层出现时不能顺带折叠菜单。
              if (MiuixBackGestureScope.blockedOf(context)) return;
              if (didPop) {
                requestDismiss();
              } else {
                // Cascading menus intentionally implement this callback with
                // a side effect: the first rejected Back collapses depth one.
                // Ordinary guards may use the call to provide rejection
                // feedback while keeping the route mounted.
                canDismiss?.call();
              }
            },
            child: themedSurface,
          );
          final routeBody = cascadingController == null
              ? guardedSurface(true)
              : ListenableBuilder(
                  listenable: cascadingController,
                  builder: (context, child) =>
                      guardedSurface(!cascadingController._secondaryExpanded),
                );
          return _MiuixListPopupPredictiveBackObserver(
            controller: backProgress,
            cascadingController: cascadingController,
            canStart: () =>
                !dismissRequested &&
                ModalRoute.of(context)?.isCurrent == true &&
                // Querying a cascading canDismiss callback would collapse its
                // submenu at gesture start. Depth ownership is handled by the
                // predictive observer instead, so only ordinary popups consult
                // the guard here.
                (cascadingController != null || (canDismiss?.call() ?? true)),
            onCommit: () {
              requestDismiss();
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: routeBody,
          );
        },
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) => child,
  ).whenComplete(() {
    requestDismiss();
    onDismissFinished?.call();
    backProgress.dispose();
  });
}

Future<T?> _showMiuixOverlayPopupSurface<T>({
  required BuildContext context,
  required Widget child,
  double maxWidth = 320,
  LayerLink? link,
  Rect? anchorRect,
  _MiuixPopupAnchorRectProvider? anchorRectProvider,
  MiuixPopupAlignment alignment = MiuixPopupAlignment.bottomStart,
  MiuixPopupPositioning positioning = MiuixPopupPositioning.dropdown,
  Offset popupAnchorOffset = Offset.zero,
  bool enableWindowDim = true,
  bool renderInRootScaffold = true,
  MiuixCascadingPopupController? cascadingController,
  VoidCallback? onDismissRequest,
  VoidCallback? onDismissFinished,
  bool Function()? canDismiss,
}) {
  final nearest = MiuixPopupHostScope.maybeOf(context);
  if (nearest == null) {
    throw FlutterError(
      'Overlay popup components require a MiuixScaffold or MiuixPopupHost.',
    );
  }
  final anchors = _miuixPopupAnchors(context, alignment);
  final controller = renderInRootScaffold ? nearest.root : nearest;
  final safeAnchorRect = _miuixSafePopupAnchorRect(anchorRect);
  Rect? safeAnchorProvider() =>
      _miuixSafePopupAnchorRect(anchorRectProvider?.call());
  return controller.show<T>(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    ),
    link: link,
    anchorRect: safeAnchorRect,
    anchorRectProvider: anchorRectProvider == null ? null : safeAnchorProvider,
    popupAlignment: alignment,
    popupPositioning: positioning,
    targetAnchor: anchors.target,
    followerAnchor: anchors.follower,
    offset:
        _miuixPopupOffset(alignment) + _miuixSafePopupOffset(popupAnchorOffset),
    dimBackground: enableWindowDim,
    dimColor: MiuixSemanticColors.of(context)['windowDimming'],
    onDismissRequest: onDismissRequest,
    onDismissFinished: onDismissFinished,
    canDismiss: canDismiss,
    cascadingController: cascadingController,
  );
}

Future<void> _showMiuixDropdownMenu<T>({
  required BuildContext context,
  required List<MiuixDropdownEntry<T>> entries,
  List<MiuixDropdownGroup<T>> groups = const [],
  required ValueChanged<T> onSelected,
  Widget Function(ValueChanged<T> onSelected)? popupBuilder,
  required MiuixPopupPresentation presentation,
  LayerLink? link,
  Rect? anchorRect,
  _MiuixPopupAnchorRectProvider? anchorRectProvider,
  MiuixPopupAlignment alignment = MiuixPopupAlignment.bottomStart,
  MiuixPopupPositioning positioning = MiuixPopupPositioning.dropdown,
  bool renderInRootScaffold = true,
  bool closeOnSelection = true,
  bool allowMultipleSelection = false,
  double popupMinWidth = 200,
  Offset popupAnchorOffset = Offset.zero,
  bool Function()? canDismiss,
  MiuixCascadingPopupController? cascadingController,
  VoidCallback? onDismissRequest,
  VoidCallback? onDismissFinished,
}) {
  if (entries.isEmpty && groups.every((group) => group.entries.isEmpty)) {
    return Future<void>.value();
  }
  final navigator = Navigator.maybeOf(context, rootNavigator: true);
  final host = MiuixPopupHostScope.maybeOf(context);
  void select(T value) {
    if (closeOnSelection) {
      if (presentation == MiuixPopupPresentation.overlay) {
        (renderInRootScaffold ? host?.root : host)?.dismissTop();
      } else {
        if (cascadingController?.collapseSecondary() == true) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (navigator?.mounted == true && navigator!.canPop()) {
              navigator.pop();
            }
          });
        } else if (navigator?.mounted == true && navigator!.canPop()) {
          navigator.pop();
        }
      }
    }
    onSelected(value);
  }

  final popup =
      popupBuilder?.call(select) ??
      MiuixListPopup<T>(
        entries: entries,
        groups: groups,
        minWidth: popupMinWidth,
        allowMultipleSelection: allowMultipleSelection,
        onSelected: select,
      );
  final safeAnchorOffset = _miuixSafePopupOffset(popupAnchorOffset);
  final adjustedAnchorRect = _miuixSafePopupAnchorRect(
    _miuixSafePopupAnchorRect(anchorRect)?.shift(safeAnchorOffset),
  );
  Rect? adjustedAnchorProvider() {
    final rect = _miuixSafePopupAnchorRect(anchorRectProvider?.call());
    return _miuixSafePopupAnchorRect(rect?.shift(safeAnchorOffset));
  }

  return presentation == MiuixPopupPresentation.overlay
      ? _showMiuixOverlayPopupSurface<void>(
          context: context,
          child: popup,
          link: link,
          anchorRect: adjustedAnchorRect,
          anchorRectProvider: anchorRectProvider == null
              ? null
              : adjustedAnchorProvider,
          alignment: alignment,
          positioning: positioning,
          popupAnchorOffset: adjustedAnchorRect == null
              ? safeAnchorOffset
              : Offset.zero,
          renderInRootScaffold: renderInRootScaffold,
          canDismiss: canDismiss,
          cascadingController: cascadingController,
          onDismissRequest: onDismissRequest,
          onDismissFinished: onDismissFinished,
        )
      : _showMiuixWindowPopupSurface<void>(
          context: context,
          child: popup,
          link: link,
          anchorRect: adjustedAnchorRect,
          anchorRectProvider: anchorRectProvider == null
              ? null
              : adjustedAnchorProvider,
          alignment: alignment,
          positioning: positioning,
          popupAnchorOffset: adjustedAnchorRect == null
              ? safeAnchorOffset
              : Offset.zero,
          cascadingController: cascadingController,
          canDismiss: canDismiss,
          onDismissRequest: onDismissRequest,
          onDismissFinished: onDismissFinished,
        );
}
