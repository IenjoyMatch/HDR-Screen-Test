// MIUIX 1.0.9 Button parity contract.
//
// Purpose
//
// This note records the durable behavior defined by Button.kt.
// It covers both Button and the TextButton convenience overload.
// The rules distinguish upstream behavior from Flutter compatibility APIs.
// Each rule affects public API, painting, measurement, input, or semantics.
//
// Source Button API
//
// The source callback is named onClick.
// The source callback is non-null even when enabled is false.
// Flutter retains nullable onPressed for ecosystem compatibility.
// A null Flutter callback is treated as unavailable interaction.
// The source enabled parameter defaults to true.
// enabled controls click installation and both disabled color fields.
// The source cornerRadius parameter defaults to 16dp.
// The source minWidth parameter defaults to 58dp.
// The source minHeight parameter defaults to 40dp.
// The source colors parameter carries four independent colors.
// The source insideMargin parameter defaults to 16dp horizontal padding.
// The same insideMargin defaults to 13dp vertical padding.
// The source accepts a caller-owned MutableInteractionSource.
// The source accepts a nullable Indication.
// The source ends with an arbitrary RowScope content slot.
// Arbitrary content is not restricted to text or icons.
//
// Flutter compatibility surface
//
// label is a convenience retained from earlier flutter_miuix releases.
// child represents the source-equivalent arbitrary content slot.
// Exactly one of label or child must be supplied.
// icon is available only beside the label convenience.
// Arbitrary child content owns its own internal arrangement.
// filled selects the upstream primary color factory.
// expand remains a Flutter-only full-width adapter.
// expand wraps the component instead of changing its source measurement.
// showIndication false represents a null upstream Indication.
// Explicit colors take precedence over the filled shortcut.
//
// Source TextButton API
//
// TextButton accepts text rather than arbitrary content.
// TextButton maps TextButtonColors into ordinary ButtonColors.
// TextButton then delegates all layout and interaction to Button.
// TextButton uses the MIUIX button text style.
// Current source accepts an optional textStyle override.
// A null textStyle resolves to MiuixTheme.textStyles.button.
// An explicit style color takes precedence over LocalContentColor.
// A style without color inherits the enabled or disabled content color.
// TextButton does not force maxLines to one or insert ellipsis.
// Its label wraps naturally when a finite parent width requires it.
// An unconstrained label retains its natural one-line width.
// Its default container is secondaryVariant.
// Its default text color is onSecondaryVariant.
// Its primary factory uses primary and onPrimary.
// The Flutter icon parameter is a compatibility extension.
// The original v1.0.9 example uses no TextButton icon.
//
// Color model
//
// ButtonColors contains enabled container color.
// ButtonColors contains disabled container color.
// ButtonColors contains enabled local content color.
// ButtonColors contains disabled local content color.
// TextButtonColors names the content pair as text colors.
// Ordinary enabled color is secondaryVariant.
// Ordinary disabled color is disabledSecondaryVariant.
// Ordinary enabled content is onSecondaryVariant.
// Ordinary disabled content is disabledOnSecondaryVariant.
// Primary enabled color is primary.
// Primary disabled color is disabledPrimaryButton.
// Primary enabled content is onPrimary.
// Primary disabled content is disabledOnPrimaryButton.
// Disabled colors are explicit tokens rather than opacity multipliers.
// Caller colors are never silently blended with Material defaults.
//
// Enabled-state behavior
//
// Source Surface receives the enabled flag.
// Enabled Surface installs click semantics and pointer handling.
// Disabled Surface does not invoke onClick.
// Disabled Surface paints disabledColor.
// Disabled Surface publishes disabledContentColor locally.
// The content tree remains mounted when disabled.
// The content layout remains unchanged when disabled.
// The smooth shape remains unchanged when disabled.
// The minimum dimensions remain unchanged when disabled.
// Disabled state does not add an opacity wrapper.
// Flutter combines enabled with non-null onPressed.
// Either false condition disables activation.
// Disabled state also suppresses pressed indication.
//
// Shape contract
//
// Button calls miuixShape with cornerRadius.
// The default continuous-corner radius is 16dp.
// The global smooth-rounding preference selects G2 or ordinary rounding.
// Background and pressed indication share the same shape.
// The shape clips the entire content and container paint.
// A custom radius affects both enabled and disabled states.
// A zero radius is valid and creates a rectangular surface.
// Negative radii are invalid.
// Button does not add a border.
// Button does not add elevation.
// Button does not add a Material stadium shape.
//
// Modifier and layout order
//
// The caller modifier is applied to Surface.
// Surface owns clickable behavior and visual clipping.
// The inner Row receives defaultMinSize.
// Padding is appended after defaultMinSize.
// The final complete Row therefore includes insideMargin.
// Row uses horizontal Arrangement.Center.
// Row uses vertical Alignment.CenterVertically.
// The content slot is invoked inside that centered Row.
// Reversing padding and minimum size changes small-button geometry.
// Moving padding outside Surface changes indication clipping.
// Moving defaultMinSize outside Surface changes semantic bounds.
// Flutter preserves the same containment order.
//
// Minimum-size behavior
//
// Fifty-eight dp is a minimum rather than a fixed width.
// Forty dp is a minimum rather than a fixed height.
// Larger arbitrary content expands the surface.
// Wider localized labels expand unless a parent supplies a tight width.
// A grid may supply equal tight widths to sibling buttons.
// A tight parent may be narrower than the natural label.
// Label convenience uses one-line ellipsis in that compatibility case.
// Independent minWidth and minHeight values are supported.
// Zero minima are valid.
// Negative minima are rejected by the Flutter constructor.
// The caller's inside padding still contributes when minima are zero.
//
// Padding and physical pixels
//
// Compose rounds each PaddingValues edge independently.
// At 420dpi, 13dp becomes 34 physical pixels.
// Both vertical edges therefore contribute 68 physical pixels.
// The captured 17sp button text placeable contributes 52 physical pixels.
// A default example button consequently measures 120 physical pixels high.
// Combining logical dimensions before rounding can incorrectly produce 121px.
// Flutter resolves directional padding before rounding each edge.
// Custom asymmetric padding retains four independent rounding operations.
// Layout density changes do not alter source logical defaults.
//
// Label compatibility content
//
// The convenience label uses the MIUIX button text size of 17sp.
// It uses regular font weight.
// It uses zero extra letter spacing.
// The label receives the resolved enabled or disabled content color.
// Its text placeable is rounded upward to enclose fractional font bounds.
// Optional compatibility icon uses a 16dp icon theme.
// Six dp separates that icon from the label.
// Those icon rules are Flutter compatibility behavior.
// Arbitrary child content receives no invented icon size or gap.
//
// Arbitrary child inheritance
//
// Source Surface publishes LocalContentColor.
// Flutter publishes the equivalent DefaultTextStyle color.
// Flutter publishes the equivalent IconTheme color.
// A child Text with an explicit color still overrides inheritance.
// A child Icon with an explicit color still overrides inheritance.
// The child may contain multiple widgets.
// The child may be taller than the default minimum.
// The child may be wider than the default minimum.
// The child is not replaced when enabled state changes.
// The child is centered as one Row content group.
//
// Indication behavior
//
// Source Button defaults to LocalIndication.current.
// The MIUIX theme supplies its ordinary pressed overlay.
// A null indication disables overlay painting.
// Button does not use sink scaling by default.
// Button does not use tilt feedback by default.
// Button does not use Material splash geometry.
// The indication is clipped to the same continuous-corner shape.
// Disabled Button never enters the indicated state.
// Flutter showIndication controls the equivalent installation.
// Existing example buttons retain indication by default.
//
// Semantics and activation
//
// The source modifier assigns Role.Button.
// Flutter publishes the button semantics flag.
// Flutter publishes the effective enabled state.
// Pointer taps invoke the latest non-null callback.
// A disabled tap has no callback effect.
// Arbitrary child semantics remain available inside the button.
// The visual surface and semantic target intentionally use different bounds.
// Compose clickable contributes a 48dp minimum interactive component target.
// That target does not increase the button's measured placeable.
// Parent layout therefore continues to own row spacing.

