part of '../miuix_widgets.dart';

/// Color roles for a segmented control.
@immutable
class MiuixSegmentedControlColors {
  /// Creates a complete segmented-control palette.
  const MiuixSegmentedControlColors({
    required this.background,
    required this.selectedBackground,
    required this.foreground,
    required this.selectedForeground,
    required this.disabledForeground,
    required this.border,
  });

  final Color background;
  final Color selectedBackground;
  final Color foreground;
  final Color selectedForeground;
  final Color disabledForeground;
  final Color border;
}

/// Defaults for keyboard-aware segmented controls.
abstract final class MiuixSegmentedControlDefaults {
  /// Legacy MIUIX outer height retained by the explicit source constructor.
  static const double legacyHeight = 42;

  /// Backward-compatible name for the legacy source metric.
  static const double height = legacyHeight;

  /// Legacy MIUIX corner retained by the explicit source constructor.
  static const double legacyCornerRadius = 16;

  /// Backward-compatible name for the legacy source metric.
  static const double cornerRadius = legacyCornerRadius;

  static MiuixSegmentedControlColors colors(BuildContext context) {
    final semantic = MiuixSemanticColors.of(context);
    // 同一个轻选中层供分段和芯片使用，普通轨道继续保持中性。
    final layers = MiuixAccentLayers.maybeOf(context);
    return MiuixSegmentedControlColors(
      background: semantic['surfaceContainerHigh'],
      selectedBackground: layers?.selectionFill ?? semantic['surface'],
      foreground: semantic['onSurfaceSecondary'],
      selectedForeground: layers?.selectionForeground ?? semantic['onSurface'],
      disabledForeground:
          layers?.disabledForeground ?? semantic['disabledOnSurface'],
      border: layers?.outline ?? semantic['dividerLine'],
    );
  }
}

/// Segmented control for small option sets.
class MiuixSegmentedControl<T> extends StatefulWidget {
  /// Creates a segmented control.
  const MiuixSegmentedControl({
    super.key,
    required this.values,
    required this.selected,
    required this.labelBuilder,
    required this.onSelectionChanged,
    this.enabled = true,
    this.isValueEnabled,
    this.multipleSelection = true,
    this.allowEmptySelection = true,
    this.expanded = false,
    this.glass = true,
    this.height,
    this.cornerRadius,
    this.glassBlur,
    this.glassOpacity,
    this.semanticLabel,
    this.colors,
  });

  /// Creates the previous opaque MIUIX presentation explicitly.
  const MiuixSegmentedControl.source({
    super.key,
    required this.values,
    required this.selected,
    required this.labelBuilder,
    required this.onSelectionChanged,
    this.enabled = true,
    this.isValueEnabled,
    this.multipleSelection = true,
    this.allowEmptySelection = true,
    this.expanded = false,
    this.glass = false,
    this.height = MiuixSegmentedControlDefaults.legacyHeight,
    this.cornerRadius = MiuixSegmentedControlDefaults.legacyCornerRadius,
    this.glassBlur,
    this.glassOpacity,
    this.semanticLabel,
    this.colors,
  });

  /// Segment values.
  final List<T> values;

  /// Currently selected values.
  final Set<T> selected;

  /// Label builder.
  final String Function(T value) labelBuilder;

  /// Selection callback.
  final ValueChanged<Set<T>> onSelectionChanged;

  /// Global and per-value interaction policy.
  final bool enabled;
  final bool Function(T value)? isValueEnabled;

  /// Whether several segments or no segment may be selected.
  final bool multipleSelection;
  final bool allowEmptySelection;

  /// Whether available width is divided equally between every segment.
  final bool expanded;

  /// Whether to sample the real content behind the local option capsule.
  final bool glass;

  /// Optional outer height overriding the HyperOS 4 theme token.
  final double? height;

  /// Optional outer corner overriding the HyperOS 4 theme token.
  final double? cornerRadius;

  /// Optional role-specific glass sigma and tint opacity.
  final double? glassBlur;
  final double? glassOpacity;

  /// Optional semantic group label.
  final String? semanticLabel;
  final MiuixSegmentedControlColors? colors;

  @override
  State<MiuixSegmentedControl<T>> createState() =>
      _MiuixSegmentedControlState<T>();
}

class _MiuixSegmentedControlState<T> extends State<MiuixSegmentedControl<T>> {
  final FocusNode _focusNode = FocusNode(debugLabel: 'MiuixSegmentedControl');

  bool _enabledAt(int index) {
    return widget.enabled &&
        (widget.isValueEnabled?.call(widget.values[index]) ?? true);
  }

  void _select(int index) {
    if (!_enabledAt(index)) return;
    final value = widget.values[index];
    final next = Set<T>.of(widget.selected);
    if (widget.multipleSelection) {
      if (!next.add(value) && (widget.allowEmptySelection || next.length > 1)) {
        next.remove(value);
      }
    } else if (next.contains(value) && widget.allowEmptySelection) {
      next.clear();
    } else {
      next
        ..clear()
        ..add(value);
    }
    if (next.length == widget.selected.length &&
        next.containsAll(widget.selected)) {
      return;
    }
    widget.onSelectionChanged(next);
    MiuixHaptics.perform(MiuixHapticType.segmentTick);
  }

