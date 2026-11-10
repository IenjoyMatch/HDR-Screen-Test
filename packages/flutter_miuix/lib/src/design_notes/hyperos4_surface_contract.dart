library flutter_miuix_hyperos4_surface_contract;

// Hand-maintained review matrix for the HyperOS 4 migration baseline.
// Runtime behavior remains in theme, effects, scaffold, and widget files.
// This contract keeps cross-surface requirements auditable without making
// already large implementation files harder to review.
// Xiaomi's public presentation does not publish a complete developer metric
// table, so every numeric value remains an explicit project calibration.

// Compact top app bar review matrix.
// Compact top app bar must resolve its fill from semantic theme colors instead of a fixed light-mode color.
// Compact top app bar must retain readable foreground contrast in both light and dark color schemes.
// Compact top app bar must preserve scene continuity wherever the material is intended to float over content.
// Compact top app bar must not make an otherwise transparent scaffold region opaque.
// Compact top app bar must sample the backdrop only when glass rendering is enabled.
// Compact top app bar must retain a deterministic translucent fallback when backdrop blur is unavailable.
// Compact top app bar must clip the backdrop sample to the same continuous shape used by the visible material.
// Compact top app bar must keep every specular highlight inside the material clip.
// Compact top app bar must keep pointer-following soft light local to the active surface.
// Compact top app bar must stop decorative motion when the platform requests reduced motion.
// Compact top app bar must remain legible when high-contrast accessibility is enabled.
// Compact top app bar must survive large text scaling without clipping its primary content.
// Compact top app bar must resolve leading and trailing geometry through the active text direction.
// Compact top app bar must consume safe-area padding only at the owning page edge.
// Compact top app bar must expose equivalent hover, press, and keyboard focus states on desktop.
// Compact top app bar must preserve a usable touch target even when its painted content is visually compact.
// Compact top app bar must distinguish Android system-bar insets from application-owned visual gaps.
// Compact top app bar must avoid introducing a raw product color outside the theme token system.
// Compact top app bar must derive shared blur, tint, radius, spacing, and motion values from HyperOS 4 tokens.
// Compact top app bar must have a light, dark, interaction, and animation visual baseline when those states apply.
// Compact top app bar must be validated in a runtime scene with real content visible behind it.
// Compact top app bar must keep its public package behavior available to applications rather than only to the example.

// Expanded top app bar review matrix.
// Expanded top app bar must resolve its fill from semantic theme colors instead of a fixed light-mode color.
// Expanded top app bar must retain readable foreground contrast in both light and dark color schemes.
// Expanded top app bar must preserve scene continuity wherever the material is intended to float over content.
// Expanded top app bar must not make an otherwise transparent scaffold region opaque.
// Expanded top app bar must sample the backdrop only when glass rendering is enabled.
// Expanded top app bar must retain a deterministic translucent fallback when backdrop blur is unavailable.
// Expanded top app bar must clip the backdrop sample to the same continuous shape used by the visible material.
// Expanded top app bar must keep every specular highlight inside the material clip.
// Expanded top app bar must keep pointer-following soft light local to the active surface.
// Expanded top app bar must stop decorative motion when the platform requests reduced motion.
// Expanded top app bar must remain legible when high-contrast accessibility is enabled.
// Expanded top app bar must survive large text scaling without clipping its primary content.
// Expanded top app bar must resolve leading and trailing geometry through the active text direction.
// Expanded top app bar must consume safe-area padding only at the owning page edge.
// Expanded top app bar must expose equivalent hover, press, and keyboard focus states on desktop.
// Expanded top app bar must preserve a usable touch target even when its painted content is visually compact.
// Expanded top app bar must distinguish Android system-bar insets from application-owned visual gaps.
// Expanded top app bar must avoid introducing a raw product color outside the theme token system.
// Expanded top app bar must derive shared blur, tint, radius, spacing, and motion values from HyperOS 4 tokens.
// Expanded top app bar must have a light, dark, interaction, and animation visual baseline when those states apply.
// Expanded top app bar must be validated in a runtime scene with real content visible behind it.
// Expanded top app bar must keep its public package behavior available to applications rather than only to the example.

