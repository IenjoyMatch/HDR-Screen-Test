part of '../miuix_widgets.dart';

/// Preferred placement of a tooltip relative to its anchor.
///
/// The source flips to the opposite side when the preferred side has no room.
/// [start] and [end] follow the active text direction.
enum MiuixTooltipAnchorPosition { above, below, left, right, start, end }

/// Source dimensions and motion values shared by plain and rich tooltips.
abstract final class MiuixTooltipDefaults {
  /// Empty distance between the anchor and tooltip.
  static const double spacingBetweenTooltipAndAnchor = 8;

  /// Optional caret geometry.
  static const Size caretSize = Size(16, 8);

  /// Plain tooltip maximum width.
  static const double plainTooltipMaxWidth = 200;

  /// Plain tooltip continuous-corner radius.
  static const double plainTooltipCornerRadius = 12;

  /// Plain tooltip content padding.
  static const EdgeInsets plainTooltipInsideMargin = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 8,
  );

  /// Rich tooltip maximum width.
  static const double richTooltipMaxWidth = 320;

  /// Rich tooltip continuous-corner radius.
  static const double richTooltipCornerRadius = 16;

  /// Rich tooltip content padding.
  static const EdgeInsets richTooltipInsideMargin = EdgeInsets.all(16);

  /// Rich tooltip action radius.
  static const double richTooltipActionCornerRadius = 8;

  /// Rich tooltip action padding.
  static const EdgeInsets richTooltipActionInsideMargin = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 6,
  );

  /// Plain tooltip background (`onSecondaryVariant`).
  static Color plainTooltipContainerColor(BuildContext context) {
    return MiuixSemanticColors.of(context)['onSecondaryVariant'];
  }

  /// Plain tooltip foreground (`secondaryVariant`).
  static Color plainTooltipContentColor(BuildContext context) {
    return MiuixSemanticColors.of(context)['secondaryVariant'];
  }

  /// Current source rich-tooltip semantic colors.
  static MiuixRichTooltipColors richTooltipColors(
    BuildContext context, {
    Color? containerColor,
    Color? contentColor,
    Color? titleContentColor,
    Color? actionContentColor,
  }) {
    final semantic = MiuixSemanticColors.of(context);
    return MiuixRichTooltipColors(
      containerColor: containerColor ?? semantic['surfaceContainer'],
      contentColor: contentColor ?? semantic['onSurfaceContainerVariant'],
      titleContentColor: titleContentColor ?? semantic['onSurfaceContainer'],
      actionContentColor: actionContentColor ?? semantic['primary'],
    );
  }
}

/// Semantic colors used by a rich tooltip.
@immutable
class MiuixRichTooltipColors {
  /// Creates an immutable source color contract.
  const MiuixRichTooltipColors({
    required this.containerColor,
    required this.contentColor,
    required this.titleContentColor,
    required this.actionContentColor,
  });

  /// Tooltip card color.
  final Color containerColor;

  /// Body text color.
  final Color contentColor;

  /// Optional title color.
  final Color titleContentColor;

  /// Optional action label color.
  final Color actionContentColor;

  /// Returns a copy with selected roles replaced.
  MiuixRichTooltipColors copyWith({
    Color? containerColor,
    Color? contentColor,
    Color? titleContentColor,
    Color? actionContentColor,
  }) {
    return MiuixRichTooltipColors(
      containerColor: containerColor ?? this.containerColor,
      contentColor: contentColor ?? this.contentColor,
      titleContentColor: titleContentColor ?? this.titleContentColor,
      actionContentColor: actionContentColor ?? this.actionContentColor,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MiuixRichTooltipColors &&
        other.containerColor == containerColor &&
        other.contentColor == contentColor &&
        other.titleContentColor == titleContentColor &&
        other.actionContentColor == actionContentColor;
  }

  @override
  int get hashCode => Object.hash(
    containerColor,
    contentColor,
    titleContentColor,
    actionContentColor,
  );
}

/// Visibility state shared between a tooltip anchor and application code.
///
/// A single global coordinator mirrors Compose's `MutatorMutex`: showing one
/// state dismisses the previously visible tooltip. Programmatic non-persistent
/// shows time out after 1500 ms, while hover and long-press input stays visible
/// until the matching dismissal rule runs.
class MiuixTooltipState extends ChangeNotifier {
  /// Creates a tooltip state.
  MiuixTooltipState({bool initialIsVisible = false, this.isPersistent = false})
    : _targetVisible = initialIsVisible;

  static MiuixTooltipState? _activeState;
  static const Duration _tooltipDuration = Duration(milliseconds: 1500);

  /// Whether this tooltip requires an explicit dismissal.
  final bool isPersistent;

  bool _targetVisible;
  bool _animationActive = false;
  bool _disposed = false;
  Timer? _dismissTimer;
  Completer<void>? _showCompleter;

  /// Whether the tooltip is shown or still completing its exit animation.
  bool get isVisible => _targetVisible || _animationActive;

  /// Whether the desired transition state is visible.
  bool get targetVisible => _targetVisible;