// Android minimum interactive target
//
// ButtonDefaults.MinHeight remains 40dp.
// LocalMinimumInteractiveComponentSize resolves to 48dp on Android.
// The clickable modifier observes that composition-local minimum.
// The minimum applies after the visible Box has been measured.
// The expansion is centered around the visible placeable.
// A 40dp-tall visual therefore receives four dp above and below.
// A 48dp-or-taller visual requires no vertical expansion.
// A 58dp-wide default button requires no horizontal expansion.
// A custom button narrower than 48dp receives horizontal expansion.
// Expansion never changes Row or Column measurement.
// Expansion never changes sibling spacing.
// Expansion never changes dialog panel height.
// Expansion never changes the continuous-corner paint path.
// Expansion never paints an invisible Material rectangle.
// Expansion is used for both pointer hit testing and semantics.
// Disabled clickable still contributes the semantic component bounds.
// Disabled clickable does not accept a pointer action.
// The explicit Button role remains present while disabled.

// Fractional-density rounding
//
// The parity device reports a density of 2.625.
// Forty-eight dp therefore resolves to exactly 126 physical pixels.
// The captured visual label button resolves to 120 physical pixels.
// The six-pixel difference is split evenly around the visual surface.
// Three physical pixels belong above the visual surface.
// Three physical pixels belong below the visual surface.
// The semantic rectangle must be 126px high on that device.
// The surface decoration must remain 120px high on that device.
// Rounding the visual height up to 48dp would be incorrect.
// Padding the surrounding dialog by three pixels would be incorrect.
// Adding a 48dp SizedBox would be incorrect.
// Applying Material tapTargetSize would alter measured layout.
// The render bridge rounds the logical 48dp target once per density.
// It preserves an already-larger visual width or height unchanged.

