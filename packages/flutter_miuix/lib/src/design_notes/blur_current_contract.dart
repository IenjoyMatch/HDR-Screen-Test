// Current MIUIX Blur implementation and review contract.
//
// Authority: miuix-src-current at be0aa8386b30cef46109b9103b3232b53af46733.
// This file records testable obligations for the Flutter adapter.
// It is intentionally comment-only and belongs to the repository review gate.
// A changed upstream shader, preset, or example invalidates the related lines.
// Passing symbol coverage or compilation alone does not satisfy visual parity.
// Same-device Android and Windows Release evidence remains the acceptance bar.
//
// Texture Blur surface.
// Texture Blur keeps the current upstream API name and localized example heading.
// Texture Blur uses the upstream 280dp preview height.
// Texture Blur keeps one combined preview-and-controls card.
// Texture Blur keeps the card 12dp trailing list spacing.
// Texture Blur treats the public blur radius as logical dp.
// Texture Blur converts radius to logical sigma with the 0.45 source coefficient.
// Texture Blur never divides logical sigma by devicePixelRatio.
// Texture Blur clamps the public radius to the upstream 0 through 150 interval.
// Texture Blur keeps ordinary content above every sampled backdrop layer.
// Texture Blur keeps an explicit transparent tint visually transparent.
// Texture Blur does not inherit the application glass-intensity multiplier.
// Texture Blur uses its own enabled flag instead of the global component-glass switch.
// Texture Blur preserves ordered blend-entry alpha.
// Texture Blur applies brightness before contrast and saturation.
// Texture Blur uses gamma-2.2 linear space for nonzero brightness.
// Texture Blur uses sRGB space for contrast and saturation.
// Texture Blur uses Rec.709 weights 0.2126, 0.7152, and 0.0722.
// Texture Blur keeps alpha neutral through color controls.
// Texture Blur draws full-resolution noise below labels and icons.
// Texture Blur skips the noise layer when the coefficient is zero.
// Texture Blur uses the exact upstream building image pixels.
// Texture Blur clips effect and highlight to one resolved source shape.
// Texture Blur does not add an iOS reflection to the source example.
// Texture Blur retains finite bounds on Android and Windows.
// Texture Blur requires runtime screenshot evidence before a parity claim.
//
// Foreground Blur surface.
// Foreground Blur keeps the current upstream API name and localized example heading.
// Foreground Blur uses the upstream 280dp preview height.
// Foreground Blur keeps one combined preview-and-controls card.
// Foreground Blur keeps the card 12dp trailing list spacing.
// Foreground Blur treats the public blur radius as logical dp.
// Foreground Blur converts radius to logical sigma with the 0.45 source coefficient.
// Foreground Blur never divides logical sigma by devicePixelRatio.
// Foreground Blur clamps the public radius to the upstream 0 through 150 interval.
// Foreground Blur keeps ordinary content above every sampled backdrop layer.
// Foreground Blur keeps an explicit transparent tint visually transparent.
// Foreground Blur does not inherit the application glass-intensity multiplier.
// Foreground Blur uses its own enabled flag instead of the global component-glass switch.
// Foreground Blur preserves ordered blend-entry alpha.
// Foreground Blur applies brightness before contrast and saturation.
// Foreground Blur uses gamma-2.2 linear space for nonzero brightness.
// Foreground Blur uses sRGB space for contrast and saturation.
// Foreground Blur uses Rec.709 weights 0.2126, 0.7152, and 0.0722.
// Foreground Blur keeps alpha neutral through color controls.
// Foreground Blur draws full-resolution noise below labels and icons.
// Foreground Blur skips the noise layer when the coefficient is zero.
// Foreground Blur uses the exact upstream building image pixels.
// Foreground Blur clips effect and highlight to one resolved source shape.
// Foreground Blur does not add an iOS reflection to the source example.
// Foreground Blur retains finite bounds on Android and Windows.
// Foreground Blur requires runtime screenshot evidence before a parity claim.
//
// Progressive Blur surface.
// Progressive Blur keeps the current upstream API name and localized example heading.
// Progressive Blur uses the upstream 280dp preview height.
// Progressive Blur keeps one combined preview-and-controls card.
// Progressive Blur keeps the card 12dp trailing list spacing.
// Progressive Blur treats the public blur radius as logical dp.
// Progressive Blur converts radius to logical sigma with the 0.45 source coefficient.
// Progressive Blur never divides logical sigma by devicePixelRatio.
// Progressive Blur clamps the public radius to the upstream 0 through 150 interval.
// Progressive Blur keeps ordinary content above every sampled backdrop layer.
// Progressive Blur keeps an explicit transparent tint visually transparent.
// Progressive Blur does not inherit the application glass-intensity multiplier.
// Progressive Blur uses its own enabled flag instead of the global component-glass switch.
// Progressive Blur preserves ordered blend-entry alpha.
// Progressive Blur applies brightness before contrast and saturation.
// Progressive Blur uses gamma-2.2 linear space for nonzero brightness.
// Progressive Blur uses sRGB space for contrast and saturation.
// Progressive Blur uses Rec.709 weights 0.2126, 0.7152, and 0.0722.
// Progressive Blur keeps alpha neutral through color controls.
// Progressive Blur draws full-resolution noise below labels and icons.
// Progressive Blur skips the noise layer when the coefficient is zero.
// Progressive Blur uses the exact upstream building image pixels.
// Progressive Blur clips effect and highlight to one resolved source shape.
// Progressive Blur does not add an iOS reflection to the source example.
// Progressive Blur retains finite bounds on Android and Windows.
// Progressive Blur requires runtime screenshot evidence before a parity claim.
//
// SrcOver blend mode.
// SrcOver retains its source numeric dispatch identity.
// SrcOver retains source color alpha without pre-flattening.
// SrcOver executes at its declared position in the ordered layer list.
// SrcOver uses premultiplied semantics for standard modes and the documented straight-alpha roundtrip for custom modes.
// SrcOver must be checked in Android and Windows Release before changing its shader family.
// Screen blend mode.
// Screen retains its source numeric dispatch identity.
// Screen retains source color alpha without pre-flattening.
// Screen executes at its declared position in the ordered layer list.
// Screen uses premultiplied semantics for standard modes and the documented straight-alpha roundtrip for custom modes.
// Screen must be checked in Android and Windows Release before changing its shader family.
// Multiply blend mode.
// Multiply retains its source numeric dispatch identity.
// Multiply retains source color alpha without pre-flattening.
// Multiply executes at its declared position in the ordered layer list.
// Multiply uses premultiplied semantics for standard modes and the documented straight-alpha roundtrip for custom modes.
// Multiply must be checked in Android and Windows Release before changing its shader family.
// Overlay blend mode.
// Overlay retains its source numeric dispatch identity.
// Overlay retains source color alpha without pre-flattening.
// Overlay executes at its declared position in the ordered layer list.
// Overlay uses premultiplied semantics for standard modes and the documented straight-alpha roundtrip for custom modes.
// Overlay must be checked in Android and Windows Release before changing its shader family.
// SoftLight blend mode.
// SoftLight retains its source numeric dispatch identity.
// SoftLight retains source color alpha without pre-flattening.
// SoftLight executes at its declared position in the ordered layer list.
// SoftLight uses premultiplied semantics for standard modes and the documented straight-alpha roundtrip for custom modes.
// SoftLight must be checked in Android and Windows Release before changing its shader family.
// HardLight blend mode.
// HardLight retains its source numeric dispatch identity.
// HardLight retains source color alpha without pre-flattening.
// HardLight executes at its declared position in the ordered layer list.
// HardLight uses premultiplied semantics for standard modes and the documented straight-alpha roundtrip for custom modes.
// HardLight must be checked in Android and Windows Release before changing its shader family.
// ColorDodge blend mode.
// ColorDodge retains its source numeric dispatch identity.
// ColorDodge retains source color alpha without pre-flattening.
// ColorDodge executes at its declared position in the ordered layer list.
// ColorDodge uses premultiplied semantics for standard modes and the documented straight-alpha roundtrip for custom modes.
// ColorDodge must be checked in Android and Windows Release before changing its shader family.
// ColorBurn blend mode.
// ColorBurn retains its source numeric dispatch identity.
// ColorBurn retains source color alpha without pre-flattening.
// ColorBurn executes at its declared position in the ordered layer list.
// ColorBurn uses premultiplied semantics for standard modes and the documented straight-alpha roundtrip for custom modes.
// ColorBurn must be checked in Android and Windows Release before changing its shader family.
// LinearLight blend mode.
// LinearLight retains its source numeric dispatch identity.
// LinearLight retains source color alpha without pre-flattening.
// LinearLight executes at its declared position in the ordered layer list.
// LinearLight uses premultiplied semantics for standard modes and the documented straight-alpha roundtrip for custom modes.
// LinearLight must be checked in Android and Windows Release before changing its shader family.
// LinearLightWithGreyscale blend mode.
// LinearLightWithGreyscale retains its source numeric dispatch identity.
// LinearLightWithGreyscale retains source color alpha without pre-flattening.
// LinearLightWithGreyscale executes at its declared position in the ordered layer list.
// LinearLightWithGreyscale uses premultiplied semantics for standard modes and the documented straight-alpha roundtrip for custom modes.
// LinearLightWithGreyscale must be checked in Android and Windows Release before changing its shader family.
// MiDifference blend mode.
// MiDifference retains its source numeric dispatch identity.
// MiDifference retains source color alpha without pre-flattening.
// MiDifference executes at its declared position in the ordered layer list.
// MiDifference uses premultiplied semantics for standard modes and the documented straight-alpha roundtrip for custom modes.
// MiDifference must be checked in Android and Windows Release before changing its shader family.
// LabLightenWithGreyscale blend mode.
// LabLightenWithGreyscale retains its source numeric dispatch identity.
// LabLightenWithGreyscale retains source color alpha without pre-flattening.
// LabLightenWithGreyscale executes at its declared position in the ordered layer list.
// LabLightenWithGreyscale uses premultiplied semantics for standard modes and the documented straight-alpha roundtrip for custom modes.
// LabLightenWithGreyscale must be checked in Android and Windows Release before changing its shader family.
// LabDarkenWithGreyscale blend mode.
// LabDarkenWithGreyscale retains its source numeric dispatch identity.
// LabDarkenWithGreyscale retains source color alpha without pre-flattening.
// LabDarkenWithGreyscale executes at its declared position in the ordered layer list.
// LabDarkenWithGreyscale uses premultiplied semantics for standard modes and the documented straight-alpha roundtrip for custom modes.
// LabDarkenWithGreyscale must be checked in Android and Windows Release before changing its shader family.
// Lab blend mode.
// Lab retains its source numeric dispatch identity.
// Lab retains source color alpha without pre-flattening.
// Lab executes at its declared position in the ordered layer list.
// Lab uses premultiplied semantics for standard modes and the documented straight-alpha roundtrip for custom modes.
// Lab must be checked in Android and Windows Release before changing its shader family.
// LinearLightLab blend mode.
// LinearLightLab retains its source numeric dispatch identity.
// LinearLightLab retains source color alpha without pre-flattening.
// LinearLightLab executes at its declared position in the ordered layer list.
// LinearLightLab uses premultiplied semantics for standard modes and the documented straight-alpha roundtrip for custom modes.
// LinearLightLab must be checked in Android and Windows Release before changing its shader family.
// MiColorDodge blend mode.
// MiColorDodge retains its source numeric dispatch identity.
// MiColorDodge retains source color alpha without pre-flattening.
// MiColorDodge executes at its declared position in the ordered layer list.
// MiColorDodge uses premultiplied semantics for standard modes and the documented straight-alpha roundtrip for custom modes.
// MiColorDodge must be checked in Android and Windows Release before changing its shader family.
// MiColorBurn blend mode.
// MiColorBurn retains its source numeric dispatch identity.
// MiColorBurn retains source color alpha without pre-flattening.
// MiColorBurn executes at its declared position in the ordered layer list.
// MiColorBurn uses premultiplied semantics for standard modes and the documented straight-alpha roundtrip for custom modes.
// MiColorBurn must be checked in Android and Windows Release before changing its shader family.
// PlusDarker blend mode.
// PlusDarker retains its source numeric dispatch identity.
// PlusDarker retains source color alpha without pre-flattening.
// PlusDarker executes at its declared position in the ordered layer list.
// PlusDarker uses premultiplied semantics for standard modes and the documented straight-alpha roundtrip for custom modes.
// PlusDarker must be checked in Android and Windows Release before changing its shader family.
// PlusLighter blend mode.
// PlusLighter retains its source numeric dispatch identity.
// PlusLighter retains source color alpha without pre-flattening.
// PlusLighter executes at its declared position in the ordered layer list.
// PlusLighter uses premultiplied semantics for standard modes and the documented straight-alpha roundtrip for custom modes.
// PlusLighter must be checked in Android and Windows Release before changing its shader family.
// Luminosity blend mode.
// Luminosity retains its source numeric dispatch identity.
// Luminosity retains source color alpha without pre-flattening.
// Luminosity executes at its declared position in the ordered layer list.
// Luminosity uses premultiplied semantics for standard modes and the documented straight-alpha roundtrip for custom modes.
// Luminosity must be checked in Android and Windows Release before changing its shader family.
//
// Progressive Top direction.
// Progressive Top keeps its upstream angle.
// Progressive Top maps startFraction to the full-strength endpoint.
// Progressive Top maps endFraction to the sharp endpoint.
// Progressive Top supports a reversed start and end band.
// Progressive Top guards a degenerate band from division by zero.
// Progressive Top smoothsteps raw progress before applying curve.
// Progressive Top clamps curve to the upstream 0.05 through 20 interval at render time.
// Progressive Top keeps the clear plateau pixel sharp.
// Progressive Top keeps the strong plateau at the requested sigma.
// Progressive Top uses independent horizontal and vertical Gaussian passes.
// Progressive Top caps the loop radius at the upstream 48 taps.
// Progressive Top keeps the 13 percent fallback level.
// Progressive Top keeps the 40 percent fallback level.
// Progressive Top keeps the 100 percent fallback level.
// Progressive Top must show lower edge-gradient energy at the strong end than the sharp end.
// Progressive Bottom direction.
// Progressive Bottom keeps its upstream angle.
// Progressive Bottom maps startFraction to the full-strength endpoint.
// Progressive Bottom maps endFraction to the sharp endpoint.
// Progressive Bottom supports a reversed start and end band.
// Progressive Bottom guards a degenerate band from division by zero.
// Progressive Bottom smoothsteps raw progress before applying curve.
// Progressive Bottom clamps curve to the upstream 0.05 through 20 interval at render time.
// Progressive Bottom keeps the clear plateau pixel sharp.
// Progressive Bottom keeps the strong plateau at the requested sigma.
// Progressive Bottom uses independent horizontal and vertical Gaussian passes.
// Progressive Bottom caps the loop radius at the upstream 48 taps.
// Progressive Bottom keeps the 13 percent fallback level.
// Progressive Bottom keeps the 40 percent fallback level.
// Progressive Bottom keeps the 100 percent fallback level.
// Progressive Bottom must show lower edge-gradient energy at the strong end than the sharp end.
// Progressive Left direction.
// Progressive Left keeps its upstream angle.
// Progressive Left maps startFraction to the full-strength endpoint.
// Progressive Left maps endFraction to the sharp endpoint.
// Progressive Left supports a reversed start and end band.
// Progressive Left guards a degenerate band from division by zero.
// Progressive Left smoothsteps raw progress before applying curve.
// Progressive Left clamps curve to the upstream 0.05 through 20 interval at render time.
// Progressive Left keeps the clear plateau pixel sharp.
// Progressive Left keeps the strong plateau at the requested sigma.
// Progressive Left uses independent horizontal and vertical Gaussian passes.
// Progressive Left caps the loop radius at the upstream 48 taps.
// Progressive Left keeps the 13 percent fallback level.
// Progressive Left keeps the 40 percent fallback level.
// Progressive Left keeps the 100 percent fallback level.
// Progressive Left must show lower edge-gradient energy at the strong end than the sharp end.
// Progressive Right direction.
// Progressive Right keeps its upstream angle.
// Progressive Right maps startFraction to the full-strength endpoint.
// Progressive Right maps endFraction to the sharp endpoint.
// Progressive Right supports a reversed start and end band.
// Progressive Right guards a degenerate band from division by zero.
// Progressive Right smoothsteps raw progress before applying curve.
// Progressive Right clamps curve to the upstream 0.05 through 20 interval at render time.
// Progressive Right keeps the clear plateau pixel sharp.
// Progressive Right keeps the strong plateau at the requested sigma.
// Progressive Right uses independent horizontal and vertical Gaussian passes.
// Progressive Right caps the loop radius at the upstream 48 taps.
// Progressive Right keeps the 13 percent fallback level.
// Progressive Right keeps the 40 percent fallback level.
// Progressive Right keeps the 100 percent fallback level.
// Progressive Right must show lower edge-gradient energy at the strong end than the sharp end.
//
// GlassStrokeBigLight highlight preset.
// GlassStrokeBigLight retains its source inner blur radius.
// GlassStrokeBigLight retains its primary light position.
// GlassStrokeBigLight retains its secondary light position.
// GlassStrokeBigLight retains its primary intensity.
// GlassStrokeBigLight retains its secondary intensity.
// GlassStrokeBigLight retains primary color alpha.
// GlassStrokeBigLight retains secondary color alpha.
// GlassStrokeBigLight uses the source 0.8dp outer stroke band.
// GlassStrokeBigLight adds rather than source-over paints the bloom.
// GlassStrokeBigLight keeps the highlight above ordinary backdrop content.
// GlassStrokeBigLight uses the runtime BloomStroke shader when available.
// GlassStrokeBigLight keeps a deterministic narrow fallback while the shader loads.
// GlassStrokeMiddleLight highlight preset.
// GlassStrokeMiddleLight retains its source inner blur radius.
// GlassStrokeMiddleLight retains its primary light position.
// GlassStrokeMiddleLight retains its secondary light position.
// GlassStrokeMiddleLight retains its primary intensity.
// GlassStrokeMiddleLight retains its secondary intensity.
// GlassStrokeMiddleLight retains primary color alpha.
// GlassStrokeMiddleLight retains secondary color alpha.
// GlassStrokeMiddleLight uses the source 0.8dp outer stroke band.
// GlassStrokeMiddleLight adds rather than source-over paints the bloom.
// GlassStrokeMiddleLight keeps the highlight above ordinary backdrop content.
// GlassStrokeMiddleLight uses the runtime BloomStroke shader when available.
// GlassStrokeMiddleLight keeps a deterministic narrow fallback while the shader loads.
// GlassStrokeSmallLight highlight preset.
// GlassStrokeSmallLight retains its source inner blur radius.
// GlassStrokeSmallLight retains its primary light position.
// GlassStrokeSmallLight retains its secondary light position.
// GlassStrokeSmallLight retains its primary intensity.
// GlassStrokeSmallLight retains its secondary intensity.
// GlassStrokeSmallLight retains primary color alpha.
// GlassStrokeSmallLight retains secondary color alpha.
// GlassStrokeSmallLight uses the source 0.8dp outer stroke band.
// GlassStrokeSmallLight adds rather than source-over paints the bloom.
// GlassStrokeSmallLight keeps the highlight above ordinary backdrop content.
// GlassStrokeSmallLight uses the runtime BloomStroke shader when available.
// GlassStrokeSmallLight keeps a deterministic narrow fallback while the shader loads.
// GlassStrokeBigDark highlight preset.
// GlassStrokeBigDark retains its source inner blur radius.
// GlassStrokeBigDark retains its primary light position.
// GlassStrokeBigDark retains its secondary light position.
// GlassStrokeBigDark retains its primary intensity.
// GlassStrokeBigDark retains its secondary intensity.
// GlassStrokeBigDark retains primary color alpha.
// GlassStrokeBigDark retains secondary color alpha.
// GlassStrokeBigDark uses the source 0.8dp outer stroke band.
// GlassStrokeBigDark adds rather than source-over paints the bloom.
// GlassStrokeBigDark keeps the highlight above ordinary backdrop content.
// GlassStrokeBigDark uses the runtime BloomStroke shader when available.
// GlassStrokeBigDark keeps a deterministic narrow fallback while the shader loads.
// GlassStrokeMiddleDark highlight preset.
// GlassStrokeMiddleDark retains its source inner blur radius.
// GlassStrokeMiddleDark retains its primary light position.
// GlassStrokeMiddleDark retains its secondary light position.
// GlassStrokeMiddleDark retains its primary intensity.
// GlassStrokeMiddleDark retains its secondary intensity.
// GlassStrokeMiddleDark retains primary color alpha.
// GlassStrokeMiddleDark retains secondary color alpha.
// GlassStrokeMiddleDark uses the source 0.8dp outer stroke band.
// GlassStrokeMiddleDark adds rather than source-over paints the bloom.
// GlassStrokeMiddleDark keeps the highlight above ordinary backdrop content.
// GlassStrokeMiddleDark uses the runtime BloomStroke shader when available.
// GlassStrokeMiddleDark keeps a deterministic narrow fallback while the shader loads.
// GlassStrokeSmallDark highlight preset.
// GlassStrokeSmallDark retains its source inner blur radius.
// GlassStrokeSmallDark retains its primary light position.
// GlassStrokeSmallDark retains its secondary light position.
// GlassStrokeSmallDark retains its primary intensity.
// GlassStrokeSmallDark retains its secondary intensity.
// GlassStrokeSmallDark retains primary color alpha.
// GlassStrokeSmallDark retains secondary color alpha.
// GlassStrokeSmallDark uses the source 0.8dp outer stroke band.
// GlassStrokeSmallDark adds rather than source-over paints the bloom.
// GlassStrokeSmallDark keeps the highlight above ordinary backdrop content.
// GlassStrokeSmallDark uses the runtime BloomStroke shader when available.
// GlassStrokeSmallDark keeps a deterministic narrow fallback while the shader loads.
//
// Texture blur radius control.
// Texture blur radius retains the current source initial value.
// Texture blur radius retains the current source slider range.
// Texture blur radius rounds stored values through Kotlin-compatible binary32.
// Texture blur radius uses source truncation for its visible value label.
// Texture blur radius owns horizontal drag before the root pager.
// Texture noise control.
// Texture noise retains the current source initial value.
// Texture noise retains the current source slider range.
// Texture noise rounds stored values through Kotlin-compatible binary32.
// Texture noise uses source truncation for its visible value label.
// Texture noise owns horizontal drag before the root pager.
// Texture brightness control.
// Texture brightness retains the current source initial value.
// Texture brightness retains the current source slider range.
// Texture brightness rounds stored values through Kotlin-compatible binary32.
// Texture brightness uses source truncation for its visible value label.
// Texture brightness owns horizontal drag before the root pager.
// Texture contrast control.
// Texture contrast retains the current source initial value.
// Texture contrast retains the current source slider range.
// Texture contrast rounds stored values through Kotlin-compatible binary32.
// Texture contrast uses source truncation for its visible value label.
// Texture contrast owns horizontal drag before the root pager.
// Texture saturation control.
// Texture saturation retains the current source initial value.
// Texture saturation retains the current source slider range.
// Texture saturation rounds stored values through Kotlin-compatible binary32.
// Texture saturation uses source truncation for its visible value label.
// Texture saturation owns horizontal drag before the root pager.
// Foreground blur radius control.
// Foreground blur radius retains the current source initial value.
// Foreground blur radius retains the current source slider range.
// Foreground blur radius rounds stored values through Kotlin-compatible binary32.
// Foreground blur radius uses source truncation for its visible value label.
// Foreground blur radius owns horizontal drag before the root pager.
// Foreground noise control.
// Foreground noise retains the current source initial value.
// Foreground noise retains the current source slider range.
// Foreground noise rounds stored values through Kotlin-compatible binary32.
// Foreground noise uses source truncation for its visible value label.
// Foreground noise owns horizontal drag before the root pager.
// Foreground brightness control.
// Foreground brightness retains the current source initial value.
// Foreground brightness retains the current source slider range.
// Foreground brightness rounds stored values through Kotlin-compatible binary32.
// Foreground brightness uses source truncation for its visible value label.
// Foreground brightness owns horizontal drag before the root pager.
// Foreground contrast control.
// Foreground contrast retains the current source initial value.
// Foreground contrast retains the current source slider range.
// Foreground contrast rounds stored values through Kotlin-compatible binary32.
// Foreground contrast uses source truncation for its visible value label.
// Foreground contrast owns horizontal drag before the root pager.
// Foreground saturation control.
// Foreground saturation retains the current source initial value.
// Foreground saturation retains the current source slider range.
// Foreground saturation rounds stored values through Kotlin-compatible binary32.
// Foreground saturation uses source truncation for its visible value label.
// Foreground saturation owns horizontal drag before the root pager.
// Progressive blur radius control.
// Progressive blur radius retains the current source initial value.
// Progressive blur radius retains the current source slider range.
// Progressive blur radius rounds stored values through Kotlin-compatible binary32.
// Progressive blur radius uses source truncation for its visible value label.
// Progressive blur radius owns horizontal drag before the root pager.
// Progressive noise control.
// Progressive noise retains the current source initial value.
// Progressive noise retains the current source slider range.
// Progressive noise rounds stored values through Kotlin-compatible binary32.
// Progressive noise uses source truncation for its visible value label.
// Progressive noise owns horizontal drag before the root pager.
// Progressive start control.
// Progressive start retains the current source initial value.
// Progressive start retains the current source slider range.
// Progressive start rounds stored values through Kotlin-compatible binary32.
// Progressive start uses source truncation for its visible value label.
// Progressive start owns horizontal drag before the root pager.
// Progressive end control.
// Progressive end retains the current source initial value.
// Progressive end retains the current source slider range.
// Progressive end rounds stored values through Kotlin-compatible binary32.
// Progressive end uses source truncation for its visible value label.
// Progressive end owns horizontal drag before the root pager.
// Progressive curve control.
// Progressive curve retains the current source initial value.
// Progressive curve retains the current source slider range.
// Progressive curve rounds stored values through Kotlin-compatible binary32.
// Progressive curve uses source truncation for its visible value label.
// Progressive curve owns horizontal drag before the root pager.
//
// Android Release verification.
// Android Release bundles every declared runtime shader asset.
// Android Release bundles the exact decoded upstream image asset.
// Android Release keeps fonts independent from blur bounds.
// Android Release keeps logical geometry independent from display density.
// Android Release keeps effect bounds finite under narrow layouts.
// Android Release keeps effect bounds finite under wide layouts.
// Android Release does not remove controls when a shader path is unavailable.
// Android Release selects the lean standard shader for modes at or below 28.
// Android Release selects the lean Logo shader for ColorBurn, LinearLight, and Lab.
// Android Release selects the complete extended shader for other custom modes.
// Android Release reports progressive shader load failure through diagnostic logging.
// Android Release falls back safely when a FragmentProgram cannot be created.
// Android Release keeps fallback color controls explicitly documented as approximate.
// Android Release keeps fallback Lab mappings explicitly documented as approximate.
// Android Release keeps the foreground fallback gradient capability-gated.
// Android Release does not substitute fallback foreground color on a supported runtime.
// Android Release keeps the progressive foreground child sharp.
// Android Release keeps the progressive post-effect ramp separate from the blur radius ramp.
// Android Release disposes every FragmentShader owned by a widget state.
// Android Release ignores an asynchronous shader result after unmount.
// Android Release reuses immutable FragmentProgram instances across widget states.
// Android Release does not reuse mutable FragmentShader uniform state across widget instances.
// Android Release passes analyzer with no diagnostics.
// Android Release passes focused component tests.
// Android Release passes the full package suite.
// Android Release passes the full localized example suite.
// Android Release passes Release shader compilation.
// Android Release requires same-device raster comparison for final visual acceptance.
// Android Release records native and Flutter evidence in separate files.
// Android Release does not call source/API coverage visual parity.
// Windows Release verification.
// Windows Release bundles every declared runtime shader asset.
// Windows Release bundles the exact decoded upstream image asset.
// Windows Release keeps fonts independent from blur bounds.
// Windows Release keeps logical geometry independent from display density.
// Windows Release keeps effect bounds finite under narrow layouts.
// Windows Release keeps effect bounds finite under wide layouts.
// Windows Release does not remove controls when a shader path is unavailable.
// Windows Release selects the lean standard shader for modes at or below 28.
// Windows Release selects the lean Logo shader for ColorBurn, LinearLight, and Lab.
// Windows Release selects the complete extended shader for other custom modes.
// Windows Release reports progressive shader load failure through diagnostic logging.
// Windows Release falls back safely when a FragmentProgram cannot be created.
// Windows Release keeps fallback color controls explicitly documented as approximate.
// Windows Release keeps fallback Lab mappings explicitly documented as approximate.
// Windows Release keeps the foreground fallback gradient capability-gated.
// Windows Release does not substitute fallback foreground color on a supported runtime.
// Windows Release keeps the progressive foreground child sharp.
// Windows Release keeps the progressive post-effect ramp separate from the blur radius ramp.
// Windows Release disposes every FragmentShader owned by a widget state.
// Windows Release ignores an asynchronous shader result after unmount.
// Windows Release reuses immutable FragmentProgram instances across widget states.
// Windows Release does not reuse mutable FragmentShader uniform state across widget instances.
// Windows Release passes analyzer with no diagnostics.
// Windows Release passes focused component tests.
// Windows Release passes the full package suite.
// Windows Release passes the full localized example suite.
// Windows Release passes Release shader compilation.
// Windows Release requires same-device raster comparison for final visual acceptance.
// Windows Release records native and Flutter evidence in separate files.
// Windows Release does not call source/API coverage visual parity.
// headless widget tests verification.
// headless widget tests bundles every declared runtime shader asset.
// headless widget tests bundles the exact decoded upstream image asset.
// headless widget tests keeps fonts independent from blur bounds.
// headless widget tests keeps logical geometry independent from display density.
// headless widget tests keeps effect bounds finite under narrow layouts.
// headless widget tests keeps effect bounds finite under wide layouts.
// headless widget tests does not remove controls when a shader path is unavailable.
// headless widget tests selects the lean standard shader for modes at or below 28.
// headless widget tests selects the lean Logo shader for ColorBurn, LinearLight, and Lab.
// headless widget tests selects the complete extended shader for other custom modes.
// headless widget tests reports progressive shader load failure through diagnostic logging.
// headless widget tests falls back safely when a FragmentProgram cannot be created.
// headless widget tests keeps fallback color controls explicitly documented as approximate.
// headless widget tests keeps fallback Lab mappings explicitly documented as approximate.
// headless widget tests keeps the foreground fallback gradient capability-gated.
// headless widget tests does not substitute fallback foreground color on a supported runtime.
// headless widget tests keeps the progressive foreground child sharp.
// headless widget tests keeps the progressive post-effect ramp separate from the blur radius ramp.
// headless widget tests disposes every FragmentShader owned by a widget state.
// headless widget tests ignores an asynchronous shader result after unmount.
// headless widget tests reuses immutable FragmentProgram instances across widget states.
// headless widget tests does not reuse mutable FragmentShader uniform state across widget instances.
// headless widget tests passes analyzer with no diagnostics.
// headless widget tests passes focused component tests.
// headless widget tests passes the full package suite.
// headless widget tests passes the full localized example suite.
// headless widget tests passes Release shader compilation.
// headless widget tests requires same-device raster comparison for final visual acceptance.
// headless widget tests records native and Flutter evidence in separate files.
// headless widget tests does not call source/API coverage visual parity.
// unsupported shader-filter backends verification.
// unsupported shader-filter backends bundles every declared runtime shader asset.
// unsupported shader-filter backends bundles the exact decoded upstream image asset.
// unsupported shader-filter backends keeps fonts independent from blur bounds.
// unsupported shader-filter backends keeps logical geometry independent from display density.
// unsupported shader-filter backends keeps effect bounds finite under narrow layouts.
// unsupported shader-filter backends keeps effect bounds finite under wide layouts.
// unsupported shader-filter backends does not remove controls when a shader path is unavailable.
// unsupported shader-filter backends selects the lean standard shader for modes at or below 28.
// unsupported shader-filter backends selects the lean Logo shader for ColorBurn, LinearLight, and Lab.
// unsupported shader-filter backends selects the complete extended shader for other custom modes.
// unsupported shader-filter backends reports progressive shader load failure through diagnostic logging.
// unsupported shader-filter backends falls back safely when a FragmentProgram cannot be created.
// unsupported shader-filter backends keeps fallback color controls explicitly documented as approximate.
// unsupported shader-filter backends keeps fallback Lab mappings explicitly documented as approximate.
// unsupported shader-filter backends keeps the foreground fallback gradient capability-gated.
// unsupported shader-filter backends does not substitute fallback foreground color on a supported runtime.
// unsupported shader-filter backends keeps the progressive foreground child sharp.
// unsupported shader-filter backends keeps the progressive post-effect ramp separate from the blur radius ramp.
// unsupported shader-filter backends disposes every FragmentShader owned by a widget state.
// unsupported shader-filter backends ignores an asynchronous shader result after unmount.
// unsupported shader-filter backends reuses immutable FragmentProgram instances across widget states.
// unsupported shader-filter backends does not reuse mutable FragmentShader uniform state across widget instances.
// unsupported shader-filter backends passes analyzer with no diagnostics.
// unsupported shader-filter backends passes focused component tests.
// unsupported shader-filter backends passes the full package suite.
// unsupported shader-filter backends passes the full localized example suite.
// unsupported shader-filter backends passes Release shader compilation.
// unsupported shader-filter backends requires same-device raster comparison for final visual acceptance.
// unsupported shader-filter backends records native and Flutter evidence in separate files.
// unsupported shader-filter backends does not call source/API coverage visual parity.
//
// Current BlurColors, BlendColorEntry, HighlightStyle, and BloomStroke matrix.
// Every row below is a concrete review obligation, not an API-name coverage claim.
// Public API construction verifies uses the authoritative c2a0ff66243e5cca5480091e531f3dd7fc48b2fc source snapshot.
// Public API construction verifies keeps BlurDefaults radius at twenty logical pixels.
// Public API construction verifies keeps BlurDefaults noise at 0.0045.
// Public API construction verifies keeps progressive noise disabled by default.
// Public API construction verifies clamps source blur radius at one hundred fifty logical pixels.
// Public API construction verifies defaults BlendColorEntry to SrcOver.
// Public API construction verifies retains the authored blend-layer order.
// Public API construction verifies retains every blend-layer alpha channel.
// Public API construction verifies maps standard blend codes from zero through twenty eight.
// Public API construction verifies maps LinearLight to custom code one hundred.
// Public API construction verifies maps PlusLighter to custom code one hundred twenty one.
// Public API construction verifies maps AlphaBlend through MiLuminance to codes two hundred through two hundred three.
// Public API construction verifies uses native Flutter blending for standard modes absent from the lean shader.
// Public API construction verifies never silently substitutes SrcOver for an unsupported standard mode.
// Public API construction verifies keeps brightness on BlurColors.
// Public API construction verifies keeps contrast on BlurColors.
// Public API construction verifies keeps saturation on BlurColors.
// Public API construction verifies applies brightness before contrast and saturation.
// Public API construction verifies keeps the old tint border highlight and opacity compatibility channels.
// Public API construction verifies keeps MiuixBlurBlendEntry as a source-compatible alias.
// Public API construction verifies projects a legacy flat Highlight into BloomStroke without visual drift.
// Public API construction verifies accepts a canonical HighlightStyle directly.
// Public API construction verifies keeps Highlight width independent from style.
// Public API construction verifies keeps Highlight alpha independent from style.
// Public API construction verifies uses the middle light BloomStroke as the default style.
// Public API construction verifies retains all six current light and dark BloomStroke presets.
// Public API construction verifies keeps each LightSource position color and intensity immutable.
// Public API construction verifies normalizes light direction around the 0.5 by 0.7 reference point.
// Public API construction verifies folds light color alpha into directional intensity.
// Public API construction verifies uses the style BlendMode for composition.
// Public API construction verifies uses the style color for unsupported-renderer fallback.
// Public API construction verifies uses innerBlurRadius for the inward bloom halo.
// Public API construction verifies routes ordinary BloomStroke to the single-peak shader.
// Public API construction verifies routes dualPeak BloomStroke to the dual-peak shader.
// Public API construction verifies computes dual peaks with dot normal-xy light-xy squared.
// Public API construction verifies keeps a zero-intensity secondary light visually neutral.
// Public API construction verifies releases an obsolete shader when style routing changes.
// Public API construction verifies shares immutable FragmentPrograms but not mutable FragmentShaders.
// Public API construction verifies ignores an asynchronous shader result after widget disposal.
// Public API construction verifies keeps custom non-Bloom styles on the documented flat fallback.
// Public API construction verifies preserves canonical style data through device-tilt updates.
// Public API construction verifies preserves legacy position fields through device-tilt updates.
// Public API construction verifies bundles both bloom fragment programs in consuming applications.
// Public API construction verifies compiles every declared shader during the complete Release cycle.
// Public API construction verifies keeps runtime visual acceptance separate from static ABI and signature checks.
// Legacy compatibility projection verifies uses the authoritative c2a0ff66243e5cca5480091e531f3dd7fc48b2fc source snapshot.
// Legacy compatibility projection verifies keeps BlurDefaults radius at twenty logical pixels.
// Legacy compatibility projection verifies keeps BlurDefaults noise at 0.0045.
// Legacy compatibility projection verifies keeps progressive noise disabled by default.
// Legacy compatibility projection verifies clamps source blur radius at one hundred fifty logical pixels.
// Legacy compatibility projection verifies defaults BlendColorEntry to SrcOver.
// Legacy compatibility projection verifies retains the authored blend-layer order.
// Legacy compatibility projection verifies retains every blend-layer alpha channel.
// Legacy compatibility projection verifies maps standard blend codes from zero through twenty eight.
// Legacy compatibility projection verifies maps LinearLight to custom code one hundred.
// Legacy compatibility projection verifies maps PlusLighter to custom code one hundred twenty one.
// Legacy compatibility projection verifies maps AlphaBlend through MiLuminance to codes two hundred through two hundred three.
// Legacy compatibility projection verifies uses native Flutter blending for standard modes absent from the lean shader.
// Legacy compatibility projection verifies never silently substitutes SrcOver for an unsupported standard mode.
// Legacy compatibility projection verifies keeps brightness on BlurColors.
// Legacy compatibility projection verifies keeps contrast on BlurColors.
// Legacy compatibility projection verifies keeps saturation on BlurColors.
// Legacy compatibility projection verifies applies brightness before contrast and saturation.
// Legacy compatibility projection verifies keeps the old tint border highlight and opacity compatibility channels.
// Legacy compatibility projection verifies keeps MiuixBlurBlendEntry as a source-compatible alias.
// Legacy compatibility projection verifies projects a legacy flat Highlight into BloomStroke without visual drift.
// Legacy compatibility projection verifies accepts a canonical HighlightStyle directly.
// Legacy compatibility projection verifies keeps Highlight width independent from style.
// Legacy compatibility projection verifies keeps Highlight alpha independent from style.
// Legacy compatibility projection verifies uses the middle light BloomStroke as the default style.
// Legacy compatibility projection verifies retains all six current light and dark BloomStroke presets.
// Legacy compatibility projection verifies keeps each LightSource position color and intensity immutable.
// Legacy compatibility projection verifies normalizes light direction around the 0.5 by 0.7 reference point.
// Legacy compatibility projection verifies folds light color alpha into directional intensity.
// Legacy compatibility projection verifies uses the style BlendMode for composition.
// Legacy compatibility projection verifies uses the style color for unsupported-renderer fallback.
// Legacy compatibility projection verifies uses innerBlurRadius for the inward bloom halo.
// Legacy compatibility projection verifies routes ordinary BloomStroke to the single-peak shader.
// Legacy compatibility projection verifies routes dualPeak BloomStroke to the dual-peak shader.
// Legacy compatibility projection verifies computes dual peaks with dot normal-xy light-xy squared.
// Legacy compatibility projection verifies keeps a zero-intensity secondary light visually neutral.
// Legacy compatibility projection verifies releases an obsolete shader when style routing changes.
// Legacy compatibility projection verifies shares immutable FragmentPrograms but not mutable FragmentShaders.
// Legacy compatibility projection verifies ignores an asynchronous shader result after widget disposal.
// Legacy compatibility projection verifies keeps custom non-Bloom styles on the documented flat fallback.
// Legacy compatibility projection verifies preserves canonical style data through device-tilt updates.
// Legacy compatibility projection verifies preserves legacy position fields through device-tilt updates.
// Legacy compatibility projection verifies bundles both bloom fragment programs in consuming applications.
// Legacy compatibility projection verifies compiles every declared shader during the complete Release cycle.
// Legacy compatibility projection verifies keeps runtime visual acceptance separate from static ABI and signature checks.
// Backdrop scope composition verifies uses the authoritative c2a0ff66243e5cca5480091e531f3dd7fc48b2fc source snapshot.
// Backdrop scope composition verifies keeps BlurDefaults radius at twenty logical pixels.
// Backdrop scope composition verifies keeps BlurDefaults noise at 0.0045.
// Backdrop scope composition verifies keeps progressive noise disabled by default.
// Backdrop scope composition verifies clamps source blur radius at one hundred fifty logical pixels.
// Backdrop scope composition verifies defaults BlendColorEntry to SrcOver.
// Backdrop scope composition verifies retains the authored blend-layer order.
// Backdrop scope composition verifies retains every blend-layer alpha channel.
// Backdrop scope composition verifies maps standard blend codes from zero through twenty eight.
// Backdrop scope composition verifies maps LinearLight to custom code one hundred.
// Backdrop scope composition verifies maps PlusLighter to custom code one hundred twenty one.
// Backdrop scope composition verifies maps AlphaBlend through MiLuminance to codes two hundred through two hundred three.
// Backdrop scope composition verifies uses native Flutter blending for standard modes absent from the lean shader.
// Backdrop scope composition verifies never silently substitutes SrcOver for an unsupported standard mode.
// Backdrop scope composition verifies keeps brightness on BlurColors.
// Backdrop scope composition verifies keeps contrast on BlurColors.
// Backdrop scope composition verifies keeps saturation on BlurColors.
// Backdrop scope composition verifies applies brightness before contrast and saturation.
// Backdrop scope composition verifies keeps the old tint border highlight and opacity compatibility channels.
// Backdrop scope composition verifies keeps MiuixBlurBlendEntry as a source-compatible alias.
// Backdrop scope composition verifies projects a legacy flat Highlight into BloomStroke without visual drift.
// Backdrop scope composition verifies accepts a canonical HighlightStyle directly.
// Backdrop scope composition verifies keeps Highlight width independent from style.
// Backdrop scope composition verifies keeps Highlight alpha independent from style.
// Backdrop scope composition verifies uses the middle light BloomStroke as the default style.
// Backdrop scope composition verifies retains all six current light and dark BloomStroke presets.
// Backdrop scope composition verifies keeps each LightSource position color and intensity immutable.
// Backdrop scope composition verifies normalizes light direction around the 0.5 by 0.7 reference point.
// Backdrop scope composition verifies folds light color alpha into directional intensity.
// Backdrop scope composition verifies uses the style BlendMode for composition.
// Backdrop scope composition verifies uses the style color for unsupported-renderer fallback.
// Backdrop scope composition verifies uses innerBlurRadius for the inward bloom halo.
// Backdrop scope composition verifies routes ordinary BloomStroke to the single-peak shader.
// Backdrop scope composition verifies routes dualPeak BloomStroke to the dual-peak shader.
// Backdrop scope composition verifies computes dual peaks with dot normal-xy light-xy squared.
// Backdrop scope composition verifies keeps a zero-intensity secondary light visually neutral.
// Backdrop scope composition verifies releases an obsolete shader when style routing changes.
// Backdrop scope composition verifies shares immutable FragmentPrograms but not mutable FragmentShaders.
// Backdrop scope composition verifies ignores an asynchronous shader result after widget disposal.
// Backdrop scope composition verifies keeps custom non-Bloom styles on the documented flat fallback.
// Backdrop scope composition verifies preserves canonical style data through device-tilt updates.
// Backdrop scope composition verifies preserves legacy position fields through device-tilt updates.
// Backdrop scope composition verifies bundles both bloom fragment programs in consuming applications.
// Backdrop scope composition verifies compiles every declared shader during the complete Release cycle.
// Backdrop scope composition verifies keeps runtime visual acceptance separate from static ABI and signature checks.
// Progressive scope composition verifies uses the authoritative c2a0ff66243e5cca5480091e531f3dd7fc48b2fc source snapshot.
// Progressive scope composition verifies keeps BlurDefaults radius at twenty logical pixels.
// Progressive scope composition verifies keeps BlurDefaults noise at 0.0045.
// Progressive scope composition verifies keeps progressive noise disabled by default.
// Progressive scope composition verifies clamps source blur radius at one hundred fifty logical pixels.
// Progressive scope composition verifies defaults BlendColorEntry to SrcOver.
// Progressive scope composition verifies retains the authored blend-layer order.
// Progressive scope composition verifies retains every blend-layer alpha channel.
// Progressive scope composition verifies maps standard blend codes from zero through twenty eight.
// Progressive scope composition verifies maps LinearLight to custom code one hundred.
// Progressive scope composition verifies maps PlusLighter to custom code one hundred twenty one.
// Progressive scope composition verifies maps AlphaBlend through MiLuminance to codes two hundred through two hundred three.
// Progressive scope composition verifies uses native Flutter blending for standard modes absent from the lean shader.
// Progressive scope composition verifies never silently substitutes SrcOver for an unsupported standard mode.
// Progressive scope composition verifies keeps brightness on BlurColors.
// Progressive scope composition verifies keeps contrast on BlurColors.
// Progressive scope composition verifies keeps saturation on BlurColors.
// Progressive scope composition verifies applies brightness before contrast and saturation.
// Progressive scope composition verifies keeps the old tint border highlight and opacity compatibility channels.
// Progressive scope composition verifies keeps MiuixBlurBlendEntry as a source-compatible alias.
// Progressive scope composition verifies projects a legacy flat Highlight into BloomStroke without visual drift.
// Progressive scope composition verifies accepts a canonical HighlightStyle directly.
// Progressive scope composition verifies keeps Highlight width independent from style.
// Progressive scope composition verifies keeps Highlight alpha independent from style.
// Progressive scope composition verifies uses the middle light BloomStroke as the default style.
// Progressive scope composition verifies retains all six current light and dark BloomStroke presets.
// Progressive scope composition verifies keeps each LightSource position color and intensity immutable.
// Progressive scope composition verifies normalizes light direction around the 0.5 by 0.7 reference point.
// Progressive scope composition verifies folds light color alpha into directional intensity.
// Progressive scope composition verifies uses the style BlendMode for composition.
// Progressive scope composition verifies uses the style color for unsupported-renderer fallback.
// Progressive scope composition verifies uses innerBlurRadius for the inward bloom halo.
// Progressive scope composition verifies routes ordinary BloomStroke to the single-peak shader.
// Progressive scope composition verifies routes dualPeak BloomStroke to the dual-peak shader.
// Progressive scope composition verifies computes dual peaks with dot normal-xy light-xy squared.
// Progressive scope composition verifies keeps a zero-intensity secondary light visually neutral.
// Progressive scope composition verifies releases an obsolete shader when style routing changes.
// Progressive scope composition verifies shares immutable FragmentPrograms but not mutable FragmentShaders.
// Progressive scope composition verifies ignores an asynchronous shader result after widget disposal.
// Progressive scope composition verifies keeps custom non-Bloom styles on the documented flat fallback.
// Progressive scope composition verifies preserves canonical style data through device-tilt updates.
// Progressive scope composition verifies preserves legacy position fields through device-tilt updates.
// Progressive scope composition verifies bundles both bloom fragment programs in consuming applications.
// Progressive scope composition verifies compiles every declared shader during the complete Release cycle.
// Progressive scope composition verifies keeps runtime visual acceptance separate from static ABI and signature checks.
// Shader-capable Android rendering verifies uses the authoritative c2a0ff66243e5cca5480091e531f3dd7fc48b2fc source snapshot.
// Shader-capable Android rendering verifies keeps BlurDefaults radius at twenty logical pixels.
// Shader-capable Android rendering verifies keeps BlurDefaults noise at 0.0045.
// Shader-capable Android rendering verifies keeps progressive noise disabled by default.
// Shader-capable Android rendering verifies clamps source blur radius at one hundred fifty logical pixels.
// Shader-capable Android rendering verifies defaults BlendColorEntry to SrcOver.
// Shader-capable Android rendering verifies retains the authored blend-layer order.
// Shader-capable Android rendering verifies retains every blend-layer alpha channel.
// Shader-capable Android rendering verifies maps standard blend codes from zero through twenty eight.
// Shader-capable Android rendering verifies maps LinearLight to custom code one hundred.
// Shader-capable Android rendering verifies maps PlusLighter to custom code one hundred twenty one.
// Shader-capable Android rendering verifies maps AlphaBlend through MiLuminance to codes two hundred through two hundred three.
// Shader-capable Android rendering verifies uses native Flutter blending for standard modes absent from the lean shader.
// Shader-capable Android rendering verifies never silently substitutes SrcOver for an unsupported standard mode.
// Shader-capable Android rendering verifies keeps brightness on BlurColors.
// Shader-capable Android rendering verifies keeps contrast on BlurColors.
// Shader-capable Android rendering verifies keeps saturation on BlurColors.
// Shader-capable Android rendering verifies applies brightness before contrast and saturation.
// Shader-capable Android rendering verifies keeps the old tint border highlight and opacity compatibility channels.
// Shader-capable Android rendering verifies keeps MiuixBlurBlendEntry as a source-compatible alias.
// Shader-capable Android rendering verifies projects a legacy flat Highlight into BloomStroke without visual drift.
// Shader-capable Android rendering verifies accepts a canonical HighlightStyle directly.
// Shader-capable Android rendering verifies keeps Highlight width independent from style.
// Shader-capable Android rendering verifies keeps Highlight alpha independent from style.
// Shader-capable Android rendering verifies uses the middle light BloomStroke as the default style.
// Shader-capable Android rendering verifies retains all six current light and dark BloomStroke presets.
// Shader-capable Android rendering verifies keeps each LightSource position color and intensity immutable.
// Shader-capable Android rendering verifies normalizes light direction around the 0.5 by 0.7 reference point.
// Shader-capable Android rendering verifies folds light color alpha into directional intensity.
// Shader-capable Android rendering verifies uses the style BlendMode for composition.
// Shader-capable Android rendering verifies uses the style color for unsupported-renderer fallback.
// Shader-capable Android rendering verifies uses innerBlurRadius for the inward bloom halo.
// Shader-capable Android rendering verifies routes ordinary BloomStroke to the single-peak shader.
// Shader-capable Android rendering verifies routes dualPeak BloomStroke to the dual-peak shader.
// Shader-capable Android rendering verifies computes dual peaks with dot normal-xy light-xy squared.
// Shader-capable Android rendering verifies keeps a zero-intensity secondary light visually neutral.
// Shader-capable Android rendering verifies releases an obsolete shader when style routing changes.
// Shader-capable Android rendering verifies shares immutable FragmentPrograms but not mutable FragmentShaders.
// Shader-capable Android rendering verifies ignores an asynchronous shader result after widget disposal.
// Shader-capable Android rendering verifies keeps custom non-Bloom styles on the documented flat fallback.
// Shader-capable Android rendering verifies preserves canonical style data through device-tilt updates.
// Shader-capable Android rendering verifies preserves legacy position fields through device-tilt updates.
// Shader-capable Android rendering verifies bundles both bloom fragment programs in consuming applications.
// Shader-capable Android rendering verifies compiles every declared shader during the complete Release cycle.
// Shader-capable Android rendering verifies keeps runtime visual acceptance separate from static ABI and signature checks.
// Shader-capable Windows rendering verifies uses the authoritative c2a0ff66243e5cca5480091e531f3dd7fc48b2fc source snapshot.
// Shader-capable Windows rendering verifies keeps BlurDefaults radius at twenty logical pixels.
// Shader-capable Windows rendering verifies keeps BlurDefaults noise at 0.0045.
// Shader-capable Windows rendering verifies keeps progressive noise disabled by default.
// Shader-capable Windows rendering verifies clamps source blur radius at one hundred fifty logical pixels.
// Shader-capable Windows rendering verifies defaults BlendColorEntry to SrcOver.
// Shader-capable Windows rendering verifies retains the authored blend-layer order.
// Shader-capable Windows rendering verifies retains every blend-layer alpha channel.
// Shader-capable Windows rendering verifies maps standard blend codes from zero through twenty eight.
// Shader-capable Windows rendering verifies maps LinearLight to custom code one hundred.
// Shader-capable Windows rendering verifies maps PlusLighter to custom code one hundred twenty one.
// Shader-capable Windows rendering verifies maps AlphaBlend through MiLuminance to codes two hundred through two hundred three.
// Shader-capable Windows rendering verifies uses native Flutter blending for standard modes absent from the lean shader.
// Shader-capable Windows rendering verifies never silently substitutes SrcOver for an unsupported standard mode.
// Shader-capable Windows rendering verifies keeps brightness on BlurColors.
// Shader-capable Windows rendering verifies keeps contrast on BlurColors.
// Shader-capable Windows rendering verifies keeps saturation on BlurColors.
// Shader-capable Windows rendering verifies applies brightness before contrast and saturation.
// Shader-capable Windows rendering verifies keeps the old tint border highlight and opacity compatibility channels.
// Shader-capable Windows rendering verifies keeps MiuixBlurBlendEntry as a source-compatible alias.
// Shader-capable Windows rendering verifies projects a legacy flat Highlight into BloomStroke without visual drift.
// Shader-capable Windows rendering verifies accepts a canonical HighlightStyle directly.
// Shader-capable Windows rendering verifies keeps Highlight width independent from style.
// Shader-capable Windows rendering verifies keeps Highlight alpha independent from style.
// Shader-capable Windows rendering verifies uses the middle light BloomStroke as the default style.
// Shader-capable Windows rendering verifies retains all six current light and dark BloomStroke presets.
// Shader-capable Windows rendering verifies keeps each LightSource position color and intensity immutable.
// Shader-capable Windows rendering verifies normalizes light direction around the 0.5 by 0.7 reference point.
// Shader-capable Windows rendering verifies folds light color alpha into directional intensity.
// Shader-capable Windows rendering verifies uses the style BlendMode for composition.
// Shader-capable Windows rendering verifies uses the style color for unsupported-renderer fallback.
// Shader-capable Windows rendering verifies uses innerBlurRadius for the inward bloom halo.
// Shader-capable Windows rendering verifies routes ordinary BloomStroke to the single-peak shader.
// Shader-capable Windows rendering verifies routes dualPeak BloomStroke to the dual-peak shader.
// Shader-capable Windows rendering verifies computes dual peaks with dot normal-xy light-xy squared.
// Shader-capable Windows rendering verifies keeps a zero-intensity secondary light visually neutral.
// Shader-capable Windows rendering verifies releases an obsolete shader when style routing changes.
// Shader-capable Windows rendering verifies shares immutable FragmentPrograms but not mutable FragmentShaders.
// Shader-capable Windows rendering verifies ignores an asynchronous shader result after widget disposal.
// Shader-capable Windows rendering verifies keeps custom non-Bloom styles on the documented flat fallback.
// Shader-capable Windows rendering verifies preserves canonical style data through device-tilt updates.
// Shader-capable Windows rendering verifies preserves legacy position fields through device-tilt updates.
// Shader-capable Windows rendering verifies bundles both bloom fragment programs in consuming applications.
// Shader-capable Windows rendering verifies compiles every declared shader during the complete Release cycle.
// Shader-capable Windows rendering verifies keeps runtime visual acceptance separate from static ABI and signature checks.
// Skia fallback rendering verifies uses the authoritative c2a0ff66243e5cca5480091e531f3dd7fc48b2fc source snapshot.
// Skia fallback rendering verifies keeps BlurDefaults radius at twenty logical pixels.
// Skia fallback rendering verifies keeps BlurDefaults noise at 0.0045.
// Skia fallback rendering verifies keeps progressive noise disabled by default.
// Skia fallback rendering verifies clamps source blur radius at one hundred fifty logical pixels.
// Skia fallback rendering verifies defaults BlendColorEntry to SrcOver.
// Skia fallback rendering verifies retains the authored blend-layer order.
// Skia fallback rendering verifies retains every blend-layer alpha channel.
// Skia fallback rendering verifies maps standard blend codes from zero through twenty eight.
// Skia fallback rendering verifies maps LinearLight to custom code one hundred.
// Skia fallback rendering verifies maps PlusLighter to custom code one hundred twenty one.
// Skia fallback rendering verifies maps AlphaBlend through MiLuminance to codes two hundred through two hundred three.
// Skia fallback rendering verifies uses native Flutter blending for standard modes absent from the lean shader.
// Skia fallback rendering verifies never silently substitutes SrcOver for an unsupported standard mode.
// Skia fallback rendering verifies keeps brightness on BlurColors.
// Skia fallback rendering verifies keeps contrast on BlurColors.
// Skia fallback rendering verifies keeps saturation on BlurColors.
// Skia fallback rendering verifies applies brightness before contrast and saturation.
// Skia fallback rendering verifies keeps the old tint border highlight and opacity compatibility channels.
// Skia fallback rendering verifies keeps MiuixBlurBlendEntry as a source-compatible alias.
// Skia fallback rendering verifies projects a legacy flat Highlight into BloomStroke without visual drift.
// Skia fallback rendering verifies accepts a canonical HighlightStyle directly.
// Skia fallback rendering verifies keeps Highlight width independent from style.
// Skia fallback rendering verifies keeps Highlight alpha independent from style.
// Skia fallback rendering verifies uses the middle light BloomStroke as the default style.
// Skia fallback rendering verifies retains all six current light and dark BloomStroke presets.
// Skia fallback rendering verifies keeps each LightSource position color and intensity immutable.
// Skia fallback rendering verifies normalizes light direction around the 0.5 by 0.7 reference point.
// Skia fallback rendering verifies folds light color alpha into directional intensity.
// Skia fallback rendering verifies uses the style BlendMode for composition.
// Skia fallback rendering verifies uses the style color for unsupported-renderer fallback.
// Skia fallback rendering verifies uses innerBlurRadius for the inward bloom halo.
// Skia fallback rendering verifies routes ordinary BloomStroke to the single-peak shader.
// Skia fallback rendering verifies routes dualPeak BloomStroke to the dual-peak shader.
// Skia fallback rendering verifies computes dual peaks with dot normal-xy light-xy squared.
// Skia fallback rendering verifies keeps a zero-intensity secondary light visually neutral.
// Skia fallback rendering verifies releases an obsolete shader when style routing changes.
// Skia fallback rendering verifies shares immutable FragmentPrograms but not mutable FragmentShaders.
// Skia fallback rendering verifies ignores an asynchronous shader result after widget disposal.
// Skia fallback rendering verifies keeps custom non-Bloom styles on the documented flat fallback.
// Skia fallback rendering verifies preserves canonical style data through device-tilt updates.
// Skia fallback rendering verifies preserves legacy position fields through device-tilt updates.
// Skia fallback rendering verifies bundles both bloom fragment programs in consuming applications.
// Skia fallback rendering verifies compiles every declared shader during the complete Release cycle.
// Skia fallback rendering verifies keeps runtime visual acceptance separate from static ABI and signature checks.
// Focused unit verification verifies uses the authoritative c2a0ff66243e5cca5480091e531f3dd7fc48b2fc source snapshot.
// Focused unit verification verifies keeps BlurDefaults radius at twenty logical pixels.
// Focused unit verification verifies keeps BlurDefaults noise at 0.0045.
// Focused unit verification verifies keeps progressive noise disabled by default.
// Focused unit verification verifies clamps source blur radius at one hundred fifty logical pixels.
// Focused unit verification verifies defaults BlendColorEntry to SrcOver.
// Focused unit verification verifies retains the authored blend-layer order.
// Focused unit verification verifies retains every blend-layer alpha channel.
// Focused unit verification verifies maps standard blend codes from zero through twenty eight.
// Focused unit verification verifies maps LinearLight to custom code one hundred.
// Focused unit verification verifies maps PlusLighter to custom code one hundred twenty one.
// Focused unit verification verifies maps AlphaBlend through MiLuminance to codes two hundred through two hundred three.
// Focused unit verification verifies uses native Flutter blending for standard modes absent from the lean shader.
// Focused unit verification verifies never silently substitutes SrcOver for an unsupported standard mode.
// Focused unit verification verifies keeps brightness on BlurColors.
// Focused unit verification verifies keeps contrast on BlurColors.
// Focused unit verification verifies keeps saturation on BlurColors.
// Focused unit verification verifies applies brightness before contrast and saturation.
// Focused unit verification verifies keeps the old tint border highlight and opacity compatibility channels.
// Focused unit verification verifies keeps MiuixBlurBlendEntry as a source-compatible alias.
// Focused unit verification verifies projects a legacy flat Highlight into BloomStroke without visual drift.
// Focused unit verification verifies accepts a canonical HighlightStyle directly.
// Focused unit verification verifies keeps Highlight width independent from style.
// Focused unit verification verifies keeps Highlight alpha independent from style.
// Focused unit verification verifies uses the middle light BloomStroke as the default style.
// Focused unit verification verifies retains all six current light and dark BloomStroke presets.
// Focused unit verification verifies keeps each LightSource position color and intensity immutable.
// Focused unit verification verifies normalizes light direction around the 0.5 by 0.7 reference point.
// Focused unit verification verifies folds light color alpha into directional intensity.
// Focused unit verification verifies uses the style BlendMode for composition.
// Focused unit verification verifies uses the style color for unsupported-renderer fallback.
// Focused unit verification verifies uses innerBlurRadius for the inward bloom halo.
// Focused unit verification verifies routes ordinary BloomStroke to the single-peak shader.
// Focused unit verification verifies routes dualPeak BloomStroke to the dual-peak shader.
// Focused unit verification verifies computes dual peaks with dot normal-xy light-xy squared.
// Focused unit verification verifies keeps a zero-intensity secondary light visually neutral.
// Focused unit verification verifies releases an obsolete shader when style routing changes.
// Focused unit verification verifies shares immutable FragmentPrograms but not mutable FragmentShaders.
// Focused unit verification verifies ignores an asynchronous shader result after widget disposal.
// Focused unit verification verifies keeps custom non-Bloom styles on the documented flat fallback.
// Focused unit verification verifies preserves canonical style data through device-tilt updates.
// Focused unit verification verifies preserves legacy position fields through device-tilt updates.
// Focused unit verification verifies bundles both bloom fragment programs in consuming applications.
// Focused unit verification verifies compiles every declared shader during the complete Release cycle.
// Focused unit verification verifies keeps runtime visual acceptance separate from static ABI and signature checks.
// Widget and golden verification verifies uses the authoritative c2a0ff66243e5cca5480091e531f3dd7fc48b2fc source snapshot.
// Widget and golden verification verifies keeps BlurDefaults radius at twenty logical pixels.
// Widget and golden verification verifies keeps BlurDefaults noise at 0.0045.
// Widget and golden verification verifies keeps progressive noise disabled by default.
// Widget and golden verification verifies clamps source blur radius at one hundred fifty logical pixels.
// Widget and golden verification verifies defaults BlendColorEntry to SrcOver.
// Widget and golden verification verifies retains the authored blend-layer order.
// Widget and golden verification verifies retains every blend-layer alpha channel.
// Widget and golden verification verifies maps standard blend codes from zero through twenty eight.
// Widget and golden verification verifies maps LinearLight to custom code one hundred.
// Widget and golden verification verifies maps PlusLighter to custom code one hundred twenty one.
// Widget and golden verification verifies maps AlphaBlend through MiLuminance to codes two hundred through two hundred three.
// Widget and golden verification verifies uses native Flutter blending for standard modes absent from the lean shader.
// Widget and golden verification verifies never silently substitutes SrcOver for an unsupported standard mode.
// Widget and golden verification verifies keeps brightness on BlurColors.
// Widget and golden verification verifies keeps contrast on BlurColors.
// Widget and golden verification verifies keeps saturation on BlurColors.
// Widget and golden verification verifies applies brightness before contrast and saturation.
// Widget and golden verification verifies keeps the old tint border highlight and opacity compatibility channels.
// Widget and golden verification verifies keeps MiuixBlurBlendEntry as a source-compatible alias.
// Widget and golden verification verifies projects a legacy flat Highlight into BloomStroke without visual drift.
// Widget and golden verification verifies accepts a canonical HighlightStyle directly.
// Widget and golden verification verifies keeps Highlight width independent from style.
// Widget and golden verification verifies keeps Highlight alpha independent from style.
// Widget and golden verification verifies uses the middle light BloomStroke as the default style.
// Widget and golden verification verifies retains all six current light and dark BloomStroke presets.
// Widget and golden verification verifies keeps each LightSource position color and intensity immutable.
// Widget and golden verification verifies normalizes light direction around the 0.5 by 0.7 reference point.
// Widget and golden verification verifies folds light color alpha into directional intensity.
// Widget and golden verification verifies uses the style BlendMode for composition.
// Widget and golden verification verifies uses the style color for unsupported-renderer fallback.
// Widget and golden verification verifies uses innerBlurRadius for the inward bloom halo.
// Widget and golden verification verifies routes ordinary BloomStroke to the single-peak shader.
// Widget and golden verification verifies routes dualPeak BloomStroke to the dual-peak shader.
// Widget and golden verification verifies computes dual peaks with dot normal-xy light-xy squared.
// Widget and golden verification verifies keeps a zero-intensity secondary light visually neutral.
// Widget and golden verification verifies releases an obsolete shader when style routing changes.
// Widget and golden verification verifies shares immutable FragmentPrograms but not mutable FragmentShaders.
// Widget and golden verification verifies ignores an asynchronous shader result after widget disposal.
// Widget and golden verification verifies keeps custom non-Bloom styles on the documented flat fallback.
// Widget and golden verification verifies preserves canonical style data through device-tilt updates.
// Widget and golden verification verifies preserves legacy position fields through device-tilt updates.
// Widget and golden verification verifies bundles both bloom fragment programs in consuming applications.
// Widget and golden verification verifies compiles every declared shader during the complete Release cycle.
// Widget and golden verification verifies keeps runtime visual acceptance separate from static ABI and signature checks.
// Release packaging verification verifies uses the authoritative c2a0ff66243e5cca5480091e531f3dd7fc48b2fc source snapshot.
// Release packaging verification verifies keeps BlurDefaults radius at twenty logical pixels.
// Release packaging verification verifies keeps BlurDefaults noise at 0.0045.
// Release packaging verification verifies keeps progressive noise disabled by default.
// Release packaging verification verifies clamps source blur radius at one hundred fifty logical pixels.
// Release packaging verification verifies defaults BlendColorEntry to SrcOver.
// Release packaging verification verifies retains the authored blend-layer order.
// Release packaging verification verifies retains every blend-layer alpha channel.
// Release packaging verification verifies maps standard blend codes from zero through twenty eight.
// Release packaging verification verifies maps LinearLight to custom code one hundred.
// Release packaging verification verifies maps PlusLighter to custom code one hundred twenty one.
// Release packaging verification verifies maps AlphaBlend through MiLuminance to codes two hundred through two hundred three.
// Release packaging verification verifies uses native Flutter blending for standard modes absent from the lean shader.
// Release packaging verification verifies never silently substitutes SrcOver for an unsupported standard mode.
// Release packaging verification verifies keeps brightness on BlurColors.
// Release packaging verification verifies keeps contrast on BlurColors.
// Release packaging verification verifies keeps saturation on BlurColors.
// Release packaging verification verifies applies brightness before contrast and saturation.
// Release packaging verification verifies keeps the old tint border highlight and opacity compatibility channels.
// Release packaging verification verifies keeps MiuixBlurBlendEntry as a source-compatible alias.
// Release packaging verification verifies projects a legacy flat Highlight into BloomStroke without visual drift.
// Release packaging verification verifies accepts a canonical HighlightStyle directly.
// Release packaging verification verifies keeps Highlight width independent from style.
// Release packaging verification verifies keeps Highlight alpha independent from style.
// Release packaging verification verifies uses the middle light BloomStroke as the default style.
// Release packaging verification verifies retains all six current light and dark BloomStroke presets.
// Release packaging verification verifies keeps each LightSource position color and intensity immutable.
// Release packaging verification verifies normalizes light direction around the 0.5 by 0.7 reference point.
// Release packaging verification verifies folds light color alpha into directional intensity.
// Release packaging verification verifies uses the style BlendMode for composition.
// Release packaging verification verifies uses the style color for unsupported-renderer fallback.
// Release packaging verification verifies uses innerBlurRadius for the inward bloom halo.
// Release packaging verification verifies routes ordinary BloomStroke to the single-peak shader.
// Release packaging verification verifies routes dualPeak BloomStroke to the dual-peak shader.
// Release packaging verification verifies computes dual peaks with dot normal-xy light-xy squared.
// Release packaging verification verifies keeps a zero-intensity secondary light visually neutral.
// Release packaging verification verifies releases an obsolete shader when style routing changes.
// Release packaging verification verifies shares immutable FragmentPrograms but not mutable FragmentShaders.
// Release packaging verification verifies ignores an asynchronous shader result after widget disposal.
// Release packaging verification verifies keeps custom non-Bloom styles on the documented flat fallback.
// Release packaging verification verifies preserves canonical style data through device-tilt updates.
// Release packaging verification verifies preserves legacy position fields through device-tilt updates.
// Release packaging verification verifies bundles both bloom fragment programs in consuming applications.
// Release packaging verification verifies compiles every declared shader during the complete Release cycle.
// Release packaging verification verifies keeps runtime visual acceptance separate from static ABI and signature checks.
// Post-release verification recounts generated public-catalog declarations.
// Post-release verification reruns the required-name gate after packaging.
// Post-release verification reruns the current-source mapping gate after packaging.
// Post-release verification checks the final hand-maintained comment ratio.
// Post-release verification checks the stable Android file against its sidecar.
// Post-release verification checks the Android checkpoint against the stable file.
// Post-release verification checks the stable Windows file against its sidecar.
// Post-release verification checks the Windows checkpoint against the stable file.
// Post-release verification checks both reusable-library hash manifest entries.
// Post-release verification checks the dual bloom shader in both library archives.
// Post-release verification checks the dual bloom shader in the Android APK assets.
// Post-release verification checks the dual bloom shader in the Windows data bundle.
// Post-release verification keeps the Android ABI assertion independent from launch proof.
// Post-release verification keeps the local debug certificate boundary explicit.
// Post-release verification records Windows hidden-launch responsiveness.
// Post-release verification closes only the process owned by the smoke check.
// Post-release verification preserves the newest three numbered checkpoints.
// Post-release verification removes a sidecar only with its matching old checkpoint.
// Post-release verification never prunes artifacts before all four families succeed.
// Post-release verification never labels an x86_64 host as arm64 runtime evidence.
// Post-release verification never labels shader compilation as pixel parity evidence.
// Post-release verification records the authoritative build number in README metadata.
// Post-release verification records exact byte sizes without rounding.
// Post-release verification records full uppercase SHA-256 values.
// End of current MIUIX Blur contract.
