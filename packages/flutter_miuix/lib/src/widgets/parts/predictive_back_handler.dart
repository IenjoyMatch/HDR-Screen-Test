part of '../miuix_widgets.dart';

/// Immutable platform-back progress payload shared by navigation surfaces.
@immutable
class MiuixNavBackEvent {
  const MiuixNavBackEvent({
    required this.progress,
    required this.swipeEdge,
    required this.touchY,
    this.frameTimeMillis = 0,
  });

  /// Gesture completion in the source driver's finite `[0, .999]` interval.
  final double progress;

  /// Physical screen edge that originated the platform gesture.
  final MiuixNavSwipeEdge swipeEdge;

  /// Vertical pointer position in logical pixels.
  final double touchY;

  /// Monotonic frame timestamp used for release-velocity estimation.
  final int frameTimeMillis;

  @override
  bool operator ==(Object other) =>
      other is MiuixNavBackEvent &&
      other.progress == progress &&
      other.swipeEdge == swipeEdge &&
      other.touchY == touchY &&
      other.frameTimeMillis == frameTimeMillis;

  @override
  int get hashCode => Object.hash(progress, swipeEdge, touchY, frameTimeMillis);
}

typedef MiuixPredictiveBackAdmission = bool Function(MiuixNavBackEvent event);

/// Bridges Flutter's predictive/discrete Back dispatch into one owner stream.
///
/// The most recently mounted enabled MIUIX back owner wins. This mirrors the
/// source dispatcher precedence and prevents a covered navigation display from
/// progressing underneath an open dialog, bottom sheet, or popup.
class MiuixPredictiveBackHandler extends StatefulWidget {
  const MiuixPredictiveBackHandler({
    super.key,
    this.enabled = true,
    this.handleDiscreteBack = true,
    this.canStart,
    required this.onProgress,
    required this.onCommit,
    required this.onCancel,
    required this.child,
  });

  final bool enabled;

  /// 嵌套 Navigator 的离散返回由外层 PopScope 委派，预测事件仍按层级仲裁。
  final bool handleDiscreteBack;
  final MiuixPredictiveBackAdmission? canStart;
  final ValueChanged<MiuixNavBackEvent> onProgress;
  final VoidCallback onCommit;
  final VoidCallback onCancel;
  final Widget child;

  @override
  State<MiuixPredictiveBackHandler> createState() =>
      _MiuixPredictiveBackHandlerState();
}

/// Explicit composition marker for content hosted in a separate app window.
///
/// Compose Android forwards between two navigation-event dispatchers. Flutter
/// routes each FlutterView's Back messages through WidgetsBinding already, so
/// this bridge preserves [child] without installing a duplicate observer.
class MiuixWindowNavigationEventBridge extends StatelessWidget {
  const MiuixWindowNavigationEventBridge({
    super.key,
    this.child = const SizedBox.shrink(),
  });

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

/// Process-local ownership order for every MIUIX predictive-back observer.
///
/// Flutter intentionally permits multiple WidgetsBindingObservers to accept a
/// gesture. MIUIX requires one terminal owner, so every observer registers one
/// stable token and accepts only while that token is last in composition order.
typedef _MiuixPredictiveBackEligibility =
    bool Function(PredictiveBackEvent? event);

// A route can be current in a nested Navigator while an outer dialog covers
// the entire branch. Cached/offstage branches must not handle platform Back.
bool _miuixBackBranchIsActive(BuildContext context) {
  if (!context.mounted ||
      !TickerMode.valuesOf(context).enabled ||
      ModalRoute.of(context)?.isCurrent == false) {
    return false;
  }
  var active = true;
  context.visitAncestorElements((element) {
    if (element is StatefulElement &&
        element.state is NavigatorState &&
        ModalRoute.of(element)?.isCurrent == false) {
      active = false;
      return false;
    }
    return true;
  });
  return active;
}

class _MiuixPredictiveBackOwnerRegistry extends ChangeNotifier {
  _MiuixPredictiveBackOwnerRegistry._();

  static final instance = _MiuixPredictiveBackOwnerRegistry._();

  final List<({Object owner, _MiuixPredictiveBackEligibility isEligible})>
  _owners = [];
  PredictiveBackEvent? _admittedEvent;
  Object? _admittedOwner;

  void register(
    Object owner,
    _MiuixPredictiveBackEligibility isEligible, {
    required BuildContext Function() context,
  }) {
    _owners.removeWhere((entry) => identical(entry.owner, owner));
    _owners.add((
      owner: owner,
      isEligible: (event) =>
          _miuixBackBranchIsActive(context()) &&
          !MiuixBackGestureScope.blockedOf(context()) &&
          // 设置关闭时只拒绝连续手势，保留普通返回的同一优先级。
          (event == null || MiuixBackGestureScope.enabledOf(context())) &&
          isEligible(event),
    ));
    notifyListeners();
  }

