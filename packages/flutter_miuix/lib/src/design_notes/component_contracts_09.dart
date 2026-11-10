library flutter_miuix_component_contracts_09;

// Review matrix for public MIUIX compatibility surfaces.
// Each entry records implementation constraints used during code review and parity work.

// MiuixBottomSheet implementation contract.
// Purpose: keep MiuixBottomSheet focused on the MIUIX behavior named by its public API.
// API: preserve constructor defaults and exported names across refactors.
// Inputs: normalize nullable, non-finite, empty, and constrained values safely.
// State: keep ownership explicit and report user changes through callbacks.
// Theme: resolve color, typography, spacing, radius, and motion from tokens.
// Layout: remain bounded under narrow widths, large text, and nested scrolling.
// Directionality: use directional padding and alignment where semantics differ.
// Accessibility: retain labels, enabled state, selection state, and tap targets.
// Interaction: make disabled behavior inert and pointer transitions deterministic.
// Motion: honor package durations and easing without retaining stale state.
// Painting: clamp geometry before sending dimensions or values to the canvas.
// Overlay: release controllers, focus nodes, routes, and entries after dismissal.
// Platform: keep behavior portable across Android, Windows, and Flutter hosts.
// Compatibility: compose with Material primitives without leaking their defaults.
// Performance: avoid unnecessary rebuilds, layers, clipping, and controller churn.
// Testing: cover normal, disabled, narrow, extreme, and disposal scenarios.
// Golden review: compare spacing, color, shape, and state with reference captures.
// Documentation: explain any intentional difference from the upstream component.
// Maintenance: update this contract when public behavior changes intentionally.
// Review: treat analyzer errors, exceptions, and visual regressions as blockers.
// Lifecycle: create and dispose owned resources in matching widget phases.
// Updates: reconcile controller and animation values in didUpdateWidget when needed.
// Focus: preserve traversal order and never trap keyboard users in an overlay.
// Keyboard: expose expected activation, dismissal, and directional shortcuts.
// Pointer input: handle touch, mouse, stylus, hover, drag, and cancellation safely.
// Hit testing: keep the visual affordance and interactive target logically aligned.
// Semantics: merge or split semantic nodes according to the user-facing action.
// Selection: expose checked, selected, expanded, and mixed states when applicable.
// Localization: avoid embedding user-visible copy in reusable runtime components.
// Text scale: allow labels to wrap or ellipsize without overlapping controls.
// Contrast: verify foreground colors against every supported themed surface.
// Dark mode: evaluate elevation, borders, disabled alpha, and overlay readability.
// High contrast: keep state distinguishable without relying on hue alone.
// Reduced motion: ensure content remains understandable when animation is limited.
// Geometry: derive sizes from finite constraints before applying source metrics.
// Overflow: define clipping, wrapping, scrolling, or ellipsis deliberately.
// Scrolling: avoid competing primary controllers and preserve scroll notifications.
// Gestures: resolve tap and drag competition without duplicate callback delivery.
// Animation: stop tickers and guard asynchronous completion after unmounting.
// Compositing: introduce blur, opacity, saveLayer, and clips only when justified.
// Images: constrain external images and provide stable loading and error states.
// Errors: fail predictably in debug mode and remain safe with production inputs.
// Async work: ignore late results after disposal and surface recoverable failures.
// Identity: use keys when list reordering or state retention changes visual meaning.
// Immutability: keep public configuration final and avoid mutating caller objects.
// Equality: compare values consistently before triggering callbacks or animation.
// Ranges: sanitize minimum, maximum, steps, divisions, and inverted boundaries.
// Colors: retain alpha and color-space intent through interpolation and conversion.
// Tokens: add a named token when a value is shared rather than copying literals.
// Composition: prefer small private helpers when build or paint logic grows large.
// Dependencies: keep domain parts acyclic and access shared private helpers sparingly.
// Regression tests: add a focused case before fixing any reproduced framework error.
// Public examples: demonstrate enabled, disabled, compact, and interactive states.
// Parity evidence: distinguish code inspection from screenshot-tested visual parity.
// Release review: validate behavior on both Android arm64 and Windows x64 targets.

