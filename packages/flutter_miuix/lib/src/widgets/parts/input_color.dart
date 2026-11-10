part of '../miuix_widgets.dart';

/// Text field with Miuix rounded filled decoration.
// Source parity notes for TextField.kt and TextFieldDefaults:
// - The default surface role is secondaryContainer in every interaction state.
// - The default corner radius is exactly 16dp.
// - The default content inset is 16dp horizontally and vertically.
// - The idle outline width is zero, not a faint Material outline.
// - The focused outline width is exactly 2dp.
// - The focused outline and cursor use the primary semantic role.
// - Normal labels use 17sp Medium text.
// - Floating labels use 10sp Medium text.
// - Floating labels translate upward by half the vertical inset, or 8dp.
// - Entered text translates downward by the matching 8dp.
// - Focus alone does not float an empty label.
// - Text content is the state that triggers the ordinary floating label.
// - useLabelAsPlaceholder changes the entered state to hidden-placeholder mode.
// - Placeholder mode removes the label instead of leaving a floating caption.
// - The field retains one line when singleLine or obscureText is selected.
// - Invalid line limits are normalized without changing these visual metrics.
// The Flutter implementation therefore avoids InputDecoration defaults entirely.
/// Compose's default spring used by TextField `animate*AsState` calls.
@visibleForTesting
SpringDescription debugMiuixTextFieldSpring() =>
    SpringDescription.withDampingRatio(mass: 1, stiffness: 1500, ratio: 1);