// Pointer routing
//
// Pointers inside the painted rectangle stay owned by MiuixPressable.
// The render bridge delegates those hit tests only to its child.
// The bridge does not add its own hit-test entry for an inside pointer.
// This prevents two TapGestureRecognizer instances entering one arena.
// It also prevents a successful inside tap from firing twice.
// It preserves MiuixPressable hover behavior on desktop.
// It preserves MiuixPressable keyboard focus behavior.
// It preserves MiuixPressable press indication timing.
// It preserves the existing golden frames for pressed buttons.
// Pointers outside paint are considered only inside the expanded rectangle.
// The render bridge owns those outside-band pointers.
// A normal RenderFlex stops hit testing at its measured 120px action row.
// The three-pixel band may therefore sit outside every ancestor hit path.
// Merely overriding the child render object's hitTest is insufficient there.
// The bridge registers one global pointer route while it is attached.
// That route observes only PointerDownEvent instances.
// It converts the global pointer position back into local button coordinates.
// It ignores every pointer inside the painted rectangle.
// It ignores every pointer outside the expanded rectangle.
// It ignores every pointer while the button is disabled.
// It joins the gesture arena only for the non-painted expansion band.
// The ordinary hitTest method returns false for that same expansion band.
// The recognizer is therefore never registered twice for one pointer.
// Detaching the render object removes the global pointer route immediately.
// Reattaching the render object installs exactly one route again.
// This preserves 48dp pointer behavior inside tightly measured dialog Rows.
// It also preserves the exact 120px action-row paint and layout height.
// A pointer outside both rectangles is rejected.
// A pointer in the expansion is rejected while disabled.
// A pointer in the expansion creates one TapGestureRecognizer sequence.
// Completed outside-band taps invoke the same callback as inside taps.
// Canceled outside-band taps never invoke the callback.
// Disposing the render object also disposes its recognizer.

// Outside-band indication
//
// Compose emits PressInteraction even when the pointer starts in expansion.
// The visible surface must therefore still show its pressed indication.
// Flutter stores only the bridge-owned outside pressed state.
// That state is forwarded through MiuixPressable holdDown.
// The hold channel uses the same ten-percent indication target.
// The original positive indication spring remains unchanged.
// The original release indication spring remains unchanged.
// Pointer down enters the held visual state.
// Pointer up exits the held visual state.
// Pointer cancellation exits the held visual state.
// Disabling during an active outside gesture clears the held state.
// An inside pointer continues to use MiuixPressable's own pressed state.
// The bridge never holds an inside pointer indication.
// showIndication false still permits outside-band activation.
// showIndication false paints no overlay for either pointer path.
// No sink scale is introduced by the bridge.
// No haptic event is invented by the bridge.