  void unregister(Object owner) {
    final before = _owners.length;
    _owners.removeWhere((entry) => identical(entry.owner, owner));
    if (identical(_admittedOwner, owner)) _admittedOwner = null;
    if (_owners.length != before) notifyListeners();
  }

  bool isTop(Object owner, [PredictiveBackEvent? event]) {
    if (event != null) {
      // WidgetsBinding asks every observer using the same event object. Keep
      // one winner even when starting its animation changes its eligibility.
      if (!identical(event, _admittedEvent)) {
        _admittedEvent = event;
        _admittedOwner = _topEligible(event);
      }
      return identical(_admittedOwner, owner);
    }
    return identical(_topEligible(null), owner);
  }

  Object? _topEligible(PredictiveBackEvent? event) {
    for (final entry in _owners.reversed) {
      final eligible = entry.isEligible(event);
      if (!eligible) continue;
      return entry.owner;
    }
    return null;
  }
}

class _MiuixPredictiveBackHandlerState extends State<MiuixPredictiveBackHandler>
    with WidgetsBindingObserver {
  bool _ownsGesture = false;
  bool _ownerUpdateScheduled = false;

  _MiuixPredictiveBackOwnerRegistry get _registry =>
      _MiuixPredictiveBackOwnerRegistry.instance;

  @override
  void initState() {
    super.initState();
    _registry
      ..register(this, _isEligible, context: () => context)
      ..addListener(_handleOwnerOrderChanged);
    WidgetsBinding.instance.addObserver(this);
  }

  void _handleOwnerOrderChanged() {
    if (!mounted || _ownerUpdateScheduled) return;
    _ownerUpdateScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ownerUpdateScheduled = false;
      if (mounted) setState(() {});
    });
  }

  MiuixNavBackEvent _event(PredictiveBackEvent event) {
    final rawProgress = event.progress;
    final progress = rawProgress.isFinite ? rawProgress.clamp(0.0, .999) : 0.0;
    final rawTouchY = event.touchOffset?.dy ?? 0;
    final touchY = rawTouchY.isFinite ? rawTouchY : 0.0;
    return MiuixNavBackEvent(
      progress: progress,
      swipeEdge: switch (event.swipeEdge) {
        SwipeEdge.left => MiuixNavSwipeEdge.left,
        SwipeEdge.right => MiuixNavSwipeEdge.right,
      },
      touchY: touchY,
      frameTimeMillis:
          SchedulerBinding.instance.currentSystemFrameTimeStamp.inMilliseconds,
    );
  }

  bool _isEligible(PredictiveBackEvent? backEvent) {
    if (!widget.enabled || !(ModalRoute.of(context)?.isCurrent ?? true)) {
      return false;
    }
    return backEvent == null ||
        (widget.canStart?.call(_event(backEvent)) ?? true);
  }

  bool get _canOwnBack => _registry.isTop(this);

  @override
  bool handleStartBackGesture(PredictiveBackEvent backEvent) {
    if (backEvent.isButtonEvent || !_registry.isTop(this, backEvent)) {
      return false;
    }
    final event = _event(backEvent);
    _ownsGesture = true;
    widget.onProgress(event);
    return true;
  }

  @override
  void handleUpdateBackGestureProgress(PredictiveBackEvent backEvent) {
    if (_ownsGesture) widget.onProgress(_event(backEvent));
  }

  @override
  void handleCancelBackGesture() {
    if (!_ownsGesture) return;
    _ownsGesture = false;
    widget.onCancel();
  }

  @override
  void handleCommitBackGesture() {
    // 保护层可能在拖动开始后出现，此时只能复位，不能继续提交。
    if (MiuixBackGestureScope.blockedOf(context)) {
      handleCancelBackGesture();
      return;
    }
    if (!_ownsGesture) return;
    _ownsGesture = false;
    widget.onCommit();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _registry
      ..removeListener(_handleOwnerOrderChanged)
      ..unregister(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ownsDiscreteBack = widget.handleDiscreteBack && _canOwnBack;
    return PopScope<Object?>(
      canPop: !ownsDiscreteBack && !MiuixBackGestureScope.blockedOf(context),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop &&
            ownsDiscreteBack &&
            !MiuixBackGestureScope.blockedOf(context)) {
          widget.onCommit();
        }
      },
      child: widget.child,
    );
  }
}
