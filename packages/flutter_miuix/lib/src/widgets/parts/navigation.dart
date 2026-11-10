part of '../miuix_widgets.dart';

/// Floating-action-button positions supported by [MiuixScaffold].
enum MiuixFabPosition { start, center, end, endOverlay }

/// Floating-toolbar positions supported by [MiuixScaffold].
enum MiuixToolbarPosition {
  topStart,
  centerStart,
  bottomStart,
  topEnd,
  centerEnd,
  bottomEnd,
  topCenter,
  bottomCenter,
}

// Dialog hosts use the source component's compact slide-up transition while
// anchored menus and ordinary popup content retain their scale transition.
enum _MiuixHostedPopupTransition { scale, fade, dialog, bottomSheet }

// MiuixPopupUtils allocates one process-local nextZIndex for dialog and popup
// states across every Scaffold. Source wrappers reserve from this sequence when
// their state identity is composed; direct route helpers reserve when opened.
var _miuixNextHostedPopupZIndex = 1;

/// Reads an anchor in application-global logical coordinates.
typedef _MiuixPopupAnchorRectProvider = Rect? Function();

// Live popup-anchor contract:
//
// - Providers return logical pixels, never physical device pixels.
// - The returned rectangle is expressed in application-global coordinates.
// - A provider may return null while its RenderObject is detached.
// - Callers keep the opening rectangle as the first-frame fallback.
// - Each popup host converts global geometry into its own local coordinates.
// - Conversion happens at sampling time, not only when the popup opens.
// - This matters because nested Scaffolds can have non-zero host origins.
// - It also matters when a desktop window moves between scaled displays.
// - Insets modify the logical trigger rectangle before host conversion.
// - Custom offsets remain placement offsets and are not baked into host origin.
// - LayerLink remains the fallback when a rectangle cannot be resolved.
// - A live rectangle takes precedence because it supports source-style flipping.
// - Sampling is post-frame so layout and paint geometry are both current.
// - Sampling callbacks never call scheduleFrame by themselves.
// - Therefore a stationary popup has no autonomous polling animation.
// - Scroll, resize, keyboard, route, and parent animation frames wake sampling.
// - Equality checks suppress rebuilds when the rectangle did not change.
// - A changed rectangle rebuilds only the popup placement subtree.
// - The trigger subtree is never marked dirty by anchor tracking.
// - Tooltip anchors dismiss when detached because an orphan has no owner.
// - Menu routes may temporarily fall back to LayerLink during reparenting.
// - Safe-area clamping is evaluated after the current anchor is sampled.
// - Text direction is evaluated in the popup host at layout time.
// - Alignment semantics therefore survive a live LTR/RTL dependency change.
// - Predictive Back progress is independent from anchor movement.
// - Closing animation continues from the latest resolved position.
// - Providers must be cheap and side-effect free because they can run per frame.
// - Providers must not retain a BuildContext after the trigger State is disposed.
// - State-owned closures satisfy that rule by checking their current GlobalKey.
// - Public APIs expose an inline callback type to avoid leaking this typedef.
// - These invariants apply equally to Overlay, root Navigator, and popup hosts.
// - Geometry tests cover both hosted and window presentation paths.
// - Runtime visual tests must still verify IME, system bars, and display cutouts.

// Compose measures every PopupPositionProvider against the complete Android
// window, even when PopupHost later clips the result inside a nested Scaffold.
// Keep the host origin in the same separately truncated physical-pixel space
// used by LayoutCoordinates.positionInWindow().
Offset? _miuixPopupHostOriginInWindow(BuildContext? hostContext) {
  final renderObject = hostContext?.findRenderObject();
  if (hostContext == null ||
      renderObject is! RenderBox ||
      !renderObject.hasSize) {
    return null;
  }
  final density = View.of(hostContext).devicePixelRatio;
  final position = renderObject.localToGlobal(Offset.zero);
  return Offset(
    (position.dx * density).truncate() / density,
    (position.dy * density).truncate() / density,
  );
}

class _MiuixHostedPopup<T> {
  _MiuixHostedPopup({
    required this.id,
    required this.zIndex,
    required this.child,
    required this.completer,
    this.link,
    this.anchorRect,
    this.anchorRectProvider,
    this.popupAlignment = MiuixPopupAlignment.bottomStart,
    this.popupPositioning = MiuixPopupPositioning.dropdown,
    this.targetAnchor = Alignment.bottomLeft,
    this.followerAnchor = Alignment.topLeft,
    this.offset = Offset.zero,
    this.unanchoredAlignment = Alignment.center,
    this.dimBackground = true,
    this.dimColor,
    this.dimAlpha,
    this.dialogBackProgress,
    this.bottomSheetBackProgress,
    this.listPopupBackProgress,
    this.cascadingController,
    this.enterTransition,
    this.exitTransition,
    this.dimEnterTransition,
    this.dimExitTransition,
    this.transition = _MiuixHostedPopupTransition.scale,
    this.barrierDismissible = true,
    this.enableBackHandler = true,
    this.enableAutoLargeScreen = true,
    this.dialogLargeScreen,
    this.canDismiss,
    this.onDismissRequest,
    this.onDismissFinished,
  });

  final int id;
  final int zIndex;
  Widget child;
  final Completer<T?> completer;
  final LayerLink? link;
  Rect? anchorRect;
  final _MiuixPopupAnchorRectProvider? anchorRectProvider;
  final MiuixPopupAlignment popupAlignment;
  final MiuixPopupPositioning popupPositioning;
  final Alignment targetAnchor;
  final Alignment followerAnchor;
  final Offset offset;
  final Alignment unanchoredAlignment;
  bool dimBackground;
  Color? dimColor;
  ValueListenable<double>? dimAlpha;
  final _MiuixDialogBackProgress? dialogBackProgress;
  final _MiuixBottomSheetBackProgress? bottomSheetBackProgress;
  final _MiuixListPopupBackProgress? listPopupBackProgress;
  final MiuixCascadingPopupController? cascadingController;
  MiuixVisibilityTransition? enterTransition;
  MiuixVisibilityTransition? exitTransition;
  MiuixVisibilityTransition? dimEnterTransition;
  MiuixVisibilityTransition? dimExitTransition;
  final _MiuixHostedPopupTransition transition;
  final bool barrierDismissible;
  bool enableBackHandler;
  bool enableAutoLargeScreen;
  final bool? dialogLargeScreen;
  final bool Function()? canDismiss;
  final VoidCallback? onDismissRequest;
  final VoidCallback? onDismissFinished;
  bool visible = true;
}

/// Controller for popups rendered inside one isolated [MiuixScaffold].
class MiuixPopupHostController extends ChangeNotifier {
  MiuixPopupHostController({this.parent});

  /// Parent host for nested-scaffold root rendering.
  final MiuixPopupHostController? parent;
  final GlobalKey _hostKey = GlobalKey();
  final List<_MiuixHostedPopup<dynamic>> _entries = [];
  LocalHistoryEntry? _backHistoryEntry;
  bool _removingBackHistoryProgrammatically = false;
  ModalRoute<dynamic>? _backGuardRoute;
  Future<bool> Function()? _backGuardCallback;
  bool _disposed = false;
  var _id = 0;

  /// Outermost popup host in the current scaffold chain.
  MiuixPopupHostController get root => parent?.root ?? this;

  List<_MiuixHostedPopup<dynamic>> get _currentEntries {
    final ordered = List<_MiuixHostedPopup<dynamic>>.of(_entries)
      ..sort((a, b) {
        final zOrder = a.zIndex.compareTo(b.zIndex);
        return zOrder != 0 ? zOrder : a.id.compareTo(b.id);
      });
    return List.unmodifiable(ordered);
  }

  // A popup that is reversing still owns the route's back gesture until its
  // exit animation has completed. Otherwise a quick second Back press can pop
  // the application page while the modal surface is visibly leaving.
  bool get _hasBackHandlingEntry =>
      _entries.any((entry) => entry.enableBackHandler);

  bool get _blocksRoutePop => _hasBackHandlingEntry;

  bool _isPredictiveBackOwner(_MiuixHostedPopup<dynamic> candidate) {
    for (final entry in _entries.reversed) {
      if (entry.enableBackHandler) {
        return identical(entry, candidate) && entry.visible;
      }
    }
    return false;
  }

  void _commitPredictiveBack(_MiuixHostedPopup<dynamic> candidate) {
    if (_isPredictiveBackOwner(candidate)) _handleRoutePop();
  }

  // BottomSheetContentLayout removes a committed predictive sheet at the
  // first frame where its offset reaches one sheet height. The surface is
  // already outside the viewport then, so replaying the hosted 680ms reverse
  // visibility spring would delay completion without drawing anything.
  void _commitBottomSheetPredictiveBack(_MiuixHostedPopup<dynamic> candidate) {
    if (!_isPredictiveBackOwner(candidate)) return;
    candidate.onDismissRequest?.call();
    candidate.visible = false;
    if (!candidate.completer.isCompleted) candidate.completer.complete();
    _remove(candidate);
  }

  void _syncBackRegistration() {
    if (_hasBackHandlingEntry) {
      _ensureBackHistoryEntry();
      _ensureBackRouteGuard();
    } else {
      _clearBackRouteGuard();
      _clearBackHistoryEntry();
    }
  }