// Semantic merging
//
// The render bridge is a semantic boundary.
// It merges descendant label semantics into the button node.
// Arbitrary child labels therefore remain readable.
// The button flag is assigned by the bridge.
// The enabled flag reflects effective enabled state.
// A tap action is registered only when effective enabled is true.
// A null callback is never assigned to SemanticsConfiguration.onTap.
// Assigning null there is invalid in the pinned Flutter engine.
// A disabled button consequently has no semantic tap action.
// A disabled button still reports the Button role.
// A disabled button still reports enabled false.
// The semanticBounds getter returns the expanded rectangle.
// Semantic height therefore matches Compose at 420dpi.
// Semantic width stays visual when visual width already exceeds 48dp.
// Descendant Text continues to supply the localized spoken label.
// Descendant Icon semantics are not discarded.
// The bridge does not fabricate a tooltip or content description.

// Dialog evidence
//
// The Arrow fixture opens its Adjust Volume dialog from SliderPreference.
// The native and Flutter dialog input bounds both measure x95 to x985.
// The native and Flutter title bounds share the same vertical origin.
// The visible native Cancel button measures 120 physical pixels high.
// The visible Flutter Cancel button measures 120 physical pixels high.
// Native accessibility expands that control to 126 physical pixels.
// Flutter accessibility now expands that control to 126 physical pixels.
// The native Cancel target spans x95 to x513 in the captured tree.
// The native Confirm target spans x566 to x985 in the captured tree.
// Flutter may differ by one horizontal rounding pixel between equal columns.
// That one-pixel allocation comes from parent Row rounding.
// It does not justify changing Button's own minimum width.
// The vertical target comparison is the relevant Button contract evidence.
// The dialog panel must not grow after adding the target bridge.
// The text field bounds must not move after adding the target bridge.
// The action row baseline must not move after adding the target bridge.

// Runtime verification protocol
//
// Build the localized Flutter example in release mode.
// Install the stable base package without an applicationIdSuffix.
// Open the Home component list on the 1080 by 2400 emulator.
// Scroll to the localized Arrow section.
// Confirm the three source rows remain in their original order.
// Tap the localized Volume row to open the dialog.
// Capture both screenshot and uiautomator hierarchy.
// Compare visible button pixels independently from semantic bounds.
// Exercise the upper expansion band with an automated pointer test.
// Confirm exactly one callback is received.
// Hold the pointer long enough for the positive spring to advance.
// Confirm indication opacity becomes greater than zero.
// Release and confirm the held state clears.
// Repeat with enabled false and confirm no callback is received.
// Keep ordinary, pressed, and midpoint button goldens unchanged.
// Run the complete root test suite after render-object changes.
// Run the complete localized example suite after fixture changes.
// Run flutter analyze after all public API changes.
// Run verify_scope to retain the requested comment-density gate.

// Regression boundaries
//
// The bridge is internal and does not alter public constructor signatures.
// Existing callers continue to configure minHeight independently.
// Existing callers continue to configure minWidth independently.
// A caller choosing minHeight above 48dp gets no expansion on that axis.
// A caller choosing minWidth above 48dp gets no expansion on that axis.
// A caller choosing zero minima can still receive a 48dp target.
// Tight parent constraints still determine visible geometry.
// Loose parent constraints still permit natural label geometry.
// Expanded hit bounds may overlap a neighboring expanded target.
// Flutter hit-test order resolves overlap using paint order.
// This matches the ordinary platform rule for overlapping targets.
// No sibling is displaced to avoid an overlap.
// No clipping is added around the semantic target.
// Ancestor clipping behavior remains owned by the ancestor.
// The bridge supports both MiuixButton and MiuixTextButton.
// Both public widgets share _MiuixButtonSurface.
// Both therefore share the same Android target correction.
// IconButton retains its separate source-specific render bridge.
// Button must not reuse IconButton disabled semantic behavior.
// IconButton removes its role when its clickable modifier is absent.
// Button assigns Role.Button before clickable in the upstream chain.
// That source-order difference is intentionally preserved.
//
// Original example contract
//
// ButtonSection uses four TextButton instances.
// Two enabled buttons occupy the first equal-width row.
// Two disabled buttons occupy the second equal-width row.
// The ordinary column uses the secondaryVariant factory.
// The primary column uses textButtonColorsPrimary.
// Twelve dp separates the two columns.
// Twelve dp separates the two rows.
// Twelve dp follows the complete section.
// At 420dpi each outside and inter-item gap resolves to 32px.
// Each equal button column resolves to 492px.
// Each button height resolves to 120px.
// Clicking the enabled buttons changes only their localized label.
// Disabled buttons retain their source disabled color pairs.
//
// Regression obligations
//
// Default tonal and primary colors require separate assertions.
// Disabled container and content colors require separate assertions.
// Smooth and conventional shape modes require separate assertions.
// Arbitrary content must remain mounted and color-inherited.
// Custom corner radius must reach both paint and indication shape.
// Custom min dimensions must remain floors.
// Larger child content must not be clipped to default maxima.
// Custom insideMargin must affect complete measured size.
// showIndication false must leave click behavior available when enabled.
// enabled false must suppress both click and indication.
// Existing label goldens must remain unchanged.
// The localized example must retain its captured 420dpi geometry.

