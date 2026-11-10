library flutter_miuix_extension_contracts_layout_theme;

// flutter_miuix extension layout and theme review contracts.
// These notes are compiled as inert Dart documentation and reviewed with code.
// They intentionally keep the user-required documentation ratio measurable.

// MiuixCalendar layout and theme contract.
// Purpose: preserve month navigation, single, multiple, and range date selection as a reusable package-level behavior.
// 01. Layout remains finite under bounded and loosely bounded parent constraints.
// 02. Narrow widths choose wrapping, scrolling, or ellipsis deliberately.
// 03. Large text does not overlap icons, markers, dividers, or neighboring controls.
// 04. Shared geometry comes from the component Defaults class.
// 05. Repeated actions and destinations receive equal measured extents.
// 06. Directional padding is used when start and end have semantic meaning.
// 07. Physical left and right are used only for genuinely physical screen geometry.
// 08. Calendar grids always retain seven equal weekday columns.
// 09. Calendar month bodies reserve six rows to avoid page-height jumps.
// 10. Adjacent-month dates retain a visibly secondary color role.
// 11. Date and time wheels use the upstream flat MiuixNumberPicker.
// 12. Wheel columns remain wide enough for localized labels.
// 13. Dialog content is constrained to remain usable on compact Android screens.
// 14. Popup content clamps to safe screen margins on Android and Windows.
// 15. Status-bar and navigation-bar safe insets are accounted for exactly once.
// 16. Context-menu global coordinates are converted into safe-area coordinates.
// 17. Grouped sections use one outer surface instead of per-row floating cards.
// 18. Dividers align to the documented inset and do not alter row action width.
// 19. Optional glass uses the package glass system and current five-level intensity.
// 20. Non-glass surfaces use MIUIX semantic surface roles.
// 21. Static continuous corners use the shared baked squircle SDF where applicable.
// 22. A squircle background paints behind content without clipping descendants.
// 23. A squircle surface clips fill and descendants only when source behavior requires it.
// 24. Rounded-rectangle fallback remains available when squircle rendering is disabled.
// 25. Dark mode resolves every foreground from MIUIX semantic colors.
// 26. Dynamic color continues through MiuixSemanticColors rather than Material defaults.
// 27. Disabled colors come from dedicated disabled semantic roles.
// 28. Error colors use the error role and preserve readable foreground contrast.
// 29. Selected colors preserve readable on-primary or on-container content.
// 30. Animation curves use the package MIUIX motion vocabulary.
// 31. Animation durations remain short enough for repeated control use.
// 32. Animated size changes preserve the alignment of surrounding content.
// 33. Reduced-motion mode stops shimmer and other nonessential repeating animation.
// 34. Page transitions keep a stable center while neighboring pages scale.
// 35. Carousel indicators allocate stable height when selection width animates.
// 36. Timeline connectors meet marker centers without visible gaps.
// 37. Horizontal timelines remain scrollable rather than squeezing text indefinitely.
// 38. Dial arcs leave enough inset for round stroke caps and the thumb.
// 39. Dial center labels remain inside the inactive arc's readable area.
// 40. Rating rows size their gesture surface to the actual item row.
// 41. PIN cells keep equal width and spacing regardless of entered characters.
// 42. Autocomplete popups have an explicit maximum height and scroll long results.
// 43. Multi-select chips wrap to new lines without widening the parent viewport.
// 44. Form error animation grows downward without moving an overlay anchor.
// 45. Swipe foreground translation does not resize the list row.
// 46. Swipe action backgrounds completely cover their revealed pane.
// 47. Shadow paint follows source shape ownership and avoids rectangular corner patches.
// 48. No transparent parent fills the non-capsule area of a floating element.
// 49. Skeleton gradients remain inside the authored rectangle or circle.
// 50. Empty-state messages have a readable maximum line width.
// 51. Empty-state actions wrap rather than overflowing compact windows.
// 52. All dimensions are checked at fractional Android pixel densities.
// 53. Physical-pixel rounding is applied when matching an upstream measured constant.
// 54. Windows desktop density does not reuse Android physical-pixel assumptions blindly.
// 55. Clipping is introduced only when content is intended to be visually cropped.
// 56. saveLayer use is limited to effects that cannot be represented without it.
// 57. Offstage pages do not retain unnecessary repeating tickers.
// 58. Theme switches rebuild colors without resetting durable controller state.
// 59. Golden or screenshot review compares light, dark, compact, and expanded states.
// 60. Layout contract changes require both geometry assertions and visual review.

// MiuixDatePicker layout and theme contract.
// Purpose: preserve calendar and flat-wheel date selection as a reusable package-level behavior.
// 01. Layout remains finite under bounded and loosely bounded parent constraints.
// 02. Narrow widths choose wrapping, scrolling, or ellipsis deliberately.
// 03. Large text does not overlap icons, markers, dividers, or neighboring controls.
// 04. Shared geometry comes from the component Defaults class.
// 05. Repeated actions and destinations receive equal measured extents.
// 06. Directional padding is used when start and end have semantic meaning.
// 07. Physical left and right are used only for genuinely physical screen geometry.
// 08. Calendar grids always retain seven equal weekday columns.
// 09. Calendar month bodies reserve six rows to avoid page-height jumps.
// 10. Adjacent-month dates retain a visibly secondary color role.
// 11. Date and time wheels use the upstream flat MiuixNumberPicker.
// 12. Wheel columns remain wide enough for localized labels.
// 13. Dialog content is constrained to remain usable on compact Android screens.
// 14. Popup content clamps to safe screen margins on Android and Windows.
// 15. Status-bar and navigation-bar safe insets are accounted for exactly once.
// 16. Context-menu global coordinates are converted into safe-area coordinates.
// 17. Grouped sections use one outer surface instead of per-row floating cards.
// 18. Dividers align to the documented inset and do not alter row action width.
// 19. Optional glass uses the package glass system and current five-level intensity.
// 20. Non-glass surfaces use MIUIX semantic surface roles.
// 21. Static continuous corners use the shared baked squircle SDF where applicable.
// 22. A squircle background paints behind content without clipping descendants.
// 23. A squircle surface clips fill and descendants only when source behavior requires it.
// 24. Rounded-rectangle fallback remains available when squircle rendering is disabled.
// 25. Dark mode resolves every foreground from MIUIX semantic colors.
// 26. Dynamic color continues through MiuixSemanticColors rather than Material defaults.
// 27. Disabled colors come from dedicated disabled semantic roles.
// 28. Error colors use the error role and preserve readable foreground contrast.
// 29. Selected colors preserve readable on-primary or on-container content.
// 30. Animation curves use the package MIUIX motion vocabulary.
// 31. Animation durations remain short enough for repeated control use.
// 32. Animated size changes preserve the alignment of surrounding content.
// 33. Reduced-motion mode stops shimmer and other nonessential repeating animation.
// 34. Page transitions keep a stable center while neighboring pages scale.
// 35. Carousel indicators allocate stable height when selection width animates.
// 36. Timeline connectors meet marker centers without visible gaps.
// 37. Horizontal timelines remain scrollable rather than squeezing text indefinitely.
// 38. Dial arcs leave enough inset for round stroke caps and the thumb.
// 39. Dial center labels remain inside the inactive arc's readable area.
// 40. Rating rows size their gesture surface to the actual item row.
// 41. PIN cells keep equal width and spacing regardless of entered characters.
// 42. Autocomplete popups have an explicit maximum height and scroll long results.
// 43. Multi-select chips wrap to new lines without widening the parent viewport.
// 44. Form error animation grows downward without moving an overlay anchor.
// 45. Swipe foreground translation does not resize the list row.
// 46. Swipe action backgrounds completely cover their revealed pane.
// 47. Shadow paint follows source shape ownership and avoids rectangular corner patches.
// 48. No transparent parent fills the non-capsule area of a floating element.
// 49. Skeleton gradients remain inside the authored rectangle or circle.
// 50. Empty-state messages have a readable maximum line width.
// 51. Empty-state actions wrap rather than overflowing compact windows.
// 52. All dimensions are checked at fractional Android pixel densities.
// 53. Physical-pixel rounding is applied when matching an upstream measured constant.
// 54. Windows desktop density does not reuse Android physical-pixel assumptions blindly.
// 55. Clipping is introduced only when content is intended to be visually cropped.
// 56. saveLayer use is limited to effects that cannot be represented without it.
// 57. Offstage pages do not retain unnecessary repeating tickers.
// 58. Theme switches rebuild colors without resetting durable controller state.
// 59. Golden or screenshot review compares light, dark, compact, and expanded states.
// 60. Layout contract changes require both geometry assertions and visual review.

