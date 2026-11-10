// HyperOS 4 reduced-motion interaction contract.
//
// Scope.
// The application reads Flutter's MediaQuery.disableAnimations signal.
// The signal can be true at first build or change while a route remains alive.
// MiuixPressable is the shared transform and indication implementation.
// MiuixIconButton owns a separate source-accurate indication state machine.
// Both implementations must obey the same accessibility boundary.
//
// Stable state instead of missing state.
// Reduced motion does not remove pressed, held, hovered, or focused feedback.
// It publishes the logical target immediately without intermediate frames.
// Sink feedback moves directly between scale 1 and the declared pressed scale.
// Tilt feedback moves directly between zero and the pointer-derived X/Y target.
// Indication alpha remains the sum of hover, focus, press, and hold channels.
// A held state still supersedes its overlapping pointer-press channel.
// Release returns every applicable channel directly to its remaining target.
// Content shape, clipping, semantics, and hit testing never depend on motion.
//
// Runtime accessibility changes.
// Enabling reduced motion stops every currently active spring controller.
// The stopped controller is assigned the latest logical state in the same turn.
// Existing velocity must not produce another frame after the setting changes.
// Awaited positive indication jobs are invalidated by a revision increment.
// An invalidated job must not start its delayed exit spring later.
// Disabling reduced motion does not replay a transition already skipped.
// The next real interaction resumes the authored spring from stable state.
//
// Input roles.
// Touch press and release use the same immediate targets.
// Long-press handoff retains the accepted held visual state.
// Mouse hover enters and exits without a fading tail.
// Keyboard focus remains visible and adds to hover or held state.
// Enter and Space activation remain available while motion is reduced.
// Pointer gesture ownership and arena participation remain unchanged.
// Expanded Android semantic targets remain independent from painted geometry.
// Windows mouse hit regions and focus traversal remain unchanged.
//
// Haptics.
// Reduced visual motion does not silently disable semantic haptic feedback.
// Long press continues using the documented MIUIX long-press role.
// Selection controls continue using their documented tick or boundary role.
// Components must not invent a new vibration merely because motion is absent.
// Platform haptic availability remains the haptic adapter's responsibility.
//
// Verification.
// A focused IconButton test checks immediate press and release indication alpha.
// A shared Pressable test begins with an actual in-flight sink spring.
// The test switches MediaQuery to reduced motion while the pointer stays down.
// Scale and indication must snap to their exact pressed targets immediately.
// Releasing must restore exact rest values without transient callbacks.
// Existing source-spring tests remain enabled under ordinary MediaQuery data.
// Full tests ensure Cards, FABs, buttons, and overlays retain their contracts.
// Static analysis and package structure gates run before every Release cycle.
// Android arm64 and Windows x64 outputs are rebuilt after the behavior changes.
//
// Navigation and transient surfaces.
// Regular NavigationBar selected-label layout snaps to its final icon offset.
// Both outgoing and incoming label alpha channels resolve in the same frame.
// Floating NavigationBar retains its existing zero-duration indicator branch.
// TopAppBar compact-title translation and opacity use a zero-duration tween.
// A released large-title bar resolves directly to its nearest stable endpoint.
// Enabling reduced motion stops an already-running TopAppBar settle simulation.
// The endpoint commit is deferred only to avoid notifying during widget build.
// Tooltip enter publishes alpha one and scale one without transition frames.
// Tooltip dismissal publishes alpha zero and the hidden scale immediately.
// Overlay removal runs after the build frame so host state is mutated safely.
// A reduced Tooltip must not retain an invisible full-screen pointer layer.
// Reopening invalidates a previously scheduled reduced-motion exit callback.
// Existing ordinary-motion tests continue proving authored source curves.
// Focused reduced-motion tests cover NavigationBar, TopAppBar, and Tooltip.
//
// Tooltip lifecycle details.
// A Tooltip reads MediaQuery from the Overlay route rather than its anchor.
// The application-level MediaQuery must therefore reach MaterialApp's Overlay.
// Enter cancellation stops both the bounded alpha and unbounded scale ticker.
// Exit cancellation also invalidates the pending overlay-removal revision.
// Dismissed status callbacks are suppressed only during an explicit snap.
// Ordinary reverse animation still removes the overlay at alpha zero.
// Reduced dismissal schedules exactly one safe post-frame host mutation.
// A newly visible state prevents an older scheduled removal from committing.
//
// Navigation details.
// Regular selected-label destinations keep immediate color and weight changes.
// Reduced motion additionally snaps their icon offset and label opacity.
// Destination callbacks still fire only after an accepted activation.
// Equal-width item measurement and platform inset behavior remain unchanged.
// TopAppBar direct drag remains finger-tracked and is not discarded as motion.
// Only released decay, endpoint spring, and compact-title transition are skipped.
// Content continues moving behind the top glass while the title is collapsed.
// The behavior preserves its content offset when committing a reduced endpoint.
// A custom snapDuration of zero and the system preference share the same result.

