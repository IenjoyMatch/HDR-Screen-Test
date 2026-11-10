part of '../miuix_widgets.dart';

/// Classification of one observable navigation-stack mutation.
sealed class MiuixNavChange {
  const MiuixNavChange();
}

final class MiuixNavNoChange extends MiuixNavChange {
  const MiuixNavNoChange();
}

final class MiuixNavPush extends MiuixNavChange {
  const MiuixNavPush();
}

final class MiuixNavPop extends MiuixNavChange {
  const MiuixNavPop();
}

final class MiuixNavMultiPush extends MiuixNavChange {
  const MiuixNavMultiPush(this.count);

  final int count;
}

final class MiuixNavMultiPop extends MiuixNavChange {
  const MiuixNavMultiPop(this.count);

  final int count;
}

final class MiuixNavReplace extends MiuixNavChange {
  const MiuixNavReplace();
}

final class MiuixNavReplaceAll extends MiuixNavChange {
  const MiuixNavReplaceAll();
}

/// Physical direction in which a pointer dismisses the current destination.
enum MiuixNavSwipeDirection {
  none,
  leftToRight,
  rightToLeft,
  topToBottom,
  bottomToTop,
}

/// Physical screen edge associated with a predictive-back gesture.
enum MiuixNavSwipeEdge { left, right, none }

/// Release path that owns the current autonomous settle.
enum MiuixNavSettlePhase { commit, cancel, programmatic }

/// Live pointer context exposed to a navigation transition.
@immutable
class MiuixNavGesture {
  const MiuixNavGesture({
    required this.progress,
    required this.swipeEdge,
    required this.touchY,
    required this.initialTouchY,
  });

  final double progress;
  final MiuixNavSwipeEdge swipeEdge;
  final double touchY;
  final double initialTouchY;
}

/// Live autonomous-settle context exposed to a navigation transition.
@immutable
class MiuixNavSettle {
  const MiuixNavSettle({
    required this.phase,
    required this.releaseVelocity,
    required this.elapsed,
  });

  final MiuixNavSettlePhase phase;
  final double releaseVelocity;
  final Duration elapsed;
}

/// Immutable transform returned by a [MiuixNavTransition].
@immutable
class MiuixNavEntryTransform {
  const MiuixNavEntryTransform({
    this.translation = Offset.zero,
    this.scaleX = 1,
    this.scaleY = 1,
    this.opacity = 1,
  });

  static const identity = MiuixNavEntryTransform();

  final Offset translation;
  final double scaleX;
  final double scaleY;
  final double opacity;
}

/// Per-entry live values used to resolve navigation visuals.
@immutable
class MiuixNavTransitionScope {
  const MiuixNavTransitionScope({
    required this.relativeDepth,
    required this.role,
    required this.change,
    required this.gesture,
    required this.settle,
    required this.layoutSize,
    required this.textDirection,
    required this.devicePixelRatio,
  });

  final double relativeDepth;
  final MiuixNavRole role;
  final MiuixNavChange change;
  final MiuixNavGesture? gesture;
  final MiuixNavSettle? settle;
  final Size layoutSize;
  final TextDirection textDirection;
  final double devicePixelRatio;
}

typedef MiuixNavTransformResolver =
    MiuixNavEntryTransform Function(MiuixNavTransitionScope scope);
typedef MiuixNavScrimResolver = double Function(MiuixNavTransitionScope scope);

/// Pure visual mapping for one continuously positioned navigation layer.
@immutable
class MiuixNavTransition {
  const MiuixNavTransition({
    required this.transform,
    this.opaqueDepth = 1,
    this.dismissDirection = MiuixNavSwipeDirection.none,
    this.motion = MiuixNavMotion.defaults,
    this.scrim,
  });

  final MiuixNavTransformResolver transform;
  final double opaqueDepth;
  final MiuixNavSwipeDirection dismissDirection;
  final MiuixNavMotion motion;
  final MiuixNavScrimResolver? scrim;

  double scrimFraction(MiuixNavTransitionScope scope) {
    final value = scrim?.call(scope) ?? scope.relativeDepth;
    return value.isFinite ? value.clamp(0.0, 1.0) : 0;
  }
}

/// Convenience constructor mirroring the current source transition factory.
MiuixNavTransition miuixNavGraphicsTransition({
  required MiuixNavTransformResolver transform,
  double opaqueDepth = 1,
  MiuixNavSwipeDirection dismissDirection = MiuixNavSwipeDirection.none,
  MiuixNavMotion motion = MiuixNavMotion.defaults,
  MiuixNavScrimResolver? scrim,
}) => MiuixNavTransition(
  transform: transform,
  opaqueDepth: opaqueDepth,
  dismissDirection: dismissDirection,
  motion: motion,
  scrim: scrim,
);

