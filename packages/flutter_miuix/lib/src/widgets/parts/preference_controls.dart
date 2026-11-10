part of '../miuix_widgets.dart';

/// Enabled and disabled disclosure-arrow foregrounds.
@immutable
class MiuixArrowPreferenceEndActionColors {
  /// Creates an immutable arrow foreground pair.
  const MiuixArrowPreferenceEndActionColors({
    required this.color,
    required this.disabledColor,
  });

  /// Arrow foreground while the preference is enabled.
  final Color color;

  /// Arrow foreground while the preference is disabled.
  final Color disabledColor;

  /// Resolves the active arrow foreground.
  Color resolve(bool enabled) => enabled ? color : disabledColor;

  /// Returns a copy with independently replaced channels.
  MiuixArrowPreferenceEndActionColors copyWith({
    Color? color,
    Color? disabledColor,
  }) {
    return MiuixArrowPreferenceEndActionColors(
      color: color ?? this.color,
      disabledColor: disabledColor ?? this.disabledColor,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MiuixArrowPreferenceEndActionColors &&
            other.color == color &&
            other.disabledColor == disabledColor;
  }

  @override
  int get hashCode => Object.hash(color, disabledColor);
}

/// Source defaults for [MiuixArrowPreference].
abstract final class MiuixArrowPreferenceDefaults {
  /// Resolves the enabled and disabled disclosure-arrow foregrounds.
  static MiuixArrowPreferenceEndActionColors endActionColors(
    BuildContext context, {
    Color? color,
    Color? disabledColor,
  }) {
    final semantic = MiuixSemanticColors.of(context);
    return MiuixArrowPreferenceEndActionColors(
      color: color ?? semantic['onSurfaceVariantActions'],
      disabledColor: disabledColor ?? semantic['disabledOnSecondaryVariant'],
    );
  }
}

/// Preference that navigates to another screen.
class MiuixArrowPreference extends StatelessWidget {
  /// Creates an arrow preference.
  const MiuixArrowPreference({
    super.key,
    required this.title,
    this.summary,
    this.titleStyle,
    this.summaryStyle,
    this.titleColor,
    this.summaryColor,
    this.endActionColors,
    this.leading,
    this.secondaryAction,
    this.bottomAction,
    this.insideMargin = MiuixBasicComponentDefaults.insideMargin,
    this.onTap,
    this.holdDown = false,
    this.enabled = true,
  }) : _sourceStyle = false;

  /// Creates the upstream `ArrowPreference` parameter surface.
  const MiuixArrowPreference.source({
    super.key,
    required this.title,
    this.summary,
    this.titleColor,
    this.summaryColor,
    Widget? startAction,
    Widget? endActions,
    this.bottomAction,
    this.insideMargin = MiuixBasicComponentDefaults.insideMargin,
    VoidCallback? onClick,
    bool holdDownState = false,
    this.enabled = true,
    this.endActionColors,
  }) : titleStyle = null,
       summaryStyle = null,
       leading = startAction,
       secondaryAction = endActions,
       onTap = onClick,
       holdDown = holdDownState,
       _sourceStyle = true;

  /// Main title.
  final String title;

  /// Optional summary.
  final String? summary;

  /// Optional title-style override forwarded to [MiuixPreference].
  final TextStyle? titleStyle;

  /// Optional summary-style override forwarded to [MiuixPreference].
  final TextStyle? summaryStyle;

  /// Source title foreground pair.
  final MiuixBasicComponentColors? titleColor;

  /// Source summary foreground pair.
  final MiuixBasicComponentColors? summaryColor;

  /// Source disclosure-arrow foreground pair.
  final MiuixArrowPreferenceEndActionColors? endActionColors;

  /// Optional leading widget.
  final Widget? leading;

  /// Optional content displayed before the disclosure arrow.
  final Widget? secondaryAction;

  /// Optional full-width content displayed under the title row.
  final Widget? bottomAction;

  /// Padding inside the preference, matching BasicComponent `insideMargin`.
  final EdgeInsetsGeometry insideMargin;

  /// Tap callback.
  final VoidCallback? onTap;

  /// Whether pressed feedback stays active while a child surface is open.
  final bool holdDown;

  /// Whether the preference can be activated.
  final bool enabled;

  final bool _sourceStyle;