// Foundation selection controls.
// Switch owns independent position, scale, track-color, and thumb-color springs.
// Reduced motion stops all four channels instead of hiding only the transform.
// The thumb position publishes the committed endpoint or live drag endpoint.
// The thumb scale publishes the current pressed-or-hovered logical target.
// Track and thumb colors publish their resolved semantic endpoints directly.
// A drag still follows pointer deltas because direct manipulation is not delay.
// Drag ownership over an ancestor PageView remains unchanged by this setting.
// Drag endpoint and release haptics retain the existing source dead-band rules.
// Enabling reduced motion during a spring discards its carried velocity.
// Disabling reduced motion does not replay the skipped switch transition.
// The next value, hover, press, or drag change may use authored springs again.
// Checkbox owns one 300ms controller with several differently timed channels.
// Reduced motion sets that controller to its exact endpoint immediately.
// Checked entry therefore publishes the final check alpha and trim values.
// Checked exit publishes the empty-path values without a partially drawn mark.
// Indeterminate entry publishes the final horizontal-mark gravitation value.
// Semantic color changes also resolve immediately while motion is reduced.
// Radio owns independent 10/150ms alpha and 300ms trim calculations.
// Reduced motion publishes the final selected or unselected frame for both.
// Enabling the preference during an active transition cancels its old frame.
// Switch, Checkbox, and Radio keep their platform-expanded 48dp hit targets.
// Their selected, checked, toggled, enabled, and group semantics remain intact.
// ToggleOn, ToggleOff, and SegmentTick haptic roles remain enabled.
// MiuixPressable independently snaps Checkbox and Radio press transforms.
// Source geometry and ordinary-motion springs remain covered by existing tests.
// The focused regression first observes real intermediate motion on all three.
// It then enables reduced motion and requires exact stable endpoints in one pump.
// A second controlled change while reduced proves no new animation is started.
// Switch color assertions ensure the shared color spring also reaches its target.
//
// Selection-control lifecycle details.
// A switch reads the accessibility preference after both controllers exist.
// This avoids consulting inherited state from initState or dispose.
// A preference change compares against the cached value before doing work.
// Repeated inherited rebuilds therefore do not restart or resnap controllers.
// Stopping with canceled true invalidates any caller awaiting an old ticker.
// The immediate value assignment happens after the ticker is canceled.
// Offset uses the current committed value plus any live drag displacement.
// Scale uses the current enabled, pressed, and hovered logical state.
// A disabled switch cannot retain an enlarged reduced-motion thumb.
// Hover exit while reduced restores scale one in the same pointer turn.
// Pointer press while reduced enlarges directly and release restores directly.
// A value update while reduced moves the thumb directly to 4dp or 25dp.
// Source-authored logical endpoints remain density-independent before paint.
// The outer 48dp semantic expansion is never driven by an animation controller.
//
// Shared spring-color lifecycle details.
// Each color animator stores the last visible from and semantic to colors.
// Ordinary retargeting still begins at the currently interpolated visible color.
// Reduced retargeting replaces both endpoints with the new semantic color.
// Its controller remains at normalized progress one after the replacement.
// Enabling reduced motion during a color spring publishes its current target.
// Theme changes while reduced publish the newly resolved theme color directly.
// Disabling reduced motion leaves that stable color untouched.
// The next semantic color change creates a fresh authored spring normally.
// Track and thumb color animators remain independent under ordinary motion.
// Their reduced endpoints are nevertheless committed in the same build frame.
//
// Checkbox lifecycle details.
// The checkbox initializes target colors before exposing its first frame.
// Its initial checked or mixed state is stable even with no elapsed duration.
// Enabling reduced motion after initialization moves progress directly to one.
// A simultaneous theme change then retargets and remains at progress one.
// A subsequent value update samples the stable old frame before changing target.
// The new target is assigned before the progress-one value is published.
// This ordering prevents one frame with a new mark and an old semantic color.
// Mixed-to-checked and checked-to-mixed transitions share the same snap rule.
// Disabled color changes share the same snap rule.
//
// Radio lifecycle details.
// The radio initializes its scalar endpoints from the controlled group value.
// It begins visually stable even though its ordinary controller starts at zero.
// Selection changes capture the current frame before changing the target flag.
// Reduced motion then assigns progress one instead of forwarding from zero.
// Enabling reduced motion mid-transition cancels and completes both channels.
// Group changes while reduced never expose a partial ring or partial checkmark.
// Disabled paint uses the same stable endpoint and remains semantically disabled.
//
// Regression maintenance details.
// Focused ordinary-motion tests must still observe intermediate spring values.
// Focused reduced-motion tests must assert exact values without pumpAndSettle.
// Using pumpAndSettle alone would hide an accidental short animation.
// A test must cover enabling the preference during real in-flight motion.
// A test must cover another controlled state update after reduced mode is active.
// Exact switch colors prove transforms are not the only channels being skipped.
// Exact checkbox trim values prove all authored keyframe channels are skipped.
// Exact radio alpha and trim values prove both durations are skipped together.
// Full golden tests remain unchanged because normal motion and stable paint match.
// Release validation must follow any source or documentation change in this file.
//
// Indeterminate-progress lifecycle details.
// Linear, circular, and orbit indicators read the preference from MediaQuery.
// They begin their ordinary autonomous cycles only after dependencies exist.
// This avoids inherited lookup in initState and supports live preference edits.
// A reduced linear indicator freezes at a centered partial-segment frame.
// A reduced circular indicator freezes at twelve o'clock with a medium sweep.
// A reduced orbit indicator freezes its secondary dot at the right-hand edge.
// These poses remain visually identifiable without suggesting completion.
// All three controllers stop before publishing their deterministic frame.
// A long frame pump must therefore preserve the exact same painter values.
// Enabling the preference during an active cycle cancels its carried phase.
// Disabling the preference resumes a fresh ordinary autonomous cycle.
// Determinate progress never starts these controllers and retains its value.
// Percentage, minimum, maximum, and progress-bar semantics remain unchanged.
// Indeterminate linear and circular indicators retain loading-spinner roles.
// The orbit adapter now exposes the same loading-spinner role explicitly.
// Motion preference changes presentation only; they do not rewrite load state.
// The regression observes live phases before enabling reduced motion.
// It then asserts exact frozen painter channels without using pumpAndSettle.
// It also waits three seconds to prove no periodic ticker restarts implicitly.
// Finally it disables the preference and verifies that motion becomes live.
//
// Progress maintenance boundaries.
// Stable poses are project accessibility decisions, not claimed Xiaomi sizes.
// Their numeric phases are internal painter inputs and not public API tokens.
// Changing a phase requires checking light and dark contrast at the new pose.
// A static linear segment must remain visibly distinct from zero percent.
// A static circular sweep must remain visibly distinct from a full ring.
// A static orbit dot must not overlap the ring into one ambiguous shape.
// Color resolution remains owned by MiuixProgressIndicatorColors.
// Reduced motion never substitutes disabledForegroundColor for active color.
// Device-pixel rounding remains applied before every stable frame is painted.
// Invalid finite values keep their existing clamp and fallback behavior.
// A null value remains the sole public signal for indeterminate progress.
// Rebuilt equal color sets must not restart a stopped reduced-motion cycle.
// Rebuilt dimensions must repaint geometry without restarting that cycle.
// Theme and text-scale changes may trigger didChangeDependencies safely.
// Cached preference comparison prevents ordinary inherited rebuild churn.
// Controllers are always disposed regardless of their stopped or live state.
// No delayed callback is scheduled when a reduced indicator becomes visible.
// Hidden tickers therefore cannot wake solely to maintain a frozen phase.
// Pull-to-refresh has a separate gesture and completion lifecycle contract.
// Its direct drag, release spring, completion fade, and spinner are coordinated
// together rather than inheriting standalone-indicator assumptions blindly.
//
// Pull-to-refresh lifecycle details.
// Direct pointer and overscroll deltas remain damped and finger-tracked.
// The threshold-entry haptic remains tied to the same state transition.
// Reduced motion skips only autonomous movement after pointer release.
// A subthreshold release commits idle and offset zero in the same turn.
// A qualifying release commits the fixed visual threshold directly.
// Its refresh callback is still invoked exactly once after that position lands.
// Enabling the preference during a spring completes its TickerFuture normally.
// Completing instead of canceling prevents the awaiting coroutine from hanging.
// The motion controller publishes normalized value one before continuation.
// The exact target offset and inverse raw distance are therefore synchronized.
// The refresh state cannot remain stranded at thresholdReached after a toggle.
// The refreshing indicator retains its random source starting orientation.
// Reduced motion freezes the rotation controller at that stable orientation.
// A multi-second pump must not change the resulting painter rotation.
// Disabling the setting during refresh resumes the ordinary 800ms revolution.
// Refresh completion still publishes refreshComplete and complete progress zero.
// Two frame boundaries guarantee that the success label paints for a full frame.
// The completion collapse then publishes progress one without intermediate fade.
// Returning from the completion phase uses the same immediate offset rule.
// Hoisted and Future-based refresh ownership retain their existing contracts.
// An owner-driven false value still finishes only an active refreshing state.
// Unmount checks remain after every awaited frame and refresh operation.
// The focused regression begins with an observable in-flight ordinary spring.
// It toggles the inherited preference and proves that the callback still starts.
// It proves stable rotation, visible completion, direct drag, and snap release.
// Ordinary five-state timing remains covered separately by source-motion tests.
//
// Scroll feedback details.
// Scrollbar geometry remains deliberately narrow and visually subordinate.
// That existing source geometry already satisfies the HyperOS lightweight rule.
// Reduced motion therefore changes timing rather than inventing new dimensions.
// Direct list scrolling and direct thumb dragging remain pointer-following.
// The one-second visibility dwell remains a logical readability interval.
// Once that dwell expires, opacity snaps hidden instead of fading for 500ms.
// Enabling the preference during a fade snaps to its recorded hide endpoint.
// Hover and thumb-drag highlighting snap between resting and expanded widths.
// Enabling the preference during a highlight transition uses current hover state.
// Content-size changes publish their final thumb extent without interpolation.
// Enabling the preference during a length tween lands at its latest destination.
// Turning reduced motion off restores the unchanged source timing constants.
// Scroll notification filtering and nested-scroll ownership remain unchanged.
// Overscroll displacement remains directly governed by scroll physics and input.
// No separate autonomous overscroll controller exists in MiuixOverscrollEffect.
// The focused regression proves mid-flight opacity and highlight convergence.
//
// Overlay-family details.
// PopupHost owns visibility clocks for hosted menus, dialogs, and bottom sheets.
// An initially enabled preference publishes content and dim progress one now.
// Enabling it during entry stops both clocks and publishes their final values.
// A reduced-motion dismissal publishes zero and removes the hosted entry next frame.
// Delaying removal by one frame lets the terminal invisible state paint safely.
// Custom public visibility transitions receive the same snapped controller value.
// Window dialog routes use zero enter and reverse durations when opened reduced.
// Their transition builder also returns settled content under the live preference.
// Compact window dialogs therefore do not traverse a viewport-height slide.
// Wide window dialogs do not run the source scale-and-fade combination reduced.
// Window bottom-sheet routes likewise use a zero visibility duration when opened.
// Direct bottom-sheet handle and nested-scroll displacement remain finger-tracked.
// A subthreshold release returns the sheet to zero offset in the same turn.
// A qualifying release moves beyond the measured sheet and dismisses immediately.
// Enabling the preference during either settle completes its logical destination.
// Predictive Back progress remains tied directly to the operating-system gesture.
// Cancelling that gesture restores dialog or sheet progress to zero immediately.
// Committing a dismissible sheet delivers its dismissal without an extra spring.
// Non-dismissible predictive Back still restores the sheet rather than removing it.
// Ordinary source springs and independent dim timings remain unchanged otherwise.
// Focused tests cover initial reduced state and an inherited mid-entry toggle.
//
// Overlay state-machine maintenance rules.
// A hosted entry remains the controller's source of logical visibility.
// Animation status must never replace entry.visible as that source of truth.
// Entering reduced mode reads entry.visible before choosing zero or one.
// This distinction matters when the inherited setting changes during reverse.
// Content and dim controllers always settle together under reduced motion.
// Leaving one channel in flight would expose a panel without its modal barrier.
// The final controller assignment still notifies transition-specific builders.
// This preserves custom MiuixVisibilityTransition endpoint rendering.
// Removal cannot occur synchronously inside didChangeDependencies.
// Inherited dependency processing may be part of an active element build pass.
// A single coalesced post-frame callback is therefore the removal boundary.
// The callback checks mounted because the containing Scaffold may close first.
// It checks entry.visible again because a caller may reopen before that frame.
// Popup completion remains owned by MiuixPopupHostController._dismiss.
// The reduced-motion view does not complete the public result a second time.
// onDismissRequest remains earlier than physical removal in every motion mode.
// onDismissFinished remains tied to actual entry removal rather than opacity zero.
// Back ownership remains active until that physical removal has completed.
// These lifecycle rules prevent a rapid second Back from escaping to the page.
//
// Window dialog maintenance rules.
// The preference is captured before constructing RawDialogRoute durations.
// A route opened reduced has zero forward and reverse route durations.
// This makes Future completion match the absence of visible transition time.
// The live transition builder also reads the inherited preference each build.
// That live check removes motion when the setting changes during an entrance.
// A route opened ordinarily retains its source duration for lifecycle stability.
// A mid-flight toggle may hide motion before the existing route clock completes.
// It must not recreate or replace the active route to shorten that clock.
// Replacing the route would lose result typing, focus, and predictive-Back state.
// Compact mode bypasses its full-viewport vertical translation when reduced.
// Large mode bypasses both the opacity channel and the scale from 0.8.
// Dialog layout, safe insets, glass, and content measurements never change.
// The accessibility preference therefore cannot cause panel geometry reflow.
//
// Bottom-sheet maintenance rules.
// Route visibility and pointer settlement are independent animation channels.
// Both must honor reduced motion or the sheet can still move after appearing.
// Pointer deltas update the unbounded drag controller without interpolation.
// The preference must not suppress those assignments while a finger is down.
// Release first evaluates the unchanged source dismissal threshold and velocity.
// A non-dismiss release publishes offset zero immediately in reduced mode.
// A dismiss release publishes at least one measured sheet height immediately.
// The existing crossing listener then delivers the same settled-dismiss callback.
// Using that listener avoids creating a second dismissal lifecycle path.
// If measurement is unavailable, viewport height is a safe off-screen target.
// Enabling reduced mode during a return spring chooses the resting endpoint.
// Enabling it during a dismissal spring chooses the off-screen endpoint.
// The settlingDismiss flag records which endpoint is logically intended.
// The serial counter still invalidates stale asynchronous settle completions.
// Nested-scroll ownership and touch-slop correction remain source-compatible.
// An upward overscroll keeps its one-tenth direct damping while dragging.
// A disabled allowDismiss setting still prevents downward release dismissal.
//
// Predictive-Back maintenance rules.
// Operating-system gesture progress is user-driven and therefore not animation.
// Start and update callbacks continue publishing that progress in every mode.
// Only cancellation and post-commit settlement are autonomous transitions.
// Dialog cancellation directly returns its progress to zero when reduced.
// Sheet cancellation uses the same direct rest endpoint when reduced.
// A dismissible sheet commit publishes the crossed threshold before removal.
// A non-dismissible commit is treated as cancellation and returns to rest.
// Enabling reduced mode during an active cancellation also publishes rest now.
// Enabling it during a commit schedules exactly one dismissal callback.
// The commitDelivered guard prevents duplicate callbacks from controller ticks.
// Deferred callback delivery avoids removing the overlay during dependency work.
// Observer disposal always unregisters from WidgetsBinding before controllers.
// Focused regressions must assert both geometry and lifecycle callback counts.
// Ordinary regressions must retain source samples at 100ms and settled frames.
//
// Verification matrix for future overlay changes.
// Compact hosted dialogs require an initial reduced-motion endpoint assertion.
// Compact hosted dialogs require an ordinary mid-spring position assertion.
// Wide hosted dialogs require reduced opacity and scale endpoint assertions.
// Hosted dialog dismissal requires physical removal and one finished callback.
// Window dialogs require a zero-duration reduced route completion assertion.
// Window dialogs require ordinary 520ms enter and 260ms reverse coverage.
// Hosted bottom sheets require reduced panel and dim endpoints together.
// Window bottom sheets require the same reduced endpoint relationship.
// A slow subthreshold handle drag must return to exact zero after release.
// A threshold-crossing handle drag must still call dismissal exactly once.
// An active ordinary return spring must settle if the preference turns on.
// An active ordinary dismiss spring must complete if the preference turns on.
// Predictive progress at one half must still move the sheet by half its height.
// Reduced predictive cancellation must restore exact zero after one pump.
// Reduced predictive commit must remove a dismissible sheet without settling.
// A non-dismissible reduced commit must leave the sheet mounted at rest.
// Dim opacity must remain one for a non-dismissible predictive gesture.
// Dialog predictive cancellation must restore scale and translation endpoints.
// Public Future results must remain typed and complete only once.
// onDismissRequest must precede onDismissFinished in every host type.
// A second Back during removal must not reach the underlying application route.
// Reopening before a scheduled removal must preserve the visible entry.
// Disposing the host during a scheduled removal must produce no exception.
// Custom enter and exit transitions must receive controller endpoints zero or one.
// Custom dim transitions must settle in the same turn as content transitions.
// Glass clipping, tint, and blur are independent of the motion preference.
// Safe-area padding and compact-versus-wide selection are also independent.
// Android gesture navigation requires bottom inset coverage in runtime checks.
// Android three-button navigation requires the same sheet accessibility check.
// Windows requires keyboard dismissal and hidden-launch smoke verification.
// Light and dark themes must retain readable dimmed foreground contrast.
// Complex image backgrounds must stay sampled inside the glass shape only.
// No reduced-motion code may introduce a full-screen opaque surface.
// No route optimization may bypass the caller's dismissal permission.
// No direct gesture callback may be dropped merely because animation is disabled.
// Tests using pumpAndSettle alone cannot prove an immediate endpoint contract.
// Reduced regressions must inspect state after a bounded single pump instead.
// Source timing regressions must continue sampling actual intermediate values.
// Release validation must run both focused tests and the complete test suite.
//
// Text-input and search details.
// TextField focus and floating-label progress are independent source channels.
// Reduced motion preserves that independence while publishing both endpoints.
// Focus still changes outline color and width to the selected semantic state.
// Entered text still changes label size and the paired vertical translations.
// Enabling the preference during either spring stops its physical simulation.
// The stored focusTarget and labelTarget remain authoritative destinations.
// Disabling the preference restores the unchanged Compose spring parameters.
// Controller, FocusNode, formatter, selection, and cursor behavior are untouched.
// Search InputField has a separate text-opacity channel used only on collapse.
// Reduced collapse does not fade the query before clearing it.
// It also omits the source 100ms autonomous delay before cleanup.
// Controlled query publication happens before internal focus finalization.
// Internal finalization waits one frame for the parent query rebuild to finish.
// This ordering avoids dirtying an ancestor and its glass descendant together.
// A stale collapse generation cannot clear a search that has reopened meanwhile.
// Re-expansion records text opacity one and cancels an outgoing collapse spring.
// This prevents interrupted collapse from leaving newly entered text invisible.
// Search cleanup visibility builds its final child directly when motion is reduced.
// Search action and results visibility likewise build width/height factor one.
// A hidden reduced child builds SizedBox.shrink without an exit retention clock.
// Direct construction avoids controller notifications during inherited builds.
// It therefore remains safe for controlled parents that setState in callbacks.
// Ordinary mode retains the 150ms cleanup fade and source visibility springs.
// Mid-expansion preference changes rebuild at the full visible endpoint.
// Mid-collapse preference changes rebuild at the fully hidden endpoint.
// Accessibility semantics retain the same 48dp search-field target throughout.
// Glass sampling, capsule geometry, and directional slots do not change.
// Search keyboard action and focus acquisition remain functional in both modes.
// Focus release still occurs after the controlled query has been published.
// Tests inspect intermediate ordinary values before switching the preference.
// They inspect exact endpoints without using pumpAndSettle as proof of immediacy.
//
// Text-field maintenance matrix.
// An empty labelled field keeps the label inline regardless of focus state.
// Focus therefore changes only the outline channel for an empty labelled field.
// Entering the first character changes the independent label destination to one.
// Removing the final character changes that destination back to zero.
// Placeholder-label mode never promotes entered text into a floating caption.
// A disabled field cannot retain focus merely to preserve an animation endpoint.
// An externally supplied FocusNode remains owned and disposed by the caller.
// An externally supplied TextEditingController remains owned by the caller too.
// Replacing either object must detach listeners from the previous instance.
// Reduced motion does not change controller ownership during that replacement.
// A focus change while reduced publishes border width two or zero exactly.
// A label change while reduced publishes font size ten or seventeen exactly.
// The label and editor keep equal and opposite vertical translations.
// Source inside margins continue determining that translation distance.
// Multi-line measurement remains independent from the label animation channel.
// Obscure text and single-line normalization keep their existing constraints.
// Read-only fields still receive focus styling when platform focus permits it.
// Explicit textStyle color remains stronger than inherited surface content color.
// Theme semantic colors continue resolving before focus progress interpolation.
// Continuous squircle and rounded compatibility shapes use the same progress.
// Device-pixel line-height rounding remains outside reduced-motion decisions.
// onTextLayout remains post-frame and cannot be triggered by animation stopping.
// Stopping a spring never synthesizes an onChanged or onSubmitted callback.
// Input formatters receive the same sequence of editing values in every mode.
// Selection color and cursor color do not depend on the motion preference.
// Keyboard type and IME action forwarding remain exact public API behavior.
// A preference toggle with no active spring must not create a new controller tick.
// A toggle during both focus and label springs must settle both in one frame.
// Re-enabling ordinary motion must affect only later state transitions.
// It must not replay the transition that reduced mode already completed.
//
// InputField controlled-state rules.
// The source-style query parameter remains the parent's authoritative value.
// The internal controller mirrors that value without transferring ownership.
// A compatibility external controller remains authoritative when one is supplied.
// Controller listeners are suppressed only for deliberate build-time mirroring.
// User editing still notifies the local widget and public callback normally.
// Cleanup initiated by collapse must publish exactly one empty query callback.
// A generation counter invalidates delayed work from an earlier collapse request.
// Re-expansion increments that generation before it restores input opacity.
// A stale post-frame finalizer therefore cannot unfocus the reopened field.
// Reduced collapse never exposes an intermediate zero-opacity non-empty query.
// It requests empty controlled state before releasing the input focus.
// The following frame reconciles the internal controller without a second callback.
// Focus finalization happens only after that reconciliation opportunity.
// A parent that declines the controlled update still receives the callback once.
// The internal controller is then cleared so collapsed presentation remains safe.
// The Search IME action reports the current effective query before collapse.
// Manual cleanup remains independent and does not request collapsed state.
// Manual cleanup still reports an empty query through onQueryChange.
// Tapping the field continues to request expansion before requesting focus.
// A disabled InputField cannot acquire focus through pointer or semantics actions.
// Hoisted interaction state continues reflecting the real FocusNode state.
// Reduced motion does not synthesize press or focus interaction records.
//
// Search visibility implementation rules.
// Ordinary visibility retains children until its exit spring has completed.
// Reduced visibility derives layout directly from the current visible property.
// Direct derivation avoids AnimationController notifications during dependency work.
// The reduced horizontal action always uses an exact widthFactor of one.
// The reduced vertical results always use an exact heightFactor of one.
// Their hidden representations are exact zero-size boxes, not transparent hit areas.
// A reduced hidden cleanup icon likewise contributes no layout or pointer target.
// A visible cleanup icon remains wrapped in IgnorePointer false explicitly.
// Ordinary cleanup retains the child during its exact 150ms linear fade.
// Directional slide origins continue mirroring under right-to-left layout.
// The reduced endpoint uses zero translation in both text directions.
// Enabling the setting during a spring stops the controller before rebuilding.
// Its silently assigned endpoint avoids marking an already-building child dirty.
// Removing and restoring the listener brackets only that endpoint assignment.
// The listener is restored immediately so later ordinary animations repaint.
// No listener removal may survive an exception or controller disposal boundary.
// The controller remains disposed by its original State ownership path.
// Retained-child state is synchronized with visible whenever preference changes.
// Disabling reduced motion starts future changes from the current exact endpoint.
// It does not animate the currently visible child merely because policy changed.
// Custom outside action content remains completely caller-owned.
// Custom results content likewise receives no invented padding or text style.
//
// Search accessibility and layout rules.
// The HyperOS capsule keeps its project-calibrated 48dp minimum height.
// The semantic target remains at least 48dp without changing visual layout.
// Narrow-width leading and trailing slot adaptations remain unchanged.
// Directional padding mirrors without changing total slot allocation.
// Cleanup removal cannot shift the leading icon or editable text origin.
// Search glass continues sampling only within the capsule clip.
// The strongest glass setting cannot become an opaque rectangular search row.
// Touch light remains pointer-driven and is not classified as autonomous motion.
// Keyboard focus indication remains visible when all transitions are disabled.
// Screen readers retain the editable node instead of a duplicate wrapper button.
// Search, clear, expand, collapse, and Back actions keep their semantic callbacks.
// PopScope ownership remains active for the complete expanded controlled state.
// Reduced visual removal does not allow Back to bypass the state callback.
// Windows mouse focus and hover paths use the same visibility endpoints.
// Android IME dismissal follows focus release after controlled cleanup.
// RTL regression must inspect both slot mirroring and zero reduced translation.
// Narrow-window regression must verify no overflow at every visibility endpoint.
// Large-text regression must verify the capsule remains readable and clipped.
// Light and dark themes must retain readable placeholder and entered text colors.
// Image-background regression must verify genuine blur remains inside the capsule.
//
// Focused regression responsibilities.
// Sample ordinary focus motion before its critically damped spring settles.
// Toggle reduced motion and assert exact final outline width immediately afterward.
// Sample ordinary floating-label motion between ten and seventeen logical pixels.
// Toggle reduced motion and assert exact label and paired translation endpoints.
// Start source search expanded with a non-empty controlled query and real focus.
// Collapse reduced and assert one empty callback plus eventual focus release.
// Assert action, results, and cleanup slots have no retained hidden descendants.
// Re-expand and assert the EditableText opacity has returned to exactly one.
// Begin ordinary action and result expansion and verify intermediate reveal factors.
// Toggle reduced motion and verify both reveal factors become exactly one.
// Run the unchanged ordinary delayed-collapse regression in the same test suite.
// Run narrow constraints, semantics, RTL, controller swap, and Search IME tests.
// Static analysis and the complete golden manifest remain required release gates.
//
// Snackbar and toast motion contract.
// Snackbar timeout duration is a readability policy, not a visual transition.
// Reduced motion therefore never shortens a configured presentation timeout.
// Android still receives the original duration through AccessibilityManager.
// The native recommendation continues accounting for text and action controls.
// An indefinite snackbar remains indefinite under every animation preference.
// Hosted entry insertion is observable immediately through SnackbarHostState.
// Ordinary insertion starts the source critically damped expansion spring.
// Reduced insertion paints height factor one on the first visible host frame.
// It also paints zero vertical translation on that first visible host frame.
// No transparent pre-entry frame may retain a tappable action or dismiss icon.
// Ordinary newest-entry motion keeps the existing twelve-pixel upward slide.
// Ordinary older-entry removal keeps its source fade and top-edge shrink.
// Reduced removal paints height factor zero before queue removal is scheduled.
// Queue removal happens after the current frame rather than during host build.
// The deferred removal must deliver no second SnackbarResult completion.
// SnackbarData remains the only authority for dismissed versus action results.
// The action callback still runs before its entry begins visual dismissal.
// A dismiss button still returns the dismissed result rather than an action.
// Disposing SnackbarHostState completes all remaining entries as dismissed.
// A scheduled reduced removal after host disposal must perform no state write.
// A stale scheduled removal must never remove a newly inserted queue entry.
// Entry identity remains the monotonically assigned host-state identifier.
// Enabling reduced motion during entry stops the live spring immediately.
// The logical visible state then overrides the controller's sampled progress.
// The stopped controller is assigned its endpoint only after the build frame.
// Deferring that write prevents an AnimationController dirty-build assertion.
// Enabling reduced motion during exit selects the hidden endpoint instead.
// That exit also schedules the same single queue-removal lifecycle callback.
// Re-enabling ordinary motion must not replay an already completed transition.
// The controller endpoint retained during reduced mode supplies that guarantee.
//
// Direct horizontal gesture contract.
// Pointer drag deltas are user-driven motion and remain enabled in reduced mode.
// Every accepted delta updates the visible horizontal translation immediately.
// The host still owns its horizontal arena above an ancestor page view.
// Disabled swipe dismissal installs no start, update, end, or cancel callback.
// The positional dismissal anchor remains one half of the measured host width.
// The velocity dismissal anchor remains one hundred twenty-five pixels per second.
// Reduced mode changes only settlement after release, never anchor evaluation.
// A reduced subthreshold release publishes horizontal offset zero immediately.
// A reduced threshold release publishes the selected off-screen edge immediately.
// The off-screen endpoint retains the sign of the drag or release velocity.
// Releasing from exact zero uses velocity direction to choose that endpoint.
// The data dismissal follows the terminal drag endpoint exactly once.
// Gesture cancellation always chooses the resting zero-offset destination.
// Reduced cancellation reaches zero without a critically damped return spring.
// Ordinary cancellation retains stiffness four hundred and damping forty.
// Enabling reduced motion during settlement chooses the recorded target endpoint.
// The recorded target is independent from the controller's intermediate sample.
// Starting a new direct drag cancels stale autonomous settlement ownership.
// A drag cannot begin after the data entry has become logically invisible.
// A drag cannot update while visual removal is already in progress.
// Width measurement must be positive before anchors or clamping are evaluated.
// Horizontal translation remains clamped to one measured width in either direction.
// The gesture path never modifies vertical stack expansion or glass geometry.
//
// Root-overlay snackbar contract.
// The compatibility overlay remains separate from the page-level hosted queue.
// Its ordinary entry combines opacity with upward fractional translation.
// Its ordinary exit reverses those same channels through the source spring.
// Reduced entry paints opacity one and translation zero without a settle wait.
// Reduced exit paints opacity zero before removing the OverlayEntry.
// OverlayEntry removal is deferred until the terminal frame has been built.
// The controller closed future completes after that overlay removal callback.
// External controller close may still remove the entry synchronously by request.
// An external close never waits for an animation and remains idempotent.
// Overlay action invocation remains synchronous before reduced visual dismissal.
// The caller's local MediaQuery can sit below the root Navigator overlay.
// The show helper therefore captures its initial disableAnimations preference.
// The overlay also observes window-level MediaQuery accessibility changes itself.
// Either source enabling reduced motion selects the reduced endpoint policy.
// A locally enabled caller cannot be overridden by a false root-overlay value.
// A globally enabled preference still affects callers without a local override.
// Initial reduced construction seeds the controller at one instead of zero.
// This prevents one invisible frame before didChangeDependencies is delivered.
// Root-overlay timeout behavior remains unchanged from hosted timeout behavior.
// The root helper retains bottom system padding plus its twelve-pixel visual gap.
// Page-level applications should still prefer MiuixScaffold snackbar hosting.
// That host is required when feedback must clear a floating navigation capsule.
//
// Toast adapter contract.
// MiuixToast deliberately shares the snackbar surface and overlay lifecycle.
// It adds the existing context-click haptic before requesting presentation.
// Reduced visual motion does not suppress that semantic haptic feedback.
// An unavailable or disabled platform haptic remains safely ignorable.
// Toast action, dismiss button, duration, and controller remain snackbar types.
// Toast therefore inherits local and window reduced-motion handling automatically.
// Toast must not introduce a second opaque rectangle behind the glass surface.
// Toast must not bypass the snackbar safe-area and contrast calculations.
// A toast action still closes the overlay after its callback has executed.
// An empty action label still creates no action button or semantic action node.
//
// Snackbar accessibility and material rules.
// Glass blur, adaptive tint, edge highlight, and shape do not depend on motion.
// Reduced mode cannot replace the localized glass with an opaque full-width band.
// HyperOS project radius and tint tokens remain independent customization points.
// Explicit source construction continues using its opaque legacy surface recipe.
// Message, action, and dismiss colors retain their independent semantic roles.
// Large text may increase surface height without changing the motion endpoints.
// Directional inside margins continue mirroring under right-to-left layout.
// The dismiss glyph keeps its separate expanded forty-eight-pixel touch bounds.
// Screen readers retain the dismiss image label and enabled tap action.
// A hidden reduced entry contributes no pointer or semantics hit region.
// Snackbar stacking continues painting the newest logical entry above older ones.
// Ordinary older-entry overlap remains behind the newest entry during shrinking.
// Reduced removal has no overlap interval but preserves the same paint ordering.
// Floating navigation clearance is determined by scaffold layout, not animation.
// Android gesture and three-button insets remain outside the snackbar surface.
// Windows bottom-window clearance remains part of the same scaffold contract.
//
// Snackbar regression matrix.
// Initial reduced host presentation requires a bounded endpoint assertion.
// Mid-entry preference changes require an intermediate then exact-one assertion.
// Reduced dismissal requires physical removal after bounded frame pumping.
// A reduced slow drag requires a visible direct offset before pointer release.
// Its subthreshold release requires exact zero without pumpAndSettle.
// A reduced threshold drag requires dismissal in both horizontal directions.
// Ordinary slow drag still requires an observable spring return interval.
// Ordinary threshold drag still requires an observable off-screen settle interval.
// Pager competition must prove the snackbar owns the accepted drag stream.
// Swipe opt-out must prove the same physical drag leaves the entry visible.
// Root-overlay reduced entry requires opacity one and translation zero assertions.
// Root-overlay reduced dismissal requires completion and physical entry removal.
// Local MediaQuery coverage must differ from the root overlay's inherited value.
// Android timeout tests must retain exact native channel arguments and duration.
// Indefinite timeout tests must prove no Timer-driven dismissal occurs.
// Action-result tests must distinguish actionPerformed from dismissed exactly.
// Stacked-entry tests must retain newest-above-oldest hit-test evidence.
// Floating-navigation tests must keep the complete snackbar above capsule bounds.
// Transparent host surroundings must still pass taps to navigation destinations.
// Light and dark golden baselines must retain readable glass contrast.
// Static analysis, scope verification, and full tests remain release prerequisites.
//
// Number-picker reduced-motion contract.
// NumberPicker pointer movement is direct manipulation and remains continuous.
// Each vertical drag delta still converts from pixels into source row units.
// The conversion keeps the independently rounded source row height.
// Non-wrapping wheels still clamp direct motion at the legal range endpoints.
// Wrapping wheels still normalize visible indexes with modulo arithmetic.
// Crossing a row during direct manipulation still emits TextHandleMove haptics.
// Reduced motion does not suppress those input-coupled semantic haptics.
// Release settlement is autonomous and therefore changes under reduced motion.
// Reduced release skips the source exponential-decay phase completely.
// Reduced release also skips the critically damped row-centering spring.
// It rounds the current direct offset using the Kotlin-compatible tie rule.
// Positive one-half rounds forward while negative one-half rounds toward zero.
// The rounded offset is clamped again before selection is committed.
// A reduced release publishes at most one controlled onChanged callback.
// The transient offset resets to zero after the parent receives that callback.
// User-scroll haptic tracking is disabled before the reset to prevent reversal.
// A release already centered on the controlled value produces no callback.
// Ordinary mode retains the exponential coefficient represented by exp(-8.4).
// Ordinary mode retains stiffness four hundred and damping forty for snapping.
// Ordinary motion still carries decay velocity into the final spring phase.
//
// Runtime preference changes during picker motion.
// Enabling reduced motion during a pointer drag does not move the pointer target.
// The next release simply uses the reduced nearest-item settlement path.
// Enabling it during decay samples the nearest row at that exact frame.
// Enabling it during the final spring samples the same nearest-row rule.
// The current autonomous controller is canceled before any endpoint publication.
// Endpoint publication is deferred until inherited-widget building has finished.
// Deferral prevents controller listeners from dirtying a wheel during its build.
// A monotonically increasing generation invalidates the canceled async settle.
// The old decay continuation cannot publish after the generation changes.
// The old spring continuation cannot reset a newer direct drag to zero.
// Starting any new drag invalidates an older settlement generation immediately.
// A range change also invalidates motion before rebuilding the legal value list.
// Disabling the picker invalidates motion and returns the controlled center.
// Gesture cancellation invalidates the current generation and restores zero.
// Re-enabling ordinary motion never replays a settlement completed while reduced.
// Later pointer releases use ordinary decay and spring behavior as configured.
//
// Picker controlled-state requirements.
// The public value remains the only stable selected-value authority.
// Transient motion remains expressed relative to that controlled center.
// Parent acceptance during a settlement cannot trigger an early double reset.
// The settling flag stays true while the synchronous callback is executing.
// After callback return, transient motion resets with haptic tracking disabled.
// External value changes while idle still become the new exact zero origin.
// External range changes still choose the nearest available legal value.
// A non-positive step is still normalized to a positive non-zero step.
// Reversed minimum and maximum inputs remain normalized into ascending values.
// Disabled wheels still install no vertical drag callbacks.
// Accessibility semantics still announces the controlled value and range.
// Reduced motion never announces a passing transient row as the selected value.
// Visible neighboring rows still use source distance opacity and scale formulas.
// Flat Stack rendering remains unchanged and never becomes an iOS perspective wheel.
// ClipRect still prevents preparation rows from leaking outside wheel bounds.
// The negative-to-positive slot paint order remains identical in both modes.
// Large text and caller-supplied text styles remain independent from settlement.
// Color interpolation remains based on distance rather than animation policy.
//
// Picker regression responsibilities.
// A reduced slow drag beyond half a row must commit after one bounded pump.
// The same test must prove no later callback after an additional full second.
// A running ordinary fling must have no callback at its intermediate sample.
// Enabling reduced motion then must commit one nearest value after bounded pumps.
// Pumping beyond the old decay duration must not produce another callback.
// Ordinary regression must still settle a one-row drag through pumpAndSettle.
// Wrap-around regressions must retain non-zero controlled initial values.
// Disabled regressions must prove physical drags leave the value unchanged.
// Semantics regressions must retain caller-formatted displayed labels.
// Fractional-density regressions must retain independently rounded row distances.
// Android runtime checks should observe haptic ticks only on crossed rows.
// Windows mouse dragging should share the same direct and settlement policies.
// Date, time, date-time, and duration pickers inherit this wheel behavior.
// Their higher-level glass, stage, and dialog transitions remain independent.
//
// Disclosure-arrow and compact expansion contract.
// The shared vertical arrow derives from the checked-in physical MIUIX path.
// Right-to-left layout cannot invert its physical up and down directions.
// Reduced motion gives AnimatedRotation an exact zero effective duration.
// Ordinary callers retain their component-specific rotation duration and curve.
// ExpandableCard already supplies its HyperOS inline-surface motion token.
// CascadingMenu uses the same reduced policy for arrow and child visibility.
// A zero-duration AnimatedCrossFade can mutate RenderAnimatedSize during layout.
// Reduced cascading content therefore builds its exact structural endpoint.
// Expanded reduced content builds the child rows directly beneath the header.
// Collapsed reduced content builds an exact zero-size box with no child semantics.
// No retained transparent menu item may intercept a tap after collapse.
// Ordinary cascading content retains its one-hundred-eighty-millisecond crossfade.
// Ordinary arrow rotation retains its matching one-hundred-eighty-millisecond time.
// A preference change while expanded preserves visible children without a flash.
// A preference change while collapsed preserves the zero-size hidden endpoint.
// Tapping the header still changes expanded state and semantic intent once.
// Selecting an enabled child still reports its typed value through onSelected.
// Disabled child rows remain non-interactive regardless of animation policy.
// Glass radius, tint, blur, and row padding remain unchanged by reduced motion.
// Focused tests must inspect both structural child removal and arrow endpoint.
// Tests must not use pumpAndSettle alone to claim immediate reduced behavior.

