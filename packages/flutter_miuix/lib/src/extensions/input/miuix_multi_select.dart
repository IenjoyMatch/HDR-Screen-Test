import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../effects/miuix_effects.dart';
import '../../platform/miuix_haptics.dart';
import '../../theme/miuix_semantic_colors.dart';
import '../../theme/miuix_theme.dart';
import '../../widgets/miuix_widgets.dart';
import '../miuix_extension_icons.dart';

/// One typed choice displayed by [MiuixMultiSelect].
@immutable
class MiuixMultiSelectOption<T> {
  /// Creates a selectable option.
  const MiuixMultiSelectOption({
    required this.value,
    required this.label,
    this.subtitle,
    this.enabled = true,
    this.leading,
  });

  /// Stable application value.
  final T value;

  /// Primary and optional secondary text.
  final String label;
  final String? subtitle;

  /// Whether this option can be toggled.
  final bool enabled;

  /// Optional icon or avatar.
  final Widget? leading;
}

/// Typed selected-value owner for [MiuixMultiSelect].
class MiuixMultiSelectController<T> extends ChangeNotifier {
  /// Creates a controller with an optional initial selection.
  MiuixMultiSelectController({Iterable<T> selected = const <Never>[]})
    : _selected = selected.toSet();

  Set<T> _selected;

  /// Immutable selected-value view.
  Set<T> get selected => UnmodifiableSetView<T>(_selected);

  /// Replaces the complete selected-value set.
  set selected(Iterable<T> values) {
    final next = values.toSet();
    if (next.length == _selected.length && next.containsAll(_selected)) return;
    _selected = next;
    notifyListeners();
  }

  /// Toggles one value.
  void toggle(T value) {
    final next = Set<T>.of(_selected);
    if (!next.remove(value)) next.add(value);
    selected = next;
  }

  /// Clears all values.
  void clear() => selected = const <Never>[];
}

/// Palette for multi-select field, chips, and dialog rows.
@immutable
class MiuixMultiSelectColors {
  /// Creates a complete multi-select palette.
  const MiuixMultiSelectColors({
    required this.background,
    required this.foreground,
    required this.secondaryForeground,
    required this.chipBackground,
    required this.chipForeground,
  });

  /// Field and text roles.
  final Color background;
  final Color foreground;
  final Color secondaryForeground;

  /// Selected chip roles.
  final Color chipBackground;
  final Color chipForeground;
}

/// Defaults shared by multi-select extensions.
abstract final class MiuixMultiSelectDefaults {
  // HyperOS 4 multi-selection implementation contract:
  // - The field uses the editable-control shape token, not a legacy radius.
  // - Existing public constructors and typed controller semantics stay intact.
  // - The dialog remains content-driven and caps only genuinely long lists.
  // - Selection is drafted locally until the explicit confirmation action.
  // - Cancel never mutates the caller-owned controller.
  // - Each option owns an equal-width complete-row interaction surface.
  // - The checkbox is a state affordance, not the sole selection highlight.
  // - Background, primary text, and secondary text share one state timeline.
  // - Disabled and maximum-limit rows retain clear semantics and hit behavior.
  // - Row identity follows the typed application value across dialog rebuilds.
  // - Collection-row radius and motion tokens govern every option.
  // - Reduced motion exposes the current draft endpoint in one rebuild.
  // - Outer-row taps emit the matching toggle-on or toggle-off haptic role.
  // - Final confirmation emits one confirm role after controller publication.
  // - Selected chips remain low capsules inside the field's shared surface.
  // - The field surface itself, not its rectangular bounds, owns indication.
  // - The field publishes merged button semantics for assistive technologies.
  // - Placeholder text keeps a secondary role until a selection is confirmed.
  // - Chip labels never alter the equal-width option rows in the dialog.
  // - The maximum-selection rule still permits deselecting an active value.
  // - A disabled option cannot be toggled through either row or checkbox.
  // - Dialog list padding remains zero so its host owns the content margins.
  // - Caller-provided leading content inherits the animated foreground role.
  // - Controller changes rebuild chips without transferring controller ownership.
  // These constraints make later styling changes preserve behavior and
  // accessibility without claiming private Xiaomi design constants.

