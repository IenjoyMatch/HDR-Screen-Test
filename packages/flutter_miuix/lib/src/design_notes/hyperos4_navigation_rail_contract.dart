library flutter_miuix_hyperos4_navigation_rail_contract;

// HyperOS 4 navigation-rail implementation contract.
//
// Evidence boundary:
// - Xiaomi's public presentation shows local floating application surfaces.
// - It does not publish a navigation-rail dp table for Flutter developers.
// - Rail dimensions in MiuixHyperOs4Tokens are project calibration values.
// - Those values must not be described as private or official Xiaomi tokens.
//
// Default-constructor contract:
// - MiuixNavigationRail is the forward-looking HyperOS 4 entry point.
// - Its surface is local rather than a full-height opaque window stripe.
// - Transparent margin remains visible around every side of the glass shape.
// - The glass clip alone owns blur, tint, reflection, and pointer light.
// - No rectangular fill may sit behind the continuous rounded surface.
// - The optional outline follows the same clipped surface silhouette.
// - System top, bottom, and logical-start insets remain transparent outside it.
// - The rail's body width remains independent from the transparent margin.
// - All ordinary destinations receive the same available rail width.
// - Text length never changes one destination's allocation.
// - The selected destination uses a local continuous-corner surface.
// - selectedIcon is honored only by the new default visual path.
// - The ordinary icon-and-label target retains a 54dp minimum hit height.
// - Icon-only, text-only, and selected-label modes remain supported.
// - A destination change emits the semantic segmentTick haptic role once.
// - Tapping the already selected destination emits no selection haptic.
// - Disabled destinations remain inert and never emit selection haptics.
//
// Accessibility and motion contract:
// - Each destination remains a selected, enabled, labeled button semantic node.
// - MediaQuery.disableAnimations controls every rail-owned transition.
// - Selection color and shape snap directly when motion is reduced.
// - Display-mode measurement snaps directly when motion is reduced.
// - Expansion width snaps directly when motion is reduced.
// - Press indication snaps directly when motion is reduced.
// - Disabling motion during an expansion cancels the active simulation.
// - The logical state remains authoritative after an interrupted animation.
// - Haptics are independent from visual animation preferences.
//
// Explicit source compatibility:
// - MiuixNavigationRail.source retains arbitrary source child composition.
// - MiuixNavigationRail.sourceItems retains the old data-driven constructor.
// - Both source constructors keep the opaque full-height surface.
// - Both source constructors keep the 0.75dp sibling divider by default.
// - Both source constructors keep the 80dp and 240dp endpoint widths.
// - Both source constructors keep the current MIUIX icon and label metrics.
// - Both source constructors keep the source critical expansion spring.
// - Source items continue to tint the same icon in every selection state.
// - Source badges continue to use the source badge-bounds calculation.
// - Source press indication remains rectangular when motion is allowed.
// - Reduced motion changes timing only; source stable endpoint paint is intact.
//
// Regression evidence required for each future edit:
// - Prove ordinary surface bounds leave transparent outer clearance.
// - Prove ordinary glass resolves blur and opacity from theme tokens.
// - Prove ordinary selection uses the selected glyph and local squircle.
// - Prove sourceItems has no glass and retains its sibling divider.
// - Prove every display mode remains buildable after selection changes.
// - Prove reduced-motion expansion reaches its endpoint in one pump.
// - Prove a changed destination emits one segmentTick haptic.
// - Prove a repeated selected tap emits no additional haptic.
// - Re-run the complete widget suite after focused rail tests pass.
// - Re-run Android and Windows Release packaging after documentation changes.
//
// Layout calibration details:
// - The 12dp outer clearance is measured outside the painted glass bounds.
// - The clearance contributes to occupied layout width beside a content pane.
// - It never contributes to the rail destination's equal-width calculation.
// - The logical-start safe inset is added before the outer clearance.
// - The physical top safe inset is added before the top clearance.
// - The physical bottom safe inset is added before the bottom clearance.
// - Safe-area pixels are therefore not tinted by the rail material.
// - A zero-inset Windows window retains the same 12dp visual clearance.
// - The glass receives EdgeInsets.zero to avoid generic surface padding.
// - Its child owns all navigation-specific internal measurement.
// - A future generic MiuixGlass padding change must not resize this rail.
// - Collapsed content width is 80dp before density-aware rounding.
// - Expanded content width is 240dp before density-aware rounding.
// - Default total widths are 104dp and 264dp at one logical pixel density.
// - Explicit minWidth and expandedWidth still override those content widths.
// - Invalid widths continue to fall back to the source-compatible defaults.
// - The outer glass corner remains independent from item corner calibration.
// - The 32dp outer radius describes a tall local capsule at rest.
// - The 22dp item radius describes the selected destination only.
// - The 54dp item minimum is a hit and paint floor, not a fixed row height.
// - Icon-and-label content may grow when text scale requires more height.
// - The scroll view owns overflow when destinations exceed window height.
// - Header and expansion controls remain inside the same clipped surface.
// - Badge paint may extend beyond its icon but stays inside the rail clip.
//
// Glass and color details:
// - navigationRailBlur is the unscaled standard-intensity sigma input.
// - navigationRailTintOpacity is the unscaled standard-intensity tint input.
// - MiuixGlass applies the global five-level material configuration afterward.
// - Disabling global glass keeps the exact local shape as a solid fallback.
// - An explicit glass false request uses the same local squircle geometry.
// - An explicit color changes the local tint, never the surrounding window.
// - The optional divider becomes a border on the clipped local silhouette.
// - It does not recreate the source's full-height sibling divider.
// - The default selected fill derives from primaryContainer at restrained alpha.
// - The default selected icon and label derive from the primary role.
// - Unselected content derives from onSurfaceVariant for clear hierarchy.
// - Source constructors continue to use onSurfaceContainer and source alphas.
// - Light and dark visual baselines must both expose the outer silhouette.
// - Complex-background runtime checks must prove actual backdrop sampling.
// - A white-page golden alone cannot prove blur because it has no texture.
//
// Input and feedback details:
// - GestureDetector retains an opaque hit region across each equal-width item.
// - The local selected paint never becomes the sole tap target.
// - A callback is still delivered for a repeated selected-destination tap.
// - Only the semantic selection haptic is suppressed for that repeated tap.
// - Haptic dispatch occurs before the public callback updates application state.
// - A missing callback leaves the destination structurally disabled by contract.
// - Pointer cancellation clears the transient pressed state.
// - A disabled item clears any carried source indication animation.
// - Selected semantics follow the clamped selected index used for paint.
// - An empty item list exposes no selected destination and remains buildable.
// - Out-of-range indices clamp only when at least one destination exists.
// - RTL keeps the rail at logical start and preserves end-side content order.
// - selectedIcon selection never changes source-item artwork.
// - Text labels remain the semantic name even in icon-only display mode.
//
// Motion implementation details:
// - The ordinary selection transition uses the centralized 380ms token.
// - That duration is project-authored and remains theme-overridable.
// - The selected fill, color, and continuous shape share one container tween.
// - Size changes retain the existing spring when animations are enabled.
// - Reduced motion bypasses the animated-size render object entirely.
// - Bypassing it prevents one stale clipped frame after a display-mode change.
// - Expansion reads the accessibility preference in didChangeDependencies.
// - Enabling reduced motion cancels a running unbounded controller safely.
// - The controller then publishes the current logical state endpoint exactly.
// - A later state notification also writes its target without simulation.
// - Source pointer indication writes either 0.1 or zero without a spring.
// - Normal source press still joins its enter job before release as authored.
// - The global glass contact-light fade already observes reduced motion.
// - No timer remains alive solely to complete a suppressed rail transition.
//
// Compatibility review details:
// - sourceItems is additive and does not remove an existing constructor.
// - Existing ordinary call sites remain source-compatible at compile time.
// - Their default visual changes intentionally under the migration policy.
// - Callers can opt out of blur with glass false while retaining new geometry.
// - Callers needing the old geometry use sourceItems instead of glass false.
// - The arbitrary-child source constructor remains unchanged at call sites.
// - MiuixNavigationRailItem remains the child for that arbitrary source form.
// - Public MiuixNavigationRailDefaults continue to document upstream metrics.
// - HyperOS calibration belongs only in MiuixHyperOs4Tokens.
// - Future token additions require constructor, field, docs, and tests together.
// - Golden updates are valid only after reviewing the generated test images.
// - Release evidence must distinguish build proof from device runtime proof.
//
// Visual-baseline review details:
// - The compact light baseline must show a narrow local surface, not a stripe.
// - The compact dark baseline must preserve the same silhouette and spacing.
// - Selected content must remain legible over both material brightnesses.
// - Unselected content must retain sufficient contrast without competing.
// - The selected surface must be visibly wider than the glyph itself.
// - The selected surface must not touch the outer glass silhouette.
// - Its vertical size must not collapse the destination's interaction target.
// - The expanded baseline must show one continuous icon-to-label relationship.
// - The expanded selected surface must remain inside the outer glass bounds.
// - Expanded text must ellipsize rather than changing the rail endpoint width.
// - Pressed baselines may change contact light without changing geometry.
// - Disabled baselines must preserve layout and suppress pointer feedback.
// - Midpoint baselines must show one rail, never two cross-faded surfaces.
// - Golden replacement requires visual inspection of generated test images.
// - A passing golden proves only the fixed test scene and fixed pixel density.
// - Runtime screenshots remain necessary for textured-backdrop blur evidence.
//
// Platform review details:
// - Android gesture navigation may contribute a bottom view-padding inset.
// - Android three-button navigation may contribute a larger bottom inset.
// - Neither inset may inherit the rail tint outside the local surface.
// - Display cutouts contribute only on the logical side where they exist.
// - Windows caption handling belongs to the surrounding application shell.
// - The rail still respects ordinary MediaQuery window padding on Windows.
// - Mouse clicks use the same destination callback and selected-state guard.
// - Keyboard and accessibility activation retain the button semantic action.
// - Hover styling can be added later without changing the selection contract.
// - A hover layer must remain clipped to the destination shape when added.
// - Platform fallback haptics must never make Windows selection fail.
// - Missing native Android haptic support falls back through MiuixHaptics.
//
// Ownership details:
// - NavigationRailState remains caller-owned and must be disposed by callers.
// - The rail subscribes when mounted and unsubscribes when state identity changes.
// - Removing a state returns the visual controller to the collapsed endpoint.
// - Replacing a state immediately follows the new logical expansion target.
// - The internal controller remains owned and disposed by the rail layout state.
// - Every retarget increments a generation to reject stale completion writes.
// - Reduced-motion writes also increment that generation before snapping.
// - The public selection index remains controlled by the application.
// - The rail never mutates selectedIndex internally after a tap.
// - The public callback therefore remains the sole selection-state authority.
// - Display mode is likewise controlled and recomputed from the current widget.
// - Header content remains caller-owned and is never reparented outside glass.
// - Source arbitrary children retain their caller-provided keys and state.
//
// Maintenance prohibitions:
// - Do not put an opaque ColoredBox behind the ordinary rail to simplify blur.
// - Do not use generic glass padding as navigation-specific spacing.
// - Do not make selected labels determine the destination width.
// - Do not animate when MediaQuery.disableAnimations is true.
// - Do not emit haptics for programmatic selection-state updates.
// - Do not emit haptics for a tap that stays on the selected destination.
// - Do not silently convert source constructors to the new visual path.
// - Do not duplicate HyperOS calibration values in the example application.
// - Do not call project calibration values official Xiaomi measurements.
// - Do not treat API coverage or a golden alone as runtime parity proof.

/// Machine-visible marker for the audited navigation-rail contract revision.
const String hyperOs4NavigationRailContractRevision = '2026-08-21';
