// HyperOS 4 reorderable-row and swipe-action implementation contract.
//
// Scope and evidence
// ------------------
// This contract covers reusable collection interaction extensions.
// Reorderable rows and swipe actions are flutter_miuix extensions.
// They are not described as unpublished Xiaomi component APIs.
// Exact dimensions remain explicit project calibrations.
// HyperOS 4 public material informs continuity, shape, and motion hierarchy.
// The library owns implementation while examples own only demonstrations.
//
// Shared collection geometry
// --------------------------
// collectionRowCornerRadius is the ordinary interactive-row shape role.
// A resting reorderable row uses that role.
// A lifted reorderable proxy uses that same role.
// A swipe-action foreground uses that same role.
// A swipe-action outer clip uses that same role.
// Theme changes must not create a shape jump when a row begins dragging.
// Theme changes must not leave swipe actions on a fixed legacy radius.
// Explicit finite widget radii take priority over theme defaults.
// Negative caller radii are clamped or rejected before paint.
// NaN is a default-resolution sentinel and is never painted.
// Source constructors retain former fixed 18dp compatibility geometry.
// Source compatibility never becomes the ordinary default again.
//
// Reorderable item behavior
// -------------------------
// MiuixReorderableItem remains a reusable row helper.
// Its default surface resolves collectionRowCornerRadius.
// Its source constructor retains the former fixed 18dp radius.
// Row color remains semantic unless explicitly overridden.
// The child remains expanded before the optional handle.
// The default handle retains a complete accessibility target.
// Android and iOS retain delayed long-press drag initiation.
// Desktop retains immediate drag initiation unless overridden.
// Disabled handles expose disabled semantics and do not start dragging.
// The list owns data ordering only through the caller callback.
// Stable caller keys remain attached to their application items.
// Header and footer remain outside the reorderable data index range.
// Nested route safe-area padding is not inserted a second time.
//
// Reorderable proxy behavior
// --------------------------
// The default proxy follows direct drag position without easing lag.
// Lift scale and shadow follow the reorder framework animation.
// The proxy uses the same collection shape as its resting row.
// The proxy clips content to the resolved continuous shape.
// Reduced motion publishes the complete lifted proxy state immediately.
// Reduced motion does not delay or disable direct drag movement.
// A drag start emits the long-press semantic haptic role once.
// A completed reorder emits the confirmation semantic haptic role once.
// Caller lifecycle callbacks run in the same transaction as feedback.
// A caller proxy decorator remains authoritative when supplied.
//
// Swipe-action shape hierarchy
// ----------------------------
// The ordinary swipe row follows the active global squircle preference.
// The outer clip and translated foreground use the identical ShapeBorder.
// Action panes remain behind the translated foreground.
// The translated foreground keeps rounded corners while actions are exposed.
// Transparent rounded cutouts reveal action color rather than a rectangle.
// The source constructor retains a rounded-rectangle silhouette.
// The source constructor retains the former fixed 18dp radius.
// The ordinary constructor resolves collectionRowCornerRadius.
// Action widths remain exactly equal within one logical side.
// Start and end placement uses Directionality rather than hard-coded left/right.
// End actions retain authored reading order after directional reversal.
// Foreground color remains semantic unless explicitly overridden.
//
// Swipe-action direct manipulation
// --------------------------------
// Horizontal drag updates translate the foreground in the same frame.
// The logical offset remains independent from LTR or RTL physical direction.
// Movement is clamped to the available action extent on each side.
// A side without actions cannot be revealed beyond zero.
// Crossing the settle threshold emits feedback once per crossing.
// Returning below the threshold rearms the semantic feedback.
// Direct drag cancels an in-flight autonomous settlement.
// A canceled old animation cannot overwrite a newer pointer position.
// DragStartBehavior.down retains displacement accumulated through touch slop.
// The visible row therefore does not begin one slop-width behind the finger.
// A disabled row installs no horizontal drag callbacks.
//
// Nested gesture ownership
// ------------------------
// A horizontal gesture beginning on a swipe row belongs to that row.
// An ancestor PageView must not advance from the same gesture stream.
// The child recognizer wins after ordinary horizontal intent is established.
// Accumulated pre-acceptance displacement is applied to the foreground.
// Several physical move samples are used to prove real arena behavior.
// Vertical page scrolling must not be claimed as a horizontal swipe.
// The surrounding row adds no unrelated eager pointer recognizer.
// Releasing the child drag settles only the swipe row.
// PageController remains at its original page after settlement.
// This guarantee applies to library consumers and not only the example shell.
//
// Swipe settlement and controllers
// ---------------------------------
// Programmatic open and close use swipeActionMotion.
// Release settlement uses the same autonomous motion channel.
// A velocity above the authored threshold selects an available side.
// A slower release uses the authored half-pane threshold.
// The controller stores the durable side only after settlement.
// onSideChanged publishes the same durable settled state.
// Action activation emits confirmation feedback once.
// closeOnPressed requests the closed controller state after activation.
// Replacing caller controllers detaches the old listener.
// Caller-owned controllers are never disposed by the widget.
// Internally created controllers are disposed with the widget.
//
// Reduced motion
// --------------
// MediaQuery.disableAnimations is authoritative for autonomous settlement.
// Enabling reduced motion stops an active animation.
// A guarded post-frame endpoint prevents build-time mutation.
// Old completion callbacks cannot publish after the generation changes.
// Controller open and close requests snap directly under reduced motion.
// Release and cancel settlement snap directly under reduced motion.
// Direct pointer movement remains immediate under reduced motion.
// Threshold feedback remains semantic under reduced motion.
// Final geometry, side state, callback, and semantics remain identical.
//
// Verification obligations
// ------------------------
// Tests inspect theme geometry on a resting reorderable row.
// Tests inspect the same theme geometry on its lifted proxy.
// Tests inspect the reorderable source 18dp compatibility path.
// Tests inspect ordinary swipe squircle shape and theme radius.
// Tests inspect source swipe rounded-rectangle shape and 18dp radius.
// Tests inspect equal action widths after programmatic opening.
// Tests inspect an intermediate custom-duration settlement frame.
// Tests inspect reduced-motion controller and release endpoints.
// Tests exercise a multi-sample horizontal drag inside PageView.
// Tests prove full accumulated displacement reaches the foreground.
// Tests prove PageController remains on the original page.
// Static analysis and the complete package suite remain mandatory.
// Package structure and comment-ratio gates remain mandatory.
// Every completed phase produces Android, Windows, and both library archives.
// Android remains arm64-v8a with its test-signing boundary reported.
// Windows must pass the hidden responsiveness smoke check.
// Old checkpoints are pruned only after the complete Release succeeds.
