// MIUIX v1.0.9 BasicComponent and preference-row parity contract.
//
// Authority
// The authoritative checkout is C:/Code/miuix-src-current.
// Its audited commit is be0aa8386b30cef46109b9103b3232b53af46733.
// The primary source is miuix-ui/basic/Component.kt.
// Arrow behavior comes from miuix-preference/ArrowPreference.kt.
// Fixture behavior comes from example/shared/NavigateTestPage.kt.
// The Flutter implementation lives in widgets/parts/preferences.dart.
// The localized fixture lives in example/lib/reference_navigation_test_page.dart.
// Source measurements are logical pixels and map directly to Flutter dp.
// This note records both visual requirements and the audited public API.
// A later upstream version must be re-audited before changing these values.
//
// Core row geometry
// Every BasicComponent fills its available horizontal width.
// Every BasicComponent has a minimum outer height of 56dp.
// Taller content is allowed to increase the row height.
// The default inside margin is 16dp on every edge.
// A short title-only row therefore retains 16dp start padding.
// A short title-only row therefore retains 16dp end padding.
// A short title-only row therefore retains 16dp top padding.
// A short title-only row therefore retains 16dp bottom padding.
// The content row is vertically centered inside the outer component.
// The start slot is vertically centered against the tallest slot.
// The center slot is vertically centered against the tallest slot.
// The end slot is vertically centered against the tallest slot.
// A bottom action is separated from the main row by 8dp.
// The Flutter source adapters expose the same bottom-action parameter.
// Bottom actions preserve the same 8dp separation.
// The row must not force a fixed height when text wraps.
// The row must not clip localized content merely to retain 56dp.
//
// Text contract
// The title uses the MIUIX headline1 size of 17sp.
// The title uses medium font weight.
// The title uses the enabled on-background color.
// Disabled title color follows disabled-on-secondary-variant.
// The summary uses the MIUIX body2 size of 13sp.
// The summary uses the on-surface-variant-summary color.
// Disabled summary color follows disabled-on-secondary-variant.
// Source title text has no forced one-line limit.
// Source summary text has no forced two-line limit.
// Long title text is allowed to wrap.
// Long summary text is allowed to wrap.
// Localized Chinese text must not be replaced with English placeholders.
// Raw start-slot Text inherits a usable 17sp body style.
// Raw end-slot Text inherits a usable 17sp body style.
// Raw Text must never inherit Flutter's 48sp red debug fallback.
// End-slot text is directionally aligned toward the row end.
//
// Slot model
// The layout has a logical start slot.
// The layout has a required center slot.
// The layout has a logical end slot.
// The start slot is omitted when no start action is supplied.
// The end slot is omitted when no end action is supplied.
// The center slot is always present.
// An occupied start slot contributes one 8dp spacer.
// An occupied end slot contributes one 8dp spacer.
// No spacer is reserved for an absent start slot.
// No spacer is reserved for an absent end slot.
// Slot width allocation excludes occupied spacer widths.
// The start slot contains icons, text, or arbitrary user content.
// The center slot contains title and optional summary.
// The end slot may contain several actions in one row.
// ArrowPreference appends its disclosure arrow to the end slot.
// Start and end widgets must remain independently measurable.
// A plain Flutter Row flex pass is not sufficient for this contract.
// Intrinsic widths must be sampled before final child layout.
//
// Intrinsic measurement
// Each occupied slot reports a maximum intrinsic width.
// Each occupied slot reports a minimum intrinsic width.
// Missing slots report zero requested width.
// Missing slots report zero minimum width.
// Requested total is start plus center plus end.
// Available width is outer width minus occupied spacers.
// Flutter unbounded-height intrinsics use zero height for natural line width.
// Passing infinite height to a vertical RenderFlex can produce word wrapping.
// That Flutter behavior differs from Compose Constraints.Infinity semantics.
// The port normalizes the difference before applying source math.
// All resolved widths are clamped to non-negative values.
// Children are measured only once with their resolved maximum widths.
// Child minimum width remains zero.
// Child maximum height follows the incoming constraint.
// The final row height is the tallest measured child.
// The final row size is constrained by the parent.
//
// Allocation when content fits
// If requested total fits, start receives its requested width.
// If requested total fits, end receives its requested width.
// If requested total fits, center receives every remaining pixel.
// The center expansion keeps outer actions content-sized.
// The end child remains aligned to the logical end edge.
// The start child remains aligned to the logical start edge.
// Unused center space is not split between outer slots.
//
// Allocation under pressure
// Occupied start has pressure weight 2.
// Center always has pressure weight 5.
// Occupied end has pressure weight 3.
// Missing start has pressure weight 0.
// Missing end has pressure weight 0.
// Total weight is the sum of occupied-slot weights.
// Base start width is available width times start weight over total weight.
// Base center width is available width times center weight over total weight.
// Base end width is available width times end weight over total weight.
// A slot is huge when requested width exceeds its base width.
// The implementation counts huge occupied slots.
// When all three are huge, base 2:5:3 widths are used.
// When two are huge, the fitting slot keeps requested width.
// Remaining width is split between the two huge slots.
// The two-slot split follows their requested-width proportions.
// When one is huge, fitting slots keep requested widths.
// The single huge slot receives every remaining pixel.
// When no slot is huge, requested widths are retained.
// Any unused no-huge space is added to center.
// Floating-point allocation may differ fractionally from Compose integers.
// Fractional differences must remain below pixel-golden tolerance.
//
// Minimum-width protection
// Center minimum width is protected before end minimum width.
// Center protection runs only when its minimum fits available width.
// Center protection calculates how much additional width is needed.
// Start slack is target start minus minimum start.
// End slack is target end minus minimum end.
// Negative start slack is treated as zero.
// Negative end slack is treated as zero.
// Center borrows from start and end in proportion to their slack.
// Center never borrows more than an outer slot's slack.
// End minimum protection runs after center protection.
// End protection runs only when its minimum fits available width.
// End protection calculates how much additional width is needed.
// End may borrow remaining start slack.
// End may borrow remaining center slack.
// End borrowing follows the two donors' slack proportions.
// End never borrows more than a donor's slack.
// There is no third protection pass for start in the source.
// The Flutter port must retain that asymmetry.
//
// Placement
// In LTR, start is placed at x zero.
// In LTR, center follows measured start width and its spacer.
// In LTR, end is placed against the right edge.
// In RTL, start is placed against the right edge.
// In RTL, center precedes start with the logical spacer.
// In RTL, end is placed against the left edge.
// Placement uses actual measured width rather than target maximum width.
// This preserves content-sized outer widgets when they measure smaller.
// Each child receives a vertically centered offset.
// Hit testing follows each child's final parent-data offset.
// Painting follows container child order.
//
// ArrowPreference geometry
// ArrowPreference includes the supplied end actions first.
// ArrowPreference separates supplied end actions from the arrow by 8dp.
// The source arrow occupies 10dp width.
// The source arrow occupies 16dp height.
// The source arrow flips horizontally in RTL.
// The arrow enabled color uses on-surface-variant-actions.
// The arrow disabled color uses disabled-on-secondary-variant.
// The Flutter glyph is fitted into the same 10 by 16 logical bounds.
// The disclosure arrow remains present even when no secondary action exists.
// The arrow remains vertically centered with wrapped center text.
// ArrowPreference always creates the caller end-actions Row.
// That Row always owns 8dp logical-end padding, even when it is empty.
// BasicComponent separately owns its occupied-end-slot 8dp spacer.
// A no-action arrow therefore reserves 18dp plus the outer slot spacer.