  /// Shows the tooltip programmatically.
  ///
  /// The returned future completes when the tooltip is dismissed, times out,
  /// or is superseded by another tooltip.
  Future<void> show() => _show(fromUserInput: false);

  Future<void> _showFromUserInput() => _show(fromUserInput: true);

  Future<void> _show({required bool fromUserInput}) {
    if (_disposed) {
      return Future<void>.value();
    }
    if (_activeState != null && !identical(_activeState, this)) {
      _activeState!.dismiss();
    }
    _activeState = this;
    _dismissTimer?.cancel();
    _showCompleter ??= Completer<void>();
    if (!_targetVisible) {
      _targetVisible = true;
      notifyListeners();
    }
    if (!isPersistent && !fromUserInput) {
      _dismissTimer = Timer(_tooltipDuration, dismiss);
    }
    return _showCompleter!.future;
  }

  /// Starts the source exit transition.
  void dismiss() {
    if (_disposed) {
      return;
    }
    _dismissTimer?.cancel();
    if (_targetVisible) {
      _targetVisible = false;
      notifyListeners();
    }
    if (identical(_activeState, this)) {
      _activeState = null;
    }
    final completer = _showCompleter;
    _showCompleter = null;
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
  }

  void _setAnimationActive(bool value) {
    if (_disposed || _animationActive == value) {
      return;
    }
    _animationActive = value;
    notifyListeners();
  }

  /// Releases timers and any suspended [show] future.
  void onDispose() {
    if (_disposed) {
      return;
    }
    dismiss();
    _disposed = true;
  }

  @override
  void dispose() {
    onDispose();
    super.dispose();
  }
}

/// Plain current-source tooltip convenience.
class MiuixTooltip extends StatelessWidget {
  /// Creates a plain HyperOS 4 glass tooltip.
  const MiuixTooltip({
    super.key,
    required this.message,
    required this.child,
    this.state,
    this.enabled = true,
    this.positioning = MiuixTooltipAnchorPosition.below,
    this.containerColor,
    this.contentColor,
    this.showCaret = false,
    this.glass = true,
    this.glassBlur,
    this.glassOpacity,
    this.cornerRadius,
  });

  /// Creates the opaque current-source tooltip presentation explicitly.
  const MiuixTooltip.source({
    super.key,
    required this.message,
    required this.child,
    this.state,
    this.enabled = true,
    this.positioning = MiuixTooltipAnchorPosition.below,
    this.containerColor,
    this.contentColor,
    this.showCaret = false,
    this.glass = false,
    this.glassBlur,
    this.glassOpacity,
    this.cornerRadius = MiuixTooltipDefaults.plainTooltipCornerRadius,
  });

  /// Tooltip text, limited to two lines by the source.
  final String message;

  /// Anchor content.
  final Widget child;

  /// Optional hoisted visibility state.
  final MiuixTooltipState? state;

  /// Whether hover and long press can show the tooltip.
  final bool enabled;

  /// Preferred placement before automatic flipping.
  final MiuixTooltipAnchorPosition positioning;

  /// Optional plain-tooltip background override.
  final Color? containerColor;

  /// Optional plain-tooltip foreground override.
  final Color? contentColor;

  /// Whether to draw the optional 16 by 8 caret.
  final bool showCaret;

  /// Whether the tooltip samples and softens the real content behind it.
  final bool glass;

  /// Optional role-specific material overrides.
  final double? glassBlur;
  final double? glassOpacity;

  /// Optional continuous-corner override.
  ///
  /// When omitted the ordinary constructor resolves the HyperOS 4 popup token;
  /// [MiuixTooltip.source] retains the upstream 12dp value.
  final double? cornerRadius;