  /// Radius of the field surface.
  static const double cornerRadius = 16;

  /// Minimum field height.
  static const double minimumHeight = 56;

  /// Maximum modal list height.
  static const double maximumDialogHeight = 420;

  /// Resolves semantic roles for the current theme.
  static MiuixMultiSelectColors colors(BuildContext context) {
    final semantic = MiuixSemanticColors.of(context);
    return MiuixMultiSelectColors(
      background: semantic['secondaryContainer'],
      foreground: semantic['onSurface'],
      secondaryForeground: semantic['onSurfaceSecondary'],
      chipBackground: semantic['tertiaryContainer'],
      chipForeground: semantic['onTertiaryContainer'],
    );
  }
}

/// MIUIX multi-select field with typed values and a modal choice list.
class MiuixMultiSelect<T> extends StatefulWidget {
  /// Creates a multi-select field.
  const MiuixMultiSelect({
    super.key,
    required this.options,
    this.controller,
    this.initialSelected = const <Never>[],
    this.onChanged,
    this.label,
    this.placeholder,
    this.dialogTitle,
    this.enabled = true,
    this.maximumSelection,
    this.glass = true,
    this.glassBlur,
    this.glassOpacity,
    this.showGlassSpecular = true,
    this.cornerRadius = double.nan,
    this.colors,
  }) : _sourceStyle = false;

  /// Creates the former fixed 16dp opaque multi-select field.
  const MiuixMultiSelect.source({
    super.key,
    required this.options,
    this.controller,
    this.initialSelected = const <Never>[],
    this.onChanged,
    this.label,
    this.placeholder,
    this.dialogTitle,
    this.enabled = true,
    this.maximumSelection,
    this.colors,
  }) : glass = false,
       glassBlur = null,
       glassOpacity = null,
       showGlassSpecular = false,
       cornerRadius = MiuixMultiSelectDefaults.cornerRadius,
       _sourceStyle = true;

  /// Available typed options.
  final List<MiuixMultiSelectOption<T>> options;

  /// Optional externally owned selection controller.
  final MiuixMultiSelectController<T>? controller;

  /// Initial values used by the internal controller.
  final Iterable<T> initialSelected;

  /// Called when a confirmed selection replaces the current one.
  final ValueChanged<Set<T>>? onChanged;

  /// Field, placeholder, and dialog labels.
  final String? label;
  final String? placeholder;
  final String? dialogTitle;

  /// Interaction and selection limits.
  final bool enabled;
  final int? maximumSelection;

  /// Trigger-field material and continuous-corner overrides.
  final bool glass;
  final double? glassBlur;
  final double? glassOpacity;
  final bool showGlassSpecular;
  final double cornerRadius;
  final bool _sourceStyle;

  /// Optional palette override.
  final MiuixMultiSelectColors? colors;

  @override
  State<MiuixMultiSelect<T>> createState() => _MiuixMultiSelectState<T>();
}