  // Overlay-hosted surfaces do not push a Navigator route. A PopScope alone
  // can veto the route pop, but Flutter then invokes every PopScope callback
  // registered on that route with didPop=false. An application-level handler
  // can therefore react as well (the reference example returned its pager to
  // Home while the dropdown was still open). LocalHistoryEntry is Flutter's
  // route-native mechanism for menus: Back removes this entry internally,
  // starts the popup dismissal, and never reaches unrelated page handlers.
  void _ensureBackHistoryEntry() {
    if (_backHistoryEntry != null || !_hasBackHandlingEntry) {
      return;
    }
    final hostContext = _hostKey.currentContext;
    final route = hostContext == null ? null : ModalRoute.of(hostContext);
    if (route == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_hasBackHandlingEntry) {
          _ensureBackHistoryEntry();
        }
      });
      return;
    }

    late final LocalHistoryEntry entry;
    entry = LocalHistoryEntry(
      impliesAppBarDismissal: false,
      onRemove: () {
        if (identical(_backHistoryEntry, entry)) {
          _backHistoryEntry = null;
        }
        if (_removingBackHistoryProgrammatically) {
          return;
        }

        // The system removed the local entry, so this is a genuine Back
        // request. Dismiss only the top live popup. Reinstall a local entry
        // while its reverse animation is still mounted; a second fast Back
        // must remain consumed until physical removal finishes.
        _handleRoutePop();
        if (_hasBackHandlingEntry) {
          _ensureBackHistoryEntry();
        }
      },
    );
    _backHistoryEntry = entry;
    route.addLocalHistoryEntry(entry);
  }

  void _clearBackHistoryEntry() {
    final entry = _backHistoryEntry;
    _backHistoryEntry = null;
    if (entry == null) {
      return;
    }
    _removingBackHistoryProgrammatically = true;
    try {
      entry.remove();
    } finally {
      _removingBackHistoryProgrammatically = false;
    }
  }

  // Local history gives the hosted popup route ownership, while this scoped
  // callback consumes Navigator.maybePop before Flutter broadcasts a rejected
  // PopScope attempt to every listener on the route. That broadcast would make
  // an unrelated pager-level PopScope react to the same Back press. Flutter
  // currently has no PopScope priority API, so the scoped callback remains the
  // compatibility bridge for overlay-hosted surfaces.
  void _ensureBackRouteGuard() {
    if (_backGuardCallback != null || !_hasBackHandlingEntry) {
      return;
    }
    final hostContext = _hostKey.currentContext;
    final route = hostContext == null ? null : ModalRoute.of(hostContext);
    if (route == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_hasBackHandlingEntry) {
          _ensureBackRouteGuard();
        }
      });
      return;
    }

    Future<bool> callback() async {
      _handleRoutePop();
      return false;
    }

    _backGuardRoute = route;
    _backGuardCallback = callback;
    // ignore: deprecated_member_use
    route.addScopedWillPopCallback(callback);
  }

  void _clearBackRouteGuard() {
    final route = _backGuardRoute;
    final callback = _backGuardCallback;
    _backGuardRoute = null;
    _backGuardCallback = null;
    if (route == null || callback == null) {
      return;
    }
    // ignore: deprecated_member_use
    route.removeScopedWillPopCallback(callback);
  }

  /// Shows content in this scaffold's popup layer.
  Future<T?> show<T>({
    required Widget child,
    int? zIndex,
    LayerLink? link,
    Rect? anchorRect,
    Rect? Function()? anchorRectProvider,
    MiuixPopupAlignment popupAlignment = MiuixPopupAlignment.bottomStart,
    MiuixPopupPositioning popupPositioning = MiuixPopupPositioning.dropdown,
    Alignment targetAnchor = Alignment.bottomLeft,
    Alignment followerAnchor = Alignment.topLeft,
    Offset offset = Offset.zero,
    Alignment unanchoredAlignment = Alignment.center,
    bool dimBackground = true,
    Color? dimColor,
    ValueListenable<double>? dimAlpha,
    MiuixVisibilityTransition? enterTransition,
    MiuixVisibilityTransition? exitTransition,
    MiuixVisibilityTransition? dimEnterTransition,
    MiuixVisibilityTransition? dimExitTransition,
    bool fadeTransition = false,
    bool dialogTransition = false,
    bool bottomSheetTransition = false,
    bool barrierDismissible = true,
    bool enableBackHandler = true,
    bool enableAutoLargeScreen = true,
    bool? dialogLargeScreen,
    bool Function()? canDismiss,
    MiuixCascadingPopupController? cascadingController,
    VoidCallback? onDismissRequest,
    VoidCallback? onDismissFinished,
  }) {
    // Anchor rectangles are measured in the application's global coordinate
    // space. A nested Scaffold's popup host starts at that Scaffold's own
    // origin, so feeding the global rectangle directly to its layout delegate
    // shifts the popup down and right by the nested host's screen offset. The
    // source PopupHost always resolves coordinates in its local layout space.
    // Convert here once, while both the trigger and host render boxes are
    // attached; root hosts naturally retain the same coordinates.
    final hostContext = _hostKey.currentContext;
    final sourceHostOrigin = _miuixPopupHostOriginInWindow(hostContext);
    final safeAnchorRect = _miuixSafePopupAnchorRect(anchorRect);
    final localAnchorRect = safeAnchorRect != null && sourceHostOrigin != null
        ? safeAnchorRect.shift(-sourceHostOrigin)
        : safeAnchorRect;
    Rect? localAnchorProvider() {
      final globalRect = _miuixSafePopupAnchorRect(anchorRectProvider?.call());
      if (globalRect == null) return null;
      final liveHostOrigin = _miuixPopupHostOriginInWindow(
        _hostKey.currentContext,
      );
      return liveHostOrigin == null
          ? globalRect
          : globalRect.shift(-liveHostOrigin);
    }

    final completer = Completer<T?>();
    final entryId = ++_id;
    final entry = _MiuixHostedPopup<T>(
      id: entryId,
      zIndex: zIndex ?? _miuixNextHostedPopupZIndex++,
      child: child,
      completer: completer,
      link: link,
      anchorRect: localAnchorRect,
      anchorRectProvider: anchorRectProvider == null
          ? null
          : localAnchorProvider,
      popupAlignment: popupAlignment,
      popupPositioning: popupPositioning,
      targetAnchor: targetAnchor,
      followerAnchor: followerAnchor,
      offset: _miuixSafePopupOffset(offset),
      unanchoredAlignment: unanchoredAlignment,
      dimBackground: dimBackground,
      dimColor: dimColor,
      dimAlpha: dimAlpha,
      dialogBackProgress:
          dialogTransition && dimAlpha is _MiuixDialogBackProgress
          ? dimAlpha
          : null,
      bottomSheetBackProgress:
          bottomSheetTransition && dimAlpha is _MiuixBottomSheetBackProgress
          ? dimAlpha
          : null,
      listPopupBackProgress:
          !bottomSheetTransition && !dialogTransition && !fadeTransition
          ? _MiuixListPopupBackProgress()
          : null,
      cascadingController: cascadingController,
      enterTransition: enterTransition,
      exitTransition: exitTransition,
      dimEnterTransition: dimEnterTransition,
      dimExitTransition: dimExitTransition,
      transition: bottomSheetTransition
          ? _MiuixHostedPopupTransition.bottomSheet
          : dialogTransition
          ? _MiuixHostedPopupTransition.dialog
          : fadeTransition
          ? _MiuixHostedPopupTransition.fade
          : _MiuixHostedPopupTransition.scale,
      barrierDismissible: barrierDismissible,
      enableBackHandler: enableBackHandler,
      enableAutoLargeScreen: enableAutoLargeScreen,
      dialogLargeScreen: dialogLargeScreen,
      canDismiss: canDismiss,
      onDismissRequest: onDismissRequest,
      onDismissFinished: onDismissFinished,
    );
    _entries.add(entry);
    _syncBackRegistration();
    notifyListeners();
    return completer.future;
  }

  void _refreshEntry(_MiuixHostedPopup<dynamic> entry) {
    if (_entries.contains(entry)) {
      _syncBackRegistration();
      notifyListeners();
    }
  }

  /// Begins the hide animation for the topmost popup.
  void dismissTop<T>([T? result]) {
    for (final entry in _entries.reversed) {
      if (entry.visible) {
        _dismiss(entry, result);
        return;
      }
    }
  }

  // A sheet that has already crossed its own height is physically outside the
  // viewport. BottomSheetContentLayout snaps the visibility channel to zero in
  // that case, so replaying the ordinary 680ms exit would delay
  // onDismissFinished after nothing remains visible.
  void _dismissTopImmediately<T>([T? result]) {
    for (final entry in _entries.reversed) {
      if (!entry.visible) continue;
      entry.visible = false;
      if (!entry.completer.isCompleted) entry.completer.complete(result);
      _remove(entry);
      return;
    }
  }

  // Handles a platform Back request using the same live dismissibility rules
  // as the popup barrier. This path must invoke onDismissRequest before the
  // reverse animation so OverlayDialog and OverlayBottomSheet can release the
  // hold-down state at the same lifecycle point as the Compose PopupHost.
  bool _handleRoutePop() {
    // 认证保护优先于浮层的兼容返回回调，不能在遮罩后关闭菜单或弹窗。
    final hostContext = _hostKey.currentContext;
    if (hostContext != null && MiuixBackGestureScope.blockedOf(hostContext)) {
      return true;
    }
    for (final entry in _entries.reversed) {
      if (!entry.enableBackHandler) {
        continue;
      }
      // A reversing popup keeps ownership of Back until it is physically
      // removed. This prevents a rapid second press from dismissing the entry
      // immediately below it.
      if (!entry.visible) {
        return true;
      }
      if (entry.canDismiss?.call() == false) {
        return false;
      }
      entry.onDismissRequest?.call();
      _dismiss(entry);
      return true;
    }
    return false;
  }

  void _dismiss<T>(_MiuixHostedPopup<dynamic> entry, [T? result]) {
    if (_disposed || !entry.visible) {
      return;
    }
    entry.visible = false;
    if (!entry.completer.isCompleted) {
      entry.completer.complete(result);
    }
    notifyListeners();
  }

  void _remove(_MiuixHostedPopup<dynamic> entry) {
    if (!_disposed && _entries.remove(entry)) {
      entry.onDismissFinished?.call();
      _syncBackRegistration();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _clearBackRouteGuard();
    _clearBackHistoryEntry();
    for (final entry in _entries) {
      if (!entry.completer.isCompleted) {
        entry.completer.complete();
      }
    }
    _entries.clear();
    super.dispose();
  }
}

/// Inherited access point used by Overlay-prefixed components.
class MiuixPopupHostScope extends InheritedNotifier<MiuixPopupHostController> {
  /// Creates a popup-host scope.
  const MiuixPopupHostScope({
    super.key,
    required MiuixPopupHostController controller,
    required super.child,
  }) : super(notifier: controller);

  /// Returns the nearest controller without establishing a dependency.
  static MiuixPopupHostController? maybeOf(BuildContext context) {
    return context
        .getInheritedWidgetOfExactType<MiuixPopupHostScope>()
        ?.notifier;
  }
}

/// Visual popup layer driven by a [MiuixPopupHostController].
class MiuixPopupHostView extends StatefulWidget {
  /// Creates a popup layer.
  const MiuixPopupHostView({super.key, required this.controller});

  final MiuixPopupHostController controller;

  @override
  State<MiuixPopupHostView> createState() => _MiuixPopupHostViewState();
}