  @override
  Widget build(BuildContext context) {
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final resolvedContainer =
        containerColor ??
        MiuixTooltipDefaults.plainTooltipContainerColor(context);
    final resolvedContent =
        contentColor ?? MiuixTooltipDefaults.plainTooltipContentColor(context);
    final textStyle =
        MiuixTheme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: resolvedContent) ??
        TextStyle(color: resolvedContent, fontSize: 14, height: 1.16);
    return _MiuixTooltipAnchor(
      state: state,
      enabled: enabled,
      persistentByDefault: false,
      focusable: false,
      positioning: positioning,
      semanticLabel: message,
      child: child,
      tooltipBuilder: (context, anchor, state) => _MiuixTooltipSurface(
        anchor: anchor,
        positioning: positioning,
        maxWidth: MiuixTooltipDefaults.plainTooltipMaxWidth,
        cornerRadius: cornerRadius ?? hyperOs4.popupCornerRadius,
        containerColor: resolvedContainer,
        insideMargin: MiuixTooltipDefaults.plainTooltipInsideMargin,
        showCaret: showCaret,
        glass: glass,
        glassBlur: glassBlur ?? hyperOs4.popupBlur,
        glassOpacity: glassOpacity ?? hyperOs4.popupTintOpacity,
        child: _MiuixTooltipSourceText(
          text: message,
          style: textStyle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

/// Adapter retaining the upstream `TooltipBox` name.
class MiuixTooltipBox extends MiuixTooltip {
  /// Creates a plain tooltip box.
  const MiuixTooltipBox({
    super.key,
    required super.message,
    required super.child,
    super.state,
    super.enabled,
    super.positioning,
    super.containerColor,
    super.contentColor,
    super.showCaret,
    super.glass,
    super.glassBlur,
    super.glassOpacity,
    super.cornerRadius,
  });

  /// Creates the opaque current-source tooltip box explicitly.
  const MiuixTooltipBox.source({
    super.key,
    required super.message,
    required super.child,
    super.state,
    super.enabled,
    super.positioning,
    super.containerColor,
    super.contentColor,
    super.showCaret,
    super.glass,
    super.glassBlur,
    super.glassOpacity,
    super.cornerRadius,
  }) : super.source();
}

/// Rich current-source tooltip with compatibility for arbitrary body widgets.
class MiuixRichTooltip extends StatelessWidget {
  /// Creates the HyperOS 4 arbitrary-content glass adapter.
  const MiuixRichTooltip({
    super.key,
    required this.child,
    required this.content,
    this.message,
    this.state,
    this.enabled = true,
    this.positioning = MiuixTooltipAnchorPosition.below,
    this.colors,
    this.showCaret = false,
    this.glass = true,
    this.glassBlur,
    this.glassOpacity,
    this.cornerRadius,
  }) : title = null,
       actionText = null,
       onActionClick = null,
       _sourceText = null;

  /// Creates the current upstream string convenience.
  const MiuixRichTooltip.source({
    super.key,
    required this.child,
    required String text,
    this.title,
    this.actionText,
    this.onActionClick,
    this.state,
    this.enabled = true,
    this.positioning = MiuixTooltipAnchorPosition.below,
    this.colors,
    this.showCaret = false,
    this.glass = false,
    this.glassBlur,
    this.glassOpacity,
    this.cornerRadius = MiuixTooltipDefaults.richTooltipCornerRadius,
  }) : content = const SizedBox.shrink(),
       message = null,
       _sourceText = text;

  /// Anchor content.
  final Widget child;

  /// Body content.
  final Widget content;

  final String? _sourceText;

  /// Compatibility title used by the earlier constructor.
  final String? message;

  /// Current-source optional title.
  final String? title;

  /// Current-source optional action label.
  final String? actionText;

  /// Invoked before the tooltip dismisses after action selection.
  final VoidCallback? onActionClick;

  /// Optional hoisted persistent state.
  final MiuixTooltipState? state;

  /// Whether hover and long press can show the tooltip.
  final bool enabled;

  /// Preferred placement before automatic flipping.
  final MiuixTooltipAnchorPosition positioning;

  /// Optional rich-tooltip colors.
  final MiuixRichTooltipColors? colors;

  /// Whether to draw the optional 16 by 8 caret.
  final bool showCaret;

  /// Whether this transient surface uses the HyperOS 4 glass material.
  final bool glass;

  /// Optional role-specific material overrides.
  final double? glassBlur;
  final double? glassOpacity;

  /// Optional continuous-corner override.
  final double? cornerRadius;

  @override
  Widget build(BuildContext context) {
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final resolvedColors =
        colors ?? MiuixTooltipDefaults.richTooltipColors(context);
    final resolvedTitle = title ?? message;
    final sourceText = _sourceText;
    final semanticLabel = resolvedTitle ?? sourceText ?? _plainText(content);
    final theme = MiuixTheme.of(context).textTheme;
    final titleStyle =
        theme.titleSmall?.copyWith(color: resolvedColors.titleContentColor) ??
        TextStyle(
          color: resolvedColors.titleContentColor,
          fontSize: 14,
          height: 1.16,
          fontWeight: FontWeight.w700,
        );
    final bodyStyle =
        theme.bodySmall?.copyWith(color: resolvedColors.contentColor) ??
        TextStyle(
          color: resolvedColors.contentColor,
          fontSize: 14,
          height: 1.16,
        );
    final resolvedContent = sourceText == null
        ? content
        : _MiuixTooltipSourceText(text: sourceText, style: bodyStyle);
    return _MiuixTooltipAnchor(
      state: state,
      enabled: enabled,
      persistentByDefault: true,
      focusable: true,
      positioning: positioning,
      semanticLabel: semanticLabel,
      child: child,
      tooltipBuilder: (context, anchor, activeState) => _MiuixTooltipSurface(
        anchor: anchor,
        positioning: positioning,
        maxWidth: MiuixTooltipDefaults.richTooltipMaxWidth,
        cornerRadius: cornerRadius ?? hyperOs4.popupCornerRadius,
        containerColor: resolvedColors.containerColor,
        insideMargin: MiuixTooltipDefaults.richTooltipInsideMargin,
        showCaret: showCaret,
        glass: glass,
        glassBlur: glassBlur ?? hyperOs4.popupBlur,
        glassOpacity: glassOpacity ?? hyperOs4.popupTintOpacity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (resolvedTitle != null) ...[
              _MiuixTooltipSourceText(text: resolvedTitle, style: titleStyle),
              const SizedBox(height: 8),
            ],
            DefaultTextStyle(style: bodyStyle, child: resolvedContent),
            if (actionText != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: MiuixTextButton(
                  label: actionText!,
                  onPressed: () {
                    onActionClick?.call();
                    activeState.dismiss();
                  },
                  minWidth: 0,
                  minHeight: 0,
                  cornerRadius:
                      MiuixTooltipDefaults.richTooltipActionCornerRadius,
                  insideMargin:
                      MiuixTooltipDefaults.richTooltipActionInsideMargin,
                  colors: MiuixButtonDefaults.textButtonColors(
                    context,
                    color: Colors.transparent,
                    textColor: resolvedColors.actionContentColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _plainText(Widget widget) {
    if (widget is Text) {
      return widget.data ?? widget.textSpan?.toPlainText() ?? '';
    }
    return '更多信息';
  }
}

/// Resolves one source typography line before surrounding layout is added.
///
/// Compose measures every `Text` placeable in integer physical pixels. A
/// multi-line tooltip then adds those measured title/body placeables, its two
/// 8dp gaps, and the action independently. Flutter otherwise keeps the 1.16em
/// line height fractional until the complete Column is rasterized; at 420dpi
/// three localized body lines lose four pixels compared with the source. A
/// forced, density-ceiled strut preserves the source line box while allowing
/// the translated text to choose its own natural number of lines.
({TextStyle style, StrutStyle strutStyle, double lineHeight})
_miuixTooltipTextMetrics(BuildContext context, TextStyle style) {
  final unscaledFontSize = style.fontSize ?? 14;
  final scaledFontSize = MediaQuery.textScalerOf(
    context,
  ).scale(unscaledFontSize);
  final sourceLineHeight = _miuixCeilLogicalDimension(
    scaledFontSize * (style.height ?? 1.16),
    MediaQuery.devicePixelRatioOf(context),
  );
  final height = sourceLineHeight / scaledFontSize;
  return (
    style: style.copyWith(height: height),
    strutStyle: StrutStyle(
      fontSize: unscaledFontSize,
      height: height,
      forceStrutHeight: true,
    ),
    lineHeight: sourceLineHeight,
  );
}

/// Text whose outer placeable grows in whole source line boxes.
///
/// Flutter's paragraph engine can report a 42px child for an authored 43px
/// strut at fractional density. The outer box is therefore authoritative,
/// while the centered paragraph still owns glyph shaping, wrapping, ellipsis,
/// and accessibility text.
class _MiuixTooltipSourceText extends StatelessWidget {
  const _MiuixTooltipSourceText({
    required this.text,
    required this.style,
    this.maxLines,
    this.overflow = TextOverflow.clip,
  });

  final String text;
  final TextStyle style;
  final int? maxLines;
  final TextOverflow overflow;

  @override
  Widget build(BuildContext context) {
    final metrics = _miuixTooltipTextMetrics(context, style);
    final direction = Directionality.of(context);
    final scaler = MediaQuery.textScalerOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: text, style: metrics.style),
          textDirection: direction,
          textScaler: scaler,
          maxLines: maxLines,
          ellipsis: overflow == TextOverflow.ellipsis ? '\u2026' : null,
        )..layout(maxWidth: constraints.maxWidth);
        final lines = math.max(1, painter.computeLineMetrics().length);
        return SizedBox(
          height: metrics.lineHeight * lines,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: 1,
            child: Text(
              text,
              maxLines: maxLines,
              overflow: overflow,
              style: metrics.style,
              strutStyle: metrics.strutStyle,
            ),
          ),
        );
      },
    );
  }
}

/// Adapter retaining the upstream `RichTooltipBox` name.
class MiuixRichTooltipBox extends MiuixRichTooltip {
  /// Creates the compatibility arbitrary-content overload.
  const MiuixRichTooltipBox({
    super.key,
    required super.child,
    required super.content,
    super.message,
    super.state,
    super.enabled,
    super.positioning,
    super.colors,
    super.showCaret,
    super.glass,
    super.glassBlur,
    super.glassOpacity,
    super.cornerRadius,
  });

  /// Creates the current upstream string overload.
  const MiuixRichTooltipBox.source({
    super.key,
    required super.child,
    required super.text,
    super.title,
    super.actionText,
    super.onActionClick,
    super.state,
    super.enabled,
    super.positioning,
    super.colors,
    super.showCaret,
    super.glass,
    super.glassBlur,
    super.glassOpacity,
    super.cornerRadius,
  }) : super.source();
}

typedef _MiuixTooltipBuilder =
    Widget Function(BuildContext context, Rect anchor, MiuixTooltipState state);

class _MiuixTooltipAnchor extends StatefulWidget {
  const _MiuixTooltipAnchor({
    required this.child,
    required this.tooltipBuilder,
    required this.positioning,
    required this.semanticLabel,
    required this.persistentByDefault,
    required this.focusable,
    required this.enabled,
    this.state,
  });

  final Widget child;
  final _MiuixTooltipBuilder tooltipBuilder;
  final MiuixTooltipAnchorPosition positioning;
  final String semanticLabel;
  final bool persistentByDefault;
  final bool focusable;
  final bool enabled;
  final MiuixTooltipState? state;

  @override
  State<_MiuixTooltipAnchor> createState() => _MiuixTooltipAnchorState();
}

class _MiuixTooltipAnchorState extends State<_MiuixTooltipAnchor> {
  OverlayEntry? _entry;
  bool _entryBuildScheduled = false;
  bool _anchorTrackingScheduled = false;
  LocalHistoryEntry? _historyEntry;
  late MiuixTooltipState _state;
  late bool _ownsState;
  Rect _anchorRect = Rect.zero;

  @override
  void initState() {
    super.initState();
    _adoptState(widget.state);
  }

  @override
  void didUpdateWidget(covariant _MiuixTooltipAnchor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.state, widget.state)) {
      _removeHistoryEntry();
      final entry = _entry;
      _entry = null;
      if (entry?.mounted == true) {
        entry?.remove();
      }
      _releaseState();
      _adoptState(widget.state);
    }
    if (_entry != null) {
      _scheduleAnchorTracking();
    }
  }

  void _adoptState(MiuixTooltipState? state) {
    _ownsState = state == null;
    _state =
        state ?? MiuixTooltipState(isPersistent: widget.persistentByDefault);
    _state.addListener(_handleStateChange);
    if (_state.targetVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _handleStateChange();
        }
      });
    }
  }

