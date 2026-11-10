// HyperOS 4 date-range material contract.
//
// Surface ownership:
// - The picker contains two endpoint summaries and one month-calendar panel.
// - Each endpoint is a local surface rather than a full-width background band.
// - The calendar remains one complete clipped panel beneath those endpoints.
// - No material layer may extend into the gaps around the three silhouettes.
// - Colored scene content must remain visible through ordinary glass mode.
//
// Shared tokens:
// - Endpoint and calendar surfaces read calendarCornerRadius.
// - Endpoint and calendar surfaces read calendarBlur.
// - Endpoint and calendar surfaces read calendarTintOpacity.
// - These values are project calibrations, not unpublished Xiaomi constants.
// - Theme replacement therefore retunes the complete date-range composition.
// - Call sites do not need to duplicate blur or corner measurements.
//
// Material modes:
// - The ordinary default keeps glass=true for the complete picker.
// - Both endpoint summaries and the calendar sample their real backdrop.
// - Passing glass=false makes all three local surfaces opaque.
// - The solid option changes material only and preserves current geometry.
// - It remains suitable for low-performance or deliberately plain scenes.
// - No hidden ancestor-sized glass or opaque rectangle is introduced.
//
// Selection hierarchy:
// - The active endpoint uses the semantic primary-container tint.
// - The inactive endpoint uses the semantic surface-container tint.
// - Glass opacity preserves those roles while allowing scene color through.
// - Endpoint foregrounds retain their matching semantic contrast roles.
// - Start and end values remain single-line and ellipsize in narrow windows.
// - Missing endpoint text remains a stable em dash instead of collapsing.
//
// Motion and interaction:
// - Endpoint tint changes use pickerStageMotion.
// - Reduced motion resolves the new tint without an autonomous transition.
// - The material wrapper does not add a pointer recognizer.
// - Calendar day taps continue to own start/end range selection.
// - Horizontal month gestures continue to stay within the calendar panel.
// - Controller synchronization and inclusive range normalization are unchanged.
// - Confirm haptics remain owned by the modal confirmation action.
//
// Rendering requirements:
// - Glass, tint, content, highlight and corner clipping share one outline.
// - Specular rendering remains inside each continuous-corner endpoint.
// - Complex backgrounds must not turn endpoint surfaces into opaque white cards.
// - Dark mode must preserve range, endpoint and adjacent-day readability.
// - The selected range color band remains independent from endpoint material.
//
// Regression obligations:
// - Unit tests inspect endpoint glass, blur, opacity and theme radius.
// - Unit tests verify glass=false reaches the endpoint surfaces.
// - Existing tests keep normalized inclusive selection behavior covered.
// - Light and dark goldens compare glass with the solid fallback.
// - Golden backgrounds include gradients and colored objects behind the picker.
// - Full package tests and a complete release cycle gate every material change.
