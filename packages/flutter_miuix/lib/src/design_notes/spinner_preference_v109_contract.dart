// MIUIX v1.0.9 SpinnerPreference source contract.
//
// Authoritative preference sources:
// - miuix-preference/.../OverlaySpinnerPreference.kt;
// - miuix-preference/.../WindowSpinnerPreference.kt.
//
// Authoritative primitive sources:
// - miuix-ui/.../basic/Dropdown.kt;
// - miuix-ui/.../basic/ListPopup.kt;
// - miuix-ui/.../layout/DialogContentLayout.kt.
//
// Public state model
//
// The current source items parameter is List<DropdownItem>.
// MiuixSpinnerEntry remains the deprecated-name compatibility surface.
// DropdownItem independently permits a missing icon, title, or summary.
// Every item and every grouped DropdownEntry has its own enabled state.
// The selected state is an integer index rather than an arbitrary value.
// A non-empty list requires the index to identify an existing entry.
// An empty list does not dereference its retained selected index.
// The selection callback is nullable.
// Programmatic index changes do not emit user haptic feedback.
// The compatibility constructor retains generic value entries for old callers.
// Single-list source constructors keep the dedicated spinner-row path.
// Grouped entries use MiuixListPopup while retaining the same source row.
//
// BasicComponent forwarding
//
// Title and summary colors remain independent enabled/disabled pairs.
// startAction occupies the BasicComponent start slot.
// bottomAction occupies the BasicComponent bottom slot.
// insideMargin remains directional.
// actualEnabled equals enabled and items.isNotEmpty.
// Empty items disable the complete preference.
// Empty items still render the 10 by 16dp ArrowUpDown end action.
// No package-specific empty message is inserted.
// showValue false removes only the selected title text.
// A selected entry with a null title contributes an empty value string.
// The arrow remains visible when showValue is false.
// Selected value and arrow share the same resolved action color.
//
// Popup-mode lifecycle
//
// Popup mode is selected when dialogButtonString is absent.
// Opening a popup sets BasicComponent holdDown true.
// Opening a popup emits ContextClick.
// A repeated activation while expanded is ignored.
// Overlay presentation registers with MiuixPopupHost.
// Window presentation uses the root Navigator.
// renderInRootScaffold chooses the outermost or nearest Overlay host.
// Both presentations align the popup to the end-action anchor.
// Both presentations apply the same PopupPositionProvider.
// Selecting a row emits Confirm.
// Selection invokes the nullable index callback before dismissal.
// Selection then dismisses the popup immediately.
// holdDown clears after physical popup removal.
//
// Popup content and measurement
//
// Every popup row is MiuixSpinnerItemImpl with dialogMode false.
// First and last rows receive 20dp outer vertical padding.
// Interior row edges receive 12dp padding.
// Each row uses 20dp horizontal padding.
// Each horizontal modifier is converted with Compose roundToPx.
// At 420dpi popup 20dp is 53px and dialog 28dp is 74px.
// At 420dpi icon/check 12dp separation is 32px.
// At 420dpi the check's 20dp measured square is 53px.
// The source offers each icon one combined sizeIn-min26 and end12 modifier.
// That min26 constrains the complete padded icon rather than a separate slot.
// A normal 24dp icon therefore occupies 36dp, not the former incorrect 38dp.
// The leading icon/text group is capped at 216dp.
// The selected check reserves 20dp plus 12dp start padding.
// The popup measures only its first eight entries for width.
// The measured width is clamped to 200 through 288dp.
// Rich text and icon widths must participate in intrinsic measurement.
// A Flexible child must not report a fabricated zero text width.
// Tight 200dp rows must truncate rather than overflow.
// Later entries do not widen a popup selected by the first eight.
// maxHeight limits the scroll viewport without deleting entries.
// ListPopupContent owns the semantic surfaceContainer background.
// SpinnerColors container channels paint each individual row.
//
// Popup SpinnerColors
//
// Ordinary title uses contentColor.
// Ordinary summary uses summaryColor.
// Ordinary row background uses containerColor.
// Selected title uses selectedContentColor.
// Selected summary uses selectedSummaryColor.
// Selected row background uses selectedContainerColor.
// Selected check uses selectedIndicatorColor.
// An unselected check remains transparent while retaining geometry.
// Popup defaults use semantic surfaceContainer for both row backgrounds.
// Popup selected foreground defaults to primary.
// Custom immutable color objects are forwarded without copying.
//
// Dialog-mode lifecycle
//
// Dialog mode is selected when dialogButtonString is present.
// Opening a source dialog emits ContextClick through the shared click handler.
// Opening still sets BasicComponent holdDown true.
// Each dialog entry is MiuixSpinnerItemImpl with dialogMode true.
// Selecting a row emits Confirm.
// Selecting a row invokes the index callback immediately.
// Selecting a row dismisses the dialog immediately.
// The bottom text button dismisses without changing the selection.
// The bottom button is not a confirm step.
// This differs intentionally from the legacy compatibility constructor.
// Overlay and Window dialogs retain their respective host ownership.
// Dialog dismissal clears holdDown only after the exit lifecycle.
//
// Dialog geometry
//
// The source dialog overrides insideMargin to DpSize(0dp, 24dp).
// Therefore the list rows reach both horizontal surface edges.
// Dialog rows use 28dp horizontal content padding.
// Dialog rows have a 56dp minimum height.
// Dialog rows receive 12dp top and bottom padding regardless of index.
// Dialog rows fill the available width.
// The list remains scrollable when constrained by dialog height.
// The button receives 24dp start and end outside padding.
// The button receives 12dp top outside padding.
// The button fills the remaining dialog width.
// The button keeps a 50dp minimum height.
// dialogSurfaceBuilder is the Flutter equivalent of popupModifier.
//
// Dialog SpinnerColors
//
// Ordinary title uses onSurfaceContainer.
// Ordinary summary uses onSurfaceVariantSummary.
// Ordinary row background defaults to transparent.
// Selected title and summary use onTertiaryContainer.
// Selected row background uses tertiaryContainer.
// Selected check uses onTertiaryContainer.
// Popup colors are not silently reused as dialog defaults.
// An explicit spinnerColors object overrides every dialog channel together.
//
// Localized example obligations
//
// The current Home Spinner section retains the original ten-row order.
// Overlay popup remains first and Window popup second.
// Overlay dialog remains third and Window dialog fourth.
// Grouped Overlay popup remains fifth and grouped Window popup sixth.
// Grouped Overlay dialog remains seventh and grouped Window dialog eighth.
// Disabled Overlay and Window rows remain ninth and tenth.
// Ordinary rows retain four rich entries in their original color ordering.
// Grouped rows retain independent 2, 2, and 4-entry selection groups.
// The second and fourth entries of the final group remain disabled.
// Popup grouped selection stays open by default for more than one group.
// Chinese text replaces labels and summaries without reordering content.
// Both popup hosts retain the captured 525 by 666px four-row surface at 420dpi.
// The row rhythm remains 177, 156, 156, and 177 physical pixels.
// Grouped popup width remains 525px at 420dpi.
// Its eight row rhythm remains 177, six 156 rows, and 177 physical pixels.
// Its two rounded divider placeables each occupy exactly 26 physical pixels.
// All ten preference rows retain the 179,179,179,179,213,213,213,213,179,179
// physical-pixel rhythm measured from the current Android sample at 420dpi.
//
// Verification obligations
//
// Tests verify every source row parameter and slot.
// Tests verify empty items keep the exact arrow while disabling the row.
// Tests verify rich popup rows receive the explicit seven-channel colors.
// Tests verify a finite maxHeight produces a scroll viewport.
// Tests verify rich rows do not produce RenderFlex overflow.
// Tests verify popup opening emits ContextClick.
// Tests verify popup selection emits Confirm and closes.
// Tests verify dialog opening emits one ContextClick.
// Tests verify dialog selection emits one Confirm and closes immediately.
// Tests verify the bottom dialog button does not change selection.
// Tests verify dialog rows touch the surface's horizontal edges.
// Tests verify the localized popup retains the native physical dimensions.
// Android runtime verification must exercise both popup and dialog modes.
// Runtime logs must contain no FlutterError or RenderFlex overflow.
//
// Source-to-Flutter symbol mapping
//
// OverlaySpinnerPreference maps to MiuixOverlaySpinnerPreference.source.
// WindowSpinnerPreference maps to MiuixWindowSpinnerPreference.source.
// DropdownItem maps to MiuixSpinnerEntry pending the deprecated alias removal.
// Grouped DropdownEntry maps to MiuixDropdownGroup and MiuixDropdownEntry.
// SpinnerColors maps to MiuixSpinnerColors.
// SpinnerItemImpl maps to MiuixSpinnerItemImpl.
// ListPopupContent maps to MiuixListPopupColumn.
// DialogContentLayout maps to the configurable MiuixDialog content column.
// popupModifier maps to dialogSurfaceBuilder in dialog mode.
// popupModifier remains internal surface composition in popup mode.
// DpSize maps to EdgeInsets after preserving directional meaning.
// HapticFeedbackType.ContextClick maps to MiuixHapticRole.contextClick.
// HapticFeedbackType.Confirm maps to MiuixHapticRole.confirm.
//
// Parameter forwarding matrix
//
// items is retained as an ordered, immutable caller-owned list.
// selectedIndex is read on every rebuild and is never cached as authority.
// title is forwarded unchanged to the BasicComponent title slot.
// titleColor is resolved only by the BasicComponent enabled state.
// summary is forwarded unchanged to the BasicComponent summary slot.
// summaryColor is resolved only by the BasicComponent enabled state.
// spinnerColors is forwarded to every generated popup or dialog row.
// startAction is forwarded as a widget and is not icon-normalized.
// bottomAction is forwarded below the main row content.
// insideMargin controls the outer preference spacing, not popup padding.
// maxHeight constrains popup content after width measurement.
// enabled combines with list non-emptiness before gesture installation.
// showValue affects the selected title but never hides the arrow.
// onSelectedIndexChange receives the selected list index.
// renderInRootScaffold affects Overlay popup ownership only.
// dialogButtonString switches source presentation into dialog mode.
// dialogSurfaceBuilder wraps the source dialog surface without re-layout.
//
// Entry forwarding matrix
//
// entry icon is rendered before the text group when present.
// The icon and its 12dp end padding share the source 26dp minimum wrapper.
// entry title occupies the primary typography line when present.
// entry summary occupies the secondary typography line when present.
// a missing icon removes its reserved icon width and separation.
// a missing title does not promote summary into title typography.
// a missing summary removes only its secondary line.
// an entry with no text still retains its row tap target.
// selected state is computed exclusively from the current list index.
// entry identity never substitutes for list index equality.
// duplicated entry values remain independently selectable by position.
//
// Popup anchor invariants
//
// The popup anchor is the visible end-action region.
// Anchor geometry is captured after layout and before route insertion.
// The end edge stays associated with the preference trailing edge.
// The popup may shift inward to remain inside safe viewport bounds.
// Viewport correction must not expand the popup to screen width.
// Vertical correction chooses the side with usable viewport space.
// Popup placement must avoid the system status-bar inset.
// Popup placement must avoid the system navigation inset.
// Window mode must use equivalent bounds to Overlay mode.
// Root-overlay mode must convert anchor coordinates into root space.
// Nearest-overlay mode must convert anchor coordinates into local space.
// Scrolling the page dismisses or moves the owned popup consistently.
// Outside taps dismiss without changing the selected index.
// Back navigation dismisses before leaving the preference page.
//
// Popup shape and paint invariants
//
// The outer popup owns one continuous rounded surface.
// Row background colors are clipped by the popup surface boundary.
// The first selected row follows the top outer corners.
// The last selected row follows the bottom outer corners.
// Interior rows never introduce independent outer corner radii.
// Popup shadow belongs to the outer surface and not to each row.
// The outer surface uses the source elevation behavior.
// The modal scrim changes surrounding luminance without repainting rows.
// Content opacity is independent from the surrounding modal scrim.
// Check geometry stays aligned when selected state changes.
//
// Popup typography invariants
//
// Title typography follows the source preference popup token.
// Summary typography follows the source secondary popup token.
// Selected typography changes color without changing font metrics.
// Text scale participates in natural-width measurement.
// Text direction participates in leading and trailing placement.
// Long titles ellipsize instead of expanding beyond 288dp.
// Long summaries ellipsize independently from their titles.
// Two-line entries preserve source line spacing.
// Icon alignment uses the complete two-line text group's center.
// Check alignment uses the complete row content's center.
//
// Dialog ownership invariants
//
// Overlay dialog belongs to the overlay dialog presentation path.
// Window dialog belongs to the window dialog presentation path.
// The source mode distinction is retained on every platform.
// Barrier taps dismiss without selecting an entry.
// Back navigation dismisses without selecting an entry.
// The close button dismisses without selecting an entry.
// A row tap selects before the dialog exit animation begins.
// Repeated input during exit cannot emit duplicate callbacks.
// Dialog holdDown state clears even when the route is externally removed.
// Dialog surface customization cannot replace selection semantics.
//
// Dialog list invariants
//
// The dialog heading remains above the list when a title is supplied.
// The list begins after the source title/content separation.
// Selected background reaches the horizontal dialog content edges.
// Selected content retains its own 28dp horizontal inset.
// Every row keeps at least the source 56dp interactive height.
// Rich two-line rows may exceed the minimum without clipping.
// The list scrolls when all rows and button cannot fit.
// The button remains reachable after scrolling the list.
// List overscroll does not move the outer dialog surface.
// Keyboard traversal preserves the same ordered indices.
//
// Haptic invariants
//
// Disabled rows never request a haptic event.
// Empty source rows never request a haptic event.
// Popup opening requests exactly one ContextClick event.
// Popup row selection requests exactly one Confirm event.
// Popup outside dismissal requests no Confirm event.
// Dialog opening requests exactly one ContextClick event.
// Dialog row selection requests exactly one Confirm event.
// Dialog button dismissal requests no Confirm event.
// Dialog barrier dismissal requests no Confirm event.
// Programmatic rebuilds request no haptic event.
//
// Accessibility invariants
//
// The complete preference remains one activatable semantic action.
// Disabled state is exposed for disabled or empty preferences.
// The visible selected title participates in the value description.
// showValue false removes that visible value from semantics as well.
// Popup rows expose their selected state individually.
// Dialog rows expose their selected state individually.
// Icon-only entries retain a meaningful caller-provided semantic label.
// The arrow is decorative and does not become a duplicate tap target.
// Focus returns to the preference after popup dismissal.
// Focus returns to the preference after dialog dismissal.
//
// Regression audit sequence
//
// Analyze the package before running interaction tests.
// Run core contract tests before visual golden tests.
// Run overlay route tests for both popup and dialog source modes.
// Run haptic recorder tests for both presentation modes.
// Run the complete package suite to detect shared primitive regressions.
// Analyze the localized example after package tests.
// Run the complete localized example suite.
// Build the Android arm64 release artifact.
// Install with replacement semantics on the configured emulator.
// Confirm the package version code increased.
// Exercise popup opening, selection, and immediate dismissal.
// Exercise dialog opening, selection, and immediate dismissal.
// Capture popup and dialog runtime screenshots.
// Search logcat for fatal, FlutterError, and overflow signatures.
// Build the Windows x64 release application.
// Package both reusable platform archives.
// Verify portable forward-slash archive entry names.
// Record artifact byte sizes and SHA-256 digests.
// Re-run the public symbol and comment-ratio scope gate.
// Record the source-name mapping count in the parity ledger.
