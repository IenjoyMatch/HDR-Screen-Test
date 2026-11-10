part of '../miuix_widgets.dart';

/// Source dimensions used by [MiuixIconButton].
///
/// The values mirror `IconButtonDefaults` in MIUIX 1.0.9. The visible
/// placeable is 40dp by default; Android independently exposes a 48dp minimum
/// interactive target without increasing the measured layout size.
abstract final class MiuixIconButtonDefaults {
  // Runtime slot and geometry contract:
  // - Arbitrary child content takes precedence over the icon convenience.
  // - Missing content retains an empty but measurable action placeable.
  // - Finite negative dimensions clamp to zero rather than enter constraints.
  // - Non-finite dimensions restore the current public HyperOS defaults.
  // - The same resolved radius owns decoration, clip, and indication paint.
  // - Valid zero dimensions remain an explicit compact-layout request.
  // - The Android interaction target remains independent from visible size.
  // - Debug and Release therefore expose identical malformed-input behavior.

  /// Explicit MIUIX 1.0.9 painted size.
  static const double legacySize = 40;

  /// Explicit MIUIX 1.0.9 radius.
  static const double legacyCornerRadius = 40;

  /// Default minimum width of the visible placeable.
  static const double minWidth = 44;

  /// Default minimum height of the visible placeable.
  static const double minHeight = 44;

  /// Default continuous-corner radius.
  static const double cornerRadius = 22;

  /// Android's accessibility and pointer target around the visual placeable.
  static const double minimumInteractiveSize = 48;
}

/// Internal interaction selector for the four current indication springs.
enum _MiuixIconButtonIndicationChange {
  pressEnter,
  pressExit,
  hoverEnter,
  hoverExit,
  focusEnter,
  focusExit,
  holdEnter,
  holdExit,
}

/// Recreates the exact `folmeSpring` pairs used by `MiuixIndication.kt`.
SpringDescription _miuixIconButtonIndicationSpring({
  required bool entering,
  required bool hoverOrFocus,
}) {
  final response = hoverOrFocus ? (entering ? .6 : .2) : (entering ? .2 : .35);
  final dampingRatio = entering ? 1.0 : (hoverOrFocus ? .96 : .95);
  final angularFrequency = 2 * math.pi / response;
  return SpringDescription.withDampingRatio(
    mass: 1,
    stiffness: angularFrequency * angularFrequency,
    ratio: dampingRatio,
  );
}

/// Compact MIUIX icon action.
///
/// This is a direct Flutter counterpart of MIUIX `IconButton`. It deliberately
/// keeps the source's minimum-size rather than fixed-size contract, so larger
/// custom content can expand the button. The Android touch target is handled
/// by a render object and therefore does not alter toolbar measurement.
class MiuixIconButton extends StatefulWidget {
  /// Creates a source-compatible MIUIX icon button.
  ///
  /// [icon] is retained as the convenient API used by earlier releases of this
  /// package. [child] exposes the arbitrary content slot from the source API.
  /// When both are supplied [child] wins; when neither is supplied the button
  /// retains its geometry with empty content. The rule is identical in Debug
  /// and Release builds and keeps decoded toolbar configurations recoverable.
  const MiuixIconButton({
    super.key,
    required this.onPressed,
    this.icon,
    this.child,
    this.enabled = true,
    this.holdDownState = false,
    this.backgroundColor,
    this.contentColor,
    this.cornerRadius = MiuixIconButtonDefaults.cornerRadius,
    this.minHeight = MiuixIconButtonDefaults.minHeight,
    this.minWidth = MiuixIconButtonDefaults.minWidth,
    this.tooltip,
    this.selected = false,
  });

  /// Creates the explicit MIUIX 1.0.9 icon-button geometry.
  const MiuixIconButton.source({
    super.key,
    required this.onPressed,
    this.icon,
    this.child,
    this.enabled = true,
    this.holdDownState = false,
    this.backgroundColor,
    this.contentColor,
    this.cornerRadius = MiuixIconButtonDefaults.legacyCornerRadius,
    this.minHeight = MiuixIconButtonDefaults.legacySize,
    this.minWidth = MiuixIconButtonDefaults.legacySize,
    this.tooltip,
    this.selected = false,
  });