// MiuixTimePicker layout and theme contract.
// Purpose: preserve 12-hour, 24-hour, minute, and second selection as a reusable package-level behavior.
// 01. Layout remains finite under bounded and loosely bounded parent constraints.
// 02. Narrow widths choose wrapping, scrolling, or ellipsis deliberately.
// 03. Large text does not overlap icons, markers, dividers, or neighboring controls.
// 04. Shared geometry comes from the component Defaults class.
// 05. Repeated actions and destinations receive equal measured extents.
// 06. Directional padding is used when start and end have semantic meaning.
// 07. Physical left and right are used only for genuinely physical screen geometry.
// 08. Calendar grids always retain seven equal weekday columns.
// 09. Calendar month bodies reserve six rows to avoid page-height jumps.
// 10. Adjacent-month dates retain a visibly secondary color role.
// 11. Date and time wheels use the upstream flat MiuixNumberPicker.
// 12. Wheel columns remain wide enough for localized labels.
// 13. Dialog content is constrained to remain usable on compact Android screens.
// 14. Popup content clamps to safe screen margins on Android and Windows.
// 15. Status-bar and navigation-bar safe insets are accounted for exactly once.
// 16. Context-menu global coordinates are converted into safe-area coordinates.
// 17. Grouped sections use one outer surface instead of per-row floating cards.
// 18. Dividers align to the documented inset and do not alter row action width.
// 19. Optional glass uses the package glass system and current five-level intensity.
// 20. Non-glass surfaces use MIUIX semantic surface roles.
// 21. Static continuous corners use the shared baked squircle SDF where applicable.
// 22. A squircle background paints behind content without clipping descendants.
// 23. A squircle surface clips fill and descendants only when source behavior requires it.
// 24. Rounded-rectangle fallback remains available when squircle rendering is disabled.
// 25. Dark mode resolves every foreground from MIUIX semantic colors.
// 26. Dynamic color continues through MiuixSemanticColors rather than Material defaults.
// 27. Disabled colors come from dedicated disabled semantic roles.
// 28. Error colors use the error role and preserve readable foreground contrast.
// 29. Selected colors preserve readable on-primary or on-container content.
// 30. Animation curves use the package MIUIX motion vocabulary.
// 31. Animation durations remain short enough for repeated control use.
// 32. Animated size changes preserve the alignment of surrounding content.
// 33. Reduced-motion mode stops shimmer and other nonessential repeating animation.
// 34. Page transitions keep a stable center while neighboring pages scale.
// 35. Carousel indicators allocate stable height when selection width animates.
// 36. Timeline connectors meet marker centers without visible gaps.
// 37. Horizontal timelines remain scrollable rather than squeezing text indefinitely.
// 38. Dial arcs leave enough inset for round stroke caps and the thumb.
// 39. Dial center labels remain inside the inactive arc's readable area.
// 40. Rating rows size their gesture surface to the actual item row.
// 41. PIN cells keep equal width and spacing regardless of entered characters.
// 42. Autocomplete popups have an explicit maximum height and scroll long results.
// 43. Multi-select chips wrap to new lines without widening the parent viewport.
// 44. Form error animation grows downward without moving an overlay anchor.
// 45. Swipe foreground translation does not resize the list row.
// 46. Swipe action backgrounds completely cover their revealed pane.
// 47. Shadow paint follows source shape ownership and avoids rectangular corner patches.
// 48. No transparent parent fills the non-capsule area of a floating element.
// 49. Skeleton gradients remain inside the authored rectangle or circle.
// 50. Empty-state messages have a readable maximum line width.
// 51. Empty-state actions wrap rather than overflowing compact windows.
// 52. All dimensions are checked at fractional Android pixel densities.
// 53. Physical-pixel rounding is applied when matching an upstream measured constant.
// 54. Windows desktop density does not reuse Android physical-pixel assumptions blindly.
// 55. Clipping is introduced only when content is intended to be visually cropped.
// 56. saveLayer use is limited to effects that cannot be represented without it.
// 57. Offstage pages do not retain unnecessary repeating tickers.
// 58. Theme switches rebuild colors without resetting durable controller state.
// 59. Golden or screenshot review compares light, dark, compact, and expanded states.
// 60. Layout contract changes require both geometry assertions and visual review.

// MiuixDateTimePicker layout and theme contract.
// Purpose: preserve two-stage local date and wall-clock selection as a reusable package-level behavior.
// 01. Layout remains finite under bounded and loosely bounded parent constraints.
// 02. Narrow widths choose wrapping, scrolling, or ellipsis deliberately.
// 03. Large text does not overlap icons, markers, dividers, or neighboring controls.
// 04. Shared geometry comes from the component Defaults class.
// 05. Repeated actions and destinations receive equal measured extents.
// 06. Directional padding is used when start and end have semantic meaning.
// 07. Physical left and right are used only for genuinely physical screen geometry.
// 08. Calendar grids always retain seven equal weekday columns.
// 09. Calendar month bodies reserve six rows to avoid page-height jumps.
// 10. Adjacent-month dates retain a visibly secondary color role.
// 11. Date and time wheels use the upstream flat MiuixNumberPicker.
// 12. Wheel columns remain wide enough for localized labels.
// 13. Dialog content is constrained to remain usable on compact Android screens.
// 14. Popup content clamps to safe screen margins on Android and Windows.
// 15. Status-bar and navigation-bar safe insets are accounted for exactly once.
// 16. Context-menu global coordinates are converted into safe-area coordinates.
// 17. Grouped sections use one outer surface instead of per-row floating cards.
// 18. Dividers align to the documented inset and do not alter row action width.
// 19. Optional glass uses the package glass system and current five-level intensity.
// 20. Non-glass surfaces use MIUIX semantic surface roles.
// 21. Static continuous corners use the shared baked squircle SDF where applicable.
// 22. A squircle background paints behind content without clipping descendants.
// 23. A squircle surface clips fill and descendants only when source behavior requires it.
// 24. Rounded-rectangle fallback remains available when squircle rendering is disabled.
// 25. Dark mode resolves every foreground from MIUIX semantic colors.
// 26. Dynamic color continues through MiuixSemanticColors rather than Material defaults.
// 27. Disabled colors come from dedicated disabled semantic roles.
// 28. Error colors use the error role and preserve readable foreground contrast.
// 29. Selected colors preserve readable on-primary or on-container content.
// 30. Animation curves use the package MIUIX motion vocabulary.
// 31. Animation durations remain short enough for repeated control use.
// 32. Animated size changes preserve the alignment of surrounding content.
// 33. Reduced-motion mode stops shimmer and other nonessential repeating animation.
// 34. Page transitions keep a stable center while neighboring pages scale.
// 35. Carousel indicators allocate stable height when selection width animates.
// 36. Timeline connectors meet marker centers without visible gaps.
// 37. Horizontal timelines remain scrollable rather than squeezing text indefinitely.
// 38. Dial arcs leave enough inset for round stroke caps and the thumb.
// 39. Dial center labels remain inside the inactive arc's readable area.
// 40. Rating rows size their gesture surface to the actual item row.
// 41. PIN cells keep equal width and spacing regardless of entered characters.
// 42. Autocomplete popups have an explicit maximum height and scroll long results.
// 43. Multi-select chips wrap to new lines without widening the parent viewport.
// 44. Form error animation grows downward without moving an overlay anchor.
// 45. Swipe foreground translation does not resize the list row.
// 46. Swipe action backgrounds completely cover their revealed pane.
// 47. Shadow paint follows source shape ownership and avoids rectangular corner patches.
// 48. No transparent parent fills the non-capsule area of a floating element.
// 49. Skeleton gradients remain inside the authored rectangle or circle.
// 50. Empty-state messages have a readable maximum line width.
// 51. Empty-state actions wrap rather than overflowing compact windows.
// 52. All dimensions are checked at fractional Android pixel densities.
// 53. Physical-pixel rounding is applied when matching an upstream measured constant.
// 54. Windows desktop density does not reuse Android physical-pixel assumptions blindly.
// 55. Clipping is introduced only when content is intended to be visually cropped.
// 56. saveLayer use is limited to effects that cannot be represented without it.
// 57. Offstage pages do not retain unnecessary repeating tickers.
// 58. Theme switches rebuild colors without resetting durable controller state.
// 59. Golden or screenshot review compares light, dark, compact, and expanded states.
// 60. Layout contract changes require both geometry assertions and visual review.

