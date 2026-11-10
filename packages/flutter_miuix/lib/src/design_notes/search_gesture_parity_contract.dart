/// Maintenance contract for source search and nested gesture parity.
///
/// The root example pager remains horizontally swipeable from ordinary page
/// content because the upstream sample exposes page user scrolling by default.
/// A horizontal control owns a pointer sequence that begins inside its track.
/// The root pager must not change destination while that control is dragging.
/// MiuixSlider uses a horizontal recognizer rather than a generic pan recognizer.
/// MiuixRangeSlider follows the same horizontal gesture ownership rule.
/// Color channel sliders follow the source ColorSlider draggable orientation.
/// Color channel sliders update on drag start as well as later drag updates.
/// Compact color tracks retain their 26dp visual and hit-test height.
/// RTL color tracks reverse the resolved fraction without reversing ownership.
/// Disabled sliders install no drag callbacks and therefore do not steal pages.
/// Slider callbacks continue to receive clamped finite values during a drag.
/// Slider haptics remain tied to values rather than raw pointer displacement.
/// A two-dimensional palette owns both horizontal and vertical pointer motion.
/// Palette ownership starts on the first real movement, not on stationary down.
/// Stationary palette taps continue to select the touched source grid cell.
/// Palette dragStartBehavior retains the first pending movement delta.
/// Palette movement consumes the root horizontal pager gesture arena entry.
/// Palette movement consumes the enclosing vertical list gesture arena entry.
/// The selected palette row and column remain clamped at all four boundaries.
/// Palette RTL mapping reverses visual columns after hit-position clamping.
/// The movable texture-blur panel follows the same consumed-pan arrangement.
/// Texture-blur dragging preserves simultaneous horizontal and vertical delta.
/// Texture-blur stationary double taps remain available for source reset.
/// Empty page margins remain available to vertical and horizontal scrolling.
/// Parent PageView tests must use a drag long enough to select another page.
/// Regression tests verify both value changes and an unchanged page index.
/// Android runtime checks repeat the same assertion with physical coordinates.
/// Runtime evidence records the changed value shown by visible localized text.
///
/// A search takeover inserted with expanded=true requests focus after layout.
/// This case cannot rely on didUpdateWidget because there is no prior state.
/// A controlled false-to-true update also requests focus after its rebuild.
/// Focus is requested only while mounted and still controlled as expanded.
/// Collapsing search clears query text before it releases the focus node.
/// Programmatic controller replacement preserves the active listener contract.
/// The icon catalogue takeover must expose a focused Android EditText node.
/// A focused source search draws the primary-colored insertion cursor.
/// The IME action remains Search in both collapsed and expanded field states.
/// Back navigation collapses expanded search before popping the owning route.
/// The outside cancel action remains localized independently from field metrics.
/// A shorter localized cancel label may give the flexible capsule more width.
/// Search result cards retain source spacing regardless of keyboard visibility.
/// Empty queries show no result cards in the icon catalogue takeover.
/// Query matching remains case-insensitive and uses the upstream icon names.
/// Selecting a result collapses search before scrolling the icon catalogue.
///
/// SearchCleanup is a layered source vector rather than Material Icons.cancel.
/// Its circle uses six percent of the resolved on-surface variant tint.
/// Its rounded cross uses thirty percent of the same resolved tint.
/// The circle radius is thirty-two units in the original sixty-eight viewport.
/// The cross endpoints follow the original 23.3934 viewport inset.
/// The cross stroke uses six viewport units with round line caps.
/// The painter scales all geometry from the shortest available side.
/// The painter multiplies layer opacity by an inherited tint alpha.
/// Dark and light themes therefore preserve the upstream layered relationship.
/// SearchCleanup keeps the existing semantic clear-action hit target unchanged.
/// The visible glyph remains smaller than the surrounding pressable padding.
/// Pressing SearchCleanup clears the controller and emits one empty callback.
/// SearchCleanup does not independently request or release text-field focus.
/// SearchBar goldens cover light, dark, pressed, disabled, and animated states.
/// Runtime comparison checks the clear glyph beside a non-empty query.
/// The source vector data remains authoritative if icon aliases later change.
/// Any replacement must be compared against the original Android sample first.
/// Analyzer, widget, golden, and Android runtime checks gate these contracts.
library;