  /// Convenience icon content.
  ///
  /// Use [child] instead when the source slot contains more than one widget.
  final Widget? icon;

  /// Arbitrary source-compatible content.
  final Widget? child;

  /// Callback invoked after a completed tap.
  ///
  /// A null callback disables the interaction for compatibility with ordinary
  /// Flutter controls. The source's explicit [enabled] switch is still applied
  /// independently when the callback is non-null.
  final VoidCallback? onPressed;

  /// Whether the clickable modifier is installed.
  ///
  /// MIUIX does not change the painted background or content tint when this is
  /// false; it only removes pointer, pressed-indication, and button semantics.
  final bool enabled;

  /// Keeps the MIUIX indication in its externally controlled held state.
  ///
  /// Popup anchors use this while their popup remains visible. Pointer press
  /// and hold-down each use the 10% channel; hold-down supersedes an overlapping
  /// pointer press, matching current `MiuixIndication.kt`.
  final bool holdDownState;

  /// Optional button background.
  ///
  /// A null value corresponds to Compose `Color.Unspecified` and paints no
  /// visible fill. It remains unchanged when the button is disabled.
  final Color? backgroundColor;

  /// Optional inherited color for icon and text content.
  ///
  /// The original slot inherits `LocalContentColor`; Flutter callers may use
  /// this property to provide the equivalent local value. When omitted, this
  /// widget leaves the nearest IconTheme and DefaultTextStyle unchanged.
  final Color? contentColor;

  /// Radius passed to the MIUIX smooth-corner shape.
  final double cornerRadius;

  /// Minimum visible height before larger custom content is measured.
  final double minHeight;

  /// Minimum visible width before larger custom content is measured.
  final double minWidth;

  /// Optional package extension that shows a MIUIX tooltip.
  ///
  /// The source icon button has no tooltip parameter; its icon content owns
  /// the accessibility description. Reference-example usages therefore avoid
  /// this extension unless they are specifically demonstrating tooltips.
  final String? tooltip;

  /// Backward-compatible selected presentation.
  ///
  /// This is a Flutter package extension, not a source parameter. An explicit
  /// [backgroundColor] takes precedence over the selected container color.
  final bool selected;

  bool get _isInteractive => enabled && onPressed != null;

  @override
  State<MiuixIconButton> createState() => _MiuixIconButtonState();
}

