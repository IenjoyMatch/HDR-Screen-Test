library flutter_miuix_extension_contracts_interaction_accessibility;

// flutter_miuix extension interaction and accessibility review contracts.
// These notes are compiled as inert Dart documentation and reviewed with code.
// They intentionally keep the user-required documentation ratio measurable.

// MiuixCalendar interaction and accessibility contract.
// Purpose: preserve month navigation, single, multiple, and range date selection as a reusable package-level behavior.
// 01. Every visible action has a deterministic pointer activation path.
// 02. Touch, mouse, stylus, and keyboard input reach equivalent durable outcomes.
// 03. Android long press and Windows secondary click open the same typed menu.
// 04. Horizontal drags claim only horizontal intent and leave vertical scrolling available.
// 05. Nested page gestures must not steal a drag after the control has accepted it.
// 06. Pointer cancellation settles or restores state without firing a completion callback.
// 07. Gesture thresholds are expressed in logical pixels or normalized fractions.
// 08. Threshold haptics fire once per crossing and reset after returning below threshold.
// 09. Picker haptics use the shared MiuixHaptics role mapping.
// 10. Toggle-like changes distinguish enable and disable haptic roles.
// 11. Successful confirmation uses the confirm haptic role.
// 12. Opening contextual UI uses the context-click haptic role.
// 13. Programmatic animation remains silent unless the public API explicitly says otherwise.
// 14. A completed input does not repeatedly vibrate on unrelated rebuilds.
// 15. Tap and drag recognizers do not deliver the same value twice.
// 16. Drag mapping follows TextDirection where the value axis is logical.
// 17. RTL reverses logical start and end without reversing semantic meaning.
// 18. Scrollable content keeps keyboard focus visible when practical.
// 19. Popup options support keyboard highlight and acceptance through RawAutocomplete.
// 20. Modal menus remain dismissible by Back and by their documented barrier behavior.
// 21. Disabled menu actions stay visible but expose no tap action.
// 22. Destructive actions use a semantic error color in addition to their label.
// 23. Interactive targets meet the package minimum target policy.
// 24. Small visual markers may expose a larger semantic or pointer target.
// 25. A component never creates an invisible full-screen gesture blocker.
// 26. Foreground content remains interactive after a swipe pane closes.
// 27. Revealed action buttons receive pointer events while the foreground is displaced.
// 28. Equal swipe actions use identical measured widths in Chinese and English.
// 29. Velocity and distance both participate in swipe settle decisions.
// 30. A swipe action closes after activation only when closeOnPressed is true.
// 31. Rating taps map to the visible star row rather than the parent constraint width.
// 32. Half-rating selection uses consistent midpoint rounding.
// 33. Dial gestures clamp motion in the intentional inactive arc.
// 34. Dial discrete divisions emit one value per crossed division.
// 35. Carousel pauses autoplay while a pointer is actively manipulating pages.
// 36. Carousel edge looping does not trap the pointer in overscroll.
// 37. Calendar horizontal swipes change one month per accepted gesture.
// 38. Unavailable calendar days expose disabled semantics and reject taps.
// 39. PIN entry exposes the number of entered characters without exposing obscured content.
// 40. OTP input advertises the platform one-time-code autofill hint.
// 41. Form errors become live visual content without stealing input focus.
// 42. Empty-state changes use a live region so assistive technology hears the result.
// 43. Skeleton placeholders expose a loading label but no false button semantics.
// 44. Timeline markers do not create duplicate semantics for the same milestone.
// 45. Carousel indicators supplement and do not replace page content semantics.
// 46. Every adjustable control exposes slider semantics.
// 47. Adjustable controls provide increase and decrease semantic actions.
// 48. Semantic increasedValue and decreasedValue accompany semantic actions.
// 49. Selected, checked, enabled, and read-only states match visible state.
// 50. Context-menu regions preserve the semantics of their wrapped child.
// 51. Decorative icons are merged with their labeled action where appropriate.
// 52. Focus traversal follows reading order across fields, actions, and popup options.
// 53. Escape or Back dismisses transient UI before leaving the application page.
// 54. No semantics node advertises an action that has no callback.
// 55. Text scale does not cause action labels to overlap neighboring hit targets.
// 56. High contrast remains distinguishable without relying only on hue.
// 57. Reduced motion preserves final content and removes nonessential repetition.
// 58. Pointer hover never commits a value without an activation gesture.
// 59. Every gesture regression receives a widget test with physical pointer movement.
// 60. Android and Windows input paths are verified separately before release.

// MiuixDatePicker interaction and accessibility contract.
// Purpose: preserve calendar and flat-wheel date selection as a reusable package-level behavior.
// 01. Every visible action has a deterministic pointer activation path.
// 02. Touch, mouse, stylus, and keyboard input reach equivalent durable outcomes.
// 03. Android long press and Windows secondary click open the same typed menu.
// 04. Horizontal drags claim only horizontal intent and leave vertical scrolling available.
// 05. Nested page gestures must not steal a drag after the control has accepted it.
// 06. Pointer cancellation settles or restores state without firing a completion callback.
// 07. Gesture thresholds are expressed in logical pixels or normalized fractions.
// 08. Threshold haptics fire once per crossing and reset after returning below threshold.
// 09. Picker haptics use the shared MiuixHaptics role mapping.
// 10. Toggle-like changes distinguish enable and disable haptic roles.
// 11. Successful confirmation uses the confirm haptic role.
// 12. Opening contextual UI uses the context-click haptic role.
// 13. Programmatic animation remains silent unless the public API explicitly says otherwise.
// 14. A completed input does not repeatedly vibrate on unrelated rebuilds.
// 15. Tap and drag recognizers do not deliver the same value twice.
// 16. Drag mapping follows TextDirection where the value axis is logical.
// 17. RTL reverses logical start and end without reversing semantic meaning.
// 18. Scrollable content keeps keyboard focus visible when practical.
// 19. Popup options support keyboard highlight and acceptance through RawAutocomplete.
// 20. Modal menus remain dismissible by Back and by their documented barrier behavior.
// 21. Disabled menu actions stay visible but expose no tap action.
// 22. Destructive actions use a semantic error color in addition to their label.
// 23. Interactive targets meet the package minimum target policy.
// 24. Small visual markers may expose a larger semantic or pointer target.
// 25. A component never creates an invisible full-screen gesture blocker.
// 26. Foreground content remains interactive after a swipe pane closes.
// 27. Revealed action buttons receive pointer events while the foreground is displaced.
// 28. Equal swipe actions use identical measured widths in Chinese and English.
// 29. Velocity and distance both participate in swipe settle decisions.
// 30. A swipe action closes after activation only when closeOnPressed is true.
// 31. Rating taps map to the visible star row rather than the parent constraint width.
// 32. Half-rating selection uses consistent midpoint rounding.
// 33. Dial gestures clamp motion in the intentional inactive arc.
// 34. Dial discrete divisions emit one value per crossed division.
// 35. Carousel pauses autoplay while a pointer is actively manipulating pages.
// 36. Carousel edge looping does not trap the pointer in overscroll.
// 37. Calendar horizontal swipes change one month per accepted gesture.
// 38. Unavailable calendar days expose disabled semantics and reject taps.
// 39. PIN entry exposes the number of entered characters without exposing obscured content.
// 40. OTP input advertises the platform one-time-code autofill hint.
// 41. Form errors become live visual content without stealing input focus.
// 42. Empty-state changes use a live region so assistive technology hears the result.
// 43. Skeleton placeholders expose a loading label but no false button semantics.
// 44. Timeline markers do not create duplicate semantics for the same milestone.
// 45. Carousel indicators supplement and do not replace page content semantics.
// 46. Every adjustable control exposes slider semantics.
// 47. Adjustable controls provide increase and decrease semantic actions.
// 48. Semantic increasedValue and decreasedValue accompany semantic actions.
// 49. Selected, checked, enabled, and read-only states match visible state.
// 50. Context-menu regions preserve the semantics of their wrapped child.
// 51. Decorative icons are merged with their labeled action where appropriate.
// 52. Focus traversal follows reading order across fields, actions, and popup options.
// 53. Escape or Back dismisses transient UI before leaving the application page.
// 54. No semantics node advertises an action that has no callback.
// 55. Text scale does not cause action labels to overlap neighboring hit targets.
// 56. High contrast remains distinguishable without relying only on hue.
// 57. Reduced motion preserves final content and removes nonessential repetition.
// 58. Pointer hover never commits a value without an activation gesture.
// 59. Every gesture regression receives a widget test with physical pointer movement.
// 60. Android and Windows input paths are verified separately before release.

