part of '../miuix_widgets.dart';

/// Immutable colors consumed by the source-level dropdown row.
///
/// Current MIUIX keeps title, summary, container, and indicator channels
/// independent. Optional compatibility arguments fall back to the former
/// four-channel meanings so existing callers retain their rendered colors.
@immutable
class MiuixDropdownColors {
  /// Creates a complete dropdown color set.
  const MiuixDropdownColors({
    required this.contentColor,
    Color? summaryColor,
    required this.containerColor,
    required this.selectedContentColor,
    Color? selectedSummaryColor,
    required this.selectedContainerColor,
    Color? selectedIndicatorColor,
  }) : summaryColor = summaryColor ?? contentColor,
       selectedSummaryColor = selectedSummaryColor ?? selectedContentColor,
       selectedIndicatorColor = selectedIndicatorColor ?? selectedContentColor;

  /// Foreground for an ordinary option.
  final Color contentColor;

  /// Supporting-text foreground for an ordinary option.
  final Color summaryColor;

  /// Background for an ordinary option.
  final Color containerColor;

  /// Foreground and check tint for the selected option.
  final Color selectedContentColor;

  /// Supporting-text foreground for a selected option.
  final Color selectedSummaryColor;

  /// Background for the selected option.
  final Color selectedContainerColor;

  /// Trailing-check foreground for a selected option.
  final Color selectedIndicatorColor;
}

/// Source defaults for [MiuixDropdownImpl].
abstract final class MiuixDropdownDefaults {
  /// Resolves the seven current upstream semantic color roles.
  static MiuixDropdownColors colors(
    BuildContext context, {
    Color? contentColor,
    Color? summaryColor,
    Color? containerColor,
    Color? selectedContentColor,
    Color? selectedSummaryColor,
    Color? selectedContainerColor,
    Color? selectedIndicatorColor,
  }) {
    final semantic = MiuixSemanticColors.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    return MiuixDropdownColors(
      contentColor: contentColor ?? semantic['onSurfaceContainer'],
      summaryColor: summaryColor ?? semantic['onSurfaceVariantSummary'],
      containerColor: containerColor ?? semantic['surfaceContainer'],
      selectedContentColor: selectedContentColor ?? primary,
      selectedSummaryColor: selectedSummaryColor ?? primary,
      selectedContainerColor:
          selectedContainerColor ?? semantic['surfaceContainer'],
      selectedIndicatorColor: selectedIndicatorColor ?? primary,
    );
  }

  /// Resolves the distinct current dialog palette.
  static MiuixDropdownColors dialogColors(
    BuildContext context, {
    Color? contentColor,
    Color? summaryColor,
    Color? containerColor,
    Color? selectedContentColor,
    Color? selectedSummaryColor,
    Color? selectedContainerColor,
    Color? selectedIndicatorColor,
  }) {
    final semantic = MiuixSemanticColors.of(context);
    final selected = semantic['onTertiaryContainer'];
    return MiuixDropdownColors(
      contentColor: contentColor ?? semantic['onSurfaceContainer'],
      summaryColor: summaryColor ?? semantic['onSurfaceVariantSummary'],
      containerColor: containerColor ?? Colors.transparent,
      selectedContentColor: selectedContentColor ?? selected,
      selectedSummaryColor: selectedSummaryColor ?? selected,
      selectedContainerColor:
          selectedContainerColor ?? semantic['tertiaryContainer'],
      selectedIndicatorColor: selectedIndicatorColor ?? selected,
    );
  }
}

/// Deprecated-name compatibility type for the current dropdown palette.
///
/// Upstream `SpinnerColors` is now a compatibility name for `DropdownColors`.
@immutable
class MiuixSpinnerColors extends MiuixDropdownColors {
  /// Creates a complete spinner color set.
  const MiuixSpinnerColors({
    required super.contentColor,
    required super.summaryColor,
    required super.containerColor,
    required super.selectedContentColor,
    required super.selectedSummaryColor,
    required super.selectedContainerColor,
    required super.selectedIndicatorColor,
  });
}

