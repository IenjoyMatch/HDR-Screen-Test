// Current miuix-nav core contract.
//
// This file records behavioral ownership for the public navigation primitives.
// It intentionally contains no executable declarations. The implementation
// remains in widgets/parts/nav_core.dart and navigation_page_transitions.dart.
//
// Key and stack ownership:
// - MiuixNavKey is a marker implemented by application destination models.
// - The library does not prescribe route names, path strings, or arguments.
// - MiuixNavBackStack keeps insertion order and allows direct list mutation.
// - Every effective public mutation publishes a ChangeNotifier update.
// - A no-op clear, empty addAll, or empty removeRange publishes no update.
// - Growing through the List.length setter is unsupported for non-null keys.
// - Callers grow the stack with add, addAll, insert, or insertAll instead.
// - Shrinking through length removes the tail and publishes one update.
// - replaceRange batches one logical replacement into one notification.
// - The stack owns a defensive copy of constructor input.
// - Restorable output is an unmodifiable snapshot, not a live list view.
// - Route serialization remains application-owned because Dart has no
//   compiler-generated polymorphic serializer matching Kotlin serialization.
// - Decoding creates a new observable stack and never aliases encoded input.
//
// Controller invariants:
// - push appends exactly one destination.
// - pop returns false when the stack contains zero or one entry.
// - pop therefore never removes an existing root destination.
// - replace inserts into an empty stack and replaces the tail otherwise.
// - popUntil examines the current tail after every removal.
// - popUntil also preserves the root when no destination matches.
// - The controller has no second state source; its back stack is authoritative.
// - Programmatic mutations and direct list mutations remain interoperable.
//
// Display effects:
// - Leading corner clipping applies only at relative depths strictly (-1, 0).
// - All corner clipping applies strictly inside (-1, 1), excluding zero.
// - Exact settled integer depths never receive transition-only input blocking.
// - Fractional positive and negative depths may receive input blocking.
// - NaN and infinity never request clipping or input blocking.
// - The default dim amount is 0.5 and the default radius is zero.
// - The none preset disables clipping and dim while retaining value semantics.
// - backdropColor remains nullable so a display can resolve its own backdrop.
// - copyWith can explicitly clear backdropColor without sentinel colors.
// - Display effects are immutable and compare all public channels by value.
//
// Motion recipes:
// - Commit and cancel default to critically damped stiffness-146 springs.
// - Overshoot clamping is enabled for those critical default springs.
// - An underdamped spring may be used only when clamping is disabled.
// - This invariant throws in Release as well as Debug; it is not assert-only.
// - Damping and stiffness must both be finite and greater than zero.
// - Programmatic navigation defaults to the calibrated 500ms response curve.
// - Tween recipes supply both duration and curve as one indivisible choice.
// - The layered display consumes spring programmatic recipes directly.
// - Navigator page routes retain their calibrated tween compatibility path.
// - The page-transitions builder owns the shared primary/secondary curve.
// - This prevents entering, retained, dim, and parallax layers from drifting.
// - MiuixPageRoute owns the matching Navigator controller duration.
// - Custom recipes should be supplied to both the builder and page route.
// - Existing constructors keep the same default visual and timing behavior.
// - Reverse progress restarts the response from elapsed pop time.
// - Route snapshotting remains disabled by default for live blur and shaders.
//
// Completion boundary:
// - These primitives now feed the public MiuixNavDisplay implementation.
// - The display owns stable content identities and one continuous depth driver.
// - Pointer and predictive-back paths expose gesture and settle phase values.
// - Direct stack mutations are classified and reconciled before each frame.
// - Exact route-runtime-type registration mirrors the source entry DSL.
// - Leaving entries remain alive until their outgoing depth exits the window.
// - Deep current entries stay mounted offstage to retain Flutter State.
// - Existing Navigator predictive-back work remains a separate foundation.
// - Name mapping proves the public contract is present, not visual parity.
// - Unit and widget tests prove deterministic behavior, not device rendering.
// - Android arm64 runtime evidence requires a task-owned compatible target.
// - The available x86_64 emulator must not be reported as arm64 evidence.
// - HyperOS 4 visual calibration remains the default for new display widgets.
// - Upstream source-compatible values remain labeled as source values.
// - Project-inferred geometry must not be described as Xiaomi official data.
// - Any later persistence helper must keep application serialization explicit.
// - Runtime gesture admission still needs owned-device edge-zone verification.
// - Full Release validation remains required after every source or doc change.
