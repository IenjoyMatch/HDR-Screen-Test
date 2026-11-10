// Copyright 2026 flutter_miuix contributors.
//
// MIUIX 1.0.9 Overscroll source-parity contract.
//
// Authority
//
// Normative behavior comes from Overscroll.kt and OverscrollFactory.kt.
// Numerical spring behavior comes from SpringUtils.kt.
// Flutter BouncingScrollPhysics is not an implementation authority.
// Flutter ScrollSpringSimulation is not an implementation authority.
//
// Public modifier family
//
// overScrollVertical selects the vertical axis.
// overScrollHorizontal selects the horizontal axis.
// overScrollOutOfBound supplies their shared implementation.
// Modifier-based overscroll dispatches to a parent by default.
// Modifier-based overscroll defaults on only for Android and iOS.
// A disabled modifier returns the original content unchanged.
// An enabled modifier clips translated content to its bounds.
//
// Factory family
//
// MiuixOverscrollFactory is a Kotlin singleton object.
// Its equality implementation is strict identity.
// Its hash code is always one.
// It creates a fresh MiuixOverscrollEffect on request.
// MiuixTheme provides this factory as its local default.
// The factory effect independently supports both X and Y axes.
//
// State
//
// OverScrollState exposes isOverScrollActive.
// Mutation remains internal to the overscroll implementation.
// Active state uses an absolute displacement threshold of one pixel.
// Either active axis makes the factory effect active.
// Detaching resets displacement and active state.
// Flutter exposes MiuixOverScrollState as the observable counterpart.
// Applications may observe but cannot publicly mutate its active bit.
//
// Damping range
//
// The vertical raw-touch range is the full window container height.
// The horizontal raw-touch range is the full window container width.
// A nested popup does not substitute its smaller viewport dimension.
// Range values update when density or window information changes.
// Flutter ScrollBehavior captures the logical MediaQuery window size.
// A directly constructed physics object falls back to viewport size.
// The fallback exists only for isolated compatibility and tests.
//
// Damping math
//
// Raw touch accumulation is clamped to plus or minus one full range.
// Normalized input is absolute raw touch divided by the range.
// Normalized input is clamped from zero through one.
// Damped factor is x minus x squared plus x cubed divided by three.
// Pixel displacement is damped factor multiplied by the range.
// Maximum visual displacement is exactly one third of the range.
// The derivative used during continued drag is `(1 - x)^2`.
//
// Inverse damping math
//
// Spring frames restore visual displacement to raw touch accumulation.
// Visual displacement is first clamped to the one-third maximum.
// Zero visual displacement restores to zero raw distance.
// Base is range minus three times absolute pixel displacement.
// Restored distance is range minus range to two-thirds times cube root base.
// Cube-root sign is retained when base becomes negative at the maximum.
// Public test helpers cover round trips throughout the complete range.
//
// Drag lifecycle
//
// A zero delta changes nothing.
// New user input cancels the running spring on the active axis.
// Programmatic scroll input bypasses overscroll consumption.
// Opposite-direction input first reduces existing raw accumulation.
// A delta large enough to consume it resets that axis immediately.
// Remaining delta after reset continues to the underlying scrollable.
// Same-direction unconsumed input increases raw accumulation.
// Post-scroll unconsumed input is absorbed into translated displacement.
// Parent nested-scroll consumption is subtracted before local damping.
// The modifier may opt out of dispatching nested scroll to its parent.
//
// Pull-to-refresh coordination
//
// Non-idle vertical PullToRefresh bypasses vertical overscroll drag handling.
// Horizontal overscroll remains independent of PullToRefresh.
// A pre-fling bypass occurs when refresh is active and overscroll is inactive.
// An already active overscroll is still allowed to spring back.
// PullToRefresh and overscroll share the active state to avoid double motion.
//
// Fling attenuation
//
// A fling with no active displacement passes to parent or content.
// A fling farther outward starts a spring with the full available velocity.
// The outward velocity is fully absorbed on that active axis.
// A fling back toward center also starts the spring at full velocity.
// Center-directed velocity passed onward is divided by 2.13333.
// Post-fling unconsumed velocity is divided by 1.53333.
// Each axis applies the same attenuation independently.
//
// Spring constants
//
// Critical damping ratio is exactly 1.0.
// Standard natural period is exactly 0.4 seconds.
// High-velocity natural period is exactly 0.55 seconds.
// High velocity means absolute initial velocity greater than 5000.
// Angular frequency is two pi divided by the selected natural period.
// Stiffness over mass is angular frequency squared.
// Damping coefficient is twice ratio times angular frequency.
//
// Spring integration
//
// MIUIX uses explicit Euler integration, not an analytic spring solver.
// Frame delta is clamped to at least 0.001 seconds.
// Frame delta is clamped to at most 0.016 seconds.
// Velocity first receives decay and the spring acceleration term.
// Position then advances by clamped delta multiplied by new velocity.
// Every frame recomputes raw touch through the exact inverse function.
// The first animation frame establishes its timestamp without integration.
// Flutter's simulation preserves one integration for each new time sample.
// Repeated x, dx, and isDone calls at one timestamp do not double-step.
//
// Source equilibrium
//
// Motion starting below target completes after crossing above target.
// Motion starting above target completes after crossing below target.
// Motion also completes when absolute target distance becomes less than one.
// Completion snaps position exactly to target.
// Completion resets velocity exactly to zero.
// A completed near-zero spring resets raw accumulation and active state.
//
// Placement
//
// Vertical displacement translates the complete measured child on Y.
// Horizontal displacement translates the complete measured child on X.
// Factory effects apply X and Y translation simultaneously.
// Translation occurs in a clipped compositing layer.
// Child measurement and reported layout size remain unchanged.
//
// Flutter behavior surface
//
// MiuixSpringScrollPhysics carries the source window range.
// applyBoundaryConditions permits displacement beyond scroll extents.
// In-range ballistic motion delegates to ClampingScrollPhysics.
// Out-of-range ballistic motion uses the source Euler simulation.
// Implicit scrolling stays disabled, matching manual boundary ownership.
// MiuixScrollBehavior suppresses Material glow and stretch indicators.
// showOverscrollIndicator false selects clamping compatibility behavior.
// MiuixOverscrollEffect installs the behavior for one subtree.
// The wrapper reports its one-pixel active state through an optional object.
// showScrollbars controls only the independent scrollbar wrapper.
//
// Regression evidence
//
// Tests cover derivative values at zero, half, and one.
// Tests cover one-third maximum displacement after a complete range drag.
// Tests cover damping and inverse-damping round trips.
// Tests prove a 100px popup still uses a 1000px window range.
// Tests cover the exact standard-period first Euler frame.
// Tests cover window-size propagation through MiuixScrollBehavior.
// Tests cover the clamping result of the compatibility toggle.
// Tests cover strict factory identity and fixed hash code.
// Tests cover factory-created effect state identity.
// Tests drag real scroll content beyond one pixel and observe active state.
// Tests settle the spring and observe active state return to false.
//
// Maintenance rule
//
// Any spring or damping change must be checked against all three source files.
// Do not replace this engine with a visually similar Flutter stock physics.
// Do not derive damping range from a popup or nested list viewport.
// Do not remove PullToRefresh coordination when evolving the gesture layer.
// Compatibility toggles must remain opt-in and preserve defaults when omitted.
