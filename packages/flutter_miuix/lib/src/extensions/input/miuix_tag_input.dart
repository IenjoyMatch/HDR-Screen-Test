import 'dart:collection';

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../platform/miuix_haptics.dart';
import '../../theme/miuix_semantic_colors.dart';
import '../../theme/miuix_theme.dart';
import '../../widgets/miuix_widgets.dart';

/// Mutable string-tag state for [MiuixTagInput].
class MiuixTagInputController extends ChangeNotifier {
  /// Creates a controller with normalized initial tags.
  MiuixTagInputController({Iterable<String> tags = const <String>[]})
    : _tags = List<String>.of(tags);

  final List<String> _tags;

  /// Immutable ordered tags.
  List<String> get tags => UnmodifiableListView<String>(_tags);

  /// Adds a tag when it is not already present under [equals].
  bool add(
    String value, {
    bool Function(String existing, String candidate)? equals,
  }) {
    final normalized = value.trim();
    if (normalized.isEmpty) return false;
    final comparator =
        equals ??
        (existing, candidate) =>
            existing.toLowerCase() == candidate.toLowerCase();
    if (_tags.any((existing) => comparator(existing, normalized))) return false;
    _tags.add(normalized);
    notifyListeners();
    return true;
  }

  /// Removes one tag by value or index.
  bool remove(String value) {
    final removed = _tags.remove(value);
    if (removed) notifyListeners();
    return removed;
  }

  String? removeLast() {
    if (_tags.isEmpty) return null;
    final removed = _tags.removeLast();
    notifyListeners();
    return removed;
  }

  /// Replaces every tag while retaining order.
  void setTags(Iterable<String> values) {
    final next = List<String>.of(values);
    if (listEquals(next, _tags)) return;
    _tags
      ..clear()
      ..addAll(next);
    notifyListeners();
  }

  /// Clears every tag.
  void clear() {
    if (_tags.isEmpty) return;
    _tags.clear();
    notifyListeners();
  }
}

/// Color roles for a tag-entry surface.
@immutable
class MiuixTagInputColors {
  /// Creates a tag-input palette.
  const MiuixTagInputColors({
    required this.background,
    required this.foreground,
    required this.hint,
    required this.focusedBorder,
    required this.error,
  });

  final Color background;
  final Color foreground;
  final Color hint;
  final Color focusedBorder;
  final Color error;
}

/// Defaults for tokenized MIUIX text entry.
abstract final class MiuixTagInputDefaults {
  /// Input geometry.
  static const double minimumHeight = 58;
  static const double cornerRadius = 18;
  static const double itemSpacing = 6;

  /// Resolves semantic colors.
  static MiuixTagInputColors colors(BuildContext context) {
    final semantic = MiuixSemanticColors.of(context);
    return MiuixTagInputColors(
      background: semantic['secondaryContainer'],
      foreground: semantic['onSurface'],
      hint: semantic['onSurfaceSecondary'],
      focusedBorder: semantic['primary'],
      error: semantic['error'],
    );
  }
}

/// Tokenized MIUIX input with duplicate prevention and keyboard deletion.
class MiuixTagInput extends StatefulWidget {
  /// Creates a tag entry surface.
  const MiuixTagInput({
    super.key,
    this.controller,
    this.initialTags = const <String>[],
    this.textController,
    this.focusNode,
    this.label,
    this.hint = '输入后按回车',
    this.maximumTags,
    this.maximumTagLength,
    this.separators = const <String>[',', '，', ';', '；'],
    this.enabled = true,
    this.glass = true,
    this.glassBlur,
    this.glassOpacity,
    this.cornerRadius = double.nan,
    this.validateTag,
    this.normalizeTag,
    this.onChanged,
    this.onRejected,
    this.colors,
  });

  /// Creates the former 18dp opaque tag-entry surface.
  const MiuixTagInput.source({
    super.key,
    this.controller,
    this.initialTags = const <String>[],
    this.textController,
    this.focusNode,
    this.label,
    this.hint = '输入后按回车',
    this.maximumTags,
    this.maximumTagLength,
    this.separators = const <String>[',', '，', ';', '；'],
    this.enabled = true,
    this.validateTag,
    this.normalizeTag,
    this.onChanged,
    this.onRejected,
    this.colors,
  }) : glass = false,
       glassBlur = null,
       glassOpacity = null,
       cornerRadius = MiuixTagInputDefaults.cornerRadius;

  /// Controlled tag, text, and focus state.
  final MiuixTagInputController? controller;
  final Iterable<String> initialTags;
  final TextEditingController? textController;
  final FocusNode? focusNode;

