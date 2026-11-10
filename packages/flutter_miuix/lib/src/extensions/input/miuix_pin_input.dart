import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../platform/miuix_haptics.dart';
import '../../theme/miuix_semantic_colors.dart';
import '../../theme/miuix_theme.dart';

/// Theme colors for [MiuixPinInput].
@immutable
class MiuixPinInputColors {
  /// Creates a complete PIN input palette.
  const MiuixPinInputColors({
    required this.background,
    required this.foreground,
    required this.focusedBorder,
    required this.idleBorder,
    required this.errorBorder,
    required this.disabledForeground,
  });

  /// Cell fill and typed-character color.
  final Color background;
  final Color foreground;

  /// Focus, idle, validation, and disabled roles.
  final Color focusedBorder;
  final Color idleBorder;
  final Color errorBorder;
  final Color disabledForeground;
}

/// Geometry and color defaults for [MiuixPinInput].
abstract final class MiuixPinInputDefaults {
  /// Default OTP/PIN length.
  static const int length = 6;

  /// Width and height of one code cell.
  static const double cellExtent = 48;

  /// Gap between neighboring cells.
  static const double spacing = 8;

  /// Continuous corner radius for each cell.
  static const double cornerRadius = 14;

  /// Resolves the current MIUIX semantic palette.
  static MiuixPinInputColors colors(BuildContext context) {
    final semantic = MiuixSemanticColors.of(context);
    return MiuixPinInputColors(
      background: semantic['secondaryContainer'],
      foreground: semantic['onSurface'],
      focusedBorder: semantic['primary'],
      idleBorder: semantic['outline'],
      errorBorder: semantic['error'],
      disabledForeground: semantic['disabledOnSurface'],
    );
  }
}

/// Segmented PIN and one-time-password input with MIUIX feedback.
class MiuixPinInput extends StatefulWidget {
  /// Creates a segmented code input.
  const MiuixPinInput({
    super.key,
    this.controller,
    this.focusNode,
    this.length = MiuixPinInputDefaults.length,
    this.enabled = true,
    this.obscureText = false,
    this.obscuringCharacter = '•',
    this.digitsOnly = true,
    this.autofocus = false,
    this.error = false,
    this.colors,
    this.cornerRadius = double.nan,
    this.onChanged,
    this.onCompleted,
  });

  /// Creates the former 14dp opaque-cell compatibility input.
  const MiuixPinInput.source({
    super.key,
    this.controller,
    this.focusNode,
    this.length = MiuixPinInputDefaults.length,
    this.enabled = true,
    this.obscureText = false,
    this.obscuringCharacter = '•',
    this.digitsOnly = true,
    this.autofocus = false,
    this.error = false,
    this.colors,
    this.onChanged,
    this.onCompleted,
  }) : cornerRadius = MiuixPinInputDefaults.cornerRadius;

  /// Optional externally owned editing controller and focus node.
  final TextEditingController? controller;
  final FocusNode? focusNode;

  /// Number of accepted characters.
  final int length;

  /// Input, masking, and keyboard behavior.
  final bool enabled;
  final bool obscureText;
  final String obscuringCharacter;
  final bool digitsOnly;
  final bool autofocus;

  /// Whether cells use the semantic error outline.
  final bool error;

  /// Optional palette override.
  final MiuixPinInputColors? colors;

  /// Optional cell-corner override.
  ///
  /// The NaN default resolves through the HyperOS 4 editable-field token.
  final double cornerRadius;

  /// Incremental and completion callbacks.
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;

  @override
  State<MiuixPinInput> createState() => _MiuixPinInputState();
}