  void _move(int delta) {
    if (widget.values.isEmpty) return;
    var index = widget.values.indexWhere(widget.selected.contains);
    if (index < 0) index = delta > 0 ? -1 : widget.values.length;
    for (var attempt = 0; attempt < widget.values.length; attempt++) {
      index = (index + delta).clamp(0, widget.values.length - 1);
      if (_enabledAt(index)) {
        _select(index);
        return;
      }
      if (index == 0 || index == widget.values.length - 1) return;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.values.isEmpty) {
      return const SizedBox.shrink();
    }
    final palette =
        widget.colors ?? MiuixSegmentedControlDefaults.colors(context);
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    // Public geometry may originate in persisted settings or animation output.
    // Keep invalid values out of layout and paint while preserving zero as an
    // intentional compact override.
    // Geometry normalization contract:
    // - A finite positive height is preserved exactly.
    // - A finite zero height remains an intentional caller override.
    // - A finite negative height is projected to zero.
    // - A non-finite height falls back to the active theme token.
    // - The theme fallback is itself checked before use.
    // - A finite positive corner radius is preserved exactly.
    // - A finite zero corner radius retains an intentional square shape.
    // - A finite negative corner radius is projected to zero.
    // - A non-finite radius falls back to the active theme token.
    // - Layout height is resolved before the inner 3dp insets are removed.
    // - Paint radius is resolved before the inner 3dp radius is removed.
    // - No invalid public double reaches constraints or BorderRadius.
    final themeHeight = hyperOs4.segmentedControlHeight.isFinite
        ? math.max(0.0, hyperOs4.segmentedControlHeight)
        : 0.0;
    final requestedHeight = widget.height ?? themeHeight;
    final outerHeight = requestedHeight.isFinite
        ? math.max(0.0, requestedHeight)
        : themeHeight;
    final themeCorner = hyperOs4.segmentedControlCornerRadius.isFinite
        ? math.max(0.0, hyperOs4.segmentedControlCornerRadius)
        : 0.0;
    final requestedCorner = widget.cornerRadius ?? themeCorner;
    final outerCorner = requestedCorner.isFinite
        ? math.max(0.0, requestedCorner)
        : themeCorner;
    final segmentCorner = math.max(0.0, outerCorner - 3);
    final motion = reduceMotion
        ? Duration.zero
        : hyperOs4.segmentedControlMotion;
    // 默认独立项可能各占112宽；窄卡片中应自动等分，不能溢出到控件外。
    return LayoutBuilder(
      builder: (context, constraints) {
        final bounded = constraints.maxWidth.isFinite;
        final available = bounded
            ? math.max(0.0, constraints.maxWidth - 8)
            : double.infinity;
        // source/显式高度是紧凑单行契约，不能自动改纵排后撑破固定父高。
        // 只有默认自适应模式可通过纵向排列换取完整标签宽度。
        final vertical =
            widget.height == null &&
            bounded &&
            available / widget.values.length < 58;
        final expanded =
            bounded &&
            (widget.expanded ||
                available <
                    widget.values.length * 112 +
                        (widget.values.length - 1) * 3);
        final width = vertical
            ? available
            : expanded
            ? available / widget.values.length
            : 112.0;
        var segmentHeight = math.max(0.0, outerHeight - 6);
        if (widget.height == null) {
          // 默认高度按全文测量；显式 source/零高度覆盖仍保留原兼容契约。
          for (final value in widget.values) {
            final painter = TextPainter(
              text: TextSpan(
                text: widget.labelBuilder(value),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              textScaler: MediaQuery.textScalerOf(context),
              textDirection: Directionality.of(context),
            )..layout(maxWidth: math.max(1, width - 26));
            segmentHeight = math.max(
              segmentHeight,
              painter.height.ceilToDouble() + 12,
            );
            painter.dispose();
          }
        }
        // 极窄宿主采用纵向排列，箭头键、焦点和选中状态仍由原逻辑处理。
        final row = Flex(
          direction: vertical ? Axis.vertical : Axis.horizontal,
          crossAxisAlignment: vertical
              ? CrossAxisAlignment.stretch
              : CrossAxisAlignment.center,
          mainAxisSize: expanded && !vertical
              ? MainAxisSize.max
              : MainAxisSize.min,
          children: <Widget>[
            for (var index = 0; index < widget.values.length; index++)
              if (expanded && !vertical)
                Expanded(
                  child: _MiuixSegmentButton<T>(
                    label: widget.labelBuilder(widget.values[index]),
                    selected: widget.selected.contains(widget.values[index]),
                    enabled: _enabledAt(index),
                    colors: palette,
                    height: segmentHeight,
                    cornerRadius: segmentCorner,
                    motion: motion,
                    paintSelection: !expanded || widget.multipleSelection,
                    onTap: () {
                      _focusNode.requestFocus();
                      _select(index);
                    },
                  ),
                )
              else
                Padding(
                  padding: EdgeInsetsDirectional.only(
                    end: vertical || index == widget.values.length - 1 ? 0 : 3,
                    bottom: vertical && index != widget.values.length - 1
                        ? 3
                        : 0,
                  ),
                  child: _MiuixSegmentButton<T>(
                    label: widget.labelBuilder(widget.values[index]),
                    selected: widget.selected.contains(widget.values[index]),
                    enabled: _enabledAt(index),
                    colors: palette,
                    height: segmentHeight,
                    cornerRadius: segmentCorner,
                    motion: motion,
                    paintSelection: true,
                    onTap: () {
                      _focusNode.requestFocus();
                      _select(index);
                    },
                  ),
                ),
          ],
        );
        final selectedIndex = widget.values.indexWhere(
          widget.selected.contains,
        );
        final Widget segments =
            expanded &&
                !vertical &&
                !widget.multipleSelection &&
                selectedIndex >= 0
            ? LayoutBuilder(
                builder: (context, constraints) {
                  final segmentWidth =
                      constraints.maxWidth / widget.values.length;
                  return SizedBox(
                    height: segmentHeight,
                    child: Stack(
                      children: <Widget>[
                        AnimatedPositionedDirectional(
                          key: const ValueKey('miuix-segmented-selection'),
                          duration: motion,
                          curve: Curves.easeOutCubic,
                          start: selectedIndex * segmentWidth,
                          top: 0,
                          bottom: 0,
                          width: segmentWidth,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: palette.selectedBackground,
                              border: Border.all(
                                color: palette.border,
                                width: .5,
                              ),
                              borderRadius: BorderRadius.circular(
                                segmentCorner,
                              ),
                            ),
                          ),
                        ),
                        row,
                      ],
                    ),
                  );
                },
              )
            : row;
        final surface = MiuixSurface(
          radius: outerCorner,
          color: widget.glass ? Colors.transparent : palette.background,
          border: BorderSide(color: palette.border, width: .5),
          glass: widget.glass,
          glassBlur: widget.glassBlur ?? hyperOs4.segmentedControlBlur,
          glassOpacity:
              widget.glassOpacity ?? hyperOs4.segmentedControlTintOpacity,
          child: Padding(padding: const EdgeInsets.all(3), child: segments),
        );
        return Semantics(
          container: true,
          enabled: widget.enabled,
          label: widget.semanticLabel,
          child: Shortcuts(
            shortcuts: const <ShortcutActivator, Intent>{
              SingleActivator(LogicalKeyboardKey.arrowLeft): _SegmentMoveIntent(
                -1,
              ),
              SingleActivator(LogicalKeyboardKey.arrowUp): _SegmentMoveIntent(
                -1,
              ),
              SingleActivator(LogicalKeyboardKey.arrowRight):
                  _SegmentMoveIntent(1),
              SingleActivator(LogicalKeyboardKey.arrowDown): _SegmentMoveIntent(
                1,
              ),
            },
            child: Actions(
              actions: <Type, Action<Intent>>{
                _SegmentMoveIntent: CallbackAction<_SegmentMoveIntent>(
                  onInvoke: (intent) {
                    _move(intent.delta);
                    return null;
                  },
                ),
              },
              child: Focus(focusNode: _focusNode, child: surface),
            ),
          ),
        );
      },
    );
  }
}