class _MiuixIconButtonState extends State<MiuixIconButton>
    with SingleTickerProviderStateMixin {
  bool _pointerPressed = false;
  bool _hovered = false;
  bool _focused = false;
  late final AnimationController _indicationController;
  TickerFuture? _positiveIndicationAnimation;
  int _indicationRevision = 0;
  bool _reduceMotion = false;

  double get _indicationTarget {
    if (!widget._isInteractive) return 0;
    return (_hovered ? .06 : 0) +
        (_focused ? .08 : 0) +
        (_pointerPressed && !widget.holdDownState ? .10 : 0) +
        (widget.holdDownState ? .10 : 0);
  }

  @override
  void initState() {
    super.initState();
    _indicationController = AnimationController.unbounded(vsync: this);
    if (widget._isInteractive && widget.holdDownState) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _syncIndication(_MiuixIconButtonIndicationChange.holdEnter);
        }
      });
    }
  }

  int _iconActivation = 0;

  void _activate() {
    if (!widget._isInteractive) return;
    setState(() => _iconActivation++);
    widget.onPressed?.call();
  }

  void _setPointerPressed(bool value) {
    if (_pointerPressed == value || !mounted) {
      return;
    }
    setState(() => _pointerPressed = value);
    _syncIndication(
      value
          ? _MiuixIconButtonIndicationChange.pressEnter
          : _MiuixIconButtonIndicationChange.pressExit,
    );
  }

  void _setHovered(bool value) {
    if (_hovered == value || !mounted) return;
    setState(() => _hovered = value);
    _syncIndication(
      value
          ? _MiuixIconButtonIndicationChange.hoverEnter
          : _MiuixIconButtonIndicationChange.hoverExit,
    );
  }

  void _setFocused(bool value) {
    if (_focused == value || !mounted) return;
    setState(() => _focused = value);
    _syncIndication(
      value
          ? _MiuixIconButtonIndicationChange.focusEnter
          : _MiuixIconButtonIndicationChange.focusExit,
    );
  }

  void _syncIndication(_MiuixIconButtonIndicationChange change) {
    final target = _indicationTarget;
    final revision = ++_indicationRevision;
    if (_reduceMotion) {
      _positiveIndicationAnimation = null;
      _indicationController
        ..stop(canceled: true)
        ..value = target;
      return;
    }
    final hoverOrFocus = switch (change) {
      _MiuixIconButtonIndicationChange.hoverEnter ||
      _MiuixIconButtonIndicationChange.hoverExit ||
      _MiuixIconButtonIndicationChange.focusEnter ||
      _MiuixIconButtonIndicationChange.focusExit => true,
      _ => false,
    };
    final entering = switch (change) {
      _MiuixIconButtonIndicationChange.pressEnter ||
      _MiuixIconButtonIndicationChange.hoverEnter ||
      _MiuixIconButtonIndicationChange.focusEnter ||
      _MiuixIconButtonIndicationChange.holdEnter => true,
      _ => false,
    };
    final spring = _miuixIconButtonIndicationSpring(
      entering: entering,
      hoverOrFocus: hoverOrFocus,
    );
    final waitsForPositive =
        change == _MiuixIconButtonIndicationChange.pressExit ||
        change == _MiuixIconButtonIndicationChange.holdExit ||
        target == 0;
    if (!waitsForPositive) {
      // Animatable.animateTo preserves the interrupted spring velocity. Capture
      // it before stop(), otherwise layered hover/focus/press input visibly
      // pauses before accelerating toward the new positive alpha.
      final carriedVelocity = _indicationController.velocity;
      _indicationController.stop(canceled: true);
      _positiveIndicationAnimation = _indicationController.animateWith(
        SpringSimulation(
          spring,
          _indicationController.value,
          target,
          carriedVelocity,
          tolerance: const Tolerance(distance: .0001, velocity: .0001),
        ),
      );
      return;
    }
    final positiveAnimation = _positiveIndicationAnimation;
    () async {
      try {
        await positiveAnimation?.orCancel;
      } catch (_) {
        // A newer positive state intentionally supersedes this pending rest.
      }
      if (!mounted ||
          revision != _indicationRevision ||
          _indicationTarget != target) {
        return;
      }
      _indicationController.animateWith(
        SpringSimulation(
          spring,
          _indicationController.value,
          target,
          _indicationController.velocity,
          tolerance: const Tolerance(distance: .0001, velocity: .0001),
        ),
      );
    }();
  }

  @override
  void didUpdateWidget(covariant MiuixIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Compose removes the whole clickable modifier when disabled. Clear any
    // pointer state left by an in-flight gesture at the same transition.
    if (!widget._isInteractive && _pointerPressed) {
      _pointerPressed = false;
    }
    if (!widget._isInteractive) {
      _hovered = false;
      _focused = false;
      _indicationRevision++;
      _indicationController
        ..stop(canceled: true)
        ..value = 0;
    } else if (oldWidget.holdDownState != widget.holdDownState) {
      _syncIndication(
        widget.holdDownState
            ? _MiuixIconButtonIndicationChange.holdEnter
            : _MiuixIconButtonIndicationChange.holdExit,
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextReduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (nextReduceMotion == _reduceMotion) return;
    _reduceMotion = nextReduceMotion;
    if (_reduceMotion) {
      // Accessibility can change while a spring is still moving. Publish the
      // current logical state immediately and invalidate an awaited positive
      // transition so it cannot resume a delayed exit animation afterward.
      _indicationRevision++;
      _positiveIndicationAnimation = null;
      _indicationController
        ..stop(canceled: true)
        ..value = _indicationTarget;
    }
  }

  @override
  void dispose() {
    _indicationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final miuixTheme = MiuixTheme.of(context);
    final glassContext = _MiuixIconButtonGlassContext.maybeOf(context);
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    // Public geometry can originate in persistence or a platform channel.
    // Normalize it before constraints and shape construction in every mode.
    final safeMinWidth = widget.minWidth.isFinite
        ? math.max(0, widget.minWidth).toDouble()
        : MiuixIconButtonDefaults.minWidth;
    final safeMinHeight = widget.minHeight.isFinite
        ? math.max(0, widget.minHeight).toDouble()
        : MiuixIconButtonDefaults.minHeight;
    final safeCornerRadius = widget.cornerRadius.isFinite
        ? math.max(0, widget.cornerRadius).toDouble()
        : MiuixIconButtonDefaults.cornerRadius;
    final effectiveMinWidth = _miuixRoundLogicalDimension(
      safeMinWidth,
      pixelRatio,
    );
    final effectiveMinHeight = _miuixRoundLogicalDimension(
      safeMinHeight,
      pixelRatio,
    );
    final borderRadius = BorderRadius.circular(safeCornerRadius);
    final ShapeBorder shape = glassContext != null
        ? const CircleBorder()
        : miuixTheme.enableSquircle
        ? MiuixSquircleBorder(borderRadius: borderRadius)
        : RoundedRectangleBorder(borderRadius: borderRadius);
    final background =
        widget.backgroundColor ??
        (widget.selected
            ? glassContext?.selectedBackgroundColor ?? scheme.primaryContainer
            : Colors.transparent);
    final content = widget.child ?? widget.icon ?? const SizedBox.shrink();
    final targetGeometry = _MiuixIconButtonTargetOffset.maybeOf(context);
    // IconButton.kt does not publish a LocalContentColor. Its arbitrary slot
    // normally inherits the caller's icon/text locals exactly as supplied.
    // A selected compact glass action uses the surrounding app-bar role so
    // its foreground and translucent selection wash remain coordinated.
    final effectiveContentColor =
        widget.contentColor ??
        (widget.selected ? glassContext?.selectedContentColor : null);
    final Widget resolvedContent;
    if (effectiveContentColor case final foreground?) {
      resolvedContent = IconTheme.merge(
        data: IconThemeData(color: foreground),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: foreground),
          child: content,
        ),
      );
    } else {
      resolvedContent = content;
    }

    // Decoration and indication share the same smooth outline. Keeping the
    // constraints inside that clip reproduces defaultMinSize -> clip ->
    // background -> clickable from the upstream modifier chain.
    final buttonContents = DecoratedBox(
      key: const ValueKey('miuix-icon-button-surface'),
      // Retain the public shape metadata used by inspection/debug tooling.
      // The outer SDF owns the final fill and clip on supported platforms.
      decoration: ShapeDecoration(color: background, shape: shape),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: effectiveMinWidth,
              minHeight: effectiveMinHeight,
            ),
            // Width and height factors keep the Box equivalent shrink-wrap
            // behavior under a Row or Column's loose cross-axis constraint.
            child: Align(
              widthFactor: 1,
              heightFactor: 1,
              child: MiuixIconInteraction(
                enabled: widget._isInteractive,
                pressed: _pointerPressed,
                selected: widget.selected,
                activation: _iconActivation,
                child: resolvedContent,
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: FadeTransition(
                key: const ValueKey('miuix-press-indication'),
                opacity: _indicationController,
                child: ColoredBox(
                  color: MiuixSemanticColors.of(context)['onBackground'],
                ),
              ),
            ),
          ),
        ],
      ),
    );
    // Compact app-bar glass already owns the visible circular material. Clip
    // selection and indication to that same circle instead of drawing a
    // smaller squircle inside the glass surface.
    final Widget visualSurface = glassContext == null
        ? MiuixSquircleSurface(
            color: background,
            borderRadius: borderRadius,
            enabled: miuixTheme.enableSquircle,
            child: buttonContents,
          )
        : ClipOval(child: buttonContents);

    final interactionSurface = MouseRegion(
      onEnter: widget._isInteractive ? (_) => _setHovered(true) : null,
      onExit: widget._isInteractive ? (_) => _setHovered(false) : null,
      child: FocusableActionDetector(
        enabled: widget._isInteractive,
        // The custom render object already exports Compose's expanded 48dp
        // semantic target, so this focus layer must remain paint-only.
        includeFocusSemantics: false,
        onFocusChange: _setFocused,
        shortcuts: widget._isInteractive
            ? const <ShortcutActivator, Intent>{
                SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
                SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
              }
            : const <ShortcutActivator, Intent>{},
        actions: widget._isInteractive
            ? <Type, Action<Intent>>{
                ActivateIntent: CallbackAction<ActivateIntent>(
                  onInvoke: (_) {
                    _activate();
                    return null;
                  },
                ),
              }
            : const <Type, Action<Intent>>{},
        child: visualSurface,
      ),
    );
    Widget button = _MiuixIconButtonTouchTarget(
      enabled: widget._isInteractive,
      selected: widget.selected,
      // The source has no selected state. Expose package selection metadata
      // only while the compatibility presentation is actually active.
      exposeSelectedState: widget.selected,
      semanticLabel: widget.tooltip,
      textDirection: Directionality.of(context),
      targetOffset: targetGeometry.offset,
      targetInsets: targetGeometry.insets,
      minimumSize: _miuixRoundLogicalDimension(
        MiuixIconButtonDefaults.minimumInteractiveSize,
        pixelRatio,
      ),
      onTap: widget._isInteractive ? _activate : null,
      onTapDown: () => _setPointerPressed(true),
      onTapUp: () => _setPointerPressed(false),
      onTapCancel: () => _setPointerPressed(false),
      child: interactionSurface,
    );
    if (widget.tooltip != null) {
      button = MiuixTooltip(message: widget.tooltip!, child: button);
    }
    return button;
  }
}

