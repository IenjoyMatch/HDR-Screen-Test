// MIUIX current Dialog contract
// =============================
// This note records the behavior implemented by DialogContentLayout.kt.
// OverlayDialog.kt and WindowDialog.kt both delegate to that shared layout.
// The Flutter overlay and window adapters must therefore render one panel.
// Only ownership differs: OverlayDialog lives in MiuixPopupHost.
// WindowDialog owns a root Navigator route and its modal window semantics.
// Neither adapter is allowed to substitute Material AlertDialog geometry.
//
// Public configuration
// --------------------
// The title is nullable and an omitted title reserves no title placeable.
// The summary is nullable and an omitted summary reserves no summary gap.
// Title, summary, and background colors each accept explicit overrides.
// The default title color is the onBackground semantic role.
// The default summary color is the onSurfaceSecondary semantic role.
// The default panel fill is the background semantic role.
// enableWindowDim controls painting only; the barrier still consumes input.
// outsideMargin is a DpSize with a default width and height of 12dp.
// Its width is applied to both horizontal edges of the available window.
// Its height is applied below the compact or centered dialog panel.
// insideMargin defaults to 24dp on both logical dimensions.
// Its width becomes left and right padding around the content column.
// Its height becomes top and bottom padding inside the panel surface.
// defaultWindowInsetsPadding can disable the standard system inset chain.
// maxWidth defaults to 420dp and must remain caller-configurable.
// largeScreen is nullable so callers can force either presentation.
// cornerRadius is nullable so callers can override the resolved source shape.
//
// Presentation selection
// ----------------------
// Automatic large-screen mode requires width at least 840dp.
// Automatic large-screen mode also requires height at least 480dp.
// A wide but short landscape window therefore remains compact.
// largeScreen true bypasses both automatic threshold checks.
// largeScreen false keeps the bottom-attached mode on desktop-sized windows.
// A centered panel uses the source 32dp radius when no override is supplied.
// A compact panel derives its radius from the physical screen corner.
// That derived radius subtracts the 12dp outside horizontal margin.
// The derived value is clamped to the inclusive range 32dp through 48dp.
// Android example code reads the bottom-left RoundedCorner radius in pixels.
// Unsupported and flat displays follow the source minimum-radius fallback.
//
// Window and inset geometry
// -------------------------
// The root layout always fills the full popup or window host bounds.
// Status, caption, and display-cutout top insets use their maximum value.
// OverlayDialog reads those insets after its Scaffold host has consumed them.
// The root overlay therefore sees a zero top inset in the current sample.
// WindowDialog captures the safe top inset before opening its platform window.
// Flutter must preserve this overlay/window distinction when centering panels.
// Its root popup host already starts on the status-bar side of the safe view.
// The adapter therefore retains half the reported top padding as correction.
// This places the 420dpi centered surface on the same native physical center.
// Navigation and caption bottom insets are applied before outsideMargin.
// The compact bottom edge therefore remains above the gesture indicator.
// IME padding replaces the obstructed bottom region while editing text.
// A compact dialog aligns to BottomCenter after all window padding.
// A large dialog aligns to Center inside that same padded root box.
// The 12dp bottom margin shifts a no-inset centered panel upward by 6dp.
// Maximum centered height is exactly two thirds of the window height.
// Compact height is content-driven and has no artificial screen-height fill.
// Horizontal outside margins remain visible when the viewport is under 444dp.
// The 420dp maximum width prevents stretched dialog panels on tablets.
// Each authored dp edge is rounded independently at the target density.
// At 420dpi, the 12dp outside edge occupies 32 physical pixels.
// At 420dpi, the 24dp inside edge occupies 63 physical pixels.
//
// Content geometry
// ----------------
// The dialog column stretches its children across the resolved inner width.
// The title uses the MIUIX title4 size of 18sp and Medium font weight.
// Title text is centered and receives 12dp of bottom padding.
// Summary text uses the MIUIX body1 size of 16sp.
// Summary text is centered and receives 12dp of bottom padding.
// Translated strings may wrap to a different number of lines than English.
// Such wrapping changes intrinsic panel height without changing its tokens.
// Flutter reserves density-rounded source line boxes for translated summaries.
// This prevents fallback-font ascent differences from moving the whole panel.
// The user content follows title and summary without another implicit gap.
// Buttons and their spacing belong to the demo content, not Dialog itself.
// DialogSection uses two equal TextButtons separated by exactly 20dp.
// Cancel uses the ordinary TextButton colors.
// Confirm uses ButtonDefaults.textButtonColorsPrimary.
//
// Wide-dialog fixture
// -------------------
// DialogSection.kt exposes both overlay and window wide-dialog rows.
// Portrait uses the ordinary 420dp dialog maximum.
// Portrait supplies a visible title and rotation summary to Dialog itself.
// Portrait stacks three full-width TextButtons vertically.
// The vertical spacing between those actions is exactly 12dp.
// Allow Once is primary; Always Allow and Deny are ordinary actions.
// Landscape removes the outer Dialog title and summary parameters.
// Landscape increases the panel maximum width to exactly 560dp.
// Landscape content is one intrinsic-height row with two equal columns.
// The left column vertically and horizontally centers title and summary.
// The left title and summary use the same styles as ordinary Dialog chrome.
// Their internal gap is exactly 8dp rather than the outer 12dp title padding.
// A VerticalDivider separates the columns.
// The divider has 20dp horizontal padding on both of its sides.
// The right column vertically centers the three full-width actions.
// Rotating the source window causes this portrait/landscape body to recompose.
//
// Current example inventory
// -------------------------
// The localized section retains the five-row source order.
// Row one is Dialog (O), hosted by the root MiuixPopupHost.
// Row two is Dialog (W), hosted by the root Navigator window route.
// Row three is Wide Dialog (O), with responsive portrait/landscape content.
// Row four is Wide Dialog (W), with the same responsive content contract.
// Row five is Centered Dialog (O), forcing largeScreen to true.
// O and W remain in the localized labels because they identify host behavior.
// Press indication stays held until onDismissFinished completes the exit.
// Dismiss request begins the exit but must not clear that row immediately.
//
// Entrance and exit motion
// ------------------------
// Compact entrance is a full-window vertical translation from below.
// Its spring uses dampingRatio 0.88 and stiffness 450.
// Large entrance combines opacity with scale from 0.8 to 1.0.
// Its folme spring uses damping 0.9 and response 0.3 seconds.
// The equivalent unit-mass Flutter stiffness is approximately 438.6.
// The presentation used at animation start selects that animation spec.
// The source does not restart the entrance spec during a mid-flight resize.
// Panel exit lasts 260ms and uses DecelerateEasing with factor 1.5.
// Dim entrance lasts 300ms and runs independently from panel settling.
// Dim exit lasts 250ms and then remains clear for the final panel frames.
// Window dim color is the MIUIX windowDimming semantic color.
// Large predictive back scales the panel down by at most twenty percent.
// Compact predictive back translates by panel height plus bottom padding.
// System Back invokes the same dismiss request as an outside-panel tap.
// A second Back during hosted exit must not reach the application page.
//
// Verification obligations
// ------------------------
// Widget tests cover all five localized rows in their source order.
// Tests verify primary versus ordinary action colors through public adapters.
// Tests verify null-title landscape layout and the VerticalDivider structure.
// Tests verify the forced centered host uses fade/scale rather than slide.
// Tests verify largeScreen false can still force compact mode on a large view.
// Tests verify colors, margins, padding, maxWidth, and radius reach MiuixDialog.
// The 420dpi test keeps physical horizontal and bottom boundaries explicit.
// Runtime comparison must use the same emulator size, density, and system bars.
// Runtime packages used for comparison must be Release builds only.
// The emulator build may target x86_64, but the delivery APK targets arm64-v8a.
// Any remaining one-pixel edge fringe must be checked against rasterization.
// A successful API-coverage script alone is not visual parity evidence.

