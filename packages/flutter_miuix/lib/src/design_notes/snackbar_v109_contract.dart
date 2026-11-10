// MIUIX v1.0.9 Snackbar reconstruction contract.
//
// Source files
// ------------
// The authoritative component is basic/Snackbar.kt.
// The authoritative sample is component/SnackbarSection.kt.
// Flutter public names add only the Miuix prefix.
// Visible example strings are translated to Chinese.
// Queue order, timing, geometry, semantics, and actions remain source-owned.
//
// Duration model
// --------------
// SnackbarDuration is a sealed source value family.
// Short resolves to 4000 milliseconds.
// Long resolves to 10000 milliseconds.
// Indefinite resolves to the effective maximum duration.
// Custom stores one positive duration in milliseconds.
// A zero Custom duration is invalid.
// A negative Custom duration is invalid.
// Flutter represents the same four choices with MiuixSnackbarDuration.
// A null Dart Duration represents Indefinite.
// Equal custom durations compare like the Kotlin data class.
// Duration equality participates in SnackbarVisuals equality.
//
// Result model
// ------------
// SnackbarResult has exactly two values.
// Dismissed represents timeout or explicit dismissal.
// ActionPerformed represents selection of the optional action.
// Only the first completion request changes the result.
// A later dismiss after an action is a no-op.
// A later action after dismissal is a no-op.
// Flutter futures complete with the corresponding MiuixSnackbarResult.
//
// Visuals model
// -------------
// SnackbarVisuals is an immutable source data class.
// message is required.
// actionLabel is nullable.
// withDismissAction is required in the data class.
// duration is required in the data class.
// showSnackbar supplies false for withDismissAction by default.
// showSnackbar supplies Short for duration by default.
// Flutter constructor defaults mirror showSnackbar.
// Equal field values compare as equal visuals.
// Equal visuals produce equal hashes.
// An empty actionLabel remains data but does not paint an action button.
// A non-null empty action still counts as a control for timeout calculation.
//
// Data handle
// -----------
// SnackbarData exposes immutable visuals.
// SnackbarData exposes an asynchronous dismiss operation.
// SnackbarData exposes an asynchronous performAction operation.
// dismiss completes the owning showSnackbar call as Dismissed.
// performAction completes the owning showSnackbar call as ActionPerformed.
// Both operations mark their queue entry invisible.
// Neither operation removes the entry before its exit animation completes.
// Repeated operations are idempotent.
//
// Host state
// ----------
// SnackbarHostState owns a list of entries.
// Every entry receives a monotonically increasing identifier.
// A new entry is inserted at list index zero.
// The new entry is therefore the newest visible snackbar.
// newestSnackbarData scans from the beginning.
// oldestSnackbarData scans from the end.
// Both queries ignore entries already marked invisible.
// Both queries return null when no visible entry remains.
// The source protects state changes with a Mutex.
// Dart's single-isolate mutation preserves the same atomic ordering.
// showSnackbar does not serialize messages into a one-at-a-time queue.
// Multiple entries may remain visible simultaneously.
// Every showSnackbar future waits for its own data completion.
// Entry removal happens after the visibility exit becomes idle.
// Disposing Flutter host state completes pending handles as dismissed.
//
// Accessibility timeout
// ---------------------
// Short begins with 4000 milliseconds.
// Long begins with 10000 milliseconds.
// Custom begins with its caller value.
// Indefinite does not create a finite Flutter timer.
// Android asks AccessibilityManager for the recommended timeout.
// The request always declares that text is present.
// The request always declares that an icon is present.
// The request declares controls when actionLabel is non-null.
// The request does not use withDismissAction for containsControls.
// This apparently unusual distinction is copied from Snackbar.kt.
// A missing accessibility manager returns the original duration.
// Windows and unattached test hosts retain the original duration.
// The replacement timer begins only after the recommendation resolves.
// A snackbar dismissed while the recommendation is pending starts no timer.
//
// Host layout
// -----------
// SnackbarHost aligns its queue to BottomCenter.
// The source uses a reverse-layout LazyColumn.
// The source vertical arrangement is Top.
// The source horizontal alignment is CenterHorizontally.
// The host contributes 12dp of bottom content padding.
// New entries appear closest to the bottom edge.
// Older entries stack upward.
// Every source item owns zIndex(currentSnackbars.size - index).
// The newest visible entry therefore paints above every older entry.
// Older-item exit uses clip=false and may overlap the newer item while shrinking.
// That overlap must remain behind the newer surface for the complete exit.
// Flutter lays out oldest-to-newest so Flex paint order reproduces source zIndex.
// Stable identifiers preserve each entry across list changes.
// Visible entries participate in source placement animation.
// Hidden entries stop participating in placement animation.
// The scaffold paints the complete host above bottom navigation.
// A floating pill does not occlude the snackbar.
// Transparent host surroundings do not block navigation taps.

