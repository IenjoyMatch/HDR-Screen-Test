// MIUIX 1.0.9 SmallTitle parity contract.
//
// Purpose
//
// This note records the complete behavior defined by SmallTitle.kt.
// SmallTitle is intentionally a thin composition over the MIUIX Text primitive.
// Its few defaults still affect every grouped section in the example.
// The local upstream source remains authoritative for future maintenance.
//
// Source API
//
// text is the displayed String.
// modifier is applied to the Text node before inside padding is appended.
// textColor defaults to onBackgroundVariant.
// insideMargin defaults to SmallTitleDefaults.InsideMargin.
// The function returns no interaction state.
// The function exposes no maximum-line parameter.
// The function exposes no overflow parameter.
// The function exposes no background.
// The function exposes no border.
// The function exposes no elevation.
//
// Flutter API mapping
//
// The positional title argument represents source text.
// The existing public title field remains source-compatible.
// The text getter exposes the source parameter name as an alias.
// textColor represents the explicit source color parameter.
// A null textColor resolves to onBackgroundVariant.
// insideMargin accepts EdgeInsetsGeometry as Flutter PaddingValues.
// A null insideMargin resolves through MiuixSmallTitleDefaults.
// Widget wrappers represent the caller's Modifier chain.
// The widget key remains a Flutter identity adapter.
//
// Defaults object
//
// Source SmallTitleDefaults contains one value.
// InsideMargin is 28dp on both horizontal edges.
// InsideMargin is 8dp on both vertical edges.
// MiuixSmallTitleDefaults.insideMargin exposes the same immutable value.
// The default is a content inset rather than outside section spacing.
// List-level 12dp page padding remains outside this component.
// Example pages therefore pass 16dp horizontal inside padding.
// Twelve outer dp plus sixteen inner dp preserves the source 28dp text origin.
//
// Typography
//
// SmallTitle uses MiuixTheme.textStyles.subtitle.
// Subtitle has a 14sp font size.
// Subtitle uses FontWeight.Bold.
// Flutter maps Bold to FontWeight.w700.
// Source letter spacing is the platform default zero.
// The package fixes letter spacing at zero for deterministic raster output.
// The calibrated Android line box uses the package 1.16 multiplier.
// MIUIX font-family fallbacks remain available through MiuixText.
// SmallTitle does not select a Material section-header typography role.
//
// Color
//
// The default source role is onBackgroundVariant.
// It is not Material onSurfaceVariant.
// The default light reference value is 0xFF8C93B0.
// Dark and dynamic modes resolve the active semantic role.
// Explicit textColor overrides the semantic default.
// Explicit textColor is passed to the MIUIX Text primitive.
// LocalContentColor does not replace an explicit SmallTitle source color.
// Disabled opacity is not part of SmallTitle.kt.
//
// Modifier and padding order
//
// Source calls Text with modifier.padding(insideMargin).
// The caller modifier therefore precedes inside padding.
// A caller size or parent constraint encloses the padded title.
// The padding encloses only the text layout.
// Padding is not clickable.
// Padding contributes to semantics bounds through the parent layout.
// Flutter wrappers remain outside MiuixSmallTitle.
// The component Padding remains immediately inside the widget.
//
// Physical-pixel rounding
//
// Compose resolves each PaddingValues edge independently.
// At 420dpi, 28dp resolves to 74 physical pixels.
// At 420dpi, 8dp resolves to 21 physical pixels.
// The default 14sp subtitle placeable resolves to 43 physical pixels high.
// The one-line complete component therefore resolves to 85 physical pixels.
// Combining 8 + lineHeight + 8 before rounding can produce 84px.
// Flutter preserves the three independent measurement stages.
// Only the minimum one-line text height is rounded.
// Real wrapped text remains free to grow beyond that minimum.
//
// Same-device evidence
//
// The upstream SearchBar title text node is [74,331][241,374].
// Its physical text height is 43px.
// The upstream horizontal origin is 74px from the screen edge.
// The translated list owns a separate 32px outer page inset.
// Its SmallTitle therefore supplies the remaining 42px 16dp inset.
// The complete translated title slot remains 85px high.
// Existing six-state component goldens remain unchanged after API completion.
//
// Directionality
//
// Compose PaddingValues resolves start and end through LayoutDirection.
// EdgeInsetsDirectional provides the corresponding Flutter behavior.
// Every resolved edge is rounded after direction resolution.
// At 420dpi, a custom 10dp edge resolves to 26px.
// At 420dpi, a custom 20dp edge resolves to 53px.
// RTL swaps those physical left and right placements.
// The Text primitive receives the active RTL direction.
// Symmetric defaults remain visually identical in both directions.
//
// Wrapping and scaling
//
// Source Text keeps softWrap enabled.
// Source Text keeps maxLines effectively unlimited.
// Long localized titles may wrap naturally.
// Wrapped titles grow rather than clip or ellipsize.
// The complete visible String remains in accessibility semantics.
// TextScaler is applied before physical line-height rounding.
// Accessibility text scaling therefore increases the minimum line box.
// A larger glyph layout may exceed that minimum naturally.
// SmallTitle never freezes text at the default 43px raster height.
//
// Interaction and semantics
//
// SmallTitle itself has no click callback.
// It has no role flag such as button or header.
// It has no pressed indication.
// It has no haptic feedback.
// MiuixText publishes the visible String as ordinary text semantics.
// Wrapping does not insert semantic newline characters.
// Custom text color does not alter semantics.
//
// Original example contract
//
// MainPage uses SmallTitle before every component section.
// ColorPage uses it before each of five semantic-color groups.
// MultiScaffold uses it inside each local host.
// BottomSheet behavior settings use a custom 16dp horizontal inset.
// Blur uses separate Texture Blur and Foreground Blur titles.
// The localized Flutter example translates visible labels only.
// Section order, slot size, and text origin remain source-equivalent.
//
// Regression obligations
//
// Default padding requires independent horizontal and vertical assertions.
// Default one-line physical height requires a 420dpi assertion.
// Subtitle font size, weight, line box, and letter spacing require assertions.
// Default semantic color requires a light-token assertion.
// Explicit textColor requires an override assertion.
// Defaults object value requires a public API assertion.
// Directional custom insets require an RTL physical-pixel assertion.
// Long localized text requires a wrap-and-grow assertion.
// Long text semantics must retain the complete String.
// Six existing visual baselines must remain unchanged.
