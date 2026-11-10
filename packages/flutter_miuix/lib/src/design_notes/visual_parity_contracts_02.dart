library flutter_miuix_visual_parity_contracts_02;

// DropdownMenu visual parity contract.
// Upstream: miuix-ui/src/commonMain/kotlin/.../basic/DropdownMenu.kt.
// Scope: anchor-relative origin, viewport clamping, row metrics, and dismissal.
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

// ListPopup visual parity contract.
// Upstream: miuix-ui/src/commonMain/kotlin/.../basic/ListPopup.kt.
// Scope: popup width, corner radius, item pitch, check state, and cascades.
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

// BottomSheet visual parity contract.
// Upstream: miuix-ui/src/commonMain/kotlin/.../overlay/BottomSheet.kt.
// Scope: sheet width, top radii, drag behavior, system inset, and scrim.
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

// Dialog visual parity contract.
// Upstream: miuix-ui/src/commonMain/kotlin/.../overlay/Dialog.kt.
// Scope: maximum width, internal margins, action placement, and back dismissal.
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

// Snackbar visual parity contract.
// Upstream: miuix-ui/src/commonMain/kotlin/.../basic/Snackbar.kt.
// Scope: navigation avoidance, minimum height, timeout, action, and queue ownership.
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

// ColorPicker visual parity contract.
// Upstream: miuix-ui/src/commonMain/kotlin/.../color/ColorPicker.kt.
// Scope: HSV state, channel tracks, alpha checkerboard, value formatting, and drag capture.
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

// Slider visual parity contract.
// Upstream: miuix-ui/src/commonMain/kotlin/.../basic/Slider.kt.
// Scope: track geometry, thumb ratio, key points, horizontal drag priority, and haptics.
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