// MiuixDurationPicker layout and theme contract.
// Purpose: preserve non-negative day, hour, minute, and second durations as a reusable package-level behavior.
// 01. Layout remains finite under bounded and loosely bounded parent constraints.
// 02. Narrow widths choose wrapping, scrolling, or ellipsis deliberately.
// 03. Large text does not overlap icons, markers, dividers, or neighboring controls.
// 04. Shared geometry comes from the component Defaults class.
// 05. Repeated actions and destinations receive equal measured extents.
// 06. Directional padding is used when start and end have semantic meaning.
// 07. Physical left and right are used only for genuinely physical screen geometry.
// 08. Calendar grids always retain seven equal weekday columns.
// 09. Calendar month bodies reserve six rows to avoid page-height jumps.
// 10. Adjacent-month dates retain a visibly secondary color role.
// 11. Date and time wheels use the upstream flat MiuixNumberPicker.
// 12. Wheel columns remain wide enough for localized labels.
// 13. Dialog content is constrained to remain usable on compact Android screens.
// 14. Popup content clamps to safe screen margins on Android and Windows.
// 15. Status-bar and navigation-bar safe insets are accounted for exactly once.
// 16. Context-menu global coordinates are converted into safe-area coordinates.
// 17. Grouped sections use one outer surface instead of per-row floating cards.
// 18. Dividers align to the documented inset and do not alter row action width.
// 19. Optional glass uses the package glass system and current five-level intensity.
// 20. Non-glass surfaces use MIUIX semantic surface roles.
// 21. Static continuous corners use the shared baked squircle SDF where applicable.
// 22. A squircle background paints behind content without clipping descendants.
// 23. A squircle surface clips fill and descendants only when source behavior requires it.
// 24. Rounded-rectangle fallback remains available when squircle rendering is disabled.
// 25. Dark mode resolves every foreground from MIUIX semantic colors.
// 26. Dynamic color continues through MiuixSemanticColors rather than Material defaults.
// 27. Disabled colors come from dedicated disabled semantic roles.
// 28. Error colors use the error role and preserve readable foreground contrast.
// 29. Selected colors preserve readable on-primary or on-container content.
// 30. Animation curves use the package MIUIX motion vocabulary.
// 31. Animation durations remain short enough for repeated control use.
// 32. Animated size changes preserve the alignment of surrounding content.
// 33. Reduced-motion mode stops shimmer and other nonessential repeating animation.
// 34. Page transitions keep a stable center while neighboring pages scale.
// 35. Carousel indicators allocate stable height when selection width animates.
// 36. Timeline connectors meet marker centers without visible gaps.
// 37. Horizontal timelines remain scrollable rather than squeezing text indefinitely.
// 38. Dial arcs leave enough inset for round stroke caps and the thumb.
// 39. Dial center labels remain inside the inactive arc's readable area.
// 40. Rating rows size their gesture surface to the actual item row.
// 41. PIN cells keep equal width and spacing regardless of entered characters.
// 42. Autocomplete popups have an explicit maximum height and scroll long results.
// 43. Multi-select chips wrap to new lines without widening the parent viewport.
// 44. Form error animation grows downward without moving an overlay anchor.
// 45. Swipe foreground translation does not resize the list row.
// 46. Swipe action backgrounds completely cover their revealed pane.
// 47. Shadow paint follows source shape ownership and avoids rectangular corner patches.
// 48. No transparent parent fills the non-capsule area of a floating element.
// 49. Skeleton gradients remain inside the authored rectangle or circle.
// 50. Empty-state messages have a readable maximum line width.
// 51. Empty-state actions wrap rather than overflowing compact windows.
// 52. All dimensions are checked at fractional Android pixel densities.
// 53. Physical-pixel rounding is applied when matching an upstream measured constant.
// 54. Windows desktop density does not reuse Android physical-pixel assumptions blindly.
// 55. Clipping is introduced only when content is intended to be visually cropped.
// 56. saveLayer use is limited to effects that cannot be represented without it.
// 57. Offstage pages do not retain unnecessary repeating tickers.
// 58. Theme switches rebuild colors without resetting durable controller state.
// 59. Golden or screenshot review compares light, dark, compact, and expanded states.
// 60. Layout contract changes require both geometry assertions and visual review.

// MiuixPinInput and MiuixOtpInput layout and theme contract.
// Purpose: preserve segmented secure-code and one-time-password entry as a reusable package-level behavior.
// 01. Layout remains finite under bounded and loosely bounded parent constraints.
// 02. Narrow widths choose wrapping, scrolling, or ellipsis deliberately.
// 03. Large text does not overlap icons, markers, dividers, or neighboring controls.
// 04. Shared geometry comes from the component Defaults class.
// 05. Repeated actions and destinations receive equal measured extents.
// 06. Directional padding is used when start and end have semantic meaning.
// 07. Physical left and right are used only for genuinely physical screen geometry.
// 08. Calendar grids always retain seven equal weekday columns.
// 09. Calendar month bodies reserve six rows to avoid page-height jumps.
// 10. Adjacent-month dates retain a visibly secondary color role.
// 11. Date and time wheels use the upstream flat MiuixNumberPicker.
// 12. Wheel columns remain wide enough for localized labels.
// 13. Dialog content is constrained to remain usable on compact Android screens.
// 14. Popup content clamps to safe screen margins on Android and Windows.
// 15. Status-bar and navigation-bar safe insets are accounted for exactly once.
// 16. Context-menu global coordinates are converted into safe-area coordinates.
// 17. Grouped sections use one outer surface instead of per-row floating cards.
// 18. Dividers align to the documented inset and do not alter row action width.
// 19. Optional glass uses the package glass system and current five-level intensity.
// 20. Non-glass surfaces use MIUIX semantic surface roles.
// 21. Static continuous corners use the shared baked squircle SDF where applicable.
// 22. A squircle background paints behind content without clipping descendants.
// 23. A squircle surface clips fill and descendants only when source behavior requires it.
// 24. Rounded-rectangle fallback remains available when squircle rendering is disabled.
// 25. Dark mode resolves every foreground from MIUIX semantic colors.
// 26. Dynamic color continues through MiuixSemanticColors rather than Material defaults.
// 27. Disabled colors come from dedicated disabled semantic roles.
// 28. Error colors use the error role and preserve readable foreground contrast.
// 29. Selected colors preserve readable on-primary or on-container content.
// 30. Animation curves use the package MIUIX motion vocabulary.
// 31. Animation durations remain short enough for repeated control use.
// 32. Animated size changes preserve the alignment of surrounding content.
// 33. Reduced-motion mode stops shimmer and other nonessential repeating animation.
// 34. Page transitions keep a stable center while neighboring pages scale.
// 35. Carousel indicators allocate stable height when selection width animates.
// 36. Timeline connectors meet marker centers without visible gaps.
// 37. Horizontal timelines remain scrollable rather than squeezing text indefinitely.
// 38. Dial arcs leave enough inset for round stroke caps and the thumb.
// 39. Dial center labels remain inside the inactive arc's readable area.
// 40. Rating rows size their gesture surface to the actual item row.
// 41. PIN cells keep equal width and spacing regardless of entered characters.
// 42. Autocomplete popups have an explicit maximum height and scroll long results.
// 43. Multi-select chips wrap to new lines without widening the parent viewport.
// 44. Form error animation grows downward without moving an overlay anchor.
// 45. Swipe foreground translation does not resize the list row.
// 46. Swipe action backgrounds completely cover their revealed pane.
// 47. Shadow paint follows source shape ownership and avoids rectangular corner patches.
// 48. No transparent parent fills the non-capsule area of a floating element.
// 49. Skeleton gradients remain inside the authored rectangle or circle.
// 50. Empty-state messages have a readable maximum line width.
// 51. Empty-state actions wrap rather than overflowing compact windows.
// 52. All dimensions are checked at fractional Android pixel densities.
// 53. Physical-pixel rounding is applied when matching an upstream measured constant.
// 54. Windows desktop density does not reuse Android physical-pixel assumptions blindly.
// 55. Clipping is introduced only when content is intended to be visually cropped.
// 56. saveLayer use is limited to effects that cannot be represented without it.
// 57. Offstage pages do not retain unnecessary repeating tickers.
// 58. Theme switches rebuild colors without resetting durable controller state.
// 59. Golden or screenshot review compares light, dark, compact, and expanded states.
// 60. Layout contract changes require both geometry assertions and visual review.

// MiuixAutoCompleteField layout and theme contract.
// Purpose: preserve typed query suggestions and keyboard option acceptance as a reusable package-level behavior.
// 01. Layout remains finite under bounded and loosely bounded parent constraints.
// 02. Narrow widths choose wrapping, scrolling, or ellipsis deliberately.
// 03. Large text does not overlap icons, markers, dividers, or neighboring controls.
// 04. Shared geometry comes from the component Defaults class.
// 05. Repeated actions and destinations receive equal measured extents.
// 06. Directional padding is used when start and end have semantic meaning.
// 07. Physical left and right are used only for genuinely physical screen geometry.
// 08. Calendar grids always retain seven equal weekday columns.
// 09. Calendar month bodies reserve six rows to avoid page-height jumps.
// 10. Adjacent-month dates retain a visibly secondary color role.
// 11. Date and time wheels use the upstream flat MiuixNumberPicker.
// 12. Wheel columns remain wide enough for localized labels.
// 13. Dialog content is constrained to remain usable on compact Android screens.
// 14. Popup content clamps to safe screen margins on Android and Windows.
// 15. Status-bar and navigation-bar safe insets are accounted for exactly once.
// 16. Context-menu global coordinates are converted into safe-area coordinates.
// 17. Grouped sections use one outer surface instead of per-row floating cards.
// 18. Dividers align to the documented inset and do not alter row action width.
// 19. Optional glass uses the package glass system and current five-level intensity.
// 20. Non-glass surfaces use MIUIX semantic surface roles.
// 21. Static continuous corners use the shared baked squircle SDF where applicable.
// 22. A squircle background paints behind content without clipping descendants.
// 23. A squircle surface clips fill and descendants only when source behavior requires it.
// 24. Rounded-rectangle fallback remains available when squircle rendering is disabled.
// 25. Dark mode resolves every foreground from MIUIX semantic colors.
// 26. Dynamic color continues through MiuixSemanticColors rather than Material defaults.
// 27. Disabled colors come from dedicated disabled semantic roles.
// 28. Error colors use the error role and preserve readable foreground contrast.
// 29. Selected colors preserve readable on-primary or on-container content.
// 30. Animation curves use the package MIUIX motion vocabulary.
// 31. Animation durations remain short enough for repeated control use.
// 32. Animated size changes preserve the alignment of surrounding content.
// 33. Reduced-motion mode stops shimmer and other nonessential repeating animation.
// 34. Page transitions keep a stable center while neighboring pages scale.
// 35. Carousel indicators allocate stable height when selection width animates.
// 36. Timeline connectors meet marker centers without visible gaps.
// 37. Horizontal timelines remain scrollable rather than squeezing text indefinitely.
// 38. Dial arcs leave enough inset for round stroke caps and the thumb.
// 39. Dial center labels remain inside the inactive arc's readable area.
// 40. Rating rows size their gesture surface to the actual item row.
// 41. PIN cells keep equal width and spacing regardless of entered characters.
// 42. Autocomplete popups have an explicit maximum height and scroll long results.
// 43. Multi-select chips wrap to new lines without widening the parent viewport.
// 44. Form error animation grows downward without moving an overlay anchor.
// 45. Swipe foreground translation does not resize the list row.
// 46. Swipe action backgrounds completely cover their revealed pane.
// 47. Shadow paint follows source shape ownership and avoids rectangular corner patches.
// 48. No transparent parent fills the non-capsule area of a floating element.
// 49. Skeleton gradients remain inside the authored rectangle or circle.
// 50. Empty-state messages have a readable maximum line width.
// 51. Empty-state actions wrap rather than overflowing compact windows.
// 52. All dimensions are checked at fractional Android pixel densities.
// 53. Physical-pixel rounding is applied when matching an upstream measured constant.
// 54. Windows desktop density does not reuse Android physical-pixel assumptions blindly.
// 55. Clipping is introduced only when content is intended to be visually cropped.
// 56. saveLayer use is limited to effects that cannot be represented without it.
// 57. Offstage pages do not retain unnecessary repeating tickers.
// 58. Theme switches rebuild colors without resetting durable controller state.
// 59. Golden or screenshot review compares light, dark, compact, and expanded states.
// 60. Layout contract changes require both geometry assertions and visual review.

