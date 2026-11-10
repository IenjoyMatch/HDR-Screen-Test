// HyperOS 4 FloatingActionButton implementation and review contract.
//
// Scope and evidence boundary.
// The ordinary constructor targets the project's HyperOS 4 visual baseline.
// The source constructor preserves the MIUIX 1.0.9 surface contract.
// Xiaomi has not published FAB blur, tint, or elevation developer tokens.
// HyperOS numeric material values are therefore project calibration points.
// Runtime screenshots are required before calling those values visually final.
// Source parity and HyperOS visual migration are separate acceptance claims.
//
// Default HyperOS material.
// The ordinary FAB renders exactly one local backdrop-sampling glass layer.
// Glass never paints outside the final circular or extended capsule silhouette.
// The page and Scaffold remain visible in every non-FAB corner and margin.
// Blur follows MiuixHyperOs4Tokens.floatingActionButtonBlur.
// Tint follows MiuixHyperOs4Tokens.floatingActionButtonTintOpacity.
// Both channels participate in the application five-level glass controller.
// The strongest glass level must still transmit backdrop color variation.
// Disabling application glass retains an opaque, readable semantic fallback.
// The ordinary default primary tint uses the matching onPrimary content role.
// Caller-provided container and content colors remain independent overrides.
// Directional specular reflection may be disabled without disabling blur.
// Pointer light observes contact without adding a competing gesture recognizer.
//
// Shape and projection.
// Fill, backdrop clip, specular edge, indication, and shadow share one shape.
// The default shape remains a percentage-based StadiumBorder.
// A square default surface consequently appears circular.
// Wider arbitrary content consequently expands the surface into a capsule.
// Global G2 enablement must not replace the default percentage circle.
// Explicit ShapeBorder values pass through without radius approximation.
// Explicit shaped glass clips the BackdropFilter with that exact outer path.
// Explicit shaped glass paints requested borders fully inside the same path.
// Specular edge strokes also follow an explicit shape rather than an RRect.
// Shadow is outside the glass clip so blur and projection are not truncated.
// Shadow has no transparent rectangular fill behind the clipped surface.
// Nonpositive source elevation produces no projection.
//
// Layout and interaction.
// The source 60dp minimum width and height remain available unchanged.
// Min dimensions are independently rounded to physical pixels before layout.
// The arbitrary child remains centered in the final minimum-constrained box.
// Content larger than the minimum remains unconstrained and changes the shape.
// A null callback exposes a disabled button and installs no press indication.
// An enabled callback retains the current MIUIX indication response.
// FAB itself does not invent a new haptic role absent from the source contract.
// Scaffold placement and Snackbar avoidance use the final measured FAB bounds.
// Android bottom insets and Windows window edges remain Scaffold responsibilities.
//
// Compatibility constructor.
// MiuixFloatingActionButton.source never creates a MiuixGlass descendant.
// Source uses the opaque primary surface and onSurface content fallback.
// Source retains the 60dp minimum, 4dp elevation, and CircleShape behavior.
// Source continues accepting arbitrary child, icon, label, and custom shape.
// Source custom colors and negative elevation preserve prior API behavior.
// Existing geometry evidence stays attached to the explicit source path.
//
// Verification.
// Focused tests cover default glass tokens, foreground, and shape identity.
// Focused tests cover source fill, content color, shadow, and press indication.
// Generic glass tests cover explicit-shape tint, reflection, border, and clip.
// Complex-backdrop goldens compare HyperOS and source in light and dark themes.
// Component-manifest goldens retain the ordinary constructor as the new default.
// Full analysis, package gates, and complete tests run before every Release.
// Android arm64 and Windows x64 artifacts are rebuilt after this contract changes.
