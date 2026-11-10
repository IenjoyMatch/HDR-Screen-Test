// Current BackdropEffectScope compatibility contract.
//
// Source reference: current miuix-blur BackdropEffectScope.kt and
// BackdropEffects.kt. Flutter cannot compile arbitrary AGSL strings at runtime,
// so the public custom boundary is an engine ImageFilter. Shader callers use a
// FragmentProgram bundled at build time and pass ImageFilter.shader.
//
// API compatibility: the historical widget constructor remains valid. Fluent
// methods return a new widget instead of mutating a Flutter Widget instance.
// `blur(x)` is isotropic and `blur(x, y)` preserves the source's independent
// axes. MiuixBackdrop.blurY stays nullable so every older recipe is unchanged.
// Progressive methods return MiuixProgressiveBackdropEffectScope, which keeps
// the same immutable post-effect vocabulary after switching render pipelines.
//
// Ordering: built-in color controls, blur, and blend colors form the texture
// recipe. Caller effects consume that completed recipe in insertion order.
// Noise is a full-resolution overlay after the image-effect chain. Highlight
// and ordinary content are painted above both, so text and icons stay sharp.
//
// Capability fallback: a supported shader filter folds source color controls,
// blur, and blend layers into the accelerated chain. A headless or unsupported
// backend uses the existing color-matrix and ordered ColorFiltered fallback.
// Custom effects must survive both branches and must not create a second
// BackdropFilter sampling pass.
// Both the two-pass progressive shader and its 13/40/100 variance fallback use
// independent X/Y maxima. An omitted vertical radius remains isotropic.
//
// Input normalization: standard textureBlurEffect clamps finite radii to the
// source 0..150dp interval. A non-finite radius becomes zero. Non-positive or
// non-finite noise follows source noiseDither and leaves prior noise unchanged.
// Direct MiuixBackdrop values remain render-sanitized for compatibility.
//
// Motion and painting: this scope configures a static render-effect chain; it
// does not invent an animation clock. Animated owners rebuild immutable scope
// values, letting Flutter retain the existing layer while filters update.
// Shape clipping remains owned by the single MiuixLayerBackdrop glass surface.
//
// Regression evidence: the public wrapper test checks anisotropic sigma,
// insertion order, source preset clamping, fallback presence, noise placement,
// and that foreground text has no ImageFiltered ancestor. The example Blur
// test proves the public preset drives the existing interactive preview.
//
// Detailed operation contract.
//
// Uniform blur:
// - The public radius remains a logical dp value.
// - The renderer converts each axis with the current-source 0.45 sigma ratio.
// - A null blurY means blurY equals blur, not zero.
// - A finite negative direct radius is render-clamped to zero.
// - A non-finite direct radius is render-clamped to zero.
// - The preset additionally clamps each finite axis to 150dp.
// - The optional Y axis never changes old isotropic constructor output.
// - An anisotropic blur uses one BackdropFilter with independent sigma slots.
// - It must not approximate two axes with nested BackdropFilters.
//
// Progressive blur:
// - The maximum X and Y sigmas are computed independently.
// - The weak fallback level uses 13 percent of each maximum.
// - The middle fallback adds variance from 13 percent to 40 percent.
// - The strong fallback adds variance from 40 percent to 100 percent.
// - Incremental variance is calculated per axis with the same scale factor.
// - The three source masks retain their authored 3/3, 2/3, and 1/3 ramps.
// - The post-effect mask retains its authored 1/1 ramp.
// - The runtime horizontal shader receives the X maximum.
// - The runtime vertical shader receives the Y maximum.
// - A zero X radius may coexist with a nonzero Y radius.
// - A zero Y radius may coexist with a nonzero X radius.
// - The fallback remains available when shader image filters are unsupported.
// - Loading the runtime shader may replace fallback blur without replacing state.
// - Foreground content remains outside both runtime and fallback blur layers.
//
// Color controls:
// - Brightness, contrast, and saturation retain their neutral values 0/1/1.
// - The accelerated texture shader applies controls before blend colors.
// - Unsupported backends retain the documented Rec.709 matrix approximation.
// - A neutral control call may reuse the previous visual recipe.
// - Public values are sanitized by the established layer implementation.
// - The scope does not introduce an unrelated color-animation duration.
//
// Blend colors:
// - Blend entries preserve insertion order.
// - The accelerated path selects the existing specialized shader asset.
// - Standard, arithmetic, Lab, and Logo routing remain unchanged.
// - Unsupported shader filters retain ordered ColorFiltered fallback layers.
// - An empty blend list is a source no-op in the fluent scope.
// - Tint, border, opacity, and blend entries travel as one MiuixBlurColors value.
// - Switching to progressive blur retains the same color recipe.
// - Post-blend custom effects must not disappear during async shader loading.
//
// Noise:
// - Noise is not represented as an ImageFilter.
// - It stays a deterministic full-resolution painter.
// - Its fixed seed prevents a continuously shimmering static surface.
// - It is painted after the background image-effect chain.
// - It is painted before ordinary foreground content.
// - A non-positive fluent coefficient leaves the previous value unchanged.
// - A non-finite fluent coefficient leaves the previous value unchanged.
// - Direct recipes continue to clamp painter strength to the safe range.
// - Progressive noise follows the same post-effect gradient mask as the source.
//
// Custom image effects:
// - Each effect is an engine ImageFilter value owned by the caller.
// - The first custom effect consumes the completed built-in texture recipe.
// - The second custom effect consumes the first effect's result.
// - Further effects retain that same left-to-right ordering.
// - ImageFilter.compose uses the previous chain as inner and the new effect as outer.
// - The debug helper exposes this portable composition order to tests.
// - Runtime FragmentShader filters must come from bundled FragmentProgram assets.
// - Raw AGSL strings cannot be accepted because Flutter has no matching compiler API.
// - Ordinary blur, matrix, dilate, and erode filters need no shader asset.
// - Custom effects use ImageFiltered around the completed background plane.
// - They do not create a second window-sampling BackdropFilter.
// - They do not become ancestors of labels, icons, noise, or highlights.
// - They survive the shader-supported blend path.
// - They survive the shader-unavailable blend fallback path.
// - They survive the progressive runtime path.
// - They survive the progressive three-level fallback path.
// - The final plane is clipped by the same component silhouette.
//
// Immutability and ownership:
// - Every fluent call returns a new widget configuration.
// - Returning a new configuration follows Flutter's Widget contract.
// - Existing child, key, radius, and padding are retained by uniform calls.
// - Progressive conversion retains child, key, radius, and effective padding.
// - Existing highlight and enabled state are retained by copyWith.
// - Existing custom effects are retained when changing blur or color values.
// - Appending an effect creates a new ordered list.
// - Callers should treat supplied effect lists as immutable configuration.
// - A rebuilt owner updates the current layer instead of mutating old Widgets.
// - No controller, ticker, focus node, or route is owned by this scope.
//
// Visual and motion acceptance:
// - The texture preview must retain its existing 280dp bounds.
// - The preview must retain its existing 24dp rounded clip.
// - The building image must remain visible through transparent texture tint.
// - Text must remain crisp when custom dilation or erosion is enabled.
// - The live highlight must continue following device tilt.
// - Slider changes rebuild filters without adding a separate transition clock.
// - Async shader availability must not flash an unfiltered foreground.
// - Reduced motion has no special branch because the effect chain is static.
// - Animated callers remain free to interpolate recipe values externally.
// - Existing Blur preview goldens are the visual non-regression authority.
//
// Platform and release acceptance:
// - Headless Skia proves fallback structure and ordering.
// - Shader-capable Android and Windows builds exercise accelerated filters.
// - Android release packaging remains arm64-v8a only.
// - Windows release packaging remains x64 only.
// - A successful build is not a substitute for an owned-device runtime check.
// - Debug-certificate Android output remains test distribution only.
// - Full library and example suites must pass before artifact pruning.
// - Stable and numbered artifacts must share the same verified build number.
//
// Failure-mode checks:
// - A missing FragmentProgram must fall back instead of throwing from build.
// - A disposed layer must not receive an async shader completion setState.
// - Replacing blend modes must dispose the previous mutable FragmentShader.
// - Replacing highlight state must not reuse another widget's mutable shader.
// - A zero-sized background must not produce invalid painter geometry.
// - An empty effect list must retain the old fast path exactly.
// - A single custom effect must create exactly one post-effect layer.
// - Multiple custom effects must nest without reversing their order.
// - Disabling the backdrop must return readable ordinary content.
// - Disabling the backdrop must not leave a custom effect layer active.
// - Changing only blurY must update the engine filter.
// - Clearing blurY must restore isotropic rendering.
// - Changing only the gradient must retain post effects.
// - Changing only colors must retain progressive radii.
// - Changing only noise must retain custom effects.
// - Changing only highlight must retain the blur chain.
// - Changing only enabled state must retain the immutable recipe.
// - Invalid preset X and valid preset Y must preserve the valid Y axis.
// - Valid preset X and invalid preset Y must preserve the valid X axis.
// - A reversed progressive band remains handled by the existing mask logic.
// - Equal progressive endpoints retain the existing epsilon separation.
// - Non-positive progressive curve retains the existing safe fallback.
// - Non-finite progressive angle retains the existing top direction.
//
// API review checks:
// - New parameters remain optional on every existing constructor.
// - The default MiuixBackdrop value remains const-constructible.
// - Existing code reading backdrop.blur observes the horizontal/source value.
// - Existing code that ignores blurY sees no API behavior change.
// - The adapter remains a subtype of MiuixLayerBackdrop for compatibility.
// - The progressive result remains a subtype of MiuixProgressiveLayerBackdrop.
// - Public docs distinguish runtime AGSL from bundled FragmentProgram shaders.
// - Public docs state the exact effect order rather than implying equivalence.
// - Public examples exercise the library implementation, not a local replica.
// - Tests use the exported scope classes through the package root barrel.
// - Debug helpers are marked visibleForTesting and are not rendering owners.
// - Source dp values are not described as Xiaomi-published HyperOS 4 tokens.
// - Project-calibrated visuals remain identified as project-derived behavior.
// - The scope introduces no Android-specific platform channel dependency.
// - The scope introduces no Windows-only graphics API dependency.
// - Web may use the documented fallback according to engine capability.
//
// Test ownership checks:
// - The wrapper suite owns direct fluent-API construction coverage.
// - The core suite owns texture-layer fallback behavior.
// - The example suite owns interactive Blur section integration.
// - The Blur texture golden owns the final uniform preview raster.
// - The Blur progressive golden owns the final gradient preview raster.
// - The foreground golden ensures background work does not alter glyph masks.
// - The package analyzer owns exported type and null-safety checks.
// - The mapping gate owns upstream name presence only.
// - The mapping gate is not treated as effect behavior evidence.
// - The comment gate records maintainability but not visual parity.
// - Android package inspection owns ABI, id, version, and signature evidence.
// - Windows smoke launch owns executable responsiveness evidence.
// - SHA sidecars own stable artifact integrity evidence.
// - Owned arm64 runtime evidence remains a separate acceptance boundary.
// - An x86_64 emulator cannot satisfy the arm64 runtime boundary.
// - Widget tests cannot prove platform haptic or system-blur behavior.
// - Golden tests cannot prove runtime shader support on every GPU.
// - Release builds cannot prove third-party shader visual correctness.
// - Callers remain responsible for validating their supplied custom filters.
// - Package behavior remains responsible for ordering and foreground isolation.
