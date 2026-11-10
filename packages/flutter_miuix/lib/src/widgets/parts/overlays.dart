part of '../miuix_widgets.dart';

// Dialog motion source contract
// -----------------------------
// The authoritative implementation is DialogContentLayout.kt in MIUIX.
// OverlayDialog and WindowDialog both delegate their motion to that layout.
// They therefore share panel geometry, timing, easing, and dim behavior.
// Flutter's stock showGeneralDialog does not preserve all of those details.
// In particular, it gives the panel and modal barrier one normalized curve.
// It also uses the same duration for the forward and reverse route by default.
// The source runs its panel and dim animations concurrently but independently.
// This file keeps that separation even though both values use one route clock.
// The route clock lasts 520ms while the entrance spring finishes settling.
// The dim curve consumes only the first 300ms of that forward route clock.
// The reverse route clock lasts 260ms, matching the source panel tween.
// The reverse dim consumes 250ms and remains transparent for the final 10ms.
// Compact dialogs animate along the vertical axis from one viewport below.
// Large dialogs animate opacity and scale from 0.8 around their center.
// The compact spring uses dampingRatio 0.88 and stiffness 450 exactly.
// The large spring uses dampingRatio 0.9 and stiffness about 438.6 exactly.
// That large stiffness is derived by folmeSpring from a 0.3 second response.
// Neither spring should be replaced by easeOutCubic or a Material curve.
// A cubic curve removes the small settling motion visible in the original.
// It also reaches the final position much too early on high-refresh displays.
// Compose treats mass as one, so natural frequency is sqrt(stiffness).
// For an underdamped spring, damped frequency is wn*sqrt(1-zeta squared).
// The unit-step response begins at zero and converges toward one.
// It may cross one slightly; that small overshoot is intentional MIUIX motion.
// Flutter permits a Curve to return a value just outside the zero-to-one range.
// The final route tick is forced to exactly one by CurvedAnimation itself.
// This prevents any residual subpixel offset after the route becomes idle.
// The source visibility threshold is 0.0001 for the compact entrance spring.
// A 520ms sampling window reaches that threshold for the upstream parameters.
// Reducing the window makes the panel visibly snap during its final approach.
// Increasing it delays focus and interaction longer than the original does.
// Entrance dimming uses Android DecelerateInterpolator with factor 1.5.
// Its exact equation is one minus one-minus-t raised to the third power.
// Flutter's named ease-out curves are close but do not use that equation.
// Exit panel motion uses the same DecelerateEasing over exactly 260ms.
// On a descending route clock, its remaining value is t raised to the third.
// Exit dimming uses the same easing independently over exactly 250ms.
// The ten millisecond timing difference is preserved instead of rounded away.
// The barrier color comes from MIUIX windowDimming semantic color.
// It must not be replaced by Material's default black 54-percent scrim.
// A transparent barrier still owns taps so background content cannot activate.
// Barrier dismissal follows the caller's barrierDismissible setting.
// System Back must request dismissal before the route or host entry is removed.
// onDismissRequest fires once when dismissal begins, never after completion.
// onDismissFinished fires after the reverse animation and physical removal.
// Overlay-hosted dialogs do not push a Navigator route of their own.
// The popup host therefore owns a PopScope while any hosted entry is present.
// That PopScope remains locked throughout the reverse animation.
// A second fast Back press must not escape to and close the application page.
// Window dialogs do push a root Navigator route for platform-level coverage.
// Their custom RawDialogRoute supplies a distinct reverseTransitionDuration.
// The custom modal barrier gives dimming its independent source timing.
// Page content is wrapped in the caller's captured Theme for route stability.
// Compact and large mode are decided from the pre-route MediaQuery size.
// The source threshold requires width at least 840 and height at least 480.
// Matching only width would incorrectly center dialogs in short desktop panes.
// Compact content remains bottom-centered throughout every animation frame.
// Its system bottom inset is added before the explicit 12dp outside margin.
// SafeArea.minimum cannot express that sum and must not be used here.
// IME and navigation insets are mutually obstructive in this dialog context.
// The larger bottom obstruction is therefore used before adding the margin.
// Left and right outside margins remain 12dp on compact screens.
// The compact panel maximum width remains 420dp, matching the source default.
// Default content padding remains 24dp on all four sides inside the shape.
// Specialized source components may override that DpSize-derived padding.
// The minimum bottom corner radius remains 32dp before platform adjustment.
// MIUIX smooth G2 geometry is used whenever the squircle option is enabled.
// A circular RoundedRectangleBorder is not equivalent near the side arcs.
// The ShapeBorder also clips descendants so children cannot leak at corners.
// Dialog title metrics remain 18sp, medium weight, and centered.
// Summary metrics remain 16sp and use onSurfaceSecondary semantic color.
// Title and summary each reserve 12dp below their text when present.
// Action layout belongs to the content surface and moves with the same panel.
// Predictive Back is a separate gesture transform layered over these timings.
// Compact panels travel by measured height plus their bottom insets and margin.
// Large panels scale from one toward 0.8 while the dim alpha follows 1-progress.
// Cancellation restores both channels over the source 150ms tween; commitment
// retains the release pose while the ordinary dismiss animation runs beneath it.
// Reduced-motion policy may shorten animation, but default motion stays exact.
// Widget tests wait through 280ms before checking completed reverse lifecycle.
// Golden expanded states wait 600ms so they never capture a settling half-frame.
// Runtime screenshots compare the fully settled geometry, not transition blur.
// On the Android reference emulator the center edge differs by at most one px.
// The smooth side arc differs by at most two px after device rasterization.
// The outermost antialias fringe can vary because Flutter and Skia sample edges.
// Such fringe differences must not be "fixed" by changing the logical radius.
// The numerical curve classes below are private implementation details.
// Public callers continue to use MiuixDialog, OverlayDialog, or WindowDialog.
// Keeping constants private prevents apps from depending on temporary clocks.
// Source changes should be reconciled here and in the lifecycle tests together.
// Any duration change also requires checking popup-host Back ownership timing.
// Any shape change also requires regenerating only the affected golden images.
// Static analyzer success is required after route or barrier overrides change.
// Android runtime verification is required because widget tests lack system Back.
// Windows verification is required because large-screen mode follows another path.
// These notes intentionally document invariants beside the implementation.
// They are maintenance constraints, not a substitute for executable tests.

// Compose's DecelerateEasing(1.5) is the Android decelerate interpolator with
// an exponent of three. Keeping it as a named curve avoids substituting a
// visually similar cubic Bezier that drifts most noticeably near the end.
class _MiuixDecelerateCurve extends Curve {
  const _MiuixDecelerateCurve();

  @override
  double transformInternal(double t) => 1 - math.pow(1 - t, 3).toDouble();
}

// When a value animates from one back to zero with DecelerateEasing(1.5), its
// remaining value is t cubed on Flutter's descending route timeline.
class _MiuixAccelerateCurve extends Curve {
  const _MiuixAccelerateCurve();

  @override
  double transformInternal(double t) => t * t * t;
}

// DialogContentLayout.kt uses a physical spring rather than a fixed easing for
// its entrance. This is the closed-form unit-step response for that same
// underdamped spring. The duration only defines the sampled time window; the
// damping and stiffness remain the upstream values.
class _MiuixDialogSpringCurve extends Curve {
  const _MiuixDialogSpringCurve({
    required this.dampingRatio,
    required this.stiffness,
    this.sampledSeconds = .52,
  });

  final double dampingRatio;
  final double stiffness;
  final double sampledSeconds;

  @override
  double transformInternal(double t) {
    final naturalFrequency = math.sqrt(stiffness);
    final dampedFactor = math.sqrt(1 - dampingRatio * dampingRatio);
    final dampedFrequency = naturalFrequency * dampedFactor;
    final seconds = t * sampledSeconds;
    final envelope = math.exp(-dampingRatio * naturalFrequency * seconds);
    final oscillation =
        math.cos(dampedFrequency * seconds) +
        dampingRatio / dampedFactor * math.sin(dampedFrequency * seconds);
    return 1 - envelope * oscillation;
  }
}

// A descending Compose animateTo call is the complement of the corresponding
// zero-to-one spring response. CurvedAnimation otherwise time-reverses the
// forward curve, which has a visibly different early velocity.
class _MiuixSpringReverseCurve extends Curve {
  const _MiuixSpringReverseCurve(this.forward);

  final Curve forward;

  @override
  double transformInternal(double t) => 1 - forward.transform(1 - t);
}

const _miuixBottomSheetVisibilityDuration = Duration(milliseconds: 680);
const _miuixBottomSheetVisibilityCurve = _MiuixDialogSpringCurve(
  dampingRatio: .9,
  // (2*pi/0.38)^2 from folmeSpring(response=.38), with unit mass.
  stiffness: 273.396243797489,
  sampledSeconds: .68,
);
const _miuixBottomSheetVisibilityReverseCurve = _MiuixSpringReverseCurve(
  _miuixBottomSheetVisibilityCurve,
);

// BottomSheetContentLayout.kt uses a second spring for every pointer-drag
// settlement, including both dismissal and return-to-rest. Its response value
// is converted with the same mass-one Folme equation used by the source.
final SpringDescription _miuixBottomSheetSettleSpring = SpringDescription(
  mass: 1,
  stiffness: math.pow(2 * math.pi / .4, 2).toDouble(),
  damping: 2 * .85 * math.sqrt(math.pow(2 * math.pi / .4, 2).toDouble()),
);

// The dim layer finishes in 300ms even though the panel spring continues to
// settle. The exit layer follows the source's independent 250ms duration.
class _MiuixDialogDimEnterCurve extends Curve {
  const _MiuixDialogDimEnterCurve();

  @override
  double transformInternal(double t) {
    final sourceProgress = math.min(t * 520 / 300, 1.0);
    return const _MiuixDecelerateCurve().transform(sourceProgress);
  }
}

class _MiuixDialogDimExitCurve extends Curve {
  const _MiuixDialogDimExitCurve();

  @override
  double transformInternal(double t) {
    final sourceProgress = ((t * 260 - 10) / 250).clamp(0.0, 1.0);
    return const _MiuixAccelerateCurve().transform(sourceProgress);
  }
}

// DialogContentLayout owns a second, gesture-driven progress value in addition
// to its ordinary enter/exit animation. The value below exposes the inverse as
// a ValueListenable because the popup host multiplies its settled dim layer by
// `1 - backProgress`, exactly like the source's mutable dimAlpha state.
abstract interface class _MiuixPredictiveBackProgress
    implements ValueListenable<double> {
  double get progress;

  void update(double progress);
}

class _MiuixDialogBackProgress extends ChangeNotifier
    implements _MiuixPredictiveBackProgress {
  double _progress = 0;

  @override
  double get progress => _progress;

  @override
  double get value => 1 - _progress;

  @override
  void update(double progress) {
    final next = progress.clamp(0.0, 1.0);
    if ((next - _progress).abs() <= 1e-9) return;
    _progress = next;
    notifyListeners();
  }
}

// Supplies the route- or host-owned gesture progress to MiuixDialog without
// adding a public controller that does not exist in the Compose API.
class _MiuixDialogBackScope extends InheritedWidget {
  const _MiuixDialogBackScope({required this.controller, required super.child});

