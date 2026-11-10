// HyperOS 4 structured-surface migration contract.
//
// Scope:
// - MiuixFormSection groups related input fields.
// - MiuixDataTable presents a bounded desktop or tablet data region.
// - MiuixProcessStepper highlights the currently expanded workflow step.
// - These widgets already consume shared HyperOS 4 geometry and motion tokens.
// - Their ordinary constructors therefore default to the matching glass layer.
//
// Default material route:
// - Ordinary constructors set glass=true unless the caller overrides it.
// - The glass is local to the component's own continuous-corner silhouette.
// - No ancestor-sized rectangle is introduced behind the clipped material.
// - Form and table surfaces use contentSurfaceBlur and tint opacity.
// - Process steps use inlineSurfaceBlur and inline tint opacity.
// - Form radius follows settingsGroupCornerRadius.
// - Table radius follows cardCornerRadius.
// - Process step radius follows inlineSurfaceCornerRadius.
// - Complex scene colors must remain visible through every ordinary surface.
// - Text, selection and header masks retain semantic contrast over the sample.
//
// Explicit solid and source routes:
// - Every ordinary widget still accepts glass=false as an explicit opt-out.
// - Opting out changes material only and does not restore legacy geometry.
// - The `.source` constructors remain the legacy geometry boundary.
// - Source form sections retain fixed padding, gaps and an opaque surface.
// - Source tables retain the fixed 20dp opaque outer surface.
// - Source process steps retain fixed 18dp opaque selected-step surfaces.
// - Source routes never inherit a theme change that silently enables glass.
//
// Form behavior:
// - Validation, save and reset remain Flutter Form responsibilities.
// - Error insertion continues to honor reduced-motion structure switching.
// - Dividers and field gaps remain inside one clipped group surface.
// - Titles and footers remain outside the sampled content material.
// - Field focus and input gestures are not intercepted by the glass wrapper.
//
// Table behavior:
// - Header and rows share one sampled, clipped table surface.
// - Header tint remains translucent only when glass mode is active.
// - Sorting, row selection and keyboard traversal retain their haptic roles.
// - Horizontal and vertical scrollbars stay inside the table's pointer bounds.
// - A horizontal scrollbar lane remains separate from the final data row.
// - Empty-state replacement and shrink-wrap measurement remain unchanged.
//
// Process behavior:
// - Only the current expanded step receives the selected glass surface.
// - Pending steps do not become a repeated stack of independent glass cards.
// - Marker, connector and expansion motion remain continuous.
// - Reduced motion builds the current endpoint without an animated-size tree.
// - Selection and default actions keep their existing feedback semantics.
//
// Regression obligations:
// - Unit tests inspect ordinary token resolution without passing glass=true.
// - Unit tests inspect `.source` opaque geometry independently.
// - Light and dark goldens use complex gradients and colored scene objects.
// - The goldens compare ordinary and source forms, steps and tables together.
// - Explicit API opt-outs remain source compatible.
// - Full-suite and release-cycle gates are required after any material change.
