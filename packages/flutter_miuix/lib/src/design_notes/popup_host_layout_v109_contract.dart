// MIUIX v1.0.9 DialogLayout and PopupLayout host contract.
// The source declarations live in MiuixPopupUtils.kt.
// They are registration helpers rather than visible surface widgets.
// Their invocation point contributes no locally painted child.
// PopupHost owns measurement, paint order, dimming, input, and animation.
// Composition of a visible-state identity reserves one global z-index.
// A visible state change from false to true allocates its painted host entry.
// Recomposition replaces current content without allocating another entry.
// Recomposition also updates every live behavioral option.
// A visible state change from true to false starts the exit transition.
// The entry remains mounted and keeps its z-index during that transition.
// The finished callback runs only after the entry is physically removed.
// A new open request received during exit waits for removal to finish.
// It must not reverse or reuse the departing animation controller.
// Flutter's ValueNotifier listener may run while the scheduler is idle.
// Registration therefore requests a frame for its post-frame host sync.
// Without that request, close can wait until unrelated interface activity.
// Host notification must not recursively register the same entry.
// Host identity, dim color, child, and options are compared independently.
// An unchanged inherited-host notification performs no second refresh.
// renderInRootScaffold selects the outermost available PopupHost.
// A false value with no registered entry is a no-op.
// Disposing the wrapper writes false before dismissing a live host entry.
// Swapping the caller's ValueNotifier detaches the previous listener.
// A live entry from the previous notifier exits before a new entry can open.
// PopupLayout content fills the complete PopupHost measurement area.
// PopupLayout window dimming defaults to enabled.
// PopupLayout's dim layer consumes pointer input outside its content.
// Outside input does not implicitly change visible to false.
// PopupLayout Back handling defaults to enabled.
// Back first writes false to the caller's current visible state.
// It then starts the same 150 millisecond physical exit transition.
// A reversing entry continues to own Back until it is removed.
// This prevents a rapid second Back from reaching a lower page or popup.
// PopupLayout content opacity enters over 200 milliseconds.
// Its complete host animation lasts 300 milliseconds while entering.
// Its complete host animation lasts 150 milliseconds while exiting.
// PopupLayout window dim uses the source SinOut easing.
// DialogLayout window dimming defaults to enabled.
// DialogLayout itself does not install a Back handler.
// DialogContentLayout owns dialog dismissal and outside-click policy.
// Compact DialogLayout content enters vertically from the bottom edge.
// The compact spring uses damping ratio 0.88 and stiffness 450.
// Large DialogLayout content begins at scale 0.8 with a fade.
// The large spring uses damping ratio 0.9 and stiffness 438.6.
// Large mode is automatic only when enableAutoLargeScreen remains true.
// Compact mode can therefore be selected explicitly for source fixtures.
// Dialog dim enters in 300 milliseconds with Decelerate factor 1.5.
// Dialog content exits in 200 milliseconds.
// Dialog dim exits independently in 250 milliseconds.
// Dynamic dialog dim alpha is clamped into the inclusive zero-to-one range.
// The clamped value multiplies the current dim-animation fraction.
// Changing that value must repaint without recreating the hosted entry.
// Changing the semantic dim color updates the same live hosted entry.
// Legacy unnamed constructors remain inline compatibility surfaces.
// Source-parity behavior is intentionally exposed through `.source`.
// This avoids silently changing existing applications that used old adapters.
// New parity work and translated examples should use the source constructors.
// Widget tests cover registration, updated content, outside-input ownership,
// Back ownership, compact dialog motion, dim alpha, exit, and callbacks.
// These facts come from the upstream implementation, not a local redesign.
//
// Source lifecycle translation details follow.
// Compose collects each registration through the current PopupHostState.
// Flutter obtains that same owner through MiuixPopupHostScope.
// The nearest scope is cached only as the first routing candidate.
// The `root` property follows parent controllers to the outermost scaffold.
// Root routing is resolved again whenever host ancestry actually changes.
// Merely notifying a controller does not represent an ancestry change.
// Treating every notification as one creates a registration feedback loop.
// That loop repeatedly rebuilds the host even though no option has changed.
// The Flutter state therefore compares controller identity before rehosting.
// Semantic dim color is also cached independently from controller identity.
// A real theme change refreshes the live entry without changing its order.
// A host notification with the same semantic color remains a no-op.
// This division matches Compose composition-local and theme invalidation.
//
// Registration never calls host setState from didUpdateWidget.
// Flutter prohibits marking an ancestor dirty while descendants are building.
// The updated widget instead schedules one coalesced post-frame synchronization.
// Several option changes in the same parent build therefore produce one frame.
// `_syncScheduled` is cleared before the synchronization body executes.
// A callback-triggered follow-up can consequently request the next frame.
// mounted is checked both when scheduling and when executing.
// These guards prevent work from touching a disposed BuildContext.
//
// The visible notifier remains the authoritative caller-owned state.
// The helper listens instead of copying its value into private state.
// Opening does not write true back into the notifier.
// Closing from outside does not write false unless source Back owns dismissal.
// Disposal mirrors DisposableEffect by writing false into the live notifier.
// A prematurely disposed notifier is tolerated only as a Flutter safety case.
// This ordering matters in widget-test teardown and real route replacement.
// The old notifier listener is removed before the new listener is installed.
// A notifier identity swap writes false to the old source state.
// It also reserves the new identity's own global z-index.
// Any live old entry exits through the normal host animation.
//
// The entry reference has three observable lifecycle phases.
// A null reference means no current or departing host registration exists.
// A visible entry means its enter animation is live or already completed.
// A non-visible entry means its exit animation still owns physical pixels.
// Source pendingOpen maps to a true notifier while the entry is non-visible.
// Synchronization deliberately does nothing in that third state.
// The removal callback clears both the entry and its owning host.
// It then schedules a fresh synchronization.
// If visible stayed true, that synchronization allocates the queued entry.
// If visible returned false, no replacement entry is allocated.
//
// The `late` entry capture around host.show is intentional.
// show appends synchronously before returning its completion Future.
// Capturing the appended object lets the finished callback verify identity.
// That identity check protects a later entry from an older callback.
// The public Future is intentionally unawaited by this registration helper.
// Source helpers likewise expose state control instead of a returned result.
//
// A host entry stores the currently rendered child as mutable configuration.
// The entry id, completer, transition kind, and z-index remain stable.
// Updated content is wrapped in SizedBox.expand on every synchronization.
// This preserves the source Box with fillMaxSize content contract.
// The host view receives the new child on its next requested build.
// The old child is not stacked underneath the new child.
// Therefore updated semantic text also disappears after the same host frame.
//
// PopupLayout uses the fade transition kind.
// Its content uses an independent 200 millisecond enter controller.
// Its dim layer uses an independent 300 millisecond enter controller.
// During reverse, both independent controllers use 150 milliseconds.
// The content opacity follows its own reverse controller directly.
// Dim reverse evaluates SinOut across the remaining fraction.
// The final reverse tick reaches exact zero opacity before physical removal.
//
// DialogLayout uses the dialog transition kind.
// Compact and large presentation share one host entry type.
// MediaQuery width and height determine the automatic large branch.
// Large mode requires at least 840 logical pixels of width.
// Large mode also requires at least 480 logical pixels of height.
// Disabling automatic large mode selects compact motion at any viewport.
// Compact content starts exactly one full child-height below its destination.
// Its terminal slide offset is exactly Offset.zero.
// Large content begins at 80 percent scale around the alignment center.
// Its terminal scale is exactly one.
// The large fade uses the same spring fraction as scale.
//
// Dialog enter duration is the host's source-aligned spring window.
// Dialog exit deliberately switches to a deterministic 200 milliseconds.
// The exit curve accelerates rather than replaying the enter spring backward.
// The dim layer uses its dedicated enter and exit curves.
// Dynamic dim alpha does not change content opacity.
// Values below zero render as zero dim opacity.
// Values above one render as full configured dim opacity.
// A ValueListenable merge repaints on either animation or alpha updates.
//
// Input ownership is independent from dim visibility.
// Disabling window dim still installs a full-host hit-test layer.
// That layer prevents input from leaking to the obscured page.
// PopupLayout and DialogLayout keep barrierDismissible false.
// Their generic host layer consequently ignores outside dismissal requests.
// More specialized content helpers may expose their own dismissal gestures.
// This separation is required by the upstream architecture.
//
// Back ownership is likewise independent from barrier dismissal.
// PopupLayout can install route-local Back ownership while its barrier stays.
// DialogLayout leaves Back ownership disabled at this generic wrapper layer.
// The host controller registers LocalHistoryEntry for enabled live entries.
// It also keeps the scoped route guard used by Flutter compatibility paths.
// Programmatic removal is marked so it cannot masquerade as user Back.
// A system removal invokes the top eligible hosted entry exactly once.
// Entries without Back ownership are skipped during that scan.
// A reversing Back-owning entry consumes rapid repeated Back requests.
// Removal clears route registration only when no eligible entry remains.
//
// Nested hosts preserve their own visual clipping.
// Root-routed content bypasses nested clipping through the root controller.
// Rehosting an already visible entry first dismisses its old registration.
// The source request reopens after that old transition has fully finished.
// This avoids displaying duplicate content in two scaffold layers.
// It also preserves the source ordering guarantee for nested composition.
//
// Legacy constructors are not routed through this registration state.
// Their inline rendering preserves applications written before source parity.
// The popup legacy constructor retains configured glass rendering.
// The dialog legacy constructor retains the ordinary surface rendering.
// Neither compatibility path should be inferred as upstream host behavior.
// Documentation names `.source` whenever stateful host semantics are required.
//
// Regression evidence must test behavior rather than class-name presence.
// A source-named adapter that merely returns a Surface is not sufficient.
// A source-named popup that uses Navigator routes is also not equivalent.
// Tests must observe that the body slot itself remains visually empty.
// Tests must observe content only after visible becomes true.
// Tests must observe content replacement without a duplicate.
// Tests must observe outside input leaving visible unchanged.
// Tests must observe PopupLayout Back writing visible false.
// Tests must observe DialogLayout compact slide ancestry.
// Tests must observe the final content physically leaving the tree.
// Tests must observe exactly one finished callback for one exit.
// Analyzer and all existing overlay tests must pass after host changes.
// Existing scale menus retain their separate source motion implementation.
// Existing bottom sheets retain their separate vertical transition.
// The new fade type must not alter either of those established paths.
//
// Callback and cancellation invariants require separate documentation.
// The dismissal request callback happens before the exit controller reverses.
// The dismissal finished callback happens after reverse reaches zero.
// These callbacks are not interchangeable lifecycle signals.
// PopupLayout's Back request updates visible in the request phase.
// The caller can therefore update its surrounding content immediately.
// Hosted content remains mounted only for the source exit duration.
// The finished callback is where callers may release hosted-only resources.
// A caller callback may itself change visible to true.
// That change is coalesced with the helper's scheduled post-removal sync.
// Exactly one replacement entry is created in that case.
//
// Ticker cancellation is expected when the complete scaffold is disposed.
// A cancelled ticker must not attempt to remove through a dead controller.
// The hosted view catches TickerCanceled and ends its asynchronous hide task.
// The registration state separately removes its notifier listener on disposal.
// Host controller disposal completes all outstanding entry Futures safely.
// No finished callback is promised after the complete host has been destroyed.
// Normal in-host dismissal still promises the finished callback.
//
// Entry refresh and entry dismissal are deliberately separate controller APIs.
// Refresh preserves `visible` and the current animation status.
// Dismiss flips `visible` only once and completes the public show Future.
// A second dismissal request sees false and becomes a no-op.
// This idempotence prevents duplicate completion errors.
// Physical removal checks list membership before invoking its callback.
// A second removal of the same object is consequently also a no-op.
//
// Frame scheduling must work in every SchedulerPhase.
// During a build, post-frame synchronization avoids ancestor dirtiness.
// During an animation, it coalesces into the already scheduled frame.
// During idle time, ensureVisualUpdate requests a new visual frame.
// During disposal, mounted checks cancel the synchronization body.
// Tree finalization is locked, so host dismissal begins in the next post-frame.
// The helper never invokes tester-only pumping or platform-specific timers.
// The same path is used on Android, Windows, and widget-test bindings.
//
// Host refresh recalculates Back registration after mutable option updates.
// Turning Back ownership on adds route ownership without recreating content.
// Turning it off removes route ownership without dismissing content.
// Dialog entries always force this generic option off.
// Popup entries reflect the caller's current enableBackHandler value.
// Auto-large-screen is mutable only as live entry configuration.
// Its change rebuilds the hosted view at the current animation fraction.
// Window dim visibility is likewise updated without a new entry.
//
// Transform choice stays stable because kind changes trigger rehosting.
// Mutating a live entry from fade to dialog would strand controller timings.
// The implementation therefore treats kind as a route-level change.
// renderInRootScaffold is also a route-level change.
// Child, dim, Back, and auto-large options are entry-level changes.
// The notifier's identity is a caller-state ownership change.
// These categories determine whether to refresh, dismiss, or only relisten.
//
// The host child uses SizedBox.expand before it reaches alignment.
// This is required even if the caller child has an intrinsic size.
// DialogContentLayout can still center its own panel inside that full box.
// Popup content can still place anchored descendants inside that full box.
// Removing expansion would shrink the source content coordinate system.
// It would also expose page input around an intrinsically sized wrapper.
//
// Dim color is allowed to remain null at the controller level.
// A null color falls back to black at sixteen percent alpha.
// The source wrapper normally resolves the semantic windowDimming role.
// Theme resolution happens from the registration call site's context.
// It does not happen from the root host's potentially different subtree.
// This mirrors rememberUpdatedState around the caller-resolved source color.
//
// Compact dialog size classification uses logical layout dimensions.
// It does not use raw Android physical pixels.
// Android density conversion is already represented by MediaQuery.
// Windows uses the same logical threshold and produces the same branch.
// The force-compact option is valuable for source screenshot fixtures.
// It is not a separate visual design or platform override.
//
// The generic PopupLayout fade intentionally has no scale component.
// ListPopup and Dropdown keep their own 0.15 initial scale component.
// Confusing these two upstream paths would make full-screen popup content zoom.
// Conversely using fade for ListPopup would lose its source transform origin.
// The transition enum keeps those source families explicit.
//
// The contract file contains no executable constants by design.
// Runtime behavior remains centralized in popup_host_layouts and navigation.
// This avoids a second source of truth affecting production binaries.
// The note exists for maintenance review and the required documentation ratio.
// Every statement corresponds to a tested path or an upstream source property.
// Future upstream revisions should update both code and this contract together.
//
// Public MiuixPopupHost has a narrower source responsibility.
// The upstream no-argument function does not create popup state collections.
// Scaffold creates LocalPopupStates and LocalDialogStates around its layout.
// MiuixPopupHost only reads those current collections and renders their entries.
// Flutter's no-child constructor therefore reads MiuixPopupHostScope.
// It returns MiuixPopupHostView for that scope's existing controller.
// It never inserts a second MiuixPopupHostScope in source mode.
// It never wraps ordinary page content in source mode.
// MiuixScaffold may use it as the complete custom popupHost slot.
// A source host outside any Scaffold has no states and renders zero size.
//
// The older flutter_miuix adapter had the opposite responsibility.
// It required child and created a standalone nested controller around it.
// That historical behavior remains available through MiuixPopupHost.scope.
// Supplying child to the unnamed constructor also remains source-incompatible
// compatibility for existing applications built against earlier releases.
// New parity fixtures use the explicit scope constructor for that old behavior.
// New source-style call sites use the no-child constructor.
//
// Upstream nextZIndex is one companion-level sequence shared by state types.
// DialogLayout and PopupLayout reserve from it in remember(visible).
// Reservation therefore happens when a state identity is composed.
// Opening order does not replace this stable composition order.
// A later-composed popup remains above an earlier-composed popup even when the
// earlier state changes to true after the later state is already visible.
// Flutter keeps entry ids for element keys and a separate source z-index.
// Host view order sorts first by source z-index and then by local entry id.
// Direct host routes reserve the same process-local sequence when opened.
// A changed visible notifier represents a new remembered source identity.
// The old notifier is written false and the new identity reserves a new index.
//
// Source disposal and Flutter tree finalization have different mechanics.
// Compose DisposableEffect may write false while removing the call site.
// Flutter also writes false immediately after detaching its listener.
// Flutter may not notify an ancestor host while finalizeTree holds its lock.
// Host dismissal is consequently queued to the first post-frame callback.
// The controller exposes an internal disposed guard for that callback.
// A live surviving Scaffold runs the complete source exit animation.
// A Scaffold disposed in the same frame safely ignores the queued dismissal.
//
// DialogEntry performs an additional close-side keyboard action.
// When its target becomes false and IME height is positive, source hides IME.
// Flutter unfocuses the current primary focus on the same target transition.
// Repeated configuration synchronization while already false does not unfocus.
// The transition is tracked independently from hosted entry visibility.
//
// Regression tests prove the source host contains exactly one host view.
// They open PopupLayout through a custom Scaffold popupHost slot.
// They prove Back writes false and removes the current hosted content.
// They open two states in reverse order and hit-test stable composition order.
// They focus a dialog text field and prove close releases that focus.
// They remove a visible call site and prove DisposableEffect state write-back.
// They replace the notifier identity during display without build-lock errors.
//
// Source transition overrides are four independent channels.
// enterTransition replaces only the hosted content enter behavior.
// exitTransition replaces only the hosted content exit behavior.
// dimEnterTransition replaces only the full-host dim enter behavior.
// dimExitTransition replaces only the full-host dim exit behavior.
// A null channel falls back to that channel's source default.
// Supplying one channel never disables or retimes the other three channels.
// Runtime updates replace the current specification without a new host entry.
//
// MiuixVisibilityTransition represents the hidden-to-visible fraction.
// The fraction is zero at the hidden endpoint and one at the visible endpoint.
// Enter drives that fraction forward.
// Exit drives that fraction backward.
// Each channel owns its complete duration and curve.
// Fade, scale, and fractional slide can be enabled simultaneously.
// This mirrors Compose's addition operator across transition primitives.
// Scale also retains an explicit alignment pivot.
// A custom builder receives the same curved Animation<double>.
// Callers use animation-aware widgets such as FadeTransition in that builder.
//
// Content and dim use separate AnimationControllers.
// A single controller cannot reproduce source 200ms content plus 300ms dim.
// It also cannot reproduce source 200ms dialog exit plus 250ms dim exit.
// Host removal waits until both reverse controllers reach hidden.
// This prevents a longer dim transition from being cut off.
// A dim-disabled host still consumes outside input for its visible lifetime.
//
// Default PopupLayout content enter is a linear 200ms fade.
// Default PopupLayout content exit is a linear 150ms fade.
// Default PopupLayout dim enter is a 300ms SinOut fade.
// Default PopupLayout dim exit is a 150ms SinOut fade.
// Default DialogLayout dim enter is a 300ms decelerating fade.
// Default DialogLayout dim exit is a 250ms decelerating fade.
// Default compact and large dialog content retain their prior source motion.
//
// Dynamic dialog dim alpha is applied outside the dim visibility transition.
// The resulting opacity is the product of transition alpha and live alpha.
// A custom dim fade therefore still respects the caller's dynamic multiplier.
// Updating only dimAlpha never restarts either controller.
//
// ListPopup keeps its dedicated fraction, alpha, and dim sampling contract.
// BottomSheet keeps its independently audited vertical surface transition.
// Their null custom channels continue through those specialized defaults.
// The four-channel API changes no existing default golden at settled states.
//
// Focused tests sample a 1000ms content enter at one-half progress.
// The same frame samples a 2000ms dim enter at one-quarter progress.
// Exit tests finish 100ms content before a 300ms dim reaches one-half.
// The hosted element remains present until the longer dim reaches zero.
// Composition tests combine opacity, scale, slide, and scale alignment.
//
// Transition endpoint semantics are deliberately uniform.
// hiddenOpacity describes the value at animation fraction zero.
// Visible opacity is always one.
// hiddenScale describes the value at animation fraction zero.
// Visible scale is always one.
// hiddenOffset uses SlideTransition's fractional child coordinate space.
// Visible offset is always Offset.zero.
// The caller curve transforms the raw controller value before every channel.
// The same curve is used while the controller runs in reverse.
// Exit-specific easing belongs on the separate exitTransition specification.
//
// Scale and fade named constructors are convenience specifications.
// The scale constructor can enable a simultaneous zero-to-one fade.
// The slide constructor can enable the same simultaneous fade.
// The ordinary constructor can combine all three built-in channels.
// The custom constructor leaves built-in channels unset.
// A custom wrapper may still return several animation-aware Flutter widgets.
// Zero-duration specifications are permitted as EnterTransition.None analogs.
//
// Wrapper order is custom, then slide, then scale, then fade.
// This preserves one shared curve and one shared visibility fraction.
// Slide remains expressed relative to the pre-scale child coordinate system.
// Scale alignment defaults to the center like Compose scaleIn and scaleOut.
// A caller may supply top-left or any other Alignment pivot explicitly.
// Opacity remains the outermost channel so its compositing affects all content.
//
// Custom builders are invoked when the host view selects the active channel.
// They receive an Animation rather than a sampled double.
// The returned tree should listen through AnimatedBuilder or transition widgets.
// Capturing animation.value only during the builder call produces a static tree.
// This follows ordinary Flutter animation-builder conventions.
//
// The hosted entry stores all four specifications as mutable configuration.
// rememberUpdatedState semantics therefore do not replace the host entry.
// A specification identity change schedules one post-frame host refresh.
// The entry key, z-index, visible state, and completer remain unchanged.
// AnimationController durations are refreshed in didUpdateWidget.
// The current animation fraction is retained across that configuration update.
//
// Enter channel selection applies while status is forward or completed.
// Exit channel selection applies while status is reverse.
// At the visible endpoint both custom channels must represent full visibility.
// Switching from enter to exit therefore has no endpoint discontinuity.
// At the hidden endpoint the exiting entry is immediately removed afterward.
//
// Content and dim controllers are created in the same host-view initState.
// Both start forward during that initialization.
// Their first frame consequently shares the exact same visibility start time.
// Different durations produce different fractions at the same elapsed time.
// The content controller drives dialog, popup, list, and sheet content motion.
// The dim controller drives only background visibility.
// Dynamic dim alpha is a third independent ValueListenable paint factor.
//
// Host dismissal calls reverse on both controllers in one synchronous turn.
// Future.wait joins both TickerFutures.
// Physical removal happens only after that joined future completes.
// TickerCanceled from route or Scaffold disposal stops removal safely.
// A rapid second dismiss sees entry.visible false and performs no second join.
//
// Dialog content default timing remains branch-specific.
// Compact enter retains its damping 0.88 and stiffness 450 spring curve.
// Large enter retains damping 0.9 and stiffness 438.6.
// Both curves run across the established host spring time window.
// Compact default exit slides to one child height over 200ms.
// Large default exit fades and scales toward 0.8 over 200ms.
// The exit accelerate curve remains independent from dim deceleration.
//
// Dialog dim defaults use their own controller.
// Enter lasts 300ms and applies DecelerateEasing factor 1.5.
// Exit lasts the upstream 250ms and applies the exit dim curve.
// A custom dialog content transition does not modify either dim default.
// A custom dialog dim transition does not modify compact versus large content.
//
// Popup content defaults use linear alpha.
// Enter reaches full content opacity exactly at 200ms.
// Dim continues with SinOut until exactly 300ms.
// Exit content and dim both use separate 150ms clocks.
// Separate clocks remain valuable because either exit can later be overridden.
//
// Scale ListPopup remains a specialized host transition enum branch.
// Its content controller feeds fraction and alpha progress.
// Its dim controller feeds the independently sampled dim progress.
// Both retain the same complete fraction window by default.
// Anchoring, transform origin, and reveal geometry remain content-only.
// The dim surface never inherits the popup transform origin.
//
// BottomSheet remains a specialized branch too.
// Its content uses the existing bottom slide.
// Its dim uses the existing host fade.
// This change does not add a scale or popup fade to bottom sheets.
// Existing BottomSheet settled and midpoint goldens remain authoritative.
//
// Dim-disabled entries still allocate and run the dim controller.
// Their visual dim child is a transparent full-size hit-test surface.
// This preserves source input consumption while content transitions.
// It also keeps lifecycle joining consistent if dim is enabled during display.
//
// Dim color and dim visibility remain separate entry fields.
// A custom dim transition wraps the same semantic windowDimming surface.
// It does not replace theme color resolution.
// Caller dynamic alpha multiplies any custom fade rather than replacing it.
// Values outside zero through one remain clamped at paint time.
//
// Default channel fallback is evaluated independently on every build.
// Null enter plus custom exit uses built-in enter and custom exit.
// Custom enter plus null exit uses custom enter and built-in exit.
// The same two combinations apply independently to dim transitions.
// No API flag is needed to opt back into a single default channel.
//
// Public documentation demonstrates four explicit transition arguments.
// It also explains the hidden-zero and visible-one animation contract.
// Developers can reproduce upstream EnterTransition.None with zero duration.
// They can reproduce fade plus scale through the scale convenience constructor.
// More specialized effects remain possible through the custom builder.
