part of '../miuix_widgets.dart';

/// Spinner preference for rich option selection.
///
/// The unnamed constructor preserves the package's original generic dropdown
/// entry API. Use the `.source` constructor on the Overlay or Window adapters
/// when mirroring MIUIX `SpinnerPreference`: that form accepts index state and
/// [MiuixSpinnerEntry] objects exactly like the upstream component.
class MiuixSpinnerPreference<T> extends MiuixDropdownPreference<T> {
  /// Creates the compatibility spinner preference.
  const MiuixSpinnerPreference({
    super.key,
    required super.title,
    required super.value,
    required super.entries,
    required super.onChanged,
    super.summary,
    super.presentation,
    super.enabled,
    super.renderInRootScaffold,
    super.onExpandedChange,
    super.dialogConfirmLabel,
    super.closeOnSelection,
    super.popupMinWidth,
    super.popupAnchorOffset,
    super.titleColors,
    super.summaryColors,
    super.leading,
    super.bottomAction,
    super.insideMargin,
    super.maxHeight,
    super.showValue,
  }) : _sourceItems = null,
       spinnerColors = null,
       _dialogSurfaceBuilder = null;

  MiuixSpinnerPreference._source({
    super.key,
    required List<MiuixSpinnerEntry> items,
    required int selectedIndex,
    required super.title,
    required super.presentation,
    required ValueChanged<int>? onSelectedIndexChange,
    MiuixBasicComponentColors? titleColor,
    super.summary,
    MiuixBasicComponentColors? summaryColor,
    this.spinnerColors,
    Widget? startAction,
    super.bottomAction,
    super.insideMargin = MiuixBasicComponentDefaults.insideMargin,
    super.maxHeight,
    super.enabled = true,
    super.showValue = true,
    super.renderInRootScaffold = true,
    super.onExpandedChange,
    String? dialogButtonString,
    Widget Function(Widget child)? dialogSurfaceBuilder,
  }) : _sourceItems = items,
       _dialogSurfaceBuilder = dialogSurfaceBuilder,
       super(
         value: selectedIndex as T,
         entries: [
           for (var index = 0; index < items.length; index++)
             MiuixDropdownEntry<T>(
               value: index as T,
               label: items[index].title ?? '',
               summary: items[index].summary,
               icon: items[index].icon,
               enabled: items[index].enabled,
             ),
         ],
         onChanged: (value) => onSelectedIndexChange?.call(value as int),
         dialogConfirmLabel: dialogButtonString,
         closeOnSelection: true,
         popupMinWidth: MiuixListPopupDefaults.minWidth,
         titleColors: titleColor,
         summaryColors: summaryColor,
         leading: startAction,
         sourceMode: true,
       );

  /// Rich source entries, or null for the compatibility constructor.
  final List<MiuixSpinnerEntry>? _sourceItems;

  /// Explicit upstream spinner colors.
  ///
  /// Popup and dialog modes intentionally resolve different defaults when this
  /// is null, matching `spinnerColors()` and `dialogSpinnerColors()`.
  final MiuixSpinnerColors? spinnerColors;

  /// Flutter equivalent of the source dialog `popupModifier`.
  final Widget Function(Widget child)? _dialogSurfaceBuilder;
}

/// Overlay-hosted spinner preference.
class MiuixOverlaySpinnerPreference<T> extends MiuixSpinnerPreference<T> {
  /// Creates the compatibility Overlay spinner preference.
  const MiuixOverlaySpinnerPreference({
    super.key,
    required super.title,
    required super.value,
    required super.entries,
    required super.onChanged,
    super.summary,
    super.enabled,
    super.renderInRootScaffold,
    super.onExpandedChange,
    super.dialogConfirmLabel,
    super.closeOnSelection,
    super.popupMinWidth,
    super.popupAnchorOffset,
    super.titleColors,
    super.summaryColors,
    super.leading,
    super.bottomAction,
    super.insideMargin,
    super.maxHeight,
    super.showValue,
  }) : super(presentation: MiuixPopupPresentation.overlay);

