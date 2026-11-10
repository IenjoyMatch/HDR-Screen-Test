part of '../miuix_widgets.dart';

/// Slider preference.
class MiuixSliderPreference extends StatelessWidget {
  /// Creates a slider preference.
  const MiuixSliderPreference({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.summary,
    this.titleColors,
    this.summaryColors,
    this.valueText,
    this.onTap,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.showKeyPoints = false,
    this.keyPoints = const <double>[],
    this.magnetThreshold = .02,
    this.onChangeFinished,
    this.reverseDirection = false,
    this.sliderHeight = MiuixSliderDefaults.minHeight,
    this.sliderColors,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
    this.leading,
    this.trailing,
    this.bottomAction,
    this.insideMargin = MiuixBasicComponentDefaults.insideMargin,
    this.holdDown = false,
    this.enabled = true,
    this.sourceStyle = false,
  });

  /// Creates the upstream `SliderPreference` parameter form.
  factory MiuixSliderPreference.source({
    Key? key,
    required double value,
    required ValueChanged<double> onValueChange,
    String? title,
    MiuixBasicComponentColors? titleColor,
    String? summary,
    MiuixBasicComponentColors? summaryColor,
    Widget? startAction,
    String? valueText,
    Widget? endActions,
    Widget? bottomAction,
    VoidCallback? onClick,
    bool holdDownState = false,
    bool enabled = true,
    double min = 0,
    double max = 1,
    int steps = 0,
    VoidCallback? onValueChangeFinished,
    bool reverseDirection = false,
    double sliderHeight = MiuixSliderDefaults.minHeight,
    MiuixSliderColors? sliderColors,
    MiuixSliderHapticEffect hapticEffect =
        MiuixSliderDefaults.defaultHapticEffect,
    bool showKeyPoints = false,
    List<double>? keyPoints,
    double magnetThreshold = .02,
    EdgeInsetsGeometry insideMargin = MiuixBasicComponentDefaults.insideMargin,
  }) {
    return MiuixSliderPreference(
      key: key,
      title: title,
      titleColors: titleColor,
      summary: summary,
      summaryColors: summaryColor,
      valueText: valueText,
      onTap: onClick,
      leading: startAction,
      trailing: endActions,
      bottomAction: bottomAction,
      value: value,
      onChanged: onValueChange,
      min: min,
      max: max,
      divisions: _miuixSourceStepsToDivisions(steps),
      onChangeFinished: onValueChangeFinished,
      reverseDirection: reverseDirection,
      sliderHeight: sliderHeight,
      sliderColors: sliderColors,
      hapticEffect: hapticEffect,
      showKeyPoints: showKeyPoints,
      keyPoints: keyPoints ?? const <double>[],
      magnetThreshold: magnetThreshold,
      insideMargin: insideMargin,
      holdDown: holdDownState,
      enabled: enabled,
      sourceStyle: true,
    );
  }

  /// Main title.
  final String? title;

  /// Optional summary.
  final String? summary;

  /// Source title foreground pair.
  final MiuixBasicComponentColors? titleColors;

  /// Source summary foreground pair.
  final MiuixBasicComponentColors? summaryColors;

  /// Optional formatted value shown at the end of the title row.
  final String? valueText;

  /// Optional row action independent of dragging the slider.
  final VoidCallback? onTap;

  /// Current value.
  final double value;

  /// Change callback.
  final ValueChanged<double> onChanged;

  /// Minimum value.
  final double min;

  /// Maximum value.
  final double max;

  /// Optional count of equal slider divisions.
  final int? divisions;

  /// Whether the slider paints its source key-point markers.
  final bool showKeyPoints;

  /// Absolute values used as visible and magnetic key points.
  final List<double> keyPoints;

  /// Magnetic snap radius expressed as a normalized range fraction.
  final double magnetThreshold;

  /// Called when a pointer finishes changing the value.
  final VoidCallback? onChangeFinished;

  /// Reverses the logical direction before automatic RTL handling.
  final bool reverseDirection;

  /// Height of the embedded source slider.
  final double sliderHeight;

  /// Optional source slider palette.
  final MiuixSliderColors? sliderColors;

