// HyperOS 4 small-title implementation contract.
//
// The section label is a typography and spacing primitive rather than a card
// or overlay. Its migration must improve content hierarchy without inventing
// glass, shadow, or an extra container around every grouped-list heading.
//
// Evidence boundary:
// - Xiaomi publishes a content-first direction, not a SmallTitle metric table.
// - Standard dimensions and type values are project-calibrated defaults.
// - They must not be represented as private or official Xiaomi measurements.
// - Exact older values remain preserved and attributable through `.source`.
//
// Standard hierarchy:
// - The label organizes the following content group.
// - It remains visually below page titles and row primary labels.
// - It remains above descriptions, footnotes, and disabled secondary content.
// - Default foreground resolves from onSurfaceSecondary.
// - The label does not own a background, blur layer, border, or shadow.
// - Parent grouped surfaces remain the only material owners in that region.
//
// Standard project calibration:
// - Default horizontal padding is 20dp.
// - Default vertical padding is 10dp.
// - Default font size is 15sp.
// - Default weight is 600.
// - Default line-height multiplier is 1.2.
// - Letter spacing remains neutral unless the caller overrides it.
// - These values can evolve through explicit design calibration evidence.
//
// Public override precedence:
// - insideMargin replaces the baseline inset without changing text semantics.
// - textStyle merges over baseline size, height, weight, and font properties.
// - textColor overrides both the semantic default and textStyle.color.
// - Accessibility text scaling is applied before physical line-height rounding.
// - Long labels wrap naturally and grow beyond the one-line minimum.
// - RTL resolves directional insets without changing content order manually.
//
// Source compatibility:
// - MiuixSmallTitle.source retains 28dp horizontal padding.
// - It retains 8dp vertical padding.
// - It retains 14sp size and 700 weight.
// - It retains the former onBackgroundVariant semantic role.
// - It retains the source 1.16 line-height multiplier.
// - It retains physical-pixel rounding at fractional Android densities.
// - It retains natural wrapping and the complete semantic label.
//
// Accessibility and layout:
// - The complete text remains one readable semantic label.
// - Text scaling can increase both the minimum line box and wrapped height.
// - A fixed one-line box must never clip translated or accessible text.
// - Padding is outside the text placeable and remains separately measurable.
// - The widget introduces no tap role because a section heading is passive.
// - Callers requiring an action must provide a distinct accessible control.
//
// Verification requirements:
// - Tests inspect standard padding, type hierarchy, and semantic color.
// - Tests inspect override precedence for color, size, weight, and insets.
// - Existing source-density, RTL, wrapping, and semantics tests use `.source`.
// - Light and dark goldens compare standard and source group hierarchy.
// - The component manifest's six standard baselines track the new default.
// - Full static analysis, package tests, and release gates remain mandatory.