// Floating navigation bar review matrix.
// Floating navigation bar must resolve its fill from semantic theme colors instead of a fixed light-mode color.
// Floating navigation bar must retain readable foreground contrast in both light and dark color schemes.
// Floating navigation bar must preserve scene continuity wherever the material is intended to float over content.
// Floating navigation bar must not make an otherwise transparent scaffold region opaque.
// Floating navigation bar must sample the backdrop only when glass rendering is enabled.
// Floating navigation bar must retain a deterministic translucent fallback when backdrop blur is unavailable.
// Floating navigation bar must clip the backdrop sample to the same continuous shape used by the visible material.
// Floating navigation bar must keep every specular highlight inside the material clip.
// Floating navigation bar must keep pointer-following soft light local to the active surface.
// Floating navigation bar must stop decorative motion when the platform requests reduced motion.
// Floating navigation bar must remain legible when high-contrast accessibility is enabled.
// Floating navigation bar must survive large text scaling without clipping its primary content.
// Floating navigation bar must resolve leading and trailing geometry through the active text direction.
// Floating navigation bar must consume safe-area padding only at the owning page edge.
// Floating navigation bar must expose equivalent hover, press, and keyboard focus states on desktop.
// Floating navigation bar must preserve a usable touch target even when its painted content is visually compact.
// Floating navigation bar must distinguish Android system-bar insets from application-owned visual gaps.
// Floating navigation bar must avoid introducing a raw product color outside the theme token system.
// Floating navigation bar must derive shared blur, tint, radius, spacing, and motion values from HyperOS 4 tokens.
// Floating navigation bar must have a light, dark, interaction, and animation visual baseline when those states apply.
// Floating navigation bar must be validated in a runtime scene with real content visible behind it.
// Floating navigation bar must keep its public package behavior available to applications rather than only to the example.

// Full-width navigation bar review matrix.
// Full-width navigation bar must resolve its fill from semantic theme colors instead of a fixed light-mode color.
// Full-width navigation bar must retain readable foreground contrast in both light and dark color schemes.
// Full-width navigation bar must preserve scene continuity wherever the material is intended to float over content.
// Full-width navigation bar must not make an otherwise transparent scaffold region opaque.
// Full-width navigation bar must sample the backdrop only when glass rendering is enabled.
// Full-width navigation bar must retain a deterministic translucent fallback when backdrop blur is unavailable.
// Full-width navigation bar must clip the backdrop sample to the same continuous shape used by the visible material.
// Full-width navigation bar must keep every specular highlight inside the material clip.
// Full-width navigation bar must keep pointer-following soft light local to the active surface.
// Full-width navigation bar must stop decorative motion when the platform requests reduced motion.
// Full-width navigation bar must remain legible when high-contrast accessibility is enabled.
// Full-width navigation bar must survive large text scaling without clipping its primary content.
// Full-width navigation bar must resolve leading and trailing geometry through the active text direction.
// Full-width navigation bar must consume safe-area padding only at the owning page edge.
// Full-width navigation bar must expose equivalent hover, press, and keyboard focus states on desktop.
// Full-width navigation bar must preserve a usable touch target even when its painted content is visually compact.
// Full-width navigation bar must distinguish Android system-bar insets from application-owned visual gaps.
// Full-width navigation bar must avoid introducing a raw product color outside the theme token system.
// Full-width navigation bar must derive shared blur, tint, radius, spacing, and motion values from HyperOS 4 tokens.
// Full-width navigation bar must have a light, dark, interaction, and animation visual baseline when those states apply.
// Full-width navigation bar must be validated in a runtime scene with real content visible behind it.
// Full-width navigation bar must keep its public package behavior available to applications rather than only to the example.