  /// Haptic mode used by the embedded slider.
  final MiuixSliderHapticEffect hapticEffect;

  /// Optional content before the title area.
  final Widget? leading;

  /// Optional content after [valueText].
  final Widget? trailing;

  /// Optional content above the slider in the bottom action area.
  final Widget? bottomAction;

  /// Source padding around the complete preference content.
  final EdgeInsetsGeometry insideMargin;

  /// Whether source press indication remains held.
  final bool holdDown;

  /// Whether the preference slider is interactive.
  final bool enabled;

  /// Whether the surrounding row uses MIUIX 1.0.9 visual metrics.
  ///
  /// Prefer [MiuixSliderPreference.source] for application call sites.
  final bool sourceStyle;

  @override
  Widget build(BuildContext context) {
    final range = _safeRange(min, max);
    final safeValue = _normalizeSliderCallbackValue(value, range);
    final semantic = MiuixSemanticColors.of(context);
    final valueLabel = valueText == null
        ? null
        : Text(
            valueText!,
            style: MiuixTheme.of(context).textTheme.bodyMedium?.copyWith(
              color: enabled
                  ? semantic['onSurfaceVariantActions']
                  : semantic['disabledOnSecondaryVariant'],
            ),
          );
    final actionContent = switch ((valueLabel, trailing)) {
      (null, null) => null,
      (final Widget label, null) => label,
      (null, final Widget action) => action,
      (final Widget label, final Widget action) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [label, action],
      ),
    };
    final showArrow = onTap != null;
    final showEndArea = actionContent != null || showArrow;
    final arrowColor = MiuixArrowPreferenceDefaults.endActionColors(
      context,
    ).resolve(enabled);
    final endArea = !showEndArea
        ? null
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (actionContent != null) Flexible(child: actionContent),
              // SliderPreference.kt always gives its value/end-actions Row an
              // eight-dp end inset, including the empty Row before an arrow.
              const SizedBox(width: 8),
              if (showArrow)
                _MiuixArrowRight(
                  color: arrowColor,
                  rtl: Directionality.of(context) == TextDirection.rtl,
                ),
            ],
          );
    return MiuixPreference(
      title: title ?? '',
      showTitle: title != null,
      titleColors: titleColors,
      summary: summary,
      summaryColors: summaryColors,
      leading: leading,
      trailing: endArea,
      onTap: enabled ? onTap : null,
      holdDown: holdDown,
      enabled: enabled,
      insideMargin: insideMargin,
      sourceStyle: sourceStyle,
      bottomAction: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ?bottomAction,
          MiuixSlider(
            value: safeValue,
            min: range.min,
            max: range.max,
            divisions: divisions,
            showKeyPoints: showKeyPoints,
            keyPoints: keyPoints,
            magnetThreshold: magnetThreshold,
            onChangeFinished: onChangeFinished,
            reverseDirection: reverseDirection,
            height: sliderHeight,
            colors: sliderColors,
            hapticEffect: hapticEffect,
            enabled: enabled,
            onChanged: (next) =>
                onChanged(_normalizeSliderCallbackValue(next, range)),
          ),
        ],
      ),
    );
  }
}

/// Placement of the radio mark inside a radio preference row.
///
/// MIUIX 1.0.9 places the mark at the start by default.  The explicit enum
/// mirrors the source API so callers can opt into the less common end layout
/// without rebuilding the preference from lower-level widgets.
enum MiuixRadioButtonLocation {
  /// Place the radio before the title and summary.
  start,

  /// Place the radio after the title and summary.
  end,
}

