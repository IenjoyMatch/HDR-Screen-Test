// Global liquid-glass intensity contract.
//
// Scope
// -----
// MiuixGlassIntensity is a theme token shared by supported glass surfaces.
// The token has exactly five ordered values.
// The localized example exposes those values as five user-facing levels.
// Level three is the default.
// Level three preserves every component's source blur value.
// Level three preserves every component's source surface opacity.
// Existing applications therefore retain their previous default rendering.
// Lower levels reduce blur and increase tint opacity.
// Higher levels increase blur and reduce tint opacity.
// Blur values must remain non-negative.
// Surface opacity values must remain in the inclusive zero-to-one range.
// Component source values remain inputs rather than duplicated global values.
// A 25dp component blur and a 4dp component blur retain their relationship.
// A 60 percent navigation tint and a 40 percent navigation tint remain distinct.
// The intensity changes strength without erasing component identity.
//
// Theme behavior
// --------------
// MiuixThemeData owns the selected intensity.
// copyWith must preserve the value when no replacement is supplied.
// copyWith must accept every public intensity value.
// Theme interpolation changes intensity at the midpoint.
// enableGlass remains the authoritative global on/off switch.
// Disabling glass removes BackdropFilter work.
// Disabling glass also restores an opaque component surface.
// The selected intensity remains stored while glass is disabled.
// Re-enabling glass restores the stored intensity.
// Standard intensity has a blur scale of one.
// Standard intensity has an opacity scale of one.
// Subtle intensity uses half of source blur.
// Intense intensity uses one and three-quarter source blur.
// Intense intensity uses 45 percent of source tint opacity.
// Public resolver methods make these rules directly testable.
//
// Component adoption
// ------------------
// MiuixGlass resolves both blur and opacity from the active theme.
// MiuixLayerBackdrop inherits the behavior through MiuixGlass.
// Glass MiuixSurface instances inherit the behavior through MiuixGlass.
// FloatingToolbar inherits the behavior when its glass flag is true.
// FloatingNavigationBar inherits the behavior when its glass flag is true.
// IosLiquidGlassNavigationBar resolves its custom 8dp blur directly.
// IosLiquidGlassNavigationBar resolves its 40 percent panel tint directly.
// TopAppBar inherits the behavior when its glass flag is true.
// BottomSheet uses MiuixGlass with a top-only 28dp radius.
// About-page cards inherit the behavior through MiuixGlass.
// Opaque components do not change merely because intensity changes.
// Regular NavigationBar remains opaque by design.
// Regular settings cards remain opaque by design.
// Components can retain an explicit color while adopting glass strength.
// MiuixGlass color therefore accepts a semantic component tint.
// Non-uniform glass shapes use the public borderRadius override.
//
// Example behavior
// ----------------
// The glass-level dropdown is visible only while blur is enabled.
// The first localized level is 1 档 · 轻微.
// The second localized level is 2 档 · 较轻.
// The third localized level is 3 档 · 标准.
// The fourth localized level is 4 档 · 较强.
// The fifth localized level is 5 档 · 最强.
// Selecting a level rebuilds the root MiuixTheme.
// Root floating surfaces update without losing navigation selection.
// Pushed routes inherit the same value through the MaterialApp builder.
// Bottom sheets inherit the same value through the root Navigator overlay.
// The setting is application-wide rather than local to the settings row.
// Tests verify all five levels exist.
// Tests verify blur increases monotonically.
// Tests verify surface opacity decreases monotonically.
// Tests verify the standard values are identity transformations.
// Tests verify the strongest iOS navigation panel reaches 18 percent tint.
// Golden tests retain visual evidence for the integrated application shell.
