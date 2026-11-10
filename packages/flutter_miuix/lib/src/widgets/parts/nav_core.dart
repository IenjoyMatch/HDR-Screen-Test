part of '../miuix_widgets.dart';

/// Marker interface for application-owned navigation destination keys.
abstract interface class MiuixNavKey {}

/// Observable, directly mutable navigation back stack.
class MiuixNavBackStack<K extends MiuixNavKey> extends ChangeNotifier
    with ListMixin<K> {
  MiuixNavBackStack([Iterable<K> entries = const []])
    : _entries = List<K>.of(entries);

  final List<K> _entries;

  @override
  int get length => _entries.length;

  @override
  set length(int value) {
    if (value == _entries.length) return;
    if (value < 0) {
      throw RangeError.value(value, 'length', 'Must not be negative.');
    }
    if (value > _entries.length) {
      throw UnsupportedError(
        'MiuixNavBackStack cannot grow through length because route keys '
        'cannot be synthesized. Use add or addAll instead.',
      );
    }
    _entries.removeRange(value, _entries.length);
    notifyListeners();
  }

  @override
  K operator [](int index) => _entries[index];

  @override
  void operator []=(int index, K value) {
    if (_entries[index] == value) return;
    _entries[index] = value;
    notifyListeners();
  }

  @override
  void add(K element) {
    _entries.add(element);
    notifyListeners();
  }

  @override
  void addAll(Iterable<K> iterable) {
    final values = List<K>.of(iterable);
    if (values.isEmpty) return;
    _entries.addAll(values);
    notifyListeners();
  }

  @override
  void insert(int index, K element) {
    _entries.insert(index, element);
    notifyListeners();
  }

  @override
  void insertAll(int index, Iterable<K> iterable) {
    final values = List<K>.of(iterable);
    if (values.isEmpty) return;
    _entries.insertAll(index, values);
    notifyListeners();
  }

  @override
  K removeAt(int index) {
    final removed = _entries.removeAt(index);
    notifyListeners();
    return removed;
  }

  @override
  bool remove(Object? element) {
    final removed = _entries.remove(element);
    if (removed) notifyListeners();
    return removed;
  }

  @override
  void clear() {
    if (_entries.isEmpty) return;
    _entries.clear();
    notifyListeners();
  }

  @override
  void removeRange(int start, int end) {
    if (start == end) return;
    _entries.removeRange(start, end);
    notifyListeners();
  }

  @override
  void replaceRange(int start, int end, Iterable<K> newContents) {
    final values = List<K>.of(newContents);
    if (start == end && values.isEmpty) return;
    _entries.replaceRange(start, end, values);
    notifyListeners();
  }

  /// Encodes the complete stack with an application-owned route serializer.
  List<Object?> toRestorableData(Object? Function(K key) encode) =>
      List<Object?>.unmodifiable(_entries.map(encode));

  /// Recreates a stack from application-owned serialized route data.
  factory MiuixNavBackStack.fromRestorableData(
    Iterable<Object?> data,
    K Function(Object? value) decode,
  ) => MiuixNavBackStack<K>(data.map(decode));
}

/// In-memory source-style back-stack constructor.
MiuixNavBackStack<K> miuixNavBackStackOf<K extends MiuixNavKey>([
  Iterable<K> elements = const [],
]) => MiuixNavBackStack<K>(elements);

/// Thin navigation controller that mutates one observable back stack.
class MiuixNavController<K extends MiuixNavKey> {
  const MiuixNavController(this.backStack);

  final MiuixNavBackStack<K> backStack;

  void push(K key) => backStack.add(key);

  bool pop() {
    if (backStack.length <= 1) return false;
    backStack.removeAt(backStack.length - 1);
    return true;
  }

  void replace(K key) {
    if (backStack.isEmpty) {
      backStack.add(key);
    } else {
      backStack[backStack.length - 1] = key;
    }
  }

  void popUntil(bool Function(K key) predicate) {
    while (backStack.length > 1 && !predicate(backStack.last)) {
      backStack.removeAt(backStack.length - 1);
    }
  }
}

/// Corners rounded by navigation display effects during a transition.
enum MiuixNavCornerClipMode { leading, all }

/// Orthogonal visual effects applied around the active page transition.
@immutable
class MiuixNavDisplayEffects {
  const MiuixNavDisplayEffects({
    this.enableCornerClip = true,
    this.cornerClipRadius = 0,
    this.cornerClipMode = MiuixNavCornerClipMode.leading,
    this.dimAmount = .5,
    this.blockInputDuringTransition = false,
    this.backdropColor,
  });

  static const defaults = MiuixNavDisplayEffects();
  static const none = MiuixNavDisplayEffects(
    enableCornerClip: false,
    dimAmount: 0,
  );