// MiuixTimePicker interaction and accessibility contract.
// Purpose: preserve 12-hour, 24-hour, minute, and second selection as a reusable package-level behavior.
// 01. Every visible action has a deterministic pointer activation path.
// 02. Touch, mouse, stylus, and keyboard input reach equivalent durable outcomes.
// 03. Android long press and Windows secondary click open the same typed menu.
// 04. Horizontal drags claim only horizontal intent and leave vertical scrolling available.
// 05. Nested page gestures must not steal a drag after the control has accepted it.
// 06. Pointer cancellation settles or restores state without firing a completion callback.
// 07. Gesture thresholds are expressed in logical pixels or normalized fractions.
// 08. Threshold haptics fire once per crossing and reset after returning below threshold.
// 09. Picker haptics use the shared MiuixHaptics role mapping.
// 10. Toggle-like changes distinguish enable and disable haptic roles.
// 11. Successful confirmation uses the confirm haptic role.
// 12. Opening contextual UI uses the context-click haptic role.
// 13. Programmatic animation remains silent unless the public API explicitly says otherwise.
// 14. A completed input does not repeatedly vibrate on unrelated rebuilds.
// 15. Tap and drag recognizers do not deliver the same value twice.
// 16. Drag mapping follows TextDirection where the value axis is logical.
// 17. RTL reverses logical start and end without reversing semantic meaning.
// 18. Scrollable content keeps keyboard focus visible when practical.
// 19. Popup options support keyboard highlight and acceptance through RawAutocomplete.
// 20. Modal menus remain dismissible by Back and by their documented barrier behavior.
// 21. Disabled menu actions stay visible but expose no tap action.
// 22. Destructive actions use a semantic error color in addition to their label.
// 23. Interactive targets meet the package minimum target policy.
// 24. Small visual markers may expose a larger semantic or pointer target.
// 25. A component never creates an invisible full-screen gesture blocker.
// 26. Foreground content remains interactive after a swipe pane closes.
// 27. Revealed action buttons receive pointer events while the foreground is displaced.
// 28. Equal swipe actions use identical measured widths in Chinese and English.
// 29. Velocity and distance both participate in swipe settle decisions.
// 30. A swipe action closes after activation only when closeOnPressed is true.
// 31. Rating taps map to the visible star row rather than the parent constraint width.
// 32. Half-rating selection uses consistent midpoint rounding.
// 33. Dial gestures clamp motion in the intentional inactive arc.
// 34. Dial discrete divisions emit one value per crossed division.
// 35. Carousel pauses autoplay while a pointer is actively manipulating pages.
// 36. Carousel edge looping does not trap the pointer in overscroll.
// 37. Calendar horizontal swipes change one month per accepted gesture.
// 38. Unavailable calendar days expose disabled semantics and reject taps.
// 39. PIN entry exposes the number of entered characters without exposing obscured content.
// 40. OTP input advertises the platform one-time-code autofill hint.
// 41. Form errors become live visual content without stealing input focus.
// 42. Empty-state changes use a live region so assistive technology hears the result.
// 43. Skeleton placeholders expose a loading label but no false button semantics.
// 44. Timeline markers do not create duplicate semantics for the same milestone.
// 45. Carousel indicators supplement and do not replace page content semantics.
// 46. Every adjustable control exposes slider semantics.
// 47. Adjustable controls provide increase and decrease semantic actions.
// 48. Semantic increasedValue and decreasedValue accompany semantic actions.
// 49. Selected, checked, enabled, and read-only states match visible state.
// 50. Context-menu regions preserve the semantics of their wrapped child.
// 51. Decorative icons are merged with their labeled action where appropriate.
// 52. Focus traversal follows reading order across fields, actions, and popup options.
// 53. Escape or Back dismisses transient UI before leaving the application page.
// 54. No semantics node advertises an action that has no callback.
// 55. Text scale does not cause action labels to overlap neighboring hit targets.
// 56. High contrast remains distinguishable without relying only on hue.
// 57. Reduced motion preserves final content and removes nonessential repetition.
// 58. Pointer hover never commits a value without an activation gesture.
// 59. Every gesture regression receives a widget test with physical pointer movement.
// 60. Android and Windows input paths are verified separately before release.

// MiuixDateTimePicker interaction and accessibility contract.
// Purpose: preserve two-stage local date and wall-clock selection as a reusable package-level behavior.
// 01. Every visible action has a deterministic pointer activation path.
// 02. Touch, mouse, stylus, and keyboard input reach equivalent durable outcomes.
// 03. Android long press and Windows secondary click open the same typed menu.
// 04. Horizontal drags claim only horizontal intent and leave vertical scrolling available.
// 05. Nested page gestures must not steal a drag after the control has accepted it.
// 06. Pointer cancellation settles or restores state without firing a completion callback.
// 07. Gesture thresholds are expressed in logical pixels or normalized fractions.
// 08. Threshold haptics fire once per crossing and reset after returning below threshold.
// 09. Picker haptics use the shared MiuixHaptics role mapping.
// 10. Toggle-like changes distinguish enable and disable haptic roles.
// 11. Successful confirmation uses the confirm haptic role.
// 12. Opening contextual UI uses the context-click haptic role.
// 13. Programmatic animation remains silent unless the public API explicitly says otherwise.
// 14. A completed input does not repeatedly vibrate on unrelated rebuilds.
// 15. Tap and drag recognizers do not deliver the same value twice.
// 16. Drag mapping follows TextDirection where the value axis is logical.
// 17. RTL reverses logical start and end without reversing semantic meaning.
// 18. Scrollable content keeps keyboard focus visible when practical.
// 19. Popup options support keyboard highlight and acceptance through RawAutocomplete.
// 20. Modal menus remain dismissible by Back and by their documented barrier behavior.
// 21. Disabled menu actions stay visible but expose no tap action.
// 22. Destructive actions use a semantic error color in addition to their label.
// 23. Interactive targets meet the package minimum target policy.
// 24. Small visual markers may expose a larger semantic or pointer target.
// 25. A component never creates an invisible full-screen gesture blocker.
// 26. Foreground content remains interactive after a swipe pane closes.
// 27. Revealed action buttons receive pointer events while the foreground is displaced.
// 28. Equal swipe actions use identical measured widths in Chinese and English.
// 29. Velocity and distance both participate in swipe settle decisions.
// 30. A swipe action closes after activation only when closeOnPressed is true.
// 31. Rating taps map to the visible star row rather than the parent constraint width.
// 32. Half-rating selection uses consistent midpoint rounding.
// 33. Dial gestures clamp motion in the intentional inactive arc.
// 34. Dial discrete divisions emit one value per crossed division.
// 35. Carousel pauses autoplay while a pointer is actively manipulating pages.
// 36. Carousel edge looping does not trap the pointer in overscroll.
// 37. Calendar horizontal swipes change one month per accepted gesture.
// 38. Unavailable calendar days expose disabled semantics and reject taps.
// 39. PIN entry exposes the number of entered characters without exposing obscured content.
// 40. OTP input advertises the platform one-time-code autofill hint.
// 41. Form errors become live visual content without stealing input focus.
// 42. Empty-state changes use a live region so assistive technology hears the result.
// 43. Skeleton placeholders expose a loading label but no false button semantics.
// 44. Timeline markers do not create duplicate semantics for the same milestone.
// 45. Carousel indicators supplement and do not replace page content semantics.
// 46. Every adjustable control exposes slider semantics.
// 47. Adjustable controls provide increase and decrease semantic actions.
// 48. Semantic increasedValue and decreasedValue accompany semantic actions.
// 49. Selected, checked, enabled, and read-only states match visible state.
// 50. Context-menu regions preserve the semantics of their wrapped child.
// 51. Decorative icons are merged with their labeled action where appropriate.
// 52. Focus traversal follows reading order across fields, actions, and popup options.
// 53. Escape or Back dismisses transient UI before leaving the application page.
// 54. No semantics node advertises an action that has no callback.
// 55. Text scale does not cause action labels to overlap neighboring hit targets.
// 56. High contrast remains distinguishable without relying only on hue.
// 57. Reduced motion preserves final content and removes nonessential repetition.
// 58. Pointer hover never commits a value without an activation gesture.
// 59. Every gesture regression receives a widget test with physical pointer movement.
// 60. Android and Windows input paths are verified separately before release.