class _MiuixPinInputState extends State<MiuixPinInput> {
  // PIN value-boundary contract:
  //
  // - Public length is validated in Debug and Release through one effective value.
  // - A positive caller length remains unchanged.
  // - Zero and negative lengths fall back to the documented six-cell default.
  // - Cell generation, formatter limit, focus index, and semantics share it.
  // - No branch may continue using raw widget.length after normalization.
  // - This prevents negative List.generate counts and clamp upper bounds.
  // - It also prevents invalid LengthLimitingTextInputFormatter construction.
  // - A caller-owned controller may initially contain more characters than fit.
  // - Existing external text is not destructively rewritten during attachment.
  // - Future user edits are constrained to the effective length.
  // - Cells render only the effective visible prefix of external text.
  // - Completion is evaluated against the same effective length.
  // - The semantic entered/total count reports that effective length.
  // - Obscuring text accepts one visible grapheme rather than one UTF-16 unit.
  // - An empty obscuring string falls back to the standard bullet.
  // - A multi-grapheme string uses only its first grapheme.
  // - Emoji and composed characters therefore remain visually intact.
  // - TextEditingController notifies for text, selection, and composing changes.
  // - Only a changed text string is a public value mutation.
  // - Cursor-only changes must not replay onChanged.
  // - Cursor-only changes must not replay onCompleted.
  // - Cursor-only changes must not replay text or confirmation haptics.
  // - A text replacement with the same length still publishes onChanged.
  // - A changed complete code still publishes its new onCompleted value.
  // - Length-changing edits use the text-handle movement feedback role.
  // - Reaching the complete boundary uses the confirmation feedback role.
  // - Controller attachment snapshots the entire previous text string.
  // - Controller replacement resets that snapshot to the new owner's text.
  // - Focus replacement does not reset text or completion history.
  // - Disabled state retains both resources for later re-enablement.
  // - Input formatters constrain future edits, not external programmatic writes.
  // - Digits-only filtering composes with the safe length formatter.
  // - Reduced motion affects cell outlines but not logical callbacks.
  // - Source and OTP facades inherit the identical safety behavior.
  // - Tests cover invalid length, empty mask, truncation, and cursor movement.
  // - Platform tests remain necessary for SMS autofill and IME composition.
  // PIN object-lifecycle contract:
  // - Editing and focus state have independent ownership boundaries.
  // - An omitted controller creates package-owned editing state.
  // - An omitted focus node creates package-owned focus state.
  // - Caller-provided objects are listened to but never disposed here.
  // - Replacing only focus must preserve the active editing controller.
  // - Replacing only editing state must preserve the active focus node.
  // - Internal text therefore survives a focus-node configuration change.
  // - Internal focus therefore survives a controller configuration change.
  // - Replaced objects lose listeners before a new object is attached.
  // - Previous-length tracking follows the newly active controller.
  // - Programmatic text changes use the same haptic boundary as input.
  // - Completion remains tied to the currently configured code length.
  // - A disabled field retains both resources for later re-enablement.
  // - A theme rebuild never recreates either state resource.
  // - A masking-mode rebuild never recreates either state resource.
  // - A validation-state rebuild never recreates either state resource.
  // - Input formatters constrain future edits, not caller-owned old text.
  // - Disposal detaches listeners before releasing owned resources.
  // - Focus repaint callbacks are ignored after State disposal.
  // - Text callbacks are ignored after State disposal by listener removal.
  // - OTP facade behavior inherits these same ownership guarantees.
  // These rules belong to the reusable library rather than its example.

  late TextEditingController _controller;
  late FocusNode _focusNode;
  late bool _ownsController;
  late bool _ownsFocusNode;
  String _previousText = '';

  int get _effectiveLength =>
      widget.length > 0 ? widget.length : MiuixPinInputDefaults.length;

  String get _effectiveObscuringCharacter =>
      widget.obscuringCharacter.characters.firstOrNull ?? '•';

  @override
  void initState() {
    super.initState();
    _attachObjects();
  }

  void _attachObjects() {
    _attachController();
    _attachFocusNode();
  }

  void _attachController() {
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();
    _previousText = _controller.text;
    _controller.addListener(_handleTextChanged);
  }

  void _attachFocusNode() {
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(MiuixPinInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _detachController();
      _attachController();
    }
    if (oldWidget.focusNode != widget.focusNode) {
      _detachFocusNode();
      _attachFocusNode();
    }
  }

