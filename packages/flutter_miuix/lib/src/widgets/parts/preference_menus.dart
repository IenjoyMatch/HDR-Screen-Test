part of '../miuix_widgets.dart';

/// Dropdown preference for option selection.
class MiuixDropdownPreference<T> extends StatefulWidget {
  /// Creates a dropdown preference.
  const MiuixDropdownPreference({
    super.key,
    required this.title,
    required this.value,
    required this.entries,
    required this.onChanged,
    this.summary,
    this.presentation = MiuixPopupPresentation.window,
    this.enabled = true,
    this.renderInRootScaffold = true,
    this.onExpandedChange,
    this.closeOnSelection = true,
    this.dialogConfirmLabel,
    this.popupMinWidth = 200,
    this.popupAnchorOffset = Offset.zero,
    this.titleColors,
    this.summaryColors,
    this.leading,
    this.bottomAction,
    this.insideMargin = MiuixBasicComponentDefaults.insideMargin,
    this.maxHeight,
    this.showValue = true,
    this.dropdownColors,
    this.sourceMode = false,
  });

  /// Main title.
  final String title;

  /// Optional summary.
  final String? summary;

  /// Selected value.
  final T value;

  /// Available entries.
  final List<MiuixDropdownEntry<T>> entries;

  /// Change callback.
  final ValueChanged<T> onChanged;

  /// Popup route family used by this preference.
  final MiuixPopupPresentation presentation;

  /// Whether the preference can open its popup.
  final bool enabled;

  /// Whether Overlay presentation uses the outermost Scaffold host.
  final bool renderInRootScaffold;

  /// Called when popup expansion starts or finishes.
  final ValueChanged<bool>? onExpandedChange;

  /// Whether choosing a popup row immediately closes the menu.
  final bool closeOnSelection;

  /// When non-null, presents spinner choices in a confirmable dialog.
  final String? dialogConfirmLabel;

  /// Minimum popup width before the source 288dp upper clamp is applied.
  final double popupMinWidth;

  /// Additional logical offset applied to the measured end-action anchor.
  ///
  /// The component already applies MIUIX's one-physical-pixel text-anchor
  /// correction. Use this only for a deliberately customized trailing layout.
  final Offset popupAnchorOffset;

  /// Optional source title foreground pair.
  final MiuixBasicComponentColors? titleColors;

  /// Optional source summary foreground pair.
  final MiuixBasicComponentColors? summaryColors;

  /// Optional source start action.
  final Widget? leading;

  /// Optional source bottom action.
  final Widget? bottomAction;

  /// Directional source inside margin.
  final EdgeInsetsGeometry insideMargin;

  /// Optional source popup height limit.
  final double? maxHeight;

  /// Whether the selected value is rendered before the dropdown arrow.
  final bool showValue;

  /// Optional source popup-row color set.
  final MiuixDropdownColors? dropdownColors;

  /// Whether this instance follows the exact index-based upstream contract.
  @protected
  final bool sourceMode;

  @override
  State<MiuixDropdownPreference<T>> createState() =>
      _MiuixDropdownPreferenceState<T>();
}

