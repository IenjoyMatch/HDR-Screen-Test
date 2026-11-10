import '../../icons/miuix_icon_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../platform/miuix_haptics.dart';
import '../../theme/miuix_semantic_colors.dart';
import '../../theme/miuix_theme.dart';
import '../../widgets/miuix_widgets.dart';
import '../miuix_extension_icons.dart';

/// Status of one task in a [MiuixProcessStepper].
enum MiuixProcessStepState { pending, current, completed, error, skipped }

/// Reading direction used by the process stepper.
enum MiuixProcessStepperOrientation { vertical, horizontal }

/// Immutable content for one process step.
@immutable
class MiuixProcessStep {
  /// Creates one step with optional detail, body, and custom action area.
  const MiuixProcessStep({
    required this.title,
    this.subtitle,
    this.content,
    this.actions,
    this.icon,
    this.state,
    this.enabled = true,
  });

  /// Main and supporting labels.
  final String title;
  final String? subtitle;

  /// Body displayed while this step is current and an optional action row.
  final Widget? content;
  final Widget? actions;

  /// Optional marker replacement and explicit state override.
  final Widget? icon;
  final MiuixProcessStepState? state;

  /// Whether pointer and keyboard activation can select this step.
  final bool enabled;
}

/// Hoisted current-step state shared by steppers and application workflows.
class MiuixProcessStepperController extends ChangeNotifier {
  /// Creates a controller positioned at [currentStep].
  MiuixProcessStepperController({int currentStep = 0})
    : _currentStep = currentStep < 0 ? 0 : currentStep;

  int _currentStep;

  /// Zero-based current step.
  int get currentStep => _currentStep;

  /// Moves directly to a non-negative step.
  void jumpTo(int value) {
    final next = value < 0 ? 0 : value;
    if (_currentStep == next) return;
    _currentStep = next;
    notifyListeners();
  }

  /// Advances or goes back one step.
  void next() => jumpTo(_currentStep + 1);
  void previous() => jumpTo(_currentStep - 1);
}

/// Semantic palette for [MiuixProcessStepper].
@immutable
class MiuixProcessStepperColors {
  /// Creates a complete process palette.
  const MiuixProcessStepperColors({
    required this.active,
    required this.completed,
    required this.pending,
    required this.error,
    required this.foreground,
    required this.secondaryForeground,
    required this.selectedContainer,
  });

  final Color active;
  final Color completed;
  final Color pending;
  final Color error;
  final Color foreground;
  final Color secondaryForeground;
  final Color selectedContainer;
}

/// Geometry and color defaults for multi-step application flows.
abstract final class MiuixProcessStepperDefaults {
  // HyperOS 4 process-stepper implementation contract:
  // - One current step owns detail content and the active action hierarchy.
  // - Vertical and horizontal layouts expose the same content and actions.
  // - Marker, connector, content, and actions share one process-state clock.
  // - Reduced motion replaces expansion with the exact selected structure.
  // - Direct pointer and keyboard selection remain immediate in every mode.
  // - The active step may sample glass only inside its continuous silhouette.
  // - Inactive rows remain visually quiet and never create opaque rectangles.
  // - Explicit step state remains authoritative over inferred index state.
  // - Semantic order and enabled state stay stable while content changes.
  // - The inline-surface token family owns new-design radius and material.
  // - Source construction preserves the former fixed opaque step geometry.
  // - Negative controller seeds normalize synchronously to the first step.
  // - Negative controlled scalar values present the first available step.
  // - Oversized scalar values present the last available step immediately.
  // - Empty workflows retain index zero without painting a phantom marker.
  // - Dynamic shrink writes a durable projected controller value after layout.
  // - Constructor behavior remains identical with assertions compiled away.
  // These rules are project calibration, not unpublished Xiaomi constants.

  /// Marker and connector measurements.
  static const double markerExtent = 30;
  static const double connectorExtent = 3;
  static const double horizontalStepWidth = 196;
  static const double cornerRadius = 18;