/// Four source palettes used by a radio preference's text states.
///
/// The radio mark has its own [MiuixRadioButtonColors]. Upstream separately
/// changes both title and summary to the theme primary color while selected.
///
/// Each property remains a [MiuixBasicComponentColors] pair rather than a
/// single color. This mirrors Kotlin's `RadioButtonPreferenceColors`, where
/// selection chooses one pair and the preference's enabled state chooses the
/// final channel inside that pair.
///
/// The resulting state table is:
///
/// * enabled and unselected: [titleColor] and [summaryColor] enabled channels;
/// * disabled and unselected: the disabled channels of those ordinary pairs;
/// * enabled and selected: [selectedTitleColor] and [selectedSummaryColor];
/// * disabled and selected: the disabled channels of the selected pairs.
///
/// Keeping these axes independent matters for custom themes. A caller may use
/// a branded selected foreground while still sharing the standard disabled
/// foreground, or may deliberately distinguish a disabled selected value.
/// Flattening this model to four raw colors loses those combinations.
///
/// Equality and [copyWith] follow the source data-class behavior so palettes
/// can be stored, compared, and selectively overridden without identity-based
/// surprises. The object contains no theme lookup; resolve theme-dependent
/// defaults through [MiuixRadioButtonPreferenceDefaults].
@immutable
class MiuixRadioButtonPreferenceColors {
  /// Creates the immutable selected/unselected text palette.
  const MiuixRadioButtonPreferenceColors({
    required this.titleColor,
    required this.selectedTitleColor,
    required this.summaryColor,
    required this.selectedSummaryColor,
  });

  /// Ordinary title colors.
  final MiuixBasicComponentColors titleColor;

  /// Selected title colors.
  final MiuixBasicComponentColors selectedTitleColor;

  /// Ordinary summary colors.
  final MiuixBasicComponentColors summaryColor;

  /// Selected summary colors.
  final MiuixBasicComponentColors selectedSummaryColor;

  /// Resolves the source title palette for [selected].
  MiuixBasicComponentColors resolveTitle(bool selected) =>
      selected ? selectedTitleColor : titleColor;

  /// Resolves the source summary palette for [selected].
  MiuixBasicComponentColors resolveSummary(bool selected) =>
      selected ? selectedSummaryColor : summaryColor;

  /// Returns a copy with independently replaced source channels.
  MiuixRadioButtonPreferenceColors copyWith({
    MiuixBasicComponentColors? titleColor,
    MiuixBasicComponentColors? selectedTitleColor,
    MiuixBasicComponentColors? summaryColor,
    MiuixBasicComponentColors? selectedSummaryColor,
  }) {
    return MiuixRadioButtonPreferenceColors(
      titleColor: titleColor ?? this.titleColor,
      selectedTitleColor: selectedTitleColor ?? this.selectedTitleColor,
      summaryColor: summaryColor ?? this.summaryColor,
      selectedSummaryColor: selectedSummaryColor ?? this.selectedSummaryColor,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MiuixRadioButtonPreferenceColors &&
            other.titleColor == titleColor &&
            other.selectedTitleColor == selectedTitleColor &&
            other.summaryColor == summaryColor &&
            other.selectedSummaryColor == selectedSummaryColor;
  }

  @override
  int get hashCode => Object.hash(
    titleColor,
    selectedTitleColor,
    summaryColor,
    selectedSummaryColor,
  );
}

/// Theme-resolved defaults from upstream `RadioButtonPreferenceDefaults`.
///
/// The upstream default factory creates four independent BasicComponent color
/// objects. Ordinary title and summary colors keep their usual semantic roles,
/// while both enabled selected foregrounds use the current theme primary.
/// Disabled channels still come from the normal BasicComponent defaults.
///
/// This means a disabled selected radio keeps a muted label instead of painting
/// active primary text. It also means changing only [selectedTitleColor] never
/// silently changes the selected summary or either ordinary state.
///
/// Resolve this factory inside a build method because every default depends on
/// the nearest [MiuixTheme] and its current brightness or dynamic color scheme.
abstract final class MiuixRadioButtonPreferenceDefaults {
  /// Resolves ordinary text normally and selected text to theme primary.
  ///
  /// Any supplied pair replaces only its matching source parameter. Omitted
  /// pairs retain the live theme defaults rather than copying another supplied
  /// channel. This is the same independent-override behavior as the Kotlin
  /// function's four default arguments.
  static MiuixRadioButtonPreferenceColors radioButtonPreferenceColors(
    BuildContext context, {
    MiuixBasicComponentColors? titleColor,
    MiuixBasicComponentColors? selectedTitleColor,
    MiuixBasicComponentColors? summaryColor,
    MiuixBasicComponentColors? selectedSummaryColor,
  }) {
    final primary = MiuixSemanticColors.of(context)['primary'];
    return MiuixRadioButtonPreferenceColors(
      titleColor: titleColor ?? MiuixBasicComponentDefaults.titleColor(context),
      selectedTitleColor:
          selectedTitleColor ??
          MiuixBasicComponentDefaults.titleColor(context, color: primary),
      summaryColor:
          summaryColor ?? MiuixBasicComponentDefaults.summaryColor(context),
      selectedSummaryColor:
          selectedSummaryColor ??
          MiuixBasicComponentDefaults.summaryColor(context, color: primary),
    );
  }
}

/// Radio preference for exclusive settings choices.
class MiuixRadioButtonPreference<T> extends StatelessWidget {
  /// Creates a radio preference row.
  const MiuixRadioButtonPreference({
    super.key,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.summary,
    this.colors,
    this.titleColor,
    this.summaryColor,
    this.leading,
    this.secondaryAction,
    this.radioButtonColors,
    this.bottomAction,
    this.insideMargin = MiuixBasicComponentDefaults.insideMargin,
    this.holdDown = false,
    this.radioButtonLocation = MiuixRadioButtonLocation.start,
    this.enabled = true,
    this.sourceStyle = false,
  });

