// MIUIX v1.0.9 DropdownPreference source contract.
//
// Authoritative component sources:
// - miuix-preference/.../OverlayDropdownPreference.kt;
// - miuix-preference/.../WindowDropdownPreference.kt;
// - miuix-ui/.../basic/Dropdown.kt;
// - miuix-ui/.../basic/ListPopup.kt.
//
// Authoritative example sources:
// - example/.../component/DropdownSection.kt;
// - example/.../DropdownPage.kt;
// - example/.../MultiScaffoldTestPage.kt.
//
// Public state model
//
// The current source exposes List<String>, one DropdownEntry, and grouped
// List<DropdownEntry> overloads.
// DropdownItem carries text, enabled, selected, onClick, icon, summary, and
// optional children for the separate cascading-menu family.
// DropdownEntry carries an item list plus an enabled flag for the whole group.
// The upstream selectedIndex parameter is Int.
// The upstream title parameter is non-null.
// The upstream summary parameter is nullable.
// The upstream selection callback is nullable.
// The source adapter keeps integer state instead of fabricating string IDs.
// Every generated Flutter entry uses its source index as the value.
// A non-empty list requires selectedIndex to identify one item.
// An empty list does not dereference selectedIndex.
// Therefore an empty source list may retain any previously hoisted index.
//
// BasicComponent forwarding
//
// Both preference families delegate their row to BasicComponent.
// Both rows expose the source DropdownList accessibility role.
// titleColor is forwarded as a complete enabled/disabled pair.
// summaryColor is forwarded independently from titleColor.
// startAction occupies the BasicComponent start slot.
// bottomAction occupies the BasicComponent bottom slot.
// insideMargin uses directional EdgeInsetsGeometry.
// enabled is combined with the non-empty item or non-empty-group condition.
// An empty item list disables the complete row.
// Empty groups are filtered before popup layout and selected-value rendering.
// A non-empty group still opens when all its items are disabled.
// A disabled group renders all of its items disabled after opening.
// A disabled caller preference also disables the complete row.
// Disabled title and summary colors come from their supplied pairs.
// The source adapter does not add an outer Card.
// The example continues to own every grouping Card.
//
// End-action contract
//
// The end-action Row always contains the 10 by 16dp dropdown arrow.
// The selected value is optional and precedes the arrow.
// showValue defaults to true.
// showValue false removes only the selected-value Text.
// showValue false does not remove the dropdown arrow.
// Empty items remove the selected-value Text.
// Empty items do not remove the dropdown arrow.
// Empty items do not insert an explanatory fallback string.
// The selected value uses the source body2 size.
// The selected value uses one fixed 17dp Android line box.
// The selected value is end aligned.
// The selected value is limited to one line.
// The selected value truncates rather than wrapping.
// Eight dp separate the selected value from the arrow.
// The complete end-action row is the popup anchor.
// The complete preference row is not the popup anchor.
//
// Enabled and held behavior
//
// actualEnabled equals enabled and itemsNotEmpty upstream.
// Opening a popup sets the held state true.
// Popup-mode opening emits ContextClick haptic feedback.
// Selecting a row emits Confirm haptic feedback.
// Popup dismissal eventually clears held state.
// A repeated click while already expanded does not add another popup.
// Disabled rows install no opening callback.
// Empty rows install no opening callback.
// The arrow uses the disabled action color whenever actualEnabled is false.
// The selected value uses the same resolved action color as the arrow.
//
// Overlay and window ownership
//
// OverlayDropdownPreference registers with a Scaffold popup host.
// renderInRootScaffold defaults to true.
// A true value selects the outermost MiuixScaffold host.
// A false value selects the nearest MiuixScaffold host.
// WindowDropdownPreference uses the root Navigator route.
// WindowDropdownPreference does not require a MiuixScaffold host.
// Both families use end alignment.
// Both families share PopupPositionProvider geometry.
// Both families preserve the same source animation channels.
// Both families dismiss immediately after a valid selection.
// Both families release held state only after dismissal finishes.
//
// Nested-host physical-coordinate correction
//
// Compose measures a half-width nested Scaffold independently.
// Compose then measures the BasicComponent end slot independently.
// At 420dpi those two integer passes move the final right edge by one pixel.
// Flutter normally carries their shared fractional coordinate to the route.
// The source overlay adapter compensates one physical pixel for local hosts.
// The correction applies only to source-mode nested Overlay preferences.
// Root Overlay preferences retain their existing exact anchor.
// Window preferences retain their existing exact anchor.
// Generic compatibility preferences retain caller-owned popupAnchorOffset.
// The MultiScaffold lower-right surface remains at physical x=481.
// Clipping still occurs at the nested host boundary after placement.
//
// Popup width contract
//
// ListPopupColumn measures only the first eight rows for width.
// Every row remains present even when excluded from width measurement.
// The minimum popup width is 200dp.
// The maximum popup width is 288dp.
// Long later rows truncate inside the already selected width.
// Localized short labels still preserve the 200dp minimum.
// DropdownImpl limits its text to 200dp before outer row padding.
// Every row reserves a 20dp trailing check image.
// Every row reserves 12dp before that check.
// A transparent check occupies the same geometry as a selected check.
// Row width therefore never changes when selection changes.
//
// Popup height contract
//
// The first row receives 20dp top padding.
// Every non-first row receives 12dp top padding.
// The last row receives 20dp bottom padding.
// Every non-last row receives 12dp bottom padding.
// Text height comes from the source body1 line box.
// maxHeight is nullable.
// A null maxHeight leaves viewport placement as the only height limit.
// A finite maxHeight constrains the scroll viewport.
// It does not remove or lazily omit source rows.
// MiuixListPopupColumn remains directly scrollable.
//
// DropdownImpl color contract
//
// Ordinary title uses DropdownColors.contentColor.
// Ordinary summary uses DropdownColors.summaryColor.
// Ordinary background uses DropdownColors.containerColor.
// Selected title uses DropdownColors.selectedContentColor.
// Selected summary uses DropdownColors.selectedSummaryColor.
// Selected background uses DropdownColors.selectedContainerColor.
// The selected check uses DropdownColors.selectedIndicatorColor.
// The unselected check uses transparent.
// Custom immutable palette objects are forwarded without copying.
// The popup surface independently uses the semantic surfaceContainer color.
// Transparent custom row containers therefore do not erase the popup surface.
// Default colors continue to resolve from MiuixDropdownDefaults.
//
// DropdownImpl arrangement contract
//
// The source Row uses Arrangement.SpaceBetween.
// The text stays at the start padding.
// The check stays at the end padding.
// Extra minimum-width space belongs between text and check.
// It must not be inserted after the check.
// It must not be divided around a separate Spacer child.
// The check remains at the same far edge for every label length.
// Right-to-left direction mirrors start and end automatically.
//
// Localized example obligations
//
// DropdownSection keeps six rows in the original order.
// Its first row uses OverlayDropdownPreference.source.
// Its second row uses WindowDropdownPreference.source.
// Its third row uses the current grouped Overlay entries overload.
// Its fourth row uses the current grouped Window entries overload.
// Its final two rows remain disabled.
// Group sizes remain two, three, and four items.
// The final group's second and fourth items remain disabled.
// Grouped popup selection remains open because there are multiple groups.
// DropdownPage alternates overlay and window rows.
// DropdownPage begins with six rows.
// Pull-to-refresh appends six more rows after 200ms.
// Every DropdownPage row shares one selected integer.
// The page retains its independent final 12dp spacer.
// MultiScaffold keeps four independently hoisted integers.
// Each nested host uses renderInRootScaffold false.
// Chinese translation changes text only.
// Chinese translation does not reorder rows or options.
//
// Verification obligations
//
// Tests verify every source parameter reaches the row.
// Tests verify showValue false removes only the value.
// Tests verify empty items produce disabled row colors.
// Tests verify empty items do not produce fallback English text.
// Tests verify custom DropdownColors reach every DropdownImpl.
// Tests verify maxHeight constrains a twelve-row popup.
// Tests verify selecting index one reports integer one.
// Tests verify selection closes the popup.
// Tests verify the 200dp short-label width.
// Tests verify first and last source padding totals.
// Tests verify the check remains at the far edge.
// Tests verify nested-host x=481 at the reference density.
// Golden coverage retains the complete open DropdownPage frame.
// Android runtime evidence must include the open localized popup.
// Runtime logs must contain no overflow or Flutter exception.
