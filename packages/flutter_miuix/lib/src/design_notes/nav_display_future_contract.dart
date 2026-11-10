// NavDisplay implementation and remaining acceptance contract.
//
// Status and purpose:
// - The public display is implemented in widgets/parts/nav_display.dart.
// - Checked items below are runtime ownership rules, not API-name evidence.
// - Widget tests cover the deterministic paths available to Flutter tests.
// - Unchecked device-specific items remain acceptance work, not completion.
// - Navigator routes remain compatible beside the new layered display.
//
// NavEntry model:
// - Each entry must retain one application-owned MiuixNavKey.
// - Entry identity must remain stable while its relative depth changes.
// - Entry identity must not be derived only from the current list index.
// - Duplicate content keys are rejected visibly; callers provide unique keys.
// - An entry must distinguish active, incoming, outgoing, and covered roles.
// - Role changes must be derived from continuous depth at one frame boundary.
// - Entry content must remain alive while visible behind a moving top page.
// - Covered content must retain scroll, focus, text, and animation state.
// - Entry disposal must wait until it is no longer displayed or transitioning.
// - A cancelled pop must restore the same entry instance to its settled role.
// - A committed pop must dispose only the removed outgoing entry.
// - Replacing the top key must reconcile identity without corrupting its child.
// - Clearing above root must not rebuild the surviving root unnecessarily.
// - Application content builders must receive the exact key for that entry.
// - Builder failures must remain attributable to the responsible destination.
// - Entry state restoration must not depend on an ephemeral widget index.
//
// Display layer ordering:
// - The retained page paints below the moving top page.
// - The fullscreen dim paints above retained content and below the top page.
// - The dim must not translate with the retained quarter-width parallax layer.
// - A backdrop color paints behind all retained and moving entry content.
// - Backdrop omission lets the owning scaffold resolve its normal background.
// - Moving-page clipping applies after its content and before its transform.
// - Input blockers follow display effects rather than visual opacity alone.
// - A transparent blocker must still cover the complete transition viewport.
// - The blocker must not remain in the tree at settled integer depths.
// - Accessibility traversal must expose only interactable settled content.
// - Covered pages must not receive pointer input through transparent regions.
// - Covered pages must not steal focus during autonomous route transitions.
// - The moving page must preserve live blur, shaders, and ticking descendants.
// - Snapshotting must remain off unless live-material equivalence is proven.
// - Overlay and Window surfaces must retain their existing z-order contracts.
// - System gesture regions must not reveal an unpainted bright edge strip.

// Continuous depth:
// - The top settled entry has relative depth zero.
// - A new incoming entry moves continuously from negative depth toward zero.
// - An outgoing top entry moves continuously away from zero during pop.
// - The retained covered entry advances continuously toward zero during pop.
// - Exact relative-depth sign conventions must match the authoritative source.
// - Translation, alpha, dim, clip, and input derive from the same depth sample.
// - No layer may independently read wall-clock time for the same transition.
// - A reversal starts from the currently rendered depth without a position jump.
// - A reversal must also preserve first derivative where the model supports it.
// - Non-finite depth input must never enter Transform, Opacity, or clipping.
// - Overshoot handling follows the active settle recipe explicitly.
// - Clamp-enabled critical springs must not paint past their settled endpoint.
// - Clamp-disabled underdamped springs may overshoot within safe paint bounds.
// - Programmatic and interactive paths must converge to identical settled depth.
// - Reduced motion must settle immediately without an intermediate stale frame.
// - Frame scheduling must stop once all entries reach an exact settled state.

// Gesture admission:
// - Back swipe begins only from the configured logical or physical edge.
// - Edge interpretation must be explicit for LTR and RTL layouts.
// - A stack with only the root rejects the back gesture before arena capture.
// - A non-dismissible destination rejects gesture admission before movement.
// - Horizontal child controls keep priority when the pointer starts on them.
// - Sliders, ranges, tabs, carousels, timelines, and panes require direct tests.
// - Vertical scrolling must remain available during an unclaimed horizontal drag.
// - Pointer kind differences require touch, stylus, and mouse consideration.
// - Mouse back buttons remain separate from edge-drag pointer gestures.
// - Trackpad navigation must not be inferred from touch-drag behavior.
// - A second pointer must not reset or steal an active transition silently.
// - Gesture cancellation restores the last stable stack and entry identities.
// - Window resize during a drag must normalize displacement against new bounds.
// - Zero-width and non-finite viewport dimensions reject gesture progression.
// - System predictive-back progress must share the same continuous-depth owner.
// - Legacy Android back remains functional when predictive back is unavailable.

