// HyperOS 4 SliverTopAppBar contract.
//
// This documentation-only library records the package rules for large-title
// sliver geometry, progressive material, scroll overlap, and source migration.
// Published Xiaomi visuals guide the hierarchy; numeric defaults below remain
// explicit project calibration rather than claimed private design tokens.
//
// Initial hierarchy contract:
// - The large page title is the primary first-screen heading.
// - The first content sliver begins after the expanded title region.
// - No opaque spacer is inserted between the title and first content row.
// - A subtitle increases the authored title region through its own token.
// - Bottom content reserves its public height after the title measurement.
// - Expanded bottom padding collapses independently with the title fraction.
// - System top inset remains inside the bar's sampled material surface.
//
// HyperOS 4 geometry contract:
// - sliverAppBarExpandedHeight owns the ordinary large-title extent.
// - sliverAppBarExpandedSubtitleHeight owns the supporting-title extent.
// - sliverAppBarCollapsedHeight owns the pinned ordinary endpoint.
// - sliverAppBarCollapsedSubtitleHeight owns the supporting endpoint.
// - The default 104dp expanded height is project calibrated.
// - The default 126dp subtitle height is project calibrated.
// - Explicit widget heights override the corresponding theme roles.
// - The visible MiuixTopAppBar receives the same resolved collapsed height as
//   its SliverPersistentHeader, preventing a transparent mismatch strip.
// - A maximum smaller than the minimum resolves to the minimum safely.
//
// Scroll and overlap contract:
// - Sliver layout supplies collapseFraction directly from shrinkOffset.
// - The component never notifies a scroll controller during render layout.
// - The first collapse range moves content toward the compact title endpoint.
// - Further scrolling moves content behind the pinned glass surface.
// - Pinned false allows the complete header to leave with ordinary slivers.
// - Floating re-entry remains owned by SliverPersistentHeader.
// - snap requires floating and uses sliverAppBarSnapMotion.
// - Reduced motion makes autonomous snap settlement immediate.
// - Direct finger-driven scrolling remains frame-synchronous in every mode.
//
// Progressive material contract:
// - Expanded pages begin as one continuous scene without an opaque top block.
// - Collapse reveals the project progressive blur and semantic tint channels.
// - Content behind the pinned header remains visible through the local sample.
// - Glass clipping is exactly the current header extent.
// - The bar does not blur content below the current pinned boundary.
// - Global glass enablement and five-level intensity remain authoritative.
// - glass false retains geometry with a readable semantic solid fallback.
// - Gaussian mode remains available for a uniformly sampled top surface.
//
// Compatibility contract:
// - MiuixSliverTopAppBar.source retains 94dp ordinary expanded height.
// - Source subtitle expansion retains 114dp.
// - Source ordinary collapse retains 56dp.
// - Source subtitle collapse retains 62dp.
// - Source still supports pinned, floating, snap, glass, and bottom content.
// - Explicit source height overrides remain valid for migrated applications.
// - Existing ordinary constructor arguments remain source compatible.
//
// Verification contract:
// - Delegate tests inspect resolved minimum and maximum extents.
// - Visible-bar tests inspect the forwarded expanded and collapsed heights.
// - Geometry tests prove first content begins below the expanded title.
// - Scrolled geometry proves content intersects the pinned header region.
// - Snap tests cover theme timing and runtime reduced-motion changes.
// - Expanded and collapsed goldens cover standard and source construction.
// - Light and dark collapsed images include content behind progressive glass.
// - These checks prove project behavior, not unavailable official dp values.
library;
