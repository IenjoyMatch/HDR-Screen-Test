// MIUIX 1.0.9 Text parity contract.
//
// Purpose
//
// This note records the durable behavior defined by basic/Text.kt.
// It covers both String and AnnotatedString overloads.
// The rules distinguish source behavior from Flutter representation details.
// Every rule affects public API, paint, layout, input, or accessibility.
//
// Source overloads
//
// The first overload accepts a String.
// The second overload accepts an AnnotatedString.
// Both overloads use the same default MIUIX main style.
// Both overloads accept an explicit color.
// Both overloads accept optional automatic sizing.
// Both overloads accept explicit font size.
// Both overloads accept optional font style.
// Both overloads accept optional font weight.
// Both overloads accept optional font family.
// Both overloads accept explicit letter spacing.
// Both overloads accept optional text decoration.
// Both overloads accept optional text alignment.
// Both overloads accept explicit line height.
// Both overloads accept overflow behavior.
// Both overloads accept soft-wrap behavior.
// Both overloads accept maximum and minimum line counts.
// Both overloads provide a layout callback.
// The AnnotatedString overload additionally accepts inline content.
//
// Flutter overload mapping
//
// MiuixText.source(data) represents the source String overload.
// MiuixText.sourceRich(span) represents the AnnotatedString overload.
// InlineSpan preserves styled ranges and link recognizers.
// WidgetSpan represents source InlineTextContent.
// The public data field remains available for compatibility.
// Rich instances keep data empty and expose their textSpan.
// Parent widgets represent the source Modifier argument.
// Flutter-only direction, locale, semantics, and line-box adapters are optional.
//
// Default style
//
// LocalTextStyles.current.main is the source default.
// Its source font size is 17sp.
// The package maps it to Theme.textTheme.bodyLarge.
// The calibrated Android line-box multiplier is retained.
// The calibrated regular font weight is retained.
// MIUIX font-family fallbacks remain available.
// A partial caller TextStyle merges over those platform defaults.
// Supplying only fontSize must not replace glyphs with the test fallback font.
// Final TextStyle inheritance is disabled after all fields are resolved.
// That prevents unrelated Material DefaultTextStyle fields from leaking in.
//
// Color precedence
//
// Explicit color has the highest precedence.
// A caller-supplied style color has the second precedence.
// LocalContentColor has the third precedence.
// The theme onSurface token is the final defensive fallback.
// Material eagerly adds onSurface to its generated bodyLarge style.
// That generated color is not a caller-supplied source style color.
// It must not hide a Surface-provided LocalContentColor equivalent.
// Surface contentColor therefore reaches plain and rich MiuixText.
// Explicit span colors still override the paragraph color.
//
// Individual style arguments
//
// Explicit fontSize merges over the base style.
// Explicit fontStyle merges over the base style.
// Explicit fontWeight merges over the base style.
// Explicit fontFamily merges over the base style.
// Explicit letterSpacing merges over the base style.
// Explicit textDecoration merges over the base style.
// Explicit lineHeight merges over the base style.
// Null values leave the corresponding base field unchanged.
// Automatic sizing takes precedence over explicit and style font sizes.
// Text alignment remains a paragraph property.
// Soft wrapping remains a paragraph property.
//
// Overflow and line count
//
// Source overflow defaults to Clip.
// Flutter null compatibility also resolves to Clip.
// Source softWrap defaults to true.
// Source maxLines defaults to Int.MAX_VALUE.
// Flutter null maxLines represents the same unlimited behavior.
// Source minLines defaults to one.
// minLines must be at least one.
// maxLines must not be lower than minLines.
// Ellipsis installs the same paragraph ellipsis marker.
// Fade, visible, and clip are forwarded without Material substitutions.
// softWrap false measures an effectively unbounded paragraph width.
//
// Minimum-line layout
//
// Flutter Text has no minLines parameter.
// TextPainter supplies the authoritative preferred line height.
// The outer text node applies that line height as a minimum.
// A one-line string with minLines three occupies three line boxes.
// Actual multi-line content may grow above that minimum.
// Active TextScaler is applied before minimum-line calculation.
// Tight parent constraints still remain authoritative.
// The minimum wrapper participates in semantics as one text component.
//
// Automatic sizing
//
// Source autoSize searches for the greatest fitting font size.
// The package exposes a step-based MiuixTextAutoSize value.
// Its minimum size must be positive.
// Its maximum must not be below the minimum.
// Its step granularity must be positive.
// Candidate sizes remain logical sp equivalents.
// The active TextScaler still applies to each candidate.
// Width, height, softWrap, maxLines, and minLines all affect fit.
// Explicit and style font sizes do not override an active policy.
// A binary search selects the greatest discrete fitting candidate.
// If even the minimum does not fit, the minimum remains selected.
// Unbounded constraints do not force unnecessary shrinking.
//
// Rich automatic sizing
//
// Standalone TextPainter ignores WidgetSpan sizes unless dimensions are set.
// Returning the largest font in that case is not source-equivalent.
// The live RenderParagraph already lays out every inline widget.
// MiuixText reads those public render-child sizes after the first frame.
// WidgetSpan preorder is matched to RenderParagraph child order.
// Placeholder alignment and baseline are retained.
// PlaceholderDimensions are fed into the following TextPainter pass.
// Automatic sizing then includes real inline width and height.
// Layout callback line metrics also include those placeholders.
// Stable dimensions do not trigger another rebuild.
// Changed inline dimensions trigger a new authoritative layout calculation.
//
// Annotated links
//
// Source URL and clickable annotations receive default styles when absent.
// The default source link color is the MIUIX primary token.
// The default source link decoration is underline.
// Explicit link styles remain unchanged.
// Flutter GestureRecognizer represents a clickable annotation.
// An otherwise unstyled recognizer span receives primary plus underline.
// Its recognizer, cursor, pointer callbacks, locale, and semantics are retained.
// Child span order is retained.
// Non-link spans do not receive link styling.
//
// Inline content
//
// Source inlineContent replaces annotated ranges with composables.
// Flutter WidgetSpan embeds an arbitrary Widget at the same paragraph position.
// Inline child semantics remain available.
// Inline child hit testing remains available.
// Inline alignment and baseline remain caller-owned.
// WidgetSpan children are not flattened into plain glyphs.
// Plain-text diagnostics use InlineSpan.toPlainText.
//
// Layout callback
//
// Source onTextLayout runs after a new paragraph layout is calculated.
// Flutter does not publish RenderParagraph's private TextPainter.
// MiuixTextLayoutResult exposes the corresponding stable observations.
// It includes actual laid-out widget size.
// It includes line metrics.
// It includes didExceedMaxLines.
// It includes the selected automatic font size.
// It includes the plain-text representation.
// lineCount is derived from line metrics.
// WidgetSpan metrics are populated after live placeholder capture.
// The callback runs after the render tree has installed the layout.
// An unchanged layout signature is not reported repeatedly.
// Replacing the callback permits the current layout to be reported again.
//
// Accessibility
//
// Flutter Text and Text.rich publish ordinary text semantics.
// Rich link recognizers publish clickable span semantics.
// WidgetSpan contributes its child semantics separately.
// semanticsLabel is a Flutter compatibility adapter.
// Default visible text remains the semantic label when no override is supplied.
// minLines does not invent newline characters in semantics.
// Automatic sizing does not change semantic content.
//
// Existing source visual compatibility
//
// MiuixText.source remains source-compatible with the previous data constructor.
// MiuixText.sourceRich retains the previous rich-text source rendering.
// Existing style, textAlign, maxLines, and overflow arguments remain available.
// The six component golden states remain pixel-identical.
// A partial 24sp style retains the same MIUIX font fallback and raster.
// The explicit source Main role remains 17sp with its calibrated line box.
// No Material TextTheme role is substituted based on content.
//
// Regression obligations
//
// Plain default role and line box require an assertion.
// Explicit, style, and local content colors require separate assertions.
// Individual style fields require merge assertions.
// Rich unstyled links require primary and underline assertions.
// Explicit link style preservation requires an assertion.
// WidgetSpan mounting requires an assertion.
// minLines requires a physical height assertion.
// Plain automatic sizing requires bounded width and height assertions.
// Rich automatic sizing requires live placeholder assertions.
// Layout callback requires actual size and line-count assertions.
// maxLines and ellipsis require forwarding assertions.
// Existing Text goldens must remain unchanged.