  /// Resolves colors from MIUIX semantic roles.
  static MiuixProcessStepperColors colors(BuildContext context) {
    final semantic = MiuixSemanticColors.of(context);
    return MiuixProcessStepperColors(
      active: semantic['primary'],
      completed: semantic['primary'],
      pending: semantic['surfaceContainerHigh'],
      error: semantic['error'],
      foreground: semantic['onSurface'],
      secondaryForeground: semantic['onSurfaceSecondary'],
      selectedContainer: semantic['primaryContainer'],
    );
  }
}

/// Interactive process stepper for forms, setup flows, and task progress.
///
/// Unlike a passive timeline, this widget owns a current index, exposes
/// forward/back callbacks, supports keyboard traversal, and expands only the
/// current step's content. Explicit states on [MiuixProcessStep] take
/// precedence over states inferred from the current index.
/// Reduced motion builds the selected content structure directly and snaps
/// marker and connector colors without retaining an animated-size subtree.
class MiuixProcessStepper extends StatefulWidget {
  /// Creates a process stepper whose selected step uses inline glass.
  const MiuixProcessStepper({
    super.key,
    required this.steps,
    this.controller,
    this.currentStep,
    this.onStepChanged,
    this.onContinue,
    this.onCancel,
    this.orientation = MiuixProcessStepperOrientation.vertical,
    this.allowStepSelection = true,
    this.showDefaultActions = true,
    this.continueLabel = '继续',
    this.backLabel = '上一步',
    this.finishLabel = '完成',
    this.colors,
    this.cornerRadius = double.nan,
    this.glass = true,
  });

  /// Creates a stepper with the former fixed 18dp opaque step surfaces.
  const MiuixProcessStepper.source({
    super.key,
    required this.steps,
    this.controller,
    this.currentStep,
    this.onStepChanged,
    this.onContinue,
    this.onCancel,
    this.orientation = MiuixProcessStepperOrientation.vertical,
    this.allowStepSelection = true,
    this.showDefaultActions = true,
    this.continueLabel = '继续',
    this.backLabel = '上一步',
    this.finishLabel = '完成',
    this.colors,
  }) : cornerRadius = MiuixProcessStepperDefaults.cornerRadius,
       glass = false;

  /// Ordered workflow steps.
  final List<MiuixProcessStep> steps;

  /// Hoisted state, or a scalar controlled value for simpler callers.
  final MiuixProcessStepperController? controller;
  final int? currentStep;

  /// Selection and default action callbacks.
  final ValueChanged<int>? onStepChanged;
  final VoidCallback? onContinue;
  final VoidCallback? onCancel;

  /// Layout and interaction policy.
  final MiuixProcessStepperOrientation orientation;
  final bool allowStepSelection;
  final bool showDefaultActions;

  /// Localizable default button labels.
  final String continueLabel;
  final String backLabel;
  final String finishLabel;

  final MiuixProcessStepperColors? colors;

  /// Step-surface radius; omitted values follow inline-surface tokens.
  final double cornerRadius;

  /// Whether the selected step samples the shared inline glass material.
  final bool glass;

  @override
  State<MiuixProcessStepper> createState() => _MiuixProcessStepperState();
}

class _MiuixProcessStepperState extends State<MiuixProcessStepper> {
  late MiuixProcessStepperController _controller;
  late bool _ownsController;
  final FocusNode _focusNode = FocusNode(debugLabel: 'MiuixProcessStepper');
  int _normalizationGeneration = 0;

  int get _current {
    if (widget.steps.isEmpty) return 0;
    final requested = widget.currentStep ?? _controller.currentStep;
    return requested.clamp(0, widget.steps.length - 1);
  }

  @override
  void initState() {
    super.initState();
    _attachController();
    _scheduleControllerNormalization();
  }