  MiuixOverlaySpinnerPreference._source({
    super.key,
    required super.items,
    required super.selectedIndex,
    required super.title,
    required super.onSelectedIndexChange,
    super.titleColor,
    super.summary,
    super.summaryColor,
    super.spinnerColors,
    super.startAction,
    super.bottomAction,
    super.insideMargin,
    super.maxHeight,
    super.enabled,
    super.showValue,
    super.renderInRootScaffold,
    super.onExpandedChange,
    super.dialogButtonString,
    super.dialogSurfaceBuilder,
  }) : super._source(presentation: MiuixPopupPresentation.overlay);

  /// Creates the index-based upstream OverlaySpinnerPreference.
  static MiuixOverlaySpinnerPreference<int> source({
    Key? key,
    required List<MiuixSpinnerEntry> items,
    required int selectedIndex,
    required String title,
    MiuixBasicComponentColors? titleColor,
    String? summary,
    MiuixBasicComponentColors? summaryColor,
    MiuixSpinnerColors? spinnerColors,
    Widget? startAction,
    Widget? bottomAction,
    EdgeInsetsGeometry insideMargin = MiuixBasicComponentDefaults.insideMargin,
    double? maxHeight,
    bool enabled = true,
    bool showValue = true,
    bool renderInRootScaffold = true,
    ValueChanged<bool>? onExpandedChange,
    String? dialogButtonString,
    Widget Function(Widget child)? dialogSurfaceBuilder,
    ValueChanged<int>? onSelectedIndexChange,
  }) {
    final safeSelectedIndex = items.isEmpty
        ? 0
        : selectedIndex.clamp(0, items.length - 1);
    return MiuixOverlaySpinnerPreference<int>._source(
      key: key,
      items: items,
      selectedIndex: safeSelectedIndex,
      title: title,
      titleColor: titleColor,
      summary: summary,
      summaryColor: summaryColor,
      spinnerColors: spinnerColors,
      startAction: startAction,
      bottomAction: bottomAction,
      insideMargin: insideMargin,
      maxHeight: maxHeight,
      enabled: enabled,
      showValue: showValue,
      renderInRootScaffold: renderInRootScaffold,
      onExpandedChange: onExpandedChange,
      dialogButtonString: dialogButtonString,
      dialogSurfaceBuilder: dialogSurfaceBuilder,
      onSelectedIndexChange: onSelectedIndexChange,
    );
  }
}

/// Window-hosted spinner preference.
class MiuixWindowSpinnerPreference<T> extends MiuixSpinnerPreference<T> {
  /// Creates the compatibility Window spinner preference.
  const MiuixWindowSpinnerPreference({
    super.key,
    required super.title,
    required super.value,
    required super.entries,
    required super.onChanged,
    super.summary,
    super.enabled,
    super.renderInRootScaffold,
    super.onExpandedChange,
    super.dialogConfirmLabel,
    super.closeOnSelection,
    super.popupMinWidth,
    super.popupAnchorOffset,
    super.titleColors,
    super.summaryColors,
    super.leading,
    super.bottomAction,
    super.insideMargin,
    super.maxHeight,
    super.showValue,
  }) : super(presentation: MiuixPopupPresentation.window);

  MiuixWindowSpinnerPreference._source({
    super.key,
    required super.items,
    required super.selectedIndex,
    required super.title,
    required super.onSelectedIndexChange,
    super.titleColor,
    super.summary,
    super.summaryColor,
    super.spinnerColors,
    super.startAction,
    super.bottomAction,
    super.insideMargin,
    super.maxHeight,
    super.enabled,
    super.showValue,
    super.onExpandedChange,
    super.dialogButtonString,
    super.dialogSurfaceBuilder,
  }) : super._source(presentation: MiuixPopupPresentation.window);

