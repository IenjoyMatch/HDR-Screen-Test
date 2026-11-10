// Navigation and top-app-bar source parity contract.
//
// Provenance
// ----------
// The authority is current compose-miuix main commit c2a0ff66243e5cca.
// The regular bar maps to basic/NavigationBar.kt.
// The floating bar maps to basic/NavigationBar.kt.
// The large title bar maps to basic/TopAppBar.kt.
// The compact title bar maps to SmallTopAppBar in that same source.
// Example option order maps to the source SettingsPage.kt.
// Example adaptive behavior maps to utils/PageUtils.kt.
// Names are localized only in the Flutter example UI.
// Public Dart identifiers remain English for package consumers.
// Values listed here are source measurements, not visual guesses.
// This file documents intentional choices made in the executable widgets.
// It also prevents later refactors from reintroducing Material defaults.
//
// Regular NavigationBar surface
// -----------------------------
// The regular navigation bar fills the available width.
// The destination row has an exact logical height of 64dp.
// Bottom system-window padding is outside that 64dp item row.
// Default background is the MIUIX surface semantic color.
// A divider is visible by default at the top edge.
// The divider is a line, not a drop shadow.
// The regular bar has no floating outer margin.
// The regular bar has no corner radius.
// The regular bar has no glass capsule.
// The regular bar has no selected pill.
// The regular bar has no selected icon background.
// The regular bar has no Material splash.
// Empty destination lists must remain safe.
// Out-of-range selected indices are clamped safely.
// Every destination receives equal horizontal width.
// The supported source range is two through five destinations.
// The API remains tolerant outside that range for defensive rendering.
// Semantics expose every destination as a selectable button.
// Semantics expose the source label even in icon-only mode.
// The selected semantics state follows the clamped destination index.
//
// Regular NavigationBar common item metrics
// -----------------------------------------
// Navigation icons are exactly 26dp square.
// Navigation labels are exactly 12sp.
// Selected label weight is bold.
// Unselected label weight is normal.
// The selected tint is onSurfaceContainer.
// Flutter maps onSurfaceContainer to ColorScheme.onSurface.
// The unselected resting alpha is 0.4.
// The selected pressed alpha is 0.5.
// The unselected pressed alpha is 0.6.
// Pressed tint replaces the resting tint immediately.
// Releasing restores the selection-derived tint.
// Cancelling a gesture also restores the resting tint.
// Icon and label colors always use the same resolved tint.
// A selectedIcon may replace the normal icon when supplied.
// A normal icon remains valid when selectedIcon is absent.
// Selection color moves over the same 300ms mode transition interval.
// Selection changes never animate a background because none exists.
// Destination taps report the source list index.
// Gesture hit testing covers the whole equal-width item.
// Labels use one line and ellipsize when width is constrained.
//
// IconAndText mode
// ----------------
// IconAndText is the first and default source display mode.
// Both icon and label remain present for every destination.
// The icon begins 8dp below the top of the 64dp item.
// The label ends 8dp above the bottom of the item.
// Remaining vertical space separates the icon and label.
// Selection changes tint and label weight only.
// No item changes its occupied width on selection.
// No item changes its occupied height on selection.
// This mode is localized as "图标和文字" in the example.
// The obsolete Dart name iconAndLabel must not return.
//
// IconOnly mode
// -------------
// IconOnly is the second source display mode.
// Every label is removed from the visual tree.
// Icons remain vertically centered in the 64dp item.
// Icon size remains 26dp rather than growing to fill the label space.
// Accessibility labels remain available through semantics.
// Selection remains visible through tint and optional selectedIcon.
// This mode is localized as "仅图标" in the example.
// IconOnly is not the floating navigation component.
// Choosing IconOnly must not change the bar surface shape.
// Choosing IconOnly must not change system inset handling.
//
// IconWithSelectedLabel mode
// -------------------------
// IconWithSelectedLabel is the third current source display mode.
// Icons remain visible for every destination.
// Only the selected destination reveals its label.
// The selected icon top position is 8dp.
// The unselected icon top position is 19dp.
// Nineteen is the centered offset for a 26dp icon in a 64dp item.
// Icon top position interpolates during selection changes.
// Label opacity interpolates during selection changes.
// The selection interpolation lasts 300ms.
// The label remains 8dp above the item bottom when visible.
// The selected label retains the 12sp bold source typography.
// Hidden labels retain semantics through their parent destination.
// This mode is localized as "仅选中项显示文字" in the example.
// The current source removed its historical text-only mode.
// Therefore the Flutter library does not invent a text-only enum value.
// A request for icon/text switching maps to these three source modes.
// Mode changes cross-fade over the source 300ms interval.
// Mode changes do not introduce scale, slide, or pill motion.
//
// FloatingNavigationBar identity
// ------------------------------
// FloatingNavigationBar is a separate component, not a display mode.
// It is always icon-only in the current source.
// It accepts the same navigation item model for shell reuse.
// Item semantics still expose labels.
// The selected destination may use selectedIcon.
// The source supports two through five items.
// Defensive rendering remains safe for an empty list.
// Out-of-range selection is clamped before rendering.
// Both onSelected and onDestinationSelected names are accepted.
// The latter aligns new code with the regular navigation callback.
// The former remains for compatibility with the previous Flutter API.
// At least one callback is required by constructor assertion.
//
// FloatingNavigationBar surface metrics
// -------------------------------------
// Minimum floating surface height is 52dp.
// The default corner radius is 50dp.
// That radius comes from FloatingToolbarDefaults.CornerRadius.
// The default surface color is surfaceContainer.
// The default internal horizontal padding is 12dp.
// The default spacing between destination items is 12dp.
// The default outside aligned-edge padding is 36dp.
// The floating bar has no divider by default.
// Enabling the divider uses a 0.75dp outline.
// Default shadow elevation is enabled at logical value 1dp.
// The source shadow blur radius is 10dp.
// The source shadow color is black at alpha 0.2.
// The source shadow has no decorative colored glow.
// The floating surface is not glass by default.
// The floating surface is not translucent by default.
// Blur may be supplied externally by the example's backdrop layer.
// The component itself must not force a glass implementation.
// The surface consumes taps so content below cannot receive them.
// The row sizes to its icon content rather than filling the screen.
// The host remains full width so alignment choices have meaning.
//
// FloatingNavigationBar item metrics
// ----------------------------------
// Floating destination icons are exactly 28dp square.
// Each icon has 10dp padding on all four sides.
// Each item therefore occupies 48dp before inter-item spacing.
// The containing surface supplies the remaining minimum-height centering.
// The selected tint is onSurfaceContainer.
// Flutter resolves that semantic role through ColorScheme.onSurface.
// The unselected resting alpha is 0.4.
// The selected pressed alpha is 0.5.
// The unselected pressed alpha is 0.6.
// The component has no visible text labels.
// The component has no selected pill.
// The component has no per-item background.
// The component has no Material ink splash.
// Flutter's optional text modes do not add a selection indicator either.
// Their equal item widths preserve the source intrinsic row total.
// They must not invent a 48dp or 56dp minimum width per destination.
// The entire 48dp item is the gesture target.
// Press cancellation restores the appropriate resting tint.
// Destination order matches the supplied list exactly.
//
// FloatingNavigationBar placement and insets
// ------------------------------------------
// The default horizontal placement is centered.
// Start placement aligns the surface to the leading edge.
// End placement aligns the surface to the trailing edge.
// Start placement applies 36dp only on the leading outside edge.
// End placement applies 36dp only on the trailing outside edge.
// Center placement applies no unnecessary horizontal outside padding.
// Directional alignment respects left-to-right and right-to-left text.
// iOS uses 36dp of bottom outside padding in the source.
// Other platforms use 36dp when navigation inset is zero.
// Other platforms use navigation inset plus 26dp when it is nonzero.
// Flutter MediaQuery bottom padding supplies the navigation inset.
// Disabling defaultWindowInsetsPadding removes this bottom padding.
// Caption-bar inset changes animate over 300ms in the source.
// Flutter rebuilds against MediaQuery inset changes from the host window.
// The floating bar may be passed directly to scaffold.bottomBar.
// The example replaces the regular bar rather than overlaying both bars.
//
// TopAppBar shared surface contract
// ---------------------------------
// Both title bar variants use surface as their default color.
// Neither variant draws a bottom border by default.
// Neither variant adds an unsolicited shadow.
// Compact title color defaults to onSurface.
// Large title color defaults to onSurface.
// Subtitle color defaults to onSurfaceVariant.
// The compact title size is 20sp.
// The compact title uses medium weight.
// The large title size is 32sp.
// The large title uses normal weight.
// Subtitle size is 14sp.
// The compact row is 52dp for TopAppBar and 50dp-centered in SmallTopAppBar.
// Large title-only collapse retains a separate 4dp bottom padding measurement.
// Title horizontal padding defaults to 26dp.
// Navigation icon start padding defaults to 16dp.
// Action icon end padding defaults to 16dp.
// Maximum title width factor is 0.9.
// Titles use one line and ellipsize under constraints.
// The compact title remains centered when side slots permit.
// The compact title is clamped away from navigation and action slots.
// Navigation and action slots remain in the 52dp collapsed band.
// Action slots use stable hit-area allocation.
// The top systemBars inset is unconditional in both source variants.
// defaultWindowInsetsPadding gates only horizontal cutout/navigation insets.
// Custom background and semantic title colors are supported.
// Optional bottomContent is placed after the title area.
// bottomContentHeight reserves deterministic preferred size for Flutter.
//
// Large TopAppBar expanded layout
// -------------------------------
// The expanded large title begins after the 52dp collapsed band.
// A title-only expanded bar is approximately 94dp tall.
// The exact source height is derived from measured title content.
// Flutter exposes expandedHeight for exact custom text measurement cases.
// Large title bottom padding is exactly 4dp without a subtitle.
// Subtitle bottom padding is exactly 8dp when a subtitle is present.
// The large title uses the optional largeTitle string when supplied.
// It falls back to the compact title string otherwise.
// Subtitle appears below the large title while expanded.
// A subtitle also appears below the compact title when collapsed.
// The expanded title is left aligned at the 26dp title inset.
// The expanded title never receives a Material toolbar baseline offset.
// The large layout clips content while its height collapses.
// Leading and action icons stay visible during the entire transition.
// Preferred size follows the current normalized collapse fraction.
// Scaffold updates its remembered content PaddingValues during every measure.
// The body therefore follows the bar without leaving an expanded gap.
//
// Large TopAppBar collapse motion
// -------------------------------
// Collapse fraction zero means fully expanded.
// Collapse fraction one means fully collapsed.
// Vertical scroll notifications drive two independent source state channels.
// Horizontal PageView notifications are ignored.
// A default title-only large bar has a measured 38dp collapse extent.
// Upward pre-scroll first collapses the title and corrects the child position.
// When a delta crosses the collapse limit, the source consumes that complete
// delta because heightOffset changed; the child starts on the next update.
// Downward child scroll returns to its leading edge before expanding the bar.
// Negative leading-edge overscroll then expands the title by that remainder.
// Large title alpha follows one minus collapseFraction times three.
// Large title is fully hidden at one-third collapse.
// Compact title becomes visible at one-third collapse.
// This visibility threshold matches the source title transition.
// Navigation and action slots do not fade with the title.
// A scroll start cancels any in-progress settle animation.
// A scroll end below midpoint settles to expanded.
// A scroll end at or above midpoint settles to collapsed.
// The settle duration defaults to 300ms.
// The settle curve is critically damped and does not overshoot bounds.
// The source folme response is represented without introducing bounce.
// Callers may set collapseFraction directly for deterministic control.
// Callers may expand immediately after root-page navigation.
// The controller owns and cancels its settle timer on dispose.
// MiuixScaffold subscribes and unsubscribes controller listeners safely.
// MiuixScaffold forwards body ScrollNotifications without swallowing them.
// ScrollPosition.correctBy returns the source-consumed pre-scroll update.
// Nested scrollables retain their normal gesture owner during that correction.
//
// Compact-title spring parity
// ---------------------------
// The source mounts compact and expanded title nodes at the same time.
// Expanded state keeps the compact title at alpha zero.
// The compact node remains centered in the collapsed 52dp band.
// It does not participate in the large-title height measurement.
// The visibility trigger is collapsedFraction multiplied by three.
// Values below one keep the compact title target hidden.
// Values at or above one set the compact title target visible.
// Crossing the threshold starts an independent animation.
// Continued scroll does not scrub that independent animation.
// Showing uses folmeSpring damping one and response 0.3 seconds.
// Hiding uses folmeSpring damping one and response 0.15 seconds.
// Damping one is the critically damped no-overshoot case.
// Folme stiffness is the square of two pi divided by response.
// The corresponding step response starts with zero velocity.
// Its position is one minus one plus omega t times exp minus omega t.
// Flutter normalizes that response to its finite animation interval.
// Normalization preserves the source acceleration and exact final value.
// Compact title alpha is the spring position.
// Compact subtitle alpha shares the same spring position.
// Compact title translation starts at 20 physical pixels.
// Compact subtitle translation shares that physical-pixel offset.
// Translation approaches zero while the title becomes visible.
// Translation returns to 20 pixels while the title becomes hidden.
// Compose graphicsLayer translation is expressed in raw pixels.
// Flutter therefore divides 20 by the current device-pixel ratio.
// A 420dpi Android device travels about 7.62 logical pixels.
// A density-one Windows surface travels 20 logical pixels.
// Leading navigation content never uses the title opacity.
// Trailing action content never uses the title opacity.
// Their hit targets remain active throughout the transition.
// Their visual centers remain fixed throughout the transition.
// Large-title alpha remains driven directly by collapse fraction.
// Large-title alpha reaches zero at the same one-third threshold.
// The compact animation can therefore continue after large title removal.
// The source snap spec uses spring stiffness 2500.
// Its default damping is critical and does not overshoot.
// Angular frequency is the square root of stiffness.
// The equivalent response is two pi divided by square root 2500.
// The settle timer samples that response at Flutter frame cadence.
// Direct controller values remain clamped between zero and one.
// Zero-duration controllers still settle synchronously for deterministic tests.
// Widget tests sample intermediate show and hide opacity values.
// Android captures verify expanded and collapsed endpoint geometry.
//
// SmallTopAppBar contract
// ----------------------
// MiuixSmallTopAppBar is a named adapter for the compact source variant.
// It always reports the 52dp title-area preferred height.
// It uses the same title, subtitle, navigation, and action slots.
// It accepts the same color and padding overrides.
// It accepts the same optional bottom content slot.
// It accepts the same optional shared scroll behavior as the large variant.
// Attaching a small bar pins the shared height offset to its zero limit.
// Pinning preserves the accumulated content offset instead of resetting it.
// While pinned, list metrics may update that content offset without collapse.
// A negative content offset keeps the compact title visibly scrolled state.
// A zero or positive content offset keeps the compact title hidden state.
// Attaching a large bar restores its measured nonzero collapse extent.
// A negative preserved offset restores the fully collapsed endpoint.
// A nonnegative preserved offset restores the fully expanded endpoint.
// Large-bar attachment clears the small-bar pin marker after restoration.
// Switching variants never consumes or corrects a child scroll delta.
// Deferred small-bar pinning is cancelled if a large bar replaces it first.
// The pin side effect runs after build, matching Compose SideEffect ordering.
// A generation counter identifies the most recently authored bar variant.
// Scheduling a compact pin increments and captures that generation.
// Attaching a large collapse extent increments the generation synchronously.
// A stale compact callback observes the mismatch and performs no mutation.
// This matters when an adaptive LayoutBuilder changes branch in one frame.
// While pinned, collapseFraction is always exactly zero.
// The preserved content offset is allowed to remain negative.
// Notification metrics may replace that offset with current scroll pixels.
// Those metrics must not consume, correct, or jump the child ScrollPosition.
// Compact title visibility reads the sign of preserved content offset.
// It does not read collapseFraction because pinned fraction is always zero.
// Returning to a large bar resolves its measured title-column extent first.
// Only then can preferredSize report the correct expanded/collapsed height.
// Negative offset restores collapseFraction one before that size is consumed.
// Zero offset restores collapseFraction zero before that size is consumed.
// Positive offset also restores the expanded endpoint, matching the source.
// Restoration clears the pin marker after applying the endpoint.
// A later ordinary list notification resumes the normal collapse algorithm.
// Listener notifications scheduled during preferred-size work are post-frame.
// No listener is called after the behavior has been disposed.
// Direct Flutter Scaffold preferred-size reads use the same preparation path.
// MiuixScaffold source-size reads use that path as well.
// Repeated attachment to the same large extent is a no-op after restoration.
// Repeated compact builds coalesce into one pending pin callback.
// Tests retain content offset across compact attachment explicitly.
// Tests also update list metrics while compact and assert zero collapse.
// Reattachment verifies the negative-offset collapsed endpoint.
// A leading-edge reset verifies the nonnegative expanded endpoint.
// Compact show/hide springs remain independent of these state transitions.
// Wide example layouts choose this variant.
// Narrow example layouts choose the large variant.
// This matches the source AdaptiveTopAppBar helper.
//
// Localized example integration
// -----------------------------
// The five root page titles are translated to Simplified Chinese.
// Narrow pages display the translated title as a large title.
// Wide pages display the translated title in SmallTopAppBar.
// The settings page shows the package version as subtitle.
// Page selection expands the shared large-title controller.
// Body scrolling then collapses the title for the active page.
// Navigation mode options preserve source enum order.
// "图标和文字" maps to IconAndText.
// "仅图标" maps to IconOnly.
// "仅选中项显示文字" maps to IconWithSelectedLabel.
// The floating navigation switch is separate from display mode.
// Regular display-mode selection hides while floating mode is active.
// Floating position selection appears only while floating mode is active.
// "居中" maps to center placement.
// "靠左" maps to start placement.
// "靠右" maps to end placement.
// Switching regular and floating bars uses a 300ms cross-fade.
// Root destination changes retain the existing 300ms pager transition.
// The example defaults to the source IconAndText mode.
// The example defaults to the source non-floating configuration.
// The example defaults the navigation badge to hidden like AppState.kt.
//
// Regression requirements
// -----------------------
// Static analysis must pass for both the package and localized example.
// Package widget tests cover source dimensions and semantic colors.
// Package widget tests cover all three regular display modes.
// Package widget tests cover expanded, midpoint, and collapsed bar heights.
// Floating tests cover icon size, icon padding, spacing, and tint.
// Golden tests cover regular navigation in light and dark themes.
// Golden tests cover compact TopAppBar with both side slots.
// Golden tests cover the floating navigation surface independently.
// Example tests verify that settings mutate the real shell.
// Android release output must remain arm64-v8a only when requested.
// Android non-production signing must be disclosed when a debug key is used.
// Windows release output must include the runner and required runtime files.
// Component source remains split into bounded, reviewable part files.
// navigation.dart retains scaffold, rail, tabs, and navigation utilities.
// navigation_bars.dart owns regular and floating bottom navigation.
// top_app_bars.dart owns both title variants and collapse behavior.
// Future changes must compare against the source before changing constants.
// Future changes must not restore removed text-only documentation.
// Future changes must not reinterpret floating navigation as a display mode.
// Future changes must not add selected pills absent from the source.
// Future changes must keep the project comment-ratio check at fifty percent.
// Current-source Defaults ownership
// ---------------------------------
// NavigationBarDefaults owns the measured 64dp destination height.
// NavigationBarDefaults owns the 26dp icon size for all regular modes.
// NavigationBarDefaults owns the 12sp visible label size.
// NavigationBarDefaults owns the 8dp icon top inset.
// NavigationBarDefaults owns the 8dp label bottom inset.
// NavigationBarDefaults owns the selected pressed alpha of one half.
// NavigationBarDefaults owns the unselected pressed alpha of three fifths.
// NavigationBarDefaults owns the resting unselected alpha of two fifths.
// The item implementation reads these public values rather than duplicates.
// Badge anchor geometry derives from the same public icon size.
// The 64dp row remains independent from the optional 0.75dp divider.
// Caption and navigation insets remain outside the 64dp item measurement.
// Display-mode animation retains its independently audited 300ms duration.
// Defaults exposure does not add text-only to the upstream source enum.
// The Flutter text-only value remains an explicit compatibility extension.

