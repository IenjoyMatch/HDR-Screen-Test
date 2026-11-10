// MIUIX 1.0.9 Surface, Card, typography, and color contract.
//
// Surface.kt defaults to RectangleShape.
// Surface.kt defaults to the semantic surface color.
// Surface.kt adds no content padding.
// Surface.kt adds no border.
// Surface.kt defaults shadowElevation to zero.
// A non-clickable Surface installs no pointer indication.
// A clickable Surface uses the ambient indication by default.
//
// Card.kt defaults its corner radius to 16dp.
// Card.kt defaults its content inset to zero.
// Card.kt uses surfaceContainer with full opacity.
// Card.kt paints no outline and no implicit shadow.
// Card.kt defaults press feedback to None.
// Card.kt defaults showIndication to false.
//
// BasicComponent.kt uses a 16dp inset on every side.
// A title uses the 17sp Medium headline1 role.
// A summary uses the 14sp body2 role.
// The Android reference line boxes are about 1.17em for this pair.
// The localized CJK glyph choice must not expand the source row geometry.
//
// TextStyles.kt uses the platform line box for ordinary roles.
// Flutter fixes that box near 1.16em to avoid Material's 1.4em merge.
// Paragraph is the exception and keeps its explicit 1.2em height.
// SmallTitle uses the 14sp Bold subtitle role with 28x8dp padding.
//
// The default light surface is exactly 0xFFF7F7F7.
// The default light surfaceContainer is exactly white.
// The default light high containers are exactly 0xFFE8E8E8.
// The default dark surface is exactly black.
// The default dark ordinary containers are exactly 0xFF242424.
// The default dark highest container is exactly 0xFF2D2D2D.
// Generated Material surface tiers must not leak into the static palette.
//
// ArrowPreference uses a 10x16 ArrowRight source vector.
// DropdownPreference uses a 10x16 ArrowUpDown source vector.
// Both action glyphs use onSurfaceVariantActions while enabled.
// Both action glyphs use disabledOnSecondaryVariant while disabled.
// Dropdown values use body2 at 14sp with ordinary weight.