  /// Labels and validation limits.
  final String? label;
  final String hint;
  final int? maximumTags;
  final int? maximumTagLength;
  final List<String> separators;
  final bool enabled;
  final bool glass;

  /// Optional HyperOS 4 content-material overrides.
  final double? glassBlur;
  final double? glassOpacity;

  /// Optional continuous-corner override.
  ///
  /// The NaN default follows the shared editable-field theme role.
  final double cornerRadius;

  /// Optional normalization and validation callbacks.
  final bool Function(String tag)? validateTag;
  final String Function(String tag)? normalizeTag;
  final ValueChanged<List<String>>? onChanged;
  final ValueChanged<String>? onRejected;
  final MiuixTagInputColors? colors;

  @override
  State<MiuixTagInput> createState() => _MiuixTagInputState();
}

class _MiuixTagInputState extends State<MiuixTagInput> {
  // Tag-input limit and separator contract:
  //
  // - Null maximumTags continues to mean an unlimited ordered collection.
  // - Positive maximumTags remains the caller's exact limit.
  // - Zero and negative maximumTags fall back to one in Release mode.
  // - Null maximumTagLength continues to mean no character-count limit.
  // - Positive maximumTagLength remains the caller's exact grapheme limit.
  // - Zero and negative maximumTagLength fall back to one grapheme.
  // - Limits are resolved at commit time so widget updates apply immediately.
  // - Existing tags are never destructively removed when a limit shrinks.
  // - Users can still delete tags while the collection is over a new limit.
  // - New commits are rejected until the collection returns below the limit.
  // - Normalization runs before length, count, validation, and duplicate checks.
  // - Length is measured in user-visible graphemes rather than UTF-16 units.
  // - Empty normalized proposals remain no-ops instead of visible errors.
  // - Empty separator strings are ignored before contains or RegExp operations.
  // - Duplicate separators are collapsed while retaining their logical values.
  // - Every remaining separator is escaped before entering a character class.
  // - Punctuation with regular-expression meaning is therefore treated literally.
  // - An empty effective separator set leaves editing text untouched.
  // - Separator parsing commits only complete pieces before the final tail.
  // - The final tail remains in the editor with a collapsed trailing selection.
  // - Active IME composing ranges are never parsed as committed separators.
  // - Rejected pasted pieces remain editable together with the final tail.
  // - Each committed piece independently respects length and collection limits.
  // - Rejected pieces remain observable through onRejected.
  // - Successful commits clear the editor and publish an immutable list copy.
  // - Duplicate comparison remains case-insensitive by controller default.
  // - Backspace removes a tag only when editable text is empty.
  // - Disabled fields ignore keyboard deletion and pointer chip deletion.
  // - Controller replacement clears error state belonging to the old record.
  // - Text-controller replacement does not replace tags or focus ownership.
  // - Focus-node replacement does not replace tags or pending editing text.
  // - Caller-owned objects are never disposed by this State.
  // - Reduced motion snaps border feedback but does not change validation order.
  // - HyperOS and source material paths share these state rules.
  // - Constructor asserts are not relied on for reusable Release behavior.
  // - Tests cover zero limits, empty separators, rejection, and retained tags.
  // - Device tests remain necessary for hardware key-repeat and IME delimiters.
  // IME composition and recovery invariants:
  // - TextField onChanged alone cannot observe a same-text composition commit.
  // - The attached TextEditingController therefore observes composing changes.
  // - A valid non-collapsed composing range always belongs to the active IME.
  // - Separator glyphs inside that range remain ordinary candidate text.
  // - Parsing begins only after the composing range becomes inactive.
  // - A composition commit may preserve every text code unit unchanged.
  // - That same-text transition still receives one separator parse pass.
  // - Text-changing commits continue through the ordinary onChanged callback.
  // - Controller observation does not parse unrelated programmatic text writes.
  // - The previous editing value is refreshed before parsing can rewrite text.
  // - This ordering prevents nested controller notifications from re-parsing.
  // - Programmatic tail recovery therefore terminates after one assignment.
  // - Complete pasted pieces are evaluated from logical start to logical end.
  // - Each accepted piece reaches the durable tag controller immediately.
  // - An accepted piece is removed from the remaining editable draft.
  // - Empty complete pieces remain no-ops and are not resurrected as errors.
  // - Every non-empty rejected piece remains in its original piece order.
  // - The unfinished tail remains after every rejected complete piece.
  // - Recovery uses the caller's first effective separator as an editable join.
  // - This join is a project behavior, not an unpublished Xiaomi design token.
  // - Recovered text receives a collapsed cursor at its final UTF-16 offset.
  // - Rejection callbacks and error visuals still run once per rejected piece.
  // - Successful pieces still publish immutable controller snapshots normally.
  // - Mixed accepted and rejected paste therefore never loses user content.
  // - Text-controller replacement detaches its composition observer first.
  // - The replacement starts with its own current editing-value snapshot.
  // - Caller-owned text controllers retain their independent disposal ownership.
  // - State disposal removes the observer before any owned controller disposal.
  // - Source and HyperOS visual modes share this exact editing state machine.
  // - Widget tests cover same-text Chinese composition and mixed paste recovery.
  // - Platform IME candidates still require Android and Windows runtime checks.
  late MiuixTagInputController _controller;
  late TextEditingController _textController;
  late FocusNode _focusNode;
  late bool _ownsController;
  late bool _ownsTextController;
  late bool _ownsFocusNode;
  late TextEditingValue _lastEditingValue;
  String? _error;

