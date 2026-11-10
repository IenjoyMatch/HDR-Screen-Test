// MIUIX v1.0.9 TabRow parity contract.
//
// Authoritative component source:
// - miuix-ui/.../basic/TabRow.kt
//
// Authoritative sample source:
// - example/shared/.../component/TabRowSection.kt
//
// This documentation records the explicit `.source` compatibility obligation
// for both TabRow variants. New ordinary constructors follow the separate
// HyperOS 4 tab-row contract and must not be validated against these pixels.
// It prevents a generic Material TabBar from being treated as equivalent only
// because it has text labels and a moving selection background.
//
// ---------------------------------------------------------------------------
// Public variants and state
// ---------------------------------------------------------------------------
//
// TabRow and TabRowWithContour receive:
// - a list of String labels;
// - selectedTabIndex;
// - onTabSelected;
// - colors;
// - minimum and maximum item width;
// - total height;
// - item corner radius;
// - item spacing;
// - content alignment;
// - nullable interaction source;
// - nullable indication.
//
// MiuixTabRow.source and MiuixTabRowWithContour.source expose those same
// controls. Their selectedTabIndex path is fully controlled: a tap reports
// intent but never moves selection until the owner publishes the new index.
//
// TabController and onTap remain compatibility extensions for existing Flutter
// call sites. They do not change the behavior of the source-controlled path.
//
// Compose Indication is an open drawing interface and cannot cross framework
// boundaries. showIndication=false represents the source default null value;
// true installs flutter_miuix's source-matched MIUIX indication layer. The
// explicit source constructors keep false as their default.
//
// MiuixInteractionSource publishes pointer press state to external callers.
//
// ---------------------------------------------------------------------------
// Defaults and colors
// ---------------------------------------------------------------------------
//
// Ordinary defaults:
// - minimum width 76dp;
// - maximum width 98dp;
// - height 42dp;
// - corner radius 12dp;
// - spacing 9dp;
// - centered content.
//
// Contour defaults:
// - minimum width 62dp;
// - maximum width 84dp;
// - height 45dp;
// - item corner radius 8dp;
// - spacing 5dp;
// - outer content padding 5dp;
// - outer corner radius 13dp;
// - centered content.
//
// MiuixTabRowDefaults publishes the source's public variant dimensions and its
// tabRowColors factory. contourPadding remains a named constant so geometry
// tests can prove the source inset and derived outer radius independently.
//
// MiuixTabRowColors keeps four independent channels:
// - backgroundColor = surface;
// - contentColor = onSurfaceVariantSummary;
// - selectedBackgroundColor = surfaceContainer;
// - selectedContentColor = onBackground.
//
// Replacing one channel must not silently modify any other channel.
//
// ---------------------------------------------------------------------------
// Width allocation and density conversion
// ---------------------------------------------------------------------------
//
// For N tabs and spacing S:
// - totalSpacing = max(0, N - 1) * S;
// - ideal = (availableWidth - totalSpacing) / N.
//
// Empty lists return the variant minimum width and retain a fixed-height
// surface plus the remembered zero-offset indicator.
//
// When ideal is below minimum, the result is minimum and the row scrolls.
//
// When ideal is between minimum and maximum, the result is ideal.
//
// When ideal exceeds maximum:
// - use ideal if N maximum-width items plus spacing would leave unused width;
// - otherwise use maximum.
//
// This final branch intentionally lets short tab lists fill a wide surface.
//
// Compose converts each declared Dp measurement through roundToPx before
// placement. Flutter rounds spacing, widths, height, and contour padding into
// logical values at the active device pixel ratio. The contour outer radius is
// calculated from the declared item radius plus declared 5dp padding before
// painting; separately rounded layout padding must not be reused for it.
//
// ---------------------------------------------------------------------------
// Indicator and scrolling
// ---------------------------------------------------------------------------
//
// The ordinary TabRow derives its indicator offset directly from the selected
// index, so both its initial placement and later selection changes are
// immediate. TabRowWithContour snaps its initial nonzero selection, then
// animates later selected-index changes to:
// selectedTabIndex * (tabWidth + itemSpacing).
// Its duration is exactly 200ms and its easing is Linear.
//
// The selected item is independently centered when possible. The requested
// center offset is clamped by the horizontal scroll extent at both ends.
//
// The rendered indicator subtracts the current scroll offset so it remains
// attached to the selected item while the user drags the row.
//
// Both the indicator and clickable items use the same active MIUIX shape:
// continuous G2 rounding when enabled, ordinary rounded rectangles otherwise.
// Ordinary unselected items draw a 1dp outline-colored border. The selected
// ordinary item uses a zero-width border; contour items never draw a border.
//
// ---------------------------------------------------------------------------
// Items, text, and interaction
// ---------------------------------------------------------------------------
//
// Ordinary items fill the 42dp row and apply 12dp horizontal content padding.
// Their labels use body1 at 16sp.
//
// Contour items fill the 35dp inner row and apply no automatic horizontal
// padding. Their labels use body2 at 14sp.
//
// Selected labels are bold; unselected labels are normal weight.
//
// All labels are one line with ellipsis overflow.
//
// The caller contentAlignment applies inside every fixed-width item.
//
// Source items have no sink or tilt transform. An indication appears only
// when the caller supplies one.
//
// Each item exposes role Tab, selected state, and a tap action to Flutter's
// semantic tree. Flutter requires selected state on Tab roles, so publishing it
// is the faithful accessible equivalent of the visual source selection.
//
// Android expands selectable items to a centered 48dp minimum interactive
// target without changing their 42dp ordinary or 35dp contour measurements.
// At 420dpi this produces a 126px semantic and pointer target around the
// 110px ordinary or 92px contour visual. The LazyRow clips paint along its
// horizontal scroll axis while preserving those perpendicular expansion bands;
// the contour background itself is not a clip.
// A containing Card may clip paint to its squircle, but it must preserve the
// complete bounds of a partially visible tab semantic node, as Compose does.
//
// ---------------------------------------------------------------------------
// Localized source sample
// ---------------------------------------------------------------------------
//
// The example retains the original sample structure:
// - SmallTitle for TabRow;
// - an ordinary three-item controlled row;
// - 12dp gap below it;
// - a full-width Card with 16dp inside margin;
// - a six-item contoured row linked to a horizontally swipeable pager;
// - 12dp gap before the page text.
//
// Only visible strings are localized:
// - Tab 1...6 -> 标签 1...6;
// - Content of Tab X -> 标签 X 的内容.
//
// Localization must not change item counts, ordering, state ownership,
// horizontal padding, vertical spacing, pager behavior, or typography.