// Public BasicComponent contract
// MiuixBasicComponent.source represents the arbitrary-content overload.
// MiuixBasicComponent.sourceText represents the title/summary overload.
// Source adapters never invent the compatibility standalone Card surface.
// The text overload permits title and summary to be independently absent.
// The arbitrary overload preserves the caller's complete center Widget.
// startAction and endActions accept arbitrary Widgets.
// bottomAction accepts an arbitrary Widget.
// insideMargin defaults to EdgeInsets.all(16).
// onClick remains nullable and controls whether indication is installed.
// onClickLabel is forwarded to the platform accessibility action hint.
// role accepts every Role value used by the current Compose source.
// MiuixAccessibilityRole contains Button and Checkbox equivalents.
// It also contains Switch, RadioButton, Tab, Image, and DropdownList.
// Flutter represents Button and DropdownList through a button flag.
// Flutter represents Checkbox through a checked-state flag.
// Flutter represents Switch through a toggled-state flag.
// Flutter represents RadioButton through checked plus mutual-exclusion flags.
// Flutter represents Tab through SemanticsRole.tab plus a selected state.
// Flutter represents Image through the image flag.
// Flutter's unimplemented comboBox role is not emitted in debug builds.
// Stateful preference wrappers forward their current checked or toggled bit.
// holdDownState drives the same indication state as an emitted hold action.
// enabled false removes pointer activation.
// interactionSource observes pointer press transitions.
// MiuixBasicComponentColors stores enabled and disabled foregrounds.
// Its equality and hash behavior follow the upstream immutable data class.
// MiuixBasicComponentDefaults publishes insideMargin.
// MiuixBasicComponentDefaults.titleColor resolves both title channels.
// MiuixBasicComponentDefaults.summaryColor resolves both summary channels.
// The unnamed MiuixBasicComponent retains its historical Card wrapper.