  int? get _effectiveMaximumTags {
    final maximum = widget.maximumTags;
    return maximum == null
        ? null
        : maximum < 1
        ? 1
        : maximum;
  }

  int? get _effectiveMaximumTagLength {
    final maximum = widget.maximumTagLength;
    return maximum == null
        ? null
        : maximum < 1
        ? 1
        : maximum;
  }

  List<String> get _effectiveSeparators => widget.separators
      .where((separator) => separator.isNotEmpty)
      .toSet()
      .toList(growable: false);

  @override
  void initState() {
    super.initState();
    _attachController();
    _attachTextController();
    _attachFocusNode();
  }

  /// Attaches the independently replaceable tag controller.
  void _attachController() {
    _ownsController = widget.controller == null;
    _controller =
        widget.controller ?? MiuixTagInputController(tags: widget.initialTags);
    _controller.addListener(_rebuild);
  }

  /// Attaches editable text without coupling it to tag ownership.
  void _attachTextController() {
    _ownsTextController = widget.textController == null;
    _textController = widget.textController ?? TextEditingController();
    _lastEditingValue = _textController.value;
    _textController.addListener(_handleEditingValueChanged);
  }

  /// Attaches focus separately so a focus-node swap cannot reset tags.
  void _attachFocusNode() {
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode(debugLabel: 'MiuixTagInput');
    _focusNode.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(MiuixTagInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _controller.removeListener(_rebuild);
      if (_ownsController) _controller.dispose();
      _attachController();
      // A rejection belongs to the old form record and must not leak into the
      // replacement controller's visual state.
      _error = null;
    }
    if (oldWidget.textController != widget.textController) {
      _textController.removeListener(_handleEditingValueChanged);
      if (_ownsTextController) _textController.dispose();
      _attachTextController();
    }
    if (oldWidget.focusNode != widget.focusNode) {
      _focusNode.removeListener(_rebuild);
      if (_ownsFocusNode) _focusNode.dispose();
      _attachFocusNode();
    }
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  void _publish() => widget.onChanged?.call(List<String>.of(_controller.tags));

  bool _commit(String raw) {
    var value = (widget.normalizeTag?.call(raw) ?? raw).trim();
    if (value.isEmpty) return false;
    final maximumLength = _effectiveMaximumTagLength;
    if (maximumLength != null && value.characters.length > maximumLength) {
      _reject(value, '标签过长');
      return false;
    }
    final maximumTags = _effectiveMaximumTags;
    if (maximumTags != null && _controller.tags.length >= maximumTags) {
      _reject(value, '已达到标签数量上限');
      return false;
    }
    if (!(widget.validateTag?.call(value) ?? true)) {
      _reject(value, '标签格式无效');
      return false;
    }
    if (!_controller.add(value)) {
      _reject(value, '标签已存在');
      return false;
    }
    setState(() => _error = null);
    _textController.clear();
    _publish();
    MiuixHaptics.perform(MiuixHapticType.confirm);
    return true;
  }

  void _reject(String value, String error) {
    setState(() => _error = error);
    widget.onRejected?.call(value);
    MiuixHaptics.perform(MiuixHapticType.gestureThresholdActivate);
  }

  void _handleTextChanged(String value) {
    final composing = _textController.value.composing;
    if (composing.isValid && !composing.isCollapsed) return;
    _parseSeparators(value);
  }

  void _handleEditingValueChanged() {
    final current = _textController.value;
    final wasComposing =
        _lastEditingValue.composing.isValid &&
        !_lastEditingValue.composing.isCollapsed;
    final isComposing =
        current.composing.isValid && !current.composing.isCollapsed;
    final committedSameText =
        wasComposing && !isComposing && current.text == _lastEditingValue.text;
    _lastEditingValue = current;
    if (committedSameText) _parseSeparators(current.text);
  }

  void _parseSeparators(String value) {
    final separators = _effectiveSeparators;
    if (separators.isEmpty || !separators.any(value.contains)) return;
    final pattern = RegExp('[${separators.map(RegExp.escape).join()}]');
    final pieces = value.split(pattern);
    final rejectedPieces = <String>[];
    for (final piece in pieces.take(pieces.length - 1)) {
      if (!_commit(piece) && piece.trim().isNotEmpty) {
        rejectedPieces.add(piece);
      }
    }
    final tail = <String>[
      ...rejectedPieces,
      pieces.last,
    ].join(separators.first);
    _textController.value = TextEditingValue(
      text: tail,
      selection: TextSelection.collapsed(offset: tail.length),
    );
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent || !widget.enabled) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.backspace &&
        _textController.text.isEmpty &&
        _controller.tags.isNotEmpty) {
      _controller.removeLast();
      _publish();
      MiuixHaptics.perform(MiuixHapticType.toggleOff);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    _controller.removeListener(_rebuild);
    _textController.removeListener(_handleEditingValueChanged);
    _focusNode.removeListener(_rebuild);
    if (_ownsController) _controller.dispose();
    if (_ownsTextController) _textController.dispose();
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.colors ?? MiuixTagInputDefaults.colors(context);
    final focused = _focusNode.hasFocus;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final motion = reduceMotion ? Duration.zero : hyperOs4.inputStateMotion;
    final radius = widget.cornerRadius.isFinite
        ? widget.cornerRadius.clamp(0.0, double.infinity).toDouble()
        : hyperOs4.textFieldCornerRadius;
    final targetBorderColor = _error != null
        ? palette.error
        : focused
        ? palette.focusedBorder
        : Colors.transparent;
    final targetBorderWidth = focused || _error != null ? 2.0 : 0.0;
    final content = ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: MiuixTagInputDefaults.minimumHeight,
      ),
      child: Wrap(
        spacing: MiuixTagInputDefaults.itemSpacing,
        runSpacing: MiuixTagInputDefaults.itemSpacing,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          for (final tag in _controller.tags)
            MiuixChip(
              label: tag,
              variant: MiuixChipVariant.input,
              enabled: widget.enabled,
              // The field already owns the local backdrop sample. A nested
              // chip blur would resample and cloud the same pixels at stronger
              // intensity levels instead of forming one coherent input plane.
              glass: false,
              onDeleted: widget.enabled
                  ? () {
                      _controller.remove(tag);
                      _publish();
                    }
                  : null,
            ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 120, maxWidth: 260),
            child: Focus(
              onKeyEvent: _handleKey,
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                enabled: widget.enabled,
                maxLines: 1,
                textInputAction: TextInputAction.done,
                onChanged: _handleTextChanged,
                onSubmitted: _commit,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: palette.foreground),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: _controller.tags.isEmpty ? widget.hint : null,
                  hintStyle: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: palette.hint),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    final surface = TweenAnimationBuilder<Color?>(
      // Re-keying only for policy changes preserves ordinary focus/error
      // interpolation while immediately discarding an in-flight midpoint when
      // reduced motion becomes authoritative.
      key: ValueKey<(String, bool)>(('tag-border-color', reduceMotion)),
      tween: ColorTween(begin: targetBorderColor, end: targetBorderColor),
      duration: motion,
      curve: Curves.easeOutCubic,
      builder: (context, animatedBorderColor, _) =>
          TweenAnimationBuilder<double>(
            key: ValueKey<(String, bool)>(('tag-border-width', reduceMotion)),
            tween: Tween<double>(
              begin: targetBorderWidth,
              end: targetBorderWidth,
            ),
            duration: motion,
            curve: Curves.easeOutCubic,
            builder: (context, animatedBorderWidth, _) => MiuixSurface(
              key: const ValueKey('miuix-tag-input-surface'),
              radius: radius,
              color: palette.background,
              glass: widget.glass,
              glassBlur: widget.glassBlur ?? hyperOs4.contentSurfaceBlur,
              glassOpacity:
                  widget.glassOpacity ?? hyperOs4.contentSurfaceTintOpacity,
              border: BorderSide(
                color: animatedBorderColor ?? targetBorderColor,
                width: animatedBorderWidth,
              ),
              padding: const EdgeInsets.all(10),
              child: content,
            ),
          ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (widget.label != null) ...<Widget>[
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 4, bottom: 6),
            child: Text(
              widget.label!,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        ],
        surface,
        if (_error != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 12, top: 5),
            child: Text(
              _error!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: palette.error),
            ),
          ),
      ],
    );
  }
}