// Predictive Back source model
// ----------------------------
// DialogContentLayout owns backProgress independently from animationProgress.
// The two values must never be collapsed into one Navigator animation value.
// animationProgress describes declarative show and hide state.
// backProgress describes only the currently sampled Android gesture.
// Both values begin at zero before a dialog is presented.
// A settled visible dialog has animationProgress one and backProgress zero.
// A gesture update writes the platform progress directly to backProgress.
// The source applies no easing to live gesture progress.
// Finger motion must therefore remain one-to-one with the visible deformation.
// Gesture progress is clamped to the inclusive zero-to-one interval.
// A button-generated Back event is not a predictive gesture.
// Button Back must continue through ordinary PopScope or Navigator handling.
// Only the top live modal surface can claim a predictive gesture.
// A reversing modal retains ownership until physical removal.
// A hidden entry below the top entry must not receive gesture updates.
// A non-dialog popup must not inherit dialog deformation accidentally.
// The gesture controller is private because MIUIX exposes no public controller.
// Public Dialog parameters remain unchanged by the Flutter implementation.
// The private controller publishes the inverse value for dim composition.
// Its listenable value is exactly one minus backProgress.
// The panel reads direct progress while the dim layer reads the inverse.
// This keeps the two source channels mathematically coupled but structurally separate.
// Rebuilding the dim layer must not remeasure or reconstruct the panel contents.
// Rebuilding the panel transform must not restart the route entrance spring.
// A predictive gesture can start only after the visible route is current.
// A WindowDialog route below another route cannot claim the event.
// An OverlayDialog entry below another hosted modal cannot claim the event.
// Overlay ownership is evaluated against z-ordered live popup entries.
// Window ownership is evaluated against RawDialogRoute.isCurrent.
// The Android manifest must keep enableOnBackInvokedCallback enabled.
// Flutter's flutter/backgesture channel supplies progress and swipe-edge values.
// The dialog deformation is edge-independent in the current upstream source.
// Left-edge and right-edge gestures therefore use the same panel transform.
// Touch Y is not used by DialogContentLayout's current gesture model.
// A future upstream change must be audited before introducing touch-Y drift.
// Desktop escape and conventional Back retain the ordinary 260ms exit path.
// Predictive support must remain inert on Windows and unsupported Android versions.
// Registering a WidgetsBindingObserver is safe on those platforms because no event arrives.
// Every observer must unregister during State disposal.
// A canceled animation controller must also be disposed with its observer State.
// Controller lifetime must follow the actual route or hosted-entry subtree.
// Delaying disposal by an arbitrary timer is not a valid ownership model.
// A route controller is released from _MiuixDialogRoute.dispose.
// A hosted controller is released from _MiuixHostedPopupViewState.dispose.
// Those boundaries occur after descendant listenables detach.
// Releasing from Future.whenComplete is too early for Navigator maintenance frames.
// Releasing from onDismissFinished is too early for popup-host rebuild frames.
// Tests preserve the previously observed use-after-dispose failure as regression context.