class MiuixTextField extends StatefulWidget {
  /// Creates a text field.
  const MiuixTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.insideMargin = MiuixTextFieldDefaults.insideMargin,
    this.colors,
    this.backgroundColor,
    double? cornerRadius,
    this.labelColor,
    this.borderColor,
    this.leadingIcon,
    this.trailingIcon,
    this.prefixIcon,
    this.prefixIconSpacing = 12,
    this.suffixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.singleLine = false,
    this.useLabelAsPlaceholder = false,
    this.minLines = 1,
    this.maxLines,
    this.textStyle,
    this.keyboardType,
    this.autofillHints,
    this.textInputAction,
    this.cursorColor,
    this.focusNode,
    this.scrollController,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.onTextLayout,
  }) : _cornerRadius = cornerRadius;

  /// Creates the source `TextField` parameter form.
  ///
  /// A [TextEditingController] preserves text, selection, and composing state,
  /// covering both upstream value-based overloads and its state-based overload.
  factory MiuixTextField.source({
    Key? key,
    required TextEditingController controller,
    EdgeInsetsGeometry insideMargin = MiuixTextFieldDefaults.insideMargin,
    MiuixTextFieldColors? colors,
    Color? backgroundColor,
    double cornerRadius = MiuixTextFieldDefaults.legacyCornerRadius,
    String label = '',
    Color? labelColor,
    Color? borderColor,
    bool useLabelAsPlaceholder = false,
    bool enabled = true,
    bool readOnly = false,
    List<TextInputFormatter>? inputTransformation,
    TextStyle? textStyle,
    TextInputType? keyboardType,
    Iterable<String>? autofillHints,
    TextInputAction? keyboardOptions,
    ValueChanged<String>? onKeyboardAction,
    bool singleLine = false,
    int minLines = 1,
    int? maxLines,
    Widget? leadingIcon,
    Widget? trailingIcon,
    ValueChanged<MiuixTextFieldLayoutResult>? onTextLayout,
    FocusNode? interactionSource,
    Color? cursorColor,
    ScrollController? scrollState,
    ValueChanged<String>? onValueChange,
  }) {
    return MiuixTextField(
      key: key,
      controller: controller,
      label: label,
      insideMargin: insideMargin,
      colors: colors,
      backgroundColor: backgroundColor,
      cornerRadius: cornerRadius,
      labelColor: labelColor,
      borderColor: borderColor,
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon,
      enabled: enabled,
      readOnly: readOnly,
      singleLine: singleLine,
      useLabelAsPlaceholder: useLabelAsPlaceholder,
      minLines: minLines,
      maxLines: singleLine ? 1 : maxLines,
      textStyle: textStyle,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      textInputAction: keyboardOptions,
      cursorColor: cursorColor,
      focusNode: interactionSource,
      scrollController: scrollState,
      inputFormatters: inputTransformation,
      onChanged: onValueChange,
      onSubmitted: onKeyboardAction,
      onTextLayout: onTextLayout,
    );
  }

  /// Text controller.
  final TextEditingController? controller;

  /// Optional label.
  final String? label;

  /// Optional hint.
  final String? hint;

  /// Source content inset, normally 16dp on every edge.
  final EdgeInsetsGeometry insideMargin;

  /// Optional complete source palette.
  ///
  /// Individual color arguments remain compatibility overrides and take
  /// precedence over the corresponding channel in this value.
  final MiuixTextFieldColors? colors;

  /// Optional filled surface color.
  final Color? backgroundColor;

  /// Source shape radius.
  double get cornerRadius =>
      _cornerRadius ?? MiuixTextFieldDefaults.cornerRadius;
  final double? _cornerRadius;

  /// Optional inline and floating label color.
  final Color? labelColor;

  /// Optional focused outline color.
  final Color? borderColor;

  /// Source leading content slot, placed without invented padding or tint.
  final Widget? leadingIcon;

  /// Source trailing content slot, placed without invented padding or tint.
  final Widget? trailingIcon;

  /// Optional leading icon.
  ///
  /// This compatibility slot retains the package's earlier 12dp separation.
  /// Prefer [leadingIcon] when translating upstream MIUIX code literally.
  final Widget? prefixIcon;

  /// Horizontal space between the optional leading content and editable text.
  ///
  /// MIUIX callers may set this to zero when the leading content is a textual
  /// prefix such as `HEX: #`; ordinary icon affordances retain the compatible
  /// 12dp separation by default.
  final double prefixIconSpacing;

  /// Optional trailing icon.
  ///
  /// This compatibility slot retains the package's earlier 12dp separation.
  /// Prefer [trailingIcon] when translating upstream MIUIX code literally.
  final Widget? suffixIcon;

  /// Whether the field accepts focus and input.
  final bool enabled;

  /// Whether selection is allowed without editing.
  final bool readOnly;

  /// Whether to hide typed text.
  final bool obscureText;

  /// Platform autofill semantics; null preserves the default opt-out behavior.
  final Iterable<String>? autofillHints;

  /// Whether the field is constrained to a single text line.
  final bool singleLine;

  /// Hides a label after text is entered instead of floating it above text.
  final bool useLabelAsPlaceholder;

  /// Minimum visible text lines for multiline fields.
  final int minLines;

  /// Maximum visible text lines for multiline fields; null lets the field grow.
  final int? maxLines;

  /// Optional editable-text style.
  final TextStyle? textStyle;

  /// Optional platform keyboard type.
  final TextInputType? keyboardType;

  /// Optional IME action such as [TextInputAction.done].
  final TextInputAction? textInputAction;

  /// Optional cursor color.
  final Color? cursorColor;

  /// Optional externally owned focus state.
  ///
  /// This is the Flutter counterpart of the source interaction source for
  /// focus observation. The caller retains ownership.
  final FocusNode? focusNode;

  /// Optional externally owned internal text scroll state.
  final ScrollController? scrollController;

  /// Input transformations applied before controller state changes.
  final List<TextInputFormatter>? inputFormatters;

  /// Change callback.
  final ValueChanged<String>? onChanged;

  /// Submit callback.
  final ValueChanged<String>? onSubmitted;

  /// Reports immutable text-layout snapshots when paragraph geometry changes.
  final ValueChanged<MiuixTextFieldLayoutResult>? onTextLayout;

  @override
  State<MiuixTextField> createState() => _MiuixTextFieldState();
}