// Popup depth and breadcrumb reduced-motion contract.
// Grouped cascading popup expansion is autonomous after the parent-row tap.
// Reduced motion therefore publishes secondary expansion progress one directly.
// The primary plane reaches its exact point-nine-five scale in the same policy.
// The secondary morph clip exposes the complete measured child plane immediately.
// Reduced collapse publishes progress zero before removing the OverlayEntry.
// Removed secondary labels cannot retain semantics or intercept pointer input.
// Enabling reduced motion during a running depth spring cancels its velocity.
// The logical expanded state chooses one; the logical collapsed state chooses zero.
// Dependency-driven endpoint publication occurs after inherited-widget building.
// This prevents a detached Overlay listener from being dirtied during layout.
// A generation token invalidates an older scheduled reduced-motion settlement.
// Ordinary expansion and collapse retain their separate source spring responses.
// Predictive Back progress remains direct input and still composes with depth.
// Dropdown trigger enabled opacity changes use a zero duration only when reduced.
// Ordinary trigger opacity keeps its authored one-hundred-sixty-millisecond time.
// Breadcrumb pointer, wheel, and touch scrolling always remain direct manipulation.
// Only automatic centering after a highlight change is decorative autonomous motion.
// Reduced automatic centering jumps to the same pixel-truncated source target.
// Enabling reduced motion during centering stops the active spring immediately.
// The target is recomputed after layout instead of reusing stale item geometry.
// Direct user scrolling can still replace that endpoint after the jump completes.
// Disabling reduced motion never replays a centering animation already skipped.
// Later ordinary highlight changes retain stiffness fifteen hundred and critical damping.
// Focused regressions sample a live spring before toggling the inherited preference.
// They then require exact endpoints after bounded pumps and no later stale movement.