  final _MiuixDialogBackProgress controller;

  static _MiuixDialogBackProgress? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_MiuixDialogBackScope>()
      ?.controller;

  @override
  bool updateShouldNotify(_MiuixDialogBackScope oldWidget) =>
      !identical(controller, oldWidget.controller);
}

// Claims Android predictive Back only while its own dialog is the active Back
// owner. Button Back remains on Flutter's normal PopScope/Navigator path.
class _MiuixPredictiveBackObserver extends StatefulWidget {
  const _MiuixPredictiveBackObserver({
    required this.controller,
    required this.canStart,
    required this.onCommit,
    required this.child,
  });

  final _MiuixPredictiveBackProgress controller;
  final bool Function() canStart;
  final VoidCallback onCommit;
  final Widget child;

  @override
  State<_MiuixPredictiveBackObserver> createState() =>
      _MiuixPredictiveBackObserverState();
}

class _MiuixPredictiveBackObserverState
    extends State<_MiuixPredictiveBackObserver>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late final AnimationController _resetAnimation;
  double _resetStart = 0;
  bool _ownsGesture = false;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _resetAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    )..addListener(_tickReset);
    _MiuixPredictiveBackOwnerRegistry.instance.register(
      this,
      (event) => widget.canStart(),
      context: () => context,
    );
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion == _reduceMotion) return;
    _reduceMotion = reduceMotion;
    if (_reduceMotion && _resetAnimation.isAnimating) {
      _resetAnimation.stop();
      widget.controller.update(0);
    }
  }

  void _tickReset() {
    final eased = Curves.fastOutSlowIn.transform(_resetAnimation.value);
    widget.controller.update(_resetStart * (1 - eased));
  }

  @override
  bool handleStartBackGesture(PredictiveBackEvent backEvent) {
    if (backEvent.isButtonEvent ||
        !_MiuixPredictiveBackOwnerRegistry.instance.isTop(this, backEvent) ||
        !widget.canStart()) {
      return false;
    }
    _resetAnimation.stop();
    _ownsGesture = true;
    widget.controller.update(backEvent.progress);
    return true;
  }

  @override
  void handleUpdateBackGestureProgress(PredictiveBackEvent backEvent) {
    if (_ownsGesture) widget.controller.update(backEvent.progress);
  }

  @override
  void handleCancelBackGesture() {
    if (!_ownsGesture) return;
    _ownsGesture = false;
    _resetStart = widget.controller.progress;
    if (_resetStart <= 1e-9) {
      widget.controller.update(0);
      return;
    }
    if (_reduceMotion) {
      widget.controller.update(0);
      return;
    }
    _resetAnimation.forward(from: 0);
  }

  @override
  void handleCommitBackGesture() {
    // 拖动期间出现保护层时只取消，不关闭其后的浮层。
    if (MiuixBackGestureScope.blockedOf(context)) {
      handleCancelBackGesture();
      return;
    }
    if (!_ownsGesture) return;
    _ownsGesture = false;
    _resetAnimation.stop();
    widget.onCommit();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _MiuixPredictiveBackOwnerRegistry.instance.unregister(this);
    _resetAnimation
      ..removeListener(_tickReset)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _MiuixBackGuard(child: widget.child);
}

/// Public defaults shared by overlay- and window-hosted MIUIX dialogs.
abstract final class MiuixDialogDefaults {
  /// Upper width bound from `DialogDefaults.MaxWidth`.
  static const double maxWidth = 420;

  /// Centered-dialog radius from `DialogDefaults.CornerRadius`.
  static const double cornerRadius = 32;

  /// Source outside width and bottom margin represented as Flutter insets.
  static const EdgeInsets outsideMargin = EdgeInsets.fromLTRB(12, 0, 12, 12);

  /// Source inside width and height margins.
  static const EdgeInsets insideMargin = EdgeInsets.all(24);

  /// Resolves `DialogDefaults.titleColor()`.
  static Color titleColor(BuildContext context) =>
      MiuixSemanticColors.of(context)['onBackground'];

  /// Resolves `DialogDefaults.summaryColor()`.
  static Color summaryColor(BuildContext context) =>
      MiuixSemanticColors.of(context)['onSurfaceSecondary'];

  /// Resolves `DialogDefaults.backgroundColor()`.
  static Color backgroundColor(BuildContext context) =>
      MiuixSemanticColors.of(context)['background'];
}

/// Public defaults shared by overlay- and window-hosted bottom sheets.
abstract final class MiuixBottomSheetDefaults {
  /// Source top-corner radius.
  static const double cornerRadius = 28;

  /// Source maximum panel width.
  static const double maxWidth = 640;

  /// Source outside margin.
  static const EdgeInsets outsideMargin = EdgeInsets.zero;

  /// Source horizontal and bottom content margin.
  static const EdgeInsets insideMargin = EdgeInsets.symmetric(horizontal: 24);

  /// Resolves `BottomSheetDefaults.backgroundColor()`.
  static Color backgroundColor(BuildContext context) =>
      MiuixSemanticColors.of(context)['background'];

  /// Resolves the resting 20-percent drag-handle tint.
  static Color dragHandleColor(BuildContext context) => MiuixSemanticColors.of(
    context,
  )['onSurfaceVariantSummary'].withValues(alpha: .2);
}

// Compose WindowInsets retain consumption state across a hosted composition.
// Flutter's MediaQuery viewPadding does not, so the overlay adapter supplies
// the consumed source top inset without mutating the MediaQuery seen by the
// popup host or by arbitrary dialog content.
class _MiuixDialogHostInsets extends InheritedWidget {
  const _MiuixDialogHostInsets({required this.top, required super.child});

  final double top;

  static double? maybeTopOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_MiuixDialogHostInsets>()?.top;

  @override
  bool updateShouldNotify(_MiuixDialogHostInsets oldWidget) =>
      top != oldWidget.top;
}

const _miuixDialogEnterDuration = Duration(milliseconds: 520);
const _miuixDialogExitDuration = Duration(milliseconds: 260);

class _MiuixDialogRoute<T> extends RawDialogRoute<T> {
  _MiuixDialogRoute({
    required this.backProgress,
    required this.reduceMotion,
    required super.pageBuilder,
    required super.barrierDismissible,
    required super.barrierColor,
    required super.barrierLabel,
    required super.transitionBuilder,
    super.requestFocus,
  }) : super(
         transitionDuration: reduceMotion
             ? Duration.zero
             : _miuixDialogEnterDuration,
       );

  final _MiuixDialogBackProgress backProgress;
  final bool reduceMotion;

  @override
  Duration get reverseTransitionDuration =>
      reduceMotion ? Duration.zero : _miuixDialogExitDuration;

  @override
  void dispose() {
    // Route disposal happens only after its page and modal-barrier listeners
    // have detached, so it is the safe ownership boundary for this controller.
    backProgress.dispose();
    super.dispose();
  }

  @override
  Widget buildModalBarrier() {
    final color = barrierColor;
    if (color == null || color.a == 0 || offstage) {
      return super.buildModalBarrier();
    }
    final opacity = CurvedAnimation(
      parent: animation!,
      curve: const _MiuixDialogDimEnterCurve(),
      reverseCurve: const _MiuixDialogDimExitCurve(),
    );
    return AnimatedBuilder(
      animation: Listenable.merge([opacity, backProgress]),
      builder: (context, child) => ModalBarrier(
        color: color.withValues(
          alpha: color.a * opacity.value * backProgress.value,
        ),
        dismissible: barrierDismissible,
        semanticsLabel: barrierLabel,
        barrierSemanticsDismissible: semanticsDismissible,
      ),
    );
  }
}

/// Dialog helper matching Miuix naming.
// Source parity notes for DialogContentLayout.kt:
// - Compact windows align the panel to BottomCenter.
// - Large windows require both width >= 840 and height >= 480.
// - The compact panel keeps 12dp outside margins on three visible edges.
// - Its bottom margin is added after the navigation/caption-bar inset.
// - The panel background is the MIUIX `background` semantic role.
// - The minimum compact corner is 32dp.
// - Content padding is 24dp on every side.
// - The title uses title4 size, which is 18sp in the default text table.
// - The title weight is Medium and its alignment is centered.
// - A summary uses body1 size, 16sp, and onSurfaceSecondary.
// - Title and summary each reserve 12dp beneath themselves.
// - Compact entrance moves vertically from one full viewport below.
// - Wide entrance fades and scales from 0.8 around the center.
// - Window dimming comes from the semantic palette, not Material scrim.
// These rules deliberately live beside the widget instead of only in tests.
// That makes later visual refactors preserve MIUIX behavior by construction.
class MiuixDialog extends StatelessWidget {
  /// Creates a dialog.
  const MiuixDialog({
    super.key,
    this.title,
    this.summary,
    required this.content,
    this.actions = const [],
    this.titleColor,
    this.summaryColor,
    this.backgroundColor,
    this.outsideMargin = MiuixDialogDefaults.outsideMargin,
    this.insideMargin = MiuixDialogDefaults.insideMargin,
    this.defaultWindowInsetsPadding = true,
    this.maxWidth = MiuixDialogDefaults.maxWidth,
    this.largeScreen,
    this.cornerRadius,
    this.glass = true,
    this.surfaceBuilder,
  });

  /// Dialog title.
  final String? title;

  /// Optional centered summary below the title.
  final String? summary;

  /// Optional source title color override.
  final Color? titleColor;

  /// Optional source summary color override.
  final Color? summaryColor;

  /// Optional source panel fill override.
  final Color? backgroundColor;

  /// Dialog content.
  final Widget content;

  /// Action widgets.
  final List<Widget> actions;

  /// Source horizontal and bottom outside margins.
  final EdgeInsetsGeometry outsideMargin;

  /// Padding inside the dialog surface.
  final EdgeInsetsGeometry insideMargin;

  /// Whether IME, navigation-bar, and caption-bar padding is applied.
  final bool defaultWindowInsetsPadding;

  /// Maximum dialog panel width.
  final double maxWidth;

  /// Optional forced compact or centered presentation.
  final bool? largeScreen;

  /// Optional source corner-radius override.
  final double? cornerRadius;

  /// Whether the dialog samples and softens the scene behind its own shape.
  final bool glass;

  /// Optional wrapper corresponding to the source dialog modifier.
  final Widget Function(Widget child)? surfaceBuilder;