class _MiuixDropdownPreferenceState<T>
    extends State<MiuixDropdownPreference<T>> {
  // Live popup ownership contract:
  //
  // - The preference State owns the logical menu for its full visible life.
  // - Overlay and Window hosts own only placement, focus, and dismissal.
  // - The popup child is detached and cannot rebuild with this Element alone.
  // - A monotonically increasing revision bridges that detached build plane.
  // - Revisions are posted after the parent frame to avoid build reentrancy.
  // - A revision rebuilds content without replacing the route or animation.
  // - Entries, selected value, colors, and constraints are read at revision.
  // - Source Spinner items are also read from the latest specialized widget.
  // - Opening geometry remains route-owned and follows its anchor provider.
  // - The opening close policy remains stable until that route is dismissed.
  // - Expansion callbacks remain balanced for the owner that opened the route.
  // - Selection callbacks deliberately resolve the current widget owner.
  // - A selected value must still exist and be enabled at dispatch time.
  // - Removed or disabled rows never leak a stale pointer event downstream.
  // - Haptic confirmation runs only after the current-state validation passes.
  // - Confirmable dialogs reuse the safe dispatch path for their final commit.
  // - Dialog option content follows revisions without replacing its route.
  // - A still-valid pending choice survives option refresh as a coherent draft.
  // - An invalid pending choice falls back to the controlled or first live row.
  // - Dispose releases the revision only after the route listener is removed.
  // - The mounted guards cover dismissal racing with a scheduled revision.
  // - Tests replace both immutable entries and callback owner while expanded.
  // - Source and compatibility presentations share these ownership guarantees.
  //
  // Race scenarios covered by the contract:
  //
  // - Parent replaces a label while the route entrance is still settling.
  // - Parent changes the selected value without dismissing the visible menu.
  // - Parent removes the row between pointer down and pointer up.
  // - Parent disables the row between pointer down and pointer up.
  // - Parent swaps callback closures while retaining the same State identity.
  // - Parent changes a popup color set while glass remains visible.
  // - Parent changes a height constraint after the route has been positioned.
  // - Source Dropdown swaps its index-labelled entry collection.
  // - Source Spinner swaps its specialized item collection.
  // - Dismissal wins a race against an already scheduled revision callback.
  // - Disposal wins a race against an asynchronously completed menu future.
  //
  // Deliberately stable opening decisions:
  //
  // - Presentation family does not migrate between Overlay and Window live.
  // - Root-versus-local popup host does not migrate while already visible.
  // - Anchor alignment and additive offset belong to the created route.
  // - Immediate-versus-persistent close behavior belongs to the created route.
  // - Dialog confirmation owns its pending value until confirm or dismissal.
  // - Changing these route-level options takes effect on the next expansion.
  /// These identities must survive a parent rebuild while the popup is open.
  final LayerLink _link = LayerLink();
  final GlobalKey _anchorKey = GlobalKey();
  final ValueNotifier<int> _popupRevision = ValueNotifier<int>(0);
  bool _popupRefreshScheduled = false;

  /// The source keeps BasicComponent's hold-down interaction active for the
  /// complete lifetime of either popup presentation, not only while the
  /// pointer is physically down.
  bool _expanded = false;

  @override
  void didUpdateWidget(covariant MiuixDropdownPreference<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_expanded || _popupRefreshScheduled) return;
    // Popup routes are detached from this preference's element subtree. A
    // parent rebuild therefore cannot refresh their entries through normal
    // inherited build propagation. Publish after the frame so an OverlayEntry
    // that is currently building is never marked dirty synchronously. This is
    // intentionally unconditional while expanded: value, colors, source-mode
    // items, height constraints, and custom callback ownership are all live
    // parts of the preference contract.
    _popupRefreshScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _popupRefreshScheduled = false;
      if (mounted && _expanded) _popupRevision.value++;
    });
  }

  @override
  void dispose() {
    _popupRevision.dispose();
    super.dispose();
  }

  void _selectCurrent(T next) {
    if (!mounted) return;
    final available = widget.entries.any(
      (entry) => entry.enabled && entry.value == next,
    );
    // A pointer event can arrive in the same frame that removes or disables a
    // row. Never forward that stale value to the newly rebuilt owner.
    if (!available) return;
    unawaited(MiuixHaptics.perform(MiuixHapticType.confirm));
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title;
    final summary = widget.summary;
    final value = widget.value;
    final entries = widget.entries;
    final presentation = widget.presentation;
    final enabled = widget.enabled;
    final renderInRootScaffold = widget.renderInRootScaffold;
    final onExpandedChange = widget.onExpandedChange;
    final closeOnSelection = widget.closeOnSelection;
    final dialogConfirmLabel = widget.dialogConfirmLabel;
    final spinnerWidget = widget is MiuixSpinnerPreference<T>
        ? widget as MiuixSpinnerPreference<T>
        : null;
    final sourceSpinnerItems = spinnerWidget?._sourceItems;
    final sourceSpinnerDialog =
        widget.sourceMode &&
        sourceSpinnerItems != null &&
        dialogConfirmLabel != null;
    MiuixDropdownEntry<T>? selectedEntry;
    var matchCount = 0;
    for (final entry in entries) {
      if (entry.value == value) {
        matchCount++;
        selectedEntry ??= entry;
      }
    }
    // Current MIUIX enables a non-empty preference even when every item is
    // disabled; the popup may still open to expose those disabled choices.
    final canOpen = enabled && entries.isNotEmpty;
    final semantic = MiuixSemanticColors.of(context);
    final trailingColor = canOpen
        ? semantic['onSurfaceVariantActions']
        : semantic['disabledOnSecondaryVariant'];
    final selectedLabel = matchCount == 1 ? selectedEntry?.label ?? '' : null;
    // Enabled controls whether the menu may open; it does not change the
    // selected-value end action. MIUIX keeps both the value and 10x16 arrow in
    // a disabled preference and only resolves them with disabled colors.
    final showSelectedLabel = widget.showValue && selectedLabel != null;
    final trailing = showSelectedLabel
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                // Compose's 14sp body2 occupies a 17dp Android line box. A
                // fixed box keeps the popup anchor's vertical bounds equal to
                // the source instead of inheriting Flutter's 16.24dp theme
                // line box and ending one physical pixel too high.
                child: SizedBox(
                  height: 17,
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Text(
                      selectedLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: trailingColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _MiuixDropdownArrow(color: trailingColor),
            ],
          )
        : widget.sourceMode
        ? _MiuixDropdownArrow(color: trailingColor)
        : Text(
            entries.isNotEmpty ? 'Unavailable' : 'No actions',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: trailingColor, fontSize: 14),
          );
    final popupEntries = [
      for (final entry in entries)
        entry.copyWith(selected: entry.value == value),
    ];
    // In the source the popup composable lives inside BasicComponent's
    // endActions Row. Its parent bounds are therefore the selected value and
    // 10x16 arrow, not the complete 56dp preference row. Linking the trailing
    // action reproduces both the 16dp end inset and the vertical anchor beside
    // the arrow; anchoring the whole preference makes every popup too low.
    final anchoredTrailing = CompositedTransformTarget(
      link: _link,
      child: SizedBox(key: _anchorKey, child: trailing),
    );
    return MiuixPreference(
      title: title,
      summary: summary,
      titleColors: widget.titleColors,
      summaryColors: widget.summaryColors,
      leading: widget.leading,
      bottomAction: widget.bottomAction,
      insideMargin: widget.insideMargin,
      enabled: canOpen,
      holdDown: _expanded,
      sourceStyle: widget.sourceMode,
      role: MiuixAccessibilityRole.dropdownList,
      onTap: canOpen
          ? () async {
              if (_expanded) {
                return;
              }
              // The current source performs ContextClick from the shared
              // handleClick path for both popup and dialog overloads.
              unawaited(MiuixHaptics.perform(MiuixHapticType.contextClick));
              setState(() => _expanded = true);
              onExpandedChange?.call(true);
              try {
                if (dialogConfirmLabel != null) {
                  if (sourceSpinnerDialog) {
                    await _showMiuixSourceSpinnerSelectionDialog<T>(
                      context: context,
                      title: title,
                      revision: _popupRevision,
                      entriesProvider: () {
                        final current = widget is MiuixSpinnerPreference<T>
                            ? widget as MiuixSpinnerPreference<T>
                            : null;
                        return current?._sourceItems ?? sourceSpinnerItems;
                      },
                      selectedIndexProvider: () => widget.value as int,
                      dialogButtonLabelProvider: () =>
                          widget.dialogConfirmLabel ?? dialogConfirmLabel,
                      spinnerColorsProvider: () {
                        final current = widget is MiuixSpinnerPreference<T>
                            ? widget as MiuixSpinnerPreference<T>
                            : null;
                        return current?.spinnerColors;
                      },
                      onChanged: _selectCurrent,
                      presentation: presentation,
                      dialogSurfaceBuilder:
                          spinnerWidget?._dialogSurfaceBuilder,
                      renderInRootScaffold: renderInRootScaffold,
                    );
                  } else {
                    await _showMiuixSpinnerSelectionDialog<T>(
                      context: context,
                      title: title,
                      value: value,
                      revision: _popupRevision,
                      entriesProvider: () => widget.entries,
                      valueProvider: () => widget.value,
                      confirmLabelProvider: () =>
                          widget.dialogConfirmLabel ?? dialogConfirmLabel,
                      onChanged: _selectCurrent,
                      presentation: presentation,
                      renderInRootScaffold: renderInRootScaffold,
                    );
                  }
                } else {
                  // Compose truncates the body2 trailing text position before
                  // adding its integer line-box height. Flutter retains the
                  // fractional font metrics, which leaves the calculated far
                  // edge one physical pixel lower. Apply the source correction
                  // here once so every dropdown preference, including one in a
                  // nested Scaffold, shares the same popup origin.
                  final density = View.of(context).devicePixelRatio;
                  final physicalLineHeight = 17 * density;
                  // Integer-density layouts already give the 17dp wrapper an
                  // integral edge. Only a fractional physical line box needs
                  // the one-pixel correction produced by Compose's separate
                  // position truncation and measured-height rounding.
                  final needsPhysicalCorrection =
                      (physicalLineHeight - physicalLineHeight.round()).abs() >
                      1e-6;
                  // Android's root Flutter surface and a clipped nested popup
                  // host both paint this fractional-density overlay one
                  // physical pixel left of the framework coordinate. Compose
                  // opens the source Spinner/Dropdown in an integer-positioned
                  // PopupHost, so carry one pixel into the overlay coordinate
                  // here; the final 420dpi raster then shares its x edges.
                  final sourceAnchorOffset = Offset(
                    widget.sourceMode &&
                            presentation == MiuixPopupPresentation.overlay &&
                            density != density.roundToDouble()
                        ? 1 / density
                        : 0,
                    needsPhysicalCorrection ? -1 / density : 0,
                  );
                  Widget buildLivePopup(ValueChanged<T> select) {
                    return ValueListenableBuilder<int>(
                      valueListenable: _popupRevision,
                      builder: (context, revision, _) {
                        final currentEntries = widget.entries;
                        final currentValue = widget.value;
                        final currentPopupEntries = [
                          for (final entry in currentEntries)
                            entry.copyWith(
                              selected: entry.value == currentValue,
                            ),
                        ];
                        if (!widget.sourceMode) {
                          return MiuixListPopup<T>(
                            entries: currentPopupEntries,
                            minWidth: widget.popupMinWidth,
                            onSelected: select,
                          );
                        }
                        final currentSpinner =
                            widget is MiuixSpinnerPreference<T>
                            ? widget as MiuixSpinnerPreference<T>
                            : null;
                        final currentSpinnerItems =
                            currentSpinner?._sourceItems;
                        if (currentSpinnerItems != null) {
                          return _MiuixSourceSpinnerPreferencePopup<T>(
                            entries: currentSpinnerItems,
                            selectedIndex: currentValue as int,
                            colors: currentSpinner?.spinnerColors,
                            maxHeight: widget.maxHeight,
                            onSelected: select,
                          );
                        }
                        return _MiuixSourceDropdownPreferencePopup<T>(
                          entries: currentPopupEntries,
                          selectedValue: currentValue,
                          colors: widget.dropdownColors,
                          minWidth: widget.popupMinWidth,
                          maxHeight: widget.maxHeight,
                          onSelected: select,
                        );
                      },
                    );
                  }

                  await _showMiuixDropdownMenu<T>(
                    context: context,
                    entries: popupEntries,
                    onSelected: _selectCurrent,
                    popupBuilder: buildLivePopup,
                    presentation: presentation,
                    link: _link,
                    anchorRect: _anchorKey.currentContext == null
                        ? null
                        : _miuixGlobalRect(_anchorKey.currentContext!),
                    anchorRectProvider: () => _anchorKey.currentContext == null
                        ? null
                        : _miuixGlobalRect(_anchorKey.currentContext!),
                    alignment: MiuixPopupAlignment.bottomEnd,
                    renderInRootScaffold: renderInRootScaffold,
                    closeOnSelection: closeOnSelection,
                    popupMinWidth: widget.popupMinWidth,
                    popupAnchorOffset:
                        sourceAnchorOffset + widget.popupAnchorOffset,
                  );
                }
              } finally {
                if (mounted) {
                  setState(() => _expanded = false);
                  onExpandedChange?.call(false);
                }
              }
            }
          : null,
      trailing: anchoredTrailing,
    );
  }
}

