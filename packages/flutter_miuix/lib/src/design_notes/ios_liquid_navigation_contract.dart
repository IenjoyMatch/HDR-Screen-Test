// iOS-like liquid navigation source-parity contract.
//
// Current unified example integration
// -----------------------------------
// The example exposes one floating-navigation presentation from 2026-08-24.
// That presentation is MiuixIosLiquidGlassNavigationBar.
// There is no user-facing default-versus-iOS style switch.
// The older MiuixFloatingNavigationBar remains public for API compatibility.
// Applications may still construct that legacy widget explicitly.
// Persisted style and alignment fields remain readable during migration.
// Those fields do not alter the unified example surface.
// Icon-only, text-only, and icon-with-text modes remain supported.
// Every destination keeps the same horizontal allocation in every locale.
// Optical and motion behavior begins with the current upstream liquid example.
// Runtime screenshots additionally govern platform-specific safety revisions.
// The panel uses 40 percent tint and 8dp blur.
// Stable desktop lens backends additionally use 1.5x vibrancy and 24dp lens
// refraction. Android prioritizes a directly composited, visible engine blur.
// Its BloomStroke highlight follows a quantized device-gravity direction.
// The selected destination owns a fixed 56dp circular liquid lens.
// That lens grows from zero to 10dp depth and 14dp refraction while pressed.
// Its pressed chromatic aberration is 0.5 and its inner shadow is eight dp.
// The circular selector grows from 56dp toward 78dp on contact.
// Velocity stretches X and compresses Y within the upstream 20 percent clamp.
// The complete panel receives the source's subtle four-dp rubber-band shift.
// Pointer movement retargets a critically damped 1/1000 value spring.
// Release rounds to the closest logical item and springs residual motion away.
// Reduced-motion mode commits the destination without interpolation.
// Cancellation returns to the last committed destination.
// Ordinary taps must not be reset by a losing horizontal-drag recognizer.
// The panel accepts two through five destinations and divides space equally.
// LTR and RTL convert logical and visual positions before callback dispatch.
// The selector remains paint-only so it cannot compete for gesture ownership.
// The page behind the pill remains visible outside the capsule bounds.
// The 78dp pressed selector is a sibling and must not be clipped to 64dp.
// Flutter splits animation invalidation into background, selector, and light.
// Position-only frames retain both expensive BackdropFilter widget subtrees.
// This is a rendering optimization and does not alter upstream motion values.
//
// Authority
// ---------
// The visual authority is the current compose-miuix checkout at commit
// 201276038c012b3864a5ea1843cb818da6af6b66 (2026-08-24).
// The exact source file is component/liquid/LiquidGlassNavigationBar.kt.
// Motion authority also includes component/animation/DampedDragAnimation.kt.
// Press-light authority also includes component/animation/InteractiveHighlight.kt.
// Refraction authority also includes component/liquid/Lens.kt.
// AppContent.kt selects this surface when floatingNavigationBarStyle is one.
// SettingsPage.kt labels that option iOS-like.
// AppState.kt stores the option independently from floating alignment.
// The implementation is example-originated rather than a Material pattern.
// The Flutter public widget preserves that source identity.
// The widget is not a display mode of the regular NavigationBar.
// The widget is not a color variant of FloatingNavigationBar.
// The widget is a third navigation surface with its own metrics.
// Visible labels may be localized by an application.
// Public Dart identifiers remain English.
// Source measurements remain logical pixels on every Flutter platform.
// No measurement in this contract comes from visual guessing.
// Every number below maps to a constant or expression in the Kotlin source.
// The contract is intentionally more precise than a screenshot comparison.
// It exists to stop future refactors from collapsing distinct source styles.
// It also explains why the widget belongs in its own Dart source file.
//
// Public API
// ----------
// MiuixIosLiquidGlassNavigationBar is a StatefulWidget.
// The items argument is required.
// The selectedIndex argument is required.
// The onDestinationSelected callback is required.
// The supported item count is two through five.
// The constructor asserts that supported source range.
// Each item reuses the MiuixNavigationItem data contract.
// Each item supplies a visible label.
// Each item supplies an icon.
// A selected icon may replace the ordinary icon in the indicator layer.
// The owning pager remains the source of truth for selectedIndex.
// Internal visual position may temporarily be fractional during motion.
// showBlur permits applications to disable the liquid backdrop effect.
// Theme enableGlass remains the global blur gate.
// Both gates must be true before BackdropFilter is created.
// defaultWindowInsetsPadding controls bottom system inset behavior.
// Disabling it removes only the outside bottom padding.
// Disabling it does not change the 64dp panel.
// The widget does not own route navigation.
// The callback lets the application animate its pager.
// The widget does not translate destination labels.
// The widget exposes stable semantics for assistive technology.
// Stable ValueKeys exist only to support exact regression checks.
// The keys do not affect production layout.
// The API does not expose Material NavigationBar properties.
// The API does not expose regular floating-bar alignment.
// The iOS-like style always uses the source full-width panel.
//
// Outer placement
// ---------------
// The outer widget fills the horizontal space offered by its bottom-bar host.
// It applies 24dp at the physical left edge.
// It applies 24dp at the physical right edge.
// The source uses start and end values of 24dp.
// Equal values make the geometry direction-independent.
// The panel width is therefore host width minus 48dp.
// A 390dp host produces a 342dp panel.
// The panel is horizontally centered by those equal insets.
// There is no start, center, or end alignment option for this style.
// FloatingNavigationBar alignment applies only to the default style.
// The settings page hides alignment while iOS-like is selected.
// The widget occupies only panel height plus bottom padding.
// It must never expand to the whole Scaffold height.
// It must never reserve an opaque rectangle behind the capsule.
// The application Scaffold uses extendBody for floating styles.
// Body painting therefore continues behind all non-panel space.
// Transparent outside space must reveal page content.
// Transparent outside space must not reveal a replacement surface color.
// The panel's bottom edge is separated from the window edge.
// On a platform with no navigation inset that separation is 36dp.
// With a non-zero navigation inset it is 8dp plus the inset.
// The source has a special iOS value of 20dp.
// Flutter target-platform selection maps iOS to the exact fixed 20dp value.
// Android consumes the plugin's navigationBars-only inset stream.
// Android captionBar is deliberately excluded from this bottom calculation.
// Before the native stream emits, MediaQuery supplies the synchronous fallback.
// Android gesture navigation therefore remains safe.
// Windows with no inset receives the exact 36dp fallback.
// A 390 by 844 no-inset test places panel bottom at 808dp.
// Its transparent host continues to the screen bottom at 844dp.
// Caption-bar height does not alter the panel height.
// System padding stays outside the glass layer.
// Shadows may paint outside panel bounds but do not change layout bounds.
//
// Panel geometry
// --------------
// The outer panel height is exactly 64dp.
// The outer panel shape is a circle-derived pill.
// Its effective radius is 32dp.
// The panel contains 4dp of padding on all four sides.
// The usable tab strip height is therefore 56dp.
// The usable tab strip width is panel width minus 8dp.
// Five items in a 342dp panel receive 66.8dp each.
// Every item receives exactly equal width.
// Labels do not change destination width.
// Badges do not change destination width.
// Selected state does not change destination width.
// Press state does not change the Row's measured width.
// Drag state does not change the Row's measured width.
// The panel uses a Stack so indicator and base content share geometry.
// The base content begins at x equals 4dp.
// The indicator is centered inside the current equal-width tab slot.
// The indicator top is exactly 4dp.
// The indicator height is exactly 56dp.
// The indicator width is exactly 56dp.
// The indicator radius is 28dp.
// The indicator clips all selected-content overflow.
// The panel clips all blur and content to its 32dp radius.
// The drop shadow is painted outside the clipping layer.
// The panel remains one continuous hit-test region.
// Tab hit regions divide the 56dp content width evenly.
// The remaining 4dp vertical edges belong to the panel gesture region.
// The panel never falls back to Material NavigationBar height.
// The panel never uses the 52dp default floating-bar minimum.
// The panel never uses regular navigation's 64dp icon-and-label row.
// Similar heights do not make those components interchangeable.
// Layout tests assert panel left, right, height, and bottom.
// Layout tests assert indicator height, top inset, and fixed circular width.
//
// Tab content
// -----------
// Every tab is a vertically centered Column.
// The icon has an exact 22dp square box.
// The source icon size is 22dp.
// IconTheme carries both source size and active color.
// The icon-to-label gap is exactly 1dp.
// The label font size is exactly 11sp.
// The label font weight is normal.
// The label uses one line.
// The label truncates with an ellipsis when necessary.
// The label uses a compact line height to retain source centering.
// Base tab content uses onSurface color.
// Selected overlay content uses primary color.
// The selected overlay may use selectedIcon when supplied.
// The base row uses the ordinary icon for every destination.
// The overlay row paints all destinations offscreen.
// Only the centered content of one overlay tab is revealed by the indicator.
// Translating that overlay row keeps selected glyphs pixel-aligned.
// The overlay translation equals negative visual index times tab width.
// The indicator translation equals positive visual index times tab width.
// Those transformations cancel for the revealed destination.
// Fractional drag values reveal a continuous transition between destinations.
// No text is reconstructed during a drag.
// No icon is swapped at a fractional boundary.
// Badges supplied inside an icon remain part of both paint layers.
// The overlay content ignores pointers.
// The base content owns pointer and semantic behavior.
// Overlay content must not create duplicate selectable semantics.
// Tab content never shows a Material splash.
// Tab content never shows a Material hover fill.
// Press feedback belongs to the liquid indicator scale.
// Item order exactly follows the supplied list.
// The localized example order remains Home, Icons, Colors, Text, Settings.
//
// Surface and glass
// -----------------
// The non-blurred panel uses surfaceContainer at full opacity.
// The blurred panel uses surfaceContainer at 40 percent opacity.
// The source samples content behind the panel.
// Flutter performs that sampling with BackdropFilter.
// The outer blur base sigma is 8 on both axes before intensity scaling.
// The filter is clipped to the 32dp panel pill.
// Stable desktop shader-filter backends reproduce the 24dp lens height.
// The same desktop shader uses the source negative 24dp refraction amount.
// Android deliberately uses one exact-bounds engine blur plane instead.
// Android does not wrap BackdropFilter in ColorFiltered because that creates
// an empty offscreen backdrop on affected Impeller devices.
// It uses direct engine blur followed by the same semantic surface tint.
// Android never binds the device-dependent ImageFilter.shader input texture.
// The final capsule ClipRRect still owns the complete visible boundary.
// Sampling padding must never contribute layout width or layout height.
// Sampling padding must never become a hit-test region.
// Sampling padding must never contribute an accessibility node.
// Optional source-mode sampling padding remains centered on its local lens.
// The panel scale transform runs outside the visible capsule clip.
// The page is therefore still observable through every non-capsule corner.
// The stable Android and failed-shader fallbacks never expand their blur plane.
// Shader load completion may replace the filter but not rebuild geometry.
// Device-pixel conversion applies to shader uniforms, not widget layout.
// A three-times-density host therefore retains a logical 32dp pill radius.
// Its shader receives the exact visible panel bounds in physical pixels.
// Press-scale reach remains 16 logical dp on every device density.
// The main panel does not expand its backdrop beyond the bottom window edge.
// The lens filter is composed outside the 8dp blur filter.
// Unsupported shader-image-filter hosts retain direct backdrop blur and tint.
// The source BloomStroke uses a one-dp outer width and two light sources.
// Its stroke color is white at 12 percent alpha.
// Its inner blur radius is 2dp.
// Its primary intensity is one and its secondary intensity is .4.
// Its secondary light remains at (.5, .8, -.5).
// Its primary light rotates around the source (.5, .7) reference point.
// Device gravity direction is quantized in exact three-degree steps.
// A near-flat device pins gravity direction to negative ninety degrees.
// The base panel adds negative forty-five degrees to gravity direction.
// The pressed selector adds positive ninety degrees to gravity direction.
// MiuixHighlightOverlay shares the library's BloomStroke SDF runtime shader.
// The highlight layer ignores pointers.
// The source shadow radius is 10dp.
// The source shadow color is black.
// The source light-theme shadow alpha is 10 percent.
// The source dark-theme shadow alpha is 20 percent.
// The Flutter BoxShadow switches between those exact brightness values.
// Shadow elevation is not represented by a Material elevation widget.
// Avoiding Material elevation prevents tint overlays.
// In light glass mode the resting indicator adds 10 percent black.
// In dark glass mode the resting indicator adds 10 percent white.
// In non-glass mode the indicator uses primary at 15 percent.
// Selected icon and label remain primary in every mode.
// During press the indicator lens height grows from zero to 10dp.
// During press the indicator refraction amount grows from zero to 14dp.
// The pressed indicator enables the source depth term.
// The pressed indicator enables .5 chromatic aberration.
// Its seven dispersion samples follow Lens.kt red-to-purple weights.
// Shader loading cannot change panel dimensions, hit testing, or semantics.
// Every optical layer respects both showBlur and enableGlass.
// High-contrast themes may still derive colors from ColorScheme.
// Surface opacity must not become an opaque reserved bottom strip.
// The Scaffold body remains visible behind the panel and its outside space.

