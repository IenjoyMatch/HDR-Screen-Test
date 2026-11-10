// MIUIX v1.0.9 ArrowPreference source contract.
//
// Authority
// The authoritative checkout is C:/Code/miuix-src-090.
// The primary file is miuix-preference/.../ArrowPreference.kt.
// Shared row behavior comes from miuix-ui/.../basic/Component.kt.
// The primary fixture is example/shared/.../component/ArrowSection.kt.
// Width-pressure fixtures come from example/shared/.../NavigateTestPage.kt.
// The Flutter implementation is widgets/parts/preference_controls.dart.
// Shared Flutter layout is widgets/parts/preferences.dart.
// Source dimensions map one Compose dp to one Flutter logical pixel.
// Android parity measurements use the established 420dpi fixture.
// A later MIUIX revision requires a new audit before changing this contract.
//
// Public function surface
// ArrowPreference requires a non-null title String.
// modifier has no direct Flutter field because Widget parents own placement.
// titleColor is a BasicComponentColors value.
// summary is nullable.
// summaryColor is a second independent BasicComponentColors value.
// startAction is an optional arbitrary content slot.
// endActions is an always-invoked RowScope content slot.
// bottomAction is an optional arbitrary content slot.
// insideMargin defaults to BasicComponentDefaults.InsideMargin.
// onClick is nullable.
// holdDownState defaults to false.
// enabled defaults to true.
// The Flutter source constructor retains those source parameter names.
// The unnamed constructor retains prior Flutter spellings for compatibility.
//
// Delegation
// ArrowPreference delegates its complete body to BasicComponent.
// It does not create an additional Card.
// It does not create an additional Surface.
// It does not create an additional minimum-height wrapper.
// It forwards title without rewriting localized content.
// It forwards titleColor without merging an unrelated theme role.
// It forwards summary without replacing null with an empty line.
// It forwards summaryColor independently from titleColor.
// It forwards startAction unchanged.
// It supplies a non-null endActions slot to BasicComponent.
// It forwards bottomAction unchanged.
// It forwards insideMargin unchanged.
// It forwards onClick unchanged.
// It forwards holdDownState unchanged.
// It forwards enabled unchanged.
//
// End slot composition
// The end slot first creates a Row for caller endActions.
// That Row is aligned vertically to the BasicComponent end Row.
// That Row uses weight 1 with fill false.
// The Row therefore remains content-sized when its children fit.
// The Row adds 8dp logical-end padding.
// Padding remains present when caller endActions emits no children.
// The disclosure arrow follows that padded Row.
// No extra Spacer is inserted after the disclosure arrow.
// BasicComponent separately inserts its occupied-end-slot 8dp gap.
// The empty endActions Row therefore consumes 8dp.
// The disclosure arrow consumes 10dp.
// The complete trailing measurable consumes 18dp with no caller action.
// The center-to-trailing gap consumes another 8dp.
// A no-action preference leaves 26dp after its center allocation.
// Removing the empty Row would incorrectly give center content 8dp more width.
// That difference becomes visible when a long localized title wraps.
// Flutter keeps the empty Row equivalent with an unconditional 8dp spacer.
//
// Disclosure artwork
// Arrow width is exactly 10dp.
// Arrow height is exactly 16dp.
// Artwork comes from the authored MiuixIcons.Basic.ArrowRight vector.
// The source does not use a platform font chevron.
// The source does not use a Material Icons glyph.
// The source does not add an arrow touch target.
// The arrow is decorative and has no content description.
// The arrow is vertically centered.
// LTR draws the authored right-facing path.
// RTL mirrors only the X axis.
// RTL does not rotate the complete preference.
// RTL does not reorder caller endActions inside their own Row.
// Flutter paints the authored centerline in the same 10 by 16 bounds.
//
// Arrow colors
// ArrowPreferenceDefaults exposes endActionColors.
// Enabled color defaults to onSurfaceVariantActions.
// Disabled color defaults to disabledOnSecondaryVariant.
// Enabled and disabled fields remain independently overridable.
// The colors object is immutable.
// Equal fields produce equal values.
// Equal values produce equal hash codes.
// Copying one field retains the other field.
// Color resolution depends only on enabled.
// Caller endActions do not automatically inherit the arrow tint.
// The fixture explicitly colors its end-action Text.
// Flutter exposes MiuixArrowPreferenceEndActionColors.
// Flutter exposes MiuixArrowPreferenceDefaults.endActionColors.
//
// BasicComponent color forwarding
// Title enabled color defaults to onBackground.
// Title disabled color defaults to disabledOnSecondaryVariant.
// Summary enabled color defaults to onSurfaceVariantSummary.
// Summary disabled color defaults to disabledOnSecondaryVariant.
// Title and summary colors use separate immutable pairs.
// A title override must not alter summary color.
// A summary override must not alter title color.
// A disabled override must not alter the enabled channel.
// MiuixBasicComponentColors mirrors the two source fields.
// MiuixBasicComponentDefaults publishes both color factories.
// The compatibility TextStyle override remains separate.
//
// Interaction
// enabled false removes BasicComponent click handling.
// enabled false still paints the complete row and disclosure arrow.
// onClick null removes click handling even when enabled is true.
// onClick does not add Arrow-specific haptics.
// The BasicComponent indication owns pointer feedback.
// ArrowPreference adds no sink scaling.
// ArrowPreference adds no tilt transformation.
// holdDownState is forwarded to the shared indication source.
// A true holdDownState paints the same ten-percent indication channel.
// Pointer press and hold-down channels add independently.
// Releasing a pointer does not clear a still-active hold-down state.
// Clearing holdDownState releases only its held channel.
// The source wrapper does not add swipe-to-dismiss behavior.
//
// Primary localized fixture
// The section title is translated to 箭头.
// The card retains the source three-row order.
// Row one supplies the Contacts start icon.
// The fixture itself adds 8dp after that start icon.
// BasicComponent adds its separate occupied-start-slot 8dp gap.
// Row one supplies localized 尾部 end text.
// Row one remains enabled and clickable.
// Row two is the upstream SliderPreference rather than ArrowPreference.
// Row two supplies the localized title 音量.
// Row two supplies a percentage valueText end action.
// Row two supplies a full-width Slider bottom action.
// SliderPreference appends the disclosure arrow when onClick is non-null.
// The value text precedes that disclosure arrow in the end row.
// The end row retains its unconditional logical-end padding.
// Flutter uses MiuixSliderPreference.source for this complete row.
// The bottom action begins after the source 8dp vertical spacer.
// Opening the volume dialog enables holdDownState.
// Dialog exit completion clears holdDownState.
// Row three supplies localized disabled title and end text.
// Row three keeps its arrow while disabling interaction.
// The Flutter fixture does not emulate this row with ArrowPreference.
//
// NavigateTest fixture
// The first card uses one ArrowPreference to push a recursive route.
// That row intentionally supplies no caller endActions.
// It therefore exercises the empty 8dp end-actions Row.
// The layout card contains eleven ArrowPreference stress cases.
// Each case keeps the upstream title and summary structure after localization.
// Each case keeps the source start-action presence or absence.
// Each case keeps the source end-action item count.
// Multiple end actions retain their explicit 8dp internal spacing.
// BasicComponent still performs the final 2:5:3 pressure allocation.
// ArrowPreference must not introduce a Flutter Expanded around center content.
// ArrowPreference must not force end actions to fill their target allocation.
// Long center text wraps inside the resolved center maximum.
// Long end text wraps inside the resolved end maximum.
// RTL continues to use logical start and end placement.
//
// Verification
// Tests verify both immutable color data models.
// Tests verify enabled and disabled resolution.
// Tests verify theme-derived title defaults.
// Tests verify theme-derived summary defaults.
// Tests verify theme-derived arrow defaults.
// Tests verify custom disabled title and summary paint.
// Tests verify the disclosure artwork remains 10 by 16dp.
// Tests verify a 320dp no-action row gives center exactly 262dp.
// Tests verify the source bottom action remains mounted.
// Tests verify hold-down indication reaches its source alpha.
// Tests verify all existing ArrowPreference visual baselines remain unchanged.
// Example tests verify twelve localized NavigateTest ArrowPreferences.
// Full package analysis guards the named source constructors.
// Scope verification guards all newly public default and color types.
