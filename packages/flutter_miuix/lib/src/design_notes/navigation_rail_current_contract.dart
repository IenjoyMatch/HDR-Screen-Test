// Current MIUIX NavigationRail parity contract.
//
// Authority
// The authoritative checkout is C:/Code/miuix-src-current.
// The component source is miuix-ui/basic/NavigationRail.kt.
// The example integration source is example/shared/AppContent.kt.
// Adaptive breakpoints come from example/shared/utils/AdaptiveUtils.kt.
// The Flutter public API lives in widgets/parts/navigation_rail.dart.
// The stateful layout lives in widgets/parts/navigation_rail_expandable.dart.
// The localized host integration lives in example/lib/main.dart.
// This contract describes the current source rather than the older static rail.
// Any upstream change requires checking all sections below again.
// Logical Compose dp maps to Flutter logical pixels before density rounding.
// Physical comparisons must use the same device pixel ratio on both apps.
//
// Public component contract
// NavigationRail accepts an optional state object.
// A null state selects the classic non-expandable presentation.
// A non-null state selects the current expandable presentation.
// State nullness must stay stable across ordinary window-size changes.
// Width changes use state.expand and state.collapse instead of swapping trees.
// The rail accepts an optional arbitrary header slot.
// The rail accepts an arbitrary destination content list.
// The rail exposes a surface background color.
// The rail exposes the vertical-divider switch.
// The rail exposes its window-inset behavior switch.
// The rail exposes a collapsed minimum width.
// The rail exposes an expanded width.
// Expanded width is coerced to at least collapsed width.
// The rail exposes localized expand accessibility text.
// The rail exposes localized collapse accessibility text.
// Flutter retains its item-list convenience constructor.
// Flutter retains the source arbitrary-child constructor.
// Flutter retains old static display modes only for state-null compatibility.
// Flutter retains fixed extended mode only for existing package consumers.
// A supplied source state takes precedence over compatibility display modes.
// A supplied source state takes precedence over fixed extended mode.
//
// State holder contract
// NavigationRailValue has exactly collapsed and expanded values.
// NavigationRailState starts collapsed unless an expanded value is supplied.
// currentValue exposes the stable target rather than the animation fraction.
// isExpanded is true only for the expanded target.
// expand changes the target to expanded.
// collapse changes the target to collapsed.
// toggle switches between the two stable targets.
// Repeating expand while expanded is a no-op.
// Repeating collapse while collapsed is a no-op.
// A no-op does not restart the expansion spring.
// A real target change notifies attached rails exactly once.
// The state can be shared with application breakpoint logic.
// The state must be disposed by the owning Flutter State object.
// The animation controller belongs to the rendered rail, not the state.
// Replacing the state removes the listener from the previous object.
// Removing a state returns the rail to compact progress immediately.
// Interrupted reversals begin from the currently rendered fraction.
// Interrupted reversals must never jump to an endpoint first.
// Only the newest spring run may snap to its final target.
//
// Expansion spring contract
// The source calls folmeSpring with damping 1.
// The source calls folmeSpring with response 0.35 seconds.
// Damping ratio 1 is critically damped.
// Critical damping prevents width overshoot.
// Angular frequency is 2*pi divided by response.
// Spring stiffness is angular frequency squared for unit mass.
// Spring damping is twice angular frequency for unit mass.
// Flutter uses SpringDescription with mass 1.
// Flutter uses the exact derived stiffness rather than a named approximation.
// Flutter uses ratio 1 rather than a hand-tuned damping constant.
// The visibility distance threshold is 0.001.
// The visibility velocity threshold is 0.001.
// The controller is unbounded so the physical simulation owns its range.
// Painted and measured progress is clamped to zero through one.
// Completion publishes the exact stable endpoint.
// The endpoint snap occurs only after the simulation enters tolerance.
// Width and every item consume the same progress animation instance.
// No independent item duration is allowed.
// No cubic AnimatedContainer is allowed for the source state branch.
// No fixed 180ms compatibility duration is allowed for expansion.
// Tests verify stiffness, damping, an intermediate frame, and both endpoints.
//
// Rail width contract
// Collapsed width defaults to 80dp.
// Expanded width defaults to 240dp.
// State-null compact width remains 80dp.
// Legacy fixed extended width remains 240dp.
// Stateful width linearly interpolates on the shared spring fraction.
// The interpolated logical width is rounded to a physical pixel.
// Rounding happens once after interpolation.
// A 0.75dp divider is a sibling after the rail column.
// The divider is not painted inside the 80dp or 240dp width.
// Total default collapsed occupancy is therefore 80.75dp at 1x density.
// Total default expanded occupancy is therefore 240.75dp at 1x density.
// The surface background extends behind the whole rail and its start inset.
// The divider stays between the rail and application content in LTR.
// The divider stays between the rail and application content in RTL.
// Directional Row placement mirrors Compose placeRelative behavior.
// The pager begins immediately after the divider.
// The example must not insert a centered desktop max-width gutter.
// The example must not replace the animated rail with a second widget.
//
// Inset contract
// The rail surface paints before any inset padding.
// The logical-start display cutout shifts rail content.
// The logical-start navigation bar shifts rail content.
// The top status bar shifts the scrollable column content.
// The bottom navigation bar shifts the scrollable column content.
// Top and bottom system insets do not shorten the divider.
// Top and bottom system insets do not expose the window background.
// The divider continues from the layout top to the layout bottom.
// The column continues from the layout top to the layout bottom.
// Content vertical padding is added inside system insets.
// Default top content padding is status inset plus 24dp.
// Default bottom content padding is navigation inset plus 24dp.
// Disabling default insets removes all system inset contributions.
// Disabling default insets preserves ordinary 24dp vertical content padding.
// The scrollable column includes the built-in toggle and header.
// A tall destination list scrolls without moving the sibling divider.
// The rail background remains opaque surface by default.
// The floating bottom navigation inset rules do not apply to this component.
//
// Built-in toggle contract
// The toggle exists only when a state is supplied.
// The toggle precedes an application header.
// The toggle uses the current MIUIX Sidebar glyph.
// The toggle icon is 28dp square.
// The toggle visual target is 56dp square at default dimensions.
// The 56dp target equals icon size plus two 14dp content insets.
// The collapsed toggle is horizontally centered in the collapsed rail.
// The expanded toggle uses a 12dp logical-start margin.
// At default dimensions both endpoint x positions equal 12dp.
// Custom widths still interpolate the two endpoint x positions.
// Toggle position uses the same rail expansion fraction.
// Toggle placement is logical-start aware in RTL.
// Toggle tint uses onSurfaceContainer.
// Collapsed state announces the localized expand description.
// Expanded state announces the localized collapse description.
// Activating the toggle calls state.toggle.
// A 24dp spacer follows the built-in toggle.
// A second 24dp spacer follows a non-null application header.
// The built-in toggle does not replace the optional application header.
//
// Destination endpoint contract
// Every stateful destination keeps its label present at both endpoints.
// Every stateful destination keeps its icon present at both endpoints.
// Collapsed labels sit below their icons.
// Expanded labels sit after their icons.
// Collapsed label size is 12sp.
// Expanded label size is 16sp.
// Label size interpolates on the shared spring fraction.
// Labels use medium font weight at both endpoints.
// Labels use onSurfaceContainer tint.
// Icons use onSurfaceContainer tint.
// Icons remain 28dp square at every fraction.
// Disabled destinations reject pointer input.
// Disabled destinations retain the ordinary source tint.
// Labels stay on one line in the stateful branch.
// Expanded long labels ellipsize instead of hard clipping.
// Collapsed labels can use the complete rail width.
// Expanded labels use the remaining pill content width.
// The label maximum width interpolates with the rail state.
// Badge content is a separate public NavigationRailItem slot.
// The 28dp icon is measured independently from its badge.
// Numeric badges retain their own 16dp minimum instead of stretching to 28dp.
// Badges use BadgedBox offsets and may paint beyond the icon anchor.
//
// Collapsed destination geometry
// Each destination begins with 12dp top item padding.
// The collapsed indicator adds 4dp above the icon.
// The collapsed indicator adds 4dp below the icon.
// A 4dp gap separates the indicator region and label.
// Each destination ends with 12dp bottom item padding.
// Collapsed icon x centers inside the 80dp rail.
// A 28dp icon therefore starts at x 26dp.
// Collapsed indicator horizontal content inset is 14dp per side.
// A 28dp icon therefore produces a 56dp collapsed indicator width.
// The default collapsed indicator starts at x 12dp.
// Collapsed indicator height is 28dp plus two 4dp pads.
// Default collapsed indicator height is therefore 36dp.
// The collapsed label centers under the icon.
// Label intrinsic width affects only its centered x coordinate.
// Text height participates in collapsed destination height.
// Compose and Flutter font fixtures must match for pixel comparisons.
//
// Expanded destination geometry
// Expanded destination height uses 14dp vertical padding per side.
// With a 28dp icon the default expanded height is 56dp.
// The expanded indicator starts 12dp from each rail edge.
// At 240dp width the expanded indicator is 216dp wide.
// Expanded indicator height equals the 56dp destination height.
// The icon starts after 12dp margin and 14dp content inset.
// The default expanded icon therefore starts at x 26dp.
// The icon baseline coincides with the default collapsed x baseline.
// The expanded label begins 16dp after the icon.
// The expanded label start is therefore x 70dp by default.
// A trailing 14dp content inset is reserved for the label.
// The indicator uses a 16dp MIUIX squircle radius.
// The indicator uses surfaceContainerHigh when selected.
// An unselected resting indicator is transparent.
// Pointer indication is clipped to the indicator shape.
// The icon remains vertically centered in the expanded pill.
// The label remains vertically centered in the expanded pill.
//
// Continuous morph contract
// Destination height interpolates between measured endpoint heights.
// Icon x interpolates between collapsed and expanded positions.
// Icon y interpolates between collapsed and expanded positions.
// Indicator x interpolates between collapsed and expanded positions.
// Indicator y interpolates between collapsed and expanded positions.
// Indicator width interpolates between collapsed and expanded widths.
// Indicator height interpolates between collapsed and expanded heights.
// Label x interpolates between centered-below and after-icon positions.
// Label y interpolates between below-icon and vertically-centered positions.
// Label font size interpolates from 12sp to 16sp.
// Coordinates remain directional and never mirror physical icon artwork.
// Geometry reads one progress value per frame.
// Width and item layout therefore cannot drift onto different frames.
// The item stack clips painting to its animated measured height.
// Pointer hit testing follows the animated item bounds.
// A selected indicator remains centered on the icon during the morph.
// Default collapsed and expanded icon x values coincide intentionally.
// Custom collapsed widths may cause visible horizontal icon motion.
// Physical golden tests must capture at a deterministic spring endpoint.
//
// Semantics and interaction contract
// Stateful destinations expose a selected tab-like button semantic.
// The label names the destination exactly once.
// The icon is decorative when the adjacent label is present.
// Disabled state is reflected in semantics.
// A completed enabled tap invokes the destination callback.
// Pointer down activates the indicator-local pressed channel.
// Pointer up clears the pressed channel.
// Pointer cancellation clears the pressed channel.
// Press feedback must not scale the complete destination.
// Press feedback must not move the icon or label.
// Press feedback remains within the squircle indicator.
// The selected indicator keeps its surfaceContainerHigh base during press.
// Neither current source branch inherits the old unselected 0.4 icon alpha.
// The classic state-null source branch uses one medium tint for every item.
// Its rectangular indication enters with response 0.2, damping ratio 1.0.
// It exits with response 0.35, damping ratio 0.95, and peaks at alpha 0.10.
// Classic source destinations expose button, selected, and enabled semantics.
// Compatibility display modes may retain their historical alpha and weight.
// Compatibility behavior must not leak into either current source branch.
//
// Localized example contract
// The example creates one NavigationRailState in initState.
// The example disposes that state with its other controllers.
// The rail is visible only in the split-pane layout.
// shouldShowSplitPane keeps its existing 600 and 840dp logic.
// shouldExpandNavigationRail switches at width 1200dp.
// The first layout initializes the state at the current breakpoint.
// A later breakpoint change calls expand or collapse after the frame.
// Manual toggle state persists while the breakpoint result is unchanged.
// Crossing below and above 1200dp reruns automatic expansion.
// The example supplies Chinese toggle descriptions.
// The example removes the obsolete navigationRailMode setting field.
// No settings row is invented for a field absent from current AppState.
// The example keeps five localized destinations.
// Rail destination selection drives the same root PageController.
// Page selection retains the original distance-aware animation duration.
// The rail remains application chrome outside the right content pane.
// Right-pane content begins immediately after the divider.
// The bottom NavigationBar remains absent in split-pane mode.
// The rail remains absent in compact bottom-navigation mode.
// Tests cover 1199dp and 1200dp endpoint behavior.
// Tests cover manual toggle persistence at a stable breakpoint.
//
// Regression evidence
// Component tests verify all new default constants.
// Component tests verify the exact derived spring description.
// Component tests verify the collapsed 80.75dp total width.
// Component tests verify an intermediate animated width.
// Component tests verify the expanded 240.75dp total width.
// Component tests verify 12sp and 16sp label endpoints.
// Component tests verify the collapsed 56x36 indicator.
// Component tests verify the expanded 216x56 indicator.
// Component tests verify the indicator uses MiuixSquircleBorder.
// Component tests verify the built-in toggle returns to collapsed.
// Existing classic rail tests remain unchanged except current inset geometry.
// Example tests verify the split-pane thresholds remain intact.
// Example tests verify the 1200dp automatic expansion threshold.
// Example tests verify a manual collapse remains stable at 1200dp.
// Scope comparison maps NavigationRailState and NavigationRailValue.
// Scope comparison maps rememberNavigationRailState to the Flutter constructor.
// Static analysis must remain clean after every component change.
// Full library tests and full example tests are the required final gates.
//
// Density and rounding contract
// Compose rounds the animated rail width during layout.
// Flutter must round that width at the current device pixel ratio.
// Flutter must not round the spring fraction itself.
// Flutter must not round endpoint constants before interpolation.
// A 2.625 Android density can expose otherwise hidden half-pixel drift.
// Indicator geometry remains in logical space until Flutter paints it.
// Text measurement uses the active localized font family.
// Text measurement uses the active text direction.
// Label intrinsic width is recomputed as its font size changes.
// Expanded label maximum width may become zero in a narrow custom rail.
// A zero label maximum must not produce a negative constraint.
// A custom expanded width narrower than minWidth is coerced upward.
// A non-finite minWidth falls back to the source 80dp default.
// A non-finite expandedWidth falls back to the source 240dp default.
// Indicator width is clamped non-negative before placement.
// Indicator height is clamped non-negative before placement.
// Label start is clamped non-negative during custom-width morphs.
// The physical divider delegate retains its own density rounding rules.
// Divider rounding is independent of animated column-width rounding.
// Tests at 1x make endpoint arithmetic readable but do not replace device QA.
//
// Compatibility isolation contract
// State-null iconAndText remains available to existing Flutter applications.
// State-null iconOnly remains available to existing Flutter applications.
// State-null textOnly remains available to existing Flutter applications.
// State-null iconWithSelectedLabel remains available to existing applications.
// Compatibility mode size changes keep the stiffness-400 content-size spring.
// The current stateful branch never reads compatibility displayMode.
// The current stateful branch never reads compatibility extended styling.
// The fixed extended branch keeps its old selected container.
// The fixed extended branch keeps its old 240dp width.
// The fixed extended branch does not synthesize the source toggle.
// Arbitrary non-item children remain legal inside the source constructor.
// Arbitrary children receive the expansion scope but may ignore it safely.
// A classic rail never allocates the 56dp toggle slot.
// A classic rail never allocates the following 24dp toggle spacer.
// Existing selected-index clamping remains intact for the convenience form.
// Existing disabled callbacks remain intact for the convenience form.
// Existing header spacing remains intact in both source and compatibility forms.
// Public names retain the Miuix prefix required by the package convention.
// The old internal navigationRailMode example field is not a public API loss.
//
// Prohibited substitutions
// Material NavigationRail must not replace this component.
// Material extended NavigationRail must not replace the stateful morph.
// AnimatedContainer must not own the 80dp to 240dp width transition.
// AnimatedSize must not own the destination endpoint transition.
// A fade-only label transition is not equivalent to the source layout morph.
// A separate icon animation timeline is not equivalent to the shared spring.
// A rectangular selected background is not equivalent to the squircle pill.
// A fixed 28dp rounded rectangle is not equivalent to the 16dp squircle.
// A 240dp static rail at every wide width is not source adaptive behavior.
// Auto-expanding at the split-pane threshold is not the 1200dp source rule.
// Re-expanding on every build would incorrectly defeat a manual collapse.
// Removing the state on window resize would cause a one-frame layout swap.
// Padding the whole Row for status bars would incorrectly shorten the divider.
// Ignoring bottom navigation insets would place content behind Android controls.
// Painting the divider inside column width would shift the right pane left.
// Replacing the Sidebar glyph with a generic menu icon is not visual parity.
// Omitting localized toggle semantics is not accessibility parity.
// Dimming unselected stateful icons to the older 0.4 alpha is not current parity.
// Using bold selected labels is not current stateful typography.
//
// Runtime review checklist
// Verify the collapsed toggle aligns with destination icons.
// Verify expanded and collapsed icon x baselines coincide at default widths.
// Verify the selected pill grows without a horizontal center jump.
// Verify Chinese labels remain vertically centered when expanded.
// Verify long labels ellipsize inside the trailing 14dp inset.
// Verify the divider stays full height under Android status bars.
// Verify rail content clears the Android navigation gesture region.
// Verify the surface remains visible behind start-side display cutouts.
// Verify RTL keeps the divider adjacent to the content pane.
// Verify rapid toggle reversals remain position-continuous.
// Verify resizing across 1200dp starts from the currently painted width.
// Verify manual collapse at 1200dp persists through ordinary rebuilds.
// Verify leaving and re-entering the breakpoint restores automatic expansion.
// Verify selecting every rail item still drives the root pager.
// Verify badge overlays retain source offsets against their 28dp anchors.
// Verify the icon FittedBox never scales the badge surface.
// Verify disabled destinations do not enter their pressed indication.
// Verify TalkBack reads one label and the selected state.
// Verify Windows uses the same 80dp and 240dp logical endpoints.
// Verify Android and Windows use identical spring constants.
// Record new native and Flutter captures whenever upstream geometry changes.
//
// Authoritative source-line map
// NavigationRail.kt documents state nullness as a stable structural choice.
// NavigationRail.kt computes effectiveExpandedWidth before layout.
// NavigationRail.kt creates one animateFloatAsState expansion fraction.
// NavigationRail.kt labels that animation navigationRailExpandProgress.
// NavigationRail.kt stores collapsed width beside the progress state.
// NavigationRail.kt paints background before inset modifiers.
// NavigationRail.kt applies display-cutout padding on the start side.
// NavigationRail.kt applies navigation-bar padding on the start side.
// NavigationRail.kt measures column width in a custom layout modifier.
// NavigationRail.kt rounds target width once with roundToPx.
// NavigationRail.kt applies top status padding before vertical scrolling.
// NavigationRail.kt applies bottom navigation padding after vertical scrolling.
// NavigationRail.kt applies 24dp vertical padding after inset modifiers.
// NavigationRail.kt inserts the toggle before the optional header.
// NavigationRail.kt inserts 24dp after the toggle.
// NavigationRail.kt inserts 24dp after the application header.
// NavigationRail.kt publishes expansion info only when state is non-null.
// NavigationRail.kt keeps VerticalDivider as the Row's second child.
// NavigationRailExpandToggle uses the public IconButton component.
// NavigationRailExpandToggle computes collapsed and expanded x endpoints.
// NavigationRailExpandToggle places its child with relative coordinates.
// NavigationRailExpandToggle uses the 28dp Sidebar vector.
// NavigationRailItem creates one interaction source per destination.
// NavigationRailItem reads onSurfaceContainer as its common tint.
// NavigationRailItem uses medium font weight.
// NavigationRailItem enters the expandable branch when local info exists.
// NavigationRailItem keeps the classic Column when local info is absent.
// The expandable branch makes the complete item selectable.
// The expandable branch clips indication to ExpandedItemShape.
// The expandable branch paints selection with surfaceContainerHigh.
// The expandable branch measures indicator, icon, and label separately.
// The expandable branch reads progress during layout.
// The expandable branch calculates expandedLabelMax from remaining width.
// The expandable branch interpolates label maxWidth before measuring text.
// The expandable branch calculates endpoint heights from measured label height.
// The expandable branch centers the collapsed icon in collapsedWidth.
// The expandable branch derives indicator placement from resolved icon placement.
// The expandable branch places the label under the collapsed icon.
// The expandable branch places the label after the expanded icon.
// NavigationRailItemLabel confines composition-time progress to the text leaf.
// NavigationRailItemLabel interpolates only the font-size scalar.
// RailExpandSpring declares its 0.001 visibility threshold.
// ExpandedItemShape is a rounded source shape with the 16dp token.
// NavigationRailDefaults declares every endpoint constant in one object.
// NavigationRailState protects currentValue with a private setter.
// NavigationRailState exposes synchronous expand, collapse, and toggle methods.
// NavigationRailState.Saver persists the enum ordinal in Compose.
// Flutter ownership persistence is supplied by the surrounding State object.
// AppContent PersistentNavigationRail computes expandRail from window width.
// AppContent remembers one rail state instead of recreating it per frame.
// AppContent initializes that state from the current breakpoint result.
// AppContent LaunchedEffect changes the state only when expandRail changes.
// AppContent passes state directly to NavigationRail.
// AppContent renders one NavigationRailItem for each navigation item.
// AppContent forwards the source badge helper into every rail item's badge slot.
// AppContent pops the pane stack before changing the main pager page.
// AdaptiveUtils returns expanded only at a width of at least 1200dp.
// AdaptiveUtils measures the threshold in density-independent dp.
// Flutter LayoutBuilder constraints are already density-independent logical dp.
// Flutter therefore compares maxWidth directly with 1200.
// The Flutter post-frame callback corresponds to Compose LaunchedEffect timing.
// The first Flutter layout sets the initial target before the rail subscribes.
// Subsequent Flutter breakpoint changes animate the existing subscribed rail.
// The source-line map must be refreshed if any named upstream function moves.
//
// Wide AppContent route ownership
// AppContent places PersistentNavigationRail before its weighted content Box.
// The weighted Box applies clipToBounds before it hosts AppNavHost.
// Route transitions are therefore clipped at the content pane's leading edge.
// A pushed route never paints over the navigation rail.
// A pushed route never changes the navigation rail's measured position.
// Transition distance is calculated from pane width rather than window width.
// Flutter mirrors this with a sibling rail and nested pane Navigator.
// ClipRect belongs outside that nested Navigator's overlay.
// The pane Navigator owns Main plus every destination pushed from Main.
// The outer Navigator remains responsible for compact-window routes.
// NavigatorPopHandler gives the pane stack first refusal on system Back.
// Back reaches the main-screen handler only after the pane returns to Main.
// Selecting a rail destination pops the pane stack before changing the pager.
// Popping before selection prevents a hidden detail route retaining focus.
// The Home route must remain live while it sits beneath a pushed route.
// A ValueNotifier forwards settings and pager rebuilds into that retained route.
// Recreating the pane Navigator would incorrectly discard navigation history.
// Keeping a stale first-route closure would freeze theme and behavior settings.
// AppContent composes the FPS monitor after NavDisplay at application scope.
// Flutter therefore places its FPS overlay above both navigation route hosts.
// A pushed About or License page must not hide the diagnostic monitor.
// The rail surface and divider keep their complete window-height ownership.
// Only the scrollable rail column consumes status and navigation-bar insets.
// These ownership rules are structural parity, not optional responsive styling.
// Tests lock the rail rectangle before and after a wide-pane route push.
// Tests also lock the pane clip from rail.trailing to the window's trailing edge.
// Both incoming and outgoing transition scenes must remain inside that clip.
//
// Classic source indication lifecycle
// The indication controller is created eagerly during State.initState.
// Eager creation registers its ticker while inherited TickerMode is available.
// A lazy first read from dispose would access an already deactivated ancestor.
// Pointer down starts the 0.2-response critically damped source spring.
// The controller's upper target is exactly 0.10 alpha.
// Pointer up starts the 0.35-response, 0.95-damped release spring.
// Pointer cancellation uses the same release path as pointer up.
// Disabling a held destination stops the spring and clears alpha immediately.
// The indication layer ignores pointers so it cannot steal destination taps.
// The indication paints across the complete classic destination rectangle.
// Expandable destinations instead clip the same alpha to their squircle.
// Both branches preserve icon and label coordinates throughout the press.
// Source press feedback never scales, sinks, or translates the destination.
// Controller disposal occurs before the State delegates to super.dispose.
// Tests sample one moving frame and both settled spring endpoints.
// Tests also verify the entering and exiting stiffness and damping constants.