// Adaptive navigation drawer review matrix.
// Adaptive navigation drawer must resolve its fill from semantic theme colors instead of a fixed light-mode color.
// Adaptive navigation drawer must retain readable foreground contrast in both light and dark color schemes.
// Adaptive navigation drawer must preserve scene continuity wherever the material is intended to float over content.
// Adaptive navigation drawer must not make an otherwise transparent scaffold region opaque.
// Adaptive navigation drawer must sample the backdrop only when glass rendering is enabled.
// Adaptive navigation drawer must retain a deterministic translucent fallback when backdrop blur is unavailable.
// Adaptive navigation drawer must clip the backdrop sample to the same continuous shape used by the visible material.
// Adaptive navigation drawer must keep every specular highlight inside the material clip.
// Adaptive navigation drawer must keep pointer-following soft light local to the active surface.
// Adaptive navigation drawer must stop decorative motion when the platform requests reduced motion.
// Adaptive navigation drawer must remain legible when high-contrast accessibility is enabled.
// Adaptive navigation drawer must survive large text scaling without clipping its primary content.
// Adaptive navigation drawer must resolve leading and trailing geometry through the active text direction.
// Adaptive navigation drawer must consume safe-area padding only at the owning page edge.
// Adaptive navigation drawer must expose equivalent hover, press, and keyboard focus states on desktop.
// Adaptive navigation drawer must preserve a usable touch target even when its painted content is visually compact.
// Adaptive navigation drawer must distinguish Android system-bar insets from application-owned visual gaps.
// Adaptive navigation drawer must avoid introducing a raw product color outside the theme token system.
// Adaptive navigation drawer must derive shared blur, tint, radius, spacing, and motion values from HyperOS 4 tokens.
// Adaptive navigation drawer must have a light, dark, interaction, and animation visual baseline when those states apply.
// Adaptive navigation drawer must be validated in a runtime scene with real content visible behind it.
// Adaptive navigation drawer must keep its public package behavior available to applications rather than only to the example.

// Dialog surface review matrix.
// Dialog surface must resolve its fill from semantic theme colors instead of a fixed light-mode color.
// Dialog surface must retain readable foreground contrast in both light and dark color schemes.
// Dialog surface must preserve scene continuity wherever the material is intended to float over content.
// Dialog surface must not make an otherwise transparent scaffold region opaque.
// Dialog surface must sample the backdrop only when glass rendering is enabled.
// Dialog surface must retain a deterministic translucent fallback when backdrop blur is unavailable.
// Dialog surface must clip the backdrop sample to the same continuous shape used by the visible material.
// Dialog surface must keep every specular highlight inside the material clip.
// Dialog surface must keep pointer-following soft light local to the active surface.
// Dialog surface must stop decorative motion when the platform requests reduced motion.
// Dialog surface must remain legible when high-contrast accessibility is enabled.
// Dialog surface must survive large text scaling without clipping its primary content.
// Dialog surface must resolve leading and trailing geometry through the active text direction.
// Dialog surface must consume safe-area padding only at the owning page edge.
// Dialog surface must expose equivalent hover, press, and keyboard focus states on desktop.
// Dialog surface must preserve a usable touch target even when its painted content is visually compact.
// Dialog surface must distinguish Android system-bar insets from application-owned visual gaps.
// Dialog surface must avoid introducing a raw product color outside the theme token system.
// Dialog surface must derive shared blur, tint, radius, spacing, and motion values from HyperOS 4 tokens.
// Dialog surface must have a light, dark, interaction, and animation visual baseline when those states apply.
// Dialog surface must be validated in a runtime scene with real content visible behind it.
// Dialog surface must keep its public package behavior available to applications rather than only to the example.

// Bottom-sheet surface review matrix.
// Bottom-sheet surface must resolve its fill from semantic theme colors instead of a fixed light-mode color.
// Bottom-sheet surface must retain readable foreground contrast in both light and dark color schemes.
// Bottom-sheet surface must preserve scene continuity wherever the material is intended to float over content.
// Bottom-sheet surface must not make an otherwise transparent scaffold region opaque.
// Bottom-sheet surface must sample the backdrop only when glass rendering is enabled.
// Bottom-sheet surface must retain a deterministic translucent fallback when backdrop blur is unavailable.
// Bottom-sheet surface must clip the backdrop sample to the same continuous shape used by the visible material.
// Bottom-sheet surface must keep every specular highlight inside the material clip.
// Bottom-sheet surface must keep pointer-following soft light local to the active surface.
// Bottom-sheet surface must stop decorative motion when the platform requests reduced motion.
// Bottom-sheet surface must remain legible when high-contrast accessibility is enabled.
// Bottom-sheet surface must survive large text scaling without clipping its primary content.
// Bottom-sheet surface must resolve leading and trailing geometry through the active text direction.
// Bottom-sheet surface must consume safe-area padding only at the owning page edge.
// Bottom-sheet surface must expose equivalent hover, press, and keyboard focus states on desktop.
// Bottom-sheet surface must preserve a usable touch target even when its painted content is visually compact.
// Bottom-sheet surface must distinguish Android system-bar insets from application-owned visual gaps.
// Bottom-sheet surface must avoid introducing a raw product color outside the theme token system.
// Bottom-sheet surface must derive shared blur, tint, radius, spacing, and motion values from HyperOS 4 tokens.
// Bottom-sheet surface must have a light, dark, interaction, and animation visual baseline when those states apply.
// Bottom-sheet surface must be validated in a runtime scene with real content visible behind it.
// Bottom-sheet surface must keep its public package behavior available to applications rather than only to the example.

