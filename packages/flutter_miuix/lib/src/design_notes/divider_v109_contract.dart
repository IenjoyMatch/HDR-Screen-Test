// MIUIX 1.0.9 Divider parity contract.
//
// Purpose
//
// This note records the complete behavior of basic/Divider.kt.
// It covers both HorizontalDivider and VerticalDivider.
// The local upstream source remains authoritative for future maintenance.
//
// Source API
//
// HorizontalDivider accepts modifier, thickness, and color.
// VerticalDivider accepts modifier, thickness, and color.
// Both thickness values default through DividerDefaults.
// Both colors default through DividerDefaults.
// Neither component accepts content.
// Neither component owns interaction state.
//
// Flutter API mapping
//
// MiuixHorizontalDivider maps the horizontal source function.
// MiuixVerticalDivider maps the vertical source function.
// MiuixDivider remains a compatibility alias for the horizontal component.
// Parent widgets represent the caller's Modifier chain.
// thickness is the source-named logical line extent.
// Vertical width remains a compatibility alias for thickness.
// Supplying both vertical aliases requires equal values.
// indent and endIndent are compatibility adapters for caller padding.
//
// Defaults object
//
// Source DividerDefaults.Thickness is 0.75dp.
// MiuixDividerDefaults.thickness exposes the same immutable value.
// Source DividerColor reads MiuixTheme.colorScheme.dividerLine.
// MiuixDividerDefaults.dividerColor resolves the same semantic token.
// The default contains no Material opacity multiplier.
// Dynamic and fixed themes resolve the active semantic table at build time.
//
// Horizontal layout
//
// Source modifier order appends fillMaxWidth then height(thickness).
// The line therefore consumes the complete available width.
// Its measured height equals the logical thickness.
// Caller constraints remain authoritative.
// The line is drawn horizontally through half the source thickness.
// Its stroke width equals thickness converted to physical pixels.
// The source installs no start or end padding by itself.
//
// Vertical layout
//
// Source modifier order appends fillMaxHeight then width(thickness).
// The line therefore consumes the complete available height.
// Its measured width equals the logical thickness.
// Caller constraints remain authoritative.
// The line is drawn vertically through half the source thickness.
// Its stroke width equals thickness converted to physical pixels.
// The source installs no top or bottom padding by itself.
//
// Fractional rasterization
//
// Default 0.75dp remains 0.75 logical pixels in layout.
// It is not rounded to one logical pixel before measurement.
// At 1x it covers one physical pixel at 75 percent alpha.
// At 2x it covers one full pixel and one half-covered pixel.
// At 2.625x it covers one full pixel and 0.96875 of the next pixel.
// At 3x it covers two full pixels and one quarter-covered pixel.
// Full pixels keep the exact semantic color.
// A fractional pixel multiplies the original alpha by its coverage.
// Antialiasing is disabled because coverage is represented explicitly.
// Horizontal and vertical directions share exactly the same painter.
//
// Hairline and zero
//
// The source documents Dp.Hairline as a one-device-pixel request.
// The current source implementation forwards its numeric thickness directly.
// This parity layer follows the actual implementation's zero measured extent.
// A zero logical extent therefore produces no drawable canvas pixels.
// Future upstream special handling must be ported if Divider.kt changes.
//
// Color
//
// dividerLine is resolved from MiuixSemanticColors.
// An explicit caller color bypasses the semantic default.
// Translucent explicit colors preserve their original alpha.
// Fractional coverage multiplies rather than replaces that alpha.
// Theme brightness changes only the default token, not geometry.
//
// Directionality
//
// The source divider itself is direction-neutral.
// Horizontal compatibility insets use EdgeInsetsDirectional.
// RTL therefore swaps only those caller-like start and end insets.
// Vertical top and bottom insets are physical and remain unchanged.
// Paint always starts at the leading canvas pixel of its resolved box.
//
// Accessibility and interaction
//
// Source Canvas adds no semantic role or label.
// The Flutter CustomPaint likewise remains silent.
// Divider has no tap, long press, focus, hover, or haptic behavior.
// Color and thickness changes do not introduce accessibility nodes.
//
// File structure
//
// All divider widgets and their painter live in parts/divider.dart.
// This removes a complete drawing family from the shared core model file.
// The painter remains private because its fractional contract is widget-owned.
// Public default values are available without exposing render internals.
//
// Current-source additions
//
// Badge and BadgedBox were added after the original 1.0.9 source snapshot.
// The authoritative current source now includes both and maps them directly.
// Their public source constructors must not be described as Material adapters.
// CircleShape expands to a stadium when badge content is wider than its height.
// At 420dpi the dot is 16px and content badges are at least 42px square.
// BadgedBox rounds its 6dp or 12dp/14dp offsets before placing the surface.
//
// Regression obligations
//
// Public thickness requires an exact 0.75 assertion.
// Public dividerColor requires a semantic-token assertion.
// Horizontal default size requires exact width and 0.75 height.
// Vertical thickness name requires exact measured width.
// Vertical width compatibility must equal the source thickness field.
// Existing density-specific painter regressions must remain unchanged.
// Navigation bar divider height must remain 0.75.
// Six existing Divider goldens must remain pixel-identical.