  /// Shows the dialog.
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    String? summary,
    required Widget content,
    List<Widget> actions = const [],
    Color? titleColor,
    Color? summaryColor,
    Color? backgroundColor,
    bool enableWindowDim = true,
    EdgeInsetsGeometry outsideMargin = MiuixDialogDefaults.outsideMargin,
    EdgeInsetsGeometry insideMargin = MiuixDialogDefaults.insideMargin,
    bool defaultWindowInsetsPadding = true,
    double maxWidth = MiuixDialogDefaults.maxWidth,
    bool? largeScreen,
    double? cornerRadius,
    bool glass = true,
    Widget Function(Widget child)? surfaceBuilder,
    bool barrierDismissible = true,
    VoidCallback? onDismissRequest,
    VoidCallback? onDismissFinished,
  }) {
    return showBuilder<T>(
      context: context,
      dialogBuilder: (_) => MiuixDialog(
        title: title,
        summary: summary,
        content: content,
        actions: actions,
        titleColor: titleColor,
        summaryColor: summaryColor,
        backgroundColor: backgroundColor,
        outsideMargin: outsideMargin,
        insideMargin: insideMargin,
        defaultWindowInsetsPadding: defaultWindowInsetsPadding,
        maxWidth: maxWidth,
        largeScreen: largeScreen,
        cornerRadius: cornerRadius,
        glass: glass,
        surfaceBuilder: surfaceBuilder,
      ),
      enableWindowDim: enableWindowDim,
      largeScreen: largeScreen,
      barrierDismissible: barrierDismissible,
      onDismissRequest: onDismissRequest,
      onDismissFinished: onDismissFinished,
    );
  }

  /// Shows a window dialog whose complete configuration can follow MediaQuery.
  ///
  /// The upstream declarative call site recomposes its nullable title, maximum
  /// width, and content when the window rotates. This builder preserves that
  /// behavior for Flutter's imperative route API.
  static Future<T?> showBuilder<T>({
    required BuildContext context,
    required WidgetBuilder dialogBuilder,
    // 消息菜单等短暂浮层不应改变底层输入焦点和光标。
    bool? requestFocus,
    bool enableWindowDim = true,
    bool? largeScreen,
    bool barrierDismissible = true,
    VoidCallback? onDismissRequest,
    VoidCallback? onDismissFinished,
  }) {
    if (!context.mounted) {
      return Future<T?>.value();
    }
    final routeTheme = Theme.of(context);
    // A root-navigator overlay otherwise loses a caller-scoped text scaler.
    // Preserve that accessibility choice while still reading live root
    // insets for the keyboard, navigation bar, and window changes.
    final routeTextScaler = MediaQuery.textScalerOf(context);
    final semantic = MiuixSemanticColors.of(context);
    final size = MediaQuery.sizeOf(context);
    final resolvedLargeScreen =
        largeScreen ?? (size.width >= 840 && size.height >= 480);
    final backProgress = _MiuixDialogBackProgress();
    var dismissRequested = false;
    void requestDismiss() {
      if (!dismissRequested) {
        dismissRequested = true;
        onDismissRequest?.call();
      }
    }

    late final _MiuixDialogRoute<T> route;
    route = _MiuixDialogRoute<T>(
      backProgress: backProgress,
      requestFocus: requestFocus,
      reduceMotion: MediaQuery.disableAnimationsOf(context),
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: enableWindowDim
          ? semantic['windowDimming']
          : Colors.transparent,
      pageBuilder: (context, animation, secondaryAnimation) =>
          _MiuixPredictiveBackObserver(
            controller: backProgress,
            canStart: () =>
                route.isCurrent &&
                route.popDisposition != RoutePopDisposition.doNotPop,
            onCommit: () {
              requestDismiss();
              route.navigator?.pop<T>();
            },
            child: _MiuixDialogBackScope(
              controller: backProgress,
              child: PopScope<Object?>(
                onPopInvokedWithResult: (didPop, result) {
                  if (didPop) {
                    requestDismiss();
                  }
                },
                child: MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: routeTextScaler),
                  child: Theme(
                    data: routeTheme,
                    child: Material(
                      type: MaterialType.transparency,
                      child: Builder(builder: dialogBuilder),
                    ),
                  ),
                ),
              ),
            ),
          ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        if (MediaQuery.disableAnimationsOf(context)) return child;
        final curved = CurvedAnimation(
          parent: animation,
          curve: _MiuixDialogSpringCurve(
            dampingRatio: resolvedLargeScreen ? .9 : .88,
            stiffness: resolvedLargeScreen ? 438.6 : 450,
          ),
          reverseCurve: const _MiuixAccelerateCurve(),
        );
        if (!resolvedLargeScreen) {
          return SlideTransition(
            key: const ValueKey('miuix-window-dialog-slide'),
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          );
        }
        return FadeTransition(
          key: const ValueKey('miuix-window-dialog-large-fade'),
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: .8, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
    return Navigator.of(
      context,
      rootNavigator: true,
    ).push<T>(route).whenComplete(() {
      requestDismiss();
      onDismissFinished?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final semantic = MiuixSemanticColors.of(context);
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final media = MediaQuery.of(context);
    final size = media.size;
    final pixelRatio = media.devicePixelRatio;
    final resolvedLargeScreen =
        largeScreen ?? (size.width >= 840 && size.height >= 480);
    // Compose applies navigationBarsPadding/captionBarPadding first and then
    // applies DialogDefaults.outsideMargin. SafeArea.minimum takes the larger
    // value instead of adding them, which placed the Flutter panel 12dp too
    // close to Android's gesture handle. IME and system navigation insets are
    // mutually exclusive here, so use their larger bottom obstruction.
    final bottomInset = defaultWindowInsetsPadding
        ? math.max(media.viewInsets.bottom, media.viewPadding.bottom)
        : 0.0;
    // Compose rounds every padding modifier edge independently before it
    // measures or positions the dialog. At the Android reference density of
    // 2.625, 12dp is therefore 32px instead of Flutter's fractional 31.5px.
    // Keeping that half pixel used to put the compact surface one pixel left
    // of the native panel and made both vertical content gaps one pixel short.
    final resolvedOutsideMargin = _miuixRoundedInsets(context, outsideMargin);
    final titleSpacing = _miuixRoundLogicalDimension(12, pixelRatio);
    // Compose's 18sp title4 paragraph produces a 21dp logical line box, then
    // its text placeable encloses that box to an integer physical pixel. The
    // 420dpi reference is therefore 56px rather than Flutter's fractional
    // 55.125px intrinsic height. Reserving the source placeable height keeps
    // a content-sized compact dialog's top edge on the same physical pixel.
    final titleLineHeight = _miuixCeilLogicalDimension(21, pixelRatio);
    final resolvedInsideMargin = _miuixRoundedInsets(context, insideMargin);
    // Dialog arguments often come from responsive configuration rather than
    // literals. Resolve invalid geometry in release as well as debug so the
    // overlay never forwards NaN, infinity, or a negative radius to painting.
    final requestedRadius = cornerRadius;
    final dialogRadius =
        requestedRadius == null ||
            !requestedRadius.isFinite ||
            requestedRadius < 0
        ? hyperOs4.dialogCornerRadius
        : requestedRadius;
    final effectiveMaxWidth = maxWidth.isFinite && maxWidth > 0
        ? maxWidth
        : MiuixDialogDefaults.maxWidth;
    final dialogColor =
        backgroundColor ?? MiuixDialogDefaults.backgroundColor(context);
    final surface = ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: effectiveMaxWidth,
        maxHeight: resolvedLargeScreen
            ? size.height * (2 / 3)
            : double.infinity,
      ),
      child: SizedBox(
        width: resolvedLargeScreen ? null : double.infinity,
        child: MiuixGlass(
          key: const ValueKey('miuix-dialog-surface'),
          enabled: glass,
          blur: hyperOs4.dialogBlur,
          opacity: hyperOs4.dialogTintOpacity,
          color: dialogColor,
          optics: MiuixGlassOptics.transient,
          radius: dialogRadius,
          padding: resolvedInsideMargin,
          showSpecular: true,
          child: DefaultTextStyle(
            style:
                (Theme.of(context).textTheme.bodyLarge ??
                        const TextStyle(fontSize: 17))
                    .copyWith(color: semantic['onSurface']),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (title != null) ...[
                  _MiuixDialogParagraph(
                    key: const ValueKey('miuix-dialog-title-placeable'),
                    text: title!,
                    color:
                        titleColor ?? MiuixDialogDefaults.titleColor(context),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    sourceLogicalLineHeight: titleLineHeight,
                    preserveNaturalLineHeight: true,
                  ),
                  SizedBox(height: titleSpacing),
                ],
                if (summary != null) ...[
                  _MiuixDialogParagraph(
                    text: summary!,
                    color:
                        summaryColor ??
                        MiuixDialogDefaults.summaryColor(context),
                  ),
                  SizedBox(height: titleSpacing),
                ],
                content,
                if (actions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 6,
                    runSpacing: 6,
                    children: actions,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
    Widget resolvedSurface = surfaceBuilder?.call(surface) ?? surface;
    if (_MiuixDialogBackScope.maybeOf(context) case final backProgress?) {
      resolvedSurface = _MiuixDialogPredictiveSurface(
        controller: backProgress,
        largeScreen: resolvedLargeScreen,
        compactBottomTravel: bottomInset + resolvedOutsideMargin.bottom,
        child: resolvedSurface,
      );
    }
    return SizedBox.expand(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          resolvedOutsideMargin.left +
              (defaultWindowInsetsPadding ? media.padding.left : 0),
          (_MiuixDialogHostInsets.maybeTopOf(context) ??
                  media.viewPadding.top) +
              resolvedOutsideMargin.top,
          resolvedOutsideMargin.right +
              (defaultWindowInsetsPadding ? media.padding.right : 0),
          bottomInset + resolvedOutsideMargin.bottom,
        ),
        child: Align(
          alignment: resolvedLargeScreen
              ? Alignment.center
              : Alignment.bottomCenter,
          child: MediaQuery.removePadding(
            context: context,
            removeLeft: defaultWindowInsetsPadding,
            removeRight: defaultWindowInsetsPadding,
            child: resolvedSurface,
          ),
        ),
      ),
    );
  }
}

/// Measures localized summary wrapping but reserves source text placeables.
///
/// Android's body1 paragraph uses a 49px placeable per line on the 420dpi
/// reference device. Flutter's Chinese fallback font reports a taller default
/// paragraph than the source Roboto paragraph, so letting the translated text
/// choose the dialog's intrinsic height moves the entire compact panel upward.
/// The painter below decides only how many lines the available width needs.
/// Each resulting line then occupies the same density-rounded source height.
class _MiuixDialogParagraph extends StatelessWidget {
  const _MiuixDialogParagraph({
    super.key,
    required this.text,
    required this.color,
    this.fontSize = 16,
    this.fontWeight,
    this.sourceLogicalLineHeight = 49 / 2.625,
    this.preserveNaturalLineHeight = false,
  });

  final String text;
  final Color color;
  final double fontSize;
  final FontWeight? fontWeight;
  final double sourceLogicalLineHeight;
  final bool preserveNaturalLineHeight;

  @override
  Widget build(BuildContext context) {
    final textDirection = Directionality.of(context);
    final textScaler = MediaQuery.textScalerOf(context);
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    // 默认字号保持已校准的原版行框；辅助功能放大后按同一 scaler 扩展。
    // 之前只放大字形却保留固定 21dp 标题框，会裁掉中文标题的上下半部。
    final sourceLineHeight = _miuixCeilLogicalDimension(
      textScaler.scale(sourceLogicalLineHeight),
      pixelRatio,
    );
    final style = DefaultTextStyle.of(context).style.merge(
      TextStyle(color: color, fontSize: fontSize, fontWeight: fontWeight),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: text, style: style),
          textAlign: TextAlign.center,
          textDirection: textDirection,
          textScaler: textScaler,
        )..layout(maxWidth: constraints.maxWidth);
        final lineCount = math.max(1, painter.computeLineMetrics().length);
        // 普通单行标题保留原版已校准的居中位置；放大或换行时容纳完整字框。
        final naturalTitle = preserveNaturalLineHeight;
        final expandedTitle =
            naturalTitle &&
            (textScaler.scale(fontSize) != fontSize || lineCount > 1);
        return SizedBox(
          height: expandedTitle
              ? math.max(sourceLineHeight * lineCount, painter.height)
              : sourceLineHeight * lineCount,
          child: Align(
            alignment: Alignment.center,
            child: Text(
              text,
              textAlign: TextAlign.center,
              // Text 和 Strut 的字号仍交给系统缩放，行高比例不能重复放大。
              style: naturalTitle
                  ? style
                  : style.copyWith(
                      height: sourceLineHeight / textScaler.scale(fontSize),
                    ),
              strutStyle: naturalTitle
                  ? null
                  : StrutStyle(
                      fontSize: fontSize,
                      height: sourceLineHeight / textScaler.scale(fontSize),
                      forceStrutHeight: true,
                    ),
            ),
          ),
        );
      },
    );
  }
}