/// Combines forward, programmatic-pop, and gesture-pop visual branches.
MiuixNavTransition miuixNavDirectionalTransition({
  required MiuixNavTransition push,
  MiuixNavTransition? pop,
  MiuixNavTransition? predictivePop,
}) {
  final resolvedPop = pop ?? push;
  final resolvedPredictive = predictivePop ?? resolvedPop;
  MiuixNavTransition branch(MiuixNavTransitionScope scope) {
    if (scope.gesture != null) return resolvedPredictive;
    if (scope.change is MiuixNavPop || scope.change is MiuixNavMultiPop) {
      return resolvedPop;
    }
    return push;
  }

  return MiuixNavTransition(
    opaqueDepth: math.max(
      push.opaqueDepth,
      math.max(resolvedPop.opaqueDepth, resolvedPredictive.opaqueDepth),
    ),
    dismissDirection: resolvedPredictive.dismissDirection,
    motion: MiuixNavMotion(
      commit: resolvedPredictive.motion.commit,
      cancel: resolvedPredictive.motion.cancel,
      programmatic: resolvedPop.motion.programmatic,
    ),
    transform: (scope) => branch(scope).transform(scope),
    scrim: (scope) => branch(scope).scrimFraction(scope),
  );
}

/// Current-source transition presets driven only by continuous depth.
abstract final class MiuixNavTransitions {
  static const miuixDefault = MiuixNavTransition(
    transform: _resolveMiuixDefaultNavTransform,
  );

  static const modal = MiuixNavTransition(
    transform: _resolveMiuixModalNavTransform,
    opaqueDepth: 2,
  );

  static const none = MiuixNavTransition(
    transform: _resolveIdentityNavTransform,
  );
}

/// Reads Android's physical display corner radius in logical pixels.
///
/// Flat or unsupported displays, desktop targets, tests without a registered
/// plugin, and channel failures resolve to zero as in the current source.
Future<double> loadMiuixNavSystemCornerRadius() async {
  if (defaultTargetPlatform != TargetPlatform.android) return 0;
  try {
    const channel = MethodChannel('flutter_miuix/platform');
    final value = await channel.invokeMethod<num>('screenCornerRadius');
    final radius = value?.toDouble() ?? 0;
    return radius.isFinite && radius > 0 ? radius : 0;
  } on PlatformException {
    return 0;
  } on MissingPluginException {
    return 0;
  }
}

MiuixNavEntryTransform _resolveMiuixDefaultNavTransform(
  MiuixNavTransitionScope scope,
) {
  final d = scope.relativeDepth;
  final width = scope.layoutSize.width;
  final rtl = scope.textDirection == TextDirection.rtl;
  if (d <= 0) {
    final pixels = (-d).clamp(0.0, 1.0) * width;
    final snapped =
        (pixels * scope.devicePixelRatio).round() / scope.devicePixelRatio;
    return MiuixNavEntryTransform(
      translation: Offset((rtl ? -1 : 1) * snapped, 0),
    );
  }
  final cover = d.clamp(0.0, 1.0);
  return MiuixNavEntryTransform(
    translation: Offset((rtl ? 1 : -1) * cover * width * .25, 0),
    opacity: 1 - .1 * cover,
  );
}

MiuixNavEntryTransform _resolveMiuixModalNavTransform(
  MiuixNavTransitionScope scope,
) {
  final d = scope.relativeDepth;
  if (d > 0) return MiuixNavEntryTransform.identity;
  return MiuixNavEntryTransform(
    translation: Offset(0, (-d).clamp(0.0, 1.0) * scope.layoutSize.height),
  );
}

MiuixNavEntryTransform _resolveIdentityNavTransform(
  MiuixNavTransitionScope scope,
) => MiuixNavEntryTransform.identity;

typedef MiuixNavContentKey<K extends MiuixNavKey> = Object Function(K key);
typedef MiuixNavContentBuilder<K extends MiuixNavKey> =
    Widget Function(BuildContext context, K key);

class _MiuixNavEntryDefinition<K extends MiuixNavKey> {
  const _MiuixNavEntryDefinition({
    required this.key,
    required this.contentKey,
    required this.metadata,
    required this.builder,
    this.transition,
    this.swipeDismiss,
  });

  final K key;
  final Object contentKey;
  final Map<String, Object> metadata;
  final MiuixNavContentBuilder<K> builder;
  final MiuixNavTransition? transition;
  final MiuixNavSwipeDirection? swipeDismiss;
}

typedef _MiuixNavEntryFactory<K extends MiuixNavKey> =
    _MiuixNavEntryDefinition<K> Function(K key);

/// Registers an exact runtime route type with its content and optional motion.
class MiuixNavEntryBuilder<K extends MiuixNavKey> {
  final Map<Type, _MiuixNavEntryFactory<K>> _factories = {};