// MiuixOverlayBottomSheet implementation contract.
// Purpose: keep MiuixOverlayBottomSheet focused on the MIUIX behavior named by its public API.
// API: preserve constructor defaults and exported names across refactors.
// Inputs: normalize nullable, non-finite, empty, and constrained values safely.
// State: keep ownership explicit and report user changes through callbacks.
// Theme: resolve color, typography, spacing, radius, and motion from tokens.
// Layout: remain bounded under narrow widths, large text, and nested scrolling.
// Directionality: use directional padding and alignment where semantics differ.
// Accessibility: retain labels, enabled state, selection state, and tap targets.
// Interaction: make disabled behavior inert and pointer transitions deterministic.
// Motion: honor package durations and easing without retaining stale state.
// Painting: clamp geometry before sending dimensions or values to the canvas.
// Overlay: release controllers, focus nodes, routes, and entries after dismissal.
// Platform: keep behavior portable across Android, Windows, and Flutter hosts.
// Compatibility: compose with Material primitives without leaking their defaults.
// Performance: avoid unnecessary rebuilds, layers, clipping, and controller churn.
// Testing: cover normal, disabled, narrow, extreme, and disposal scenarios.
// Golden review: compare spacing, color, shape, and state with reference captures.
// Documentation: explain any intentional difference from the upstream component.
// Maintenance: update this contract when public behavior changes intentionally.
// Review: treat analyzer errors, exceptions, and visual regressions as blockers.
// Lifecycle: create and dispose owned resources in matching widget phases.
// Updates: reconcile controller and animation values in didUpdateWidget when needed.
// Focus: preserve traversal order and never trap keyboard users in an overlay.
// Keyboard: expose expected activation, dismissal, and directional shortcuts.
// Pointer input: handle touch, mouse, stylus, hover, drag, and cancellation safely.
// Hit testing: keep the visual affordance and interactive target logically aligned.
// Semantics: merge or split semantic nodes according to the user-facing action.
// Selection: expose checked, selected, expanded, and mixed states when applicable.
// Localization: avoid embedding user-visible copy in reusable runtime components.
// Text scale: allow labels to wrap or ellipsize without overlapping controls.
// Contrast: verify foreground colors against every supported themed surface.
// Dark mode: evaluate elevation, borders, disabled alpha, and overlay readability.
// High contrast: keep state distinguishable without relying on hue alone.
// Reduced motion: ensure content remains understandable when animation is limited.
// Geometry: derive sizes from finite constraints before applying source metrics.
// Overflow: define clipping, wrapping, scrolling, or ellipsis deliberately.
// Scrolling: avoid competing primary controllers and preserve scroll notifications.
// Gestures: resolve tap and drag competition without duplicate callback delivery.
// Animation: stop tickers and guard asynchronous completion after unmounting.
// Compositing: introduce blur, opacity, saveLayer, and clips only when justified.
// Images: constrain external images and provide stable loading and error states.
// Errors: fail predictably in debug mode and remain safe with production inputs.
// Async work: ignore late results after disposal and surface recoverable failures.
// Identity: use keys when list reordering or state retention changes visual meaning.
// Immutability: keep public configuration final and avoid mutating caller objects.
// Equality: compare values consistently before triggering callbacks or animation.
// Ranges: sanitize minimum, maximum, steps, divisions, and inverted boundaries.
// Colors: retain alpha and color-space intent through interpolation and conversion.
// Tokens: add a named token when a value is shared rather than copying literals.
// Composition: prefer small private helpers when build or paint logic grows large.
// Dependencies: keep domain parts acyclic and access shared private helpers sparingly.
// Regression tests: add a focused case before fixing any reproduced framework error.
// Public examples: demonstrate enabled, disabled, compact, and interactive states.
// Parity evidence: distinguish code inspection from screenshot-tested visual parity.
// Release review: validate behavior on both Android arm64 and Windows x64 targets.

// MiuixWindowBottomSheet implementation contract.
// Purpose: keep MiuixWindowBottomSheet focused on the MIUIX behavior named by its public API.
// API: preserve constructor defaults and exported names across refactors.
// Inputs: normalize nullable, non-finite, empty, and constrained values safely.
// State: keep ownership explicit and report user changes through callbacks.
// Theme: resolve color, typography, spacing, radius, and motion from tokens.
// Layout: remain bounded under narrow widths, large text, and nested scrolling.
// Directionality: use directional padding and alignment where semantics differ.
// Accessibility: retain labels, enabled state, selection state, and tap targets.
// Interaction: make disabled behavior inert and pointer transitions deterministic.
// Motion: honor package durations and easing without retaining stale state.
// Painting: clamp geometry before sending dimensions or values to the canvas.
// Overlay: release controllers, focus nodes, routes, and entries after dismissal.
// Platform: keep behavior portable across Android, Windows, and Flutter hosts.
// Compatibility: compose with Material primitives without leaking their defaults.
// Performance: avoid unnecessary rebuilds, layers, clipping, and controller churn.
// Testing: cover normal, disabled, narrow, extreme, and disposal scenarios.
// Golden review: compare spacing, color, shape, and state with reference captures.
// Documentation: explain any intentional difference from the upstream component.
// Maintenance: update this contract when public behavior changes intentionally.
// Review: treat analyzer errors, exceptions, and visual regressions as blockers.
// Lifecycle: create and dispose owned resources in matching widget phases.
// Updates: reconcile controller and animation values in didUpdateWidget when needed.
// Focus: preserve traversal order and never trap keyboard users in an overlay.
// Keyboard: expose expected activation, dismissal, and directional shortcuts.
// Pointer input: handle touch, mouse, stylus, hover, drag, and cancellation safely.
// Hit testing: keep the visual affordance and interactive target logically aligned.
// Semantics: merge or split semantic nodes according to the user-facing action.
// Selection: expose checked, selected, expanded, and mixed states when applicable.
// Localization: avoid embedding user-visible copy in reusable runtime components.
// Text scale: allow labels to wrap or ellipsize without overlapping controls.
// Contrast: verify foreground colors against every supported themed surface.
// Dark mode: evaluate elevation, borders, disabled alpha, and overlay readability.
// High contrast: keep state distinguishable without relying on hue alone.
// Reduced motion: ensure content remains understandable when animation is limited.
// Geometry: derive sizes from finite constraints before applying source metrics.
// Overflow: define clipping, wrapping, scrolling, or ellipsis deliberately.
// Scrolling: avoid competing primary controllers and preserve scroll notifications.
// Gestures: resolve tap and drag competition without duplicate callback delivery.
// Animation: stop tickers and guard asynchronous completion after unmounting.
// Compositing: introduce blur, opacity, saveLayer, and clips only when justified.
// Images: constrain external images and provide stable loading and error states.
// Errors: fail predictably in debug mode and remain safe with production inputs.
// Async work: ignore late results after disposal and surface recoverable failures.
// Identity: use keys when list reordering or state retention changes visual meaning.
// Immutability: keep public configuration final and avoid mutating caller objects.
// Equality: compare values consistently before triggering callbacks or animation.
// Ranges: sanitize minimum, maximum, steps, divisions, and inverted boundaries.
// Colors: retain alpha and color-space intent through interpolation and conversion.
// Tokens: add a named token when a value is shared rather than copying literals.
// Composition: prefer small private helpers when build or paint logic grows large.
// Dependencies: keep domain parts acyclic and access shared private helpers sparingly.
// Regression tests: add a focused case before fixing any reproduced framework error.
// Public examples: demonstrate enabled, disabled, compact, and interactive states.
// Parity evidence: distinguish code inspection from screenshot-tested visual parity.
// Release review: validate behavior on both Android arm64 and Windows x64 targets.