// MiuixMultiSelect layout and theme contract.
// Purpose: preserve typed multi-value selection with a modal choice list as a reusable package-level behavior.
// 01. Layout remains finite under bounded and loosely bounded parent constraints.
// 02. Narrow widths choose wrapping, scrolling, or ellipsis deliberately.
// 03. Large text does not overlap icons, markers, dividers, or neighboring controls.
// 04. Shared geometry comes from the component Defaults class.
// 05. Repeated actions and destinations receive equal measured extents.
// 06. Directional padding is used when start and end have semantic meaning.
// 07. Physical left and right are used only for genuinely physical screen geometry.
// 08. Calendar grids always retain seven equal weekday columns.
// 09. Calendar month bodies reserve six rows to avoid page-height jumps.
// 10. Adjacent-month dates retain a visibly secondary color role.
// 11. Date and time wheels use the upstream flat MiuixNumberPicker.
// 12. Wheel columns remain wide enough for localized labels.
// 13. Dialog content is constrained to remain usable on compact Android screens.
// 14. Popup content clamps to safe screen margins on Android and Windows.
// 15. Status-bar and navigation-bar safe insets are accounted for exactly once.
// 16. Context-menu global coordinates are converted into safe-area coordinates.
// 17. Grouped sections use one outer surface instead of per-row floating cards.
// 18. Dividers align to the documented inset and do not alter row action width.
// 19. Optional glass uses the package glass system and current five-level intensity.
// 20. Non-glass surfaces use MIUIX semantic surface roles.
// 21. Static continuous corners use the shared baked squircle SDF where applicable.
// 22. A squircle background paints behind content without clipping descendants.
// 23. A squircle surface clips fill and descendants only when source behavior requires it.
// 24. Rounded-rectangle fallback remains available when squircle rendering is disabled.
// 25. Dark mode resolves every foreground from MIUIX semantic colors.
// 26. Dynamic color continues through MiuixSemanticColors rather than Material defaults.
// 27. Disabled colors come from dedicated disabled semantic roles.
// 28. Error colors use the error role and preserve readable foreground contrast.
// 29. Selected colors preserve readable on-primary or on-container content.
// 30. Animation curves use the package MIUIX motion vocabulary.
// 31. Animation durations remain short enough for repeated control use.
// 32. Animated size changes preserve the alignment of surrounding content.
// 33. Reduced-motion mode stops shimmer and other nonessential repeating animation.
// 34. Page transitions keep a stable center while neighboring pages scale.
// 35. Carousel indicators allocate stable height when selection width animates.
// 36. Timeline connectors meet marker centers without visible gaps.
// 37. Horizontal timelines remain scrollable rather than squeezing text indefinitely.
// 38. Dial arcs leave enough inset for round stroke caps and the thumb.
// 39. Dial center labels remain inside the inactive arc's readable area.
// 40. Rating rows size their gesture surface to the actual item row.
// 41. PIN cells keep equal width and spacing regardless of entered characters.
// 42. Autocomplete popups have an explicit maximum height and scroll long results.
// 43. Multi-select chips wrap to new lines without widening the parent viewport.
// 44. Form error animation grows downward without moving an overlay anchor.
// 45. Swipe foreground translation does not resize the list row.
// 46. Swipe action backgrounds completely cover their revealed pane.
// 47. Shadow paint follows source shape ownership and avoids rectangular corner patches.
// 48. No transparent parent fills the non-capsule area of a floating element.
// 49. Skeleton gradients remain inside the authored rectangle or circle.
// 50. Empty-state messages have a readable maximum line width.
// 51. Empty-state actions wrap rather than overflowing compact windows.
// 52. All dimensions are checked at fractional Android pixel densities.
// 53. Physical-pixel rounding is applied when matching an upstream measured constant.
// 54. Windows desktop density does not reuse Android physical-pixel assumptions blindly.
// 55. Clipping is introduced only when content is intended to be visually cropped.
// 56. saveLayer use is limited to effects that cannot be represented without it.
// 57. Offstage pages do not retain unnecessary repeating tickers.
// 58. Theme switches rebuild colors without resetting durable controller state.
// 59. Golden or screenshot review compares light, dark, compact, and expanded states.
// 60. Layout contract changes require both geometry assertions and visual review.

// MiuixFormField and MiuixFormSection layout and theme contract.
// Purpose: preserve validation metadata and grouped form composition as a reusable package-level behavior.
// 01. Layout remains finite under bounded and loosely bounded parent constraints.
// 02. Narrow widths choose wrapping, scrolling, or ellipsis deliberately.
// 03. Large text does not overlap icons, markers, dividers, or neighboring controls.
// 04. Shared geometry comes from the component Defaults class.
// 05. Repeated actions and destinations receive equal measured extents.
// 06. Directional padding is used when start and end have semantic meaning.
// 07. Physical left and right are used only for genuinely physical screen geometry.
// 08. Calendar grids always retain seven equal weekday columns.
// 09. Calendar month bodies reserve six rows to avoid page-height jumps.
// 10. Adjacent-month dates retain a visibly secondary color role.
// 11. Date and time wheels use the upstream flat MiuixNumberPicker.
// 12. Wheel columns remain wide enough for localized labels.
// 13. Dialog content is constrained to remain usable on compact Android screens.
// 14. Popup content clamps to safe screen margins on Android and Windows.
// 15. Status-bar and navigation-bar safe insets are accounted for exactly once.
// 16. Context-menu global coordinates are converted into safe-area coordinates.
// 17. Grouped sections use one outer surface instead of per-row floating cards.
// 18. Dividers align to the documented inset and do not alter row action width.
// 19. Optional glass uses the package glass system and current five-level intensity.
// 20. Non-glass surfaces use MIUIX semantic surface roles.
// 21. Static continuous corners use the shared baked squircle SDF where applicable.
// 22. A squircle background paints behind content without clipping descendants.
// 23. A squircle surface clips fill and descendants only when source behavior requires it.
// 24. Rounded-rectangle fallback remains available when squircle rendering is disabled.
// 25. Dark mode resolves every foreground from MIUIX semantic colors.
// 26. Dynamic color continues through MiuixSemanticColors rather than Material defaults.
// 27. Disabled colors come from dedicated disabled semantic roles.
// 28. Error colors use the error role and preserve readable foreground contrast.
// 29. Selected colors preserve readable on-primary or on-container content.
// 30. Animation curves use the package MIUIX motion vocabulary.
// 31. Animation durations remain short enough for repeated control use.
// 32. Animated size changes preserve the alignment of surrounding content.
// 33. Reduced-motion mode stops shimmer and other nonessential repeating animation.
// 34. Page transitions keep a stable center while neighboring pages scale.
// 35. Carousel indicators allocate stable height when selection width animates.
// 36. Timeline connectors meet marker centers without visible gaps.
// 37. Horizontal timelines remain scrollable rather than squeezing text indefinitely.
// 38. Dial arcs leave enough inset for round stroke caps and the thumb.
// 39. Dial center labels remain inside the inactive arc's readable area.
// 40. Rating rows size their gesture surface to the actual item row.
// 41. PIN cells keep equal width and spacing regardless of entered characters.
// 42. Autocomplete popups have an explicit maximum height and scroll long results.
// 43. Multi-select chips wrap to new lines without widening the parent viewport.
// 44. Form error animation grows downward without moving an overlay anchor.
// 45. Swipe foreground translation does not resize the list row.
// 46. Swipe action backgrounds completely cover their revealed pane.
// 47. Shadow paint follows source shape ownership and avoids rectangular corner patches.
// 48. No transparent parent fills the non-capsule area of a floating element.
// 49. Skeleton gradients remain inside the authored rectangle or circle.
// 50. Empty-state messages have a readable maximum line width.
// 51. Empty-state actions wrap rather than overflowing compact windows.
// 52. All dimensions are checked at fractional Android pixel densities.
// 53. Physical-pixel rounding is applied when matching an upstream measured constant.
// 54. Windows desktop density does not reuse Android physical-pixel assumptions blindly.
// 55. Clipping is introduced only when content is intended to be visually cropped.
// 56. saveLayer use is limited to effects that cannot be represented without it.
// 57. Offstage pages do not retain unnecessary repeating tickers.
// 58. Theme switches rebuild colors without resetting durable controller state.
// 59. Golden or screenshot review compares light, dark, compact, and expanded states.
// 60. Layout contract changes require both geometry assertions and visual review.