  void _handleTextChanged() {
    final text = _controller.text;
    final previousText = _previousText;
    if (text == previousText) {
      // TextEditingController also notifies for cursor and composing-region
      // changes. Those are not value changes and must not replay completion.
      return;
    }
    _previousText = text;
    if (text.length != previousText.length) {
      MiuixHaptics.perform(MiuixHapticType.textHandleMove);
    }
    widget.onChanged?.call(text);
    if (text.length == _effectiveLength) {
      MiuixHaptics.perform(MiuixHapticType.confirm);
      widget.onCompleted?.call(text);
    }
    if (mounted) setState(() {});
  }

  void _handleFocusChanged() {
    if (mounted) setState(() {});
  }

  void _detachController() {
    _controller.removeListener(_handleTextChanged);
    if (_ownsController) _controller.dispose();
  }

  void _detachFocusNode() {
    _focusNode.removeListener(_handleFocusChanged);
    if (_ownsFocusNode) _focusNode.dispose();
  }

  @override
  void dispose() {
    _detachController();
    _detachFocusNode();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors ?? MiuixPinInputDefaults.colors(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final motion = hyperOs4.inputStateMotion;
    final cornerRadius = widget.cornerRadius.isFinite
        ? widget.cornerRadius.clamp(0.0, double.infinity)
        : hyperOs4.textFieldCornerRadius;
    final text = _controller.text;
    final length = _effectiveLength;
    final obscuringCharacter = _effectiveObscuringCharacter;
    final activeIndex = text.length.clamp(0, length - 1);

    return Semantics(
      textField: true,
      enabled: widget.enabled,
      label: 'PIN',
      value: '${text.length} of $length characters entered',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.enabled ? _focusNode.requestFocus : null,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Opacity(
              opacity: 0,
              child: SizedBox(
                width: 1,
                height: 1,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  autofocus: widget.autofocus,
                  keyboardType: widget.digitsOnly
                      ? TextInputType.number
                      : TextInputType.text,
                  textInputAction: TextInputAction.done,
                  autofillHints: const <String>[AutofillHints.oneTimeCode],
                  inputFormatters: <TextInputFormatter>[
                    if (widget.digitsOnly)
                      FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(length),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List<Widget>.generate(length, (index) {
                final populated = index < text.length;
                final focused = _focusNode.hasFocus && index == activeIndex;
                final borderColor = widget.error
                    ? colors.errorBorder
                    : focused
                    ? colors.focusedBorder
                    : colors.idleBorder;
                final character = populated
                    ? (widget.obscureText ? obscuringCharacter : text[index])
                    : '';
                return Padding(
                  padding: EdgeInsetsDirectional.only(
                    end: index == length - 1
                        ? 0
                        : MiuixPinInputDefaults.spacing,
                  ),
                  child: AnimatedContainer(
                    // Recreate a live outline tween when the inherited policy
                    // changes so no sampled border survives reduced motion.
                    key: ValueKey<(int, bool)>((index, reduceMotion)),
                    duration: reduceMotion ? Duration.zero : motion,
                    curve: Curves.easeOutCubic,
                    width: MiuixPinInputDefaults.cellExtent,
                    height: MiuixPinInputDefaults.cellExtent,
                    decoration: BoxDecoration(
                      color: colors.background,
                      borderRadius: BorderRadius.circular(cornerRadius),
                      border: Border.all(
                        color: borderColor,
                        width: focused || widget.error ? 2 : 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      character,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: widget.enabled
                            ? colors.foreground
                            : colors.disabledForeground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

/// OTP-named facade with the same behavior as [MiuixPinInput].
class MiuixOtpInput extends MiuixPinInput {
  /// Creates a one-time-password input.
  const MiuixOtpInput({
    super.key,
    super.controller,
    super.focusNode,
    super.length,
    super.enabled,
    super.obscureText,
    super.obscuringCharacter,
    super.digitsOnly,
    super.autofocus,
    super.error,
    super.colors,
    super.cornerRadius,
    super.onChanged,
    super.onCompleted,
  });

  /// Creates the OTP facade with the former 14dp cell geometry.
  const MiuixOtpInput.source({
    super.key,
    super.controller,
    super.focusNode,
    super.length,
    super.enabled,
    super.obscureText,
    super.obscuringCharacter,
    super.digitsOnly,
    super.autofocus,
    super.error,
    super.colors,
    super.onChanged,
    super.onCompleted,
  }) : super.source();
}