// Spinner dialog mode keeps a temporary selection until the user confirms it,
// matching MIUIX `dialogButtonString` rather than treating the dialog as a
// differently positioned dropdown.
//
// Live confirm-dialog contract:
//
// - The route owns presentation, focus trapping, barrier, and dismissal.
// - The preference State owns the current option and callback collections.
// - ValueListenableBuilder bridges those collections into the detached route.
// - A host rebuild increments the same revision used by ordinary popups.
// - The revision rebuilds only content below the existing dialog surface.
// - The dialog entrance animation is therefore never replayed by data refresh.
// - The local pending value remains a draft until the confirm action runs.
// - A label-only replacement does not discard a still-valid pending value.
// - A color-only or callback-only replacement does not discard that draft.
// - A removed pending value is invalid even when an old row remains on screen.
// - A disabled pending value is invalid under the same current-state rule.
// - The controlled value is the first fallback for an invalid draft.
// - The first enabled current entry is the second fallback.
// - An empty or fully disabled collection leaves no confirmable value.
// - The confirm control reflects that state through its null callback.
// - Pointer selection reads the entries produced by the latest revision.
// - Final commit still passes through the State's current membership guard.
// - The latest callback owner is read only after that membership guard passes.
// - Cancel never publishes either the draft or the controlled fallback.
// - Dynamic height follows current row count within the existing 420dp cap.
// - Route family and root-host selection stay fixed for this invocation.
// - A later invocation reads any changed route-level configuration.
// - Disposal causes the State-level commit guard to reject late confirmation.
// - Tests cover valid-draft retention, invalid-draft fallback, and route identity.
Future<void> _showMiuixSpinnerSelectionDialog<T>({
  required BuildContext context,
  required String title,
  required T value,
  required ValueListenable<int> revision,
  required List<MiuixDropdownEntry<T>> Function() entriesProvider,
  required T Function() valueProvider,
  required String Function() confirmLabelProvider,
  required ValueChanged<T> onChanged,
  required MiuixPopupPresentation presentation,
  required bool renderInRootScaffold,
}) {
  final host = MiuixPopupHostScope.maybeOf(context);
  final overlayHost = renderInRootScaffold ? host?.root : host;
  final navigator = Navigator.maybeOf(context, rootNavigator: true);
  var pendingValue = value;

  void dismiss() {
    if (presentation == MiuixPopupPresentation.overlay) {
      overlayHost?.dismissTop();
    } else if (navigator?.mounted == true && navigator!.canPop()) {
      navigator.pop();
    }
  }

  final content = StatefulBuilder(
    builder: (dialogContext, setDialogState) {
      return ValueListenableBuilder<int>(
        valueListenable: revision,
        builder: (context, revisionValue, _) {
          final currentEntries = entriesProvider();
          bool accepts(T candidate) => currentEntries.any(
            (entry) => entry.enabled && entry.value == candidate,
          );

          // Preserve an authored draft while it remains valid. When its row
          // disappears or becomes disabled, prefer the current controlled
          // value and then the first enabled row, so the check and confirm
          // action can never point at stale content.
          if (!accepts(pendingValue)) {
            final controlled = valueProvider();
            if (accepts(controlled)) {
              pendingValue = controlled;
            } else {
              for (final entry in currentEntries) {
                if (entry.enabled) {
                  pendingValue = entry.value;
                  break;
                }
              }
            }
          }
          final canConfirm = accepts(pendingValue);
          return SizedBox(
            height: math.min(420, currentEntries.length * 58 + 64).toDouble(),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: currentEntries.length,
                    itemBuilder: (context, index) {
                      final entry = currentEntries[index];
                      return _MiuixMenuRow(
                        label: entry.label,
                        summary: entry.summary,
                        icon: entry.icon,
                        enabled: entry.enabled,
                        trailing: entry.value == pendingValue
                            ? _MiuixDropdownCheck(
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : null,
                        onTap: entry.enabled
                            ? () => setDialogState(
                                () => pendingValue = entry.value,
                              )
                            : null,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: MiuixButton(
                        label: '取消',
                        filled: false,
                        onPressed: dismiss,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: MiuixButton(
                        label: confirmLabelProvider(),
                        onPressed: canConfirm
                            ? () {
                                onChanged(pendingValue);
                                dismiss();
                              }
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );

  return presentation == MiuixPopupPresentation.overlay
      ? MiuixOverlayDialog.show<void>(
          context: context,
          title: title,
          content: content,
          renderInRootScaffold: renderInRootScaffold,
        )
      : MiuixWindowDialog.show<void>(
          context: context,
          title: title,
          content: content,
        );
}

/// Dropdown preference whose groups keep independent selected entries.
class MiuixGroupedDropdownPreference<T> extends StatefulWidget {
  /// Creates a grouped dropdown or spinner preference.
  const MiuixGroupedDropdownPreference({
    super.key,
    required this.title,
    required this.groups,
    required this.onSelected,
    this.summary,
    this.presentation = MiuixPopupPresentation.window,
    this.enabled = true,
    this.renderInRootScaffold = true,
    this.closeOnSelection = false,
    this.dialogConfirmLabel,
    this.onExpandedChange,
    this.showValue = true,
    this.titleColors,
    this.summaryColors,
    this.leading,
    this.bottomAction,
    this.insideMargin = MiuixBasicComponentDefaults.insideMargin,
    this.maxHeight,
    this.dropdownColors,
    this.dialogSurfaceBuilder,
    this.sourceMode = false,
  });

  /// Main preference title.
  final String title;

  /// Optional expansion or mode summary.
  final String? summary;

  /// Independently selectable groups rendered with separators.
  final List<MiuixDropdownGroup<T>> groups;

  /// Receives the value of every enabled row selection.
  final ValueChanged<T> onSelected;

  /// Popup host family.
  final MiuixPopupPresentation presentation;

  /// Whether the preference is interactive.
  final bool enabled;

  /// Whether Overlay presentation uses the outermost scaffold.
  final bool renderInRootScaffold;

  /// Whether a row selection immediately closes the popup.
  final bool closeOnSelection;

  /// Optional dialog confirmation label for grouped spinner mode.
  final String? dialogConfirmLabel;

  /// Called at the start and end of popup visibility.
  final ValueChanged<bool>? onExpandedChange;

  /// Whether selected labels are shown before the source dropdown arrow.
  ///
  /// The current entries overload joins one selected label from every group
  /// with line breaks. Keeping the switch here also matches the source
  /// `showValue` parameter used by both Overlay and Window preferences.
  final bool showValue;

  /// Optional current-source title colors.
  final MiuixBasicComponentColors? titleColors;

  /// Optional current-source summary colors.
  final MiuixBasicComponentColors? summaryColors;

  /// Optional current-source leading slot.
  final Widget? leading;

  /// Optional current-source content below the preference row.
  final Widget? bottomAction;

  /// Directional inner spacing forwarded to `BasicComponent`.
  final EdgeInsetsGeometry insideMargin;

  /// Optional popup viewport limit.
  final double? maxHeight;

  /// Optional seven-channel popup or dialog row colors.
  final MiuixDropdownColors? dropdownColors;

  /// Flutter equivalent of the source dialog `popupModifier`.
  final Widget Function(Widget child)? dialogSurfaceBuilder;

  /// Whether this instance follows the current entries overload.
  final bool sourceMode;

  @override
  State<MiuixGroupedDropdownPreference<T>> createState() =>
      _MiuixGroupedDropdownPreferenceState<T>();
}

class _MiuixGroupedDropdownPreferenceState<T>
    extends State<MiuixGroupedDropdownPreference<T>> {
  // Grouped live popup ownership adds the following invariants:
  //
  // - Empty groups are filtered again on every detached-content revision.
  // - Source-row styling is resolved from the current widget configuration.
  // - Every group's independent selected flags remain caller-controlled.
  // - A group removed while open disappears without collapsing the route.
  // - A group added while open becomes interactive in the existing route.
  // - Row dispatch checks both the group's and the entry's current enabled bit.
  // - Duplicate values are accepted only when at least one current row is live.
  // - The callback is read after validation, never captured at route creation.
  // - Height and color changes update without replaying the entrance transition.
  // - Host placement and focus restoration remain identical to simple menus.
  // - Dialog presentation rebuilds current groups through the same revision.
  // - Regression tests replace groups and callback ownership in one parent frame.
  /// Stable anchoring prevents expansion summaries from unlinking the popup.
  final LayerLink _link = LayerLink();
  final GlobalKey _anchorKey = GlobalKey();
  final ValueNotifier<int> _popupRevision = ValueNotifier<int>(0);
  bool _popupRefreshScheduled = false;

  /// Mirrors BasicComponent's persistent hold-down state while expanded.
  bool _expanded = false;

  @override
  void didUpdateWidget(covariant MiuixGroupedDropdownPreference<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_expanded || _popupRefreshScheduled) return;
    // Grouped menus live in the same detached popup route as ordinary dropdown
    // preferences. Keep selected flags, group membership, colors, constraints,
    // and the active callback owner synchronized without replaying the route's
    // entrance transition.
    _popupRefreshScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _popupRefreshScheduled = false;
      if (mounted && _expanded) _popupRevision.value++;
    });
  }

  @override
  void dispose() {
    _popupRevision.dispose();
    super.dispose();
  }

  void _selectCurrent(T next) {
    if (!mounted) return;
    final available = widget.groups.any(
      (group) =>
          group.enabled &&
          group.entries.any((entry) => entry.enabled && entry.value == next),
    );
    if (!available) return;
    unawaited(MiuixHaptics.perform(MiuixHapticType.confirm));
    widget.onSelected(next);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title;
    final summary = widget.summary;
    final groups = widget.groups;
    final presentation = widget.presentation;
    final enabled = widget.enabled;
    final renderInRootScaffold = widget.renderInRootScaffold;
    final closeOnSelection = widget.closeOnSelection;
    final dialogConfirmLabel = widget.dialogConfirmLabel;
    final onExpandedChange = widget.onExpandedChange;
    final nonEmptyGroups = groups
        .where((group) => group.entries.isNotEmpty)
        .toList(growable: false);
    final canOpen = enabled && nonEmptyGroups.isNotEmpty;
    final semantic = MiuixSemanticColors.of(context);
    final color = canOpen
        ? semantic['onSurfaceVariantActions']
        : semantic['disabledOnSecondaryVariant'];

    // The entries overload presents every group's independent selected value
    // in the end action. Newlines are significant: Compose measures this as a
    // real multi-line trailing column instead of flattening it into one label.
    final selectedLabels = nonEmptyGroups
        .expand((group) => group.entries)
        .where((entry) => entry.selected)
        .map((entry) => entry.label)
        .where((label) => label.isNotEmpty)
        .toList(growable: false);
    final selectedValueText = selectedLabels.join('\n');
    final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
    final selectedValueHeight =
        selectedLabels.length * (43 / 2.625) * textScale;

    final anchoredTrailing = CompositedTransformTarget(
      link: _link,
      child: SizedBox(
        key: _anchorKey,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showValue && selectedValueText.isNotEmpty) ...[
              SizedBox(
                height: selectedValueHeight,
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  widthFactor: 1,
                  child: Text(
                    selectedValueText,
                    textAlign: TextAlign.end,
                    strutStyle: const StrutStyle(
                      fontSize: 14,
                      height: (43.25 / 2.625) / 14,
                      forceStrutHeight: true,
                    ),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      // Android exposes a 43px body2 glyph boundary at 420dpi.
                      // The fixed parent measures exactly one such line per
                      // selected group while this strut keeps the glyph block
                      // centered without Flutter's taller platform leading.
                      height: (43.25 / 2.625) / 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            _MiuixDropdownArrow(color: color),
          ],
        ),
      ),
    );
    return MiuixPreference(
      title: title,
      summary: summary,
      titleColors: widget.titleColors,
      summaryColors: widget.summaryColors,
      leading: widget.leading,
      bottomAction: widget.bottomAction,
      insideMargin: widget.insideMargin,
      enabled: canOpen,
      holdDown: _expanded,
      sourceStyle: widget.sourceMode,
      role: MiuixAccessibilityRole.dropdownList,
      trailing: anchoredTrailing,
      onTap: canOpen
          ? () async {
              if (_expanded) {
                return;
              }
              unawaited(MiuixHaptics.perform(MiuixHapticType.contextClick));
              setState(() => _expanded = true);
              onExpandedChange?.call(true);
              try {
                if (dialogConfirmLabel != null) {
                  await _showMiuixGroupedSelectionDialog<T>(
                    context: context,
                    title: title,
                    revision: _popupRevision,
                    groupsProvider: () => widget.groups
                        .where((group) => group.entries.isNotEmpty)
                        .toList(growable: false),
                    confirmLabelProvider: () =>
                        widget.dialogConfirmLabel ?? dialogConfirmLabel,
                    sourceModeProvider: () => widget.sourceMode,
                    colorsProvider: () => widget.dropdownColors,
                    onSelected: _selectCurrent,
                    presentation: presentation,
                    renderInRootScaffold: renderInRootScaffold,
                    sourceMode: widget.sourceMode,
                    dialogSurfaceBuilder: widget.dialogSurfaceBuilder,
                    closeOnSelection: closeOnSelection,
                  );
                } else {
                  Widget buildLivePopup(ValueChanged<T> select) {
                    return ValueListenableBuilder<int>(
                      valueListenable: _popupRevision,
                      builder: (context, revision, _) {
                        final currentGroups = widget.groups
                            .where((group) => group.entries.isNotEmpty)
                            .toList(growable: false);
                        return ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: widget.maxHeight ?? double.infinity,
                          ),
                          child: MiuixListPopup<T>(
                            entries: const [],
                            groups: currentGroups,
                            onSelected: select,
                            sourceRows: widget.sourceMode,
                            colors: widget.dropdownColors,
                          ),
                        );
                      },
                    );
                  }

                  await _showMiuixDropdownMenu<T>(
                    context: context,
                    entries: const [],
                    groups: nonEmptyGroups,
                    onSelected: _selectCurrent,
                    popupBuilder: buildLivePopup,
                    presentation: presentation,
                    link: _link,
                    anchorRect: _anchorKey.currentContext == null
                        ? null
                        : _miuixGlobalRect(_anchorKey.currentContext!),
                    anchorRectProvider: () => _anchorKey.currentContext == null
                        ? null
                        : _miuixGlobalRect(_anchorKey.currentContext!),
                    alignment: MiuixPopupAlignment.bottomEnd,
                    renderInRootScaffold: renderInRootScaffold,
                    closeOnSelection: closeOnSelection,
                  );
                }
              } finally {
                if (mounted) {
                  setState(() => _expanded = false);
                  onExpandedChange?.call(false);
                }
              }
            }
          : null,
    );
  }
}

// Grouped confirm-dialog live-content contract:
//
// - Group and row ordering always come from the latest preference widget.
// - Empty groups are filtered by the provider before reaching popup layout.
// - Group-level and row-level enabled state remain separately meaningful.
// - Current-state dispatch validates both levels before publishing a value.
// - Source rows retain their specialized geometry and divider ownership.
// - Compatibility rows retain the generic list-popup geometry.
// - Switching source-mode content rebuilds the content plane, not the route.
// - Current colors are resolved on every revision against the dialog context.
// - A changed close-button label is visible without dismissing the dialog.
// - The opening close-on-selection policy remains stable for the invocation.
// - Immediate selection can dismiss only through the opening route host.
// - Persistent selection leaves the current dialog surface in place.
// - The bottom close action never synthesizes another selection callback.
// - Overlay and Window variants share identical live group ownership.
// - The source surface builder and inside margin remain opening decisions.
// - Those stable decisions prevent a visible dialog from jumping host layers.
// - A scheduled revision after dismissal is ignored by the mounted guard.
// - Tests replace groups, labels, button text, and callback owner while visible.
Future<void> _showMiuixGroupedSelectionDialog<T>({
  required BuildContext context,
  required String title,
  required ValueListenable<int> revision,
  required List<MiuixDropdownGroup<T>> Function() groupsProvider,
  required String Function() confirmLabelProvider,
  required bool Function() sourceModeProvider,
  required MiuixDropdownColors? Function() colorsProvider,
  required ValueChanged<T> onSelected,
  required MiuixPopupPresentation presentation,
  required bool renderInRootScaffold,
  required bool sourceMode,
  required bool closeOnSelection,
  Widget Function(Widget child)? dialogSurfaceBuilder,
}) {
  final host = MiuixPopupHostScope.maybeOf(context);
  final overlayHost = renderInRootScaffold ? host?.root : host;
  final navigator = Navigator.maybeOf(context, rootNavigator: true);

  void dismiss() {
    if (presentation == MiuixPopupPresentation.overlay) {
      overlayHost?.dismissTop();
    } else if (navigator?.mounted == true && navigator!.canPop()) {
      navigator.pop();
    }
  }

  void select(T value) {
    onSelected(value);
    if (closeOnSelection) dismiss();
  }

  Widget buildContent(BuildContext context) {
    final currentGroups = groupsProvider();
    final currentSourceMode = sourceModeProvider();
    final currentColors = colorsProvider();
    return currentSourceMode
        ? Flexible(
            fit: FlexFit.loose,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: SingleChildScrollView(
                    child: MiuixListPopup<T>(
                      entries: const [],
                      groups: currentGroups,
                      onSelected: select,
                      sourceRows: true,
                      dialogMode: true,
                      colors:
                          currentColors ??
                          MiuixDropdownDefaults.dialogColors(context),
                      showSurface: false,
                    ),
                  ),
                ),
                Padding(
                  padding: _miuixRoundedInsets(
                    context,
                    const EdgeInsetsDirectional.only(
                      start: 24,
                      top: 12,
                      end: 24,
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: MiuixTextButton(
                      label: confirmLabelProvider(),
                      minHeight: 50,
                      onPressed: dismiss,
                    ),
                  ),
                ),
              ],
            ),
          )
        : SizedBox(
            height: 420,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: MiuixListPopup<T>(
                      entries: const [],
                      groups: currentGroups,
                      onSelected: select,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: MiuixButton(
                    label: confirmLabelProvider(),
                    onPressed: dismiss,
                  ),
                ),
              ],
            ),
          );
  }

  final content = ValueListenableBuilder<int>(
    valueListenable: revision,
    builder: (context, revisionValue, _) => buildContent(context),
  );
  return presentation == MiuixPopupPresentation.overlay
      ? MiuixOverlayDialog.show<void>(
          context: context,
          title: title,
          content: content,
          insideMargin: sourceMode
              ? const EdgeInsets.symmetric(vertical: 24)
              : MiuixDialogDefaults.insideMargin,
          surfaceBuilder: sourceMode ? dialogSurfaceBuilder : null,
          renderInRootScaffold: renderInRootScaffold,
        )
      : MiuixWindowDialog.show<void>(
          context: context,
          title: title,
          content: content,
          insideMargin: sourceMode
              ? const EdgeInsets.symmetric(vertical: 24)
              : MiuixDialogDefaults.insideMargin,
          surfaceBuilder: sourceMode ? dialogSurfaceBuilder : null,
        );
}

