// MIUIX v1.0.9 NavigationRail parity contract.
//
// Authoritative component source:
// - miuix-ui/.../basic/NavigationRail.kt
//
// Authoritative example integration:
// - example/shared/src/commonMain/kotlin/AppContent.kt
// - example/shared/src/commonMain/kotlin/SettingsPage.kt
//
// ---------------------------------------------------------------------------
// Public NavigationRail surface
// ---------------------------------------------------------------------------
//
// Upstream NavigationRail accepts arbitrary ColumnScope content. It does not
// own a destination list, selected index, or selection callback.
//
// MiuixNavigationRail.source is the literal Flutter form. Its source inputs
// are:
// - nullable arbitrary header;
// - color, defaulting to surface;
// - showDivider = true;
// - defaultWindowInsetsPadding = true;
// - minWidth = 80dp;
// - mode = IconAndText;
// - an arbitrary list of content widgets.
//
// The unnamed items/selectedIndex constructor is retained solely for
// compatibility with earlier flutter_miuix applications.
//
// Source modifier order is:
// 1. caller modifier;
// 2. fillMaxHeight;
// 3. optional status-bar vertical inset padding;
// 4. optional display-cutout start inset padding;
// 5. optional navigation-bar start inset padding;
// 6. surface background.
//
// Insets are consumed by consecutive modifiers and therefore must not be
// summed when they overlap.
//
// The content column has an exact width of minWidth, fills the available
// height, scrolls vertically, and owns 24dp top and bottom padding.
//
// A non-null header is invoked directly and followed by a separate 24dp
// spacer. No size, alignment, tint, or click behavior is added to the header.
//
// The optional VerticalDivider is a Row sibling after the column. Its default
// 0.75dp width increases the complete rail width from 80dp to 80.75dp.
//
// The rail background covers its inset padding, content, and divider region.
//
// ---------------------------------------------------------------------------
// Public NavigationRailItem
// ---------------------------------------------------------------------------
//
// MiuixNavigationRailItem is a rendered widget, not destination data.
//
// Its controlled source inputs are:
// - selected;
// - onClick;
// - icon;
// - label;
// - enabled = true.
//
// The display mode comes from the nearest MiuixNavigationRail.source through
// the Flutter counterpart of LocalNavigationRailDisplayMode. A standalone
// item defaults to IconAndText.
//
// The source takes one ImageVector and uses that same artwork in every state.
// A separate selected icon is not part of NavigationRailItem.kt.
//
// Every icon is forced to 28dp and receives the resolved tint.
//
// Every item fills the rail width, uses 12dp vertical outer padding, centers
// content horizontally and vertically, and applies animateContentSize.
//
// animateContentSize uses the Compose medium-low critically damped spring:
// stiffness 400, damping ratio 1, and one-pixel visibility threshold.
//
// It displays the new content immediately while interpolating and clipping the
// parent size. It does not retain or cross-fade the old content.
//
// IconAndText:
// - 28dp icon;
// - 4dp spacer;
// - 12sp centered label.
//
// IconOnly:
// - 28dp icon only.
//
// TextOnly:
// - no icon;
// - 14sp centered label;
// - 4dp extra vertical label padding.
//
// IconWithSelectedLabel:
// - every item keeps its 28dp icon;
// - only the selected item adds the 4dp spacer and 12sp label.
//
// Selected text is Bold. Unselected text is Normal.
//
// Tint alpha:
// - selected idle = 1.0;
// - unselected idle = 0.4;
// - selected pressed = 0.5;
// - unselected pressed = 0.6.
//
// Disabled items keep their ordinary idle tint. They do not press or click.
//
// pointerInput/detectTapGestures adds no ripple, scale, capsule, background,
// haptic, tooltip, or Material indication.
//
// The source Image publishes the label with Role.Image. Because the click is
// implemented with pointerInput rather than clickable, the item itself does
// not publish an accessibility click action. The source constructor preserves
// that behavior; the older compatibility constructor retains its historical
// button semantics.
//
// ---------------------------------------------------------------------------
// Defaults
// ---------------------------------------------------------------------------
//
// NavigationRailDefaults maps to MiuixNavigationRailDefaults:
// - MinWidth = 80dp;
// - VerticalPadding = 24dp;
// - HeaderSpacing = 24dp;
// - IconSize = 28dp;
// - IconTextSpacing = 4dp;
// - ItemVerticalPadding = 12dp;
// - LabelFontSize = 12sp;
// - TextOnlyFontSize = 14sp;
// - TextOnlyVerticalPadding = 4dp;
// - SelectedPressedAlpha = 0.5;
// - UnselectedPressedAlpha = 0.6;
// - UnselectedAlpha = 0.4.
//
// ---------------------------------------------------------------------------
// Localized wide-screen example
// ---------------------------------------------------------------------------
//
// WideScreenContent renders NavigationRail only when showNavigationBar is
// true. The localized Flutter example now uses MiuixNavigationRail.source and
// one MiuixNavigationRailItem for each of the five original destinations.
//
// Destination order remains:
// - 主页;
// - 图标;
// - 颜色;
// - 下拉菜单;
// - 设置.
//
// Selection compares the pager page with each item index. Clicking an item
// animates the existing pager to that index.
//
// Settings exposes the source four-entry NavigationRail Mode preference only
// on wide screens while navigation is enabled. Visible labels are localized;
// option order and stored indices remain source-identical.