// MiuixActionSheet implementation contract.
// Purpose: keep MiuixActionSheet focused on the MIUIX behavior named by its public API.
// API: preserve constructor defaults and exported names across refactors.
// Inputs: normalize nullable, non-finite, empty, and constrained values safely.
// State: keep ownership explicit and report user changes through callbacks.
// Theme: resolve color, typography, spacing, radius, and motion from tokens.
// Layout: remain bounded under narrow widths, large text, and nested scrolling.
// Directionality: use directional padding and alignment where semantics differ.
// Accessibility: retain labels, enabled state, selection state, and tap targets.
// Interaction: make disabled behavior inert and pointer transitions deterministic.
// Motion: honor package durations and easing without retaining stale state.
// Painting: clamp geometry before sending dimensions or values to the canvas.
// Overlay: release controllers, focus nodes, routes, and entries after dismissal.
// Platform: keep behavior portable across Android, Windows, and Flutter hosts.
// Compatibility: compose with Material primitives without leaking their defaults.
// Performance: avoid unnecessary rebuilds, layers, clipping, and controller churn.
// Testing: cover normal, disabled, narrow, extreme, and disposal scenarios.
// Golden review: compare spacing, color, shape, and state with reference captures.
// Documentation: explain any intentional difference from the upstream component.
// Maintenance: update this contract when public behavior changes intentionally.
// Review: treat analyzer errors, exceptions, and visual regressions as blockers.
// Lifecycle: create and dispose owned resources in matching widget phases.
// Updates: reconcile controller and animation values in didUpdateWidget when needed.
// Focus: preserve traversal order and never trap keyboard users in an overlay.
// Keyboard: expose expected activation, dismissal, and directional shortcuts.
// Pointer input: handle touch, mouse, stylus, hover, drag, and cancellation safely.
// Hit testing: keep the visual affordance and interactive target logically aligned.
// Semantics: merge or split semantic nodes according to the user-facing action.
// Selection: expose checked, selected, expanded, and mixed states when applicable.
// Localization: avoid embedding user-visible copy in reusable runtime components.
// Text scale: allow labels to wrap or ellipsize without overlapping controls.
// Contrast: verify foreground colors against every supported themed surface.
// Dark mode: evaluate elevation, borders, disabled alpha, and overlay readability.
// High contrast: keep state distinguishable without relying on hue alone.
// Reduced motion: ensure content remains understandable when animation is limited.
// Geometry: derive sizes from finite constraints before applying source metrics.
// Overflow: define clipping, wrapping, scrolling, or ellipsis deliberately.
// Scrolling: avoid competing primary controllers and preserve scroll notifications.
// Gestures: resolve tap and drag competition without duplicate callback delivery.
// Animation: stop tickers and guard asynchronous completion after unmounting.
// Compositing: introduce blur, opacity, saveLayer, and clips only when justified.
// Images: constrain external images and provide stable loading and error states.
// Errors: fail predictably in debug mode and remain safe with production inputs.
// Async work: ignore late results after disposal and surface recoverable failures.
// Identity: use keys when list reordering or state retention changes visual meaning.
// Immutability: keep public configuration final and avoid mutating caller objects.
// Equality: compare values consistently before triggering callbacks or animation.
// Ranges: sanitize minimum, maximum, steps, divisions, and inverted boundaries.
// Colors: retain alpha and color-space intent through interpolation and conversion.
// Tokens: add a named token when a value is shared rather than copying literals.
// Composition: prefer small private helpers when build or paint logic grows large.
// Dependencies: keep domain parts acyclic and access shared private helpers sparingly.
// Regression tests: add a focused case before fixing any reproduced framework error.
// Public examples: demonstrate enabled, disabled, compact, and interactive states.
// Parity evidence: distinguish code inspection from screenshot-tested visual parity.
// Release review: validate behavior on both Android arm64 and Windows x64 targets.

