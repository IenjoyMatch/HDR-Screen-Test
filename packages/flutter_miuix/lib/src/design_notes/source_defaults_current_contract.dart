// Current-source defaults and palette contract.
//
// SurfaceDefaults and TextFieldColors are public source declarations, not
// incidental constants that may remain hidden inside Flutter build methods.
// The following maintenance rules preserve their API and rendering meaning.
//
// Surface defaults:
// - The source default shape is a rectangle with no rounded corners.
// - The source default shadow elevation is zero logical pixels.
// - A caller-provided ShapeBorder always wins over every radius convenience.
// - A caller-provided radius remains a Flutter compatibility extension.
// - The explicit source constructor resolves through SurfaceDefaults.shape.
// - The ordinary constructor keeps the package's HyperOS shape routing.
// - A finite compatibility radius may use the active G2 shape preference.
// - A non-finite compatibility radius is normalized without poisoning paint.
// - A negative compatibility radius is clamped to zero.
// - SurfaceDefaults must not inherit HyperOS card radius tokens.
// - SurfaceDefaults must not invent a border or minimum interactive size.
// - The non-clickable overload remains an accessibility traversal container.
// - The clickable overload retains the same shape for fill and indication.
// - Margin remains outside the source paint and interaction region.
// - Content color remains independent from the surface fill.
// - Positive explicit elevation owns the only outer shadow layer.
// - Zero elevation must not allocate a transparent shadow decoration.
//
// Text-field palette:
// - TextFieldColors contains background, label, and focused-border channels.
// - Every channel is immutable and participates in value equality.
// - copyWith changes only channels explicitly supplied by the caller.
// - Default background uses the secondaryContainer semantic role.
// - Default label uses the onSecondaryContainer semantic role.
// - Default focused border uses the primary semantic role.
// - The cursor follows the resolved border unless explicitly overridden.
// - The idle outline interpolates from the resolved background channel.
// - The focused outline reaches exactly two logical pixels.
// - Inline and floating label states share the resolved label channel.
// - Palette changes must not alter the label spring or geometry.
// - Palette changes must not alter editable text inheritance.
// - Palette changes must not tint arbitrary leading or trailing source slots.
// - The complete palette is accepted by ordinary and source constructors.
// - Existing individual color arguments remain compatibility overrides.
// - backgroundColor overrides only the palette background channel.
// - labelColor overrides only the palette label channel.
// - borderColor overrides only the palette focused-border channel.
// - Omitting an individual argument preserves the corresponding palette value.
// - Omitting the palette resolves all three channels from the active context.
// - Context resolution must happen during build, never in a const constructor.
// - Theme changes therefore update an unoverridden palette on the next build.
// - Disabled and read-only behavior remain independent from palette ownership.
// - Reduced motion changes animation timing, not resolved color values.
// - Explicit TextStyle.color remains the editable-text foreground authority.
//
// Source mapping:
// - Current MIUIX ColorSchemeMode has exactly six behavior branches.
// - MiuixColorMode represents System, Light, Dark, and the three Monet modes.
// - The legacy MiuixColorSchemeMode describes older Flutter source metadata.
// - Legacy preset/custom/dynamic names are compatibility extensions only.
// - A compatibility extension must not count as current-source parity proof.
// - Scope mappings name the implementation that owns runtime behavior.
// - Adding a source mapping requires a real public declaration in lib.
// - A name-only class must not satisfy a behavior or visual completion claim.
// - Public defaults added here are included in the required-name gate.
// - Direct tests must exercise construction as well as rendered consumption.
// - Full suite and Release validation remain mandatory after these changes.
// - Android build proof remains separate from owned-device visual proof.
// - HyperOS project defaults and explicit source defaults remain distinguishable.
// - Project-derived dimensions must not be presented as Xiaomi public tokens.
// - Future upstream changes require re-reading the authoritative Kotlin source.
//
// Source-constructor interaction details:
// - Source surfaces disable package glass unless the caller uses another API.
// - A null source onClick selects the non-clickable overload semantics.
// - A non-null source onClick selects the clickable overload semantics.
// - Disabled source surfaces keep paint but remove pointer activation.
// - A null source indication suppresses only indication, not the click action.
// - An explicit source border remains outside the clipped indication layer.
// - An explicit source content color still reaches nested text and icons.
// - Source shape identity is inspectable without rendering a compatibility radius.
// - Ordinary radius behavior remains covered by the smooth-rounding regression.
// - The source constructor must not silently enable HyperOS glass on rebuild.
// - The source constructor must not invent padding, margin, or feedback motion.
// - A supplied interaction source remains observable across enabled changes.
// - Factory defaults and SurfaceDefaults must be changed in the same revision.
// - Tests cover both the source defaults and ordinary HyperOS shape behavior.
// - Release validation must retain both branches after future refactors.