// Runtime lens pipeline
// ---------------------
// The optical material follows AndroidLiquidGlass commit 65ab177.
// Its bottom-tab backdrop applies 1.5x vibrancy, then 8dp blur, then lens.
// Vibrancy uses the same Rec. 709 coefficients .213, .715, and .072.
// The Flutter shader performs that linear color transform at sample time.
// The outer rounded-rectangle lens remains 24dp high with 24dp displacement.
// miuix_liquid_lens.frag is a Flutter ImageFilter runtime-effect asset.
// The shader declares u_size before every caller-controlled float.
// Flutter owns u_size float slots zero and one for shader image filters.
// Shape width and height occupy caller slots two and three.
// Sampling-padding offsets occupy caller slots four and five.
// The main panel uses zero offsets because its signed displacement points in.
// Caller-controlled rounded-corner radii occupy float slots six through nine.
// Radius order is top-left, top-right, bottom-right, then bottom-left.
// Refraction height occupies float slot ten.
// Signed refraction amount occupies float slot eleven.
// Depth-effect enablement occupies float slot twelve.
// Chromatic-aberration strength occupies float slot thirteen.
// Vibrancy saturation occupies float slot fourteen.
// Every geometric uniform converts from logical dp to physical pixels.
// That matches the physical bound-texture size supplied in u_size.
// The input sampler remains the final runtime-effect uniform.
// Flutter supplies that sampler from the backdrop-filter destination texture.
// Source Lens.kt negates its positive public refraction amount.
// The Dart adapter therefore writes a negative value into slot eleven.
// Rounded-rectangle distance uses the corner selected by coordinate quadrant.
// The edge gradient matches Lens.kt's straight-edge and corner branches.
// Circle mapping clamps its input before evaluating the square root.
// Interior pixels deeper than the refraction height sample without displacement.
// A zero refraction height also samples without displacement.
// Refraction sampling clamps half a pixel inside the destination texture.
// OpenGLES Impeller flips sampler Y to match Flutter runtime-effect coordinates.
// The depth term adds the normalized centered coordinate to the edge normal.
// Non-depth outer-panel refraction uses only the rounded-edge normal.
// Dispersion intensity retains the source signed x*y quadrant expression.
// The red dispersion sample uses positive full displacement.
// The orange sample uses positive two-thirds displacement.
// The yellow sample uses positive one-third displacement.
// The green sample uses the undispersed refracted coordinate.
// The cyan sample uses negative one-third displacement.
// The blue sample uses negative two-thirds displacement.
// The purple sample uses negative full displacement.
// Channel and alpha divisors remain identical to Lens.kt.
// The outer panel composes lens outside blur rather than blurring refracted output.
// Flutter cannot sample Compose's combined panel backdrop, so the indicator
// retains its separately tuned 4dp source-compatibility blur before refraction.
// Default HyperOS geometry never inserts that second indicator filter.
// Android never loads the runtime lens after repeated real-device split input.
// It uses exact-bounds ImageFilter.blur with tint inside BackdropFilter.
// Skia or shader compilation failure retains that same stable material path.
// Vibrancy mixes sampled RGB away from Rec. 709 luminance by a factor of 1.5.
// Its output is clamped to alpha so the runtime filter remains premultiplied.
// Each widget instance owns a mutable FragmentShader.
// FragmentShader instances are disposed with their owning State.
// The asynchronously compiled FragmentProgram may be shared by engine caches.
// Package consumers first resolve the packages/flutter_miuix asset namespace.
// Root tests and the example may resolve the unprefixed shader asset key.
// Failure of both keys leaves a blur-only BackdropFilter in place.
// A failed shader compilation must not hide icons or disable navigation.
// Async completion checks mounted before installing a shader or calling setState.