class _MiuixSegmentButton<T> extends StatelessWidget {
  const _MiuixSegmentButton({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.colors,
    required this.height,
    required this.cornerRadius,
    required this.motion,
    required this.paintSelection,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final MiuixSegmentedControlColors colors;
  final double height;
  final double cornerRadius;
  final Duration motion;
  final bool paintSelection;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = !enabled
        ? colors.disabledForeground
        : selected
        ? colors.selectedForeground
        : colors.foreground;
    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      child: MiuixPressable(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        feedbackType: MiuixPressFeedbackType.none,
        showIndication: true,
        child: AnimatedContainer(
          duration: motion,
          curve: Curves.easeOutCubic,
          height: height,
          constraints: const BoxConstraints(minWidth: 58, maxWidth: 112),
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            color: selected && paintSelection
                ? colors.selectedBackground
                : Colors.transparent,
            border: Border.all(
              color: selected && paintSelection
                  ? colors.border
                  : Colors.transparent,
              width: .5,
            ),
            borderRadius: BorderRadius.circular(cornerRadius),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            // 默认控件已按真实全文预留高度，不再用省略号隐藏选项。
            textAlign: TextAlign.center,
            softWrap: true,
            style: theme.textTheme.labelLarge?.copyWith(
              color: foreground,
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _SegmentMoveIntent extends Intent {
  const _SegmentMoveIntent(this.delta);
  final int delta;
}

/// Arrangement direction used by [MiuixFloatingToolbar].
enum MiuixFloatingToolbarOrientation {
  /// Place actions from start to end.
  horizontal,

  /// Place actions from top to bottom.
  vertical,
}

/// Public source defaults for [MiuixFloatingToolbar].
abstract final class MiuixFloatingToolbarDefaults {
  /// Legacy MIUIX continuous-corner radius.
  static const double legacyCornerRadius = 50;

  /// Backward-compatible name for the legacy source metric.
  static const double cornerRadius = legacyCornerRadius;

  /// Default logical outside padding.
  static const EdgeInsets outSidePadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 8,
  );

  /// Resolves `FloatingToolbarDefaults.defaultColor()`.
  static Color defaultColor(BuildContext context) {
    return MiuixSemanticColors.of(context)['surfaceContainer'];
  }
}

/// Floating toolbar matching MIUIX surface and shadow defaults.
class MiuixFloatingToolbar extends StatelessWidget {
  /// Creates a floating toolbar.
  const MiuixFloatingToolbar({
    super.key,
    this.child,
    this.children = const <Widget>[],
    this.orientation = MiuixFloatingToolbarOrientation.horizontal,
    this.color,
    this.cornerRadius = -1,
    this.outSidePadding = MiuixFloatingToolbarDefaults.outSidePadding,
    this.outsidePadding,
    this.contentPadding = EdgeInsets.zero,
    this.spacing = 0,
    this.shadowElevation = 4,
    this.showDivider = false,
    this.glass = true,
    this.glassBlur,
    this.glassOpacity,
  });

  /// Creates the previous opaque MIUIX source presentation explicitly.
  const MiuixFloatingToolbar.source({
    super.key,
    this.child,
    this.children = const <Widget>[],
    this.orientation = MiuixFloatingToolbarOrientation.horizontal,
    this.color,
    this.cornerRadius = MiuixFloatingToolbarDefaults.legacyCornerRadius,
    this.outSidePadding = MiuixFloatingToolbarDefaults.outSidePadding,
    this.outsidePadding,
    this.contentPadding = EdgeInsets.zero,
    this.spacing = 0,
    this.shadowElevation = 4,
    this.showDivider = false,
    this.glass = false,
    this.glassBlur,
    this.glassOpacity,
  });

  /// Arbitrary source-style toolbar content.
  ///
  /// Upstream does not arrange actions itself; its sample supplies a Row or
  /// Column as this slot. [children] remains the Flutter convenience adapter.
  final Widget? child;

  /// Convenience actions arranged by [orientation].
  final List<Widget> children;

  /// Horizontal or vertical action arrangement.
  final MiuixFloatingToolbarOrientation orientation;

  /// Surface color, defaulting to MIUIX `surfaceContainer`.
  final Color? color;

  /// Surface corner radius; -1 resolves through the HyperOS 4 theme token.
  final double cornerRadius;

  /// Source-named padding outside the painted toolbar.
  final EdgeInsetsGeometry outSidePadding;

  /// Legacy spelling retained for source compatibility with earlier releases.
  ///
  /// When supplied this takes precedence over [outSidePadding].
  final EdgeInsetsGeometry? outsidePadding;

  /// Padding around the arranged action content.
  final EdgeInsetsGeometry contentPadding;

  /// Gap between adjacent actions.
  final double spacing;

  /// Source-named shadow gate.
  ///
  /// Every non-positive value disables the shadow. Every positive value
  /// enables the source's
  /// fixed 10dp, 10%-black projection; the numeric magnitude is not scaled.
  final double shadowElevation;

  /// Whether to draw the source 0.75dp outline.
  final bool showDivider;

  /// Whether the local toolbar samples the real content behind its capsule.
  final bool glass;

  /// Optional role-specific glass sigma and tint opacity.
  final double? glassBlur;
  final double? glassOpacity;

  @override
  Widget build(BuildContext context) {
    final semantic = MiuixSemanticColors.of(context);
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final effectiveCornerRadius = !cornerRadius.isFinite || cornerRadius < 0
        ? hyperOs4.floatingToolbarCornerRadius
        : cornerRadius;
    // Spacing participates directly in Row/Column geometry. Clamp it here so
    // malformed persisted settings cannot create negative box constraints.
    final effectiveSpacing = spacing.isFinite ? math.max(0.0, spacing) : 0.0;
    final arranged =
        child ??
        (orientation == MiuixFloatingToolbarOrientation.horizontal
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: _spacedChildren(Axis.horizontal, effectiveSpacing),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: _spacedChildren(Axis.vertical, effectiveSpacing),
              ));
    final content = Padding(padding: contentPadding, child: arranged);
    final resolvedOutsidePadding = _miuixRoundedInsets(
      context,
      outsidePadding ?? outSidePadding,
    );
    final resolvedDividerPadding = _miuixRoundedInsets(
      context,
      const EdgeInsets.all(.75),
    );
    final corners = BorderRadius.circular(effectiveCornerRadius);
    // FloatingToolbar.kt deliberately gives dropShadow a
    // RoundedCornerShape, even when squircleBackground uses the optional G2
    // fill. Keeping those two shapes separate avoids inventing a squircle
    // shadow that the source component does not paint.
    final ShapeBorder shadowShape = RoundedRectangleBorder(
      borderRadius: corners,
    );
    final background =
        color ?? MiuixFloatingToolbarDefaults.defaultColor(context);
    final pointerContent = GestureDetector(
      behavior: HitTestBehavior.opaque,
      excludeFromSemantics: true,
      onTap: () {},
      child: content,
    );

    Widget surface;
    if (glass) {
      surface = MiuixGlass(
        key: const ValueKey('floating-toolbar-glass'),
        blur: glassBlur ?? hyperOs4.floatingToolbarBlur,
        opacity: glassOpacity ?? hyperOs4.floatingToolbarTintOpacity,
        color: background,
        radius: effectiveCornerRadius,
        padding: EdgeInsets.zero,
        // Compose's texture blur has tint and noise but no diagonal specular
        // layer; the latter belongs only to explicit liquid-glass surfaces.
        showSpecular: false,
        child: pointerContent,
      );
    } else {
      // squircleBackground is fill-only: descendants remain unclipped while
      // the upstream baked SDF supplies the exact static-corner silhouette.
      surface = MiuixSquircleBackground(
        key: const ValueKey('miuix-floating-toolbar-fill'),
        color: background,
        borderRadius: corners,
        enabled: MiuixTheme.of(context).enableSquircle,
        child: pointerContent,
      );
    }

    // Despite its source name, shadowElevation is only an enable/disable gate
    // in FloatingToolbar.kt. Every positive value paints this fixed dropShadow:
    // a 10dp blur radius, 10% black, and the Shadow default of zero offset.
    if (shadowElevation.isFinite && shadowElevation > 0) {
      surface = DecoratedBox(
        key: const ValueKey('miuix-floating-toolbar-shadow'),
        decoration: ShapeDecoration(
          color: Colors.transparent,
          shape: shadowShape,
          shadows: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: .10),
              blurRadius: 10,
            ),
          ],
        ),
        child: surface,
      );
    }

    // Source divider order is background(dividerLine) -> padding(0.75dp) ->
    // graphicsLayer/clip -> toolbar background. It therefore adds measurable
    // size around the inner surface rather than painting an inset BoxBorder.
    if (showDivider) {
      surface = MiuixSquircleBackground(
        key: const ValueKey('miuix-floating-toolbar-divider'),
        color: semantic['dividerLine'],
        borderRadius: corners,
        enabled: MiuixTheme.of(context).enableSquircle,
        child: Padding(padding: resolvedDividerPadding, child: surface),
      );
    }

    return Padding(
      padding: resolvedOutsidePadding,
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        child: surface,
      ),
    );
  }