/// Overlay-hosted grouped dropdown preference.
class MiuixOverlayGroupedDropdownPreference<T>
    extends MiuixGroupedDropdownPreference<T> {
  /// Creates an overlay grouped dropdown preference.
  const MiuixOverlayGroupedDropdownPreference({
    super.key,
    required super.title,
    required super.groups,
    required super.onSelected,
    super.summary,
    super.enabled,
    super.renderInRootScaffold,
    super.closeOnSelection,
    super.onExpandedChange,
    super.showValue,
    super.titleColors,
    super.summaryColors,
    super.leading,
    super.bottomAction,
    super.insideMargin,
    super.maxHeight,
    super.dropdownColors,
    super.dialogSurfaceBuilder,
    super.sourceMode,
  }) : super(presentation: MiuixPopupPresentation.overlay);

  /// Creates the current entries-based OverlayDropdownPreference overload.
  ///
  /// Empty groups are omitted before layout, matching the upstream entries
  /// overload rather than reserving blank separator space. Group enablement
  /// combines with each entry's enablement, so a disabled group remains
  /// visible but contributes no clickable rows. Multiple groups keep the
  /// popup open by default because each group owns an independent selection;
  /// callers can still override that behavior with [closeOnSelection].
  /// Overlay presentation resolves its anchor from the preference row.
  static MiuixOverlayGroupedDropdownPreference<T> source<T>({
    Key? key,
    required String title,
    required List<MiuixDropdownGroup<T>> groups,
    required ValueChanged<T> onSelected,
    String? summary,
    bool enabled = true,
    bool renderInRootScaffold = true,
    bool? closeOnSelection,
    ValueChanged<bool>? onExpandedChange,
    bool showValue = true,
    MiuixBasicComponentColors? titleColor,
    MiuixBasicComponentColors? summaryColor,
    MiuixDropdownColors? dropdownColors,
    Widget? startAction,
    Widget? bottomAction,
    EdgeInsetsGeometry insideMargin = MiuixBasicComponentDefaults.insideMargin,
    double? maxHeight,
  }) {
    return MiuixOverlayGroupedDropdownPreference<T>(
      key: key,
      title: title,
      groups: groups,
      onSelected: onSelected,
      summary: summary,
      enabled: enabled,
      renderInRootScaffold: renderInRootScaffold,
      closeOnSelection: closeOnSelection ?? groups.length <= 1,
      onExpandedChange: onExpandedChange,
      showValue: showValue,
      titleColors: titleColor,
      summaryColors: summaryColor,
      dropdownColors: dropdownColors,
      leading: startAction,
      bottomAction: bottomAction,
      insideMargin: insideMargin,
      maxHeight: maxHeight,
      sourceMode: true,
    );
  }
}