/// Supplies the material contract for an icon button embedded in circular
/// app-bar glass without changing the public icon-button API.
class _MiuixIconButtonGlassContext extends InheritedWidget {
  const _MiuixIconButtonGlassContext({
    required this.selectedBackgroundColor,
    required this.selectedContentColor,
    required super.child,
  });

  final Color selectedBackgroundColor;
  final Color selectedContentColor;

  static _MiuixIconButtonGlassContext? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_MiuixIconButtonGlassContext>();

  @override
  bool updateShouldNotify(_MiuixIconButtonGlassContext oldWidget) =>
      selectedBackgroundColor != oldWidget.selectedBackgroundColor ||
      selectedContentColor != oldWidget.selectedContentColor;
}

/// Widget bridge for the non-layout-affecting Android interaction target.
///
/// A normal `SizedBox.square(48)` would move neighboring icons eight logical
/// pixels farther apart. Compose instead expands hit testing and semantics
/// around the 40dp placeable. This render object mirrors that distinction.
class _MiuixIconButtonTouchTarget extends SingleChildRenderObjectWidget {
  const _MiuixIconButtonTouchTarget({
    super.key,
    required this.enabled,
    required this.selected,
    this.semanticButton = true,
    this.semanticImage = false,
    this.exposeSelectedState = false,
    required this.semanticLabel,
    required this.textDirection,
    required this.targetOffset,
    required this.targetInsets,
    required this.minimumSize,
    required this.onTap,
    required this.onTapDown,
    required this.onTapUp,
    required this.onTapCancel,
    required super.child,
  });