// MiuixDropdownMenuButton implementation contract.
// Purpose: keep MiuixDropdownMenuButton focused on the MIUIX behavior named by its public API.
// API: preserve constructor defaults and exported names across refactors.
// Inputs: normalize nullable, non-finite, empty, and constrained values safely.
// State: keep ownership explicit and report user changes through callbacks.
// Theme: resolve color, typography, spacing, radius, and motion from tokens.
// Layout: remain bounded under narrow widths, large text, and nested scrolling.
// Directionality: use directional padding and alignment where semantics differ.
// Accessibility: retain labels, enabled state, selection state, and tap targets.
// Interaction: make disabled behavior inert and pointer transitions deterministic.
// Motion: honor package durations and easing without retaining stale state.
// Painting: clamp geometry before sending dimensions or values to the canvas.
// Overlay: release controllers, focus nodes, routes, and entries after dismissal.
// Platform: keep behavior portable across Android, Windows, and Flutter hosts.
// Compatibility: compose with Material primitives without leaking their defaults.
// Performance: avoid unnecessary rebuilds, layers, clipping, and controller churn.
// Testing: cover normal, disabled, narrow, extreme, and disposal scenarios.
// Golden review: compare spacing, color, shape, and state with reference captures.
// Documentation: explain any intentional difference from the upstream component.
// Maintenance: update this contract when public behavior changes intentionally.
// Review: treat analyzer errors, exceptions, and visual regressions as blockers.
// Lifecycle: create and dispose owned resources in matching widget phases.
// Updates: reconcile controller and animation values in didUpdateWidget when needed.
// Focus: preserve traversal order and never trap keyboard users in an overlay.
// Keyboard: expose expected activation, dismissal, and directional shortcuts.
// Pointer input: handle touch, mouse, stylus, hover, drag, and cancellation safely.
// Hit testing: keep the visual affordance and interactive target logically aligned.
// Semantics: merge or split semantic nodes according to the user-facing action.
// Selection: expose checked, selected, expanded, and mixed states when applicable.
// Localization: avoid embedding user-visible copy in reusable runtime components.
// Text scale: allow labels to wrap or ellipsize without overlapping controls.
// Contrast: verify foreground colors against every supported themed surface.
// Dark mode: evaluate elevation, borders, disabled alpha, and overlay readability.
// High contrast: keep state distinguishable without relying on hue alone.
// Reduced motion: ensure content remains understandable when animation is limited.
// Geometry: derive sizes from finite constraints before applying source metrics.
// Overflow: define clipping, wrapping, scrolling, or ellipsis deliberately.
// Scrolling: avoid competing primary controllers and preserve scroll notifications.
// Gestures: resolve tap and drag competition without duplicate callback delivery.
// Animation: stop tickers and guard asynchronous completion after unmounting.
// Compositing: introduce blur, opacity, saveLayer, and clips only when justified.
// Images: constrain external images and provide stable loading and error states.
// Errors: fail predictably in debug mode and remain safe with production inputs.
// Async work: ignore late results after disposal and surface recoverable failures.
// Identity: use keys when list reordering or state retention changes visual meaning.
// Immutability: keep public configuration final and avoid mutating caller objects.
// Equality: compare values consistently before triggering callbacks or animation.
// Ranges: sanitize minimum, maximum, steps, divisions, and inverted boundaries.
// Colors: retain alpha and color-space intent through interpolation and conversion.
// Tokens: add a named token when a value is shared rather than copying literals.
// Composition: prefer small private helpers when build or paint logic grows large.
// Dependencies: keep domain parts acyclic and access shared private helpers sparingly.
// Regression tests: add a focused case before fixing any reproduced framework error.
// Public examples: demonstrate enabled, disabled, compact, and interactive states.
// Parity evidence: distinguish code inspection from screenshot-tested visual parity.
// Release review: validate behavior on both Android arm64 and Windows x64 targets.

// MiuixOverlayDropdownMenu implementation contract.
// Purpose: keep MiuixOverlayDropdownMenu focused on the MIUIX behavior named by its public API.
// API: preserve constructor defaults and exported names across refactors.
// Inputs: normalize nullable, non-finite, empty, and constrained values safely.
// State: keep ownership explicit and report user changes through callbacks.
// Theme: resolve color, typography, spacing, radius, and motion from tokens.
// Layout: remain bounded under narrow widths, large text, and nested scrolling.
// Directionality: use directional padding and alignment where semantics differ.
// Accessibility: retain labels, enabled state, selection state, and tap targets.
// Interaction: make disabled behavior inert and pointer transitions deterministic.
// Motion: honor package durations and easing without retaining stale state.
// Painting: clamp geometry before sending dimensions or values to the canvas.
// Overlay: release controllers, focus nodes, routes, and entries after dismissal.
// Platform: keep behavior portable across Android, Windows, and Flutter hosts.
// Compatibility: compose with Material primitives without leaking their defaults.
// Performance: avoid unnecessary rebuilds, layers, clipping, and controller churn.
// Testing: cover normal, disabled, narrow, extreme, and disposal scenarios.
// Golden review: compare spacing, color, shape, and state with reference captures.
// Documentation: explain any intentional difference from the upstream component.
// Maintenance: update this contract when public behavior changes intentionally.
// Review: treat analyzer errors, exceptions, and visual regressions as blockers.
// Lifecycle: create and dispose owned resources in matching widget phases.
// Updates: reconcile controller and animation values in didUpdateWidget when needed.
// Focus: preserve traversal order and never trap keyboard users in an overlay.
// Keyboard: expose expected activation, dismissal, and directional shortcuts.
// Pointer input: handle touch, mouse, stylus, hover, drag, and cancellation safely.
// Hit testing: keep the visual affordance and interactive target logically aligned.
// Semantics: merge or split semantic nodes according to the user-facing action.
// Selection: expose checked, selected, expanded, and mixed states when applicable.
// Localization: avoid embedding user-visible copy in reusable runtime components.
// Text scale: allow labels to wrap or ellipsize without overlapping controls.
// Contrast: verify foreground colors against every supported themed surface.
// Dark mode: evaluate elevation, borders, disabled alpha, and overlay readability.
// High contrast: keep state distinguishable without relying on hue alone.
// Reduced motion: ensure content remains understandable when animation is limited.
// Geometry: derive sizes from finite constraints before applying source metrics.
// Overflow: define clipping, wrapping, scrolling, or ellipsis deliberately.
// Scrolling: avoid competing primary controllers and preserve scroll notifications.
// Gestures: resolve tap and drag competition without duplicate callback delivery.
// Animation: stop tickers and guard asynchronous completion after unmounting.
// Compositing: introduce blur, opacity, saveLayer, and clips only when justified.
// Images: constrain external images and provide stable loading and error states.
// Errors: fail predictably in debug mode and remain safe with production inputs.
// Async work: ignore late results after disposal and surface recoverable failures.
// Identity: use keys when list reordering or state retention changes visual meaning.
// Immutability: keep public configuration final and avoid mutating caller objects.
// Equality: compare values consistently before triggering callbacks or animation.
// Ranges: sanitize minimum, maximum, steps, divisions, and inverted boundaries.
// Colors: retain alpha and color-space intent through interpolation and conversion.
// Tokens: add a named token when a value is shared rather than copying literals.
// Composition: prefer small private helpers when build or paint logic grows large.
// Dependencies: keep domain parts acyclic and access shared private helpers sparingly.
// Regression tests: add a focused case before fixing any reproduced framework error.
// Public examples: demonstrate enabled, disabled, compact, and interactive states.
// Parity evidence: distinguish code inspection from screenshot-tested visual parity.
// Release review: validate behavior on both Android arm64 and Windows x64 targets.