/// Window-hosted grouped dropdown preference.
class MiuixWindowGroupedDropdownPreference<T>
    extends MiuixGroupedDropdownPreference<T> {
  /// Creates a window grouped dropdown preference.
  const MiuixWindowGroupedDropdownPreference({
    super.key,
    required super.title,
    required super.groups,
    required super.onSelected,
    super.summary,
    super.enabled,
    super.closeOnSelection,
    super.onExpandedChange,
    super.showValue,
    super.titleColors,
    super.summaryColors,
    super.leading,
    super.bottomAction,
    super.insideMargin,
    super.maxHeight,
    super.dropdownColors,
    super.dialogSurfaceBuilder,
    super.sourceMode,
  }) : super(presentation: MiuixPopupPresentation.window);

  /// Creates the current entries-based WindowDropdownPreference overload.
  ///
  /// This uses the same filtered group model and seven-channel row palette as
  /// the Overlay overload, while presenting through the window-level dialog
  /// host used by the original MIUIX API. A non-empty group containing only
  /// disabled rows can still be opened for inspection, but its rows expose no
  /// tap callback or Android click semantics. Multiple groups therefore stay
  /// open by default unless [closeOnSelection] is supplied explicitly.
  /// Selection values remain typed and are forwarded without index remapping.
  static MiuixWindowGroupedDropdownPreference<T> source<T>({
    Key? key,
    required String title,
    required List<MiuixDropdownGroup<T>> groups,
    required ValueChanged<T> onSelected,
    String? summary,
    bool enabled = true,
    bool? closeOnSelection,
    ValueChanged<bool>? onExpandedChange,
    bool showValue = true,
    MiuixBasicComponentColors? titleColor,
    MiuixBasicComponentColors? summaryColor,
    MiuixDropdownColors? dropdownColors,
    Widget? startAction,
    Widget? bottomAction,
    EdgeInsetsGeometry insideMargin = MiuixBasicComponentDefaults.insideMargin,
    double? maxHeight,
  }) {
    return MiuixWindowGroupedDropdownPreference<T>(
      key: key,
      title: title,
      groups: groups,
      onSelected: onSelected,
      summary: summary,
      enabled: enabled,
      closeOnSelection: closeOnSelection ?? groups.length <= 1,
      onExpandedChange: onExpandedChange,
      showValue: showValue,
      titleColors: titleColor,
      summaryColors: summaryColor,
      dropdownColors: dropdownColors,
      leading: startAction,
      bottomAction: bottomAction,
      insideMargin: insideMargin,
      maxHeight: maxHeight,
      sourceMode: true,
    );
  }
}