  List<Widget> _spacedChildren(Axis axis, double effectiveSpacing) {
    return [
      for (var index = 0; index < children.length; index++) ...[
        if (index > 0)
          SizedBox(
            width: axis == Axis.horizontal ? effectiveSpacing : 0,
            height: axis == Axis.vertical ? effectiveSpacing : 0,
          ),
        children[index],
      ],
    ];
  }
}

/// Result returned when a hosted snackbar finishes.
enum MiuixSnackbarResult {
  /// The snackbar timed out, was swiped, or was explicitly dismissed.
  dismissed,

  /// The snackbar action was selected.
  actionPerformed,
}

/// Duration model matching MIUIX short, long, indefinite, and custom modes.
@immutable
class MiuixSnackbarDuration {
  const MiuixSnackbarDuration._(this.duration);

  /// A four-second snackbar.
  static const short = MiuixSnackbarDuration._(Duration(seconds: 4));

  /// A ten-second snackbar.
  static const long = MiuixSnackbarDuration._(Duration(seconds: 10));

  /// A snackbar that remains until user or application dismissal.
  static const indefinite = MiuixSnackbarDuration._(null);

  /// Creates a positive custom duration.
  factory MiuixSnackbarDuration.custom(Duration duration) {
    if (duration <= Duration.zero) {
      throw ArgumentError.value(
        duration,
        'duration',
        'must be greater than zero',
      );
    }
    return MiuixSnackbarDuration._(duration);
  }

  /// Concrete timeout, or null for [indefinite].
  final Duration? duration;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MiuixSnackbarDuration && other.duration == duration;

  @override
  int get hashCode => duration.hashCode;
}

/// Immutable content and behavior of one snackbar.
@immutable
class MiuixSnackbarVisuals {
  /// Creates snackbar visuals.
  const MiuixSnackbarVisuals({
    required this.message,
    this.actionLabel,
    this.withDismissAction = false,
    this.duration = MiuixSnackbarDuration.short,
  });

  /// Message shown by the snackbar.
  final String message;

  /// Optional action label.
  final String? actionLabel;

  /// Whether a trailing close control is shown.
  final bool withDismissAction;

  /// Visibility duration.
  final MiuixSnackbarDuration duration;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MiuixSnackbarVisuals &&
          other.message == message &&
          other.actionLabel == actionLabel &&
          other.withDismissAction == withDismissAction &&
          other.duration == duration;

  @override
  int get hashCode =>
      Object.hash(message, actionLabel, withDismissAction, duration);
}

/// Immutable four-channel color contract from `SnackbarColors`.
@immutable
class MiuixSnackbarColors {
  /// Creates a snackbar color set.
  const MiuixSnackbarColors({
    required this.containerColor,
    required this.contentColor,
    required this.actionContentColor,
    required this.dismissActionContentColor,
    required this.actionContainerColor,
  });

  /// Snackbar surface color.
  final Color containerColor;

  /// Message foreground color.
  final Color contentColor;

  /// Action-button foreground color.
  final Color actionContentColor;

  /// Dismiss-icon foreground color.
  final Color dismissActionContentColor;

  /// Action-button capsule color.
  final Color actionContainerColor;