  final bool enabled;
  final bool selected;
  final bool semanticButton;
  final bool semanticImage;
  final bool exposeSelectedState;
  final String? semanticLabel;
  final TextDirection textDirection;
  final Offset targetOffset;
  final EdgeInsets targetInsets;
  final double minimumSize;
  final VoidCallback? onTap;
  final VoidCallback onTapDown;
  final VoidCallback onTapUp;
  final VoidCallback onTapCancel;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderMiuixIconButtonTouchTarget(
      enabled: enabled,
      selected: selected,
      semanticButton: semanticButton,
      semanticImage: semanticImage,
      exposeSelectedState: exposeSelectedState,
      semanticLabel: semanticLabel,
      textDirection: textDirection,
      targetOffset: targetOffset,
      targetInsets: targetInsets,
      minimumSize: minimumSize,
      onTap: onTap,
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      onTapCancel: onTapCancel,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderMiuixIconButtonTouchTarget renderObject,
  ) {
    // Install callbacks before enabling the render object. Updating enabled
    // first can synchronously rebuild semantics while the previous disabled
    // frame still owns a null tap callback.
    renderObject
      ..onTap = onTap
      ..onTapDown = onTapDown
      ..onTapUp = onTapUp
      ..onTapCancel = onTapCancel
      ..enabled = enabled
      ..selected = selected
      ..semanticButton = semanticButton
      ..semanticImage = semanticImage
      ..exposeSelectedState = exposeSelectedState
      ..semanticLabel = semanticLabel
      ..textDirection = textDirection
      ..targetOffset = targetOffset
      ..targetInsets = targetInsets
      ..minimumSize = minimumSize;
  }
}

