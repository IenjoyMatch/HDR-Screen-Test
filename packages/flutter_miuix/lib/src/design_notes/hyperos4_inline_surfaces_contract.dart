// HyperOS 4 inline application surface contract.
//
// Scope
// -----
// This contract covers MiuixChip, MiuixInlineAlert, MiuixBanner, and
// MiuixExpandableCard as reusable package components.
// The ordinary constructors represent the current HyperOS 4 presentation.
// Named source constructors retain the previous opaque compatibility style.
// The example application may demonstrate these components but may not own
// private replacements for their material, geometry, or motion behavior.
//
// Evidence boundary
// -----------------
// Xiaomi's public imagery demonstrates light local floating surfaces and
// content-first composition but does not publish developer-facing dp values.
// Blur, tint, corner, and duration values are project calibration points.
// Project-calibrated values must remain centralized in MiuixHyperOs4Tokens.
// A calibrated value must never be described as a private Xiaomi constant.
// Visual comparisons supplement structural tests and package compilation.
//
// Default material
// ----------------
// Ordinary inline surfaces use real backdrop sampling by default.
// Each surface clips blur, tint, border, and reflection to its own silhouette.
// No parent-sized opaque box may be added behind a rounded local surface.
// Content behind rounded corner cutouts must remain visible.
// Global enableGlass remains the application-level performance authority.
// The five-level glass intensity modifies blur and tint as one material.
// Strong intensity must not turn a local surface into opaque white paint.
// Dark mode must use a semantic dark tint instead of inverted light paint.
//
// Semantic tint
// -------------
// Alert severity color remains present when backdrop glass is enabled.
// Information, warning, error, and success must remain distinguishable.
// A transparent placeholder color must not erase alert hierarchy.
// Banner tint starts from the active semantic surface color.
// Expandable-card tint starts from the active semantic surface color.
// Caller-provided chip palettes continue to affect selected and disabled states.
// Glass opacity controls material strength, not semantic-state selection.
// Text and icons retain readable semantic foreground colors over every tint.
//
// Chip geometry and interaction
// -----------------------------
// Chips remain low-height capsules rather than miniature rounded cards.
// Capsule width follows its compact content and documented maximum width.
// A selected chip does not claim extra layout width merely for selection.
// Filter and choice variants continue to publish selected semantics.
// Assist, input, and suggestion variants retain their distinct action roles.
// Delete remains an independent semantic action inside an input chip.
// Disabled chips expose no pointer action and no haptic feedback.
// An accepted selection emits exactly one toggle haptic role.
// An accepted ordinary action emits exactly one confirm haptic role.
// Selection color retargets from the currently sampled transition value.
// Reduced motion changes the selection-color duration to zero.
// The material transition must not resize or detach the chip content.
//
// Alert and banner behavior
// -------------------------
// Inline alerts remain live-region containers for time-sensitive information.
// Banner live-region behavior remains explicitly controlled by its caller.
// Dismiss controls keep their own button semantics and tooltip description.
// Dismissing a surface must not create a second tap target on the background.
// Alert actions remain inside the clipped material surface.
// Banner actions remain inside the clipped material surface.
// Leading artwork must not change the outer corner or material bounds.
// Long localized text may wrap without escaping the calibrated inner padding.
// Severity tint and readable foreground must be checked in light and dark mode.
//
// Expandable-card behavior
// ------------------------
// The ordinary expandable card uses the inline continuous-corner token.
// Header indication clips to the same continuous-corner silhouette.
// Expansion uses one shared token for disclosure and content-size movement.
// Reduced motion makes both disclosure and content transitions immediate.
// Controlled and uncontrolled state continue to produce identical geometry.
// An empty child list cannot report an expanded accessibility state.
// Disabled cards cannot toggle, vibrate, or publish an enabled action.
// A real expansion change emits one matching toggle haptic role.
// Interrupting expansion must retarget from the currently painted size.
// Child content remains in package-owned padding inside the material surface.
//
// Source compatibility
// --------------------
// MiuixChip.source keeps the former opaque capsule presentation by default.
// MiuixInlineAlert.source keeps the former opaque 18dp corner presentation.
// MiuixBanner.source keeps the former opaque 20dp corner presentation.
// MiuixExpandableCard.source keeps the former rectangular presentation.
// Source constructors retain the same callbacks, slots, semantics, and state.
// Explicit caller overrides remain possible without changing ordinary defaults.
// Existing glass and color parameters remain source compatible.
// Source-specific tests must use named source constructors explicitly.
// New examples must use ordinary constructors unless demonstrating migration.
//
// Adaptive and accessibility requirements
// ---------------------------------------
// Inline surfaces must remain usable on Android phones, tablets, and Windows.
// Pointer hover and keyboard focus must stay visible over translucent material.
// Touch targets remain independent from the painted chip height where needed.
// Text scaling may increase content height without clipping semantic actions.
// RTL mirrors directional padding and disclosure placement exactly once.
// High-contrast foreground remains readable over simple and complex backdrops.
// Background sampling itself must not create an accessibility node.
// Decorative reflection and contact light must not claim pointer gestures.
//
// Verification
// ------------
// Widget tests inspect default token blur, tint, and continuous corner values.
// Widget tests prove source constructors remain opaque.
// Widget tests prove severity tint reaches the actual MiuixGlass layer.
// Widget tests prove reduced motion produces zero-duration expansion.
// Visual baselines cover current and source styles in light and dark themes.
// Visual baselines use a multicolor backdrop so transparency is observable.
// Every generated golden must be inspected before it becomes a baseline.
// Full analyzer, scope verification, and Flutter tests remain release gates.
// Android release validation must confirm package, ABI, version, and signature.
// Windows release validation must confirm hidden launch responsiveness.
// Build success is not proof of visual material correctness on a real device.
// Missing Android runtime access must be disclosed instead of inferred.
// Release notes must describe this as one migration phase, not full parity.

library;