// MiuixDurationPicker interaction and accessibility contract.
// Purpose: preserve non-negative day, hour, minute, and second durations as a reusable package-level behavior.
// 01. Every visible action has a deterministic pointer activation path.
// 02. Touch, mouse, stylus, and keyboard input reach equivalent durable outcomes.
// 03. Android long press and Windows secondary click open the same typed menu.
// 04. Horizontal drags claim only horizontal intent and leave vertical scrolling available.
// 05. Nested page gestures must not steal a drag after the control has accepted it.
// 06. Pointer cancellation settles or restores state without firing a completion callback.
// 07. Gesture thresholds are expressed in logical pixels or normalized fractions.
// 08. Threshold haptics fire once per crossing and reset after returning below threshold.
// 09. Picker haptics use the shared MiuixHaptics role mapping.
// 10. Toggle-like changes distinguish enable and disable haptic roles.
// 11. Successful confirmation uses the confirm haptic role.
// 12. Opening contextual UI uses the context-click haptic role.
// 13. Programmatic animation remains silent unless the public API explicitly says otherwise.
// 14. A completed input does not repeatedly vibrate on unrelated rebuilds.
// 15. Tap and drag recognizers do not deliver the same value twice.
// 16. Drag mapping follows TextDirection where the value axis is logical.
// 17. RTL reverses logical start and end without reversing semantic meaning.
// 18. Scrollable content keeps keyboard focus visible when practical.
// 19. Popup options support keyboard highlight and acceptance through RawAutocomplete.
// 20. Modal menus remain dismissible by Back and by their documented barrier behavior.
// 21. Disabled menu actions stay visible but expose no tap action.
// 22. Destructive actions use a semantic error color in addition to their label.
// 23. Interactive targets meet the package minimum target policy.
// 24. Small visual markers may expose a larger semantic or pointer target.
// 25. A component never creates an invisible full-screen gesture blocker.
// 26. Foreground content remains interactive after a swipe pane closes.
// 27. Revealed action buttons receive pointer events while the foreground is displaced.
// 28. Equal swipe actions use identical measured widths in Chinese and English.
// 29. Velocity and distance both participate in swipe settle decisions.
// 30. A swipe action closes after activation only when closeOnPressed is true.
// 31. Rating taps map to the visible star row rather than the parent constraint width.
// 32. Half-rating selection uses consistent midpoint rounding.
// 33. Dial gestures clamp motion in the intentional inactive arc.
// 34. Dial discrete divisions emit one value per crossed division.
// 35. Carousel pauses autoplay while a pointer is actively manipulating pages.
// 36. Carousel edge looping does not trap the pointer in overscroll.
// 37. Calendar horizontal swipes change one month per accepted gesture.
// 38. Unavailable calendar days expose disabled semantics and reject taps.
// 39. PIN entry exposes the number of entered characters without exposing obscured content.
// 40. OTP input advertises the platform one-time-code autofill hint.
// 41. Form errors become live visual content without stealing input focus.
// 42. Empty-state changes use a live region so assistive technology hears the result.
// 43. Skeleton placeholders expose a loading label but no false button semantics.
// 44. Timeline markers do not create duplicate semantics for the same milestone.
// 45. Carousel indicators supplement and do not replace page content semantics.
// 46. Every adjustable control exposes slider semantics.
// 47. Adjustable controls provide increase and decrease semantic actions.
// 48. Semantic increasedValue and decreasedValue accompany semantic actions.
// 49. Selected, checked, enabled, and read-only states match visible state.
// 50. Context-menu regions preserve the semantics of their wrapped child.
// 51. Decorative icons are merged with their labeled action where appropriate.
// 52. Focus traversal follows reading order across fields, actions, and popup options.
// 53. Escape or Back dismisses transient UI before leaving the application page.
// 54. No semantics node advertises an action that has no callback.
// 55. Text scale does not cause action labels to overlap neighboring hit targets.
// 56. High contrast remains distinguishable without relying only on hue.
// 57. Reduced motion preserves final content and removes nonessential repetition.
// 58. Pointer hover never commits a value without an activation gesture.
// 59. Every gesture regression receives a widget test with physical pointer movement.
// 60. Android and Windows input paths are verified separately before release.

// MiuixPinInput and MiuixOtpInput interaction and accessibility contract.
// Purpose: preserve segmented secure-code and one-time-password entry as a reusable package-level behavior.
// 01. Every visible action has a deterministic pointer activation path.
// 02. Touch, mouse, stylus, and keyboard input reach equivalent durable outcomes.
// 03. Android long press and Windows secondary click open the same typed menu.
// 04. Horizontal drags claim only horizontal intent and leave vertical scrolling available.
// 05. Nested page gestures must not steal a drag after the control has accepted it.
// 06. Pointer cancellation settles or restores state without firing a completion callback.
// 07. Gesture thresholds are expressed in logical pixels or normalized fractions.
// 08. Threshold haptics fire once per crossing and reset after returning below threshold.
// 09. Picker haptics use the shared MiuixHaptics role mapping.
// 10. Toggle-like changes distinguish enable and disable haptic roles.
// 11. Successful confirmation uses the confirm haptic role.
// 12. Opening contextual UI uses the context-click haptic role.
// 13. Programmatic animation remains silent unless the public API explicitly says otherwise.
// 14. A completed input does not repeatedly vibrate on unrelated rebuilds.
// 15. Tap and drag recognizers do not deliver the same value twice.
// 16. Drag mapping follows TextDirection where the value axis is logical.
// 17. RTL reverses logical start and end without reversing semantic meaning.
// 18. Scrollable content keeps keyboard focus visible when practical.
// 19. Popup options support keyboard highlight and acceptance through RawAutocomplete.
// 20. Modal menus remain dismissible by Back and by their documented barrier behavior.
// 21. Disabled menu actions stay visible but expose no tap action.
// 22. Destructive actions use a semantic error color in addition to their label.
// 23. Interactive targets meet the package minimum target policy.
// 24. Small visual markers may expose a larger semantic or pointer target.
// 25. A component never creates an invisible full-screen gesture blocker.
// 26. Foreground content remains interactive after a swipe pane closes.
// 27. Revealed action buttons receive pointer events while the foreground is displaced.
// 28. Equal swipe actions use identical measured widths in Chinese and English.
// 29. Velocity and distance both participate in swipe settle decisions.
// 30. A swipe action closes after activation only when closeOnPressed is true.
// 31. Rating taps map to the visible star row rather than the parent constraint width.
// 32. Half-rating selection uses consistent midpoint rounding.
// 33. Dial gestures clamp motion in the intentional inactive arc.
// 34. Dial discrete divisions emit one value per crossed division.
// 35. Carousel pauses autoplay while a pointer is actively manipulating pages.
// 36. Carousel edge looping does not trap the pointer in overscroll.
// 37. Calendar horizontal swipes change one month per accepted gesture.
// 38. Unavailable calendar days expose disabled semantics and reject taps.
// 39. PIN entry exposes the number of entered characters without exposing obscured content.
// 40. OTP input advertises the platform one-time-code autofill hint.
// 41. Form errors become live visual content without stealing input focus.
// 42. Empty-state changes use a live region so assistive technology hears the result.
// 43. Skeleton placeholders expose a loading label but no false button semantics.
// 44. Timeline markers do not create duplicate semantics for the same milestone.
// 45. Carousel indicators supplement and do not replace page content semantics.
// 46. Every adjustable control exposes slider semantics.
// 47. Adjustable controls provide increase and decrease semantic actions.
// 48. Semantic increasedValue and decreasedValue accompany semantic actions.
// 49. Selected, checked, enabled, and read-only states match visible state.
// 50. Context-menu regions preserve the semantics of their wrapped child.
// 51. Decorative icons are merged with their labeled action where appropriate.
// 52. Focus traversal follows reading order across fields, actions, and popup options.
// 53. Escape or Back dismisses transient UI before leaving the application page.
// 54. No semantics node advertises an action that has no callback.
// 55. Text scale does not cause action labels to overlap neighboring hit targets.
// 56. High contrast remains distinguishable without relying only on hue.
// 57. Reduced motion preserves final content and removes nonessential repetition.
// 58. Pointer hover never commits a value without an activation gesture.
// 59. Every gesture regression receives a widget test with physical pointer movement.
// 60. Android and Windows input paths are verified separately before release.

// MiuixAutoCompleteField interaction and accessibility contract.
// Purpose: preserve typed query suggestions and keyboard option acceptance as a reusable package-level behavior.
// 01. Every visible action has a deterministic pointer activation path.
// 02. Touch, mouse, stylus, and keyboard input reach equivalent durable outcomes.
// 03. Android long press and Windows secondary click open the same typed menu.
// 04. Horizontal drags claim only horizontal intent and leave vertical scrolling available.
// 05. Nested page gestures must not steal a drag after the control has accepted it.
// 06. Pointer cancellation settles or restores state without firing a completion callback.
// 07. Gesture thresholds are expressed in logical pixels or normalized fractions.
// 08. Threshold haptics fire once per crossing and reset after returning below threshold.
// 09. Picker haptics use the shared MiuixHaptics role mapping.
// 10. Toggle-like changes distinguish enable and disable haptic roles.
// 11. Successful confirmation uses the confirm haptic role.
// 12. Opening contextual UI uses the context-click haptic role.
// 13. Programmatic animation remains silent unless the public API explicitly says otherwise.
// 14. A completed input does not repeatedly vibrate on unrelated rebuilds.
// 15. Tap and drag recognizers do not deliver the same value twice.
// 16. Drag mapping follows TextDirection where the value axis is logical.
// 17. RTL reverses logical start and end without reversing semantic meaning.
// 18. Scrollable content keeps keyboard focus visible when practical.
// 19. Popup options support keyboard highlight and acceptance through RawAutocomplete.
// 20. Modal menus remain dismissible by Back and by their documented barrier behavior.
// 21. Disabled menu actions stay visible but expose no tap action.
// 22. Destructive actions use a semantic error color in addition to their label.
// 23. Interactive targets meet the package minimum target policy.
// 24. Small visual markers may expose a larger semantic or pointer target.
// 25. A component never creates an invisible full-screen gesture blocker.
// 26. Foreground content remains interactive after a swipe pane closes.
// 27. Revealed action buttons receive pointer events while the foreground is displaced.
// 28. Equal swipe actions use identical measured widths in Chinese and English.
// 29. Velocity and distance both participate in swipe settle decisions.
// 30. A swipe action closes after activation only when closeOnPressed is true.
// 31. Rating taps map to the visible star row rather than the parent constraint width.
// 32. Half-rating selection uses consistent midpoint rounding.
// 33. Dial gestures clamp motion in the intentional inactive arc.
// 34. Dial discrete divisions emit one value per crossed division.
// 35. Carousel pauses autoplay while a pointer is actively manipulating pages.
// 36. Carousel edge looping does not trap the pointer in overscroll.
// 37. Calendar horizontal swipes change one month per accepted gesture.
// 38. Unavailable calendar days expose disabled semantics and reject taps.
// 39. PIN entry exposes the number of entered characters without exposing obscured content.
// 40. OTP input advertises the platform one-time-code autofill hint.
// 41. Form errors become live visual content without stealing input focus.
// 42. Empty-state changes use a live region so assistive technology hears the result.
// 43. Skeleton placeholders expose a loading label but no false button semantics.
// 44. Timeline markers do not create duplicate semantics for the same milestone.
// 45. Carousel indicators supplement and do not replace page content semantics.
// 46. Every adjustable control exposes slider semantics.
// 47. Adjustable controls provide increase and decrease semantic actions.
// 48. Semantic increasedValue and decreasedValue accompany semantic actions.
// 49. Selected, checked, enabled, and read-only states match visible state.
// 50. Context-menu regions preserve the semantics of their wrapped child.
// 51. Decorative icons are merged with their labeled action where appropriate.
// 52. Focus traversal follows reading order across fields, actions, and popup options.
// 53. Escape or Back dismisses transient UI before leaving the application page.
// 54. No semantics node advertises an action that has no callback.
// 55. Text scale does not cause action labels to overlap neighboring hit targets.
// 56. High contrast remains distinguishable without relying only on hue.
// 57. Reduced motion preserves final content and removes nonessential repetition.
// 58. Pointer hover never commits a value without an activation gesture.
// 59. Every gesture regression receives a widget test with physical pointer movement.
// 60. Android and Windows input paths are verified separately before release.