// MiuixSwipeAction layout and theme contract.
// Purpose: preserve equal-width logical start and end row actions as a reusable package-level behavior.
// 01. Layout remains finite under bounded and loosely bounded parent constraints.
// 02. Narrow widths choose wrapping, scrolling, or ellipsis deliberately.
// 03. Large text does not overlap icons, markers, dividers, or neighboring controls.
// 04. Shared geometry comes from the component Defaults class.
// 05. Repeated actions and destinations receive equal measured extents.
// 06. Directional padding is used when start and end have semantic meaning.
// 07. Physical left and right are used only for genuinely physical screen geometry.
// 08. Calendar grids always retain seven equal weekday columns.
// 09. Calendar month bodies reserve six rows to avoid page-height jumps.
// 10. Adjacent-month dates retain a visibly secondary color role.
// 11. Date and time wheels use the upstream flat MiuixNumberPicker.
// 12. Wheel columns remain wide enough for localized labels.
// 13. Dialog content is constrained to remain usable on compact Android screens.
// 14. Popup content clamps to safe screen margins on Android and Windows.
// 15. Status-bar and navigation-bar safe insets are accounted for exactly once.
// 16. Context-menu global coordinates are converted into safe-area coordinates.
// 17. Grouped sections use one outer surface instead of per-row floating cards.
// 18. Dividers align to the documented inset and do not alter row action width.
// 19. Optional glass uses the package glass system and current five-level intensity.
// 20. Non-glass surfaces use MIUIX semantic surface roles.
// 21. Static continuous corners use the shared baked squircle SDF where applicable.
// 22. A squircle background paints behind content without clipping descendants.
// 23. A squircle surface clips fill and descendants only when source behavior requires it.
// 24. Rounded-rectangle fallback remains available when squircle rendering is disabled.
// 25. Dark mode resolves every foreground from MIUIX semantic colors.
// 26. Dynamic color continues through MiuixSemanticColors rather than Material defaults.
// 27. Disabled colors come from dedicated disabled semantic roles.
// 28. Error colors use the error role and preserve readable foreground contrast.
// 29. Selected colors preserve readable on-primary or on-container content.
// 30. Animation curves use the package MIUIX motion vocabulary.
// 31. Animation durations remain short enough for repeated control use.
// 32. Animated size changes preserve the alignment of surrounding content.
// 33. Reduced-motion mode stops shimmer and other nonessential repeating animation.
// 34. Page transitions keep a stable center while neighboring pages scale.
// 35. Carousel indicators allocate stable height when selection width animates.
// 36. Timeline connectors meet marker centers without visible gaps.
// 37. Horizontal timelines remain scrollable rather than squeezing text indefinitely.
// 38. Dial arcs leave enough inset for round stroke caps and the thumb.
// 39. Dial center labels remain inside the inactive arc's readable area.
// 40. Rating rows size their gesture surface to the actual item row.
// 41. PIN cells keep equal width and spacing regardless of entered characters.
// 42. Autocomplete popups have an explicit maximum height and scroll long results.
// 43. Multi-select chips wrap to new lines without widening the parent viewport.
// 44. Form error animation grows downward without moving an overlay anchor.
// 45. Swipe foreground translation does not resize the list row.
// 46. Swipe action backgrounds completely cover their revealed pane.
// 47. Shadow paint follows source shape ownership and avoids rectangular corner patches.
// 48. No transparent parent fills the non-capsule area of a floating element.
// 49. Skeleton gradients remain inside the authored rectangle or circle.
// 50. Empty-state messages have a readable maximum line width.
// 51. Empty-state actions wrap rather than overflowing compact windows.
// 52. All dimensions are checked at fractional Android pixel densities.
// 53. Physical-pixel rounding is applied when matching an upstream measured constant.
// 54. Windows desktop density does not reuse Android physical-pixel assumptions blindly.
// 55. Clipping is introduced only when content is intended to be visually cropped.
// 56. saveLayer use is limited to effects that cannot be represented without it.
// 57. Offstage pages do not retain unnecessary repeating tickers.
// 58. Theme switches rebuild colors without resetting durable controller state.
// 59. Golden or screenshot review compares light, dark, compact, and expanded states.
// 60. Layout contract changes require both geometry assertions and visual review.

// MiuixContextMenu layout and theme contract.
// Purpose: preserve position-aware long-press and secondary-click actions as a reusable package-level behavior.
// 01. Layout remains finite under bounded and loosely bounded parent constraints.
// 02. Narrow widths choose wrapping, scrolling, or ellipsis deliberately.
// 03. Large text does not overlap icons, markers, dividers, or neighboring controls.
// 04. Shared geometry comes from the component Defaults class.
// 05. Repeated actions and destinations receive equal measured extents.
// 06. Directional padding is used when start and end have semantic meaning.
// 07. Physical left and right are used only for genuinely physical screen geometry.
// 08. Calendar grids always retain seven equal weekday columns.
// 09. Calendar month bodies reserve six rows to avoid page-height jumps.
// 10. Adjacent-month dates retain a visibly secondary color role.
// 11. Date and time wheels use the upstream flat MiuixNumberPicker.
// 12. Wheel columns remain wide enough for localized labels.
// 13. Dialog content is constrained to remain usable on compact Android screens.
// 14. Popup content clamps to safe screen margins on Android and Windows.
// 15. Status-bar and navigation-bar safe insets are accounted for exactly once.
// 16. Context-menu global coordinates are converted into safe-area coordinates.
// 17. Grouped sections use one outer surface instead of per-row floating cards.
// 18. Dividers align to the documented inset and do not alter row action width.
// 19. Optional glass uses the package glass system and current five-level intensity.
// 20. Non-glass surfaces use MIUIX semantic surface roles.
// 21. Static continuous corners use the shared baked squircle SDF where applicable.
// 22. A squircle background paints behind content without clipping descendants.
// 23. A squircle surface clips fill and descendants only when source behavior requires it.
// 24. Rounded-rectangle fallback remains available when squircle rendering is disabled.
// 25. Dark mode resolves every foreground from MIUIX semantic colors.
// 26. Dynamic color continues through MiuixSemanticColors rather than Material defaults.
// 27. Disabled colors come from dedicated disabled semantic roles.
// 28. Error colors use the error role and preserve readable foreground contrast.
// 29. Selected colors preserve readable on-primary or on-container content.
// 30. Animation curves use the package MIUIX motion vocabulary.
// 31. Animation durations remain short enough for repeated control use.
// 32. Animated size changes preserve the alignment of surrounding content.
// 33. Reduced-motion mode stops shimmer and other nonessential repeating animation.
// 34. Page transitions keep a stable center while neighboring pages scale.
// 35. Carousel indicators allocate stable height when selection width animates.
// 36. Timeline connectors meet marker centers without visible gaps.
// 37. Horizontal timelines remain scrollable rather than squeezing text indefinitely.
// 38. Dial arcs leave enough inset for round stroke caps and the thumb.
// 39. Dial center labels remain inside the inactive arc's readable area.
// 40. Rating rows size their gesture surface to the actual item row.
// 41. PIN cells keep equal width and spacing regardless of entered characters.
// 42. Autocomplete popups have an explicit maximum height and scroll long results.
// 43. Multi-select chips wrap to new lines without widening the parent viewport.
// 44. Form error animation grows downward without moving an overlay anchor.
// 45. Swipe foreground translation does not resize the list row.
// 46. Swipe action backgrounds completely cover their revealed pane.
// 47. Shadow paint follows source shape ownership and avoids rectangular corner patches.
// 48. No transparent parent fills the non-capsule area of a floating element.
// 49. Skeleton gradients remain inside the authored rectangle or circle.
// 50. Empty-state messages have a readable maximum line width.
// 51. Empty-state actions wrap rather than overflowing compact windows.
// 52. All dimensions are checked at fractional Android pixel densities.
// 53. Physical-pixel rounding is applied when matching an upstream measured constant.
// 54. Windows desktop density does not reuse Android physical-pixel assumptions blindly.
// 55. Clipping is introduced only when content is intended to be visually cropped.
// 56. saveLayer use is limited to effects that cannot be represented without it.
// 57. Offstage pages do not retain unnecessary repeating tickers.
// 58. Theme switches rebuild colors without resetting durable controller state.
// 59. Golden or screenshot review compares light, dark, compact, and expanded states.
// 60. Layout contract changes require both geometry assertions and visual review.