// Extension carousel reduced-motion contract.
// Pointer displacement remains a direct PageView gesture while contact is active.
// Programmatic animateTo, next, and previous jump to the normalized target page.
// Enabling reduced motion during a programmatic page animation stops that activity.
// The last requested page, rather than a fractional intermediate page, is retained.
// A released pointer snaps to the nearest page after gesture ownership completes.
// Loop-edge overscroll still resolves to the opposite authored endpoint.
// Autoplay timers are canceled while reduced motion remains enabled.
// Enabling autoplay under reduced motion must not schedule a hidden periodic move.
// Disabling reduced motion permits later autoplay cycles without replaying old ones.
// Neighbor scale remains coupled to direct page position and is not independently animated.
// Indicator width and color use an exact zero duration while motion is reduced.
// Ordinary controller calls retain their caller duration and curve overrides.
// Ordinary autoplay retains the configured interval and pointer-down pause policy.
// Page changes continue to publish the same controller index and semantic haptic.

// Extension swipe-action reduced-motion contract.
// Horizontal pointer deltas continue to update the foreground every input frame.
// Logical start and end mapping continues to respect ambient TextDirection.
// Gesture-threshold haptics remain coupled to direct threshold crossings.
// Distance and velocity still choose the same durable side on pointer release.
// Only the autonomous travel from release position to that side is removed.
// Programmatic openStart, openEnd, and close also publish exact endpoints directly.
// Cancellation still chooses closed but reaches it without an easing controller.
// Enabling reduced motion during easing cancels the controller and keeps its target.
// A monotonically increasing generation rejects stale canceled completions.
// Beginning a new drag invalidates any older programmatic settlement generation.
// onSideChanged fires for the one durable settlement rather than every drag frame.
// Equal action widths, clipping, haptics, and action callbacks remain unchanged.

