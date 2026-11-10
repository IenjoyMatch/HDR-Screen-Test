// ListPopup and CascadingListPopup predictive-Back parity contract.
//
// Authority
//
// This contract follows the current upstream MIUIX source checkout.
// Ordinary list-popup behavior comes from ListPopupLayout.kt.
// Cascading behavior comes from CascadingListPopupLayout.kt.
// Search behavior comes from SearchBar.kt and is recorded for contrast.
// The implementation must be checked again when those source files change.
// Symbol coverage alone does not prove any rule documented below.
// Widget tests prove event routing and deterministic sampled geometry.
// Android runtime evidence remains required for platform gesture integration.
//
// Progress ownership
//
// A visible ordinary popup owns an independent backProgress value.
// Its resting value is zero.
// Platform gesture progress is copied directly into that value.
// The value is not eased while the pointer is moving.
// The value is clamped only at the Flutter platform boundary.
// Button Back does not write a predictive progress sample.
// Button Back continues through PopScope or the hosted history entry.
// A predictive gesture is accepted only by the top visible popup.
// A reversing popup keeps Back ownership until physical removal.
// A hidden popup must never pass a queued Back event to the page below.
// Window and Overlay presentations use the same visual progress equations.
// Their route ownership differs, but their rendered samples must not differ.
//
// Ordinary popup content
//
// The settled entrance fraction is one.
// The settled entrance alpha is one.
// The effective fraction is entranceFraction times one-minus-backProgress.
// The effective alpha is entranceAlpha times one-minus-backProgress.
// The scale equation remains 0.15 plus 0.85 times effectiveFraction.
// A half-progress Back sample therefore paints scale 0.575 when settled.
// A half-progress Back sample therefore paints content alpha 0.5.
// The reveal clip samples the same effective fraction as the scale.
// Scale and reveal must retreat toward the resolved popup spawn corner.
// The transform origin must come from actual above, below, or middle placement.
// The origin must not be guessed from the requested alignment after layout.
// A right-aligned popup retreats toward its right edge.
// A left-aligned popup retreats toward its left edge.
// A popup above its anchor retreats toward its bottom edge.
// A popup below its anchor retreats toward its top edge.
// A vertically centered popup retreats toward its vertical midpoint.
// Pointer hit testing remains in the settled popup layout coordinates.
// Paint-only reveal clipping must not shrink the interactive row bounds.
//
// Ordinary popup dim
//
// The settled dim progress is one.
// Effective dim is dimProgress times one-minus-backProgress.
// The source semantic window-dimming color remains unchanged.
// Only its effective opacity changes during Back.
// Window route barriers remain transparent.
// The popup-owned dim layer supplies the visible color and timing.
// Overlay hosts multiply their existing dim animation by the same inverse.
// A half-progress Back sample therefore paints half of settled dim opacity.
// Disabling window dim still leaves a full-screen outside-tap target.
// Disabling window dim must not create an invisible extra alpha layer.
// Cascading depth one is an exception and does not reduce the outer dim.
//
// Ordinary popup cancellation
//
// Cancellation animates backProgress from its current sample to zero.
// The reset uses ListPopupDefaults.ResetAnimationSpec.
// That spec has damping ratio 0.82.
// That spec has stiffness 362.5.
// That spec has visibility threshold 0.0001.
// Flutter samples its closed-form response over the established spring window.
// Reset must start from the latest platform sample.
// Reset must not jump to one and play an entrance animation.
// Reset must not change the route-visible state.
// Reset must not invoke onDismissRequest.
// Reset must not invoke onDismissFinished.
// The popup remains the active Back owner throughout reset.
// A new gesture atomically replaces the old reset ownership.
// An asynchronous completion from the old reset must not clear the new owner.
//
// Ordinary popup commit
//
// Commit requests normal source dismissal at depth zero.
// It does not invent a second gesture-completion animation.
// The current Back sample remains applied while ordinary exit begins.
// The surface may already be visually absent when progress reached one.
// onDismissRequest fires exactly once.
// onDismissFinished fires after the host has removed the surface.
// Window commit pops only its popup route.
// Overlay commit hides only its top hosted entry.
// A commit must not pop the application page behind an Overlay popup.
// A queued second Back remains consumed during the reverse lifecycle.
//
// Cascading depth model
//
// A cascading popup is one popup with two navigation depths.
// Depth zero means only the primary plane is logically expanded.
// Depth one means a secondary plane has a non-null expanded parent.
// The displayed parent outlives logical expansion during collapse.
// The secondary surface remains mounted until its main spring settles.
// A single platform Back event must affect exactly one depth.
// Gesture depth is frozen when the predictive gesture starts.
// A depth change during the gesture must not transfer its progress channel.
// Two independent Back tracks permit a depth-zero gesture during settle.
// backEnterProgress belongs to the complete popup entrance tree.
// backExpandProgress belongs only to the secondary expansion tree.
//
// Cascading depth-one preview
//
// Depth-one Back leaves backEnterProgress at zero.
// The outer popup fraction therefore remains fully settled.
// The outer popup alpha therefore remains fully settled.
// The outer window dim therefore remains fully settled.
// backExpandProgress copies the platform sample directly.
// Effective expand fraction is expandFraction times one-minus-backExpandProgress.
// Effective primary scale retreats through the same inverse multiplier.
// Effective primary mask alpha retreats through the same inverse multiplier.
// Effective arrow rotation retreats through the same inverse multiplier.
// Effective secondary clip geometry retreats through the same inverse multiplier.
// A settled half-progress sample paints primary scale 0.975.
// A settled half-progress sample paints half of the primary depth mask.
// The secondary panel remains positioned at its frozen primary-row anchor.
// Preview must not remove the detached secondary Overlay entry.
// Preview must not enable primary-row actions under the depth mask.
//
// Cascading depth-one cancellation
//
// Cancellation returns backExpandProgress to zero.
// The reset uses the expansion Folme spring.
// Its damping ratio is 0.99.
// Its response is 0.45 seconds.
// The base expansion controller remains at its current value.
// Effective expansion returns to the fully expanded state.
// The secondary remains logically expanded.
// The secondary remains the next Back owner.
// The outer popup dim never changes during this reset.
// The reset does not invoke the leaf selection callback.
// The reset does not invoke popup dismissal callbacks.
//
// Cascading depth-one commit
//
// Commit clears the logical expanded parent.
// Commit does not dismiss the outer popup.
// The base expansion controller retargets toward zero.
// The collapse main spring uses damping ratio 0.95.
// The collapse main spring uses response 0.20 seconds.
// The displayed parent remains available while this spring settles.
// backExpandProgress stays applied until the base collapse is complete.
// Clearing it earlier would make the effective channels jump outward.
// After settle the detached secondary Overlay entry is removed.
// After settle backExpandProgress is reset to zero.
// The primary plane then becomes the active depth-zero Back owner.
//
// Cascading depth-zero behavior
//
// Depth-zero predictive Back drives backEnterProgress.
// It uses the same fraction, alpha, reveal, pivot, and dim equations as ListPopup.
// Cancellation uses ListPopupDefaults.ResetAnimationSpec.
// Commit dismisses the entire cascading popup.
// A still-settling hidden secondary does not regain Back ownership.
// Its separate backExpandProgress may remain one until its own cleanup finishes.
//
// Button Back and outside taps
//
// Predictive observers reject button events.
// Overlay button Back is consumed by the hosted popup history entry.
// Window button Back is guarded by the live cascading controller depth.
// At depth one button Back collapses secondary and vetoes route removal.
// At depth zero button Back permits removal of the popup route.
// An outside tap mirrors the same depth rule.
// At depth one an outside tap collapses only the secondary.
// At depth zero an outside tap dismisses the popup.
// A secondary header tap also collapses only the secondary.
// One event must never collapse depth one and dismiss depth zero together.
// Programmatic leaf selection may dismiss after depth state updates.
// Window selection waits one frame so PopScope observes the new depth.
// That scheduling must not delay the application selection callback.
//
// SearchBar boundary
//
// SearchBar owns Back only while expanded.
// SearchBar does not consume transition progress from NavigationBackHandler.
// SearchBar therefore has no predictive scale, translation, or alpha preview.
// Cancellation leaves SearchBar expanded without an invented reset animation.
// Completion calls onExpandedChange(false).
// Flutter must not reuse list-popup visual progress for SearchBar.
// The root pager must not also process the same consumed SearchBar Back event.
//
// Listener and lifecycle safety
//
// Each AnimatedBuilder attaches to one stable Listenable.
// A new MergingListenable must not be allocated on every popup frame.
// Popup progress is disposed only at its host or route ownership boundary.
// No descendant may attach after that disposal boundary.
// Window route progress outlives its page and modal barrier listeners.
// Overlay entry progress outlives the hosted popup view descendants.
// Cascading controller listeners are detached when the popup State is disposed.
// Detached secondary Overlay entries are removed synchronously at disposal.
// A canceled animation future is lifecycle control rather than an error.
// Every asynchronous collapse continuation checks mounted and current depth.
// Reopening a popup starts both Back tracks at zero.
// No Back sample may leak from one popup instance into the next.
//
// Regression obligations
//
// Test Overlay ordinary popup progress at a non-endpoint sample.
// Test Overlay ordinary popup dim at the same non-endpoint sample.
// Test Overlay cancellation restores settled scale and preserves content.
// Test Overlay commit removes only the hosted popup.
// Test Window ordinary popup progress at a non-endpoint sample.
// Test Window commit removes only the popup route.
// Test cascading depth-one progress changes primary scale but not outer dim.
// Test cascading cancellation restores the fully expanded secondary.
// Test the first cascading commit removes secondary but retains primary.
// Test the second cascading commit removes the primary popup.
// Test Window button Back consumes one cascading depth per press.
// Test Window leaf selection still closes a depth-one popup.
// Test an app replacement with an open popup does not use disposed progress.
// Run the complete library test suite after any listener-ownership change.
// Run the complete example test suite after any route-guard change.
// Run Android Release on an isolated emulator for platform gesture evidence.
// Preserve the user's existing emulator and never repurpose it for this proof.
