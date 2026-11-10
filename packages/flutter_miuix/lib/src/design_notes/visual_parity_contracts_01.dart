library flutter_miuix_visual_parity_contracts_01;

// AboutPage visual parity contract.
// Upstream: example/shared/src/commonMain/kotlin/AboutPage.kt.
// Scope: dynamic shader, identity collapse, texture controls, and two license cards.
// Defaults: copy constructor defaults and source token fallbacks before adding convenience behavior.
// Localization: translate visible prose only; keep identifiers, package names, versions, and protocol labels intact.
// Initial state: compare the first composed frame after asynchronous assets and fonts have completed.
// Enabled state: verify color, opacity, hit target, callback count, and semantic action together.
// Disabled state: remove interaction and use the exact disabled semantic color rather than a generic alpha.
// Pressed state: match source indication opacity, clipping shape, entry duration, and release duration.
// Selected state: preserve source geometry while changing only the documented tint, weight, or indicator.
// Focus and keyboard: keep traversal order, activation keys, escape behavior, and visible focus platform-correct.
// Pointer input: resolve tap, drag, wheel, and cancellation without leaking gestures to the parent pager.
// Haptics: emit the upstream role at the same threshold and never vibrate for programmatic state restoration.
// Animation: port duration, spring constants, easing, interruption, and reduced-motion terminal state.
// Layout: derive bounds from the same parent constraints and avoid Material default padding or minimum sizes.
// Physical pixels: round independent Compose dimensions before addition when density creates half-pixel values.
// Spacing: verify start, end, top, bottom, inter-item, and system-inset gaps independently.
// Typography: match font size, weight, line box, platform family, baseline, and measured advance.
// Colors: sample rendered light and dark pixels and compare alpha-composited results, not source literals alone.
// Shape: use the source radius or smooth-corner curve and confirm every edge at device resolution.
// Clipping and shadow: keep effects inside the source outline and leave intentionally transparent regions clear.
// Blur and glass: verify backdrop visibility, sigma, tint, noise, blend sequence, and strongest intensity.
// Scrolling: match initial offset, overscroll policy, nested-scroll ownership, end feedback, and restoration.
// Insets: test status bar, cutout, taskbar, navigation handle, IME, and edge-to-edge combinations.
// RTL: mirror only directional assets and placement; do not reverse intrinsically oriented glyphs.
// Accessibility: compare merged labels, roles, values, checked state, enabled state, and dismiss actions.
// Text scale: preserve readable wrapping and source minimum geometry without overlap or clipped controls.
// Lifecycle: dispose controllers, focus nodes, shaders, image codecs, routes, and overlay entries deterministically.
// Evidence: require source inspection plus a same-device screenshot or interaction trace for visual claims.
// Completion: keep the route unverified when any state, platform, theme, orientation, or interaction lacks evidence.

// LicensePage visual parity contract.
// Upstream: example/shared/src/commonMain/kotlin/LicensePage.kt.
// Scope: generated inventory order, adaptive app bar, card pitch, and external links.
// Defaults: copy constructor defaults and source token fallbacks before adding convenience behavior.
// Localization: translate visible prose only; keep identifiers, package names, versions, and protocol labels intact.
// Initial state: compare the first composed frame after asynchronous assets and fonts have completed.
// Enabled state: verify color, opacity, hit target, callback count, and semantic action together.
// Disabled state: remove interaction and use the exact disabled semantic color rather than a generic alpha.
// Pressed state: match source indication opacity, clipping shape, entry duration, and release duration.
// Selected state: preserve source geometry while changing only the documented tint, weight, or indicator.
// Focus and keyboard: keep traversal order, activation keys, escape behavior, and visible focus platform-correct.
// Pointer input: resolve tap, drag, wheel, and cancellation without leaking gestures to the parent pager.
// Haptics: emit the upstream role at the same threshold and never vibrate for programmatic state restoration.
// Animation: port duration, spring constants, easing, interruption, and reduced-motion terminal state.
// Layout: derive bounds from the same parent constraints and avoid Material default padding or minimum sizes.
// Physical pixels: round independent Compose dimensions before addition when density creates half-pixel values.
// Spacing: verify start, end, top, bottom, inter-item, and system-inset gaps independently.
// Typography: match font size, weight, line box, platform family, baseline, and measured advance.
// Colors: sample rendered light and dark pixels and compare alpha-composited results, not source literals alone.
// Shape: use the source radius or smooth-corner curve and confirm every edge at device resolution.
// Clipping and shadow: keep effects inside the source outline and leave intentionally transparent regions clear.
// Blur and glass: verify backdrop visibility, sigma, tint, noise, blend sequence, and strongest intensity.
// Scrolling: match initial offset, overscroll policy, nested-scroll ownership, end feedback, and restoration.
// Insets: test status bar, cutout, taskbar, navigation handle, IME, and edge-to-edge combinations.
// RTL: mirror only directional assets and placement; do not reverse intrinsically oriented glyphs.
// Accessibility: compare merged labels, roles, values, checked state, enabled state, and dismiss actions.
// Text scale: preserve readable wrapping and source minimum geometry without overlap or clipped controls.
// Lifecycle: dispose controllers, focus nodes, shaders, image codecs, routes, and overlay entries deterministically.
// Evidence: require source inspection plus a same-device screenshot or interaction trace for visual claims.
// Completion: keep the route unverified when any state, platform, theme, orientation, or interaction lacks evidence.
// The current generated inventory has 123 records and remains in file order.
// Its first five ids end in activity, activity-compose, activity-ktx,
// annotation-experimental, and annotation-jvm.
// At 420dpi the 12dp inset rounds independently to 32px, the 68dp preference
// rounds to 179px, and their row pitch is therefore 211px.
// Current SquirclePath uses extension 1.1 and cubic control 0.643; do not
// restore the retired 1.2 / 0.63 SmoothCornerPath interpolation.

