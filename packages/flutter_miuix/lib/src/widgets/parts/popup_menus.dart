part of '../miuix_widgets.dart';

/// Action sheet item.
@immutable
class MiuixActionSheetItem {
  /// Creates an action sheet item.
  const MiuixActionSheetItem({
    required this.label,
    required this.onTap,
    this.icon,
    this.summary,
    this.enabled = true,
    this.selected = false,
    this.semanticLabel,
    this.destructive = false,
  });

  /// Action label.
  final String label;

  /// Optional icon.
  final Widget? icon;

  /// Optional supporting copy shown below [label].
  final String? summary;

  /// Tap callback.
  final VoidCallback onTap;

  /// Interaction, selected-state, and accessibility metadata.
  final bool enabled;
  final bool selected;
  final String? semanticLabel;

  /// Whether this is a destructive action.
  final bool destructive;
}

class _MiuixMenuRow extends StatelessWidget {
  const _MiuixMenuRow({
    required this.label,
    this.summary,
    this.icon,
    this.onTap,
    this.enabled = true,
    this.destructive = false,
    this.indent,
    this.isFirst = false,
    this.isLast = false,
    this.selected = false,
    this.trailing,
    this.allowTextWrap = false,
  });

  final String label;
  final String? summary;
  final Widget? icon;
  final VoidCallback? onTap;
  final bool enabled;
  final bool destructive;
  final double? indent;
  final bool isFirst;
  final bool isLast;
  final bool selected;
  final Widget? trailing;
  final bool allowTextWrap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final metrics = debugMiuixDropdownMetrics(isFirst: isFirst, isLast: isLast);
    final textColor = !enabled
        ? scheme.onSurface.withValues(alpha: .38)
        : destructive
        ? scheme.error
        : selected
        ? scheme.primary
        : scheme.onSurface;
    final iconColor = !enabled
        ? scheme.onSurface.withValues(alpha: .38)
        : destructive
        ? scheme.error
        : selected
        ? scheme.primary
        : scheme.onSurfaceVariant;
    final titleStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
      color: textColor,
      fontWeight: FontWeight.w500,
      // DropdownImpl reads body1.fontSize, which is 16sp in the source.
      fontSize: metrics.textFontSize,
    );
    final summaryStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: textColor.withValues(alpha: .62),
      fontSize: 14,
    );
    final textBudget =
        metrics.maxItemTextWidth -
        6 -
        (icon == null ? 0 : metrics.iconMinSize + metrics.iconEndPadding);
    bool wrapsAtSourceWidth(String text, TextStyle? style) {
      if (!allowTextWrap || text.isEmpty) return false;
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout(maxWidth: textBudget);
      return painter.computeLineMetrics().length > 1;
    }

    final titleWraps = wrapsAtSourceWidth(label, titleStyle);
    final summaryWraps = summary != null
        ? wrapsAtSourceWidth(summary!, summaryStyle)
        : false;
    return MiuixPressable(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(15),
      feedbackType: MiuixPressFeedbackType.none,
      showIndication: enabled,
      // DropdownImpl.kt does not impose a 56dp Material touch-row height.
      // Its height is exactly body1 text plus 20/12dp edge padding on the
      // first and last rows and 12dp on the inner edges. Keeping the padding
      // as the direct child also lets IntrinsicWidth reproduce the source's
      // 200..288dp widest-item measurement instead of expanding every row.
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: (indent ?? metrics.horizontalPadding) + .0,
          end: metrics.horizontalPadding,
          top: metrics.topPadding,
          bottom: metrics.bottomPadding,
        ),
        child: Row(
          children: [
            // Popup width is resolved by an IntrinsicWidth ancestor. During
            // that pass, the outer Row asks each child for its natural width
            // before the final 200..288dp constraint is selected.
            //
            // A Flexible here would report zero intrinsic width and make the
            // popup settle at its 200dp minimum even when the label, summary,
            // and optional icon require more room. The later layout pass would
            // then receive a width that cannot contain the same content that
            // was used to choose it, producing a RenderFlex overflow.
            //
            // The first ConstrainedBox instead caps the content at the exact
            // MIUIX text budget while retaining its natural intrinsic width.
            // The nested Row remains `min` sized so short localized labels do
            // not stretch a popup beyond the upstream width calculation.
            //
            // The second constraint subtracts the fixed leading-icon slot.
            // That subtraction must happen before text layout; truncating only
            // after the Row is laid out would count the icon twice and shift
            // the trailing selected check beyond the popup surface.
            //
            // Align uses `widthFactor: 1` for the same reason. Without it, an
            // Align in an unbounded intrinsic pass can claim the maximum width
            // rather than the actual one-line label width.
            //
            // Spacer is deliberately outside this bounded content group. It
            // consumes only the width left after the intrinsic popup decision
            // and therefore places the selected check at the trailing inset
            // without influencing the label's natural measurement.
            //
            // This structure mirrors Compose's measurement order: measure the
            // optional icon, measure the one-line text column, reserve the
            // trailing affordance, and finally clamp the complete row.
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: metrics.maxItemTextWidth - 6,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: metrics.iconMinSize,
                        minHeight: metrics.iconMinSize,
                      ),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: IconTheme(
                          data: IconThemeData(color: iconColor, size: 18),
                          child: icon!,
                        ),
                      ),
                    ),
                    SizedBox(width: metrics.iconEndPadding),
                  ],
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth:
                          metrics.maxItemTextWidth -
                          6 -
                          (icon == null
                              ? 0
                              : metrics.iconMinSize + metrics.iconEndPadding),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ConstrainedBox(
                          // Accumulate the source's fractional Compose line
                          // box before the popup is rounded to device pixels.
                          // At the reference 420dpi density this is exactly
                          // 54px. Letting each Text round independently makes
                          // four rows jump between 192dp and 196dp in Flutter.
                          constraints: BoxConstraints(
                            minHeight: summary == null
                                ? metrics.textLineHeight
                                : metrics.summaryTitleLineHeight,
                            maxHeight: titleWraps
                                ? double.infinity
                                : summary == null
                                ? metrics.textLineHeight
                                : metrics.summaryTitleLineHeight,
                          ),
                          child: Align(
                            alignment: AlignmentDirectional.centerStart,
                            widthFactor: 1,
                            child: Text(
                              label,
                              maxLines: titleWraps ? null : 1,
                              overflow: titleWraps
                                  ? TextOverflow.clip
                                  : TextOverflow.ellipsis,
                              style: titleStyle,
                            ),
                          ),
                        ),
                        if (summary != null)
                          ConstrainedBox(
                            // Compose resolves the source 14sp body2 through
                            // its Android font metrics to a 14.8dp line box.
                            // Flutter's unconstrained CJK bodySmall is about
                            // 1.1dp taller, which accumulated to a 12px error
                            // across the four rows in SpinnerSection.
                            constraints: BoxConstraints(
                              minHeight: metrics.summaryLineHeight,
                              maxHeight: summaryWraps
                                  ? double.infinity
                                  : metrics.summaryLineHeight,
                            ),
                            child: Align(
                              alignment: AlignmentDirectional.centerStart,
                              widthFactor: 1,
                              child: Text(
                                summary!,
                                maxLines: summaryWraps ? null : 1,
                                overflow: summaryWraps
                                    ? TextOverflow.clip
                                    : TextOverflow.ellipsis,
                                style: summaryStyle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            if (trailing != null) ...[
              SizedBox(width: metrics.checkIconStartPadding),
              IconTheme(
                data: IconThemeData(
                  color: iconColor,
                  size: metrics.checkIconSize,
                ),
                child: trailing!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Exposes MIUIX dropdown row source metrics for regression tests.
///
/// These values are kept together because the popup's final size is the sum
/// of several independent Compose tokens. Changing only a font size or only a
/// padding value can make a single row look plausible while the complete
/// Spinner menu drifts by several physical pixels.
///
/// The returned fields correspond to the following upstream responsibilities:
///
/// * `minHeight` records that MIUIX does not force a Material 56dp row.
/// * `minWidth` is the lower bound used by `DropdownImpl`.
/// * `horizontalPadding` is applied on both logical edges of every row.
/// * `topPadding` includes the larger first-row outer inset.
/// * `bottomPadding` includes the larger last-row outer inset.
/// * `iconMinSize` reserves the Compose icon slot before text measurement.
/// * `iconEndPadding` separates an optional leading icon from its label.
/// * `checkIconSize` matches the selected-item trailing glyph.
/// * `checkIconStartPadding` keeps the check away from the text column.
/// * `maxItemTextWidth` preserves the source popup's 288dp upper bound.
/// * `textFontSize` mirrors the upstream `body1` font-size lookup.
/// * `textLineHeight` preserves the fractional Android body1 line box.
/// * `summaryTitleLineHeight` preserves the effective body1 line box when it
///   is stacked with body2 inside SpinnerItemImpl.
/// * `summaryLineHeight` preserves the fractional Android body2 line box.
///
/// First and last are inputs instead of separate constants because Compose
/// applies its outer padding at row level. This lets both production layout
/// and regression tests exercise the same edge-row calculation.
@visibleForTesting
({
  double minHeight,
  double minWidth,
  double horizontalPadding,
  double topPadding,
  double bottomPadding,
  double iconMinSize,
  double iconEndPadding,
  double checkIconSize,
  double checkIconStartPadding,
  double maxItemTextWidth,
  double textFontSize,
  double textLineHeight,
  double summaryTitleLineHeight,
  double summaryLineHeight,
})
debugMiuixDropdownMetrics({required bool isFirst, required bool isLast}) {
  return (
    minHeight: 0,
    minWidth: 200,
    horizontalPadding: 20,
    topPadding: isFirst ? 20 : 12,
    bottomPadding: isLast ? 20 : 12,
    iconMinSize: 26,
    iconEndPadding: 12,
    checkIconSize: 20,
    checkIconStartPadding: 12,
    maxItemTextWidth: 216,
    textFontSize: 16,
    // 54 physical pixels at 2.625 density. Besides matching the Android text
    // placeable, this makes the three-row context menu's true hit boundaries
    // exactly y=322 and y=439 instead of the visually rounded y=322.075 and
    // y=439.15. The upstream accessibility tree reports y=318 for its first
    // row, but direct pointer probes prove that exported bound is inaccurate.
    textLineHeight: 54 / 2.625,
    // SpinnerItemImpl measures body1 and body2 as two independent Text
    // placeables. Retaining this effective height keeps the source four-row
    // popup at 666 physical pixels while the one-line DropdownImpl boundary
    // remains exactly pixel aligned.
    summaryTitleLineHeight: 20.6,
    summaryLineHeight: 14.8,
  );
}

/// HyperOS-style action sheet.
class MiuixActionSheet {
  /// Shows an action sheet.
  static Future<void> show({
    required BuildContext context,
    required List<MiuixActionSheetItem> actions,
    String? title,
    String? message,
    String? cancelLabel,
    bool allowDismiss = true,
    bool glass = true,
  }) {
    if (actions.isEmpty || !context.mounted) {
      return Future<void>.value();
    }
    final navigator = Navigator.maybeOf(context, rootNavigator: true);
    return MiuixBottomSheet.show<void>(
      context: context,
      title: title,
      allowDismiss: allowDismiss,
      glass: glass,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: MiuixSemanticColors.of(
                        context,
                      )['onSurfaceSecondary'],
                    ),
                  ),
                ),
              ),
            for (var index = 0; index < actions.length; index++)
              Semantics(
                label: actions[index].semanticLabel,
                child: _MiuixMenuRow(
                  icon: actions[index].icon,
                  label: actions[index].label,
                  summary: actions[index].summary,
                  enabled: actions[index].enabled,
                  selected: actions[index].selected,
                  trailing: actions[index].selected
                      ? _MiuixDropdownCheck(
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  destructive: actions[index].destructive,
                  isFirst: index == 0,
                  isLast: index == actions.length - 1,
                  onTap: () {
                    if (navigator?.mounted == true && navigator!.canPop()) {
                      navigator.pop();
                    }
                    MiuixHaptics.perform(
                      actions[index].destructive
                          ? MiuixHapticType.gestureThresholdActivate
                          : MiuixHapticType.confirm,
                    );
                    actions[index].onTap();
                  },
                ),
              ),
            if (cancelLabel != null) ...[
              const SizedBox(height: 8),
              MiuixButton(
                label: cancelLabel,
                expand: true,
                onPressed: () {
                  if (navigator?.mounted == true && navigator!.canPop()) {
                    navigator.pop();
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Selects whether a popup is hosted by Scaffold or a window-level route.
enum MiuixPopupPresentation { overlay, window }

/// Alignment of a popup relative to its trigger.
enum MiuixPopupAlignment {
  start,
  end,
  topStart,
  topEnd,
  bottomStart,
  bottomEnd,
}

/// Source positioning formula used to place an anchored popup.
///
/// Dropdowns keep an eight-dp vertical gap and choose below/above according to
/// available space. Context menus use the upstream twenty-dp horizontal margin
/// with no vertical gap and honor the requested above/below alignment.
enum MiuixPopupPositioning { dropdown, contextMenu }

({Alignment target, Alignment follower}) _miuixPopupAnchors(
  BuildContext context,
  MiuixPopupAlignment alignment,
) {
  final rtl = Directionality.of(context) == TextDirection.rtl;
  final start = rtl ? Alignment.centerRight : Alignment.centerLeft;
  final end = rtl ? Alignment.centerLeft : Alignment.centerRight;
  final topStart = rtl ? Alignment.topRight : Alignment.topLeft;
  final topEnd = rtl ? Alignment.topLeft : Alignment.topRight;
  final bottomStart = rtl ? Alignment.bottomRight : Alignment.bottomLeft;
  final bottomEnd = rtl ? Alignment.bottomLeft : Alignment.bottomRight;
  return switch (alignment) {
    MiuixPopupAlignment.start => (target: start, follower: start),
    MiuixPopupAlignment.end => (target: end, follower: end),
    MiuixPopupAlignment.topStart => (target: topStart, follower: bottomStart),
    MiuixPopupAlignment.topEnd => (target: topEnd, follower: bottomEnd),
    MiuixPopupAlignment.bottomStart => (
      target: bottomStart,
      follower: topStart,
    ),
    MiuixPopupAlignment.bottomEnd => (target: bottomEnd, follower: topEnd),
  };
}

/// Matches the original dropdown provider's eight-dp anchor separation.
Offset _miuixPopupOffset(MiuixPopupAlignment alignment) {
  return switch (alignment) {
    MiuixPopupAlignment.bottomStart ||
    MiuixPopupAlignment.bottomEnd => const Offset(0, 8),
    MiuixPopupAlignment.topStart ||
    MiuixPopupAlignment.topEnd => const Offset(0, -8),
    _ => Offset.zero,
  };
}

Rect? _miuixGlobalRect(BuildContext context) {
  final renderObject = context.findRenderObject();
  if (renderObject is! RenderBox ||
      !renderObject.hasSize ||
      !renderObject.attached) {
    return null;
  }
  final density = View.of(context).devicePixelRatio;
  final position = renderObject.localToGlobal(Offset.zero);

  // ListPopupLayout.kt builds its IntRect by truncating positionInWindow,
  // then adding the already measured integer width and height. Rounding the
  // far edge directly is not equivalent at fractional Android densities:
  // (position + size).round() can be one pixel larger than
  // position.toInt() + size.roundToPx().
  final leftPixels = (position.dx * density).truncate();
  final topPixels = (position.dy * density).truncate();
  final widthPixels = (renderObject.size.width * density).round();
  final heightPixels = (renderObject.size.height * density).round();
  return Rect.fromLTWH(
    leftPixels / density,
    topPixels / density,
    widthPixels / density,
    heightPixels / density,
  );
}

// Positions every dropdown family through one source-compatible algorithm.
//
// Compose asks its PopupPositionProvider for an IntOffset after measuring the
// anchor and popup in physical pixels. Flutter normally keeps those values as
// logical doubles until painting. At fractional Android densities the two
// coordinate systems can disagree by one pixel even when their dp constants
// are identical. This delegate therefore preserves Flutter's exact horizontal
// composited edge, but performs the source's vertical comparisons, midpoint,
// and margin arithmetic in integer physical pixels before converting back.
// Overlay and window popup APIs both use this delegate so they cannot drift.
