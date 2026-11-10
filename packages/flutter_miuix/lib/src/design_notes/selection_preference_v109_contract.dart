// MIUIX v1.0.9 selection-preference source contract.
//
// This file records the audited behavior of three upstream components:
// - miuix-preference/.../SwitchPreference.kt;
// - miuix-preference/.../CheckboxPreference.kt;
// - miuix-preference/.../RadioButtonPreference.kt.
//
// It is intentionally documentation-only.
// Runtime implementation stays split between preference_controls.dart and
// preference_selection.dart so neither implementation file becomes a catalog.
//
// Shared BasicComponent delegation
//
// Each preference delegates its row layout to BasicComponent.
// Each preference forwards title to the BasicComponent text overload.
// Each preference forwards summary to the BasicComponent text overload.
// Each preference forwards titleColor independently from summaryColor.
// Each preference forwards startAction without wrapping the complete row.
// Each preference forwards endActions without replacing the control.
// Each preference forwards bottomAction below the main row.
// Each preference forwards the directional insideMargin value.
// Each preference forwards the externally held interaction state.
// Each preference forwards enabled to both row and nested control.
// No preference creates an additional Card in the source-style constructor.
// Card grouping remains the responsibility of the calling example.
//
// Shared source spacing
//
// BasicComponent inserts an 8dp gap after an occupied start slot.
// BasicComponent inserts an 8dp gap before an occupied end slot.
// A preference can add spacing inside either supplied slot as well.
// Those two layers of spacing are independent upstream decisions.
// Removing one layer changes the source center-allocation pressure.
// Empty endActions still count because the wrapper Row is always emitted.
// That wrapper carries 8dp directional end padding.
// Therefore a missing caller end action does not mean a zero-width wrapper.
// Long-title tests lock the resulting center width at a compact viewport.
// Directional padding is used so right-to-left layouts mirror correctly.
//
// SwitchPreference public contract
//
// checked is a non-null Boolean.
// onCheckedChange is a non-null value callback.
// title is a non-null String.
// summary is nullable.
// startAction is nullable.
// endActions is nullable caller content.
// bottomAction is nullable caller content.
// switchColors is independently replaceable.
// insideMargin defaults to the BasicComponent source value.
// holdDownState defaults to false.
// enabled defaults to true.
// The row click callback negates the current checked value.
// The nested Switch receives the current checked value.
// The nested Switch receives the same onCheckedChange callback.
// The nested Switch receives the source switch palette.
// The nested Switch receives enabled.
// The end slot is a horizontal Row.
// Caller endActions appear before the switch.
// The caller-content wrapper reserves 8dp after those actions.
// That 8dp remains when caller endActions is absent.
// BasicComponent adds its separate occupied-end 8dp gap.
// The switch is the final visual item in the end slot.
// Row activation and direct-control activation must both work.
// Direct-control semantics remain Switch semantics.
// The complete row also exposes the source Switch role and current state.
// Direct-control feedback remains owned by MiuixSwitch.
// Row feedback remains owned by the shared BasicComponent pressable.
//
// CheckboxPreference public contract
//
// title is a non-null String.
// checked is a non-null Boolean in the preference wrapper.
// onCheckedChange is nullable upstream.
// summary is nullable.
// checkboxColors is independently replaceable.
// endActions is nullable caller content.
// checkboxLocation defaults to Start.
// bottomAction is nullable caller content.
// insideMargin defaults to the BasicComponent source value.
// holdDownState defaults to false.
// enabled defaults to true.
// The Flutter location enum uses start and end values.
// Compatibility construction now also defaults to source-correct start.
// A start checkbox is wrapped with 8dp directional end padding.
// BasicComponent then adds its own occupied-start 8dp gap.
// This intentional combined spacing is visible in upstream layout.
// The endActions wrapper is always emitted.
// Its caller content is followed by 8dp directional end padding.
// The checkbox follows that wrapper only for the End location.
// BasicComponent adds the occupied-end gap before the complete end slot.
// The row click callback toggles checked when a callback exists.
// When the callback is null, upstream still supplies a no-op click lambda.
// The Flutter source adapter preserves that clickable row shape.
// The nested checkbox stays disabled only when enabled is false.
// Nullable callback does not itself change the enabled visual palette.
// The nested control uses tristate plumbing for source checkbox reuse.
// Preference state passed by this API remains true or false.
// Direct checkbox activation invokes the same owner callback.
// The complete row exposes the source Checkbox role and checked state.
// Direct-control semantics remain Checkbox semantics.
// Direct-control haptics remain owned by MiuixCheckbox.
// Row activation uses the shared preference haptic path.
//
// RadioButtonPreference public contract
//
// title is a non-null String.
// selected is a non-null Boolean.
// onClick is nullable upstream.
// summary is nullable.
// radioButtonColors is independently replaceable.
// endActions is nullable caller content.
// radioButtonLocation defaults to Start.
// bottomAction is nullable caller content.
// insideMargin defaults to the BasicComponent source value.
// holdDownState defaults to false.
// enabled defaults to true.
// The generic compatibility widget still models value and groupValue.
// The source adapter collapses that model to selected.
// It uses true as the represented value.
// It uses selected as the source-equivalent group value.
// Selecting the row invokes onClick without inventing a second value.
// The start radio is wrapped with 8dp directional end padding.
// BasicComponent then adds its own occupied-start 8dp gap.
// The endActions wrapper is always emitted.
// Its caller content is followed by 8dp directional end padding.
// The radio follows that wrapper only for the End location.
// BasicComponent adds the occupied-end gap before the complete end slot.
// When onClick is null, upstream still supplies a no-op row click lambda.
// The Flutter source adapter preserves that row interaction structure.
// The direct radio control invokes onClick when it is available.
// Direct-control semantics remain RadioButton semantics.
// The complete row exposes the source RadioButton role and selected state.
// Direct-control haptics remain owned by MiuixRadioButton.
// Row activation uses the shared preference haptic path.
//
// Color forwarding
//
// Title colors use MiuixBasicComponentColors.
// Summary colors use a separate MiuixBasicComponentColors instance.
// Switch colors use MiuixSwitchColors.
// Checkbox colors use MiuixCheckboxColors.
// Radio colors use MiuixRadioButtonColors.
// Callers can pass immutable palette objects.
// Adapters forward those objects without copying or merging them.
// Enabled selection resolves each control's selected channel.
// Disabled selection resolves each control's disabled channel.
// BasicComponent resolves text colors separately from control colors.
// A disabled row must not erase a caller-provided disabled text color.
// A disabled control must not reuse an enabled selected color.
//
// Interaction ownership
//
// BasicComponent owns the complete row pointer region.
// Nested controls own their smaller direct pointer regions.
// Gesture arbitration prevents one tap from toggling twice.
// A row tap invokes exactly one owner callback.
// A direct-control tap invokes exactly one owner callback.
// Disabled rows install no effective owner mutation.
// Externally held state affects the shared row indication.
// It does not force the nested control into a synthetic pressed state.
// Platform haptic dispatch stays in the existing shared adapters.
// Windows keeps its safe Flutter fallback.
// Android keeps native role-aware feedback through the package plugin.
//
// Localized example obligations
//
// The primary Switch card calls MiuixSwitchPreference.source.
// The primary Checkbox card calls MiuixCheckboxPreference.source.
// The primary RadioButton card calls MiuixRadioButtonPreference.source.
// Chinese labels replace text without changing component order.
// Chinese labels do not change location defaults.
// Chinese labels do not remove empty slot reservations.
// Example state remains hoisted in the page State object.
// Whole-row taps visibly update the same hoisted values.
// Direct-control taps visibly update the same hoisted values.
// Disabled examples remain present in the same card order.
//
// Verification obligations
//
// Focused tests verify switch row toggling.
// Focused tests verify checkbox row toggling.
// Focused tests verify radio row selection.
// Focused tests verify switch color identity.
// Focused tests verify checkbox color identity.
// Focused tests verify radio color identity.
// Focused tests verify bottom actions remain mounted.
// Focused tests verify start and end slot ordering.
// Focused tests verify externally held row state.
// Focused tests verify exact compact long-title widths.
// Golden tests cover light, dark, pressed, disabled, expanded, and midpoint.
// Only source-authorized geometry changes may refresh those baselines.
// Android runtime inspection must show no overflow or Flutter exception.
// Android packaging must retain the existing package signer.
// Android versionCode must increase for in-place replacement.
// Windows startup smoke testing must keep the process alive.
// Library archives must include these source adapters and this contract.
// Package verification must analyze each extracted archive independently.
