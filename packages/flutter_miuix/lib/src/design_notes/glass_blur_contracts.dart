library flutter_miuix_glass_blur_contracts;

// Glass and texture-blur implementation contract.
//
// Scope
// This contract covers MiuixGlass, MiuixBackdrop, MiuixLayerBackdrop, blur
// blend entries, glass-enabled bars, and example surfaces that expose them.
// The rules below are review criteria, not public API declarations.
// Update this file whenever a deliberate rendering contract changes.

// Rendering order
// Sample the already-painted page before drawing any component tint.
// Clip the backdrop filter to the same path used by the visible surface.
// Apply backdrop blur before tint so tint edges remain sharp.
// Paint ordered blend colors after blur and before foreground content.
// Preserve the order supplied by MiuixBlurColors.blendColors.
// Never sort blend entries by alpha, color, or mode.
// Paint component content after every backdrop-only operation.
// Keep labels and icons outside color filters intended for the backdrop.
// Paint noise after the content only when the source effect requires grain.
// Do not let decorative grain participate in pointer hit testing.
// Paint the liquid-glass reflection above tint but below interactive ink.
// Keep the reflection inside the component clip.
// Use a save layer when a non-srcOver blend must combine ordered layers.
// Avoid a save layer when the blend list is empty.
// Retain caller-supplied alpha throughout tint composition.
// Treat Colors.transparent as transparent, never as opaque black.
// Use the same resolved shape for tint, reflection, clipping, and outline.
// Avoid rectangular blur leakage around rounded or squircle surfaces.
// Ensure a zero radius produces an exact rectangular clip.
// Ensure nonuniform BorderRadius values remain nonuniform after clipping.

// Five-level intensity
// MiuixGlassIntensity must keep exactly five ordered values.
// Blur strength must increase monotonically from subtle to intense.
// Tint opacity must decrease monotonically from subtle to intense.
// Standard must preserve a component's requested blur value.
// Standard must preserve a component's requested tint opacity.
// Clamp resolved opacity to the inclusive zero-to-one range.
// Clamp resolved blur to a nonnegative value.
// Subtle may become opaque when the requested tint is already high.
// Intense must still reveal meaningful backdrop structure.
// Do not equate stronger glass with an arbitrarily huge Gaussian sigma.
// Sparse text behind a level-five surface should remain a blurred silhouette.
// A pale page behind pale glass must not appear as one flat opaque rectangle.
// Reflection strength may increase as tint opacity decreases.
// Reflection must not obscure content at any intensity.
// Navigation level five caps Gaussian growth and preserves backdrop structure.
// Navigation optics may retain modest backdrop saturation and contrast.
// Navigation optics use boundary refraction instead of a full-panel white wash.
// Bright top/leading and dark bottom/trailing edges share one clipped path.
// Optical values inferred from reference imagery are not official Apple data.
// A disabled global glass switch must bypass BackdropFilter construction.
// A disabled global glass switch must resolve the tint as an opaque surface.
// Disabling glass must remove the reflection layer.
// Disabling glass must preserve component size and child layout.
// Toggling intensity must rebuild the effect without losing component state.
// Intensity changes must not alter hit-test bounds.

// Explicit texture blur
// Numeric texture-blur controls represent their raw source values.
// Explicit MiuixLayerBackdrop blur must not be scaled by global intensity.
// Explicit texture blur owns its enabled flag and ignores global enableGlass.
// A raw blur value of zero must remain zero.
// Public texture and progressive blur radii are logical dp values.
// Convert a source radius to Flutter sigma with radius * 0.45.
// Do not divide that logical sigma by devicePixelRatio a second time.
// Noise accepts source values from zero through one tenth.
// Brightness accepts source values from minus one through one.
// Contrast treats one as neutral.
// Saturation treats one as neutral.
// Clamp contrast to the supported zero-through-three interval.
// Clamp saturation to the supported zero-through-three interval.
// Keep alpha neutral in brightness, contrast, and saturation processing.
// Apply brightness in gamma-2.2 linear space on shader-capable backends.
// Apply contrast and saturation afterward in sRGB space.
// Use current Rec.709 weights 0.2126, 0.7152, and 0.0722.
// A ColorFilter matrix is only a documented nonlinear-brightness fallback.
// Do not apply backdrop color adjustment to unrelated route content.
// Do not apply texture reflection to source TextureBlur previews.
// Texture preview controls must continue to show exact numeric values.
// The source default noise coefficient is 0.0045.
// Texture preview default blur radius is 100.
// Foreground preview default blur radius is 200.
// The current texture preview has no invented drag or double-tap behavior.
// Progressive preview default blur radius is 20.
// Progressive blur exposes Top, Bottom, Left, and Right source directions.
// Progressive blur applies smoothstep before its configurable power curve.
// Shader-capable backends use the source separable variable-radius Gaussian.
// The loop radius derives from sigma as 2 * sigma - 1 and is capped at 48.
// Headless or unsupported backends use 13%, 40%, and 100% Gaussian levels.
// The fallback composites those levels from weakest to strongest.
// Foreground blur uses DstIn glyph alpha over the live sampled backdrop.
// A supplied foreground gradient is used only without shader image filters.