/// Source defaults for [MiuixSpinnerItemImpl].
abstract final class MiuixSpinnerDefaults {
  /// Colors used by an anchored spinner popup.
  static MiuixSpinnerColors colors(
    BuildContext context, {
    Color? contentColor,
    Color? summaryColor,
    Color? containerColor,
    Color? selectedContentColor,
    Color? selectedSummaryColor,
    Color? selectedContainerColor,
    Color? selectedIndicatorColor,
  }) {
    final semantic = MiuixSemanticColors.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    return MiuixSpinnerColors(
      contentColor: contentColor ?? semantic['onSurfaceContainer'],
      summaryColor: summaryColor ?? semantic['onSurfaceVariantSummary'],
      containerColor: containerColor ?? semantic['surfaceContainer'],
      selectedContentColor: selectedContentColor ?? primary,
      selectedSummaryColor: selectedSummaryColor ?? primary,
      selectedContainerColor:
          selectedContainerColor ?? semantic['surfaceContainer'],
      selectedIndicatorColor: selectedIndicatorColor ?? primary,
    );
  }

  /// Colors used by the spinner's dialog presentation.
  static MiuixSpinnerColors dialogColors(
    BuildContext context, {
    Color? contentColor,
    Color? summaryColor,
    Color? containerColor,
    Color? selectedContentColor,
    Color? selectedSummaryColor,
    Color? selectedContainerColor,
    Color? selectedIndicatorColor,
  }) {
    final semantic = MiuixSemanticColors.of(context);
    final selected = semantic['onTertiaryContainer'];
    return MiuixSpinnerColors(
      contentColor: contentColor ?? semantic['onSurfaceContainer'],
      summaryColor: summaryColor ?? semantic['onSurfaceVariantSummary'],
      containerColor: containerColor ?? Colors.transparent,
      selectedContentColor: selectedContentColor ?? selected,
      selectedSummaryColor: selectedSummaryColor ?? selected,
      selectedContainerColor:
          selectedContainerColor ?? semantic['tertiaryContainer'],
      selectedIndicatorColor: selectedIndicatorColor ?? selected,
    );
  }
}

/// One source spinner entry.
///
/// Unlike [MiuixDropdownEntry], this mirrors `SpinnerEntry`: title and summary
/// may independently be absent and the icon is presentation-only.
@immutable
class MiuixSpinnerEntry {
  /// Creates a spinner entry.
  const MiuixSpinnerEntry({
    this.icon,
    this.title,
    this.summary,
    this.enabled = true,
  });

  /// Optional leading icon.
  final Widget? icon;

  /// Optional primary line.
  final String? title;

  /// Optional secondary line.
  final String? summary;

  /// Whether the current source item accepts selection input.
  final bool enabled;
}

/// The exact 10×16 ArrowUpDown trailing action used by preferences.
class MiuixDropdownArrowEndAction extends StatelessWidget {
  /// Creates the source trailing arrow.
  const MiuixDropdownArrowEndAction({super.key, required this.actionColor});

  /// Arrow tint.
  final Color actionColor;

  @override
  Widget build(BuildContext context) => _MiuixDropdownArrow(color: actionColor);
}

/// Direct Flutter counterpart of MIUIX `DropdownImpl`.
///
/// The first and last rows receive 20dp outer padding; inner edges remain
/// 12dp. A transparent 20dp check is always measured so selected and ordinary
/// rows have identical intrinsic width.
class MiuixDropdownImpl extends StatelessWidget {
  /// Creates one dropdown option row.
  const MiuixDropdownImpl({
    super.key,
    required this.text,
    required this.optionSize,
    required this.isSelected,
    required this.index,
    required this.onSelectedIndexChange,
    this.colors,
    this.icon,
    this.summary,
    this.enabled = true,
    this.dialogMode = false,
    this.isFirst,
    this.isLast,
  });

  /// Text of this option.
  final String text;

  /// Total number of options.
  final int optionSize;

  /// Whether this row is selected.
  final bool isSelected;

  /// Index reported when the row is tapped.
  final int index;

  /// Optional explicit color set.
  final MiuixDropdownColors? colors;

  /// Optional leading content from the current `DropdownItem` model.
  final Widget? icon;

  /// Optional secondary line from the current `DropdownItem` model.
  final String? summary;

  /// Whether this item exposes selection input.
  final bool enabled;

  /// Whether the row uses full-width dialog geometry.
  final bool dialogMode;

  /// Popup-global first-row override used by grouped entries.
  final bool? isFirst;

  /// Popup-global last-row override used by grouped entries.
  final bool? isLast;

  /// Selection callback.
  final ValueChanged<int> onSelectedIndexChange;