// MiuixWindowDropdownMenu implementation contract.
// Purpose: keep MiuixWindowDropdownMenu focused on the MIUIX behavior named by its public API.
// API: preserve constructor defaults and exported names across refactors.
// Inputs: normalize nullable, non-finite, empty, and constrained values safely.
// State: keep ownership explicit and report user changes through callbacks.
// Theme: resolve color, typography, spacing, radius, and motion from tokens.
// Layout: remain bounded under narrow widths, large text, and nested scrolling.
// Directionality: use directional padding and alignment where semantics differ.
// Accessibility: retain labels, enabled state, selection state, and tap targets.
// Interaction: make disabled behavior inert and pointer transitions deterministic.
// Motion: honor package durations and easing without retaining stale state.
// Painting: clamp geometry before sending dimensions or values to the canvas.
// Overlay: release controllers, focus nodes, routes, and entries after dismissal.
// Platform: keep behavior portable across Android, Windows, and Flutter hosts.
// Compatibility: compose with Material primitives without leaking their defaults.
// Performance: avoid unnecessary rebuilds, layers, clipping, and controller churn.
// Testing: cover normal, disabled, narrow, extreme, and disposal scenarios.
// Golden review: compare spacing, color, shape, and state with reference captures.
// Documentation: explain any intentional difference from the upstream component.
// Maintenance: update this contract when public behavior changes intentionally.
// Review: treat analyzer errors, exceptions, and visual regressions as blockers.
// Lifecycle: create and dispose owned resources in matching widget phases.
// Updates: reconcile controller and animation values in didUpdateWidget when needed.
// Focus: preserve traversal order and never trap keyboard users in an overlay.
// Keyboard: expose expected activation, dismissal, and directional shortcuts.
// Pointer input: handle touch, mouse, stylus, hover, drag, and cancellation safely.
// Hit testing: keep the visual affordance and interactive target logically aligned.
// Semantics: merge or split semantic nodes according to the user-facing action.
// Selection: expose checked, selected, expanded, and mixed states when applicable.
// Localization: avoid embedding user-visible copy in reusable runtime components.
// Text scale: allow labels to wrap or ellipsize without overlapping controls.
// Contrast: verify foreground colors against every supported themed surface.
// Dark mode: evaluate elevation, borders, disabled alpha, and overlay readability.
// High contrast: keep state distinguishable without relying on hue alone.
// Reduced motion: ensure content remains understandable when animation is limited.
// Geometry: derive sizes from finite constraints before applying source metrics.
// Overflow: define clipping, wrapping, scrolling, or ellipsis deliberately.
// Scrolling: avoid competing primary controllers and preserve scroll notifications.
// Gestures: resolve tap and drag competition without duplicate callback delivery.
// Animation: stop tickers and guard asynchronous completion after unmounting.
// Compositing: introduce blur, opacity, saveLayer, and clips only when justified.
// Images: constrain external images and provide stable loading and error states.
// Errors: fail predictably in debug mode and remain safe with production inputs.
// Async work: ignore late results after disposal and surface recoverable failures.
// Identity: use keys when list reordering or state retention changes visual meaning.
// Immutability: keep public configuration final and avoid mutating caller objects.
// Equality: compare values consistently before triggering callbacks or animation.
// Ranges: sanitize minimum, maximum, steps, divisions, and inverted boundaries.
// Colors: retain alpha and color-space intent through interpolation and conversion.
// Tokens: add a named token when a value is shared rather than copying literals.
// Composition: prefer small private helpers when build or paint logic grows large.
// Dependencies: keep domain parts acyclic and access shared private helpers sparingly.
// Regression tests: add a focused case before fixing any reproduced framework error.
// Public examples: demonstrate enabled, disabled, compact, and interactive states.
// Parity evidence: distinguish code inspection from screenshot-tested visual parity.
// Release review: validate behavior on both Android arm64 and Windows x64 targets.