  /// Creates the index-based upstream WindowSpinnerPreference.
  static MiuixWindowSpinnerPreference<int> source({
    Key? key,
    required List<MiuixSpinnerEntry> items,
    required int selectedIndex,
    required String title,
    MiuixBasicComponentColors? titleColor,
    String? summary,
    MiuixBasicComponentColors? summaryColor,
    MiuixSpinnerColors? spinnerColors,
    Widget? startAction,
    Widget? bottomAction,
    EdgeInsetsGeometry insideMargin = MiuixBasicComponentDefaults.insideMargin,
    double? maxHeight,
    bool enabled = true,
    bool showValue = true,
    ValueChanged<bool>? onExpandedChange,
    String? dialogButtonString,
    Widget Function(Widget child)? dialogSurfaceBuilder,
    ValueChanged<int>? onSelectedIndexChange,
  }) {
    final safeSelectedIndex = items.isEmpty
        ? 0
        : selectedIndex.clamp(0, items.length - 1);
    return MiuixWindowSpinnerPreference<int>._source(
      key: key,
      items: items,
      selectedIndex: safeSelectedIndex,
      title: title,
      titleColor: titleColor,
      summary: summary,
      summaryColor: summaryColor,
      spinnerColors: spinnerColors,
      startAction: startAction,
      bottomAction: bottomAction,
      insideMargin: insideMargin,
      maxHeight: maxHeight,
      enabled: enabled,
      showValue: showValue,
      onExpandedChange: onExpandedChange,
      dialogButtonString: dialogButtonString,
      dialogSurfaceBuilder: dialogSurfaceBuilder,
      onSelectedIndexChange: onSelectedIndexChange,
    );
  }
}

/// Exact source content used by OverlayListPopup and WindowListPopup.
class _MiuixSourceSpinnerPreferencePopup<T> extends StatelessWidget {
  const _MiuixSourceSpinnerPreferencePopup({
    required this.entries,
    required this.selectedIndex,
    required this.onSelected,
    this.colors,
    this.maxHeight,
  });

  final List<MiuixSpinnerEntry> entries;
  final int selectedIndex;
  final ValueChanged<T> onSelected;
  final MiuixSpinnerColors? colors;
  final double? maxHeight;

  @override
  Widget build(BuildContext context) {
    final resolvedColors = colors ?? MiuixSpinnerDefaults.colors(context);
    final semantic = MiuixSemanticColors.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: MiuixListPopupDefaults.minWidth,
        maxWidth: MiuixListPopupDefaults.maxWidth,
        maxHeight: maxHeight ?? double.infinity,
      ),
      child: MiuixSurface(
        padding: EdgeInsets.zero,
        radius: MiuixListPopupDefaults.cornerRadius,
        color: semantic['surfaceContainer'],
        glass: true,
        child: MiuixListPopupColumn(
          children: [
            for (var index = 0; index < entries.length; index++)
              MiuixSpinnerItemImpl(
                entry: entries[index],
                entryCount: entries.length,
                isSelected: selectedIndex == index,
                index: index,
                colors: resolvedColors,
                onSelectedIndexChange: (selected) => onSelected(selected as T),
              ),
          ],
        ),
      ),
    );
  }
}