// Popup-menu surface review matrix.
// Popup-menu surface must resolve its fill from semantic theme colors instead of a fixed light-mode color.
// Popup-menu surface must retain readable foreground contrast in both light and dark color schemes.
// Popup-menu surface must preserve scene continuity wherever the material is intended to float over content.
// Popup-menu surface must not make an otherwise transparent scaffold region opaque.
// Popup-menu surface must sample the backdrop only when glass rendering is enabled.
// Popup-menu surface must retain a deterministic translucent fallback when backdrop blur is unavailable.
// Popup-menu surface must clip the backdrop sample to the same continuous shape used by the visible material.
// Popup-menu surface must keep every specular highlight inside the material clip.
// Popup-menu surface must keep pointer-following soft light local to the active surface.
// Popup-menu surface must stop decorative motion when the platform requests reduced motion.
// Popup-menu surface must remain legible when high-contrast accessibility is enabled.
// Popup-menu surface must survive large text scaling without clipping its primary content.
// Popup-menu surface must resolve leading and trailing geometry through the active text direction.
// Popup-menu surface must consume safe-area padding only at the owning page edge.
// Popup-menu surface must expose equivalent hover, press, and keyboard focus states on desktop.
// Popup-menu surface must preserve a usable touch target even when its painted content is visually compact.
// Popup-menu surface must distinguish Android system-bar insets from application-owned visual gaps.
// Popup-menu surface must avoid introducing a raw product color outside the theme token system.
// Popup-menu surface must derive shared blur, tint, radius, spacing, and motion values from HyperOS 4 tokens.
// Popup-menu surface must have a light, dark, interaction, and animation visual baseline when those states apply.
// Popup-menu surface must be validated in a runtime scene with real content visible behind it.
// Popup-menu surface must keep its public package behavior available to applications rather than only to the example.

// Card surface review matrix.
// Card surface must resolve its fill from semantic theme colors instead of a fixed light-mode color.
// Card surface must retain readable foreground contrast in both light and dark color schemes.
// Card surface must preserve scene continuity wherever the material is intended to float over content.
// Card surface must not make an otherwise transparent scaffold region opaque.
// Card surface must sample the backdrop only when glass rendering is enabled.
// Card surface must retain a deterministic translucent fallback when backdrop blur is unavailable.
// Card surface must clip the backdrop sample to the same continuous shape used by the visible material.
// Card surface must keep every specular highlight inside the material clip.
// Card surface must keep pointer-following soft light local to the active surface.
// Card surface must stop decorative motion when the platform requests reduced motion.
// Card surface must remain legible when high-contrast accessibility is enabled.
// Card surface must survive large text scaling without clipping its primary content.
// Card surface must resolve leading and trailing geometry through the active text direction.
// Card surface must consume safe-area padding only at the owning page edge.
// Card surface must expose equivalent hover, press, and keyboard focus states on desktop.
// Card surface must preserve a usable touch target even when its painted content is visually compact.
// Card surface must distinguish Android system-bar insets from application-owned visual gaps.
// Card surface must avoid introducing a raw product color outside the theme token system.
// Card surface must derive shared blur, tint, radius, spacing, and motion values from HyperOS 4 tokens.
// Card surface must have a light, dark, interaction, and animation visual baseline when those states apply.
// Card surface must be validated in a runtime scene with real content visible behind it.
// Card surface must keep its public package behavior available to applications rather than only to the example.