  /// Creates the upstream non-generic `RadioButtonPreference` surface.
  static MiuixRadioButtonPreference<bool> source({
    Key? key,
    required String title,
    required bool selected,
    required VoidCallback? onClick,
    MiuixRadioButtonPreferenceColors? colors,
    MiuixBasicComponentColors? titleColor,
    String? summary,
    MiuixBasicComponentColors? summaryColor,
    MiuixRadioButtonColors? radioButtonColors,
    Widget? endActions,
    MiuixRadioButtonLocation radioButtonLocation =
        MiuixRadioButtonLocation.start,
    Widget? bottomAction,
    EdgeInsetsGeometry insideMargin = MiuixBasicComponentDefaults.insideMargin,
    bool holdDownState = false,
    bool enabled = true,
  }) {
    return MiuixRadioButtonPreference<bool>(
      key: key,
      title: title,
      value: true,
      groupValue: selected,
      onChanged: onClick == null ? null : (_) => onClick(),
      colors: colors,
      titleColor: titleColor,
      summary: summary,
      summaryColor: summaryColor,
      secondaryAction: endActions,
      radioButtonColors: radioButtonColors,
      radioButtonLocation: radioButtonLocation,
      bottomAction: bottomAction,
      insideMargin: insideMargin,
      holdDown: holdDownState,
      enabled: enabled,
      sourceStyle: true,
    );
  }

  /// Main title.
  final String title;

  /// Optional summary.
  final String? summary;

  /// Source selected/unselected text palette.
  ///
  /// When omitted, [MiuixRadioButtonPreferenceDefaults] supplies ordinary
  /// semantic text for unselected rows and primary text for selected rows.
  /// The older [titleColor] and [summaryColor] fields remain compatibility
  /// overrides and take precedence over the corresponding resolved palette.
  final MiuixRadioButtonPreferenceColors? colors;

  /// Source title foreground pair.
  final MiuixBasicComponentColors? titleColor;

  /// Source summary foreground pair.
  final MiuixBasicComponentColors? summaryColor;

  /// Optional leading widget.
  ///
  /// This remains available for compatibility. When supplied with the
  /// default start location it replaces the standard start radio action.
  final Widget? leading;

  /// Optional caller content before an end-positioned radio.
  final Widget? secondaryAction;

  /// Optional source radio palette.
  final MiuixRadioButtonColors? radioButtonColors;

  /// Optional full-width source content below the primary row.
  final Widget? bottomAction;

  /// Directional padding inside the complete preference.
  final EdgeInsetsGeometry insideMargin;

  /// Location of the radio mark; MIUIX defaults to the start edge.
  final MiuixRadioButtonLocation radioButtonLocation;

  /// Radio value for this row.
  final T value;

  /// Currently selected group value.
  final T? groupValue;

  /// Change callback.
  final ValueChanged<T?>? onChanged;

  /// Whether the pressed indication remains held.
  final bool holdDown;

  /// Whether the preference and its radio are interactive.
  final bool enabled;

