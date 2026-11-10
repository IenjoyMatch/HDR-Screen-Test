part of '../miuix_widgets.dart';

/// Applies an additional custom transform to a hosted visibility transition.
typedef MiuixVisibilityTransitionBuilder =
    Widget Function(
      BuildContext context,
      Animation<double> animation,
      Widget child,
    );

/// Composable Flutter counterpart of Compose EnterTransition/ExitTransition.
///
/// The animation always represents visibility: zero is fully hidden and one
/// is fully visible. Enter drives it forward; exit drives it in reverse.
@immutable
class MiuixVisibilityTransition {
  /// Creates a transition that can combine fade, scale, slide, and a custom
  /// wrapper, matching Compose's `transitionA + transitionB` composition.
  const MiuixVisibilityTransition({
    required this.duration,
    this.curve = Curves.linear,
    this.hiddenOpacity,
    this.hiddenScale,
    this.hiddenOffset,
    this.scaleAlignment = Alignment.center,
    this.builder,
  });

  /// Creates a fade between [hiddenOpacity] and full opacity.
  const MiuixVisibilityTransition.fade({
    required this.duration,
    this.curve = Curves.linear,
    this.hiddenOpacity = 0,
  }) : hiddenScale = null,
       hiddenOffset = null,
       scaleAlignment = Alignment.center,
       builder = null;

  /// Creates a scale transition with an optional simultaneous fade.
  const MiuixVisibilityTransition.scale({
    required this.duration,
    this.curve = Curves.linear,
    this.hiddenScale = .8,
    bool fade = false,
    this.scaleAlignment = Alignment.center,
  }) : hiddenOpacity = fade ? 0 : null,
       hiddenOffset = null,
       builder = null;

  /// Creates a fractional slide with an optional simultaneous fade.
  const MiuixVisibilityTransition.slide({
    required this.duration,
    required this.hiddenOffset,
    this.curve = Curves.linear,
    bool fade = false,
  }) : hiddenOpacity = fade ? 0 : null,
       hiddenScale = null,
       scaleAlignment = Alignment.center,
       builder = null;

  /// Creates a fully custom transition wrapper.
  const MiuixVisibilityTransition.custom({
    required this.duration,
    required MiuixVisibilityTransitionBuilder this.builder,
    this.curve = Curves.linear,
  }) : hiddenOpacity = null,
       hiddenScale = null,
       hiddenOffset = null,
       scaleAlignment = Alignment.center;

  /// Complete time from hidden to visible, or visible to hidden.
  final Duration duration;

  /// Fraction mapping applied before every configured transform.
  final Curve curve;

  /// Opacity at the hidden endpoint, or null when fade is not configured.
  final double? hiddenOpacity;

  /// Scale at the hidden endpoint, or null when scale is not configured.
  final double? hiddenScale;

  /// Fractional translation at the hidden endpoint.
  final Offset? hiddenOffset;

  /// Pivot used by the optional scale channel.
  final Alignment scaleAlignment;

  /// Optional caller-defined wrapper receiving the same curved fraction.
  final MiuixVisibilityTransitionBuilder? builder;

  /// Non-negative duration consumed by the hosted animation controllers.
  Duration get _safeDuration => duration.isNegative ? Duration.zero : duration;

  Widget _build(BuildContext context, Animation<double> parent, Widget child) {
    final curved = CurvedAnimation(
      parent: parent,
      curve: curve,
      reverseCurve: curve,
    );
    var result = builder?.call(context, curved, child) ?? child;
    if (hiddenOffset case final offset?) {
      final safeOffset = Offset(
        offset.dx.isFinite ? offset.dx : 0,
        offset.dy.isFinite ? offset.dy : 0,
      );
      result = SlideTransition(
        position: Tween<Offset>(
          begin: safeOffset,
          end: Offset.zero,
        ).animate(curved),
        child: result,
      );
    }
    if (hiddenScale case final scale?) {
      final safeScale = scale.isFinite ? math.max(0.0, scale) : 0.0;
      result = ScaleTransition(
        scale: Tween<double>(begin: safeScale, end: 1).animate(curved),
        alignment: scaleAlignment,
        child: result,
      );
    }
    if (hiddenOpacity case final opacity?) {
      final safeOpacity = opacity.isFinite ? opacity.clamp(0.0, 1.0) : 0.0;
      result = FadeTransition(
        opacity: Tween<double>(begin: safeOpacity, end: 1).animate(curved),
        child: result,
      );
    }
    return result;
  }
}