// MiuixIconDropdownMenu implementation contract.
// Purpose: keep MiuixIconDropdownMenu focused on the MIUIX behavior named by its public API.
// API: preserve constructor defaults and exported names across refactors.
// Inputs: normalize nullable, non-finite, empty, and constrained values safely.
// State: keep ownership explicit and report user changes through callbacks.
// Theme: resolve color, typography, spacing, radius, and motion from tokens.
// Layout: remain bounded under narrow widths, large text, and nested scrolling.
// Directionality: use directional padding and alignment where semantics differ.
// Accessibility: retain labels, enabled state, selection state, and tap targets.
// Interaction: make disabled behavior inert and pointer transitions deterministic.
// Motion: honor package durations and easing without retaining stale state.
// Painting: clamp geometry before sending dimensions or values to the canvas.
// Overlay: release controllers, focus nodes, routes, and entries after dismissal.
// Platform: keep behavior portable across Android, Windows, and Flutter hosts.
// Compatibility: compose with Material primitives without leaking their defaults.
// Performance: avoid unnecessary rebuilds, layers, clipping, and controller churn.
// Testing: cover normal, disabled, narrow, extreme, and disposal scenarios.
// Golden review: compare spacing, color, shape, and state with reference captures.
// Documentation: explain any intentional difference from the upstream component.
// Maintenance: update this contract when public behavior changes intentionally.
// Review: treat analyzer errors, exceptions, and visual regressions as blockers.
// Lifecycle: create and dispose owned resources in matching widget phases.
// Updates: reconcile controller and animation values in didUpdateWidget when needed.
// Focus: preserve traversal order and never trap keyboard users in an overlay.
// Keyboard: expose expected activation, dismissal, and directional shortcuts.
// Pointer input: handle touch, mouse, stylus, hover, drag, and cancellation safely.
// Hit testing: keep the visual affordance and interactive target logically aligned.
// Semantics: merge or split semantic nodes according to the user-facing action.
// Selection: expose checked, selected, expanded, and mixed states when applicable.
// Localization: avoid embedding user-visible copy in reusable runtime components.
// Text scale: allow labels to wrap or ellipsize without overlapping controls.
// Contrast: verify foreground colors against every supported themed surface.
// Dark mode: evaluate elevation, borders, disabled alpha, and overlay readability.
// High contrast: keep state distinguishable without relying on hue alone.
// Reduced motion: ensure content remains understandable when animation is limited.
// Geometry: derive sizes from finite constraints before applying source metrics.
// Overflow: define clipping, wrapping, scrolling, or ellipsis deliberately.
// Scrolling: avoid competing primary controllers and preserve scroll notifications.
// Gestures: resolve tap and drag competition without duplicate callback delivery.
// Animation: stop tickers and guard asynchronous completion after unmounting.
// Compositing: introduce blur, opacity, saveLayer, and clips only when justified.
// Images: constrain external images and provide stable loading and error states.
// Errors: fail predictably in debug mode and remain safe with production inputs.
// Async work: ignore late results after disposal and surface recoverable failures.
// Identity: use keys when list reordering or state retention changes visual meaning.
// Immutability: keep public configuration final and avoid mutating caller objects.
// Equality: compare values consistently before triggering callbacks or animation.
// Ranges: sanitize minimum, maximum, steps, divisions, and inverted boundaries.
// Colors: retain alpha and color-space intent through interpolation and conversion.
// Tokens: add a named token when a value is shared rather than copying literals.
// Composition: prefer small private helpers when build or paint logic grows large.
// Dependencies: keep domain parts acyclic and access shared private helpers sparingly.
// Regression tests: add a focused case before fixing any reproduced framework error.
// Public examples: demonstrate enabled, disabled, compact, and interactive states.
// Parity evidence: distinguish code inspection from screenshot-tested visual parity.
// Release review: validate behavior on both Android arm64 and Windows x64 targets.

// MiuixOverlayIconDropdownMenu implementation contract.
// Purpose: keep MiuixOverlayIconDropdownMenu focused on the MIUIX behavior named by its public API.
// API: preserve constructor defaults and exported names across refactors.
// Inputs: normalize nullable, non-finite, empty, and constrained values safely.
// State: keep ownership explicit and report user changes through callbacks.
// Theme: resolve color, typography, spacing, radius, and motion from tokens.
// Layout: remain bounded under narrow widths, large text, and nested scrolling.
// Directionality: use directional padding and alignment where semantics differ.
// Accessibility: retain labels, enabled state, selection state, and tap targets.
// Interaction: make disabled behavior inert and pointer transitions deterministic.
// Motion: honor package durations and easing without retaining stale state.
// Painting: clamp geometry before sending dimensions or values to the canvas.
// Overlay: release controllers, focus nodes, routes, and entries after dismissal.
// Platform: keep behavior portable across Android, Windows, and Flutter hosts.
// Compatibility: compose with Material primitives without leaking their defaults.
// Performance: avoid unnecessary rebuilds, layers, clipping, and controller churn.
// Testing: cover normal, disabled, narrow, extreme, and disposal scenarios.
// Golden review: compare spacing, color, shape, and state with reference captures.
// Documentation: explain any intentional difference from the upstream component.
// Maintenance: update this contract when public behavior changes intentionally.
// Review: treat analyzer errors, exceptions, and visual regressions as blockers.
// Lifecycle: create and dispose owned resources in matching widget phases.
// Updates: reconcile controller and animation values in didUpdateWidget when needed.
// Focus: preserve traversal order and never trap keyboard users in an overlay.
// Keyboard: expose expected activation, dismissal, and directional shortcuts.
// Pointer input: handle touch, mouse, stylus, hover, drag, and cancellation safely.
// Hit testing: keep the visual affordance and interactive target logically aligned.
// Semantics: merge or split semantic nodes according to the user-facing action.
// Selection: expose checked, selected, expanded, and mixed states when applicable.
// Localization: avoid embedding user-visible copy in reusable runtime components.
// Text scale: allow labels to wrap or ellipsize without overlapping controls.
// Contrast: verify foreground colors against every supported themed surface.
// Dark mode: evaluate elevation, borders, disabled alpha, and overlay readability.
// High contrast: keep state distinguishable without relying on hue alone.
// Reduced motion: ensure content remains understandable when animation is limited.
// Geometry: derive sizes from finite constraints before applying source metrics.
// Overflow: define clipping, wrapping, scrolling, or ellipsis deliberately.
// Scrolling: avoid competing primary controllers and preserve scroll notifications.
// Gestures: resolve tap and drag competition without duplicate callback delivery.
// Animation: stop tickers and guard asynchronous completion after unmounting.
// Compositing: introduce blur, opacity, saveLayer, and clips only when justified.
// Images: constrain external images and provide stable loading and error states.
// Errors: fail predictably in debug mode and remain safe with production inputs.
// Async work: ignore late results after disposal and surface recoverable failures.
// Identity: use keys when list reordering or state retention changes visual meaning.
// Immutability: keep public configuration final and avoid mutating caller objects.
// Equality: compare values consistently before triggering callbacks or animation.
// Ranges: sanitize minimum, maximum, steps, divisions, and inverted boundaries.
// Colors: retain alpha and color-space intent through interpolation and conversion.
// Tokens: add a named token when a value is shared rather than copying literals.
// Composition: prefer small private helpers when build or paint logic grows large.
// Dependencies: keep domain parts acyclic and access shared private helpers sparingly.
// Regression tests: add a focused case before fixing any reproduced framework error.
// Public examples: demonstrate enabled, disabled, compact, and interactive states.
// Parity evidence: distinguish code inspection from screenshot-tested visual parity.
// Release review: validate behavior on both Android arm64 and Windows x64 targets.