// Extension process-stepper reduced-motion contract.
// Current-step selection remains controlled by the existing public state authority.
// Marker and connector implicit color transitions receive an exact zero duration.
// Vertical expanded content is built as its final structural branch when reduced.
// No AnimatedSize subtree remains to retain outgoing content or semantics.
// The former current body disappears in the same bounded update as the next body.
// Horizontal process content already uses direct conditional structure in both modes.
// Click, keyboard traversal, default actions, and segment haptics remain unchanged.
// Ordinary vertical layout retains its three-hundred-millisecond size transition.
// Ordinary markers and connectors retain their two-hundred-eighty-millisecond timing.
// Focused regressions inspect exact transforms, durations, structure, and stale motion.
// Extension controller ownership and lifecycle requirements.
// An externally supplied carousel controller remains owned by its application.
// An internally created carousel controller is disposed with the carousel State.
// Replacing a carousel controller transfers listeners before applying motion policy.
// The newly attached controller receives item count and looping configuration first.
// Motion policy is applied only after normalization has a valid page domain.
// A pending inherited-policy callback carries a generation owned by the widget State.
// Disposal invalidates that generation before any controller can be touched again.
// Programmatic carousel movement separately tracks its requested destination.
// Intermediate onPageChanged events may publish visible index but not replace that target.
// A physical pointer down explicitly transfers destination ownership back to the user.
// It also invalidates completion bookkeeping from the interrupted programmatic move.
// Reduced settlement stops current scroll activity through an exact page jump.
// The resulting page callback remains the sole durable public index notification.
// An externally supplied swipe controller likewise remains application-owned.
// Replacing it removes the former listener before resolving the new requested side.
// Reduced resolution after widget update is deferred beyond the current build scope.
// Swipe animation disposal invalidates every outstanding completion generation.
// Ticker cancellation returns without publishing a stale side or callback.
// Direct drag invalidates the old generation before applying its first pointer delta.
// Process-stepper controller replacement follows the same listener ownership boundary.
// Structural reduced content never requires an AnimationController or delayed cleanup.
// Tests dispose every external controller and preference notifier they create.
// Tests use bounded pumps for endpoint proof and ordinary settle for source timing proof.
// Full-suite, static-analysis, component-scope, and comment-ratio gates remain mandatory.

