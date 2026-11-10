// HyperOS 4 application-card contract.
//
// This documentation-only library covers AccountHeader, DeviceCard,
// AppListTile, NotificationCard, PermissionCard, and UpdateCard. The rules
// distinguish shared application hierarchy from component-specific content.
// Numeric defaults remain project calibration unless Xiaomi publishes them.
//
// Shared surface contract:
// - Standard constructors opt into the shared content-card glass material.
// - contentSurfaceBlur supplies the default backdrop sigma.
// - contentSurfaceTintOpacity supplies the default semantic tint strength.
// - cardCornerRadius supplies the default continuous silhouette.
// - Global enableGlass and the five-level intensity setting stay authoritative.
// - A caller may disable glass without changing new-design geometry.
// - glassBlur and glassOpacity independently override theme material channels.
// - showGlassSpecular may remove highlight while retaining blur and tint.
// - An explicit finite cornerRadius overrides the shared card role.
// - Every composite owns exactly one MiuixCard backdrop-filter layer.
// - Nested rows, buttons, progress, and icon plates do not blur again.
//
// Color hierarchy contract:
// - Card tint derives from the surrounding semantic surface role.
// - Primary color marks identity, selection, or a key affirmative action.
// - Error color is limited to permission/privacy emphasis and denial context.
// - Status color does not flood the complete application-card background.
// - Supporting text uses the secondary on-surface role in both brightnesses.
// - Caller-supplied icons keep their own artwork inside the authored slot.
// - The library does not force every third-party application icon into 2.5D.
//
// Component hierarchy contract:
// - AccountHeader keeps avatar, identity text, and trailing account action.
// - DeviceCard keeps device identity, connection status, and optional battery.
// - AppListTile keeps application identity and package metadata as one row.
// - NotificationCard keeps app provenance above title, body, and actions.
// - PermissionCard keeps explanation before deny and allow decisions.
// - UpdateCard keeps version, summary, progress, and update action in order.
// - Material migration must not reorder semantics or callback ownership.
// - Optional content remains absent rather than leaving empty visual slots.
//
// Interaction contract:
// - Account, device, and app rows forward their whole-card tap callback.
// - Nested permission buttons remain independent semantic actions.
// - Notification actions remain caller-provided widgets and callbacks.
// - Update progress is passive and does not synthesize a click action.
// - Update action remains disabled by absence rather than an empty callback.
// - Card feedback and haptics continue through the underlying public controls.
// - Mouse, keyboard, touch, and accessibility targets retain existing order.
//
// Compatibility contract:
// - Every application-card type exposes a `.source` constructor.
// - Source construction disables application-card backdrop sampling.
// - Source construction disables glass specular highlight.
// - Source construction restores the former 16dp card radius.
// - Content, callbacks, optional slots, and localization remain unchanged.
// - Existing standard constructor calls remain source compatible.
// - MiuixCard.source remains available for arbitrary legacy card content.
//
// Verification contract:
// - Theme tests inspect all six resolved blur, tint, radius, and glass states.
// - Source tests inspect all six opaque and legacy-radius states.
// - Override tests inspect solid material with custom channels and radius.
// - Light and dark goldens place complex color behind every standard surface.
// - Source goldens prove that the same backdrop is hidden by opaque cards.
// - Permission buttons and progress remain visible in both material branches.
// - Full package tests guard unrelated foundational MiuixCard consumers.
// - These checks prove package behavior, not unpublished official pixels.
library;