  @override
  Widget build(BuildContext context) {
    final safeIndex = math.max(0, index);
    final safeOptionSize = math.max(optionSize, safeIndex + 1);
    final resolved = colors ?? MiuixDropdownDefaults.colors(context);
    final semantic = MiuixSemanticColors.of(context);
    final selectedIndicator = !isSelected
        ? Colors.transparent
        : enabled
        ? resolved.selectedIndicatorColor
        : semantic['disabledOnSecondaryVariant'];
    final selectedTitle = isSelected
        ? resolved.selectedContentColor
        : resolved.contentColor;
    final selectedSummary = isSelected
        ? resolved.selectedSummaryColor
        : resolved.summaryColor;
    return _MiuixSourcePopupRow(
      title: text,
      summary: summary,
      icon: icon,
      selected: isSelected,
      titleColor: enabled
          ? selectedTitle
          : semantic['disabledOnSecondaryVariant'],
      summaryColor: enabled
          ? selectedSummary
          : semantic['disabledOnSecondaryVariant'],
      backgroundColor: isSelected
          ? resolved.selectedContainerColor
          : resolved.containerColor,
      indicatorColor: selectedIndicator,
      horizontalPadding: dialogMode ? 28 : 20,
      topPadding: !dialogMode && (isFirst ?? safeIndex == 0) ? 20 : 12,
      bottomPadding: !dialogMode && (isLast ?? safeIndex == safeOptionSize - 1)
          ? 20
          : 12,
      minHeight: dialogMode ? 56 : 0,
      minWidth: dialogMode ? 200 : 0,
      fillWidth: dialogMode,
      // DropdownDefaults.MaxItemTextWidth is 216dp in the current source.
      // The complete popup can therefore reach 288dp after the two 20dp row
      // insets, the 12dp check gap, and the 20dp check itself are included.
      maxLeadingContentWidth: dialogMode ? null : 216,
      allowTextWrap: true,
      onTap: enabled ? () => onSelectedIndexChange(safeIndex) : null,
    );
  }
}

/// Direct Flutter counterpart of MIUIX `SpinnerItemImpl`.
class MiuixSpinnerItemImpl extends StatelessWidget {
  /// Creates one spinner option row.
  const MiuixSpinnerItemImpl({
    super.key,
    required this.entry,
    required this.entryCount,
    required this.isSelected,
    required this.index,
    required this.onSelectedIndexChange,
    this.colors,
    this.dialogMode = false,
    this.isFirst,
    this.isLast,
  });

  /// Spinner entry rendered by this row.
  final MiuixSpinnerEntry entry;

  /// Number of sibling entries.
  final int entryCount;

  /// Whether this row is selected.
  final bool isSelected;

  /// Index reported when tapped.
  final int index;

  /// Optional explicit colors.
  final MiuixDropdownColors? colors;

  /// Whether to use full-width dialog geometry.
  final bool dialogMode;

  /// Popup-global first row override for entries-based groups.
  final bool? isFirst;

  /// Popup-global last row override for entries-based groups.
  final bool? isLast;

  /// Selection callback.
  final ValueChanged<int> onSelectedIndexChange;

  @override
  Widget build(BuildContext context) {
    final safeIndex = math.max(0, index);
    final safeEntryCount = math.max(entryCount, safeIndex + 1);
    final resolved =
        colors ??
        (dialogMode
            ? MiuixSpinnerDefaults.dialogColors(context)
            : MiuixSpinnerDefaults.colors(context));
    final semantic = MiuixSemanticColors.of(context);
    final enabled = entry.enabled;
    return _MiuixSourcePopupRow(
      title: entry.title,
      summary: entry.summary,
      icon: entry.icon,
      selected: isSelected,
      titleColor: !enabled
          ? semantic['disabledOnSecondaryVariant']
          : isSelected
          ? resolved.selectedContentColor
          : resolved.contentColor,
      summaryColor: !enabled
          ? semantic['disabledOnSecondaryVariant']
          : isSelected
          ? resolved.selectedSummaryColor
          : resolved.summaryColor,
      backgroundColor: isSelected
          ? resolved.selectedContainerColor
          : resolved.containerColor,
      indicatorColor: !isSelected
          ? Colors.transparent
          : enabled
          ? resolved.selectedIndicatorColor
          : semantic['disabledOnSecondaryVariant'],
      horizontalPadding: dialogMode ? 28 : 20,
      topPadding: !dialogMode && (isFirst ?? safeIndex == 0) ? 20 : 12,
      bottomPadding: !dialogMode && (isLast ?? safeIndex == safeEntryCount - 1)
          ? 20
          : 12,
      minHeight: dialogMode ? 56 : 0,
      minWidth: dialogMode ? 200 : 0,
      fillWidth: dialogMode,
      maxLeadingContentWidth: dialogMode ? null : 216,
      onTap: enabled ? () => onSelectedIndexChange(safeIndex) : null,
    );
  }
}