// FloatingNavigationBarDefaults owns the 36dp source outside inset.
// FloatingNavigationBarDefaults owns the 1dp elevation enable value.
// FloatingNavigationBarDefaults owns the 12dp inner horizontal padding.
// FloatingNavigationBarDefaults owns the 12dp spacing between destinations.
// FloatingNavigationBarDefaults owns the 28dp icon-only source size.
// FloatingNavigationBarDefaults owns the 10dp padding around that icon.
// FloatingNavigationBarDefaults owns the selected pressed alpha of one half.
// FloatingNavigationBarDefaults owns the unselected pressed alpha of three fifths.
// FloatingNavigationBarDefaults owns the resting unselected alpha of two fifths.
// HyperOS constructors may resolve newer layout tokens independently.
// Source metrics remain public even when the ordinary visual uses new tokens.
// The source shadow radius remains 10dp and its opacity remains one fifth.
// Elevation remains a positive-value gate rather than scaling the shadow.
// The icon-only implementation reads the public source icon and padding values.
// Pressed and resting tint paths read the public alpha values in every mode.
// A source Defaults mapping never claims that a HyperOS extension is upstream.

// TopAppBarDefaults owns the 26dp horizontal title padding.
// TopAppBarDefaults owns the 16dp navigation-icon start padding.
// TopAppBarDefaults owns the 16dp action-icon end padding.
// TopAppBarDefaults owns the 52dp compact collapsed height.
// TopAppBarDefaults owns the 50dp SmallTopAppBar vertical center height.
// TopAppBarDefaults owns the 4dp bottom inset after a large title.
// TopAppBarDefaults owns the 8dp bottom inset after a subtitle.
// Public MiuixTopAppBar static names remain compatibility aliases.
// Constructor fallbacks resolve through the public Defaults object.
// Invalid title padding restores the public title-padding value.
// Invalid navigation padding restores the public navigation-padding value.
// Invalid action padding restores the public action-padding value.
// Collapse calculations consume the same public height and bottom insets.
// Preferred-size calculations consume the same public height values.
// Defaults exposure does not change Gaussian, gradient, or progressive selection.
// HyperOS action glass uses independent circles; plain mode retains source slots.
// Defaults exposure does not change nested-scroll spring stiffness.
// Defaults exposure does not change reduced-motion settling behavior.
// Focused tests compare every public source metric to current Kotlin source.
// Widget tests continue to cover resolved size, tint, glass, and semantics.
// Mapping tests establish public-name coverage but do not replace those tests.
// Runtime and screenshot evidence remain required for visual parity claims.
// Hoisted TopAppBarState contract
// -------------------------------
// MiuixTopAppBarState stores a negative heightOffsetLimit in logical pixels.
// A positive limit is normalized to zero for recoverable decoded input.
// Non-finite limits restore the source unbounded initial sentinel.
// heightOffset is always coerced between the negative limit and zero.
// Non-finite height offsets recover to the fully expanded zero endpoint.
// contentOffset remains independent from the clamped height offset.
// Non-finite content offsets recover to zero.
// collapsedFraction is zero when the height range is pinned to zero.
// Otherwise collapsedFraction is heightOffset divided by heightOffsetLimit.
// The exposed collapse value remains inside zero through one.
// overlappedFraction follows the current upstream TopAppBarState equation.
// The exposed overlap value remains inside zero through one.
// Every effective public state mutation notifies state listeners once.
// Assigning an unchanged normalized value does not notify listeners.
// MiuixTopAppBarScrollBehavior accepts an optional hoisted state.
// Omitting state creates an independently observable state automatically.
// A finite bounded initial state restores the behavior collapse extent.
// The initial height offset restores the behavior collapse fraction.
// The initial content offset restores progressive blur distance independently.
// Behavior-driven collapse writes heightOffset back to the hoisted state.
// Behavior-driven content movement writes contentOffset back to the state.
// The measured title column writes heightOffsetLimit back after the frame.
// SmallTopAppBar pins the public height range to zero while retaining content.
// Reattaching a large bar restores the measured negative height limit.
// An external heightOffset mutation updates behavior collapse immediately.
// An external contentOffset mutation updates progressive blur immediately.
// External mutations cancel an in-flight settle before applying new authority.
// Internal synchronization guards against state-listener recursion.
// Disposing behavior removes only its listener from a caller-owned state.
// Callers retain responsibility for disposing a separately created state.
// Existing collapseFraction and contentOffset getters remain compatible.
// Existing setCollapseFraction remains compatible and now updates state.
// Existing PageStorage restoration remains authoritative when no state was set.
// Existing explicit state remains authoritative over late list attachment.
// The source rememberTopAppBarState maps to construction of this state value.
// The source ScrollBehavior interface maps to the top-bar behavior controller.
// The source MiuixScrollBehavior factory maps to that same top-bar controller.
// It must never map to the unrelated package-wide overscroll behavior again.
// The generic MiuixScrollBehavior type remains public for page physics only.
// Same-name coverage is insufficient when state and nested-scroll roles differ.
// Focused tests verify initial fraction and overlap calculations.
// Focused tests verify behavior-to-state synchronization.
// Focused tests verify state-to-behavior synchronization.
// Existing scroll, compact-pin, restoration, and PageStorage tests also pass.
// Static analysis remains required after every state-notification change.
// Runtime visual evidence remains separate from state-model unit evidence.

