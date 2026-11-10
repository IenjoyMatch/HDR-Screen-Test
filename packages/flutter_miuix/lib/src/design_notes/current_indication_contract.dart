// Current MIUIX indication parity contract
//
// Authority
//
// The behavioral authority is the current upstream MiuixIndication.kt file.
// The audited source revision is recorded in the repository parity document.
// This contract supersedes the older 1.0.9 linear-animation assumption.
// It applies to every control that consumes the theme-local indication.
// It also applies to IconButton, whose upstream clickable uses that local.
// NavigationRail retains a component-local implementation of the same rules.
// No Flutter Material ripple is part of the upstream visual result.
// No sink scale is implied merely because indication is enabled.
// No tilt transform is implied merely because indication is enabled.
// The overlay is rectangular before a component's existing shape clip.
// A component shape therefore determines the visible clipped outline.
//
// Public descriptor
//
// MiuixIndication is an immutable description of the overlay paint.
// Its optional color corresponds to the upstream indication color argument.
// A missing explicit color resolves the active semantic onBackground role.
// A null descriptor means that no indication layer is installed.
// Null must not disable the control's click callback or keyboard activation.
// Equality compares the effective descriptor field rather than object identity.
// Hashing follows the same field so descriptors remain safe as theme values.
// A custom color changes paint only and never changes the motion parameters.
// The default descriptor is suitable for source-compatible clickable controls.
// Compatibility extensions may still opt out by passing a null descriptor.
//
// Interaction state
//
// The source records pointer press, hover, keyboard focus, and hold-down.
// Each interaction arrives as a discrete state transition.
// Unknown interaction types do not alter the current indication state.
// Press begins when the clickable recognizer accepts pointer-down tracking.
// Press ends on release or cancellation.
// Hover begins when a mouse pointer enters the actual visual hit region.
// Hover ends when that pointer leaves the actual visual hit region.
// Focus begins when the control owns keyboard focus.
// Focus ends when that focus is transferred or cleared.
// Hold-down begins from the explicit component observer state.
// Hold-down ends when that explicit state becomes false.
// Disabled controls remove their clickable indication node altogether.
// A disabled control therefore exposes no residual animated overlay.
// In-flight pointer state is cleared when a control becomes disabled.
// In-flight hover state is cleared when a control becomes disabled.
// In-flight focus state is cleared when a control becomes disabled.
// A re-enabled control starts from a clean zero-alpha state.
//
// Target alpha
//
// Hover contributes 0.06 to the current target alpha.
// Keyboard focus contributes 0.08 to the current target alpha.
// Pointer press contributes 0.10 when hold-down is not active.
// Hold-down contributes 0.10 while it is active.
// Hold-down replaces the overlapping pointer-press channel.
// Press and hold-down must therefore never create a 0.20 pair by themselves.
// Hover may coexist with either press or hold-down.
// Focus may coexist with either press or hold-down.
// Hover and focus may coexist with one another.
// Hover plus focus resolves to a 0.14 target.
// Hover plus focus plus press resolves to a 0.24 target.
// Hover plus focus plus hold-down also resolves to a 0.24 target.
// Focus plus press resolves to a 0.18 target.
// Hover plus press resolves to a 0.16 target.
// The overlay remains absent while the resolved target is zero.
// Floating-point comparisons use the exact state-derived target.
// The target is recalculated after every recognized transition.
//
// Folme conversion
//
// Upstream expresses motion with damping ratio and response time.
// Flutter SpringDescription expresses mass, stiffness, and damping.
// The contract fixes spring mass to 1.
// Angular frequency is two times pi divided by response.
// Stiffness is angular frequency squared for unit mass.
// Damping is two times ratio times angular frequency for unit mass.
// This is the same conversion used by the repository folmeSpring helpers.
// It must not be substituted with a duration-based curve approximation.
// It must not be sampled from a Tween or AnimatedOpacity duration.
// An unbounded AnimationController preserves the physical spring simulation.
// The paint layer reads that controller directly through FadeTransition.
// Tight simulation tolerance avoids visible long-tail scheduling in tests.
// Tolerance does not change the source target or the selected spring pair.
//
// Press and hold enter spring
//
// A press-enter transition selects response 0.2 seconds.
// A press-enter transition selects damping ratio 1.0.
// A hold-enter transition selects response 0.2 seconds.
// A hold-enter transition selects damping ratio 1.0.
// This critically damped pair approaches the target without overshoot.
// It replaces the former 120ms linear positive transition.
// A fixed 120ms capture is therefore still an intermediate spring frame.
// Tests must not assert that the value already equals 0.10 at 120ms.
// Tests may assert that the value is positive and below its target then.
// Endpoint tests must pump until the spring settles.
// A new positive transition cancels the preceding positive transition.
// It also cancels a pending resting transition.
// The new simulation starts from the controller's current value.
// This prevents discontinuities when interaction channels overlap.
//
// Press and hold exit spring
//
// A press-exit transition selects response 0.35 seconds.
// A press-exit transition selects damping ratio 0.95.
// A hold-exit transition selects response 0.35 seconds.
// A hold-exit transition selects damping ratio 0.95.
// Release does not immediately cancel a still-running positive animation.
// Release first waits for that positive animation job to complete.
// The resting simulation then starts from the completed positive value.
// This job ordering is observable after a very quick click.
// It keeps quick taps visible instead of truncating feedback immediately.
// The exit target can be zero, hover, focus, or hover plus focus.
// Release while hovered must therefore settle to 0.06 rather than zero.
// Release while focused must therefore settle to 0.08 rather than zero.
// Release while hovered and focused must settle to 0.14.
// An asynchronous continuation captures the target for its own transition.
// Before starting it verifies that the current target still matches capture.
// Checking only for a zero target is incorrect for hovered release states.
// A revision token prevents stale continuations from starting later.
// Disposal prevents all pending continuations from touching the controller.
//
// Hover and focus enter spring
//
// A hover-enter transition selects response 0.6 seconds.
// A hover-enter transition selects damping ratio 1.0.
// A focus-enter transition selects response 0.6 seconds.
// A focus-enter transition selects damping ratio 1.0.
// This intentionally feels slower than pointer press feedback.
// It replaces any active positive animation from another enter transition.
// It begins from the current animated alpha rather than from zero.
// Adding focus while hovered moves continuously from 0.06 toward 0.14.
// Adding hover while focused moves continuously from 0.08 toward 0.14.
// Adding press later switches to the faster press-enter spring.
// Removing another channel later selects the transition that actually changed.
// The state priority follows the upstream collector's comparison order.
// Press state changes are considered before hold-down changes.
// Hold-down state changes are considered before hover changes.
// Hover state changes are considered before focus changes.
// Widget update paths emit one explicit change selector at a time.
//
// Hover and focus exit spring
//
// A hover-exit transition selects response 0.2 seconds.
// A hover-exit transition selects damping ratio 0.96.
// A focus-exit transition selects response 0.2 seconds.
// A focus-exit transition selects damping ratio 0.96.
// A transition whose target becomes zero uses the resting-job path.
// A transition whose target remains positive uses the positive-job path.
// Hover exit while focused approaches the remaining 0.08 channel.
// Focus exit while hovered approaches the remaining 0.06 channel.
// Hover exit during press approaches the remaining 0.10 press channel.
// Focus exit during hold-down approaches the remaining 0.10 hold channel.
// Pointer removal in a widget test must pump the scheduled exit simulation.
// A zero-time pump may be required to expose an async continuation to clock.
// This is deterministic scheduler behavior, not a production delay token.
//
// MiuixPressable integration
//
// MiuixPressable owns one indication controller per mounted pressable.
// Its sink and tilt controllers remain independent from indication motion.
// The indication controller is not included in the transform listenable.
// FadeTransition listens to indication changes without rebuilding geometry.
// The child is painted before the overlay.
// IgnorePointer prevents the overlay from intercepting gestures.
// The existing ShapeBorder clip applies equally to child and overlay.
// BorderRadius compatibility clipping applies equally to child and overlay.
// A missing clip preserves the upstream rectangular indication description.
// InteractionSource continues to observe only externally supported channels.
// Pointer state still drives sink or tilt feedback where a component requests it.
// showIndication false resolves the indication target to zero.
// indication null also resolves the indication target to zero.
// Enabling indication during an active interaction animates toward live target.
// Disabling indication clears its controller without affecting click semantics.
// Changing hold-down while mounted selects hold enter or hold exit explicitly.
// Initial hold-down is emitted after the first indication attachment frame.
// This mirrors the upstream observer attaching to its interaction source.
//
// MiuixSurface integration
//
// MiuixSurface forwards its indication descriptor to MiuixPressable.
// MiuixSurface forwards its optional interaction observer independently.
// Surface margin remains outside the gesture and indication target.
// Surface shape remains the only visible clipping authority.
// Surface background paint is below the indication overlay.
// Surface content color inheritance is unaffected by indication color.
// Disabling a surface removes tap interaction as before.
// A null indication does not remove an otherwise enabled surface tap.
// Buttons and floating action buttons inherit this corrected surface behavior.
// Preference rows inherit it through their existing surface or pressable path.
// Popup anchors inherit it while preserving their explicit hold-down state.
//
// Breadcrumb integration
//
// MiuixBreadcrumbBar accepts one optional shared interaction observer.
// Each clickable segment forwards the current indication descriptor.
// A null descriptor keeps segments clickable without painting an overlay.
// A custom descriptor color reaches the segment's FadeTransition child.
// The breadcrumb separator remains outside the preceding segment overlay.
// Segment hit geometry and text measurement are unchanged by this API.
// The active segment semantics remain the same as before indication support.
//
// IconButton integration
//
// Upstream IconButton creates one MutableInteractionSource per composition.
// Its clickable consumes the theme-local current MiuixIndication.
// Flutter IconButton therefore cannot keep its former AnimatedOpacity path.
// It owns an unbounded controller with the same four spring selections.
// It records pointer, hover, focus, and explicit hold-down state.
// Hold-down supersedes pointer press in its alpha target.
// The visible button remains a 40dp minimum placeable.
// Android interaction and semantics remain a separate 48dp minimum rectangle.
// The four-dp expansion must not change row or app-bar measurement.
// The custom render object continues to own pointer tap recognition.
// Its recognizer reports down, up, and cancel into the indication state.
// The desktop MouseRegion lives inside that custom render object.
// The desktop focus detector also lives inside that custom render object.
// Keeping them inside preserves the public key's precise semantic mapping.
// Focus semantics are disabled on the detector because the render object owns them.
// Within the painted 40dp region, child hit testing exposes mouse annotations.
// In the extra four-dp Android region, only the render recognizer participates.
// Hover therefore follows visual bounds rather than accessibility expansion.
// Enter and Space invoke the same current onPressed callback.
// Keyboard activation does not invent a second semantic node.
// Tooltip wrapping remains outside the exact target implementation.
// Disabled IconButton paint remains caller-controlled as in upstream.
// Disabled IconButton exposes neither tap semantics nor held indication.
// Fractional-density top-app-bar target corrections remain paint-independent.
//
// Visual regression expectations
//
// Pressed golden frames intentionally sample a spring in flight.
// Animation-midpoint golden frames intentionally sample a later spring frame.
// They must differ from a 120ms linear interpolation baseline.
// Open popup anchors retain exactly one 10% hold-down channel.
// Old baselines that stacked press and hold-down are invalid.
// Popup geometry must remain pixel-identical when those baselines are updated.
// Dialog geometry must remain pixel-identical when those baselines are updated.
// Sheet geometry must remain pixel-identical when those baselines are updated.
// Only trigger and clickable surface luminance should change from this repair.
// Representative isolated diffs must be inspected before accepting baselines.
// The full golden suite must pass again without the update flag afterward.
//
// Behavioral validation
//
// Unit tests expose all four SpringDescription parameter pairs.
// Unit tests sample press-enter before its endpoint.
// Unit tests confirm quick release waits for positive completion.
// Unit tests confirm release can settle to a nonzero hover target.
// Unit tests confirm hover settles to 0.06.
// Unit tests confirm focus plus hover settles to 0.14.
// Unit tests confirm press plus hover plus focus settles to 0.24.
// Unit tests confirm Enter activates a focused control.
// Unit tests confirm hold-down and pointer remain at 0.10 by themselves.
// Unit tests confirm disabled controls remain at zero alpha.
// Unit tests confirm IconButton still measures 40dp.
// Unit tests confirm IconButton semantics still measure 48dp.
// Unit tests confirm taps in the four-dp expansion still activate it.
// Unit tests confirm a custom breadcrumb indication color reaches paint.
// Unit tests confirm a null breadcrumb indication removes only its overlay.
// Full package behavior tests guard all unrelated component contracts.
// Full localized example tests guard source page structure and geometry.
// Static analysis must remain clean after every indication change.
// Android release compilation is required after the final validated change.
// The installed build number must remain newer than prior test artifacts.
