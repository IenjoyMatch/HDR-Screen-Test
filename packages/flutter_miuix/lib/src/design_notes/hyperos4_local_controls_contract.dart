// HyperOS 4 local-control migration contract.
//
// Scope
// -----
// This contract covers segmented controls and floating action toolbars.
// Both are local controls layered above page content rather than page chrome.
// Their ordinary constructors represent the current HyperOS 4 presentation.
// Their named source constructors preserve the previous MIUIX presentation.
// The implementation belongs to the reusable library and not the example.
//
// Evidence boundary
// -----------------
// Xiaomi's public page shows local translucent capsules and continuous motion.
// It does not publish exact Flutter blur, opacity, height, or timing values.
// Numeric defaults in MiuixHyperOs4Tokens are project-calibrated values.
// Those numbers remain theme-overridable and must not be called official dp.
// Legacy source numbers remain available only through explicit source APIs.
//
// Segmented-control material
// --------------------------
// The ordinary segmented control opts into backdrop sampling by default.
// Blur is clipped to the complete outer capsule and never fills its parent.
// Tint opacity resolves from the active HyperOS 4 theme token.
// The outer corner and height resolve from the active HyperOS 4 theme token.
// Explicit widget values take priority over theme defaults.
// glass=false disables local blur without changing behavior or semantics.
// The source constructor defaults to the old opaque 42dp by 16dp surface.
//
// Segmented-control selection
// ---------------------------
// Expanded single-selection controls divide available width exactly equally.
// One shared selection surface moves between those equal destination regions.
// Text length must not allocate a wider destination to one option.
// The moving surface uses directional positioning so RTL order remains valid.
// Foreground colors update together with the shared surface destination.
// Disabled options remain skipped by both pointer and keyboard navigation.
// Multi-selection retains independent selection fills because several values
// can be selected at the same time and no single moving surface can represent
// that state truthfully.
// Non-expanded controls retain intrinsic label sizing for inline composition.
//
// Motion and accessibility
// ------------------------
// Shared selection movement uses the HyperOS 4 continuous-motion token.
// Reversing a selection while moving retargets the currently painted surface.
// MediaQuery.disableAnimations reduces the transition duration to zero.
// Reduced motion changes timing only, never selection semantics or geometry.
// Selection emits the existing segment-tick haptic role once per value change.
// Tapping the selected value obeys the caller's allow-empty-selection policy.
// Arrow keys preserve disabled-option skipping and the active focus boundary.
// Every segment continues to publish selected, enabled, and button semantics.
//
// Floating toolbar material
// -------------------------
// The ordinary toolbar opts into local backdrop glass by default.
// Its blur, tint, and capsule corner resolve from HyperOS 4 theme tokens.
// The source constructor retains the opaque squircle and legacy 50dp radius.
// An explicit corner radius overrides both current and source defaults.
// The shadow follows the same rounded silhouette as the visible toolbar.
// No parent-sized DecoratedBox may be introduced behind the local capsule.
// Non-toolbar content remains visible around every rounded corner cutout.
// The optional divider remains an independently measured source extension.
// An arbitrary child remains unclipped in the explicit opaque source path.
// The glass path clips sampling and edge reflection to its own exact shape.
//
// Theme and intensity
// -------------------
// Global enableGlass remains the application-level performance authority.
// The five-level material controller continues to modulate allowed glass.
// Strong intensity must show sampled background instead of opaque white fill.
// Light and dark themes resolve readable foreground through semantic colors.
// Caller-provided colors tint the glass but do not expand its clipping bounds.
//
// Verification
// ------------
// Tests inspect the default blur, opacity, radius, and measured control height.
// Tests prove the shared selector changes directional position after selection.
// Tests prove reduced motion produces a zero-duration selector transition.
// Tests prove named source constructors remain opaque and keep old geometry.
// Tests inspect toolbar glass separately from the opaque source fill.
// Full analysis, package tests, scope verification, and Release remain required.
//
// Layout resilience
// -----------------
// Empty value lists collapse without constructing an unbounded option row.
// Expanded layout assumes a finite width supplied by its surrounding page.
// Intrinsic layout remains available for toolbars and compact inline forms.
// Narrow labels ellipsize inside their own destination instead of overflowing.
// The outer surface height includes its three-dp project-calibrated inset.
// The shared selector remains inside that inset for every selected index.
// A custom height cannot produce a negative inner height or corner radius.
// Toolbar outside padding stays outside paint, shadow, and pointer capture.
// Horizontal and vertical toolbar arrangements retain caller-owned spacing.
//
// Interaction ownership
// ---------------------
// Pointer input is accepted only by enabled segmented destinations.
// A disabled destination cannot emit a callback, haptic, or focus selection.
// Toolbar background input is consumed so it cannot activate content behind.
// Toolbar children retain their own actions and accessibility descriptions.
// Glass sampling itself never creates an accessibility node or tap action.
// Keyboard movement remains bounded and does not wrap across group endpoints.
// Focus indication remains local to the option group on Windows.
//
// Regression boundaries
// ---------------------
// The legacy constants remain public aliases for source compatibility.
// Those aliases are not reused as ordinary-constructor visual defaults.
// Source-specific tests must construct the named source presentation.
// Current visual goldens must construct the ordinary HyperOS presentation.
// A golden update is accepted only after inspecting the changed rendered image.
// Build success alone cannot establish glass clipping or selector movement.
// Structural tests complement, rather than replace, rendered visual baselines.
// Release metadata changes generated after packaging belong to the same cycle.
