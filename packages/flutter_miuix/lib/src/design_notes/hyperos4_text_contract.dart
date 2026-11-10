// HyperOS 4 high-level text contract.
//
// Evidence boundary
//
// Xiaomi has not published a complete Flutter typography metric table.
// The 16sp content-body size is therefore a project-calibrated value.
// It follows the proportions observed in official first-party app imagery.
// It also maps directly to the package bodyMedium theme role.
// This value must not be described as an official Xiaomi dp specification.
// The source constructors remain the authority for MIUIX 1.0.9 parity.
//
// Standard entry points
//
// MiuixText(data) is the default HyperOS 4 plain-text entry point.
// MiuixText.rich(span) is the default HyperOS 4 rich-text entry point.
// Both start from ThemeData.textTheme.bodyMedium.
// Their defensive fallback is 16sp, regular weight, and 1.16 line height.
// The same role is used in light and dark themes.
// Semantic theme colors supply the actual contrast for each brightness.
// Local content color can still override the generated theme color.
//
// Source compatibility entry points
//
// MiuixText.source(data) preserves the old plain Main role.
// MiuixText.sourceRich(span) preserves the old rich Main role.
// Both start from ThemeData.textTheme.bodyLarge.
// Their defensive fallback remains 17sp with the calibrated line box.
// Their input, layout, semantics, and automatic sizing APIs stay unchanged.
// No legacy rendering is selected implicitly from the text content.
//
// Override precedence
//
// The explicit color argument has the highest precedence.
// A caller-provided style color has the next precedence.
// The local content color follows caller-owned colors.
// The theme surface color is only a defensive final fallback.
// Caller style fields merge over the selected standard or source role.
// Individual font parameters merge after the caller style.
// Active automatic sizing owns the final font size.
// Rich spans may override the resolved paragraph style locally.
//
// Layout behavior
//
// Standard and source entry points share the same paragraph engine.
// minLines continues to reserve real line-box height.
// maxLines and overflow continue to reach RenderParagraph unchanged.
// TextScaler is included in minimum-line and automatic-size calculations.
// WidgetSpan dimensions continue to participate in rich automatic sizing.
// onTextLayout continues to report the installed paragraph geometry.
// Explicit 20sp or other caller sizes must not be normalized to 16sp.
//
// Interaction and accessibility
//
// Recognizer spans retain their gesture and semantic behavior.
// Unstyled link spans retain semantic primary color and underline.
// WidgetSpan children retain their own hit testing and semantics.
// semanticsLabel remains available on every constructor.
// Visible text remains the default accessible label.
// Typography migration must not alter semantic text content.
//
// Regression obligations
//
// Unit tests compare standard 16sp and source 17sp roles.
// Unit tests cover both plain and rich constructors.
// Existing color-precedence tests use explicit source constructors.
// Existing link, WidgetSpan, minLines, and auto-size tests must pass.
// Light and dark goldens cover the standard body role.
// Light and dark goldens cover the explicit source role.
// Goldens include plain, rich, and caller-sized paragraphs.
// Component baselines remain stable when their size is explicitly provided.
// Full analysis and the complete test suite gate every release cycle.