  /// Returns a copy with selected channels replaced.
  MiuixSnackbarColors copyWith({
    Color? containerColor,
    Color? contentColor,
    Color? actionContentColor,
    Color? dismissActionContentColor,
    Color? actionContainerColor,
  }) {
    return MiuixSnackbarColors(
      containerColor: containerColor ?? this.containerColor,
      contentColor: contentColor ?? this.contentColor,
      actionContentColor: actionContentColor ?? this.actionContentColor,
      dismissActionContentColor:
          dismissActionContentColor ?? this.dismissActionContentColor,
      actionContainerColor: actionContainerColor ?? this.actionContainerColor,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MiuixSnackbarColors &&
          other.containerColor == containerColor &&
          other.contentColor == contentColor &&
          other.actionContentColor == actionContentColor &&
          other.dismissActionContentColor == dismissActionContentColor &&
          other.actionContainerColor == actionContainerColor;

  @override
  int get hashCode => Object.hash(
    containerColor,
    contentColor,
    actionContentColor,
    dismissActionContentColor,
    actionContainerColor,
  );
}

/// Theme-resolved defaults from the source `SnackbarDefaults` object.
abstract final class MiuixSnackbarDefaults {
  /// Explicit MIUIX 1.0.9 radius for compatibility constructors.
  static const double legacyCornerRadius = 16;

  /// Default source surface radius.
  static const double cornerRadius = 24;

  /// Default source content padding.
  static const EdgeInsets insideMargin = EdgeInsets.all(12);

  /// Default padding outside the painted snackbar.
  static const EdgeInsets outerPadding = EdgeInsets.fromLTRB(12, 8, 12, 0);

  /// Default action-pill radius.
  static const double actionCornerRadius = 50;

  /// Default action-pill content padding.
  static const EdgeInsets actionInsideMargin = EdgeInsets.symmetric(
    horizontal: 12,
  );

  /// Resolves the source color roles with optional independent overrides.
  static MiuixSnackbarColors snackbarColors(
    BuildContext context, {
    Color? containerColor,
    Color? contentColor,
    Color? actionContentColor,
    Color? dismissActionContentColor,
    Color? actionContainerColor,
  }) {
    final semantic = MiuixSemanticColors.of(context);
    return MiuixSnackbarColors(
      containerColor: containerColor ?? semantic['onSecondaryVariant'],
      contentColor: contentColor ?? semantic['secondaryVariant'],
      actionContentColor: actionContentColor ?? semantic['onPrimary'],
      dismissActionContentColor:
          dismissActionContentColor ?? semantic['onSurfaceContainerVariant'],
      actionContainerColor: actionContainerColor ?? semantic['primary'],
    );
  }
}

/// Public handle for a snackbar managed by [MiuixSnackbarHostState].
abstract interface class MiuixSnackbarData {
  /// Visual configuration for this entry.
  MiuixSnackbarVisuals get visuals;

  /// Dismisses this snackbar.
  Future<void> dismiss();

  /// Completes this snackbar with an action result.
  Future<void> performAction();
}

class _MiuixSnackbarEntry {
  _MiuixSnackbarEntry(this.id, this.data);

  final int id;
  final _MiuixSnackbarData data;
  bool visible = true;
}

class _MiuixSnackbarData implements MiuixSnackbarData {
  _MiuixSnackbarData({required this.visuals, required this.onFinish});

  @override
  final MiuixSnackbarVisuals visuals;
  final ValueChanged<MiuixSnackbarResult> onFinish;
  bool _finished = false;

  void _complete(MiuixSnackbarResult result) {
    if (_finished) {
      return;
    }
    _finished = true;
    onFinish(result);
  }

  @override
  Future<void> dismiss() async => _complete(MiuixSnackbarResult.dismissed);

  @override
  Future<void> performAction() async =>
      _complete(MiuixSnackbarResult.actionPerformed);
}

/// Observable snackbar queue rendered by [MiuixSnackbarHost].
class MiuixSnackbarHostState extends ChangeNotifier {
  final List<_MiuixSnackbarEntry> _entries = [];
  var _id = 0;

  List<_MiuixSnackbarEntry> get _currentEntries => List.unmodifiable(_entries);

  /// Shows a snackbar and completes after dismissal or action selection.
  Future<MiuixSnackbarResult> showSnackbar(
    String message, {
    String? actionLabel,
    bool withDismissAction = false,
    MiuixSnackbarDuration duration = MiuixSnackbarDuration.short,
  }) {
    final result = Completer<MiuixSnackbarResult>();
    late final _MiuixSnackbarEntry entry;
    final data = _MiuixSnackbarData(
      visuals: MiuixSnackbarVisuals(
        message: message,
        actionLabel: actionLabel,
        withDismissAction: withDismissAction,
        duration: duration,
      ),
      onFinish: (value) {
        if (!result.isCompleted) {
          result.complete(value);
        }
        if (entry.visible) {
          entry.visible = false;
          notifyListeners();
        }
      },
    );
    entry = _MiuixSnackbarEntry(++_id, data);
    _entries.insert(0, entry);
    notifyListeners();
    return result.future;
  }

  /// Returns the newest visible snackbar.
  Future<MiuixSnackbarData?> newestSnackbarData() async {
    for (final entry in _entries) {
      if (entry.visible) {
        return entry.data;
      }
    }
    return null;
  }

  /// Returns the oldest visible snackbar.
  Future<MiuixSnackbarData?> oldestSnackbarData() async {
    for (final entry in _entries.reversed) {
      if (entry.visible) {
        return entry.data;
      }
    }
    return null;
  }

  void _remove(_MiuixSnackbarEntry entry) {
    if (_entries.remove(entry)) {
      notifyListeners();
    }
  }

  /// Compatibility helper for callers that still prefer the root overlay API.
  MiuixSnackbarController show(BuildContext context, String message) {
    return MiuixSnackbar.show(context, message);
  }

  @override
  void dispose() {
    for (final entry in List<_MiuixSnackbarEntry>.of(_entries)) {
      entry.data._complete(MiuixSnackbarResult.dismissed);
    }
    _entries.clear();
    super.dispose();
  }
}

/// Renders and animates every snackbar in a [MiuixSnackbarHostState] queue.
class MiuixSnackbarHost extends StatefulWidget {
  /// Creates a snackbar host.
  const MiuixSnackbarHost({
    super.key,
    this.state,
    this.child,
    this.canSwipeToDismiss = true,
    this.contentBuilder,
  });

  /// Queue rendered by this host. Null preserves the former child-only adapter.
  final MiuixSnackbarHostState? state;

  /// Optional content placed behind the snackbar stack.
  final Widget? child;

  /// Whether horizontal anchored dragging can dismiss an entry.
  final bool canSwipeToDismiss;

  /// Optional custom snackbar renderer.
  final Widget Function(BuildContext context, MiuixSnackbarData data)?
  contentBuilder;

  @override
  State<MiuixSnackbarHost> createState() => _MiuixSnackbarHostWidgetState();
}

class _MiuixSnackbarHostWidgetState extends State<MiuixSnackbarHost> {
  @override
  void initState() {
    super.initState();
    widget.state?.addListener(_changed);
  }

  @override
  void didUpdateWidget(covariant MiuixSnackbarHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      oldWidget.state?.removeListener(_changed);
      widget.state?.addListener(_changed);
    }
  }

  @override
  void dispose() {
    widget.state?.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    if (state == null) {
      return widget.child ?? const SizedBox.shrink();
    }
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        if (widget.child != null) Positioned.fill(child: widget.child!),
        Padding(
          padding: _miuixRoundedInsets(
            context,
            const EdgeInsets.only(bottom: 12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // SnackbarHostState stores newest first, while a normal Column
              // paints later children above earlier children. Build the
              // visual stack oldest-to-newest so its geometry still grows
              // upward from the bottom and the newest entry paints last.
              // This is the Flutter equivalent of Snackbar.kt's explicit
              // zIndex(currentSnackbars.size - index): during an older
              // entry's unclipped shrink, its full child must pass behind the
              // newer surface instead of flashing across its top edge.
              for (
                var index = state._currentEntries.length - 1;
                index >= 0;
                index--
              )
                _MiuixHostedSnackbarEntry(
                  key: ValueKey(state._currentEntries[index].id),
                  entry: state._currentEntries[index],
                  index: index,
                  state: state,
                  canSwipeToDismiss: widget.canSwipeToDismiss,
                  contentBuilder: widget.contentBuilder,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiuixHostedSnackbarEntry extends StatefulWidget {
  const _MiuixHostedSnackbarEntry({
    super.key,
    required this.entry,
    required this.index,
    required this.state,
    required this.canSwipeToDismiss,
    this.contentBuilder,
  });

  final _MiuixSnackbarEntry entry;
  final int index;
  final MiuixSnackbarHostState state;
  final bool canSwipeToDismiss;
  final Widget Function(BuildContext context, MiuixSnackbarData data)?
  contentBuilder;

  @override
  State<_MiuixHostedSnackbarEntry> createState() =>
      _MiuixHostedSnackbarEntryState();
}

class _MiuixHostedSnackbarEntryState extends State<_MiuixHostedSnackbarEntry>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _dragController;
  Timer? _timer;
  var _hiding = false;
  var _reduceMotion = false;
  var _removalScheduled = false;
  var _dragSettling = false;
  double _dragWidth = 0;
  double _dragTarget = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this);
    _dragController = AnimationController.unbounded(vsync: this, value: 0);
    _controller.animateWith(_miuixSnackbarSpring(0, 1));
    unawaited(_startTimer());
  }

  @override
  void didUpdateWidget(covariant _MiuixHostedSnackbarEntry oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.entry.visible && oldWidget.entry.visible) {
      _hide();
    } else if (!widget.entry.visible &&
        _controller.status != AnimationStatus.reverse) {
      _hide();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextReduceMotion = MediaQuery.disableAnimationsOf(context);
    if (nextReduceMotion == _reduceMotion) {
      return;
    }
    _reduceMotion = nextReduceMotion;
    if (!_reduceMotion) {
      return;
    }

    // A dependency change can happen while either autonomous spring is in
    // flight. Stop both immediately, but defer controller writes until after
    // the current frame so no AnimationController notification dirties an
    // ancestor that Flutter is already building.
    _controller.stop(canceled: true);
    _dragController.stop(canceled: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_reduceMotion) {
        return;
      }
      _controller.value = _hiding ? 0 : 1;
      if (_dragSettling) {
        _dragSettling = false;
        _dragController.value = _dragTarget;
      }
    });
    if (_hiding) {
      _scheduleRemoval();
    }
  }

  Future<void> _startTimer() async {
    final duration = widget.entry.data.visuals.duration.duration;
    if (duration == null) {
      return;
    }
    // Snackbar.kt asks Android's AccessibilityManager to account for text,
    // icons, controls, and the user's preferred interaction timeout before it
    // begins delay(). The package bridge performs the same native calculation.
    final recommended = await MiuixAccessibility.recommendedSnackbarTimeout(
      duration,
      hasAction: widget.entry.data.visuals.actionLabel != null,
    );
    if (!mounted || _hiding || !widget.entry.visible) {
      return;
    }
    _timer = Timer(recommended, widget.entry.data.dismiss);
  }

  Future<void> _hide() async {
    if (_hiding) {
      return;
    }
    _hiding = true;
    _timer?.cancel();
    if (!mounted) {
      return;
    }
    if (_reduceMotion) {
      _controller.stop(canceled: true);
      _scheduleRemoval();
      return;
    }
    try {
      await _controller.animateWith(
        _miuixSnackbarSpring(_controller.value.clamp(0.0, 1.0), 0),
      );
    } on TickerCanceled {
      return;
    }
    widget.state._remove(widget.entry);
  }

  void _scheduleRemoval() {
    if (_removalScheduled) {
      return;
    }
    _removalScheduled = true;
    // Keep removal outside the host's listener-driven rebuild. The terminal
    // hidden frame is painted first, then the queue can safely discard it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _hiding) {
        widget.state._remove(widget.entry);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _dragController.dispose();
    super.dispose();
  }

  void _handleHorizontalDragStart(DragStartDetails details) {
    if (!widget.canSwipeToDismiss || !widget.entry.visible || _hiding) {
      return;
    }
    _dragController.stop();
    _dragSettling = false;
    _dragTarget = _dragController.value;
  }

  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    if (!widget.canSwipeToDismiss || !widget.entry.visible || _hiding) {
      return;
    }
    final width = _dragWidth;
    if (width <= 0) {
      return;
    }
    _dragController.value = (_dragController.value + details.delta.dx).clamp(
      -width,
      width,
    );
  }

  Future<void> _handleHorizontalDragEnd(DragEndDetails details) async {
    if (!widget.canSwipeToDismiss || !widget.entry.visible || _hiding) {
      return;
    }
    final width = _dragWidth;
    if (width <= 0) {
      return;
    }
    final offset = _dragController.value;
    final velocity = details.primaryVelocity ?? 0;
    // AnchoredDraggable uses the caller's 50-percent positional threshold and
    // its platform velocity threshold. The 125 dp/s default is the Compose
    // foundation threshold used by this source host.
    final dismiss = offset.abs() >= width * .5 || velocity.abs() >= 125;
    final target = dismiss
        ? width * ((offset == 0 ? velocity : offset).isNegative ? -1 : 1)
        : 0.0;
    _dragTarget = target;
    if (_reduceMotion) {
      _dragSettling = false;
      _dragController.value = target;
      if (dismiss && mounted) {
        await widget.entry.data.dismiss();
      }
      return;
    }
    _dragSettling = true;
    try {
      await _dragController.animateWith(
        SpringSimulation(
          const SpringDescription(mass: 1, stiffness: 400, damping: 40),
          offset,
          target,
          velocity,
          tolerance: const Tolerance(distance: .5, velocity: 1),
        ),
      );
    } on TickerCanceled {
      _dragSettling = false;
      return;
    }
    _dragSettling = false;
    if (dismiss && mounted) {
      await widget.entry.data.dismiss();
    }
  }

  void _handleHorizontalDragCancel() {
    if (!widget.canSwipeToDismiss || _hiding) {
      return;
    }
    final offset = _dragController.value;
    if (offset == 0) {
      return;
    }
    _dragTarget = 0;
    if (_reduceMotion) {
      _dragSettling = false;
      _dragController.value = 0;
      return;
    }
    // A platform cancellation does not choose either anchored destination.
    // Restore the visible entry with the same critically damped source spring
    // instead of leaving a partially translated snackbar on screen.
    _dragSettling = true;
    unawaited(
      _dragController
          .animateWith(
            SpringSimulation(
              const SpringDescription(mass: 1, stiffness: 400, damping: 40),
              offset,
              0,
              0,
              tolerance: const Tolerance(distance: .5, velocity: 1),
            ),
          )
          .whenComplete(() {
            _dragSettling = false;
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.entry.data;
    final content =
        widget.contentBuilder?.call(context, data) ??
        _MiuixHostedSnackbarSurface(data: data);
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _dragController]),
      child: LayoutBuilder(
        builder: (context, constraints) {
          _dragWidth = constraints.maxWidth;
          // Compose's anchoredDraggable owns a qualified horizontal stream
          // before the surrounding HorizontalPager. Use the same priority
          // recognizer as the source-style sliders so a snackbar swipe cannot
          // turn into a root PageView destination change on Android.
          return _miuixPriorityHorizontalDrag(
            onStart: widget.canSwipeToDismiss
                ? _handleHorizontalDragStart
                : null,
            onUpdate: widget.canSwipeToDismiss
                ? _handleHorizontalDragUpdate
                : null,
            onEnd: widget.canSwipeToDismiss ? _handleHorizontalDragEnd : null,
            onCancel: widget.canSwipeToDismiss
                ? _handleHorizontalDragCancel
                : null,
            child: content,
          );
        },
      ),
      builder: (context, child) {
        final progress = _reduceMotion
            ? (_hiding ? 0.0 : 1.0)
            : _controller.value.clamp(0.0, 1.0);
        final dragOffset = _reduceMotion && _dragSettling
            ? _dragTarget
            : _dragController.value;
        final newest = widget.index == 0;
        final slide = !_hiding || newest;
        Widget transitioned = Transform.translate(
          offset: Offset(dragOffset, slide ? 12 * (1 - progress) : 0),
          child: child,
        );
        if (_hiding && !newest) {
          transitioned = Opacity(opacity: progress, child: transitioned);
        }
        // Current Snackbar.kt combines a 12dp slide with top-anchored vertical
        // expansion. The newest exit slides and shrinks; older exits fade and
        // shrink without a placement slide. All three transitions use clip=false.
        return Align(
          alignment: Alignment.topCenter,
          heightFactor: progress,
          child: transitioned,
        );
      },
    );
  }
}

/// Compose's default spring uses unit mass, stiffness 400, and critical
/// damping. Snackbar.kt uses that default for slide, fade, and exit shrink.
SpringSimulation _miuixSnackbarSpring(double from, double to) {
  return SpringSimulation(
    const SpringDescription(mass: 1, stiffness: 400, damping: 40),
    from,
    to,
    0,
    tolerance: const Tolerance(distance: .001, velocity: .01),
  );
}

class _MiuixHostedSnackbarSurface extends StatelessWidget {
  const _MiuixHostedSnackbarSurface({required this.data});