  /// Whether the composite forwards MIUIX 1.0.9 row typography.
  ///
  /// Prefer the static [MiuixRadioButtonPreference.source] constructor.
  final bool sourceStyle;

  @override
  Widget build(BuildContext context) {
    void selectFromRow() {
      // RadioButtonPreference.kt invokes the row callback without haptics.
      // ToggleOn/ToggleOff belongs exclusively to the nested RadioButton.
      onChanged?.call(value);
    }

    final radio = MiuixRadio<T>(
      value: value,
      groupValue: groupValue,
      enabled: enabled,
      onChanged: onChanged,
      colors: radioButtonColors,
    );
    final selected = value == groupValue;
    final resolvedColors =
        colors ??
        MiuixRadioButtonPreferenceDefaults.radioButtonPreferenceColors(context);
    final radioAtStart = radioButtonLocation == MiuixRadioButtonLocation.start;
    return MiuixPreference(
      title: title,
      summary: summary,
      // The compatibility per-channel overrides remain authoritative, while
      // source calls use the four-state palette selected above.
      titleColors: titleColor ?? resolvedColors.resolveTitle(selected),
      summaryColors: summaryColor ?? resolvedColors.resolveSummary(selected),
      leading: radioAtStart
          ? leading ??
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 5),
                  child: radio,
                )
          : leading,
      bottomAction: bottomAction,
      insideMargin: insideMargin,
      holdDown: holdDown,
      enabled: enabled,
      onTap: enabled ? selectFromRow : null,
      role: MiuixAccessibilityRole.radioButton,
      semanticChecked: selected,
      sourceStyle: sourceStyle,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (secondaryAction != null) Flexible(child: secondaryAction!),
          // RadioButtonPreference.kt retains this for empty endActions.
          const SizedBox(width: 8),
          if (!radioAtStart) radio,
        ],
      ),
    );
  }
}

/// Range slider preference for two-value settings.
class MiuixRangeSliderPreference extends StatelessWidget {
  /// Creates a range slider preference.
  ///
  /// This compatibility constructor keeps Flutter-style [RangeValues] and
  /// [onChanged] names. Use [MiuixRangeSliderPreference.source] when porting
  /// the upstream Kotlin call site directly.
  const MiuixRangeSliderPreference({
    super.key,
    required this.values,
    required this.onChanged,
    this.title,
    this.summary,
    this.titleColors,
    this.summaryColors,
    this.valueText,
    this.onTap,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.showKeyPoints = false,
    this.keyPoints = const <double>[],
    this.magnetThreshold = .02,
    this.onChangeFinished,
    this.sliderHeight = MiuixSliderDefaults.minHeight,
    this.sliderColors,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
    this.leading,
    this.trailing,
    this.bottomAction,
    this.insideMargin = MiuixBasicComponentDefaults.insideMargin,
    this.holdDown = false,
    this.enabled = true,
    this.sourceStyle = false,
  });

  /// Creates the complete upstream `RangeSliderPreference` parameter form.
  factory MiuixRangeSliderPreference.source({
    Key? key,
    required RangeValues value,
    required ValueChanged<RangeValues> onValueChange,
    String? title,
    MiuixBasicComponentColors? titleColor,
    String? summary,
    MiuixBasicComponentColors? summaryColor,
    Widget? startAction,
    String? valueText,
    Widget? endActions,
    Widget? bottomAction,
    VoidCallback? onClick,
    bool holdDownState = false,
    bool enabled = true,
    double min = 0,
    double max = 1,
    int steps = 0,
    VoidCallback? onValueChangeFinished,
    double sliderHeight = MiuixSliderDefaults.minHeight,
    MiuixSliderColors? sliderColors,
    MiuixSliderHapticEffect hapticEffect =
        MiuixSliderDefaults.defaultHapticEffect,
    bool showKeyPoints = false,
    List<double>? keyPoints,
    double magnetThreshold = .02,
    EdgeInsetsGeometry insideMargin = MiuixBasicComponentDefaults.insideMargin,
  }) {
    return MiuixRangeSliderPreference(
      key: key,
      title: title,
      titleColors: titleColor,
      summary: summary,
      summaryColors: summaryColor,
      valueText: valueText,
      onTap: onClick,
      leading: startAction,
      trailing: endActions,
      bottomAction: bottomAction,
      values: value,
      onChanged: onValueChange,
      min: min,
      max: max,
      divisions: _miuixSourceStepsToDivisions(steps),
      onChangeFinished: onValueChangeFinished,
      sliderHeight: sliderHeight,
      sliderColors: sliderColors,
      hapticEffect: hapticEffect,
      showKeyPoints: showKeyPoints,
      keyPoints: keyPoints ?? const <double>[],
      magnetThreshold: magnetThreshold,
      insideMargin: insideMargin,
      holdDown: holdDownState,
      enabled: enabled,
      sourceStyle: true,
    );
  }