// Extension form-field reduced-motion contract.
// Validation remains governed by the existing Form and validator lifecycle.
// The ordinary error region retains its two-hundred-twenty-millisecond size change.
// Reduced motion builds the exact error-present or error-absent branch directly.
// No zero-duration AnimatedSize substitutes for the removed structural transition.
// A cleared error cannot retain layout space after the bounded state update.
// A cleared error cannot retain semantics or intercept pointer input.
// A newly published error is available to accessibility in that same final branch.
// Label, helper, required-state, and field ownership behavior remain unchanged.
// Validation callbacks and submission continue to run exactly once per request.

// Extension PIN-input reduced-motion contract.
// Text editing and focus movement are direct interaction and remain responsive.
// Each cell publishes its focused, filled, error, or idle outline without delay.
// Reduced outline transitions use an exact zero duration on the existing cell.
// Ordinary cell transitions retain their two-hundred-twenty-millisecond duration.
// Automatic focus advancement remains tied to accepted input, not animation time.
// Error and completion haptics remain enabled because they communicate state.
// Externally supplied text controllers and focus nodes remain application-owned.
// Internally created text controllers and focus nodes remain State-owned.
// Focused regressions must tap the actual input rather than forge focus state.

// Extension tag-input reduced-motion contract.
// Keyboard entry, separator submission, backspace deletion, and chips remain direct.
// Focus and rejection outlines publish their final decoration without delay.
// Reduced surface decoration uses an exact zero implicit-animation duration.
// Ordinary surface decoration retains its two-hundred-twenty-millisecond duration.
// Duplicate, maximum-count, length, and custom validation policies stay unchanged.
// Rejection callbacks and semantic haptics continue to describe the same outcome.
// A rejected value must not appear temporarily as an accepted chip.
// Controller and focus-node ownership is unaffected by the motion preference.
// Tests inspect the surface decoration and rejection result after one bounded pump.

// Extension command-palette reduced-motion contract.
// Search filtering publishes its result collection immediately in every mode.
// Ordinary result-count changes retain the two-hundred-twenty-millisecond size change.
// Reduced motion builds the measured final-height panel without AnimatedSize.
// Removed result rows cannot remain as outgoing render or semantic children.
// Keyboard focus, arrow traversal, activation, and global shortcuts remain intact.
// Command invocation ordering remains independent from the panel height policy.
// Empty, populated, and constrained result sets use the same final measurement rules.
// A preference change never replays an earlier filter transition.
// Focused regressions inspect both the exact height and absence of AnimatedSize.

// Extension split-view reduced-motion contract.
// Divider pointer movement remains direct manipulation in every motion mode.
// Ordinary controller extent changes retain the three-hundred-millisecond easing.
// Ordinary collapse and expansion retain that same spatial continuity.
// Reduced motion publishes the constrained controller extent with zero duration.
// A collapsed primary pane is removed from the visible content branch immediately.
// The divider remains absent whenever the controller reports collapsed state.
// Keyboard and accessibility increments preserve their existing logical step.
// Boundary haptics remain coupled to an attempted constrained resize.
// External controller ownership and listener transfer remain unchanged.
// Focused regressions inspect exact geometry after one bounded pump.