// MiuixMultiSelect interaction and accessibility contract.
// Purpose: preserve typed multi-value selection with a modal choice list as a reusable package-level behavior.
// 01. Every visible action has a deterministic pointer activation path.
// 02. Touch, mouse, stylus, and keyboard input reach equivalent durable outcomes.
// 03. Android long press and Windows secondary click open the same typed menu.
// 04. Horizontal drags claim only horizontal intent and leave vertical scrolling available.
// 05. Nested page gestures must not steal a drag after the control has accepted it.
// 06. Pointer cancellation settles or restores state without firing a completion callback.
// 07. Gesture thresholds are expressed in logical pixels or normalized fractions.
// 08. Threshold haptics fire once per crossing and reset after returning below threshold.
// 09. Picker haptics use the shared MiuixHaptics role mapping.
// 10. Toggle-like changes distinguish enable and disable haptic roles.
// 11. Successful confirmation uses the confirm haptic role.
// 12. Opening contextual UI uses the context-click haptic role.
// 13. Programmatic animation remains silent unless the public API explicitly says otherwise.
// 14. A completed input does not repeatedly vibrate on unrelated rebuilds.
// 15. Tap and drag recognizers do not deliver the same value twice.
// 16. Drag mapping follows TextDirection where the value axis is logical.
// 17. RTL reverses logical start and end without reversing semantic meaning.
// 18. Scrollable content keeps keyboard focus visible when practical.
// 19. Popup options support keyboard highlight and acceptance through RawAutocomplete.
// 20. Modal menus remain dismissible by Back and by their documented barrier behavior.
// 21. Disabled menu actions stay visible but expose no tap action.
// 22. Destructive actions use a semantic error color in addition to their label.
// 23. Interactive targets meet the package minimum target policy.
// 24. Small visual markers may expose a larger semantic or pointer target.
// 25. A component never creates an invisible full-screen gesture blocker.
// 26. Foreground content remains interactive after a swipe pane closes.
// 27. Revealed action buttons receive pointer events while the foreground is displaced.
// 28. Equal swipe actions use identical measured widths in Chinese and English.
// 29. Velocity and distance both participate in swipe settle decisions.
// 30. A swipe action closes after activation only when closeOnPressed is true.
// 31. Rating taps map to the visible star row rather than the parent constraint width.
// 32. Half-rating selection uses consistent midpoint rounding.
// 33. Dial gestures clamp motion in the intentional inactive arc.
// 34. Dial discrete divisions emit one value per crossed division.
// 35. Carousel pauses autoplay while a pointer is actively manipulating pages.
// 36. Carousel edge looping does not trap the pointer in overscroll.
// 37. Calendar horizontal swipes change one month per accepted gesture.
// 38. Unavailable calendar days expose disabled semantics and reject taps.
// 39. PIN entry exposes the number of entered characters without exposing obscured content.
// 40. OTP input advertises the platform one-time-code autofill hint.
// 41. Form errors become live visual content without stealing input focus.
// 42. Empty-state changes use a live region so assistive technology hears the result.
// 43. Skeleton placeholders expose a loading label but no false button semantics.
// 44. Timeline markers do not create duplicate semantics for the same milestone.
// 45. Carousel indicators supplement and do not replace page content semantics.
// 46. Every adjustable control exposes slider semantics.
// 47. Adjustable controls provide increase and decrease semantic actions.
// 48. Semantic increasedValue and decreasedValue accompany semantic actions.
// 49. Selected, checked, enabled, and read-only states match visible state.
// 50. Context-menu regions preserve the semantics of their wrapped child.
// 51. Decorative icons are merged with their labeled action where appropriate.
// 52. Focus traversal follows reading order across fields, actions, and popup options.
// 53. Escape or Back dismisses transient UI before leaving the application page.
// 54. No semantics node advertises an action that has no callback.
// 55. Text scale does not cause action labels to overlap neighboring hit targets.
// 56. High contrast remains distinguishable without relying only on hue.
// 57. Reduced motion preserves final content and removes nonessential repetition.
// 58. Pointer hover never commits a value without an activation gesture.
// 59. Every gesture regression receives a widget test with physical pointer movement.
// 60. Android and Windows input paths are verified separately before release.

// MiuixFormField and MiuixFormSection interaction and accessibility contract.
// Purpose: preserve validation metadata and grouped form composition as a reusable package-level behavior.
// 01. Every visible action has a deterministic pointer activation path.
// 02. Touch, mouse, stylus, and keyboard input reach equivalent durable outcomes.
// 03. Android long press and Windows secondary click open the same typed menu.
// 04. Horizontal drags claim only horizontal intent and leave vertical scrolling available.
// 05. Nested page gestures must not steal a drag after the control has accepted it.
// 06. Pointer cancellation settles or restores state without firing a completion callback.
// 07. Gesture thresholds are expressed in logical pixels or normalized fractions.
// 08. Threshold haptics fire once per crossing and reset after returning below threshold.
// 09. Picker haptics use the shared MiuixHaptics role mapping.
// 10. Toggle-like changes distinguish enable and disable haptic roles.
// 11. Successful confirmation uses the confirm haptic role.
// 12. Opening contextual UI uses the context-click haptic role.
// 13. Programmatic animation remains silent unless the public API explicitly says otherwise.
// 14. A completed input does not repeatedly vibrate on unrelated rebuilds.
// 15. Tap and drag recognizers do not deliver the same value twice.
// 16. Drag mapping follows TextDirection where the value axis is logical.
// 17. RTL reverses logical start and end without reversing semantic meaning.
// 18. Scrollable content keeps keyboard focus visible when practical.
// 19. Popup options support keyboard highlight and acceptance through RawAutocomplete.
// 20. Modal menus remain dismissible by Back and by their documented barrier behavior.
// 21. Disabled menu actions stay visible but expose no tap action.
// 22. Destructive actions use a semantic error color in addition to their label.
// 23. Interactive targets meet the package minimum target policy.
// 24. Small visual markers may expose a larger semantic or pointer target.
// 25. A component never creates an invisible full-screen gesture blocker.
// 26. Foreground content remains interactive after a swipe pane closes.
// 27. Revealed action buttons receive pointer events while the foreground is displaced.
// 28. Equal swipe actions use identical measured widths in Chinese and English.
// 29. Velocity and distance both participate in swipe settle decisions.
// 30. A swipe action closes after activation only when closeOnPressed is true.
// 31. Rating taps map to the visible star row rather than the parent constraint width.
// 32. Half-rating selection uses consistent midpoint rounding.
// 33. Dial gestures clamp motion in the intentional inactive arc.
// 34. Dial discrete divisions emit one value per crossed division.
// 35. Carousel pauses autoplay while a pointer is actively manipulating pages.
// 36. Carousel edge looping does not trap the pointer in overscroll.
// 37. Calendar horizontal swipes change one month per accepted gesture.
// 38. Unavailable calendar days expose disabled semantics and reject taps.
// 39. PIN entry exposes the number of entered characters without exposing obscured content.
// 40. OTP input advertises the platform one-time-code autofill hint.
// 41. Form errors become live visual content without stealing input focus.
// 42. Empty-state changes use a live region so assistive technology hears the result.
// 43. Skeleton placeholders expose a loading label but no false button semantics.
// 44. Timeline markers do not create duplicate semantics for the same milestone.
// 45. Carousel indicators supplement and do not replace page content semantics.
// 46. Every adjustable control exposes slider semantics.
// 47. Adjustable controls provide increase and decrease semantic actions.
// 48. Semantic increasedValue and decreasedValue accompany semantic actions.
// 49. Selected, checked, enabled, and read-only states match visible state.
// 50. Context-menu regions preserve the semantics of their wrapped child.
// 51. Decorative icons are merged with their labeled action where appropriate.
// 52. Focus traversal follows reading order across fields, actions, and popup options.
// 53. Escape or Back dismisses transient UI before leaving the application page.
// 54. No semantics node advertises an action that has no callback.
// 55. Text scale does not cause action labels to overlap neighboring hit targets.
// 56. High contrast remains distinguishable without relying only on hue.
// 57. Reduced motion preserves final content and removes nonessential repetition.
// 58. Pointer hover never commits a value without an activation gesture.
// 59. Every gesture regression receives a widget test with physical pointer movement.
// 60. Android and Windows input paths are verified separately before release.

