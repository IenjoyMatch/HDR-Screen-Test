// MIUIX 1.0.9 IconButton parity contract.
//
// Purpose
//
// This note records the behavior verified against IconButton.kt.
// It separates durable source facts from Flutter implementation details.
// It also explains why the component cannot be replaced by IconButton.
// Every rule below has visible, interactive, or accessibility consequences.
//
// Public source API
//
// The source callback is named onClick and is always non-null.
// Flutter keeps nullable onPressed for ecosystem compatibility.
// A null Flutter callback is treated as an unavailable clickable modifier.
// The source exposes an independent enabled Boolean.
// enabled defaults to true.
// The source exposes an externally controlled holdDownState Boolean.
// holdDownState defaults to false.
// The source exposes backgroundColor.
// backgroundColor defaults to Color.Unspecified.
// The source exposes cornerRadius.
// cornerRadius defaults to 40dp.
// The source exposes minHeight.
// minHeight defaults to 40dp.
// The source exposes minWidth.
// minWidth defaults to 40dp.
// The source ends with an arbitrary composable content slot.
// The content is normally an Icon but is not restricted to icons.
//
// Compatibility extensions
//
// The Flutter icon parameter is a convenience alias for simple callers.
// The Flutter child parameter represents the real arbitrary source slot.
// Supplying both would make content precedence ambiguous.
// Supplying neither would create a meaningless empty action.
// Exactly one content entry is therefore required.
// The selected parameter predates the source-parity rewrite.
// selected remains available to avoid breaking package consumers.
// selected is not presented as a source IconButton capability.
// An explicit backgroundColor overrides the selected compatibility fill.
// tooltip is another package extension.
// tooltip remains useful for general Flutter applications.
// Original-example routes avoid tooltip unless demonstrating tooltips.
// Source accessibility names normally belong to Icon content descriptions.
//
// Modifier order
//
// The source starts with the caller's modifier.
// defaultMinSize is applied after that modifier.
// The smooth MIUIX shape clip follows minimum sizing.
// The background is drawn after the clip.
// The clickable modifier is appended last when enabled.
// Reordering those operations changes clipping or measurement.
// A background outside the clip would paint square corners.
// A fixed size would reject larger custom content.
// A clickable wrapper with padding would change toolbar spacing.
// Flutter therefore keeps constraints inside the clipped visual surface.
// Flutter keeps the touch-target expansion outside visual measurement.
//
// Minimum-size behavior
//
// Forty dp is a minimum, not an unconditional square.
// A normal 24dp icon yields a 40dp by 40dp placeable.
// Wider custom content may make the placeable wider.
// Taller custom content may make the placeable taller.
// The requested minimum width may differ from the minimum height.
// Zero is a valid caller-provided minimum.
// Negative minima are rejected by the Flutter constructor.
// Compose converts dp layout constraints to integer physical pixels.
// Flutter rounds each minimum dimension independently at current density.
// Independent rounding matters at Android density 2.625.
// The rounded logical value maps back to an integer physical extent.
// A parent may still impose a larger tight constraint.
// The content remains centered in the resulting visual surface.
//
// Shape behavior
//
// The source calls miuixShape with cornerRadius.
// Smooth rounding therefore follows the global MIUIX shape switch.
// Enabled smooth rounding uses the continuous-corner outline.
// Disabled smooth rounding uses a conventional rounded rectangle.
// Both branches use the same caller-provided radius.
// The source default radius equals the default minimum dimensions.
// That combination looks circular for a square icon button.
// Rectangular custom content becomes a capsule-like smooth shape.
// The implementation must not force CircleBorder.
// The implementation must not force a Material stadium.
// Background and pressed indication share the same outline.
// Clip geometry remains unchanged when interaction is disabled.
//
// Background behavior
//
// Color.Unspecified produces no visible source fill.
// Flutter represents that result with transparent painting.
// The default button is therefore visually transparent.
// A caller-provided fill is painted without extra elevation.
// The source does not add a border.
// The source does not add a shadow.
// The source does not substitute a disabled background.
// The source does not reduce disabled background alpha.
// The selected compatibility fill uses primaryContainer.
// Explicit backgroundColor always wins over that compatibility fill.
// The fill covers the complete measured visual placeable.
// The fill never covers the expanded Android touch-only region.
//
// Content color behavior
//
// Source content inherits LocalContentColor unless it specifies a tint.
// Most original-example icons specify onBackground explicitly.
// Floating-toolbar icons specify onPrimary explicitly.
// BackNavigationIcon specifies onBackground explicitly.
// The IconButton itself does not invent a disabled tint.
// Disabling the action leaves its content paint unchanged.
// Flutter contentColor supplies an explicit local foreground override.
// A null Flutter contentColor installs no local override of its own.
// The nearest parent IconTheme and DefaultTextStyle therefore survive.
// A controller-backed MiuixTheme supplies the source onBackground local.
// An explicitly colored Icon continues to override IconTheme.
// Text content receives the same local foreground through DefaultTextStyle.
// Arbitrary child widgets may still own their individual colors.
// No opacity wrapper is applied merely because interaction is disabled.
//
// Enabled behavior
//
// The source remembers a clickable modifier only when enabled is true.
// When enabled is false it appends an empty Modifier.
// There is no disabled clickable role in that branch.
// There is no pressed indication observer in that branch.
// The background remains present in that branch.
// The content remains present in that branch.
// The shape clip remains present in that branch.
// The minimum layout size remains present in that branch.
// Flutter combines enabled with a non-null onPressed callback.
// Either false condition removes pointer activation.
// An in-flight pointer state is cleared when interaction becomes unavailable.
// An externally held state paints nothing while interaction is unavailable.
//
// Interaction source
//
// The source remembers one MutableInteractionSource per composition.
// Ordinary pointer presses emit Press and Release interactions.
// Pointer cancellation emits the corresponding cancel transition.
// The interaction source is shared with hold-down events.
// Recomposition does not create a new active pointer lifecycle.
// Flutter owns one TapGestureRecognizer per render target.
// Callback updates do not replace its measured child.
// Recognizer callbacks are synchronized when widget properties change.
// The recognizer is disposed with its render object.
// Only PointerDownEvent joins the tap gesture arena.
// Completion invokes the latest onPressed callback.
// Cancellation clears the visual pointer state.
//
// Hold-down behavior
//
// A true holdDownState emits HoldDownInteraction.HoldDown upstream.
// The source remembers the emitted hold interaction object.
// A false transition emits Release for that same object.
// A repeated true recomposition does not stack new held interactions.
// Pointer press and hold-down are independently observable states.
// Each state contributes ten percent only while hold-down is not replacing it.
// Hold-down alone therefore paints 0.10 alpha.
// Pointer press alone therefore paints 0.10 alpha.
// Both states together remain at 0.10 alpha because hold-down has precedence.
// Releasing the pointer while held remains at 0.10 alpha.
// Releasing hold-down while pressed returns to 0.10 alpha.
// Releasing both states returns to zero.
// Disabled interaction suppresses both contributions.
//
// Pressed indication
//
// LocalIndication resolves to the MIUIX indication implementation.
// Its overlay color is onBackground.
// Its press contribution is ten percent.
// Its hold-down contribution is ten percent.
// Press and hold enter use the response .2, damping 1 Folme spring.
// Press and hold exit use the response .35, damping .95 Folme spring.
// Hover and focus enter use the response .6, damping 1 Folme spring.
// Hover and focus exit use the response .2, damping .96 Folme spring.
// IconButton does not use sink scaling.
// IconButton does not use tilt feedback.
// IconButton does not translate downward.
// IconButton does not use Material splash geometry.
// The indication is clipped to the same smooth visual shape.
// The indication is painted over both background and content.
// The indication does not expand into the touch-only margin.
//
// Android interactive target
//
// Compose reports a 48dp minimum interactive component target on Android.
// That target is larger than the default 40dp visual placeable.
// Four dp is added on each side of a default button.
// The visual layout remains exactly 40dp.
// Neighboring toolbar centers therefore remain 40dp apart.
// Adjacent 48dp action targets overlap by eight dp.
// Turning the widget into a 48dp SizedBox would be incorrect.
// Adding four dp of ordinary padding would be incorrect.
// Both alternatives would move titles and popup anchors.
// Flutter expands hit testing in the render layer instead.
// Flutter also expands semantic bounds in the render layer.
// The expanded rectangle stays centered on the visual placeable.
// Larger custom content naturally becomes its own minimum target.
//
// Top app bar placement
//
// Original compact navigation content measures as a 40dp placeable.
// Its visible start edge is 16dp from the window edge.
// Its Android semantic target begins four dp earlier.
// At 420dpi the 48dp semantic width becomes 126 physical pixels.
// The original NavigateTestPage leading node spans x 32 through x 158.
// The original visible 40dp center remains at x 95 physical pixels.
// Flutter must preserve that center while expanding the node bounds.
// Leading width reservation remains 40dp plus navigation padding.
// The title must not reserve 48dp for the leading placeable.
// Action centers also remain spaced by 40dp.
// Popup position providers use the visual anchor center.
// Semantic expansion must not shift the context-menu anchor.
//
// Parent hit-testing constraints
//
// A child can only receive expanded hits that reach it through ancestors.
// Top app bar Stack bounds contain the complete 48dp target.
// Floating toolbar padding contains the complete 48dp target.
// Bottom-sheet title rows contain the complete 48dp target.
// A tightly clipped 40dp parent can intentionally limit outer hit slop.
// The render target does not paint outside its visual child.
// The render target adds itself directly to the hit-test result.
// Its decorative Icon child does not need pointer handlers.
// Tests should tap the MiuixIconButton rather than the Icon descendant.
// Hit-test ownership therefore matches the source clickable modifier.
// Overlapping sibling targets follow normal paint-order precedence.
// The outer component remains keyboard and semantics activatable.
//
// Accessibility behavior
//
// Enabled source clickable semantics use Role.Button.
// Enabled Flutter semantics expose the button flag.
// Enabled Flutter semantics expose a tap action.
// Enabled content descriptions merge into that one clickable node.
// The semantic rectangle uses the expanded Android target.
// The optional tooltip string can serve as a compatibility label.
// Source-style Icon semantic labels remain valid child descriptions.
// Disabled source code removes the clickable modifier completely.
// Disabled Flutter code therefore removes the tap action.
// Disabled Flutter code does not advertise a false button activation.
// Child content semantics can remain discoverable.
// The default source-compatible state exposes no selected metadata.
// selected true exposes the package compatibility selected flag.
// Layout bounds and semantic bounds are intentionally different.
// Widget tests verify both rectangles independently.
//
// Original-example usage
//
// Floating toolbar contains Edit, Delete, and More actions.
// Those icons explicitly use onPrimary.
// The original sample does not wrap them in tooltips.
// Flutter removes non-source tooltip arguments from that toolbar.
// About uses BackNavigationIcon without a tooltip wrapper.
// Licenses uses BackNavigationIcon without a tooltip wrapper.
// Tooltip demonstrations still use MiuixTooltip explicitly.
// Bottom-sheet actions use Close and Ok icons.
// Navigation-test leading content uses the Back icon.
// Navigation-test action holds its indication while popup dismissal animates.
// Localized Chinese labels belong to visible content, not invented chrome.
// Icon orientation remains controlled by the icon catalog and RTL wrapper.
//
// Verification requirements
//
// Unit tests assert the default visual size is 40dp.
// Unit tests assert the semantic size is 48dp.
// Unit tests tap inside the four-dp expansion.
// Unit tests assert default transparent background.
// Unit tests assert caller background survives disabled state.
// Unit tests assert caller foreground survives disabled state.
// Unit tests assert custom radius reaches the smooth shape.
// Unit tests assert arbitrary text content can expand the placeable.
// Unit tests assert hold-down supersedes the overlapping pointer alpha.
// Unit tests assert current press, hover, focus, and hold spring behavior.
// Unit tests assert disabled controls expose no tap action.
// Android UIAutomator data verifies real physical semantic bounds.
//
// Fractional-density target rounding
//
// Android exports semantics as integer physical-pixel rectangles.
// Compose and Flutter begin from logical rectangles before that export.
// Their treatment of a fractional start coordinate is not identical.
// Compose advances the start coordinate to the following physical pixel.
// Flutter normally expands the start coordinate toward the preceding pixel.
// Both systems advance a fractional end coordinate.
// A symmetric logical offset would therefore move an already-correct end.
// A trailing target may need a start-only physical-pixel correction.
// That correction belongs to the semantic and hit rectangle only.
// It must not translate the visible glyph.
// It must not translate the button background.
// It must not translate the pressed indication.
// It must not translate the popup's visual anchor.
// It must not alter title-space reservation.
// The correction is zero when the source start lies on an integer pixel.
// At 420dpi the trailing one-action start lies at a half pixel.
// Flutter would otherwise export x=922 while Compose exports x=923.
// The common end already exports as x=1049 in both systems.
// Moving only the start inward reproduces `[923,1049]`.
// The resulting raw logical semantics width is slightly below 48dp.
// Android's integer export still reports the source 126-pixel node width.
// The pointer target uses the same corrected rectangle as semantics.
// The 40dp visual content remains centered at the source coordinate.
// Leading and trailing targets need separate horizontal treatment.
// The tested leading start already rounds to the source x=32.
// It therefore receives no matching horizontal inset.
// Vertical fractional origins differ for both leading and actions.
// They receive one physical pixel of inherited downward correction.
// At 420dpi this changes y=68 to the source y=69.
// Their bottom edge changes from y=194 to the source y=195.
// At integral target origins no vertical correction is applied.
// Per-density calculation avoids a hard-coded logical-pixel shift.
// Per-axis calculation avoids disturbing already-correct coordinates.
// TopAppBar owns these corrections because it knows global placement.
// Standalone IconButton retains an exact centered 48dp target.
// Tests cover standalone, leading, and trailing target branches.
// Device UI trees remain the final authority for exported integer bounds.
//
// Regression boundaries
//
// Do not restore Material IconButton defaults.
// Do not add 48dp layout padding to satisfy accessibility.
// Do not dim disabled content without an upstream source change.
// Do not suppress a caller background when disabled.
// Do not convert the minimum dimensions into a fixed square.
// Do not replace the smooth shape with CircleBorder.
// Do not add sink or tilt motion.
// Do not paint the pressed overlay beyond the visual clip.
// Do not keep non-source tooltip wrappers in original-example routes.
// Do not use a glyph finder as the expected pointer owner in tests.
// Do not move popup anchors to semantic target edges.
// Recheck every rule if the tracked MIUIX source version changes.