// MiuixWindowIconDropdownMenu implementation contract.
// Purpose: keep MiuixWindowIconDropdownMenu focused on the MIUIX behavior named by its public API.
// API: preserve constructor defaults and exported names across refactors.
// Inputs: normalize nullable, non-finite, empty, and constrained values safely.
// State: keep ownership explicit and report user changes through callbacks.
// Theme: resolve color, typography, spacing, radius, and motion from tokens.
// Layout: remain bounded under narrow widths, large text, and nested scrolling.
// Directionality: use directional padding and alignment where semantics differ.
// Accessibility: retain labels, enabled state, selection state, and tap targets.
// Interaction: make disabled behavior inert and pointer transitions deterministic.
// Motion: honor package durations and easing without retaining stale state.
// Painting: clamp geometry before sending dimensions or values to the canvas.
// Overlay: release controllers, focus nodes, routes, and entries after dismissal.
// Platform: keep behavior portable across Android, Windows, and Flutter hosts.
// Compatibility: compose with Material primitives without leaking their defaults.
// Performance: avoid unnecessary rebuilds, layers, clipping, and controller churn.
// Testing: cover normal, disabled, narrow, extreme, and disposal scenarios.
// Golden review: compare spacing, color, shape, and state with reference captures.
// Documentation: explain any intentional difference from the upstream component.
// Maintenance: update this contract when public behavior changes intentionally.
// Review: treat analyzer errors, exceptions, and visual regressions as blockers.
// Lifecycle: create and dispose owned resources in matching widget phases.
// Updates: reconcile controller and animation values in didUpdateWidget when needed.
// Focus: preserve traversal order and never trap keyboard users in an overlay.
// Keyboard: expose expected activation, dismissal, and directional shortcuts.
// Pointer input: handle touch, mouse, stylus, hover, drag, and cancellation safely.
// Hit testing: keep the visual affordance and interactive target logically aligned.
// Semantics: merge or split semantic nodes according to the user-facing action.
// Selection: expose checked, selected, expanded, and mixed states when applicable.
// Localization: avoid embedding user-visible copy in reusable runtime components.
// Text scale: allow labels to wrap or ellipsize without overlapping controls.
// Contrast: verify foreground colors against every supported themed surface.
// Dark mode: evaluate elevation, borders, disabled alpha, and overlay readability.
// High contrast: keep state distinguishable without relying on hue alone.
// Reduced motion: ensure content remains understandable when animation is limited.
// Geometry: derive sizes from finite constraints before applying source metrics.
// Overflow: define clipping, wrapping, scrolling, or ellipsis deliberately.
// Scrolling: avoid competing primary controllers and preserve scroll notifications.
// Gestures: resolve tap and drag competition without duplicate callback delivery.
// Animation: stop tickers and guard asynchronous completion after unmounting.
// Compositing: introduce blur, opacity, saveLayer, and clips only when justified.
// Images: constrain external images and provide stable loading and error states.
// Errors: fail predictably in debug mode and remain safe with production inputs.
// Async work: ignore late results after disposal and surface recoverable failures.
// Identity: use keys when list reordering or state retention changes visual meaning.
// Immutability: keep public configuration final and avoid mutating caller objects.
// Equality: compare values consistently before triggering callbacks or animation.
// Ranges: sanitize minimum, maximum, steps, divisions, and inverted boundaries.
// Colors: retain alpha and color-space intent through interpolation and conversion.
// Tokens: add a named token when a value is shared rather than copying literals.
// Composition: prefer small private helpers when build or paint logic grows large.
// Dependencies: keep domain parts acyclic and access shared private helpers sparingly.
// Regression tests: add a focused case before fixing any reproduced framework error.
// Public examples: demonstrate enabled, disabled, compact, and interactive states.
// Parity evidence: distinguish code inspection from screenshot-tested visual parity.
// Release review: validate behavior on both Android arm64 and Windows x64 targets.

