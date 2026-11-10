// HyperOS 4 navigation-drawer project contract.
//
// This contract covers MiuixNavigationDrawer and its AdaptiveScaffold use.
// Xiaomi does not publish the dp values used by this project translation.
// The defaults below are project calibrations shared with NavigationRail.
//
// ---------------------------------------------------------------------------
// Public presentation boundary
// ---------------------------------------------------------------------------
//
// The ordinary constructor is the HyperOS 4 presentation.
// The source constructor is the former edge-attached presentation.
// Both constructors consume the same MiuixNavigationItem destination model.
// Both constructors preserve typed integer destination callbacks.
// Both constructors preserve header and footer arbitrary widget slots.
// Both constructors preserve disabled destination behavior.
// Both constructors preserve optional SafeArea consumption.
// The ordinary visual is allowed to change under the workspace migration rule.
// The source visual must remain stable for explicit legacy migration.
// AdaptiveScaffold uses the ordinary constructor on expanded windows.
// AdaptiveScaffold never substitutes example-only drawer implementation code.
//
// ---------------------------------------------------------------------------
// Ordinary floating material
// ---------------------------------------------------------------------------
//
// The ordinary drawer enables glass by default.
// Its blur reads hyperOs4.navigationRailBlur.
// Its tint reads hyperOs4.navigationRailTintOpacity.
// Its corner reads hyperOs4.navigationRailCornerRadius.
// Its outer clearance reads hyperOs4.navigationRailOuterMargin.
// These shared tokens keep rail and drawer in one wide-window material family.
// The default shared corner is a 32dp project calibration.
// The default shared clearance is a 12dp project calibration.
// The default shared blur is a 24-sigma project calibration.
// The default shared tint is a 0.56 standard-level project calibration.
// None of those values are described as unpublished official Xiaomi tokens.
// The glass filter samples only behind the clipped drawer silhouette.
// The surrounding outer clearance contains no drawer fill.
// Page content or its background remains visible through that clearance.
// The complete window is never covered by an invisible drawer rectangle.
// The specular edge belongs only to the clipped glass panel.
// A caller may disable the specular edge independently from glass sampling.
// A caller may override blur independently from tint and geometry.
// A caller may override tint independently from blur and geometry.
// A caller may override radius independently from material strength.
// A caller may override outer clearance independently from panel width.
// Invalid negative or non-finite geometry overrides use the theme fallback.
// Zero radius and zero outer clearance remain valid explicit choices.
//
// ---------------------------------------------------------------------------
// Solid HyperOS 4 alternative
// ---------------------------------------------------------------------------
//
// glass false disables backdrop filtering for performance or accessibility.
// glass false does not imply source mode.
// A solid ordinary drawer retains the same outer clearance by default.
// A solid ordinary drawer retains the same continuous corner by default.
// A solid ordinary drawer uses the same semantic background role.
// A solid ordinary drawer uses MiuixSurface rather than a raw ColoredBox.
// MiuixSurface retains the project's optional G2 continuous shape policy.
// The solid panel exposes no MiuixGlass descendant.
// The solid panel preserves every destination and interaction callback.
// This branch keeps hierarchy stable while allowing blur to be switched off.
//
// ---------------------------------------------------------------------------
// Floating and edge-attached layout
// ---------------------------------------------------------------------------
//
// floating true enables the resolved outer clearance.
// floating false resolves the outer clearance to zero.
// floating false does not forcibly disable glass.
// floating false resolves the default outer corner to zero.
// An explicit nonzero corner can still customize an edge-attached panel.
// The ordinary default sets floating true.
// AdaptiveScaffold.floatingDrawer forwards directly to this policy.
// AdaptiveScaffold defaults floatingDrawer to true.
// Apps can opt out for modal or migration-specific edge attachment.
// The source constructor always sets floating false.
// The source constructor always sets outer clearance to zero.
// The source constructor always sets outer corner to zero.
// The source constructor always disables glass and its specular edge.
//
// ---------------------------------------------------------------------------
// Width and parent-constraint behavior
// ---------------------------------------------------------------------------
//
// width describes the painted panel width before outer clearance.
// The default painted width remains 300dp.
// Finite width values are clamped from 240dp through 420dp.
// A non-finite width resolves to the 300dp project default.
// A floating default therefore occupies 324dp including both 12dp margins.
// A source default occupies exactly 300dp including its zero margins.
// A tight Scaffold body must not stretch the painted panel to window width.
// A direction-aware outer Row releases the drawer horizontal child constraint.
// That Row retains the parent's bounded usable height.
// Its cross-axis stretch keeps the panel aligned to full available height.
// In LTR the drawer remains at the physical left through logical start order.
// In RTL the Row's destination order follows the ambient text direction.
// Remaining horizontal space stays visually transparent to the page layer.
// An outer adaptive Row measures the drawer at its natural complete width.
// Main content then receives the remaining width through Expanded.
// The drawer does not use a Stack that could cover main-content pointer input.
//
// ---------------------------------------------------------------------------
// Destination rows
// ---------------------------------------------------------------------------
//
// Every destination row spans the same available drawer content width.
// Localized label length never changes sibling allocation.
// The list retains 12dp horizontal and 8dp vertical project padding.
// Rows retain 3dp vertical separation on each side.
// Row content retains its existing directional 16/14dp horizontal padding.
// Row content retains 12dp vertical padding.
// Selected row corners read navigationRailItemCornerRadius.
// Selection interpolation reads navigationRailMotion.
// Reduced motion replaces an in-flight selection with its exact endpoint.
// Selected background interpolates from transparent to primaryContainer.
// Selected icon color interpolates to onPrimaryContainer.
// Selected label color interpolates to onPrimaryContainer.
// Selected label weight interpolates from 500 to 600.
// Selected icon replacement retains one stable centered coordinate.
// An optional badge stays attached to the icon stack.
// Badge geometry does not change the label's equal row allocation.
// A disabled destination installs no pointer callback.
// A disabled destination remains visible and semantically disabled.
// Enabled selection emits the confirm haptic once.
// closeOnSelection requests route dismissal only after enabled selection.
//
// ---------------------------------------------------------------------------
// Insets, header, and footer
// ---------------------------------------------------------------------------
//
// Header content remains before the scrollable destination list.
// Footer content remains after the scrollable destination list.
// Header and footer stay inside the clipped material panel.
// The destination list alone expands and scrolls between those slots.
// A footer divider uses the semantic dividerLine role.
// defaultWindowInsetsPadding true wraps panel content in SafeArea.
// The SafeArea excludes redundant left and right inset consumption.
// Top and bottom system regions remain protected by default.
// Outer visual clearance is independent from platform safe-area padding.
// Disabling SafeArea does not remove the floating visual clearance.
// Disabling floating does not remove the configured SafeArea behavior.
//
// ---------------------------------------------------------------------------
// AdaptiveScaffold integration
// ---------------------------------------------------------------------------
//
// Compact automatic mode continues to use floating bottom navigation.
// Medium automatic mode continues to use NavigationRail.
// Expanded automatic mode continues to use NavigationDrawer.
// The project breakpoints remain 600dp and 1200dp by default.
// Those breakpoints remain caller-overridable and are not official claims.
// glassNavigation forwards to the expanded drawer glass property.
// glassNavigation false creates a solid floating drawer by default.
// floatingDrawer forwards independently to the expanded drawer floating flag.
// Drawer header and footer slots forward unchanged.
// Selected index and destination callback forward unchanged.
// The adaptive body remains Expanded beside rail or drawer navigation.
// Bottom and rail modes do not instantiate a hidden drawer.
// Resizing across modes rebuilds one presentation from the same item model.
// onResolvedModeChanged continues to publish the resolved current mode.
//
// ---------------------------------------------------------------------------
// Required evidence
// ---------------------------------------------------------------------------
//
// A 1280dp adaptive window must resolve MiuixNavigationDrawer.
// Its default panel must be MiuixGlass with blur 24 and opacity 0.56.
// Its default panel radius must be 32dp.
// Its outer rectangle must exceed the panel by 12dp on each edge.
// A direct tight 500dp Scaffold must paint only a 300dp-wide panel.
// Its floating outer rectangle must measure 324dp wide.
// Its 700dp-high outer rectangle must leave a 676dp-high panel.
// glass false must resolve MiuixSurface with the same 32dp radius.
// glass false must preserve the same 300 by 676dp panel geometry.
// source must resolve MiuixSurface with radius zero.
// source must measure exactly 300 by 700dp under the same window.
// Theme overrides must reach blur, tint, corner, margin, item corner, and motion.
// Disabled semantics and enabled selection tests must continue to pass.
// Four visual baselines must cover light/dark and ordinary/source modes.
// Ordinary baselines must visibly expose content around all panel edges.
// Source baselines must retain the full-height attached rectangular surface.
// Full static analysis and the complete Flutter suite must pass.
// The package scope and comment gates must pass.
// A complete Android, Windows, and two-library Release cycle is mandatory.
