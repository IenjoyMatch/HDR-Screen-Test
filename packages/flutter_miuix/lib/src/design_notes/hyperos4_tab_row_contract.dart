// HyperOS 4 tab-row migration contract.
//
// Evidence boundary.
// Xiaomi's public HyperOS imagery demonstrates shallow, wide local option
// capsules, continuous selected surfaces, restrained semantic color, and
// translucent material. It does not publish a Flutter or dp token table.
// The default dimensions below are therefore project calibrations and must
// never be described as official Xiaomi measurements.
//
// Public-constructor boundary.
// MiuixTabRow and MiuixTabRowWithContour are the new HyperOS 4 defaults.
// MiuixTabBar follows the same default when called directly.
// Their complete surface is local glass rather than a full opaque page strip.
// The outer capsule uses the compact option-group material token family.
// The selected surface stays inside the exact same clipped shape hierarchy.
// Caller-provided colors continue to replace only their matching channels.
// Caller-provided glass blur and opacity override the theme token separately.
// Passing glass false retains HyperOS geometry with an opaque local surface.
//
// Legacy-source boundary.
// MiuixTabRow.source preserves the 42dp ordinary MIUIX 1.0.9 row.
// It preserves 76dp minimum width, 98dp maximum width, and 9dp spacing.
// It preserves 12dp item corners and ordinary unselected outlines.
// Its selected indicator remains positioned without a transition.
// MiuixTabRowWithContour.source preserves the 45dp contour row.
// It preserves 5dp padding, 8dp item corners, and 13dp outer corners.
// It preserves 62dp minimum width, 84dp maximum width, and 5dp spacing.
// Its later selected-index changes retain the source 200ms linear motion.
// Both source adapters keep indication disabled and add no new haptic role.
// MiuixTabBar.source and contourSource expose the same direct compatibility.
//
// HyperOS geometry boundary.
// The complete project-calibrated capsule height is 44dp.
// Three dp of local inset leaves a 38dp visible selected surface.
// The item corner is 19dp and the resulting outer corner is 22dp.
// A separate 48dp semantic and pointer proxy remains vertically centered.
// The visible control can therefore stay shallow without shrinking its target.
// Neighboring interaction regions retain a project-calibrated 3dp gap.
// Width allocation remains equal whenever the available width permits it.
// Short labels do not create unequal destination widths.
// Long collections retain the existing horizontal scrolling and centering.
// Initial selection and restored offsets snap before first visible paint.
//
// Motion and feedback boundary.
// HyperOS selection uses the compact option-group duration and easing curve.
// The moving surface preserves shared position instead of fading out and in.
// MediaQuery.disableAnimations changes that duration to exactly zero.
// Automatic selected-tab centering also jumps instead of scrolling then.
// Direct horizontal scrolling remains user-driven and is not disabled.
// A change to a genuinely different tab emits segmentTick exactly once.
// Repeated activation of the selected tab emits no haptic.
// The explicit source constructors emit no newly invented haptic feedback.
// Default pointer indication remains anchored to the pressed tab region.
// Controlled selection continues to wait for the owner's published index.
//
// Regression boundary.
// Source tests must invoke source constructors before asserting old pixels.
// Default tests must inspect the real MiuixSurface rather than only constants.
// They verify glass, blur, tint, height, padding, width equality, and text role.
// They observe a real intermediate selected-surface position in normal motion.
// They then enable reduced motion and require the exact endpoint in one pump.
// Haptic tests distinguish changed, repeated, and explicit-source activation.
// Golden baselines for the ordinary public constructors intentionally change.
// Source geometry tests remain unchanged and protect migration compatibility.
//
// Controlled-state ownership details.
// A non-null selectedTabIndex remains authoritative for every visible channel.
// Pointer activation reports intent through onTabSelected and onTap.
// It does not optimistically move the indicator before the owner rebuilds.
// Text weight and semantic selected state wait for that same owner rebuild.
// A TabController remains a Flutter compatibility path when no index is given.
// Its current index is clamped against the current label count before paint.
// Removing labels cannot leave the local fallback index outside the new range.
// An empty list keeps a stable surface and a zero-index internal sentinel.
// No semantic tab proxy is created when the label collection is empty.
// Repeated selection of the controlled index can still invoke compatibility
// callbacks, but it does not produce a false state-change haptic.
//
// Width and scrolling details.
// Width calculation subtracts all inter-item gaps before dividing space.
// The result is clamped through the existing minimum and maximum algorithm.
// A short set may expand equally to fill its explicitly constrained surface.
// A long set uses its minimum width and becomes horizontally scrollable.
// The selected item is centered when content exists on both sides.
// First layout and restored selection jump to the calculated center offset.
// Later ordinary selection changes animate centering with the shared duration.
// Reduced motion changes that automatic centering operation to jumpTo.
// Pointer and trackpad scrolling continue to use ClampingScrollPhysics.
// The current horizontal viewport clips only along its scroll paint boundary.
// Item semantics track the same scroll offset as visible item geometry.
// A partially visible item cannot leave a detached invisible tap target behind.
// Generation numbers discard stale post-frame centering requests safely.
// Disposal checks prevent a queued request from touching a dead controller.
//
// Density and direction details.
// Declared layout values are rounded independently at device pixel density.
// Outer height, item widths, spacing, and padding each follow that rule.
// The item radius remains a logical shape parameter rather than a layout size.
// The outer radius is item radius plus the separately selected surface inset.
// Directional positioning keeps selection movement correct in RTL layouts.
// The centering controller continues to use physical scroll coordinates.
// Visible label alignment remains caller-controlled through AlignmentGeometry.
// Default center alignment therefore mirrors without manual offset branches.
// Text stays one line and ellipsizes inside its equal item region.
// Chinese and English labels receive the same allocated item width.
// Font weight changes do not participate in width calculation or reflow.
//
// Surface and glass details.
// MiuixSurface owns one outer clip for tint, blur, border, and edge reflection.
// Transparent color is used only when glass sampling is enabled.
// Disabling glass switches to the resolved background color in the same shape.
// The selected surface is painted inside the padded local capsule.
// It never receives a rectangular shadow or backdrop filter of its own.
// The outer half-pixel semantic divider remains low contrast in both themes.
// Glass intensity is resolved by MiuixSurface and the application theme.
// A zero effective blur still preserves tint, border, and shape hierarchy.
// The component does not place an opaque box outside the capsule clip.
// Complex page content can therefore remain visible around the local surface.
// The surface does not force a page background or own system-bar insets.
// Callers decide whether the complete control is full-width or content-width.
//
// Indicator details.
// The default indicator is an AnimatedPositionedDirectional shared surface.
// Its start coordinate is selectedIndex times item width plus item spacing.
// Top and bottom remain zero inside the already padded content region.
// Its width always equals the selected item's equal interaction width.
// The default ease-out curve provides continuous deceleration at the endpoint.
// Interrupting a selection change starts Flutter's retargeted position tween.
// Reduced motion supplies Duration.zero before the new target is constructed.
// The old source ordinary indicator stays a non-animated PositionedDirectional.
// The old source contour indicator retains its exact linear 200ms duration.
// Initial placement never fabricates an entrance animation for either family.
// Selected and unselected content colors still switch on the controlled state.
//
// Pointer and accessibility details.
// Visible item height is intentionally smaller than the interaction minimum.
// A separate centered target proxy supplies the complete 48dp vertical band.
// That proxy owns tab role, selected state, label, and semantic tap action.
// Painted button content is excluded from duplicate semantics deliberately.
// Pointer taps in the expansion band route to the same selection callback.
// The default indication is clipped to the exact selected item shape.
// Its feedback does not change item measurement or neighboring widths.
// Keyboard behavior remains available through the surrounding tab controller.
// Text scaling can enlarge glyphs but does not remove ellipsis protection.
// High-contrast color behavior stays delegated to semantic theme roles.
// The control never relies on glass transparency alone to express selection.
// Selected text weight and a separate selected surface remain visible together.
//
// Haptic details.
// Haptics are requested only after a different valid index is activated.
// The role is segmentTick because tabs form a discrete adjacent option group.
// Android uses the registered semantic platform channel implementation.
// Windows uses the package's safe duration and intensity fallback behavior.
// A failed platform haptic cannot prevent callbacks or controlled rebuilding.
// Programmatic selected-index changes do not vibrate without user activation.
// Source constructors retain their historic silent behavior for exact parity.
// Shared interaction sources still observe press state independently of haptic.
//
// Golden and maintenance details.
// Light and dark baselines must show readable selected and unselected labels.
// Pressed baseline must confine indication to the activated destination region.
// Disabled and expanded fixture states keep their documented driver semantics.
// Animation-midpoint baseline must show one continuous moving selected surface.
// A normal golden update is valid only after inspecting the generated image.
// Pixel differences alone do not prove that the new visual is intentional.
// Source numeric tests are separate from default HyperOS visual goldens.
// Future token calibration changes must update tests, docs, and goldens together.
// Any public source-constructor regression blocks a HyperOS default migration.
// Any code, documentation, or golden change requires a complete Release cycle.