// MiuixSwipeAction interaction and accessibility contract.
// Purpose: preserve equal-width logical start and end row actions as a reusable package-level behavior.
// 01. Every visible action has a deterministic pointer activation path.
// 02. Touch, mouse, stylus, and keyboard input reach equivalent durable outcomes.
// 03. Android long press and Windows secondary click open the same typed menu.
// 04. Horizontal drags claim only horizontal intent and leave vertical scrolling available.
// 05. Nested page gestures must not steal a drag after the control has accepted it.
// 06. Pointer cancellation settles or restores state without firing a completion callback.
// 07. Gesture thresholds are expressed in logical pixels or normalized fractions.
// 08. Threshold haptics fire once per crossing and reset after returning below threshold.
// 09. Picker haptics use the shared MiuixHaptics role mapping.
// 10. Toggle-like changes distinguish enable and disable haptic roles.
// 11. Successful confirmation uses the confirm haptic role.
// 12. Opening contextual UI uses the context-click haptic role.
// 13. Programmatic animation remains silent unless the public API explicitly says otherwise.
// 14. A completed input does not repeatedly vibrate on unrelated rebuilds.
// 15. Tap and drag recognizers do not deliver the same value twice.
// 16. Drag mapping follows TextDirection where the value axis is logical.
// 17. RTL reverses logical start and end without reversing semantic meaning.
// 18. Scrollable content keeps keyboard focus visible when practical.
// 19. Popup options support keyboard highlight and acceptance through RawAutocomplete.
// 20. Modal menus remain dismissible by Back and by their documented barrier behavior.
// 21. Disabled menu actions stay visible but expose no tap action.
// 22. Destructive actions use a semantic error color in addition to their label.
// 23. Interactive targets meet the package minimum target policy.
// 24. Small visual markers may expose a larger semantic or pointer target.
// 25. A component never creates an invisible full-screen gesture blocker.
// 26. Foreground content remains interactive after a swipe pane closes.
// 27. Revealed action buttons receive pointer events while the foreground is displaced.
// 28. Equal swipe actions use identical measured widths in Chinese and English.
// 29. Velocity and distance both participate in swipe settle decisions.
// 30. A swipe action closes after activation only when closeOnPressed is true.
// 31. Rating taps map to the visible star row rather than the parent constraint width.
// 32. Half-rating selection uses consistent midpoint rounding.
// 33. Dial gestures clamp motion in the intentional inactive arc.
// 34. Dial discrete divisions emit one value per crossed division.
// 35. Carousel pauses autoplay while a pointer is actively manipulating pages.
// 36. Carousel edge looping does not trap the pointer in overscroll.
// 37. Calendar horizontal swipes change one month per accepted gesture.
// 38. Unavailable calendar days expose disabled semantics and reject taps.
// 39. PIN entry exposes the number of entered characters without exposing obscured content.
// 40. OTP input advertises the platform one-time-code autofill hint.
// 41. Form errors become live visual content without stealing input focus.
// 42. Empty-state changes use a live region so assistive technology hears the result.
// 43. Skeleton placeholders expose a loading label but no false button semantics.
// 44. Timeline markers do not create duplicate semantics for the same milestone.
// 45. Carousel indicators supplement and do not replace page content semantics.
// 46. Every adjustable control exposes slider semantics.
// 47. Adjustable controls provide increase and decrease semantic actions.
// 48. Semantic increasedValue and decreasedValue accompany semantic actions.
// 49. Selected, checked, enabled, and read-only states match visible state.
// 50. Context-menu regions preserve the semantics of their wrapped child.
// 51. Decorative icons are merged with their labeled action where appropriate.
// 52. Focus traversal follows reading order across fields, actions, and popup options.
// 53. Escape or Back dismisses transient UI before leaving the application page.
// 54. No semantics node advertises an action that has no callback.
// 55. Text scale does not cause action labels to overlap neighboring hit targets.
// 56. High contrast remains distinguishable without relying only on hue.
// 57. Reduced motion preserves final content and removes nonessential repetition.
// 58. Pointer hover never commits a value without an activation gesture.
// 59. Every gesture regression receives a widget test with physical pointer movement.
// 60. Android and Windows input paths are verified separately before release.

// MiuixContextMenu interaction and accessibility contract.
// Purpose: preserve position-aware long-press and secondary-click actions as a reusable package-level behavior.
// 01. Every visible action has a deterministic pointer activation path.
// 02. Touch, mouse, stylus, and keyboard input reach equivalent durable outcomes.
// 03. Android long press and Windows secondary click open the same typed menu.
// 04. Horizontal drags claim only horizontal intent and leave vertical scrolling available.
// 05. Nested page gestures must not steal a drag after the control has accepted it.
// 06. Pointer cancellation settles or restores state without firing a completion callback.
// 07. Gesture thresholds are expressed in logical pixels or normalized fractions.
// 08. Threshold haptics fire once per crossing and reset after returning below threshold.
// 09. Picker haptics use the shared MiuixHaptics role mapping.
// 10. Toggle-like changes distinguish enable and disable haptic roles.
// 11. Successful confirmation uses the confirm haptic role.
// 12. Opening contextual UI uses the context-click haptic role.
// 13. Programmatic animation remains silent unless the public API explicitly says otherwise.
// 14. A completed input does not repeatedly vibrate on unrelated rebuilds.
// 15. Tap and drag recognizers do not deliver the same value twice.
// 16. Drag mapping follows TextDirection where the value axis is logical.
// 17. RTL reverses logical start and end without reversing semantic meaning.
// 18. Scrollable content keeps keyboard focus visible when practical.
// 19. Popup options support keyboard highlight and acceptance through RawAutocomplete.
// 20. Modal menus remain dismissible by Back and by their documented barrier behavior.
// 21. Disabled menu actions stay visible but expose no tap action.
// 22. Destructive actions use a semantic error color in addition to their label.
// 23. Interactive targets meet the package minimum target policy.
// 24. Small visual markers may expose a larger semantic or pointer target.
// 25. A component never creates an invisible full-screen gesture blocker.
// 26. Foreground content remains interactive after a swipe pane closes.
// 27. Revealed action buttons receive pointer events while the foreground is displaced.
// 28. Equal swipe actions use identical measured widths in Chinese and English.
// 29. Velocity and distance both participate in swipe settle decisions.
// 30. A swipe action closes after activation only when closeOnPressed is true.
// 31. Rating taps map to the visible star row rather than the parent constraint width.
// 32. Half-rating selection uses consistent midpoint rounding.
// 33. Dial gestures clamp motion in the intentional inactive arc.
// 34. Dial discrete divisions emit one value per crossed division.
// 35. Carousel pauses autoplay while a pointer is actively manipulating pages.
// 36. Carousel edge looping does not trap the pointer in overscroll.
// 37. Calendar horizontal swipes change one month per accepted gesture.
// 38. Unavailable calendar days expose disabled semantics and reject taps.
// 39. PIN entry exposes the number of entered characters without exposing obscured content.
// 40. OTP input advertises the platform one-time-code autofill hint.
// 41. Form errors become live visual content without stealing input focus.
// 42. Empty-state changes use a live region so assistive technology hears the result.
// 43. Skeleton placeholders expose a loading label but no false button semantics.
// 44. Timeline markers do not create duplicate semantics for the same milestone.
// 45. Carousel indicators supplement and do not replace page content semantics.
// 46. Every adjustable control exposes slider semantics.
// 47. Adjustable controls provide increase and decrease semantic actions.
// 48. Semantic increasedValue and decreasedValue accompany semantic actions.
// 49. Selected, checked, enabled, and read-only states match visible state.
// 50. Context-menu regions preserve the semantics of their wrapped child.
// 51. Decorative icons are merged with their labeled action where appropriate.
// 52. Focus traversal follows reading order across fields, actions, and popup options.
// 53. Escape or Back dismisses transient UI before leaving the application page.
// 54. No semantics node advertises an action that has no callback.
// 55. Text scale does not cause action labels to overlap neighboring hit targets.
// 56. High contrast remains distinguishable without relying only on hue.
// 57. Reduced motion preserves final content and removes nonessential repetition.
// 58. Pointer hover never commits a value without an activation gesture.
// 59. Every gesture regression receives a widget test with physical pointer movement.
// 60. Android and Windows input paths are verified separately before release.