  void entry<T extends K>({
    MiuixNavContentKey<T>? contentKey,
    MiuixNavTransition? transition,
    MiuixNavSwipeDirection? swipeDismiss,
    Map<String, Object> metadata = const {},
    required MiuixNavContentBuilder<T> builder,
  }) {
    _factories[T] = (key) {
      final typed = key as T;
      return _MiuixNavEntryDefinition<K>(
        key: typed,
        contentKey: contentKey?.call(typed) ?? typed,
        metadata: Map<String, Object>.unmodifiable(metadata),
        builder: (context, value) => builder(context, value as T),
        transition: transition,
        swipeDismiss: swipeDismiss,
      );
    };
  }

  _MiuixNavEntryDefinition<K> _build(K key) {
    final factory = _factories[key.runtimeType];
    if (factory == null) {
      throw StateError(
        'No MiuixNavEntryBuilder.entry registered for ${key.runtimeType}.',
      );
    }
    return factory(key);
  }
}

class _MiuixPresentedEntry<K extends MiuixNavKey> {
  _MiuixPresentedEntry({
    required this.definition,
    required this.index,
    required this.content,
    required this.contentRevision,
  });

  _MiuixNavEntryDefinition<K> definition;
  int index;
  Widget content;
  int contentRevision;
  bool removing = false;
}

/// Continuously animated, state-preserving display for a MIUIX navigation stack.
class MiuixNavDisplay<K extends MiuixNavKey> extends StatefulWidget {
  const MiuixNavDisplay({
    super.key,
    required this.backStack,
    required this.entries,
    this.onBack,
    this.transition = MiuixNavTransitions.miuixDefault,
    this.effects = MiuixNavDisplayEffects.defaults,
    this.enablePredictiveBack = true,
    this.clipBehavior = Clip.hardEdge,
  });

  MiuixNavDisplay.controller({
    super.key,
    required MiuixNavController<K> navController,
    required this.entries,
    this.onBack,
    this.transition = MiuixNavTransitions.miuixDefault,
    this.effects = MiuixNavDisplayEffects.defaults,
    this.enablePredictiveBack = true,
    this.clipBehavior = Clip.hardEdge,
  }) : backStack = navController.backStack;

  final MiuixNavBackStack<K> backStack;
  final void Function(MiuixNavEntryBuilder<K> builder) entries;
  final VoidCallback? onBack;
  final MiuixNavTransition transition;
  final MiuixNavDisplayEffects effects;
  final bool enablePredictiveBack;
  final Clip clipBehavior;

  @override
  State<MiuixNavDisplay<K>> createState() => _MiuixNavDisplayState<K>();
}

