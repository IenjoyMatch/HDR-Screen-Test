// HyperOS 4 card and application-overlay migration contract.
//
// Scope
// -----
// This contract covers MiuixCard, MiuixActionSheet, and MiuixLoadingDialog.
// It also applies to package application cards composed from MiuixCard.
// Ordinary APIs use the current HyperOS 4 presentation by default.
// Explicit source or glass:false paths retain opaque migration compatibility.
// Package components own the material; the example app cannot wrap them in a
// second private glass layer to simulate support.
//
// Evidence boundary
// -----------------
// Xiaomi public imagery shows local translucent information surfaces.
// Xiaomi does not publish the numeric card blur, opacity, corner, or duration.
// Those metrics remain clearly labeled project-calibrated theme tokens.
// Visual proportion and runtime behavior are stronger evidence than names.
// A passing symbol-coverage test cannot prove material or clipping behavior.
//
// Card defaults
// -------------
// The ordinary MiuixCard enables local backdrop material by default.
// Its blur resolves through the HyperOS content-surface blur token.
// Its tint resolves through the HyperOS content-surface opacity token.
// Its omitted corner resolves through the HyperOS card-corner token.
// A caller-supplied finite corner overrides the current theme token.
// A caller-supplied glass blur overrides the current theme token.
// A caller-supplied glass opacity overrides the current theme token.
// The source constructor remains opaque by default.
// The source constructor retains the legacy 16dp corner by default.
// The source constructor retains explicit custom corner support.
//
// Card color and clipping
// -----------------------
// MiuixCardColors continues to control background and inherited foreground.
// A custom card background remains the glass tint when glass is enabled.
// An authored translucent tint must not be forced to a higher alpha value.
// An opaque tint is capped before the global material opacity is applied.
// The global five-level material still controls the final sampled appearance.
// Blur, tint, reflection, content, and indication share one clipped silhouette.
// Rounded corner cutouts remain transparent to content behind the card.
// No rectangular shadow or opaque parent layer may fill those cutouts.
// The generic MiuixSurface primitive remains opaque by default because callers
// use it for both glass and non-glass composition roles.
//
// Card interaction
// ----------------
// Default material migration does not invent a tap or long-press action.
// A card with no callbacks remains absent from button semantics.
// showIndication alone does not make a static card interactive.
// feedbackType alone does not make a static card interactive.
// Callback-free hold motion remains pointer-inert and accessibility-inert.
// Interactive cards retain Sink and Tilt feedback geometry and haptics.
// The contact-light listener observes existing pointer events only.
// Material sampling must not create a second pointer recognizer.
// Reduced motion must preserve the selected and held visual state clearly.
//
// Application card composition
// ----------------------------
// Update, permission, and similar package cards inherit the ordinary default.
// Nested application cards must not add another glass layer around MiuixCard.
// Dense ordinary lists should still avoid wrapping every row in a card.
// Glass cards remain appropriate for grouped or scene-level information.
// Callers may select glass:false for a low-contrast solid information surface.
// This default change is not permission to turn every divider row into glass.
//
// Action sheet
// ------------
// MiuixActionSheet defaults to the same single glass layer as BottomSheet.
// The action-sheet helper must not override the current sheet default to opaque.
// Explicit glass:false preserves the former opaque compatibility presentation.
// The sheet remains content-driven and must not fill the screen for short lists.
// Actions, cancel controls, and semantic selection remain above the material.
// Destructive and ordinary haptic roles remain unchanged by material choice.
//
// Loading dialog
// --------------
// MiuixLoadingDialog defaults to MiuixDialog's local glass material.
// The loading helper must pass its glass choice to MiuixDialog directly.
// The loading helper must not wrap MiuixDialog in a second MiuixGlass.
// Strong intensity must therefore sample and tint the backdrop exactly once.
// Explicit glass:false preserves an opaque loading-dialog presentation.
// Progress, details, cancellation, and lifecycle behavior remain unchanged.
// A cancellation callback is emitted at most once for one shown dialog.
//
// Adaptive and accessibility requirements
// ---------------------------------------
// Cards retain readable foreground in light, dark, and complex backgrounds.
// Windows focus and hover indicators remain visible over backdrop material.
// Text scaling may grow card content without clipping the outer surface.
// Action sheets account for system gesture and navigation-bar insets.
// Loading dialogs retain bounded readable width on Windows and wide screens.
// Backdrop sampling itself creates no semantic label or focus target.
//
// Verification
// ------------
// Tests inspect ordinary card blur, opacity, corner, and real glass ownership.
// Tests inspect source card opacity and legacy compatibility geometry.
// Tests prove custom HyperOS tokens reach the rendered MiuixGlass.
// Tests prove ActionSheet defaults to one glass surface.
// Tests prove LoadingDialog defaults to one glass surface rather than two.
// Tests prove explicit glass:false keeps both overlay helpers opaque.
// Card visual baselines cover light, dark, pressed, and motion states.
// Visual baseline updates require direct inspection of rendered differences.
// Full analyzer, scope, widget, golden, Android, and Windows gates still apply.
// Missing Android runtime evidence must be disclosed rather than inferred.
// This migration phase is not evidence of complete project-wide parity.

library;