// Current TextButton style extension
// ----------------------------------
// The authoritative current Button.kt revision is the main-source snapshot.
// Its TextButton overload now accepts an optional TextStyle parameter.
// The parameter is named textStyle rather than style.
// It appears after insideMargin in the source parameter list.
// It appears before interactionSource in the source parameter list.
// Its default value is null.
// A null value selects MiuixTheme.textStyles.button.
// A non-null value is forwarded to the MIUIX Text component unchanged.
// TextButton still maps TextButtonColors before creating its label.
// TextButton still delegates its surface to Button.
// The new parameter does not create another painted surface.
// The new parameter does not create another pointer recognizer.
// The new parameter does not alter the Button minimum dimensions.
// The new parameter does not alter the Button corner radius.
// The new parameter does not alter the Button inside margin.
// The new parameter does not alter enabled-state selection.
// The new parameter does not alter the interaction source.
// The new parameter does not alter the indication object.
// The new parameter does not alter the Button role semantics.
// Flutter exposes the parameter directly on MiuixTextButton.
// MiuixButton keeps its arbitrary child contract unchanged.
// MiuixButton label remains a compatibility convenience.

// Text style precedence
// ---------------------
// Source Text resolves an explicit color parameter first.
// TextButton supplies no explicit Text color parameter.
// Source Text therefore checks textStyle.color next.
// LocalContentColor is used only when textStyle has no color.
// Button publishes the enabled content color through LocalContentColor.
// Button publishes the disabled content color through LocalContentColor.
// Flutter copies an explicit textStyle color to the rendered Text.
// Flutter injects the active button content color only when style color is null.
// An explicit red style remains red on an enabled ordinary button.
// An explicit red style remains red on an enabled primary button.
// An explicit red style remains red when the ButtonColors text field differs.
// A colorless style inherits ordinary onSecondaryVariant when enabled.
// A colorless style inherits disabledOnSecondaryVariant when disabled.
// A colorless primary style inherits onPrimary when enabled.
// A colorless primary style inherits disabledOnPrimaryButton when disabled.
// Font size is independent from the resolved color.
// Font weight is independent from the resolved color.
// Font style is independent from the resolved color.
// Letter spacing is independent from the resolved color.
// Line height is independent from the resolved color.
// Text decoration is retained when callers include it in textStyle.
// Font family is retained when callers include it in textStyle.
// Locale fallback remains owned by Flutter's paragraph engine.
// The compatibility leading icon continues to use the button content color.

// Default typography
// ------------------
// The source default button text size is 17sp.
// The source default button text weight is regular.
// The source default button text has no added letter spacing.
// The source default line-height factor is 1.16 in this package theme.
// Text scaling applies before physical-pixel line-box rounding.
// Android density conversion applies after text scaling.
// At 420dpi the density factor is 2.625.
// A 17sp line scaled by 1.16 has an authored height of 19.72dp.
// The corresponding Android paragraph placeable is 52 physical pixels.
// Flutter RenderParagraph otherwise reports a 20dp logical line.
// Twenty logical dp would become 52.5 physical pixels at this density.
// That half-pixel error expands the complete button from 120px to 120.5px.
// The package must not update the expected native measurement to 120.5px.
// The package must preserve the independently rounded 52px text placeable.
// Both 13dp vertical padding edges round independently to 34px.
// The complete default visible button is therefore 34 + 52 + 34 pixels.
// The resulting visible height is exactly 120 physical pixels.
// Android minimum-interactive expansion remains exactly 126 physical pixels.
// The visual 120px surface and 126px semantic target are separate evidence.
// Default Button and TextButton retain the same source typography role.

