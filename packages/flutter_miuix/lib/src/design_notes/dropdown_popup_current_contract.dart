library flutter_miuix_dropdown_popup_current_contract;

// Current MIUIX DropdownPopup and DropdownDialog parity contract.
//
// Authoritative source files:
// - miuix-preference/.../popup/OverlayDropdownPopup.kt
// - miuix-preference/.../popup/WindowDropdownPopup.kt
//
// Public Flutter entry points:
// - MiuixOverlayDropdownPopup.show
// - MiuixWindowDropdownPopup.show
// - MiuixOverlayDropdownDialog.show
// - MiuixWindowDropdownDialog.show
//
// Compatibility boundary:
// - The unnamed widget constructors predate the current source adapters.
// - Those constructors remain inline list surfaces for existing applications.
// - They do not claim to create an OverlayDialog or WindowDialog route.
// - The static show methods are the source-equivalent hosted entry points.
// - Adding the hosted entry points must not change old constructor defaults.
// - MiuixOverlayListPopup and MiuixWindowListPopup keep bottomStart defaults.
// - Current DropdownPopup explicitly requests logical-end alignment itself.
// - Source behavior must not leak into generic compatibility list defaults.
//
// Data model:
// - A flat entries list represents one visible logical group.
// - MiuixDropdownGroup represents one independently selectable source group.
// - Empty groups do not reserve a divider or interaction row.
// - Group order remains the authored order.
// - Entry order remains the authored order inside each group.
// - Group enabled state combines with each entry enabled state.
// - A disabled row retains geometry but exposes no activation action.
// - Selected state is read from the current MiuixDropdownEntry model.
// - Popup-local checks update before the application callback observes input.
// - Groups are separated by the same source divider used by preferences.
// - An icon is an arbitrary leading presentation slot.
// - Summary text remains independently optional from the main label.
// - Long labels may wrap under current DropdownImpl rules.
// - The transparent check slot is measured on every row.
// - Duplicate application values in separate groups remain separate rows.
// - Multi-group selection state remains independently owned per group.
//
// Popup hosting:
// - OverlayDropdownPopup requires a MiuixPopupHost in the active subtree.
// - renderInRootScaffold selects the root or nearest popup host.
// - WindowDropdownPopup always creates a root Navigator route.
// - Overlay and Window variants must never become aliases of one host.
// - Overlay dismissal removes the owning popup-host entry.
// - Window dismissal pops only the root popup route.
// - A nested Navigator route remains intact after a Window popup closes.
// - The supplied LayerLink remains the preferred live anchor.
// - Missing LayerLink falls back to the caller context rectangle.
// - Logical-end alignment mirrors under RTL.
// - Dropdown positioning retains its eight-dp vertical separation.
// - Low anchors flip above rather than leaving the safe window.
// - Resizing or scrolling resamples the current anchor rectangle.
// - An anchor that disappears causes the host to dismiss safely.
// - The popup route owns one dim layer and one popup surface.
// - No nested modal barrier is inserted around the list content.
// - Outside input reaches the owning host dismissal policy.
// - Physical Back follows the same route or host ownership.
// - Predictive Back remains implemented by the shared popup surface.
// - Focus restoration remains the responsibility of that shared host.
//
// Popup geometry and material:
// - Current source rows use MiuixDropdownImpl rather than generic menu rows.
// - Popup mode retains 20dp outer first and last row padding.
// - Middle row edges retain 12dp padding.
// - The source 216dp leading-content limit remains enforced.
// - The complete popup remains bounded by the source 288dp maximum.
// - An explicit positive finite maxHeight limits the scrolling content plane.
// - Null, non-finite, zero, or negative maxHeight leaves the safe host limit.
// - A height limit never creates invalid BoxConstraints.
// - MiuixDropdownColors controls all seven independent row color channels.
// - Null colors resolve from the current source popup palette.
// - Popup glass belongs to the outer ListPopup surface exactly once.
// - Child rows never create a second glass sampling layer.
// - Shadow and continuous corner clipping remain owned by the host surface.
// - Current geometry is distinct from HyperOS application extension styling.
// - These source values are not described as HyperOS 4 official parameters.
//
// Popup selection and dismissal:
// - Every accepted source row click publishes Confirm haptics.
// - Reselecting an already selected source row still publishes Confirm.
// - Generic compatibility rows keep state-boundary segmentTick behavior.
// - Disabled rows publish neither callbacks nor haptics.
// - collapseOnSelection true dismisses after an accepted selection.
// - collapseOnSelection false retains the same visible popup instance.
// - A single visible group defaults collapseOnSelection to true.
// - More than one visible group defaults collapseOnSelection to false.
// - Empty groups do not inflate the visible-group calculation.
// - A flat non-empty entries list counts as one visible group.
// - An explicit caller value always overrides the inferred group policy.
// - Retained popups update their local check state without replaying entry.
// - Selection never invokes the close-button callback because none exists.
// - Route completion never synthesizes another selection callback.
//
// Popup lifecycle callbacks:
// - onDismissRequest fires once when dismissal first becomes committed.
// - onDismissFinished fires once after the exit transition settles.
// - Outside click, Back, selection collapse, and programmatic close converge.
// - Multiple close requests cannot duplicate either lifecycle event.
// - The returned Future completes only after the host has removed the surface.
// - Disposed calling widgets are not dereferenced during route completion.
// - Overlay host disposal completes the same lifecycle defensively.
// - Window Navigator disposal cannot leave an unresolved popup Future.
//
// Dialog hosting:
// - OverlayDropdownDialog uses MiuixOverlayDialog.
// - WindowDropdownDialog uses MiuixWindowDialog.
// - Overlay renderInRootScaffold selects the root or nearest dialog host.
// - Window dialog ownership remains the root Navigator.
// - Dialog variants are not anchored to the triggering LayerLink.
// - Dialog placement follows compact and large-screen shared host rules.
// - Android predictive Back remains handled by the dialog host.
// - Window dimming remains one independently animated host channel.
// - Reduced motion snaps host scale, alpha, and dimming to their endpoints.
// - The dialog surface remains mounted until its exit completes.
// - surfaceBuilder decorates the one owned outer dialog surface.
// - surfaceBuilder never wraps each source row separately.
//
// Dialog structure:
// - The authored title is passed to the shared dialog title slot.
// - The content uses vertical inside margins of 24dp.
// - Source rows run in dialogMode with full-width measurement.
// - Dialog rows use a 56dp minimum height.
// - Dialog rows use 28dp independently rounded horizontal padding.
// - Dialog source colors default to MiuixDropdownDefaults.dialogColors.
// - The list does not paint a nested popup surface.
// - The list scrolls when its intrinsic content exceeds available height.
// - The close action is outside that scrollable list.
// - The close action receives 24dp logical start and end padding.
// - The close action receives 12dp top separation from the list.
// - The close action fills the available dialog width.
// - The close action retains the source 50dp minimum height.
// - dialogButtonString is rendered without inventing an icon.
// - Pressing the close action never changes the selected value.
// - Dialog content remains valid when every group is empty.
// - An empty dialog still exposes its title and explicit close action.
//
// Dialog selection and dismissal:
// - Source dialog row input publishes the same Confirm haptic as popup rows.
// - Single-group dialogs default to closing after selection.
// - Multi-group dialogs default to remaining open after selection.
// - Explicit collapseOnSelection overrides that inferred behavior.
// - Retained dialog selection updates the row check immediately.
// - The title and close action remain present after retained selection.
// - Selection collapse closes through the opening host, not a new context.
// - Manual close uses the opening host without walking a nested Navigator.
// - Overlay dialog close removes only the popup-host entry.
// - Window dialog close pops only the root dialog route.
// - onDismissRequest and onDismissFinished retain shared dialog semantics.
// - Exit completion never repeats the application selection callback.
//
// Motion contract:
// - Popup entry retains the shared fraction spring and independent alpha tween.
// - Popup exit retains its shorter reverse alpha channel.
// - Popup transform origin follows the resolved logical-end anchor.
// - Dialog entry retains the shared compact or large-screen source spring.
// - Dialog exit retains the shared reverse spring and dimming sequence.
// - Selection check changes retain current DropdownImpl state painting.
// - A retained popup or dialog does not replay its route entry animation.
// - A close action cannot start a second simultaneous exit.
// - Runtime disableAnimations changes settle the already visible host.
// - Pointer-driven predictive Back progress remains direct input motion.
// - Reduced motion removes autonomous settling but not direct pointer motion.
//
// Accessibility and input:
// - Every enabled row exposes one semantic activation action.
// - Disabled rows retain labels without advertising activation.
// - Selected state remains exposed through the measured check-bearing row.
// - The close action remains a separate semantic button.
// - Dialog title remains discoverable independently from list content.
// - Keyboard focus stays within the modal dialog while it is visible.
// - Window popup Back restores focus to the original trigger scope.
// - Overlay popup outside input does not activate page content underneath.
// - RTL changes physical placement without changing logical group order.
// - Large text may wrap labels without hiding the trailing check slot.
//
// Regression obligations:
// - Direct tests must name all four public source adapters.
// - Overlay Popup must prove multi-group persistence.
// - Window Popup must prove single-group default collapse.
// - Window Dialog must prove title, rows, and manual close action.
// - Overlay Dialog must prove multi-group persistence and manual close.
// - Tests must inspect sourceRows rather than only visible strings.
// - Dialog tests must inspect dialogMode and showSurface false.
// - Lifecycle tests must count request and finished callbacks exactly once.
// - Haptic tests must cover reselecting an already selected source row.
// - Existing generic ListPopup haptic tests must remain unchanged.
// - Existing dropdown anchor and resize tests must continue passing.
// - Existing reduced-motion popup and dialog tests must continue passing.
// - Existing grouped preference dynamic-owner tests remain separate evidence.
// - Static analysis must cover both adapter and part-library implementations.
// - The full library suite must pass before a Release is generated.
// - The localized example suite must pass in the same Release cycle.
// - Windows Release must reach input idle and remain responsive.
// - Android arm64 output must pass ABI, package, version, and signature checks.
// - Android runtime material and haptics still require an owned arm64 device.
//
// Invocation ownership:
// - Every static show call creates one immutable route invocation boundary.
// - Host selection is resolved from the opening BuildContext exactly once.
// - A later ambient Navigator change cannot migrate an already visible route.
// - A later popup-host change cannot migrate an already visible overlay entry.
// - renderInRootScaffold is therefore an opening decision.
// - LayerLink identity is also an opening decision for that popup route.
// - Live geometry may change while the opening LayerLink remains attached.
// - Replacing the caller widget does not replace the opening LayerLink object.
// - The application callback belongs to the same show invocation.
// - Route completion must not search for a newer callback owner implicitly.
// - Callers that need live owner replacement should close and reopen explicitly.
// - Preference widgets provide a separate revision-driven live-content contract.
// - The static adapters do not duplicate that preference State machinery.
// - This difference is documented rather than hidden behind stale assumptions.
//
// Callback ordering and safety:
// - An accepted row updates popup-local selection before external notification.
// - Haptic dispatch is fire-and-forget and cannot delay route state updates.
// - A failed platform haptic does not cancel the application selection callback.
// - Generic popup host dismissal remains idempotent after callback-driven rebuilds.
// - The Window route checks Navigator mounting before attempting a pop.
// - The Overlay route tolerates its opening host already being disposed.
// - Manual close is a no-op when the opening host is no longer mounted.
// - A no-op close cannot produce a second selection callback.
// - onDismissFinished remains owned by the route or overlay entry completion.
// - The returned Future remains the authoritative completion signal.
//
// Failure and boundary handling:
// - Overlay show without any MiuixPopupHost throws a descriptive FlutterError.
// - Window show without a root Navigator completes without inventing a host.
// - Popup show with no visible rows returns a completed Future.
// - Empty popup input never inserts a dim layer without selectable content.
// - Dialog show with no visible rows still provides an explicit close action.
// - Non-finite popup heights never reach BoxConstraints unchanged.
// - Negative popup heights never create a reversed constraint interval.
// - Excessive popup heights remain bounded by the route safe area.
// - Excessive intrinsic row width remains capped by ListPopup source geometry.
// - A disabled complete group never becomes selectable through a child callback.
// - An empty group does not create an orphan divider.
// - A selected disabled row retains appearance without acquiring activation.
// - A null summary does not reserve a second text line.
// - A null icon does not reserve the source icon slot.
// - A custom color palette cannot change route ownership or dismissal.
// - A custom surface builder cannot bypass the dialog modal barrier.
//
// Visual review boundaries:
// - Existing ListPopup goldens prove source row material and check geometry.
// - Existing Dialog goldens prove compact and large-screen outer surfaces.
// - Wrapper tests prove the two pieces are composed in the intended host.
// - A wrapper string-only test is insufficient without inspecting widget flags.
// - Windows runtime review should exercise both compact and maximized layouts.
// - Android runtime review should exercise physical Back and platform haptics.
// - Widget tests remain authoritative for deterministic animation timing.
// - Screenshots remain authoritative for final material and clipping review.
// - Static source comparison remains authoritative for default policy values.
// - None of those evidence classes substitutes for all the others.
//
// Release review checklist:
// - The four static show methods remain exported from the package root.
// - Generic type inference accepts flat entries and grouped entries.
// - Explicit type arguments remain valid on every static show call.
// - Existing constructor-only source clients continue compiling unchanged.
// - Generic OverlayListPopup default alignment remains bottomStart.
// - Generic WindowListPopup default alignment remains bottomStart.
// - Current DropdownPopup adapters continue requesting logical end explicitly.
// - Popup sourceRows remains true in all four hosted adapters.
// - Dialog dialogMode remains true in both dialog adapters.
// - Dialog showSurface remains false to prevent nested materials.
// - Popup showSurface remains true to preserve its one outer surface.
// - Dialog palettes resolve from dialogColors rather than popup colors.
// - Popup palettes resolve from ordinary dropdown colors.
// - Source row Confirm does not alter compatibility row segmentTick.
// - Multi-group inferred persistence remains covered on both host families.
// - Single-group inferred collapse remains covered on a Window route.
// - Manual close remains covered on both dialog host families.
// - Outside dismissal remains covered on an Overlay popup host.
// - Request and finished callback counts remain exactly one.
// - Full dropdown and dialog filtered suites remain green.
// - Full library and example suites supersede those filtered checks.
// - Release packaging starts only after every static gate succeeds.
// - Failed packaging cannot prune the preceding complete checkpoints.
// - Stable filenames update only after the complete cycle succeeds.
// - Final reporting records paths, hashes, version code, and signing boundary.
// - Package archives include this contract beside the public implementation.
// - Package verification imports the stable root library after extraction.
// - Android packaging contains only the requested arm64 native ABI.
// - Windows packaging contains one x64 executable and portable archive paths.
// - Hidden Windows startup remains a smoke check rather than visual proof.
// - Actual Windows screenshots supplement that smoke check when UI changes.
// - Debug Android signing is described only as test distribution signing.
// - No x86 emulator result is presented as arm64 runtime evidence.
// - No widget test is presented as platform haptic waveform evidence.
// - The audit remains open until owned Android runtime evidence is available.