  @override
  Widget build(BuildContext context) {
    final arrowColor =
        (endActionColors ??
                MiuixArrowPreferenceDefaults.endActionColors(context))
            .resolve(enabled);
    return MiuixPreference(
      title: title,
      summary: summary,
      titleStyle: titleStyle,
      summaryStyle: summaryStyle,
      titleColors: titleColor,
      summaryColors: summaryColor,
      leading: leading,
      bottomAction: bottomAction,
      insideMargin: insideMargin,
      onTap: enabled ? onTap : null,
      holdDown: holdDown,
      enabled: enabled,
      sourceStyle: _sourceStyle,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (secondaryAction != null) Flexible(child: secondaryAction!),
          // ArrowPreference.kt always creates an end-actions Row with end
          // padding, even when its caller supplies no endActions content.
          const SizedBox(width: 8),
          _MiuixArrowRight(
            color: arrowColor,
            rtl: Directionality.of(context) == TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}

/// Exact disclosure glyph from ArrowRight.kt.
///
/// A fitted Material chevron has different bearings and can appear reversed
/// after font fallback. Painting the source 10x16 centerline removes the font
/// dependency and mirrors only for an actual RTL Directionality, just as the
/// Compose graphicsLayer does.
class _MiuixArrowRight extends StatelessWidget {
  const _MiuixArrowRight({required this.color, required this.rtl});

  final Color color;
  final bool rtl;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: const Size(10, 16),
    painter: _MiuixArrowRightPainter(color: color, rtl: rtl),
  );
}

/// Vertical disclosure arrow derived from the exact MIUIX `ArrowRight` path.
///
/// Material's keyboard-arrow font glyph has platform-dependent bearings and
/// may be mirrored by icon-font directionality. Rotating the checked-in MIUIX
/// vector keeps the stroke, optical center, and physical up/down direction
/// stable on Android, Windows, and RTL layouts.
class _MiuixVerticalDisclosureArrow extends StatelessWidget {
  const _MiuixVerticalDisclosureArrow({
    super.key,
    required this.expanded,
    required this.color,
    required this.duration,
  });

  final bool expanded;
  final Color color;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final effectiveDuration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : duration;
    return SizedBox.square(
      dimension: 20,
      child: Center(
        child: AnimatedRotation(
          key: const ValueKey('miuix-vertical-disclosure-arrow'),
          duration: effectiveDuration,
          curve: Curves.easeOutCubic,
          // The base vector points right. A quarter turn points down; the
          // expanded state takes the shortest half-turn back to point upward.
          turns: expanded ? -.25 : .25,
          child: _MiuixArrowRight(color: color, rtl: false),
        ),
      ),
    );
  }
}

class _MiuixArrowRightPainter extends CustomPainter {
  const _MiuixArrowRightPainter({required this.color, required this.rtl});

  final Color color;
  final bool rtl;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.43
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    double x(double value) => rtl ? size.width - value : value;
    final arrow = Path()
      ..moveTo(x(2.15), 1.97)
      ..lineTo(x(8.22), 8.03)
      ..lineTo(x(2.15), 14.10);
    canvas.drawPath(arrow, paint);
  }

  @override
  bool shouldRepaint(covariant _MiuixArrowRightPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.rtl != rtl;
}

/// Switch preference.
class MiuixSwitchPreference extends StatelessWidget {
  /// Creates a switch preference.
  const MiuixSwitchPreference({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.summary,
    this.titleColor,
    this.summaryColor,
    this.leading,
    this.secondaryAction,
    this.bottomAction,
    this.switchColors,
    this.insideMargin = MiuixBasicComponentDefaults.insideMargin,
    this.holdDown = false,
    this.enabled = true,
  }) : _sourceStyle = false;

  /// Creates the upstream `SwitchPreference` parameter surface.
  const MiuixSwitchPreference.source({
    super.key,
    required bool checked,
    required ValueChanged<bool> onCheckedChange,
    required this.title,
    this.titleColor,
    this.summary,
    this.summaryColor,
    Widget? startAction,
    Widget? endActions,
    this.bottomAction,
    this.switchColors,
    this.insideMargin = MiuixBasicComponentDefaults.insideMargin,
    bool holdDownState = false,
    this.enabled = true,
  }) : value = checked,
       onChanged = onCheckedChange,
       leading = startAction,
       secondaryAction = endActions,
       holdDown = holdDownState,
       _sourceStyle = true;

  /// Main title.
  final String title;

  /// Optional summary.
  final String? summary;

  /// Source title foreground pair.
  final MiuixBasicComponentColors? titleColor;

  /// Source summary foreground pair.
  final MiuixBasicComponentColors? summaryColor;

  /// Optional leading widget.
  final Widget? leading;

  /// Optional content displayed immediately before the switch.
  final Widget? secondaryAction;

  /// Optional full-width source content below the primary row.
  final Widget? bottomAction;

  /// Optional source switch palette.
  final MiuixSwitchColors? switchColors;

  /// Directional padding inside the complete preference.
  final EdgeInsetsGeometry insideMargin;

  /// Current value.
  final bool value;

  /// Change callback.
  final ValueChanged<bool> onChanged;

  /// Whether the pressed indication remains held.
  final bool holdDown;

  /// Whether the preference and its switch are interactive.
  final bool enabled;

  final bool _sourceStyle;