class _MiuixMultiSelectState<T> extends State<MiuixMultiSelect<T>> {
  // Selection-dialog ownership contract:
  // - Every opening owns one monotonically increasing local generation.
  // - A newer opening invalidates any unresolved result from an older route.
  // - The controller present at opening owns the initial draft snapshot.
  // - Only that identical controller may receive an accepted confirmation.
  // - Replacing the controller invalidates the route result before reattach.
  // - Replacing options invalidates a draft authored in the former value set.
  // - Changing the maximum invalidates choices made under the former limit.
  // - Disabling the trigger invalidates confirmation without forcing a pop.
  // - The route keeps its opening option snapshot for a coherent edit session.
  // - Theme-only rebuilds do not invalidate logically equivalent selection.
  // - Cancellation remains a null result and performs no controller mutation.
  // - A stale result never publishes through the current onChanged callback.
  // - Controller ownership and disposal remain independent of route lifetime.
  // - Disposal invalidates the generation before detaching its listener.
  // - Valid confirmation updates controller state before outward publication.
  // - The callback receives an immutable copy of the confirmed draft.
  // - Confirm haptics occur only for a result accepted by the current owner.
  // - Dialog row animation remains local and does not mutate durable selection.
  // - Disabled options and maximum-limited options remain non-interactive.
  // - Removing a selected option in a newer generation cannot revive it later.
  // - Example application state is not involved in this library-side barrier.
  // - Future modal entry points must join this generation ownership protocol.
  // Dynamic collection and trigger-keyboard contract:
  // - Controller values must exist in the current typed option collection.
  // - Disabled options remain valid existing selections until explicitly removed.
  // - Values for deleted options are removed from the controller immediately.
  // - Duplicate option values collapse into one logical selected entry.
  // - Reordering options preserves selection identity.
  // - Selection display order follows current option order.
  // - Null maximumSelection remains unlimited.
  // - Zero and negative maximumSelection resolve to one in Release mode.
  // - A reduced maximum keeps the earliest selected current options.
  // - A later maximum expansion never restores discarded stale values.
  // - Attachment normalization occurs before the widget listener is installed.
  // - Attachment correction does not invoke the user confirmation callback.
  // - External controller writes pass through the same legal-value projection.
  // - A recursion guard absorbs the nested controller correction notification.
  // - Programmatic reconciliation rebuilds without imitating user confirmation.
  // - External controller listeners can still observe the corrected state.
  // - Live options or maximum changes invalidate the active modal generation.
  // - The controller is reconciled before any replacement dialog opens.
  // - Confirmation can therefore never revive a value from deleted options.
  // - An empty option collection clears selection and disables the trigger.
  // - Empty disabled triggers expose no pointer or keyboard activation action.
  // - Trigger semantics uses the placeholder when no legal selection remains.
  // - Enter and Space open an enabled non-empty trigger.
  // - Alt+ArrowDown opens the same trigger for desktop convention compatibility.
  // - The composite trigger contributes one deterministic Tab focus stop.
  // - Opening through keyboard and pointer shares one generation boundary.
  // - Non-positive maximum values no longer disable every unselected dialog row.
  // - A selected row remains removable even while the draft is at its limit.
  // - Checkbox and full-row actions continue editing the same local draft.
  // - Glass and source constructors share all reconciliation behavior.
  // - Tests cover deleted values, reduced limits, empty triggers, and shortcuts.
  // - Device validation remains required for native focus-ring appearance.
  // Dialog keyboard and accessibility invariants:
  // - Every opening snapshots one row collection and creates one scroll owner.
  // - The dialog list owns one keyboard Focus rather than one Tab stop per row.
  // - Its first currently interactive row becomes the initial logical highlight.
  // - A leading run of disabled rows can never receive that highlight.
  // - Arrow Down searches forward without wrapping past the final option.
  // - Arrow Up searches backward without wrapping before the first option.
  // - Both directions skip rows disabled by the caller.
  // - Both directions also skip unselected rows disabled by the active maximum.
  // - A selected row stays interactive at the maximum so it can be removed.
  // - Enter and Space toggle only the currently highlighted interactive row.
  // - Other keyboard events remain available to the dialog and Navigator.
  // - Pointer row activation moves the logical highlight to the activated row.
  // - Checkbox activation moves the same highlight through the same helper.
  // - Row and checkbox activation emit one identical toggle haptic operation.
  // - Selection status and keyboard focus remain separate semantics properties.
  // - Each typed option value owns a stable semantics key for direct regression.
  // - Highlight movement never commits the durable external controller value.
  // - Draft mutation never publishes onChanged before explicit confirmation.
  // - Newly limited rows update immediately after a draft selection is added.
  // - Removing a selection immediately makes newly available rows navigable.
  // - A highlighted selected row remains valid during maximum enforcement.
  // - Long-list movement schedules visibility work after the rebuilt row exists.
  // - ensureVisible keeps an already visible row stationary where possible.
  // - Reduced-motion policy turns keyboard reveal animation into a direct jump.
  // - Ordinary reveal uses a short project-calibrated ease-out movement.
  // - Route completion happens before the local ScrollController is disposed.
  // - Navigator focus restoration returns interaction to the opening trigger.
  // - Cancellation discards every keyboard-authored draft mutation.
  // - Generation validation still rejects confirmation from an obsolete opening.
  // - Empty or fully unavailable lists leave the dialog row focus unrequested.
  // - Dialog action buttons remain reachable through the enclosing FocusTraversal.
  // - Source and HyperOS material modes share the same keyboard behavior.
  // - Widget tests cover disabled skipping, maximum changes, toggling, and restore.
  // - Hardware focus-ring appearance remains a Windows runtime validation item.
  // Focus movement edge cases:
  // - A one-row list treats both arrow directions as handled boundary attempts.
  // - Boundary attempts preserve highlight, draft selection, and scroll offset.
  // - A list becoming limited during the modal session is evaluated live.
  // - Logical value equality remains independent from label presentation changes.
  // - The stable opening snapshot prevents mid-route row identity replacement.
  // - A later widget collection instead invalidates the complete route generation.
  // - Semantics focused state follows every accepted keyboard movement in one frame.
  // - Semantics selected state follows every accepted toggle in that same rebuild.
  // - Disabled semantics continues reflecting the effective row action callback.
  // - The list controller is not shared with any application-owned scrollable.
  // - Reveal callbacks tolerate a route that closed before the scheduled frame.
  // - Missing row contexts therefore become safe no-ops rather than stale access.
  // - Focus ownership never leaks a node into the component's public API surface.
  // - Trigger keyboard activation and modal keyboard editing remain distinct scopes.
  // - Modal focus does not mutate the trigger's enabled or semantic value state.
  // - Confirm writes the final draft only after all generation checks succeed.
  // - The controller then normalizes once more against the current live options.
  // - Confirmation haptics remain separate from row-level toggle haptics.
  // - A rejected stale confirmation emits neither callback nor confirm feedback.
  // - These rules are reusable behavior rather than example-only event handling.
  // - Analysis and full tests run before Release version allocation.
  // - Android and Windows runtime checks remain separate from widget semantics.
  // Verification boundaries:
  // - Widget focus assertions verify Flutter semantics, not native narration tone.
  // - Widget scroll assertions verify visibility, not device refresh-rate smoothness.
  // - Haptic calls verify intent routing, not the physical actuator waveform.
  // - Golden coverage verifies material pixels under the deterministic test renderer.
  // - Windows hidden-launch smoke verifies responsiveness after Release compilation.
  // - Android static inspection verifies package, ABI, version, and test signature.
  // - A connected owned arm64 target is required for final system integration proof.
  // - Missing device proof must remain explicit in every Release handoff.
  // - No design metric in this keyboard contract is claimed as Xiaomi-published.
  // - Project-calibrated motion values remain replaceable through theme tokens.
  // - Explicit source presentation remains available for upstream comparison.
  // - Default presentation continues following the HyperOS 4 project baseline.
  // Detailed reconciliation invariants:
  // - Selection comparison uses typed value equality rather than row identity.
  // - A rebuilt Widget instance with equivalent values does not clear state.
  // - A row label or leading-widget change does not alter selection identity.
  // - Option order controls visible chips and deterministic limit retention.
  // - Controller Set insertion order is never trusted as display order.
  // - A disabled retained value remains visible as a disabled selected chip.
  // - Deleting that disabled option removes its now-unrepresentable value.
  // - An empty list correction occurs before trigger semantics are built.
  // - The resulting placeholder and controller empty set share one frame.
  // - The correction guard is active only for the nested setter notification.
  // - Ordinary later controller notifications remain observable and rebuild.
  // - Maximum normalization is shared by controller and dialog draft paths.
  // - The confirmed draft is already legal for the opening option snapshot.
  // - Generation validation then checks it against the current widget owner.
  // - Replaced options increment generation before reconciliation completes.
  // - A cancelled dialog never publishes the reconciled snapshot as a choice.
  // - Keyboard activation invokes the same asynchronous function as pointer tap.
  // - A disabled Focus node cannot consume Enter from surrounding navigation.
  // - Alt+ArrowDown is handled only while the enabled trigger owns focus.
  // - The trigger does not expose a clear action absent from the public API.
  // - Chips remain presentation-only inside the one trigger interaction node.
  // - Source chips and current chips read the identical legal selection list.
  // - Semantic value order matches visual chip order exactly.
  // - A placeholder-only trigger remains enabled when options still exist.
  // - Empty options are distinct from a non-empty list with every row disabled.
  // - The latter can still open so users can inspect retained disabled choices.
  // - Tests assert programmatic cleanup leaves onChanged untouched.
  // - Full-suite tests retain the existing modal cancellation behavior.
  // - Golden tests guard material and geometry independently from this state fix.
  // - These rules describe reusable library behavior across Android and Windows.
  late MiuixMultiSelectController<T> _controller;
  late bool _ownsController;
  int _dialogGeneration = 0;
  bool _normalizingSelection = false;