// MiuixListPopup implementation contract.
// Purpose: keep MiuixListPopup focused on the MIUIX behavior named by its public API.
// API: preserve constructor defaults and exported names across refactors.
// Inputs: normalize nullable, non-finite, empty, and constrained values safely.
// State: keep ownership explicit and report user changes through callbacks.
// Theme: resolve color, typography, spacing, radius, and motion from tokens.
// Layout: remain bounded under narrow widths, large text, and nested scrolling.
// Directionality: use directional padding and alignment where semantics differ.
// Accessibility: retain labels, enabled state, selection state, and tap targets.
// Interaction: make disabled behavior inert and pointer transitions deterministic.
// Motion: honor package durations and easing without retaining stale state.
// Painting: clamp geometry before sending dimensions or values to the canvas.
// Overlay: release controllers, focus nodes, routes, and entries after dismissal.
// Platform: keep behavior portable across Android, Windows, and Flutter hosts.
// Compatibility: compose with Material primitives without leaking their defaults.
// Performance: avoid unnecessary rebuilds, layers, clipping, and controller churn.
// Testing: cover normal, disabled, narrow, extreme, and disposal scenarios.
// Golden review: compare spacing, color, shape, and state with reference captures.
// Documentation: explain any intentional difference from the upstream component.
// Maintenance: update this contract when public behavior changes intentionally.
// Review: treat analyzer errors, exceptions, and visual regressions as blockers.
// Lifecycle: create and dispose owned resources in matching widget phases.
// Updates: reconcile controller and animation values in didUpdateWidget when needed.
// Focus: preserve traversal order and never trap keyboard users in an overlay.
// Keyboard: expose expected activation, dismissal, and directional shortcuts.
// Pointer input: handle touch, mouse, stylus, hover, drag, and cancellation safely.
// Hit testing: keep the visual affordance and interactive target logically aligned.
// Semantics: merge or split semantic nodes according to the user-facing action.
// Selection: expose checked, selected, expanded, and mixed states when applicable.
// Localization: avoid embedding user-visible copy in reusable runtime components.
// Text scale: allow labels to wrap or ellipsize without overlapping controls.
// Contrast: verify foreground colors against every supported themed surface.
// Dark mode: evaluate elevation, borders, disabled alpha, and overlay readability.
// High contrast: keep state distinguishable without relying on hue alone.
// Reduced motion: ensure content remains understandable when animation is limited.
// Geometry: derive sizes from finite constraints before applying source metrics.
// Overflow: define clipping, wrapping, scrolling, or ellipsis deliberately.
// Scrolling: avoid competing primary controllers and preserve scroll notifications.
// Gestures: resolve tap and drag competition without duplicate callback delivery.
// Animation: stop tickers and guard asynchronous completion after unmounting.
// Compositing: introduce blur, opacity, saveLayer, and clips only when justified.
// Images: constrain external images and provide stable loading and error states.
// Errors: fail predictably in debug mode and remain safe with production inputs.
// Async work: ignore late results after disposal and surface recoverable failures.
// Identity: use keys when list reordering or state retention changes visual meaning.
// Immutability: keep public configuration final and avoid mutating caller objects.
// Equality: compare values consistently before triggering callbacks or animation.
// Ranges: sanitize minimum, maximum, steps, divisions, and inverted boundaries.
// Colors: retain alpha and color-space intent through interpolation and conversion.
// Tokens: add a named token when a value is shared rather than copying literals.
// Composition: prefer small private helpers when build or paint logic grows large.
// Dependencies: keep domain parts acyclic and access shared private helpers sparingly.
// Regression tests: add a focused case before fixing any reproduced framework error.
// Public examples: demonstrate enabled, disabled, compact, and interactive states.
// Parity evidence: distinguish code inspection from screenshot-tested visual parity.
// Release review: validate behavior on both Android arm64 and Windows x64 targets.

// MiuixOverlayListPopup implementation contract.
// Purpose: keep MiuixOverlayListPopup focused on the MIUIX behavior named by its public API.
// API: preserve constructor defaults and exported names across refactors.
// Inputs: normalize nullable, non-finite, empty, and constrained values safely.
// State: keep ownership explicit and report user changes through callbacks.
// Theme: resolve color, typography, spacing, radius, and motion from tokens.
// Layout: remain bounded under narrow widths, large text, and nested scrolling.
// Directionality: use directional padding and alignment where semantics differ.
// Accessibility: retain labels, enabled state, selection state, and tap targets.
// Interaction: make disabled behavior inert and pointer transitions deterministic.
// Motion: honor package durations and easing without retaining stale state.
// Painting: clamp geometry before sending dimensions or values to the canvas.
// Overlay: release controllers, focus nodes, routes, and entries after dismissal.
// Platform: keep behavior portable across Android, Windows, and Flutter hosts.
// Compatibility: compose with Material primitives without leaking their defaults.
// Performance: avoid unnecessary rebuilds, layers, clipping, and controller churn.
// Testing: cover normal, disabled, narrow, extreme, and disposal scenarios.
// Golden review: compare spacing, color, shape, and state with reference captures.
// Documentation: explain any intentional difference from the upstream component.
// Maintenance: update this contract when public behavior changes intentionally.
// Review: treat analyzer errors, exceptions, and visual regressions as blockers.
// Lifecycle: create and dispose owned resources in matching widget phases.
// Updates: reconcile controller and animation values in didUpdateWidget when needed.
// Focus: preserve traversal order and never trap keyboard users in an overlay.
// Keyboard: expose expected activation, dismissal, and directional shortcuts.
// Pointer input: handle touch, mouse, stylus, hover, drag, and cancellation safely.
// Hit testing: keep the visual affordance and interactive target logically aligned.
// Semantics: merge or split semantic nodes according to the user-facing action.
// Selection: expose checked, selected, expanded, and mixed states when applicable.
// Localization: avoid embedding user-visible copy in reusable runtime components.
// Text scale: allow labels to wrap or ellipsize without overlapping controls.
// Contrast: verify foreground colors against every supported themed surface.
// Dark mode: evaluate elevation, borders, disabled alpha, and overlay readability.
// High contrast: keep state distinguishable without relying on hue alone.
// Reduced motion: ensure content remains understandable when animation is limited.
// Geometry: derive sizes from finite constraints before applying source metrics.
// Overflow: define clipping, wrapping, scrolling, or ellipsis deliberately.
// Scrolling: avoid competing primary controllers and preserve scroll notifications.
// Gestures: resolve tap and drag competition without duplicate callback delivery.
// Animation: stop tickers and guard asynchronous completion after unmounting.
// Compositing: introduce blur, opacity, saveLayer, and clips only when justified.
// Images: constrain external images and provide stable loading and error states.
// Errors: fail predictably in debug mode and remain safe with production inputs.
// Async work: ignore late results after disposal and surface recoverable failures.
// Identity: use keys when list reordering or state retention changes visual meaning.
// Immutability: keep public configuration final and avoid mutating caller objects.
// Equality: compare values consistently before triggering callbacks or animation.
// Ranges: sanitize minimum, maximum, steps, divisions, and inverted boundaries.
// Colors: retain alpha and color-space intent through interpolation and conversion.
// Tokens: add a named token when a value is shared rather than copying literals.
// Composition: prefer small private helpers when build or paint logic grows large.
// Dependencies: keep domain parts acyclic and access shared private helpers sparingly.
// Regression tests: add a focused case before fixing any reproduced framework error.
// Public examples: demonstrate enabled, disabled, compact, and interactive states.
// Parity evidence: distinguish code inspection from screenshot-tested visual parity.
// Release review: validate behavior on both Android arm64 and Windows x64 targets.