// Anchored swipe dismissal
// -------------------------
// SnackbarHost enables horizontal swipe dismissal by default.
// canSwipeToDismiss can explicitly disable the gesture.
// Every visible entry owns StartToEnd, Settled, and EndToStart anchors.
// The side anchors equal the complete measured entry width.
// Drag offset follows the pointer and paints through IntOffset rounding.
// Positional selection changes at fifty percent of the total distance.
// Settling on either side anchor completes the entry as Dismissed.
// Settling back at zero leaves the entry and its timer alive.
// Flutter mirrors both directions, the fifty-percent threshold, and spring return.
// Qualified horizontal intent wins before an ancestor application pager.
// Swiping a visible Snackbar must not select another root destination.
//
// Visibility motion
// -----------------
// Every entry starts with MutableTransitionState(false).
// The target state follows entry.visible.
// Enter slides from exactly the 12dp host-bottom-padding distance.
// Enter expands vertically from Alignment.Top without clipping.
// Enter deliberately adds no alpha animation.
// The newest exit slides by the same 12dp and shrinks from Alignment.Top.
// Older exits fade with StiffnessMedium and shrink from Alignment.Top.
// Moving parts deliberately avoid a shared alpha layer and placement animation.
// Compose's default spring is critically damped.
// Flutter uses unit mass, stiffness 400, and damping 40.
// Entry removal waits for the exit motion.
//
// Surface contract
// ----------------
// Snackbar is a public composable that accepts SnackbarData.
// cornerRadius defaults to 16dp.
// colors defaults through SnackbarDefaults.snackbarColors.
// insideMargin defaults to 12dp on all four sides.
// Caller modifier is applied to the complete outer snackbar.
// Flutter exposes the same data, radius, colors, and insideMargin fields.
// Direct widget use wraps height to content.
// Direct widget use retains the available horizontal extent.
// The complete snackbar consumes otherwise unhandled taps.
// Horizontal dismissal belongs to SnackbarHost rather than this surface.
//
// Outer surface geometry
// ----------------------
// The source applies 12dp horizontal outer padding.
// The source applies 8dp top outer padding and no bottom outer padding.
// A 400dp host therefore leaves a 376dp painted surface.
// The drop-shadow path is always RoundedCornerShape.
// The nested fill follows squircleBackground when smooth rounding is active.
// Shadow and fill deliberately use different corner paths.
// The surface uses a 16dp default radius.
// The drop shadow has a 10dp radius, black color, and 0.1 alpha.
// The surface color is colors.containerColor.
// The surface publishes Polite live-region semantics.
//
// Message row
// -----------
// The Row centers children vertically.
// defaultMinSize contributes a 48dp minimum height.
// insideMargin is applied after the minimum-size modifier.
// A one-line message with default padding retains the 48dp minimum.
// A source action has a 26dp minimum height.
// Default 12dp vertical padding therefore makes an action snackbar 50dp.
// A custom taller inside margin may increase the complete surface naturally.
// The message receives weight 1.
// The message uses body2 typography.
// Android measures each default 14sp body2 line as 43px at 420dpi.
// Flutter resolves the corresponding 1.16-em line and rounds it physically.
// Two lines plus separately rounded 12dp vertical insets produce 150px.
// The message uses colors.contentColor.
// The message is limited to two lines.
// Overflow is an ellipsis.
//
// Action contract
// ---------------
// No action is painted for a null label.
// No action is painted for an empty label.
// A non-empty label creates a source TextButton.
// The action button uses colors.actionContainerColor.
// The action text uses colors.actionContentColor.
// Action inside padding is 12dp horizontal and zero vertical.
// The source TextButton has a 26dp minimum width and height.
// The source action pill uses a 50dp corner radius and 15sp text.
// Selecting the action launches SnackbarData.performAction.
// The action exports button and tap semantics.
//
// Dismiss contract
// ----------------
// withDismissAction controls the close icon independently from actionLabel.
// The icon is MiuixIcons.Basic.Close.
// The icon occupies exactly 20dp by 20dp.
// Android expands its clickable and semantic target to 48dp without layout.
// At fractional Android density its independently rounded origin advances by one physical pixel.
// This expansion comes from Compose's minimum interactive component handling.
// It must not be reproduced with a 48dp SizedBox inside the message Row.
// Doing that would consume another 28dp and move the message and action label.
// The expanded rectangle is therefore a hit-test and semantics concern only.
// Its center stays aligned with the center of the painted 20dp icon.
// The target may extend into the Snackbar's logical inside padding.
// The Snackbar surface still owns clipping, paint, and pointer dismissal.
// The invisible target must not paint a Material splash or hover overlay.
// Source clickable explicitly disables its visual indication.
// Disabled dismissal removes the tap action but retains the icon geometry.
// Android exposes the resulting semantics node as android.widget.ImageView.
// Flutter must consequently announce an image rather than fabricate a button class.
// The Dismiss content description remains the node's accessible name.
// The node must expose a tap action whenever SnackbarData.dismiss is available.
// A semantics-only expansion must also participate in RenderBox hit testing.
// Expanding semantics without the hit-test rectangle would create a false target.
// Expanding hit testing without semantics would leave accessibility at 20dp.
// Pointer coordinates are converted through the same shifted target rectangle.
// Fractional-density correction is Android-only and leaves desktop unchanged.
// Integer-density Android devices require no physical-pixel origin correction.
// The icon has 8dp logical-start padding.
// The icon tint is colors.dismissActionContentColor.
// The source content description is Dismiss.
// The icon exports image and tap semantics through clickable.
// Selecting the icon launches SnackbarData.dismiss.
//
// Color model
// -----------
// SnackbarColors has five immutable channels.
// containerColor paints the surface.
// contentColor paints the message.
// actionContentColor paints the action label.
// dismissActionContentColor paints the close icon.
// actionContainerColor paints the action pill.
// SnackbarDefaults resolves onSecondaryVariant as containerColor.
// SnackbarDefaults resolves secondaryVariant as contentColor.
// SnackbarDefaults resolves onPrimary for the action label.
// SnackbarDefaults resolves onSurfaceContainerVariant for dismissal.
// SnackbarDefaults resolves primary for the action pill.
// Each default color accepts an independent caller override.
// Flutter colors compare and copy like the Kotlin data class.
//
// Localized example
// -----------------
// The sample section title is translated from Snackbar to 提示条.
// Dismiss oldest is translated to 关闭最早项.
// Dismiss newest is translated to 关闭最新项.
// Short and Long keep their visible duration values.
// Custom keeps the source two-second duration.
// Action keeps the source waiting, undo, and expired state sequence.
// Dismissible keeps withDismissAction true and Long duration.
// Indefinite keeps withDismissAction true and Indefinite duration.
// Action + Close keeps actionLabel, withDismissAction, and Long duration.
// All nine controls use MiuixTextButton like source TextButton.
// The action control alone uses the primary text-button palette.
// Five rows retain 12dp horizontal and vertical spacing.
//
// Regression obligations
// ----------------------
// Tests cover both result values.
// Tests cover newest and oldest ordering.
// Tests cover newest-over-older paint order during an older unclipped exit.
// Tests cover simultaneous visible entries.
// Tests cover native accessibility timeout arguments.
// Tests cover the 376dp default surface width.
// Tests cover 48dp and 50dp default heights.
// Tests cover the current 150px two-line height at 420dpi.
// Tests cover shadow, shape, and semantic default colors.
// Tests cover custom colors, radius, and directional inside margin.
// Tests cover the empty-label no-action rule.
// Tests cover two-way default swipe dismissal and opt-out spring return.
// Tests cover Dismiss button and Tap semantics.
// Tests cover source model equality.
// Tests cover bottom-navigation and floating-pill clearance.
// Goldens cover short, action, and dismissible surfaces.
