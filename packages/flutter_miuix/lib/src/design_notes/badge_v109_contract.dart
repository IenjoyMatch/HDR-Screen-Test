// Badge / BadgedBox current-source contract.
//
// Authority:
// C:\Code\miuix-src-current\miuix-ui\src\commonMain\kotlin\
// top\yukonga\miuix\kmp\basic\Badge.kt
// at commit be0aa8386b30cef46109b9103b3232b53af46733.
//
// Public source surfaces:
// - Badge draws either a six-dp dot or a content badge with a sixteen-dp
//   minimum size.
// - Content badges add four dp of horizontal padding on both sides.
// - CircleShape remains circular for square bounds and becomes a stadium when
//   content expands the width beyond the height.
// - The default container and content channels are error and onError.
// - Content inherits footnote2 merged with a centered, untrimmed sixteen-sp
//   line height.
// - Badge contains no pointer consumer; input continues to belong to the
//   anchor or its owning navigation destination.
//
// BadgedBox measurement:
// - The badge is measured first.
// - Badge measurement copies the complete incoming Constraints and clears
//   only minHeight.
// - In particular, minWidth is not cleared. A directly tight-width BadgedBox
//   therefore applies that same minimum width to its badge.
// - The anchor is measured with the original constraints.
// - The complete layout reports exactly the anchor width and height.
// - FirstBaseline and LastBaseline are forwarded only from the anchor; badge
//   text cannot change the parent's baseline.
//
// BadgedBox placement:
// - Badge width greater than the rounded six-dp dot size selects the content
//   placement branch.
// - A content badge uses twelve-dp horizontal and fourteen-dp vertical
//   offsets.
// - A dot badge uses six dp for both offsets.
// - Placement is logical-direction-relative, so top-end mirrors in RTL.
// - badgeBounds rulers may clamp top and logical-end paint within a navigation
//   destination without changing the anchor-owned layout size.
// - Clamping translates the badge; it does not clip the BadgedBox or its
//   destination.
// - In LTR the badge's physical right edge cannot pass logical end. In RTL the
//   badge's physical left edge cannot pass logical end.
// - Logical start and bottom overflow remain legal in both directions.
//
// Flutter translation:
// - MiuixBadge.source is the direct Badge content surface.
// - MiuixBadgedBox.source is the direct anchor-owned layout.
// - The compatibility unnamed constructors remain package extensions and do
//   not redefine source measurement.
// - _RenderMiuixBadgedBox must call constraints.copyWith(minHeight: 0); adding
//   minWidth: 0 changes the public source contract.
// - Source owners that measure NavigationItemIcon or FlowRow children with
//   zero minimum dimensions must reproduce that loose outer measurement before
//   constructing BadgedBox. They must not force every BadgedBox itself to
//   ignore an incoming minimum width.
// - The expandable NavigationRail therefore releases the tight Positioned
//   cell around the whole icon/badge pair while keeping only the icon anchor at
//   twenty-eight dp.
// - The localized BadgeSection does the same inside its integer-pixel
//   SpaceEvenly adapter because Compose FlowRow measures each child loosely.
// - Navigation adapters pass the complete destination rectangle in anchor-local
//   coordinates to the private BadgedBox render object.
// - Regular NavigationBar converts its centered 26dp icon and live 8..19dp top
//   position into that rectangle for all icon-bearing display modes.
// - FloatingNavigationBar converts its equal item size and centered 28dp or
//   24dp icon into the same rectangle.
// - Classic NavigationRail includes the source twelve-dp outer item padding.
// - Expandable NavigationRail uses its live interpolated icon X/Y and item
//   width/height, including the physical RTL X conversion.
// - No navigation adapter uses Clip.hardEdge as a substitute for badgeBounds;
//   clipping would incorrectly remove legal logical-start overflow.
//
// Regression evidence:
// - A direct twenty-eight-dp tight BadgedBox produces a 28 x 16 content badge.
// - The expandable NavigationRail still produces a natural content-badge width
//   below twenty-eight dp in both collapsed and expanded states.
// - The localized 420dpi FlowRow retains a sixteen-pixel dot and the original
//   source anchor positions.
// - Oversized arbitrary badges touch the destination top and logical-end edge
//   in regular, floating, classic-rail, and expandable-rail layouts.
// - The regular-bar oversized case mirrors from physical right to physical
//   left under RTL.
// - Badge six-state goldens, the full library suite, and the full example suite
//   must remain green.
