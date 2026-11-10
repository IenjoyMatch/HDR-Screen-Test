// HyperOS 4 collection-group contract.
//
// This documentation-only library separates three related visual levels:
// grouped list containers, ordinary selectable tree rows, and the temporary
// lifted proxy of a reorderable list. They must not all become glass cards.
// Numeric defaults remain project calibration unless explicitly published.
//
// Grouped-list contract:
// - MiuixListSection represents one semantic information group.
// - The standard constructor owns one clipped content-glass surface.
// - Child rows remain caller-owned widgets inside that one surface.
// - A child row does not receive a second backdrop filter automatically.
// - Title and footer remain outside the sampled group silhouette.
// - Internal dividers remain weak, inset, and absent at outer boundaries.
// - settingsGroupCornerRadius supplies the standard continuous outline.
// - contentSurfaceBlur supplies the standard backdrop sigma.
// - contentSurfaceTintOpacity supplies the semantic tint channel.
// - Global enableGlass and five-level intensity remain authoritative.
// - showGlassSpecular may disable highlight without disabling blur.
// - glass false retains new geometry as a readable low-contrast solid group.
// - MiuixListSection.source restores the former opaque 18dp group.
//
// Tree-row contract:
// - An unselected tree row remains visually quiet and transparent.
// - The selected row uses semantic selection color, not backdrop glass.
// - Standard row shape resolves from collectionRowCornerRadius.
// - rowCornerRadius allows an explicit per-tree shape override.
// - MiuixTreeView.source restores the former fixed 15dp row radius.
// - Expansion, indentation, asynchronous loading, and semantics stay intact.
// - A source row does not revert current keyboard or accessibility fixes.
// - Disclosure chevrons continue to respect logical direction and expansion.
// - Reduced motion changes transition timing, not tree hierarchy state.
//
// Reorderable-list contract:
// - Resting rows may use MiuixReorderableItem as a low-contrast row helper.
// - Standard resting and lifted shapes share collectionRowCornerRadius.
// - The lift proxy scales and gains shadow without becoming a glass panel.
// - proxyCornerRadius explicitly overrides only the temporary lifted shape.
// - MiuixReorderableList.source restores the former 18dp proxy shape.
// - MiuixReorderableItem.source restores the former 18dp resting row shape.
// - Drag position remains synchronous with the pointer in reduced motion.
// - Reduced motion removes autonomous lift interpolation only.
// - Long-press start and reorder completion retain semantic haptic roles.
// - Caller data and stable keys remain the authoritative ordering state.
//
// Layout contract:
// - Nested collection scroll views do not consume route safe insets again.
// - Empty sections and trees remain structurally valid and content-driven.
// - Tree indentation is directional and does not hard-code physical left.
// - Reorder handles retain a usable touch, pointer, and semantic target.
// - Collection rows retain authored heights rather than equalizing all groups.
// - Short collection content does not expand to fill a page by default.
//
// Verification contract:
// - Group tests inspect theme blur, tint, shape, specular, and solid fallback.
// - Source tests inspect opaque 18dp grouping.
// - Tree tests inspect theme and source row radii through stable row keys.
// - Proxy tests inspect theme and source lifted Material outlines.
// - Existing drag, keyboard, async loading, and reduced-motion tests remain.
// - Light and dark goldens compare standard and source group hierarchy.
// - Complex backdrops appear through the group only, not every row.
// - These checks prove package behavior, not unavailable official pixel data.
library;