// Current localized fixture evidence
// The source fixture contains one enabled and one disabled row.
// Both rows include title, summary, start action, and two end actions.
// The localized fixture preserves that order and uses sourceText directly.
// At 420dpi the complete section is [32,545][1048,1020].
// Its painted Card is [32,630][1048,988].
// Each independently rounded row is 179 physical pixels high.
// The two title baselines begin at y=672 and y=851 in both captures.
// Start and end actions retain the source y coordinates after localization.
// The separate 12dp card-bottom margin rounds to 32 physical pixels.
// Paired Release evidence is in basic_component_current_2026-08-10.

// Public ArrowPreference contract
// MiuixArrowPreference.source exposes the upstream parameter names.
// titleColor and summaryColor accept MiuixBasicComponentColors.
// startAction maps to the logical start slot.
// endActions is measured before the disclosure arrow.
// bottomAction remains below the primary row.
// onClick, holdDownState, and enabled retain source meanings.
// MiuixArrowPreferenceEndActionColors stores both arrow foregrounds.
// MiuixArrowPreferenceDefaults.endActionColors resolves semantic defaults.
// Enabled arrow color is onSurfaceVariantActions.
// Disabled arrow color is disabledOnSecondaryVariant.
// The unnamed constructor remains a compatibility spelling of the same row.
//
// Navigate fixture structure
// The fixture top bar title includes the current recursive page index.
// The initial localized title is 导航测试 1.
// The top bar has a back action.
// The top bar has an edit action.
// The edit action opens three window choices.
// Window choice labels are localized as 窗口 1 through 窗口 3.
// The first card pushes another copy of the fixture.
// Recursive pushes increment the visible index in the Flutter adapter.
// The layout card follows the push card with 12dp separation.
// The layout card contains exactly eleven stress rows.
// Together with the push row the route has twelve ArrowPreferences.
// The stress-row order must match NavigateTestPage.kt.
//
// Stress case 1
// Case 1 uses a long title.
// Case 1 uses a short summary.
// Case 1 uses a short start action.
// Case 1 uses two short end actions.
// Case 1 pressures center while retaining both outer slots.
//
// Stress case 2
// Case 2 uses a short title.
// Case 2 uses a long summary.
// Case 2 uses a short start action.
// Case 2 uses two short end actions.
// Case 2 verifies summary wrapping in center.
//
// Stress case 3
// Case 3 uses a short title.
// Case 3 uses a short summary.
// Case 3 uses a long start action.
// Case 3 uses two short end actions.
// Case 3 pressures the start slot.
//
// Stress case 4
// Case 4 uses a short title.
// Case 4 uses a short summary.
// Case 4 uses a short start action.
// Case 4 uses one long end action.
// Case 4 pressures the end slot.
//
// Stress case 5
// Case 5 uses a long title.
// Case 5 uses a short summary.
// Case 5 uses a long start action.
// Case 5 uses one short end action.
// Case 5 pressures start and center.
//
// Stress case 6
// Case 6 uses a long title.
// Case 6 uses a short summary.
// Case 6 uses a short start action.
// Case 6 uses one long end action.
// Case 6 pressures center and end.
//
// Stress case 7
// Case 7 uses a short title.
// Case 7 uses a short summary.
// Case 7 uses a long start action.
// Case 7 uses one long end action.
// Case 7 pressures both outer slots.
//
// Stress case 8
// Case 8 uses a short title.
// Case 8 uses a long summary.
// Case 8 omits the start action.
// Case 8 uses one long end action.
// Case 8 verifies the 5:3 two-slot weight system.
//
// Stress case 9
// Case 9 uses a long title.
// Case 9 uses a long summary.
// Case 9 omits the start action.
// Case 9 uses a medium-long end action.
// Case 9 pressures both occupied slots heavily.
//
// Stress case 10
// Case 10 uses a medium-long title.
// Case 10 uses a short summary.
// Case 10 omits the start action.
// Case 10 uses a medium-long end action.
// Case 10 checks natural requested-width allocation.
//
// Stress case 11
// Case 11 uses a short title.
// Case 11 uses a medium-long summary.
// Case 11 omits the start action.
// Case 11 uses a shorter long end action.
// Case 11 checks center minimum protection.
//
// Localization
// English fixture labels are translated into simplified Chinese.
// Repeated source phrases remain repeated after translation.
// Ideographic spaces preserve visible phrase separation.
// Translation must not change which slots are occupied.
// Translation must not merge two end actions into one semantic action.
// Translation must not remove long-text pressure cases.
// Translation must not add extra stress rows.
// Navigation labels use the established example terminology.
// Visible version and route structure remain unchanged by localization.
//
// Regression requirements
// A title-only MiuixPreference must measure exactly 56dp high.
// A title-only MiuixPreference must start content 16dp from its edge.
// A preference title must resolve to 17sp.
// A preference title must resolve to medium weight.
// A preference title must have unlimited max lines.
// A preference summary must resolve to 13sp.
// A preference summary must have unlimited max lines.
// A 220dp-wide long-content group must not overflow.
// The eleven-case navigation page must not throw layout exceptions.
// The navigation route must expose twelve ArrowPreferences total.
// Four source cases share the longest localized title string.
// The recursive push action must open the next navigation route.
// Back must return to the preceding route.
// The top-bar popup must retain all three options.
//
// Golden requirements
// BasicComponent light state must be refreshed after metric changes.
// BasicComponent dark state must be refreshed after metric changes.
// BasicComponent disabled state must be refreshed after metric changes.
// BasicComponent pressed state must be refreshed after metric changes.
// BasicComponent expanded state must be refreshed after metric changes.
// BasicComponent animation midpoint must remain deterministic.
// ArrowPreference light state must show the 10 by 16 arrow.
// Preference goldens must retain 16dp inside margins.
// Settings page goldens must reflect the taller source rows.
// About page goldens must reflect the taller source rows.
// Floating navigation goldens must retain transparent outer regions.
// Golden changes must be inspected rather than blindly accepted.
//
// Safety requirements
// Width allocation must never produce a negative constraint.
// Width allocation must tolerate a missing start slot.
// Width allocation must tolerate a missing end slot.
// Width allocation must tolerate both outer slots missing.
// Width allocation must tolerate zero available width.
// Width allocation must tolerate fractional device pixels.
// Layout must remain safe under unbounded vertical constraints.
// Layout must remain safe under bounded vertical constraints.
// Layout must remain safe when end content is a nested Row.
// Layout must remain safe when start content is an Icon.
// Layout must remain safe when start content is Text.
// Layout must remain safe with long CJK strings.
// Layout must remain safe with long Latin words.
// Layout must retain correct hit-test offsets after RTL placement.
//
// Completion evidence for this contract
// dart format must leave all touched Dart files clean.
// flutter analyze must report no issues for the library.
// flutter analyze must report no issues for the example.
// The behavior test suite must pass.
// The component golden suite must pass.
// The example structure suite must pass.
// The example golden suite must pass.
// verify_scope.ps1 must report at least 50 percent comments.
// compare_miuix_scope.ps1 must retain all mapped coverage.
// Android and Windows artifacts are rebuilt only after source tests pass.
// The broader pixel-parity goal remains active beyond this row contract.
