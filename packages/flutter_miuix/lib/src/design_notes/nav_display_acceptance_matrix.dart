// NavDisplay behavior and release acceptance matrix.
//
// Purpose:
// - This file contains no executable declarations.
// - It turns the layered navigation implementation into reviewable acceptance questions.
// - Each subject is checked across ownership, identity, frame coherence, safety, testing, and evidence.
// - A line records an invariant to verify; it does not claim owned-device acceptance by itself.
// - Source-derived values remain distinct from project-inferred visual calibration.
// - Static ABI, signature, and widget tests remain distinct from runtime visual proof.
//
// back-stack root preservation:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// single push reconciliation:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// batched push reconciliation:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// single pop reconciliation:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// batched pop reconciliation:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// top replacement:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// whole-stack replacement:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// middle insertion:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// middle deletion:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// same-length reorder:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// empty-stack rejection:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// controller replacement:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// display disposal:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// entry registry rebuild:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// exact runtime-type lookup:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// missing route registration:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// duplicate content keys:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// stable content identity:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// route metadata snapshot:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// route builder refresh:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// retained Flutter State:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// covered scroll state:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// covered focus state:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// covered text state:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// covered animation state:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// deep-entry culling:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// leaving-entry retention:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// outgoing-entry disposal:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// cancelled-pop restoration:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// continuous animated top:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// relative-depth sign:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// top role assignment:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// covered role assignment:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// incoming role assignment:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// outgoing role assignment:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// boundary transition ownership:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// default push translation:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// default covered parallax:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// default covered opacity:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// modal vertical translation:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// modal opaque depth:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// identity transition:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// fullscreen backdrop:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// fullscreen dim scrim:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// scrim boundary ownership:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// scrim alpha sanitization:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// corner clip admission:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// corner radius sanitization:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// leading-corner resolution:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// RTL geometry mirroring:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// pixel-snapped translation:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// input blocking:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// covered pointer rejection:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// top pointer ownership:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// child gesture priority:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// horizontal gesture admission:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// vertical gesture admission:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// physical swipe direction:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// pointer progress normalization:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// finger progress cap:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// position commit threshold:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// velocity commit threshold:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// opposing-fling cancellation:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// gesture cancellation:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// gesture commit:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// running-motion grab:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// gesture reversal:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// settle generation invalidation:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// commit spring:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// cancel spring:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// programmatic tween:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// programmatic spring:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// commit velocity floor:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// bounded overshoot:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// settle elapsed time:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// settle release velocity:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// reduced-motion settle:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// non-finite transform:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// non-finite opacity:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// non-finite scale:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// non-finite viewport:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// viewport resize:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// button Back:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// nested Back ownership:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// predictive Back start:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// predictive Back update:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// predictive Back cancel:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// predictive Back commit:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// predictive Back stale callback:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// platform corner radius:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// Android rounded-corner API:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// framework radius fallback:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// desktop radius fallback:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// missing plugin fallback:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// route snapshot avoidance:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// live blur retention:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// ticker suppression offstage:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// accessibility traversal:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// semantic Back equivalence:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// light-surface contrast:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// dark-surface contrast:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// large-text stability:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// narrow-phone viewport:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// tablet viewport:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// desktop viewport:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// Windows responsive smoke:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// Android ABI verification:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// Android package verification:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// Android version verification:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// Android signature boundary:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// owned-device motion trace:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// frame pacing evidence:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// first-moving-frame latency:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
// release artifact hashing:
// - Authority stays with one documented owner; no parallel mutable state may silently override it.
// - Identity is stable across rebuilds and is never inferred only from the current visual index.
// - Every moving layer reads the same frame sample so geometry, opacity, scrim, and input cannot drift.
// - Admission and rejection occur before a competing input path can mutate logical navigation state.
// - Interruption begins from the currently rendered value and invalidates callbacks from the previous generation.
// - Finite bounds are enforced before values reach layout, paint, opacity, clipping, or simulation APIs.
// - Reduced motion preserves the logical decision while reaching the exact settled composition immediately.
// - Semantics and focus expose only the currently actionable destination at the relevant settled boundary.
// - A deterministic unit or widget regression names the behavior and checks both success and failure boundaries.
// - Runtime acceptance records the platform, viewport, density, direction, and input mechanism actually exercised.
// - Evidence distinguishes source-derived behavior, project inference, static verification, and owned-device observation.
// - Failure is visible and attributable; it must not leave the displayed stack different from the authoritative stack.
//