/// Overlay-hosted grouped spinner preference.
class MiuixOverlayGroupedSpinnerPreference<T>
    extends MiuixGroupedDropdownPreference<T> {
  /// Creates an overlay grouped spinner preference.
  const MiuixOverlayGroupedSpinnerPreference({
    super.key,
    required super.title,
    required super.groups,
    required super.onSelected,
    super.summary,
    super.enabled,
    super.renderInRootScaffold,
    super.closeOnSelection,
    super.dialogConfirmLabel,
    super.onExpandedChange,
    super.showValue,
    super.titleColors,
    super.summaryColors,
    super.leading,
    super.bottomAction,
    super.insideMargin,
    super.maxHeight,
    super.dropdownColors,
    super.dialogSurfaceBuilder,
    super.sourceMode,
  }) : super(presentation: MiuixPopupPresentation.overlay);

  /// Creates the current entries-based OverlaySpinnerPreference overload.
  static MiuixOverlayGroupedSpinnerPreference<T> source<T>({
    Key? key,
    required String title,
    required List<MiuixDropdownGroup<T>> groups,
    required ValueChanged<T> onSelected,
    String? summary,
    bool enabled = true,
    bool renderInRootScaffold = true,
    bool? closeOnSelection,
    String? dialogButtonString,
    ValueChanged<bool>? onExpandedChange,
    bool showValue = true,
    MiuixBasicComponentColors? titleColor,
    MiuixBasicComponentColors? summaryColor,
    Widget? startAction,
    Widget? bottomAction,
    EdgeInsetsGeometry insideMargin = MiuixBasicComponentDefaults.insideMargin,
    double? maxHeight,
    MiuixSpinnerColors? spinnerColors,
    Widget Function(Widget child)? dialogSurfaceBuilder,
  }) {
    return MiuixOverlayGroupedSpinnerPreference<T>(
      key: key,
      title: title,
      groups: groups,
      onSelected: onSelected,
      summary: summary,
      enabled: enabled,
      renderInRootScaffold: renderInRootScaffold,
      closeOnSelection: closeOnSelection ?? groups.length <= 1,
      dialogConfirmLabel: dialogButtonString,
      onExpandedChange: onExpandedChange,
      showValue: showValue,
      titleColors: titleColor,
      summaryColors: summaryColor,
      leading: startAction,
      bottomAction: bottomAction,
      insideMargin: insideMargin,
      maxHeight: maxHeight,
      dropdownColors: spinnerColors,
      dialogSurfaceBuilder: dialogSurfaceBuilder,
      sourceMode: true,
    );
  }
}

