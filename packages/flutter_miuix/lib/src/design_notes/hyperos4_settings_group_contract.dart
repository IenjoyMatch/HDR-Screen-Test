// HyperOS 4 settings-group contract.
//
// Evidence boundary
//
// Official first-party imagery shows settings content grouped by hierarchy.
// It does not publish a Flutter surface parameter table.
// Radius, blur, opacity, stroke, and spacing remain project calibrations.
// These values must not be described as official Xiaomi dp measurements.
// The explicit source constructor preserves the former package surface.
//
// Standard hierarchy
//
// MiuixSettingsGroup owns exactly one surface for the complete row group.
// Individual child rows do not receive independent glass backgrounds.
// The group samples only content behind its continuous rounded silhouette.
// Content remains visible outside the rounded outline and its corner cuts.
// No rectangular shadow or fill may surround the clipped group.
// The title remains outside the shared information surface.
// Empty groups retain their prior title-only layout.
//
// Material resolution
//
// Glass is enabled by default on the ordinary constructor.
// Blur resolves from the shared content-surface token.
// Tint opacity resolves from the shared content-surface token.
// The standard corner resolves from settingsGroupCornerRadius.
// The low container semantic color provides the readable tint source.
// The weak semantic outline remains clipped to the same surface shape.
// Global glass intensity still scales the complete material configuration.
// Global glass disablement falls back to a readable semantic solid surface.
// Local blur and opacity overrides affect only this group.
// Local color, border, radius, and specular overrides remain independent.
//
// Source compatibility
//
// MiuixSettingsGroup.source disables backdrop glass.
// It disables the HyperOS edge reflection.
// It retains the former low-container opaque fill.
// It retains the former theme-resolved settings-group corner radius.
// It retains the former weak half-pixel outline.
// It retains title and divider placement.
// Caller color, border, and radius overrides remain available.
//
// Rows and separators
//
// Child ordering remains exactly caller owned.
// Child interaction and semantics remain unchanged.
// Dividers remain optional and absent at the outer edges.
// Dividers remain inset from both horizontal edges.
// A divider is not promoted to another glass or surface layer.
// Group glass must not intercept a child's pointer gestures.
// Group glass must not create an extra actionable semantics node.
//
// Adaptive and accessibility behavior
//
// The group expands to the width offered by its parent.
// Text scaling remains owned by the child preference rows.
// Light and dark contrast resolve through semantic theme colors.
// Windows mouse, keyboard, and focus behavior remain child owned.
// Android system insets remain page-scaffold responsibilities.
// Reduced motion does not alter this static material hierarchy.
//
// Regression obligations
//
// Unit tests inspect standard token forwarding.
// Unit tests inspect caller override forwarding.
// Unit tests inspect the opaque source branch.
// Unit tests verify divider count and empty-group behavior.
// Light and dark goldens use a complex multicolor backdrop.
// Standard goldens must show backdrop variation through the group.
// Source goldens must remain opaque within the same outline.
// Full package analysis and tests gate every release cycle.