// Runtime highlight pipeline
// --------------------------
// MiuixHighlightOverlay is a package-level reusable effects primitive.
// It paints ordinary child content before the non-interactive highlight layer.
// It never introduces its own gesture recognizer or semantic node.
// Its FragmentProgram is shared while each instance owns a mutable shader.
// It loads the same miuix_bloom_stroke.frag used by MiuixLayerBackdrop.
// The exact SDF shader receives all four equal pill radii.
// It reconstructs the source hemispheric rim normal from inner blur radius.
// It retains the source flat stroke-alpha band at the rounded edge.
// It evaluates both primary and secondary directional light dot products.
// It squares each non-negative light result before applying intensity.
// It composites the result with additive BlendMode.plus.
// The gradient fallback is used only before compilation or without support.
// Base-panel highlight opacity stays at .75 independently of press state.
// Indicator highlight opacity follows current press progress exactly.
// A sensor event does not rebuild the navigation geometry.
// Only a quantized gravity-angle change rebuilds the focused overlay subtree.
// Sensor streams are cancelled before AnimationControllers are disposed.
// Windows and test hosts without native sensors retain the flat default angle.

// Interaction state ownership
// ---------------------------
// _currentIndex represents the last logical destination accepted by the widget.
// _positionTarget represents the latest continuous spring destination.
// _position.value represents the currently painted continuous coordinate.
// Those three values are intentionally independent during motion.
// External selectedIndex changes update _currentIndex without firing callbacks.
// External selectedIndex changes animate toward their new clamped coordinate.
// A base-tab click changes _currentIndex before invoking the public callback.
// That ordering prevents a synchronous parent rebuild from restarting old motion.
// Clicking an already-current base tab does not duplicate the callback.
// Pressing the moving indicator begins visual feedback on raw pointer down.
// Releasing without a drag schedules the source deferred release.
// Horizontal-drag recognition marks the pointer as drag-owned.
// A raw pointer-up schedules a next-frame fallback release.
// A normal tap-up or drag-end invalidates that fallback before it can run.
// Drag end clears drag ownership before starting settle and release.
// Drag cancellation returns toward _currentIndex rather than a rounded stale value.
// Every new press invalidates a previously scheduled release epoch.
// Every immediate cancellation also invalidates a scheduled release epoch.
// Position listeners check deferred release without issuing layout setState calls.
// Listenable.merge rebuilds all paint channels in one AnimatedBuilder.
// The position controller itself reports current physical velocity.
// Spring interruption preserves that physical velocity unless explicitly seeded.
// New drag targets start from _positionTarget like Compose Animatable.targetValue.
// Using _position.value instead would lag the pointer during repeated updates.
// Raw panel drag distance does not clamp before fraction conversion.
// Its derived fraction clamps to the source negative-one through positive-one range.
// Text direction changes only the logical coordinate delta, not raw panel motion.
// The panel therefore follows the finger physically in both LTR and RTL.
// Disabled items remain visible but their base-tab recognizer is absent.
// Decorative selected copies remain excluded from hit testing and semantics.