// Natural wrapping
// ----------------
// Source TextButton does not pass maxLines to Text.
// Source Text therefore retains its effectively unlimited line count.
// Source TextButton does not pass TextOverflow.Ellipsis.
// Source Text therefore retains clip overflow by default.
// Source TextButton does not disable soft wrapping.
// A finite parent width may therefore create multiple label lines.
// An unconstrained parent retains the label's natural one-line width.
// The 58dp minimum width is a floor rather than a wrapping boundary.
// A tighter parent may override that natural minimum through constraints.
// Inside padding is removed before the label receives its maximum width.
// Each line uses the same declared button text role.
// Compose rounds the complete multi-line paragraph to physical pixels.
// The Flutter bridge derives line count with the same text and style.
// The bridge uses the finite maximum width supplied after inside padding.
// The bridge uses infinite width only when the parent is genuinely unbounded.
// The bridge never inserts a manual newline into the caller's string.
// The bridge never truncates the caller's string to make geometry pass.
// The bridge never scales the font down to avoid wrapping.
// The bridge never changes the caller's letter spacing.
// The bridge never changes the caller's text direction.
// Default line-box height is multiplied by the measured line count.
// The multiplied authored height is rounded once in physical pixels.
// A two-line default label uses ceil(19.72 * 2 * density) pixels.
// A three-line default label uses ceil(19.72 * 3 * density) pixels.
// Custom textStyle uses Flutter's natural explicit-style paragraph height.
// The custom path does not force the default 1.16 factor onto the caller.
// A custom explicit height remains the caller's requested multiplier.
// A custom unspecified height retains platform-natural font metrics.
// The compatibility icon path remains natural-width because it is not source API.

// Physical line-box render bridge
// -------------------------------
// _MiuixButtonTextLineBox is internal implementation detail.
// It is installed only for a default-style source TextButton label.
// It wraps a real Flutter Text widget rather than replacing it.
// The child Text remains discoverable by widget and semantics tests.
// The child Text remains responsible for glyph shaping.
// The child Text remains responsible for fallback font selection.
// The child Text remains responsible for bidirectional text shaping.
// The child Text remains responsible for locale-sensitive glyph selection.
// The proxy uses a matching TextPainter only for measurement.
// The measurement painter receives the identical plain string.
// The measurement painter receives the identical resolved TextStyle.
// The measurement painter receives the active TextDirection.
// The measurement painter receives the active TextScaler.
// The measurement painter receives the available finite width.
// TextPainter line metrics determine the number of visual lines.
// The line count has a minimum of one for empty strings.
// Authored line height uses the scaled 17sp role and theme multiplier.
// Authored paragraph height multiplies that line height by line count.
// Physical paragraph height uses ceil after the complete multiplication.
// The final physical value converts back to logical layout units once.
// The proxy constrains its width with the actual child width.
// The proxy constrains its height with the corrected source paragraph height.
// The child is centered inside the corrected layout rectangle.
// A small negative half-pixel paint inset is allowed at fractional density.
// That inset reproduces the former one-line calibrated SizedBox behavior.
// The proxy adds no clip around the Text child.
// The enclosing Button squircle remains the visual clip owner.
// The proxy adds no opacity or color layer.
// The proxy adds no compositing layer by itself.
// The proxy adds no pointer recognizer.
// The proxy adds no semantics boundary.
// Child semantics flow through the shifted render object unchanged.
// Hit testing applies the same child paint offset.
// Paint transforms expose the same offset to accessibility geometry.
// Baseline queries include the child vertical offset.
// The proxy has no public constructor or exported type.

