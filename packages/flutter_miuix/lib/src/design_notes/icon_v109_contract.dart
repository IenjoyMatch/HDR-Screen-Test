// MIUIX 1.0.9 Icon parity contract.
//
// Purpose
//
// This note records every public behavior defined by basic/Icon.kt.
// Icon is a drawing primitive rather than the MIUIX icon asset catalogue.
// The local upstream source remains authoritative for future maintenance.
//
// Source overloads
//
// The first overload accepts ImageVector artwork.
// The second overload accepts ImageBitmap artwork.
// The third overload accepts Painter artwork and a static Color tint.
// The fourth overload accepts Painter artwork and a reactive ColorProducer.
// Every overload accepts a nullable localized contentDescription.
// Every overload accepts the caller's Modifier chain.
// Static tint defaults to LocalContentColor.current.
// Color.Unspecified disables the static color filter.
// A null ColorProducer disables the reactive color filter.
//
// Flutter overload mapping
//
// MiuixIcon(IconData) represents vector-like font artwork.
// MiuixIcon.image(ImageProvider) represents ImageBitmap artwork.
// MiuixIcon.painter(CustomPainter) represents Painter artwork.
// tint is the source-compatible static color name.
// color remains a compatibility alias for existing package users.
// tintListenable represents the observable ColorProducer overload.
// applyTint false represents the static Color.Unspecified behavior.
// contentDescription is the source-compatible accessibility name.
// semanticLabel remains a compatibility alias.
// Parent widgets represent the source Modifier chain.
//
// Tint precedence
//
// An active tintListenable has highest precedence.
// Its non-null value installs a source-in color filter.
// Its null value removes the color filter.
// Static tint has second precedence.
// The compatibility color value has third precedence.
// The nearest IconTheme color represents LocalContentColor.
// Theme onSurface is the final defensive fallback.
// applyTint false bypasses every static and inherited tint.
// A reactive producer remains authoritative over applyTint.
// Bitmap and painter artwork retain original colors when tint is absent.
//
// Sizing
//
// Source Painter intrinsic dimensions are retained when finite.
// Source ImageBitmap uses BitmapPainter and therefore keeps bitmap dimensions.
// A painter with unspecified or infinite intrinsic dimensions receives 24dp.
// Flutter ImageProvider keeps natural dimensions when size is omitted.
// Flutter CustomPainter cannot expose intrinsic dimensions.
// Painter intrinsicSize therefore records a finite source-equivalent extent.
// A painter without that adapter receives the 24dp fallback.
// An explicit size creates a square requested extent for every artwork kind.
// IconData has no intrinsic canvas size and therefore receives 24dp by default.
// The caller's constraints can still tighten or enlarge the final render box.
//
// Scaling and painting
//
// Source ContentScale.Fit preserves aspect ratio inside the icon bounds.
// Flutter BoxFit.contain is the direct bitmap mapping.
// The painter constructor exposes fit for source metadata compatibility.
// CustomPainter commands receive their resolved canvas extent directly.
// Static bitmap tint uses BlendMode.srcIn.
// Static painter tint uses ColorFilter.mode with BlendMode.srcIn.
// No background, clipping, padding, or elevation is added by Icon.
// Icon itself provides no pressed state or interaction.
//
// Reactive tint
//
// Source drawWithCache records painter content into a graphics layer.
// ColorProducer is evaluated when the cached layer is drawn.
// Flutter ValueListenableBuilder rebuilds only the icon paint subtree.
// Changing the produced color updates the color filter without replacing Icon.
// Emitting null removes ColorFiltered from painter artwork.
// Producer values do not alter layout or accessibility semantics.
//
// Accessibility
//
// A non-null contentDescription publishes the localized label.
// The same node receives the image role.
// Child artwork semantics are excluded to prevent duplicate announcements.
// A null description adds no image semantics wrapper.
// Decorative icons therefore remain silent to accessibility services.
// Tint, artwork family, and reactive updates do not change the description.
//
// Compatibility
//
// The unnamed positional IconData constructor is unchanged.
// Existing size, color, and semanticLabel arguments remain accepted.
// Supplying both tint and color is rejected in debug builds.
// Supplying both description aliases is rejected in debug builds.
// Negative explicit sizes are rejected in debug builds.
// The extra constructors add source capabilities without changing old paint.
//
// Regression obligations
//
// Default IconData sizing requires a 24dp assertion.
// Inherited IconTheme tint requires an explicit precedence assertion.
// A localized content description requires image-role semantics.
// Bitmap artwork must keep null width and height without an explicit size.
// applyTint false must leave bitmap color unset.
// Painter artwork without intrinsicSize must occupy 24dp square.
// A reactive color must install a ColorFiltered node.
// A reactive null must remove that node on the next frame.
// Existing six-state Icon goldens must remain pixel-identical.