/// Shows the source dialog overload.
///
/// Selection is committed immediately and dismisses the dialog. The bottom
/// text button only closes the dialog; it is not a second confirmation step.
//
// Source Spinner live-dialog contract:
//
// - The source overload continues treating selection as an immediate commit.
// - The bottom text button remains dismissal-only and never confirms a draft.
// - Entries are read from the latest specialized Spinner preference instance.
// - Selected index is also read from the latest controlled widget value.
// - Spinner colors and button text participate in the same content revision.
// - Rich title, summary, icon, and enabled state refresh in the visible dialog.
// - Source row geometry and dialogMode remain unchanged by that refresh.
// - The existing dialog surface and route animation remain in place.
// - A selected index is converted to T only at the established source boundary.
// - State-level entry validation rejects an index removed before pointer-up.
// - State-level dispatch reads the latest onSelectedIndexChange owner.
// - Successful selection dismisses through the opening presentation host.
// - Repeated dismissal requests collapse through one idempotent guard.
// - The text button uses the same guard when selection already requested close.
// - Overlay root/local selection and Window Navigator remain opening decisions.
// - The source surface builder remains stable until the next invocation.
// - Parent data rebuilds do not restart focus, barrier, or entrance transitions.
// - Tests replace items, button text, and callback owner while the route is open.
Future<void> _showMiuixSourceSpinnerSelectionDialog<T>({
  required BuildContext context,
  required String title,
  required ValueListenable<int> revision,
  required List<MiuixSpinnerEntry> Function() entriesProvider,
  required int Function() selectedIndexProvider,
  required String Function() dialogButtonLabelProvider,
  required MiuixSpinnerColors? Function() spinnerColorsProvider,
  required ValueChanged<T> onChanged,
  required MiuixPopupPresentation presentation,
  required bool renderInRootScaffold,
  Widget Function(Widget child)? dialogSurfaceBuilder,
}) {
  final host = MiuixPopupHostScope.maybeOf(context);
  final overlayHost = renderInRootScaffold ? host?.root : host;
  final navigator = Navigator.maybeOf(context, rootNavigator: true);
  var dismissRequested = false;

  void dismiss() {
    if (dismissRequested) return;
    dismissRequested = true;
    if (presentation == MiuixPopupPresentation.overlay) {
      overlayHost?.dismissTop();
    } else if (navigator?.mounted == true && navigator!.canPop()) {
      navigator.pop();
    }
  }

  final content = ValueListenableBuilder<int>(
    valueListenable: revision,
    builder: (context, revisionValue, _) {
      return _MiuixSourceSpinnerDialogContent<T>(
        entries: entriesProvider(),
        selectedIndex: selectedIndexProvider(),
        colors: spinnerColorsProvider(),
        dialogButtonLabel: dialogButtonLabelProvider(),
        onSelected: (index) {
          onChanged(index as T);
          dismiss();
        },
        onDismiss: dismiss,
      );
    },
  );
  return presentation == MiuixPopupPresentation.overlay
      ? MiuixOverlayDialog.show<void>(
          context: context,
          title: title,
          content: content,
          insideMargin: const EdgeInsets.symmetric(vertical: 24),
          surfaceBuilder: dialogSurfaceBuilder,
          renderInRootScaffold: renderInRootScaffold,
        )
      : MiuixWindowDialog.show<void>(
          context: context,
          title: title,
          content: content,
          insideMargin: const EdgeInsets.symmetric(vertical: 24),
          surfaceBuilder: dialogSurfaceBuilder,
        );
}

class _MiuixSourceSpinnerDialogContent<T> extends StatelessWidget {
  const _MiuixSourceSpinnerDialogContent({
    required this.entries,
    required this.selectedIndex,
    required this.dialogButtonLabel,
    required this.onSelected,
    required this.onDismiss,
    this.colors,
  });

  final List<MiuixSpinnerEntry> entries;
  final int selectedIndex;
  final String dialogButtonLabel;
  final ValueChanged<int> onSelected;
  final VoidCallback onDismiss;
  final MiuixSpinnerColors? colors;

  @override
  Widget build(BuildContext context) {
    final resolvedColors = colors ?? MiuixSpinnerDefaults.dialogColors(context);
    final dialogButtonPadding = _miuixRoundedInsets(
      context,
      const EdgeInsetsDirectional.only(start: 24, top: 12, end: 24),
    );
    return Flexible(
      fit: FlexFit.loose,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            fit: FlexFit.loose,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: entries.length,
              itemBuilder: (context, index) => MiuixSpinnerItemImpl(
                entry: entries[index],
                entryCount: entries.length,
                isSelected: selectedIndex == index,
                index: index,
                colors: resolvedColors,
                dialogMode: true,
                onSelectedIndexChange: onSelected,
              ),
            ),
          ),
          Padding(
            padding: dialogButtonPadding,
            child: SizedBox(
              width: double.infinity,
              child: MiuixTextButton(
                label: dialogButtonLabel,
                minHeight: 50,
                onPressed: onDismiss,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