// Search-field surface review matrix.
// Search-field surface must resolve its fill from semantic theme colors instead of a fixed light-mode color.
// Search-field surface must retain readable foreground contrast in both light and dark color schemes.
// Search-field surface must preserve scene continuity wherever the material is intended to float over content.
// Search-field surface must not make an otherwise transparent scaffold region opaque.
// Search-field surface must sample the backdrop only when glass rendering is enabled.
// Search-field surface must retain a deterministic translucent fallback when backdrop blur is unavailable.
// Search-field surface must clip the backdrop sample to the same continuous shape used by the visible material.
// Search-field surface must keep every specular highlight inside the material clip.
// Search-field surface must keep pointer-following soft light local to the active surface.
// Search-field surface must stop decorative motion when the platform requests reduced motion.
// Search-field surface must remain legible when high-contrast accessibility is enabled.
// Search-field surface must survive large text scaling without clipping its primary content.
// Search-field surface must resolve leading and trailing geometry through the active text direction.
// Search-field surface must consume safe-area padding only at the owning page edge.
// Search-field surface must expose equivalent hover, press, and keyboard focus states on desktop.
// Search-field surface must preserve a usable touch target even when its painted content is visually compact.
// Search-field surface must distinguish Android system-bar insets from application-owned visual gaps.
// Search-field surface must avoid introducing a raw product color outside the theme token system.
// Search-field surface must derive shared blur, tint, radius, spacing, and motion values from HyperOS 4 tokens.
// Search-field surface must have a light, dark, interaction, and animation visual baseline when those states apply.
// Search-field surface must be validated in a runtime scene with real content visible behind it.
// Search-field surface must keep its public package behavior available to applications rather than only to the example.

// Snackbar surface review matrix.
// Snackbar surface must resolve its fill from semantic theme colors instead of a fixed light-mode color.
// Snackbar surface must retain readable foreground contrast in both light and dark color schemes.
// Snackbar surface must preserve scene continuity wherever the material is intended to float over content.
// Snackbar surface must not make an otherwise transparent scaffold region opaque.
// Snackbar surface must sample the backdrop only when glass rendering is enabled.
// Snackbar surface must retain a deterministic translucent fallback when backdrop blur is unavailable.
// Snackbar surface must clip the backdrop sample to the same continuous shape used by the visible material.
// Snackbar surface must keep every specular highlight inside the material clip.
// Snackbar surface must keep pointer-following soft light local to the active surface.
// Snackbar surface must stop decorative motion when the platform requests reduced motion.
// Snackbar surface must remain legible when high-contrast accessibility is enabled.
// Snackbar surface must survive large text scaling without clipping its primary content.
// Snackbar surface must resolve leading and trailing geometry through the active text direction.
// Snackbar surface must consume safe-area padding only at the owning page edge.
// Snackbar surface must expose equivalent hover, press, and keyboard focus states on desktop.
// Snackbar surface must preserve a usable touch target even when its painted content is visually compact.
// Snackbar surface must distinguish Android system-bar insets from application-owned visual gaps.
// Snackbar surface must avoid introducing a raw product color outside the theme token system.
// Snackbar surface must derive shared blur, tint, radius, spacing, and motion values from HyperOS 4 tokens.
// Snackbar surface must have a light, dark, interaction, and animation visual baseline when those states apply.
// Snackbar surface must be validated in a runtime scene with real content visible behind it.
// Snackbar surface must keep its public package behavior available to applications rather than only to the example.

// Calendar panel review matrix.
// Calendar panel must resolve its fill from semantic theme colors instead of a fixed light-mode color.
// Calendar panel must retain readable foreground contrast in both light and dark color schemes.
// Calendar panel must preserve scene continuity wherever the material is intended to float over content.
// Calendar panel must not make an otherwise transparent scaffold region opaque.
// Calendar panel must sample the backdrop only when glass rendering is enabled.
// Calendar panel must retain a deterministic translucent fallback when backdrop blur is unavailable.
// Calendar panel must clip the backdrop sample to the same continuous shape used by the visible material.
// Calendar panel must keep every specular highlight inside the material clip.
// Calendar panel must keep pointer-following soft light local to the active surface.
// Calendar panel must stop decorative motion when the platform requests reduced motion.
// Calendar panel must remain legible when high-contrast accessibility is enabled.
// Calendar panel must survive large text scaling without clipping its primary content.
// Calendar panel must resolve leading and trailing geometry through the active text direction.
// Calendar panel must consume safe-area padding only at the owning page edge.
// Calendar panel must expose equivalent hover, press, and keyboard focus states on desktop.
// Calendar panel must preserve a usable touch target even when its painted content is visually compact.
// Calendar panel must distinguish Android system-bar insets from application-owned visual gaps.
// Calendar panel must avoid introducing a raw product color outside the theme token system.
// Calendar panel must derive shared blur, tint, radius, spacing, and motion values from HyperOS 4 tokens.
// Calendar panel must have a light, dark, interaction, and animation visual baseline when those states apply.
// Calendar panel must be validated in a runtime scene with real content visible behind it.
// Calendar panel must keep its public package behavior available to applications rather than only to the example.