// Compact predictive geometry
// ---------------------------
// Small-screen dialogs remain bottom-attached during predictive Back.
// Their gesture transform is a positive vertical translation.
// The maximum translation equals the measured panel height plus bottom travel.
// Measured height includes surface fill, padding, title, summary, and user content.
// Measured height excludes system padding outside the panel.
// Bottom travel includes navigation and caption obstruction.
// Bottom travel also includes the explicit outsideMargin height.
// At the reference setup this is 24dp plus 12dp.
// IME obstruction replaces the navigation obstruction while the keyboard is shown.
// Flutter resolves that obstruction as the larger current bottom inset.
// The panel translation at progress p is p times the maximum translation.
// At progress zero the panel remains at its settled screen origin.
// At progress one the complete panel has moved below the visible window.
// At progress one the outside bottom spacing has moved below the window as well.
// A 50-percent gesture must move exactly half of the computed travel.
// The source does not scale a compact panel during this gesture.
// The source does not fade the compact panel during this gesture.
// Panel opacity remains controlled by declarative show and hide motion.
// The transform wraps the resolved custom surfaceBuilder result.
// A caller-supplied surface must move as one unit with the standard panel.
// The transform must not sit inside the squircle clip.
// Placing it inside the clip would leave a stationary clipped outline.
// The transform must not modify the panel's layout bounds.
// Outside-tap hit testing continues to use the original host layout.
// The surface height is captured after the first completed layout.
// A ValueListenable update reads that cached measured height.
// It does not call intrinsic measurement during every gesture frame.
// A changed child schedules another post-frame measurement.
// A changed compact/large mode invalidates the cached height.
// The first interactive frame normally follows the initial measurement frame.
// Widget tests use a settled dialog before injecting gesture messages.
// Release runtime verification must likewise wait for the entrance spring to settle.
// Fractional density rounding occurs before physical screen comparison.
// The translation may be fractional in logical pixels and exact in physical pixels.
// Geometry assertions use closeTo rather than integer logical equality.
// The reference physical screen is 1080 by 2400 at 420dpi.
// Its gesture area is part of the computed bottom travel.
// Disabling defaultWindowInsetsPadding removes system bottom travel.
// It does not remove the caller's outsideMargin height.
// Setting outsideMargin bottom to zero removes only that explicit segment.
// Neither setting is allowed to invent a full-screen-height panel.
// Content-sized compact dialogs remain content-sized throughout the gesture.
// This distinction prevents the earlier Surface Actions full-height failure pattern.