class _MiuixPopupHostViewState extends State<MiuixPopupHostView> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_changed);
  }

  @override
  void didUpdateWidget(covariant MiuixPopupHostView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_changed);
      widget.controller.addListener(_changed);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final semantic = MiuixSemanticColors.of(context);
    final textStyle =
        (Theme.of(context).textTheme.bodyLarge ?? const TextStyle(fontSize: 17))
            .copyWith(color: semantic['onSurface']);
    return SizedBox.expand(
      key: widget.controller._hostKey,
      child: PopScope<Object?>(
        // Overlay-prefixed components live inside the page instead of on a
        // Navigator route. Registering their host with PopScope is therefore
        // required to stop Android Back from closing the Activity behind them.
        canPop: !widget.controller._blocksRoutePop,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) widget.controller._handleRoutePop();
        },
        child: DefaultTextStyle(
          // The host is intentionally a sibling painted above Scaffold. Restore
          // the MIUIX main text style here because Scaffold's Material defaults
          // no longer sit above popup children in the element tree.
          style: textStyle,
          child: Stack(
            fit: StackFit.expand,
            children: [
              for (final entry in widget.controller._currentEntries)
                _MiuixHostedPopupView(
                  key: ValueKey(entry.id),
                  entry: entry,
                  controller: widget.controller,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiuixHostedPopupView extends StatefulWidget {
  const _MiuixHostedPopupView({
    super.key,
    required this.entry,
    required this.controller,
  });

  final _MiuixHostedPopup<dynamic> entry;
  final MiuixPopupHostController controller;

  @override
  State<_MiuixHostedPopupView> createState() => _MiuixHostedPopupViewState();
}

class _MiuixHostedPopupViewState extends State<_MiuixHostedPopupView>
    with TickerProviderStateMixin {
  // Hosted-popup lifetime notes:
  //
  // - The controller owns entry insertion, z-order, and result completion.
  // - This State owns only visual transition controllers and placement cache.
  // - Entry fields may change while the popup remains in the host Stack.
  // - didUpdateWidget resynchronizes durations without recreating controllers.
  // - Reduced motion jumps both content and dim channels to terminal values.
  // - Removal is deferred beyond build to avoid mutating the host Stack inline.
  // - A dismissal request first honors barrier and canDismiss contracts.
  // - onDismissRequest is emitted before the controller starts the exit path.
  // - onDismissFinished is emitted only after the entry has actually detached.
  // - Predictive Back owns separate progress objects tied to this entry.
  // - Those objects are disposed after descendants have stopped listening.
  // - The initial anchor can be host-local or absent when LayerLink is used.
  // - A live provider refreshes entry.anchorRect in host-local coordinates.
  // - The latest rectangle is the single source for placement and flipping.
  // - A null live sample deliberately selects the linked fallback branch.
  // - Returning later to a rectangle switches back without reopening the menu.
  // - Popup layout position is cached only to select the correct scale origin.
  // - The delegate reports a new position when safe-area flipping changes side.
  // - That report schedules State work after layout rather than inside paint.
  // - Dim hit testing fills the host even when visible dim alpha is disabled.
  // - Anchored content stays above the dim surface in Stack paint order.
  // - Host window bounds retain negative edges for nested source-compatible hosts.
  // - Device-pixel truncation matches the source window-coordinate behavior.
  // - No live-sampling path creates a Ticker or Timer.
  // - Widget tests use pump frames to model application-produced movement.
  late final AnimationController _contentAnimation;
  late final AnimationController _dimAnimation;
  MiuixPopupLayoutPosition? _popupLayoutPosition;
  bool _reduceMotion = false;
  bool _removeScheduled = false;
  bool _anchorTrackingScheduled = false;

  Duration get _contentEnterDuration =>
      widget.entry.enterTransition?._safeDuration ??
      switch (widget.entry.transition) {
        _MiuixHostedPopupTransition.dialog => _miuixDialogEnterDuration,
        _MiuixHostedPopupTransition.scale =>
          MiuixListPopupDefaults.fractionDuration,
        _MiuixHostedPopupTransition.fade => const Duration(milliseconds: 200),
        _MiuixHostedPopupTransition.bottomSheet =>
          _miuixBottomSheetVisibilityDuration,
      };

  Duration get _contentExitDuration =>
      widget.entry.exitTransition?._safeDuration ??
      switch (widget.entry.transition) {
        _MiuixHostedPopupTransition.dialog => const Duration(milliseconds: 200),
        _MiuixHostedPopupTransition.scale =>
          MiuixListPopupDefaults.fractionDuration,
        _MiuixHostedPopupTransition.fade => const Duration(milliseconds: 150),
        _MiuixHostedPopupTransition.bottomSheet =>
          _miuixBottomSheetVisibilityDuration,
      };

  Duration get _dimEnterDuration =>
      widget.entry.dimEnterTransition?._safeDuration ??
      switch (widget.entry.transition) {
        _MiuixHostedPopupTransition.dialog ||
        _MiuixHostedPopupTransition.fade => const Duration(milliseconds: 300),
        _MiuixHostedPopupTransition.scale =>
          MiuixListPopupDefaults.fractionDuration,
        _MiuixHostedPopupTransition.bottomSheet =>
          _miuixBottomSheetVisibilityDuration,
      };

  Duration get _dimExitDuration =>
      widget.entry.dimExitTransition?._safeDuration ??
      switch (widget.entry.transition) {
        _MiuixHostedPopupTransition.dialog => const Duration(milliseconds: 250),
        _MiuixHostedPopupTransition.scale =>
          MiuixListPopupDefaults.fractionDuration,
        _MiuixHostedPopupTransition.fade => const Duration(milliseconds: 150),
        _MiuixHostedPopupTransition.bottomSheet =>
          _miuixBottomSheetVisibilityDuration,
      };

  @override
  void initState() {
    super.initState();
    _contentAnimation = AnimationController(
      vsync: this,
      duration: _contentEnterDuration,
      reverseDuration: _contentExitDuration,
    )..forward();
    _dimAnimation = AnimationController(
      vsync: this,
      duration: _dimEnterDuration,
      reverseDuration: _dimExitDuration,
    )..forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion == _reduceMotion) return;
    _reduceMotion = reduceMotion;
    if (!_reduceMotion) return;

    // Hosted overlays preserve direct predictive-Back and drag progress, but
    // inherited reduced motion removes their autonomous visibility clocks.
    _contentAnimation.stop();
    _dimAnimation.stop();
    if (widget.entry.visible) {
      _contentAnimation.value = 1;
      _dimAnimation.value = 1;
    } else {
      _contentAnimation.value = 0;
      _dimAnimation.value = 0;
      _scheduleRemove();
    }
  }

  @override
  void didUpdateWidget(covariant _MiuixHostedPopupView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _contentAnimation
      ..duration = _contentEnterDuration
      ..reverseDuration = _contentExitDuration;
    _dimAnimation
      ..duration = _dimEnterDuration
      ..reverseDuration = _dimExitDuration;
    if (!widget.entry.visible &&
        (_contentAnimation.status != AnimationStatus.reverse ||
            _dimAnimation.status != AnimationStatus.reverse)) {
      if (_reduceMotion) {
        _contentAnimation.value = 0;
        _dimAnimation.value = 0;
        _scheduleRemove();
      } else {
        _hide();
      }
    }
  }

  void _scheduleRemove() {
    if (_removeScheduled) return;
    _removeScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _removeScheduled = false;
      if (mounted && !widget.entry.visible) {
        widget.controller._remove(widget.entry);
      }
    });
  }

  Future<void> _hide() async {
    try {
      await Future.wait([_contentAnimation.reverse(), _dimAnimation.reverse()]);
    } on TickerCanceled {
      return;
    }
    widget.controller._remove(widget.entry);
  }

  void _requestDismiss() {
    if (!widget.entry.barrierDismissible ||
        widget.entry.canDismiss?.call() == false) {
      return;
    }
    widget.entry.onDismissRequest?.call();
    widget.controller._dismiss(widget.entry);
  }

  /// Passively refreshes an application-global anchor into this host's local
  /// coordinate space after each frame the application already produces.
  ///
  /// The provider stored by the controller already performs the global-to-host
  /// conversion. This view must not convert the value again: doing so would
  /// subtract the host origin twice and make a menu drift whenever its Scaffold
  /// is inset. The equality guard also intentionally compares complete Rects;
  /// changes in size can alter the valid above/below placement even if the
  /// trigger's top-left point is unchanged.
  void _scheduleLiveAnchorSample() {
    if (_anchorTrackingScheduled || widget.entry.anchorRectProvider == null) {
      return;
    }
    _anchorTrackingScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _anchorTrackingScheduled = false;
      if (!mounted) return;
      final next = widget.entry.anchorRectProvider?.call();
      if (next != widget.entry.anchorRect) {
        setState(() => widget.entry.anchorRect = next);
      }
      _scheduleLiveAnchorSample();
    });
  }

  @override
  void dispose() {
    _contentAnimation.dispose();
    _dimAnimation.dispose();
    // Hosted dialog progress is private entry state. The entry's descendants
    // have detached before this State is disposed, so no listener survives it.
    widget.entry.dialogBackProgress?.dispose();
    widget.entry.bottomSheetBackProgress?.dispose();
    widget.entry.listPopupBackProgress?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scheduleLiveAnchorSample();
    _popupLayoutPosition ??= _miuixPredictedPopupLayoutPosition(
      widget.entry.popupAlignment,
      Directionality.of(context),
    );
    final bottomSheetCurve = CurvedAnimation(
      parent: _contentAnimation,
      curve: _miuixBottomSheetVisibilityCurve,
      reverseCurve: _miuixBottomSheetVisibilityReverseCurve,
    );
    final size = MediaQuery.sizeOf(context);
    final largeDialog =
        widget.entry.dialogLargeScreen ??
        (widget.entry.enableAutoLargeScreen &&
            size.width >= 840 &&
            size.height >= 480);
    final dialogCurve = CurvedAnimation(
      parent: _contentAnimation,
      curve: _MiuixDialogSpringCurve(
        dampingRatio: largeDialog ? .9 : .88,
        stiffness: largeDialog ? 438.6 : 450,
      ),
      reverseCurve: const _MiuixAccelerateCurve(),
    );
    final dimCurve = switch (widget.entry.transition) {
      _MiuixHostedPopupTransition.dialog => CurvedAnimation(
        parent: _dimAnimation,
        curve: const _MiuixDialogDimEnterCurve(),
        reverseCurve: const _MiuixDialogDimExitCurve(),
      ),
      _MiuixHostedPopupTransition.bottomSheet => CurvedAnimation(
        parent: _dimAnimation,
        curve: _miuixBottomSheetVisibilityCurve,
        reverseCurve: _miuixBottomSheetVisibilityReverseCurve,
      ),
      _ => CurvedAnimation(parent: _dimAnimation, curve: Curves.easeOutCubic),
    };
    final defaultPopup = switch (widget.entry.transition) {
      _MiuixHostedPopupTransition.dialog when !largeDialog => SlideTransition(
        key: const ValueKey('miuix-host-dialog-slide'),
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(dialogCurve),
        child: widget.entry.child,
      ),
      _MiuixHostedPopupTransition.dialog => FadeTransition(
        key: const ValueKey('miuix-host-dialog-large-fade'),
        opacity: dialogCurve,
        child: ScaleTransition(
          scale: Tween<double>(begin: .8, end: 1).animate(dialogCurve),
          child: widget.entry.child,
        ),
      ),
      _MiuixHostedPopupTransition.bottomSheet => SlideTransition(
        key: const ValueKey('miuix-host-bottom-sheet-slide'),
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(bottomSheetCurve),
        child: widget.entry.child,
      ),
      _MiuixHostedPopupTransition.scale => _MiuixAnimatedListPopupSurface(
        animation: _contentAnimation,
        position: _popupLayoutPosition!,
        backProgress: widget.entry.listPopupBackProgress,
        child: widget.entry.child,
      ),
      _MiuixHostedPopupTransition.fade => FadeTransition(
        opacity: _contentAnimation,
        child: widget.entry.child,
      ),
    };
    final contentTransition =
        _contentAnimation.status == AnimationStatus.reverse
        ? widget.entry.exitTransition
        : widget.entry.enterTransition;
    final popup =
        contentTransition?._build(
          context,
          _contentAnimation,
          widget.entry.child,
        ) ??
        defaultPopup;
    final dimGesture = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _requestDismiss,
      child: widget.entry.dimBackground
          ? ColoredBox(
              color:
                  widget.entry.dimColor ?? Colors.black.withValues(alpha: .16),
            )
          : const SizedBox.expand(),
    );
    final selectedDimTransition =
        _dimAnimation.status == AnimationStatus.reverse
        ? widget.entry.dimExitTransition
        : widget.entry.dimEnterTransition;
    Widget dimSurface;
    if (!widget.entry.dimBackground) {
      dimSurface = dimGesture;
    } else if (selectedDimTransition != null) {
      dimSurface = selectedDimTransition._build(
        context,
        _dimAnimation,
        dimGesture,
      );
    } else {
      dimSurface = switch (widget.entry.transition) {
        _MiuixHostedPopupTransition.scale => AnimatedBuilder(
          animation: _dimAnimation,
          builder: (context, child) {
            final progress = _miuixListPopupProgress(_dimAnimation);
            return Opacity(opacity: progress.dim.clamp(0.0, 1.0), child: child);
          },
          child: dimGesture,
        ),
        _MiuixHostedPopupTransition.fade => AnimatedBuilder(
          animation: _dimAnimation,
          builder: (context, child) {
            final reversing = _dimAnimation.status == AnimationStatus.reverse;
            final dimProgress = reversing
                ? 1 -
                      const _MiuixSinOutCurve().transform(
                        1 - _dimAnimation.value,
                      )
                : const _MiuixSinOutCurve().transform(_dimAnimation.value);
            return Opacity(opacity: dimProgress.clamp(0.0, 1.0), child: child);
          },
          child: dimGesture,
        ),
        _MiuixHostedPopupTransition.dialog => FadeTransition(
          opacity: dimCurve,
          child: dimGesture,
        ),
        _MiuixHostedPopupTransition.bottomSheet => AnimatedBuilder(
          animation: dimCurve,
          builder: (context, child) => Opacity(
            key: const ValueKey('miuix-host-bottom-sheet-dim'),
            opacity: dimCurve.value.clamp(0.0, 1.0),
            child: child,
          ),
          child: dimGesture,
        ),
      };
    }
    if (widget.entry.dimAlpha case final dimAlpha?) {
      dimSurface = AnimatedBuilder(
        animation: dimAlpha,
        builder: (context, child) => Opacity(
          key: ValueKey(
            widget.entry.bottomSheetBackProgress != null
                ? 'miuix-bottom-sheet-predictive-dim'
                : 'miuix-dialog-predictive-dim',
          ),
          opacity: dimAlpha.value.clamp(0.0, 1.0),
          child: child,
        ),
        child: dimSurface,
      );
    }
    if (widget.entry.listPopupBackProgress case final backProgress?) {
      dimSurface = AnimatedBuilder(
        animation: backProgress,
        builder: (context, child) => Opacity(
          key: const ValueKey('miuix-list-popup-predictive-dim'),
          opacity: backProgress.value.clamp(0.0, 1.0),
          child: child,
        ),
        child: dimSurface,
      );
    }
    final density = View.of(context).devicePixelRatio;
    final windowSize = View.of(context).physicalSize / density;
    final windowPadding = MediaQuery.paddingOf(context);
    final sourceHostOrigin =
        _miuixPopupHostOriginInWindow(
          widget.controller._hostKey.currentContext,
        ) ??
        Offset.zero;
    // Bounds remain expressed in this host's local coordinates, but their
    // edges are the real safe Android window. A right-hand nested host thus
    // receives a negative local left edge; the popup may align left of that
    // host and is then clipped by PopupHost exactly like the Compose fixture.
    final sourceWindowBounds = Rect.fromLTRB(
      windowPadding.left - sourceHostOrigin.dx,
      windowPadding.top - sourceHostOrigin.dy,
      windowSize.width - windowPadding.right - sourceHostOrigin.dx,
      windowSize.height - windowPadding.bottom - sourceHostOrigin.dy,
    );
    final hostedSurface = Stack(
      fit: StackFit.expand,
      children: [
        dimSurface,
        if (widget.entry.anchorRect case final anchorRect?)
          CustomSingleChildLayout(
            delegate: _MiuixPopupLayoutDelegate(
              anchorRect: anchorRect,
              alignment: widget.entry.popupAlignment,
              positioning: widget.entry.popupPositioning,
              textDirection: Directionality.of(context),
              safePadding: windowPadding,
              placementBounds: sourceWindowBounds,
              devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
              onLayoutPositionChanged: (position) {
                if (position != _popupLayoutPosition && mounted) {
                  setState(() => _popupLayoutPosition = position);
                }
              },
            ),
            child: popup,
          )
        else if (widget.entry.link case final link?)
          _MiuixAdaptivePopupFollower(
            link: link,
            targetAnchor: widget.entry.targetAnchor,
            followerAnchor: widget.entry.followerAnchor,
            offset: widget.entry.offset,
            child: popup,
          )
        else
          Align(alignment: widget.entry.unanchoredAlignment, child: popup),
      ],
    );
    if (widget.entry.dialogBackProgress case final backProgress?) {
      return _MiuixPredictiveBackObserver(
        controller: backProgress,
        canStart: () => widget.controller._isPredictiveBackOwner(widget.entry),
        onCommit: () => widget.controller._commitPredictiveBack(widget.entry),
        child: hostedSurface,
      );
    }
    if (widget.entry.bottomSheetBackProgress case final backProgress?) {
      return _MiuixBottomSheetPredictiveBackObserver(
        controller: backProgress,
        canStart: () => widget.controller._isPredictiveBackOwner(widget.entry),
        onCommit: () =>
            widget.controller._commitBottomSheetPredictiveBack(widget.entry),
        child: hostedSurface,
      );
    }
    if (widget.entry.listPopupBackProgress case final backProgress?) {
      return _MiuixListPopupPredictiveBackObserver(
        controller: backProgress,
        cascadingController: widget.entry.cascadingController,
        canStart: () => widget.controller._isPredictiveBackOwner(widget.entry),
        onCommit: () => widget.controller._commitPredictiveBack(widget.entry),
        child: hostedSurface,
      );
    }
    return hostedSurface;
  }
}

