// HyperOS 4 selection-trigger-field contract.
//
// This file intentionally contains documentation only. It records the design
// and compatibility decisions shared by MiuixMultiSelect,
// MiuixSearchableSelect, and MiuixComboBox so future refactors can be reviewed
// without treating project-calibrated values as unpublished Xiaomi metrics.
//
// Material contract:
// - Standard constructors opt into the theme's local content glass.
// - Glass permission still obeys MiuixThemeData.enableGlass and intensity.
// - Blur and tint resolve from contentSurfaceBlur and
//   contentSurfaceTintOpacity unless the caller provides an override.
// - The outline uses textFieldCornerRadius so selection fields align with
//   editable fields in the same form.
// - showGlassSpecular controls the restrained highlight independently from
//   blur and tint.
// - glass: false disables the material effect without reverting geometry.
//
// Multi-value contract:
// - The trigger owns the only backdrop-filter layer.
// - Selected values use compact input chips inside that parent surface.
// - Chips must not introduce nested backdrop blur because repeated filtering
//   muddies text and makes the field appear heavier than adjacent controls.
// - Chip width follows its label and remove affordance; it must not expand to
//   divide all available row width.
// - Overflow wraps vertically while the trigger remains content-driven.
//
// Popup contract:
// - Selection dialogs remain content-driven and bounded by the viewport.
// - Trigger migration must not turn popup content into a full-height sheet.
// - Popup glass is owned by the dialog and is separate from trigger glass.
// - Keyboard, focus, semantics, and selection behavior remain unchanged.
//
// Compatibility contract:
// - MiuixMultiSelect.source preserves the prior opaque 16dp trigger.
// - MiuixSearchableSelect.source preserves the prior opaque 18dp trigger.
// - MiuixComboBox.source preserves the prior opaque 18dp trigger.
// - Source styles may retain historical selected-value geometry for migration
//   screenshots, but new work must use the standard compact-chip path.
// - Public constructor parameters remain source compatible; added material
//   controls are optional.
//
// Evidence boundary:
// - Xiaomi has not published exact selection-field blur, opacity, or radius
//   values for HyperOS 4 in the referenced promotional material.
// - The defaults used here are project-calibrated theme tokens, not claimed
//   official dp or material specifications.
// - Acceptance therefore combines theme-resolution tests, compact-geometry
//   assertions, golden images, and runtime review rather than a false claim of
//   pixel-perfect reproduction from unavailable official measurements.
library;