/// Source-level registration wrapper for MIUIX dialog content.
///
/// `DialogLayout` does not paint a surface at its call site. It registers one
/// stateful entry with the nearest popup host, which then owns z order,
/// dimming, animation, root-scaffold routing, and exit completion.
class MiuixDialogLayout extends StatelessWidget {
  /// Retains the pre-1.0.9 inline-surface API for existing Flutter callers.
  ///
  /// New source-parity code should use [MiuixDialogLayout.source].
  const MiuixDialogLayout({super.key, required this.child})
    : visible = null,
      enableWindowDim = true,
      enableAutoLargeScreen = true,
      enterTransition = null,
      exitTransition = null,
      dimEnterTransition = null,
      dimExitTransition = null,
      dimAlpha = null,
      onDismissFinished = null,
      renderInRootScaffold = true;

  /// Creates the Flutter counterpart of `MiuixPopupUtils.DialogLayout`.
  const MiuixDialogLayout.source({
    super.key,
    required ValueNotifier<bool> this.visible,
    required this.child,
    this.enableWindowDim = true,
    this.enableAutoLargeScreen = true,
    this.enterTransition,
    this.exitTransition,
    this.dimEnterTransition,
    this.dimExitTransition,
    this.dimAlpha,
    this.onDismissFinished,
    this.renderInRootScaffold = true,
  });

  /// Mutable source visibility state.
  ///
  /// Changing this notifier to true registers the entry. Changing it to false
  /// begins the exit transition and keeps the entry mounted until it settles.
  final ValueNotifier<bool>? visible;

  /// Full-screen dialog content registered with the host.
  final Widget child;

  /// Whether the host paints the semantic window-dimming color.
  final bool enableWindowDim;

  /// Whether a window at least 840×480dp uses fade plus 0.8 scale.
  ///
  /// When false, the compact slide-up transition is retained at every size.
  final bool enableAutoLargeScreen;

  /// Optional source content-enter transition.
  final MiuixVisibilityTransition? enterTransition;

  /// Optional source content-exit transition.
  final MiuixVisibilityTransition? exitTransition;

  /// Optional source dim-layer enter transition.
  final MiuixVisibilityTransition? dimEnterTransition;

  /// Optional source dim-layer exit transition.
  final MiuixVisibilityTransition? dimExitTransition;

  /// Optional live multiplier for the dim layer.
  ///
  /// The source clamps this value to zero through one and multiplies it with
  /// the animated dim alpha instead of replacing the dim animation.
  final ValueListenable<double>? dimAlpha;

  /// Called only after the exit animation and physical host removal finish.
  final VoidCallback? onDismissFinished;

  /// Whether to register in the outermost Scaffold host.
  final bool renderInRootScaffold;

  @override
  Widget build(BuildContext context) {
    final sourceVisible = visible;
    if (sourceVisible == null) {
      final hyperOs4 = MiuixTheme.of(context).hyperOs4;
      return MiuixSurface(
        glass: true,
        glassBlur: hyperOs4.dialogBlur,
        glassOpacity: hyperOs4.dialogTintOpacity,
        glassOptics: MiuixGlassOptics.transient,
        radius: hyperOs4.dialogCornerRadius,
        child: child,
      );
    }
    return _MiuixSourceHostedLayout(
      visible: sourceVisible,
      kind: _MiuixSourceHostedLayoutKind.dialog,
      enableWindowDim: enableWindowDim,
      enableAutoLargeScreen: enableAutoLargeScreen,
      enterTransition: enterTransition,
      exitTransition: exitTransition,
      dimEnterTransition: dimEnterTransition,
      dimExitTransition: dimExitTransition,
      dimAlpha: dimAlpha,
      onDismissFinished: onDismissFinished,
      renderInRootScaffold: renderInRootScaffold,
      child: child,
    );
  }
}

