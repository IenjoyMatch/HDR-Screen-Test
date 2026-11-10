// HyperOS 4 preference-row contract.
//
// Evidence boundary
//
// Official first-party settings imagery establishes a compact content ladder.
// Xiaomi does not publish a complete Flutter preference metric table.
// The 16sp title, 13sp summary, and 60dp minimum are project calibrations.
// They must not be described as official Xiaomi developer measurements.
// MIUIX 1.0.9 source metrics remain available through explicit constructors.
//
// Standard row hierarchy
//
// MiuixPreference uses a 16sp medium-weight primary label.
// Its optional summary uses a 13sp regular supporting role.
// The title uses a 1.20 calibrated line-height multiplier.
// The summary uses a 1.25 calibrated line-height multiplier.
// A title-only row reserves at least 60 logical pixels.
// Multiline and scaled content may grow without clipping.
// Caller title and summary styles merge over these defaults.
// Explicit caller colors remain authoritative.
// Enabled colors resolve from semantic surface roles.
// Disabled colors continue to use the disabled semantic role.
// Standard slot text follows the 16sp content role.
// Standard leading icons use a calibrated 22dp optical size.
//
// Source compatibility
//
// MiuixPreference.source retains the 17sp medium source title.
// It retains the 14sp source summary.
// It retains the 1.17 source line-box multiplier.
// It retains the 56dp source minimum row height.
// It retains 24dp source leading-icon geometry.
// It retains physical-pixel height rounding at fractional Android densities.
// MiuixPreference.source is preferred over the forwarding sourceStyle flag.
//
// Composite routing
//
// MiuixBasicComponent uses the standard hierarchy by default.
// MiuixBasicComponent.source and sourceText use source metrics.
// MiuixArrowPreference.source forwards source metrics.
// MiuixSwitchPreference.source forwards source metrics.
// MiuixCheckboxPreference.source forwards source metrics.
// MiuixRadioButtonPreference.source forwards source metrics.
// Source-mode dropdown and spinner rows forward source metrics.
// Ordinary versions of those composites use the standard hierarchy.
// Application-list source cards retain source preference typography.
//
// Interaction and accessibility
//
// Row actions, hold-down indication, and enabled state remain unchanged.
// Embedded toggles continue to own their semantic haptic roles.
// A row tap must not duplicate a nested switch or checkbox haptic.
// Checkbox, radio, switch, and dropdown semantic roles remain unchanged.
// Text scaling may increase row height and must not clip summary content.
// Keyboard focus and Windows pointer behavior remain child owned.
// RTL changes slot order and arrow direction, not font hierarchy.
//
// Regression obligations
//
// Unit tests compare standard and source direct-row geometry.
// Unit tests compare standard and source title and summary metrics.
// Unit tests cover BasicComponent and common preference wrappers.
// Existing source physical-pixel tests must remain exact.
// Existing haptic and semantic tests must remain exact.
// Light and dark goldens cover the complete standard row family.
// Light and dark goldens cover the complete source row family.
// Full component goldens must be updated only for intentional default changes.
// Full package analysis and tests gate every release cycle.