// ---------------------------------------------------------------------------
// Current-source requirement and evidence matrix
// ---------------------------------------------------------------------------
//
// TR-001 Requirement: Ordinary TabRow fills the complete incoming width before applying its caller modifier.
// TR-001 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-001 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-002 Requirement: Ordinary TabRow paints the unselected surface channel behind the complete 42dp row.
// TR-002 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-002 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-003 Requirement: Ordinary TabRow rounds its authored 42dp height independently at fractional density.
// TR-003 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-003 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-004 Requirement: Ordinary TabRow uses 76dp as the default minimum item width.
// TR-004 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-004 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-005 Requirement: Ordinary TabRow uses 98dp as the default maximum item width.
// TR-005 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-005 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-006 Requirement: Ordinary TabRow inserts exactly 9dp between neighboring items.
// TR-006 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-006 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-007 Requirement: Ordinary TabRow uses a 12dp item corner radius.
// TR-007 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-007 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-008 Requirement: Ordinary TabRow applies 12dp horizontal content padding inside each item.
// TR-008 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-008 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-009 Requirement: Ordinary TabRow renders labels with the source body1 16sp size.
// TR-009 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-009 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-010 Requirement: Ordinary TabRow renders selected labels with bold weight.
// TR-010 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-010 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-011 Requirement: Ordinary TabRow renders unselected labels with normal weight.
// TR-011 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-011 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-012 Requirement: Ordinary TabRow paints selected labels with selectedContentColor.
// TR-012 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-012 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-013 Requirement: Ordinary TabRow paints unselected labels with contentColor.
// TR-013 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-013 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-014 Requirement: Ordinary TabRow paints the selected indicator with selectedBackgroundColor.
// TR-014 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-014 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-015 Requirement: Ordinary TabRow draws a 1dp outline border only around unselected items.
// TR-015 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-015 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-016 Requirement: Ordinary TabRow resolves the unselected border from the outline semantic role.
// TR-016 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-016 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-017 Requirement: Ordinary TabRow gives the selected item a zero-width border.
// TR-017 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-017 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-018 Requirement: Ordinary TabRow reuses the same corner path for indicator and item border.
// TR-018 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-018 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-019 Requirement: Ordinary TabRow changes indicator position immediately when selection changes.
// TR-019 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-019 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-020 Requirement: Ordinary TabRow places an initial nonzero selection without an entrance animation.
// TR-020 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-020 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-021 Requirement: Ordinary TabRow keeps its indicator attached while the row is manually scrolled.
// TR-021 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-021 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-022 Requirement: Ordinary TabRow keeps its background visible when the tabs list is empty.
// TR-022 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-022 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-023 Requirement: Ordinary TabRow keeps a 76dp zero-selection indicator when the list is empty.
// TR-023 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-023 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-024 Requirement: Contour TabRow keeps a complete authored height of 45dp.
// TR-024 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-024 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-025 Requirement: Contour TabRow rounds its 45dp height independently at fractional density.
// TR-025 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-025 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-026 Requirement: Contour TabRow applies exactly 5dp outer content padding on every edge.
// TR-026 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-026 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-027 Requirement: Contour TabRow rounds each 5dp padding edge independently.
// TR-027 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-027 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-028 Requirement: Contour TabRow leaves a 35dp inner visual row at integer-density layouts.
// TR-028 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-028 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-029 Requirement: Contour TabRow uses 62dp as its default minimum item width.
// TR-029 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-029 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-030 Requirement: Contour TabRow uses 84dp as its default maximum item width.
// TR-030 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-030 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-031 Requirement: Contour TabRow inserts exactly 5dp between neighboring items.
// TR-031 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-031 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-032 Requirement: Contour TabRow uses an 8dp item corner radius.
// TR-032 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-032 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-033 Requirement: Contour TabRow derives its outer radius from authored 8dp plus authored 5dp.
// TR-033 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-033 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-034 Requirement: Contour TabRow does not derive the outer radius from an already rounded padding value.
// TR-034 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-034 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-035 Requirement: Contour TabRow uses a 13dp outer corner radius.
// TR-035 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-035 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-036 Requirement: Contour TabRow paints the unselected background on the outer surface.
// TR-036 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-036 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-037 Requirement: Contour TabRow paints selectedBackgroundColor only on the moving inner indicator.
// TR-037 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-037 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-038 Requirement: Contour TabRow does not draw ordinary-item outline borders.
// TR-038 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-038 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-039 Requirement: Contour TabRow renders labels with the source body2 14sp size.
// TR-039 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-039 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-040 Requirement: Contour TabRow applies no automatic horizontal text padding.
// TR-040 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-040 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-041 Requirement: Contour TabRow snaps the indicator to an initial nonzero selection.
// TR-041 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-041 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-042 Requirement: Contour TabRow animates only later selection changes.
// TR-042 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-042 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-043 Requirement: Contour TabRow uses an exact 200ms indicator duration.
// TR-043 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-043 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-044 Requirement: Contour TabRow uses LinearEasing for its indicator animation.
// TR-044 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-044 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-045 Requirement: Contour TabRow retargets the moving indicator from its live position.
// TR-045 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-045 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-046 Requirement: Contour TabRow keeps indicator movement independent from pager spring movement.
// TR-046 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-046 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-047 Requirement: Contour TabRow does not clip its children to the outer background silhouette.
// TR-047 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-047 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-048 Requirement: Contour TabRow keeps its background surface when the tabs list is empty.
// TR-048 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-048 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-049 Requirement: Contour TabRow keeps a 62dp zero-selection indicator when the list is empty.
// TR-049 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-049 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-050 Requirement: Width calculation subtracts all inter-item spacing before dividing available width.
// TR-050 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-050 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-051 Requirement: Width calculation returns the variant minimum for zero tabs.
// TR-051 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-051 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-052 Requirement: Width calculation returns the variant minimum when usable content width is nonpositive.
// TR-052 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-052 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-053 Requirement: Width calculation returns the ideal width when it lies inside the min-max interval.
// TR-053 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-053 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-054 Requirement: Width calculation clamps to the minimum when ideal width is too small.
// TR-054 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-054 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-055 Requirement: Width calculation considers the complete max-width row when ideal width is too large.
// TR-055 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-055 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-056 Requirement: Width calculation lets a short list fill unused wide space.
// TR-056 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-056 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-057 Requirement: Width calculation uses the maximum when maximum-width items already consume the viewport.
// TR-057 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-057 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-058 Requirement: Width calculation never includes contour outer padding in the item-content width twice.
// TR-058 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-058 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-059 Requirement: Width calculation preserves finite values under a zero-width constraint.
// TR-059 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-059 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-060 Requirement: Each declared spacing and width is converted to physical pixels independently.
// TR-060 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-060 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-061 Requirement: Centering computes the selected item's midpoint against the visible viewport.
// TR-061 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-061 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-062 Requirement: Centering clamps the requested offset to the leading scroll extent.
// TR-062 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-062 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-063 Requirement: Centering clamps the requested offset to the trailing scroll extent.
// TR-063 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-063 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-064 Requirement: Initial centering uses a nonanimated jump matching scrollToItem.
// TR-064 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-064 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-065 Requirement: Repeated layout with the same selection and target avoids redundant scroll work.
// TR-065 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-065 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-066 Requirement: A viewport-size change with unchanged selection uses nonanimated repositioning.
// TR-066 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-066 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-067 Requirement: A later selection change uses the source animated scroll path.
// TR-067 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-067 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-068 Requirement: A newer centering request supersedes an older scheduled post-frame request.
// TR-068 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-068 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-069 Requirement: Manual horizontal scrolling subtracts the live scroll offset from indicator placement.
// TR-069 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-069 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-070 Requirement: Manual horizontal scrolling subtracts the same live offset from semantic placement.
// TR-070 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-070 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-071 Requirement: Horizontal overscroll uses clamping behavior and does not add a Flutter glow.
// TR-071 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-071 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-072 Requirement: The horizontal viewport does not clip vertical 48dp target expansion.
// TR-072 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-072 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-073 Requirement: Every visual item remains exactly its authored width despite the expanded target.
// TR-073 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-073 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-074 Requirement: Every visual item remains exactly its authored height despite the expanded target.
// TR-074 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-074 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-075 Requirement: Android interaction height is centered at 48dp around an ordinary 42dp visual.
// TR-075 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-075 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-076 Requirement: Android interaction height is centered at 48dp around a contour 35dp visual.
// TR-076 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-076 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-077 Requirement: At 420dpi the minimum interaction height rounds to exactly 126 physical pixels.
// TR-077 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-077 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-078 Requirement: At 420dpi the ordinary painted height rounds to exactly 110 physical pixels.
// TR-078 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-078 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-079 Requirement: At 420dpi the contour inner painted height rounds to exactly 92 physical pixels.
// TR-079 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-079 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-080 Requirement: At 420dpi ordinary target expansion contributes eight pixels above and below.
// TR-080 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-080 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-081 Requirement: At 420dpi contour target expansion contributes seventeen pixels above and below.
// TR-081 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-081 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-082 Requirement: A pointer inside the painted item remains owned by MiuixPressable.
// TR-082 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-082 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-083 Requirement: A pointer only in the expansion band is owned by the target bridge.
// TR-083 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-083 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-084 Requirement: The expansion bridge does not register a duplicate recognizer inside painted bounds.
// TR-084 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-084 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-085 Requirement: The expansion bridge clears external pressed state on pointer up.
// TR-085 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-085 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-086 Requirement: The expansion bridge clears external pressed state on pointer cancellation.
// TR-086 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-086 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-087 Requirement: The expansion bridge clears external pressed state when detached.
// TR-087 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-087 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-088 Requirement: The expansion bridge forwards an accepted expanded-band tap exactly once.
// TR-088 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-088 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-089 Requirement: Expanded targets remain available inside a vertically scrolling Home page.
// TR-089 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-089 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-090 Requirement: Expanded targets remain available when nested inside a noninteractive Card.
// TR-090 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-090 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-091 Requirement: Each tab exposes exactly one semantic node rather than visual and overlay duplicates.
// TR-091 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-091 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-092 Requirement: Each semantic node exposes the Tab role.
// TR-092 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-092 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-093 Requirement: Each semantic node exposes the current selected state.
// TR-093 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-093 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-094 Requirement: Each semantic node exposes an enabled state.
// TR-094 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-094 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-095 Requirement: Each semantic node exposes a tap action.
// TR-095 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-095 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-096 Requirement: Each semantic node uses the localized visible label.
// TR-096 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-096 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-097 Requirement: Each semantic node uses the ambient text direction.
// TR-097 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-097 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-098 Requirement: Visual Text semantics are excluded after the dedicated target node is created.
// TR-098 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-098 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-099 Requirement: Semantic targets move with the horizontal scroll controller.
// TR-099 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-099 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-100 Requirement: Partially visible semantic targets retain their complete source rectangle.
// TR-100 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-100 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-101 Requirement: A Card paint clip does not truncate a partially visible child semantic rectangle.
// TR-101 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-101 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-102 Requirement: A Card still clips painted pixels and pointer input to its authored shape.
// TR-102 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-102 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-103 Requirement: The surface semantics correction does not change Card visual golden images.
// TR-103 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-103 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-104 Requirement: The surface semantics correction does not change TabRow visual golden images.
// TR-104 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-104 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-105 Requirement: The selected ordinary target begins at the same x coordinate as its indicator.
// TR-105 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-105 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-106 Requirement: The second ordinary target follows the independently rounded spacing boundary.
// TR-106 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-106 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-107 Requirement: The final contour target may extend beyond the Card while remaining screen-clipped.
// TR-107 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-107 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-108 Requirement: At 420dpi the final visible contour target reaches x=1080 in the reference viewport.
// TR-108 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-108 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-109 Requirement: The ordinary three-item fixture preserves source item count and order.
// TR-109 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-109 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-110 Requirement: The contour six-item fixture preserves source item count and order.
// TR-110 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-110 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-111 Requirement: Only sample strings are translated from Tab to 标签.
// TR-111 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-111 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-112 Requirement: The localized content string keeps the selected tab identity.
// TR-112 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-112 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-113 Requirement: The ordinary fixture owns its selected index in surrounding state.
// TR-113 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-113 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-114 Requirement: The contour fixture derives selected state from the pager current page.
// TR-114 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-114 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-115 Requirement: Tapping a contour tab launches the pager animation but not a second indicator spring.
// TR-115 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-115 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-116 Requirement: Swiping the pager updates the selected contour label.
// TR-116 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-116 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-117 Requirement: The pager continues to use the Compose default critically damped spring mapping.
// TR-117 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-117 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-118 Requirement: The Card retains 16dp source inside margin around the contour fixture.
// TR-118 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-118 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-119 Requirement: The sample retains 12dp spacing between contour row and content text.
// TR-119 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-119 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-120 Requirement: The sample retains the source natural body text line box.
// TR-120 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-120 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-121 Requirement: The sample retains 12dp bottom margin after the contour Card.
// TR-121 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-121 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-122 Requirement: Runtime comparison normalizes only one whole-page vertical scroll offset.
// TR-122 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-122 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-123 Requirement: After normalization ordinary target x and height match the native UI tree.
// TR-123 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-123 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-124 Requirement: After normalization contour target x and height match the native UI tree.
// TR-124 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-124 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-125 Requirement: After normalization the content row keeps the same relative y coordinate.
// TR-125 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-125 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-126 Requirement: Native and Flutter captures use the same 1080 by 2400 viewport.
// TR-126 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-126 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-127 Requirement: Native and Flutter captures use the same 420dpi density.
// TR-127 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-127 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-128 Requirement: Flutter runtime evidence is collected from an x86_64 Release build.
// TR-128 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-128 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-129 Requirement: Native runtime evidence comes from the current local main commit.
// TR-129 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-129 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-130 Requirement: Release log review must contain no FlutterError or RenderFlex failure.
// TR-130 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-130 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-131 Requirement: Component tests must lock the ordinary immediate indicator path.
// TR-131 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-131 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-132 Requirement: Component tests must lock the contour 200ms linear path.
// TR-132 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-132 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-133 Requirement: Component tests must lock initial contour snap behavior.
// TR-133 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-133 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-134 Requirement: Component tests must lock the 48dp semantic height.
// TR-134 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-134 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-135 Requirement: Component tests must tap the expansion band outside painted bounds.
// TR-135 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-135 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-136 Requirement: Component tests must lock selected and unselected border sides.
// TR-136 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-136 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-137 Requirement: Component tests must lock the four independent color channels.
// TR-137 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-137 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-138 Requirement: Component tests must lock both smooth and rounded fallback shapes.
// TR-138 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-138 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-139 Requirement: Component tests must lock empty-list fixed surfaces.
// TR-139 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-139 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-140 Requirement: Component tests must lock width allocation at narrow and wide constraints.
// TR-140 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-140 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-141 Requirement: Example tests must retain the 318px contour Card height at 420dpi.
// TR-141 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-141 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-142 Requirement: Full library tests must run after any surface clipping change.
// TR-142 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-142 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-143 Requirement: Full example tests must run after any TabRow behavior change.
// TR-143 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-143 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-144 Requirement: Static analysis must report no issue in library and example.
// TR-144 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-144 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-145 Requirement: The component-name comparison gate remains coverage evidence only.
// TR-145 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-145 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-146 Requirement: Same-device screenshots and UI trees remain the visual and geometry evidence.
// TR-146 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-146 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-147 Requirement: Passing tests do not replace the paired native Release comparison.
// TR-147 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-147 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-148 Requirement: This contract must be updated if current TabRow.kt changes its animation branches.
// TR-148 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-148 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-149 Requirement: This contract must be updated if Android minimum interactive sizing changes.
// TR-149 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-149 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-150 Requirement: This contract must be updated if Card clipping changes semantic geometry.
// TR-150 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-150 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-151 Requirement: The global parity goal remains incomplete until every remaining section has equivalent evidence.
// TR-151 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-151 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
// TR-152 Requirement: The horizontal viewport clips off-screen label paint at its main-axis bounds without clipping the independent 48dp vertical target.
// TR-152 Authority: current TabRow.kt, TabRowSection.kt, or Compose Android semantics behavior.
// TR-152 Proof: focused widget coverage plus the paired 420dpi Release evidence where applicable.