  /// Main title; the upstream component allows it to be absent.
  final String? title;

  /// Optional summary.
  final String? summary;

  /// Source title foreground pair.
  final MiuixBasicComponentColors? titleColors;

  /// Source summary foreground pair.
  final MiuixBasicComponentColors? summaryColors;

  /// Optional formatted range shown at the end of the title row.
  final String? valueText;

  /// Optional row action independent of dragging either thumb.
  final VoidCallback? onTap;

  /// Current range.
  final RangeValues values;

  /// Change callback.
  final ValueChanged<RangeValues> onChanged;

  /// Minimum value.
  final double min;

  /// Maximum value.
  final double max;

  /// Optional count of equal slider divisions.
  final int? divisions;

  /// Whether value markers are painted along the range track.
  final bool showKeyPoints;

  /// Absolute values used as visible and magnetic key points.
  final List<double> keyPoints;

  /// Magnetic snap radius expressed as a normalized range fraction.
  final double magnetThreshold;

  /// Called after a pointer finishes changing the range.
  final VoidCallback? onChangeFinished;

  /// Height of the embedded source range slider.
  final double sliderHeight;

  /// Optional source eight-channel slider palette.
  final MiuixSliderColors? sliderColors;

  /// Source feedback mode, defaulting to edge-only feedback.
  final MiuixSliderHapticEffect hapticEffect;

  /// Optional content before the title area.
  final Widget? leading;

  /// Optional content after [valueText].
  final Widget? trailing;

  /// Optional content above the slider in the bottom action area.
  final Widget? bottomAction;

  /// Source padding around the complete preference content.
  final EdgeInsetsGeometry insideMargin;

  /// Whether the source row indication remains held.
  final bool holdDown;

  /// Whether the preference range slider is interactive.
  final bool enabled;

  /// Whether the surrounding row uses MIUIX 1.0.9 visual metrics.
  ///
  /// Prefer [MiuixRangeSliderPreference.source] for application call sites.
  final bool sourceStyle;

  @override
  Widget build(BuildContext context) {
    final range = _safeRange(min, max);
    final safeValues = _normalizeSliderCallbackRange(values, range);
    final semantic = MiuixSemanticColors.of(context);
    final valueLabel = valueText == null
        ? null
        : Text(
            valueText!,
            style: MiuixTheme.of(context).textTheme.bodyMedium?.copyWith(
              color: enabled
                  ? semantic['onSurfaceVariantActions']
                  : semantic['disabledOnSecondaryVariant'],
            ),
          );
    final actionContent = switch ((valueLabel, trailing)) {
      (null, null) => null,
      (final Widget label, null) => label,
      (null, final Widget action) => action,
      (final Widget label, final Widget action) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [label, action],
      ),
    };
    final showArrow = onTap != null;
    final showEndArea = actionContent != null || showArrow;
    final arrowColor = MiuixArrowPreferenceDefaults.endActionColors(
      context,
    ).resolve(enabled);
    final endArea = !showEndArea
        ? null
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (actionContent != null) Flexible(child: actionContent),
              // RangeSliderPreference.kt applies this inset to the whole
              // value/end-actions Row, even when the only sibling is an arrow.
              const SizedBox(width: 8),
              if (showArrow)
                _MiuixArrowRight(
                  color: arrowColor,
                  rtl: Directionality.of(context) == TextDirection.rtl,
                ),
            ],
          );
    return MiuixPreference(
      title: title ?? '',
      showTitle: title != null,
      titleColors: titleColors,
      summary: summary,
      summaryColors: summaryColors,
      leading: leading,
      trailing: endArea,
      onTap: enabled ? onTap : null,
      holdDown: holdDown,
      enabled: enabled,
      insideMargin: insideMargin,
      sourceStyle: sourceStyle,
      bottomAction: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ?bottomAction,
          MiuixRangeSlider(
            values: safeValues,
            min: range.min,
            max: range.max,
            divisions: divisions,
            showKeyPoints: showKeyPoints,
            keyPoints: keyPoints,
            magnetThreshold: magnetThreshold,
            onChangeFinished: onChangeFinished,
            height: sliderHeight,
            colors: sliderColors,
            hapticEffect: hapticEffect,
            enabled: enabled,
            onChanged: (next) =>
                onChanged(_normalizeSliderCallbackRange(next, range)),
          ),
        ],
      ),
    );
  }
}

