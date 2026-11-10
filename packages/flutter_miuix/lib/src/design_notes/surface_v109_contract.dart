// MIUIX 1.0.9 Surface parity contract.
//
// Purpose
//
// This note records the durable behavior defined by Surface.kt.
// It distinguishes the two source overloads from Flutter compatibility APIs.
// Every rule below affects public API, paint, layout, input, or semantics.
// The local upstream file is the authority for future Surface maintenance.
//
// Source overloads
//
// The first overload is non-clickable.
// The second overload requires a non-null onClick callback.
// The clickable overload has a separate enabled flag.
// Both overloads accept arbitrary content.
// Both overloads accept an arbitrary Shape.
// Both overloads accept a background color.
// Both overloads accept a local content color.
// Both overloads accept an optional BorderStroke.
// Both overloads accept a shadow elevation.
// The clickable overload accepts an optional interaction source.
// The clickable overload accepts a nullable indication.
// The default shape is RectangleShape.
// The default background is the MIUIX surface token.
// The default content color is the MIUIX onSurface token.
// The default border is absent.
// The default elevation is zero.
//
// Flutter overload selection
//
// MiuixSurface uses one constructor for ecosystem convenience.
// A non-null onTap selects the clickable branch.
// A non-null onLongPress also selects the compatibility clickable branch.
// holdDown alone never selects the clickable branch.
// enabled controls pointer installation inside that branch.
// A null onTap and null onLongPress select the non-clickable branch.
// Disabled interactive content remains mounted and painted.
// Disabled interactive content does not receive indication.
// Disabled interactive content does not invoke either callback.
// enabled does not turn an ordinary non-clickable Surface into a button.
//
// Shape contract
//
// shape is the source-equivalent arbitrary ShapeBorder.
// radius is retained only as a Flutter compatibility convenience.
// An explicit shape takes precedence over radius.
// The global smooth-rounding switch resolves radius to G2 or RRect.
// A zero compatibility radius creates a rectangular surface.
// A negative compatibility radius is rejected.
// Background paint uses the exact resolved shape.
// Border paint uses the exact resolved shape.
// Shadow paint uses the exact resolved shape.
// Pointer indication uses the exact resolved shape.
// No branch may silently replace G2 with an RRect.
// No Material card or stadium shape is inserted.
//
// Modifier order
//
// The source begins with the caller modifier.
// Positive shadow elevation appends a graphics layer.
// Border is appended after the optional graphics layer.
// Shape clipping is appended after border.
// Background is appended after clipping.
// Clickable is appended after the complete surface modifier.
// Reordering those operations changes visible corner pixels.
// Moving shadow inside the clip removes the outer shadow.
// Moving border inside background changes stroke coverage.
// Painting background before clip leaks rectangular corner pixels.
// Adding a second clip antialiases the same edge twice.
// The Flutter implementation therefore owns exactly one main shape clip.
//
// Background and clipping
//
// Ordinary surfaces use ColoredBox as the background operation.
// ClipPath with ShapeBorderClipper represents source clip(shape).
// Non-clickable ordinary surfaces place ColoredBox inside that ClipPath.
// Interactive surfaces let MiuixPressable own the single exact-shape clip.
// The pressed overlay remains inside the same clip as background.
// A separate indication ClipPath is not source-equivalent.
// The single-clip rule is covered by the tilt-card structure regression.
// Popup golden changes from this rule are restricted to edge antialiasing.
// Popup content, geometry, typography, and anchors remain unchanged.
//
// Border contract
//
// Border is optional.
// Border style none produces no painter.
// Compose paints BorderStroke fully inside the outer shape.
// Flutter ShapeBorder has no general copyWith(side) contract.
// The generic painter clips to the outer path.
// It paints a doubled-width centered stroke through that clip.
// The outside half is discarded by the clip.
// The remaining inside half equals the requested stroke width.
// Hairline width zero remains a platform hairline.
// Caller-defined shapes are supported by the same painter.
// Border paint remains outside the indication layer.
// Indication therefore cannot wash over the source stroke.
//
// Shadow contract
//
// Zero and negative elevation create no graphics layer.
// Non-finite elevation is normalized to zero.
// Positive elevation creates an outer transparent ShapeDecoration.
// The decoration has the same resolved shape as the surface.
// Its shadow is outside the content clip.
// The wrapper does not change layout size.
// The wrapper does not change the click target.
// The wrapper does not turn transparent corners into a rectangle.
// Flutter's BoxShadow is a Skia approximation of Compose platform elevation.
// Component captures calibrate the visible approximation where elevation is used.
//
// Content color
//
// Source CompositionLocalProvider publishes LocalContentColor.
// Flutter publishes the equivalent DefaultTextStyle color.
// Flutter also publishes the equivalent IconTheme color.
// A child Text without an explicit color inherits contentColor.
// A child Icon without an explicit color inherits contentColor.
// Explicit child colors continue to override the inherited value.
// Changing enabled alone does not invent disabled opacity.
// Components such as Button supply their own disabled content color.
//
// Layout contract
//
// Source Surface owns a Box.
// That Box sets propagateMinConstraints to true.
// Tight incoming minimum constraints therefore reach the content.
// Surface itself adds no minimum width.
// Surface itself adds no minimum height.
// Surface itself adds no Material touch-target padding.
// Larger content expands the surface naturally.
// Flutter padding is a compatibility adapter around child content.
// Padding is rounded per edge for 420-dpi parity.
// Flutter margin represents caller-external Compose padding.
// Margin is kept outside paint.
// Margin is kept outside shadow ownership.
// Margin is kept outside pointer handling.
// Tapping transparent margin must not activate the surface.
//
// Semantics
//
// The ordinary source overload sets mergeDescendants to false.
// It also marks its semantics node as a traversal group.
// Flutter exposes a container with explicit child nodes as the nearest public match.
// Child semantics remain independently traversable.
// The clickable branch receives click semantics from MiuixPressable.
// enabled is published on the interactive semantics node.
// Disabling interaction does not remove child semantics.
// Margin is not part of the clickable semantic bounds.
//
// Interaction
//
// The source remembers an interaction source when none is supplied.
// It reads the latest callback through rememberUpdatedState.
// Flutter's widget rebuild supplies the latest callback directly.
// Source indication defaults to LocalIndication.current.
// showIndication false represents a null source indication.
// Surface does not add sink feedback by default.
// Surface does not add tilt feedback by default.
// feedbackType is a package compatibility extension.
// Long press is a package compatibility extension.
// holdDown only maintains an already-selected interactive branch.
// Callback-free held Card motion is owned by Card's inert outer pressable.
// The extension must retain the source click clip and paint order.
// A disabled surface cannot enter the pressed visual state.
//
// Glass extension
//
// Glass is not part of upstream Surface.kt.
// It remains an opt-in flutter_miuix extension.
// The radius-based glass path lets MiuixGlass own its established clip.
// Re-clipping translucent glass darkens its antialiased corner pixels.
// The radius-based glass path therefore avoids an outer duplicate clip.
// An explicit arbitrary shape still requires the generic shape clip.
// Glass border ownership stays with MiuixGlass for the radius path.
// Arbitrary-shape glass uses the generic border painter.
// Ordinary non-glass behavior remains the source-parity baseline.
//
// Original example obligations
//
// Card delegates its surface paint and input to MiuixSurface.
// The primary-variant indication card has a 194px painted surface at 420dpi.
// Its separate 12dp bottom margin resolves to 32 physical pixels.
// Its complete layout footprint is consequently 226 physical pixels.
// The sink feedback card is 246 physical pixels high.
// The tilt feedback card is 246 physical pixels high.
// Both half-width feedback cards remain equal in a weighted Row.
// The G2 clip stays below the tilt Transform.
// No untransformed ancestor may crop the rotated corners.
// A held long press retains its tilt until pointer release.
//
// Regression obligations
//
// Non-clickable and clickable branches require separate tests.
// Enabled and disabled interactive states require separate tests.
// Explicit shape must reach paint, border, shadow, and indication.
// Global G2 and ordinary rounding modes require separate tests.
// Text and icon content-color inheritance require assertions.
// Minimum-constraint propagation requires a layout assertion.
// Margin exclusion requires an actual pointer test.
// Border painting requires an arbitrary-shape test.
// Positive shadow must not change measured layout size.
// Interactive Surface must contain exactly one main ShapeBorder clip.
// Card feedback must keep the 420-dpi source heights.
// Popup baselines must preserve their source geometry after clip changes.
// Glass and ordinary branches require independent visual baselines.