  void _attachController() {
    _ownsController = widget.controller == null;
    _controller =
        widget.controller ??
        MiuixProcessStepperController(currentStep: widget.currentStep ?? 0);
    _controller.addListener(_rebuild);
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(MiuixProcessStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _controller.removeListener(_rebuild);
      if (_ownsController) _controller.dispose();
      _attachController();
    }
    if (oldWidget.controller != widget.controller ||
        oldWidget.steps.length != widget.steps.length ||
        oldWidget.currentStep != widget.currentStep) {
      _scheduleControllerNormalization();
    }
  }

  void _scheduleControllerNormalization() {
    // Controller normalization contract:
    // - A controlled scalar is presentation-only and never writes controller.
    // - An uncontrolled controller is the durable source of selected position.
    // - Empty steps normalize storage to zero without rendering a phantom step.
    // - Shrinking steps projects the old position to the nearest valid index.
    // - Growing steps leaves an already valid selection unchanged.
    // - The correction happens after build, never while descendants are built.
    // - Every scheduled correction receives a monotonically increasing token.
    // - A newer widget update invalidates every older post-frame correction.
    // - Replacing the external controller invalidates work for the old owner.
    // - Switching into controlled mode invalidates uncontrolled write-back.
    // - Disposal invalidates work before the controller listener is detached.
    // - The captured controller identity is checked again at callback time.
    // - A no-op projection does not allocate a frame callback.
    // - The controller publishes its normal ChangeNotifier event on correction.
    // - onStepChanged publishes the same corrected index exactly once.
    // - Normalization is programmatic maintenance, so it emits no haptic tick.
    // - User selection still follows the separate pointer/keyboard path below.
    // - Disabled step policy is not applied to storage normalization itself.
    // - Explicit per-step visual states remain independent of selected index.
    // - This keeps dynamic workflows deterministic across parent rebuilds.
    // - It also prevents stale deleted indices from leaking into later reads.
    // - The example app is not involved in any part of this state contract.
    // - Tests cover initial overflow, step shrink, replacement and publication.
    // - Future async work must join this generation rather than add raw frames.
    // - Callers retain ownership and disposal responsibility for their controller.
    // - Internally owned controllers continue to be disposed by this State.
    // - The visible getter clamps immediately while storage catches up next frame.
    // - Therefore a shrink never paints an out-of-range transient frame.
    // - Callbacks observe a value that is already readable from the controller.
    // - This ordering is part of the public behavioral compatibility promise.
    final generation = ++_normalizationGeneration;
    if (widget.currentStep != null) return;
    final observedController = _controller;
    final target = widget.steps.isEmpty
        ? 0
        : observedController.currentStep.clamp(0, widget.steps.length - 1);
    if (target == observedController.currentStep) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          generation != _normalizationGeneration ||
          widget.currentStep != null ||
          !identical(_controller, observedController)) {
        return;
      }
      observedController.jumpTo(target);
      widget.onStepChanged?.call(target);
    });
  }

  MiuixProcessStepState _stateFor(int index) {
    final explicit = widget.steps[index].state;
    if (explicit != null) return explicit;
    if (index < _current) return MiuixProcessStepState.completed;
    if (index == _current) return MiuixProcessStepState.current;
    return MiuixProcessStepState.pending;
  }

  Color _stateColor(
    MiuixProcessStepperColors colors,
    MiuixProcessStepState state,
  ) => switch (state) {
    MiuixProcessStepState.current => colors.active,
    MiuixProcessStepState.completed => colors.completed,
    MiuixProcessStepState.error => colors.error,
    MiuixProcessStepState.pending ||
    MiuixProcessStepState.skipped => colors.pending,
  };

  void _select(int index) {
    if (!widget.allowStepSelection ||
        !widget.steps[index].enabled ||
        index == _current) {
      return;
    }
    if (widget.currentStep == null) _controller.jumpTo(index);
    widget.onStepChanged?.call(index);
    MiuixHaptics.perform(MiuixHapticType.segmentTick);
  }

  void _move(int delta) {
    if (widget.steps.isEmpty) return;
    var candidate = _current;
    do {
      final next = (candidate + delta).clamp(0, widget.steps.length - 1);
      if (next == candidate) return;
      candidate = next;
      if (widget.steps[candidate].enabled) {
        _select(candidate);
        return;
      }
    } while (candidate != 0 && candidate != widget.steps.length - 1);
  }

  Widget _marker(
    int index,
    MiuixProcessStep step,
    MiuixProcessStepperColors colors,
  ) {
    final state = _stateFor(index);
    final fill = _stateColor(colors, state);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final motion = MiuixTheme.of(context).hyperOs4.processStateMotion;
    final icon = switch (state) {
      MiuixProcessStepState.completed => MiuixExtensionGlyphs.confirm,
      MiuixProcessStepState.error => MiuixExtensionGlyphs.close,
      MiuixProcessStepState.skipped => MiuixExtensionGlyphs.remove,
      MiuixProcessStepState.current => Icons.circle,
      MiuixProcessStepState.pending => null,
    };
    return AnimatedContainer(
      key: ValueKey<(int, bool)>((index, reduceMotion)),
      duration: reduceMotion ? Duration.zero : motion,
      curve: Curves.easeOutCubic,
      width: MiuixProcessStepperDefaults.markerExtent,
      height: MiuixProcessStepperDefaults.markerExtent,
      decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: IconTheme(
        data: IconThemeData(
          size: 17,
          color: state == MiuixProcessStepState.pending
              ? colors.secondaryForeground
              : Colors.white,
        ),
        child:
            step.icon ??
            (icon == null
                ? Text('${index + 1}', style: const TextStyle(fontSize: 13))
                : MiuixThemedIcon(icon)),
      ),
    );
  }

  Widget _labels(MiuixProcessStep step, MiuixProcessStepperColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          step.title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: step.enabled
                ? colors.foreground
                : colors.secondaryForeground,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (step.subtitle != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              step.subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.secondaryForeground,
              ),
            ),
          ),
      ],
    );
  }

  Widget _defaultActions(int index) {
    // Default-action contract:
    // - The primary label changes to finish only on the final logical step.
    // - The back action is absent on the first step rather than disabled.
    // - Owning applications retain control of actual workflow advancement.
    // - The stepper never mutates the index merely because Continue is tapped.
    // - Actions wrap on narrow cards instead of overflowing horizontally.
    // - Run spacing preserves separation after text-scale induced wrapping.
    // - Button components supply their own semantics, focus, and haptics.
    // - A custom action widget replaces this complete default action group.
    // - Horizontal and vertical orientations call this identical builder.
    // - Reduced motion affects insertion only, never action availability.
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: <Widget>[
        MiuixButton(
          label: index == widget.steps.length - 1
              ? widget.finishLabel
              : widget.continueLabel,
          filled: true,
          onPressed: widget.onContinue,
        ),
        if (index > 0)
          MiuixTextButton(label: widget.backLabel, onPressed: widget.onCancel),
      ],
    );
  }

  Widget _verticalStep(int index, MiuixProcessStepperColors colors) {
    // Vertical-step layout contract:
    // - The marker column keeps a stable width while labels may wrap freely.
    // - The connector starts below the marker and ends at the row boundary.
    // - Only the current row inserts content and action widgets.
    // - AnimatedSize observes one complete content branch, not each child.
    // - Reduced motion substitutes that branch before layout interpolation.
    // - Selected glass is clipped by the same surface that owns pointer input.
    // - An inactive row stays transparent but retains its complete hit region.
    // - Custom actions replace, rather than duplicate, default navigation.
    // - Explicit caller radius remains authoritative over theme calibration.
    // - Semantic selection follows the controlled index during every frame.
    // - Connector tint and marker tint share the same resolved state mapping.
    // - Content insertion never changes marker or connector column alignment.
    // - Keyboard and pointer paths both dispatch through the same selector.
    // - Disabled steps remain readable but cannot receive selection feedback.
    // - No glass or shadow layer is allowed outside the step silhouette.
    final step = widget.steps[index];
    final current = index == _current;
    final connector = _stateColor(colors, _stateFor(index));
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final motion = MiuixTheme.of(context).hyperOs4.processStateMotion;
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final radius = widget.cornerRadius.isFinite
        ? widget.cornerRadius.clamp(0.0, double.infinity).toDouble()
        : hyperOs4.inlineSurfaceCornerRadius;
    final expansion = !current
        ? const SizedBox(width: double.infinity)
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (step.content != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: step.content!,
                ),
              if (step.actions != null || widget.showDefaultActions)
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: step.actions ?? _defaultActions(index),
                ),
            ],
          );
    return Semantics(
      button: widget.allowStepSelection,
      selected: current,
      enabled: step.enabled,
      label: step.title,
      value: '${index + 1}/${widget.steps.length}',
      child: Stack(
        children: <Widget>[
          if (index < widget.steps.length - 1)
            PositionedDirectional(
              start: (38 - MiuixProcessStepperDefaults.connectorExtent) / 2,
              top: MiuixProcessStepperDefaults.markerExtent,
              bottom: 0,
              child: AnimatedContainer(
                key: ValueKey<(int, bool)>((index, reduceMotion)),
                duration: reduceMotion ? Duration.zero : motion,
                width: MiuixProcessStepperDefaults.connectorExtent,
                color: connector,
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 38,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: _marker(index, step, colors),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MiuixSurface(
                  key: ValueKey<String>('miuix-process-step-$index'),
                  radius: radius,
                  color: current
                      ? colors.selectedContainer
                      : Colors.transparent,
                  glass: widget.glass && current,
                  glassBlur: hyperOs4.inlineSurfaceBlur,
                  glassOpacity: hyperOs4.inlineSurfaceTintOpacity,
                  onTap: () => _select(index),
                  enabled: widget.allowStepSelection && step.enabled,
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _labels(step, colors),
                      if (reduceMotion)
                        expansion
                      else
                        AnimatedSize(
                          duration: motion,
                          curve: Curves.easeOutCubic,
                          alignment: Alignment.topCenter,
                          child: expansion,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _horizontalStep(int index, MiuixProcessStepperColors colors) {
    // Horizontal-step layout contract:
    // - Every step keeps the stable source width for predictable scrolling.
    // - Marker and connector occupy the first row in reading order.
    // - The last step omits its outgoing connector without adding a spacer.
    // - Connector color interpolates on the shared process-state timeline.
    // - Detail content and actions match the vertical component hierarchy.
    // - Both detail branches are wrapped by one AnimatedSize transition.
    // - Reduced motion builds only the exact current branch immediately.
    // - Default action labels remain localizable through the parent widget.
    // - Custom actions replace default actions for the selected step only.
    // - Selection glass is clipped to the tokenized continuous rectangle.
    // - Inactive cards stay transparent and preserve their semantic bounds.
    // - Horizontal scrolling does not create a competing primary controller.
    // - Directional keyboard navigation reuses the common selection method.
    // - State changes never remove titles or shift the marker reading order.
    // - Explicit radius values bypass project calibration in both orientations.
    // - The source constructor retains the former opaque 18dp surface path.
    final step = widget.steps[index];
    final current = index == _current;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final motion = hyperOs4.processStateMotion;
    final radius = widget.cornerRadius.isFinite
        ? widget.cornerRadius.clamp(0.0, double.infinity).toDouble()
        : hyperOs4.inlineSurfaceCornerRadius;
    final expansion = !current
        ? const SizedBox(width: double.infinity)
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (step.content != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: step.content!,
                ),
              if (step.actions != null || widget.showDefaultActions)
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: step.actions ?? _defaultActions(index),
                ),
            ],
          );
    return SizedBox(
      width: MiuixProcessStepperDefaults.horizontalStepWidth,
      child: Semantics(
        button: widget.allowStepSelection,
        selected: current,
        enabled: step.enabled,
        label: step.title,
        child: MiuixSurface(
          key: ValueKey<String>('miuix-process-step-$index'),
          radius: radius,
          color: current ? colors.selectedContainer : Colors.transparent,
          glass: widget.glass && current,
          glassBlur: hyperOs4.inlineSurfaceBlur,
          glassOpacity: hyperOs4.inlineSurfaceTintOpacity,
          onTap: () => _select(index),
          enabled: widget.allowStepSelection && step.enabled,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  _marker(index, step, colors),
                  if (index < widget.steps.length - 1)
                    Expanded(
                      child: AnimatedContainer(
                        key: ValueKey<(int, bool)>((index, reduceMotion)),
                        duration: reduceMotion ? Duration.zero : motion,
                        curve: Curves.easeOutCubic,
                        height: MiuixProcessStepperDefaults.connectorExtent,
                        color: _stateColor(colors, _stateFor(index)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              _labels(step, colors),
              if (reduceMotion)
                expansion
              else
                AnimatedSize(
                  duration: motion,
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: expansion,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _normalizationGeneration++;
    _controller.removeListener(_rebuild);
    if (_ownsController) _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Root composition contract:
    // - An empty workflow produces no focus target or stray scroll container.
    // - The caller's controller is observed but never disposed by this widget.
    // - An internally created controller is disposed with the stepper state.
    // - Arrow keys map by logical movement and skip disabled destinations.
    // - Horizontal overflow is local and never claims the page primary scroll.
    // - Vertical mode preserves parent scrolling and expands in normal layout.
    // - Theme colors resolve once per build for one coherent process snapshot.
    // - Focus ownership remains stable when selected content is reconstructed.
    // - Public selection callbacks fire from keyboard and pointer paths alike.
    // - No example-only state or localization dependency enters this library.
    if (widget.steps.isEmpty) return const SizedBox.shrink();
    final colors = widget.colors ?? MiuixProcessStepperDefaults.colors(context);
    final horizontal =
        widget.orientation == MiuixProcessStepperOrientation.horizontal;
    final keyboardSelectionEnabled =
        widget.allowStepSelection && widget.steps.any((step) => step.enabled);
    final shortcuts = !keyboardSelectionEnabled
        ? const <ShortcutActivator, Intent>{}
        : horizontal
        ? const <ShortcutActivator, Intent>{
            SingleActivator(LogicalKeyboardKey.arrowLeft): _StepperMoveIntent(
              -1,
            ),
            SingleActivator(LogicalKeyboardKey.arrowRight): _StepperMoveIntent(
              1,
            ),
          }
        : const <ShortcutActivator, Intent>{
            SingleActivator(LogicalKeyboardKey.arrowUp): _StepperMoveIntent(-1),
            SingleActivator(LogicalKeyboardKey.arrowDown): _StepperMoveIntent(
              1,
            ),
          };
    return Shortcuts(
      shortcuts: shortcuts,
      child: Actions(
        actions: <Type, Action<Intent>>{
          _StepperMoveIntent: CallbackAction<_StepperMoveIntent>(
            onInvoke: (intent) {
              _move(intent.delta);
              return null;
            },
          ),
        },
        child: Focus(
          focusNode: _focusNode,
          canRequestFocus: keyboardSelectionEnabled,
          child: horizontal
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List<Widget>.generate(
                      widget.steps.length,
                      (index) => _horizontalStep(index, colors),
                    ),
                  ),
                )
              : Column(
                  children: List<Widget>.generate(
                    widget.steps.length,
                    (index) => _verticalStep(index, colors),
                  ),
                ),
        ),
      ),
    );
  }
}

class _StepperMoveIntent extends Intent {
  const _StepperMoveIntent(this.delta);
  final int delta;
}
