// HyperOS 4 context-menu project contract.
//
// This file documents the public-library behavior implemented by
// lib/src/extensions/interaction/miuix_context_menu.dart.
// It is intentionally a design contract rather than executable Dart code.
// Xiaomi's public HyperOS 4 material does not publish context-menu dp values.
// Every numeric value described here is therefore a project calibration.
// No line in this contract claims access to private Xiaomi design tokens.
//
// ---------------------------------------------------------------------------
// 1. Scope and entry points
// ---------------------------------------------------------------------------
//
// MiuixContextMenu is the directly composable menu panel.
// MiuixContextMenu.show opens the default HyperOS 4 route.
// MiuixContextMenuRegion installs long-press and secondary-click activation.
// MiuixContextMenuController prevents duplicate programmatic routes.
// MiuixContextMenu.source is the explicit legacy direct panel.
// MiuixContextMenu.showSource is the explicit legacy route.
// MiuixContextMenuController.showSource owns the legacy controller lifecycle.
// MiuixContextMenuRegion.sourceStyle selects the legacy activation path.
// The ordinary APIs must never silently fall back to source styling.
// The source APIs must never silently acquire new glass defaults.
// Items retain typed values from construction through route completion.
// Selection returns exactly the authored value of the tapped enabled item.
// A dismissed route returns null and publishes no selection callback.
// Empty regions do not open a route because they have no valid action.
// A direct empty panel remains a valid, minimally sized composition.
// Public palette overrides apply equally to direct and route-hosted panels.
// The implementation lives in lib and does not depend on example code.
//
// ---------------------------------------------------------------------------
// 2. HyperOS 4 material hierarchy
// ---------------------------------------------------------------------------
//
// The ordinary panel owns exactly one outer sampled-glass surface.
// That surface samples only pixels behind its clipped popup silhouette.
// The popup uses hyperOs4.popupBlur as its default backdrop sigma.
// The popup uses hyperOs4.popupTintOpacity as its standard tint input.
// The popup uses hyperOs4.popupCornerRadius as its continuous corner input.
// Global enableGlass still determines whether MiuixGlass performs blur.
// Global glassIntensity modifies blur and tint through the shared glass path.
// The component must not implement a second private intensity table.
// showGlassSpecular controls the existing clipped edge reflection.
// A caller may disable glass without selecting legacy geometry.
// A caller may override blur without changing tint or corner geometry.
// A caller may override tint without changing blur or corner geometry.
// A caller may override the corner without changing width or row height.
// Transparent ordinary rows preserve one continuous popup material.
// Ordinary rows must not paint separate rectangular cards over the glass.
// Press indication remains clipped to the row inside the outer panel.
// The outer panel clips the sampled material to its complete silhouette.
// The legacy panel remains opaque through MiuixContextMenu.source.
// The legacy panel retains its former Surface-default action-row fills.
// The legacy panel does not paint a glass specular highlight.
// A source request is an explicit migration choice, not an automatic fallback.
//
// ---------------------------------------------------------------------------
// 3. Content-fitting width
// ---------------------------------------------------------------------------
//
// The ordinary menu does not use the former fixed 220dp width.
// Its intrinsic width is derived from the widest authored action row.
// A row width includes its horizontal insets on both physical sides.
// A row with an icon also includes the icon's authored intrinsic width.
// A row with an icon also includes contextMenuIconSpacing.
// A row without an icon introduces no empty icon reservation.
// contextMenuMinWidth provides the ordinary lower width bound.
// contextMenuMaxWidth provides the ordinary upper width bound.
// The default 200dp lower bound matches the package popup family.
// The default 288dp upper bound matches the package popup family.
// Those two numbers are project consistency points, not official values.
// A short one-word action therefore resolves to the configured minimum.
// A medium action may resolve to any intrinsic width inside the interval.
// A long action resolves to the configured maximum and truncates safely.
// maxWidth is defensively raised to minWidth when overrides cross.
// Non-finite or non-positive width overrides use their token fallback.
// Parent constraints may still reduce the panel below its configured minimum.
// That reduction is necessary on windows narrower than both edge margins.
// The panel must not overflow merely to preserve a project-calibrated minimum.
// Direct callers can provide equal minWidth and maxWidth for a fixed panel.
// The source constructor does exactly that with two 220dp constraints.
// Intrinsic measurement must not cause rows to choose different final widths.
// The final Column stretches every row to the resolved panel width.
// Inset dividers also measure against the resolved complete panel width.
//
// ---------------------------------------------------------------------------
// 4. Height and internal scrolling
// ---------------------------------------------------------------------------
//
// One ordinary action uses hyperOs4.contextMenuItemHeight by default.
// The default action height is a 52dp project calibration.
// Each action may display at most two lines inside that stable height.
// Text beyond the available two-line region resolves through ellipsis.
// Stable row height prevents the menu from jumping between press states.
// The complete natural height is the sum of rows, separators, and padding.
// A short action list keeps that natural content-driven height.
// A route computes its height limit from the usable SafeArea constraints.
// The route subtracts the configured edge margin from both vertical sides.
// The panel never requests the complete screen height for a short list.
// A tall list is constrained to the remaining usable height.
// Only the internal SingleChildScrollView scrolls after that constraint.
// The route barrier and page behind it do not scroll with menu content.
// The internal scroll view is non-primary and owns no page PrimaryScrollController.
// A direct panel remains naturally sized when maxHeight is not supplied.
// Direct callers can supply maxHeight to opt into the same local scroll model.
// Invalid finite-height overrides fall back without producing NaN constraints.
// Separator thickness contributes to the natural content extent.
// Vertical padding contributes once above and once below the action group.
// Scrolling preserves the clipped outer glass and stationary corner geometry.
// Scrolling does not create a second glass layer around the moving content.
// The shadow belongs to the stationary panel rather than the scroll child.
// The source route also accepts its host's final safe height constraint.
// Source overflow scrolls only because leaving the usable window is invalid.
// Source row height and width nevertheless remain the former fixed values.
//
// ---------------------------------------------------------------------------
// 5. Window and anchor positioning
// ---------------------------------------------------------------------------
//
// The authored position is expressed in global route coordinates.
// SafeArea moves route content into a local usable coordinate system.
// The delegate subtracts safe left padding from the global anchor X.
// The delegate subtracts safe top padding from the global anchor Y.
// Placement occurs only after the child has reported its final layout size.
// Width is never estimated from a hard-coded default during positioning.
// Height is never estimated from item count during positioning.
// The final physical left edge is at least contextMenuScreenMargin.
// The final physical top edge is at least contextMenuScreenMargin.
// The final physical right edge is at most width minus that margin.
// The final physical bottom edge is at most height minus that margin.
// A central anchor places the menu at the authored local position.
// A right-edge anchor shifts the complete final child toward the left.
// A bottom-edge anchor shifts the complete final child upward.
// A bottom-right anchor applies both corrections without changing size.
// A very small window clamps both axes to the only feasible margin origin.
// The delegate provides loose constraints within the two edge margins.
// Loose constraints allow intrinsic width instead of forcing full-window width.
// Safe padding and visual edge margin remain independent quantities.
// The legacy route uses the same final-child positioning correction.
// The legacy route retains the former 12dp visual margin.
// The ordinary route reads contextMenuScreenMargin from theme tokens.
// A caller may override the ordinary route margin per invocation.
// Negative or non-finite margin overrides resolve to the token value.
// Position correction never scales or distorts the panel content.
// Position correction never inserts invisible full-screen surface fill.
//
// ---------------------------------------------------------------------------
// 6. Motion and reduced-motion policy
// ---------------------------------------------------------------------------
//
// MiuixContextMenu.show reads hyperOs4.contextMenuMotion.
// The duration governs autonomous route entrance and exit only.
// Direct pointer movement inside a menu is never delayed by that duration.
// The ordinary route fades from transparent to fully visible.
// The ordinary route scales from 0.94 to 1.0.
// The ordinary route uses an ease-out cubic entrance.
// The ordinary route uses an ease-in cubic exit.
// The ordinary transform begins from the logical start edge.
// LTR therefore uses the physical top-left transform origin.
// RTL therefore uses the physical top-right transform origin.
// The source route retains its former 0.88 initial scale.
// The source route retains its former ease-out-back entrance.
// Source and ordinary routes still share the configurable duration channel.
// MediaQuery.disableAnimations replaces the duration with Duration.zero.
// A newly opened reduced-motion route appears at opacity one immediately.
// A newly opened reduced-motion route appears at scale one immediately.
// Reduced motion does not remove pointer, keyboard, or semantics behavior.
// Reduced motion does not suppress opening or confirmation haptics.
// Reduced motion does not change popup geometry or positioning.
// Reduced motion does not replace glass with an opaque fallback.
// Toggling the system policy affects subsequently created menu routes.
// No periodic animation remains active after the menu reaches its endpoint.
// No route timer owns selection or controller state.
// Dismissal completion remains driven by Navigator route completion.
//
// ---------------------------------------------------------------------------
// 7. Action rows and visual roles
// ---------------------------------------------------------------------------
//
// Items preserve their authored list order.
// separatorBefore inserts one separator immediately before that item.
// No separator is fabricated merely because an item is destructive.
// Ordinary separators are inset by the resolved horizontal row padding.
// Source separators span the former complete panel width.
// The separator uses the semantic dividerLine color role.
// Enabled ordinary text uses the semantic onSurface role.
// Disabled text uses the semantic disabledOnSurface role.
// Destructive enabled text uses the semantic error role.
// Disabled state takes precedence over the destructive color role.
// An icon inherits the same local content color as its action label.
// The label uses the surrounding bodyLarge typography role.
// Typography remains application-theme controlled rather than hard coded.
// Horizontal content padding is symmetric within each action.
// Icon spacing is inserted only after a non-null icon.
// Row content uses logical reading order supplied by Directionality.
// RTL reverses Row placement without manually mirroring semantic values.
// The complete row remains the interactive target, not only its text glyphs.
// Every row occupies the same resolved panel width.
// Every row occupies the same resolved item height.
// Press feedback uses the package sink indication.
// Disabled actions install no onTap callback.
// Disabled actions remain in layout and retain their visible label.
// Caller-supplied colors override only the corresponding semantic channels.
// Palette overrides do not silently change glass strength or geometry.
// Geometry overrides do not silently change action colors.
//
// ---------------------------------------------------------------------------
// 8. Interaction and haptic behavior
// ---------------------------------------------------------------------------
//
// Opening an eligible menu emits MiuixHapticType.contextClick once.
// The opening haptic occurs before the asynchronous route is awaited.
// Selecting an enabled action emits MiuixHapticType.confirm once.
// Confirmation occurs before Navigator completes with the typed value.
// Tapping a disabled action emits no confirmation haptic.
// Barrier dismissal emits no confirmation haptic.
// Controller duplicate-open rejection emits no second route.
// Controller duplicate-open rejection returns null to the rejected caller.
// The controller sets isOpen before awaiting the route.
// The controller notifies listeners after setting isOpen true.
// The controller clears isOpen in a finally block.
// The controller therefore clears state after selection, dismissal, or error.
// The controller notifies listeners after clearing isOpen.
// Controller.close delegates to the nearest Navigator maybePop operation.
// A region long press passes the pointer's global position to the route.
// A region secondary click passes the pointer's global position to the route.
// A disabled region installs neither activation callback.
// An empty region returns before asking either route owner to open.
// A region forwards a non-null selected value to onSelected.
// A dismissed region route does not call onSelected.
// sourceStyle chooses source APIs before consulting controller presence.
// A sourceStyle region with a controller calls controller.showSource.
// An ordinary region with a controller calls controller.show.
// Region gesture behavior remains deferToChild.
// Existing child gestures therefore retain first opportunity where applicable.
//
// ---------------------------------------------------------------------------
// 9. Accessibility and keyboard boundaries
// ---------------------------------------------------------------------------
//
// The dialog route publishes the platform modal-barrier dismissal label.
// barrierDismissible controls whether the barrier accepts dismissal.
// Each enabled MiuixSurface row exposes its actionable semantics.
// Each disabled row exposes enabled false and no actionable callback.
// Visible text remains part of the row's semantic subtree.
// The typed Dart value is not exposed as accidental spoken text.
// Decorative glass reflection contributes no semantic node.
// Decorative outer shadow contributes no semantic node.
// The scroll view preserves access to actions beyond the visible height.
// The panel does not merge every action into one inaccessible button.
// The panel does not install a full-screen semantic click target.
// The transparent route barrier remains separate from menu action semantics.
// Focus traversal follows the authored action order in the Column.
// Disabled rows remain discoverable according to Flutter platform policy.
// Destructive color alone is never the only representation of the label.
// Text scaling may increase glyph layout within the fixed project row height.
// Two-line and ellipsis limits prevent scaled text from escaping the panel.
// Applications needing larger custom rows can override itemHeight.
// Applications needing richer semantics may provide semantic widgets as icons.
// Those icon semantics remain descendants of the corresponding row.
// Directionality changes visual order and transform origin consistently.
// The safe-area calculation does not alter the semantic bounds after layout.
// The final menu semantics stay within the same corrected visual rectangle.
// Reduced motion leaves the final semantic tree unchanged.
// Source mode changes presentation but retains the same action semantics.
//
// ---------------------------------------------------------------------------
// 10. Defensive geometry resolution
// ---------------------------------------------------------------------------
//
// Positive-only inputs reject zero where zero would erase required extent.
// minWidth rejects zero and falls back to contextMenuMinWidth.
// maxWidth rejects zero and falls back to contextMenuMaxWidth.
// itemHeight rejects zero and falls back to contextMenuItemHeight.
// maxHeight rejects zero when a direct caller supplies an invalid limit.
// Non-negative inputs deliberately accept zero where removal is meaningful.
// horizontalPadding accepts zero for edge-aligned custom content.
// iconSpacing accepts zero for directly adjacent custom icon content.
// verticalPadding accepts zero for a flush custom action group.
// cornerRadius accepts zero for an explicitly rectangular custom popup.
// screenMargin accepts zero for an explicitly edge-aligned route.
// shadowElevation accepts zero to disable the popup shadow.
// Negative values for non-negative inputs resolve to theme fallbacks.
// NaN values resolve to their corresponding theme fallback.
// Infinite values resolve to their corresponding theme fallback.
// maxWidth is compared only after both width inputs are sanitized.
// available route height is clamped to zero before constructing constraints.
// Delegate child width is clamped to zero on impossibly narrow windows.
// Delegate child height is clamped to zero on impossibly short windows.
// Placement upper bounds are never allowed below the lower margin bound.
// Clamp therefore receives a valid ordered interval on both axes.
// Position outputs are converted to finite doubles after clamping.
// Source constants are finite compile-time values and bypass theme drift.
// Theme overrides remain immutable within one MiuixHyperOs4Tokens instance.
// Route and direct widgets resolve against their own active MiuixTheme context.
//
// ---------------------------------------------------------------------------
// 11. Compatibility boundary
// ---------------------------------------------------------------------------
//
// Existing unnamed constructor call sites remain source compatible.
// Existing show call sites remain source compatible.
// Existing controller show call sites remain source compatible.
// Existing region call sites default sourceStyle to false.
// Existing palette types and item types remain unchanged.
// Existing item enabled, destructive, and separator flags remain unchanged.
// MiuixContextMenuDefaults.width remains available as a legacy alias.
// MiuixContextMenuDefaults.itemHeight remains available as a legacy alias.
// MiuixContextMenuDefaults.cornerRadius remains available as a legacy alias.
// MiuixContextMenuDefaults.screenMargin remains available as a legacy alias.
// Explicit source constants document what those aliases mean.
// The ordinary default visual intentionally changes to HyperOS 4.
// That default change is required by the workspace migration rule.
// Legacy geometry requires an explicit source-named entry point.
// Source direct width remains exactly 220dp under loose parent constraints.
// Source row height remains exactly 48dp.
// Source corner radius remains exactly 18dp.
// Source edge margin remains exactly 12dp.
// Source horizontal row padding remains exactly 14dp.
// Source icon spacing remains exactly 12dp.
// Source vertical panel padding remains exactly 6dp per edge.
// Source shadow elevation input remains exactly 14dp.
// Source separators remain non-inset.
// Source action rows retain the former default Surface color behavior.
// Source route entrance retains the former scale and easing.
//
// ---------------------------------------------------------------------------
// 12. Required regression evidence
// ---------------------------------------------------------------------------
//
// A short ordinary menu must resolve to a theme-overridden minimum width.
// A long ordinary label must resolve to a theme-overridden maximum width.
// The ordinary surface must expose glass true by default.
// The ordinary surface must expose popup blur and tint token values.
// The ordinary surface must expose the popup corner token.
// The ordinary surface must expose the context-menu shadow token.
// Ordinary divider bounds must be inset by horizontal row padding.
// Source surface width must remain 220dp under loose constraints.
// Source surface must expose glass false.
// Source surface must expose radius 18 and shadow elevation 14.
// Source divider bounds must match the complete panel width.
// A bottom-right route must remain inside all four 12dp default margins.
// A ten-row route on a 320x240 test window must resolve to 216dp height.
// That constrained route must report a positive internal maxScrollExtent.
// A controller-backed source region must open an opaque 220dp route.
// Selecting its action must clear controller.isOpen.
// The ordinary typed route must return its authored value.
// A custom 777ms motion token must remain incomplete before 777ms.
// Reduced motion must expose opacity one on the first pumped route frame.
// Four visual baselines cover ordinary/source and light/dark combinations.
// The ordinary baselines must show one continuous translucent panel.
// The source baselines must show the retained opaque legacy panel.
// Visual baselines must not show independently narrow ordinary action cards.
// Full flutter analyze must report no issues after public API changes.
// Full flutter test must include route, direct, geometry, and golden evidence.
// verify_scope must retain all required public names and comment policy.
// A complete Release cycle is required after the implementation phase.
// Android verification must confirm arm64, package, version, and signature.
// Windows verification must include the hidden responsiveness smoke check.
// Android and Windows library archives must contain this public implementation.
// Only a successful four-artifact cycle may prune older checkpoints.