  void _releaseState() {
    _state.removeListener(_handleStateChange);
    // This anchor owns the presentation lifetime even when the visibility
    // state is hoisted. Clear the exit bookkeeping only after detaching the
    // listener so disposal cannot synchronously re-enter the widget tree.
    _state._setAnimationActive(false);
    if (_ownsState) {
      _state.dispose();
    }
  }

  @override
  void dispose() {
    _releaseState();
    _removeHistoryEntry();
    final entry = _entry;
    _entry = null;
    if (entry?.mounted == true) {
      entry?.remove();
    }
    super.dispose();
  }

  void _handleStateChange() {
    if (!mounted) {
      return;
    }
    if (_state.targetVisible) {
      _ensureEntry();
    } else {
      _scheduleEntryBuild();
    }
  }

  /// Defers OverlayEntry dirtiness until the current widget build is over.
  ///
  /// Top-bar action menus rebuild several sibling tooltips together. The
  /// global single-tooltip coordinator can dismiss one sibling while another
  /// is in `build`, where calling `markNeedsBuild` synchronously is illegal.
  void _scheduleEntryBuild() {
    if (_entry == null || _entryBuildScheduled) {
      return;
    }
    if (SchedulerBinding.instance.schedulerPhase !=
        SchedulerPhase.persistentCallbacks) {
      _entry?.markNeedsBuild();
      return;
    }
    _entryBuildScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _entryBuildScheduled = false;
      final entry = _entry;
      if (mounted && entry?.mounted == true) {
        entry?.markNeedsBuild();
      }
    });
  }

  void _ensureEntry() {
    if (_entry != null || !_updateAnchorRect()) {
      return;
    }
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) {
      return;
    }
    // Assign before notifying: listeners run synchronously and would otherwise
    // re-enter this method while [_entry] is still null.
    _entry = OverlayEntry(
      builder: (overlayContext) {
        final tooltip = _MiuixTooltipOverlay(
          anchor: _anchorRect,
          positioning: widget.positioning,
          visible: _state.targetVisible,
          focusable: widget.focusable,
          state: _state,
          onExitComplete: _removeEntryAfterExit,
          child: widget.tooltipBuilder(overlayContext, _anchorRect, _state),
        );
        // The root Overlay belongs to MaterialApp and sits above the MiuixTheme
        // installed around this anchor. Capture the anchor's inherited Theme
        // on every entry build so tooltip actions keep MIUIX fonts, line boxes,
        // colors, and any live theme change instead of falling back to the
        // Material root defaults.
        return InheritedTheme.capture(
          from: context,
          // OverlayState is the common ancestor. The entry builder itself is
          // already below Overlay, so using overlayContext would invert the
          // required ancestor relationship.
          to: overlay.context,
        ).wrap(tooltip);
      },
    );
    _state._setAnimationActive(true);
    overlay.insert(_entry!);
    _scheduleAnchorTracking();
    if (widget.focusable && _state.isPersistent) {
      final route = ModalRoute.of(context);
      if (route != null) {
        _historyEntry = LocalHistoryEntry(onRemove: _state.dismiss);
        route.addLocalHistoryEntry(_historyEntry!);
      }
    }
  }

  bool _updateAnchorRect() {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize || !box.attached) {
      return false;
    }
    final origin = box.localToGlobal(Offset.zero);
    _anchorRect = origin & box.size;
    return true;
  }

  /// Samples anchor geometry after every frame that the application already
  /// produces while a tooltip is mounted.
  ///
  /// A chained post-frame callback does not request autonomous frames, so an
  /// idle persistent tooltip consumes no animation budget. Scroll, resize,
  /// keyboard inset, route transition, and parent layout frames naturally
  /// wake the sample. When the painted rectangle changes, only the root
  /// OverlayEntry is rebuilt; the anchor subtree remains untouched.
  void _scheduleAnchorTracking() {
    if (_anchorTrackingScheduled || _entry == null) return;
    _anchorTrackingScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _anchorTrackingScheduled = false;
      final entry = _entry;
      if (!mounted || entry == null || entry.mounted != true) return;
      final previous = _anchorRect;
      if (!_updateAnchorRect()) {
        // A temporarily or permanently detached anchor cannot provide a safe
        // semantic relationship. Dismiss instead of leaving an orphaned card
        // over unrelated content at the last known screen coordinate.
        _state.dismiss();
        return;
      }
      if (_anchorRect != previous) entry.markNeedsBuild();
      _scheduleAnchorTracking();
    });
  }

  void _removeEntryAfterExit() {
    if (_state.targetVisible) {
      return;
    }
    _removeHistoryEntry();
    final entry = _entry;
    _entry = null;
    if (entry?.mounted == true) {
      entry?.remove();
    }
    _state._setAnimationActive(false);
  }

  void _removeHistoryEntry() {
    final history = _historyEntry;
    _historyEntry = null;
    history?.remove();
  }

  void _showFromUserInput() {
    if (!widget.enabled) {
      return;
    }
    _updateAnchorRect();
    unawaited(_state._showFromUserInput());
  }

  @override
  Widget build(BuildContext context) {
    Widget anchor = MouseRegion(
      onEnter: (_) => _showFromUserInput(),
      onExit: (_) {
        if (!_state.isPersistent) {
          _state.dismiss();
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onLongPress: widget.enabled ? _showFromUserInput : null,
        child: widget.child,
      ),
    );
    anchor = Semantics(
      container: true,
      tooltip: widget.semanticLabel,
      onLongPress: widget.enabled ? _showFromUserInput : null,
      onLongPressHint: widget.enabled ? '显示工具提示' : null,
      child: anchor,
    );
    return anchor;
  }
}