class _MiuixTextFieldState extends State<MiuixTextField>
    with TickerProviderStateMixin
    implements TextSelectionGestureDetectorBuilderDelegate {
  // Animation parity notes for the state holder:
  // - Compose owns independent animate-as-state channels for each target value.
  // - Flutter therefore keeps focus and label motion in separate controllers.
  // - Focus motion drives both the outline thickness and its semantic color.
  // - Label motion drives the caption size and the paired vertical offsets.
  // - An unbounded controller allows a physical spring to overshoot naturally.
  // - The source default spring is critically damped, so overshoot is uncommon.
  // - Keeping the controller unbounded still preserves source interruption math.
  // - A merged listenable coalesces both channels into one visual rebuild path.
  // - The controller listener remains responsible for text-state transitions.
  // - The focus-node listener remains responsible for focus-state transitions.
  // - Empty labels stay absent instead of occupying a hidden caption position.
  // - Focus alone changes the outline but does not promote an empty text label.
  // - Entered text promotes the label unless placeholder-label mode is enabled.
  // - Placeholder-label mode hides the label after the user enters text.
  // - External controllers are observed without transferring their ownership.
  // - Internal controllers are disposed together with the field state.
  // - Replacing an external controller detaches the old listener first.
  // - Widget updates immediately reconcile both animation target values.
  // - Exact endpoint snapping happens only after the active spring completes.
  // - These rules match independent Compose animateDp/ColorAsState behavior.
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late final AnimationController _focusAnimation;
  late final AnimationController _labelAnimation;
  late final Listenable _visualMotion;
  bool _ownsController = false;
  bool _ownsFocusNode = false;
  double _focusTarget = 0;
  double _labelTarget = 0;
  bool _reduceMotion = false;
  // 系统返回可隐藏键盘而保留 FocusNode，下一次点击必须重新请求输入连接。
  // key 稳定绑定原 EditableText，不替换 controller、选区或输入法组合状态。
  final _editableKey = GlobalKey<EditableTextState>();
  late final TextSelectionGestureDetectorBuilder _selectionGestures;

  @override
  GlobalKey<EditableTextState> get editableTextKey => _editableKey;

  // 与框架标准输入框一致，压力手势仅在 iOS 开启。
  // 选择、长按和单击共用一套识别器，不能让父子 Tap 竞争漏掉再次唤起。
  @override
  bool get forcePressEnabled => defaultTargetPlatform == TargetPlatform.iOS;

  // 只读仍可选择文字；具体策略继续由原 EditableText 决定。
  // 构建首帧尚未绑定 key 时只保留 enabled 约束，不缓存一个过期策略。
  @override
  bool get selectionEnabled =>
      widget.enabled &&
      (_editableKey.currentState?.widget.selectionEnabled ?? true);

  // 选择手势不自动提供辅助功能动作，读屏激活仍须接回同一个编辑状态。
  // 只读允许获得选择焦点，禁用不得接纳焦点；两者都不能请求可编辑键盘。
  void _activateAccessibleInput() {
    if (!widget.enabled) return;
    if (!_focusNode.hasFocus) _focusNode.requestFocus();
    if (widget.readOnly) return;
    // 第一次辅助功能激活可能没有光标，按标准输入框将光标放在草稿末尾。
    // 已有合法选区保持原样，不改写文本或输入法组合内容。
    if (!_controller.selection.isValid) {
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    }
    _editableKey.currentState?.requestKeyboard();
  }

  MiuixTextFieldLayoutResult? _lastLayoutResult;
  MiuixTextFieldLayoutResult? _pendingLayoutResult;
  bool _layoutReportScheduled = false;

  @override
  void initState() {
    super.initState();
    _selectionGestures = TextSelectionGestureDetectorBuilder(delegate: this);
    _syncController();
    _syncFocusNode();
    _focusTarget = 0;
    _labelTarget = _resolvedLabelTarget;
    _focusAnimation = AnimationController.unbounded(
      vsync: this,
      value: _focusTarget,
    );
    _labelAnimation = AnimationController.unbounded(
      vsync: this,
      value: _labelTarget,
    );
    _visualMotion = Listenable.merge([_focusAnimation, _labelAnimation])
      ..addListener(_handleAnimationTick);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion == _reduceMotion) return;
    _reduceMotion = reduceMotion;
    if (!_reduceMotion) return;

    // Focus and label state stay fully observable, but their autonomous
    // critically damped springs settle at the current logical destinations.
    _focusAnimation
      ..stop()
      ..value = _focusTarget;
    _labelAnimation
      ..stop()
      ..value = _labelTarget;
  }

  @override
  void didUpdateWidget(covariant MiuixTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (_ownsController) {
        _controller.dispose();
      } else {
        _controller.removeListener(_handleStateChanged);
      }
      _syncController();
    }
    if (oldWidget.focusNode != widget.focusNode) {
      _detachFocusNode();
      _syncFocusNode();
    }
    if (oldWidget.enabled != widget.enabled) {
      if (_ownsFocusNode) {
        _focusNode.canRequestFocus = widget.enabled;
      }
      if (!widget.enabled && _focusNode.hasFocus) {
        _focusNode.unfocus();
      }
    }
    if (oldWidget.onTextLayout != widget.onTextLayout) {
      _lastLayoutResult = null;
    }
    _syncVisualAnimations();
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    } else {
      _controller.removeListener(_handleStateChanged);
    }
    _detachFocusNode();
    _visualMotion.removeListener(_handleAnimationTick);
    _focusAnimation.dispose();
    _labelAnimation.dispose();
    super.dispose();
  }

  void _syncController() {
    final external = widget.controller;
    _ownsController = external == null;
    _controller = external ?? TextEditingController();
    _controller.addListener(_handleStateChanged);
  }

  void _syncFocusNode() {
    final external = widget.focusNode;
    _ownsFocusNode = external == null;
    _focusNode = external ?? FocusNode(canRequestFocus: widget.enabled);
    _focusNode.addListener(_handleStateChanged);
  }

  void _detachFocusNode() {
    _focusNode.removeListener(_handleStateChanged);
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
  }

  void _handleStateChanged() {
    if (mounted) {
      _syncVisualAnimations();
      setState(() {});
    }
  }

  void _handleAnimationTick() {
    if (mounted) setState(() {});
  }

  void _reportTextLayout(MiuixTextFieldLayoutResult result) {
    if (result == _lastLayoutResult && !_layoutReportScheduled) return;
    _pendingLayoutResult = result;
    if (_layoutReportScheduled) return;
    _layoutReportScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _layoutReportScheduled = false;
      if (!mounted) return;
      final pending = _pendingLayoutResult;
      _pendingLayoutResult = null;
      if (pending == null || pending == _lastLayoutResult) return;
      _lastLayoutResult = pending;
      widget.onTextLayout?.call(pending);
    });
  }

  double get _resolvedLabelTarget {
    final hasLabel = widget.label?.isNotEmpty ?? false;
    return hasLabel &&
            _controller.text.isNotEmpty &&
            !widget.useLabelAsPlaceholder
        ? 1
        : 0;
  }

  void _springTo(AnimationController controller, double target) {
    // Interruption parity notes for the spring handoff:
    // - Compose retargets an in-flight animation from its current sampled value.
    // - It also carries the sampled velocity into the replacement spring.
    // - Starting from controller.value reproduces the sampled-value handoff.
    // - Starting with controller.velocity reproduces the velocity handoff.
    // - Using one spring description keeps dp and color channels synchronized.
    // - The 1500 stiffness is Compose Spring.StiffnessMedium's exact default.
    // - The 1.0 damping ratio is Compose DampingRatioNoBouncy's exact default.
    // - Unit mass matches Flutter's normalized SpringDescription convention.
    // - A small tolerance prevents an invisible spring tail from ticking forever.
    // - Tolerance does not choose the final value; the target snap below does.
    // - Completion callbacks can outlive the simulation that registered them.
    // - controller.isAnimating rejects a callback from an interrupted spring.
    // - The stored target rejects a callback whose destination became stale.
    // - Controller identity selects the corresponding authoritative target.
    // - Focus and label targets can change independently in the same frame.
    // - A reversed focus spring therefore retains its outgoing momentum.
    // - Rapid typing likewise retargets label motion without a discontinuity.
    // - Endpoint snapping avoids subpixel border residue after spring settling.
    // - Mounted checks prevent a late completion from touching disposed state.
    // - This replaces the previous fixed-duration ease-out approximation.
    if (_reduceMotion) {
      controller
        ..stop()
        ..value = target;
      return;
    }
    controller
        .animateWith(
          SpringSimulation(
            debugMiuixTextFieldSpring(),
            controller.value,
            target,
            controller.velocity,
            tolerance: const Tolerance(distance: .01, velocity: .01),
          ),
        )
        .whenCompleteOrCancel(() {
          if (!mounted || controller.isAnimating) return;
          final currentTarget = identical(controller, _focusAnimation)
              ? _focusTarget
              : _labelTarget;
          if (currentTarget == target) controller.value = target;
        });
  }

  void _syncVisualAnimations() {
    final nextFocusTarget = _focusNode.hasFocus ? 1.0 : 0.0;
    final nextLabelTarget = _resolvedLabelTarget;
    if (_focusTarget != nextFocusTarget) {
      _focusTarget = nextFocusTarget;
      _springTo(_focusAnimation, nextFocusTarget);
    }
    if (_labelTarget != nextLabelTarget) {
      _labelTarget = nextLabelTarget;
      _springTo(_labelAnimation, nextLabelTarget);
    }
  }

  void _handleChanged(String value) {
    widget.onChanged?.call(value);
    _handleStateChanged();
  }

  int get _safeMinLines {
    final min = widget.minLines <= 0 ? 1 : widget.minLines;
    if (widget.singleLine || widget.obscureText) {
      return 1;
    }
    final max = widget.maxLines;
    if (max != null && max > 0 && min > max) {
      return max;
    }
    return min;
  }

  int? get _safeMaxLines {
    if (widget.singleLine || widget.obscureText) {
      return 1;
    }
    final min = widget.minLines <= 0 ? 1 : widget.minLines;
    final max = widget.maxLines;
    if (max == null) {
      return null;
    }
    if (max <= 0) {
      return min;
    }
    return math.max(min, max);
  }

  @override
  Widget build(BuildContext context) {
    final materialTheme = Theme.of(context);
    final semantic = MiuixSemanticColors.of(context);
    final miuixTheme = MiuixTheme.of(context);
    final hasText = _controller.text.isNotEmpty;
    final focused = _focusNode.hasFocus;
    final hasLabel = widget.label?.isNotEmpty ?? false;
    final focusProgress = _focusAnimation.value.clamp(0.0, 1.0);
    final labelProgress = _labelAnimation.value.clamp(0.0, 1.0);
    final hidesEnteredPlaceholder = widget.useLabelAsPlaceholder && hasText;
    final floatingLabel = hasLabel && hasText && !widget.useLabelAsPlaceholder;
    final showsInlineLabel =
        hasLabel && !floatingLabel && !hidesEnteredPlaceholder;
    final sourceMainStyle =
        materialTheme.textTheme.bodyLarge ??
        const TextStyle(fontSize: 17, fontWeight: FontWeight.w400);
    final textStyle = widget.textStyle == null
        ? sourceMainStyle
        : sourceMainStyle.merge(widget.textStyle);
    final localContentColor =
        _MiuixContentColor.maybeOf(context) ??
        DefaultTextStyle.of(context).style.color ??
        semantic['onSurface'];
    final resolvedTextColor = widget.textStyle?.color ?? localContentColor;
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final scaledFontSize = MediaQuery.textScalerOf(
      context,
    ).scale(textStyle.fontSize ?? 17);
    final sourceLineHeight = _miuixCeilLogicalDimension(
      scaledFontSize * (textStyle.height ?? 1.16),
      pixelRatio,
    );
    final sourceHeightRatio = sourceLineHeight / scaledFontSize;
    final sourceTextStyle = textStyle.copyWith(height: sourceHeightRatio);
    final sourceStrutStyle = StrutStyle(
      fontSize: textStyle.fontSize ?? 17,
      height: sourceHeightRatio,
      forceStrutHeight: true,
    );
    final minLines = _safeMinLines;
    final maxLines = _safeMaxLines;
    final defaultColors = MiuixTextFieldDefaults.colors(context);
    final backgroundColor =
        widget.backgroundColor ??
        widget.colors?.backgroundColor ??
        defaultColors.backgroundColor;
    final borderColor =
        widget.borderColor ??
        widget.colors?.borderColor ??
        defaultColors.borderColor;
    final labelColor =
        widget.labelColor ??
        widget.colors?.labelColor ??
        defaultColors.labelColor;
    final cursorColor = widget.cursorColor ?? borderColor;
    final borderRadius = BorderRadius.circular(
      math.max(
        0,
        _finiteOr(
          widget._cornerRadius ??
              MiuixTheme.of(context).hyperOs4.textFieldCornerRadius,
          MiuixTextFieldDefaults.cornerRadius,
        ),
      ),
    );
    final side = BorderSide(
      color: Color.lerp(backgroundColor, borderColor, focusProgress)!,
      width: 2 * focusProgress,
    );
    final ShapeBorder shape = miuixTheme.enableSquircle
        ? MiuixSquircleBorder(borderRadius: borderRadius, side: side)
        : RoundedRectangleBorder(borderRadius: borderRadius, side: side);
    final insideMargin = _miuixRoundedInsets(context, widget.insideMargin);
    final sourceLeading = widget.leadingIcon;
    final sourceTrailing = widget.trailingIcon;
    // Source slots form one geometry family. If either is supplied, suppress
    // both compatibility aliases so mixed dynamic configuration cannot paint
    // two leading/trailing systems in release while debug rejects the build.
    final usesSourceSlots = sourceLeading != null || sourceTrailing != null;
    final safePrefixSpacing = widget.prefixIconSpacing.isFinite
        ? math.max(0.0, widget.prefixIconSpacing)
        : 12.0;
    final direction = Directionality.of(context);
    final sourceContentPadding = EdgeInsets.fromLTRB(
      direction == TextDirection.ltr
          ? (sourceLeading == null ? insideMargin.left : 0)
          : (sourceTrailing == null ? insideMargin.left : 0),
      insideMargin.top,
      direction == TextDirection.ltr
          ? (sourceTrailing == null ? insideMargin.right : 0)
          : (sourceLeading == null ? insideMargin.right : 0),
      insideMargin.bottom,
    );
    final field = _selectionGestures.buildGestureDetector(
      behavior: HitTestBehavior.opaque,
      child: _MiuixTextFieldBackground(
        key: const ValueKey('miuix-text-field-surface'),
        color: backgroundColor,
        borderRadius: borderRadius,
        shape: shape,
        enableSquircle: miuixTheme.enableSquircle,
        child: Padding(
          // Compose resolves the Text placeable and all four padding edges
          // independently. A forced strut keeps every wrapped line on that
          // source grid instead of fixing the whole field to one line.
          padding: usesSourceSlots ? EdgeInsets.zero : insideMargin,
          child: Row(
            children: [
              ?sourceLeading,
              if (!usesSourceSlots && widget.prefixIcon != null) ...[
                IconTheme(
                  data: IconThemeData(
                    color: focused
                        ? borderColor
                        : semantic['onSecondaryContainer'],
                    size: 22,
                  ),
                  child: widget.prefixIcon!,
                ),
                SizedBox(width: safePrefixSpacing),
              ],
              Expanded(
                child: Padding(
                  key: const ValueKey('miuix-text-field-content-padding'),
                  padding: usesSourceSlots
                      ? sourceContentPadding
                      : EdgeInsets.zero,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Count wrapped lines with the final content width, then
                      // give every line the exact independently rounded source
                      // height. EditableText otherwise rounds its preferred line
                      // to 20 logical pixels before the inset edges are added.
                      final painter = TextPainter(
                        text: TextSpan(
                          text: _controller.text.isEmpty
                              ? ' '
                              : _controller.text,
                          style: sourceTextStyle,
                        ),
                        textDirection: Directionality.of(context),
                        textScaler: MediaQuery.textScalerOf(context),
                        maxLines: maxLines,
                      )..layout(maxWidth: constraints.maxWidth);
                      var lineCount = math.max(
                        minLines,
                        painter.computeLineMetrics().length,
                      );
                      if (maxLines != null) {
                        lineCount = math.min(lineCount, maxLines);
                      }
                      final layoutResult = MiuixTextFieldLayoutResult(
                        size: painter.size,
                        lineCount: lineCount,
                        didExceedMaxLines: painter.didExceedMaxLines,
                        text: _controller.text,
                      );
                      painter.dispose();
                      _reportTextLayout(layoutResult);
                      // 按最终可用宽度与系统字号测量装饰文字；不能靠单行省略隐藏操作条件。
                      // 普通短标签仍采用原单行尺寸和弹簧，只为实际放不下的内容增加空间。
                      final animatedLabelStyle = sourceTextStyle.copyWith(
                        color: labelColor,
                        fontSize: ui.lerpDouble(17, 10, labelProgress),
                        fontWeight: FontWeight.w500,
                      );
                      final paintsLabel = showsInlineLabel || floatingLabel;
                      final paintsHint =
                          !hasText &&
                          widget.label == null &&
                          widget.hint != null;
                      final decorationText = paintsLabel
                          ? widget.label
                          : paintsHint
                          ? widget.hint
                          : null;
                      // 标签与提示沿用各自原有字体；测量器与实际 Text 使用相同缩放和方向。
                      // 提示保留正文 strut，标签则和原 Text 一样不强制正文行高。
                      final decorationStyle = paintsLabel
                          ? animatedLabelStyle
                          : sourceTextStyle;
                      double decorationHeight = 0;
                      var wrapsDecoration = false;
                      double finalLabelHeight = 0;
                      if (decorationText != null) {
                        final decorationPainter = TextPainter(
                          text: TextSpan(
                            text: decorationText,
                            style: decorationStyle,
                          ),
                          textDirection: direction,
                          textScaler: MediaQuery.textScalerOf(context),
                          strutStyle: paintsHint ? sourceStrutStyle : null,
                        )..layout(maxWidth: constraints.maxWidth);
                        decorationHeight = decorationPainter.height;
                        wrapsDecoration =
                            decorationPainter.computeLineMetrics().length > 1;
                        decorationPainter.dispose();
                        // 即使只有一行，大字号浮动标签也可能超过原上下各半内距形成的带宽。
                        // 用最终浮动字号判断适配需求，避免改变一倍字号短标签的正常动画几何。
                        if (floatingLabel) {
                          final finalPainter = TextPainter(
                            text: TextSpan(
                              text: decorationText,
                              style: animatedLabelStyle.copyWith(fontSize: 10),
                            ),
                            textDirection: direction,
                            textScaler: MediaQuery.textScalerOf(context),
                          )..layout(maxWidth: constraints.maxWidth);
                          finalLabelHeight = finalPainter.height;
                          finalPainter.dispose();
                        }
                      }
                      final needsReadableBand =
                          wrapsDecoration ||
                          (floatingLabel &&
                              finalLabelHeight + 4 > insideMargin.top);
                      // 额外四像素是可读布局的项目间距，不宣称来自原版官方尺寸。
                      // 浮动标签与输入之间留开距离，空提示则只扩展整体可读高度。
                      final decorationExtra = !needsReadableBand
                          ? 0.0
                          : floatingLabel
                          ? math.max(
                              0.0,
                              decorationHeight +
                                  4 -
                                  insideMargin.top * labelProgress,
                            )
                          : math.max(
                              0.0,
                              decorationHeight - sourceLineHeight * lineCount,
                            );
                      return SizedBox(
                        height: sourceLineHeight * lineCount + decorationExtra,
                        child: Stack(
                          alignment: AlignmentDirectional.topStart,
                          clipBehavior: Clip.none,
                          children: [
                            if (showsInlineLabel || floatingLabel)
                              DefaultTextStyle(
                                // The normal and floating labels share one spring
                                // channel, exactly as TextField.kt does.
                                style: animatedLabelStyle,
                                child: Transform.translate(
                                  offset: Offset(
                                    0,
                                    -insideMargin.top / 2 * labelProgress,
                                  ),
                                  child: Text(
                                    widget.label ?? '',
                                    // 只有实测需要多行才放开装饰文本，输入自身的行数约束不变。
                                    maxLines: wrapsDecoration ? null : 1,
                                    overflow: wrapsDecoration
                                        ? TextOverflow.visible
                                        : TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            if (!hasText &&
                                widget.label == null &&
                                widget.hint != null)
                              IgnorePointer(
                                child: Text(
                                  widget.hint!,
                                  maxLines: wrapsDecoration ? null : 1,
                                  overflow: wrapsDecoration
                                      ? TextOverflow.visible
                                      : TextOverflow.ellipsis,
                                  style: sourceTextStyle.copyWith(
                                    color:
                                        semantic['onSecondaryContainerVariant'],
                                  ),
                                  strutStyle: sourceStrutStyle,
                                ),
                              ),
                            Transform.translate(
                              offset: Offset(
                                0,
                                insideMargin.top / 2 * labelProgress +
                                    (floatingLabel ? decorationExtra : 0),
                              ),
                              // 仅平移同一个编辑器，焦点、选区、密码语义与回调不复制。
                              // 动作绑定在编辑器附近，和密码标记、值及选区共用语义节点。
                              // 装饰层不新增一个可点击的假输入框，读屏无需重复聚焦两次。
                              child: Semantics(
                                onTap: widget.enabled && !widget.readOnly
                                    ? _activateAccessibleInput
                                    : null,
                                onFocus: widget.enabled
                                    ? _activateAccessibleInput
                                    : null,
                                child: EditableText(
                                  key: _editableKey,
                                  // 选择识别器统一负责点击与长按，避免两个识别器互相抢占。
                                  // 框架在每次有效点击结束时都会请求键盘，已有焦点也能重新弹出。
                                  rendererIgnoresPointer: true,
                                  controller: _controller,
                                  focusNode: _focusNode,
                                  style: sourceTextStyle.copyWith(
                                    color: resolvedTextColor,
                                  ),
                                  strutStyle: sourceStrutStyle,
                                  cursorColor: cursorColor,
                                  backgroundCursorColor: semantic['onSurface'],
                                  readOnly: widget.readOnly,
                                  obscureText: widget.obscureText,
                                  autofillHints: widget.autofillHints,
                                  onChanged: _handleChanged,
                                  onSubmitted: widget.onSubmitted,
                                  minLines: minLines,
                                  maxLines: maxLines,
                                  keyboardType:
                                      widget.keyboardType ??
                                      (maxLines == 1
                                          ? TextInputType.text
                                          : TextInputType.multiline),
                                  textInputAction: widget.textInputAction,
                                  inputFormatters: widget.inputFormatters,
                                  scrollController: widget.scrollController,
                                  selectionColor: borderColor.withValues(
                                    alpha: .24,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (!usesSourceSlots && widget.suffixIcon != null) ...[
                const SizedBox(width: 12),
                IconTheme(
                  data: IconThemeData(
                    color: focused
                        ? borderColor
                        : semantic['onSecondaryContainer'],
                    size: 22,
                  ),
                  child: widget.suffixIcon!,
                ),
              ],
              ?sourceTrailing,
            ],
          ),
        ),
      ),
    );
    return Semantics(
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      textField: true,
      child: IgnorePointer(ignoring: !widget.enabled, child: field),
    );
  }
}

/// Keeps TextField's dynamic focus outline above its non-clipping SDF fill.
class _MiuixTextFieldBackground extends StatelessWidget {
  const _MiuixTextFieldBackground({
    super.key,
    required this.color,
    required this.borderRadius,
    required this.shape,
    required this.enableSquircle,
    required this.child,
  });

  final Color color;
  final BorderRadius borderRadius;
  final ShapeBorder shape;
  final bool enableSquircle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!enableSquircle) {
      return DecoratedBox(
        decoration: ShapeDecoration(color: color, shape: shape),
        child: child,
      );
    }
    return DecoratedBox(
      decoration: ShapeDecoration(shape: shape),
      child: MiuixSquircleBackground(
        color: color,
        borderRadius: borderRadius,
        child: child,
      ),
    );
  }
}

/// Exposes the MIUIX text-field label state rule for regression tests.
@visibleForTesting
bool debugMiuixTextFieldLabelFloats({
  required String? label,
  required bool hasText,
}) {
  return label != null && label.isNotEmpty && hasText;
}
