// MIUIX v1.0.9 theme-mode reconstruction contract.
//
// Purpose
// -------
// This note records the observable source behavior used by the Flutter port.
// It prevents the example settings from drifting into a custom theme editor.
// It also explains which options belong to the public library theme object.
// Visible labels may be localized, but option identity and order stay intact.
//
// Color modes
// -----------
// The source exposes exactly six color modes.
// System is the first mode.
// Light is the second mode.
// Dark is the third mode.
// Monet System is the fourth mode.
// Monet Light is the fifth mode.
// Monet Dark is the sixth mode.
// System follows the host brightness.
// Light always resolves to a light scheme.
// Dark always resolves to a dark scheme.
// Monet System follows the host brightness.
// Monet Light always resolves to a light dynamic scheme.
// Monet Dark always resolves to a dark dynamic scheme.
// Fixed modes do not expose dynamic key-color controls in the example.
// Monet modes expose the key-color control immediately.
//
// Key colors
// ----------
// Default is the first key-color choice.
// Blue, green, purple, yellow, orange, pink, and teal follow Default.
// The translated labels do not change the source RGB values.
// Default represents the absence of an explicit user seed.
// A missing explicit seed uses Android's platform dynamic palette on Android.
// Other platforms use ThemeController's deterministic fallback purple.
// Selecting a concrete key color rebuilds all inherited MIUIX theme data.
// The color preview page reads the same effective seed as the components.
// Key-color selection survives changes between the three Monet modes.
// Fixed modes retain the selection without applying it to their fixed scheme.
//
// Palette styles
// --------------
// Palette controls appear only after a concrete Monet key color is selected.
// Tonal Spot is the first and default palette family.
// Neutral is the second palette family.
// Vibrant is the third palette family.
// Expressive is the fourth palette family.
// Rainbow is the fifth palette family.
// Fruit Salad is the sixth palette family.
// Monochrome is the seventh palette family.
// Fidelity is the eighth palette family.
// Content is the ninth palette family.
// Their order follows the source SettingsPage rather than alphabetical order.
// Every family maps to the corresponding Flutter dynamic-scheme variant.
// Changing family must change the generated scheme without changing its seed.
// Changing family must not alter the selected light or dark mode policy.
//
// Color specifications
// --------------------
// The source exposes Spec 2021 first and Spec 2025 second.
// Specification controls follow the same visibility rule as palette controls.
// The selected specification is retained in MiuixThemeData.
// copyWith preserves it unless a replacement is supplied.
// Theme interpolation chooses one specification at the midpoint.
// Monet generation uses the same 2021 and 2025 dynamic-color algorithms.
// Tonal Spot, Neutral, Vibrant, and Expressive retain a requested Spec 2025.
// Rainbow, Fruit Salad, Monochrome, Fidelity, and Content fall back to 2021.
// This support matrix is the one implemented by source ThemeController.kt.
// Every generated Material role is preserved before MIUIX semantic mapping.
// Tests lock representative 2021 and 2025 colors for the example's blue seed.
// The fallback does not affect the six mode choices or nine palette styles.
//
// Settings visibility
// -------------------
// Color Mode is always visible in the main source settings card.
// Key Color is hidden for System, Light, and Dark.
// Key Color is visible for all three Monet modes.
// Palette Style is hidden while Key Color is Default.
// Color Spec is hidden while Key Color is Default.
// Palette Style appears after a concrete Monet key is selected.
// Color Spec appears after a concrete Monet key is selected.
// Returning to a fixed mode hides all three conditional dynamic controls.
// Returning to Monet restores the retained selections.
// Conditional rows must not leave blank dividers or placeholder height.
// The source settings cards do not add automatic section headings.
// The source settings cards do not add automatic row dividers.
//
// Glass interaction
// -----------------
// Theme color selection and liquid-glass intensity are independent tokens.
// Changing a palette does not reset the five-level glass choice.
// Changing a glass level does not reset the key color or palette family.
// Disabling blur retains the chosen glass intensity for later restoration.
// Glass components tint from the currently resolved color scheme.
// Opaque components continue to use the same resolved semantic colors.
// Floating navigation paints only its pill-shaped glass surface.
// The rectangular area around that pill remains transparent.
// Page content remains laid out behind floating navigation through extendBody.
// Transparent regions never become a full-screen modal or opaque scaffold.
//
// Verification
// ------------
// Unit tests count all six public color-mode values.
// Unit tests count all nine public palette-style values.
// Unit tests count both public color-specification values.
// Widget tests verify conditional settings-row visibility.
// Widget tests verify forced brightness for Monet Light and Monet Dark.
// Widget tests verify a selected key color reaches inherited theme data.
// Widget tests verify palette changes alter the generated primary color.
// Golden tests cover floating navigation above real scrolling page content.
// Golden tests cover the iOS-like selected-item liquid-glass treatment.
// Static analysis must remain clean after any option is added or renamed.
// The package comment-ratio check includes this maintained design contract.
//
// ThemeController constructor
// ---------------------------
// The source constructor defaults ColorSchemeMode to System.
// The source constructor defaults lightColors to lightColorScheme().
// The source constructor defaults darkColors to darkColorScheme().
// The source constructor defaults keyColor to null.
// The source constructor defaults ThemeColorSpec to Spec2021.
// The source constructor defaults ThemePaletteStyle to TonalSpot.
// The source constructor defaults isDark to null.
// Every constructor value is observable through a property of the same name.
// The Kotlin properties are backed by snapshot state.
// The Kotlin public properties expose immutable val access.
// Flutter exposes getters with the corresponding source meaning.
// Flutter mutation helpers replace recreation in a stateful Dart owner.
// Mutation helpers must still resolve through the original source branch table.
// The compatibility mode argument aliases colorSchemeMode.
// The compatibility seedColor argument aliases a non-null keyColor.
// Supplying both names for either alias pair is invalid.
// The legacy schemeMode field is Flutter metadata, not a source branch input.
// The source colorSchemeMode remains the authoritative runtime selector.
// The fixed schemes remain independent from the dynamic scheme pair.
// The optional platform pair remains independent from the fixed scheme pair.
//
// Fixed System branch
// -------------------
// System first resolves whether the active appearance is dark.
// A non-null isDark value wins over the platform appearance.
// A null isDark value delegates to the platform appearance.
// A dark result returns darkColors without regeneration.
// A light result returns lightColors without regeneration.
// System never reads keyColor.
// System never reads colorSpec.
// System never reads paletteStyle.
// System never reads platformDynamicColors.
// Replacing keyColor while System is active cannot recolor the interface.
// Replacing paletteStyle while System is active cannot recolor the interface.
// Replacing colorSpec while System is active cannot recolor the interface.
// Replacing lightColors immediately affects a light System appearance.
// Replacing darkColors immediately affects a dark System appearance.
// Clearing isDark returns brightness control to the platform.
//
// Fixed Light branch
// ------------------
// Light always returns lightColors.
// Light ignores the platform appearance.
// Light ignores isDark even when isDark is true.
// Light ignores keyColor.
// Light ignores colorSpec.
// Light ignores paletteStyle.
// Light ignores both platform dynamic schemes.
// A custom lightColors object is preserved rather than seed-generated.
// Updating the unused darkColors remains visible after switching to Dark.
// Updating keyColor remains visible as state after switching to Monet.
// Fixed Light still reports isDynamicColor as false.
//
// Fixed Dark branch
// -----------------
// Dark always returns darkColors.
// Dark ignores the platform appearance.
// Dark ignores isDark even when isDark is false.
// Dark ignores keyColor.
// Dark ignores colorSpec.
// Dark ignores paletteStyle.
// Dark ignores both platform dynamic schemes.
// A custom darkColors object is preserved rather than seed-generated.
// Updating the unused lightColors remains visible after switching to Light.
// Updating keyColor remains visible as state after switching to Monet.
// Fixed Dark still reports isDynamicColor as false.
//
// Monet System branch
// -------------------
// MonetSystem first resolves whether the active appearance is dark.
// A non-null isDark value wins over the platform appearance.
// A null isDark value delegates to the platform appearance.
// A non-null keyColor enters generated-palette behavior.
// Generated light colors use the requested key, style, and specification.
// Generated dark colors use the same key, style, and specification.
// The resolved appearance chooses one generated side.
// A null keyColor enters platform-dynamic behavior.
// Platform-dynamic light is selected for a light resolved appearance.
// Platform-dynamic dark is selected for a dark resolved appearance.
// Fixed lightColors and darkColors are not consulted in MonetSystem.
// MonetSystem reports isDynamicColor as true with or without a key.
//
// Monet Light branch
// ------------------
// MonetLight always resolves a light dynamic scheme.
// MonetLight ignores the platform appearance.
// MonetLight ignores isDark even when isDark is true.
// A non-null keyColor generates a light palette.
// A null keyColor requests the light platform dynamic palette.
// Fixed lightColors is not a substitute for platform dynamic light.
// Fixed darkColors is never read by MonetLight.
// MonetLight reports isDynamicColor as true.
// Switching from MonetLight to MonetDark retains key and palette metadata.
//
// Monet Dark branch
// -----------------
// MonetDark always resolves a dark dynamic scheme.
// MonetDark ignores the platform appearance.
// MonetDark ignores isDark even when isDark is false.
// A non-null keyColor generates a dark palette.
// A null keyColor requests the dark platform dynamic palette.
// Fixed darkColors is not a substitute for platform dynamic dark.
// Fixed lightColors is never read by MonetDark.
// MonetDark reports isDynamicColor as true.
// Switching from MonetDark to MonetLight retains key and palette metadata.
//
// Null-key platform behavior
// --------------------------
// The common source declares platformDynamicColors as an expected function.
// Android supplies the actual implementation.
// Android API 33 and newer first inspect the secure theme customization JSON.
// The secure setting key is theme_customization_overlay_packages.
// A non-empty system_palette value is parsed as the dynamic seed.
// A missing system_palette value falls back to system_accent1_500.
// The theme_style value selects the palette family.
// TONAL_SPOT maps to TonalSpot.
// VIBRANT maps to Vibrant.
// EXPRESSIVE maps to Expressive.
// SPRITZ maps to Neutral.
// RAINBOW maps to Rainbow.
// FRUIT_SALAD maps to FruitSalad.
// MONOCHROMATIC and MONOCHROME both map to Monochrome.
// FIDELITY maps to Fidelity.
// CONTENT maps to Content.
// NEUTRAL maps to Neutral.
// Unknown Android style names fall back to TonalSpot.
// Android API 36 and newer request Spec2025 from the secure palette.
// Android API 33 through 35 request Spec2021 from the secure palette.
// Malformed secure data falls through instead of failing theme construction.
// Android API 31 and newer can map the five platform palette families directly.
// The mapping reads accent1, accent2, accent3, neutral1, and neutral2 resources.
// Android API 34 changes several neutral-role tone projections.
// Older Android versions use the purple common fallback.
// Non-Android common targets use the same purple common fallback.
// The fallback seed is 0xFF6750A4.
// The fallback palette family is TonalSpot.
// The fallback specification is Spec2021.
// Flutter accepts a resolved platform light/dark pair at the controller boundary.
// The example Android channel reads the same secure seed, style, and spec inputs.
// A caller that has not resolved platform colors receives the common fallback.
//
// Palette generation
// ------------------
// Generation converts the ARGB key into HCT.
// Every generated DynamicScheme uses zero contrast.
// Every generated DynamicScheme targets the phone platform.
// TonalSpot maps to SchemeTonalSpot.
// Neutral maps to SchemeNeutral.
// Vibrant maps to SchemeVibrant.
// Expressive maps to SchemeExpressive.
// Rainbow maps to SchemeRainbow.
// FruitSalad maps to SchemeFruitSalad.
// Monochrome maps to SchemeMonochrome.
// Fidelity maps to SchemeFidelity.
// Content maps to SchemeContent.
// Spec2025 support is checked before scheme construction.
// TonalSpot supports Spec2025.
// Neutral supports Spec2025.
// Vibrant supports Spec2025.
// Expressive supports Spec2025.
// Rainbow downgrades Spec2025 to Spec2021.
// FruitSalad downgrades Spec2025 to Spec2021.
// Monochrome downgrades Spec2025 to Spec2021.
// Fidelity downgrades Spec2025 to Spec2021.
// Content downgrades Spec2025 to Spec2021.
// The requested public colorSpec remains unchanged after a runtime downgrade.
// Light and dark sides use the same effective support decision.
// Generated roles are mapped into MIUIX roles after scheme construction.
//
// MiuixTheme overload behavior
// ----------------------------
// The controller overload provides the controller colorSchemeMode locally.
// The controller overload resolves currentColors for every rebuild.
// The Flutter controller overload listens to ChangeNotifier updates.
// A mode mutation rebuilds descendants without replacing the controller.
// A key mutation rebuilds descendants without replacing the controller.
// A palette mutation rebuilds descendants without replacing the controller.
// A specification mutation rebuilds descendants without replacing the controller.
// An isDark mutation rebuilds descendants without replacing the controller.
// A platform-palette mutation rebuilds descendants without replacing the controller.
// The direct data overload has no source controller mode.
// The direct data overload therefore reports colorSchemeMode as null.
// A null source controller mode reports isDynamicColor as false.
// Controller MonetSystem reports isDynamicColor as true.
// Controller MonetLight reports isDynamicColor as true.
// Controller MonetDark reports isDynamicColor as true.
// Controller System reports isDynamicColor as false.
// Controller Light reports isDynamicColor as false.
// Controller Dark reports isDynamicColor as false.
// MiuixTheme.of continues to return the resolved MiuixThemeData extension.
// Flutter Material widgets receive the same resolved ColorScheme.
// MIUIX semantic roles derive from dynamic schemes only in Monet modes.
// Fixed schemes retain the explicit MIUIX light or dark semantic tables.
// Controller and direct-data inputs are mutually exclusive in one wrapper.
//
// Theme regression evidence
// -------------------------
// Unit coverage proves that a fixed key does not recolor System.
// Unit coverage proves that isDark overrides System brightness.
// Unit coverage proves that a concrete Monet key bypasses platform colors.
// Unit coverage proves that a null Monet key consumes platform colors.
// Unit coverage proves both supplied platform sides remain available.
// Widget coverage proves the controller overload rebuilds after setMode.
// Widget coverage proves the resolved Material primary follows the active side.
// Widget coverage proves fixed modes expose a false dynamic flag.
// Widget coverage proves Monet modes expose a true dynamic flag.
// Example coverage proves null-key Android data reaches the inherited theme.
// Example coverage proves Key Color visibility is limited to Monet modes.
// Example coverage proves Palette Style waits for a concrete key.
// Example coverage proves Color Spec waits for a concrete key.
// Full golden coverage guards the unchanged default fixed theme pixels.