class _MiuixTooltipOverlay extends StatefulWidget {
  const _MiuixTooltipOverlay({
    required this.anchor,
    required this.positioning,
    required this.visible,
    required this.focusable,
    required this.state,
    required this.onExitComplete,
    required this.child,
  });

  final Rect anchor;
  final MiuixTooltipAnchorPosition positioning;
  final bool visible;
  final bool focusable;
  final MiuixTooltipState state;
  final VoidCallback onExitComplete;
  final Widget child;

  @override
  State<_MiuixTooltipOverlay> createState() => _MiuixTooltipOverlayState();
}

class _MiuixTooltipOverlayState extends State<_MiuixTooltipOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _alpha;
  late final AnimationController _scale;
  bool _reduceMotion = false;
  bool _suppressDismissedCallback = false;
  int _exitRevision = 0;

  @override
  void initState() {
    super.initState();
    _alpha = AnimationController(
      vsync: this,
      value: widget.visible ? 0 : 1,
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 150),
    )..addStatusListener(_handleAlphaStatus);
    _scale = AnimationController.unbounded(
      vsync: this,
      value: widget.visible ? .9 : 1,
    );
    _animateTo(widget.visible);
  }

  @override
  void didUpdateWidget(covariant _MiuixTooltipOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visible != widget.visible) {
      _animateTo(widget.visible);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextReduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (nextReduceMotion == _reduceMotion) return;
    _reduceMotion = nextReduceMotion;
    if (_reduceMotion) _animateTo(widget.visible);
  }

  void _animateTo(bool visible) {
    final revision = ++_exitRevision;
    if (_reduceMotion) {
      _alpha.stop(canceled: true);
      _scale.stop(canceled: true);
      _suppressDismissedCallback = true;
      _alpha.value = visible ? 1 : 0;
      _scale.value = visible ? 1 : .9;
      _suppressDismissedCallback = false;
      if (!visible) {
        // Overlay removal mutates the host. Defer it until the current build
        // frame finishes while still skipping every visual transition frame.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || revision != _exitRevision || widget.visible) {
            return;
          }
          widget.onExitComplete();
        });
      }
      return;
    }
    if (visible) {
      _alpha.forward();
      _scale.animateWith(
        SpringSimulation(
          SpringDescription.withDampingRatio(
            mass: 1,
            stiffness: 362.5,
            ratio: .82,
          ),
          _scale.value,
          1,
          _scale.velocity,
          tolerance: const Tolerance(distance: .0001, velocity: .0001),
        ),
      );
    } else {
      _alpha.reverse();
      _scale.animateWith(
        SpringSimulation(
          SpringDescription.withDampingRatio(
            mass: 1,
            stiffness: 1500,
            ratio: 1,
          ),
          _scale.value,
          .9,
          _scale.velocity,
          tolerance: const Tolerance(distance: .0001, velocity: .0001),
        ),
      );
    }
  }

  void _handleAlphaStatus(AnimationStatus status) {
    if (!_suppressDismissedCallback &&
        status == AnimationStatus.dismissed &&
        !widget.visible) {
      widget.onExitComplete();
    }
  }

  @override
  void dispose() {
    _alpha.dispose();
    _scale.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final positioned = CustomSingleChildLayout(
      delegate: _MiuixTooltipPositionDelegate(
        anchor: widget.anchor,
        positioning: widget.positioning,
        textDirection: Directionality.of(context),
      ),
      child: AnimatedBuilder(
        animation: Listenable.merge([_alpha, _scale]),
        child: widget.focusable
            ? GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
                child: widget.child,
              )
            : IgnorePointer(child: widget.child),
        builder: (context, child) => Opacity(
          opacity: _alpha.value.clamp(0.0, 1.0),
          child: Transform.scale(scale: _scale.value, child: child),
        ),
      ),
    );

    Widget result = Stack(
      fit: StackFit.expand,
      children: [
        if (widget.focusable)
          GestureDetector(
            key: const ValueKey('miuix-tooltip-outside-dismiss'),
            behavior: HitTestBehavior.opaque,
            onTap: widget.state.dismiss,
          ),
        positioned,
      ],
    );
    if (!widget.focusable) {
      result = IgnorePointer(child: result);
    }
    return Semantics(
      container: true,
      liveRegion: true,
      label: '工具提示',
      child: result,
    );
  }
}