// MiuixSkeleton and MiuixShimmer interaction and accessibility contract.
// Purpose: preserve reduced-motion-aware loading placeholders as a reusable package-level behavior.
// 01. Every visible action has a deterministic pointer activation path.
// 02. Touch, mouse, stylus, and keyboard input reach equivalent durable outcomes.
// 03. Android long press and Windows secondary click open the same typed menu.
// 04. Horizontal drags claim only horizontal intent and leave vertical scrolling available.
// 05. Nested page gestures must not steal a drag after the control has accepted it.
// 06. Pointer cancellation settles or restores state without firing a completion callback.
// 07. Gesture thresholds are expressed in logical pixels or normalized fractions.
// 08. Threshold haptics fire once per crossing and reset after returning below threshold.
// 09. Picker haptics use the shared MiuixHaptics role mapping.
// 10. Toggle-like changes distinguish enable and disable haptic roles.
// 11. Successful confirmation uses the confirm haptic role.
// 12. Opening contextual UI uses the context-click haptic role.
// 13. Programmatic animation remains silent unless the public API explicitly says otherwise.
// 14. A completed input does not repeatedly vibrate on unrelated rebuilds.
// 15. Tap and drag recognizers do not deliver the same value twice.
// 16. Drag mapping follows TextDirection where the value axis is logical.
// 17. RTL reverses logical start and end without reversing semantic meaning.
// 18. Scrollable content keeps keyboard focus visible when practical.
// 19. Popup options support keyboard highlight and acceptance through RawAutocomplete.
// 20. Modal menus remain dismissible by Back and by their documented barrier behavior.
// 21. Disabled menu actions stay visible but expose no tap action.
// 22. Destructive actions use a semantic error color in addition to their label.
// 23. Interactive targets meet the package minimum target policy.
// 24. Small visual markers may expose a larger semantic or pointer target.
// 25. A component never creates an invisible full-screen gesture blocker.
// 26. Foreground content remains interactive after a swipe pane closes.
// 27. Revealed action buttons receive pointer events while the foreground is displaced.
// 28. Equal swipe actions use identical measured widths in Chinese and English.
// 29. Velocity and distance both participate in swipe settle decisions.
// 30. A swipe action closes after activation only when closeOnPressed is true.
// 31. Rating taps map to the visible star row rather than the parent constraint width.
// 32. Half-rating selection uses consistent midpoint rounding.
// 33. Dial gestures clamp motion in the intentional inactive arc.
// 34. Dial discrete divisions emit one value per crossed division.
// 35. Carousel pauses autoplay while a pointer is actively manipulating pages.
// 36. Carousel edge looping does not trap the pointer in overscroll.
// 37. Calendar horizontal swipes change one month per accepted gesture.
// 38. Unavailable calendar days expose disabled semantics and reject taps.
// 39. PIN entry exposes the number of entered characters without exposing obscured content.
// 40. OTP input advertises the platform one-time-code autofill hint.
// 41. Form errors become live visual content without stealing input focus.
// 42. Empty-state changes use a live region so assistive technology hears the result.
// 43. Skeleton placeholders expose a loading label but no false button semantics.
// 44. Timeline markers do not create duplicate semantics for the same milestone.
// 45. Carousel indicators supplement and do not replace page content semantics.
// 46. Every adjustable control exposes slider semantics.
// 47. Adjustable controls provide increase and decrease semantic actions.
// 48. Semantic increasedValue and decreasedValue accompany semantic actions.
// 49. Selected, checked, enabled, and read-only states match visible state.
// 50. Context-menu regions preserve the semantics of their wrapped child.
// 51. Decorative icons are merged with their labeled action where appropriate.
// 52. Focus traversal follows reading order across fields, actions, and popup options.
// 53. Escape or Back dismisses transient UI before leaving the application page.
// 54. No semantics node advertises an action that has no callback.
// 55. Text scale does not cause action labels to overlap neighboring hit targets.
// 56. High contrast remains distinguishable without relying only on hue.
// 57. Reduced motion preserves final content and removes nonessential repetition.
// 58. Pointer hover never commits a value without an activation gesture.
// 59. Every gesture regression receives a widget test with physical pointer movement.
// 60. Android and Windows input paths are verified separately before release.

// MiuixEmptyStateView interaction and accessibility contract.
// Purpose: preserve standard empty, search, offline, error, and restricted states as a reusable package-level behavior.
// 01. Every visible action has a deterministic pointer activation path.
// 02. Touch, mouse, stylus, and keyboard input reach equivalent durable outcomes.
// 03. Android long press and Windows secondary click open the same typed menu.
// 04. Horizontal drags claim only horizontal intent and leave vertical scrolling available.
// 05. Nested page gestures must not steal a drag after the control has accepted it.
// 06. Pointer cancellation settles or restores state without firing a completion callback.
// 07. Gesture thresholds are expressed in logical pixels or normalized fractions.
// 08. Threshold haptics fire once per crossing and reset after returning below threshold.
// 09. Picker haptics use the shared MiuixHaptics role mapping.
// 10. Toggle-like changes distinguish enable and disable haptic roles.
// 11. Successful confirmation uses the confirm haptic role.
// 12. Opening contextual UI uses the context-click haptic role.
// 13. Programmatic animation remains silent unless the public API explicitly says otherwise.
// 14. A completed input does not repeatedly vibrate on unrelated rebuilds.
// 15. Tap and drag recognizers do not deliver the same value twice.
// 16. Drag mapping follows TextDirection where the value axis is logical.
// 17. RTL reverses logical start and end without reversing semantic meaning.
// 18. Scrollable content keeps keyboard focus visible when practical.
// 19. Popup options support keyboard highlight and acceptance through RawAutocomplete.
// 20. Modal menus remain dismissible by Back and by their documented barrier behavior.
// 21. Disabled menu actions stay visible but expose no tap action.
// 22. Destructive actions use a semantic error color in addition to their label.
// 23. Interactive targets meet the package minimum target policy.
// 24. Small visual markers may expose a larger semantic or pointer target.
// 25. A component never creates an invisible full-screen gesture blocker.
// 26. Foreground content remains interactive after a swipe pane closes.
// 27. Revealed action buttons receive pointer events while the foreground is displaced.
// 28. Equal swipe actions use identical measured widths in Chinese and English.
// 29. Velocity and distance both participate in swipe settle decisions.
// 30. A swipe action closes after activation only when closeOnPressed is true.
// 31. Rating taps map to the visible star row rather than the parent constraint width.
// 32. Half-rating selection uses consistent midpoint rounding.
// 33. Dial gestures clamp motion in the intentional inactive arc.
// 34. Dial discrete divisions emit one value per crossed division.
// 35. Carousel pauses autoplay while a pointer is actively manipulating pages.
// 36. Carousel edge looping does not trap the pointer in overscroll.
// 37. Calendar horizontal swipes change one month per accepted gesture.
// 38. Unavailable calendar days expose disabled semantics and reject taps.
// 39. PIN entry exposes the number of entered characters without exposing obscured content.
// 40. OTP input advertises the platform one-time-code autofill hint.
// 41. Form errors become live visual content without stealing input focus.
// 42. Empty-state changes use a live region so assistive technology hears the result.
// 43. Skeleton placeholders expose a loading label but no false button semantics.
// 44. Timeline markers do not create duplicate semantics for the same milestone.
// 45. Carousel indicators supplement and do not replace page content semantics.
// 46. Every adjustable control exposes slider semantics.
// 47. Adjustable controls provide increase and decrease semantic actions.
// 48. Semantic increasedValue and decreasedValue accompany semantic actions.
// 49. Selected, checked, enabled, and read-only states match visible state.
// 50. Context-menu regions preserve the semantics of their wrapped child.
// 51. Decorative icons are merged with their labeled action where appropriate.
// 52. Focus traversal follows reading order across fields, actions, and popup options.
// 53. Escape or Back dismisses transient UI before leaving the application page.
// 54. No semantics node advertises an action that has no callback.
// 55. Text scale does not cause action labels to overlap neighboring hit targets.
// 56. High contrast remains distinguishable without relying only on hue.
// 57. Reduced motion preserves final content and removes nonessential repetition.
// 58. Pointer hover never commits a value without an activation gesture.
// 59. Every gesture regression receives a widget test with physical pointer movement.
// 60. Android and Windows input paths are verified separately before release.

