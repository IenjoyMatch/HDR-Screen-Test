// HyperOS 4 slider preference migration contract.
//
// This documentation-only file records the boundary protected by tests while
// both public widgets share their production code in preference_selection.
//
// Standard constructors:
// - Both slider preference widgets use MiuixPreference.
// - The row inherits the project-calibrated HyperOS 4 hierarchy.
// - Titles use the standard 16sp / 500 preference role.
// - Summaries use the standard 13sp supporting role.
// - The title area inherits the 60dp single-line minimum row height.
// - Standard rows can live inside the shared HyperOS 4 settings-group glass.
//
// Explicit source constructors:
// - The `.source` factories set sourceStyle on the surrounding preference.
// - Source titles remain 17sp and source summaries remain 14sp.
// - Source title areas retain the 56dp minimum and source rounding.
// - Source settings groups remain available for direct MIUIX 1.0.9 ports.
//
// Shared slider mechanics:
// - The migration changes only the surrounding preference hierarchy.
// - Slider track, thumb, mask, key-point and pressed geometry stay shared.
// - Horizontal slider drags continue to own their horizontal gesture arena.
// - An outer PageView must not switch while either thumb is being dragged.
// - Values are normalized before they reach the embedded slider.
// - Callback values are normalized again before reaching application code.
// - Degenerate or reversed numeric ranges remain safe.
// - Range values remain ordered and clamped to the effective range.
// - RTL and reverse-direction mapping remain slider responsibilities.
// - Source `steps` continue to map to the matching Flutter division count.
// - Visible and magnetic key points use the same supplied values.
// - Magnet thresholds remain normalized fractions of the effective range.
//
// Feedback and completion:
// - Edge and step haptics remain controlled by MiuixSliderHapticEffect.
// - Haptic feedback must not be synthesized by the preference row itself.
// - Completion callbacks still fire after pointer interaction completes.
// - Row onTap remains independent from dragging the embedded slider.
// - Disabled rows disable both the row action and the embedded slider.
// - Held source press indication remains available through holdDownState.
//
// End-area composition:
// - valueText and end actions continue to share one compact end row.
// - A tappable preference retains calibrated source arrow geometry.
// - Optional leading and bottom actions are forwarded without rebuilding them.
// - A missing title is represented by showTitle=false, not a visible blank row.
//
// Regression obligations:
// - Unit tests assert 16/13 standard and 17/14 source text roles.
// - Unit tests assert ordinary/source routing on the nested preference.
// - Existing tests protect source actions, steps, key points and callbacks.
// - Component goldens cover interaction states of each preference type.
// - Dedicated light/dark goldens compare standard and source hierarchy.
// - Full-suite verification is required before producing release artifacts.