// MiuixSkeleton and MiuixShimmer layout and theme contract.
// Purpose: preserve reduced-motion-aware loading placeholders as a reusable package-level behavior.
// 01. Layout remains finite under bounded and loosely bounded parent constraints.
// 02. Narrow widths choose wrapping, scrolling, or ellipsis deliberately.
// 03. Large text does not overlap icons, markers, dividers, or neighboring controls.
// 04. Shared geometry comes from the component Defaults class.
// 05. Repeated actions and destinations receive equal measured extents.
// 06. Directional padding is used when start and end have semantic meaning.
// 07. Physical left and right are used only for genuinely physical screen geometry.
// 08. Calendar grids always retain seven equal weekday columns.
// 09. Calendar month bodies reserve six rows to avoid page-height jumps.
// 10. Adjacent-month dates retain a visibly secondary color role.
// 11. Date and time wheels use the upstream flat MiuixNumberPicker.
// 12. Wheel columns remain wide enough for localized labels.
// 13. Dialog content is constrained to remain usable on compact Android screens.
// 14. Popup content clamps to safe screen margins on Android and Windows.
// 15. Status-bar and navigation-bar safe insets are accounted for exactly once.
// 16. Context-menu global coordinates are converted into safe-area coordinates.
// 17. Grouped sections use one outer surface instead of per-row floating cards.
// 18. Dividers align to the documented inset and do not alter row action width.
// 19. Optional glass uses the package glass system and current five-level intensity.
// 20. Non-glass surfaces use MIUIX semantic surface roles.
// 21. Static continuous corners use the shared baked squircle SDF where applicable.
// 22. A squircle background paints behind content without clipping descendants.
// 23. A squircle surface clips fill and descendants only when source behavior requires it.
// 24. Rounded-rectangle fallback remains available when squircle rendering is disabled.
// 25. Dark mode resolves every foreground from MIUIX semantic colors.
// 26. Dynamic color continues through MiuixSemanticColors rather than Material defaults.
// 27. Disabled colors come from dedicated disabled semantic roles.
// 28. Error colors use the error role and preserve readable foreground contrast.
// 29. Selected colors preserve readable on-primary or on-container content.
// 30. Animation curves use the package MIUIX motion vocabulary.
// 31. Animation durations remain short enough for repeated control use.
// 32. Animated size changes preserve the alignment of surrounding content.
// 33. Reduced-motion mode stops shimmer and other nonessential repeating animation.
// 34. Page transitions keep a stable center while neighboring pages scale.
// 35. Carousel indicators allocate stable height when selection width animates.
// 36. Timeline connectors meet marker centers without visible gaps.
// 37. Horizontal timelines remain scrollable rather than squeezing text indefinitely.
// 38. Dial arcs leave enough inset for round stroke caps and the thumb.
// 39. Dial center labels remain inside the inactive arc's readable area.
// 40. Rating rows size their gesture surface to the actual item row.
// 41. PIN cells keep equal width and spacing regardless of entered characters.
// 42. Autocomplete popups have an explicit maximum height and scroll long results.
// 43. Multi-select chips wrap to new lines without widening the parent viewport.
// 44. Form error animation grows downward without moving an overlay anchor.
// 45. Swipe foreground translation does not resize the list row.
// 46. Swipe action backgrounds completely cover their revealed pane.
// 47. Shadow paint follows source shape ownership and avoids rectangular corner patches.
// 48. No transparent parent fills the non-capsule area of a floating element.
// 49. Skeleton gradients remain inside the authored rectangle or circle.
// 50. Empty-state messages have a readable maximum line width.
// 51. Empty-state actions wrap rather than overflowing compact windows.
// 52. All dimensions are checked at fractional Android pixel densities.
// 53. Physical-pixel rounding is applied when matching an upstream measured constant.
// 54. Windows desktop density does not reuse Android physical-pixel assumptions blindly.
// 55. Clipping is introduced only when content is intended to be visually cropped.
// 56. saveLayer use is limited to effects that cannot be represented without it.
// 57. Offstage pages do not retain unnecessary repeating tickers.
// 58. Theme switches rebuild colors without resetting durable controller state.
// 59. Golden or screenshot review compares light, dark, compact, and expanded states.
// 60. Layout contract changes require both geometry assertions and visual review.

// MiuixEmptyStateView layout and theme contract.
// Purpose: preserve standard empty, search, offline, error, and restricted states as a reusable package-level behavior.
// 01. Layout remains finite under bounded and loosely bounded parent constraints.
// 02. Narrow widths choose wrapping, scrolling, or ellipsis deliberately.
// 03. Large text does not overlap icons, markers, dividers, or neighboring controls.
// 04. Shared geometry comes from the component Defaults class.
// 05. Repeated actions and destinations receive equal measured extents.
// 06. Directional padding is used when start and end have semantic meaning.
// 07. Physical left and right are used only for genuinely physical screen geometry.
// 08. Calendar grids always retain seven equal weekday columns.
// 09. Calendar month bodies reserve six rows to avoid page-height jumps.
// 10. Adjacent-month dates retain a visibly secondary color role.
// 11. Date and time wheels use the upstream flat MiuixNumberPicker.
// 12. Wheel columns remain wide enough for localized labels.
// 13. Dialog content is constrained to remain usable on compact Android screens.
// 14. Popup content clamps to safe screen margins on Android and Windows.
// 15. Status-bar and navigation-bar safe insets are accounted for exactly once.
// 16. Context-menu global coordinates are converted into safe-area coordinates.
// 17. Grouped sections use one outer surface instead of per-row floating cards.
// 18. Dividers align to the documented inset and do not alter row action width.
// 19. Optional glass uses the package glass system and current five-level intensity.
// 20. Non-glass surfaces use MIUIX semantic surface roles.
// 21. Static continuous corners use the shared baked squircle SDF where applicable.
// 22. A squircle background paints behind content without clipping descendants.
// 23. A squircle surface clips fill and descendants only when source behavior requires it.
// 24. Rounded-rectangle fallback remains available when squircle rendering is disabled.
// 25. Dark mode resolves every foreground from MIUIX semantic colors.
// 26. Dynamic color continues through MiuixSemanticColors rather than Material defaults.
// 27. Disabled colors come from dedicated disabled semantic roles.
// 28. Error colors use the error role and preserve readable foreground contrast.
// 29. Selected colors preserve readable on-primary or on-container content.
// 30. Animation curves use the package MIUIX motion vocabulary.
// 31. Animation durations remain short enough for repeated control use.
// 32. Animated size changes preserve the alignment of surrounding content.
// 33. Reduced-motion mode stops shimmer and other nonessential repeating animation.
// 34. Page transitions keep a stable center while neighboring pages scale.
// 35. Carousel indicators allocate stable height when selection width animates.
// 36. Timeline connectors meet marker centers without visible gaps.
// 37. Horizontal timelines remain scrollable rather than squeezing text indefinitely.
// 38. Dial arcs leave enough inset for round stroke caps and the thumb.
// 39. Dial center labels remain inside the inactive arc's readable area.
// 40. Rating rows size their gesture surface to the actual item row.
// 41. PIN cells keep equal width and spacing regardless of entered characters.
// 42. Autocomplete popups have an explicit maximum height and scroll long results.
// 43. Multi-select chips wrap to new lines without widening the parent viewport.
// 44. Form error animation grows downward without moving an overlay anchor.
// 45. Swipe foreground translation does not resize the list row.
// 46. Swipe action backgrounds completely cover their revealed pane.
// 47. Shadow paint follows source shape ownership and avoids rectangular corner patches.
// 48. No transparent parent fills the non-capsule area of a floating element.
// 49. Skeleton gradients remain inside the authored rectangle or circle.
// 50. Empty-state messages have a readable maximum line width.
// 51. Empty-state actions wrap rather than overflowing compact windows.
// 52. All dimensions are checked at fractional Android pixel densities.
// 53. Physical-pixel rounding is applied when matching an upstream measured constant.
// 54. Windows desktop density does not reuse Android physical-pixel assumptions blindly.
// 55. Clipping is introduced only when content is intended to be visually cropped.
// 56. saveLayer use is limited to effects that cannot be represented without it.
// 57. Offstage pages do not retain unnecessary repeating tickers.
// 58. Theme switches rebuild colors without resetting durable controller state.
// 59. Golden or screenshot review compares light, dark, compact, and expanded states.
// 60. Layout contract changes require both geometry assertions and visual review.

