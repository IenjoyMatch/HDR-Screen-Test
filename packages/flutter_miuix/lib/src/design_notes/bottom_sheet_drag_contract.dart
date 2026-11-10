// MIUIX current BottomSheet ordinary-drag parity contract
//
// Authority
//
// The source of truth is layout/BottomSheetContentLayout.kt.
// OverlayBottomSheet and WindowBottomSheet both delegate to that layout.
// Ordinary pointer dragging is distinct from predictive Back progress.
// Ordinary visibility animation is also distinct from pointer settlement.
// All three channels may contribute to the final vertical translation.
// The Flutter port must keep those channels independently observable.
// The current source snapshot is recorded in doc/parity.md.
// A later upstream source change reopens every numeric rule below.
//
// Coordinate channel
//
// The resting ordinary drag offset is exactly zero logical pixels.
// Positive offset moves the complete sheet downward.
// Negative offset represents damped upward overscroll.
// The offset is not normalized by viewport or sheet height.
// Predictive progress remains normalized and multiplies sheet height.
// Visibility progress remains normalized and uses its own spring response.
// The final transform sums all three resulting pixel distances.
// Dim alpha reads the ordinary drag offset independently.
// A transform change must not relayout the sheet contents.
// A completed return spring writes an exact final zero.
// That exact write avoids retained subpixel hit-test displacement.
//
// Direct handle ownership
//
// The handle owns a 24dp-high interaction area.
// Its resting painted width is 45dp.
// Its resting painted height is 4dp.
// Its resting tint uses onSurfaceVariantSummary at alpha .20.
// Press and drag expand the painted width to 55dp.
// Press and drag scale the painted height by 1.15.
// Press and drag use alpha .35 for the handle tint.
// The transition into the pressed pose lasts 100ms.
// The transition back to rest lasts 150ms.
// Both handle transitions are linear in the current source.
// Pointer down starts the pressed pose without waiting for drag acceptance.
// Pointer up and pointer cancellation both restore the resting pose.
// Vertical drag start cancels any in-flight settlement spring.
// Android touch acquisition removes the platform 8dp touch slop.
// Only the over-slop remainder of the first MOVE reaches the offset channel.
// Flutter DragStartBehavior.down retains that pending first movement.
// The port subtracts 8dp once rather than dropping the complete first MOVE.
// The handle works even when enableNestedScroll is false.
// The handle works when allowDismiss is false, but motion is resisted.
// The complete content surface is not an unconditional drag target.
// Buttons, sliders, pickers, and lists below the handle retain gestures.
//
// Offset calculation
//
// Every update begins with newOffset equal to current plus pointer delta.
// A newOffset below zero enters the upward-overscroll branch.
// The upward-overscroll branch applies one tenth of the pointer delta.
// The upward-overscroll result is capped at zero from above.
// It remains free to become negative without an authored distance cap.
// A nonnegative offset with allowDismiss true follows the pointer exactly.
// A nonnegative offset with allowDismiss false resists downward movement.
// That resisted downward delta is multiplied by one tenth.
// An upward delta while resisted restores the offset at full strength.
// The resisted result is clamped to zero from below.
// Toggling allowDismiss is read live for every drag update.
// Changing enableNestedScroll never disables the direct handle calculation.
// No Material bottom-sheet drag coefficient substitutes for these branches.
// No easeOut transform substitutes for the source physical offset.
//
// Upward background continuity
//
// A negative offset lifts the shaped surface above the window bottom.
// The source draws a background continuation below that lifted surface.
// Its height is negative dragOffset plus one dp.
// The extra one dp prevents a raster seam at fractional device scales.
// The continuation uses the same semantic background as the sheet.
// It remains behind the shaped surface rather than inside its content column.
// It does not receive the two rounded top corners.
// It remains constrained to the same maximum sheet width.
// It disappears as soon as the offset returns to zero.
// It never appears for positive downward displacement.
// Optional Flutter glass does not invent a reflective strip in this region.
// Android physical-pixel captures must check the bottom seam during an up drag.
//
// Dim calculation
//
// Negative ordinary offset keeps the drag contribution to dim alpha at one.
// allowDismiss false keeps the drag contribution at one for every offset.
// Positive allowed offset uses one minus offset divided by sheet height.
// The resulting contribution is clamped between zero and one.
// Predictive dim contribution multiplies the ordinary drag contribution.
// Visibility dim contribution remains outside the sheet transform.
// The full-screen dim layer must never translate with the sheet.
// A zero or unmeasured sheet height falls back to alpha one.
// Crossing one sheet height therefore reaches zero ordinary drag dim.
// The surface removal and zero dim must occur on the same crossing frame.
//
// Settlement decision
//
// Settlement reads the pointer primary velocity in logical pixels per second.
// Positive primary velocity means a downward release.
// Negative primary velocity means an upward release.
// The source distance threshold is strictly greater than 150dp.
// The source downward velocity threshold is strictly greater than 800dp/s.
// A fast downward release may dismiss below the distance threshold.
// A slow release may dismiss after crossing the distance threshold.
// A release at exactly 150dp does not satisfy the distance branch.
// A release at exactly 800dp/s does not satisfy the velocity branch.
// Distance dismissal also requires velocity greater than negative 800dp/s.
// A stronger upward release therefore cancels beyond 150dp.
// allowDismiss false makes every settlement return to rest.
// The decision is evaluated once at release, not on every spring frame.
//
// Settlement spring
//
// Return and dismissal use the same Folme spring definition.
// Its damping ratio is .85.
// Its response is .4 seconds.
// Compose and Flutter both use unit mass for this conversion.
// Stiffness is the square of two pi divided by .4.
// Damping is two times .85 times the square root of stiffness.
// The release velocity becomes the spring initial velocity.
// A resisted positive release forces the return initial velocity to zero.
// That exception prevents a forbidden downward fling from adding travel.
// Dismissal targets the complete viewport height.
// Return targets exact zero.
// A new drag invalidates completion from the preceding spring.
// An interrupted return must never snap over the new pointer offset.
//
// Dismissal crossing
//
// The dismissal spring does not wait to reach the viewport target.
// It watches the measured sheet height on every animation tick.
// The host dismisses at the first offset greater than or equal to that height.
// The spring stops on that crossing frame.
// A sheet already beyond its height at release dismisses immediately.
// The host invokes onDismissRequest once at the crossing.
// The host physically removes the route or popup at the same crossing.
// onDismissFinished follows physical removal rather than an invisible delay.
// The ordinary 680ms visibility reverse must not replay after this crossing.
// Action buttons still use the ordinary visibility reverse.
// Outside taps still use the ordinary visibility reverse.
// Button-style system Back still uses the ordinary visibility reverse.
// Predictive commitment uses the same crossing-removal lifecycle as a drag.
//
// Overlay host lifecycle
//
// Overlay dismissal targets the live top hosted sheet.
// The sheet requests dismissal before its hosted entry is removed.
// Its completer resolves when the entry becomes nonvisible.
// Physical removal invokes onDismissFinished exactly once.
// Popup-host Back registration is resynchronized after removal.
// No reverse entry remains to absorb a later Back press.
// The page beneath the popup host remains mounted.
// Normal popup dismissal continues to animate and is unaffected.
//
// Window host lifecycle
//
// Window dismissal resolves the active RawDialogRoute.
// A settled-offscreen sheet removes that route directly.
// Direct route removal bypasses the invisible 680ms reverse transition.
// The show future still completes through its existing whenComplete block.
// The request callback remains guarded against duplicate delivery.
// The finished callback remains guarded by route completion ownership.
// The root Navigator page beneath the route must remain current.
// A controller action still calls Navigator.pop and preserves normal exit.
//
// Nested-scroll boundary
//
// enableNestedScroll controls only the content-scroll bridge.
// It never changes handle interaction.
// Only depth-zero notifications from the wrapped child are considered.
// A child at its leading edge reports negative unconsumed overscroll.
// That exact unconsumed magnitude becomes positive sheet displacement.
// The pointer bridge removes the same one-time 8dp source touch slop.
// It prevents Flutter's child Scrollable from dropping the complete first MOVE.
// Downward nested displacement requires allowDismiss true.
// allowDismiss false returns zero nested consumption to the sheet.
// A displaced sheet receives upward pre-scroll before its child scrolls.
// The bridge consumes at most the remaining positive sheet offset.
// Any upward remainder continues into the child ScrollPosition.
// ScrollPosition correction must not cancel the active pointer drag.
// A content pointer owns a separate velocity tracker for settlement.
// Pointer cancellation settles with zero velocity.
// Pointer release settles with the measured vertical velocity.
// A ScrollEnd notification is a fallback for nonstandard pointer delivery.
// Ballistic overscroll without drag details must not start a sheet drag.
// Horizontal child gestures must not be converted into sheet displacement.
// Disabling nested scrolling during a gesture prevents further forwarding.
//
// Automated regression matrix
//
// A direct handle test begins with both live flags false.
// It verifies a second -100dp delta produces exactly -10dp sheet movement.
// It verifies the continuation background exists during negative offset.
// It verifies return-to-rest ends at the original global top coordinate.
// It verifies a second +100dp delta produces exactly +10dp resisted movement.
// It verifies resisted positive displacement leaves dim alpha at one.
// It verifies the handle returns to exactly 45dp by 4dp.
// It verifies the pressed target is 55dp with scale 1.15.
// It verifies whole-surface dragging is disabled when the bridge is disabled.
// It verifies the direct handle still dismisses in that configuration.
// A threshold test injects exact DragEndDetails values.
// It verifies 200dp plus negative 900dp/s returns to rest.
// It verifies 40dp plus positive 900dp/s dismisses.
// It verifies 220dp plus zero velocity dismisses.
// It verifies callbacks remain pending before the crossing frame.
// It verifies request and finish each increment exactly once after crossing.
// A nested test starts from a ClampingScrollPhysics list at offset zero.
// It verifies 100dp unconsumed movement becomes 100dp sheet movement.
// It verifies the list offset remains zero during that displacement.
// It reverses by 60dp and verifies the sheet restores by 60dp.
// It verifies the list offset still remains zero after that pre-scroll.
// It disables the bridge and verifies a 220dp list drag leaves the sheet still.
// It re-enables the bridge and verifies the same slow drag dismisses.
// Every regression ends with tester.takeException returning null.
// These tests run through the top-level miuix_flutter_test.dart entrypoint.
// Running a part file directly is not valid Dart test evidence.
//
// Runtime obligations
//
// Android verification uses a Release APK only.
// The audit device is emulator-5558 when it is explicitly started for parity.
// emulator-5554 remains excluded from every command.
// The audit records model, resolution, density, ABI, and package version.
// The original and Flutter packages are opened from clean settled states.
// Direct handle downward motion is captured before release.
// Direct handle upward motion is captured before release.
// The bottom continuation seam is inspected at native resolution.
// A slow over-threshold release is checked for complete removal.
// A fast under-distance release is checked where input tooling permits it.
// A strong upward cancellation is not claimed from a one-segment adb swipe.
// Widget evidence covers exact velocity branches unavailable to adb input.
// Overlay and Window hosts are checked separately when practical.
// Logcat is filtered for Flutter, AndroidRuntime, fatal, and exception records.
// A zero fatal count is required before recording runtime evidence.
// Runtime screenshots do not replace automated lifecycle assertions.
// Automated tests do not replace native-source and physical comparison.
//
// Maintenance boundary
//
// This contract covers ordinary BottomSheet pointer motion and settlement.
// It does not close every BottomSheet visual or accessibility question.
// It does not prove ListPopup or CascadingListPopup gesture behavior.
// It does not prove SearchBar predictive Back behavior.
// Structural mapping counts are not behavioral parity evidence.
// Comment-ratio success is not behavioral parity evidence.
// Static analysis success is not runtime parity evidence.
// A Release build is not runtime parity evidence until installed and exercised.
// Any threshold change requires all three focused drag tests again.
// Any host change requires callback and Back-ownership tests again.
// Any transform change requires settled golden baselines again.
// Any ScrollPosition change requires the reverse-direction nested test again.
// Any handle change requires physical-size and pressed-state assertions again.
// The overall localized example parity goal remains active after this cycle.