class _MiuixTooltipPositionDelegate extends SingleChildLayoutDelegate {
  const _MiuixTooltipPositionDelegate({
    required this.anchor,
    required this.positioning,
    required this.textDirection,
  });

  final Rect anchor;
  final MiuixTooltipAnchorPosition positioning;
  final TextDirection textDirection;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.loose(constraints.biggest);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return debugMiuixTooltipPosition(
      anchor: anchor,
      windowSize: size,
      tooltipSize: childSize,
      positioning: positioning,
      textDirection: textDirection,
    );
  }

  @override
  bool shouldRelayout(covariant _MiuixTooltipPositionDelegate oldDelegate) {
    return oldDelegate.anchor != anchor ||
        oldDelegate.positioning != positioning ||
        oldDelegate.textDirection != textDirection;
  }
}

/// Exact current-source tooltip placement, exposed for geometry tests.
@visibleForTesting
Offset debugMiuixTooltipPosition({
  required Rect anchor,
  required Size windowSize,
  required Size tooltipSize,
  required MiuixTooltipAnchorPosition positioning,
  required TextDirection textDirection,
  double spacing = MiuixTooltipDefaults.spacingBetweenTooltipAndAnchor,
}) {
  final resolved = switch (positioning) {
    MiuixTooltipAnchorPosition.start =>
      textDirection == TextDirection.ltr
          ? MiuixTooltipAnchorPosition.left
          : MiuixTooltipAnchorPosition.right,
    MiuixTooltipAnchorPosition.end =>
      textDirection == TextDirection.ltr
          ? MiuixTooltipAnchorPosition.right
          : MiuixTooltipAnchorPosition.left,
    _ => positioning,
  };
  var x = anchor.left + (anchor.width - tooltipSize.width) / 2;
  var y = anchor.top + (anchor.height - tooltipSize.height) / 2;
  switch (resolved) {
    case MiuixTooltipAnchorPosition.below:
      final below = anchor.bottom + spacing;
      final above = anchor.top - tooltipSize.height - spacing;
      y = below + tooltipSize.height <= windowSize.height || above < 0
          ? below
          : above;
    case MiuixTooltipAnchorPosition.above:
      final above = anchor.top - tooltipSize.height - spacing;
      final below = anchor.bottom + spacing;
      y = above >= 0 || below + tooltipSize.height > windowSize.height
          ? above
          : below;
    case MiuixTooltipAnchorPosition.left:
      final left = anchor.left - tooltipSize.width - spacing;
      final right = anchor.right + spacing;
      x = left >= 0 || right + tooltipSize.width > windowSize.width
          ? left
          : right;
    case MiuixTooltipAnchorPosition.right:
      final right = anchor.right + spacing;
      final left = anchor.left - tooltipSize.width - spacing;
      x = right + tooltipSize.width <= windowSize.width || left < 0
          ? right
          : left;
    case MiuixTooltipAnchorPosition.start:
    case MiuixTooltipAnchorPosition.end:
      break;
  }
  return Offset(
    x.clamp(0.0, math.max(0.0, windowSize.width - tooltipSize.width)),
    y.clamp(0.0, math.max(0.0, windowSize.height - tooltipSize.height)),
  );
}

