// HyperOS 4 control-surface and process-row implementation contract.
//
// Status and provenance
// ---------------------
// These widgets are flutter_miuix application extensions.
// They are not presented as private Xiaomi APIs.
// Xiaomi does not publish developer dp values for these extension widgets.
// Geometry below is therefore project-calibrated and theme-overridable.
// Official promotional material informs hierarchy and material direction only.
// Network rumors about a complete Control Center layout are not normative here.
// The library owns the behavior; the example only demonstrates the result.
//
// Control-center tile material
// ----------------------------
// The ordinary tile constructor uses the HyperOS 4 application default.
// Its rounded local surface may sample real page content behind the tile.
// Backdrop blur must remain clipped to the same continuous tile silhouette.
// Tint must remain semantic in light and dark color schemes.
// Edge reflection must never extend into transparent tile corners.
// A rectangular shadow or opaque backing plate is not permitted.
// The cardCornerRadius token supplies the default outer shape.
// The contentSurfaceBlur token supplies the default backdrop sigma.
// The contentSurfaceTintOpacity token supplies the standard-level tint.
// The global five-level glass setting scales the complete material recipe.
// Intense glass must still reveal background chroma rather than become white.
// Disabling global glass keeps the same local shape and content dimensions.
// The widget-level glass flag may explicitly disable backdrop material.
// Caller blur and opacity values take priority over theme defaults.
// Caller cornerRadius takes priority over the card geometry token.
// Invalid negative visual radius is clamped before reaching the surface.
// The NaN default remains an internal sentinel rather than painted geometry.
// The named source constructor restores the former opaque compatibility path.
// The source path retains the former 20dp project radius.
// The source path does not insert a hidden MiuixGlass descendant.
// The source path remains theme-colored rather than using a raw white fill.
// Source compatibility must not become the ordinary constructor default again.
//
// Control-slider tile material
// ----------------------------
// The compact slider tile follows the same local content-material hierarchy.
// Its ordinary constructor enables clipped glass by default.
// Its backdrop role uses contentSurfaceBlur.
// Its tint role uses contentSurfaceTintOpacity.
// Its default continuous corner uses cardCornerRadius.
// The compact layout does not imply an opaque or rectangular backing layer.
// The icon well remains inside the one outer material surface.
// The slider track does not create a second full-card blur layer.
// The percent label remains above the same local backdrop sample.
// Caller glass values override role defaults without changing slider math.
// The global five-level glass setting scales this surface like other cards.
// A globally disabled glass setting retains the same compact geometry.
// The named source constructor restores the former opaque path explicitly.
// The source constructor retains the former 18dp project radius.
// The source constructor does not build a hidden MiuixGlass descendant.
// The ordinary and source paths return identical normalized values.
// The ordinary and source paths expose the same semantic slider range.
// Zero-width ranges remain disabled and never divide by zero.
// Non-finite inputs are normalized before reaching the slider renderer.
// Callback values remain clamped to the authored minimum and maximum.
// A callback is emitted only when the normalized value meaningfully changes.
//
// Control-slider gesture ownership
// --------------------------------
// Horizontal movement beginning on the slider belongs to the value control.
// An ancestor PageView must not win that same horizontal drag.
// The control continues to receive pointer updates after exceeding touch slop.
// Dragging left lowers a left-to-right value without advancing the page.
// Dragging right raises a left-to-right value without reversing the page.
// Directional value behavior remains delegated to the shared MiuixSlider.
// A vertical gesture is not converted into an invented horizontal value jump.
// The surrounding tile does not add a competing horizontal recognizer.
// Direct manipulation remains immediate rather than eased behind the pointer.
// Programmatic value changes retain the shared slider motion policy.
// Reduced motion does not disable direct manipulation.
// Disabled zero-range sliders remain silent inside a pager.
// Slider haptics remain semantic and are not emitted by page motion.
// A completed slider drag must leave the PageController on the original page.
// The behavior must hold in a reusable library consumer, not only the example.
//
// Control-center tile state
// -------------------------
// Enabled and disabled surfaces use semantic container roles.
// Enabled and disabled icon wells use semantic primary/container roles.
// Enabled and disabled title text retain sufficient contrast.
// Optional value text remains subordinate to the title.
// Long titles and values remain one line and ellipsize under narrow width.
// The compact tile must not overflow a 96dp application column.
// An enabled tile with a callback exposes one interactive surface.
// A disabled tile must not invoke the callback.
// A callback-free tile must not invent an accessibility tap action.
// State colors share the inputStateMotion theme channel.
// Color transitions use the same easing and logical state boundary.
// Direct pointer feedback remains owned by MiuixSurface indication.
// A state transition must not resize the tile.
// A state transition must not replace the semantic label.
// Changing glass strength must not change selection or enabled semantics.
// MediaQuery.disableAnimations is authoritative for reduced motion.
// Reduced motion publishes the enabled-state endpoint in one frame.
// Switching reduced motion during a transition discards the sampled midpoint.
// No animation controller is retained after the stateless tile leaves the tree.
//
// Stepper-row process semantics
// -----------------------------
// A stepper row exposes pending, current, completed, and error states.
// The completed bool remains a source-compatible shorthand.
// An explicit state takes priority over the completed shorthand.
// Pending uses a secondary semantic marker.
// Current uses the primary semantic marker.
// Completed uses the primary semantic marker and confirmation glyph.
// Error uses the error semantic marker and close glyph.
// Marker foreground always comes from the matching on-color role.
// A caller-provided icon occupies the same stable marker box.
// The marker box remains 32dp while its content changes.
// The complete row retains a minimum 56dp interaction height.
// Marker changes do not alter title or trailing layout coordinates.
// Optional subtitle remains below the title and may occupy two lines.
// Optional trailing content remains aligned after the text column.
// The current title receives a stronger weight than resting states.
// Disabled title contrast remains visibly subordinate but readable.
// The semantic selected flag is true only for the current process state.
// Completed is not incorrectly announced as the currently selected step.
// Error is not incorrectly announced as a disabled row.
// The semantic label includes the subtitle when one is authored.
// The enabled flag follows the public enabled property.
//
// Stepper-row motion
// ------------------
// One logical process change uses one shared processStateMotion duration.
// Marker fill interpolates continuously between semantic colors.
// Marker glyphs cross-fade rather than disappearing between frames.
// Marker glyphs use a subtle scale entrance on the same timeline.
// Title weight changes on the same process timeline.
// The transition does not animate row height or horizontal position.
// The transition does not synthesize a value callback.
// The transition does not synthesize haptic feedback on programmatic rebuilds.
// A user tap emits the existing segment semantic haptic exactly once.
// Disabled rows remain silent and noninteractive.
// Callback-free rows remain silent and noninteractive.
// MediaQuery.disableAnimations reduces every autonomous channel to zero.
// Reduced motion retains the same final marker color and glyph.
// Reduced motion retains the same final title weight.
// Changing motion policy mid-transition discards intermediate marker color.
// AnimatedSwitcher content identity follows the resolved process state.
// Custom icons retain state identity even when their widget instance is reused.
// No outgoing process glyph may retain pointer or semantic actions.
//
// Shared row geometry and interaction
// -----------------------------------
// The press indication uses collectionRowCornerRadius from the theme.
// The visual process marker remains circular inside that row boundary.
// The press shape and indication clip must agree at every corner.
// A squircle-enabled application may still use the shared pressable shape path.
// Horizontal padding remains symmetric for LTR and RTL text.
// Trailing placement follows Directionality through the Row layout.
// Text scaling must not clip the marker or trailing slot.
// Keyboard activation must use the same callback transaction as pointer input.
// Desktop hover and focus feedback remain inside the row silhouette.
// Android haptics use the package semantic role and platform fallback.
// Windows retains a safe non-native fallback without throwing.
//
// Verification obligations
// ------------------------
// Tests inspect the ordinary tile's MiuixGlass presence.
// Tests inspect theme-provided blur, tint, and radius values.
// Tests inspect the source tile's opaque 20dp compatibility path.
// Tests retain the narrow-column overflow regression.
// Tests inspect the configured input-state duration.
// Tests change stepper state through a retained widget identity.
// Tests inspect processStateMotion on the glyph transition.
// Tests inspect collectionRowCornerRadius on the pressable boundary.
// Tests inspect the completed endpoint after the transition.
// Tests inspect the zero-duration reduced-motion endpoint.
// Static analysis must remain clean after implementation changes.
// The complete package test suite must remain green.
// Package structure and public component-name verification remain mandatory.
// The hand-maintained comment-ratio gate remains mandatory.
// Android Release output must remain arm64-v8a only.
// Android package name and monotonically increasing versionCode are verified.
// Android test signing must not be described as production signing.
// Windows Release output must pass the hidden responsiveness smoke check.
// Android and Windows reusable library archives include these public changes.
// A completed modification phase requires one complete Release cycle.
// Old checkpoints are pruned only after every release gate succeeds.