// Large predictive geometry
// -------------------------
// Large-screen dialogs remain centered during predictive Back.
// Their gesture transform is a uniform scale around the panel center.
// The scale equation is one minus 0.2 times backProgress.
// At progress zero the scale is exactly one.
// At progress 0.5 the scale is exactly 0.9.
// At progress one the scale is exactly 0.8.
// The source applies no gesture translation to a large dialog.
// The source applies no additional panel fade to a large dialog.
// Declarative entrance opacity remains complete while the gesture is active.
// The centered scale is separate from the 0.8-to-1 entrance scale.
// A gesture begins only after the entrance route is current and complete.
// The two scale transforms therefore compose without changing their definitions.
// On commit the release scale remains active during ordinary dismissal.
// On cancel the scale returns to one over the reset tween.
// Maximum panel height remains two-thirds of the host height.
// Gesture scale must not change that layout constraint.
// Maximum panel width remains the caller's maxWidth value.
// Gesture scale must not trigger another responsive wide-dialog layout.
// Landscape wide content stays in two columns while scaled.
// Portrait action content stays stacked while scaled.
// Window resize selection is still independent from gesture deformation.
// A forced largeScreen true always uses this scale branch.
// A forced largeScreen false always uses the compact translation branch.
// Automatic mode still requires both the 840dp and 480dp thresholds.
// The transform key is shared by tests but only one branch exists per dialog.
// Tests inspect matrix scale for large mode and matrix translation for compact mode.

// Dim-layer behavior
// ------------------
// Gesture dimming multiplies the settled dim animation by one minus progress.
// It does not replace the independent 300ms enter dim animation.
// It does not replace the independent 250ms exit dim animation.
// At settled progress zero the gesture multiplier is one.
// At progress 0.5 the gesture multiplier is 0.5.
// At progress one the gesture multiplier is zero.
// When enableWindowDim is false the transparent barrier still consumes taps.
// Gesture progress must not make that transparent barrier dismiss unexpectedly.
// OverlayDialog applies the multiplier outside its hosted FadeTransition.
// WindowDialog applies the multiplier inside its custom modal-barrier color.
// Both paths produce the same final alpha equation.
// The source semantic windowDimming color remains the base color.
// Flutter's Material default scrim must never be substituted.
// Barrier semantics remain dismissible only when barrierDismissible is true.
// Gesture updates must not create an extra semantics node.
// The test key belongs to the opacity multiplier, not the colored dim surface.
// Runtime frame inspection must compare effective raster alpha, not widget opacity alone.
// Cancellation restores the multiplier to one.
// Commitment leaves the release multiplier in place during the hide animation.
// Declarative exit then drives the remaining dim layer toward zero.
// The product of both values prevents an alpha jump at gesture release.
// A second dialog opened later starts from a fresh zero progress controller.
// Progress from a dismissed dialog must never leak into the next modal entry.

// Cancellation behavior
// ---------------------
// A canceled predictive gesture does not invoke onDismissRequest.
// A canceled predictive gesture does not invoke onDismissFinished.
// It does not pop a WindowDialog route.
// It does not dismiss an OverlayDialog popup entry.
// It does not allow the application page behind the dialog to pop.
// Reset duration is exactly 150ms.
// Compose tween uses its default FastOutSlowIn easing for this reset.
// Reset begins from the live sampled progress at cancellation time.
// It must not jump to a hard-coded start value.
// A second cancel at progress zero leaves the controller at rest.
// Starting another gesture stops any in-flight reset animation.
// The next gesture begins from the platform-provided new progress.
// Cancellation restores both panel deformation and dim multiplier.
// At the end of 150ms compact translation is zero.
// At the end of 150ms large scale is one.
// At the end of 150ms the gesture dim multiplier is one.
// The dialog remains fully interactive after reset.
// Existing action buttons remain connected to the same dismiss callback.
// Existing hold-down state remains true because the dialog never exited.