/// Keeps an Overlay-hosted popup inside the same safe placement rules as the
/// original MIUIX `DropdownPositionProvider` while retaining a live LayerLink.
//
// Adaptive-follower invariants:
//
// - CompositedTransformFollower supplies the moving base transform.
// - The correction Transform supplies only safe-window displacement.
// - Measurement removes the previous correction before solving the next one.
// - That subtraction prevents one-pixel drift from accumulating every frame.
// - Leader size is read from LayerLink after paint and can change dynamically.
// - Popup size is read from the unscaled layout box during entrance animation.
// - Horizontal clamping preserves the caller's start/end anchor semantics.
// - Vertical preference is inferred from target and follower anchor ordering.
// - Complete fit below wins for bottom-aligned dropdowns.
// - Complete fit above is the second choice for bottom-aligned dropdowns.
// - When neither side fits, the surface centers near the trigger and clamps.
// - Eight logical pixels remain as the visual safe-edge margin.
// - System padding excludes status, navigation, gesture, and cutout regions.
// - The follower stays linked while the correction changes.
// - Updating link or anchor configuration clears stale correction immediately.
// - Post-frame measurement observes the final linked paint transform.
// - Its callback chain is passive and cannot make an idle page render forever.
// - A sub-pixel equality tolerance avoids redundant correction setState calls.
// - The same implementation is used by hosted and root-window menu fallbacks.
// - Exact source parity still depends on device screenshots at unusual insets.
class _MiuixAdaptivePopupFollower extends StatefulWidget {
  const _MiuixAdaptivePopupFollower({
    required this.link,
    required this.targetAnchor,
    required this.followerAnchor,
    required this.offset,
    required this.child,
  });

  final LayerLink link;
  final Alignment targetAnchor;
  final Alignment followerAnchor;
  final Offset offset;
  final Widget child;

  @override
  State<_MiuixAdaptivePopupFollower> createState() =>
      _MiuixAdaptivePopupFollowerState();
}