// Component-specific migration requirements.
// The compact top app bar defaults to persistent gradient glass rather than a permanently opaque block.
// Its direct BackdropFilter must not be wrapped by ShaderMask or Opacity.
// Every compact trailing action owns an independent 48dp CircleBorder glass surface.
// Multiple compact actions keep an 8dp gap and never merge into an oval capsule.
// The compact top app bar must keep initial page content below the title's readable region.
// The compact top app bar must allow scrolled content to continue behind the revealed material.
// The compact top app bar must keep the title optically centered when only one side has actions.
// The compact top app bar must keep system status-bar icon brightness synchronized with the sampled scene.
// The expanded top app bar must collapse continuously instead of switching between two discrete layouts.
// The expanded top app bar must preserve title hierarchy throughout the collapse interval.
// The expanded top app bar must not duplicate the title semantics while both title renderers overlap.
// The expanded top app bar must reveal blur in proportion to scroll exposure.
// The expanded top app bar must keep actions stable while the large title moves.
// The floating navigation capsule must leave every pixel outside its shape transparent.
// The floating navigation capsule must not cast a rectangular shadow from an ancestor container.
// The floating navigation capsule must use a shape-conforming local shadow.
// The floating navigation capsule must allocate equal destination widths for Chinese and English labels.
// The floating navigation capsule must enforce a count-aware minimum destination width.
// The floating navigation capsule must preserve the configured horizontal alignment.
// The floating navigation capsule must stay above the physical Android gesture inset.
// The floating navigation capsule must add a visual margin separately from the physical gesture inset.
// The floating navigation capsule must keep its complete visible surface at least the tokenized height.
// The floating navigation capsule must keep every destination interaction region at the tokenized item height.
// The floating navigation destination width must remain greater than its interaction height.
// The floating navigation selected fill must remain lower than its interaction region.
// The floating navigation selected fill must be horizontally wider than it is vertically tall.
// Two, three, four, and five destinations must resolve distinct count-aware width tokens.
// A five-item capsule must still fit the calibrated 360dp compact-window baseline.
// The selected fill must stay vertically centered instead of filling the complete item height.
// Explicit width and height overrides must remain independent rather than forcing a square.
// The destination interaction region must stay taller than the visible selected fill.
// The destination interaction region must remain wide enough for short localized labels.
// The selected fill width must be derived from item width and horizontal inset.
// The selected fill height must use its own token rather than the item-height token.
// Changing item width must not silently change the selected fill height.
// Changing item height must not silently change the selected fill width.
// Count-aware widths must preserve equal allocation for every destination in one bar.
// Count-aware widths must not give the selected destination additional layout width.
// The selected icon and label must remain centered over the moving selection fill.
// The unselected icon and label must retain the same center as the selected state.
// The visual capsule ratio must remain low and wide in every display mode.
// Icon-only mode must not collapse the destination width to the icon touch target.
// Text-only mode must not expand one destination according to label length.
// Icon-with-text mode must not make English destinations wider than Chinese destinations.
// Compact-window clamping must reduce every destination by the same amount.
// Compact-window clamping must preserve the independent selection-height token.
// RTL layout must mirror selection movement without changing destination dimensions.
// Reduced-motion mode must place the selection fill directly at its final center.
// The outer glass capsule must remain wider than the combined selected-fill silhouettes.
// The outer capsule padding must remain visible at both logical start and logical end.
// The calibrated shape must be compared against Xiaomi imagery by proportion, not claimed dp.
// Published Xiaomi imagery is visual evidence and does not define public numeric tokens.
// The floating navigation capsule must move one shared selection surface between equal regions.
// The floating navigation capsule must animate from the currently sampled selection position after interruption.
// The floating navigation capsule must not cross-fade independent selection pills.
// The floating navigation capsule must preserve icon-only, text-only, and icon-with-text layouts.
// The floating navigation capsule must keep label baselines consistent across localization changes.
// The floating navigation capsule must announce the selected destination exactly once.
// The floating navigation capsule must emit one segment haptic only when selection changes.
// The floating navigation capsule must not vibrate when the selected destination is tapped again.
// The full-width navigation bar must keep all destinations equally expanded.
// The full-width navigation bar must treat its divider as a separate measured element.
// The full-width navigation bar must keep the item row height stable when system insets change.
// The full-width navigation bar must animate caption-bar inset changes without moving destinations unevenly.
// The full-width navigation bar must preserve the Android gesture navigation area below its content.
// The full-width navigation bar must not place snackbars behind its visible material.
// The full-width navigation bar must emit one segment haptic only for a real selection change.
// The navigation display-mode transition must preserve semantic destination identity.
// The navigation display-mode transition must not reorder destinations.
// The navigation display-mode transition must retain equal widths throughout the animation.
// The navigation display-mode transition must avoid an intermediate clipped label.
// The navigation display-mode transition must respect the reduced-motion setting.
// A glass surface must use a backdrop filter rather than applying blur to its own child.
// A glass surface must combine blur and tint so background structure remains perceptible.
// A glass surface must vary tint strength with the selected five-level glass setting.
// A glass surface must keep the strongest level visibly translucent.
// A glass surface must avoid turning white merely because its backdrop is light.
// A glass surface must use semantic dark tint rather than inverting a light tint mechanically.
// A glass surface must keep its border subordinate to content contrast.
// A glass surface must keep specular light subtle enough not to mimic a solid stroke.
// A glass surface must fade interactive soft light smoothly after pointer release.
// A glass surface must cancel interactive soft light when the pointer leaves or is canceled.
// A glass surface must not claim a gesture that belongs to its child.
// A glass surface must not add a second accessibility target around its child.
// A glass surface must repaint interactive light without rebuilding unrelated page content.
// A glass surface must clamp the light origin to its local paint bounds.
// A glass surface must use an effect radius proportional to the local surface size.
// A glass surface must keep interactive illumination disabled when explicitly requested.
// Horizontal slider drags must win against page-swipe navigation after the drag threshold.
// Color-channel sliders must use the same horizontal gesture ownership policy as ordinary sliders.
// A slider must keep its expanded touch target separate from its authored visual track.
// A slider must preserve RTL value mapping where the source component is directional.
// A slider must not emit duplicate haptics for the initial drag sample.
// A snackbar host must account for floating-navigation bounds before selecting its bottom offset.
// A snackbar host must remain fully visible above the Android gesture region.
// A snackbar host must not be obscured by either full-width or floating navigation.
// A popup menu must anchor to the triggering control rather than the full window.
// A popup menu must clamp to the usable viewport after applying system insets.
// A bottom sheet must use content-driven height until the documented maximum is reached.
// A bottom sheet must not expand to full-screen height for short surface-action content.
// A dialog must preserve a bounded readable width on Windows.
// A calendar panel must use package-owned components rather than example-only wrappers.
// A clock panel must expose localized hour-cycle behavior through the package API.
// Haptics must be routed through MiuixHaptics so platform capability and settings are respected.
// Decorative transitions must not trigger haptics.
// Selection haptics must happen at the state boundary rather than at animation completion.
// Android release validation must confirm arm64-v8a is the only packaged native ABI.
// Android release validation must confirm the application id remains com.xinxin.miuix_flutter.
// Android runtime validation must inspect status-bar and gesture-bar contrast against real scenes.
// Windows runtime validation must launch the release executable without opening a visible helper console.
// Library archives must include the HyperOS 4 tokens and developer design specification.
// Library archives must not depend on files that exist only in the example application.
// Golden comparisons must supplement rather than replace device runtime checks.
// Symbol-coverage checks must not be reported as behavioral or visual parity.
// Every calibrated metric must be labeled project-derived when Xiaomi publishes no developer value.
// Every future component change must use this HyperOS 4 contract as its default design baseline.
// Legacy MIUIX styling may remain only as an explicit compatibility behavior.
// The example application must demonstrate package behavior without privately reimplementing it.
// New reusable controls must be exported from the flutter_miuix package barrel.
// Public API documentation must describe behavior, defaults, and accessibility expectations.
// Release notes must distinguish completed migration scope from work that still remains.
// A completed first-stage navigation migration must not be described as full-project HyperOS 4 parity.