// Applies the source predictive-back deformation to the panel only. The route
// entrance remains stationary at its completed value while this transform is
// driven directly by Android's continuous gesture progress.
class _MiuixDialogPredictiveSurface extends StatefulWidget {
  const _MiuixDialogPredictiveSurface({
    required this.controller,
    required this.largeScreen,
    required this.compactBottomTravel,
    required this.child,
  });

  final _MiuixDialogBackProgress controller;
  final bool largeScreen;
  final double compactBottomTravel;
  final Widget child;

  @override
  State<_MiuixDialogPredictiveSurface> createState() =>
      _MiuixDialogPredictiveSurfaceState();
}

class _MiuixDialogPredictiveSurfaceState
    extends State<_MiuixDialogPredictiveSurface> {
  final GlobalKey _surfaceKey = GlobalKey();
  double _surfaceHeight = 0;
  bool _measurementScheduled = false;

  void _scheduleMeasurement() {
    if (_measurementScheduled || widget.largeScreen) return;
    _measurementScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measurementScheduled = false;
      if (!mounted) return;
      final renderObject = _surfaceKey.currentContext?.findRenderObject();
      if (renderObject is RenderBox && renderObject.hasSize) {
        _surfaceHeight = renderObject.size.height;
      }
    });
  }

  @override
  void didUpdateWidget(covariant _MiuixDialogPredictiveSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child != widget.child ||
        oldWidget.largeScreen != widget.largeScreen) {
      _surfaceHeight = 0;
      _scheduleMeasurement();
    }
  }

  @override
  Widget build(BuildContext context) {
    _scheduleMeasurement();
    return ValueListenableBuilder<double>(
      valueListenable: widget.controller,
      child: KeyedSubtree(key: _surfaceKey, child: widget.child),
      builder: (context, dimAlpha, child) {
        final progress = widget.controller.progress;
        if (widget.largeScreen) {
          return Transform.scale(
            key: const ValueKey('miuix-dialog-predictive-transform'),
            scale: 1 - .2 * progress,
            child: child,
          );
        }
        return Transform.translate(
          key: const ValueKey('miuix-dialog-predictive-transform'),
          offset: Offset(
            0,
            progress * (_surfaceHeight + widget.compactBottomTravel),
          ),
          child: child,
        );
      },
    );
  }
}

/// Mutable behavior state for a visible MIUIX bottom sheet.
///
/// Flutter routes are created once, while the source Compose demo can update
/// `allowDismiss` and `enableNestedScroll` through recomposition. This
/// controller provides the equivalent live contract and also gives title-bar
/// actions a host-independent way to close either an overlay or window sheet.
class MiuixBottomSheetController extends ChangeNotifier {
  /// Creates bottom-sheet behavior state.
  MiuixBottomSheetController({
    bool allowDismiss = true,
    bool enableNestedScroll = true,
  }) : _allowDismiss = allowDismiss,
       _enableNestedScroll = enableNestedScroll;

  bool _allowDismiss;
  bool _enableNestedScroll;
  VoidCallback? _dismiss;
  VoidCallback? _dismissAfterSettledDrag;

  /// Whether outside taps, back gestures, and downward drags may dismiss.
  bool get allowDismiss => _allowDismiss;

  set allowDismiss(bool value) {
    if (_allowDismiss != value) {
      _allowDismiss = value;
      notifyListeners();
    }
  }

  /// Whether sheet dragging participates with its scrollable child.
  bool get enableNestedScroll => _enableNestedScroll;

  set enableNestedScroll(bool value) {
    if (_enableNestedScroll != value) {
      _enableNestedScroll = value;
      notifyListeners();
    }
  }

  /// Closes the attached sheet even when gesture dismissal is disabled.
  void dismiss() => _dismiss?.call();

  void _dismissSettledDrag() => (_dismissAfterSettledDrag ?? _dismiss)?.call();

  void _attach(VoidCallback dismiss, {VoidCallback? dismissAfterSettledDrag}) {
    _dismiss = dismiss;
    _dismissAfterSettledDrag = dismissAfterSettledDrag;
  }

  void _detach(VoidCallback dismiss) {
    if (identical(_dismiss, dismiss)) {
      _dismiss = null;
      _dismissAfterSettledDrag = null;
    }
  }
}

// BottomSheetContentLayout keeps predictive Back in the same offset channel as
// pointer dragging. The public behavior controller remains source-shaped; this
// private object owns only the transient platform gesture and panel geometry.
class _MiuixBottomSheetBackProgress extends ChangeNotifier
    implements _MiuixPredictiveBackProgress {
  _MiuixBottomSheetBackProgress(this.behavior, {this.disposeBehavior = false}) {
    behavior.addListener(_behaviorChanged);
  }

  final MiuixBottomSheetController behavior;
  final bool disposeBehavior;
  double _progress = 0;
  double _sheetHeight = 0;
  double _viewportHeight = 0;
  double _dragOffset = 0;

  @override
  double get progress => _progress;

  bool get allowDismiss => behavior.allowDismiss;

  double get effectiveProgress => _progress * (allowDismiss ? 1 : .1);

  double get dragOffset => _dragOffset;

  // The source keeps the dim layer fixed when allowDismiss is false.
  @override
  double get value {
    final predictiveAlpha = allowDismiss
        ? (1 - _progress).clamp(0.0, 1.0)
        : 1.0;
    final dragAlpha = allowDismiss && _dragOffset >= 0 && _sheetHeight > 0
        ? (1 - _dragOffset / _sheetHeight).clamp(0.0, 1.0)
        : 1.0;
    return (predictiveAlpha * dragAlpha).clamp(0.0, 1.0);
  }

  double get commitTargetProgress {
    if (_sheetHeight <= 0 || _viewportHeight <= 0) return 1;
    return math.max(1, _viewportHeight / _sheetHeight);
  }

  @override
  void update(double progress) {
    final next = progress.clamp(0.0, 1.0);
    if ((next - _progress).abs() <= 1e-9) return;
    _progress = next;
    notifyListeners();
  }

  void updateGeometry({
    required double sheetHeight,
    required double viewportHeight,
  }) {
    _sheetHeight = sheetHeight;
    _viewportHeight = viewportHeight;
  }

  void updateDragOffset(double offset) {
    if ((offset - _dragOffset).abs() <= 1e-9) return;
    _dragOffset = offset;
    notifyListeners();
  }

  void _behaviorChanged() => notifyListeners();

  @override
  void dispose() {
    behavior.removeListener(_behaviorChanged);
    if (disposeBehavior) behavior.dispose();
    super.dispose();
  }
}

// Predictive completion does not reuse the ordinary visibility animation.
// MIUIX continues the offset toward the window height with a .85/.4 Folme
// spring and removes the sheet as soon as one measured sheet height is crossed.
class _MiuixBottomSheetPredictiveBackObserver extends StatefulWidget {
  const _MiuixBottomSheetPredictiveBackObserver({
    required this.controller,
    required this.canStart,
    required this.onCommit,
    required this.child,
  });

  final _MiuixBottomSheetBackProgress controller;
  final bool Function() canStart;
  final VoidCallback onCommit;
  final Widget child;

  @override
  State<_MiuixBottomSheetPredictiveBackObserver> createState() =>
      _MiuixBottomSheetPredictiveBackObserverState();
}

class _MiuixBottomSheetPredictiveBackObserverState
    extends State<_MiuixBottomSheetPredictiveBackObserver>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late final AnimationController _settleAnimation;
  double _settleStart = 0;
  double _commitTarget = 1;
  bool _committing = false;
  bool _ownsGesture = false;
  bool _commitDelivered = false;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _settleAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..addListener(_tickSettle);
    _MiuixPredictiveBackOwnerRegistry.instance.register(
      this,
      (event) => widget.canStart(),
      context: () => context,
    );
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion == _reduceMotion) return;
    _reduceMotion = reduceMotion;
    if (!_reduceMotion || !_settleAnimation.isAnimating) return;
    _settleAnimation.stop();
    if (_committing && widget.controller.allowDismiss) {
      widget.controller.update(1);
      if (!_commitDelivered) {
        _commitDelivered = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.onCommit();
        });
      }
    } else {
      widget.controller.update(0);
    }
  }

  void _tickSettle() {
    if (_committing) {
      // folmeSpring(damping=.85,response=.4), mass=1. The 800ms controller is
      // only a sampling window; dismissal normally happens at the first
      // crossing of one sheet height, well before that window ends.
      const dampingRatio = .85;
      final stiffness = math.pow(2 * math.pi / .4, 2).toDouble();
      final naturalFrequency = math.sqrt(stiffness);
      final dampedFactor = math.sqrt(1 - dampingRatio * dampingRatio);
      final dampedFrequency = naturalFrequency * dampedFactor;
      final seconds = _settleAnimation.value * .8;
      final envelope = math.exp(-dampingRatio * naturalFrequency * seconds);
      final response =
          1 -
          envelope *
              (math.cos(dampedFrequency * seconds) +
                  dampingRatio /
                      dampedFactor *
                      math.sin(dampedFrequency * seconds));
      final next = _settleStart + (_commitTarget - _settleStart) * response;
      if (next >= 1) {
        widget.controller.update(1);
        _settleAnimation.stop();
        if (!_commitDelivered) {
          _commitDelivered = true;
          widget.onCommit();
        }
      } else {
        widget.controller.update(next);
      }
      return;
    }
    final eased = Curves.fastOutSlowIn.transform(_settleAnimation.value);
    widget.controller.update(_settleStart * (1 - eased));
  }

  void _resetToRest() {
    _committing = false;
    _settleStart = widget.controller.progress;
    if (_settleStart <= 1e-9) {
      widget.controller.update(0);
      return;
    }
    if (_reduceMotion) {
      widget.controller.update(0);
      return;
    }
    _settleAnimation
      ..duration = const Duration(milliseconds: 150)
      ..forward(from: 0);
  }

  @override
  bool handleStartBackGesture(PredictiveBackEvent backEvent) {
    if (backEvent.isButtonEvent ||
        !_MiuixPredictiveBackOwnerRegistry.instance.isTop(this, backEvent) ||
        !widget.canStart()) {
      return false;
    }
    _settleAnimation.stop();
    _commitDelivered = false;
    _ownsGesture = true;
    widget.controller.update(backEvent.progress);
    return true;
  }

  @override
  void handleUpdateBackGestureProgress(PredictiveBackEvent backEvent) {
    if (_ownsGesture) widget.controller.update(backEvent.progress);
  }

  @override
  void handleCancelBackGesture() {
    if (!_ownsGesture) return;
    _ownsGesture = false;
    _resetToRest();
  }

  @override
  void handleCommitBackGesture() {
    // 拖动期间出现保护层时只取消，不关闭其后的浮层。
    if (MiuixBackGestureScope.blockedOf(context)) {
      handleCancelBackGesture();
      return;
    }
    if (!_ownsGesture) return;
    _ownsGesture = false;
    if (!widget.controller.allowDismiss) {
      _resetToRest();
      return;
    }
    _committing = true;
    _settleStart = widget.controller.progress;
    _commitTarget = widget.controller.commitTargetProgress;
    if (_reduceMotion) {
      widget.controller.update(1);
      _commitDelivered = true;
      widget.onCommit();
      return;
    }
    _settleAnimation
      ..duration = const Duration(milliseconds: 800)
      ..forward(from: 0);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _MiuixPredictiveBackOwnerRegistry.instance.unregister(this);
    _settleAnimation
      ..removeListener(_tickSettle)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _MiuixBackGuard(child: widget.child);
}