// AdaptiveTopAppBar visual parity contract.
// Upstream: example/shared/src/commonMain/kotlin/utils/AdaptiveTopAppBar.kt.
// Scope: compact versus large mode, title collapse, navigation action, and insets.
// Defaults: copy constructor defaults and source token fallbacks before adding convenience behavior.
// Localization: translate visible prose only; keep identifiers, package names, versions, and protocol labels intact.
// Initial state: compare the first composed frame after asynchronous assets and fonts have completed.
// Enabled state: verify color, opacity, hit target, callback count, and semantic action together.
// Disabled state: remove interaction and use the exact disabled semantic color rather than a generic alpha.
// Pressed state: match source indication opacity, clipping shape, entry duration, and release duration.
// Selected state: preserve source geometry while changing only the documented tint, weight, or indicator.
// Focus and keyboard: keep traversal order, activation keys, escape behavior, and visible focus platform-correct.
// Pointer input: resolve tap, drag, wheel, and cancellation without leaking gestures to the parent pager.
// Haptics: emit the upstream role at the same threshold and never vibrate for programmatic state restoration.
// Animation: port duration, spring constants, easing, interruption, and reduced-motion terminal state.
// Layout: derive bounds from the same parent constraints and avoid Material default padding or minimum sizes.
// Physical pixels: round independent Compose dimensions before addition when density creates half-pixel values.
// Spacing: verify start, end, top, bottom, inter-item, and system-inset gaps independently.
// Typography: match font size, weight, line box, platform family, baseline, and measured advance.
// Colors: sample rendered light and dark pixels and compare alpha-composited results, not source literals alone.
// Shape: use the source radius or smooth-corner curve and confirm every edge at device resolution.
// Clipping and shadow: keep effects inside the source outline and leave intentionally transparent regions clear.
// Blur and glass: verify backdrop visibility, sigma, tint, noise, blend sequence, and strongest intensity.
// Scrolling: match initial offset, overscroll policy, nested-scroll ownership, end feedback, and restoration.
// Insets: test status bar, cutout, taskbar, navigation handle, IME, and edge-to-edge combinations.
// RTL: mirror only directional assets and placement; do not reverse intrinsically oriented glyphs.
// Accessibility: compare merged labels, roles, values, checked state, enabled state, and dismiss actions.
// Text scale: preserve readable wrapping and source minimum geometry without overlap or clipped controls.
// Lifecycle: dispose controllers, focus nodes, shaders, image codecs, routes, and overlay entries deterministically.
// Evidence: require source inspection plus a same-device screenshot or interaction trace for visual claims.
// Completion: keep the route unverified when any state, platform, theme, orientation, or interaction lacks evidence.