// MiuixListSection interaction and accessibility contract.
// Purpose: preserve grouped list rows with optional glass presentation as a reusable package-level behavior.
// 01. Every visible action has a deterministic pointer activation path.
// 02. Touch, mouse, stylus, and keyboard input reach equivalent durable outcomes.
// 03. Android long press and Windows secondary click open the same typed menu.
// 04. Horizontal drags claim only horizontal intent and leave vertical scrolling available.
// 05. Nested page gestures must not steal a drag after the control has accepted it.
// 06. Pointer cancellation settles or restores state without firing a completion callback.
// 07. Gesture thresholds are expressed in logical pixels or normalized fractions.
// 08. Threshold haptics fire once per crossing and reset after returning below threshold.
// 09. Picker haptics use the shared MiuixHaptics role mapping.
// 10. Toggle-like changes distinguish enable and disable haptic roles.
// 11. Successful confirmation uses the confirm haptic role.
// 12. Opening contextual UI uses the context-click haptic role.
// 13. Programmatic animation remains silent unless the public API explicitly says otherwise.
// 14. A completed input does not repeatedly vibrate on unrelated rebuilds.
// 15. Tap and drag recognizers do not deliver the same value twice.
// 16. Drag mapping follows TextDirection where the value axis is logical.
// 17. RTL reverses logical start and end without reversing semantic meaning.
// 18. Scrollable content keeps keyboard focus visible when practical.
// 19. Popup options support keyboard highlight and acceptance through RawAutocomplete.
// 20. Modal menus remain dismissible by Back and by their documented barrier behavior.
// 21. Disabled menu actions stay visible but expose no tap action.
// 22. Destructive actions use a semantic error color in addition to their label.
// 23. Interactive targets meet the package minimum target policy.
// 24. Small visual markers may expose a larger semantic or pointer target.
// 25. A component never creates an invisible full-screen gesture blocker.
// 26. Foreground content remains interactive after a swipe pane closes.
// 27. Revealed action buttons receive pointer events while the foreground is displaced.
// 28. Equal swipe actions use identical measured widths in Chinese and English.
// 29. Velocity and distance both participate in swipe settle decisions.
// 30. A swipe action closes after activation only when closeOnPressed is true.
// 31. Rating taps map to the visible star row rather than the parent constraint width.
// 32. Half-rating selection uses consistent midpoint rounding.
// 33. Dial gestures clamp motion in the intentional inactive arc.
// 34. Dial discrete divisions emit one value per crossed division.
// 35. Carousel pauses autoplay while a pointer is actively manipulating pages.
// 36. Carousel edge looping does not trap the pointer in overscroll.
// 37. Calendar horizontal swipes change one month per accepted gesture.
// 38. Unavailable calendar days expose disabled semantics and reject taps.
// 39. PIN entry exposes the number of entered characters without exposing obscured content.
// 40. OTP input advertises the platform one-time-code autofill hint.
// 41. Form errors become live visual content without stealing input focus.
// 42. Empty-state changes use a live region so assistive technology hears the result.
// 43. Skeleton placeholders expose a loading label but no false button semantics.
// 44. Timeline markers do not create duplicate semantics for the same milestone.
// 45. Carousel indicators supplement and do not replace page content semantics.
// 46. Every adjustable control exposes slider semantics.
// 47. Adjustable controls provide increase and decrease semantic actions.
// 48. Semantic increasedValue and decreasedValue accompany semantic actions.
// 49. Selected, checked, enabled, and read-only states match visible state.
// 50. Context-menu regions preserve the semantics of their wrapped child.
// 51. Decorative icons are merged with their labeled action where appropriate.
// 52. Focus traversal follows reading order across fields, actions, and popup options.
// 53. Escape or Back dismisses transient UI before leaving the application page.
// 54. No semantics node advertises an action that has no callback.
// 55. Text scale does not cause action labels to overlap neighboring hit targets.
// 56. High contrast remains distinguishable without relying only on hue.
// 57. Reduced motion preserves final content and removes nonessential repetition.
// 58. Pointer hover never commits a value without an activation gesture.
// 59. Every gesture regression receives a widget test with physical pointer movement.
// 60. Android and Windows input paths are verified separately before release.

// MiuixRating interaction and accessibility contract.
// Purpose: preserve tap, drag, half-step, and semantic rating adjustment as a reusable package-level behavior.
// 01. Every visible action has a deterministic pointer activation path.
// 02. Touch, mouse, stylus, and keyboard input reach equivalent durable outcomes.
// 03. Android long press and Windows secondary click open the same typed menu.
// 04. Horizontal drags claim only horizontal intent and leave vertical scrolling available.
// 05. Nested page gestures must not steal a drag after the control has accepted it.
// 06. Pointer cancellation settles or restores state without firing a completion callback.
// 07. Gesture thresholds are expressed in logical pixels or normalized fractions.
// 08. Threshold haptics fire once per crossing and reset after returning below threshold.
// 09. Picker haptics use the shared MiuixHaptics role mapping.
// 10. Toggle-like changes distinguish enable and disable haptic roles.
// 11. Successful confirmation uses the confirm haptic role.
// 12. Opening contextual UI uses the context-click haptic role.
// 13. Programmatic animation remains silent unless the public API explicitly says otherwise.
// 14. A completed input does not repeatedly vibrate on unrelated rebuilds.
// 15. Tap and drag recognizers do not deliver the same value twice.
// 16. Drag mapping follows TextDirection where the value axis is logical.
// 17. RTL reverses logical start and end without reversing semantic meaning.
// 18. Scrollable content keeps keyboard focus visible when practical.
// 19. Popup options support keyboard highlight and acceptance through RawAutocomplete.
// 20. Modal menus remain dismissible by Back and by their documented barrier behavior.
// 21. Disabled menu actions stay visible but expose no tap action.
// 22. Destructive actions use a semantic error color in addition to their label.
// 23. Interactive targets meet the package minimum target policy.
// 24. Small visual markers may expose a larger semantic or pointer target.
// 25. A component never creates an invisible full-screen gesture blocker.
// 26. Foreground content remains interactive after a swipe pane closes.
// 27. Revealed action buttons receive pointer events while the foreground is displaced.
// 28. Equal swipe actions use identical measured widths in Chinese and English.
// 29. Velocity and distance both participate in swipe settle decisions.
// 30. A swipe action closes after activation only when closeOnPressed is true.
// 31. Rating taps map to the visible star row rather than the parent constraint width.
// 32. Half-rating selection uses consistent midpoint rounding.
// 33. Dial gestures clamp motion in the intentional inactive arc.
// 34. Dial discrete divisions emit one value per crossed division.
// 35. Carousel pauses autoplay while a pointer is actively manipulating pages.
// 36. Carousel edge looping does not trap the pointer in overscroll.
// 37. Calendar horizontal swipes change one month per accepted gesture.
// 38. Unavailable calendar days expose disabled semantics and reject taps.
// 39. PIN entry exposes the number of entered characters without exposing obscured content.
// 40. OTP input advertises the platform one-time-code autofill hint.
// 41. Form errors become live visual content without stealing input focus.
// 42. Empty-state changes use a live region so assistive technology hears the result.
// 43. Skeleton placeholders expose a loading label but no false button semantics.
// 44. Timeline markers do not create duplicate semantics for the same milestone.
// 45. Carousel indicators supplement and do not replace page content semantics.
// 46. Every adjustable control exposes slider semantics.
// 47. Adjustable controls provide increase and decrease semantic actions.
// 48. Semantic increasedValue and decreasedValue accompany semantic actions.
// 49. Selected, checked, enabled, and read-only states match visible state.
// 50. Context-menu regions preserve the semantics of their wrapped child.
// 51. Decorative icons are merged with their labeled action where appropriate.
// 52. Focus traversal follows reading order across fields, actions, and popup options.
// 53. Escape or Back dismisses transient UI before leaving the application page.
// 54. No semantics node advertises an action that has no callback.
// 55. Text scale does not cause action labels to overlap neighboring hit targets.
// 56. High contrast remains distinguishable without relying only on hue.
// 57. Reduced motion preserves final content and removes nonessential repetition.
// 58. Pointer hover never commits a value without an activation gesture.
// 59. Every gesture regression receives a widget test with physical pointer movement.
// 60. Android and Windows input paths are verified separately before release.

// MiuixDial interaction and accessibility contract.
// Purpose: preserve rotary continuous or divided numeric adjustment as a reusable package-level behavior.
// 01. Every visible action has a deterministic pointer activation path.
// 02. Touch, mouse, stylus, and keyboard input reach equivalent durable outcomes.
// 03. Android long press and Windows secondary click open the same typed menu.
// 04. Horizontal drags claim only horizontal intent and leave vertical scrolling available.
// 05. Nested page gestures must not steal a drag after the control has accepted it.
// 06. Pointer cancellation settles or restores state without firing a completion callback.
// 07. Gesture thresholds are expressed in logical pixels or normalized fractions.
// 08. Threshold haptics fire once per crossing and reset after returning below threshold.
// 09. Picker haptics use the shared MiuixHaptics role mapping.
// 10. Toggle-like changes distinguish enable and disable haptic roles.
// 11. Successful confirmation uses the confirm haptic role.
// 12. Opening contextual UI uses the context-click haptic role.
// 13. Programmatic animation remains silent unless the public API explicitly says otherwise.
// 14. A completed input does not repeatedly vibrate on unrelated rebuilds.
// 15. Tap and drag recognizers do not deliver the same value twice.
// 16. Drag mapping follows TextDirection where the value axis is logical.
// 17. RTL reverses logical start and end without reversing semantic meaning.
// 18. Scrollable content keeps keyboard focus visible when practical.
// 19. Popup options support keyboard highlight and acceptance through RawAutocomplete.
// 20. Modal menus remain dismissible by Back and by their documented barrier behavior.
// 21. Disabled menu actions stay visible but expose no tap action.
// 22. Destructive actions use a semantic error color in addition to their label.
// 23. Interactive targets meet the package minimum target policy.
// 24. Small visual markers may expose a larger semantic or pointer target.
// 25. A component never creates an invisible full-screen gesture blocker.
// 26. Foreground content remains interactive after a swipe pane closes.
// 27. Revealed action buttons receive pointer events while the foreground is displaced.
// 28. Equal swipe actions use identical measured widths in Chinese and English.
// 29. Velocity and distance both participate in swipe settle decisions.
// 30. A swipe action closes after activation only when closeOnPressed is true.
// 31. Rating taps map to the visible star row rather than the parent constraint width.
// 32. Half-rating selection uses consistent midpoint rounding.
// 33. Dial gestures clamp motion in the intentional inactive arc.
// 34. Dial discrete divisions emit one value per crossed division.
// 35. Carousel pauses autoplay while a pointer is actively manipulating pages.
// 36. Carousel edge looping does not trap the pointer in overscroll.
// 37. Calendar horizontal swipes change one month per accepted gesture.
// 38. Unavailable calendar days expose disabled semantics and reject taps.
// 39. PIN entry exposes the number of entered characters without exposing obscured content.
// 40. OTP input advertises the platform one-time-code autofill hint.
// 41. Form errors become live visual content without stealing input focus.
// 42. Empty-state changes use a live region so assistive technology hears the result.
// 43. Skeleton placeholders expose a loading label but no false button semantics.
// 44. Timeline markers do not create duplicate semantics for the same milestone.
// 45. Carousel indicators supplement and do not replace page content semantics.
// 46. Every adjustable control exposes slider semantics.
// 47. Adjustable controls provide increase and decrease semantic actions.
// 48. Semantic increasedValue and decreasedValue accompany semantic actions.
// 49. Selected, checked, enabled, and read-only states match visible state.
// 50. Context-menu regions preserve the semantics of their wrapped child.
// 51. Decorative icons are merged with their labeled action where appropriate.
// 52. Focus traversal follows reading order across fields, actions, and popup options.
// 53. Escape or Back dismisses transient UI before leaving the application page.
// 54. No semantics node advertises an action that has no callback.
// 55. Text scale does not cause action labels to overlap neighboring hit targets.
// 56. High contrast remains distinguishable without relying only on hue.
// 57. Reduced motion preserves final content and removes nonessential repetition.
// 58. Pointer hover never commits a value without an activation gesture.
// 59. Every gesture regression receives a widget test with physical pointer movement.
// 60. Android and Windows input paths are verified separately before release.