/// Window-hosted grouped spinner preference.
class MiuixWindowGroupedSpinnerPreference<T>
    extends MiuixGroupedDropdownPreference<T> {
  /// Creates a window grouped spinner preference.
  const MiuixWindowGroupedSpinnerPreference({
    super.key,
    required super.title,
    required super.groups,
    required super.onSelected,
    super.summary,
    super.enabled,
    super.closeOnSelection,
    super.dialogConfirmLabel,
    super.onExpandedChange,
    super.showValue,
    super.titleColors,
    super.summaryColors,
    super.leading,
    super.bottomAction,
    super.insideMargin,
    super.maxHeight,
    super.dropdownColors,
    super.dialogSurfaceBuilder,
    super.sourceMode,
  }) : super(presentation: MiuixPopupPresentation.window);

  /// Creates the current entries-based WindowSpinnerPreference overload.
  static MiuixWindowGroupedSpinnerPreference<T> source<T>({
    Key? key,
    required String title,
    required List<MiuixDropdownGroup<T>> groups,
    required ValueChanged<T> onSelected,
    String? summary,
    bool enabled = true,
    bool? closeOnSelection,
    String? dialogButtonString,
    ValueChanged<bool>? onExpandedChange,
    bool showValue = true,
    MiuixBasicComponentColors? titleColor,
    MiuixBasicComponentColors? summaryColor,
    Widget? startAction,
    Widget? bottomAction,
    EdgeInsetsGeometry insideMargin = MiuixBasicComponentDefaults.insideMargin,
    double? maxHeight,
    MiuixSpinnerColors? spinnerColors,
    Widget Function(Widget child)? dialogSurfaceBuilder,
  }) {
    return MiuixWindowGroupedSpinnerPreference<T>(
      key: key,
      title: title,
      groups: groups,
      onSelected: onSelected,
      summary: summary,
      enabled: enabled,
      closeOnSelection: closeOnSelection ?? groups.length <= 1,
      dialogConfirmLabel: dialogButtonString,
      onExpandedChange: onExpandedChange,
      showValue: showValue,
      titleColors: titleColor,
      summaryColors: summaryColor,
      leading: startAction,
      bottomAction: bottomAction,
      insideMargin: insideMargin,
      maxHeight: maxHeight,
      dropdownColors: spinnerColors,
      dialogSurfaceBuilder: dialogSurfaceBuilder,
      sourceMode: true,
    );
  }
}

/// Overlay-named dropdown preference adapter.
class MiuixOverlayDropdownPreference<T> extends MiuixDropdownPreference<T> {
  /// Creates an overlay dropdown preference.
  const MiuixOverlayDropdownPreference({
    super.key,
    required super.title,
    required super.value,
    required super.entries,
    required super.onChanged,
    super.summary,
    super.enabled,
    super.renderInRootScaffold,
    super.onExpandedChange,
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
    super.dropdownColors,
    super.sourceMode,
  }) : super(presentation: MiuixPopupPresentation.overlay);