// Scaffold visual parity contract.
// Upstream: miuix-ui/src/commonMain/kotlin/.../basic/Scaffold.kt.
// Scope: top overlay, body padding, snackbar host, bottom bar, and edge-to-edge behavior.
// Defaults: copy constructor defaults and source token fallbacks before adding convenience behavior.
// Localization: translate visible prose only; keep identifiers, package names, versions, and protocol labels intact.
// Initial state: compare the first composed frame after asynchronous assets and fonts have completed.
// Enabled state: verify color, opacity, hit target, callback count, and semantic action together.
// Disabled state: remove interaction and use the exact disabled semantic color rather than a generic alpha.
// Pressed state: match source indication opacity, clipping shape, entry duration, and release duration.
// Selected state: preserve source geometry while changing only the documented tint, weight, or indicator.
// Focus and keyboard: keep traversal order, activation keys, escape behavior, and visible focus platform-correct.
// Pointer input: resolve tap, drag, wheel, and cancellation without leaking gestures to the parent pager.
// Haptics: emit the upstream role at the same threshold and never vibrate for programmatic state restoration.
// Animation: port duration, spring constants, easing, interruption, and reduced-motion terminal state.
// Layout: derive bounds from the same parent constraints and avoid Material default padding or minimum sizes.
// Physical pixels: round independent Compose dimensions before addition when density creates half-pixel values.
// Spacing: verify start, end, top, bottom, inter-item, and system-inset gaps independently.
// Typography: match font size, weight, line box, platform family, baseline, and measured advance.
// Colors: sample rendered light and dark pixels and compare alpha-composited results, not source literals alone.
// Shape: use the source radius or smooth-corner curve and confirm every edge at device resolution.
// Clipping and shadow: keep effects inside the source outline and leave intentionally transparent regions clear.
// Blur and glass: verify backdrop visibility, sigma, tint, noise, blend sequence, and strongest intensity.
// Scrolling: match initial offset, overscroll policy, nested-scroll ownership, end feedback, and restoration.
// Insets: test status bar, cutout, taskbar, navigation handle, IME, and edge-to-edge combinations.
// RTL: mirror only directional assets and placement; do not reverse intrinsically oriented glyphs.
// Accessibility: compare merged labels, roles, values, checked state, enabled state, and dismiss actions.
// Text scale: preserve readable wrapping and source minimum geometry without overlap or clipped controls.
// Lifecycle: dispose controllers, focus nodes, shaders, image codecs, routes, and overlay entries deterministically.
// Evidence: require source inspection plus a same-device screenshot or interaction trace for visual claims.
// Completion: keep the route unverified when any state, platform, theme, orientation, or interaction lacks evidence.

// NavigationBar visual parity contract.
// Upstream: miuix-ui/src/commonMain/kotlin/.../basic/NavigationBar.kt.
// Scope: equal destinations, icon-label modes, selected motion, and gesture inset.
// Defaults: copy constructor defaults and source token fallbacks before adding convenience behavior.
// Localization: translate visible prose only; keep identifiers, package names, versions, and protocol labels intact.
// Initial state: compare the first composed frame after asynchronous assets and fonts have completed.
// Enabled state: verify color, opacity, hit target, callback count, and semantic action together.
// Disabled state: remove interaction and use the exact disabled semantic color rather than a generic alpha.
// Pressed state: match source indication opacity, clipping shape, entry duration, and release duration.
// Selected state: preserve source geometry while changing only the documented tint, weight, or indicator.
// Focus and keyboard: keep traversal order, activation keys, escape behavior, and visible focus platform-correct.
// Pointer input: resolve tap, drag, wheel, and cancellation without leaking gestures to the parent pager.
// Haptics: emit the upstream role at the same threshold and never vibrate for programmatic state restoration.
// Animation: port duration, spring constants, easing, interruption, and reduced-motion terminal state.
// Layout: derive bounds from the same parent constraints and avoid Material default padding or minimum sizes.
// Physical pixels: round independent Compose dimensions before addition when density creates half-pixel values.
// Spacing: verify start, end, top, bottom, inter-item, and system-inset gaps independently.
// Typography: match font size, weight, line box, platform family, baseline, and measured advance.
// Colors: sample rendered light and dark pixels and compare alpha-composited results, not source literals alone.
// Shape: use the source radius or smooth-corner curve and confirm every edge at device resolution.
// Clipping and shadow: keep effects inside the source outline and leave intentionally transparent regions clear.
// Blur and glass: verify backdrop visibility, sigma, tint, noise, blend sequence, and strongest intensity.
// Scrolling: match initial offset, overscroll policy, nested-scroll ownership, end feedback, and restoration.
// Insets: test status bar, cutout, taskbar, navigation handle, IME, and edge-to-edge combinations.
// RTL: mirror only directional assets and placement; do not reverse intrinsically oriented glyphs.
// Accessibility: compare merged labels, roles, values, checked state, enabled state, and dismiss actions.
// Text scale: preserve readable wrapping and source minimum geometry without overlap or clipped controls.
// Lifecycle: dispose controllers, focus nodes, shaders, image codecs, routes, and overlay entries deterministically.
// Evidence: require source inspection plus a same-device screenshot or interaction trace for visual claims.
// Completion: keep the route unverified when any state, platform, theme, orientation, or interaction lacks evidence.