/// Shared source row for DropdownImpl and SpinnerItemImpl.
///
/// This is intentionally not a Material ListTile. ListTile would force a
/// platform row height and would no longer reproduce the source's text-driven
/// 12/20dp vertical measurements.
class _MiuixSourcePopupRow extends StatelessWidget {
  const _MiuixSourcePopupRow({
    required this.selected,
    required this.titleColor,
    required this.summaryColor,
    required this.backgroundColor,
    required this.indicatorColor,
    required this.topPadding,
    required this.bottomPadding,
    required this.onTap,
    this.title,
    this.summary,
    this.icon,
    this.horizontalPadding = 20,
    this.minHeight = 0,
    this.minWidth = 0,
    this.fillWidth = false,
    this.maxLeadingContentWidth,
    this.allowTextWrap = false,
  });

  final String? title;
  final String? summary;
  final Widget? icon;
  final bool selected;
  final Color titleColor;
  final Color summaryColor;
  final Color backgroundColor;
  final Color indicatorColor;
  final double horizontalPadding;
  final double topPadding;
  final double bottomPadding;
  final double minHeight;
  final double minWidth;
  final bool fillWidth;
  final double? maxLeadingContentWidth;
  final bool allowTextWrap;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Compose converts each horizontal padding value with roundToPx before
    // measuring the row. This matters at Android's 2.625 density: popup 20dp
    // becomes 53px and dialog 28dp becomes 74px. Leaving Flutter's fractional
    // 52.5/73.5px positions moved every swatch one physical pixel toward the
    // surface edge in the same-device captures.
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final sourceHorizontalPadding = _miuixRoundLogicalDimension(
      horizontalPadding,
      pixelRatio,
    );
    final sourceIconMinimum = _miuixRoundLogicalDimension(26, pixelRatio);
    final sourceIconEndPadding = _miuixRoundLogicalDimension(12, pixelRatio);
    final sourceCheckStartPadding = _miuixRoundLogicalDimension(12, pixelRatio);
    final sourceCheckSize = _miuixRoundLogicalDimension(20, pixelRatio);
    final metrics = debugMiuixDropdownMetrics(
      isFirst: topPadding == 20,
      isLast: bottomPadding == 20,
    );
    final titleStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
      color: titleColor,
      fontWeight: FontWeight.w500,
      fontSize: 16,
    );
    final summaryStyle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: summaryColor, fontSize: 14);
    int measuredLineCount(String? text, TextStyle? style) {
      if (text == null || text.isEmpty || !allowTextWrap) return 1;
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout(maxWidth: maxLeadingContentWidth ?? double.infinity);
      return math.max(1, painter.computeLineMetrics().length);
    }

    final titleLineCount = title == null
        ? 0
        : measuredLineCount(title, titleStyle);
    final summaryLineCount = summary == null
        ? 0
        : measuredLineCount(summary, summaryStyle);
    // Android's 16sp body1 placeable is 54px high for one line at the source
    // 420dpi reference density. Each additional Compose line advances the
    // baseline by 45px, so two wrapped lines occupy 99px rather than 108px.
    // Keeping the first line and continuation advance separate reproduces the
    // native 117px/162px middle-row rhythm exactly.
    const wrappedBody1Advance = 45 / 2.625;
    final titleHeight = titleLineCount == 0
        ? 0.0
        : (summary == null
                  ? metrics.textLineHeight
                  : metrics.summaryTitleLineHeight) +
              (titleLineCount - 1) * wrappedBody1Advance;
    final summaryHeight = summaryLineCount == 0
        ? 0.0
        : metrics.summaryLineHeight +
              (summaryLineCount - 1) * wrappedBody1Advance;
    final sourceTextHeight = titleHeight + summaryHeight;
    // Compose exposes the complete measured row as an integer-pixel
    // placeable. The fractional Flutter line-box model intentionally matches
    // its glyph positions, but 12 + 20.6 + 14.8 + 12dp is 155.925px at 420
    // dpi. Enclosing the complete placeable to 156px keeps every row boundary
    // identical to the native popup and dialog without moving the text.
    final sourceMeasuredMinHeight = _miuixCeilLogicalDimension(
      math.max(minHeight, topPadding + sourceTextHeight + bottomPadding),
      pixelRatio,
    );
    final textColumn = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          SizedBox(
            height: titleHeight,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: 1,
              child: Text(
                title!,
                maxLines: allowTextWrap ? null : 1,
                softWrap: allowTextWrap,
                overflow: allowTextWrap
                    ? TextOverflow.clip
                    : TextOverflow.ellipsis,
                style: titleStyle,
              ),
            ),
          ),
        if (summary != null)
          SizedBox(
            height: summaryHeight,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: 1,
              child: Text(
                summary!,
                maxLines: allowTextWrap ? null : 1,
                softWrap: allowTextWrap,
                overflow: allowTextWrap
                    ? TextOverflow.clip
                    : TextOverflow.ellipsis,
                style: summaryStyle,
              ),
            ),
          ),
      ],
    );
    // SpinnerItemImpl passes `sizeIn(minWidth = 26, minHeight = 26)` and
    // `padding(end = 12)` as one modifier chain to the caller's icon lambda.
    // The 26dp minimum therefore constrains the complete padded icon; it is
    // not a separate 26dp slot followed by another 12dp gap. A normal 24dp
    // icon consequently occupies max(26, 24 + 12) = 36dp, exactly as the
    // source SpinnerSection painter does. The former 38dp model shifted every
    // rich-row title two dp away from its icon.
    final iconSlotWidth = icon == null
        ? 0.0
        : math.max(
            sourceIconMinimum,
            _miuixRoundLogicalDimension(24, pixelRatio) + sourceIconEndPadding,
          );
    double textWidth(String? text, TextStyle? style) {
      if (text == null || text.isEmpty) return 0;
      final painter =
          TextPainter(
            text: TextSpan(text: text, style: style),
            maxLines: 1,
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
          )..layout(
            maxWidth: math.max(
              0,
              (maxLeadingContentWidth ?? double.infinity) - iconSlotWidth,
            ),
          );
      return painter.width;
    }

    final measuredTextWidth = math.max(
      textWidth(title, titleStyle),
      textWidth(summary, summaryStyle),
    );
    final naturalLeadingWidth = maxLeadingContentWidth == null
        ? iconSlotWidth + measuredTextWidth
        : math.min(maxLeadingContentWidth!, iconSlotWidth + measuredTextWidth);
    final naturalPopupWidth =
        sourceHorizontalPadding * 2 +
        naturalLeadingWidth +
        sourceCheckStartPadding +
        sourceCheckSize;
    final boundedTextColumn = maxLeadingContentWidth == null
        ? textColumn
        : ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: math.max(0, maxLeadingContentWidth! - iconSlotWidth),
            ),
            child: textColumn,
          );
    final leading = Row(
      mainAxisSize: fillWidth ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (icon != null)
          ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: sourceIconMinimum,
              minHeight: sourceIconMinimum,
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.only(end: sourceIconEndPadding),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: icon,
              ),
            ),
          ),
        if (fillWidth)
          Expanded(child: textColumn)
        else if (maxLeadingContentWidth != null)
          Flexible(fit: FlexFit.loose, child: boundedTextColumn)
        else
          boundedTextColumn,
      ],
    );
    final boundedLeading = maxLeadingContentWidth == null
        ? leading
        : ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxLeadingContentWidth!),
            child: leading,
          );
    final row = Row(
      mainAxisSize: fillWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (fillWidth)
          Expanded(child: boundedLeading)
        else if (maxLeadingContentWidth != null)
          Flexible(fit: FlexFit.loose, child: boundedLeading)
        else
          boundedLeading,
        Padding(
          padding: EdgeInsetsDirectional.only(start: sourceCheckStartPadding),
          child: _MiuixDropdownCheck(
            color: indicatorColor,
            size: sourceCheckSize,
          ),
        ),
      ],
    );
    return MiuixPressable(
      onTap: onTap,
      feedbackType: MiuixPressFeedbackType.none,
      // A disabled native Dropdown row exposes neither a press indication nor
      // a semantic click action. Keeping indication enabled would make
      // MiuixPressable synthesize an empty tap handler for animation purposes,
      // which Android accessibility then reports as a clickable row.
      showIndication: onTap != null,
      child: ColoredBox(
        color: backgroundColor,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: fillWidth
                ? minWidth
                : math.max(minWidth, naturalPopupWidth),
            minHeight: sourceMeasuredMinHeight,
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              sourceHorizontalPadding,
              topPadding,
              sourceHorizontalPadding,
              bottomPadding,
            ),
            child: row,
          ),
        ),
      ),
    );
  }
}