  /// Creates the exact index-based upstream OverlayDropdownPreference.
  static MiuixOverlayDropdownPreference<int> source({
    Key? key,
    required List<String> items,
    required int selectedIndex,
    required String title,
    MiuixBasicComponentColors? titleColor,
    String? summary,
    MiuixBasicComponentColors? summaryColor,
    MiuixDropdownColors? dropdownColors,
    Widget? startAction,
    Widget? bottomAction,
    EdgeInsetsGeometry insideMargin = MiuixBasicComponentDefaults.insideMargin,
    double? maxHeight,
    bool enabled = true,
    bool showValue = true,
    bool renderInRootScaffold = true,
    ValueChanged<bool>? onExpandedChange,
    ValueChanged<int>? onSelectedIndexChange,
  }) {
    final safeSelectedIndex = items.isEmpty
        ? 0
        : selectedIndex.clamp(0, items.length - 1);
    return MiuixOverlayDropdownPreference<int>(
      key: key,
      title: title,
      value: safeSelectedIndex,
      entries: [
        for (var index = 0; index < items.length; index++)
          MiuixDropdownEntry<int>(value: index, label: items[index]),
      ],
      onChanged: (index) => onSelectedIndexChange?.call(index),
      titleColors: titleColor,
      summary: summary,
      summaryColors: summaryColor,
      dropdownColors: dropdownColors,
      leading: startAction,
      bottomAction: bottomAction,
      insideMargin: insideMargin,
      maxHeight: maxHeight,
      enabled: enabled,
      showValue: showValue,
      renderInRootScaffold: renderInRootScaffold,
      onExpandedChange: onExpandedChange,
      sourceMode: true,
    );
  }
}

/// Window-named dropdown preference adapter.
class MiuixWindowDropdownPreference<T> extends MiuixDropdownPreference<T> {
  /// Creates a window dropdown preference.
  const MiuixWindowDropdownPreference({
    super.key,
    required super.title,
    required super.value,
    required super.entries,
    required super.onChanged,
    super.summary,
    super.enabled,
    super.renderInRootScaffold,
    super.onExpandedChange,
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
    super.dropdownColors,
    super.sourceMode,
  }) : super(presentation: MiuixPopupPresentation.window);

  /// Creates the exact index-based upstream WindowDropdownPreference.
  static MiuixWindowDropdownPreference<int> source({
    Key? key,
    required List<String> items,
    required int selectedIndex,
    required String title,
    MiuixBasicComponentColors? titleColor,
    String? summary,
    MiuixBasicComponentColors? summaryColor,
    MiuixDropdownColors? dropdownColors,
    Widget? startAction,
    Widget? bottomAction,
    EdgeInsetsGeometry insideMargin = MiuixBasicComponentDefaults.insideMargin,
    double? maxHeight,
    bool enabled = true,
    bool showValue = true,
    ValueChanged<bool>? onExpandedChange,
    ValueChanged<int>? onSelectedIndexChange,
  }) {
    final safeSelectedIndex = items.isEmpty
        ? 0
        : selectedIndex.clamp(0, items.length - 1);
    return MiuixWindowDropdownPreference<int>(
      key: key,
      title: title,
      value: safeSelectedIndex,
      entries: [
        for (var index = 0; index < items.length; index++)
          MiuixDropdownEntry<int>(value: index, label: items[index]),
      ],
      onChanged: (index) => onSelectedIndexChange?.call(index),
      titleColors: titleColor,
      summary: summary,
      summaryColors: summaryColor,
      dropdownColors: dropdownColors,
      leading: startAction,
      bottomAction: bottomAction,
      insideMargin: insideMargin,
      maxHeight: maxHeight,
      enabled: enabled,
      showValue: showValue,
      onExpandedChange: onExpandedChange,
      sourceMode: true,
    );
  }
}

/// Source ListPopupColumn used by dropdown preferences.
///
/// The generic compatibility popup supports disabled rows, summaries, icons,
/// and independent groups. The upstream preference instead supplies only a
/// String list and builds DropdownImpl directly for every index.
class _MiuixSourceDropdownPreferencePopup<T> extends StatelessWidget {
  const _MiuixSourceDropdownPreferencePopup({
    required this.entries,
    required this.selectedValue,
    required this.onSelected,
    required this.minWidth,
    this.colors,
    this.maxHeight,
  });

  final List<MiuixDropdownEntry<T>> entries;
  final T selectedValue;
  final ValueChanged<T> onSelected;
  final MiuixDropdownColors? colors;
  final double minWidth;
  final double? maxHeight;

  @override
  Widget build(BuildContext context) {
    final resolvedColors = colors ?? MiuixDropdownDefaults.colors(context);
    final semantic = MiuixSemanticColors.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minWidth.clamp(0, MiuixListPopupDefaults.maxWidth).toDouble(),
        maxWidth: MiuixListPopupDefaults.maxWidth,
        maxHeight: maxHeight ?? double.infinity,
      ),
      child: MiuixSurface(
        padding: EdgeInsets.zero,
        radius: MiuixListPopupDefaults.cornerRadius,
        // ListPopupContent owns a semantic surfaceContainer independently of
        // DropdownColors. A transparent custom row must not make the popup
        // itself transparent.
        color: semantic['surfaceContainer'],
        glass: true,
        child: MiuixListPopupColumn(
          children: [
            for (var index = 0; index < entries.length; index++)
              MiuixDropdownImpl(
                text: entries[index].label,
                optionSize: entries.length,
                isSelected: entries[index].value == selectedValue,
                index: index,
                colors: resolvedColors,
                onSelectedIndexChange: (selectedIndex) =>
                    onSelected(entries[selectedIndex].value),
              ),
          ],
        ),
      ),
    );
  }
}

/// Exact 10x16 end action used by Dropdown.kt.
///
/// Material's `unfold_more` reserves a square 20dp icon box and uses a
/// different stroke silhouette. The source vector is only 10dp wide, with two
/// rounded chevrons occupying the top and bottom halves. A tiny painter keeps
/// that geometry independent of the platform Material icon font.
class _MiuixDropdownArrow extends StatelessWidget {
  const _MiuixDropdownArrow({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: const Size(10, 16),
    painter: _MiuixDropdownArrowPainter(color),
  );
}

class _MiuixDropdownArrowPainter extends CustomPainter {
  const _MiuixDropdownArrowPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // ArrowUpDown.kt uses a roughly 1.52dp rounded stroke over a 10x16
    // viewport. Drawing the center lines reproduces its filled curved path
    // while avoiding scale-dependent Icon font bearings.
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.52
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final up = Path()
      ..moveTo(.92, 5.13)
      ..lineTo(5, 1.05)
      ..lineTo(9.08, 5.13);
    final down = Path()
      ..moveTo(.92, 10.87)
      ..lineTo(5, 14.95)
      ..lineTo(9.08, 10.87);
    canvas
      ..drawPath(up, paint)
      ..drawPath(down, paint);
  }

  @override
  bool shouldRepaint(covariant _MiuixDropdownArrowPainter oldDelegate) =>
      oldDelegate.color != color;
}
