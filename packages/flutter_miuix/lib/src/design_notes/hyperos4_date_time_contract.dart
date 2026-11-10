// HyperOS 4 date and time extension contract.
//
// Scope
// -----
// The upstream Compose MIUIX catalog does not publish these widgets as a
// standalone component family. They are flutter_miuix extensions and must not
// be described as private Xiaomi APIs or as official unpublished dp values.
// Their geometry is project-calibrated from the public application language.
//
// Material hierarchy
// ------------------
// A month, week, month-grid, year-grid, or wheel group owns one local panel.
// The panel clips blur, tint, reflection, and content to one continuous shape.
// No transparent corner may retain a rectangular fill or rectangular shadow.
// Inline panels sample page content only within their own rounded boundary.
// A caller may set glass=false to retain a deterministic opaque compatibility
// surface; disabling glass must not change selection semantics or dimensions.
// Calendar blur, opacity, and radius come from MiuixHyperOs4Tokens.
// Wheel-group blur, opacity, and radius use their separate picker token role.
// The global five-level glass intensity continues to scale both material roles.
// A dialog may contain an inline glass panel inside its larger dialog material.
// The inner panel remains content-sized and must never force full-screen height.
//
// Calendar layout
// ---------------
// A month always renders six seven-day rows so the dialog does not jump height.
// Route safe-area padding must not leak into the nested non-scrollable grid.
// Header actions retain a full accessibility target even in a compact row.
// Adjacent-month cells keep their authored place but may hide their text.
// A disabled day retains its semantic date and enabled=false state.
// Weekday order begins at the caller-selected firstWeekday in every locale.
// Month names continue to come from Flutter's MaterialLocalizations delegate.
//
// Range geometry
// --------------
// Single and multiple selection use a circular 44dp project-calibrated target.
// A completed range is a continuous horizontal band, not disconnected circles.
// The logical start endpoint rounds its leading side and joins its trailing side.
// The logical end endpoint joins its leading side and rounds its trailing side.
// Interior cells have no horizontal corner gap and use rangeBackground.
// BorderRadiusDirectional keeps the endpoint geometry correct in RTL layouts.
// A one-day in-progress range remains a circle rather than a one-cell strip.
// rangeForeground is independent from selectedForeground for contrast safety.
// Existing custom palettes without rangeForeground fall back to foreground.
// Endpoint dates continue to use the stronger selected background and text.
// Every contained date remains selected in accessibility semantics.
//
// Gesture ownership
// -----------------
// A horizontal month fling belongs to the calendar before an ancestor pager.
// A vertical sequence remains available to an ancestor page scroll view.
// A stationary day tap is not converted into a month change.
// The month threshold ignores low-velocity accidental motion.
// A successful month change emits the picker-step haptic role exactly once.
// A successful day selection emits the semantic confirmation haptic role.
// Disabled dates and no-op controller assignments stay silent.
//
// Date and time pickers
// ---------------------
// Date wheel mode owns one glass picker panel around all three number wheels.
// Time wheels own one panel regardless of seconds or period-column visibility.
// Duration wheels own one panel regardless of which unit columns are enabled.
// Wheel widths remain stable so localized labels do not shift adjacent columns.
// MiuixNumberPicker retains drag, wrap, stepping, and item haptic behavior.
// Static show methods forward glass instead of silently restoring old styling.
// Dialog actions use the package buttons and remain outside the wheel panel.
// Confirmation returns the controller value only after the explicit action.
// Cancellation disposes the private controller without publishing a new value.
//
// Combined date-time picker
// -------------------------
// Date and time are two stages of one value rather than unrelated fields.
// The stage selector is one shared tab surface with a moving selected region.
// Two independently sized push buttons are not an acceptable stage selector.
// Switching stages must preserve year, month, day, hour, minute, and second.
// The date controller updates only the date portion of the combined value.
// The time controller updates only the time portion of the combined value.
// A stage change emits one toggle haptic role and no value callback by itself.
// Stage content uses coordinated opacity and subtle scale, not an abrupt swap.
// The duration comes from the pickerStageMotion HyperOS token.
//
// Reduced motion
// --------------
// MediaQuery.disableAnimations is authoritative for accessibility reduction.
// Under reduced motion, stage and calendar state transitions use zero duration.
// The final geometry, color, selection, and semantics remain identical.
// Haptics remain semantic and are not synthesized from animation completion.
// No animation controller may continue ticking after reduced-motion settlement.
//
// Desktop and adaptive behavior
// -----------------------------
// Windows uses the same visual hierarchy with hover and keyboard accessibility.
// Inline panels must tolerate narrow dialogs and resizable desktop windows.
// Wheel groups use their intrinsic width and do not stretch to the entire page.
// Year grids may scroll internally or delegate scrolling when shrinkWrap=true.
// A shrink-wrapped grid must not steal vertical drag from an enclosing list.
// Every visible choice retains a usable pointer and semantic target.
//
// Verification obligations
// ------------------------
// Tests must prove six calendar rows and stable compact dialog containment.
// Tests must distinguish range endpoint fill from range interior fill.
// Tests must inspect continuous interior and directional endpoint radii.
// Tests must prove that calendar swipes do not advance an ancestor PageView.
// Tests must prove glass is present by default and absent when explicitly off.
// Tests must prove date-time stage switching preserves the complete value.
// Tests must cover controller replacement so detached controllers stay inert.
// Tests must cover localized 12/24-hour and duration unit presentations.
// Static analysis and the full package suite remain mandatory after changes.
// Visual baselines are updated only after inspecting intentional differences.
// Android runtime evidence requires an owned arm64 device or emulator.
// Windows runtime evidence requires launching the produced archive executable.
// Passing API coverage alone is not proof of visual or behavioral completion.
//
// Localization and bidirectional layout
// -------------------------------------
// Calendar labels come from Flutter localizations rather than fixed strings.
// The first-day-of-week offset follows the active material localization.
// Range endpoints use directional radii so RTL reverses their visual caps.
// Previous and next controls retain chronological meaning in every locale.
// Twelve-hour markers remain associated with the localized hour wheel.
// Numeric columns reserve enough width for localized digits and text scale.
// Public callbacks always return normalized DateTime values, not display text.
//
// Composition boundaries
// ----------------------
// The library owns surfaces and interaction behavior; examples only compose it.
// Dialog routes may add a surrounding glass shell without changing picker APIs.
// Inline consumers can disable the local glass layer to avoid nested blur cost.
// Disabling glass never disables selection, haptics, semantics, or validation.
// Theme tokens provide defaults while explicit widget parameters take priority.
// Compatibility overrides are opt-in and must not become the default path.
// A host application remains free to constrain width without forking the picker.
//
// Performance and rendering
// -------------------------
// Blur is clipped to the rounded local panel instead of the complete viewport.
// Calendar grids build a fixed six-week window for predictable layout cost.
// Range fills reuse day cells and do not introduce a second overlay scroll view.
// Wheel columns keep bounded extents to avoid unbounded intrinsic measurement.
// Animations change opacity, scale, color, and shape without relayout loops.
// Reduced-motion paths settle in one frame and expose the same final semantics.
// Gesture ownership is resolved at the calendar boundary before route paging.
// These constraints apply equally to Android release and Windows x64 builds.