class _RenderMiuixIconButtonTouchTarget extends RenderProxyBox {
  _RenderMiuixIconButtonTouchTarget({
    required bool enabled,
    required bool selected,
    required bool semanticButton,
    required bool semanticImage,
    required bool exposeSelectedState,
    required String? semanticLabel,
    required TextDirection textDirection,
    required Offset targetOffset,
    required EdgeInsets targetInsets,
    required double minimumSize,
    required VoidCallback? onTap,
    required VoidCallback onTapDown,
    required VoidCallback onTapUp,
    required VoidCallback onTapCancel,
  }) : _enabled = enabled,
       _selected = selected,
       _semanticButton = semanticButton,
       _semanticImage = semanticImage,
       _exposeSelectedState = exposeSelectedState,
       _semanticLabel = semanticLabel,
       _textDirection = textDirection,
       _targetOffset = targetOffset,
       _targetInsets = targetInsets,
       _minimumSize = minimumSize,
       _onTap = onTap,
       _onTapDown = onTapDown,
       _onTapUp = onTapUp,
       _onTapCancel = onTapCancel {
    _tapRecognizer = TapGestureRecognizer(debugOwner: this);
    _syncRecognizer();
  }

  late final TapGestureRecognizer _tapRecognizer;
  bool _enabled;
  bool _selected;
  bool _semanticButton;
  bool _semanticImage;
  bool _exposeSelectedState;
  String? _semanticLabel;
  TextDirection _textDirection;
  Offset _targetOffset;
  EdgeInsets _targetInsets;
  double _minimumSize;
  VoidCallback? _onTap;
  VoidCallback _onTapDown;
  VoidCallback _onTapUp;
  VoidCallback _onTapCancel;

  bool get enabled => _enabled;
  set enabled(bool value) {
    if (_enabled == value) return;
    _enabled = value;
    _syncRecognizer();
    markNeedsSemanticsUpdate();
  }

  bool get selected => _selected;
  set selected(bool value) {
    if (_selected == value) return;
    _selected = value;
    markNeedsSemanticsUpdate();
  }

  bool get semanticButton => _semanticButton;
  set semanticButton(bool value) {
    if (_semanticButton == value) return;
    _semanticButton = value;
    markNeedsSemanticsUpdate();
  }

  bool get semanticImage => _semanticImage;
  set semanticImage(bool value) {
    if (_semanticImage == value) return;
    _semanticImage = value;
    markNeedsSemanticsUpdate();
  }

  bool get exposeSelectedState => _exposeSelectedState;
  set exposeSelectedState(bool value) {
    if (_exposeSelectedState == value) return;
    _exposeSelectedState = value;
    markNeedsSemanticsUpdate();
  }

  String? get semanticLabel => _semanticLabel;
  set semanticLabel(String? value) {
    if (_semanticLabel == value) return;
    _semanticLabel = value;
    markNeedsSemanticsUpdate();
  }