class _MiuixTooltipSurface extends StatelessWidget {
  const _MiuixTooltipSurface({
    required this.anchor,
    required this.positioning,
    required this.maxWidth,
    required this.cornerRadius,
    required this.containerColor,
    required this.insideMargin,
    required this.showCaret,
    required this.glass,
    required this.glassBlur,
    required this.glassOpacity,
    required this.child,
  });

  final Rect anchor;
  final MiuixTooltipAnchorPosition positioning;
  final double maxWidth;
  final double cornerRadius;
  final Color containerColor;
  final EdgeInsets insideMargin;
  final bool showCaret;
  final bool glass;
  final double glassBlur;
  final double glassOpacity;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = MiuixTheme.of(context);
    final verticalCaret =
        showCaret &&
        (positioning == MiuixTooltipAnchorPosition.above ||
            positioning == MiuixTooltipAnchorPosition.below);
    final caretOnTop = positioning == MiuixTooltipAnchorPosition.below;
    final radius = BorderRadius.circular(cornerRadius);
    final ShapeBorder glassShape = theme.enableSquircle
        ? MiuixSquircleBorder(borderRadius: radius)
        : RoundedRectangleBorder(borderRadius: radius);
    final ShapeBorder shadowShape = glass
        ? glassShape
        : RoundedRectangleBorder(borderRadius: radius);
    final Widget fill = glass
        ? MiuixGlass(
            key: const ValueKey('miuix-tooltip-fill'),
            blur: glassBlur,
            opacity: glassOpacity,
            color: containerColor,
            optics: MiuixGlassOptics.transient,
            radius: cornerRadius,
            padding: insideMargin,
            showSpecular: true,
            child: child,
          )
        : MiuixSquircleBackground(
            key: const ValueKey('miuix-tooltip-fill'),
            color: containerColor,
            borderRadius: radius,
            enabled: theme.enableSquircle,
            child: Padding(padding: insideMargin, child: child),
          );
    return ConstrainedBox(
      key: const ValueKey('miuix-tooltip-surface'),
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: _MiuixTooltipCaretHost(
        anchor: anchor,
        cornerRadius: cornerRadius,
        color: containerColor,
        drawCaret: verticalCaret,
        caretOnTop: caretOnTop,
        child: Padding(
          padding: EdgeInsets.only(
            top: verticalCaret && caretOnTop
                ? MiuixTooltipDefaults.caretSize.height
                : 0,
            bottom: verticalCaret && !caretOnTop
                ? MiuixTooltipDefaults.caretSize.height
                : 0,
          ),
          child: DecoratedBox(
            key: const ValueKey('miuix-tooltip-shadow'),
            decoration: ShapeDecoration(
              // HyperOS glass requires the shadow to follow the same G2 path
              // as its clipped material so no rectangular-looking corner halo
              // survives. The explicit source path keeps Tooltip.kt's separate
              // RoundedCornerShape shadow and squircleBackground fill.
              shape: shadowShape,
              shadows: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: fill,
          ),
        ),
      ),
    );
  }
}