  final MiuixSnackbarData data;

  @override
  Widget build(BuildContext context) => MiuixSnackbar(data: data);
}

/// Exact default Snackbar surface shared by the hosted and overlay APIs.
class _MiuixSnackbarSurface extends StatelessWidget {
  const _MiuixSnackbarSurface({
    required this.visuals,
    this.onAction,
    this.onDismiss,
    this.cornerRadius = MiuixSnackbarDefaults.cornerRadius,
    this.colors,
    this.insideMargin = MiuixSnackbarDefaults.insideMargin,
    this.glass = true,
  });

  final MiuixSnackbarVisuals visuals;
  final FutureOr<void> Function()? onAction;
  final FutureOr<void> Function()? onDismiss;
  final double cornerRadius;
  final MiuixSnackbarColors? colors;
  final EdgeInsetsGeometry insideMargin;
  final bool glass;

  @override
  Widget build(BuildContext context) {
    final resolvedColors =
        colors ?? MiuixSnackbarDefaults.snackbarColors(context);
    final theme = MiuixTheme.of(context);
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final fractionalAndroidDensity =
        defaultTargetPlatform == TargetPlatform.android &&
        (pixelRatio - pixelRatio.roundToDouble()).abs() > 1e-6;
    final radius = BorderRadius.circular(cornerRadius);
    final roundedShadowShape = RoundedRectangleBorder(borderRadius: radius);
    final ShapeBorder fillShape = theme.enableSquircle
        ? MiuixSquircleBorder(borderRadius: radius)
        : roundedShadowShape;
    final content = ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: _miuixRoundLogicalDimension(48, pixelRatio),
      ),
      child: Padding(
        padding: _miuixRoundedInsets(context, insideMargin),
        child: Row(
          children: [
            Expanded(
              child: _MiuixSnackbarMessage(
                message: visuals.message,
                color: resolvedColors.contentColor,
              ),
            ),
            if (visuals.actionLabel case final label? when label.isNotEmpty)
              _MiuixSnackbarAction(
                label: label,
                color: resolvedColors.actionContentColor,
                backgroundColor: resolvedColors.actionContainerColor,
                onTap: onAction,
              ),
            if (visuals.withDismissAction)
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 8),
                child: _MiuixIconButtonTouchTarget(
                  key: const ValueKey('miuix-snackbar-dismiss-action'),
                  enabled: onDismiss != null,
                  selected: false,
                  semanticButton: false,
                  semanticImage: true,
                  exposeSelectedState: false,
                  semanticLabel: 'Dismiss',
                  textDirection: Directionality.of(context),
                  // Compose independently rounds the 20dp placeable and the
                  // 48dp touch expansion. At Android fractional densities the
                  // expanded origin advances one physical pixel; Flutter's
                  // centered logical rectangle otherwise starts one pixel up.
                  targetOffset: fractionalAndroidDensity
                      ? Offset(0, 1 / pixelRatio)
                      : Offset.zero,
                  targetInsets: EdgeInsets.zero,
                  minimumSize: _miuixRoundLogicalDimension(48, pixelRatio),
                  onTap: onDismiss == null ? null : () => onDismiss?.call(),
                  // Snackbar.kt explicitly disables indication for this raw
                  // clickable icon. These callbacks therefore stay inert even
                  // though the target expands independently to Android's 48dp.
                  onTapDown: () {},
                  onTapUp: () {},
                  onTapCancel: () {},
                  child: MiuixThemedIcon(
                    MiuixIcons.basic.close,
                    size: 20,
                    color: resolvedColors.dismissActionContentColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
    final paintedFill = glass
        ? MiuixGlass(
            radius: cornerRadius,
            blur: theme.hyperOs4.snackbarBlur,
            opacity: theme.hyperOs4.snackbarTintOpacity,
            color: resolvedColors.containerColor,
            optics: MiuixGlassOptics.transient,
            padding: EdgeInsets.zero,
            showSpecular: true,
            child: content,
          )
        : theme.enableSquircle
        ? MiuixSquircleBackground(
            color: resolvedColors.containerColor,
            borderRadius: radius,
            child: content,
          )
        : DecoratedBox(
            decoration: ShapeDecoration(
              color: resolvedColors.containerColor,
              shape: fillShape,
            ),
            child: content,
          );
    final surface = DecoratedBox(
      key: const ValueKey('miuix-snackbar-surface'),
      decoration: ShapeDecoration(
        // Snackbar.kt shadows RoundedCornerShape first and only then draws the
        // nested squircle background. Sharing the fill's G2 outline here pulls
        // the corner falloff inward and is visibly different at large radii.
        shape: roundedShadowShape,
        shadows: [
          BoxShadow(color: Colors.black.withValues(alpha: .1), blurRadius: 10),
        ],
      ),
      child: paintedFill,
    );
    // The source Row wraps its measured height even when Snackbar is used
    // directly in a large Box. Keep the finite horizontal constraint required
    // by the weighted message, but remove the parent's vertical expansion.
    return UnconstrainedBox(
      constrainedAxis: Axis.horizontal,
      child: Padding(
        padding: _miuixRoundedInsets(
          context,
          MiuixSnackbarDefaults.outerPadding,
        ),
        child: Semantics(
          liveRegion: true,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: true,
            onTap: () {},
            child: surface,
          ),
        ),
      ),
    );
  }
}

/// Source body2 paragraph with per-line Android physical rounding.
///
/// Compose measures the message after the trailing action and dismiss slots,
/// then creates one independently rounded line-height placeable per visual
/// line. Flutter normally rounds the final paragraph height instead. Those
/// orders are observably different at fractional Android densities: two
/// source lines are 43px + 43px at 420dpi, while an unconstrained Flutter
/// paragraph loses two physical pixels across its first and last baselines.
///
/// This widget deliberately keeps measurement and painting tied to the same
/// style, scaler, strut, direction, width, maximum line count, and ellipsis.
/// It therefore only changes the physical rounding boundary; it does not
/// force a translation-specific wrap or reserve two lines for short content.
/// One-line messages still rely on the surrounding 48dp row minimum, while a
/// genuine two-line message contributes the exact 86px source placeable.
/// Keeping that distinction here also preserves the queue's source entrance
/// and exit geometry when text scale or the available action width changes.
class _MiuixSnackbarMessage extends StatelessWidget {
  const _MiuixSnackbarMessage({required this.message, required this.color});

  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final textScaler = MediaQuery.textScalerOf(context);
    final scaledFontSize = textScaler.scale(14);
    // The current Android body2 placeable measures one 14sp line as 43px at
    // 420dpi. Round that line independently before multiplying by the actual
    // wrapped line count; rounding the complete Flutter paragraph loses two
    // pixels for the two-line source Action + Close message.
    final sourceLineHeight = _miuixRoundLogicalDimension(
      scaledFontSize * 1.16,
      pixelRatio,
    );
    final sourceHeightRatio = sourceLineHeight / scaledFontSize;
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: color,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: sourceHeightRatio,
    );
    final strutStyle = StrutStyle(
      fontSize: 14,
      height: sourceHeightRatio,
      forceStrutHeight: true,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        // The action and dismiss slots are measured by the surrounding Row
        // first, so maxWidth here is the exact width Compose gives its
        // weighted message. Use the same width to distinguish one and two
        // lines without inserting a locale-specific hard line break.
        final painter = TextPainter(
          text: TextSpan(text: message, style: style),
          textDirection: Directionality.of(context),
          textScaler: textScaler,
          strutStyle: strutStyle,
          maxLines: 2,
          ellipsis: '…',
        )..layout(maxWidth: constraints.maxWidth);
        final lineCount = painter.computeLineMetrics().length.clamp(1, 2);
        return SizedBox(
          height: sourceLineHeight * lineCount,
          child: Text(
            message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            strutStyle: strutStyle,
            style: style,
          ),
        );
      },
    );
  }
}