// Commitment behavior
// -------------------
// A committed predictive gesture requests dismissal exactly once.
// WindowDialog commits by popping its own current route.
// OverlayDialog commits through the popup host's top-entry dismissal path.
// Both paths call onDismissRequest before physical removal.
// Both paths call onDismissFinished after their exit animation completes.
// The release progress is intentionally not reset before dismissal.
// Resetting first would create a visible snap back to the settled panel.
// Compact release retains its partial downward translation.
// Large release retains its partial scale.
// Gesture dim retains its partial inverse alpha.
// The ordinary 260ms panel exit composes underneath that release pose.
// The ordinary 250ms dim exit composes underneath the gesture multiplier.
// A reversing OverlayDialog keeps Back ownership until it is removed.
// A queued second Back cannot pop the page underneath.
// A reversing WindowDialog remains the root Navigator's top route.
// Route completion cannot dispose gesture state before barrier listeners detach.
// Popup completion cannot dispose gesture state before host listeners detach.
// Lifecycle tests count request and finish callbacks separately.
// Each counter must equal one after a committed gesture.
// A cancel followed by a commit still produces only one dismissal lifecycle.

// Interaction with existing navigation
// ------------------------------------
// The example's page transitions have their own predictive-back observer.
// A dialog observer must not make the page transition animate simultaneously.
// OverlayDialog installs a LocalHistoryEntry on the owning page route.
// That entry makes PageRoute.willHandlePopInternally true.
// Flutter then reports the page route's popGestureEnabled as false.
// The example page observer therefore declines the same gesture.
// WindowDialog is a distinct current RawDialogRoute above the page route.
// The page route is not current and therefore declines the gesture.
// Only the dialog observer remains an owner in both cases.
// Ordinary popup menus keep their existing Back ownership behavior.
// Bottom sheets do not opt into dialogTransition and receive no dialog controller.
// A generic dimAlpha notifier cannot be mistaken for the private controller type.
// The popup host recognizes predictive dialog state only for dialogTransition entries.
// This avoids changing existing list-popup and tooltip rendering.
// Root horizontal paging remains disabled by the modal barrier during a dialog.
// Slider and color-picker gesture recognizers remain unrelated to system Back.
// System gesture insets affect placement but not horizontal pager arbitration.

// Executable and runtime evidence
// -------------------------------
// The compact widget regression injects flutter/backgesture method messages.
// It opens a real OverlayDialog inside MiuixScaffold.
// It waits for the complete entrance motion before starting the gesture.
// It captures the real rendered panel height from miuix-dialog-surface.
// At progress 0.5 it checks half of height plus 24dp plus 12dp.
// It checks the external dim multiplier is exactly 0.5.
// It cancels and waits the exact 150ms reset duration.
// It checks translation returns to zero and content remains mounted.
// It starts a second gesture at progress 0.65 and commits it.
// It waits beyond the 260ms exit duration.
// It checks content removal and one request/finish callback pair.
// The large widget regression opens a real WindowDialog route.
// It uses a 900dp by 700dp view to satisfy both large thresholds.
// At progress 0.5 it checks a matrix scale of exactly 0.9.
// It commits and checks route removal after the source exit duration.
// It also checks one request/finish callback pair.
// The pre-existing custom-surface routing regression must continue to pass.
// The pre-existing double-Back overlay ownership regression must continue to pass.
// Golden tests must remain unchanged at settled progress zero.
// Root full tests must run after any listener-lifetime change.
// Example full tests must run after any host ownership change.
// Static analysis must remain clean in both package and example.
// Android Release runtime must use a gesture-navigation emulator.
// Runtime evidence should include a screen recording, not only endpoint screenshots.
// Extracted frames should show continuous deformation before either cancel or commit.
// Native and Flutter recordings must use the same start edge and approximate duration.
// UIAutomator endpoint trees cannot prove intermediate gesture motion alone.
// Logcat must be checked for Flutter errors, fatal exceptions, and ANRs.
// Delivery APK metadata must remain arm64-v8a and non-debuggable.
// The build number must remain monotonic for in-place installation.
// Evidence notes must identify source commit and exact source files.
// This dialog closure is one component cycle, not proof of whole-package parity.