class _MiuixNavDisplayState<K extends MiuixNavKey>
    extends State<MiuixNavDisplay<K>>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _driver;
  final List<_MiuixPresentedEntry<K>> _presented = [];
  bool _entriesDirty = true;
  int _contentRevision = 0;
  List<Object>? _currentContentKeys;
  MiuixNavChange _change = const MiuixNavNoChange();
  MiuixNavGesture? _gesture;
  MiuixNavSettle? _settle;
  double? _settleTarget;
  Stopwatch? _settleClock;
  int _settleGeneration = 0;
  bool _settleScheduled = false;
  double _gestureAnchor = 0;
  double _gestureTravel = 0;
  double _gestureInitialTouchY = 0;
  double _gestureLastProgress = 0;
  Duration _gestureLastTime = Duration.zero;
  double _gestureVelocity = 0;
  bool _predictiveGesture = false;

  @override
  void initState() {
    super.initState();
    if (widget.backStack.isEmpty) {
      throw ArgumentError.value(
        widget.backStack,
        'backStack',
        'MiuixNavDisplay back stack cannot be empty.',
      );
    }
    _driver = AnimationController.unbounded(
      vsync: this,
      value: widget.backStack.length - 1.0,
    )..addListener(_handleDriverTick);
    widget.backStack.addListener(_handleStackChanged);
    _MiuixPredictiveBackOwnerRegistry.instance.register(
      this,
      (event) =>
          widget.enablePredictiveBack &&
          widget.backStack.length > 1 &&
          !_predictiveGesture &&
          (ModalRoute.of(context)?.isCurrent ?? true),
      context: () => context,
    );
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didUpdateWidget(covariant MiuixNavDisplay<K> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _entriesDirty = true;
    _contentRevision += 1;
    if (!identical(oldWidget.backStack, widget.backStack)) {
      oldWidget.backStack.removeListener(_handleStackChanged);
      if (widget.backStack.isEmpty) {
        throw ArgumentError.value(
          widget.backStack,
          'backStack',
          'MiuixNavDisplay back stack cannot be empty.',
        );
      }
      widget.backStack.addListener(_handleStackChanged);
      _presented.clear();
      _currentContentKeys = null;
      _driver.value = widget.backStack.length - 1.0;
    }
  }

  void _handleDriverTick() {
    if (!mounted) return;
    final clock = _settleClock;
    if (clock != null && _settle != null) {
      _settle = MiuixNavSettle(
        phase: _settle!.phase,
        releaseVelocity: _settle!.releaseVelocity,
        elapsed: clock.elapsed,
      );
    }
    setState(() {});
  }

  void _handleStackChanged() {
    if (!mounted) return;
    _entriesDirty = true;
    setState(() {});
  }

  Widget _buildEntryContent(_MiuixNavEntryDefinition<K> definition) {
    return KeyedSubtree(
      key: ValueKey(definition.contentKey),
      child: SizedBox.expand(
        child: Builder(
          builder: (context) => definition.builder(context, definition.key),
        ),
      ),
    );
  }

  MiuixNavChange _classify(List<Object> oldKeys, List<Object> newKeys) {
    var common = 0;
    final limit = math.min(oldKeys.length, newKeys.length);
    while (common < limit && oldKeys[common] == newKeys[common]) {
      common += 1;
    }
    final removed = oldKeys.length - common;
    final added = newKeys.length - common;
    if (removed == 0 && added == 0) return const MiuixNavNoChange();
    if (removed == 0) {
      return added == 1 ? const MiuixNavPush() : MiuixNavMultiPush(added);
    }
    if (added == 0) {
      return removed == 1 ? const MiuixNavPop() : MiuixNavMultiPop(removed);
    }
    if (common == newKeys.length - 1 && removed == 1 && added == 1) {
      return const MiuixNavReplace();
    }
    return const MiuixNavReplaceAll();
  }

  void _synchronizeEntries() {
    if (widget.backStack.isEmpty) {
      throw StateError('MiuixNavDisplay back stack cannot be empty.');
    }
    final registry = MiuixNavEntryBuilder<K>();
    widget.entries(registry);
    final definitions = widget.backStack.map(registry._build).toList();
    final newKeys = definitions.map((entry) => entry.contentKey).toList();
    final uniqueKeys = <Object>{};
    for (final contentKey in newKeys) {
      if (!uniqueKeys.add(contentKey)) {
        throw ArgumentError.value(
          contentKey,
          'contentKey',
          'Every MiuixNavDisplay entry requires a unique contentKey.',
        );
      }
    }

    final previous = _currentContentKeys;
    if (previous != null && !listEquals(previous, newKeys)) {
      _change = _classify(previous, newKeys);
    }
    final currentKeys = newKeys.toSet();
    for (final entry in _presented) {
      if (!currentKeys.contains(entry.definition.contentKey)) {
        entry.removing = true;
      }
    }
    for (var index = 0; index < definitions.length; index += 1) {
      final definition = definitions[index];
      final existing = _presented.cast<_MiuixPresentedEntry<K>?>().firstWhere(
        (entry) => entry?.definition.contentKey == definition.contentKey,
        orElse: () => null,
      );
      if (existing == null) {
        _presented.add(
          _MiuixPresentedEntry<K>(
            definition: definition,
            index: index,
            content: _buildEntryContent(definition),
            contentRevision: _contentRevision,
          ),
        );
      } else {
        existing
          ..definition = definition
          ..index = index
          ..removing = false;
        if (existing.contentRevision != _contentRevision) {
          existing
            ..content = _buildEntryContent(definition)
            ..contentRevision = _contentRevision;
        }
      }
    }
    _presented.removeWhere(
      (entry) => entry.removing && entry.index < definitions.length,
    );
    final changed = previous != null && !listEquals(previous, newKeys);
    _currentContentKeys = List<Object>.unmodifiable(newKeys);
    if (changed) _scheduleTargetSettle();
  }

  void _scheduleTargetSettle() {
    if (_settleScheduled) return;
    _settleScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _settleScheduled = false;
      if (!mounted) return;
      final target = widget.backStack.length - 1.0;
      if ((_driver.value - target).abs() <= 1e-9) {
        return;
      }
      if (_settle != null &&
          _settleTarget != null &&
          (_settleTarget! - target).abs() <= 1e-9) {
        return;
      }
      final transition = _topPresentedTransition;
      final distance = (target - _driver.value).abs();
      final spec = _driver.velocity.abs() < 1e-6 && distance >= .999
          ? transition.motion.programmatic
          : transition.motion.commit;
      _settleTo(
        target,
        spec,
        phase: MiuixNavSettlePhase.programmatic,
        releaseVelocity: 0,
        initialVelocity: _driver.velocity,
      );
    });
  }

  MiuixNavTransition get _topPresentedTransition {
    if (_presented.isEmpty) return widget.transition;
    var top = _presented.first;
    for (final entry in _presented.skip(1)) {
      if (entry.index >= top.index) top = entry;
    }
    return top.definition.transition ?? widget.transition;
  }

  Future<void> _settleTo(
    double target,
    MiuixNavSettleSpec spec, {
    required MiuixNavSettlePhase phase,
    required double releaseVelocity,
    required double initialVelocity,
  }) async {
    final generation = ++_settleGeneration;
    _driver.stop();
    _settleTarget = target;
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (disableAnimations ||
        spec is MiuixNavTweenSettleSpec && spec.duration <= Duration.zero) {
      _driver.value = target;
      _finishSettle(generation);
      return;
    }
    _settleClock = Stopwatch()..start();
    _settle = MiuixNavSettle(
      phase: phase,
      releaseVelocity: releaseVelocity,
      elapsed: Duration.zero,
    );
    try {
      if (spec is MiuixNavTweenSettleSpec) {
        await _driver
            .animateTo(target, duration: spec.duration, curve: spec.curve)
            .orCancel;
      } else if (spec is MiuixNavSpringSettleSpec) {
        var velocity = initialVelocity;
        if (phase == MiuixNavSettlePhase.commit && spec.clampOvershoot) {
          final remaining = (_driver.value - target).abs();
          final floor = -math.sqrt(spec.stiffness) * remaining;
          velocity = velocity.clamp(floor, double.infinity);
        }
        Simulation simulation = SpringSimulation(
          spec.toSpringDescription(),
          _driver.value,
          target,
          velocity,
        );
        if (spec.clampOvershoot || phase == MiuixNavSettlePhase.cancel) {
          simulation = _MiuixBoundedNavSimulation(
            simulation,
            math.min(_driver.value, target),
            math.max(_driver.value, target),
          );
        }
        await _driver.animateWith(simulation).orCancel;
      }
      if (mounted && generation == _settleGeneration) {
        _driver.value = target;
      }
    } on TickerCanceled {
      return;
    } finally {
      _finishSettle(generation);
    }
  }

  void _finishSettle(int generation) {
    if (!mounted || generation != _settleGeneration) return;
    _settleClock?.stop();
    _settleClock = null;
    _settleTarget = null;
    _settle = null;
    _gesture = null;
    _predictiveGesture = false;
    final currentKeys = widget.backStack.toSet();
    _presented.removeWhere(
      (entry) =>
          entry.removing &&
          (!currentKeys.contains(entry.definition.key) ||
              _driver.value - entry.index <= -1 + 1e-6),
    );
    if (mounted) setState(() {});
  }

  void _requestBack() {
    if (widget.backStack.length <= 1) return;
    if (widget.onBack case final callback?) {
      callback();
    } else {
      widget.backStack.removeAt(widget.backStack.length - 1);
    }
  }

  void _beginGesture({
    required double touchY,
    required MiuixNavSwipeEdge edge,
    bool predictive = false,
  }) {
    _driver.stop();
    _settleGeneration += 1;
    _settleClock?.stop();
    _settleClock = null;
    _settleTarget = null;
    _settle = null;
    _gestureAnchor = (widget.backStack.length - 1 - _driver.value).clamp(
      0.0,
      .999,
    );
    _gestureTravel = 0;
    _gestureInitialTouchY = touchY;
    _gestureLastProgress = 0;
    _gestureLastTime = Duration.zero;
    _gestureVelocity = 0;
    _predictiveGesture = predictive;
    _gesture = MiuixNavGesture(
      progress: _gestureAnchor,
      swipeEdge: edge,
      touchY: touchY,
      initialTouchY: touchY,
    );
    setState(() {});
  }

  void _updateGesture({
    required double progress,
    required double touchY,
    required MiuixNavSwipeEdge edge,
    Duration? frameTime,
  }) {
    final safeProgress = progress.isFinite ? progress.clamp(0.0, .999) : 0.0;
    final timestamp =
        frameTime ?? SchedulerBinding.instance.currentSystemFrameTimeStamp;
    if (_gestureLastTime != Duration.zero && timestamp > _gestureLastTime) {
      final micros = (timestamp - _gestureLastTime).inMicroseconds;
      _gestureVelocity =
          (safeProgress - _gestureLastProgress) *
          Duration.microsecondsPerSecond /
          micros;
    }
    if (timestamp != Duration.zero) {
      _gestureLastProgress = safeProgress;
      _gestureLastTime = timestamp;
    }
    _driver.value = widget.backStack.length - 1 - safeProgress;
    _gesture = MiuixNavGesture(
      progress: safeProgress,
      swipeEdge: edge,
      touchY: touchY,
      initialTouchY: _gestureInitialTouchY,
    );
  }

  void _cancelGesture({double progressVelocity = 0}) {
    final depthVelocity = math.min(0.0, -progressVelocity);
    _settleTo(
      widget.backStack.length - 1.0,
      _topPresentedTransition.motion.cancel,
      phase: MiuixNavSettlePhase.cancel,
      releaseVelocity: progressVelocity,
      initialVelocity: depthVelocity,
    );
  }

  void _commitGesture(double velocity) {
    final oldLength = widget.backStack.length;
    final transition = _topPresentedTransition;
    _requestBack();
    if (widget.backStack.length == oldLength) {
      _cancelGesture(progressVelocity: velocity);
      return;
    }
    _settleTo(
      widget.backStack.length - 1.0,
      transition.motion.commit,
      phase: MiuixNavSettlePhase.commit,
      releaseVelocity: velocity,
      initialVelocity: -velocity,
    );
  }

  bool _shouldCommit(double progress, double velocity) {
    if (velocity >= 1) return true;
    if (velocity <= -1) return false;
    return progress >= .5;
  }

  void _handleDragStart(DragStartDetails details) {
    final direction = _effectiveDismissDirection;
    _beginGesture(
      touchY: details.globalPosition.dy,
      edge: switch (direction) {
        MiuixNavSwipeDirection.leftToRight => MiuixNavSwipeEdge.left,
        MiuixNavSwipeDirection.rightToLeft => MiuixNavSwipeEdge.right,
        _ => MiuixNavSwipeEdge.none,
      },
    );
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final direction = _effectiveDismissDirection;
    final delta = switch (direction) {
      MiuixNavSwipeDirection.leftToRight => details.delta.dx,
      MiuixNavSwipeDirection.rightToLeft => -details.delta.dx,
      MiuixNavSwipeDirection.topToBottom => details.delta.dy,
      MiuixNavSwipeDirection.bottomToTop => -details.delta.dy,
      MiuixNavSwipeDirection.none => 0.0,
    };
    final extent = switch (direction) {
      MiuixNavSwipeDirection.leftToRight ||
      MiuixNavSwipeDirection.rightToLeft => context.size?.width ?? 0,
      MiuixNavSwipeDirection.topToBottom ||
      MiuixNavSwipeDirection.bottomToTop => context.size?.height ?? 0,
      MiuixNavSwipeDirection.none => 0.0,
    };
    if (extent <= 0 || !extent.isFinite) return;
    _gestureTravel += delta;
    final progress = (_gestureAnchor + _gestureTravel / extent).clamp(
      0.0,
      .999,
    );
    _updateGesture(
      progress: progress,
      touchY: details.globalPosition.dy,
      edge: _gesture?.swipeEdge ?? MiuixNavSwipeEdge.none,
    );
  }

  void _handleDragEnd(DragEndDetails details) {
    final direction = _effectiveDismissDirection;
    final pixelsPerSecond = switch (direction) {
      MiuixNavSwipeDirection.leftToRight => details.velocity.pixelsPerSecond.dx,
      MiuixNavSwipeDirection.rightToLeft =>
        -details.velocity.pixelsPerSecond.dx,
      MiuixNavSwipeDirection.topToBottom => details.velocity.pixelsPerSecond.dy,
      MiuixNavSwipeDirection.bottomToTop =>
        -details.velocity.pixelsPerSecond.dy,
      MiuixNavSwipeDirection.none => 0.0,
    };
    final extent = switch (direction) {
      MiuixNavSwipeDirection.leftToRight ||
      MiuixNavSwipeDirection.rightToLeft => context.size?.width ?? 0,
      MiuixNavSwipeDirection.topToBottom ||
      MiuixNavSwipeDirection.bottomToTop => context.size?.height ?? 0,
      MiuixNavSwipeDirection.none => 0.0,
    };
    final velocity = extent > 0 ? pixelsPerSecond / extent : 0.0;
    final progress = (widget.backStack.length - 1 - _driver.value).clamp(
      0.0,
      .999,
    );
    if (_shouldCommit(progress, velocity)) {
      _commitGesture(velocity);
    } else {
      _cancelGesture(progressVelocity: velocity);
    }
  }

  MiuixNavSwipeDirection get _effectiveDismissDirection {
    if (widget.backStack.length <= 1 || _presented.isEmpty) {
      return MiuixNavSwipeDirection.none;
    }
    final currentTop = widget.backStack.last;
    final entry = _presented.cast<_MiuixPresentedEntry<K>?>().firstWhere(
      (candidate) =>
          candidate?.definition.key == currentTop && !candidate!.removing,
      orElse: () => null,
    );
    if (entry == null) return MiuixNavSwipeDirection.none;
    return entry.definition.swipeDismiss ??
        (entry.definition.transition ?? widget.transition).dismissDirection;
  }

  @override
  bool handleStartBackGesture(PredictiveBackEvent backEvent) {
    if (!widget.enablePredictiveBack ||
        !_MiuixPredictiveBackOwnerRegistry.instance.isTop(this, backEvent) ||
        backEvent.isButtonEvent ||
        widget.backStack.length <= 1 ||
        _predictiveGesture ||
        !(ModalRoute.of(context)?.isCurrent ?? true)) {
      return false;
    }
    final touchY = backEvent.touchOffset?.dy ?? 0;
    final edge = switch (backEvent.swipeEdge) {
      SwipeEdge.left => MiuixNavSwipeEdge.left,
      SwipeEdge.right => MiuixNavSwipeEdge.right,
    };
    _beginGesture(touchY: touchY, edge: edge, predictive: true);
    _updateGesture(
      progress: backEvent.progress,
      touchY: touchY,
      edge: edge,
      frameTime: SchedulerBinding.instance.currentSystemFrameTimeStamp,
    );
    return true;
  }

  @override
  void handleUpdateBackGestureProgress(PredictiveBackEvent backEvent) {
    if (!_predictiveGesture) return;
    _updateGesture(
      progress: backEvent.progress,
      touchY: backEvent.touchOffset?.dy ?? _gesture?.touchY ?? 0,
      edge: _gesture?.swipeEdge ?? MiuixNavSwipeEdge.none,
      frameTime: SchedulerBinding.instance.currentSystemFrameTimeStamp,
    );
  }

  @override
  void handleCancelBackGesture() {
    if (!_predictiveGesture) return;
    _cancelGesture(progressVelocity: _gestureVelocity);
  }

  @override
  void handleCommitBackGesture() {
    if (MiuixBackGestureScope.blockedOf(context)) {
      handleCancelBackGesture();
      return;
    }
    if (!_predictiveGesture) return;
    if (_gestureVelocity <= -1) {
      _cancelGesture(progressVelocity: _gestureVelocity);
    } else {
      _commitGesture(_gestureVelocity);
    }
  }

  MiuixNavRole _roleFor(double depth, bool removing) {
    if (depth > .001) return MiuixNavRole.covered;
    if (depth < -.001) {
      return removing ? MiuixNavRole.outgoing : MiuixNavRole.incoming;
    }
    return MiuixNavRole.top;
  }

  MiuixNavTransitionScope _scopeFor(
    _MiuixPresentedEntry<K> entry,
    Size size,
    TextDirection direction,
    double pixelRatio,
  ) {
    final depth = _driver.value - entry.index;
    return MiuixNavTransitionScope(
      relativeDepth: depth,
      role: _roleFor(depth, entry.removing),
      change: _change,
      gesture: _gesture,
      settle: _settle,
      layoutSize: size,
      textDirection: direction,
      devicePixelRatio: pixelRatio,
    );
  }

  Widget _buildEntry(
    _MiuixPresentedEntry<K> entry,
    Size size,
    TextDirection direction,
    double pixelRatio,
    bool visible,
  ) {
    final scope = _scopeFor(entry, size, direction, pixelRatio);
    final ownTransition = entry.definition.transition ?? widget.transition;
    _MiuixPresentedEntry<K>? upper;
    for (final candidate in _presented) {
      if (candidate.index == entry.index + 1) upper = candidate;
    }
    final activeTransition = scope.relativeDepth <= 0
        ? ownTransition
        : upper?.definition.transition ?? widget.transition;
    final resolved = activeTransition.transform(scope);
    final opacity = resolved.opacity.isFinite
        ? resolved.opacity.clamp(0.0, 1.0)
        : 1.0;
    final translation =
        resolved.translation.dx.isFinite && resolved.translation.dy.isFinite
        ? resolved.translation
        : Offset.zero;
    final scaleX = resolved.scaleX.isFinite && resolved.scaleX >= 0
        ? resolved.scaleX
        : 1.0;
    final scaleY = resolved.scaleY.isFinite && resolved.scaleY >= 0
        ? resolved.scaleY
        : 1.0;

    Widget child = entry.content;
    if (widget.effects.shouldClipCornersAt(scope.relativeDepth) &&
        widget.effects.cornerClipRadius.isFinite &&
        widget.effects.cornerClipRadius > 0) {
      final radius = widget.effects.cornerClipRadius;
      final all = widget.effects.cornerClipMode == MiuixNavCornerClipMode.all;
      final leadingLeft = direction == TextDirection.ltr;
      child = ClipPath(
        clipper: ShapeBorderClipper(
          shape: MiuixSquircleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(all || leadingLeft ? radius : 0),
              bottomLeft: Radius.circular(all || leadingLeft ? radius : 0),
              topRight: Radius.circular(all || !leadingLeft ? radius : 0),
              bottomRight: Radius.circular(all || !leadingLeft ? radius : 0),
            ),
          ),
        ),
        child: child,
      );
    }
    child = AbsorbPointer(
      absorbing: widget.effects.shouldBlockInputAt(scope.relativeDepth),
      child: IgnorePointer(
        ignoring: entry.removing || entry.index != widget.backStack.length - 1,
        child: child,
      ),
    );
    child = Opacity(opacity: opacity, child: child);
    child = Transform(
      key: ValueKey<(String, Object)>((
        'miuix-nav-entry-transform',
        entry.definition.contentKey,
      )),
      alignment: Alignment.center,
      transform: Matrix4.diagonal3Values(scaleX, scaleY, 1)
        ..setTranslationRaw(translation.dx, translation.dy, 0),
      child: child,
    );
    child = Visibility(visible: visible, maintainState: true, child: child);
    return Positioned.fill(
      key: ValueKey<Object>(entry.definition.contentKey),
      child: child,
    );
  }

  List<Widget> _buildLayers(
    Size size,
    TextDirection direction,
    double pixelRatio,
  ) {
    var windowDepth = widget.transition.opaqueDepth.isFinite
        ? math.max(0.0, widget.transition.opaqueDepth)
        : 1.0;
    for (final entry in _presented) {
      final depth =
          (entry.definition.transition ?? widget.transition).opaqueDepth;
      if (depth.isFinite) windowDepth = math.max(windowDepth, depth);
    }
    final visible = _presented.where((entry) {
      final depth = _driver.value - entry.index;
      return depth > -1 && depth <= windowDepth;
    }).toList()..sort((a, b) => a.index.compareTo(b.index));
    final layers = <Widget>[];
    final backdrop = widget.effects.backdropColor;
    final dimAmount = widget.effects.dimAmount.isFinite
        ? widget.effects.dimAmount.clamp(0.0, 1.0)
        : 0.0;
    if (backdrop != null) {
      layers.add(
        Positioned.fill(
          key: const ValueKey('miuix-nav-display-backdrop'),
          child: ColoredBox(color: backdrop),
        ),
      );
    }
    if (visible.isEmpty) return layers;
    final topVisible = visible.last;
    final visibleKeys = visible
        .map((entry) => entry.definition.contentKey)
        .toSet();
    final ordered = _presented.toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    for (final entry in ordered) {
      if (identical(entry, topVisible) && entry.index > 0 && dimAmount > 0) {
        _MiuixPresentedEntry<K>? below;
        for (final candidate in _presented) {
          if (candidate.index == entry.index - 1) below = candidate;
        }
        if (below != null) {
          final transition = entry.definition.transition ?? widget.transition;
          final fraction = transition
              .scrimFraction(_scopeFor(below, size, direction, pixelRatio))
              .clamp(0.0, 1.0);
          final alpha = (dimAmount * fraction).clamp(0.0, 1.0);
          if (alpha > 0) {
            layers.add(
              Positioned.fill(
                key: const ValueKey('miuix-nav-display-scrim-layer'),
                child: IgnorePointer(
                  child: ColoredBox(
                    key: const ValueKey('miuix-nav-display-scrim'),
                    color: Colors.black.withValues(alpha: alpha),
                  ),
                ),
              ),
            );
          }
        }
      }
      layers.add(
        _buildEntry(
          entry,
          size,
          direction,
          pixelRatio,
          visibleKeys.contains(entry.definition.contentKey),
        ),
      );
    }
    return layers;
  }

  Widget _withDismissGesture(Widget child) {
    final direction = _effectiveDismissDirection;
    if (direction == MiuixNavSwipeDirection.none) return child;
    final horizontal =
        direction == MiuixNavSwipeDirection.leftToRight ||
        direction == MiuixNavSwipeDirection.rightToLeft;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      dragStartBehavior: DragStartBehavior.down,
      onHorizontalDragStart: horizontal ? _handleDragStart : null,
      onHorizontalDragUpdate: horizontal ? _handleDragUpdate : null,
      onHorizontalDragEnd: horizontal ? _handleDragEnd : null,
      onHorizontalDragCancel: horizontal ? _cancelGesture : null,
      onVerticalDragStart: horizontal ? null : _handleDragStart,
      onVerticalDragUpdate: horizontal ? null : _handleDragUpdate,
      onVerticalDragEnd: horizontal ? null : _handleDragEnd,
      onVerticalDragCancel: horizontal ? null : _cancelGesture,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_entriesDirty) {
      _entriesDirty = false;
      _synchronizeEntries();
    }
    final direction = Directionality.of(context);
    final rawPixelRatio = MediaQuery.devicePixelRatioOf(context);
    final pixelRatio = rawPixelRatio.isFinite && rawPixelRatio > 0
        ? rawPixelRatio
        : 1.0;
    final canHandleBack = widget.backStack.length > 1;
    return PopScope<Object?>(
      canPop: !canHandleBack && !MiuixBackGestureScope.blockedOf(context),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop &&
            canHandleBack &&
            !MiuixBackGestureScope.blockedOf(context)) {
          _requestBack();
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          final safeSize = Size(
            size.width.isFinite ? size.width : 0,
            size.height.isFinite ? size.height : 0,
          );
          return ClipRect(
            clipBehavior: widget.clipBehavior,
            child: _withDismissGesture(
              Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.none,
                children: _buildLayers(safeSize, direction, pixelRatio),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _MiuixPredictiveBackOwnerRegistry.instance.unregister(this);
    widget.backStack.removeListener(_handleStackChanged);
    _driver
      ..removeListener(_handleDriverTick)
      ..dispose();
    super.dispose();
  }
}

class _MiuixBoundedNavSimulation extends Simulation {
  _MiuixBoundedNavSimulation(this.parent, this.minimum, this.maximum);

  final Simulation parent;
  final double minimum;
  final double maximum;

  @override
  double x(double time) => parent.x(time).clamp(minimum, maximum);

  @override
  double dx(double time) {
    final position = parent.x(time);
    if (position < minimum || position > maximum) return 0;
    return parent.dx(time);
  }

  @override
  bool isDone(double time) => parent.isDone(time);
}