  int? get _effectiveMaximumSelection {
    final maximum = widget.maximumSelection;
    if (maximum == null) return null;
    return maximum < 1 ? 1 : maximum;
  }

  bool get _triggerEnabled => widget.enabled && widget.options.isNotEmpty;

  Set<T> _legalSelection() {
    final selected = _controller.selected;
    final maximum = _effectiveMaximumSelection;
    final legal = <T>{};
    for (final option in widget.options) {
      if (!selected.contains(option.value)) continue;
      legal.add(option.value);
      if (maximum != null && legal.length >= maximum) break;
    }
    return legal;
  }

  void _normalizeSelection() {
    final legal = _legalSelection();
    if (legal.length == _controller.selected.length &&
        legal.containsAll(_controller.selected)) {
      return;
    }
    _normalizingSelection = true;
    try {
      _controller.selected = legal;
    } finally {
      _normalizingSelection = false;
    }
  }

  @override
  void initState() {
    super.initState();
    _attachController();
  }

  void _attachController() {
    _ownsController = widget.controller == null;
    _controller =
        widget.controller ??
        MiuixMultiSelectController<T>(selected: widget.initialSelected);
    _normalizeSelection();
    _controller.addListener(_handleChanged);
  }

  @override
  void didUpdateWidget(MiuixMultiSelect<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final dialogContractChanged =
        oldWidget.controller != widget.controller ||
        oldWidget.options != widget.options ||
        oldWidget.maximumSelection != widget.maximumSelection ||
        oldWidget.enabled != widget.enabled;
    if (dialogContractChanged) _dialogGeneration++;
    if (oldWidget.controller != widget.controller) {
      _controller.removeListener(_handleChanged);
      if (_ownsController) _controller.dispose();
      _attachController();
      return;
    }
    if (oldWidget.options != widget.options ||
        oldWidget.maximumSelection != widget.maximumSelection) {
      _normalizeSelection();
    }
  }