// Extension data-table reduced-motion contract.
// Pointer selection, sorting, and direct scrollbar dragging remain direct input.
// Ordinary keyboard row movement retains its one-hundred-eighty-millisecond scroll.
// Reduced keyboard movement jumps to the same clamped target scroll offset.
// No intermediate scroll position may replace the focused-row destination.
// Row selection, focus, and hover surfaces use zero duration when reduced.
// Ordinary row surfaces retain their one-hundred-forty-millisecond color change.
// Sorting order, stable row identity, and selection callbacks remain unchanged.
// Selection and sort haptics continue to communicate the same semantic result.
// Horizontal overflow and its dedicated scrollbar lane remain unchanged.
// Focused regressions inspect row durations and the exact vertical offset.

// Extension file-drop reduced-motion contract.
// Native drag entry and exit remain direct platform-driven state changes.
// Reduced motion publishes border width, border color, and surface state directly.
// Ordinary drag-state decoration retains its one-hundred-eighty-millisecond change.
// The active instruction text changes with the same logical drag state in all modes.
// Native drop hit testing and browse activation remain enabled when configured.
// File count, extension, MIME, size, and custom validation remain unchanged.
// Accepted and rejected callbacks retain their order and typed rejection reasons.
// Threshold haptics remain enabled because they confirm the native drag boundary.
// Controller ownership and lazy byte-reading behavior remain unchanged.
// Focused regressions inspect the public surface duration without forging a drop.

// Core slider-family reduced-motion contract.
// Horizontal, vertical, and range variants share one inherited motion policy.
// Pointer position remains direct input and continues to publish every accepted value.
// Horizontal gesture priority over a parent pager remains unchanged.
// Vertical gesture priority over a parent scroll remains unchanged.
// Ordinary external value changes retain the calibrated progress spring.
// Reduced external value changes publish the exact normalized fraction directly.
// Enabling reduced motion during a progress spring cancels the prior velocity.
// The current controlled value, rather than an intermediate sample, owns settlement.
// Range start and end progress controllers settle independently to their endpoints.
// An active range drag retains its current thumb ownership when policy changes.
// Reduced thumb hover and drag scale publish the exact active scale directly.
// Reduced pointer exit and drag release publish the resting scale directly.
// Reduced drag-overlay entry publishes the exact authored alpha directly.
// Reduced overlay exit publishes transparent without retaining an old tween.
// Ordinary thumb scale retains its source-calibrated underdamped spring.
// Ordinary overlay entry and exit retain their one-hundred-fifty-millisecond tween.
// Key-point magnetism, divisions, RTL mapping, and reverse direction stay unchanged.
// Edge and step haptics remain coupled to direct value transitions.
// onChanged and onChangeFinished preserve their existing invocation boundaries.
// Disabled sliders remain non-interactive regardless of animation preference.
// Semantics increase and decrease actions continue to publish controlled values.
// The paint-snapshot test hook exposes only rendered values, not mutable controllers.
// Focused regressions first prove ordinary motion has an intermediate frame.
// They then toggle the inherited preference during that running motion.
// One bounded pump must expose exact horizontal, vertical, and range endpoints.
// A reduced drag must expose exact active scale and overlay alpha after one pump.
// A reduced release must expose exact resting scale and zero overlay after one pump.

// Slider controller and policy-transition maintenance requirements.
// Every slider body owns only the AnimationControllers created by its State.
// All owned controllers are stopped implicitly by disposal and then disposed once.
// No public value controller is introduced by the reduced-motion implementation.
// The caller remains the single authority for horizontal and vertical values.
// The caller likewise remains the single authority for both range endpoints.
// didChangeDependencies is the authority for inherited motion-policy changes.
// didUpdateWidget is the authority for controlled value and enabled-state changes.
// Initial reduced motion is discovered after all animation controllers exist.
// Initial settlement therefore uses the same endpoint path as a later toggle.
// A false-to-true policy change settles every currently running controller.
// A true-to-false change does not replay motion skipped while reduction was active.
// The next logical value, hover, drag, or release event may start ordinary motion.
// Controller stop uses cancellation so an old TickerFuture cannot claim completion.
// Direct controller value assignment follows stop and publishes one exact frame.
// Progress visibility thresholds apply only while an ordinary spring is running.
// Reduced settlement never approximates an endpoint through that threshold.
// Horizontal progress stores the normalized authored fraction from minimum to maximum.
// Vertical progress stores the same authored fraction despite inverted paint geometry.
// Vertical painting converts that fraction only after policy settlement has completed.
// Range progress stores start and end in two independent normalized controllers.
// Range normalization preserves ordered endpoints before either controller is driven.
// A range drag can transfer ownership only through the existing equality rule.
// Motion-policy changes cannot manufacture an ownership transfer between thumbs.
// Motion-policy changes cannot invoke onChanged or onChangeFinished by themselves.
// Disabling a slider still ends transient interaction through the existing path.
// That disabled transition settles its feedback directly when reduction is active.
// Hover hit testing samples the current painted progress for pointer locality.
// Reduced progress settlement therefore also updates the next hover hit target.
// Hover does not change the controlled slider value in either policy mode.
// Drag start continues to cross the platform gesture-slop recognizer first.
// A stationary press does not become a slider drag because animations are reduced.
// Drag updates continue to normalize callback values against finite safe bounds.
// The reduced policy does not bypass division snapping or custom key-point magnetism.
// Haptic dispatch continues to compare logical values rather than animation samples.
// Overlay activity remains a transient representation of current drag ownership.
// Forced overlay settlement is required when policy changes during an active tween.
// Without that force, an already-matching logical flag could leave stale paint alpha.
// Thumb settlement is always driven because hover and drag flags can overlap.
// Release settlement chooses the resting scale even if hover has already cleared.
// Pointer exit settlement chooses drag scale when an active drag still owns input.
// Range start and end thumb scales are resolved separately for simultaneous hover.
// Ordinary mode retains velocity continuity by continuing to use spring simulation.
// Reduced mode deliberately discards velocity because no autonomous travel remains.
// Paint diagnostics receive immutable frame data and cannot mutate component state.
// The diagnostic rejects unrelated CustomPainters instead of returning false evidence.
// Tests locate the slider painter inside each public widget subtree independently.
// The ordinary intermediate-frame assertion proves the test can detect a live spring.
// Endpoint assertions use tight tolerances so near-final frames cannot count as direct.
// Drag feedback assertions sample both activation and release after bounded pumps.
// Full-suite coverage remains necessary because color pickers reuse slider behavior.
// Gesture regressions remain necessary because sliders can live inside page pagers.

// Navigation system-inset reduced-motion contract.
// Android navigation-bar and caption-bar insets remain independent measurements.
// The navigation-bar inset always preserves the physical gesture-system gap.
// The caption-bar inset lifts the complete navigation surface above that gap.
// Ordinary caption appearance retains the source-compatible 300ms linear tween.
// Ordinary caption disappearance retains that same duration and directionality.
// Reduced motion publishes the current native caption endpoint with zero duration.
// Enabling reduced motion during a live inset tween settles the latest endpoint.
// The half-travel frame may never persist after the inherited preference changes.
// Disabling reduced motion does not replay a transition that was already skipped.
// A later native inset event may again use the ordinary transition duration.
// Regular and floating navigation bars consume the same inherited motion policy.
// Regular navigation keeps its item row independent from its bottom inset spacer.
// Floating navigation keeps the non-capsule system region completely transparent.
// Floating navigation preserves its authored outside margin above system insets.
// Caption settlement cannot change destination widths or selected-item geometry.
// Caption settlement cannot trigger destination callbacks or selection haptics.
// Caption settlement cannot replace the MediaQuery launch-frame fallback.
// The first explicit native zero still replaces any combined fallback padding.
// iOS retains its fixed regular-navigation spacer and floating authored margin.
// Desktop hosts without native events retain their documented zero-caption state.
// Focused regressions preserve the ordinary halfway frame at exactly 150ms.
// A separate regression toggles policy at that halfway frame and expects endpoint.
// Floating reduced-motion coverage inspects the capsule-to-host bottom distance.
// Both regressions inspect the actual public TweenAnimationBuilder duration.

// Page-indicator reduced-motion contract.
// The public count remains normalized to zero for negative input.
// The public index remains clamped to the available indicator count.
// Empty indicators remain absent and do not create animation state.
// The active page is represented by the authored 16dp low-wide mark.
// Every inactive page is represented by the authored 6dp circular mark.
// Ordinary index changes use the HyperOS segmented-control motion token.
// Applications can calibrate that token once instead of patching this widget.
// Ordinary width travel retains the shared ease-out cubic continuity.
// Active and inactive colors retain their existing semantic scheme channels.
// Reduced motion publishes all target widths with zero autonomous duration.
// Enabling reduced motion during width travel discards both sampled widths.
// Every dot is recreated against the latest controlled index for settlement.
// The stable outer indicator identity and layout direction remain unchanged.
// Disabling reduced motion does not replay the transition skipped previously.
// A later controlled index change may start the ordinary tokenized transition.
// Motion-policy changes cannot modify count, index, colors, or semantics.
// The component remains stateless and does not introduce controller ownership.
// Focused regression overrides the token to prove it is actually consumed.
// The same regression proves a detectable ordinary intermediate geometry.
// It toggles the inherited preference while both dot widths are in flight.
// One bounded pump must then expose exact 6dp and 16dp endpoint geometry.