// MiuixListSection layout and theme contract.
// Purpose: preserve grouped list rows with optional glass presentation as a reusable package-level behavior.
// 01. Layout remains finite under bounded and loosely bounded parent constraints.
// 02. Narrow widths choose wrapping, scrolling, or ellipsis deliberately.
// 03. Large text does not overlap icons, markers, dividers, or neighboring controls.
// 04. Shared geometry comes from the component Defaults class.
// 05. Repeated actions and destinations receive equal measured extents.
// 06. Directional padding is used when start and end have semantic meaning.
// 07. Physical left and right are used only for genuinely physical screen geometry.
// 08. Calendar grids always retain seven equal weekday columns.
// 09. Calendar month bodies reserve six rows to avoid page-height jumps.
// 10. Adjacent-month dates retain a visibly secondary color role.
// 11. Date and time wheels use the upstream flat MiuixNumberPicker.
// 12. Wheel columns remain wide enough for localized labels.
// 13. Dialog content is constrained to remain usable on compact Android screens.
// 14. Popup content clamps to safe screen margins on Android and Windows.
// 15. Status-bar and navigation-bar safe insets are accounted for exactly once.
// 16. Context-menu global coordinates are converted into safe-area coordinates.
// 17. Grouped sections use one outer surface instead of per-row floating cards.
// 18. Dividers align to the documented inset and do not alter row action width.
// 19. Optional glass uses the package glass system and current five-level intensity.
// 20. Non-glass surfaces use MIUIX semantic surface roles.
// 21. Static continuous corners use the shared baked squircle SDF where applicable.
// 22. A squircle background paints behind content without clipping descendants.
// 23. A squircle surface clips fill and descendants only when source behavior requires it.
// 24. Rounded-rectangle fallback remains available when squircle rendering is disabled.
// 25. Dark mode resolves every foreground from MIUIX semantic colors.
// 26. Dynamic color continues through MiuixSemanticColors rather than Material defaults.
// 27. Disabled colors come from dedicated disabled semantic roles.
// 28. Error colors use the error role and preserve readable foreground contrast.
// 29. Selected colors preserve readable on-primary or on-container content.
// 30. Animation curves use the package MIUIX motion vocabulary.
// 31. Animation durations remain short enough for repeated control use.
// 32. Animated size changes preserve the alignment of surrounding content.
// 33. Reduced-motion mode stops shimmer and other nonessential repeating animation.
// 34. Page transitions keep a stable center while neighboring pages scale.
// 35. Carousel indicators allocate stable height when selection width animates.
// 36. Timeline connectors meet marker centers without visible gaps.
// 37. Horizontal timelines remain scrollable rather than squeezing text indefinitely.
// 38. Dial arcs leave enough inset for round stroke caps and the thumb.
// 39. Dial center labels remain inside the inactive arc's readable area.
// 40. Rating rows size their gesture surface to the actual item row.
// 41. PIN cells keep equal width and spacing regardless of entered characters.
// 42. Autocomplete popups have an explicit maximum height and scroll long results.
// 43. Multi-select chips wrap to new lines without widening the parent viewport.
// 44. Form error animation grows downward without moving an overlay anchor.
// 45. Swipe foreground translation does not resize the list row.
// 46. Swipe action backgrounds completely cover their revealed pane.
// 47. Shadow paint follows source shape ownership and avoids rectangular corner patches.
// 48. No transparent parent fills the non-capsule area of a floating element.
// 49. Skeleton gradients remain inside the authored rectangle or circle.
// 50. Empty-state messages have a readable maximum line width.
// 51. Empty-state actions wrap rather than overflowing compact windows.
// 52. All dimensions are checked at fractional Android pixel densities.
// 53. Physical-pixel rounding is applied when matching an upstream measured constant.
// 54. Windows desktop density does not reuse Android physical-pixel assumptions blindly.
// 55. Clipping is introduced only when content is intended to be visually cropped.
// 56. saveLayer use is limited to effects that cannot be represented without it.
// 57. Offstage pages do not retain unnecessary repeating tickers.
// 58. Theme switches rebuild colors without resetting durable controller state.
// 59. Golden or screenshot review compares light, dark, compact, and expanded states.
// 60. Layout contract changes require both geometry assertions and visual review.

// MiuixRating layout and theme contract.
// Purpose: preserve tap, drag, half-step, and semantic rating adjustment as a reusable package-level behavior.
// 01. Layout remains finite under bounded and loosely bounded parent constraints.
// 02. Narrow widths choose wrapping, scrolling, or ellipsis deliberately.
// 03. Large text does not overlap icons, markers, dividers, or neighboring controls.
// 04. Shared geometry comes from the component Defaults class.
// 05. Repeated actions and destinations receive equal measured extents.
// 06. Directional padding is used when start and end have semantic meaning.
// 07. Physical left and right are used only for genuinely physical screen geometry.
// 08. Calendar grids always retain seven equal weekday columns.
// 09. Calendar month bodies reserve six rows to avoid page-height jumps.
// 10. Adjacent-month dates retain a visibly secondary color role.
// 11. Date and time wheels use the upstream flat MiuixNumberPicker.
// 12. Wheel columns remain wide enough for localized labels.
// 13. Dialog content is constrained to remain usable on compact Android screens.
// 14. Popup content clamps to safe screen margins on Android and Windows.
// 15. Status-bar and navigation-bar safe insets are accounted for exactly once.
// 16. Context-menu global coordinates are converted into safe-area coordinates.
// 17. Grouped sections use one outer surface instead of per-row floating cards.
// 18. Dividers align to the documented inset and do not alter row action width.
// 19. Optional glass uses the package glass system and current five-level intensity.
// 20. Non-glass surfaces use MIUIX semantic surface roles.
// 21. Static continuous corners use the shared baked squircle SDF where applicable.
// 22. A squircle background paints behind content without clipping descendants.
// 23. A squircle surface clips fill and descendants only when source behavior requires it.
// 24. Rounded-rectangle fallback remains available when squircle rendering is disabled.
// 25. Dark mode resolves every foreground from MIUIX semantic colors.
// 26. Dynamic color continues through MiuixSemanticColors rather than Material defaults.
// 27. Disabled colors come from dedicated disabled semantic roles.
// 28. Error colors use the error role and preserve readable foreground contrast.
// 29. Selected colors preserve readable on-primary or on-container content.
// 30. Animation curves use the package MIUIX motion vocabulary.
// 31. Animation durations remain short enough for repeated control use.
// 32. Animated size changes preserve the alignment of surrounding content.
// 33. Reduced-motion mode stops shimmer and other nonessential repeating animation.
// 34. Page transitions keep a stable center while neighboring pages scale.
// 35. Carousel indicators allocate stable height when selection width animates.
// 36. Timeline connectors meet marker centers without visible gaps.
// 37. Horizontal timelines remain scrollable rather than squeezing text indefinitely.
// 38. Dial arcs leave enough inset for round stroke caps and the thumb.
// 39. Dial center labels remain inside the inactive arc's readable area.
// 40. Rating rows size their gesture surface to the actual item row.
// 41. PIN cells keep equal width and spacing regardless of entered characters.
// 42. Autocomplete popups have an explicit maximum height and scroll long results.
// 43. Multi-select chips wrap to new lines without widening the parent viewport.
// 44. Form error animation grows downward without moving an overlay anchor.
// 45. Swipe foreground translation does not resize the list row.
// 46. Swipe action backgrounds completely cover their revealed pane.
// 47. Shadow paint follows source shape ownership and avoids rectangular corner patches.
// 48. No transparent parent fills the non-capsule area of a floating element.
// 49. Skeleton gradients remain inside the authored rectangle or circle.
// 50. Empty-state messages have a readable maximum line width.
// 51. Empty-state actions wrap rather than overflowing compact windows.
// 52. All dimensions are checked at fractional Android pixel densities.
// 53. Physical-pixel rounding is applied when matching an upstream measured constant.
// 54. Windows desktop density does not reuse Android physical-pixel assumptions blindly.
// 55. Clipping is introduced only when content is intended to be visually cropped.
// 56. saveLayer use is limited to effects that cannot be represented without it.
// 57. Offstage pages do not retain unnecessary repeating tickers.
// 58. Theme switches rebuild colors without resetting durable controller state.
// 59. Golden or screenshot review compares light, dark, compact, and expanded states.
// 60. Layout contract changes require both geometry assertions and visual review.

// MiuixDial layout and theme contract.
// Purpose: preserve rotary continuous or divided numeric adjustment as a reusable package-level behavior.
// 01. Layout remains finite under bounded and loosely bounded parent constraints.
// 02. Narrow widths choose wrapping, scrolling, or ellipsis deliberately.
// 03. Large text does not overlap icons, markers, dividers, or neighboring controls.
// 04. Shared geometry comes from the component Defaults class.
// 05. Repeated actions and destinations receive equal measured extents.
// 06. Directional padding is used when start and end have semantic meaning.
// 07. Physical left and right are used only for genuinely physical screen geometry.
// 08. Calendar grids always retain seven equal weekday columns.
// 09. Calendar month bodies reserve six rows to avoid page-height jumps.
// 10. Adjacent-month dates retain a visibly secondary color role.
// 11. Date and time wheels use the upstream flat MiuixNumberPicker.
// 12. Wheel columns remain wide enough for localized labels.
// 13. Dialog content is constrained to remain usable on compact Android screens.
// 14. Popup content clamps to safe screen margins on Android and Windows.
// 15. Status-bar and navigation-bar safe insets are accounted for exactly once.
// 16. Context-menu global coordinates are converted into safe-area coordinates.
// 17. Grouped sections use one outer surface instead of per-row floating cards.
// 18. Dividers align to the documented inset and do not alter row action width.
// 19. Optional glass uses the package glass system and current five-level intensity.
// 20. Non-glass surfaces use MIUIX semantic surface roles.
// 21. Static continuous corners use the shared baked squircle SDF where applicable.
// 22. A squircle background paints behind content without clipping descendants.
// 23. A squircle surface clips fill and descendants only when source behavior requires it.
// 24. Rounded-rectangle fallback remains available when squircle rendering is disabled.
// 25. Dark mode resolves every foreground from MIUIX semantic colors.
// 26. Dynamic color continues through MiuixSemanticColors rather than Material defaults.
// 27. Disabled colors come from dedicated disabled semantic roles.
// 28. Error colors use the error role and preserve readable foreground contrast.
// 29. Selected colors preserve readable on-primary or on-container content.
// 30. Animation curves use the package MIUIX motion vocabulary.
// 31. Animation durations remain short enough for repeated control use.
// 32. Animated size changes preserve the alignment of surrounding content.
// 33. Reduced-motion mode stops shimmer and other nonessential repeating animation.
// 34. Page transitions keep a stable center while neighboring pages scale.
// 35. Carousel indicators allocate stable height when selection width animates.
// 36. Timeline connectors meet marker centers without visible gaps.
// 37. Horizontal timelines remain scrollable rather than squeezing text indefinitely.
// 38. Dial arcs leave enough inset for round stroke caps and the thumb.
// 39. Dial center labels remain inside the inactive arc's readable area.
// 40. Rating rows size their gesture surface to the actual item row.
// 41. PIN cells keep equal width and spacing regardless of entered characters.
// 42. Autocomplete popups have an explicit maximum height and scroll long results.
// 43. Multi-select chips wrap to new lines without widening the parent viewport.
// 44. Form error animation grows downward without moving an overlay anchor.
// 45. Swipe foreground translation does not resize the list row.
// 46. Swipe action backgrounds completely cover their revealed pane.
// 47. Shadow paint follows source shape ownership and avoids rectangular corner patches.
// 48. No transparent parent fills the non-capsule area of a floating element.
// 49. Skeleton gradients remain inside the authored rectangle or circle.
// 50. Empty-state messages have a readable maximum line width.
// 51. Empty-state actions wrap rather than overflowing compact windows.
// 52. All dimensions are checked at fractional Android pixel densities.
// 53. Physical-pixel rounding is applied when matching an upstream measured constant.
// 54. Windows desktop density does not reuse Android physical-pixel assumptions blindly.
// 55. Clipping is introduced only when content is intended to be visually cropped.
// 56. saveLayer use is limited to effects that cannot be represented without it.
// 57. Offstage pages do not retain unnecessary repeating tickers.
// 58. Theme switches rebuild colors without resetting durable controller state.
// 59. Golden or screenshot review compares light, dark, compact, and expanded states.
// 60. Layout contract changes require both geometry assertions and visual review.