// Blend data
// MiuixBlurBlendEntry is immutable.
// Every entry retains both color alpha and the named source mode.
// Empty blend lists represent the source None preset.
// Single-entry presets display their mode in the example.
// Multi-entry presets display their exact layer count in the example.
// Source presets retain theme-specific light and dark tables.
// The source thin overlay intentionally uses its light table in both themes.
// Preserve that upstream asymmetry until the reference changes.
// SrcOver maps directly to Flutter BlendMode.srcOver.
// Screen maps directly to Flutter BlendMode.screen.
// Multiply maps directly to Flutter BlendMode.multiply.
// Overlay maps directly to Flutter BlendMode.overlay.
// SoftLight maps directly to Flutter BlendMode.softLight.
// HardLight maps directly to Flutter BlendMode.hardLight.
// ColorDodge maps directly to Flutter BlendMode.colorDodge.
// ColorBurn maps directly to Flutter BlendMode.colorBurn.
// Luminosity maps directly to Flutter BlendMode.luminosity.
// PlusLighter uses Flutter's additive BlendMode.plus.
// Lab-specific modes retain their source names in the public model.
// Portable Lab fallbacks must be documented rather than silently renamed.
// Changing a fallback requires a visual test on Android and Windows.
// Equality checks compare color and mode for every ordered entry.
// Painter invalidation is unnecessary when ordered entries are unchanged.

// Navigation glass
// Regular bottom navigation requests a transparent tint when glass is active.
// Floating navigation clips blur to the pill rather than its full-width host.
// The transparent area outside a floating pill reveals page content unchanged.
// A floating pill must never reserve an opaque rectangular strip.
// Root Scaffold.extendBody must be true for glass bottom navigation.
// AnimatedSwitcher wrappers must not defeat body extension.
// Floating-bar shadow is outside the blur clip.
// Floating-bar reflection is inside the blur clip.
// The shadow must not be interpreted as a tint layer.
// Level-five floating tint is intentionally lower than standard tint.
// Level-five floating blur retains recognizable rows behind the pill.
// Icons and labels remain crisp above the blurred page.
// Selected-item animation remains independent of blur changes.
// Display-mode animation remains independent of blur changes.
// Alignment changes must not expand the pill vertically.
// Safe-area bottom padding stays outside the floating glass surface.
// The unified floating selector keeps its dedicated 24/64/4/56 geometry.
// The panel uses 8dp blur and 40 percent tint on every glass backend.
// Stable desktop lens backends additionally use 1.5x vibrancy.
// Stable desktop backends additionally retain the 24dp runtime lens.
// The moving selector uses a second 56dp circular backdrop lens while pressed.
// Its 56-to-78dp expansion must paint outside the panel's 64dp bounds.
// Dragging retargets the source spring and transfers at most 4dp to the panel.
// Position frames must retain filter subtrees to avoid repeated shader setup.
// Android uses a direct BackdropFilter instead of the unstable runtime lens.
// Do not wrap that filter in ColorFiltered: affected Impeller devices then
// composite an empty offscreen backdrop and the panel appears transparent.
// The safety path keeps tint, highlight, shadow, and intensity.
// Navigation semantics expose one interactive node per destination.
// Decorative selected overlays must not duplicate destination semantics.

// Top app bar glass
// Glass top bars require Scaffold.extendBodyBehindAppBar.
// Page content must be paintable in the app-bar region.
// Large-title collapse state remains driven by scroll notifications.
// Glass must not alter expanded or collapsed bar heights.
// Glass must not alter system-window inset handling.
// Compact and expanded titles stay above every effect layer.
// Bottom content attached to a top bar shares the same glass surface.
// Top-bar reflection may create a subtle bottom edge on pale surfaces.
// The reflection must not resemble an opaque Material elevation overlay.
// Level-five top tint must remain visibly translucent.
// Level-five top blur must not erase all sparse page structure.
// A top bar with glass disabled uses its explicit or themed solid color.
// An explicit transparent top color remains transparent when glass is active.
// About-page title opacity remains independent of glass tint opacity.
// Collapse animation must not recreate scroll controllers.
// Collapse animation must not create a new backdrop filter every frame needlessly.
// A route without body content behind the bar may show reflection only.
// Uniform backgrounds cannot demonstrate blur without a reflection cue.
// Visual tests should therefore include nonuniform content behind the bar.
// App-bar hit testing must remain unchanged when glass toggles.

