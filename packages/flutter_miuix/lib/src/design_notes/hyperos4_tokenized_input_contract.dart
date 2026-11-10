// HyperOS 4 tokenized PIN and tag-input implementation contract.
//
// Scope and evidence boundary
// ---------------------------
// This contract covers MiuixPinInput, MiuixOtpInput, and MiuixTagInput.
// These are flutter_miuix application extensions, not private Xiaomi APIs.
// Xiaomi's public material does not publish their exact dp geometry.
// Default numbers are project calibrations and remain theme-overridable.
// The reusable library owns all behavior described here.
// Example pages provide demonstrations and regression scenes only.
// Passing symbol coverage is not proof of material or interaction fidelity.
//
// Shared editable-field geometry
// ------------------------------
// Ordinary input constructors follow HyperOS 4 editable-field geometry.
// textFieldCornerRadius is the shared default shape role.
// A caller-provided finite radius overrides the shared theme role.
// Negative explicit radii are clamped before paint.
// The NaN default is a resolution sentinel and never reaches rendering.
// Shape changes must not change input value, focus, or validation semantics.
// Shape changes must not change controller ownership.
// Source constructors preserve former geometry only when explicitly selected.
// Source compatibility must not become the ordinary default again.
//
// PIN input geometry and state
// ----------------------------
// The ordinary PIN input resolves each cell through textFieldCornerRadius.
// Every cell retains the authored 48dp project extent.
// Every neighboring cell retains the authored directional spacing.
// The old 14dp cell shape is available through MiuixPinInput.source.
// MiuixOtpInput exposes the same current geometry as its PIN parent.
// MiuixOtpInput.source exposes the same old geometry as PinInput.source.
// The active cell follows text length and current focus.
// Filled cells retain their stable positions when another character arrives.
// Error state takes precedence over focused and idle outline colors.
// Focused and error outlines use the authored stronger stroke width.
// Idle cells retain the authored lower stroke width.
// Disabled content uses the semantic disabled foreground.
// Obscured input paints exactly one authored obscuring character per cell.
// Digits-only formatting remains independent from visual geometry.
// Length limiting occurs before completion publication.
// The hidden TextField remains one logical editing control.
// Visible cells must not each create an independent editable semantic node.
// Tapping the visible cell row requests focus on the hidden editor.
// Disabled input cannot request focus through the visible row.
//
// PIN input motion and feedback
// -----------------------------
// Cell outline changes use inputStateMotion.
// Each cell uses the same duration and easing for one logical change.
// Retargeting focus continues from the currently sampled outline.
// MediaQuery.disableAnimations is authoritative for reduced motion.
// Enabling reduced motion discards a sampled outline midpoint.
// Reduced motion retains final color, width, geometry, and semantics.
// A character-count change emits the text-handle semantic haptic role.
// Reaching the complete authored length emits confirmation once.
// Programmatic focus changes do not synthesize completion feedback.
// Replacing caller-owned controllers detaches the old listener.
// Replacing caller-owned focus nodes detaches the old listener.
// Caller-owned objects are never disposed by the widget.
// Internally created objects are disposed when the widget leaves the tree.
//
// Tag-input material
// ------------------
// The ordinary tag input owns one local HyperOS 4 content-glass surface.
// Its blur resolves from contentSurfaceBlur.
// Its tint resolves from contentSurfaceTintOpacity.
// Its radius resolves from textFieldCornerRadius.
// The five-level glass setting scales the complete local material.
// The global enableGlass switch remains the performance authority.
// The visible blur is clipped to the same continuous input silhouette.
// Transparent corners must not contain a rectangular opaque fill.
// Focus and validation outlines follow the same clipped silhouette.
// An explicit glass=false disables backdrop sampling without changing layout.
// MiuixTagInput.source retains the former opaque 18dp surface.
// The source path does not insert a hidden MiuixGlass descendant.
// Explicit blur, tint, and radius values take priority over theme defaults.
// The input label remains outside the local backdrop surface.
// The validation message remains below the local backdrop surface.
// The field itself retains its authored minimum height.
//
// Nested material hierarchy
// -------------------------
// The tag field samples its backdrop once and only once.
// Input chips inside a glass tag field do not create nested backdrop filters.
// Chip semantic colors remain visible on the shared input plane.
// Chip deletion indication remains clipped to the chip silhouette.
// Disabling nested blur does not disable chip deletion or tag selection.
// Strong glass intensity must not turn nested tags into cloudy white islands.
// A field with one or many tags still owns exactly one MiuixGlass layer.
// A field with no tags still owns the same material and geometry.
// A source field with tags owns no MiuixGlass layer.
//
// Tag validation and controller behavior
// --------------------------------------
// Submitted tags are trimmed before validation.
// Optional normalization runs before duplicate and length checks.
// Empty submissions do not create tags or validation noise.
// Maximum grapheme length is checked without splitting user characters.
// Maximum tag count is checked before controller mutation.
// Caller validation runs before insertion.
// Duplicate comparison remains case-insensitive by default.
// A rejected tag preserves editable text for correction.
// A successful tag clears editable text and publishes an immutable copy.
// Separator parsing accepts authored Chinese and Western separators.
// Only completed pieces are committed while the final tail remains editable.
// Backspace on an empty editor removes the final existing tag.
// Backspace with non-empty text remains owned by the text editor.
// Disabled input does not remove tags through keyboard handling.
// Successful insertion emits confirmation feedback once.
// Rejection emits the gesture-threshold semantic feedback once.
// Keyboard removal emits toggle-off feedback once.
// Replacing the tag controller clears validation belonging to the old record.
// Tag, text, and focus controllers remain independently replaceable.
// Detached controllers cannot continue rebuilding the current widget.
//
// Tag-input motion and accessibility
// ----------------------------------
// Focus and validation outlines use inputStateMotion.
// Border color and border width share one logical duration.
// An error retargets the current focus outline rather than snapping from idle.
// Clearing an error retargets from the currently painted error outline.
// Reduced motion publishes both final border color and width immediately.
// A policy change replaces only the animation state, not the logical content.
// Validation text remains readable and tied to the field's semantic context.
// The inner TextField retains native editing and selection accessibility.
// Chips retain their input/deletion semantics inside the wrapping surface.
// Large text may wrap chips without expanding a blur layer to the viewport.
// RTL layout retains directional label, padding, and chip flow behavior.
//
// Verification obligations
// ------------------------
// Tests inspect theme-driven PIN cell radius.
// Tests inspect the PIN source 14dp compatibility radius.
// Tests inspect inputStateMotion on every PIN cell.
// Tests inspect PIN reduced-motion outline endpoints.
// Tests retain length limiting and completion callbacks.
// Tests inspect the ordinary tag input MiuixSurface.
// Tests inspect tag blur, tint, and editable-field radius tokens.
// Tests prove one tagged field creates only one glass layer.
// Tests inspect the tag source opaque 18dp compatibility path.
// Tests retarget focus and validation before enabling reduced motion.
// Tests inspect zero-duration color and width transition endpoints.
// Tests retain separator, duplicate, rejection, and backspace behavior.
// Tests retain independent controller replacement behavior.
// Static analysis and the complete package suite remain mandatory.
// Package structure and 50-percent comment gates remain mandatory.
// Every completed phase produces Android, Windows, and both library archives.
// Android output remains arm64-v8a and test-signed within the stated boundary.
// Windows output passes the hidden responsiveness smoke check.
// Release retention runs only after every build and verification succeeds.
