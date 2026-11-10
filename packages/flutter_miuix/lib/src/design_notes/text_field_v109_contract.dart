// MIUIX v1.0.9 TextField parity contract.
//
// Authoritative component source:
// - miuix-ui/.../basic/TextField.kt
//
// Authoritative sample source:
// - example/shared/.../component/TextFieldSection.kt
//
// This file is documentation only. It records the complete obligation so a
// Material-looking filled input cannot be mistaken for source parity merely
// because its idle screenshot has approximately the right color and radius.
//
// ---------------------------------------------------------------------------
// Public overloads and Flutter state adapter
// ---------------------------------------------------------------------------
//
// TextField.kt exposes three overloads:
// 1. TextFieldState with InputTransformation, OutputTransformation,
//    TextFieldLineLimits, KeyboardActionHandler, onTextLayout, and ScrollState;
// 2. TextFieldValue with value/onValueChange, VisualTransformation,
//    KeyboardActions, singleLine, minLines, maxLines, and onTextLayout;
// 3. String with the same value-based configuration.
//
// A Flutter TextEditingController retains the same three state dimensions
// carried by TextFieldValue and TextFieldState:
// - text;
// - selection;
// - composing range.
//
// MiuixTextField.source therefore requires a controller and exposes source-like
// names for the remaining configuration. The ordinary constructor remains the
// compatibility form and can own a controller when the caller omits one.
//
// Flutter equivalents are:
// - onValueChange -> onChanged;
// - onKeyboardAction -> onSubmitted;
// - interactionSource focus observation -> externally owned FocusNode;
// - inputTransformation -> List<TextInputFormatter>;
// - scrollState -> externally owned ScrollController;
// - lineLimits -> singleLine/minLines/maxLines;
// - VisualTransformation.None -> ordinary visible EditableText;
// - password-style transformation -> obscureText compatibility extension.
//
// EditableText exposes a cursor Color rather than an arbitrary Brush. The
// public cursorColor therefore represents the SolidColor default used by every
// source sample. No gradient cursor is claimed by this adapter.
//
// MiuixTextFieldLayoutResult is an immutable substitute for Compose's
// TextLayoutResult. It reports the paragraph size, visual line count,
// max-line overflow state, and controller text without leaking a TextPainter
// whose lifetime has already ended.
//
// ---------------------------------------------------------------------------
// Public defaults
// ---------------------------------------------------------------------------
//
// TextFieldDefaults exposes exactly two public values:
// - CornerRadius = 16dp;
// - InsideMargin = DpSize(16dp, 16dp).
//
// Flutter publishes these as:
// - MiuixTextFieldDefaults.cornerRadius;
// - MiuixTextFieldDefaults.insideMargin.
//
// The following source values are internal implementation details:
// - focused BorderWidth = 2dp;
// - floating LabelFontSize = 10dp;
// - normal LabelFontSize = 17dp.
//
// They remain exact in rendering and focused tests but are not invented as
// additional public defaults.
//
// Default semantic roles are:
// - backgroundColor = secondaryContainer;
// - labelColor = onSecondaryContainer;
// - focused borderColor = primary;
// - cursor = SolidColor(borderColor) for the state overload;
// - cursor = SolidColor(primary) for the value overloads.
//
// The sample uses the default primary border, so both source overload defaults
// resolve identically there.
//
// ---------------------------------------------------------------------------
// Text color and inherited content
// ---------------------------------------------------------------------------
//
// Source textStyle defaults to MiuixTheme.textStyles.main.
//
// It resolves its text color by taking an explicit textStyle color first and
// falling back to LocalContentColor.current only when the style has no color.
//
// Material ThemeData eagerly injects an onSurface color into bodyLarge.
// MiuixTextField must not interpret that generated value as a caller override.
// The Flutter precedence is consequently:
// 1. color explicitly present in the caller's textStyle;
// 2. private MIUIX content-color scope from MiuixSurface;
// 3. DefaultTextStyle color;
// 4. onSurface fallback.
//
// This lets a text field inside a custom MIUIX Surface inherit exactly as the
// Compose BasicTextField does while retaining explicit caller colors.
//
// ---------------------------------------------------------------------------
// Label state machine and animation
// ---------------------------------------------------------------------------
//
// The source has four private states:
// - Hidden when label is empty;
// - Placeholder when useLabelAsPlaceholder is true and text is non-empty;
// - Floating when ordinary text is non-empty;
// - Normal otherwise.
//
// Focus does not participate in this label-state decision.
//
// Therefore an empty focused field retains its normal inline 17sp label.
// Only entered text floats an ordinary label.
//
// Floating motion uses two independent animateDpAsState channels:
// - label offset changes from 0 to -insideMargin.height / 2;
// - editable content offset changes from 0 to +insideMargin.height / 2;
// - label size changes from 17dp interpreted as sp to 10dp interpreted as sp.
//
// At the default inset those offsets are -8dp and +8dp.
//
// Placeholder mode does not float the label. Once text becomes non-empty the
// label composable is removed and only the entered text remains.
//
// Empty labels create no label widget and consume no hidden caption space.
//
// Compose animate*AsState uses its default critically damped spring:
// - damping ratio 1.0;
// - stiffness 1500;
// - normalized mass 1.
//
// Focus border motion and label motion remain independent and retain sampled
// position and velocity when interrupted.
//
// ---------------------------------------------------------------------------
// Decoration, border, and modifier order
// ---------------------------------------------------------------------------
//
// BasicTextField owns the caller modifier and all editable semantics.
//
// Its decorator creates one Box with:
// 1. secondaryContainer background clipped by miuixShape(cornerRadius);
// 2. content drawing;
// 3. a focused outline drawn afterward and inset by half its stroke width.
//
// Idle border width is zero. The animated idle border color is the background,
// so no faint Material outline may remain.
//
// Focus animates the outline to the full 2dp primary stroke.
//
// The outline must remain wholly inside the field bounds. Its shape is the
// active G2 continuous shape when smooth rounding is enabled, or the ordinary
// rounded rectangle fallback when it is disabled.
//
// There is no Material InputDecoration, floating-label gap, helper line,
// counter, error state, prefix constraint, suffix constraint, or elevation.
//
// The upstream component exposes no error parameter; the localized sample
// must not invent an error-state field.
//
// ---------------------------------------------------------------------------
// Leading and trailing content geometry
// ---------------------------------------------------------------------------
//
// TextFieldDecorationBox uses one full-width Row centered vertically.
//
// leadingIcon and trailingIcon are invoked directly:
// - no automatic IconTheme tint;
// - no automatic 22dp size;
// - no automatic 12dp gap;
// - no automatic minimum touch target.
//
// Callers own every dimension and color inside those arbitrary composable slots.
//
// The middle weighted Box applies padding conditionally:
// - neither slot: horizontal 16dp plus vertical 16dp;
// - trailing only: logical start 16dp plus vertical 16dp;
// - leading only: logical end 16dp plus vertical 16dp;
// - both slots: vertical 16dp only.
//
// Directional start/end behavior mirrors under RTL.
//
// Flutter's source leadingIcon/trailingIcon path follows that exact rule.
//
// Existing prefixIcon/suffixIcon parameters remain a compatibility extension
// with the package's previous 12dp spacing and focus-aware IconTheme. Source
// and compatibility slots cannot be mixed in one field.
//
// ---------------------------------------------------------------------------
// Editable behavior
// ---------------------------------------------------------------------------
//
// enabled=false prevents pointer focus and editing while preserving paint.
//
// readOnly=true preserves focus, selection, scrolling, and text paint but
// prevents edits.
//
// singleLine forces one line and source defaults maxLines to one in that mode.
//
// Ordinary multiline mode defaults to one minimum line and an unbounded
// maximum. Flutter null maxLines represents Compose Int.MAX_VALUE.
//
// The compatibility layer safely normalizes invalid external line values; this
// defensive extension must not alter valid source configurations.
//
// Keyboard type, IME action, input transformations, submit callback, external
// focus node, controller, and internal scroll controller are forwarded to
// EditableText without a Material TextField wrapper.
//
// Input transformations run before the new value reaches the controller and
// onValueChange callback, matching state-based input filtering order.
//
// The cursor uses the resolved source SolidColor channel.
//
// Selection tint is a translucent form of the same primary border role.
//
// ---------------------------------------------------------------------------
// Accessibility
// ---------------------------------------------------------------------------
//
// BasicTextField provides one editable semantics node.
//
// Flutter exposes the same text-field role with enabled and read-only state.
//
// No outer card/button role, tooltip, error label, or redundant editable node
// may be introduced.
//
// Disabled fields retain their value and description while becoming disabled.
//
// Source slot content keeps its own semantics because the decorator does not
// replace it with a synthetic icon description.
//
// ---------------------------------------------------------------------------
// Localized TextFieldSection fixture
// ---------------------------------------------------------------------------
//
// TextFieldSection.kt contains exactly four fields in this order:
// 1. empty String value overload with no label;
// 2. empty TextFieldValue overload labelled "With title";
// 3. empty TextFieldState overload labelled "State-based";
// 4. empty String overload labelled "Placeholder & SingleLine", with
//    useLabelAsPlaceholder=true and singleLine=true.
//
// Every field applies:
// - 12dp horizontal page padding;
// - a separate 12dp bottom padding;
// - ImeAction.Done;
// - Done action clearing focus.
//
// Only visible strings are localized:
// - TextField -> 文本框;
// - With title -> 带标题;
// - State-based -> 状态式文本框;
// - Placeholder & SingleLine -> 占位标题与单行输入.
//
// Translation must not add fields, reorder overload states, change callbacks,
// change line limits, or replace Done with another keyboard action.
//
// ---------------------------------------------------------------------------
// Same-device physical evidence
// ---------------------------------------------------------------------------
//
// At 1080 x 2400 and 420dpi:
// - every source field spans x=32..1048 physical pixels;
// - each empty one-line field is 52dp high;
// - each inter-field bottom gap is independently rounded from 12dp;
// - default radius and inside margins remain 16dp;
// - focused outline animates from 0dp to 2dp;
// - empty focus leaves the 17sp label inline;
// - entered ordinary text produces the 10sp floating label;
// - the paired offsets remain -8dp and +8dp;
// - placeholder-label input removes its caption;
// - IME Done clears focus without clearing the stored value.
//
// Paired native and Flutter static, focused, entered, placeholder, keyboard,
// and Done captures live under artifacts/parity/audit_2026-07-27.
//
// ---------------------------------------------------------------------------
// Required regression evidence
// ---------------------------------------------------------------------------
//
// Focused tests must cover:
// - public defaults;
// - all valid line-limit forms and defensive invalid normalization;
// - empty focus versus entered floating-label state;
// - placeholder-label removal;
// - independent border and label spring channels;
// - custom background, label, border, cursor, shape, and inside margin;
// - inherited LocalContentColor and explicit style precedence;
// - source leading/trailing slots with zero invented gap/tint/size;
// - conditional source padding in LTR and RTL;
// - external controller, focus node, scroll controller, and formatter identity;
// - immutable text-layout reports;
// - read-only and disabled semantics;
// - the unchanged six TextField component goldens.
//
// Full root tests, example tests, analysis, mapping coverage, comment-ratio
// verification, and Android runtime checks remain required before packaging.
