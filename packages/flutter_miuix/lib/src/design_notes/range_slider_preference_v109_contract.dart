// Copyright 2026 flutter_miuix contributors.
//
// MIUIX 1.0.9 RangeSliderPreference source-parity contract.
//
// Authority
//
// Normative behavior comes from miuix-preference/SliderPreference.kt at the
// repository revision recorded by doc/parity.md.
// The example obligation comes from example/component/SliderSection.kt.
// The earlier Flutter convenience widget is not a layout authority.
//
// Public source surface
//
// The source adapter accepts value and required onValueChange.
// Title and summary are independently nullable.
// Title and summary each accept the full enabled/disabled color pair.
// startAction, endActions, and bottomAction remain arbitrary widget slots.
// valueText is optional and is never synthesized from the numeric range.
// onClick independently controls row activation and disclosure-arrow presence.
// holdDownState drives the same BasicComponent indication as the source.
// enabled disables both the row action and the embedded range slider.
// valueRange maps to min and max without changing the source callback model.
// Positive source steps map to one greater Flutter division count.
// onValueChangeFinished is forwarded without being used to commit values.
// sliderHeight and all eight slider color channels remain caller controlled.
// hapticEffect, showKeyPoints, keyPoints, and magnetThreshold are forwarded.
// insideMargin applies to the complete BasicComponent content.
//
// End area
//
// No end area is built when valueText, endActions, and onClick are all absent.
// When present, valueText uses the MIUIX body2 role and action foreground.
// Disabled value text uses disabledOnSecondaryVariant.
// Caller endActions follow valueText inside the same compact Row.
// That Row always reserves an 8dp trailing inset.
// A 10 x 16dp directional arrow follows only when onClick is non-null.
// RTL mirrors the arrow without reordering the logical content contract.
//
// Bottom area
//
// BasicComponent owns the source 8dp row-to-bottom-action spacing.
// Caller bottomAction, when supplied, is placed before the RangeSlider.
// The RangeSlider fills the available width and retains its authored height.
// Normalization clamps both values and restores start less than or equal to end.
// The callback reports normalized RangeValues through the caller-owned state.
//
// Example fixture
//
// The first three enabled rows use EdgeInsets.fromLTRB(16, 16, 16, 0).
// The disabled row uses BasicComponentDefaults.InsideMargin unchanged.
// Localized title and value strings remain separate left and right placeables.
// The four-row source surface is exactly 798 physical pixels at 420dpi.
// The Card's separate 12dp bottom modifier adds 32 physical pixels externally.
// The corresponding five-row Slider surface is exactly 987 physical pixels.
// Its external bottom modifier therefore produces a 1019px widget footprint.
//
// Runtime evidence
//
// Same-device Android Release captures use 1080 x 2400 at 420dpi.
// Range active-track x bounds match the native fixture at 246..833,
// 289..1005, and 246..833 for its three enabled rows.
// A real injected drag changed the first range from 20%-80% to 45%-80%.
// The root PageView remained on Home throughout that horizontal drag.
// A scalar edge drag emitted Android TOUCH/TICK haptic constant 23.
// Native and Flutter therefore exercise the same observable haptic category.
//
// Maintenance rule
//
// Do not restore the former fabricated two-decimal value label.
// Do not split the title row and slider into unrelated preference widgets.
// Do not replace the embedded source slider with Material RangeSlider.
// Recheck source, physical geometry, pager ownership, and haptics together.
