// HyperOS 4 command-palette material contract.
//
// This file deliberately contains no runtime declarations. It records the
// visual and ownership rules that are otherwise easy to lose while changing
// filtering, keyboard navigation, dialog routing, or reusable surface code.
//
// Evidence boundary:
// - Xiaomi does not publish command-palette dp values as an official table.
// - Popup material values are therefore project-calibrated theme tokens.
// - The official content-first and spatial-continuity direction is the basis.
// - Legacy MIUIX behavior remains available only through explicit source APIs.
//
// Embedded standard palette:
// - The complete palette owns exactly one local popup surface.
// - Its clip, tint, backdrop filter, and edge reflection share one silhouette.
// - Radius resolves from popupCornerRadius unless the caller overrides it.
// - Blur resolves from popupBlur unless the caller overrides it.
// - Tint resolves from popupTintOpacity unless the caller overrides it.
// - The specular edge can be disabled without disabling blur or tint.
// - glass=false creates one opaque surface with the same spatial geometry.
// - The panel never extends its blur beyond its own continuous corner clip.
// - Search, results, shortcuts, and empty state remain inside that one owner.
//
// Standard dialog palette:
// - MiuixDialog owns the only backdrop-filtering layer on the route.
// - The nested palette shell is transparent and has glass disabled.
// - The transparent shell may preserve sizing but cannot resample the scene.
// - The title and command content therefore share one coherent modal depth.
// - Closing the dialog precedes invocation of the selected command future.
// - Navigation started by a command cannot race the dialog exit transition.
//
// Source compatibility:
// - MiuixCommandPalette.source does not invent an embedded panel surface.
// - Existing applications may continue to provide their own opaque host.
// - MiuixCommandPalette.showSource disables the dialog glass material.
// - Source filtering, focus, shortcuts, semantics, and callbacks stay intact.
// - Source is an explicit migration boundary, not the new visual default.
//
// Row hierarchy:
// - Command rows do not create independent backdrop filters.
// - The selected row uses a semantic solid tint over the shared panel.
// - Disabled rows remain distinguishable without lowering panel contrast.
// - Icon, title, subtitle, category, and shortcut retain content hierarchy.
// - The complete row is the pointer and semantic target.
// - Row corners resolve from the shared collection-row token family.
// - Selection tint and foreground interpolate on the same motion timeline.
// - Reduced motion replaces any in-flight sample with the logical endpoint.
//
// Input and layout:
// - The search field is the first focusable element.
// - A short result list keeps a content-fitting panel height.
// - maxHeight is a cap and never a forced full-height destination.
// - Long results scroll while the search field remains fixed.
// - Filtering resets the visible highlight coordinate deterministically.
// - An empty result retains the same anchored panel coordinate space.
// - Route safe-area padding must not leak into the internal result ListView.
//
// Keyboard and accessibility:
// - Arrow keys move across visible logical results.
// - Enter and pointer activation publish the same command object.
// - Disabled commands cannot become invokable endpoints.
// - Escape delegates dismissal through the caller-provided callback.
// - Each row reports button, enabled, selected, and title semantics.
// - Confirmation haptics occur only after an enabled command is invoked.
// - Controller replacement preserves caller ownership and listener disposal.
//
// Verification requirements:
// - Widget tests inspect popup token resolution and explicit overrides.
// - Widget tests prove standard embedded glass and source host separation.
// - Dialog tests prove one enabled glass owner in the standard route.
// - Dialog tests prove the source route uses an opaque disabled-glass owner.
// - Motion tests cover interruption and the reduced-motion endpoint.
// - Light and dark goldens compare standard and source presentations.
// - Full package tests and static analysis remain release gates.