// State restoration and lifecycle matrix
// --------------------------------------
// A state restored at half collapse initializes behavior at half collapse.
// A state restored fully expanded initializes behavior at zero collapse.
// A state restored fully collapsed initializes behavior at one collapse.
// A restored negative content offset remains available to progressive blur.
// A restored positive content offset remains stored without changing height.
// A default unbounded limit does not replace the measured 38dp title extent.
// The first measured title column replaces that sentinel after layout.
// A custom 54dp subtitle column writes a distinct public negative limit.
// Changing only contentOffset never changes collapsedFraction.
// Changing only heightOffset never discards contentOffset.
// Changing the limit clamps an out-of-range height into the new interval.
// Pinning a compact bar exposes a zero limit and zero height offset.
// Pinning does not erase whether content already moved upward.
// Replacing compact with large restores the appropriate collapsed endpoint.
// Replacing large with compact invalidates any running height simulation.
// A fresh user drag invalidates an externally restored settle simulation.
// A programmatic state write invalidates an internally running settle.
// Reduced motion still commits a stable endpoint to both observers.
// A spring frame writes one coherent limit, height, and content snapshot.
// A decay frame writes one coherent limit, height, and content snapshot.
// State listeners cannot observe height from one frame and content from another.
// Behavior listeners run after the hoisted state has been synchronized.
// Reading state inside a behavior listener therefore returns current values.
// Reading behavior inside a state listener avoids recursive writes.
// State equality is identity-based because it is a mutable observable owner.
// The state object deliberately does not implement copyWith value semantics.
// Restoration adapters should save its three public numeric channels.
// Pinned compact mode may additionally be inferred from a zero height limit.
// Platform scroll physics remain outside the state object's responsibility.
// Ticker ownership remains inside MiuixTopAppBarScrollBehavior.
// A state without an attached behavior allocates no ticker.
// Disposing an unattached state has no platform or frame side effect.
// Disposing behavior stops its ticker before removing the state listener.
// A caller-owned state may be attached to a later replacement behavior.
// Tests dispose behavior before disposing its caller-owned state.
// This lifecycle order mirrors provider and StatefulWidget ownership patterns.
// No global singleton is used for top-app-bar state.
// Separate tabs can therefore preserve independent collapse positions.
// Shared compact and large bars can intentionally reuse one behavior and state.
// These lifecycle guarantees are part of runtime parity, not mapping metadata.
// The public limit uses logical pixels because Flutter layout is density-aware.
// Native physical evidence must convert the value with the active density.
// Fraction calculations remain density-independent after that conversion.
// A zero collapse extent never produces NaN or infinity.
// A malformed infinite height never poisons title interpolation.
// A malformed infinite content value never poisons blur opacity.
// A positive decoded limit recovers as the pinned zero range.
// A height above zero recovers as the expanded endpoint.
// A height below the limit recovers as the collapsed endpoint.
// Listener de-duplication uses normalized values rather than raw bad input.
// The state API remains usable without a BuildContext.
// It remains usable in controller, provider, and restoration layers.
// It does not read MediaQuery, theme, platform, or animation preferences.
// Those context-dependent decisions remain in the widget and behavior.
// The behavior continues to expose the existing 300ms maximum settle cap.
// The source spring continues to use stiffness 2500 and critical damping.
// This batch changes state ownership without changing that motion curve.
// Golden tests remain responsible for detecting unintended geometry changes.
// Gesture tests remain responsible for detecting consumed-scroll regressions.
// Full-suite verification remains required before producing Release artifacts.
// Source mapping verifies that the controller name resolves to this behavior.
// Public-name verification verifies that the state remains exported.
// Static analysis verifies that numeric normalization remains type-safe.
// Focused state tests verify both synchronization directions.
// Existing nested-scroll tests verify real notification integration.
// Existing restoration tests verify late ScrollPosition attachment.
// Existing compact-bar tests verify deferred pinning after a frame.
// Existing motion tests verify interruption and endpoint settling.
// Windows smoke verification checks that state changes do not hang startup.
// Android runtime verification remains pending without an owned arm64 target.
// Static APK inspection cannot substitute for that runtime boundary.
// The parity report must keep this distinction explicit.
