// MIUIX v1.0.9 nested popup placement contract.
// This note documents why popup geometry uses two coordinate spaces.
// PopupPositionProvider first receives Android window coordinates.
// The complete safe window bounds placement before any local clipping.
// A nested PopupHost does not replace those global placement bounds.
// It only becomes the drawing and interaction clip for its popup surface.
// Therefore a surface may have a negative coordinate in host-local space.
// That negative coordinate is intentional and must not be clamped to zero.
// MultiScaffoldTestPage provides the authoritative four-host fixture.
// Its compact reference viewport is 1080 by 2400 physical pixels.
// The reference density is 420 dpi, or 2.625 physical pixels per dp.
// Each fixture column occupies exactly 540 physical pixels.
// The lower-right dropdown anchor ends at physical x 1006.
// Its three-row ListPopup keeps the source 200dp or 525px width.
// The uncut surface consequently occupies physical x 481 through 1006.
// The lower-right host begins at physical x 540.
// PopupHost clips the painted and semantic row content at that x coordinate.
// The resulting visible content occupies physical x 540 through 1006.
// Moving the surface itself to x 540 is not equivalent to clipping it.
// That mistake shifts its far edge to x 1065 and changes row alignment.
// Keeping x 481 without clipping is also incorrect despite matching bounds.
// It visibly leaks the surface into the neighboring lower-left Scaffold.
// The Flutter implementation must preserve both stages independently.
// First it translates the global anchor by the truncated host origin.
// Then it lays out against safe window bounds translated into host space.
// Finally a nested host clips its popup layer to the host rectangle.
// Root popup hosts remain unclipped beyond their ordinary window boundary.
// This preserves existing root dialogs, menus, and cascading-menu goldens.
// Compose truncates positionInWindow before adding measured integer size.
// Flutter otherwise combines fractional position and size until painting.
// The reference fixture applies one physical-pixel horizontal correction.
// That correction belongs only to the fixture's half-width end-action slot.
// It must not change ordinary full-width dropdown preference alignment.
// The top-left fixture remains clamped to the global window's x zero edge.
// The lower-right fixture is allowed to begin left of its local host origin.
// Vertical dropdown placement continues to prefer below, then above.
// If neither side fits, it centers on the anchor before safe-window clamping.
// The 8dp dropdown margin remains part of that global vertical calculation.
// Android system-bar padding constrains the root safe window only once.
// Translating those safe edges prevents nested hosts duplicating insets.
// Widget tests assert the uncut surface rectangle and the host clip rectangle.
// Device UI trees assert the final clipped accessibility row boundaries.
// Device screenshots prove the neighboring quadrant remains visually clear.
// Runtime logs must contain no Flutter exception or RenderFlex overflow.
// A regression is not accepted merely because the popup origin is correct.
// Width, far edge, clipping, dim-layer ownership, and row rhythm all matter.
// This contract applies to Overlay presentation with renderInRootScaffold false.
// Window presentation still belongs to the root Navigator coordinate space.
// Overlay presentation with renderInRootScaffold true uses the root host.
// Standalone MiuixPopupHost keeps its prior root behavior when it has no parent.
// Only a host with a parent controller receives the nested clipping stage.
// These distinctions mirror the source fixture instead of inventing new UI.