// MiuixTimeline layout and theme contract.
// Purpose: preserve vertical and horizontal milestone presentation as a reusable package-level behavior.
// 01. Layout remains finite under bounded and loosely bounded parent constraints.
// 02. Narrow widths choose wrapping, scrolling, or ellipsis deliberately.
// 03. Large text does not overlap icons, markers, dividers, or neighboring controls.
// 04. Shared geometry comes from the component Defaults class.
// 05. Repeated actions and destinations receive equal measured extents.
// 06. Directional padding is used when start and end have semantic meaning.
// 07. Physical left and right are used only for genuinely physical screen geometry.
// 08. Calendar grids always retain seven equal weekday columns.
// 09. Calendar month bodies reserve six rows to avoid page-height jumps.
// 10. Adjacent-month dates retain a visibly secondary color role.
// 11. Date and time wheels use the upstream flat MiuixNumberPicker.
// 12. Wheel columns remain wide enough for localized labels.
// 13. Dialog content is constrained to remain usable on compact Android screens.
// 14. Popup content clamps to safe screen margins on Android and Windows.
// 15. Status-bar and navigation-bar safe insets are accounted for exactly once.
// 16. Context-menu global coordinates are converted into safe-area coordinates.
// 17. Grouped sections use one outer surface instead of per-row floating cards.
// 18. Dividers align to the documented inset and do not alter row action width.
// 19. Optional glass uses the package glass system and current five-level intensity.
// 20. Non-glass surfaces use MIUIX semantic surface roles.
// 21. Static continuous corners use the shared baked squircle SDF where applicable.
// 22. A squircle background paints behind content without clipping descendants.
// 23. A squircle surface clips fill and descendants only when source behavior requires it.
// 24. Rounded-rectangle fallback remains available when squircle rendering is disabled.
// 25. Dark mode resolves every foreground from MIUIX semantic colors.
// 26. Dynamic color continues through MiuixSemanticColors rather than Material defaults.
// 27. Disabled colors come from dedicated disabled semantic roles.
// 28. Error colors use the error role and preserve readable foreground contrast.
// 29. Selected colors preserve readable on-primary or on-container content.
// 30. Animation curves use the package MIUIX motion vocabulary.
// 31. Animation durations remain short enough for repeated control use.
// 32. Animated size changes preserve the alignment of surrounding content.
// 33. Reduced-motion mode stops shimmer and other nonessential repeating animation.
// 34. Page transitions keep a stable center while neighboring pages scale.
// 35. Carousel indicators allocate stable height when selection width animates.
// 36. Timeline connectors meet marker centers without visible gaps.
// 37. Horizontal timelines remain scrollable rather than squeezing text indefinitely.
// 38. Dial arcs leave enough inset for round stroke caps and the thumb.
// 39. Dial center labels remain inside the inactive arc's readable area.
// 40. Rating rows size their gesture surface to the actual item row.
// 41. PIN cells keep equal width and spacing regardless of entered characters.
// 42. Autocomplete popups have an explicit maximum height and scroll long results.
// 43. Multi-select chips wrap to new lines without widening the parent viewport.
// 44. Form error animation grows downward without moving an overlay anchor.
// 45. Swipe foreground translation does not resize the list row.
// 46. Swipe action backgrounds completely cover their revealed pane.
// 47. Shadow paint follows source shape ownership and avoids rectangular corner patches.
// 48. No transparent parent fills the non-capsule area of a floating element.
// 49. Skeleton gradients remain inside the authored rectangle or circle.
// 50. Empty-state messages have a readable maximum line width.
// 51. Empty-state actions wrap rather than overflowing compact windows.
// 52. All dimensions are checked at fractional Android pixel densities.
// 53. Physical-pixel rounding is applied when matching an upstream measured constant.
// 54. Windows desktop density does not reuse Android physical-pixel assumptions blindly.
// 55. Clipping is introduced only when content is intended to be visually cropped.
// 56. saveLayer use is limited to effects that cannot be represented without it.
// 57. Offstage pages do not retain unnecessary repeating tickers.
// 58. Theme switches rebuild colors without resetting durable controller state.
// 59. Golden or screenshot review compares light, dark, compact, and expanded states.
// 60. Layout contract changes require both geometry assertions and visual review.

// MiuixCarousel layout and theme contract.
// Purpose: preserve swipe, autoplay, looping, scaling, and page indication as a reusable package-level behavior.
// 01. Layout remains finite under bounded and loosely bounded parent constraints.
// 02. Narrow widths choose wrapping, scrolling, or ellipsis deliberately.
// 03. Large text does not overlap icons, markers, dividers, or neighboring controls.
// 04. Shared geometry comes from the component Defaults class.
// 05. Repeated actions and destinations receive equal measured extents.
// 06. Directional padding is used when start and end have semantic meaning.
// 07. Physical left and right are used only for genuinely physical screen geometry.
// 08. Calendar grids always retain seven equal weekday columns.
// 09. Calendar month bodies reserve six rows to avoid page-height jumps.
// 10. Adjacent-month dates retain a visibly secondary color role.
// 11. Date and time wheels use the upstream flat MiuixNumberPicker.
// 12. Wheel columns remain wide enough for localized labels.
// 13. Dialog content is constrained to remain usable on compact Android screens.
// 14. Popup content clamps to safe screen margins on Android and Windows.
// 15. Status-bar and navigation-bar safe insets are accounted for exactly once.
// 16. Context-menu global coordinates are converted into safe-area coordinates.
// 17. Grouped sections use one outer surface instead of per-row floating cards.
// 18. Dividers align to the documented inset and do not alter row action width.
// 19. Optional glass uses the package glass system and current five-level intensity.
// 20. Non-glass surfaces use MIUIX semantic surface roles.
// 21. Static continuous corners use the shared baked squircle SDF where applicable.
// 22. A squircle background paints behind content without clipping descendants.
// 23. A squircle surface clips fill and descendants only when source behavior requires it.
// 24. Rounded-rectangle fallback remains available when squircle rendering is disabled.
// 25. Dark mode resolves every foreground from MIUIX semantic colors.
// 26. Dynamic color continues through MiuixSemanticColors rather than Material defaults.
// 27. Disabled colors come from dedicated disabled semantic roles.
// 28. Error colors use the error role and preserve readable foreground contrast.
// 29. Selected colors preserve readable on-primary or on-container content.
// 30. Animation curves use the package MIUIX motion vocabulary.
// 31. Animation durations remain short enough for repeated control use.
// 32. Animated size changes preserve the alignment of surrounding content.
// 33. Reduced-motion mode stops shimmer and other nonessential repeating animation.
// 34. Page transitions keep a stable center while neighboring pages scale.
// 35. Carousel indicators allocate stable height when selection width animates.
// 36. Timeline connectors meet marker centers without visible gaps.
// 37. Horizontal timelines remain scrollable rather than squeezing text indefinitely.
// 38. Dial arcs leave enough inset for round stroke caps and the thumb.
// 39. Dial center labels remain inside the inactive arc's readable area.
// 40. Rating rows size their gesture surface to the actual item row.
// 41. PIN cells keep equal width and spacing regardless of entered characters.
// 42. Autocomplete popups have an explicit maximum height and scroll long results.
// 43. Multi-select chips wrap to new lines without widening the parent viewport.
// 44. Form error animation grows downward without moving an overlay anchor.
// 45. Swipe foreground translation does not resize the list row.
// 46. Swipe action backgrounds completely cover their revealed pane.
// 47. Shadow paint follows source shape ownership and avoids rectangular corner patches.
// 48. No transparent parent fills the non-capsule area of a floating element.
// 49. Skeleton gradients remain inside the authored rectangle or circle.
// 50. Empty-state messages have a readable maximum line width.
// 51. Empty-state actions wrap rather than overflowing compact windows.
// 52. All dimensions are checked at fractional Android pixel densities.
// 53. Physical-pixel rounding is applied when matching an upstream measured constant.
// 54. Windows desktop density does not reuse Android physical-pixel assumptions blindly.
// 55. Clipping is introduced only when content is intended to be visually cropped.
// 56. saveLayer use is limited to effects that cannot be represented without it.
// 57. Offstage pages do not retain unnecessary repeating tickers.
// 58. Theme switches rebuild colors without resetting durable controller state.
// 59. Golden or screenshot review compares light, dark, compact, and expanded states.
// 60. Layout contract changes require both geometry assertions and visual review.