// Gesture progress and velocity:
// - Pointer displacement converts through logical direction exactly once.
// - Progress remains finite and bounded for display-effect calculations.
// - Raw overscroll may be retained separately when the motion model needs it.
// - Release velocity uses the same coordinate convention as displacement.
// - Commit decisions combine position and velocity using source-derived rules.
// - Thresholds not published by Xiaomi must be labeled project calibrations.
// - A fast opposing fling cancels even after crossing a positional threshold.
// - A fast committing fling may commit before a positional threshold.
// - Zero velocity uses only the documented positional decision boundary.
// - Velocity estimation must survive sparse and coalesced pointer samples.
// - Progress callbacks must be monotonic only while direction remains unchanged.
// - Reversing the finger may reverse progress without recreating entry content.
// - Haptic feedback must trigger on meaningful state transitions, not frames.
// - Cancel and commit haptics must have explicit semantic roles and tests.
// - Reduced motion may remove settle animation but not commit decision logic.
// - Accessibility actions need equivalent commit/cancel behavior without drag.

// Settle state machine:
// - Idle, dragging, committing, and cancelling are distinct observable phases.
// - Only one settle operation owns the display clock at a time.
// - Starting a new gesture during settle follows an explicit interruption rule.
// - Interruption must sample the rendered position before replacing simulation.
// - Commit uses MiuixNavMotion.commit and cancel uses its cancel recipe.
// - Programmatic changes use MiuixNavMotion.programmatic.
// - Spring mass, damping ratio, stiffness, and clamp remain inspectable.
// - Tween duration and curve remain inspectable and deterministic in tests.
// - A zero-duration tween reaches its final state in the current frame safely.
// - A non-finite spring result must terminate at the intended safe endpoint.
// - Removing a route during cancel cannot resurrect already disposed content.
// - Replacing the stack during commit requires deterministic reconciliation.
// - A completed commit mutates the authoritative back stack exactly once.
// - A completed cancel performs no logical stack mutation.
// - Completion callbacks run after display state reaches the settled endpoint.
// - Disposing the display cancels simulations without late callbacks.

// Reconciliation:
// - External direct stack mutations may arrive while the display is idle.
// - External direct stack mutations may also arrive during an active transition.
// - The reconciler compares stable entry identity, not only destination equality.
// - Appends become programmatic pushes when no interactive operation owns state.
// - Tail removal becomes a programmatic pop when it matches the visible stack.
// - Multiple tail removals require an explicit batch animation policy.
// - Middle insertion cannot be misclassified as a simple push.
// - Middle deletion cannot leave a covered orphan entry in the render tree.
// - Whole-stack replacement must preserve any safely matching prefix identities.
// - Duplicate keys require occurrence-aware matching or explicit entry tokens.
// - An empty external stack needs a documented display fallback.
// - Root insertion into an empty stack must become visible deterministically.
// - Mutation notifications may be coalesced only within one frame transaction.
// - A later mutation generation invalidates scheduled work from an older one.
// - Reconciliation errors must fail visibly rather than silently desynchronize.
// - The logical stack and displayed settled stack must agree after every settle.

// Persistence and restoration:
// - Application serializers own every destination payload schema.
// - The library never serializes arbitrary closures or Widget instances.
// - Encoded stack order matches logical root-to-top order.
// - Restoring an empty stack follows the same policy as a live empty stack.
// - Decode failure must identify the failing element and avoid partial mutation.
// - Schema migration remains an application responsibility.
// - Restored duplicate destinations require distinct application content keys.
// - Restoration before first layout must not animate from an empty viewport.
// - Restoration after process death must not replay obsolete gesture progress.
// - Only settled logical state is persisted by the basic stack helper.
// - Future transition-state persistence requires a separately versioned format.
// - Navigation restoration must compose with Flutter RestorationScope ownership.
// - Encoder output must remain detached from future mutable destination state.
// - Decoder output must be validated before publishing the restored stack.
// - Tests must cover nested payloads and deliberately malformed data.
// - Release builds must enforce the same validation as Debug builds.