// Intrinsic measurement
// ---------------------
// Dialog layouts query action-button intrinsic dimensions.
// Wide dialog landscape mode uses IntrinsicHeight around its two columns.
// A LayoutBuilder inside Button cannot answer those intrinsic queries.
// The rejected first implementation therefore broke wide-dialog layout.
// _MiuixButtonTextLineBox implements dry layout directly.
// Dry width comes from a matching TextPainter layout.
// Dry height comes from the same physical line-box calculation.
// Minimum intrinsic width comes from TextPainter.minIntrinsicWidth.
// Maximum intrinsic width comes from TextPainter.maxIntrinsicWidth.
// Minimum intrinsic height uses the supplied finite width.
// Maximum intrinsic height uses the supplied finite width.
// The intrinsic path must not mutate the live child render tree.
// The intrinsic path must not schedule a post-frame correction.
// The intrinsic path must not depend on a GlobalKey measurement.
// The intrinsic path must not introduce a one-frame dialog jump.
// Button's enclosing Align supports intrinsic measurement.
// Align passes a finite loose width to ordinary TextButton labels.
// Align shrinks to natural content under loose outer constraints.
// Align fills a tight equal-column constraint without changing the label.
// Align centers the one logical Row content group like source Arrangement.Center.
// MiuixButton arbitrary content uses the same one-group centering rule.
// The outer ConstrainedBox still applies minWidth and minHeight floors.
// The outer Padding still rounds all four edges independently.
// No intrinsic workaround is permitted to reorder padding and minimum size.
// No intrinsic workaround is permitted to replace the source Row with Material Button.

// Semantics and input invariants
// ------------------------------
// TextButton continues to expose Role.Button through the surface.
// Enabled TextButton continues to expose a tap action.
// Disabled TextButton continues to expose disabled state without tap.
// Wrapped label text remains merged into the Button semantic node.
// The full label remains the accessible name after visual wrapping.
// No newline is inserted into the semantic label by the layout bridge.
// The corrected paragraph box does not reduce the 48dp Android target.
// The corrected paragraph box does not expand sibling layout for one line.
// The outside target bridge still owns the non-painted expansion band.
// Pointer-down indication still begins inside the painted surface.
// Pointer-down indication still begins inside the expanded outside band.
// Pointer-up still invokes the callback exactly once.
// Pointer cancellation still clears the held indication.
// Disabled labels still paint with disabledTextColor when style color is absent.
// Explicit style color remains visible even when the button is disabled.
// Keyboard Enter activation remains owned by MiuixPressable.
// Keyboard Space activation remains owned by MiuixPressable.
// Hover and focus indication channels remain unchanged.
// Text wrapping must never hand horizontal gestures to the root page pager.
// TextButton itself requests no haptic feedback.

// Verification matrix
// -------------------
// A focused test supplies font size, height, weight, spacing, and explicit color.
// That test verifies every style field reaches the rendered Text.
// A focused test omits color and verifies active TextButtonColors inheritance.
// A focused test constrains custom styled text and verifies natural wrapping.
// A focused test constrains default styled text and verifies multiple lines.
// The default-wrap test derives expected height from source physical pixels.
// The default-wrap test verifies independently rounded vertical padding.
// The one-line 420dpi test retains the exact 120px visible height.
// The Android semantic test retains the exact 126px target height.
// Tooltip action tests retain their exact 84px source action height.
// Window dialog tests retain their exact panel top and bottom bounds.
// Wide dialog landscape tests retain successful intrinsic recomposition.
// Button six-state goldens remain unchanged for short default labels.
// The complete library suite must pass after every bridge change.
// The complete example suite must pass after every bridge change.
// Static analysis must report no issue after every public API change.
// Current-source mapping count must remain complete.
// Public-name verification count must remain complete.
// Hand-maintained comment ratio must remain at least fifty percent.
// Native and Flutter default Button surfaces must both be 492 by 126px.
// Enabled and disabled source rows must retain the same two-column allocation.
// Android Release logs must contain no strict Flutter or platform error.
// Runtime evidence belongs under artifacts/parity/text_button_current_2026-08-17.
// API tests prove the new custom style path not shown by the upstream sample.
// Runtime sample comparison proves the unchanged default source path.
// Neither evidence alone is sufficient for the complete contract.

// Maintenance boundaries
// ----------------------
// Recheck Button.kt whenever the upstream textStyle default changes.
// Recheck Text.kt whenever source color precedence changes.
// Recheck theme typography whenever button font size or line height changes.
// Recheck Android density behavior when Flutter paragraph rounding changes.
// Remove the render bridge only after runtime evidence proves it unnecessary.
// Do not replace the bridge with a fixed one-line SizedBox.
// Do not restore maxLines one on the source TextButton path.
// Do not add ellipsis to the source TextButton path.
// Do not merge caller textStyle with an invented Material label style.
// Do not let a colorless style fall back to Material onSurface.
// Do not let explicit style color be overwritten by ButtonColors.
// Do not move textStyle onto MiuixButton's arbitrary child API.
// Do not treat the compatibility icon as an upstream TextButton parameter.
// Do not add LayoutBuilder beneath an intrinsic dialog action.
// Do not calculate line count from string length or whitespace count.
// Do not calculate physical height before applying TextScaler.
// Do not round each logical padding pair as one combined value.
// Do not change existing equal-column button allocation.
// Do not change public Button defaults while repairing TextButton typography.
// Keep the package-wide parity goal active beyond this component correction.