// 返回值在 pop 开始时交给调用者，退出动画仍会继续使用控制器。
// 控制器由 Route 持有，直到 Overlay 子树卸载后再释放。
// 这样调用方立即切换主题、字号或页面也不会重用已销毁的监听器。
class _MiuixWindowBottomSheetRoute<T> extends RawDialogRoute<T> {
  // 转发原有遮罩和过渡参数，只调整资源归属，不新增另一套弹层动画。
  _MiuixWindowBottomSheetRoute({
    required this.behavior,
    required this.backProgress,
    required this.ownsController,
    required this.onDismissRequest,
    required this.onDismissFinished,
    required super.pageBuilder,
    required super.barrierDismissible,
    required super.barrierLabel,
    required super.barrierColor,
    required super.transitionDuration,
    required super.transitionBuilder,
  });

  // 调用者传入的行为控制器仍由调用者管理，不随一次弹层销毁。
  final MiuixBottomSheetController behavior;
  // 手势进度对象只属于单次弹层，不与后续弹层共享。
  final _MiuixBottomSheetBackProgress backProgress;
  // 所有权来自 show 的输入，不在退出时猜测控制器是否还有监听者。
  final bool ownsController;
  // 请求回调有外层幂等保护，程序移除路由也保持请求早于完成。
  final VoidCallback onDismissRequest;
  // 关闭完成与确认结果分开，只有真正移出Overlay才发出此通知。
  final VoidCallback? onDismissFinished;

  @override
  void dispose() {
    // 路由可能由返回、确认、拖动或程序移除结束，出口共用同一份清理。
    // Route 的销毁晚于退出动画和页面监听器卸载，不绑定 popped Future。
    try {
      onDismissRequest();
      // 完成通知发生在资源释放前，回调可以完成外部状态同步。
      onDismissFinished?.call();
    } finally {
      // 用户完成回调抛错时也必须释放本次创建的手势和行为资源。
      backProgress.dispose();
      if (ownsController) behavior.dispose();
      // 最后释放父路由资源，外部传入的行为对象仍可继续使用。
      super.dispose();
    }
  }
}

/// Bottom sheet helper.
class MiuixBottomSheet {
  /// Shows a modal bottom sheet.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    Widget? startAction,
    Widget? endAction,
    MiuixBottomSheetController? controller,
    bool allowDismiss = true,
    bool enableNestedScroll = true,
    Color? backgroundColor,
    bool enableWindowDim = true,
    double? cornerRadius,
    double sheetMaxWidth = MiuixBottomSheetDefaults.maxWidth,
    EdgeInsetsGeometry outsideMargin = MiuixBottomSheetDefaults.outsideMargin,
    bool? glass,
    EdgeInsetsGeometry insideMargin = MiuixBottomSheetDefaults.insideMargin,
    bool defaultWindowInsetsPadding = true,
    Color? dragHandleColor,
    VoidCallback? onDismissRequest,
    VoidCallback? onDismissFinished,
  }) {
    if (!context.mounted) {
      return Future<T?>.value();
    }
    final routeTheme = Theme.of(context);
    final ownsController = controller == null;
    final behavior =
        controller ??
        MiuixBottomSheetController(
          allowDismiss: allowDismiss,
          enableNestedScroll: enableNestedScroll,
        );
    final backProgress = _MiuixBottomSheetBackProgress(behavior);
    var dismissRequested = false;
    void requestDismiss() {
      if (!dismissRequested) {
        dismissRequested = true;
        onDismissRequest?.call();
      }
    }

    final route = _MiuixWindowBottomSheetRoute<T>(
      behavior: behavior,
      backProgress: backProgress,
      ownsController: ownsController,
      onDismissRequest: requestDismiss,
      onDismissFinished: onDismissFinished,
      // A custom barrier reads the live behavior controller. A route-level
      // ModalBarrier cannot change dismissibility after it is constructed.
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.transparent,
      transitionDuration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : _miuixBottomSheetVisibilityDuration,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Theme(
          data: routeTheme,
          child: Material(
            type: MaterialType.transparency,
            child: _MiuixWindowBottomSheetHost(
              controller: behavior,
              backProgress: backProgress,
              visibilityAnimation: animation,
              enableWindowDim: enableWindowDim,
              onDismissRequest: requestDismiss,
              child: _MiuixBottomSheetSurface(
                // HyperOS 4 application surfaces use local glass by default.
                // Passing false remains the explicit opaque compatibility path.
                glass: glass ?? true,
                backgroundColor: backgroundColor,
                cornerRadius: cornerRadius,
                sheetMaxWidth: sheetMaxWidth,
                outsideMargin: outsideMargin,
                insideMargin: insideMargin,
                defaultWindowInsetsPadding: defaultWindowInsetsPadding,
                dragHandleColor: dragHandleColor,
                title: title,
                startAction: startAction,
                endAction: endAction,
                controller: behavior,
                backProgress: backProgress,
                visibilityAnimation: animation,
                child: child,
              ),
            ),
          ),
        );
      },
      // BottomSheetContentLayout animates its panel and dim channels inside the
      // window; the route itself must not translate the full-screen scrim.
      transitionBuilder: (context, animation, secondaryAnimation, child) =>
          child,
    );
    // 保留原有结果时机：确认后可立即应用设置，不必等待退出动画。
    // 资源释放和完成回调统一交给 Route.dispose，避免主题重建时提前销毁。
    return Navigator.of(
      context,
      rootNavigator: true,
    ).push<T>(route).whenComplete(requestDismiss);
  }
}

class _MiuixWindowBottomSheetHost extends StatefulWidget {
  const _MiuixWindowBottomSheetHost({
    required this.controller,
    required this.backProgress,
    required this.visibilityAnimation,
    required this.enableWindowDim,
    required this.onDismissRequest,
    required this.child,
  });

  final MiuixBottomSheetController controller;
  final _MiuixBottomSheetBackProgress backProgress;
  final Animation<double> visibilityAnimation;
  final bool enableWindowDim;
  final VoidCallback onDismissRequest;
  final Widget child;

  @override
  State<_MiuixWindowBottomSheetHost> createState() =>
      _MiuixWindowBottomSheetHostState();
}

class _MiuixWindowBottomSheetHostState
    extends State<_MiuixWindowBottomSheetHost> {
  bool _forceDismiss = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_behaviorChanged);
    widget.controller._attach(
      _dismissFromAction,
      dismissAfterSettledDrag: _dismissAfterSettledDrag,
    );
  }

  @override
  void didUpdateWidget(covariant _MiuixWindowBottomSheetHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller
        ..removeListener(_behaviorChanged)
        .._detach(_dismissFromAction);
      widget.controller
        ..addListener(_behaviorChanged)
        .._attach(
          _dismissFromAction,
          dismissAfterSettledDrag: _dismissAfterSettledDrag,
        );
    }
  }

  void _behaviorChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _dismissFromAction() {
    if (_forceDismiss || !mounted) {
      return;
    }
    setState(() => _forceDismiss = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  void _dismissFromGesture() {
    if (!widget.controller.allowDismiss) {
      return;
    }
    widget.onDismissRequest();
    Navigator.of(context).pop();
  }

  void _dismissFromPredictiveBack() {
    if (!widget.controller.allowDismiss || !mounted) return;
    _dismissAfterSettledDrag();
  }

  void _dismissAfterSettledDrag() {
    if (!widget.controller.allowDismiss || !mounted) return;
    widget.onDismissRequest();
    final route = ModalRoute.of(context);
    if (route != null) {
      Navigator.of(context).removeRoute(route);
    }
  }

  @override
  void dispose() {
    widget.controller
      ..removeListener(_behaviorChanged)
      .._detach(_dismissFromAction);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canPop = widget.controller.allowDismiss || _forceDismiss;
    final visibility = CurvedAnimation(
      parent: widget.visibilityAnimation,
      curve: _miuixBottomSheetVisibilityCurve,
      reverseCurve: _miuixBottomSheetVisibilityReverseCurve,
    );
    return _MiuixBottomSheetPredictiveBackObserver(
      controller: widget.backProgress,
      canStart: () => ModalRoute.of(context)?.isCurrent ?? true,
      onCommit: _dismissFromPredictiveBack,
      child: PopScope<Object?>(
        canPop: canPop,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            widget.onDismissRequest();
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _dismissFromGesture,
              child: AnimatedBuilder(
                animation: Listenable.merge([visibility, widget.backProgress]),
                builder: (context, child) => Opacity(
                  key: const ValueKey('miuix-bottom-sheet-predictive-dim'),
                  opacity: (visibility.value * widget.backProgress.value).clamp(
                    0.0,
                    1.0,
                  ),
                  child: child,
                ),
                child: ColoredBox(
                  color: widget.enableWindowDim
                      ? MiuixSemanticColors.of(context)['windowDimming']
                      : Colors.transparent,
                ),
              ),
            ),
            widget.child,
          ],
        ),
      ),
    );
  }
}

class _MiuixBottomSheetSurface extends StatefulWidget {
  const _MiuixBottomSheetSurface({
    required this.child,
    required this.glass,
    this.backgroundColor,
    this.cornerRadius,
    this.sheetMaxWidth = MiuixBottomSheetDefaults.maxWidth,
    this.outsideMargin = MiuixBottomSheetDefaults.outsideMargin,
    this.insideMargin = MiuixBottomSheetDefaults.insideMargin,
    this.defaultWindowInsetsPadding = true,
    this.dragHandleColor,
    this.title,
    this.startAction,
    this.endAction,
    this.controller,
    this.backProgress,
    this.visibilityAnimation,
  });