// Predictive back integration:
// - Android start decides whether the display can own the back operation.
// - Android update maps platform progress into the same gesture progress model.
// - Android cancel uses the configured cancel settle recipe.
// - Android commit uses the configured commit recipe and one stack mutation.
// - Platform progress may arrive non-monotonically and requires safe handling.
// - Platform callbacks after route disposal must be ignored by generation.
// - A modal overlay above NavDisplay gets first opportunity to handle back.
// - A non-dismissible overlay must prevent navigation back from starting beneath.
// - Nested navigators must resolve the active back owner deterministically.
// - NavDisplay, dialogs, sheets, popups, and public Back handlers share one
//   composition-ordered registry; only the highest eligible owner may accept.
// - A disabled or non-dismissible surface is skipped instead of shadowing the
//   next eligible owner, and one gesture delivers exactly one terminal action.
// - System animation and in-app translation must not apply displacement twice.
// - Android edge direction must agree with the app's resolved text direction.
// - Fullscreen dialogs require an explicit predictive-back participation policy.
// - Gesture exclusion regions require device testing, not only widget tests.
// - API levels without predictive back keep equivalent button-back outcomes.
// - Platform-channel errors must fail closed without corrupting the stack.
// - Task-owned arm64 hardware or emulator is required for runtime acceptance.

// Visual and motion acceptance:
// - HyperOS 4 is the default target for any newly introduced display widget.
// - Source compatibility values remain available through explicit source paths.
// - Corner geometry uses the shared continuous/squircle shape infrastructure.
// - Corner radius must scale safely when the viewport is smaller than two radii.
// - Dim amount is clamped to a finite visible alpha before painting.
// - Backdrop and dim colors preserve semantic contrast in light and dark modes.
// - Glass content remains live during push, pop, cancel, and reversal.
// - Text and icon rasterization must not blur because of fractional transforms.
// - RTL screenshots must show mirrored geometry, not merely reversed stack order.
// - Reduced-motion screenshots must show the exact settled composition.
// - Foldable, tablet, desktop, and narrow phone viewports require layout samples.
// - Window resizing during autonomous motion must not expose uncovered pixels.
// - Frame pacing and first-moving-frame response require measured runtime traces.
// - A passing Golden proves only its captured size, theme, and deterministic frame.
// - Project-inferred radius and easing values must be labeled as inferred.
// - Official descriptions, visual observations, and rumors remain separated.

// Test matrix:
// - Unit tests cover every controller mutation and root-preservation boundary.
// - Unit tests cover every display-effect open interval and non-finite input.
// - Unit tests cover valid and invalid settle recipes in normal Release logic.
// - Widget tests cover push, pop, cancel, commit, reversal, and interruption.
// - Widget tests cover direct stack mutation during every settle phase.
// - Widget tests cover duplicate keys and stable retained state.
// - Widget tests cover LTR, RTL, reduced motion, and large text scaling.
// - Widget tests cover keyboard, semantics, and platform back dispatch.
// - Gesture tests cover child controls both inside and outside edge admission.
// - Lifecycle tests cover controller replacement and display disposal mid-frame.
// - Golden tests cover representative light, dark, and high-contrast surfaces.
// - Windows Release smoke verifies a responsive hidden launch and clean close.
// - Android static checks verify package, version, ABI, and signing boundary.
// - Android runtime tests use only a task-owned compatible target.
// - x86_64 execution cannot be reported as arm64 behavior or smoothness proof.
// - Full library and example suites remain mandatory before each Release handoff.

// Scope and release discipline:
// - NavDisplay is mapped because it now owns real layered rendering behavior.
// - Gesture types are mapped because they drive pointer and predictive paths.
// - Settle types are mapped because their phases are exposed to transitions.
// - NavChange is mapped because direct mutations are classified and tested.
// - Internal upstream runtime types remain intentionally unmapped.
// - API-name coverage never substitutes for behavioral or pixel parity.
// - Source compilation never substitutes for application runtime verification.
// - A signed APK never substitutes for device visual and motion evidence.
// - Every source, documentation, resource, or build change starts a Release cycle.
// - The cycle must use tool/build_release_cycle.ps1.
// - Android arm64, Windows x64, and both library archives must all succeed.
// - Stable aliases and numbered checkpoints must share the verified build number.
// - SHA-256, architecture, package, version, and signature checks are mandatory.
// - A failed platform or package step preserves the prior complete Release.
// - Pruning runs only after every required artifact and verification succeeds.
// - Delivery reports exact paths, hashes, signature boundary, and runtime boundary.
