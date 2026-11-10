library flutter_miuix_visual_parity_contracts_03;

// MiuixTheme visual parity contract.
// Upstream: miuix-ui/src/commonMain/kotlin/.../theme/MiuixTheme.kt.
// Scope: light and dark tokens, typography, spacing, radius, motion, and localization.
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

// TextureBlur visual parity contract.
// Upstream: miuix-blur/src/commonMain/kotlin/.../TextureBlur.kt.
// Scope: backdrop sampling, blur radius, noise, blend order, and enable semantics.
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

// LayerBackdrop visual parity contract.
// Upstream: miuix-blur/src/commonMain/kotlin/.../LayerBackdrop.kt.
// Scope: owned texture effect, global-setting independence, clipping, and disposal.
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

// MiuixHaptics visual parity contract.
// Upstream: miuix-ui interaction sources and Android HapticFeedbackConstants.
// Scope: role mapping, edge thresholds, toggles, confirmation, and fallback.
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

// SystemInsets visual parity contract.
// Upstream: example App.kt and pageContentPadding.kt.
// Scope: status bar, navigation gesture handle, cutouts, initial padding, and scroll-behind.
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

// PullToRefresh visual parity contract.
// Upstream: miuix-ui/src/commonMain/kotlin/.../basic/PullToRefresh.kt.
// Scope: threshold, five states, indicator geometry, rotation, and release motion.
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

// IconCatalogAndSearch visual parity contract.
// Upstream: example IconPage.kt and upstream icon font metadata.
// Scope: glyph orientation, weight selection, names, filtering, and search takeover.
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