  TextDirection get textDirection => _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsSemanticsUpdate();
  }

  Offset get targetOffset => _targetOffset;
  set targetOffset(Offset value) {
    if (_targetOffset == value) return;
    _targetOffset = value;
    markNeedsSemanticsUpdate();
  }

  EdgeInsets get targetInsets => _targetInsets;
  set targetInsets(EdgeInsets value) {
    if (_targetInsets == value) return;
    _targetInsets = value;
    markNeedsSemanticsUpdate();
  }

  double get minimumSize => _minimumSize;
  set minimumSize(double value) {
    if (_minimumSize == value) return;
    _minimumSize = value;
    markNeedsSemanticsUpdate();
  }

  VoidCallback? get onTap => _onTap;
  set onTap(VoidCallback? value) {
    if (_onTap == value) return;
    _onTap = value;
    _syncRecognizer();
    markNeedsSemanticsUpdate();
  }

  VoidCallback get onTapDown => _onTapDown;
  set onTapDown(VoidCallback value) {
    if (_onTapDown == value) return;
    _onTapDown = value;
    _syncRecognizer();
  }

  VoidCallback get onTapUp => _onTapUp;
  set onTapUp(VoidCallback value) {
    if (_onTapUp == value) return;
    _onTapUp = value;
    _syncRecognizer();
  }

  VoidCallback get onTapCancel => _onTapCancel;
  set onTapCancel(VoidCallback value) {
    if (_onTapCancel == value) return;
    _onTapCancel = value;
    _syncRecognizer();
  }

  Rect get _interactiveBounds {
    final targetWidth = math.max(size.width, minimumSize);
    final targetHeight = math.max(size.height, minimumSize);
    final expanded = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: targetWidth,
      height: targetHeight,
    ).shift(targetOffset);
    return Rect.fromLTRB(
      expanded.left + targetInsets.left,
      expanded.top + targetInsets.top,
      expanded.right - targetInsets.right,
      expanded.bottom - targetInsets.bottom,
    );
  }

  void _syncRecognizer() {
    _tapRecognizer
      ..onTap = enabled ? _onTap : null
      ..onTapDown = enabled ? (_) => _onTapDown() : null
      ..onTapUp = enabled ? (_) => _onTapUp() : null
      ..onTapCancel = enabled ? _onTapCancel : null;
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!enabled || size.isEmpty || !_interactiveBounds.contains(position)) {
      return false;
    }
    // Inside the painted 40dp placeable, keep descendant mouse annotations
    // discoverable. The four-dp Android expansion remains owned by this render
    // object alone and therefore cannot change visual layout or hover bounds.
    if (size.contains(position)) {
      hitTestChildren(result, position: position);
    }
    // The render object owns the recognizer, so a pointer in the four-dp
    // expansion does not need to be artificially clamped into its child.
    result.add(BoxHitTestEntry(this, position));
    return true;
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent && enabled) {
      _tapRecognizer.addPointer(event);
    }
  }

  @override
  Rect get semanticBounds => _interactiveBounds;

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config.isSemanticBoundary = true;
    if (!enabled) {
      // Upstream removes `Modifier.clickable` completely rather than exposing
      // a disabled button role. Child content semantics remain discoverable.
      return;
    }
    // Compose clickable merges the Icon content description into the button
    // node. Without this flag Flutter exported an unlabeled button followed by
    // a separate image, making TalkBack encounter two controls for one action.
    config.isMergingSemanticsOfDescendants = true;
    config.isEnabled = true;
    // Render-object properties are updated independently during a widget
    // rebuild. In the disabled-to-enabled transition there can be a moment
    // where `enabled` is true before a nullable callback has been installed.
    // Semantics must tolerate that legal intermediate state instead of using
    // a null assertion and aborting the frame.
    //
    // The property update path writes callbacks first as the primary defense;
    // this guard remains necessary for direct render-object clients and future
    // refactors that may update the fields in a different order.
    final callback = _onTap;
    if (callback != null) config.onTap = callback;
    if (semanticButton) config.isButton = true;
    if (semanticImage) config.isImage = true;
    if (exposeSelectedState) config.isSelected = selected;
    if (_semanticLabel case final label? when label.isNotEmpty) {
      config
        ..label = label
        ..textDirection = textDirection;
    }
  }

  @override
  void dispose() {
    _tapRecognizer.dispose();
    super.dispose();
  }
}

/// Supplies a paint-independent interaction correction to top-bar buttons.
///
/// Compose rounds Android touch-bound coordinates toward the following
/// physical pixel at fractional densities. Flutter otherwise places the
/// semantic rectangle one pixel earlier on the vertical axis. The correction
/// is inherited so it never changes the button's visual layout or public API.
class _MiuixIconButtonTargetOffset extends InheritedWidget {
  const _MiuixIconButtonTargetOffset({
    required this.offset,
    this.insets = EdgeInsets.zero,
    required super.child,
  });

  final Offset offset;
  final EdgeInsets insets;

  static _MiuixIconButtonTargetOffset maybeOf(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<
              _MiuixIconButtonTargetOffset
            >() ??
        const _MiuixIconButtonTargetOffset(
          offset: Offset.zero,
          child: SizedBox.shrink(),
        );
  }

  @override
  bool updateShouldNotify(_MiuixIconButtonTargetOffset oldWidget) {
    return offset != oldWidget.offset || insets != oldWidget.insets;
  }
}
