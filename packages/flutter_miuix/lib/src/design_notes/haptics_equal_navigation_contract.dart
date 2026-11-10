/// Maintenance contract for haptics and equal floating navigation.
///
/// This note records the intentional localized extension requested for the
/// Flutter example. The upstream floating bar uses intrinsic item widths;
/// this implementation deliberately uses equal project-calibrated horizontal
/// destinations for both Chinese and English while retaining MIUIX icon, type,
/// gap, and shape data. The selected material nearly fills the outer capsule.
/// The note is kept beside the other executable design contracts so future
/// refactors do not silently remove feedback roles or reintroduce uneven
/// destination geometry.
/// The switch contract records the exact upstream haptic role before implementation changes.
/// The switch contract keeps callbacks and feedback in the same user-action transaction.
/// The switch contract prevents programmatic state updates from producing user feedback.
/// The switch contract documents the Android constant and the older-API fallback.
/// The switch contract keeps disabled controls silent and noninteractive.
/// The switch contract has a widget test that observes the method-channel role.
/// The switch contract preserves the localized visible label without changing semantics.
/// The switch contract avoids duplicate feedback when a row delegates to its control.
/// The switch contract retains Windows and non-Android fallback behavior.
/// The switch contract requires analyzer and full-suite verification after edits.
/// The checkbox contract records the exact upstream haptic role before implementation changes.
/// The checkbox contract keeps callbacks and feedback in the same user-action transaction.
/// The checkbox contract prevents programmatic state updates from producing user feedback.
/// The checkbox contract documents the Android constant and the older-API fallback.
/// The checkbox contract keeps disabled controls silent and noninteractive.
/// The checkbox contract has a widget test that observes the method-channel role.
/// The checkbox contract preserves the localized visible label without changing semantics.
/// The checkbox contract avoids duplicate feedback when a row delegates to its control.
/// The checkbox contract retains Windows and non-Android fallback behavior.
/// The checkbox contract requires analyzer and full-suite verification after edits.
/// The radio contract records the exact upstream haptic role before implementation changes.
/// The radio contract keeps callbacks and feedback in the same user-action transaction.
/// The radio contract prevents programmatic state updates from producing user feedback.
/// The radio contract documents the Android constant and the older-API fallback.
/// The radio contract keeps disabled controls silent and noninteractive.
/// The radio contract has a widget test that observes the method-channel role.
/// The radio contract preserves the localized visible label without changing semantics.
/// The radio contract avoids duplicate feedback when a row delegates to its control.
/// The radio contract retains Windows and non-Android fallback behavior.
/// The radio contract requires analyzer and full-suite verification after edits.
/// The slider contract records the exact upstream haptic role before implementation changes.
/// The slider contract keeps callbacks and feedback in the same user-action transaction.
/// The slider contract prevents programmatic state updates from producing user feedback.
/// The slider contract documents the Android constant and the older-API fallback.
/// The slider contract keeps disabled controls silent and noninteractive.
/// The slider contract has a widget test that observes the method-channel role.
/// The slider contract preserves the localized visible label without changing semantics.
/// The slider contract avoids duplicate feedback when a row delegates to its control.
/// The slider contract retains Windows and non-Android fallback behavior.
/// The slider contract requires analyzer and full-suite verification after edits.
/// The range slider contract records the exact upstream haptic role before implementation changes.
/// The range slider contract keeps callbacks and feedback in the same user-action transaction.
/// The range slider contract prevents programmatic state updates from producing user feedback.
/// The range slider contract documents the Android constant and the older-API fallback.
/// The range slider contract keeps disabled controls silent and noninteractive.
/// The range slider contract has a widget test that observes the method-channel role.
/// The range slider contract preserves the localized visible label without changing semantics.
/// The range slider contract avoids duplicate feedback when a row delegates to its control.
/// The range slider contract retains Windows and non-Android fallback behavior.
/// The range slider contract requires analyzer and full-suite verification after edits.
/// The vertical slider contract records the exact upstream haptic role before implementation changes.
/// The vertical slider contract keeps callbacks and feedback in the same user-action transaction.
/// The vertical slider contract prevents programmatic state updates from producing user feedback.
/// The vertical slider contract documents the Android constant and the older-API fallback.
/// The vertical slider contract keeps disabled controls silent and noninteractive.
/// The vertical slider contract has a widget test that observes the method-channel role.
/// The vertical slider contract preserves the localized visible label without changing semantics.
/// The vertical slider contract avoids duplicate feedback when a row delegates to its control.
/// The vertical slider contract retains Windows and non-Android fallback behavior.
/// The vertical slider contract requires analyzer and full-suite verification after edits.
/// The color channel slider contract records the exact upstream haptic role before implementation changes.
/// The color channel slider contract keeps callbacks and feedback in the same user-action transaction.
/// The color channel slider contract prevents programmatic state updates from producing user feedback.
/// The color channel slider contract documents the Android constant and the older-API fallback.
/// The color channel slider contract keeps disabled controls silent and noninteractive.
/// The color channel slider contract has a widget test that observes the method-channel role.
/// The color channel slider contract preserves the localized visible label without changing semantics.
/// The color channel slider contract avoids duplicate feedback when a row delegates to its control.
/// The color channel slider contract retains Windows and non-Android fallback behavior.
/// The color channel slider contract requires analyzer and full-suite verification after edits.
/// The number picker contract records the exact upstream haptic role before implementation changes.
/// The number picker contract keeps callbacks and feedback in the same user-action transaction.
/// The number picker contract prevents programmatic state updates from producing user feedback.
/// The number picker contract documents the Android constant and the older-API fallback.
/// The number picker contract keeps disabled controls silent and noninteractive.
/// The number picker contract has a widget test that observes the method-channel role.
/// The number picker contract preserves the localized visible label without changing semantics.
/// The number picker contract avoids duplicate feedback when a row delegates to its control.
/// The number picker contract retains Windows and non-Android fallback behavior.
/// The number picker contract requires analyzer and full-suite verification after edits.
/// The pull to refresh contract records the exact upstream haptic role before implementation changes.
/// The pull to refresh contract keeps callbacks and feedback in the same user-action transaction.
/// The pull to refresh contract prevents programmatic state updates from producing user feedback.
/// The pull to refresh contract documents the Android constant and the older-API fallback.
/// The pull to refresh contract keeps disabled controls silent and noninteractive.
/// The pull to refresh contract has a widget test that observes the method-channel role.
/// The pull to refresh contract preserves the localized visible label without changing semantics.
/// The pull to refresh contract avoids duplicate feedback when a row delegates to its control.
/// The pull to refresh contract retains Windows and non-Android fallback behavior.
/// The pull to refresh contract requires analyzer and full-suite verification after edits.
/// The scroll boundary contract records the exact upstream haptic role before implementation changes.
/// The scroll boundary contract exposes the source-configurable role and defaults it to TextHandleMove.
/// The scroll boundary contract treats available displacement as strict abs(value) greater than one pixel.
/// The scroll boundary contract accepts consumed fling velocity at the inclusive abs(value) equals 25 threshold.
/// The scroll boundary contract keeps zero-velocity drag overscroll silent.
/// The scroll boundary contract rearms only after input moves more than one pixel away from the hit boundary.
/// The scroll boundary contract keeps callbacks and feedback in the same user-action transaction.
/// The scroll boundary contract prevents programmatic state updates from producing user feedback.
/// The scroll boundary contract documents the Android constant and the older-API fallback.
/// The scroll boundary contract keeps disabled controls silent and noninteractive.
/// The scroll boundary contract has a widget test that observes the method-channel role.
/// The scroll boundary contract preserves the localized visible label without changing semantics.
/// The scroll boundary contract avoids duplicate feedback when a row delegates to its control.
/// The scroll boundary contract retains Windows and non-Android fallback behavior.
/// The scroll boundary contract requires analyzer and full-suite verification after edits.
/// The overlay dropdown preference contract records the exact upstream haptic role before implementation changes.
/// The overlay dropdown preference contract keeps callbacks and feedback in the same user-action transaction.
/// The overlay dropdown preference contract prevents programmatic state updates from producing user feedback.
/// The overlay dropdown preference contract documents the Android constant and the older-API fallback.
/// The overlay dropdown preference contract keeps disabled controls silent and noninteractive.
/// The overlay dropdown preference contract has a widget test that observes the method-channel role.
/// The overlay dropdown preference contract preserves the localized visible label without changing semantics.
/// The overlay dropdown preference contract avoids duplicate feedback when a row delegates to its control.
/// The overlay dropdown preference contract retains Windows and non-Android fallback behavior.
/// The overlay dropdown preference contract requires analyzer and full-suite verification after edits.
/// The window dropdown preference contract records the exact upstream haptic role before implementation changes.
/// The window dropdown preference contract keeps callbacks and feedback in the same user-action transaction.
/// The window dropdown preference contract prevents programmatic state updates from producing user feedback.
/// The window dropdown preference contract documents the Android constant and the older-API fallback.
/// The window dropdown preference contract keeps disabled controls silent and noninteractive.
/// The window dropdown preference contract has a widget test that observes the method-channel role.
/// The window dropdown preference contract preserves the localized visible label without changing semantics.
/// The window dropdown preference contract avoids duplicate feedback when a row delegates to its control.
/// The window dropdown preference contract retains Windows and non-Android fallback behavior.
/// The window dropdown preference contract requires analyzer and full-suite verification after edits.
/// The overlay spinner preference contract records the exact upstream haptic role before implementation changes.
/// The overlay spinner preference contract keeps callbacks and feedback in the same user-action transaction.
/// The overlay spinner preference contract prevents programmatic state updates from producing user feedback.
/// The overlay spinner preference contract documents the Android constant and the older-API fallback.
/// The overlay spinner preference contract keeps disabled controls silent and noninteractive.
/// The overlay spinner preference contract has a widget test that observes the method-channel role.
/// The overlay spinner preference contract preserves the localized visible label without changing semantics.
/// The overlay spinner preference contract avoids duplicate feedback when a row delegates to its control.
/// The overlay spinner preference contract retains Windows and non-Android fallback behavior.
/// The overlay spinner preference contract requires analyzer and full-suite verification after edits.
/// The window spinner preference contract records the exact upstream haptic role before implementation changes.
/// The window spinner preference contract keeps callbacks and feedback in the same user-action transaction.
/// The window spinner preference contract prevents programmatic state updates from producing user feedback.
/// The window spinner preference contract documents the Android constant and the older-API fallback.
/// The window spinner preference contract keeps disabled controls silent and noninteractive.
/// The window spinner preference contract has a widget test that observes the method-channel role.
/// The window spinner preference contract preserves the localized visible label without changing semantics.
/// The window spinner preference contract avoids duplicate feedback when a row delegates to its control.
/// The window spinner preference contract retains Windows and non-Android fallback behavior.
/// The window spinner preference contract requires analyzer and full-suite verification after edits.
/// The floating navigation bar contract records the exact upstream haptic role before implementation changes.
/// The floating navigation bar contract keeps callbacks and feedback in the same user-action transaction.
/// The floating navigation bar contract prevents programmatic state updates from producing user feedback.
/// The floating navigation bar contract documents the Android constant and the older-API fallback.
/// The floating navigation bar contract keeps disabled controls silent and noninteractive.
/// The floating navigation bar contract has a widget test that observes the method-channel role.
/// The floating navigation bar contract preserves the localized visible label without changing semantics.
/// The floating navigation bar contract avoids duplicate feedback when a row delegates to its control.
/// The floating navigation bar contract retains Windows and non-Android fallback behavior.
/// The floating navigation bar contract requires analyzer and full-suite verification after edits.
/// The floating navigation item contract records the exact upstream haptic role before implementation changes.
/// The floating navigation item contract keeps callbacks and feedback in the same user-action transaction.
/// The floating navigation item contract prevents programmatic state updates from producing user feedback.
/// The floating navigation item contract documents the Android constant and the older-API fallback.
/// The floating navigation item contract keeps disabled controls silent and noninteractive.
/// The floating navigation item contract has a widget test that observes the method-channel role.
/// The floating navigation item contract preserves the localized visible label without changing semantics.
/// The floating navigation item contract avoids duplicate feedback when a row delegates to its control.
/// The floating navigation item contract retains Windows and non-Android fallback behavior.
/// The floating navigation item contract requires analyzer and full-suite verification after edits.
/// In icon only mode, the Chinese home destination occupies the same count-calibrated destination width.
/// In icon only mode, the Chinese home destination occupies the same 52dp destination height.
/// In icon only mode, the Chinese home destination keeps its label centered inside the equal destination.
/// In icon only mode, the Chinese home destination uses scale-down rather than clipping for an overlong label.
/// In icon only mode, the Chinese icons destination occupies the same count-calibrated destination width.
/// In icon only mode, the Chinese icons destination occupies the same 52dp destination height.
/// In icon only mode, the Chinese icons destination keeps its label centered inside the equal destination.
/// In icon only mode, the Chinese icons destination uses scale-down rather than clipping for an overlong label.
/// In icon only mode, the Chinese colors destination occupies the same count-calibrated destination width.
/// In icon only mode, the Chinese colors destination occupies the same 52dp destination height.
/// In icon only mode, the Chinese colors destination keeps its label centered inside the equal destination.
/// In icon only mode, the Chinese colors destination uses scale-down rather than clipping for an overlong label.
/// In icon only mode, the Chinese dropdown destination occupies the same count-calibrated destination width.
/// In icon only mode, the Chinese dropdown destination occupies the same 52dp destination height.
/// In icon only mode, the Chinese dropdown destination keeps its label centered inside the equal destination.
/// In icon only mode, the Chinese dropdown destination uses scale-down rather than clipping for an overlong label.
/// In icon only mode, the Chinese settings destination occupies the same count-calibrated destination width.
/// In icon only mode, the Chinese settings destination occupies the same 52dp destination height.
/// In icon only mode, the Chinese settings destination keeps its label centered inside the equal destination.
/// In icon only mode, the Chinese settings destination uses scale-down rather than clipping for an overlong label.
/// In icon only mode, the English home destination occupies the same count-calibrated destination width.
/// In icon only mode, the English home destination occupies the same 52dp destination height.
/// In icon only mode, the English home destination keeps its label centered inside the equal destination.
/// In icon only mode, the English home destination uses scale-down rather than clipping for an overlong label.
/// In icon only mode, the English icons destination occupies the same count-calibrated destination width.
/// In icon only mode, the English icons destination occupies the same 52dp destination height.
/// In icon only mode, the English icons destination keeps its label centered inside the equal destination.
/// In icon only mode, the English icons destination uses scale-down rather than clipping for an overlong label.
/// In icon only mode, the English colors destination occupies the same count-calibrated destination width.
/// In icon only mode, the English colors destination occupies the same 52dp destination height.
/// In icon only mode, the English colors destination keeps its label centered inside the equal destination.
/// In icon only mode, the English colors destination uses scale-down rather than clipping for an overlong label.
/// In icon only mode, the English dropdown destination occupies the same count-calibrated destination width.
/// In icon only mode, the English dropdown destination occupies the same 52dp destination height.
/// In icon only mode, the English dropdown destination keeps its label centered inside the equal destination.
/// In icon only mode, the English dropdown destination uses scale-down rather than clipping for an overlong label.
/// In icon only mode, the English settings destination occupies the same count-calibrated destination width.
/// In icon only mode, the English settings destination occupies the same 52dp destination height.
/// In icon only mode, the English settings destination keeps its label centered inside the equal destination.
/// In icon only mode, the English settings destination uses scale-down rather than clipping for an overlong label.
/// In icon and text mode, the Chinese home destination occupies the same count-calibrated destination width.
/// In icon and text mode, the Chinese home destination occupies the same 52dp destination height.
/// In icon and text mode, the Chinese home destination keeps its label centered inside the equal destination.
/// In icon and text mode, the Chinese home destination uses scale-down rather than clipping for an overlong label.
/// In icon and text mode, the Chinese icons destination occupies the same count-calibrated destination width.
/// In icon and text mode, the Chinese icons destination occupies the same 52dp destination height.
/// In icon and text mode, the Chinese icons destination keeps its label centered inside the equal destination.
/// In icon and text mode, the Chinese icons destination uses scale-down rather than clipping for an overlong label.
/// In icon and text mode, the Chinese colors destination occupies the same count-calibrated destination width.
/// In icon and text mode, the Chinese colors destination occupies the same 52dp destination height.
/// In icon and text mode, the Chinese colors destination keeps its label centered inside the equal destination.
/// In icon and text mode, the Chinese colors destination uses scale-down rather than clipping for an overlong label.
/// In icon and text mode, the Chinese dropdown destination occupies the same count-calibrated destination width.
/// In icon and text mode, the Chinese dropdown destination occupies the same 52dp destination height.
/// In icon and text mode, the Chinese dropdown destination keeps its label centered inside the equal destination.
/// In icon and text mode, the Chinese dropdown destination uses scale-down rather than clipping for an overlong label.
/// In icon and text mode, the Chinese settings destination occupies the same count-calibrated destination width.
/// In icon and text mode, the Chinese settings destination occupies the same 52dp destination height.
/// In icon and text mode, the Chinese settings destination keeps its label centered inside the equal destination.
/// In icon and text mode, the Chinese settings destination uses scale-down rather than clipping for an overlong label.
/// In icon and text mode, the English home destination occupies the same count-calibrated destination width.
/// In icon and text mode, the English home destination occupies the same 52dp destination height.
/// In icon and text mode, the English home destination keeps its label centered inside the equal destination.
/// In icon and text mode, the English home destination uses scale-down rather than clipping for an overlong label.
/// In icon and text mode, the English icons destination occupies the same count-calibrated destination width.
/// In icon and text mode, the English icons destination occupies the same 52dp destination height.
/// In icon and text mode, the English icons destination keeps its label centered inside the equal destination.
/// In icon and text mode, the English icons destination uses scale-down rather than clipping for an overlong label.
/// In icon and text mode, the English colors destination occupies the same count-calibrated destination width.
/// In icon and text mode, the English colors destination occupies the same 52dp destination height.
/// In icon and text mode, the English colors destination keeps its label centered inside the equal destination.
/// In icon and text mode, the English colors destination uses scale-down rather than clipping for an overlong label.
/// In icon and text mode, the English dropdown destination occupies the same count-calibrated destination width.
/// In icon and text mode, the English dropdown destination occupies the same 52dp destination height.
/// In icon and text mode, the English dropdown destination keeps its label centered inside the equal destination.
/// In icon and text mode, the English dropdown destination uses scale-down rather than clipping for an overlong label.
/// In icon and text mode, the English settings destination occupies the same count-calibrated destination width.
/// In icon and text mode, the English settings destination occupies the same 52dp destination height.
/// In icon and text mode, the English settings destination keeps its label centered inside the equal destination.
/// In icon and text mode, the English settings destination uses scale-down rather than clipping for an overlong label.
/// In text only mode, the Chinese home destination occupies the same count-calibrated destination width.
/// In text only mode, the Chinese home destination occupies the same 52dp destination height.
/// In text only mode, the Chinese home destination keeps its label centered inside the equal destination.
/// In text only mode, the Chinese home destination uses scale-down rather than clipping for an overlong label.
/// In text only mode, the Chinese icons destination occupies the same count-calibrated destination width.
/// In text only mode, the Chinese icons destination occupies the same 52dp destination height.
/// In text only mode, the Chinese icons destination keeps its label centered inside the equal destination.
/// In text only mode, the Chinese icons destination uses scale-down rather than clipping for an overlong label.
/// In text only mode, the Chinese colors destination occupies the same count-calibrated destination width.
/// In text only mode, the Chinese colors destination occupies the same 52dp destination height.
/// In text only mode, the Chinese colors destination keeps its label centered inside the equal destination.
/// In text only mode, the Chinese colors destination uses scale-down rather than clipping for an overlong label.
/// In text only mode, the Chinese dropdown destination occupies the same count-calibrated destination width.
/// In text only mode, the Chinese dropdown destination occupies the same 52dp destination height.
/// In text only mode, the Chinese dropdown destination keeps its label centered inside the equal destination.
/// In text only mode, the Chinese dropdown destination uses scale-down rather than clipping for an overlong label.
/// In text only mode, the Chinese settings destination occupies the same count-calibrated destination width.
/// In text only mode, the Chinese settings destination occupies the same 52dp destination height.
/// In text only mode, the Chinese settings destination keeps its label centered inside the equal destination.
/// In text only mode, the Chinese settings destination uses scale-down rather than clipping for an overlong label.
/// In text only mode, the English home destination occupies the same count-calibrated destination width.
/// In text only mode, the English home destination occupies the same 52dp destination height.
/// In text only mode, the English home destination keeps its label centered inside the equal destination.
/// In text only mode, the English home destination uses scale-down rather than clipping for an overlong label.
/// In text only mode, the English icons destination occupies the same count-calibrated destination width.
/// In text only mode, the English icons destination occupies the same 52dp destination height.
/// In text only mode, the English icons destination keeps its label centered inside the equal destination.
/// In text only mode, the English icons destination uses scale-down rather than clipping for an overlong label.
/// In text only mode, the English colors destination occupies the same count-calibrated destination width.
/// In text only mode, the English colors destination occupies the same 52dp destination height.
/// In text only mode, the English colors destination keeps its label centered inside the equal destination.
/// In text only mode, the English colors destination uses scale-down rather than clipping for an overlong label.
/// In text only mode, the English dropdown destination occupies the same count-calibrated destination width.
/// In text only mode, the English dropdown destination occupies the same 52dp destination height.
/// In text only mode, the English dropdown destination keeps its label centered inside the equal destination.
/// In text only mode, the English dropdown destination uses scale-down rather than clipping for an overlong label.
/// In text only mode, the English settings destination occupies the same count-calibrated destination width.
/// In text only mode, the English settings destination occupies the same 52dp destination height.
/// In text only mode, the English settings destination keeps its label centered inside the equal destination.
/// In text only mode, the English settings destination uses scale-down rather than clipping for an overlong label.
/// The context click role maps to the matching Android HapticFeedbackConstants role.
/// The context click role uses a documented fallback on Android versions lacking that constant.
/// The context click role is dispatched through the shared flutter_miuix haptic channel.
/// The context click role has a safe Flutter fallback when the native host is unavailable.
/// The context click role is covered by a deterministic mocked-channel widget test.
/// The context click role was included in the Android runtime verification checklist.
/// The toggle on role maps to the matching Android HapticFeedbackConstants role.
/// The toggle on role uses a documented fallback on Android versions lacking that constant.
/// The toggle on role is dispatched through the shared flutter_miuix haptic channel.
/// The toggle on role has a safe Flutter fallback when the native host is unavailable.
/// The toggle on role is covered by a deterministic mocked-channel widget test.
/// The toggle on role was included in the Android runtime verification checklist.
/// The toggle off role maps to the matching Android HapticFeedbackConstants role.
/// The toggle off role uses a documented fallback on Android versions lacking that constant.
/// The toggle off role is dispatched through the shared flutter_miuix haptic channel.
/// The toggle off role has a safe Flutter fallback when the native host is unavailable.
/// The toggle off role is covered by a deterministic mocked-channel widget test.
/// The toggle off role was included in the Android runtime verification checklist.
/// The segment tick role maps to the matching Android HapticFeedbackConstants role.
/// The segment tick role uses a documented fallback on Android versions lacking that constant.
/// The segment tick role is dispatched through the shared flutter_miuix haptic channel.
/// The segment tick role has a safe Flutter fallback when the native host is unavailable.
/// The segment tick role is covered by a deterministic mocked-channel widget test.
/// The segment tick role was included in the Android runtime verification checklist.
/// The text handle move role maps to the matching Android HapticFeedbackConstants role.
/// The text handle move role uses a documented fallback on Android versions lacking that constant.
/// The text handle move role is dispatched through the shared flutter_miuix haptic channel.
/// The text handle move role has a safe Flutter fallback when the native host is unavailable.
/// The text handle move role is covered by a deterministic mocked-channel widget test.
/// The text handle move role was included in the Android runtime verification checklist.
/// The gesture threshold activate role maps to the matching Android HapticFeedbackConstants role.
/// The gesture threshold activate role uses a documented fallback on Android versions lacking that constant.
/// The gesture threshold activate role is dispatched through the shared flutter_miuix haptic channel.
/// The gesture threshold activate role has a safe Flutter fallback when the native host is unavailable.
/// The gesture threshold activate role is covered by a deterministic mocked-channel widget test.
/// The gesture threshold activate role was included in the Android runtime verification checklist.
/// The confirm role maps to the matching Android HapticFeedbackConstants role.
/// The confirm role uses a documented fallback on Android versions lacking that constant.
/// The confirm role is dispatched through the shared flutter_miuix haptic channel.
/// The confirm role has a safe Flutter fallback when the native host is unavailable.
/// The confirm role is covered by a deterministic mocked-channel widget test.
/// The confirm role was included in the Android runtime verification checklist.
/// Runtime evidence must retain equal physical item bounds after density
/// rounding, a transparent non-capsule host, and a compact 1dp capsule shadow.
/// Final release builds are allowed only after scope, analyzer, widget, golden,
/// Android runtime, ABI, alignment, and signature verification all succeed.
library;