// Layout and clipping
// Glass never changes the child's intrinsic width.
// Glass never changes the child's intrinsic height.
// Optional padding is applied exactly once.
// Null padding resolves to the shared large spacing token.
// EdgeInsets.zero must remain zero.
// A floating bar controls its own internal horizontal padding.
// A top app bar always passes EdgeInsets.zero to the glass surface.
// A regular navigation bar always passes EdgeInsets.zero to the glass surface.
// ClipPath must receive finite component bounds.
// Avoid backdrop filters with unbounded width or height.
// Avoid placing BackdropFilter inside an unconstrained vertical Align.
// Keep floating hosts intrinsic-height rather than full-height.
// Preserve directional alignment under right-to-left layout.
// Preserve the pill's outside start/end padding semantics.
// Do not clip shadows with the inner glass path.
// Do clip blend layers with the inner glass path.
// Do clip specular reflection with the inner glass path.
// A half-pixel outline may be used to retain the source edge.
// Outline alpha must remain subordinate to content contrast.
// Rounded and squircle paths must share the same requested corner radius.

// State and lifecycle
// Glass widgets own no animation controllers.
// Stateful navigation items dispose every owned controller.
// Repeating example backgrounds stop and dispose when their lazy item leaves.
// The home component list must remain lazily built.
// Offscreen blur previews must not continue ticking.
// Theme changes rebuild blend preset colors without resetting user controls.
// Foreground dynamic-background state survives ordinary parent rebuilds.
// Turning dynamic background off stops its controller.
// Turning dynamic background back on resumes repeating animation.
// Late animation callbacks must not call setState after disposal.
// Popup dismissal must release any held-down preference state.
// Glass setting changes must preserve selected navigation destination.
// Glass setting changes must preserve PageController position.
// Glass setting changes must preserve list PageStorage offsets.
// Asset image decoding must not reset blur control state.
// Drag offsets reset only on the documented double-tap action.
// Blend index wraps at both ends of its exact preset list.
// Previous from index zero selects the last preset.
// Next from the final index selects the first preset.
// User changes are reported synchronously through public callbacks.
// Rendering-only changes never emit value callbacks.

// Accessibility and input
// Decorative backdrop filters are excluded from semantics.
// Decorative reflection layers are excluded from semantics.
// Decorative blend painters are excluded from semantics.
// Navigation icons retain destination labels in icon-only mode.
// Text-only mode retains the same destination activation target.
// Disabled glass does not disable component interaction.
// Disabled components remain inert regardless of glass state.
// Blur sliders retain keyboard and pointer adjustment.
// Slider values remain clamped before painting.
// Previous and next blend buttons have localized visible labels.
// Dynamic-background switch exposes its current checked state.
// Texture preview drag target remains reachable by touch and mouse.
// Double tap does not activate unrelated card actions.
// Pointer cancellation must not leave a pressed navigation item scaled.
// Hit targets remain at least as large as the source component metrics.
// High-contrast users must still distinguish selected navigation state.
// Reflection alone must never be the only selected-state cue.
// Blur alone must never be the only enabled-state cue.
// Reduced-motion environments still show the final selected destination.
// Large text must not be clipped by the glass surface.
// Text scaling must not increase the blur clip unexpectedly.

// Performance
// Do not create BackdropFilter when glass is globally disabled.
// Do not create blend CustomPaint when the entry list is empty.
// Do not create noise CustomPaint when noise is zero.
// Keep blur clips as small as component geometry permits.
// Avoid overlapping full-screen blur filters in the same route.
// Prefer one bar filter over one filter per destination.
// Reuse immutable blend entry lists where practical.
// Painter shouldRepaint must compare ordered source values.
// Avoid rebuilding static image providers on animation ticks.
// Repaint animated effect backgrounds inside their own boundary.
// Keep static texture previews inside their own RepaintBoundary.
// Do not make the entire long home page one repaint boundary.
// Lazy construction prevents offscreen color and blur work.
// Profile level-five blur on low-end Android hardware.
// Verify Windows compositor behavior with the release executable.
// Avoid enormous sigma values that increase cost while reducing visible detail.
// Use a calibrated component blur before applying intensity scaling.
// Keep reflection gradients shader-simple and allocation-stable.
// Avoid per-frame list allocation in navigation animation builders.
// Do not decode the reference image more than once per ImageCache lifecycle.
// Treat saveLayer additions as reviewable performance changes.