class _MiuixAdaptivePopupFollowerState
    extends State<_MiuixAdaptivePopupFollower> {
  final GlobalKey _popupKey = GlobalKey();
  Offset _correction = Offset.zero;
  bool _measurementScheduled = false;

  bool get _prefersBelow => widget.targetAnchor.y > widget.followerAnchor.y;

  bool get _prefersAbove => widget.targetAnchor.y < widget.followerAnchor.y;

  @override
  void didUpdateWidget(covariant _MiuixAdaptivePopupFollower oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.link != widget.link ||
        oldWidget.targetAnchor != widget.targetAnchor ||
        oldWidget.followerAnchor != widget.followerAnchor ||
        oldWidget.offset != widget.offset) {
      _correction = Offset.zero;
    }
  }

  void _scheduleMeasurement() {
    if (_measurementScheduled) return;
    _measurementScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measurementScheduled = false;
      if (!mounted) return;
      _updateCorrection();
      // LayerLink updates at paint time and does not notify this State. Chain
      // one passive sample into the next application-produced frame so a
      // scrolling or resizing anchor can flip/clamp the popup without running
      // an idle ticker or forcing continuous frames.
      _scheduleMeasurement();
    });
  }

  // Placement deliberately mirrors `ListPopupDefaults.dropdownPositionProvider`:
  // 1. Read the popup's painted global rectangle after its first layout.
  // 2. Remove the previous correction to recover the linked base position.
  // 3. Treat system padding as the original provider's safe window bounds.
  // 4. Reserve eight logical pixels only for the final surface margin.
  // 5. Prefer the full popup below the anchor when it fits there.
  // 6. Otherwise prefer the full popup above the anchor when it fits there.
  // 7. If neither side fits, center it vertically on the anchor.
  // 8. Clamp that result between the top and bottom safe margins.
  // 9. Clamp horizontally without changing end/start alignment semantics.
  // 10. Apply the correction as a paint transform so the LayerLink remains live.
  // The correction is recomputed when text wrapping or menu state changes size.
  // Measuring the untransformed layout size avoids feedback from scale animation.
  // Subtracting the prior correction prevents cumulative drift across frames.
  // Strict `>` fit comparisons match the Compose implementation at boundaries.
  // Disabled rows remain part of popup size because MIUIX keeps them visible.
  // MediaQuery padding represents status, navigation, and display-cutout insets.
  // The root popup host may rebuild while open; the stable link preserves origin.
  // A sub-pixel tolerance prevents redundant frames from rounding differences.
  // All callers therefore share one placement rule on Android, Windows, and web.
  void _updateCorrection() {
    final box = _popupKey.currentContext?.findRenderObject();
    final leaderSize = widget.link.leaderSize;
    if (box is! RenderBox || !box.attached || leaderSize == null) return;

    final media = MediaQuery.of(context);
    final paintedTopLeft = box.localToGlobal(Offset.zero);
    final baseTopLeft = paintedTopLeft - _correction;
    final popupSize = box.size;
    final safeLeft = media.padding.left;
    final windowTop = media.padding.top;
    final safeRight = media.size.width - media.padding.right;
    final windowBottom = media.size.height - media.padding.bottom;
    final safeTop = windowTop + 8;
    final safeBottom = windowBottom - 8;

    final desiredX = baseTopLeft.dx
        .clamp(safeLeft, math.max(safeLeft, safeRight - popupSize.width))
        .toDouble();
    var desiredY = baseTopLeft.dy;
    if (_prefersBelow) {
      final anchorBottom = baseTopLeft.dy - widget.offset.dy;
      final anchorTop = anchorBottom - leaderSize.height;
      final availableBelow = windowBottom - anchorBottom;
      final availableAbove = anchorTop - windowTop;
      desiredY = availableBelow > popupSize.height
          ? anchorBottom + 8
          : availableAbove > popupSize.height
          ? anchorTop - popupSize.height - 8
          : anchorTop + leaderSize.height / 2 - popupSize.height / 2;
    } else if (_prefersAbove) {
      final anchorTop = baseTopLeft.dy + popupSize.height - widget.offset.dy;
      desiredY = anchorTop - popupSize.height - 8;
    }
    desiredY = desiredY
        .clamp(safeTop, math.max(safeTop, safeBottom - popupSize.height))
        .toDouble();
    final next = Offset(desiredX - baseTopLeft.dx, desiredY - baseTopLeft.dy);
    if ((next - _correction).distance > .1 && mounted) {
      setState(() => _correction = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    _scheduleMeasurement();
    return CompositedTransformFollower(
      link: widget.link,
      showWhenUnlinked: false,
      targetAnchor: widget.targetAnchor,
      followerAnchor: widget.followerAnchor,
      offset: widget.offset,
      child: Transform.translate(
        offset: _correction,
        child: UnconstrainedBox(
          alignment: widget.followerAnchor,
          child: SizedBox(key: _popupKey, child: widget.child),
        ),
      ),
    );
  }
}

/// Application scaffold with isolated popup state and MIUIX floating slots.
///
/// The upstream scaffold is a placement container rather than a Material
/// bottom-bar layout. Its body owns the complete window and independently
/// receives content padding for the measured top and bottom components.
/// Flutter's stock [Scaffold] normally removes the bottom-navigation height
/// from the body, which is correct for a regular rectangular bar but not for a
/// floating capsule. This adapter keeps those two source paths separate.
///
/// Regular navigation remains in [Scaffold.bottomNavigationBar] so Flutter can
/// reserve its rectangular layout area. Floating navigation is instead painted
/// in the outer full-window stack. That preserves the page below the clear
/// corners of the capsule and gives its zero-offset blur room above the surface.
///
/// Layer order intentionally follows the original scaffold contract:
///
/// 1. the page and its connected top-bar scroll behavior;
/// 2. page-local floating controls;
/// 3. the regular or floating navigation surface;
/// 4. snackbar feedback lifted above navigation;
/// 5. the scaffold popup host.
///
/// Keeping snackbar and popup layers outside Material's body also prevents a
/// glass navigation surface from filtering or covering transient feedback.
/// Nested [MiuixScaffold] instances retain their own popup controller and can
/// still delegate root overlays through [MiuixPopupHostScope].
class MiuixScaffold extends StatefulWidget {
  /// Creates a scaffold.
  const MiuixScaffold({
    super.key,
    required this.body,
    this.topBar,
    this.bottomBar,
    this.floatingActionButton,
    this.floatingActionButtonPosition = MiuixFabPosition.end,
    this.floatingToolbar,
    this.floatingToolbarPosition = MiuixToolbarPosition.bottomCenter,
    this.snackbarHost,
    this.popupHost,
    this.drawer,
    this.backgroundColor,
    this.extendBody = false,
    this.bottomBarIsFloating = false,
    this.bottomBarShadowPaintExtent,
  });

  /// Main page body.
  final Widget body;

  /// Optional app bar.
  final PreferredSizeWidget? topBar;

  /// Optional bottom bar.
  final Widget? bottomBar;

  /// Optional floating action button.
  final Widget? floatingActionButton;

  /// Placement of [floatingActionButton].
  final MiuixFabPosition floatingActionButtonPosition;

  /// Optional floating toolbar.
  final Widget? floatingToolbar;

  /// Placement of [floatingToolbar].
  final MiuixToolbarPosition floatingToolbarPosition;

  /// Optional snackbar host rendered above other body content.
  final Widget? snackbarHost;

  /// Optional popup layer override. The default renders this scaffold's host.
  final Widget? popupHost;

  /// Optional drawer.
  final Widget? drawer;

  /// Optional background color.
  final Color? backgroundColor;

  /// Whether body painting continues behind a non-rectangular bottom bar.
  final bool extendBody;

  /// Treats a wrapped [bottomBar] as a floating full-window overlay.
  ///
  /// Concrete MIUIX floating bars are detected automatically. Set this only
  /// when an animation or visibility widget hides the concrete child type.
  ///
  /// This flag changes placement, clipping, and body extension together. It is
  /// therefore not merely a visual style hint: a true value means pixels
  /// outside the capsule must continue to reveal the underlying page.
  ///
  /// The flag is exposed because transition wrappers erase the concrete child
  /// type from runtime checks. Callers with an unwrapped
  /// [MiuixFloatingNavigationBar] or [MiuixIosLiquidGlassNavigationBar] should
  /// leave it at its default and use automatic detection.
  final bool bottomBarIsFloating;

  /// Upper paint allowance for a wrapped floating bar's drop shadow.
  ///
  /// A direct [MiuixFloatingNavigationBar] resolves to its source 10dp radius;
  /// other bars resolve to zero. Wrapped bars can provide the hidden value.
  ///
  /// This allowance is paint-only. It must not be included in snackbar,
  /// floating-action-button, or body inset calculations because the Compose
  /// shadow does not participate in measurement. The state subtracts it from
  /// the reported render-box height before publishing `_bottomBarHeight`.
  final double? bottomBarShadowPaintExtent;

  @override
  State<MiuixScaffold> createState() => _MiuixScaffoldState();
}

class _MiuixScaffoldState extends State<MiuixScaffold> {
  // MIUIX places floating scaffold controls 12dp from their measured anchor.
  static const double _floatingSpacing = 12;
  // A bottom-docked toolbar is lifted by 4dp and leaves another 4dp below a
  // snackbar, matching the two independently rounded source placements.
  static const double _floatingToolbarSpacing = 4;
  // The key observes the complete rendered bar, including paint-only padding.
  final GlobalKey _bottomBarSizeKey = GlobalKey();
  // Floating controls are measured against the final outer scaffold stack.
  // Their actual top edges are authoritative for snackbar avoidance because
  // callers may provide arbitrary-size FAB and toolbar content.
  final GlobalKey _scaffoldLayerKey = GlobalKey();
  final GlobalKey _floatingActionButtonSizeKey = GlobalKey();
  final GlobalKey _floatingToolbarSizeKey = GlobalKey();
  // Each scaffold owns a popup controller so nested routes do not share state.
  MiuixPopupHostController? _popupController;
  // The parent controller is retained only for root-overlay delegation.
  MiuixPopupHostController? _parentController;
  // Large top bars publish their collapse extent through this connector.
  MiuixTopAppBarScrollBehavior? _topBarScrollBehavior;
  // This is the source layout height, never the blur's extra paint extent.
  double _bottomBarHeight = 0;
  // Animated wrappers can emit several size notifications within one frame.
  bool _bottomBarMeasureScheduled = false;
  // Distance from the outer scaffold bottom to each control's painted top.
  // Compose obtains these values synchronously from measured placeables; the
  // Flutter adapter refreshes them immediately after the corresponding frame.
  double _floatingActionButtonTopClearance = 0;
  double _floatingToolbarTopClearance = 0;
  bool _floatingControlsMeasureScheduled = false;

  // Direct floating types are discoverable without requiring caller metadata.
  // Wrapped bars use the explicit escape hatch documented on the public field.
  bool get _bottomBarIsFloating =>
      widget.bottomBarIsFloating ||
      widget.bottomBar is MiuixFloatingNavigationBar ||
      widget.bottomBar is MiuixIosLiquidGlassNavigationBar;

  // A standard source capsule needs the complete 10dp upper blur allowance.
  // The iOS-like extension paints inside its own bounds and therefore uses 0.
  // Invalid external values are normalized so they cannot corrupt placement.
  double get _bottomBarShadowPaintExtent {
    final explicit = widget.bottomBarShadowPaintExtent;
    if (explicit != null) {
      return explicit.isFinite ? math.max(0.0, explicit) : 0.0;
    }
    return widget.bottomBar is MiuixFloatingNavigationBar
        ? MiuixFloatingNavigationBar.sourceShadowRadius
        : 0.0;
  }

  @override
  void initState() {
    super.initState();
    _attachTopBarScrollBehavior();
  }

  @override
  void didUpdateWidget(covariant MiuixScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.bottomBar == null) {
      _bottomBarHeight = 0;
    }
    if (widget.floatingActionButton == null) {
      _floatingActionButtonTopClearance = 0;
    }
    if (widget.floatingToolbar == null) {
      _floatingToolbarTopClearance = 0;
    }
    final nextBehavior = _behaviorOf(widget.topBar);
    if (!identical(nextBehavior, _topBarScrollBehavior)) {
      _topBarScrollBehavior?.removeListener(_handleTopBarChanged);
      _topBarScrollBehavior = nextBehavior;
      _topBarScrollBehavior?.addListener(_handleTopBarChanged);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final parent = MiuixPopupHostScope.maybeOf(context);
    if (_popupController == null || parent != _parentController) {
      _popupController?.dispose();
      _parentController = parent;
      _popupController = MiuixPopupHostController(parent: parent);
    }
  }

  @override
  void dispose() {
    _topBarScrollBehavior?.removeListener(_handleTopBarChanged);
    _popupController?.dispose();
    super.dispose();
  }

  MiuixTopAppBarScrollBehavior? _behaviorOf(PreferredSizeWidget? topBar) {
    return topBar is MiuixTopAppBar ? topBar.scrollBehavior : null;
  }

  void _attachTopBarScrollBehavior() {
    _topBarScrollBehavior = _behaviorOf(widget.topBar);
    _topBarScrollBehavior?.addListener(_handleTopBarChanged);
  }

  void _handleTopBarChanged() {
    if (mounted) {
      // Scaffold reads preferredSize only while it builds. Rebuilding here lets
      // the body follow the collapsing MIUIX top bar without leaving a gap.
      setState(() {});
    }
  }

  bool _handleBodyScroll(ScrollNotification notification) {
    _topBarScrollBehavior?.handleNotification(notification);
    return false;
  }

  bool _handleBottomBarSizeChanged(SizeChangedLayoutNotification notification) {
    // SizeChangedLayoutNotifier may emit more than once while AnimatedSwitcher
    // transitions between regular and floating bars. Coalescing measurements
    // keeps those animation frames from scheduling redundant scaffold rebuilds.
    _scheduleBottomBarMeasurement();
    return false;
  }

  void _scheduleBottomBarMeasurement() {
    if (_bottomBarMeasureScheduled) {
      return;
    }
    _bottomBarMeasureScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bottomBarMeasureScheduled = false;
      if (!mounted) {
        return;
      }
      final renderObject = _bottomBarSizeKey.currentContext?.findRenderObject();
      final rawHeight = renderObject is RenderBox && renderObject.hasSize
          ? renderObject.size.height
          : 0.0;
      // The floating overlay reserves 10dp only as a paint clip allowance.
      // Compose shadows do not contribute to Scaffold's measured bottom bar.
      final nextHeight = _bottomBarIsFloating
          ? math.max(0.0, rawHeight - _bottomBarShadowPaintExtent)
          : rawHeight;
      if ((nextHeight - _bottomBarHeight).abs() > .5) {
        setState(() => _bottomBarHeight = nextHeight);
      }
    });
  }

  /// Measures each floating control relative to the final scaffold layer.
  ///
  /// Reading the transformed global position matters for the toolbar: its
  /// source 4dp lift is a placement transform and is not part of its size.
  void _scheduleFloatingControlsMeasurement() {
    if (_floatingControlsMeasureScheduled) return;
    _floatingControlsMeasureScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _floatingControlsMeasureScheduled = false;
      if (!mounted) return;
      final scaffoldRender = _scaffoldLayerKey.currentContext
          ?.findRenderObject();
      if (scaffoldRender is! RenderBox || !scaffoldRender.hasSize) return;
      final scaffoldTop = scaffoldRender.localToGlobal(Offset.zero).dy;
      final scaffoldBottom = scaffoldTop + scaffoldRender.size.height;

      double topClearance(GlobalKey key) {
        final renderObject = key.currentContext?.findRenderObject();
        if (renderObject is! RenderBox || !renderObject.hasSize) return 0;
        final top = renderObject.localToGlobal(Offset.zero).dy;
        return math.max(0.0, scaffoldBottom - top);
      }

      final nextFab = widget.floatingActionButton == null
          ? 0.0
          : topClearance(_floatingActionButtonSizeKey);
      final nextToolbar = widget.floatingToolbar == null
          ? 0.0
          : topClearance(_floatingToolbarSizeKey);
      if ((nextFab - _floatingActionButtonTopClearance).abs() <= .5 &&
          (nextToolbar - _floatingToolbarTopClearance).abs() <= .5) {
        return;
      }
      setState(() {
        _floatingActionButtonTopClearance = nextFab;
        _floatingToolbarTopClearance = nextToolbar;
      });
    });
  }

  AlignmentDirectional _toolbarAlignment(MiuixToolbarPosition position) {
    return switch (position) {
      MiuixToolbarPosition.topStart => AlignmentDirectional.topStart,
      MiuixToolbarPosition.centerStart => AlignmentDirectional.centerStart,
      MiuixToolbarPosition.bottomStart => AlignmentDirectional.bottomStart,
      MiuixToolbarPosition.topEnd => AlignmentDirectional.topEnd,
      MiuixToolbarPosition.centerEnd => AlignmentDirectional.centerEnd,
      MiuixToolbarPosition.bottomEnd => AlignmentDirectional.bottomEnd,
      MiuixToolbarPosition.topCenter => AlignmentDirectional.topCenter,
      MiuixToolbarPosition.bottomCenter => AlignmentDirectional.bottomCenter,
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final controller = _popupController!;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    // Compose rounds FabSpacing as an independent Dp placement value. At
    // 420dpi, 12dp is 32 physical pixels rather than Flutter's fractional
    // 31.5px, which otherwise moves an end-aligned FAB one pixel inward.
    final sourceFloatingSpacing = _miuixRoundLogicalDimension(
      _floatingSpacing,
      pixelRatio,
    );
    final sourceFloatingToolbarSpacing = _miuixRoundLogicalDimension(
      _floatingToolbarSpacing,
      pixelRatio,
    );
    final bottomBarUsesGlass = switch (widget.bottomBar) {
      final MiuixNavigationBar bottomBar => bottomBar.glass,
      final MiuixFloatingNavigationBar bottomBar => bottomBar.glass,
      final MiuixIosLiquidGlassNavigationBar bottomBar => bottomBar.showBlur,
      _ => false,
    };
    final bottomBarIsFloating = _bottomBarIsFloating;
    final effectiveExtendBody =
        widget.extendBody ||
        bottomBarIsFloating ||
        bottomBarUsesGlass ||
        widget.floatingActionButtonPosition == MiuixFabPosition.endOverlay;
    // A normal Flutter Scaffold shortens its body above bottomNavigationBar,
    // so only the source spacing is needed there. An extended body keeps the
    // complete window height and must explicitly subtract the measured bar,
    // exactly like Scaffold.kt's bottomBarPlaceable.height branch.
    final floatingBottom =
        widget.bottomBar == null ||
            widget.floatingActionButtonPosition == MiuixFabPosition.endOverlay
        ? sourceFloatingSpacing + bottomInset
        : effectiveExtendBody
        ? sourceFloatingSpacing + _bottomBarHeight
        : sourceFloatingSpacing;
    if (widget.bottomBar != null) {
      // SizeChangedLayoutNotifier reports later changes but not every initial
      // layout, so schedule one explicit first-frame measurement as well.
      _scheduleBottomBarMeasurement();
    }
    if (widget.floatingActionButton != null || widget.floatingToolbar != null) {
      // The first ordinary snackbar is interaction-driven, so these controls
      // have already completed this measurement before it appears. Repeating
      // the cheap read on rebuild also covers window resize and alignment
      // changes without retaining stale global coordinates.
      _scheduleFloatingControlsMeasurement();
    }
    final effectiveTopBar = switch (widget.topBar) {
      final MiuixTopAppBar bar => PreferredSize(
        // PreferredSizeWidget has no BuildContext, so its public nominal size
        // cannot express Compose's independently rounded 52dp row and 4dp
        // bottom padding. Resolve the source size with this window's density
        // before Flutter Scaffold creates its tight app-bar constraint.
        preferredSize: bar._sourcePreferredSize(context),
        child: bar,
      ),
      final bar => bar,
    };
    final content = Stack(
      children: [
        Positioned.fill(
          child: _MiuixTopBarScrollConnector(
            behavior: _topBarScrollBehavior,
            child: NotificationListener<ScrollNotification>(
              onNotification: _handleBodyScroll,
              child: widget.body,
            ),
          ),
        ),
        if (widget.floatingActionButton != null &&
            widget.floatingActionButtonPosition != MiuixFabPosition.center)
          PositionedDirectional(
            start: switch (widget.floatingActionButtonPosition) {
              MiuixFabPosition.start => sourceFloatingSpacing,
              MiuixFabPosition.center => null,
              MiuixFabPosition.end || MiuixFabPosition.endOverlay => null,
            },
            end: switch (widget.floatingActionButtonPosition) {
              MiuixFabPosition.start || MiuixFabPosition.center => null,
              MiuixFabPosition.end ||
              MiuixFabPosition.endOverlay => sourceFloatingSpacing,
            },
            bottom: floatingBottom,
            child: SizedBox(
              key: _floatingActionButtonSizeKey,
              child: widget.floatingActionButton!,
            ),
          ),
        if (widget.floatingActionButton != null &&
            widget.floatingActionButtonPosition == MiuixFabPosition.center)
          PositionedDirectional(
            start: 0,
            end: 0,
            bottom: floatingBottom,
            child: Align(
              child: SizedBox(
                key: _floatingActionButtonSizeKey,
                child: widget.floatingActionButton!,
              ),
            ),
          ),
        if (widget.floatingToolbar != null)
          Positioned.fill(
            child: Transform.translate(
              // The original Scaffold lifts the aligned toolbar by 4dp;
              // outside edge spacing belongs to FloatingToolbar itself.
              offset: Offset(0, -sourceFloatingToolbarSpacing),
              child: Align(
                alignment: _toolbarAlignment(widget.floatingToolbarPosition),
                child: SizedBox(
                  key: _floatingToolbarSizeKey,
                  child: widget.floatingToolbar,
                ),
              ),
            ),
          ),
      ],
    );
    final bottomBarLayer = widget.bottomBar == null
        ? null
        : SizeChangedLayoutNotifier(
            child: bottomBarIsFloating
                ? _MiuixFloatingShadowPaintScope(
                    paintExtent: _bottomBarShadowPaintExtent,
                    child: SizedBox(
                      key: _bottomBarSizeKey,
                      child: widget.bottomBar,
                    ),
                  )
                : SizedBox(key: _bottomBarSizeKey, child: widget.bottomBar),
          );
    final scaffold = Scaffold(
      // A BackdropFilter needs the body to be painted in the same region. The
      // glass flags therefore opt into extension automatically for direct
      // bar children; wrapped bars can still request extendBody explicitly.
      extendBody: effectiveExtendBody,
      // Compose MIUIX always places page content at y=0 and reports the
      // current top-bar height as content padding.  The first list item is
      // therefore below the title initially, but can scroll through the
      // app-bar layer after that padding is consumed.  This geometry is not
      // conditional on glass: an opaque bar simply hides the passing item,
      // while a glass bar reveals it through the backdrop filter.
      extendBodyBehindAppBar: widget.topBar != null,
      appBar: effectiveTopBar,
      body: content,
      // A floating capsule is painted by the outer full-window Stack below.
      // Scaffold clips paint above its bottomNavigationBar slot, which removed
      // the upper half of MIUIX's symmetric 10dp drop shadow.
      bottomNavigationBar: bottomBarIsFloating ? null : bottomBarLayer,
      drawer: widget.drawer,
      backgroundColor: widget.backgroundColor ?? scheme.surface,
    );
    // Flutter paints Scaffold.bottomNavigationBar after its body.  Keeping the
    // snackbar host inside `content` therefore allowed an opaque or glass tab
    // bar to cover the lower edge of a transient message even when its geometry
    // had been lifted correctly.  Compose measures the snackbar against the
    // bottom bar, then gives it an independent placement layer.  This outer
    // stack reproduces that contract: the host is offset by the complete bar
    // height and is also painted after the bar.
    final baseSnackbarBottom = widget.bottomBar == null
        ? bottomInset
        : _bottomBarHeight > .5
        ? _bottomBarHeight
        // The first frame precedes SizeChangedLayoutNotifier's callback.
        // A conservative regular-bar estimate prevents a snackbar queued
        // during startup from flashing behind Android's gesture region.
        : bottomInset + 64;
    // Upstream prioritizes the FAB over the bottom bar and then takes the
    // maximum of that anchor and a bottom-docked toolbar. The measured top
    // clearances express the same final geometry for arbitrary Flutter slots.
    final directFabFallback =
        widget.floatingActionButton is MiuixFloatingActionButton
        ? floatingBottom + MiuixFloatingActionButtonDefaults.minHeight
        : 0.0;
    final fabSnackbarBottom = widget.floatingActionButton == null
        ? 0.0
        : _floatingActionButtonTopClearance > .5
        ? _floatingActionButtonTopClearance
        : directFabFallback;
    final toolbarAtBottom = switch (widget.floatingToolbarPosition) {
      MiuixToolbarPosition.bottomStart ||
      MiuixToolbarPosition.bottomCenter ||
      MiuixToolbarPosition.bottomEnd => true,
      _ => false,
    };
    final toolbarSnackbarBottom =
        widget.floatingToolbar != null &&
            toolbarAtBottom &&
            _floatingToolbarTopClearance > .5
        ? _floatingToolbarTopClearance + sourceFloatingToolbarSpacing
        : 0.0;
    final snackbarBottom = math.max(
      baseSnackbarBottom,
      math.max(fabSnackbarBottom, toolbarSnackbarBottom),
    );
    return MiuixPopupHostScope(
      controller: controller,
      child: NotificationListener<SizeChangedLayoutNotification>(
        onNotification: _handleBottomBarSizeChanged,
        child: Stack(
          key: _scaffoldLayerKey,
          children: [
            Positioned.fill(child: scaffold),
            if (bottomBarIsFloating && bottomBarLayer != null)
              PositionedDirectional(
                start: 0,
                end: 0,
                bottom: 0,
                child: bottomBarLayer,
              ),
            if (widget.snackbarHost != null)
              PositionedDirectional(
                key: const ValueKey('miuix-scaffold-snackbar-layer'),
                start: 0,
                end: 0,
                bottom: snackbarBottom,
                child: widget.snackbarHost!,
              ),
            // Compose's popup layer belongs to the complete scaffold, not to
            // its content slot.  Painting this host last lets modal sheets and
            // dialogs cover the app navigation bar while still drawing behind
            // Android's transparent gesture area, matching the source sample.
            Positioned.fill(
              child: controller.parent == null
                  ? widget.popupHost ??
                        MiuixPopupHostView(controller: controller)
                  : ClipRect(
                      key: const ValueKey('miuix-popup-host-clip'),
                      child:
                          widget.popupHost ??
                          MiuixPopupHostView(controller: controller),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Connects a scaffold bar to the authoritative descendant ScrollPosition.
///
/// ScrollNotification covers gestures but may miss a PageStorage restoration
/// performed while elements are attaching. Reading the position after layout
/// handles that initial path; later programmatic jumps emit scroll metrics and
/// are synchronized by the scaffold notification listener.
class _MiuixTopBarScrollConnector extends StatefulWidget {
  const _MiuixTopBarScrollConnector({
    required this.behavior,
    required this.child,
  });

  final MiuixTopAppBarScrollBehavior? behavior;
  final Widget child;

  @override
  State<_MiuixTopBarScrollConnector> createState() =>
      _MiuixTopBarScrollConnectorState();
}

class _MiuixTopBarScrollConnectorState
    extends State<_MiuixTopBarScrollConnector> {
  ScrollPosition? _position;
  bool _attachmentScheduled = false;

  @override
  void didUpdateWidget(covariant _MiuixTopBarScrollConnector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.behavior, widget.behavior)) {
      _detach();
    }
  }

  @override
  void dispose() {
    _detach();
    super.dispose();
  }

  void _detach() {
    _position = null;
  }

  void _scheduleAttachment() {
    if (_attachmentScheduled || widget.behavior == null) return;
    _attachmentScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _attachmentScheduled = false;
      if (!mounted) return;
      final nextPosition = _findVerticalPosition();
      if (!identical(nextPosition, _position)) {
        _detach();
        _position = nextPosition;
      }
      _syncPosition();
    });
  }

  ScrollPosition? _findVerticalPosition() {
    ScrollPosition? result;
    void visit(Element element) {
      if (result != null) return;
      if (element is StatefulElement && element.state is ScrollableState) {
        final scrollable = element.state as ScrollableState;
        if (axisDirectionToAxis(scrollable.axisDirection) == Axis.vertical) {
          result = scrollable.position;
          return;
        }
      }
      element.visitChildren(visit);
    }

    context.visitChildElements(visit);
    return result;
  }

  void _syncPosition() {
    final position = _position;
    if (position != null && position.hasPixels) {
      widget.behavior?._restoreFromMetrics(position);
    }
  }

  @override
  Widget build(BuildContext context) {
    _scheduleAttachment();
    return widget.child;
  }
}

/// Immutable colors used by source-compatible MIUIX tab rows.
@immutable
class MiuixTabRowColors {
  /// Creates an explicit tab-row color set.
  const MiuixTabRowColors({
    required this.backgroundColor,
    required this.contentColor,
    required this.selectedBackgroundColor,
    required this.selectedContentColor,
  });

  /// Background behind every tab and the moving indicator.
  final Color backgroundColor;

  /// Foreground used by unselected labels.
  final Color contentColor;

  /// Fill of the selected-tab indicator.
  final Color selectedBackgroundColor;

  /// Foreground used by the selected label.
  final Color selectedContentColor;

  /// Resolves the foreground for one tab.
  Color contentColorFor(bool selected) {
    return selected ? selectedContentColor : contentColor;
  }

  /// Returns a copy with independently replaced channels.
  MiuixTabRowColors copyWith({
    Color? backgroundColor,
    Color? contentColor,
    Color? selectedBackgroundColor,
    Color? selectedContentColor,
  }) {
    return MiuixTabRowColors(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      contentColor: contentColor ?? this.contentColor,
      selectedBackgroundColor:
          selectedBackgroundColor ?? this.selectedBackgroundColor,
      selectedContentColor: selectedContentColor ?? this.selectedContentColor,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MiuixTabRowColors &&
            other.backgroundColor == backgroundColor &&
            other.contentColor == contentColor &&
            other.selectedBackgroundColor == selectedBackgroundColor &&
            other.selectedContentColor == selectedContentColor;
  }

  @override
  int get hashCode => Object.hash(
    backgroundColor,
    contentColor,
    selectedBackgroundColor,
    selectedContentColor,
  );
}

/// Dimensions and theme-resolved colors from MIUIX `TabRowDefaults`.
abstract final class MiuixTabRowDefaults {
  /// HyperOS 4 project-calibrated complete option-capsule height.
  static const double hyperOs4Height = 44;

  /// HyperOS 4 project-calibrated selected-item corner radius.
  static const double hyperOs4CornerRadius = 19;

  /// HyperOS 4 project-calibrated minimum tab width.
  static const double hyperOs4MinWidth = 72;

  /// HyperOS 4 project-calibrated maximum tab width.
  static const double hyperOs4MaxWidth = 120;

  /// HyperOS 4 gap between neighboring equal interaction regions.
  static const double hyperOs4ItemSpacing = 3;

  /// HyperOS 4 inset between the outer glass and selected surface.
  static const double hyperOs4Padding = 3;

  /// Legacy ordinary row height from MIUIX 1.0.9.
  static const double height = 42;

  /// Legacy contoured row height from MIUIX 1.0.9.
  static const double contourHeight = 45;

  /// Ordinary tab corner radius.
  static const double cornerRadius = 12;

  /// Contoured tab corner radius.
  static const double contourCornerRadius = 8;

  /// Ordinary minimum tab width.
  static const double minWidth = 76;

  /// Contoured minimum tab width.
  static const double contourMinWidth = 62;

  /// Ordinary maximum tab width.
  static const double maxWidth = 98;

  /// Contoured maximum tab width.
  static const double contourMaxWidth = 84;

  /// Ordinary gap between tabs.
  static const double itemSpacing = 9;

  /// Contoured gap between tabs.
  static const double contourItemSpacing = 5;

  /// Insets between the contour surface and its tab items.
  static const double contourPadding = 5;

  /// Resolves the four source color roles with independent overrides.
  static MiuixTabRowColors tabRowColors(
    BuildContext context, {
    Color? backgroundColor,
    Color? contentColor,
    Color? selectedBackgroundColor,
    Color? selectedContentColor,
  }) {
    final semantic = MiuixSemanticColors.of(context);
    // 页内 Tab 与分段选择共用轻选中角色，显式调用方颜色仍优先。
    final layers = MiuixAccentLayers.maybeOf(context);
    return MiuixTabRowColors(
      backgroundColor: backgroundColor ?? semantic['surface'],
      contentColor: contentColor ?? semantic['onSurfaceVariantSummary'],
      selectedBackgroundColor:
          selectedBackgroundColor ??
          layers?.selectionFill ??
          semantic['surfaceContainer'],
      selectedContentColor:
          selectedContentColor ??
          layers?.selectionForeground ??
          semantic['onBackground'],
    );
  }
}

/// Tab bar wrapper for text tabs.
class MiuixTabBar extends StatefulWidget {
  /// Creates a HyperOS 4 glass tab bar.
  const MiuixTabBar({
    super.key,
    required this.tabs,
    this.controller,
    this.selectedTabIndex,
    this.onTabSelected,
    this.onTap,
    this.colors,
    this.minWidth = MiuixTabRowDefaults.hyperOs4MinWidth,
    this.maxWidth = MiuixTabRowDefaults.hyperOs4MaxWidth,
    this.height = MiuixTabRowDefaults.hyperOs4Height,
    this.cornerRadius = MiuixTabRowDefaults.hyperOs4CornerRadius,
    this.itemSpacing = MiuixTabRowDefaults.hyperOs4ItemSpacing,
    this.contentAlignment = Alignment.center,
    this.interactionSource,
    this.showIndication = true,
    this.glass = true,
    this.glassBlur,
    this.glassOpacity,
  }) : withContour = false,
       _source = false;

  /// Creates the previous MIUIX 1.0.9 ordinary tab row explicitly.
  const MiuixTabBar.source({
    super.key,
    required this.tabs,
    this.controller,
    this.selectedTabIndex,
    this.onTabSelected,
    this.onTap,
    this.colors,
    this.minWidth = MiuixTabRowDefaults.minWidth,
    this.maxWidth = MiuixTabRowDefaults.maxWidth,
    this.height = MiuixTabRowDefaults.height,
    this.cornerRadius = MiuixTabRowDefaults.cornerRadius,
    this.itemSpacing = MiuixTabRowDefaults.itemSpacing,
    this.contentAlignment = Alignment.center,
    this.interactionSource,
    this.showIndication = false,
    this.glass = false,
    this.glassBlur,
    this.glassOpacity,
  }) : withContour = false,
       _source = true;

  /// Creates a HyperOS 4 glass tab bar through the contour API shape.
  const MiuixTabBar.contour({
    super.key,
    required this.tabs,
    this.controller,
    this.selectedTabIndex,
    this.onTabSelected,
    this.onTap,
    this.colors,
    this.minWidth = MiuixTabRowDefaults.hyperOs4MinWidth,
    this.maxWidth = MiuixTabRowDefaults.hyperOs4MaxWidth,
    this.height = MiuixTabRowDefaults.hyperOs4Height,
    this.cornerRadius = MiuixTabRowDefaults.hyperOs4CornerRadius,
    this.itemSpacing = MiuixTabRowDefaults.hyperOs4ItemSpacing,
    this.contentAlignment = Alignment.center,
    this.interactionSource,
    this.showIndication = true,
    this.glass = true,
    this.glassBlur,
    this.glassOpacity,
  }) : withContour = true,
       _source = false;

  /// Creates the previous MIUIX 1.0.9 contoured tab row explicitly.
  const MiuixTabBar.contourSource({
    super.key,
    required this.tabs,
    this.controller,
    this.selectedTabIndex,
    this.onTabSelected,
    this.onTap,
    this.colors,
    this.minWidth = MiuixTabRowDefaults.contourMinWidth,
    this.maxWidth = MiuixTabRowDefaults.contourMaxWidth,
    this.height = MiuixTabRowDefaults.contourHeight,
    this.cornerRadius = MiuixTabRowDefaults.contourCornerRadius,
    this.itemSpacing = MiuixTabRowDefaults.contourItemSpacing,
    this.contentAlignment = Alignment.center,
    this.interactionSource,
    this.showIndication = false,
    this.glass = false,
    this.glassBlur,
    this.glassOpacity,
  }) : withContour = true,
       _source = true;

  /// Tab labels.
  final List<String> tabs;

  /// Optional tab controller.
  ///
  /// This is the Flutter compatibility path. Source-style call sites should
  /// prefer [selectedTabIndex] and [onTabSelected].
  final TabController? controller;

  /// Source-controlled selected tab index.
  ///
  /// When supplied, tapping a tab never mutates selection locally. The owner
  /// must publish the next index, matching MIUIX `TabRow`.
  final int? selectedTabIndex;

  /// Source selection callback.
  final ValueChanged<int>? onTabSelected;

  /// Backward-compatible tap callback.
  final ValueChanged<int>? onTap;

  /// Explicit source color contract, or theme defaults when omitted.
  final MiuixTabRowColors? colors;

  /// Minimum width allocated to one tab.
  final double minWidth;

  /// Maximum width allocated to one tab while the row needs scrolling.
  final double maxWidth;

  /// Complete row height.
  final double height;

  /// Continuous corner radius of each tab and its indicator.
  final double cornerRadius;

  /// Horizontal gap between adjacent tabs.
  final double itemSpacing;

  /// Alignment of each label inside its tab.
  final AlignmentGeometry contentAlignment;

  /// Optional observer shared by the source tab items.
  final MiuixInteractionSource? interactionSource;

  /// Whether to paint the optional MIUIX indication layer while interacting.
  ///
  /// The source accepts a nullable Compose `Indication`; `false` represents
  /// its default `null`, while `true` selects this library's exact MIUIX
  /// indication implementation.
  final bool showIndication;

  /// Whether the complete local capsule samples content behind it.
  final bool glass;

  /// Optional override for the compact option-group blur token.
  final double? glassBlur;

  /// Optional override for the compact option-group tint opacity.
  final double? glassOpacity;

  /// Whether this tab row should use MIUIX TabRowWithContour metrics.
  final bool withContour;

  /// Whether exact MIUIX 1.0.9 geometry and paint are requested.
  final bool _source;

  @override
  State<MiuixTabBar> createState() => _MiuixTabBarState();
}

class _MiuixTabBarState extends State<MiuixTabBar> {
  TabController? _controller;
  final ScrollController _scrollController = ScrollController();
  int _localIndex = 0;
  double? _lastScrollTarget;
  int? _lastSettledSelectedTabIndex;
  int _scrollRequestGeneration = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncController();
  }

  @override
  void didUpdateWidget(covariant MiuixTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _syncController();
    }
    final controller = _controller;
    if (controller != null && controller.index >= widget.tabs.length) {
      _localIndex = widget.tabs.isEmpty ? 0 : widget.tabs.length - 1;
    }
    if (_localIndex >= widget.tabs.length) {
      _localIndex = widget.tabs.isEmpty ? 0 : widget.tabs.length - 1;
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_handleControllerChange);
    _scrollController.dispose();
    super.dispose();
  }

  void _syncController() {
    final next = widget.controller ?? DefaultTabController.maybeOf(context);
    if (identical(next, _controller)) {
      return;
    }
    _controller?.removeListener(_handleControllerChange);
    _controller = next;
    _controller?.addListener(_handleControllerChange);
    final tabsLength = widget.tabs.length;
    if (tabsLength <= 0) {
      _localIndex = 0;
      return;
    }
    final controllerIndex = _controller?.index ?? _localIndex;
    _localIndex = controllerIndex.clamp(0, tabsLength - 1);
  }

  void _handleControllerChange() {
    if (mounted) {
      setState(() {});
    }
  }

  void _select(int index) {
    final currentIndex = _resolvedSelectedIndex;
    final changed = widget.tabs.isNotEmpty && index != currentIndex;
    // The original component is fully controlled: a click reports intent and
    // the indicator moves only after selectedTabIndex changes.
    if (widget.selectedTabIndex != null) {
      widget.onTabSelected?.call(index);
      widget.onTap?.call(index);
      if (!widget._source && changed) {
        unawaited(MiuixHaptics.perform(MiuixHapticType.segmentTick));
      }
      return;
    }
    setState(() => _localIndex = index);
    final controller = _controller;
    if (controller != null && index >= 0 && index < controller.length) {
      controller.animateTo(index);
    }
    widget.onTabSelected?.call(index);
    widget.onTap?.call(index);
    if (!widget._source && changed) {
      unawaited(MiuixHaptics.perform(MiuixHapticType.segmentTick));
    }
  }

  int get _resolvedSelectedIndex {
    if (widget.tabs.isEmpty) return 0;
    final controller = _controller;
    return widget.selectedTabIndex != null
        ? widget.selectedTabIndex!.clamp(0, widget.tabs.length - 1)
        : controller == null
        ? _localIndex.clamp(0, widget.tabs.length - 1)
        : controller.index.clamp(0, widget.tabs.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final selected = _resolvedSelectedIndex;
    // Current TabRow.kt has deliberately different indicator behavior. The
    // ordinary row derives its offset directly from selectedTabIndex, while
    // the contour variant snaps its first value and linearly animates later
    // changes for 200 ms. Building the contour AnimatedPositioned at the
    // selected offset gives the same initial snap without a fabricated frame.
    final indicatorIndex = selected;
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    // Public geometry may be sourced from remote flags, persisted settings,
    // or an adaptive design editor rather than compile-time constants.
    // Constructor assertions therefore cannot define release behavior.
    // Resolve the fallback family before density rounding because source and
    // HyperOS rows intentionally expose different width and motion metrics.
    // Contour source keeps its five-dp inset while the HyperOS family keeps
    // its own compact inset even when entered through the contour alias.
    // A finite negative minimum is a request for the smallest legal value.
    // A maximum below that resolved minimum collapses to the same width.
    // This retains a stable scroll formula instead of swapping both fields.
    // Non-finite input means the caller has no usable value and therefore
    // falls back to the matching public default.
    final fallbackMinWidth = widget._source
        ? widget.withContour
              ? MiuixTabRowDefaults.contourMinWidth
              : MiuixTabRowDefaults.minWidth
        : MiuixTabRowDefaults.hyperOs4MinWidth;
    final fallbackMaxWidth = widget._source
        ? widget.withContour
              ? MiuixTabRowDefaults.contourMaxWidth
              : MiuixTabRowDefaults.maxWidth
        : MiuixTabRowDefaults.hyperOs4MaxWidth;
    final fallbackHeight = widget._source
        ? widget.withContour
              ? MiuixTabRowDefaults.contourHeight
              : MiuixTabRowDefaults.height
        : MiuixTabRowDefaults.hyperOs4Height;
    final fallbackRadius = widget._source
        ? widget.withContour
              ? MiuixTabRowDefaults.contourCornerRadius
              : MiuixTabRowDefaults.cornerRadius
        : MiuixTabRowDefaults.hyperOs4CornerRadius;
    final requestedMinWidth = widget.minWidth.isFinite
        ? math.max(0.0, widget.minWidth)
        : fallbackMinWidth;
    final requestedMaxWidth = widget.maxWidth.isFinite
        ? math.max(requestedMinWidth, widget.maxWidth)
        : math.max(requestedMinWidth, fallbackMaxWidth);
    final minimumHeight = !widget._source
        ? MiuixTabRowDefaults.hyperOs4Padding * 2
        : widget.withContour
        ? MiuixTabRowDefaults.contourPadding * 2
        : 0.0;
    final requestedHeight = widget.height.isFinite
        ? math.max(minimumHeight, widget.height)
        : fallbackHeight;
    final requestedRadius = widget.cornerRadius.isFinite
        ? math.max(0.0, widget.cornerRadius)
        : fallbackRadius;
    final requestedSpacing = widget.itemSpacing.isFinite
        ? math.max(0.0, widget.itemSpacing)
        : (widget._source
              ? widget.withContour
                    ? MiuixTabRowDefaults.contourItemSpacing
                    : MiuixTabRowDefaults.itemSpacing
              : MiuixTabRowDefaults.hyperOs4ItemSpacing);
    // Height reserves both surface insets before the inner Stack is built;
    // otherwise a short release-only value becomes a negative SizedBox.
    // Radius and spacing never influence that minimum and are clamped alone.
    // Every downstream user consumes the resolved values below: tab width,
    // indicator position, semantic hit targets, centering, and surface paint.
    // Keeping one pipeline prevents a visible indicator from diverging from
    // the invisible 48dp accessibility target under malformed configuration.
    // Compose measures every Dp layout value through roundToPx before placing
    // the tab row. Keeping raw fractional physical pixels makes the 45 dp
    // contour row 118.125 px at 420 dpi and pushes its enclosing sample card
    // one pixel away from the source.
    final spacing = _miuixRoundLogicalDimension(requestedSpacing, pixelRatio);
    final minWidth = _miuixRoundLogicalDimension(requestedMinWidth, pixelRatio);
    final maxWidth = _miuixRoundLogicalDimension(requestedMaxWidth, pixelRatio);
    final outerHeight = _miuixRoundLogicalDimension(
      requestedHeight,
      pixelRatio,
    );
    final surfacePadding = _miuixRoundLogicalDimension(
      widget._source
          ? widget.withContour
                ? MiuixTabRowDefaults.contourPadding
                : 0
          : MiuixTabRowDefaults.hyperOs4Padding,
      pixelRatio,
    );
    final radius = requestedRadius;
    final colors = widget.colors ?? MiuixTabRowDefaults.tabRowColors(context);
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final selectionMotion = reduceMotion
        ? Duration.zero
        : hyperOs4.segmentedControlMotion;
    final useSmoothRounding = MiuixTheme.of(context).enableSquircle;
    // TabRow.kt creates one `miuixShape(cornerRadius)` and reuses it for the
    // moving indicator and every clickable tab. This is not equivalent to a
    // circular BoxDecoration: smooth rounding extends each corner farther
    // along the straight edge, which is visible on the shallow 35/42 dp rows.
    final BorderRadius tabBorderRadius = BorderRadius.circular(radius);
    // The contour source adds the declared 5 dp to the declared 8 dp radius
    // before density conversion. `contourPadding` above is the separately
    // rounded layout inset, so adding it here would incorrectly produce
    // 12.952 dp rather than the source's exact 13 dp at Android 420 dpi.
    final BorderRadius contourBorderRadius = BorderRadius.circular(
      radius + surfacePadding,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final outerWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final availableWidth = math.max(0.0, outerWidth - surfacePadding * 2);
        final tabWidth = debugMiuixTabWidth(
          tabCount: widget.tabs.length,
          minWidth: minWidth,
          maxWidth: maxWidth,
          spacing: spacing,
          availableWidth: availableWidth,
        );
        final contentWidth =
            tabWidth * widget.tabs.length +
            spacing * math.max(0, widget.tabs.length - 1);
        _centerSelectedTab(
          selected: selected,
          tabWidth: tabWidth,
          spacing: spacing,
          viewportWidth: availableWidth,
          contentWidth: contentWidth,
          reduceMotion: reduceMotion,
        );
        final row = SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          // Compose LazyRow clips paint on its horizontal scroll axis. Keeping
          // this as Clip.none lets the next off-screen label escape past the
          // contour surface (visible in the six-tab sample). The independent
          // semantics layer and render-object pointer proxy below still retain
          // the centered 48dp vertical target outside the shorter visual row.
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: math.max(availableWidth, contentWidth),
            height: outerHeight - surfacePadding * 2,
            child: Stack(
              children: [
                if (!widget._source || widget.withContour)
                  AnimatedPositionedDirectional(
                    key: const ValueKey('miuix-tab-indicator'),
                    duration: widget._source
                        ? const Duration(milliseconds: 200)
                        : selectionMotion,
                    curve: widget._source ? Curves.linear : Curves.easeOutCubic,
                    start: indicatorIndex * (tabWidth + spacing),
                    top: 0,
                    bottom: 0,
                    width: tabWidth,
                    child: MiuixSquircleBackground(
                      key: const ValueKey('miuix-tab-indicator-surface'),
                      color: colors.selectedBackgroundColor,
                      borderRadius: tabBorderRadius,
                      enabled: useSmoothRounding,
                      child: const SizedBox.expand(),
                    ),
                  )
                else
                  PositionedDirectional(
                    key: const ValueKey('miuix-tab-indicator'),
                    start: indicatorIndex * (tabWidth + spacing),
                    top: 0,
                    bottom: 0,
                    width: tabWidth,
                    child: MiuixSquircleBackground(
                      key: const ValueKey('miuix-tab-indicator-surface'),
                      color: colors.selectedBackgroundColor,
                      borderRadius: tabBorderRadius,
                      enabled: useSmoothRounding,
                      child: const SizedBox.expand(),
                    ),
                  ),
                Row(
                  children: [
                    for (
                      var index = 0;
                      index < widget.tabs.length;
                      index++
                    ) ...[
                      if (index > 0) SizedBox(width: spacing),
                      _MiuixTabButton(
                        key: ValueKey('miuix-tab-$index'),
                        index: index,
                        label: widget.tabs[index],
                        selected: index == selected,
                        withContour: widget.withContour,
                        source: widget._source,
                        width: tabWidth,
                        height: outerHeight - surfacePadding * 2,
                        cornerRadius: radius,
                        contentAlignment: widget.contentAlignment,
                        foreground: colors.contentColorFor(index == selected),
                        interactionSource: widget.interactionSource,
                        showIndication: widget.showIndication,
                        onTap: () => _select(index),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
        final semanticTargetHeight = _miuixRoundLogicalDimension(
          _miuixTabMinimumInteractiveSize,
          pixelRatio,
        );
        final visibleItemHeight = outerHeight - surfacePadding * 2;
        final semanticLayer = AnimatedBuilder(
          animation: _scrollController,
          builder: (context, _) {
            final scrollOffset = _scrollController.hasClients
                ? _scrollController.offset
                : 0.0;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                for (var index = 0; index < widget.tabs.length; index++)
                  PositionedDirectional(
                    start: index * (tabWidth + spacing) - scrollOffset,
                    top: (visibleItemHeight - semanticTargetHeight) / 2,
                    width: tabWidth,
                    height: semanticTargetHeight,
                    child: _MiuixTabSemanticsTarget(
                      key: ValueKey('miuix-tab-semantic-$index'),
                      label: widget.tabs[index],
                      selected: index == selected,
                      textDirection: Directionality.of(context),
                      onTap: () => _select(index),
                    ),
                  ),
              ],
            );
          },
        );
        final layeredRow = Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(child: row),
            Positioned.fill(child: semanticLayer),
          ],
        );
        if (widget._source && !widget.withContour) {
          return ColoredBox(
            color: colors.backgroundColor,
            child: SizedBox(height: outerHeight, child: layeredRow),
          );
        }
        // Compose applies clip(outerShape), paints the surface background, and
        // only then inserts the 5 dp content padding. ShapeDecoration supplies
        // the same ShapeBorder path to Container's anti-aliased clip.
        final paddedRow = Padding(
          padding: EdgeInsets.all(surfacePadding),
          child: layeredRow,
        );
        if (!widget._source) {
          return SizedBox(
            key: const ValueKey('miuix-hyperos4-tab-surface'),
            height: outerHeight,
            child: MiuixSurface(
              radius: radius + surfacePadding,
              color: widget.glass ? Colors.transparent : colors.backgroundColor,
              border: BorderSide(
                color: MiuixSemanticColors.of(context)['dividerLine'],
                width: .5,
              ),
              glass: widget.glass,
              glassBlur: widget.glassBlur ?? hyperOs4.segmentedControlBlur,
              glassOpacity:
                  widget.glassOpacity ?? hyperOs4.segmentedControlTintOpacity,
              child: paddedRow,
            ),
          );
        }
        return SizedBox(
          key: const ValueKey('miuix-contour-tab-surface'),
          height: outerHeight,
          child: MiuixSquircleBackground(
            color: colors.backgroundColor,
            borderRadius: contourBorderRadius,
            enabled: useSmoothRounding,
            child: paddedRow,
          ),
        );
      },
    );
  }

  void _centerSelectedTab({
    required int selected,
    required double tabWidth,
    required double spacing,
    required double viewportWidth,
    required double contentWidth,
    required bool reduceMotion,
  }) {
    final maxOffset = math.max(0.0, contentWidth - viewportWidth);
    final target =
        (selected * (tabWidth + spacing) - (viewportWidth - tabWidth) / 2)
            .clamp(0.0, maxOffset);
    final previousSelected = _lastSettledSelectedTabIndex;
    if (previousSelected == selected &&
        _lastScrollTarget != null &&
        (_lastScrollTarget! - target).abs() < .01) {
      return;
    }
    final shouldAnimate =
        previousSelected != null && previousSelected != selected;
    _lastSettledSelectedTabIndex = selected;
    _lastScrollTarget = target;
    final requestGeneration = ++_scrollRequestGeneration;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          requestGeneration != _scrollRequestGeneration ||
          !_scrollController.hasClients) {
        return;
      }
      if (shouldAnimate && !reduceMotion) {
        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 200),
          curve: Curves.linear,
        );
      } else {
        _scrollController.jumpTo(target);
      }
    });
  }
}