// Carousel-indicator reduced-motion contract.
// Carousel page movement and indicator width remain separate animation channels.
// Direct pointer paging continues to follow the finger in either motion policy.
// Programmatic paging continues to use the controller's configured page motion.
// The built-in indicator consumes the same HyperOS token as page indicators.
// Its active authored width remains 18dp and inactive width remains 6dp.
// Its existing active and inactive extension palette channels remain supported.
// Ordinary indicator travel retains the shared ease-out cubic continuity.
// Reduced motion publishes the latest controlled carousel index immediately.
// Policy identity discards any indicator width sampled before that preference.
// Autoplay remains paused while reduced motion is active.
// A running programmatic page motion still settles through controller ownership.
// Indicator settlement cannot publish an additional page-change callback.
// Indicator settlement cannot emit a duplicate page-change haptic.
// Restoring ordinary motion does not restart a previously paused indicator tween.
// Focused coverage overrides the shared token to prove ordinary token routing.
// The reduced endpoint check includes the authored horizontal margins.
// Three rendered extents must therefore settle to 12dp, 12dp, and 24dp.

// Input and process token-routing contract.
// PIN active-cell outlines consume the shared HyperOS input-state token.
// Tag focus and validation outlines consume that same input-state token.
// Filter-chip selection remains independent through its dedicated chip token.
// Applications may calibrate editable state without retiming filter surfaces.
// Ordinary input transitions preserve their ease-out cubic continuity.
// Every PIN cell retains its independent controlled active-state target.
// Tag validation retains its error precedence over ordinary focus color.
// Reduced motion recreates live implicit input animations at their endpoints.
// A policy change cannot retain a sampled outline color or border width.
// Text entry, focus ownership, and completion callbacks remain unchanged.
// Process markers, connectors, and content share one process-state token.
// Applications may calibrate a complete process transition as one timeline.
// Ordinary marker and connector colors preserve ease-out cubic interpolation.
// Ordinary vertical content preserves top-aligned size continuity.
// Reduced process content remains structurally direct without AnimatedSize.
// Reduced marker and connector surfaces publish zero autonomous duration.
// Process controller selection and enabled-step rules remain unchanged.
// Motion-policy changes cannot advance a process or emit selection callbacks.
// Focused tests override both tokens with deliberately distinct durations.
// Those overrides prove routing instead of merely observing default constants.

// Form and file-input token-routing contract.
// Form validation height uses the same input-state token as editable outlines.
// Ordinary validation insertion retains top-aligned ease-out cubic continuity.
// Reduced validation keeps the direct structural branch without AnimatedSize.
// File-drop borders and active surfaces consume the shared input-state token.
// Ordinary native drag entry and exit retain ease-out cubic interpolation.
// Reduced native drag feedback recreates its implicit surface at the endpoint.
// Browse activation and native drop callbacks remain independent from motion.
// File acceptance, rejection, byte reading, and validation rules stay unchanged.
// Focused tests override the token for both form and file-input surfaces.
// They prove ordinary routing and a live inherited preference transition.

// Adaptive and command-surface token-routing contract.
// Programmatic split-view extent changes consume the inline-surface token.
// Collapse and expansion retain the same tokenized spatial continuity.
// Direct divider dragging always publishes geometry with zero duration.
// Entering direct drag recreates a running implicit layout at current extent.
// Reduced motion likewise recreates the primary pane at its controlled extent.
// Divider semantics, haptics, and constrained resize rules remain unchanged.
// Command-palette result-height changes consume the inline-surface token.
// Ordinary result filtering retains top-aligned ease-out cubic continuity.
// Reduced command results retain the direct structural panel branch.
// Query ownership, keyboard focus, highlight, and invocation stay unchanged.
// Focused tests override the shared token in both independent components.

// Dense collection token-routing contract.
// Data-row hover, focus, and selection use the collection-row motion token.
// Keyboard focus positioning uses the separate collection-scroll motion token.
// Pointer wheel and direct scrollbar input remain direct platform scrolling.
// Ordinary keyboard movement retains an observable intermediate scroll offset.
// The latest keyboard target remains owned until its animation completes.
// A superseding keyboard command replaces that target without stale cleanup.
// Enabling reduced motion during travel jumps to the latest clamped target.
// The inherited-policy generation rejects obsolete post-frame settlement work.
// Completed, canceled, or manually superseded animation futures clear ownership.
// Reduced row surfaces recreate at exact semantic color endpoints.
// Sorting, stable row identity, selection callbacks, and haptics stay unchanged.
// Focused regression overrides both collection tokens with distinct durations.
// It proves ordinary intermediate travel before toggling the inherited policy.

// Swipe-action token-routing contract.
// Pointer drag displacement remains direct and independent from theme duration.
// Threshold comparison and threshold haptics remain coupled to pointer travel.
// Autonomous open, close, cancel, and release settlement use one theme token.
// The animation controller receives that token through inherited dependencies.
// A live theme replacement may retime future and currently owned settlement.
// Reduced motion stops a running controller and retains its latest target.
// Post-frame settlement is guarded by the existing motion generation.
// Obsolete animation completion cannot overwrite a newer drag or controller side.
// Focused regression uses 777ms so the former 320ms clock cannot pass unnoticed.
// The same regression toggles reduction while that longer motion is still active.

// Context-menu token-routing contract.
// Anchor placement and safe-edge clamping remain independent from animation.
// Long-press, secondary-click, and accepted-action haptics remain unchanged.
// Normal route entrance and exit use the HyperOS 4 context-menu motion token.
// Reduced motion selects a zero route duration before the popup is presented.
// A focused regression overrides the token with a distinctive 777ms duration.
// It observes a normal intermediate opacity after the former 260ms endpoint.
// The same route opened under reduced motion must be fully visible immediately.

// Sliver-top-app-bar snap token-routing contract.
// Scroll-driven collapse remains a direct mapping from the sliver shrink offset.
// Floating re-entry settlement reads a dedicated HyperOS 4 theme duration.
// The delegate receives the resolved value so a theme replacement rebuilds it.
// Reduced motion publishes a zero-duration snap configuration at runtime.
// Pinned geometry, safe insets, glass reveal, and bottom content remain unchanged.
// Focused regression distinguishes the token with a 777ms configuration value.
// It then toggles reduction and observes the same delegate at the zero endpoint.

// Skeleton token-routing contract.
// The compatibility default duration delegates to the HyperOS 4 theme token.
// A non-default public duration remains an explicit component-level override.
// Normal loading repeats one complete highlight traversal on the resolved clock.
// Reduced motion stops autonomous traversal and settles at the stable midpoint.
// Disabled placeholders use the same midpoint, avoiding a random frozen phase.
// Zero-duration theme or widget overrides also select that deterministic state.
// Focused regression distinguishes theme routing with a 2777ms duration.
// It observes ordinary progress before toggling the inherited reduced policy.

// Carousel and page-indicator token-routing contract.
// Direct PageView dragging remains owned by the pointer and Flutter viewport.
// Default controller, autoplay, next, and previous movement use carousel motion.
// A non-default public duration remains an explicit controller-level override.
// Reduced motion jumps to the latest logical destination and pauses autoplay.
// Standalone and embedded page dots share a dedicated indicator motion token.
// They no longer inherit the semantically unrelated segmented-control clock.
// Runtime reduction recreates implicit dots at exact width and color endpoints.
// Focused regression uses 777ms page and 444ms indicator theme overrides.
// The page remains intermediate beyond the former 420ms default before snap.

// Tree-row selection token-routing contract.
// Selection ownership, keyboard navigation, expansion, and loading stay direct.
// Row background and foreground interpolate on the collection-row motion token.
// The interactive row radius reads the collection-row corner calibration token.
// Stable node keys preserve normal retargeting when selection changes quickly.
// A policy-keyed animation discards sampled color when reduction turns on.
// Reduced motion rebuilds the selected row at its exact semantic color endpoint.
// Node semantics and selection callbacks publish the logical state immediately.
// Focused regression uses 777ms motion and a distinctive 23dp test radius.

// Reorder-proxy reduced-motion contract.
// Drag position remains direct because ReorderableListView owns pointer motion.
// Ordinary proxy scale and elevation continue to follow its supplied animation.
// Reduced motion maps that autonomous lift channel directly to its complete state.
// Long-press, reorder-start, reorder-end, and confirmation haptics remain intact.
// Proxy clipping consumes the shared collection-row corner calibration token.
// A focused regression supplies a quarter-progress animation under reduction.
// It proves full elevation, full scale, and the distinctive 23dp test radius.

// Tree-branch insertion and removal contract.
// The flattened logical list remains authoritative for keyboard navigation.
// AnimatedList mirrors only that list's visible insertions and removals.
// Branch rows combine top-anchored size and opacity on a dedicated theme token.
// Lazy loading completes before its children enter the logical visible list.
// Collapse removes descendants logically before their retained exit paint ends.
// Runtime reduction replaces AnimatedList with the exact current logical set.
// No half-height outgoing or incoming row survives that inherited-policy change.
// Arbitrary application data reordering resets atomically rather than faking it.
// Focused regression uses 777ms and observes an actual partial-height child.