// Paint and clip order
// --------------------
// The panel shadow is outside the rounded clip and never fills transparent corners.
// The panel tint is the first child inside the rounded clip.
// Source geometry paints its base BloomStroke after the tint.
// HyperOS geometry omits that outline because its lower secondary light reads
// as a white horizontal divider on bright Android content.
// Interactive press light precedes ordinary tab glyph content.
// Ordinary tab content precedes the moving indicator.
// The indicator owns its own rounded clip after anisotropic transformation.
// Resting indicator fill fades out as press progress approaches one.
// The three-percent pressed black fill fades in over that same progress.
// Selected glyph content scales from one to 1.2 only in glass mode.
// That scale substitutes the source hidden accent backdrop inside Flutter's layer model.
// Indicator BloomStroke follows selected glyph content and precedes inner shadow.
// Inner shadow uses the source eight-dp maximum blur and .15 black alpha.
// Lens filtering samples already-painted panel and ordinary tab content behind it.
// Refraction never changes the indicator's allocated 56dp width.
// Panel press scale is applied outside the complete clipped optical surface.
// Rubber-band translation is applied outside panel press scale.
// Outer placement padding remains outside both transforms.
// System bottom padding therefore never stretches or translates the glass capsule.
//
// Selection animation
// -------------------
// The visual selection coordinate is a double.
// Whole numbers identify settled destinations.
// Fractional values identify drag or spring positions.
// The owning selectedIndex is clamped before initialization.
// An unbounded AnimationController stores the coordinate.
// Manual clamping keeps the coordinate inside destination bounds.
// Programmatic selection begins the same press sequence as source animation.
// The source value spring stiffness is 1000.
// The Flutter value spring stiffness is also 1000.
// The source spring is critically damped.
// Flutter damping is computed as two times square root of stiffness.
// Spring mass is one.
// The animation stops before a new target starts.
// A selectedIndex update animates only when the delta is meaningful.
// The epsilon threshold is .001 destinations.
// Rebuilding with the same selectedIndex does not restart motion.
// Tapping a destination starts visual motion immediately.
// The callback then lets the owning pager follow.
// Parent rebuilds do not snap the ongoing indicator.
// Drag start immediately starts press progress and two scale springs.
// Press progress uses critical damping and stiffness 1000.
// Horizontal scale uses damping ratio .6 and stiffness 250.
// Vertical scale uses damping ratio .7 and stiffness 250.
// Both scales target the source 78 divided by 56 value.
// Release waits one frame before evaluating the position.
// Release then waits until position is within 2.5 percent of its full range.
// Drag update divides directional physical delta by tab width.
// Drag update therefore has one destination per tab-width movement.
// Drag update clamps at the first and last destinations.
// Drag end rounds to the closest destination.
// Drag end converts pixel velocity into destinations per second.
// That velocity seeds the stiffness-1000 settling spring.
// The current logical index, not a stale parent echo, suppresses duplicates.
// Travel velocity is normalized by the complete destination span.
// The normalized velocity is divided by ten for glass deformation.
// Horizontal scale divides by one minus .75 of clamped velocity.
// Vertical scale multiplies by one minus .25 of clamped velocity.
// Both velocity terms clamp independently to negative or positive .2.
// The opaque fallback intentionally receives no graphics-layer deformation.
// The old 140ms AnimatedScale is not source behavior and must not return.
// Scaling does not alter the indicator's layout allocation.
// Scaling does not alter tab widths.
// Scaling is clipped by the panel boundary where appropriate.
// The complete glass panel expands by at most 16dp divided by panel width.
// Destination changes must never use a hard linear jump.
//
// Current whole-panel interaction revision
// ----------------------------------------
// Commit bc4b939 replaces per-tab pointer clickables with one panel gesture.
// This is an upstream behavior change rather than a Flutter convenience.
// The panel gesture begins at the first raw pointer-down sample.
// The source maps that down position before observing any drag displacement.
// Consequently an unselected destination begins moving before pointer-up.
// That early visual motion does not imply an early application callback.
// Application selection changes only when the pointer sequence completes.
// Current index and animated target therefore remain separate state channels.
// The parent-selected index may arrive later through an asynchronous pager.
// Such a parent update retargets the same stiffness-1000 value spring.
// It also invokes the ordinary press-and-deferred-release sequence.
// The source touch mapping includes the panel's four-dp internal padding.
// Values inside the leading padding clamp to the first logical destination.
// Values inside the trailing padding clamp to the final logical destination.
// LTR uses the physical local x coordinate without mirroring.
// RTL subtracts physical x from the complete measured panel width first.
// The resulting logical x is truncated after division by equal tab width.
// Truncation matches Kotlin Float.toInt for the nonnegative clamped domain.
// Flutter applies the same rule before clamping to the authored item count.
// An application-disabled extension item cannot become the committed target.
// Touching such an item returns motion to the last committed enabled index.
// This disabled-item rule is a compatible extension to the source item model.
// A drag continues from the down-selected animation target, not current value.
// Each accepted horizontal delta is divided by the measured single-tab width.
// Physical delta changes sign in RTL before it reaches logical index space.
// A zero horizontal delta cannot retarget the value animation.
// Current and previous pointer positions must both remain inside the panel.
// A segment crossing outside is ignored without transferring gesture ownership.
// Later inside segments may continue because the source owner remains active.
// Drag-end rounds the animated target to the nearest logical destination.
// Drag cancellation never rounds or commits the transient animation target.
// Cancellation instead springs directly to the last committed current index.
// Both end paths independently return the rubber-band channel to zero.
// Their return spring retains damping one, stiffness 300, threshold .5px.
// The ordinary tap path uses the same commit and panel-return operations.
// Pointer-up is read by the panel owner before a competing tap recognizer.
// This preserves DampedDragAnimation's raw pointer-loop ordering in Flutter.
// Destination children therefore remain pointer-paint content, not tap owners.
// Their Semantics onTap action still activates the precise destination.
// Their focus action still activates the precise destination on key-up.
// Repeated semantic activation replays press feedback without duplicate callback.
// The decorative selected row remains excluded from all input and semantics.
// The indicator itself is IgnorePointer because it no longer owns the drag.
// Moving the indicator over another destination cannot steal the panel stream.
// Whole-panel ownership also prevents the root PageView from winning the drag.
// Outside 24dp horizontal placement margins remain page-owned transparent space.
// Bottom safe-area padding likewise remains outside the gesture region.
// Tests must begin the controller clock before sampling an intermediate frame.
// A first AnimationController tick establishes its epoch and has zero elapsed.
// Sampling only that tick would falsely report no motion after a valid down.
// The deterministic regression therefore pumps an epoch then a 50ms interval.
// It asserts no callback before up and a nonzero selector displacement.
// A second assertion commits exactly once after the same pointer reaches up.
// RTL drag coverage separately protects the physical-to-logical sign mapping.
// Source spring coverage separately protects value and scale intermediate frames.
// Geometry coverage separately protects the 64dp panel and 56dp selector bounds.
//
// Gesture behavior
// ----------------
// The complete 64dp panel is one opaque pointer-input region.
// Pointer-down maps its physical x coordinate to a logical tab immediately.
// Four-dp inner padding is subtracted before dividing by equal tab width.
// RTL mirrors physical x before calculating that logical destination.
// Down starts selector travel but does not emit the callback before release.
// A tap release commits the nearest enabled tab.
// Pressing anywhere in the panel activates indicator scale feedback.
// Releasing a tap removes scale feedback.
// Cancelling a tap removes scale feedback.
// Horizontal dragging may begin from any destination, not only the indicator.
// Both current and previous pointer positions gate accepted drag segments.
// A cancelled drag returns to the last committed current index.
// A completed drag rounds and commits the live target index.
// Horizontal dragging does not resize the panel.
// Horizontal dragging does not scroll the page behind the panel.
// Raw Listener pointer-down starts press before Flutter resolves touch slop.
// Destination children do not install competing pointer tap recognizers.
// Semantics and keyboard activation remain destination-specific.
// Pointer-up and whole-panel drag-end own separate release paths.
// Raw drag distance also drives the complete panel's rubber band.
// Rubber-band fraction is raw distance divided by full panel width.
// EaseOut maps that signed fraction to a maximum four-dp translation.
// Panel release uses critical damping and stiffness 300.
// Its source visibility threshold is .5 physical pixels.
// Outside transparent padding has no panel tap behavior.
// Page content behind outside padding remains visually available.
// Bottom safe padding is not a destination hit region.
// Repeated taps on the selected item do not duplicate callbacks.
// A drag settling on the selected item does not duplicate callbacks.
// A callback may animate a PageView.
// The PageView onPageChanged result may update selectedIndex later.
// The spring tolerates that asynchronous parent update.
// A callback may synchronously rebuild the entire application shell.
// AnimationController remains owned by the persistent keyed state.
// AnimatedSwitcher keys distinguish default and iOS-like surfaces.
// Changing styles disposes the old animation controller safely.
// No timer survives widget disposal.
// No future calls setState after disposal.
//
// Semantics and accessibility
// ---------------------------
// Each interactive tab exposes a semantic button.
// Each interactive tab exposes its localized label.
// Enter, numpad Enter, and Space activate the focused destination on key-up.
// The current destination exposes selected equals true.
// Other destinations expose selected equals false.
// The selected semantic index follows the clamped parent index.
// The visual fractional position does not create fractional semantics.
// The hidden overlay row does not own taps.
// The hidden overlay row must not become a second navigation group.
// Decorative selected content must not be announced twice.
// Icons are decorative because the adjacent label names the destination.
// Truncated visible labels retain their full semantic label.
// Keyboard activation may target the semantic button.
// Screen readers encounter items in source list order.
// RTL layout retains list order through Flutter Row behavior.
// Equal physical outer insets remain correct in RTL.
// PositionedDirectional moves the indicator from the physical RTL end edge.
// The clipped selected-content row uses right alignment in RTL.
// Its RTL translation has the opposite sign from the indicator translation.
// A physical rightward RTL drag reduces the logical destination index.
// Pointer scale feedback must not reduce semantic bounds.
// Blur availability must not alter semantic output.
// Theme brightness must not alter semantic output.
// Safe-area size must not alter semantic output.
// The test keys are not used as semantic labels.
// The panel itself is not announced as an extra button.
// Destination buttons remain reachable when content extends behind the bar.
// The transparent host is not announced.
// App localization owns pronunciation-friendly destination strings.
// Public library code never hardcodes example Chinese labels.
// The example translates visible labels while retaining original order.
//
// Example settings integration
// ----------------------------
// showNavigation remains the outer visibility switch.
// useFloatingNavigationBar chooses floating rather than regular navigation.
// floatingNavigationBarStyle chooses default or iOS-like floating style.
// The default stored style is default.
// The localized options appear as 默认 and iOS 风格.
// Style selection is visible only while floating navigation is enabled.
// Alignment selection is visible only for the default floating style.
// Selecting iOS-like retains the stored default alignment value.
// Returning to default restores that stored alignment.
// Badge visibility is shared by all navigation styles.
// Root selectedIndex is shared by all navigation styles.
// The iOS-like style calls the same page-selection method.
// The root PageView remains the destination content owner.
// The root Scaffold enables extendBody for both floating styles.
// The root settings page can scroll behind either floating surface.
// The root body keeps additional bottom content padding.
// That padding prevents the final preference from becoming unreachable.
// The padding does not paint an opaque navigation rectangle.
// AnimatedSwitcher transitions between navigation surfaces.
// Each surface has a distinct ValueKey.
// iOS-like position remains centered and full-width within 24dp margins.
// The style does not consume floatingNavigationBarAlignment.
// The style respects the global enableBlur setting.
// Disabling blur keeps the exact same panel geometry.
// Disabling blur uses source non-glass indicator colors.
// Wide layouts continue using NavigationRail instead.
// The iOS-like option is hidden on wide layouts.
// The regular navigation display-mode selector remains independent.
// Changing regular display mode does not affect this surface.
// All settings labels are translated without changing control order.
//
// Regression evidence
// -------------------
// Widget tests use a 390 by 844 logical-pixel viewport.
// Device pixel ratio is one for direct dp-to-pixel assertions.
// The test enters Settings through the fifth root destination.
// The test enables floating navigation.
// The test changes style through the real dropdown preference.
// The test verifies the iOS-like widget exists exactly once.
// The test verifies default FloatingNavigationBar is absent.
// The test verifies alignment control is hidden.
// The test verifies panel left equals 24.
// The test verifies panel right equals 366.
// The test verifies panel width equals 342 by implication.
// The test verifies panel height equals 64.
// The test verifies panel bottom equals 808.
// The test verifies bottom transparent space equals 36.
// The test verifies indicator top inset equals 4.
// The test verifies indicator height equals 56.
// The test verifies indicator width remains 56 for every item count.
// The test taps a destination through its stable tab key.
// The test waits for both spring and pager animation to settle.
// The test verifies the Icons page becomes active.
// A golden captures the complete root shell with this style.
// The golden includes content painted behind the bottom-bar host.
// The golden includes translated labels.
// The golden includes the selected indicator.
// The isolated golden includes the outline, icons, labels, and selected state.
// Backdrop-filter transparency must be judged in an ancestor-backed capture.
// An isolated subtree has no page pixels and may flatten its sample to black.
// Golden updates require visual inspection before acceptance.
// Motion tests lock the analytic stiffness-1000 critical-spring position.
// Motion tests lock independent horizontal and vertical press channels.
// Motion tests lock the four-dp rubber-band maximum and release.
// RTL tests lock physical drag direction and selected callback behavior.
// iOS tests lock the fixed 20dp bottom inset despite a 34dp MediaQuery inset.
// A passing narrow test cannot prove wide NavigationRail behavior.
// A passing golden cannot replace the explicit geometry assertions.
// Explicit geometry cannot replace the interaction assertion.
// Interaction cannot replace semantic review.
// Full package analysis must remain clean.
// Root and example test suites must both remain green.
// Android and Windows release builds remain final integration gates.
// Comment-ratio verification includes this executable contract.
// The overall original-example parity goal remains broader than this widget.
//
// Reduced-motion extension
// ------------------------
// The component reads MediaQuery.disableAnimations from its own build context.
// The ordinary source-parity springs remain the default when that flag is false.
// Pointer down remains direct input and publishes the held visual state immediately.
// Held state keeps press progress one and both authored pressed scale endpoints.
// The interactive highlight remains visible while the pointer owns the panel.
// Pointer drag updates the logical target using the same RTL-aware delta mapping.
// Reduced drag publishes that target directly instead of spring-following it.
// The physical panel-drag accumulator remains coupled to each pointer delta.
// Its visible rubber-band transform therefore continues to follow direct input.
// Pointer release retains the same nearest-enabled-destination decision.
// Only autonomous position travel after that decision is removed.
// Release sets press, X scale, Y scale, spot, and panel drag to rest immediately.
// Pointer cancellation returns to the current committed index without a spring.
// Programmatic selectedIndex updates also move directly to their final index.
// Repeated semantic activation does not synthesize decorative motion when reduced.
// Enabling reduced motion during travel stops all six animation controllers.
// Position settles to the current logical target rather than the intermediate value.
// If a pointer is still down, the held visual endpoint is retained after settlement.
// If no pointer is down, every deformation channel settles to its neutral endpoint.
// Dependency-driven controller writes are deferred beyond inherited-widget build.
// A preference generation invalidates stale post-frame settlement callbacks.
// Deferred release epochs are invalidated before direct endpoints are published.
// Disabling reduced motion does not replay any spring skipped while it was active.
// Later pointer and programmatic interactions resume the unchanged source springs.
// Tilt-driven specular direction is a sensor-coupled paint input and remains enabled.
// Blur, tint, clipping, shadow, and safe-inset geometry remain unchanged.
// Refraction remains backend-dependent and is disabled on Android for stability.
// Focused tests sample ordinary travel before enabling reduced motion at runtime.
// They assert the exact two-tab endpoint after bounded pumps without settle loops.
// They also assert direct drag, held scale, final destination, and zero rubber band.
//
// Reduced-motion accessibility and geometry boundaries
// ----------------------------------------------------
// Reduced motion never changes the number or order of navigation destinations.
// Every destination retains its stable ios-liquid-tab index semantics key.
// The selected semantics flag follows the same internally committed index.
// Disabled destinations remain visible and continue to reject pointer activation.
// Keyboard Enter, Numpad Enter, and Space retain their existing ActivateIntent path.
// A repeated keyboard activation keeps selection stable without creating motion.
// The duplicated selected paint layer remains excluded from semantics in both modes.
// Indicator clipping remains paint-only and cannot add a second hit-test target.
// The whole sixty-four-dp panel continues to own the raw pointer sequence.
// Horizontal drag recognition continues to compete normally in Flutter's arena.
// Reduced motion does not add an opaque ancestor around the transparent margins.
// The twenty-four-dp outside horizontal margins continue showing page content.
// The four-dp internal panel padding and equal tab-width formula remain unchanged.
// Five destinations therefore retain the calibrated sixty-six-point-eight-dp width.
// The indicator remains fifty-six dp high inside the sixty-four-dp panel.
// Android navigation-bar inset resolution remains separate from visual motion.
// Android zero inset still selects the authored thirty-six-dp optical bottom gap.
// A nonzero Android navigation inset still adds the authored eight-dp spacing.
// iOS continues to use its fixed twenty-dp compatibility inset when requested.
// Windows retains the same panel geometry and keyboard focus behavior.
// Turning blur off does not disable reduced-motion state handling.
// Turning glass off does not restore autonomous springs while reduction is active.
// Five-level blur, opacity, lens padding, and refraction remain material concerns.
// Gravity updates repaint only specular direction and never move the destination.
// Preference changes do not subscribe or unsubscribe the device-tilt stream.
// Shader loading completion cannot restart a stopped navigation motion channel.
// Render-backend lens fallback remains an ordinary blur inside the same clip.
// Tests keep motion endpoint assertions independent from shader availability.
// Runtime Android and Windows checks remain necessary for final pointer confidence.
// Static widget tests prove policy and geometry but not physical sensor quality.
// Release reporting must preserve that distinction rather than claim device proof.
// Reduced-motion regression maintenance
// -------------------------------------
// The runtime-toggle test must begin with a demonstrably intermediate spring frame.
// Its sampled indicator left edge must be strictly between source and destination.
// Two bounded pumps then prove inherited-policy propagation and endpoint painting.
// A later physical drag must prove the indicator moves before pointer release.
// Held-state assertions inspect both independent scale-axis matrix entries.
// Release assertions inspect the committed callback index and exact tab geometry.
// The panel translation assertion prevents a stale rubber-band offset from surviving.
// Ordinary motion tests remain separate and retain their analytic spring comparison.
// RTL regression remains separate and retains physical-right-to-logical-start mapping.
// Full-suite execution is required because this shared bar participates in scaffold tests.
// Comment-ratio and release gates run only after every behavior regression is green.