// Button color value and factory contract
// ---------------------------------------
// Upstream declares ButtonColors as an immutable Kotlin data class.
// Flutter therefore compares ButtonColors by all four stored channels.
// Equal ButtonColors values must produce equal hash codes.
// copyWith without replacements must remain value-equal to its receiver.
// copyWith color replaces only the enabled container channel.
// copyWith disabledColor replaces only the disabled container channel.
// copyWith contentColor replaces only the enabled content channel.
// copyWith disabledContentColor replaces only the disabled content channel.
// Color values remain exact ARGB values and are never opacity-normalized.
// Theme changes create new resolved values rather than mutating old palettes.
// Upstream declares TextButtonColors as a separate immutable data class.
// Flutter therefore compares TextButtonColors by all four stored channels.
// Equal TextButtonColors values must produce equal hash codes.
// Its copyWith without replacements must remain value-equal to its receiver.
// Its color field remains the enabled container channel.
// Its disabledColor field remains the disabled container channel.
// Its textColor field remains the enabled label channel.
// Its disabledTextColor field remains the disabled label channel.
// ButtonColors and TextButtonColors never compare equal across their types.
// The ordinary factory resolves secondaryVariant for its container.
// The ordinary factory resolves disabledSecondaryVariant when disabled.
// The ordinary factory resolves onSecondaryVariant for enabled content.
// The ordinary factory resolves disabledOnSecondaryVariant for disabled content.
// The primary factory resolves primary for its container.
// The primary factory resolves disabledPrimaryButton when disabled.
// The primary factory resolves onPrimary for enabled content.
// The primary factory resolves disabledOnPrimaryButton for disabled content.
// Every optional factory argument overrides only its corresponding channel.
// A custom enabled color never changes the three omitted theme channels.
// A custom disabled color never changes the enabled container channel.
// A custom content color never changes either container channel.
// A custom disabled content color never changes the enabled content channel.
// buttonColorsPrimary is public under the same name as the source factory.
// It delegates to the same palette construction used by ordinary buttons.
// Its primary selection is explicit and cannot be disabled by a caller flag.
// textButtonColorsPrimary is also public under its source factory name.
// It converts the primary button content pair into the text pair exactly once.
// Its textColor override is forwarded as the enabled content override.
// Its disabledTextColor override is forwarded as disabled content override.
// The legacy boolean primary parameter remains available for compatibility.
// The source-named factories avoid requiring callers to know that adapter.
// Dialog confirm actions may call textButtonColorsPrimary directly.
// Ordinary dialog actions continue to call textButtonColors directly.
// The MiuixButton filled convenience continues to resolve primary colors.
// The unfilled convenience continues to resolve ordinary tonal colors.
// Disabled painting selects both disabled channels from one immutable palette.
// Enabled painting selects both enabled channels from one immutable palette.
// Widget rebuilding never mutates a caller-owned color value.
// Equality supports stable theme and configuration comparison in state owners.
// copyWith supports changing one semantic role without reconstructing four fields.
// Public-name verification includes both immutable color model types.
// Public-name verification includes MiuixButtonDefaults.
// Current-source mapping includes ButtonColors and TextButtonColors separately.
// Current-source mapping includes ButtonDefaults independently from Button.
// Defaults mappings are evidence of API presence, not visual parity by themselves.
// Widget tests still verify the resolved channels against semantic theme tokens.
// Source constructors still verify the audited 58 by 40 minimum geometry.
// HyperOS constructors still use the separately documented 48dp visual minimum.
// Adding value semantics must not change layout, indication, or hit testing.
// Adding source-named factories must not change existing boolean-factory results.
// No Material ButtonColors object is exposed through this source adapter.
// No WidgetStateProperty is required to read a fixed source palette.
// The four source fields remain final and publicly readable.
// Future upstream fields require a new source audit before expanding this model.
// Future semantic token changes require both ordinary and primary regression tests.
