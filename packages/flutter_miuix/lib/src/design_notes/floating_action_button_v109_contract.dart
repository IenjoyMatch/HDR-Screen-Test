// MIUIX 1.0.9 FloatingActionButton parity contract.
//
// Purpose
//
// This note records the complete behavior of basic/FloatingActionButton.kt.
// The component is a composition of Surface, defaultMinSize, and centered Box.
// The local upstream source remains authoritative for future maintenance.
//
// Source API
//
// onClick is required.
// modifier is applied to the outer Surface.
// shape defaults to Compose CircleShape.
// containerColor defaults to the active primary token.
// shadowElevation defaults through FloatingActionButtonDefaults.
// minWidth defaults through FloatingActionButtonDefaults.
// minHeight defaults through FloatingActionButtonDefaults.
// content is an arbitrary composable slot.
// The component defines no selected or expanded state.
// The component defines no built-in icon or label parameters.
//
// Flutter API mapping
//
// onPressed represents source onClick.
// A null onPressed is a compatibility-only disabled adapter.
// Parent widgets represent the source Modifier chain.
// shape represents an explicit source Shape.
// containerColor represents the source background.
// shadowElevation, minWidth, and minHeight map directly.
// child represents the arbitrary content slot.
// icon is an existing convenience adapter for a single widget.
// label is an existing convenience adapter that constructs arbitrary content.
// The adapters do not alter the source minimum surface constraints.
//
// Defaults object
//
// Source MinWidth is 60dp.
// Source MinHeight is 60dp.
// Source ShadowElevation is 4dp.
// MiuixFloatingActionButtonDefaults exposes the three immutable values.
// Constructor defaults reference that public object instead of repeated numbers.
// Defaults describe minimums rather than fixed dimensions.
//
// Layout
//
// Source modifier.defaultMinSize is applied to the inner Box.
// Incoming tighter parent constraints remain authoritative.
// Content larger than either minimum expands the surface.
// Content is aligned to the center of the resulting Box.
// Center alignment applies equally to icon, label, and direct child paths.
// A direct small child must not remain at the upper-leading corner.
// A plain icon does not receive source padding.
// No maximum width or height is installed.
// No Material 56dp FloatingActionButton constraint is inherited.
// No Material hero, notch, or tooltip behavior is added.
//
// Physical-pixel rounding
//
// Compose converts each Dp minimum to an integer physical constraint.
// At 420dpi, 60dp becomes 158 physical pixels.
// Flutter rounds minWidth and minHeight independently before layout.
// A 60-by-60 default therefore occupies 158-by-158 physical pixels.
// Custom minimums use the same independent rounding.
// Larger intrinsic content remains free to determine the final physical extent.
//
// Circle shape
//
// CircleShape is a 50-percent RoundedCornerShape.
// It is independent of the MIUIX smooth-rounding theme preference.
// A square final surface is circular.
// A rectangular final surface is a stadium with semicircular short ends.
// Flutter StadiumBorder is the direct percentage-based counterpart.
// MiuixCapsuleBorder remains available to components that explicitly use the
// MIUIX smooth capsule, but FloatingActionButton must not select it by default.
// Explicit caller shapes bypass the default capsule switch entirely.
//
// Surface and color
//
// Source containerColor defaults to primary.
// Source Surface content color defaults to onSurface.
// The Flutter compatibility contentColor exposes that inherited slot color.
// Content receives both the private MIUIX content-color scope and IconTheme.
// MiuixIcon therefore inherits the same foreground as ordinary Flutter Icon.
// Text receives the same foreground through DefaultTextStyle.
// Explicit icon or text colors still take precedence in their own primitives.
// The capsule paints no border by default.
//
// Shadow
//
// Source Surface owns a graphics-layer shadow outside its clip.
// Default source shadow elevation is 4dp.
// The calibrated Flutter shadow uses 20 percent black.
// Its blur radius is twice the logical elevation.
// Its vertical offset is half the logical elevation.
// Surface.kt installs graphicsLayer only when the converted value is > 0f.
// Zero and negative elevation therefore both remove the BoxShadow list.
// Negative source input remains legal and must not trip a Flutter assertion.
// The content/indication clip never clips the outer shadow.
//
// Interaction
//
// Source Surface installs its ordinary indication.
// It does not add sink, tilt, or shrink motion.
// MiuixPressable therefore uses feedback type none.
// The ordinary press overlay reaches 10 percent opacity.
// A completed tap invokes onPressed once.
// A null compatibility callback removes both tap and indication.
// FloatingActionButton.kt itself requests no haptic feedback.
//
// Accessibility
//
// The outer source modifier adds Role.Button semantics.
// Flutter publishes button true on the complete capsule bounds.
// A non-null callback publishes enabled true.
// A null compatibility callback publishes enabled false.
// Child content contributes its own localized label or description.
// The wrapper does not invent an English accessibility label.
// Custom shape and color do not alter semantic bounds or role.
//
// File structure
//
// The component is isolated in parts/floating_action_button.dart.
// This keeps the shared core model file below its previous responsibility count.
// MiuixCapsuleBorder lives with reusable effects and source shapes.
// The shape is available to other MIUIX components with dynamic content.
//
// Regression obligations
//
// Public default values require exact assertions.
// Default logical size requires a 60-by-60 assertion.
// Default 420dpi size requires the existing physical-rounding assertion.
// Default container, foreground, shadow, and button role require assertions.
// Both smooth-theme modes require StadiumBorder for the default source shape.
// A direct MiuixCapsuleBorder helper test remains separate from FAB parity.
// Arbitrary content must expand beyond the default minimum.
// Arbitrary content smaller than the minimum must be centered on both axes.
// Explicit custom shapes must remain unchanged.
// Zero and negative shadow elevations must both remain legal and shadowless.
// Disabled compatibility behavior must remove indication and activation.
// Six FloatingActionButton goldens record the current percentage-circle edge.
