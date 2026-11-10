// MIUIX v1.0.9 FloatingToolbar parity contract.
//
// Authoritative component source:
// - miuix-ui/.../basic/FloatingToolbar.kt
//
// Authoritative example integration:
// - example/shared/.../AppContent.kt
// - example/shared/.../SettingsPage.kt
//
// ---------------------------------------------------------------------------
// Public component
// ---------------------------------------------------------------------------
//
// FloatingToolbar is a surface primitive. It does not own action semantics or
// arrange its content. The public source parameters are:
// - color;
// - cornerRadius;
// - outSidePadding;
// - shadowElevation;
// - showDivider;
// - one arbitrary content slot.
//
// MiuixFloatingToolbar.child is that arbitrary source slot.
//
// children, orientation, spacing, contentPadding, outsidePadding, and glass
// remain explicit flutter_miuix compatibility or project extensions. When a
// child and children are both supplied, the source child takes precedence.
//
// ---------------------------------------------------------------------------
// Defaults
// ---------------------------------------------------------------------------
//
// FloatingToolbarDefaults publicly exposes:
// - CornerRadius = 50dp;
// - OutSidePadding = PaddingValues(horizontal 12dp, vertical 8dp);
// - defaultColor() = surfaceContainer.
//
// Flutter publishes these through MiuixFloatingToolbarDefaults.
//
// shadowElevation defaults directly to 4dp on FloatingToolbar; it is not an
// upstream FloatingToolbarDefaults member.
//
// showDivider defaults false.
//
// ---------------------------------------------------------------------------
// Modifier and paint order
// ---------------------------------------------------------------------------
//
// Source modifier order is:
// 1. caller modifier;
// 2. outside padding;
// 3. optional dividerLine background using the toolbar shape;
// 4. optional 0.75dp padding inside that divider background;
// 5. a fixed dropShadow when shadowElevation is positive;
// 6. toolbar color background;
// 7. pointer input consuming taps.
//
// The divider is therefore not an inset BoxBorder. It adds 0.75dp on every
// edge around the inner shadow/clip/background and changes measured size.
//
// Each padding edge is converted independently through Compose roundToPx.
//
// Positive shadowElevation is only a gate in the current source. Its numeric
// value does not change the projection: every positive value uses a rounded
// rectangle shadow with 10dp radius, 10 percent black, and zero offset. Zero
// and negative elevations create no shadow layer and are both accepted.
//
// The fill is a G2 continuous shape when smooth rounding is enabled and an
// ordinary rounded rectangle otherwise. The shadow remains a rounded rectangle
// in both modes because FloatingToolbar.kt passes RoundedCornerShape directly
// to dropShadow.
//
// squircleBackground is fill-only and does not clip descendants. The Flutter
// adapter must likewise leave arbitrary source child overflow un-clipped.
//
// The consumed pointer tap prevents events from reaching the page behind the
// floating surface. detectTapGestures does not add an accessibility click
// action, so the Flutter gesture adapter must be excluded from semantics.
// Semantics owned by toolbar children remain intact.
//
// No LocalContentColor override, automatic IconTheme, minimum dimensions,
// internal padding, or action spacing is provided by the source primitive.
//
// ---------------------------------------------------------------------------
// Localized example
// ---------------------------------------------------------------------------
//
// AppContent uses:
// - primary surface color;
// - 20dp radius;
// - source-default outside padding and 4dp shadow;
// - three IconButtons with explicit onPrimary icons;
// - Edit, Delete, More ordering;
// - an 8dp-padded Row or Column with 8dp action spacing;
// - default AnimatedContent when the orientation changes.
//
// Default AnimatedContent behavior is:
// - outgoing content fades out linearly over 90ms;
// - incoming content waits 90ms, then fades from zero to one and scales from
//   0.92 to 1 over 220ms;
// - size changes use a clipped medium-low spring with stiffness 400.
//
// The settings keep the upstream order:
// - Show FloatingToolbar;
// - conditional FloatingToolbar Position;
// - conditional FloatingToolbar Orientation;
// - Show FloatingActionButton.
//
// Visible settings and action descriptions are localized only. Counts,
// ordering, defaults, placement choices, and behavior remain unchanged.
