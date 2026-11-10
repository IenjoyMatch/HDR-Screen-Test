// HyperOS 4 autocomplete-field contract.
//
// This documentation-only library records the package decisions shared by
// the editable anchor, RawAutocomplete overlay, and result rows. Values are
// project calibration unless Xiaomi has published an explicit measurement.
//
// Anchor contract:
// - RawAutocomplete remains the owner of overlay attachment and direction.
// - The field paint transform determines the popup's logical start edge.
// - Keyboard insets and safe-area bounds are resolved by Flutter's overlay.
// - The package must not recenter a short result list in the viewport.
// - The standard field radius resolves from textFieldCornerRadius.
// - An explicit finite fieldCornerRadius overrides the theme role.
// - Negative explicit radii are clamped to zero instead of asserting later.
// - Source construction keeps the prior 16dp editable-field geometry.
//
// Popup material contract:
// - Standard construction opts into popup glass.
// - popupBlur supplies the default backdrop sigma.
// - popupTintOpacity supplies the default semantic tint strength.
// - popupCornerRadius supplies the default continuous silhouette.
// - popupGlassBlur and popupGlassOpacity override their theme channels.
// - showPopupGlassSpecular may disable highlight without disabling blur.
// - popupGlass false preserves new geometry with a readable solid fallback.
// - Global enableGlass and intensity remain authoritative after local opt-in.
// - The clipped popup owns one shadow and one material sample only.
// - Result rows never add another backdrop filter inside the popup.
// - Source construction uses an opaque 18dp result plane without specular.
//
// Width contract:
// - Standard results match the editable-field width by default.
// - Narrow fields clamp the popup before the public minimum can overflow.
// - Wide desktop fields stop at maximumOptionsWidth.
// - The result plane stays aligned to the field's logical start after capping.
// - matchFieldWidth false makes minimumOptionsWidth an explicit compact width.
// - Invalid zero or reversed public width ranges fail at construction time.
// - Directionality changes alignment, not the meaning of minimum or maximum.
// - Popup width never becomes the complete desktop overlay width by accident.
//
// Height contract:
// - A short result list remains content-driven.
// - maximumOptionsHeight introduces scrolling only after content reaches it.
// - Available overlay height clamps a caller-provided larger maximum.
// - RawAutocomplete may place the plane above when the chosen direction says
//   so; the content itself must not add a second vertical offset.
// - Every stock row retains the authored equal option height.
// - Custom result content remains clipped by the same popup silhouette.
//
// Interaction contract:
// - RawAutocomplete continues to own arrow-key highlight and submission.
// - Pointer selection routes through the same onSelected callback.
// - Confirmation haptic fires after an option has been accepted.
// - The public controller receives the selected typed value exactly once.
// - Externally owned text controllers and focus nodes are never disposed.
// - Replacing either external object detaches the old owned state safely.
// - Reduced motion snaps highlight progress but preserves selection behavior.
// - Disabled text entry cannot create a separate interactive popup contract.
//
// Verification contract:
// - Theme tests inspect field radius, popup blur, tint, shape, and specular.
// - Compatibility tests inspect the source field and opaque popup together.
// - Geometry tests cover narrow, matched, wide-capped, and compact widths.
// - Interaction tests type a query and accept a typed option.
// - Light and dark goldens include a complex background behind the popup.
// - Golden review distinguishes sampled glass from the opaque source plane.
// - These checks prove package behavior, not unpublished official pixel data.
library;