class _MiuixTabButton extends StatelessWidget {
  const _MiuixTabButton({
    super.key,
    required this.index,
    required this.label,
    required this.selected,
    required this.withContour,
    required this.source,
    required this.width,
    required this.height,
    required this.cornerRadius,
    required this.contentAlignment,
    required this.foreground,
    required this.interactionSource,
    required this.showIndication,
    required this.onTap,
  });

  final int index;
  final String label;
  final bool selected;
  final bool withContour;
  final bool source;
  final double width;
  final double height;
  final double cornerRadius;
  final AlignmentGeometry contentAlignment;
  final Color foreground;
  final MiuixInteractionSource? interactionSource;
  final bool showIndication;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final minimumInteractiveSize = _miuixRoundLogicalDimension(
      _miuixTabMinimumInteractiveSize,
      MediaQuery.devicePixelRatioOf(context),
    );
    final outlineSide = source && !withContour && !selected
        ? BorderSide(
            color: MiuixSemanticColors.of(context)['outline'],
            width: 1,
          )
        : BorderSide.none;
    final outlineShape = MiuixTheme.of(context).enableSquircle
        ? MiuixSquircleBorder(
            borderRadius: BorderRadius.circular(cornerRadius),
            side: outlineSide,
          )
        : RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cornerRadius),
            side: outlineSide,
          );
    final pressable = MiuixPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(cornerRadius),
      feedbackType: MiuixPressFeedbackType.none,
      interactionSource: interactionSource,
      showIndication: showIndication,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: source && !withContour ? 12 : 10,
        ),
        child: Align(
          alignment: contentAlignment,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: foreground,
              fontSize: source && !withContour ? 16 : 14,
              fontWeight: selected
                  ? source
                        ? FontWeight.w700
                        : FontWeight.w600
                  : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
    return ExcludeSemantics(
      child: _MiuixTabTouchTarget(
        selected: selected,
        minimumSize: minimumInteractiveSize,
        onTap: onTap,
        interactionSource: interactionSource,
        child: SizedBox(
          width: width,
          height: height,
          child: !source || withContour
              ? pressable
              : DecoratedBox(
                  key: ValueKey('miuix-tab-outline-$index'),
                  position: DecorationPosition.foreground,
                  decoration: ShapeDecoration(shape: outlineShape),
                  child: pressable,
                ),
        ),
      ),
    );
  }
}

/// Applies the source width allocation used by both MIUIX tab rows.
@visibleForTesting
double debugMiuixTabWidth({
  required int tabCount,
  required double minWidth,
  required double maxWidth,
  required double spacing,
  required double availableWidth,
}) {
  if (tabCount <= 0) {
    return minWidth;
  }
  final totalSpacing = math.max(0, tabCount - 1) * spacing;
  final contentWidth = availableWidth - totalSpacing;
  if (contentWidth <= 0) {
    return minWidth;
  }
  final idealWidth = contentWidth / tabCount;
  if (idealWidth < minWidth) {
    return minWidth;
  }
  if (idealWidth > maxWidth) {
    final totalMaxWidth = maxWidth * tabCount + totalSpacing;
    return totalMaxWidth < availableWidth ? idealWidth : maxWidth;
  }
  return idealWidth;
}