  void _handleChanged() {
    if (!mounted || _normalizingSelection) return;
    _normalizeSelection();
    setState(() {});
  }

  Future<void> _showChoices() async {
    if (!_triggerEnabled) return;
    final generation = ++_dialogGeneration;
    final openingController = _controller;
    final openingOptions = widget.options;
    final openingMaximumSelection = _effectiveMaximumSelection;
    final draft = Set<T>.of(openingController.selected);
    final localizations = MaterialLocalizations.of(context);
    final colors = widget.colors ?? MiuixMultiSelectDefaults.colors(context);
    final navigator = Navigator.of(context, rootNavigator: true);
    final rowScrollController = ScrollController();
    final rowKeys = List<GlobalKey>.generate(
      openingOptions.length,
      (_) => GlobalKey(),
    );
    int? highlightedIndex;

    bool optionEnabled(int index) {
      final option = openingOptions[index];
      final selected = draft.contains(option.value);
      final atLimit =
          openingMaximumSelection != null &&
          draft.length >= openingMaximumSelection;
      return option.enabled && (selected || !atLimit);
    }

    for (var index = 0; index < openingOptions.length; index++) {
      if (optionEnabled(index)) {
        highlightedIndex = index;
        break;
      }
    }

    void revealHighlightedRow() {
      final index = highlightedIndex;
      if (index == null) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final rowContext = rowKeys[index].currentContext;
        if (rowContext != null) {
          Scrollable.ensureVisible(
            rowContext,
            duration: MediaQuery.disableAnimationsOf(rowContext)
                ? Duration.zero
                : const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
          );
        }
      });
    }

    void toggleOption(int index, StateSetter updateDialog) {
      if (!optionEnabled(index)) return;
      final option = openingOptions[index];
      final wasSelected = draft.contains(option.value);
      updateDialog(() {
        if (!draft.remove(option.value)) draft.add(option.value);
        highlightedIndex = index;
      });
      MiuixHaptics.perform(
        wasSelected ? MiuixHapticType.toggleOff : MiuixHapticType.toggleOn,
      );
    }

    final confirmed = await MiuixDialog.show<Set<T>>(
      context: context,
      title: widget.dialogTitle ?? widget.label,
      content: StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          final reduceMotion = MediaQuery.disableAnimationsOf(dialogContext);
          final hyperOs4 = MiuixTheme.of(dialogContext).hyperOs4;
          return Focus(
            autofocus: highlightedIndex != null,
            onKeyEvent: (node, event) {
              if (event is! KeyDownEvent || highlightedIndex == null) {
                return KeyEventResult.ignored;
              }
              final key = event.logicalKey;
              if (key == LogicalKeyboardKey.enter ||
                  key == LogicalKeyboardKey.space) {
                toggleOption(highlightedIndex!, setDialogState);
                return KeyEventResult.handled;
              }
              final direction = switch (key) {
                LogicalKeyboardKey.arrowDown => 1,
                LogicalKeyboardKey.arrowUp => -1,
                _ => 0,
              };
              if (direction == 0) return KeyEventResult.ignored;
              var candidate = highlightedIndex! + direction;
              while (candidate >= 0 && candidate < openingOptions.length) {
                if (optionEnabled(candidate)) {
                  setDialogState(() => highlightedIndex = candidate);
                  revealHighlightedRow();
                  break;
                }
                candidate += direction;
              }
              return KeyEventResult.handled;
            },
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: MiuixMultiSelectDefaults.maximumDialogHeight,
              ),
              child: ListView.builder(
                controller: rowScrollController,
                primary: false,
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: openingOptions.length,
                itemBuilder: (context, index) {
                  final option = openingOptions[index];
                  final selected = draft.contains(option.value);
                  final atLimit =
                      openingMaximumSelection != null &&
                      draft.length >= openingMaximumSelection;
                  final enabled = option.enabled && (selected || !atLimit);
                  return Padding(
                    key: rowKeys[index],
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: TweenAnimationBuilder<double>(
                      // Each logical value owns one continuous highlight. A
                      // runtime accessibility change replaces that animation
                      // and exposes the draft selection endpoint immediately.
                      key: ValueKey<(T, bool)>((option.value, reduceMotion)),
                      tween: Tween<double>(end: selected ? 1 : 0),
                      duration: reduceMotion
                          ? Duration.zero
                          : hyperOs4.collectionRowMotion,
                      curve: Curves.easeOutCubic,
                      builder: (context, selectionProgress, _) {
                        final foreground = Color.lerp(
                          colors.foreground,
                          colors.chipForeground,
                          selectionProgress,
                        )!;
                        final secondary = Color.lerp(
                          colors.secondaryForeground,
                          colors.chipForeground,
                          selectionProgress,
                        )!;
                        final background = Color.lerp(
                          Colors.transparent,
                          colors.chipBackground,
                          selectionProgress,
                        )!;
                        return Semantics(
                          key: ValueKey<Object>((
                            'miuix-multi-select-row-semantics',
                            option.value,
                          )),
                          selected: selected,
                          focused: highlightedIndex == index,
                          child: MiuixSurface(
                            onTap: enabled
                                ? () => toggleOption(index, setDialogState)
                                : null,
                            enabled: enabled,
                            feedbackType: MiuixPressFeedbackType.sink,
                            radius: hyperOs4.collectionRowCornerRadius,
                            color: background,
                            contentColor: foreground,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: SizedBox(
                              height: option.subtitle == null ? 56 : 68,
                              child: Row(
                                children: <Widget>[
                                  if (option.leading != null) ...<Widget>[
                                    option.leading!,
                                    const SizedBox(width: 12),
                                  ],
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(option.label),
                                        if (option.subtitle != null)
                                          Text(
                                            option.subtitle!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(color: secondary),
                                          ),
                                      ],
                                    ),
                                  ),
                                  MiuixCheckbox(
                                    value: selected,
                                    enabled: enabled,
                                    onChanged: enabled
                                        ? (_) => toggleOption(
                                            index,
                                            setDialogState,
                                          )
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
      actions: <Widget>[
        MiuixTextButton(
          label: localizations.cancelButtonLabel,
          onPressed: navigator.pop,
        ),
        MiuixButton(
          label: localizations.okButtonLabel,
          filled: true,
          onPressed: () => navigator.pop(Set<T>.of(draft)),
        ),
      ],
    );
    rowScrollController.dispose();
    if (!mounted ||
        confirmed == null ||
        generation != _dialogGeneration ||
        !identical(_controller, openingController) ||
        !_triggerEnabled) {
      return;
    }
    openingController.selected = confirmed;
    widget.onChanged?.call(Set<T>.unmodifiable(confirmed));
    MiuixHaptics.perform(MiuixHapticType.confirm);
  }

  @override
  void dispose() {
    _dialogGeneration++;
    _controller.removeListener(_handleChanged);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors ?? MiuixMultiSelectDefaults.colors(context);
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final radius = widget.cornerRadius.isFinite && widget.cornerRadius >= 0
        ? widget.cornerRadius
        : hyperOs4.textFieldCornerRadius;
    final selectedOptions = widget.options
        .where((option) => _controller.selected.contains(option.value))
        .toList(growable: false);
    final chipColors = MiuixChipColors(
      background: colors.chipBackground,
      foreground: colors.chipForeground,
      selectedBackground: colors.chipBackground,
      selectedForeground: colors.chipForeground,
      disabledBackground: colors.chipBackground.withValues(alpha: .5),
      disabledForeground: colors.secondaryForeground,
      outline: Colors.transparent,
    );

    final trigger = Semantics(
      button: true,
      enabled: _triggerEnabled,
      label: widget.label,
      value: selectedOptions.isEmpty
          ? widget.placeholder ?? widget.label ?? ''
          : selectedOptions.map((option) => option.label).join(', '),
      child: MiuixSurface(
        key: const ValueKey('miuix-multi-select-trigger'),
        color: colors.background,
        radius: radius,
        glass: widget.glass,
        glassBlur: widget.glassBlur ?? hyperOs4.contentSurfaceBlur,
        glassOpacity: widget.glassOpacity ?? hyperOs4.contentSurfaceTintOpacity,
        showGlassSpecular: widget.showGlassSpecular,
        onTap: _triggerEnabled ? _showChoices : null,
        enabled: _triggerEnabled,
        feedbackType: MiuixPressFeedbackType.sink,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: MiuixMultiSelectDefaults.minimumHeight,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: selectedOptions.isEmpty
                    ? Text(
                        widget.placeholder ?? widget.label ?? '',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colors.secondaryForeground,
                        ),
                      )
                    : Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: selectedOptions
                            .map(
                              (option) => widget._sourceStyle
                                  ? MiuixSurface(
                                      key: ValueKey<Object>((
                                        'miuix-multi-select-source-chip',
                                        option.value,
                                      )),
                                      color: colors.chipBackground,
                                      contentColor: colors.chipForeground,
                                      radius: 999,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      child: Text(option.label),
                                    )
                                  : MiuixChip(
                                      key: ValueKey<Object>((
                                        'miuix-multi-select-chip',
                                        option.value,
                                      )),
                                      label: option.label,
                                      variant: MiuixChipVariant.input,
                                      selected: true,
                                      enabled: _triggerEnabled,
                                      // The trigger already owns the sampled
                                      // glass layer; nested blur would double
                                      // sample and darken overlapping chips.
                                      glass: false,
                                      colors: chipColors,
                                    ),
                            )
                            .toList(),
                      ),
              ),
              const SizedBox(width: 8),
              MiuixExtensionChevron(
                direction: MiuixExtensionChevronDirection.down,
                color: colors.foreground,
              ),
            ],
          ),
        ),
      ),
    );
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.arrowDown, alt: true):
            ActivateIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _showChoices();
              return null;
            },
          ),
        },
        child: Focus(canRequestFocus: _triggerEnabled, child: trigger),
      ),
    );
  }
}