/// Source-level registration wrapper for arbitrary popup content.
///
/// The source helper owns only host registration, fade, dimming, Back, and
/// z-order lifecycle. Anchored ListPopup geometry and its spring/reveal motion
/// remain the responsibility of `ListPopupLayout` and `ListPopupContent`.
class MiuixPopupLayout extends StatelessWidget {
  /// Retains the former inline glass-surface API.
  ///
  /// New source-parity code should use [MiuixPopupLayout.source].
  const MiuixPopupLayout({super.key, required this.child})
    : visible = null,
      enableWindowDim = true,
      enableBackHandler = true,
      enterTransition = null,
      exitTransition = null,
      dimEnterTransition = null,
      dimExitTransition = null,
      onDismissFinished = null,
      renderInRootScaffold = true;

  /// Creates the Flutter counterpart of `MiuixPopupUtils.PopupLayout`.
  const MiuixPopupLayout.source({
    super.key,
    required ValueNotifier<bool> this.visible,
    required this.child,
    this.enableWindowDim = true,
    this.enableBackHandler = true,
    this.enterTransition,
    this.exitTransition,
    this.dimEnterTransition,
    this.dimExitTransition,
    this.onDismissFinished,
    this.renderInRootScaffold = true,
  });

  /// Mutable source visibility state.
  final ValueNotifier<bool>? visible;

  /// Full-screen popup content registered with the host.
  final Widget child;

  /// Whether the host paints the semantic window-dimming color.
  final bool enableWindowDim;

  /// Whether Android Back changes [visible] to false.
  final bool enableBackHandler;

  /// Optional source content-enter transition.
  final MiuixVisibilityTransition? enterTransition;

  /// Optional source content-exit transition.
  final MiuixVisibilityTransition? exitTransition;

  /// Optional source dim-layer enter transition.
  final MiuixVisibilityTransition? dimEnterTransition;

  /// Optional source dim-layer exit transition.
  final MiuixVisibilityTransition? dimExitTransition;

  /// Called after exit animation and physical removal.
  final VoidCallback? onDismissFinished;

  /// Whether to register in the outermost Scaffold host.
  final bool renderInRootScaffold;

  @override
  Widget build(BuildContext context) {
    final sourceVisible = visible;
    if (sourceVisible == null) {
      final hyperOs4 = MiuixTheme.of(context).hyperOs4;
      return MiuixSurface(
        glass: true,
        glassBlur: hyperOs4.popupBlur,
        glassOpacity: hyperOs4.popupTintOpacity,
        glassOptics: MiuixGlassOptics.transient,
        radius: hyperOs4.popupCornerRadius,
        child: child,
      );
    }
    return _MiuixSourceHostedLayout(
      visible: sourceVisible,
      kind: _MiuixSourceHostedLayoutKind.popup,
      enableWindowDim: enableWindowDim,
      enableBackHandler: enableBackHandler,
      enterTransition: enterTransition,
      exitTransition: exitTransition,
      dimEnterTransition: dimEnterTransition,
      dimExitTransition: dimExitTransition,
      onDismissFinished: onDismissFinished,
      renderInRootScaffold: renderInRootScaffold,
      child: child,
    );
  }
}

enum _MiuixSourceHostedLayoutKind { dialog, popup }

/// Shared registration state for the two public source wrappers.
///
/// It intentionally renders no local child. Compose's helper also leaves only
/// a registration side effect at its call site; the PopupHost paints content.
class _MiuixSourceHostedLayout extends StatefulWidget {
  const _MiuixSourceHostedLayout({
    required this.visible,
    required this.kind,
    required this.enableWindowDim,
    required this.renderInRootScaffold,
    required this.child,
    this.enableBackHandler = false,
    this.enableAutoLargeScreen = true,
    this.enterTransition,
    this.exitTransition,
    this.dimEnterTransition,
    this.dimExitTransition,
    this.dimAlpha,
    this.onDismissFinished,
  });

  final ValueNotifier<bool> visible;
  final _MiuixSourceHostedLayoutKind kind;
  final bool enableWindowDim;
  final bool enableBackHandler;
  final bool enableAutoLargeScreen;
  final MiuixVisibilityTransition? enterTransition;
  final MiuixVisibilityTransition? exitTransition;
  final MiuixVisibilityTransition? dimEnterTransition;
  final MiuixVisibilityTransition? dimExitTransition;
  final ValueListenable<double>? dimAlpha;
  final VoidCallback? onDismissFinished;
  final bool renderInRootScaffold;
  final Widget child;

