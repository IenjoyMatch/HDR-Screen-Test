// MIUIX current BottomSheet motion and predictive-Back contract.
//
// Authority
//
// The authoritative shared implementation is BottomSheetContentLayout.kt.
// OverlayBottomSheet.kt supplies the in-page PopupHost adapter.
// WindowBottomSheet.kt supplies the separate window adapter.
// BottomSheetSection.kt supplies the current example content and state flow.
// The audited source commit is recorded in doc/parity.md.
// The Flutter implementation must be compared with that exact checkout.
// API-name coverage alone does not establish this contract.
// Static settled screenshots alone do not establish this motion contract.
// A successful build alone does not establish system Back behavior.
//
// Host equivalence
//
// Overlay and Window variants share BottomSheetContentLayout upstream.
// They therefore share panel geometry.
// They share ordinary visibility motion.
// They share predictive-Back motion.
// They share dim-alpha behavior.
// They share allowDismiss behavior.
// They share nested-scroll behavior.
// They share request and completion lifecycle ordering.
// Their ownership mechanisms remain different.
// Overlay lives inside the nearest or root Miuix PopupHost.
// Window lives on a root Navigator route in Flutter.
// The host distinction must not change visible panel motion.
// The host distinction must not change the dim curve.
// The host distinction must not change the predictive transform.
// The host distinction must not change the localized example layout.
//
// Public behavior state
//
// MiuixBottomSheetController mirrors live source recomposition.
// allowDismiss may change while a sheet remains open.
// enableNestedScroll may change while a sheet remains open.
// The example retains one controller for each host variant.
// Overlay and Window behavior values are therefore independent.
// Closing and reopening one variant retains its own behavior values.
// The shared preference value inside the example remains shared separately.
// A caller-owned controller is never disposed by the component.
// A component-owned controller is disposed after descendants detach.
// A title action can dismiss regardless of allowDismiss.
// An outside gesture can dismiss only when allowDismiss is true.
// A system Back commit can dismiss only when allowDismiss is true.
// A downward drag can dismiss only when allowDismiss is true.
//
// Resting geometry
//
// The sheet is aligned to BottomCenter.
// The default maximum width is 640dp.
// The default outside margin is zero in both dimensions.
// The default inside margin is 24dp horizontally and zero vertically.
// The sheet extends to the bottom window edge.
// The sheet maximum height stops below the safe top inset.
// Only the two top corners receive the source 28dp radius.
// The lower corners remain attached to the window edge.
// The source default background is opaque.
// Global glass settings must not implicitly change that default.
// Explicit glass remains a Flutter compatibility extension.
// The drag handle owns a 24dp-high layout area.
// The painted drag handle is exactly 45dp wide.
// The painted drag handle is exactly 4dp tall.
// The drag handle uses onSurfaceVariantSummary at twenty-percent alpha.
// The title row adds 6dp above its measured content.
// The title row adds 12dp below its measured content.
// The title uses the 18sp Medium title4 token.
// Start and end actions do not displace the centered title.
// Chinese localization must retain the authored source line box.
//
// Current example structure
//
// The section title remains BottomSheet, localized in Flutter.
// The outer card contains exactly two rows.
// Row one opens BottomSheet (O).
// Row two opens BottomSheet (W).
// Both rows retain hold-down feedback until dismissal finishes.
// Both sheets use the same content order.
// The first inner section is Behavior Settings.
// The first behavior row is Allow Dismiss.
// The second behavior row is Enable NestedScroll.
// The TextField follows the behavior card.
// No Slider exists in the current authoritative example.
// The final card contains one host-specific DropdownPreference.
// The final card then contains SwitchPref.
// The content ends with navigation-bar plus caption-bar bottom spacing.
// The start action is the Close icon.
// The end action is the Ok icon.
// Both title actions use the local dismissal owner for Window.
// Overlay title actions use the same externally requested dismissal path.
//
// Ordinary visibility state
//
// Source animationProgress starts at zero.
// Showing first marks internalVisible true.
// Showing resets dragOffsetY to zero.
// Showing animates animationProgress from zero to one.
// Hiding normally animates animationProgress from one to zero.
// A sheet already dragged off-screen skips that ordinary hide animation.
// internalVisible becomes false only after the hide path completes.
// onDismissFinished runs after internalVisible becomes false.
// The panel translation includes the ordinary visibility offset.
// The dim alpha includes the same ordinary visibility progress.
// The full-screen dim surface itself never translates.
// Translating the entire route is not source-equivalent.
// Translating the dim surface exposes undimmed background during entry.
// The Flutter Window route therefore returns its full-screen child unchanged.
// The Window host applies visibility to dim and panel independently.
// The Overlay host already owns separate dim and content animations.
//
// Ordinary Folme spring
//
// Showing uses folmeSpring(damping=.9,response=.38).
// Hiding uses folmeSpring(damping=.9,response=.38).
// Spring mass is one.
// Natural angular frequency is 2*pi divided by response.
// Stiffness is the square of that natural frequency.
// The exact stiffness is approximately 273.396243797489.
// The damping ratio is exactly .9.
// The closed-form response begins at zero.
// It approaches one with the source's small overshoot.
// The response at 50ms is approximately .2093814316.
// The response at 100ms is approximately .5226858350.
// The response at 150ms is approximately .7540351527.
// The response at 200ms is approximately .8890350427.
// The response at 300ms is approximately .9866858165.
// The first small overshoot is visible near 400ms.
// The sampled route window reaches the .0001 displacement threshold near 680ms.
// A cubic easeOut is not an acceptable substitute.
// A 180ms enter duration is not an acceptable substitute.
// A 150ms ordinary exit duration is not an acceptable substitute.
// Reverse motion uses the complement of the forward spring response.
// Merely time-reversing the forward Curve gives the wrong initial velocity.
// The dim channel clamps the tiny spring overshoot before Opacity paint.
// The panel channel retains the tiny geometric overshoot.
//
// Visibility transform formula
//
// Let h be the measured logical panel height.
// Let v be the ordinary visibility spring value.
// At rest v equals one.
// Before entry v equals zero.
// Ordinary panel translation is h times one-minus-v.
// The source falls back to window height before the panel is measured.
// Flutter normally measures the panel on its first hosted frame.
// The measurement key must wrap only the content-sized panel.
// It must not wrap the full-screen Align or Stack.
// A full-screen measurement would multiply progress by the wrong distance.
// The transform must be outside the sheet shape and all sheet content.
// The dim layer must remain a sibling of that transform.
// The transform must not alter the measured layout bounds.
// The transform must not alter the sheet's semantic content order.
//
// Predictive Back state
//
// Source predictive Back reuses dragOffsetY.
// It is independent of animationProgress.
// Flutter keeps an equivalent private progress object.
// The private object is not part of the public source API.
// Raw Back progress is clamped from zero through one.
// The object also remembers measured panel and viewport height.
// The object listens to live allowDismiss changes.
// It exposes a dim multiplier to the host.
// It exposes an effective translation fraction to the panel.
// Button-generated Back is not a predictive gesture.
// Ordinary button Back remains on PopScope and Navigator handling.
// Only the top live modal may claim a predictive gesture.
// A reversing modal continues to own Back until physical removal.
// A modal beneath another popup cannot claim the gesture.
// Unsupported platforms never receive these system callbacks.
//
// Predictive progress when dismissal is allowed
//
// Let p be the latest system Back progress.
// The sheet translation contribution is p times h.
// The dim multiplier is one minus p.
// At p=0 the panel remains at rest.
// At p=.5 the panel moves exactly half its measured height.
// At p=.5 the dim multiplier is exactly .5.
// At p=1 the panel is one complete panel height below rest.
// The ordinary visibility progress remains one during the gesture.
// The pointer-drag offset remains a separate channel in Flutter.
// The predictive transform surrounds the existing pointer-drag transform.
// Both channels therefore affect the same complete sheet surface.
// The gesture never moves the full-screen dim hit target.
// The gesture does not resize the sheet.
// The gesture does not reflow its scrollable content.
//
// Predictive progress when dismissal is forbidden
//
// NavigationBackHandler remains enabled upstream while the sheet is shown.
// A forbidden gesture is therefore still consumed by the sheet.
// It must not fall through to the page or Activity.
// The panel shows resistance rather than staying perfectly still.
// Its contribution is p times h times .1.
// At p=.5 it moves exactly five percent of h.
// The dim multiplier remains exactly one.
// The dim layer must not brighten at any forbidden progress.
// Committing a forbidden gesture does not request dismissal.
// Committing a forbidden gesture runs the same reset as cancellation.
// onDismissRequest remains untouched.
// onDismissFinished remains untouched.
// The panel remains mounted after reset.
// Live allowDismiss changes affect the current controller immediately.
//
// Cancellation
//
// Cancellation animates the gesture offset back to zero.
// Cancellation animates the dim multiplier back to one when needed.
// The source cancellation duration is exactly 150ms.
// The source uses tween(durationMillis=150).
// Compose tween defaults to FastOutSlowIn easing.
// Flutter uses Curves.fastOutSlowIn for that reset.
// The reset starts from the currently sampled progress.
// A cancellation at zero does not schedule redundant animation.
// A new gesture stops an unfinished reset.
// Cancellation never invokes onDismissRequest.
// Cancellation never invokes onDismissFinished.
// Cancellation never pops a Window route.
// Cancellation never removes an Overlay entry.
// Cancellation restores the exact settled panel location.
// Cancellation restores the exact settled dim value.
//
// Allowed commitment
//
// Completion does not jump straight to an ordinary route pop.
// Source animateDismissOffScreen continues dragOffsetY.
// Its target is the full window height.
// Its spring uses damping=.85 and response=.4.
// Its mass remains one.
// Its stiffness is (2*pi/.4)^2.
// It starts from the system gesture's final sampled offset.
// Predictive snap updates reset velocity before this continuation.
// Dim alpha follows one-minus-offset-divided-by-panel-height.
// The dim multiplier is clamped from zero through one.
// The source observes dragOffsetY while the continuation runs.
// It dismisses as soon as the offset crosses one panel height.
// It does not wait to reach the full window-height target.
// The continuation job is canceled at that crossing.
// onDismissRequest fires once at that crossing.
// A compact panel therefore completes before the target spring settles.
// Flutter computes viewport-height divided by panel-height as target progress.
// Flutter stops at raw progress one and then invokes the host dismissal path.
// The resulting visual crossing matches the source threshold.
//
// Overlay commitment ownership
//
// Overlay predictive state is stored on its hosted popup entry.
// The entry exposes its dim multiplier through dimAlpha.
// The host recognizes that state only for bottomSheetTransition entries.
// Ordinary popups cannot accidentally acquire sheet gesture behavior.
// The top-entry check runs at gesture start.
// The same top-entry check runs when commitment is delivered.
// Commitment calls the entry's onDismissRequest once.
// Commitment begins hosted entry removal.
// The already off-screen transformed panel remains visually absent.
// The already transparent predictive dim remains visually absent.
// Hosted state owns disposal of predictive progress.
// Disposal happens after descendants detach.
// A component-owned behavior controller is disposed at that same safe point.
// A caller-owned behavior controller remains alive.
//
// Window commitment ownership
//
// Window predictive state belongs to one route invocation.
// The observer claims Back only while that route is current.
// Commitment calls the guarded request callback.
// Commitment then pops that current route.
// PopScope may report the completed pop again.
// The guarded request callback prevents duplicate user notification.
// The panel and dim are already visually gone at the crossing.
// Route teardown may finish bookkeeping after that visible crossing.
// onDismissFinished runs after physical route removal.
// Predictive progress is disposed after route descendants detach.
// A component-owned behavior controller is disposed after progress detaches.
// A caller-owned behavior controller remains alive.
//
// Ordinary Back
//
// Keyboard Escape and Android button Back do not enter predictive progress.
// allowDismiss true lets the normal Back path request dismissal.
// allowDismiss false blocks the normal Back path.
// Window PopScope publishes the live value.
// Overlay PopupHost consults the live canDismiss callback.
// A title action sets the internal force-dismiss path for Window.
// A title action is never blocked by allowDismiss.
// The request callback remains at-most-once across all paths.
// The finish callback remains exactly once after removal.
//
// Pointer drag relationship
//
// Downward pointer motion follows the finger when allowed.
// Upward motion from rest is damped to one tenth.
// Pointer release may return to rest or dismiss.
// The source release spring uses damping=.85 and response=.4.
// The source velocity threshold is density-scaled.
// The source distance threshold is density-scaled.
// A forbidden downward drag must not dismiss.
// A settling pointer animation may be interrupted by a new gesture.
// Nested scroll first restores an already offset sheet on upward input.
// Nested downward transfer begins only at the child's leading edge.
// Predictive Back does not depend on enableNestedScroll.
// Predictive Back remains active when nested sheet dragging is disabled.
// The two channels must not dispose or overwrite each other's controller.
//
// Dim ownership
//
// The semantic dim color is windowDimming.
// The source multiplies its base alpha by ordinary animationProgress.
// It multiplies by predictive dimAlpha when dismissal is allowed.
// Forbidden predictive motion leaves dimAlpha at one.
// Window builds the dim as a stationary full-screen sibling.
// Overlay builds the dim in PopupHost below the aligned panel.
// The dim surface retains its opaque hit-test behavior.
// Transparent animation frames still block background activation.
// Outside taps consult live allowDismiss.
// The predictive opacity key belongs to the gesture multiplier.
// The hosted visibility opacity key belongs to the Folme channel.
// Tests must distinguish those two opacity widgets.
//
// Localization
//
// Only visible strings are translated.
// Translation does not change row order.
// Translation does not add or remove controls.
// Translation does not change the title-line physical height.
// Translation does not change button or icon target geometry.
// Translation does not rename source host markers O and W.
// Translation does not introduce a Slider absent upstream.
// Translation does not enable the optional glass extension.
//
// Deterministic regression obligations
//
// A compact Overlay test must open a real MiuixOverlayBottomSheet.
// It must measure the rendered sheet surface.
// It must send startBackGesture through flutter/backgesture.
// It must assert that the gesture is claimed.
// It must send a progress update of .5.
// It must assert translation equals half the measured height.
// It must assert predictive dim equals .5.
// It must cancel and advance exactly 150ms.
// It must assert translation returns to zero.
// It must assert the sheet remains mounted.
// It must begin a second gesture and commit it.
// It must assert request and finish each occur once.
// A Window test must begin with allowDismiss false.
// It must assert .5 progress moves only .05 of panel height.
// It must assert dim remains one.
// It must commit and assert the sheet remains mounted.
// It must assert neither callback fired.
// It must toggle allowDismiss true while still open.
// It must commit another gesture and assert removal.
// It must assert both lifecycle callbacks occur once.
//
// Visibility regression obligations
//
// Window entry must sample the source response at 100ms.
// Its panel translation must equal h times one-minus-response.
// Its stationary dim opacity must equal response.
// The dim must not descend from the panel Transform.
// Window exit must sample the complement response at 100ms.
// Its panel translation must equal h times response.
// Its dim opacity must equal one-minus-response.
// Overlay entry must sample the same response at 100ms.
// Its SlideTransition dy must equal one-minus-response.
// Its hosted dim opacity must equal response.
// Both hosts must settle to exact rest without a final snap.
// Existing static 420dpi geometry tests must remain unchanged.
// Existing route-safety tests must remain unchanged.
// Existing onDismissFinished tests must remain unchanged.
// Existing live-controller tests must remain unchanged.
//
// Android runtime obligations
//
// Runtime verification uses a Release build.
// It uses the same 1080x2400 420dpi emulator for both applications.
// The original package and Flutter package must be recorded separately.
// The same BottomSheet (O) row must be opened in each application.
// The same BottomSheet (W) row must also be checked when practical.
// Settled UI trees must retain the already audited exact geometry.
// A long edge swipe must expose a capture during the gesture.
// The panel top edge must move down continuously.
// Background dim must reduce continuously.
// The full-screen dim must never translate with the panel.
// A committed gesture must remove only the sheet.
// The Home page must remain after commitment.
// A blocked gesture must leave the sheet visible.
// Command-line swipe velocity limitations must be documented honestly.
// Widget cancellation evidence must not be mislabeled as physical-device input.
// Logcat must be checked for Flutter and Android fatal errors.
// emulator-5554 must remain outside this audit.
//
// Maintenance boundary
//
// This contract closes BottomSheet motion only when all evidence is present.
// It does not prove ListPopup predictive Back.
// It does not prove CascadingListPopup predictive Back.
// It does not prove SearchBar Back progress.
// Those components own different transforms and require separate audits.
// Mapping gates remain narrow structural checks.
// Comment-ratio gates remain maintenance checks.
// Neither gate replaces source, test, and runtime comparison.
// Any upstream change to BottomSheetContentLayout must reopen this contract.
// Any change to route animation timing must rerun visibility samples.
// Any change to popup lifetime must rerun controller-disposal regressions.
// Any change to allowDismiss must rerun both predictive branches.
// Any change to localization must rerun physical geometry captures.
// The overall example parity goal remains active after this component closes.