  final bool enableCornerClip;
  final double cornerClipRadius;
  final MiuixNavCornerClipMode cornerClipMode;
  final double dimAmount;
  final bool blockInputDuringTransition;
  final Color? backdropColor;

  bool shouldClipCornersAt(double relativeDepth) {
    if (!enableCornerClip || !relativeDepth.isFinite) return false;
    return switch (cornerClipMode) {
      MiuixNavCornerClipMode.leading => relativeDepth > -1 && relativeDepth < 0,
      MiuixNavCornerClipMode.all =>
        relativeDepth > -1 && relativeDepth < 1 && relativeDepth != 0,
    };
  }

  bool shouldBlockInputAt(double relativeDepth) {
    if (!blockInputDuringTransition || !relativeDepth.isFinite) return false;
    return relativeDepth != relativeDepth.truncateToDouble();
  }

  MiuixNavDisplayEffects copyWith({
    bool? enableCornerClip,
    double? cornerClipRadius,
    MiuixNavCornerClipMode? cornerClipMode,
    double? dimAmount,
    bool? blockInputDuringTransition,
    Color? backdropColor,
    bool clearBackdropColor = false,
  }) => MiuixNavDisplayEffects(
    enableCornerClip: enableCornerClip ?? this.enableCornerClip,
    cornerClipRadius: cornerClipRadius ?? this.cornerClipRadius,
    cornerClipMode: cornerClipMode ?? this.cornerClipMode,
    dimAmount: dimAmount ?? this.dimAmount,
    blockInputDuringTransition:
        blockInputDuringTransition ?? this.blockInputDuringTransition,
    backdropColor: clearBackdropColor
        ? null
        : backdropColor ?? this.backdropColor,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MiuixNavDisplayEffects &&
          other.enableCornerClip == enableCornerClip &&
          other.cornerClipRadius == cornerClipRadius &&
          other.cornerClipMode == cornerClipMode &&
          other.dimAmount == dimAmount &&
          other.blockInputDuringTransition == blockInputDuringTransition &&
          other.backdropColor == backdropColor;

  @override
  int get hashCode => Object.hash(
    enableCornerClip,
    cornerClipRadius,
    cornerClipMode,
    dimAmount,
    blockInputDuringTransition,
    backdropColor,
  );
}

/// Render role derived from one entry's continuous relative depth.
enum MiuixNavRole { top, incoming, outgoing, covered }

/// Settle curve used by one navigation release phase.
sealed class MiuixNavSettleSpec {
  const MiuixNavSettleSpec();
}

final class MiuixNavSpringSettleSpec extends MiuixNavSettleSpec {
  factory MiuixNavSpringSettleSpec({
    double dampingRatio = 1,
    double stiffness = 146,
    bool clampOvershoot = true,
  }) {
    if (!dampingRatio.isFinite || dampingRatio <= 0) {
      throw ArgumentError.value(
        dampingRatio,
        'dampingRatio',
        'Must be finite and greater than zero.',
      );
    }
    if (!stiffness.isFinite || stiffness <= 0) {
      throw ArgumentError.value(
        stiffness,
        'stiffness',
        'Must be finite and greater than zero.',
      );
    }
    if (dampingRatio < 1 && clampOvershoot) {
      throw ArgumentError.value(
        clampOvershoot,
        'clampOvershoot',
        'Underdamped springs require clampOvershoot=false.',
      );
    }
    return MiuixNavSpringSettleSpec._(
      dampingRatio: dampingRatio,
      stiffness: stiffness,
      clampOvershoot: clampOvershoot,
    );
  }

  const MiuixNavSpringSettleSpec._({
    this.dampingRatio = 1,
    this.stiffness = 146,
    this.clampOvershoot = true,
  });

  final double dampingRatio;
  final double stiffness;
  final bool clampOvershoot;

  SpringDescription toSpringDescription() => SpringDescription.withDampingRatio(
    mass: 1,
    stiffness: stiffness,
    ratio: dampingRatio,
  );
}

final class MiuixNavTweenSettleSpec extends MiuixNavSettleSpec {
  const MiuixNavTweenSettleSpec({required this.duration, required this.curve});

  final Duration duration;
  final Curve curve;
}

/// Motion recipe governing commit, cancel, and programmatic navigation.
@immutable
class MiuixNavMotion {
  const MiuixNavMotion({
    this.commit = const MiuixNavSpringSettleSpec._(),
    this.cancel = const MiuixNavSpringSettleSpec._(),
    this.programmatic = const MiuixNavTweenSettleSpec(
      duration: Duration(milliseconds: 500),
      curve: MiuixNavigationTransitionCurve(),
    ),
  });

  static const defaults = MiuixNavMotion();

  final MiuixNavSettleSpec commit;
  final MiuixNavSettleSpec cancel;
  final MiuixNavSettleSpec programmatic;
}