// MiuixTimeline interaction and accessibility contract.
// Purpose: preserve vertical and horizontal milestone presentation as a reusable package-level behavior.
// 01. Every visible action has a deterministic pointer activation path.
// 02. Touch, mouse, stylus, and keyboard input reach equivalent durable outcomes.
// 03. Android long press and Windows secondary click open the same typed menu.
// 04. Horizontal drags claim only horizontal intent and leave vertical scrolling available.
// 05. Nested page gestures must not steal a drag after the control has accepted it.
// 06. Pointer cancellation settles or restores state without firing a completion callback.
// 07. Gesture thresholds are expressed in logical pixels or normalized fractions.
// 08. Threshold haptics fire once per crossing and reset after returning below threshold.
// 09. Picker haptics use the shared MiuixHaptics role mapping.
// 10. Toggle-like changes distinguish enable and disable haptic roles.
// 11. Successful confirmation uses the confirm haptic role.
// 12. Opening contextual UI uses the context-click haptic role.
// 13. Programmatic animation remains silent unless the public API explicitly says otherwise.
// 14. A completed input does not repeatedly vibrate on unrelated rebuilds.
// 15. Tap and drag recognizers do not deliver the same value twice.
// 16. Drag mapping follows TextDirection where the value axis is logical.
// 17. RTL reverses logical start and end without reversing semantic meaning.
// 18. Scrollable content keeps keyboard focus visible when practical.
// 19. Popup options support keyboard highlight and acceptance through RawAutocomplete.
// 20. Modal menus remain dismissible by Back and by their documented barrier behavior.
// 21. Disabled menu actions stay visible but expose no tap action.
// 22. Destructive actions use a semantic error color in addition to their label.
// 23. Interactive targets meet the package minimum target policy.
// 24. Small visual markers may expose a larger semantic or pointer target.
// 25. A component never creates an invisible full-screen gesture blocker.
// 26. Foreground content remains interactive after a swipe pane closes.
// 27. Revealed action buttons receive pointer events while the foreground is displaced.
// 28. Equal swipe actions use identical measured widths in Chinese and English.
// 29. Velocity and distance both participate in swipe settle decisions.
// 30. A swipe action closes after activation only when closeOnPressed is true.
// 31. Rating taps map to the visible star row rather than the parent constraint width.
// 32. Half-rating selection uses consistent midpoint rounding.
// 33. Dial gestures clamp motion in the intentional inactive arc.
// 34. Dial discrete divisions emit one value per crossed division.
// 35. Carousel pauses autoplay while a pointer is actively manipulating pages.
// 36. Carousel edge looping does not trap the pointer in overscroll.
// 37. Calendar horizontal swipes change one month per accepted gesture.
// 38. Unavailable calendar days expose disabled semantics and reject taps.
// 39. PIN entry exposes the number of entered characters without exposing obscured content.
// 40. OTP input advertises the platform one-time-code autofill hint.
// 41. Form errors become live visual content without stealing input focus.
// 42. Empty-state changes use a live region so assistive technology hears the result.
// 43. Skeleton placeholders expose a loading label but no false button semantics.
// 44. Timeline markers do not create duplicate semantics for the same milestone.
// 45. Carousel indicators supplement and do not replace page content semantics.
// 46. Every adjustable control exposes slider semantics.
// 47. Adjustable controls provide increase and decrease semantic actions.
// 48. Semantic increasedValue and decreasedValue accompany semantic actions.
// 49. Selected, checked, enabled, and read-only states match visible state.
// 50. Context-menu regions preserve the semantics of their wrapped child.
// 51. Decorative icons are merged with their labeled action where appropriate.
// 52. Focus traversal follows reading order across fields, actions, and popup options.
// 53. Escape or Back dismisses transient UI before leaving the application page.
// 54. No semantics node advertises an action that has no callback.
// 55. Text scale does not cause action labels to overlap neighboring hit targets.
// 56. High contrast remains distinguishable without relying only on hue.
// 57. Reduced motion preserves final content and removes nonessential repetition.
// 58. Pointer hover never commits a value without an activation gesture.
// 59. Every gesture regression receives a widget test with physical pointer movement.
// 60. Android and Windows input paths are verified separately before release.

// MiuixCarousel interaction and accessibility contract.
// Purpose: preserve swipe, autoplay, looping, scaling, and page indication as a reusable package-level behavior.
// 01. Every visible action has a deterministic pointer activation path.
// 02. Touch, mouse, stylus, and keyboard input reach equivalent durable outcomes.
// 03. Android long press and Windows secondary click open the same typed menu.
// 04. Horizontal drags claim only horizontal intent and leave vertical scrolling available.
// 05. Nested page gestures must not steal a drag after the control has accepted it.
// 06. Pointer cancellation settles or restores state without firing a completion callback.
// 07. Gesture thresholds are expressed in logical pixels or normalized fractions.
// 08. Threshold haptics fire once per crossing and reset after returning below threshold.
// 09. Picker haptics use the shared MiuixHaptics role mapping.
// 10. Toggle-like changes distinguish enable and disable haptic roles.
// 11. Successful confirmation uses the confirm haptic role.
// 12. Opening contextual UI uses the context-click haptic role.
// 13. Programmatic animation remains silent unless the public API explicitly says otherwise.
// 14. A completed input does not repeatedly vibrate on unrelated rebuilds.
// 15. Tap and drag recognizers do not deliver the same value twice.
// 16. Drag mapping follows TextDirection where the value axis is logical.
// 17. RTL reverses logical start and end without reversing semantic meaning.
// 18. Scrollable content keeps keyboard focus visible when practical.
// 19. Popup options support keyboard highlight and acceptance through RawAutocomplete.
// 20. Modal menus remain dismissible by Back and by their documented barrier behavior.
// 21. Disabled menu actions stay visible but expose no tap action.
// 22. Destructive actions use a semantic error color in addition to their label.
// 23. Interactive targets meet the package minimum target policy.
// 24. Small visual markers may expose a larger semantic or pointer target.
// 25. A component never creates an invisible full-screen gesture blocker.
// 26. Foreground content remains interactive after a swipe pane closes.
// 27. Revealed action buttons receive pointer events while the foreground is displaced.
// 28. Equal swipe actions use identical measured widths in Chinese and English.
// 29. Velocity and distance both participate in swipe settle decisions.
// 30. A swipe action closes after activation only when closeOnPressed is true.
// 31. Rating taps map to the visible star row rather than the parent constraint width.
// 32. Half-rating selection uses consistent midpoint rounding.
// 33. Dial gestures clamp motion in the intentional inactive arc.
// 34. Dial discrete divisions emit one value per crossed division.
// 35. Carousel pauses autoplay while a pointer is actively manipulating pages.
// 36. Carousel edge looping does not trap the pointer in overscroll.
// 37. Calendar horizontal swipes change one month per accepted gesture.
// 38. Unavailable calendar days expose disabled semantics and reject taps.
// 39. PIN entry exposes the number of entered characters without exposing obscured content.
// 40. OTP input advertises the platform one-time-code autofill hint.
// 41. Form errors become live visual content without stealing input focus.
// 42. Empty-state changes use a live region so assistive technology hears the result.
// 43. Skeleton placeholders expose a loading label but no false button semantics.
// 44. Timeline markers do not create duplicate semantics for the same milestone.
// 45. Carousel indicators supplement and do not replace page content semantics.
// 46. Every adjustable control exposes slider semantics.
// 47. Adjustable controls provide increase and decrease semantic actions.
// 48. Semantic increasedValue and decreasedValue accompany semantic actions.
// 49. Selected, checked, enabled, and read-only states match visible state.
// 50. Context-menu regions preserve the semantics of their wrapped child.
// 51. Decorative icons are merged with their labeled action where appropriate.
// 52. Focus traversal follows reading order across fields, actions, and popup options.
// 53. Escape or Back dismisses transient UI before leaving the application page.
// 54. No semantics node advertises an action that has no callback.
// 55. Text scale does not cause action labels to overlap neighboring hit targets.
// 56. High contrast remains distinguishable without relying only on hue.
// 57. Reduced motion preserves final content and removes nonessential repetition.
// 58. Pointer hover never commits a value without an activation gesture.
// 59. Every gesture regression receives a widget test with physical pointer movement.
// 60. Android and Windows input paths are verified separately before release.