  @override
  State<_MiuixSourceHostedLayout> createState() =>
      _MiuixSourceHostedLayoutState();
}

class _MiuixSourceHostedLayoutState extends State<_MiuixSourceHostedLayout> {
  MiuixPopupHostController? _nearestHost;
  MiuixPopupHostController? _entryHost;
  _MiuixHostedPopup<void>? _entry;
  Color? _resolvedDimColor;
  late int _sourceZIndex;
  bool? _lastSynchronizedVisibility;
  var _replaceEntryForStateIdentity = false;
  var _syncScheduled = false;

  bool get _isDialog => widget.kind == _MiuixSourceHostedLayoutKind.dialog;

  MiuixPopupHostController? get _targetHost {
    final host = _nearestHost;
    if (host == null) {
      return null;
    }
    return widget.renderInRootScaffold ? host.root : host;
  }

  Widget get _hostChild => SizedBox.expand(child: widget.child);

  @override
  void initState() {
    super.initState();
    // Upstream remember(visible) allocates z-index at composition time, not
    // when the caller eventually opens the surface.
    _sourceZIndex = _miuixNextHostedPopupZIndex++;
    widget.visible.addListener(_visibilityChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextHost = MiuixPopupHostScope.maybeOf(context);
    final nextDimColor = MiuixSemanticColors.of(context)['windowDimming'];
    final hostChanged = !identical(nextHost, _nearestHost);
    final dimColorChanged = nextDimColor != _resolvedDimColor;
    _resolvedDimColor = nextDimColor;
    if (hostChanged) {
      _nearestHost = nextHost;
      _rehostIfNeeded();
    } else if (dimColorChanged) {
      _scheduleSync();
    }
  }

  @override
  void didUpdateWidget(covariant _MiuixSourceHostedLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    final visibleChanged = !identical(oldWidget.visible, widget.visible);
    final hostRouteChanged =
        oldWidget.renderInRootScaffold != widget.renderInRootScaffold ||
        oldWidget.kind != widget.kind;
    final entryConfigurationChanged =
        !identical(oldWidget.child, widget.child) ||
        oldWidget.enableWindowDim != widget.enableWindowDim ||
        oldWidget.enableBackHandler != widget.enableBackHandler ||
        oldWidget.enableAutoLargeScreen != widget.enableAutoLargeScreen ||
        oldWidget.enterTransition != widget.enterTransition ||
        oldWidget.exitTransition != widget.exitTransition ||
        oldWidget.dimEnterTransition != widget.dimEnterTransition ||
        oldWidget.dimExitTransition != widget.dimExitTransition ||
        !identical(oldWidget.dimAlpha, widget.dimAlpha);

    if (visibleChanged) {
      oldWidget.visible.removeListener(_visibilityChanged);
      _setFalseIfNeeded(oldWidget.visible);
      widget.visible.addListener(_visibilityChanged);
      _sourceZIndex = _miuixNextHostedPopupZIndex++;
      _lastSynchronizedVisibility = null;
      _replaceEntryForStateIdentity = _entry != null;
    }

    if (hostRouteChanged) {
      _rehostIfNeeded();
    } else if (visibleChanged || entryConfigurationChanged) {
      // Defer host notification until after this build. Calling setState on
      // the host from didUpdateWidget would violate Flutter's build contract.
      _scheduleSync();
    }
  }

  @override
  void dispose() {
    widget.visible.removeListener(_visibilityChanged);
    _setFalseIfNeeded(widget.visible);
    final entry = _entry;
    if (entry != null && entry.visible) {
      final host = _entryHost;
      // Element disposal runs while Flutter's tree is locked. Source still
      // writes false immediately, but host notification must wait until the
      // current frame has completed finalization.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (host != null && !host._disposed) {
          host._dismiss(entry);
        }
      });
      WidgetsBinding.instance.ensureVisualUpdate();
    }
    super.dispose();
  }

  void _setFalseIfNeeded(ValueNotifier<bool> notifier) {
    if (!notifier.value) {
      return;
    }
    try {
      // DisposableEffect writes false when a composed source registration is
      // removed. Tolerate a caller that disposed its notifier prematurely.
      notifier.value = false;
    } on FlutterError {
      // A disposed ChangeNotifier rejects notification in debug mode.
    }
  }

  void _visibilityChanged() => _scheduleSync();

  void _rehostIfNeeded() {
    // Host notification cannot occur during dependency or widget updates.
    // The post-frame synchronization compares the target and dismisses there.
    _scheduleSync();
  }

  void _scheduleSync() {
    if (_syncScheduled || !mounted) {
      return;
    }
    _syncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncScheduled = false;
      if (mounted) {
        _syncVisibility();
      }
    });
    // ValueNotifier updates may arrive while the scheduler is idle. A
    // post-frame callback alone does not request a frame, so explicitly wake
    // the pipeline or a close request could remain pending until unrelated UI
    // activity occurs.
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  void _syncVisibility() {
    final entry = _entry;
    if (_replaceEntryForStateIdentity) {
      if (entry != null) {
        if (entry.visible) {
          _entryHost?._dismiss(entry);
        }
        return;
      }
      _replaceEntryForStateIdentity = false;
    }

    final expectedTransition = _isDialog
        ? _MiuixHostedPopupTransition.dialog
        : _MiuixHostedPopupTransition.fade;
    if (entry != null &&
        (!identical(_targetHost, _entryHost) ||
            entry.transition != expectedTransition)) {
      if (entry.visible) {
        _entryHost?._dismiss(entry);
      }
      return;
    }

    final currentVisibility = widget.visible.value;
    final visibilityChanged = currentVisibility != _lastSynchronizedVisibility;
    _lastSynchronizedVisibility = currentVisibility;
    if (!currentVisibility) {
      if (_isDialog && visibilityChanged) {
        // DialogEntry hides the active software keyboard whenever its target
        // changes to false. Unfocus is Flutter's cross-platform equivalent.
        FocusManager.instance.primaryFocus?.unfocus();
      }
      if (entry != null && entry.visible) {
        _entryHost?._dismiss(entry);
      }
      return;
    }
    if (entry != null) {
      // A false-to-true change during exit is queued until the old entry is
      // physically removed, matching the source pendingOpen behavior.
      if (!entry.visible) {
        return;
      }
      entry.child = _hostChild;
      entry.dimBackground = widget.enableWindowDim;
      entry.dimColor = _resolvedDimColor;
      entry.dimAlpha = _isDialog ? widget.dimAlpha : null;
      entry.enableBackHandler = !_isDialog && widget.enableBackHandler;
      entry.enableAutoLargeScreen = widget.enableAutoLargeScreen;
      entry.enterTransition = widget.enterTransition;
      entry.exitTransition = widget.exitTransition;
      entry.dimEnterTransition = widget.dimEnterTransition;
      entry.dimExitTransition = widget.dimExitTransition;
      _entryHost?._refreshEntry(entry);
      return;
    }
    _open();
  }

  void _open() {
    final host = _targetHost;
    if (host == null || !widget.visible.value) {
      return;
    }

    late _MiuixHostedPopup<void> createdEntry;
    _entryHost = host;
    unawaited(
      host.show<void>(
        child: _hostChild,
        zIndex: _sourceZIndex,
        dimBackground: widget.enableWindowDim,
        dimColor: _resolvedDimColor,
        dimAlpha: _isDialog ? widget.dimAlpha : null,
        fadeTransition: !_isDialog,
        dialogTransition: _isDialog,
        enterTransition: widget.enterTransition,
        exitTransition: widget.exitTransition,
        dimEnterTransition: widget.dimEnterTransition,
        dimExitTransition: widget.dimExitTransition,
        barrierDismissible: false,
        enableBackHandler: !_isDialog && widget.enableBackHandler,
        enableAutoLargeScreen: widget.enableAutoLargeScreen,
        onDismissRequest: !_isDialog && widget.enableBackHandler
            ? () {
                if (widget.visible.value) {
                  widget.visible.value = false;
                }
              }
            : null,
        onDismissFinished: () {
          if (identical(_entry, createdEntry)) {
            _entry = null;
            _entryHost = null;
          }
          widget.onDismissFinished?.call();
          _scheduleSync();
        },
      ),
    );
    createdEntry = host._entries.last as _MiuixHostedPopup<void>;
    _entry = createdEntry;
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
