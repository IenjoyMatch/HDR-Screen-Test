// MIUIX v1.0.9 navigation and smooth-shape parity contract.
//
// Authority
// This contract follows the local upstream checkout at C:/Code/miuix-src-090.
// Navigation metrics come from miuix-ui/basic/NavigationBar.kt.
// Rail metrics come from miuix-ui/basic/NavigationRail.kt.
// Smooth corner math comes from miuix-squircle/SquirclePath.kt.
// Example structure comes from example/shared/MainPage.kt and AppContent.kt.
// Flutter names remain public and idiomatic while visual behavior follows source.
//
// Root page contract
// The current sample exposes exactly five root destinations.
// Destination zero is Home and is localized as 主页.
// Destination one is Icon and is localized as 图标.
// Destination two is Color and is localized as 颜色.
// Destination three is Dropdown and is localized as 下拉菜单.
// Destination four is Settings and is localized as 设置.
// The fourth destination is not the older TextStyle page.
// The fourth destination uses the upstream Sort icon.
// Root page order must match navigation item order.
// Horizontal paging must retain all five pages.
// A navigation tap must animate to the corresponding page.
// A user page swipe must update the selected navigation destination.
// Returning from a secondary route must preserve the selected root page.
// Compact layouts use a bottom navigation component.
// Wide layouts use an 80dp navigation rail.
// The page body remains visible behind floating navigation outside its surface.
//
// Home section contract
// SearchBar is the first item in the Home list.
// Basic Component is the first component chapter.
// Checkbox follows Basic Component.
// RadioButton follows Checkbox.
// Switch follows RadioButton.
// Arrow follows Switch.
// Dialog follows Arrow.
// BottomSheet follows Dialog.
// Dropdown follows BottomSheet.
// Spinner follows Dropdown.
// Button follows Spinner.
// Snackbar follows Button.
// ProgressIndicator follows Snackbar.
// TextField follows ProgressIndicator.
// Slider follows TextField.
// TabRow follows Slider.
// NumberPicker follows TabRow.
// ColorPicker follows NumberPicker.
// Card follows ColorPicker.
// Shape Comparison follows Card.
// Blur is the final component chapter.
// Older Tooltip and Badge fixture classes are not rendered on current Home.
// Older Other links are not rendered on current Home.
// Search may use localized titles and upstream English aliases.
// Search filtering must preserve upstream chapter order.
// Search with no match must show one localized empty state.
//
// Dropdown page contract
// The initial page contains six preference rows.
// Row one uses OverlayDropdownPreference.
// Row two uses WindowDropdownPreference.
// Overlay and Window rows alternate for the whole list.
// Every row shares one selected option value.
// The option list contains four entries.
// The default selected entry is the first option.
// Selecting an option in one row updates every row label.
// Overlay rows use the outer MIUIX Scaffold popup host.
// Window rows use the Navigator window route.
// The first row owns both top 16dp corners.
// Middle rows have no outer corner radius.
// The last row owns both bottom 16dp corners.
// Adjacent rows form one visually continuous surface.
// The list has 12dp horizontal page padding.
// The list has 12dp initial top spacing.
// Pull-to-refresh is available even when content is short.
// Refresh waits 200ms, matching the source fixture.
// Refresh appends exactly six additional rows.
// New rows continue the same alternating presentation sequence.
// The former last row loses its bottom corners after refresh.
// The new last row gains the bottom corners after refresh.
// Pull-to-refresh must not reset the selected option.
// Pull-to-refresh must not replace existing row state.
// The page keeps the compact bottom navigation clearance.
// Wide mode uses its normal page bottom clearance.
//
// Regular navigation bar contract
// The source supports between two and five destinations.
// The item strip height is 64dp on Android and desktop.
// The default mode is IconAndText.
// IconAndText displays every icon and every label.
// IconOnly displays every icon and no visible label.
// TextOnly displays every label and no visible icon.
// IconWithSelectedLabel always displays every icon.
// IconWithSelectedLabel displays only the selected label.
// Icons are 26dp in regular navigation.
// Labels are 12sp in IconAndText.
// TextOnly labels are 14sp to match the current source.
// Icon top padding is 8dp in IconAndText.
// Label bottom padding is 8dp on non-iOS platforms.
// Selected labels use bold weight.
// Unselected labels use normal weight.
// Selected icons use the full on-surface-container tint.
// Unselected items use 0.4 alpha.
// Selected pressed items use 0.5 alpha.
// Unselected pressed items use 0.6 alpha.
// Mode changes animate over 300ms.
// Selected-label icon movement animates over 300ms.
// Selected-label text opacity animates over 300ms.
// Mode changes must not replace the selected destination.
// Mode changes must not change the item hit regions.
// Semantics retain labels when icons or text are visually hidden.
// The divider remains independently configurable.
// System bottom insets remain independently configurable.
//
// Floating navigation bar contract
// Floating navigation is a distinct component, not a regular bar mode.
// The current source supports IconAndText, IconOnly, and TextOnly.
// The source default is IconOnly.
// IconOnly uses a 28dp icon.
// IconOnly applies 10dp padding on all sides.
// IconOnly therefore produces a 48dp item extent.
// IconAndText uses a 24dp icon.
// IconAndText uses a 12sp label.
// IconAndText uses 6dp top and bottom padding.
// TextOnly uses a 14sp label.
// TextOnly uses 16dp vertical padding.
// TextOnly uses 2dp horizontal padding.
// Selected labels use bold weight.
// Hidden bold labels reserve stable width during weight changes.
// Adjacent items use 12dp spacing.
// The floating surface uses 12dp horizontal inner padding.
// The floating surface may align start, center, or end.
// Start and end modes use 36dp outside padding.
// Center mode has no artificial outside padding.
// Android without a navigation inset uses 36dp bottom spacing.
// Android with a navigation inset adds the source inset spacing.
// The floating surface itself must not fill the Scaffold bottom slot.
// Only the pill participates in hit testing and painting.
// The area outside the pill reveals the active page.
// Glass mode clips blur to the pill path.
// Non-glass mode clips color to the same pill path.
// Divider mode strokes the same continuous-corner path.
// Shadow mode follows the same continuous-corner path.
// Press alpha values match regular navigation semantics.
// Display-mode changes use a 300ms content transition.
// Display-mode changes use animated size rather than a hard geometry jump.
// Display-mode changes retain the current selected index.
// Display-mode changes retain alignment and outside padding.
// Semantics retain each label in all three modes.
//
// Navigation rail contract
// The current source rail minimum width is 80dp.
// The source rail uses 24dp vertical content padding.
// Each destination uses 12dp vertical item padding.
// The source supports IconAndText, IconOnly, TextOnly, and selected label.
// IconAndText displays a 28dp icon and a 12sp label.
// IconAndText uses 4dp icon-to-label spacing.
// IconOnly displays the 28dp icon alone.
// TextOnly displays a 14sp label alone.
// TextOnly uses 4dp additional vertical padding.
// IconWithSelectedLabel displays every icon.
// IconWithSelectedLabel displays a label only for the selected item.
// Selected text uses bold weight.
// Unselected text uses normal weight.
// Selected tint uses full on-surface-container color.
// Unselected tint uses 0.4 alpha.
// The rail scrolls vertically when its destinations do not fit.
// The rail respects status, display-cutout, and navigation insets.
// The rail divider is drawn on the content-facing edge.
// The old 240dp extended adapter remains compatibility-only.
// The current example must not opt into the old extended adapter.
// Wide-screen settings expose the four current rail modes.
// Changing rail mode must not resize the page content unpredictably.
// Changing rail mode must retain the selected destination.
//
// Smooth corner path contract
// Flutter's ordinary RRect is not a sufficient MIUIX smooth shape.
// The implementation ports the source cubic Bézier algorithm directly.
// SquircleDefaults.Extension is 1.1.
// SQUIRCLE_CONTROL is 0.643.
// The corner tile is radius times extension.
// The corner tile is clamped to half the narrowest rectangle dimension.
// A zero radius produces a rectangular path.
// Every corner may have an independent radius.
// Logical start and end radii resolve through TextDirection before painting.
// Each corner uses one cubic Bézier segment.
// Cubic endpoints remain tangent to their adjacent straight edges.
// The outer path is the canonical painted shape.
// The inner path deflates both bounds and radii by border width.
// The stroked path is centered by half the border width.
// Surface fill and border use the same ShapeBorder path.
// Surface shadows use the same ShapeBorder path.
// Glass tint uses the same ShapeBorder path.
// Backdrop blur clipping uses the same ShapeBorder path.
// Image and custom-child clipping uses the same ShapeBorder path.
// Floating navigation uses the same ShapeBorder path.
// Uneven dropdown list corners use the same ShapeBorder path.
// Shape Comparison visualizes the smooth path against a circular RRect.
// Shape Comparison fills the circular reference with primary color.
// Shape Comparison draws the XOR difference with error color.
// Shape Comparison starts at a 48dp radius.
// Shape Comparison allows a radius range from 0dp through 80dp.
// Shape Comparison preview height is 160dp.
// Shape Comparison displays the current integer radius in its label.
// The comparison slider has 8dp top and 12dp bottom spacing.
//
// Glass interaction contract
// Transparent tint remains transparent after opacity scaling.
// Tint alpha multiplies rather than replaces the caller alpha.
// Global glass intensity scales both blur and tint opacity.
// Disabling glass removes BackdropFilter work.
// Disabling glass preserves an explicitly transparent top-bar tint.
// Glass clipping must never create a full-screen opaque layer.
// Floating pill glass must not reserve a rectangular bottom background.
// Bottom sheet glass clips only the source sheet surface.
// Top app bar glass can operate as a blur-only layer.
// All glass paths use the same continuous-corner implementation.
//
// Verification contract
// Static analysis must report no issue in lib or example/lib.
// The scope verifier must continue to find every required public name.
// The measured comment ratio must remain at least 50 percent.
// Unit tests must cover all regular navigation display modes.
// Unit tests must cover all floating navigation display modes.
// Unit tests must cover all navigation rail display modes.
// Unit tests must prove floating content overlaps the active page area.
// Unit tests must prove the floating pill alone owns the glass key.
// Unit tests must prove the Dropdown page starts with six rows.
// Unit tests must prove Dropdown row presentation alternates.
// Unit tests must prove a selection is shared by all Dropdown rows.
// Unit tests must prove refresh appends exactly six rows.
// Unit tests must prove the fourth root page is Dropdown.
// Unit tests must prove the old TextStyle root label is absent.
// Unit tests must prove Shape Comparison is present on Home.
// Path tests must distinguish the smooth path from a circular RRect.
// Path tests must exercise zero radius and constrained capsule geometry.
// Golden tests must be deliberately refreshed after shape changes.
// Golden review must confirm changed corners, not unrelated layout drift.
// Android release builds must contain arm64-v8a native libraries only.
// APK signature verification must pass the configured V2 scheme.
// Debug-certificate signing must be disclosed for test artifacts.
// Windows release packaging must include the executable and Flutter runtime.
// Both final artifacts must receive fresh SHA-256 hashes.
