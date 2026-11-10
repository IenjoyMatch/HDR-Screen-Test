// MIUIX v1.0.9 SearchBar parity contract.
//
// Authoritative source:
// - miuix-ui/.../basic/SearchBar.kt
//
// Authoritative localized example:
// - example/shared/src/commonMain/kotlin/MainPage.kt
//
// ---------------------------------------------------------------------------
// SearchBar container
// ---------------------------------------------------------------------------
//
// SearchBar receives one arbitrary inputField slot. It does not manufacture or
// style that slot. The other source parameters are:
// - onExpandedChange;
// - insideMargin = DpSize(12dp, 0dp);
// - expanded = false;
// - nullable outsideEndAction;
// - one required ColumnScope content slot.
//
// MiuixSearchBar.source is the literal Flutter form of that API.
//
// The unnamed MiuixSearchBar controller constructor remains a compatibility
// convenience for applications written against earlier flutter_miuix builds.
// It must not constrain the source constructor's arbitrary slot behavior.
//
// The input field is placed in a weight-one Box after applying the horizontal
// and vertical insideMargin. The outside action is its Row sibling.
//
// The outside action uses expandHorizontally plus slideInHorizontally from one
// complete child width. Exit uses shrinkHorizontally plus slideOutHorizontally
// to one complete child width. There is no fade on this slot.
//
// Both size and slide channels use Compose's medium-low, critically damped
// visibility spring: stiffness 400 and damping ratio 1.
//
// Expanded content uses ColumnScope AnimatedVisibility defaults:
// - fadeIn plus expandVertically;
// - fadeOut plus shrinkVertically;
// - content retained until all exit channels settle.
//
// Back handling is enabled only while expanded and reports false through the
// current onExpandedChange callback before route navigation may continue.
//
// ---------------------------------------------------------------------------
// InputField
// ---------------------------------------------------------------------------
//
// MiuixInputField is the source SearchBar InputField. It is not an alias for
// MiuixTextField and does not share TextField.kt's rounded-rectangle layout.
//
// Its public source values are:
// - controlled query and onQueryChange;
// - onSearch receiving the current query;
// - controlled expanded and onExpandedChange;
// - label = empty;
// - enabled = true;
// - nullable textStyle;
// - nullable arbitrary leadingIcon and trailingIcon slots;
// - nullable hoisted interactionSource.
//
// MiuixInputField.controller is a Flutter-only bridge that preserves selection
// and composing state for callers already owning a TextEditingController.
//
// Focus requests expansion. Expansion requests focus. The Search IME action
// reports the current controlled query without inventing a collapse.
//
// On collapse while focused:
// 1. wait exactly 100ms;
// 2. if the query is non-empty, animate text alpha from one to zero with the
//    default Animatable spring (stiffness 1500, damping ratio 1);
// 3. report an empty query;
// 4. snap text alpha back to one;
// 5. release focus.
//
// A superseding expansion or disposal cancels that sequence.
//
// ---------------------------------------------------------------------------
// Geometry and colors
// ---------------------------------------------------------------------------
//
// SearchBarDefaults maps to MiuixSearchBarDefaults:
// - InsideMargin = Size(12, 0);
// - InputFieldMinHeight = 45dp;
// - InputFieldFontSize = 17sp;
// - LeadingIconStartPadding = 16dp;
// - LeadingIconEndPadding = 8dp;
// - TrailingIconStartPadding = 8dp;
// - TrailingIconEndPadding = 16dp.
//
// The Search vector declares an intrinsic 20dp size. Its ordinary layout width
// is therefore 16 + 20 + 8 = 44dp.
//
// SearchCleanup declares an intrinsic 18.199984dp size. Its ordinary layout
// width is therefore 8 + 18.199984 + 16 = 42.199984dp. It must not be rounded
// up to a fabricated 20dp vector or 44dp layout slot.
//
// The capsule minimum height is 45dp and uses surfaceContainerHigh.
//
// Search tint is onSurfaceContainerHigh. Cleanup tint is
// onSurfaceContainerHighest. Cursor tint is primary.
//
// Main text starts with the MIUIX main style, forces Medium weight, merges the
// caller style, then forces the current LocalContentColor. Caller text color
// therefore cannot override the active content-color scope.
//
// Label style starts at 17sp Medium and merges caller textStyle. Its explicit
// paint color remains onSurfaceContainerHigh.
//
// The label is empty whenever query is non-empty or expanded is true.
//
// Custom leading and trailing slots are invoked directly. The component adds
// no padding, size, tint, icon theme, semantics label, or click behavior.
//
// ---------------------------------------------------------------------------
// Localized source example
// ---------------------------------------------------------------------------
//
// The Home example keeps the source structure and only translates visible
// strings:
// - SmallTitle SearchBar -> 搜索栏;
// - label Search -> 搜索;
// - outside action Cancel -> 取消;
// - Suggestion 0..3 -> 建议 0..3.
//
// The SearchBar receives a separate 12dp bottom modifier.
//
// The outside action retains 12dp end padding, 17sp Bold text, primary color,
// and a click target without indication or an interaction source.
//
// Cancel collapses and clears immediately. Selecting a suggestion assigns its
// text and collapses. The InputField collapse sequence subsequently fades and
// clears that text exactly like the source.
//
// All sections after SearchBar are absent while expanded. They are not merely
// hidden, excluded from semantics, or blocked from pointer input.