class _MiuixSnackbarAction extends StatelessWidget {
  const _MiuixSnackbarAction({
    required this.label,
    required this.color,
    required this.backgroundColor,
    required this.onTap,
  });

  final String label;
  final Color color;
  final Color backgroundColor;
  final FutureOr<void> Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    return Semantics(
      button: true,
      child: MiuixPressable(
        onTap: onTap == null ? null : () => onTap?.call(),
        borderRadius: BorderRadius.circular(
          MiuixSnackbarDefaults.actionCornerRadius,
        ),
        feedbackType: MiuixPressFeedbackType.none,
        showIndication: onTap != null,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(
              MiuixSnackbarDefaults.actionCornerRadius,
            ),
          ),
          child: ConstrainedBox(
            key: const ValueKey('miuix-snackbar-action'),
            constraints: BoxConstraints(
              minWidth: _miuixRoundLogicalDimension(26, pixelRatio),
              minHeight: _miuixRoundLogicalDimension(26, pixelRatio),
            ),
            child: Padding(
              padding: _miuixRoundedInsets(
                context,
                MiuixSnackbarDefaults.actionInsideMargin,
              ),
              child: Center(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0,
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

/// Source snackbar surface plus the legacy root-overlay helper.
class MiuixSnackbar extends StatelessWidget {
  /// Creates the exact `Snackbar(data, cornerRadius, colors, insideMargin)`.
  const MiuixSnackbar({
    super.key,
    required this.data,
    this.cornerRadius = MiuixSnackbarDefaults.cornerRadius,
    this.colors,
    this.insideMargin = MiuixSnackbarDefaults.insideMargin,
    this.glass = true,
  });

  /// Creates the explicit opaque MIUIX 1.0.9 snackbar surface.
  const MiuixSnackbar.source({
    super.key,
    required this.data,
    this.cornerRadius = MiuixSnackbarDefaults.legacyCornerRadius,
    this.colors,
    this.insideMargin = MiuixSnackbarDefaults.insideMargin,
  }) : glass = false;

  /// Source data handle.
  final MiuixSnackbarData data;

  /// Source surface corner radius.
  final double cornerRadius;

  /// Optional source color set.
  final MiuixSnackbarColors? colors;

  /// Padding inside the source surface.
  final EdgeInsetsGeometry insideMargin;

  /// Whether the transient surface uses HyperOS 4 backdrop material.
  final bool glass;

  @override
  Widget build(BuildContext context) {
    return _MiuixSnackbarSurface(
      visuals: data.visuals,
      onAction: data.performAction,
      onDismiss: data.dismiss,
      cornerRadius: cornerRadius,
      colors: colors,
      insideMargin: insideMargin,
      glass: glass,
    );
  }

  /// Shows a snackbar.
  static MiuixSnackbarController show(
    BuildContext context,
    String message, {
    SnackBarAction? action,
    MiuixSnackbarDuration duration = MiuixSnackbarDuration.short,
    bool withDismissAction = false,
    bool ignorePointer = false,
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    final controller = MiuixSnackbarController._();
    if (!context.mounted || overlay == null) {
      controller._complete();
      return controller;
    }
    final callerReduceMotion = MediaQuery.disableAnimationsOf(context);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _MiuixSnackbarOverlay(
        message: message,
        actionLabel: action?.label,
        onAction: action?.onPressed,
        duration: duration,
        withDismissAction: withDismissAction,
        ignorePointer: ignorePointer,
        reduceMotion: callerReduceMotion,
        onDismissed: () {
          controller._dismiss = null;
          if (entry.mounted) {
            entry.remove();
          }
          controller._complete();
        },
      ),
    );
    controller._dismiss = () {
      if (controller._closed.isCompleted) {
        return;
      }
      if (entry.mounted) {
        entry.remove();
      }
      controller._complete();
    };
    if (context.mounted) {
      overlay.insert(entry);
    } else {
      controller._complete();
    }
    return controller;
  }
}

/// Controller returned when showing a Miuix snackbar.
class MiuixSnackbarController {
  MiuixSnackbarController._();

  final Completer<void> _closed = Completer<void>();
  VoidCallback? _dismiss;

  /// Completes when the snackbar is dismissed.
  Future<void> get closed => _closed.future;

  /// Dismisses the snackbar if it is still visible.
  void close() {
    final dismiss = _dismiss;
    _dismiss = null;
    dismiss?.call();
    _complete();
  }

  void _complete() {
    if (!_closed.isCompleted) {
      _closed.complete();
    }
  }
}

class _MiuixSnackbarOverlay extends StatefulWidget {
  const _MiuixSnackbarOverlay({
    required this.message,
    required this.onDismissed,
    required this.duration,
    required this.withDismissAction,
    required this.ignorePointer,
    required this.reduceMotion,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final MiuixSnackbarDuration duration;
  final bool withDismissAction;
  final bool ignorePointer;
  final bool reduceMotion;
  final VoidCallback onDismissed;

  @override
  State<_MiuixSnackbarOverlay> createState() => _MiuixSnackbarOverlayState();
}

class _MiuixSnackbarOverlayState extends State<_MiuixSnackbarOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _timer;
  bool _dismissed = false;
  bool _reduceMotion = false;
  bool _dismissScheduled = false;

  @override
  void initState() {
    super.initState();
    _reduceMotion = widget.reduceMotion;
    _controller = AnimationController.unbounded(
      vsync: this,
      value: _reduceMotion ? 1 : 0,
    );
    if (!_reduceMotion) {
      _controller.animateWith(_miuixSnackbarSpring(0, 1));
    }
    final timeout = widget.duration.duration;
    if (timeout != null) _timer = Timer(timeout, _dismiss);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // OverlayEntry is hosted under the Navigator overlay and can therefore be
    // outside a local MediaQuery placed around the calling subtree. Preserve
    // the caller's initial preference while still observing window-level
    // accessibility changes delivered to the overlay itself.
    final nextReduceMotion =
        widget.reduceMotion || MediaQuery.disableAnimationsOf(context);
    if (nextReduceMotion == _reduceMotion) {
      return;
    }
    _reduceMotion = nextReduceMotion;
    if (!_reduceMotion) {
      return;
    }
    _controller.stop(canceled: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _reduceMotion) {
        _controller.value = _dismissed ? 0 : 1;
      }
    });
    if (_dismissed) {
      _scheduleDismissed();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    if (_dismissed || !mounted) {
      return;
    }
    _dismissed = true;
    _timer?.cancel();
    if (_reduceMotion) {
      _controller.stop(canceled: true);
      _scheduleDismissed();
      return;
    }
    try {
      await _controller.animateWith(
        _miuixSnackbarSpring(_controller.value.clamp(0.0, 1.0), 0),
      );
    } on TickerCanceled {
      return;
    }
    if (mounted) {
      widget.onDismissed();
    }
  }

  void _scheduleDismissed() {
    if (_dismissScheduled) {
      return;
    }
    _dismissScheduled = true;
    // Overlay removal mutates the OverlayEntry list. Defer it until the
    // terminal invisible frame has completed to avoid changing that list
    // during its own build pass.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _dismissed) {
        widget.onDismissed();
      }
    });
  }

  void _performAction() {
    if (_dismissed) {
      return;
    }
    widget.onAction?.call();
    _dismiss();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom + 12;
    return Positioned(
      left: 0,
      right: 0,
      bottom: bottom,
      child: IgnorePointer(
        ignoring: widget.ignorePointer,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final progress = _reduceMotion
                ? (_dismissed ? 0.0 : 1.0)
                : _controller.value.clamp(0.0, 1.0);
            return Opacity(
              opacity: progress,
              child: FractionalTranslation(
                translation: Offset(0, 1 - progress),
                child: child,
              ),
            );
          },
          child: _MiuixSnackbarSurface(
            visuals: MiuixSnackbarVisuals(
              message: widget.message,
              actionLabel: widget.actionLabel,
              duration: widget.duration,
              withDismissAction: widget.withDismissAction,
            ),
            onAction: widget.actionLabel == null ? null : _performAction,
            onDismiss: widget.withDismissAction ? _dismiss : null,
          ),
        ),
      ),
    );
  }
}
