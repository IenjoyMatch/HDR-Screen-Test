// Current MIUIX grouped SpinnerPreference parity contract.
//
// Purpose
//
// This note records behavior that cannot be inferred from public type names.
// It is kept beside the Flutter implementation so later refactors can compare
// behavior with the current Compose source instead of preserving accidents.
// Measurements below come from a 1080x2400 Android target at 420dpi.
// Physical-pixel values are authoritative for the matching reference fixture.
// Chinese strings may change intrinsic text width but not component geometry.
// The localized example must preserve source ordering and interaction roles.
//
// Source data model
//
// A grouped preference accepts an ordered list of DropdownEntry groups.
// Each group owns an ordered list of DropdownItem-compatible entries.
// Group boundaries are semantic and remain visible through separators.
// Every group has an independent selected entry.
// Selecting one group must not clear selection in another group.
// The example begins with selection index zero in all three groups.
// The first example group contains two entries.
// The second example group contains two entries.
// The third example group contains four entries.
// The third group's second entry is disabled.
// The third group's fourth entry is disabled.
// Disabled entries remain visible in their original order.
// Disabled entries keep their icon and supporting summary.
// Disabled entries cannot invoke the selection callback.
// Disabled entries cannot request Confirm haptic feedback.
// Disabled entries cannot change the locally rendered check state.
// A disabled group makes all of its entries effectively disabled.
// A disabled group does not require mutation of its child entries.
// Entry enabled state combines with the containing group enabled state.
// A preference cannot open when no effective entry is enabled.
// Empty groups do not invent a selectable placeholder.
// Caller-owned group and entry lists are not mutated by the popup.
// Selected state is derived from caller models when the widget rebuilds.
// Popup-local selected state updates immediately after a valid tap.
// Duplicate values in different groups remain independent selections.
// Entry identity never replaces the group boundary in selection logic.
//
// Current example ordering
//
// Row one is the ordinary Overlay popup preference.
// Row two is the ordinary Window popup preference.
// Row three is the ordinary Overlay dialog preference.
// Row four is the ordinary Window dialog preference.
// Row five is the grouped Overlay popup preference.
// Row six is the grouped Window popup preference.
// Row seven is the grouped Overlay dialog preference.
// Row eight is the grouped Window dialog preference.
// Row nine is the disabled Overlay preference.
// Row ten is the disabled Window preference.
// The first ordinary row starts with option one selected.
// The second ordinary row starts with option two selected.
// The third ordinary row starts with option three selected.
// The fourth ordinary row starts with option four selected.
// Grouped rows begin with option one, option three, and option one selected.
// Each grouped row owns its own selection list in the example state.
// Changing the Overlay popup does not alter the Window popup.
// Changing a popup does not alter either dialog preference.
// Changing one dialog does not alter the other dialog preference.
// Disabled rows retain option five and option six value labels.
// Localized labels replace English content without reordering rows.
// Overlay and Window suffixes remain visible after localization.
// Dialog summaries retain the host suffix and expansion state.
// Popup summaries retain the dynamic expanded or collapsed state.
// The localized confirmation label is the Chinese equivalent of OK.
//
// Preference-row geometry
//
// The source sample card begins and ends at the same horizontal insets.
// All ten preferences occupy one continuous rounded card surface.
// Ordinary popup rows measure 179 physical pixels at 420dpi.
// Ordinary dialog rows measure 179 physical pixels at 420dpi.
// Disabled rows measure 179 physical pixels at 420dpi.
// Grouped popup rows measure 213 physical pixels at 420dpi.
// Grouped dialog rows measure 213 physical pixels at 420dpi.
// The full physical sequence is 179, 179, 179, 179, 213.
// The sequence continues 213, 213, 213, 179, 179.
// A grouped trailing value displays three independent text lines.
// Those three lines must not be flattened into comma-separated text.
// The trailing arrow remains vertically centered beside all selected lines.
// The summary remains below the title and never joins the value column.
// Expanded state changes text only and does not alter row height.
// Disabled foreground colors apply to title, summary, value, and arrow.
// Disabled rows have no pointer or semantic activation action.
// First and last card corners belong to the outer preference surface.
// Interior rows do not introduce independent card corner radii.
// Translation must not cause the value column to overlap the arrow.
// Text scaling participates in the selected-value column measurement.
// Three source value lines occupy three fixed body line boxes.
// The row preserves its source height at the reference text scale.
//
// Popup ownership
//
// Overlay presentation registers through the nearest configured popup host.
// Window presentation registers through the root navigation overlay.
// Both presentations use the same popup content implementation.
// Both presentations use the same popup position provider.
// Both presentations align to the visible trailing action anchor.
// Anchor coordinates are converted into the owning overlay coordinate space.
// Root-overlay ownership must not reuse nearest-overlay local coordinates.
// Popup placement avoids the status-bar safe inset.
// Popup placement avoids the navigation-gesture safe inset.
// Popup placement chooses the side with sufficient visible height.
// Popup placement never stretches content to the screen width.
// Opening either popup emits exactly one ContextClick haptic event.
// A repeated activation while expanded is ignored.
// Opening holds the preference pressed until route removal completes.
// Outside activation dismisses without changing any selected entry.
// Platform Back dismisses the popup before leaving the page.
// Dismissal clears the held preference state after the exit lifecycle.
// Programmatic selection changes do not produce user haptic feedback.
// A valid row tap emits exactly one Confirm haptic event.
// Selection callback runs before optional route dismissal.
// Multi-group source popups stay open after a valid selection.
// Staying open permits selection in more than one group per visit.
// A single-group source popup may close after selection by default.
// The explicit closeOnSelection value always overrides that default.
//
// Popup surface geometry
//
// The current grouped popup measures only its first eight row children.
// Group divider placeables count toward the first-eight measurement window.
// Later entries do not widen an already measured popup.
// Natural width is clamped between 200dp and 288dp.
// The localized fixture retains the source 200dp physical width.
// At 420dpi that width is exactly 525 physical pixels.
// The outer surface owns one continuous rounded outline.
// Popup shadow belongs only to the outer surface.
// Individual rows do not paint rectangular outer shadows.
// The first global row receives the top corner padding.
// The last global row receives the bottom corner padding.
// Group boundaries do not create additional outer corners.
// The first physical row height is exactly 177 pixels.
// Each visible interior physical row height is exactly 156 pixels.
// The last physical row height is exactly 177 pixels.
// The eight-row rhythm is 177, 156, 156, 156, 156, 156, 156, 177.
// Two group separators are inserted between the three groups.
// Every group separator occupies exactly 26 physical pixels.
// Separator horizontal inset starts from a rounded 20dp value.
// Separator vertical padding starts from a rounded 4dp value.
// Separator thickness starts from a rounded 1.5dp value.
// Compose rounds those dimensions independently before placement.
// At 420dpi the corresponding rounded values are 53px, 11px, and 4px.
// Eleven pixels above plus four thickness plus eleven below equals 26px.
// Rounding only the final combined extent would produce the wrong rhythm.
// The popup scroll viewport physical height is exactly 1009 pixels.
// The popup clips later rows rather than expanding beyond that viewport.
// Scrolling reveals every retained entry without deleting group boundaries.
//
// Popup row content
//
// Each source popup row is rendered by MiuixSpinnerItemImpl.
// Every rich row preserves its optional leading icon.
// Every rich row preserves its optional title.
// Every rich row preserves its optional supporting summary.
// Missing icons remove their complete wrapper and end separation.
// Missing titles do not promote summaries into title typography.
// Missing summaries remove only the supporting line.
// Icon and end padding share the source minimum-size wrapper.
// The icon wrapper minimum is 26dp before density rounding.
// Icon-to-text spacing is 12dp before density rounding.
// The leading icon and text group share vertical centering.
// The trailing check slot is measured in every row.
// An unselected check is transparent but retains the same geometry.
// Check size is 20dp before density rounding.
// Check start padding is 12dp before density rounding.
// Selected foreground uses the current primary token.
// Selected summary uses the selected summary channel.
// Selected background uses the selected container channel.
// Disabled title and summary use their disabled color channels.
// Disabled selected entries cannot expose an active tap action.
// Row text wraps only according to current source constraints.
// Long text cannot increase the popup beyond its 288dp maximum.
// Tight rows ellipsize without a RenderFlex overflow.
// The leading content budget remains capped at 216dp.
// Color changes never alter row metrics.
// Check visibility changes never shift the text column.
//
// Dialog ownership
//
// Dialog mode is selected by a non-null dialog button string.
// Overlay and Window dialog adapters retain distinct host ownership.
// Both hosts render the same grouped dialog content geometry.
// Opening either dialog emits exactly one ContextClick haptic event.
// Dialog opening holds the preference pressed through route lifetime.
// A valid dialog row tap emits exactly one Confirm haptic event.
// Dialog row selection updates only the tapped logical group.
// Grouped dialog selection remains visible until explicit dismissal.
// The bottom button dismisses without changing selection.
// The bottom button does not emit Confirm feedback.
// Barrier dismissal does not change selection.
// Platform Back dismissal does not change selection.
// Repeated input during route exit cannot duplicate callbacks.
// Dialog surface customization cannot replace selection semantics.
// Focus returns to the originating preference after dismissal.
// Dialog content remains scrollable when vertical room is constrained.
// The title stays outside the scrollable grouped row region.
// The confirmation button remains reachable below the row region.
// The modal barrier changes surrounding luminance only.
// Dialog row opacity remains independent from barrier opacity.
// Selected backgrounds extend to the dialog's horizontal content edges.
// Selected foreground content retains its own horizontal inset.
// The outer dialog surface alone owns the large rounded corners.
// Interior selected rows never create their own outer corner shape.
//
// Dialog physical geometry
//
// The reference dialog surface begins at physical x coordinate 32.
// The reference dialog surface ends at physical x coordinate 1048.
// Every grouped row therefore spans 1016 physical pixels.
// The first row occupies y 779 through 935.
// The second row occupies y 935 through 1091.
// The first divider occupies y 1091 through 1117.
// The third row occupies y 1117 through 1273.
// The fourth row occupies y 1273 through 1429.
// The second divider occupies y 1429 through 1455.
// The fifth row occupies y 1455 through 1611.
// The sixth row occupies y 1611 through 1767.
// The seventh row occupies y 1767 through 1923.
// The eighth row occupies y 1923 through 2079.
// Every dialog row is therefore exactly 156 physical pixels tall.
// Every dialog divider is exactly 26 physical pixels tall.
// The list-to-button gap begins at y 2079 and ends at y 2111.
// That gap is exactly 32 physical pixels.
// The confirmation button begins at physical x coordinate 95.
// The confirmation button ends at physical x coordinate 985.
// The confirmation button begins at physical y coordinate 2111.
// The confirmation button ends at physical y coordinate 2242.
// The button is therefore 890 physical pixels wide.
// The button is therefore 131 physical pixels tall.
// Dialog inside margin is zero horizontally and 24dp vertically.
// Row content uses 28dp horizontal padding before density rounding.
// Row content uses 12dp vertical padding before density rounding.
// Button outer horizontal padding is 24dp before density rounding.
// Button outer top padding is 12dp before density rounding.
// Dialog surface translation cannot change these child measurements.
//
// Accessibility and semantics
//
// The complete preference exposes one activation action when enabled.
// The preference semantic value includes every selected group label.
// Selected group values retain source order in semantic output.
// showValue false removes the visible and semantic value column.
// The arrow is decorative and does not duplicate the preference action.
// Popup rows expose their individual selected state.
// Dialog rows expose their individual selected state.
// Disabled rows expose no semantic activation action.
// Disabled groups expose no semantic activation action on child rows.
// Icon-only entries require a meaningful caller-provided semantic label.
// Supporting summaries remain available to accessibility services.
// Localization does not remove enabled, selected, or checked semantics.
// Popup dismissal returns accessibility focus to its preference.
// Dialog dismissal returns accessibility focus to its preference.
// Keyboard traversal follows entry order within each group.
// Keyboard traversal crosses group separators without focusing them.
// The confirmation button follows the final row in traversal order.
// The modal route prevents focus from escaping behind the dialog.
// The popup route prevents hidden rows from receiving pointer activation.
// A disabled selected row may remain announced as selected and disabled.
// Selection announcements occur only after a valid enabled activation.
//
// Verification evidence
//
// Widget tests use a physical 1080x2400 test view at 2.625 density.
// Widget tests apply 63px top and bottom safe-area padding.
// Tests assert all ten localized preference rows in source order.
// Tests assert adapter counts for Overlay, Window, popup, and dialog modes.
// Tests assert the three grouped entry counts are 2, 2, and 4.
// Tests assert the final group's enabled pattern is true,false,true,false.
// Tests assert popup closeOnSelection remains false for three groups.
// Tests assert popup physical width is exactly 525px.
// Tests assert popup first-eight viewport height is exactly 1009px.
// Tests assert every popup row physical height with floating tolerance.
// Tests assert both popup separator gaps are exactly 26px.
// Tests tap a disabled popup row and observe no callback.
// Tests tap an enabled popup row and observe one callback.
// Tests confirm the grouped popup remains mounted after selection.
// Tests assert all eight dialog row heights are exactly 156px.
// Tests assert both dialog separator gaps are exactly 26px.
// Tests assert the dialog button gap is exactly 32px.
// Tests assert the dialog button height is exactly 131px.
// Tests assert the dialog button dismisses without selecting.
// Haptic tests assert ContextClick on popup and dialog opening.
// Haptic tests assert Confirm on valid selection only.
// Full library tests protect shared popup primitives from regressions.
// Full example tests protect localized structure and physical row rhythm.
// Static analysis must report no issues for both package and example.
// Android validation uses an x86_64 Release APK on the 420dpi emulator.
// APK metadata must contain the expected application identifier.
// APK verification must report a valid v2 signature.
// APK badging must not expose the debuggable application flag.
// Replacement installation must succeed without clearing application data.
// Runtime screenshots record rows, grouped popup, and grouped dialog.
// Runtime hierarchy records exact row and button physical coordinates.
// Runtime logcat must contain no FlutterError signature.
// Runtime logcat must contain no RenderFlex overflow signature.
// Runtime logcat must contain no fatal application exception.
// Release handoff must also produce an arm64-v8a-only APK.
// The final arm64 package must use a monotonic versionCode.
// The final arm64 package must pass Android signature verification.
// Documentation-ratio verification runs after all source edits.
// Public-symbol comparison remains a scope check rather than parity proof.
// Visual and behavioral evidence remains required for completion claims.