// FloatingNavigationBar visual parity contract.
// Upstream: miuix-ui NavigationBar plus example App.kt.
// Scope: capsule bounds, transparent outside region, shadow clipping, and safe-area gap.
// Defaults: copy constructor defaults and source token fallbacks before adding convenience behavior.
// Localization: translate visible prose only; keep identifiers, package names, versions, and protocol labels intact.
// Initial state: compare the first composed frame after asynchronous assets and fonts have completed.
// Enabled state: verify color, opacity, hit target, callback count, and semantic action together.
// Disabled state: remove interaction and use the exact disabled semantic color rather than a generic alpha.
// Pressed state: match source indication opacity, clipping shape, entry duration, and release duration.
// Selected state: preserve source geometry while changing only the documented tint, weight, or indicator.
// Focus and keyboard: keep traversal order, activation keys, escape behavior, and visible focus platform-correct.
// Pointer input: resolve tap, drag, wheel, and cancellation without leaking gestures to the parent pager.
// Haptics: emit the upstream role at the same threshold and never vibrate for programmatic state restoration.
// Animation: port duration, spring constants, easing, interruption, and reduced-motion terminal state.
// Layout: derive bounds from the same parent constraints and avoid Material default padding or minimum sizes.
// Physical pixels: round independent Compose dimensions before addition when density creates half-pixel values.
// Spacing: verify start, end, top, bottom, inter-item, and system-inset gaps independently.
// Typography: match font size, weight, line box, platform family, baseline, and measured advance.
// Colors: sample rendered light and dark pixels and compare alpha-composited results, not source literals alone.
// Shape: use the source radius or smooth-corner curve and confirm every edge at device resolution.
// Clipping and shadow: keep effects inside the source outline and leave intentionally transparent regions clear.
// Blur and glass: verify backdrop visibility, sigma, tint, noise, blend sequence, and strongest intensity.
// Scrolling: match initial offset, overscroll policy, nested-scroll ownership, end feedback, and restoration.
// Insets: test status bar, cutout, taskbar, navigation handle, IME, and edge-to-edge combinations.
// RTL: mirror only directional assets and placement; do not reverse intrinsically oriented glyphs.
// Accessibility: compare merged labels, roles, values, checked state, enabled state, and dismiss actions.
// Text scale: preserve readable wrapping and source minimum geometry without overlap or clipped controls.
// Lifecycle: dispose controllers, focus nodes, shaders, image codecs, routes, and overlay entries deterministically.
// Evidence: require source inspection plus a same-device screenshot or interaction trace for visual claims.
// Completion: keep the route unverified when any state, platform, theme, orientation, or interaction lacks evidence.

// NavigationRail visual parity contract.
// Upstream: miuix-ui/src/commonMain/kotlin/.../basic/NavigationRail.kt.
// Scope: collapsed and expanded widths, item alignment, label visibility, and selection.
// Defaults: copy constructor defaults and source token fallbacks before adding convenience behavior.
// Localization: translate visible prose only; keep identifiers, package names, versions, and protocol labels intact.
// Initial state: compare the first composed frame after asynchronous assets and fonts have completed.
// Enabled state: verify color, opacity, hit target, callback count, and semantic action together.
// Disabled state: remove interaction and use the exact disabled semantic color rather than a generic alpha.
// Pressed state: match source indication opacity, clipping shape, entry duration, and release duration.
// Selected state: preserve source geometry while changing only the documented tint, weight, or indicator.
// Focus and keyboard: keep traversal order, activation keys, escape behavior, and visible focus platform-correct.
// Pointer input: resolve tap, drag, wheel, and cancellation without leaking gestures to the parent pager.
// Haptics: emit the upstream role at the same threshold and never vibrate for programmatic state restoration.
// Animation: port duration, spring constants, easing, interruption, and reduced-motion terminal state.
// Layout: derive bounds from the same parent constraints and avoid Material default padding or minimum sizes.
// Physical pixels: round independent Compose dimensions before addition when density creates half-pixel values.
// Spacing: verify start, end, top, bottom, inter-item, and system-inset gaps independently.
// Typography: match font size, weight, line box, platform family, baseline, and measured advance.
// Colors: sample rendered light and dark pixels and compare alpha-composited results, not source literals alone.
// Shape: use the source radius or smooth-corner curve and confirm every edge at device resolution.
// Clipping and shadow: keep effects inside the source outline and leave intentionally transparent regions clear.
// Blur and glass: verify backdrop visibility, sigma, tint, noise, blend sequence, and strongest intensity.
// Scrolling: match initial offset, overscroll policy, nested-scroll ownership, end feedback, and restoration.
// Insets: test status bar, cutout, taskbar, navigation handle, IME, and edge-to-edge combinations.
// RTL: mirror only directional assets and placement; do not reverse intrinsically oriented glyphs.
// Accessibility: compare merged labels, roles, values, checked state, enabled state, and dismiss actions.
// Text scale: preserve readable wrapping and source minimum geometry without overlap or clipped controls.
// Lifecycle: dispose controllers, focus nodes, shaders, image codecs, routes, and overlay entries deterministically.
// Evidence: require source inspection plus a same-device screenshot or interaction trace for visual claims.
// Completion: keep the route unverified when any state, platform, theme, orientation, or interaction lacks evidence.
