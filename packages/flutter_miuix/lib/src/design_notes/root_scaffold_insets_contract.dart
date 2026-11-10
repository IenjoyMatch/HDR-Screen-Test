// MIUIX v1.0.9 root Scaffold and navigation-inset contract.
//
// Purpose
// -------
// This note records the measurement behavior shared by the library and sample.
// It exists because Flutter Scaffold and Compose Scaffold use different models.
// The original sample always measures its page content at full window height.
// The bottom navigation is measured separately and painted over that content.
// A content-padding value tells scroll containers how far their final item moves.
// Therefore the page viewport itself is never shortened by a compact bottom bar.
// This distinction keeps scrollable content visible through transparent regions.
// It also avoids reserving the same navigation height in two different layers.
//
// Compact regular navigation
// --------------------------
// The regular navigation item row is 64dp high in the original component.
// A separate 0.75dp divider is measured immediately above that item row.
// The system-navigation inset is appended below the row on edge-to-edge hosts.
// Measured height is consequently 64.75dp plus the safe bottom inset.
// The root pager still extends to the physical bottom edge of the application.
// Each page uses the measured value as its final scroll-content bottom padding.
// A device without a bottom safe inset therefore reports exactly 64.75dp.
// An Android device with a 24dp navigation inset reports exactly 88.75dp.
// The navigation surface may be opaque without changing the measurement model.
// Enabling glass changes its paint and blur behavior, not its occupied height.
// Switching labels or icons also leaves the outer 64dp measurement unchanged.
//
// Hidden navigation
// -----------------
// Hiding compact navigation removes the component height from content padding.
// The platform safe bottom inset remains because page controls must stay usable.
// A test environment with a zero safe inset therefore receives zero padding.
// A gesture-navigation device continues to receive its reported bottom inset.
// The pager remains full height in both cases and no invisible bar is retained.
// Animated removal must not leave the old 64.75dp padding afterward.
// Animated insertion must update padding with the same state as the visible bar.
// Wide layouts follow the same hidden behavior because they have no bottom bar.
// Their navigation rail affects horizontal width rather than vertical padding.
//
// Standard floating navigation
// ----------------------------
// The HyperOS 4 floating surface is calibrated to 58dp around 52dp targets.
// Its pill is placed above a project-calibrated 16dp visual breathing space.
// Android appends the reported navigation or gesture inset to that space.
// A zero-inset Android or Windows layout therefore reports 74dp total padding.
// A 24dp Android inset produces 58dp plus 40dp, or 98dp, total padding.
// The 52dp item hit region and selected visual surface are independently tunable.
// Only the pill participates in surface color, shadow, clipping, and glass blur.
// The rectangular region around it must reveal the already-laid-out page.
// Its rounded-corner shadow must be clipped to the same pill-shaped boundary.
// Equal-width destinations divide the pill's usable width, not the screen width.
// Localization may change glyph widths but cannot change destination allocation.
//
// HyperOS 4 horizontal destination geometry
// -----------------------------------------
// The combined display mode stacks its icon above its one-line label.
// Its 24dp icon and label remain horizontally centered on the same ruler.
// The complete visible group remains inside the 52dp selection material.
// An eight-dp total horizontal content inset prevents edge collisions.
// The icon-label gap resolves from a dedicated project-calibrated theme token.
// Xiaomi has not published that gap as a developer-facing platform constant.
// Labels scale down only after each destination has received its equal width.
// A long English label cannot increase either the item or outer pill width.
// Text-only and icon-only modes keep the same item and selection rectangles.
// Switching modes therefore changes content without moving destination centers.
// The selected surface moves between those centers as one continuous object.
// Direct horizontal drag owns the bottom-bar gesture rather than the page pager.
// The drag position follows logical direction and therefore mirrors under RTL.
// Crossing an enabled destination emits one segment-tick haptic transaction.
// The callback commits only after release so page content does not churn mid-drag.
// A critically damped stiffness-1000 spring retains normalized release velocity.
// During drag, every selector edge receives an extra two-dp project inset.
// A three-item 84x52 surface therefore becomes 80x48 while manipulated.
// This intentional shrink differs from the expanding iOS liquid selector.
// Reduced-motion mode preserves the same endpoint geometry without interpolation.
// Logical-start placement makes the icon-label row naturally mirror under RTL.
// Badge rulers are converted from the icon's actual physical anchor position.
// A wide badge may extend toward logical start but not beyond logical end.
// A tall badge must not paint above the complete destination hit region.
// Tests cover two- and five-item widths, Chinese, English, RTL, and large badges.
// Golden baselines preserve the near-full selector in light and dark.
//
// iOS-like floating navigation
// ----------------------------
// The optional iOS-like extension uses a 64dp navigation panel.
// With no safe inset it keeps the same 36dp desktop-style lower breathing room.
// With a safe inset it uses an 8dp visual gap followed by that inset.
// A 24dp inset therefore produces a 96dp total content-padding measurement.
// The liquid-glass material belongs only to the panel and selected item layers.
// The surrounding rectangle stays fully transparent at every glass intensity.
// Changing the five-level blur setting cannot alter panel geometry or padding.
// The page remains interactive and visible outside the floating panel bounds.
//
// Top application bar interaction
// -------------------------------
// Root pages begin below the expanded title content on their initial scroll state.
// The top application bar itself is painted above the page viewport.
// Scrolling upward may move list content behind the top application bar layer.
// Opaque and glass top bars retain the same content-inset calculation.
// The Android status-bar inset is part of the top bar's safe layout region.
// Edge-to-edge drawing may extend its surface behind the status-bar icons.
// The first page item must never begin beneath the title before scrolling occurs.
// Bottom navigation changes must not reset or alter the current top scroll offset.
//
// Snackbar and transient content
// ------------------------------
// Snackbar placement uses the actually rendered bottom-navigation measurement.
// A snackbar cannot be obscured behind either regular or floating navigation.
// Hidden navigation allows the snackbar to descend to the remaining safe inset.
// A measured floating action button takes precedence over the bottom-bar anchor.
// Its complete top clearance includes its height and the authored 12dp spacing.
// A bottom-start, bottom-center, or bottom-end toolbar is a second obstruction.
// Snackbar placement takes the larger of the FAB and bottom-toolbar clearances.
// The toolbar is first lifted 4dp, then the snackbar leaves another rounded 4dp.
// Top- and center-aligned toolbar positions do not affect bottom feedback.
// Arbitrary Flutter slot sizes are measured instead of assuming default controls.
// Transformed toolbar coordinates are used because its lift is placement-only.
// These overlays do not reserve an additional permanent strip in the root pager.
// Dialogs and sheets use their own window insets and do not reuse page padding.
//
// Adaptive layout
// ---------------
// Widths below 600dp always use the compact bottom-navigation arrangement.
// Widths from 600dp use split panes only below the source's 1.2 aspect threshold.
// Widths of at least 840dp use the split-pane navigation rail unconditionally.
// The wide pager fills all horizontal space remaining beside the rail.
// It does not receive a centered maximum-width wrapper or artificial side gutter.
// Wide pages retain only the platform safe bottom inset for their scroll content.
// Returning to compact mode restores the active bottom-bar measurement at once.
//
// Verification
// ------------
// Unit tests lock hidden, regular, floating, and iOS-like inset calculations.
// Widget tests assert that a 390 by 844 compact pager remains exactly 844 high.
// Widget tests assert a 64dp row plus 0.75dp divider without system insets.
// Widget tests compare list bottom padding with the rendered navigation height.
// Floating-navigation tests assert that the page extends behind the pill region.
// Glass tests verify that real page pixels remain visible through blurred panels.
// Snackbar tests verify that feedback is painted above the active navigation bar.
// Focused tests also verify FAB priority and bottom-only toolbar avoidance.
// The 4dp toolbar-to-snackbar gap rounds independently at fractional density.
// Adaptive tests lock the 600dp ratio boundary and unconditional 840dp boundary.
// Any future navigation metric change must update source evidence and these tests.
// Static analysis and the package comment-ratio gate must remain clean afterward.