  @override
  Widget build(BuildContext context) {
    void toggleFromRow() {
      // SwitchPreference.kt delegates the BasicComponent row directly to the
      // value callback. Only the nested Switch performs ToggleOn/ToggleOff,
      // so tapping the label area must not synthesize another haptic.
      onChanged(!value);
    }

    return MiuixPreference(
      title: title,
      summary: summary,
      titleColors: titleColor,
      summaryColors: summaryColor,
      leading: leading,
      bottomAction: bottomAction,
      insideMargin: insideMargin,
      holdDown: holdDown,
      enabled: enabled,
      onTap: enabled ? toggleFromRow : null,
      role: MiuixAccessibilityRole.switchControl,
      semanticToggled: value,
      sourceStyle: _sourceStyle,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (secondaryAction != null) Flexible(child: secondaryAction!),
          // SwitchPreference.kt always pads its caller endActions Row.
          const SizedBox(width: 8),
          MiuixSwitch.source(
            checked: value,
            enabled: enabled,
            colors: switchColors,
            onCheckedChange: onChanged,
          ),
        ],
      ),
    );
  }
}

/// Placement of the checkbox within a preference row.
enum MiuixCheckboxLocation { start, end }

/// Checkbox preference.
class MiuixCheckboxPreference extends StatelessWidget {
  /// Creates a checkbox preference.
  const MiuixCheckboxPreference({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.summary,
    this.titleColor,
    this.summaryColor,
    this.leading,
    this.secondaryAction,
    this.checkboxColors,
    this.bottomAction,
    this.insideMargin = MiuixBasicComponentDefaults.insideMargin,
    this.holdDown = false,
    this.location = MiuixCheckboxLocation.start,
    this.enabled = true,
  }) : _sourceStyle = false;

  /// Creates the upstream `CheckboxPreference` parameter surface.
  const MiuixCheckboxPreference.source({
    super.key,
    required this.title,
    required bool checked,
    required ValueChanged<bool>? onCheckedChange,
    this.titleColor,
    this.summary,
    this.summaryColor,
    this.checkboxColors,
    Widget? endActions,
    MiuixCheckboxLocation checkboxLocation = MiuixCheckboxLocation.start,
    this.bottomAction,
    this.insideMargin = MiuixBasicComponentDefaults.insideMargin,
    bool holdDownState = false,
    this.enabled = true,
  }) : value = checked,
       onChanged = onCheckedChange,
       leading = null,
       secondaryAction = endActions,
       location = checkboxLocation,
       holdDown = holdDownState,
       _sourceStyle = true;

  /// Main title.
  final String title;

  /// Optional summary.
  final String? summary;

  /// Source title foreground pair.
  final MiuixBasicComponentColors? titleColor;

  /// Source summary foreground pair.
  final MiuixBasicComponentColors? summaryColor;

  /// Optional leading widget.
  final Widget? leading;

  /// Optional content placed on the opposite side of the text block.
  final Widget? secondaryAction;

  /// Optional source checkbox palette.
  final MiuixCheckboxColors? checkboxColors;

  /// Optional full-width source content below the primary row.
  final Widget? bottomAction;

  /// Directional padding inside the complete preference.
  final EdgeInsetsGeometry insideMargin;

  /// Side of the row on which the checkbox is displayed.
  final MiuixCheckboxLocation location;

  /// Current value.
  final bool value;

  /// Change callback.
  final ValueChanged<bool>? onChanged;

  /// Whether the pressed indication remains held.
  final bool holdDown;

  /// Whether the preference and its checkbox are interactive.
  final bool enabled;

  final bool _sourceStyle;

  @override
  Widget build(BuildContext context) {
    void toggleFromRow() {
      // CheckboxPreference.kt has the same split path as the source switch
      // preference: its BasicComponent row is silent, while the embedded
      // Checkbox owns the state-dependent haptic role.
      onChanged?.call(!value);
    }

    final checkbox = MiuixCheckbox.tristate(
      state: value,
      enabled: enabled,
      colors: checkboxColors,
      onClick: onChanged == null ? null : () => onChanged!.call(!value),
    );
    final checkboxAtStart = location == MiuixCheckboxLocation.start;
    return MiuixPreference(
      title: title,
      summary: summary,
      titleColors: titleColor,
      summaryColors: summaryColor,
      leading: checkboxAtStart
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  // CheckboxPreferenceStartAction.kt uses 5dp before the
                  // BasicComponent's separate 8dp occupied-start gap.
                  padding: const EdgeInsetsDirectional.only(end: 5),
                  child: checkbox,
                ),
                ?leading,
              ],
            )
          : leading,
      bottomAction: bottomAction,
      insideMargin: insideMargin,
      holdDown: holdDown,
      enabled: enabled,
      role: MiuixAccessibilityRole.checkbox,
      semanticChecked: value,
      sourceStyle: _sourceStyle,
      // Source installs a non-null row click closure even when the nullable
      // state callback is absent; the closure then intentionally does nothing.
      onTap: enabled ? toggleFromRow : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (secondaryAction != null) Flexible(child: secondaryAction!),
          // CheckboxPreference.kt keeps this padding for an empty endActions.
          const SizedBox(width: 8),
          if (!checkboxAtStart) checkbox,
        ],
      ),
    );
  }
}