  final Widget child;
  final bool glass;
  final Color? backgroundColor;
  final double? cornerRadius;
  final double sheetMaxWidth;
  final EdgeInsetsGeometry outsideMargin;
  final EdgeInsetsGeometry insideMargin;
  final bool defaultWindowInsetsPadding;
  final Color? dragHandleColor;
  final String? title;
  final Widget? startAction;
  final Widget? endAction;
  final MiuixBottomSheetController? controller;
  final _MiuixBottomSheetBackProgress? backProgress;
  final Animation<double>? visibilityAnimation;

  @override
  State<_MiuixBottomSheetSurface> createState() =>
      _MiuixBottomSheetSurfaceState();
}

class _MiuixBottomSheetSurfaceState extends State<_MiuixBottomSheetSurface>
    with SingleTickerProviderStateMixin {
  // Source parity notes for BottomSheetContentLayout.kt:
  // - The sheet is bottom aligned and content sized.
  // - Its maximum width is 640dp on every platform.
  // - Its maximum height stops at the status-bar-safe top edge.
  // - Default outside margin is zero, so the background reaches the gesture bar.
  // - Interactive content still ends above the navigation/gesture indicator.
  // - Default horizontal inside margin is 24dp.
  // - Default vertical inside margin is zero.
  // - Only the two top corners use the 28dp source radius.
  // - The drag handle owns a 24dp-high interaction area.
  // - Its resting painted size is exactly 45 by 4dp.
  // - The handle tint is onSurfaceVariantSummary at 20 percent opacity.
  // - The title/action row adds 6dp above and 12dp below.
  // - The title uses the 18sp Medium title4 token.
  // - Downward motion follows the pointer when dismissal is allowed.
  // - Upward overscroll is damped to one tenth of pointer movement.
  // - A popup-hosted sheet still uses the same vertical slide as a window sheet.
  // - Optional glass follows the global extension; source-default mode stays opaque.
  final GlobalKey _surfaceKey = GlobalKey();
  late final AnimationController _dragMotion;
  var _settleSerial = 0;
  bool _settlingDismiss = false;
  bool _dismissDelivered = false;
  bool _handlePressed = false;
  bool _handleNeedsTouchSlopCorrection = false;
  bool _nestedDragActive = false;
  int? _nestedPointer;
  VelocityTracker? _nestedVelocityTracker;
  Offset? _nestedDownPosition;
  double _nestedForwardedDy = 0;
  double _nestedPendingPreScrollCorrection = 0;
  bool _nestedAtLeadingEdge = true;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _dragMotion = AnimationController.unbounded(vsync: this)
      ..addListener(_syncDragMotion);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion == _reduceMotion) return;
    _reduceMotion = reduceMotion;
    if (!_reduceMotion || !_dragMotion.isAnimating) return;
    _dragMotion.stop();
    if (_settlingDismiss) {
      final target = math.max(_sheetHeight, MediaQuery.sizeOf(context).height);
      _dragMotion.value = target;
      _syncDragMotion();
    } else {
      _dragMotion.value = 0;
    }
  }

  @override
  void didUpdateWidget(covariant _MiuixBottomSheetSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.backProgress != widget.backProgress) {
      oldWidget.backProgress?.updateDragOffset(0);
      widget.backProgress?.updateDragOffset(_dragMotion.value);
    }
  }

  @override
  void dispose() {
    _dragMotion
      ..removeListener(_syncDragMotion)
      ..dispose();
    super.dispose();
  }

  double get _sheetHeight {
    final box = _surfaceKey.currentContext?.findRenderObject() as RenderBox?;
    return box != null && box.hasSize ? box.size.height : 0;
  }

  void _syncDragMotion() {
    widget.backProgress?.updateDragOffset(_dragMotion.value);
    if (!_settlingDismiss || _dismissDelivered) return;
    final height = _sheetHeight;
    if (height > 0 && _dragMotion.value >= height) {
      _dismissDelivered = true;
      _dragMotion.stop();
      widget.controller?._dismissSettledDrag();
    }
  }

  void _schedulePredictiveMeasurement() {
    final controller = widget.backProgress;
    if (controller == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final box = _surfaceKey.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) return;
      controller.updateGeometry(
        sheetHeight: box.size.height,
        viewportHeight: MediaQuery.sizeOf(context).height,
      );
    });
  }

  double _calculateNewOffset(double current, double delta) {
    final controller = widget.controller;
    if (controller == null) return current;
    final newOffset = current + delta;
    if (newOffset < 0) {
      return (current + delta * .1).clamp(double.negativeInfinity, 0.0);
    }
    if (!controller.allowDismiss) {
      final dampedAmount = delta > 0 ? delta * .1 : delta;
      return (current + dampedAmount).clamp(0.0, double.infinity);
    }
    return newOffset;
  }

  void _beginDrag() {
    _settleSerial++;
    _settlingDismiss = false;
    _dismissDelivered = false;
    _handleNeedsTouchSlopCorrection = false;
    _dragMotion.stop();
  }

  void _beginHandleDrag() {
    _beginDrag();
    _handleNeedsTouchSlopCorrection = true;
  }

  void _applyDragDelta(double delta) {
    if (delta == 0) return;
    _dragMotion.value = _calculateNewOffset(_dragMotion.value, delta);
  }

  void _dragUpdate(DragUpdateDetails details) {
    var delta = details.primaryDelta ?? 0;
    if (_handleNeedsTouchSlopCorrection) {
      _handleNeedsTouchSlopCorrection = false;
      // Compose's Android pointer path starts after the platform 8dp touch
      // slop and forwards only the over-slop remainder. DragStartBehavior.down
      // preserves Flutter's pending first movement so that exact remainder can
      // be recovered instead of losing the complete first MOVE event.
      final magnitude = math.max(0.0, delta.abs() - 8);
      delta = delta.isNegative ? -magnitude : magnitude;
    }
    _applyDragDelta(delta);
  }

  void _dragEnd(DragEndDetails details) {
    _settleDrag(details.primaryVelocity ?? 0);
  }

  void _settleDrag(double velocity) {
    final controller = widget.controller;
    if (controller == null) return;
    final currentOffset = _dragMotion.value;
    final shouldDismiss =
        controller.allowDismiss &&
        (velocity > 800 || (currentOffset > 150 && velocity > -800));
    final serial = ++_settleSerial;
    if (shouldDismiss) {
      _settlingDismiss = true;
      _dismissDelivered = false;
      final viewportHeight = MediaQuery.sizeOf(context).height;
      if (_reduceMotion) {
        _dragMotion.value = math.max(_sheetHeight, viewportHeight);
        _syncDragMotion();
        return;
      }
      if (_sheetHeight > 0 && currentOffset >= _sheetHeight) {
        _syncDragMotion();
        return;
      }
      _dragMotion.animateWith(
        SpringSimulation(
          _miuixBottomSheetSettleSpring,
          currentOffset,
          viewportHeight,
          velocity,
        ),
      );
      return;
    }
    if (_reduceMotion) {
      _settlingDismiss = false;
      _dragMotion.value = 0;
      return;
    }
    _settlingDismiss = false;
    final effectiveVelocity = !controller.allowDismiss && velocity > 0
        ? 0.0
        : velocity;
    _dragMotion
        .animateWith(
          SpringSimulation(
            _miuixBottomSheetSettleSpring,
            currentOffset,
            0,
            effectiveVelocity,
          ),
        )
        .whenCompleteOrCancel(() {
          if (mounted && serial == _settleSerial && !_settlingDismiss) {
            _dragMotion.value = 0;
          }
        });
  }

  void _setHandlePressed(bool value) {
    if (_handlePressed == value) return;
    setState(() => _handlePressed = value);
  }

  void _cancelHandleDrag() {
    _setHandlePressed(false);
    _settleDrag(0);
  }

  void _beginNestedDrag() {
    if (_nestedDragActive) return;
    _nestedDragActive = true;
    _beginDrag();
  }

  void _nestedPointerDown(PointerDownEvent event) {
    if (widget.controller?.enableNestedScroll != true) return;
    _nestedPointer = event.pointer;
    _nestedDownPosition = event.position;
    _nestedForwardedDy = 0;
    _nestedPendingPreScrollCorrection = 0;
    _nestedVelocityTracker = VelocityTracker.withKind(event.kind)
      ..addPosition(event.timeStamp, event.position);
  }

  void _nestedPointerMove(PointerMoveEvent event) {
    if (event.pointer != _nestedPointer) return;
    _nestedVelocityTracker?.addPosition(event.timeStamp, event.position);
    final controller = widget.controller;
    final downPosition = _nestedDownPosition;
    if (controller == null ||
        !controller.enableNestedScroll ||
        downPosition == null) {
      return;
    }
    final displacement = event.position - downPosition;
    if (!_nestedDragActive) {
      final isVerticalPull =
          displacement.dy > 8 && displacement.dy.abs() > displacement.dx.abs();
      if (!isVerticalPull ||
          !_nestedAtLeadingEdge ||
          !controller.allowDismiss) {
        return;
      }
      _beginNestedDrag();
    }

    final desiredForwardedDy = displacement.dy > 0
        ? math.max(0.0, displacement.dy - 8)
        : math.min(0.0, displacement.dy + 8);
    final delta = desiredForwardedDy - _nestedForwardedDy;
    _nestedForwardedDy = desiredForwardedDy;
    if (delta > 0 && controller.allowDismiss && _nestedAtLeadingEdge) {
      _applyDragDelta(delta);
      return;
    }
    if (delta < 0 && _dragMotion.value > 0) {
      final consumed = math.min(_dragMotion.value, -delta);
      _nestedPendingPreScrollCorrection += consumed;
      _applyDragDelta(-consumed);
    }
  }

  void _finishNestedPointer(PointerEvent event, {required bool cancelled}) {
    if (event.pointer != _nestedPointer) return;
    _nestedVelocityTracker?.addPosition(event.timeStamp, event.position);
    final velocity = cancelled
        ? 0.0
        : (_nestedVelocityTracker?.getVelocity().pixelsPerSecond.dy ?? 0);
    _nestedPointer = null;
    _nestedVelocityTracker = null;
    _nestedDownPosition = null;
    _nestedForwardedDy = 0;
    _nestedPendingPreScrollCorrection = 0;
    if (_nestedDragActive) {
      _nestedDragActive = false;
      _settleDrag(velocity);
    }
  }

  bool _handleNestedScroll(ScrollNotification notification) {
    final controller = widget.controller;
    if (controller == null ||
        !controller.enableNestedScroll ||
        notification.depth != 0 ||
        notification.metrics.axis != Axis.vertical) {
      return false;
    }
    _nestedAtLeadingEdge =
        notification.metrics.pixels <=
        notification.metrics.minScrollExtent + .5;

    if (notification case OverscrollNotification(
      :final dragDetails,
      :final overscroll,
    )) {
      // At the leading edge, a downward finger delta is the negative amount
      // the ScrollPosition could not consume. The source forwards that exact
      // unconsumed distance to the sheet only when dismissal is allowed.
      if (_nestedPointer == null &&
          dragDetails != null &&
          overscroll < 0 &&
          controller.allowDismiss) {
        _beginNestedDrag();
        _applyDragDelta(-overscroll);
      }
      return false;
    }

    if (notification case ScrollUpdateNotification(
      :final dragDetails,
      :final scrollDelta,
    )) {
      if (dragDetails == null || scrollDelta == null || scrollDelta <= 0) {
        return false;
      }
      final notificationContext = notification.context;
      final scrollable = notificationContext == null
          ? null
          : Scrollable.maybeOf(notificationContext);
      if (_nestedPointer != null) {
        final correction = math.min(
          _nestedPendingPreScrollCorrection,
          scrollDelta,
        );
        if (correction > 0) {
          final position = scrollable?.position;
          position?.correctBy(-correction);
          _nestedPendingPreScrollCorrection -= correction;
          if (position != null) {
            _nestedAtLeadingEdge =
                position.pixels <= position.minScrollExtent + .5;
          }
        }
        return false;
      }
      final currentOffset = _dragMotion.value;
      if (currentOffset <= 0) return false;
      // Nested pre-scroll restores a displaced sheet before content may move.
      // ScrollNotification arrives during the viewport layout that accepted
      // the delta. correctBy returns the consumed part without cancelling the
      // active ScrollDragController; any remainder continues into the list.
      final consumed = math.min(currentOffset, scrollDelta);
      scrollable?.position.correctBy(-consumed);
      _beginNestedDrag();
      _applyDragDelta(-consumed);
      return false;
    }

    if (notification is ScrollEndNotification && _nestedDragActive) {
      _nestedDragActive = false;
      _settleDrag(notification.dragDetails?.primaryVelocity ?? 0);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    _schedulePredictiveMeasurement();
    final semantic = MiuixSemanticColors.of(context);
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final media = MediaQuery.of(context);
    final safeTop = media.padding.top;
    final background =
        widget.backgroundColor ??
        MiuixBottomSheetDefaults.backgroundColor(context);
    final handleColor =
        widget.dragHandleColor ??
        MiuixBottomSheetDefaults.dragHandleColor(context);
    final safeMaxWidth =
        widget.sheetMaxWidth.isFinite && widget.sheetMaxWidth > 0
        ? widget.sheetMaxWidth
        : MiuixBottomSheetDefaults.maxWidth;
    final requestedRadius = widget.cornerRadius;
    final safeRadius = requestedRadius != null && requestedRadius.isFinite
        ? math.max(0.0, requestedRadius)
        : hyperOs4.bottomSheetCornerRadius;
    final resolvedOutsideMargin = _miuixRoundedInsets(
      context,
      widget.outsideMargin,
    );
    final imeBottom = widget.defaultWindowInsetsPadding
        ? media.viewInsets.bottom
        : 0.0;
    // Keep the sheet material edge-to-edge so it paints behind Android's
    // gesture indicator, but reserve the currently unobscured system padding
    // inside that material. `padding.bottom` becomes zero while the IME is
    // visible, so the outer IME offset and this inner navigation inset are
    // never added twice.
    final navigationBottom = widget.defaultWindowInsetsPadding
        ? media.padding.bottom
        : 0.0;
    // Compose rounds each modifier padding edge before it measures the child.
    // The current Android source's 18sp title4 paragraph is 56 physical pixels
    // at 420dpi. A Chinese fallback paragraph is naturally 25px taller in
    // Flutter, but localization must not change the authored sheet geometry.
    // Force the source line box while retaining ordinary multi-line wrapping.
    final titlePadding = _miuixRoundedInsets(
      context,
      const EdgeInsets.only(top: 6, bottom: 12),
    );
    final titleLineHeight = _miuixRoundLogicalDimension(
      56 / 2.625,
      MediaQuery.devicePixelRatioOf(context),
    );
    return Padding(
      padding: resolvedOutsideMargin.add(EdgeInsets.only(bottom: imeBottom)),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: AnimatedBuilder(
          animation: _dragMotion,
          builder: (context, child) {
            final overscrollHeight = math.max(0.0, -_dragMotion.value + 1);
            return Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                if (overscrollHeight > 1)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: overscrollHeight,
                    child: ColoredBox(
                      key: const ValueKey(
                        'miuix-bottom-sheet-overscroll-background',
                      ),
                      color: background,
                    ),
                  ),
                child!,
              ],
            );
          },
          child: _MiuixBottomSheetPredictiveTransform(
            controller: widget.backProgress,
            dragMotion: _dragMotion,
            visibilityAnimation: widget.visibilityAnimation,
            surfaceKey: _surfaceKey,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: safeMaxWidth,
                  maxHeight: MediaQuery.sizeOf(context).height - safeTop,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: MiuixGlass(
                    key: const ValueKey('miuix-bottom-sheet-surface'),
                    enabled: widget.glass,
                    blur: hyperOs4.bottomSheetBlur,
                    opacity: hyperOs4.bottomSheetTintOpacity,
                    color: background,
                    optics: MiuixGlassOptics.transient,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(safeRadius),
                    ),
                    padding: widget.insideMargin,
                    // HyperOS 4 keeps a restrained edge reflection inside the
                    // panel clip; it must never extend into the rounded cutouts.
                    showSpecular: true,
                    child: SafeArea(
                      top: false,
                      bottom: false,
                      left: widget.defaultWindowInsetsPadding,
                      right: widget.defaultWindowInsetsPadding,
                      child: Padding(
                        key: const ValueKey(
                          'miuix-bottom-sheet-system-bottom-inset',
                        ),
                        padding: EdgeInsets.only(bottom: navigationBottom),
                        child: DefaultTextStyle(
                          style:
                              (Theme.of(context).textTheme.bodyLarge ??
                                      const TextStyle(fontSize: 17))
                                  .copyWith(color: semantic['onSurface']),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Listener(
                                key: const ValueKey(
                                  'miuix-bottom-sheet-drag-handle-area',
                                ),
                                behavior: HitTestBehavior.opaque,
                                onPointerDown: (_) => _setHandlePressed(true),
                                onPointerUp: (_) => _setHandlePressed(false),
                                onPointerCancel: (_) =>
                                    _setHandlePressed(false),
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  dragStartBehavior: DragStartBehavior.down,
                                  onVerticalDragStart: (_) {
                                    _setHandlePressed(true);
                                    _beginHandleDrag();
                                  },
                                  onVerticalDragUpdate: _dragUpdate,
                                  onVerticalDragEnd: (details) {
                                    _setHandlePressed(false);
                                    _dragEnd(details);
                                  },
                                  onVerticalDragCancel: _cancelHandleDrag,
                                  child: SizedBox(
                                    height: 24,
                                    child: Center(
                                      child: AnimatedContainer(
                                        key: const ValueKey(
                                          'miuix-bottom-sheet-drag-handle',
                                        ),
                                        duration: Duration(
                                          milliseconds: _handlePressed
                                              ? 100
                                              : 150,
                                        ),
                                        curve: Curves.linear,
                                        width: _handlePressed ? 55 : 45,
                                        height: 4,
                                        transformAlignment: Alignment.center,
                                        transform: Matrix4.diagonal3Values(
                                          1,
                                          _handlePressed ? 1.15 : 1,
                                          1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: handleColor.withValues(
                                            alpha: _handlePressed ? .35 : .2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (widget.title != null ||
                                  widget.startAction != null ||
                                  widget.endAction != null)
                                Padding(
                                  padding: titlePadding,
                                  // Compose's Box has no authored 40dp height here. It
                                  // measures the tallest title/action placeable, then
                                  // adds the independently rounded 6dp and 12dp edges.
                                  // IntrinsicHeight gives the expanding Stack that same
                                  // child-owned cross-axis size while preserving a
                                  // title centered independently of asymmetric actions.
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minHeight: titleLineHeight,
                                    ),
                                    child: IntrinsicHeight(
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: Stack(
                                          fit: StackFit.expand,
                                          alignment: Alignment.center,
                                          children: [
                                            if (widget.startAction != null)
                                              Align(
                                                alignment: AlignmentDirectional
                                                    .centerStart,
                                                child: widget.startAction,
                                              ),
                                            if (widget.title != null)
                                              Center(
                                                child: Text(
                                                  widget.title!,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color:
                                                        semantic['onSurface'],
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w500,
                                                    height:
                                                        titleLineHeight / 18,
                                                  ),
                                                  strutStyle: StrutStyle(
                                                    fontSize: 18,
                                                    height:
                                                        titleLineHeight / 18,
                                                    forceStrutHeight: true,
                                                  ),
                                                ),
                                              ),
                                            if (widget.endAction != null)
                                              Align(
                                                alignment: AlignmentDirectional
                                                    .centerEnd,
                                                child: widget.endAction,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              Flexible(
                                fit: FlexFit.loose,
                                child: NotificationListener<ScrollNotification>(
                                  onNotification: _handleNestedScroll,
                                  child: Listener(
                                    behavior: HitTestBehavior.translucent,
                                    onPointerDown: _nestedPointerDown,
                                    onPointerMove: _nestedPointerMove,
                                    onPointerUp: (event) =>
                                        _finishNestedPointer(
                                          event,
                                          cancelled: false,
                                        ),
                                    onPointerCancel: (event) =>
                                        _finishNestedPointer(
                                          event,
                                          cancelled: true,
                                        ),
                                    child: widget.child,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MiuixBottomSheetPredictiveTransform extends StatelessWidget {
  const _MiuixBottomSheetPredictiveTransform({
    required this.controller,
    required this.dragMotion,
    required this.visibilityAnimation,
    required this.surfaceKey,
    required this.child,
  });

  final _MiuixBottomSheetBackProgress? controller;
  final Animation<double> dragMotion;
  final Animation<double>? visibilityAnimation;
  final GlobalKey surfaceKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final keyedChild = KeyedSubtree(key: surfaceKey, child: child);
    final progress = controller;
    final visibility = visibilityAnimation;
    final listenables = <Listenable>[?progress, ?visibility, dragMotion];
    return AnimatedBuilder(
      animation: Listenable.merge(listenables),
      child: keyedChild,
      builder: (context, child) {
        final measuredHeight = progress?._sheetHeight ?? 0;
        final fallbackHeight = 500 / MediaQuery.devicePixelRatioOf(context);
        final height = measuredHeight > 0 ? measuredHeight : fallbackHeight;
        final visibleFraction = visibility == null
            ? 1.0
            : (CurvedAnimation(
                parent: visibility,
                curve: _miuixBottomSheetVisibilityCurve,
                reverseCurve: _miuixBottomSheetVisibilityReverseCurve,
              ).value).clamp(0.0, 1.0);
        final gestureOffset =
            (progress?.effectiveProgress ?? 0) * height + dragMotion.value;
        return Transform.translate(
          key: const ValueKey('miuix-bottom-sheet-predictive-transform'),
          offset: Offset(0, height * (1 - visibleFraction) + gestureOffset),
          child: child,
        );
      },
    );
  }
}

/// Overlay-named dialog adapter matching MIUIX component naming.
class MiuixOverlayDialog {
  /// Shows an overlay dialog.
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    String? summary,
    required Widget content,
    List<Widget> actions = const [],
    Color? titleColor,
    Color? summaryColor,
    Color? backgroundColor,
    bool enableWindowDim = true,
    EdgeInsetsGeometry outsideMargin = MiuixDialogDefaults.outsideMargin,
    EdgeInsetsGeometry insideMargin = MiuixDialogDefaults.insideMargin,
    bool defaultWindowInsetsPadding = true,
    double maxWidth = MiuixDialogDefaults.maxWidth,
    bool? largeScreen,
    double? cornerRadius,
    bool glass = true,
    Widget Function(Widget child)? surfaceBuilder,
    bool barrierDismissible = true,
    bool renderInRootScaffold = true,
    VoidCallback? onDismissRequest,
    VoidCallback? onDismissFinished,
  }) {
    return showBuilder<T>(
      context: context,
      dialogBuilder: (_) => MiuixDialog(
        title: title,
        summary: summary,
        content: content,
        actions: actions,
        titleColor: titleColor,
        summaryColor: summaryColor,
        backgroundColor: backgroundColor,
        outsideMargin: outsideMargin,
        insideMargin: insideMargin,
        defaultWindowInsetsPadding: defaultWindowInsetsPadding,
        maxWidth: maxWidth,
        largeScreen: largeScreen,
        cornerRadius: cornerRadius,
        glass: glass,
        surfaceBuilder: surfaceBuilder,
      ),
      enableWindowDim: enableWindowDim,
      largeScreen: largeScreen,
      barrierDismissible: barrierDismissible,
      renderInRootScaffold: renderInRootScaffold,
      onDismissRequest: onDismissRequest,
      onDismissFinished: onDismissFinished,
    );
  }

  /// Shows a hosted dialog whose complete configuration can follow MediaQuery.
  static Future<T?> showBuilder<T>({
    required BuildContext context,
    required WidgetBuilder dialogBuilder,
    bool enableWindowDim = true,
    bool? largeScreen,
    bool barrierDismissible = true,
    bool renderInRootScaffold = true,
    VoidCallback? onDismissRequest,
    VoidCallback? onDismissFinished,
  }) {
    final nearest = MiuixPopupHostScope.maybeOf(context);
    if (nearest == null) {
      throw FlutterError(
        'MiuixOverlayDialog requires a MiuixScaffold or MiuixPopupHost.',
      );
    }
    final controller = renderInRootScaffold ? nearest.root : nearest;
    final backProgress = _MiuixDialogBackProgress();
    // Flutter's root popup host begins inside the status-bar side of the view,
    // while Compose carries an already-consumed inset into DialogContentLayout.
    // Alignment distributes the remaining difference across both sides, so
    // half of Flutter's reported safe top reproduces the source window center.
    final view = View.of(context);
    final consumedTopInset = view.viewPadding.top / view.devicePixelRatio / 2;
    return controller.show<T>(
      // OverlayDialog reads WindowInsets.statusBars from inside the source
      // Scaffold host, where that top inset has already been consumed.
      // WindowDialog captures it before creating its separate platform window.
      child: _MiuixDialogHostInsets(
        top: consumedTopInset,
        child: _MiuixDialogBackScope(
          controller: backProgress,
          child: Builder(builder: dialogBuilder),
        ),
      ),
      dimBackground: enableWindowDim,
      dimColor: MiuixSemanticColors.of(context)['windowDimming'],
      dimAlpha: backProgress,
      dialogTransition: true,
      barrierDismissible: barrierDismissible,
      enableAutoLargeScreen: largeScreen == null,
      dialogLargeScreen: largeScreen,
      onDismissRequest: onDismissRequest,
      onDismissFinished: () {
        onDismissFinished?.call();
      },
    );
  }
}

/// Window-named dialog adapter matching MIUIX component naming.
class MiuixWindowDialog {
  /// Shows a window dialog.
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    String? summary,
    required Widget content,
    List<Widget> actions = const [],
    Color? titleColor,
    Color? summaryColor,
    Color? backgroundColor,
    bool enableWindowDim = true,
    EdgeInsetsGeometry outsideMargin = MiuixDialogDefaults.outsideMargin,
    EdgeInsetsGeometry insideMargin = MiuixDialogDefaults.insideMargin,
    bool defaultWindowInsetsPadding = true,
    double maxWidth = MiuixDialogDefaults.maxWidth,
    bool? largeScreen,
    double? cornerRadius,
    bool glass = true,
    Widget Function(Widget child)? surfaceBuilder,
    bool barrierDismissible = true,
    VoidCallback? onDismissRequest,
    VoidCallback? onDismissFinished,
  }) {
    return MiuixDialog.show<T>(
      context: context,
      title: title,
      summary: summary,
      content: content,
      actions: actions,
      titleColor: titleColor,
      summaryColor: summaryColor,
      backgroundColor: backgroundColor,
      enableWindowDim: enableWindowDim,
      outsideMargin: outsideMargin,
      insideMargin: insideMargin,
      defaultWindowInsetsPadding: defaultWindowInsetsPadding,
      maxWidth: maxWidth,
      largeScreen: largeScreen,
      cornerRadius: cornerRadius,
      glass: glass,
      surfaceBuilder: surfaceBuilder,
      barrierDismissible: barrierDismissible,
      onDismissRequest: onDismissRequest,
      onDismissFinished: onDismissFinished,
    );
  }

  /// Shows a window dialog whose complete configuration follows MediaQuery.
  static Future<T?> showBuilder<T>({
    required BuildContext context,
    required WidgetBuilder dialogBuilder,
    bool enableWindowDim = true,
    bool? largeScreen,
    bool barrierDismissible = true,
    VoidCallback? onDismissRequest,
    VoidCallback? onDismissFinished,
  }) {
    return MiuixDialog.showBuilder<T>(
      context: context,
      dialogBuilder: dialogBuilder,
      enableWindowDim: enableWindowDim,
      largeScreen: largeScreen,
      barrierDismissible: barrierDismissible,
      onDismissRequest: onDismissRequest,
      onDismissFinished: onDismissFinished,
    );
  }
}

/// Overlay-named bottom sheet adapter matching MIUIX component naming.
class MiuixOverlayBottomSheet {
  /// Shows an overlay bottom sheet.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    Widget? startAction,
    Widget? endAction,
    MiuixBottomSheetController? controller,
    bool allowDismiss = true,
    bool enableNestedScroll = true,
    Color? backgroundColor,
    bool enableWindowDim = true,
    double? cornerRadius,
    double sheetMaxWidth = MiuixBottomSheetDefaults.maxWidth,
    EdgeInsetsGeometry outsideMargin = MiuixBottomSheetDefaults.outsideMargin,
    bool? glass,
    bool renderInRootScaffold = true,
    EdgeInsetsGeometry insideMargin = MiuixBottomSheetDefaults.insideMargin,
    bool defaultWindowInsetsPadding = true,
    Color? dragHandleColor,
    VoidCallback? onDismissRequest,
    VoidCallback? onDismissFinished,
  }) {
    final nearest = MiuixPopupHostScope.maybeOf(context);
    if (nearest == null) {
      throw FlutterError(
        'MiuixOverlayBottomSheet requires a MiuixScaffold or MiuixPopupHost.',
      );
    }
    final popupHost = renderInRootScaffold ? nearest.root : nearest;
    final ownsController = controller == null;
    final behavior =
        controller ??
        MiuixBottomSheetController(
          allowDismiss: allowDismiss,
          enableNestedScroll: enableNestedScroll,
        );
    final backProgress = _MiuixBottomSheetBackProgress(
      behavior,
      disposeBehavior: ownsController,
    );
    var dismissRequested = false;
    void requestDismiss() {
      if (!dismissRequested) {
        dismissRequested = true;
        onDismissRequest?.call();
      }
    }

    void dismissFromAction() {
      requestDismiss();
      popupHost.dismissTop<T>();
    }

    void dismissAfterSettledDrag() {
      requestDismiss();
      popupHost._dismissTopImmediately<T>();
    }

    behavior._attach(
      dismissFromAction,
      dismissAfterSettledDrag: dismissAfterSettledDrag,
    );
    final future = popupHost.show<T>(
      unanchoredAlignment: Alignment.bottomCenter,
      dimBackground: enableWindowDim,
      dimColor: MiuixSemanticColors.of(context)['windowDimming'],
      dimAlpha: backProgress,
      bottomSheetTransition: true,
      canDismiss: () => behavior.allowDismiss,
      onDismissRequest: requestDismiss,
      onDismissFinished: onDismissFinished,
      child: _MiuixOverlayBottomSheetHost(
        controller: behavior,
        child: _MiuixBottomSheetSurface(
          // Overlay and Window hosts share the current HyperOS 4 glass default;
          // passing false retains the opaque source-compatible presentation.
          glass: glass ?? true,
          backgroundColor: backgroundColor,
          cornerRadius: cornerRadius,
          sheetMaxWidth: sheetMaxWidth,
          outsideMargin: outsideMargin,
          insideMargin: insideMargin,
          defaultWindowInsetsPadding: defaultWindowInsetsPadding,
          dragHandleColor: dragHandleColor,
          title: title,
          startAction: startAction,
          endAction: endAction,
          controller: behavior,
          backProgress: backProgress,
          child: child,
        ),
      ),
    );
    return future.whenComplete(() {
      behavior._detach(dismissFromAction);
    });
  }
}

class _MiuixOverlayBottomSheetHost extends StatelessWidget {
  const _MiuixOverlayBottomSheetHost({
    required this.controller,
    required this.child,
  });

  final MiuixBottomSheetController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop &&
            controller.allowDismiss &&
            !MiuixBackGestureScope.blockedOf(context)) {
          controller.dismiss();
        }
      },
      child: child,
    );
  }
}

/// Window-named bottom sheet adapter matching MIUIX component naming.
class MiuixWindowBottomSheet {
  /// Shows a window bottom sheet.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    Widget? startAction,
    Widget? endAction,
    MiuixBottomSheetController? controller,
    bool allowDismiss = true,
    bool enableNestedScroll = true,
    Color? backgroundColor,
    bool enableWindowDim = true,
    double? cornerRadius,
    double sheetMaxWidth = MiuixBottomSheetDefaults.maxWidth,
    EdgeInsetsGeometry outsideMargin = MiuixBottomSheetDefaults.outsideMargin,
    bool? glass,
    EdgeInsetsGeometry insideMargin = MiuixBottomSheetDefaults.insideMargin,
    bool defaultWindowInsetsPadding = true,
    Color? dragHandleColor,
    VoidCallback? onDismissRequest,
    VoidCallback? onDismissFinished,
  }) {
    return MiuixBottomSheet.show<T>(
      context: context,
      child: child,
      title: title,
      startAction: startAction,
      endAction: endAction,
      controller: controller,
      allowDismiss: allowDismiss,
      enableNestedScroll: enableNestedScroll,
      backgroundColor: backgroundColor,
      enableWindowDim: enableWindowDim,
      cornerRadius: cornerRadius,
      sheetMaxWidth: sheetMaxWidth,
      outsideMargin: outsideMargin,
      glass: glass,
      insideMargin: insideMargin,
      defaultWindowInsetsPadding: defaultWindowInsetsPadding,
      dragHandleColor: dragHandleColor,
      onDismissRequest: onDismissRequest,
      onDismissFinished: onDismissFinished,
    );
  }
}