class _MiuixTooltipCaretHost extends StatefulWidget {
  const _MiuixTooltipCaretHost({
    required this.anchor,
    required this.cornerRadius,
    required this.color,
    required this.drawCaret,
    required this.caretOnTop,
    required this.child,
  });

  final Rect anchor;
  final double cornerRadius;
  final Color color;
  final bool drawCaret;
  final bool caretOnTop;
  final Widget child;

  @override
  State<_MiuixTooltipCaretHost> createState() => _MiuixTooltipCaretHostState();
}

class _MiuixTooltipCaretHostState extends State<_MiuixTooltipCaretHost> {
  final GlobalKey _paintKey = GlobalKey();
  double? _caretCenterX;

  @override
  void initState() {
    super.initState();
    _scheduleMeasure();
  }

  @override
  void didUpdateWidget(covariant _MiuixTooltipCaretHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.anchor != widget.anchor ||
        oldWidget.drawCaret != widget.drawCaret) {
      _scheduleMeasure();
    }
  }

  void _scheduleMeasure() {
    if (!widget.drawCaret) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final box = _paintKey.currentContext?.findRenderObject();
      if (box is! RenderBox || !box.hasSize) {
        return;
      }
      final left = box.localToGlobal(Offset.zero).dx;
      final center = widget.anchor.center.dx - left;
      if (_caretCenterX != center) {
        setState(() => _caretCenterX = center);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      key: _paintKey,
      painter: _MiuixTooltipCaretPainter(
        color: widget.color,
        cornerRadius: widget.cornerRadius,
        centerX: _caretCenterX,
        onTop: widget.caretOnTop,
        enabled: widget.drawCaret,
      ),
      child: widget.child,
    );
  }
}

class _MiuixTooltipCaretPainter extends CustomPainter {
  const _MiuixTooltipCaretPainter({
    required this.color,
    required this.cornerRadius,
    required this.centerX,
    required this.onTop,
    required this.enabled,
  });

  final Color color;
  final double cornerRadius;
  final double? centerX;
  final bool onTop;
  final bool enabled;

  @override
  void paint(Canvas canvas, Size size) {
    if (!enabled) {
      return;
    }
    final half = MiuixTooltipDefaults.caretSize.width / 2;
    final height = MiuixTooltipDefaults.caretSize.height;
    final minimum = cornerRadius + half;
    final maximum = math.max(minimum, size.width - cornerRadius - half);
    final x = (centerX ?? size.width / 2).clamp(minimum, maximum);
    final path = Path();
    if (onTop) {
      path
        ..moveTo(x, 0)
        ..lineTo(x - half, height)
        ..lineTo(x + half, height);
    } else {
      path
        ..moveTo(x, size.height)
        ..lineTo(x - half, size.height - height)
        ..lineTo(x + half, size.height - height);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _MiuixTooltipCaretPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.cornerRadius != cornerRadius ||
        oldDelegate.centerX != centerX ||
        oldDelegate.onTop != onTop ||
        oldDelegate.enabled != enabled;
  }
}