// Cross-platform behavior
// Android and Windows must both use the same public intensity semantics.
// Android and Windows may render Gaussian edges with minor pixel variance.
// Golden tolerances must remain narrow enough to catch opaque regressions.
// Do not special-case Windows by silently disabling BackdropFilter.
// Do not special-case Android by silently reducing tint transparency.
// Android may disable only the unstable refraction shader while retaining blur.
// Standard blend lists use the lean standard runtime shader variant.
// The three-entry Logo Blend uses its lean ColorBurn-or-ColorDodge,
// LinearLight, and Lab specialization for the light and dark tokens.
// Source PlusLighter/PlusDarker presets use the lean non-Lab arithmetic shader.
// Standalone Lab lighten, darken, and linear-light presets use a Lab-only shader.
// Other extended source modes use the complete extended shader variant.
// Unsupported source Lab shaders use the documented portable mappings.
// Runtime shader availability must not remove controls from the example.
// Asset paths use Flutter bundle notation on every platform.
// The exact upstream WebP is decoded losslessly to the bundled PNG asset.
// The PNG pixels must remain identical to the upstream WebP decode.
// Font loading must not affect backdrop filter bounds.
// Device pixel ratio must not alter logical bar metrics.
// Safe-area padding resolves from the active platform MediaQuery.
// Android edge-to-edge mode keeps both system-bar colors transparent.
// Android icon brightness follows the resolved light or dark color scheme.
// System contrast scrims stay disabled so they cannot make glass opaque.
// Top-bar surfaces paint before applying the status-bar content inset.
// The status-bar region therefore shares the same opaque or glass surface.
// Title controls remain below status icons even while their surface extends.
// Initial scroll content reserves the top system inset and expanded bar height.
// That leading reservation belongs to the scrollable rather than the viewport.
// Upward scrolling may consequently carry page content behind the title glass.
// Bottom controls remain above Android gesture-navigation insets.
// Page backgrounds may continue behind the gesture indicator in edge-to-edge.
// Hosted snackbars reserve the measured bottom-navigation height when extended.
// Animated bottom-bar wrappers must report both initial and changing heights.
// Snackbar surfaces must never be occluded by a later-painted navigation layer.
// Desktop window resize must preserve finite blur bounds.
// Narrow mobile layouts must keep the floating pill within horizontal padding.
// Wide layouts use navigation rail and do not construct hidden bottom glass.
// Route transitions must not leave stale filtered frames.
// Popup overlays must render above page glass.
// Window dialogs must render above page glass.
// Platform brightness selects matching preset blend tables.
// A theme-mode switch must repaint all active blur colors.

// Verification
// Unit tests verify five monotonic intensity levels.
// Unit tests verify standard intensity identity.
// Widget tests verify BackdropFilter presence when enabled.
// Widget tests verify BackdropFilter absence when disabled.
// Widget tests verify reflection presence when enabled.
// Widget tests verify reflection absence when disabled.
// Widget tests verify ordered blend painter creation.
// Widget tests verify explicit texture blur omits reflection.
// Widget tests verify root body extension behind bottom glass.
// Widget tests verify nested body extension behind top glass.
// Widget tests use nonzero Android top and bottom safe-area values.
// Widget tests verify initial content starts below the expanded title surface.
// Widget tests verify scrolling moves that content behind the title surface.
// Widget tests verify hosted feedback ends above animated bottom navigation.
// Widget tests verify transparent system-bar styles and disabled contrast scrims.
// Widget tests verify level-five tint alpha for top navigation.
// Widget tests verify level-five tint alpha for floating navigation.
// Widget tests verify level-five tint alpha for regular navigation.
// Example tests verify exact 280dp blur preview heights.
// Example tests verify five sliders in each of the three control cards.
// Example tests verify initial source blur values.
// Example tests verify source blend preset order.
// Example tests verify Texture, Foreground, and Progressive source sections.
// Example tests verify the exact upstream image pixels are rendered.
// Focused goldens protect all three preview compositions.
// Golden review checks transparency, blur structure, and edge reflection.
// Full analyzer output must contain no issues before release.
// Full package and example tests must pass before release.
// Scope verification must keep the requested comment ratio at or above 50%.
// Android release verification checks arm64-v8a contents and signature.
// Windows release verification checks packaged runtime dependencies.
// Any unverified visual claim remains incomplete rather than assumed correct.