/// Group container for settings pages.
class MiuixSettingsGroup extends StatelessWidget {
  /// Creates a HyperOS 4 settings group with one shared glass surface.
  const MiuixSettingsGroup({
    super.key,
    required this.children,
    this.title,
    this.showDividers = false,
    this.glass = true,
    this.glassBlur,
    this.glassOpacity,
    this.showGlassSpecular = true,
    this.cornerRadius = double.nan,
    this.surfaceColor,
    this.border,
  });

  /// Creates the former opaque settings-group surface.
  const MiuixSettingsGroup.source({
    super.key,
    required this.children,
    this.title,
    this.showDividers = false,
    this.cornerRadius = double.nan,
    this.surfaceColor,
    this.border,
  }) : glass = false,
       glassBlur = null,
       glassOpacity = null,
       showGlassSpecular = false;

  /// Optional section title.
  final String? title;

  /// Preference rows.
  final List<Widget> children;

  /// Whether to add separators that are not present in MIUIX `Card` itself.
  final bool showDividers;

  /// Whether the complete group participates in the shared glass system.
  final bool glass;

  /// Optional local material overrides.
  final double? glassBlur;
  final double? glassOpacity;
  final bool showGlassSpecular;

  /// Optional local shape and paint overrides.
  final double cornerRadius;
  final Color? surfaceColor;
  final BorderSide? border;

  @override
  Widget build(BuildContext context) {
    final theme = MiuixTheme.of(context);
    final materialTheme = Theme.of(context);
    final hyperOs4 = theme.hyperOs4;
    final radius = cornerRadius.isFinite
        ? cornerRadius.clamp(0.0, double.infinity).toDouble()
        : hyperOs4.settingsGroupCornerRadius;
    final resolvedColor =
        surfaceColor ?? materialTheme.colorScheme.surfaceContainerLow;
    final resolvedBorder =
        border ??
        BorderSide(
          color: materialTheme.colorScheme.outlineVariant.withValues(
            alpha: .10,
          ),
          width: .5,
        );
    if (children.isEmpty) {
      return title == null
          ? const SizedBox.shrink()
          : Padding(
              padding: EdgeInsets.fromLTRB(
                theme.spacing.lg,
                theme.spacing.lg,
                theme.spacing.lg,
                theme.spacing.sm,
              ),
              child: Text(
                title!,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: EdgeInsets.fromLTRB(
              theme.spacing.lg,
              theme.spacing.lg,
              theme.spacing.lg,
              theme.spacing.xs,
            ),
            child: Text(
              title!,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        MiuixSurface(
          key: const ValueKey('miuix-settings-group-surface'),
          padding: EdgeInsets.zero,
          radius: radius,
          color: resolvedColor,
          border: resolvedBorder,
          glass: glass,
          glassBlur: glassBlur ?? hyperOs4.contentSurfaceBlur,
          glassOpacity: glassOpacity ?? hyperOs4.contentSurfaceTintOpacity,
          showGlassSpecular: showGlassSpecular,
          child: Column(
            children: [
              for (var index = 0; index < children.length; index++) ...[
                children[index],
                if (showDividers && index != children.length - 1)
                  Divider(
                    height: 1,
                    thickness: .5,
                    indent: 16,
                    endIndent: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.outlineVariant.withValues(alpha: .24),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
