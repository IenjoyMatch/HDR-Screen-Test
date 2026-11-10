// MIUIX v1.0.9 BottomSheet measurement contract
//
// Source of truth
// - layout/BottomSheetContentLayout.kt owns both Overlay and Window sheets.
// - AboutPage.kt supplies the Texture Set fixture used by the Android audit.
// - The reference device is 1080x2400 at Android density 420, or 2.625 dpr.
//
// Surface
// - The sheet is aligned to the bottom of the complete Android window.
// - Its source maximum width is 640dp.
// - Only the two top corners use the 28dp source shape.
// - The zero outside margin lets the surface cover the gesture region.
// - The default inside margin is 24dp horizontally and zero vertically.
// - A zero inside margin from AboutPage must remove that horizontal inset.
//
// Header measurement
// - DragHandleArea is a separately measured 24dp-high placeable.
// - Its resting painted handle is 45dp by 4dp.
// - TitleAndActionsRow has no authored 40dp height in the Kotlin source.
// - The row adds a separately rounded 6dp top padding.
// - The row adds a separately rounded 12dp bottom padding.
// - Its Android title4 paragraph owns a measured 31dp line box.
// - At 420dpi those four parts are 63px, 16px, 81px, and 32px.
// - Their exact sum is the 192px Texture Set header.
// - The title stays centered independently of asymmetric side actions.
// - A custom action taller than title4 is allowed to grow the row.
//
// About Texture Set evidence
// - The source surface begins at physical y=147 and ends at y=2400.
// - The source controls viewport begins at physical y=339.
// - The first three 56dp switch rows consume 147px independently.
// - Their painted switch tracks begin at y=397, y=544, and y=691.
// - Five title-plus-slider rows consume 189px independently.
// - Their expanded slider origins are y=895, 1084, 1273, 1462, and 1651.
// - Combining fractional Flutter line boxes before rounding produces 190px.
// - The title placeable must therefore finalize before the 8dp gap and slider.
// - SkParagraph's translated 17sp half-pixel line is truncated for this path.
// - Ordinary rows retain nearest-pixel finalization and their prior geometry.
//
// Example sizing
// - The translated control list has the source natural 785dp content height.
// - A short test window still leaves the source 56dp strip above the sheet.
// - Available content height subtracts that strip and the measured header.
// - The natural list height is used when the window has enough room.
// - The list remains scrollable when the available height is smaller.
// - Android navigation padding remains the final item inside the list.
//
// Interaction and lifecycle
// - Overlay and Window variants share this exact surface measurement.
// - The sheet consumes taps so content behind it cannot activate.
// - Outside taps and Back consult the live allowDismiss state.
// - Nested scrolling restores a displaced sheet before scrolling its child.
// - Upward drag remains damped while downward drag follows the pointer.
// - Dismiss callbacks run once and completion waits for the exit transition.
//
// Regression obligations
// - Keep compact content-sized sheets bottom aligned.
// - Keep the existing Surface Actions sheet boundaries byte-for-byte stable.
// - Test the Texture Set surface, switches, slider origins, and 189px rhythm.
// - Verify the localized Android executable against the native package.
// - Do not replace source measurement with a percentage-of-screen cap.
// Public defaults and override propagation
// ----------------------------------------
// BottomSheetDefaults backgroundColor resolves the semantic background role.
// BottomSheetDefaults dragHandleColor resolves onSurfaceVariantSummary.
// The resting drag-handle alpha remains one fifth for a custom base color.
// The pressed drag-handle alpha replaces it with thirty-five percent.
// BottomSheetDefaults cornerRadius is the current source 28dp value.
// BottomSheetDefaults maxWidth is the current source 640dp value.
// BottomSheetDefaults outsideMargin is zero on both source axes.
// BottomSheetDefaults insideMargin is 24dp horizontally and zero vertically.
// MiuixBottomSheetDefaults exposes every one of these source-owned values.
// Overlay and Window entry points accept the same background override.
// Overlay and Window entry points accept the same dim-enable switch.
// Overlay and Window entry points accept the same top-corner override.
// Overlay and Window entry points accept the same maximum-width override.
// Overlay and Window entry points accept the same outside-margin override.
// Overlay and Window entry points accept the same inside-margin override.
// Overlay and Window entry points accept the same inset-enable switch.
// Overlay and Window entry points accept the same drag-handle color override.
// Every override reaches the one shared bottom-sheet surface implementation.
// A custom background also owns the elastic overscroll fill behind the panel.
// A custom background does not recolor the independent window-dimming plane.
// Disabling enableWindowDim keeps the modal hit target but paints it clear.
// A clear dim target still receives outside taps when dismissal is allowed.
// A custom corner radius applies only to the two top corners.
// The two bottom corners remain square against the bottom window edge.
// Negative finite corner radii recover to zero without a paint assertion.
// Non-finite corner radii restore the active HyperOS sheet token.
// A positive finite maximum width remains a real layout upper bound.
// Nonpositive and non-finite maximum widths restore the 640dp source bound.
// Directional outside margins resolve through the active text direction.
// Outside margins constrain both the panel and its overscroll background.
// Inside margin stays inside the same clipped opaque or glass silhouette.
// defaultWindowInsetsPadding adds the live IME bottom inset when enabled.
// Disabling it lets application content own IME accommodation explicitly.
// Status-bar-safe maximum height remains enforced independently of that switch.
// The source and HyperOS paths share drag, nested-scroll, and predictive Back.
// Ordinary entry points continue to select local HyperOS glass by default.
// Passing glass false preserves the current opaque source-compatible path.
// Defaults mapping proves the public owner exists but not visual parity alone.
// Focused widget evidence verifies background, shape, margins, handle, and dim.
// Existing predictive Back tests verify cancel, commit, and dismiss denial.
// Existing visibility tests verify the .9/.38 Folme entrance and exit channels.
// Existing drag tests verify 150dp displacement and 800dp/s velocity thresholds.
// Existing nested-scroll tests verify only unconsumed leading-edge motion moves.
// Existing lifecycle tests verify request and finished callbacks remain ordered.
// Full goldens remain required to detect unintended panel geometry changes.
// Android arm64 runtime evidence remains separate from static package checks.
// Overlay hosting resolves the nearest root or nested popup scope explicitly.
// Window hosting resolves a root Navigator route independently of that scope.
// The same public surface parameters must produce the same panel geometry.
// Host selection must not change the drag-handle press animation.
// Host selection must not change the settle spring damping or response.
// Host selection must not change the predictive Back translation channel.
// Host selection must not change the nested-scroll edge eligibility rule.
// The dim-enable switch is forwarded separately for each hosting mechanism.
// Overlay dimming remains owned by the popup host and its live alpha value.
// Window dimming remains owned by the full-screen route Stack.
// Both dim planes multiply the same drag and predictive progress channels.
// A transparent dim plane never turns the panel background transparent.
// A custom opaque panel remains opaque when global glass intensity changes.
// A custom glass panel continues to respect the transient optics profile.
// The supplied maximum width is measured before inside content padding.
// Outside margin is measured outside the clipped panel silhouette.
// The maximum height still stops below the status-bar-safe top edge.
// Long content remains responsible for providing its own scrollable viewport.
// These ownership rules prevent customization from changing motion semantics.
// Release packaging verifies both host implementations compile on both targets.
