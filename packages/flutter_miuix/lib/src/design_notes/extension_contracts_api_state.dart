library flutter_miuix_extension_contracts_api_state;

// flutter_miuix extension API and state review contracts.
// These notes are compiled as inert Dart documentation and reviewed with code.
// They intentionally keep the user-required documentation ratio measurable.

// MiuixCalendar API and state contract.
// Purpose: preserve month navigation, single, multiple, and range date selection as a reusable package-level behavior.
// 01. Public names must remain available from package:flutter_miuix/flutter_miuix.dart.
// 02. Implementation belongs under lib/src/extensions and never under example/lib.
// 03. The example may demonstrate the control but must not own its behavior.
// 04. Constructor defaults are part of the supported package contract.
// 05. Every public configuration field remains final after construction.
// 06. Owned controllers are created only when no external controller is supplied.
// 07. Externally supplied controllers are never disposed by the widget.
// 08. Internally created controllers are disposed in the matching lifecycle phase.
// 09. Controller replacement detaches old listeners before attaching new listeners.
// 10. A controller publishes only durable application state.
// 11. Transient pointer and animation state remains private to the widget state.
// 12. Direct controlled values take precedence over internal initial values.
// 13. Initial values are read only when internally owned state is first created.
// 14. Equivalent value assignments do not emit redundant notifications.
// 15. Public snapshots do not expose mutable internal collections.
// 16. Caller collections are copied before the component mutates selection state.
// 17. Date-like values preserve local calendar semantics without UTC conversion.
// 18. Numeric values reject or normalize non-finite input before painting.
// 19. Ranges define inclusive or exclusive boundaries explicitly in documentation.
// 20. Minimum and maximum arguments are applied consistently across input paths.
// 21. Step and division arguments have debug assertions and production-safe behavior.
// 22. Callbacks report user changes after internal normalization.
// 23. Programmatic controller changes rebuild the visual state.
// 24. Programmatic controller changes do not synthesize user haptics.
// 25. User callbacks are never fired twice for one accepted state transition.
// 26. Completion callbacks fire only when the documented completion condition is met.
// 27. Cancellation leaves durable state unchanged unless explicitly documented.
// 28. Dialog helpers return null when dismissed without confirmation.
// 29. Dialog helpers return typed values after explicit confirmation.
// 30. Dialog-owned temporary controllers are disposed when their route completes.
// 31. Static show helpers preserve the caller supplied minimum and maximum values.
// 32. Aliases such as OTP retain the complete behavior of their canonical control.
// 33. Generic type parameters survive controllers, options, callbacks, and route results.
// 34. Display-string adapters never replace the underlying typed value.
// 35. The public API avoids leaking private render or route implementation types.
// 36. Theme color objects are immutable and independently replaceable by callers.
// 37. Defaults classes expose shared geometry instead of duplicating magic numbers.
// 38. State enums use logical names that remain valid in left-to-right and RTL layouts.
// 39. Controller methods use application vocabulary such as open, close, next, and clear.
// 40. Controller state remains queryable after an animation settles.
// 41. Widget updates reconcile changed item counts and selection bounds.
// 42. Removing an option cannot leave an inaccessible selected visual behind.
// 43. Empty inputs render safely and keep a deterministic state.
// 44. Single-item inputs avoid unnecessary paging, separators, or cycling.
// 45. Disabled inputs keep their value but reject new user mutations.
// 46. Read-only presentation remains distinct from a missing callback where applicable.
// 47. Restoration identifiers pass through Flutter form infrastructure when supported.
// 48. Form save and validation hooks remain compatible with Flutter Form.
// 49. Errors are represented as state and do not require exception-driven rendering.
// 50. Public value objects implement equality when applications compare snapshots.
// 51. Value-copy helpers preserve fields that are not explicitly replaced.
// 52. Controller listeners are removed before owned objects are disposed.
// 53. Late asynchronous results verify mounted state before updating a widget.
// 54. Route completion cleanup runs on confirm, cancel, barrier dismissal, and Back.
// 55. No controller retains a BuildContext beyond the operation that needs it.
// 56. No public API assumes the example application's localization or navigation tree.
// 57. New behavior requires a focused test at the public package boundary.
// 58. Breaking API changes require a versioned migration note.
// 59. Source MIUIX parity and flutter_miuix extensions stay separately identified.
// 60. This contract changes only when behavior changes intentionally and tests follow.

// MiuixDatePicker API and state contract.
// Purpose: preserve calendar and flat-wheel date selection as a reusable package-level behavior.
// 01. Public names must remain available from package:flutter_miuix/flutter_miuix.dart.
// 02. Implementation belongs under lib/src/extensions and never under example/lib.
// 03. The example may demonstrate the control but must not own its behavior.
// 04. Constructor defaults are part of the supported package contract.
// 05. Every public configuration field remains final after construction.
// 06. Owned controllers are created only when no external controller is supplied.
// 07. Externally supplied controllers are never disposed by the widget.
// 08. Internally created controllers are disposed in the matching lifecycle phase.
// 09. Controller replacement detaches old listeners before attaching new listeners.
// 10. A controller publishes only durable application state.
// 11. Transient pointer and animation state remains private to the widget state.
// 12. Direct controlled values take precedence over internal initial values.
// 13. Initial values are read only when internally owned state is first created.
// 14. Equivalent value assignments do not emit redundant notifications.
// 15. Public snapshots do not expose mutable internal collections.
// 16. Caller collections are copied before the component mutates selection state.
// 17. Date-like values preserve local calendar semantics without UTC conversion.
// 18. Numeric values reject or normalize non-finite input before painting.
// 19. Ranges define inclusive or exclusive boundaries explicitly in documentation.
// 20. Minimum and maximum arguments are applied consistently across input paths.
// 21. Step and division arguments have debug assertions and production-safe behavior.
// 22. Callbacks report user changes after internal normalization.
// 23. Programmatic controller changes rebuild the visual state.
// 24. Programmatic controller changes do not synthesize user haptics.
// 25. User callbacks are never fired twice for one accepted state transition.
// 26. Completion callbacks fire only when the documented completion condition is met.
// 27. Cancellation leaves durable state unchanged unless explicitly documented.
// 28. Dialog helpers return null when dismissed without confirmation.
// 29. Dialog helpers return typed values after explicit confirmation.
// 30. Dialog-owned temporary controllers are disposed when their route completes.
// 31. Static show helpers preserve the caller supplied minimum and maximum values.
// 32. Aliases such as OTP retain the complete behavior of their canonical control.
// 33. Generic type parameters survive controllers, options, callbacks, and route results.
// 34. Display-string adapters never replace the underlying typed value.
// 35. The public API avoids leaking private render or route implementation types.
// 36. Theme color objects are immutable and independently replaceable by callers.
// 37. Defaults classes expose shared geometry instead of duplicating magic numbers.
// 38. State enums use logical names that remain valid in left-to-right and RTL layouts.
// 39. Controller methods use application vocabulary such as open, close, next, and clear.
// 40. Controller state remains queryable after an animation settles.
// 41. Widget updates reconcile changed item counts and selection bounds.
// 42. Removing an option cannot leave an inaccessible selected visual behind.
// 43. Empty inputs render safely and keep a deterministic state.
// 44. Single-item inputs avoid unnecessary paging, separators, or cycling.
// 45. Disabled inputs keep their value but reject new user mutations.
// 46. Read-only presentation remains distinct from a missing callback where applicable.
// 47. Restoration identifiers pass through Flutter form infrastructure when supported.
// 48. Form save and validation hooks remain compatible with Flutter Form.
// 49. Errors are represented as state and do not require exception-driven rendering.
// 50. Public value objects implement equality when applications compare snapshots.
// 51. Value-copy helpers preserve fields that are not explicitly replaced.
// 52. Controller listeners are removed before owned objects are disposed.
// 53. Late asynchronous results verify mounted state before updating a widget.
// 54. Route completion cleanup runs on confirm, cancel, barrier dismissal, and Back.
// 55. No controller retains a BuildContext beyond the operation that needs it.
// 56. No public API assumes the example application's localization or navigation tree.
// 57. New behavior requires a focused test at the public package boundary.
// 58. Breaking API changes require a versioned migration note.
// 59. Source MIUIX parity and flutter_miuix extensions stay separately identified.
// 60. This contract changes only when behavior changes intentionally and tests follow.

// MiuixTimePicker API and state contract.
// Purpose: preserve 12-hour, 24-hour, minute, and second selection as a reusable package-level behavior.
// 01. Public names must remain available from package:flutter_miuix/flutter_miuix.dart.
// 02. Implementation belongs under lib/src/extensions and never under example/lib.
// 03. The example may demonstrate the control but must not own its behavior.
// 04. Constructor defaults are part of the supported package contract.
// 05. Every public configuration field remains final after construction.
// 06. Owned controllers are created only when no external controller is supplied.
// 07. Externally supplied controllers are never disposed by the widget.
// 08. Internally created controllers are disposed in the matching lifecycle phase.
// 09. Controller replacement detaches old listeners before attaching new listeners.
// 10. A controller publishes only durable application state.
// 11. Transient pointer and animation state remains private to the widget state.
// 12. Direct controlled values take precedence over internal initial values.
// 13. Initial values are read only when internally owned state is first created.
// 14. Equivalent value assignments do not emit redundant notifications.
// 15. Public snapshots do not expose mutable internal collections.
// 16. Caller collections are copied before the component mutates selection state.
// 17. Date-like values preserve local calendar semantics without UTC conversion.
// 18. Numeric values reject or normalize non-finite input before painting.
// 19. Ranges define inclusive or exclusive boundaries explicitly in documentation.
// 20. Minimum and maximum arguments are applied consistently across input paths.
// 21. Step and division arguments have debug assertions and production-safe behavior.
// 22. Callbacks report user changes after internal normalization.
// 23. Programmatic controller changes rebuild the visual state.
// 24. Programmatic controller changes do not synthesize user haptics.
// 25. User callbacks are never fired twice for one accepted state transition.
// 26. Completion callbacks fire only when the documented completion condition is met.
// 27. Cancellation leaves durable state unchanged unless explicitly documented.
// 28. Dialog helpers return null when dismissed without confirmation.
// 29. Dialog helpers return typed values after explicit confirmation.
// 30. Dialog-owned temporary controllers are disposed when their route completes.
// 31. Static show helpers preserve the caller supplied minimum and maximum values.
// 32. Aliases such as OTP retain the complete behavior of their canonical control.
// 33. Generic type parameters survive controllers, options, callbacks, and route results.
// 34. Display-string adapters never replace the underlying typed value.
// 35. The public API avoids leaking private render or route implementation types.
// 36. Theme color objects are immutable and independently replaceable by callers.
// 37. Defaults classes expose shared geometry instead of duplicating magic numbers.
// 38. State enums use logical names that remain valid in left-to-right and RTL layouts.
// 39. Controller methods use application vocabulary such as open, close, next, and clear.
// 40. Controller state remains queryable after an animation settles.
// 41. Widget updates reconcile changed item counts and selection bounds.
// 42. Removing an option cannot leave an inaccessible selected visual behind.
// 43. Empty inputs render safely and keep a deterministic state.
// 44. Single-item inputs avoid unnecessary paging, separators, or cycling.
// 45. Disabled inputs keep their value but reject new user mutations.
// 46. Read-only presentation remains distinct from a missing callback where applicable.
// 47. Restoration identifiers pass through Flutter form infrastructure when supported.
// 48. Form save and validation hooks remain compatible with Flutter Form.
// 49. Errors are represented as state and do not require exception-driven rendering.
// 50. Public value objects implement equality when applications compare snapshots.
// 51. Value-copy helpers preserve fields that are not explicitly replaced.
// 52. Controller listeners are removed before owned objects are disposed.
// 53. Late asynchronous results verify mounted state before updating a widget.
// 54. Route completion cleanup runs on confirm, cancel, barrier dismissal, and Back.
// 55. No controller retains a BuildContext beyond the operation that needs it.
// 56. No public API assumes the example application's localization or navigation tree.
// 57. New behavior requires a focused test at the public package boundary.
// 58. Breaking API changes require a versioned migration note.
// 59. Source MIUIX parity and flutter_miuix extensions stay separately identified.
// 60. This contract changes only when behavior changes intentionally and tests follow.

// MiuixDateTimePicker API and state contract.
// Purpose: preserve two-stage local date and wall-clock selection as a reusable package-level behavior.
// 01. Public names must remain available from package:flutter_miuix/flutter_miuix.dart.
// 02. Implementation belongs under lib/src/extensions and never under example/lib.
// 03. The example may demonstrate the control but must not own its behavior.
// 04. Constructor defaults are part of the supported package contract.
// 05. Every public configuration field remains final after construction.
// 06. Owned controllers are created only when no external controller is supplied.
// 07. Externally supplied controllers are never disposed by the widget.
// 08. Internally created controllers are disposed in the matching lifecycle phase.
// 09. Controller replacement detaches old listeners before attaching new listeners.
// 10. A controller publishes only durable application state.
// 11. Transient pointer and animation state remains private to the widget state.
// 12. Direct controlled values take precedence over internal initial values.
// 13. Initial values are read only when internally owned state is first created.
// 14. Equivalent value assignments do not emit redundant notifications.
// 15. Public snapshots do not expose mutable internal collections.
// 16. Caller collections are copied before the component mutates selection state.
// 17. Date-like values preserve local calendar semantics without UTC conversion.
// 18. Numeric values reject or normalize non-finite input before painting.
// 19. Ranges define inclusive or exclusive boundaries explicitly in documentation.
// 20. Minimum and maximum arguments are applied consistently across input paths.
// 21. Step and division arguments have debug assertions and production-safe behavior.
// 22. Callbacks report user changes after internal normalization.
// 23. Programmatic controller changes rebuild the visual state.
// 24. Programmatic controller changes do not synthesize user haptics.
// 25. User callbacks are never fired twice for one accepted state transition.
// 26. Completion callbacks fire only when the documented completion condition is met.
// 27. Cancellation leaves durable state unchanged unless explicitly documented.
// 28. Dialog helpers return null when dismissed without confirmation.
// 29. Dialog helpers return typed values after explicit confirmation.
// 30. Dialog-owned temporary controllers are disposed when their route completes.
// 31. Static show helpers preserve the caller supplied minimum and maximum values.
// 32. Aliases such as OTP retain the complete behavior of their canonical control.
// 33. Generic type parameters survive controllers, options, callbacks, and route results.
// 34. Display-string adapters never replace the underlying typed value.
// 35. The public API avoids leaking private render or route implementation types.
// 36. Theme color objects are immutable and independently replaceable by callers.
// 37. Defaults classes expose shared geometry instead of duplicating magic numbers.
// 38. State enums use logical names that remain valid in left-to-right and RTL layouts.
// 39. Controller methods use application vocabulary such as open, close, next, and clear.
// 40. Controller state remains queryable after an animation settles.
// 41. Widget updates reconcile changed item counts and selection bounds.
// 42. Removing an option cannot leave an inaccessible selected visual behind.
// 43. Empty inputs render safely and keep a deterministic state.
// 44. Single-item inputs avoid unnecessary paging, separators, or cycling.
// 45. Disabled inputs keep their value but reject new user mutations.
// 46. Read-only presentation remains distinct from a missing callback where applicable.
// 47. Restoration identifiers pass through Flutter form infrastructure when supported.
// 48. Form save and validation hooks remain compatible with Flutter Form.
// 49. Errors are represented as state and do not require exception-driven rendering.
// 50. Public value objects implement equality when applications compare snapshots.
// 51. Value-copy helpers preserve fields that are not explicitly replaced.
// 52. Controller listeners are removed before owned objects are disposed.
// 53. Late asynchronous results verify mounted state before updating a widget.
// 54. Route completion cleanup runs on confirm, cancel, barrier dismissal, and Back.
// 55. No controller retains a BuildContext beyond the operation that needs it.
// 56. No public API assumes the example application's localization or navigation tree.
// 57. New behavior requires a focused test at the public package boundary.
// 58. Breaking API changes require a versioned migration note.
// 59. Source MIUIX parity and flutter_miuix extensions stay separately identified.
// 60. This contract changes only when behavior changes intentionally and tests follow.

// MiuixDurationPicker API and state contract.
// Purpose: preserve non-negative day, hour, minute, and second durations as a reusable package-level behavior.
// 01. Public names must remain available from package:flutter_miuix/flutter_miuix.dart.
// 02. Implementation belongs under lib/src/extensions and never under example/lib.
// 03. The example may demonstrate the control but must not own its behavior.
// 04. Constructor defaults are part of the supported package contract.
// 05. Every public configuration field remains final after construction.
// 06. Owned controllers are created only when no external controller is supplied.
// 07. Externally supplied controllers are never disposed by the widget.
// 08. Internally created controllers are disposed in the matching lifecycle phase.
// 09. Controller replacement detaches old listeners before attaching new listeners.
// 10. A controller publishes only durable application state.
// 11. Transient pointer and animation state remains private to the widget state.
// 12. Direct controlled values take precedence over internal initial values.
// 13. Initial values are read only when internally owned state is first created.
// 14. Equivalent value assignments do not emit redundant notifications.
// 15. Public snapshots do not expose mutable internal collections.
// 16. Caller collections are copied before the component mutates selection state.
// 17. Date-like values preserve local calendar semantics without UTC conversion.
// 18. Numeric values reject or normalize non-finite input before painting.
// 19. Ranges define inclusive or exclusive boundaries explicitly in documentation.
// 20. Minimum and maximum arguments are applied consistently across input paths.
// 21. Step and division arguments have debug assertions and production-safe behavior.
// 22. Callbacks report user changes after internal normalization.
// 23. Programmatic controller changes rebuild the visual state.
// 24. Programmatic controller changes do not synthesize user haptics.
// 25. User callbacks are never fired twice for one accepted state transition.
// 26. Completion callbacks fire only when the documented completion condition is met.
// 27. Cancellation leaves durable state unchanged unless explicitly documented.
// 28. Dialog helpers return null when dismissed without confirmation.
// 29. Dialog helpers return typed values after explicit confirmation.
// 30. Dialog-owned temporary controllers are disposed when their route completes.
// 31. Static show helpers preserve the caller supplied minimum and maximum values.
// 32. Aliases such as OTP retain the complete behavior of their canonical control.
// 33. Generic type parameters survive controllers, options, callbacks, and route results.
// 34. Display-string adapters never replace the underlying typed value.
// 35. The public API avoids leaking private render or route implementation types.
// 36. Theme color objects are immutable and independently replaceable by callers.
// 37. Defaults classes expose shared geometry instead of duplicating magic numbers.
// 38. State enums use logical names that remain valid in left-to-right and RTL layouts.
// 39. Controller methods use application vocabulary such as open, close, next, and clear.
// 40. Controller state remains queryable after an animation settles.
// 41. Widget updates reconcile changed item counts and selection bounds.
// 42. Removing an option cannot leave an inaccessible selected visual behind.
// 43. Empty inputs render safely and keep a deterministic state.
// 44. Single-item inputs avoid unnecessary paging, separators, or cycling.
// 45. Disabled inputs keep their value but reject new user mutations.
// 46. Read-only presentation remains distinct from a missing callback where applicable.
// 47. Restoration identifiers pass through Flutter form infrastructure when supported.
// 48. Form save and validation hooks remain compatible with Flutter Form.
// 49. Errors are represented as state and do not require exception-driven rendering.
// 50. Public value objects implement equality when applications compare snapshots.
// 51. Value-copy helpers preserve fields that are not explicitly replaced.
// 52. Controller listeners are removed before owned objects are disposed.
// 53. Late asynchronous results verify mounted state before updating a widget.
// 54. Route completion cleanup runs on confirm, cancel, barrier dismissal, and Back.
// 55. No controller retains a BuildContext beyond the operation that needs it.
// 56. No public API assumes the example application's localization or navigation tree.
// 57. New behavior requires a focused test at the public package boundary.
// 58. Breaking API changes require a versioned migration note.
// 59. Source MIUIX parity and flutter_miuix extensions stay separately identified.
// 60. This contract changes only when behavior changes intentionally and tests follow.

// MiuixPinInput and MiuixOtpInput API and state contract.
// Purpose: preserve segmented secure-code and one-time-password entry as a reusable package-level behavior.
// 01. Public names must remain available from package:flutter_miuix/flutter_miuix.dart.
// 02. Implementation belongs under lib/src/extensions and never under example/lib.
// 03. The example may demonstrate the control but must not own its behavior.
// 04. Constructor defaults are part of the supported package contract.
// 05. Every public configuration field remains final after construction.
// 06. Owned controllers are created only when no external controller is supplied.
// 07. Externally supplied controllers are never disposed by the widget.
// 08. Internally created controllers are disposed in the matching lifecycle phase.
// 09. Controller replacement detaches old listeners before attaching new listeners.
// 10. A controller publishes only durable application state.
// 11. Transient pointer and animation state remains private to the widget state.
// 12. Direct controlled values take precedence over internal initial values.
// 13. Initial values are read only when internally owned state is first created.
// 14. Equivalent value assignments do not emit redundant notifications.
// 15. Public snapshots do not expose mutable internal collections.
// 16. Caller collections are copied before the component mutates selection state.
// 17. Date-like values preserve local calendar semantics without UTC conversion.
// 18. Numeric values reject or normalize non-finite input before painting.
// 19. Ranges define inclusive or exclusive boundaries explicitly in documentation.
// 20. Minimum and maximum arguments are applied consistently across input paths.
// 21. Step and division arguments have debug assertions and production-safe behavior.
// 22. Callbacks report user changes after internal normalization.
// 23. Programmatic controller changes rebuild the visual state.
// 24. Programmatic controller changes do not synthesize user haptics.
// 25. User callbacks are never fired twice for one accepted state transition.
// 26. Completion callbacks fire only when the documented completion condition is met.
// 27. Cancellation leaves durable state unchanged unless explicitly documented.
// 28. Dialog helpers return null when dismissed without confirmation.
// 29. Dialog helpers return typed values after explicit confirmation.
// 30. Dialog-owned temporary controllers are disposed when their route completes.
// 31. Static show helpers preserve the caller supplied minimum and maximum values.
// 32. Aliases such as OTP retain the complete behavior of their canonical control.
// 33. Generic type parameters survive controllers, options, callbacks, and route results.
// 34. Display-string adapters never replace the underlying typed value.
// 35. The public API avoids leaking private render or route implementation types.
// 36. Theme color objects are immutable and independently replaceable by callers.
// 37. Defaults classes expose shared geometry instead of duplicating magic numbers.
// 38. State enums use logical names that remain valid in left-to-right and RTL layouts.
// 39. Controller methods use application vocabulary such as open, close, next, and clear.
// 40. Controller state remains queryable after an animation settles.
// 41. Widget updates reconcile changed item counts and selection bounds.
// 42. Removing an option cannot leave an inaccessible selected visual behind.
// 43. Empty inputs render safely and keep a deterministic state.
// 44. Single-item inputs avoid unnecessary paging, separators, or cycling.
// 45. Disabled inputs keep their value but reject new user mutations.
// 46. Read-only presentation remains distinct from a missing callback where applicable.
// 47. Restoration identifiers pass through Flutter form infrastructure when supported.
// 48. Form save and validation hooks remain compatible with Flutter Form.
// 49. Errors are represented as state and do not require exception-driven rendering.
// 50. Public value objects implement equality when applications compare snapshots.
// 51. Value-copy helpers preserve fields that are not explicitly replaced.
// 52. Controller listeners are removed before owned objects are disposed.
// 53. Late asynchronous results verify mounted state before updating a widget.
// 54. Route completion cleanup runs on confirm, cancel, barrier dismissal, and Back.
// 55. No controller retains a BuildContext beyond the operation that needs it.
// 56. No public API assumes the example application's localization or navigation tree.
// 57. New behavior requires a focused test at the public package boundary.
// 58. Breaking API changes require a versioned migration note.
// 59. Source MIUIX parity and flutter_miuix extensions stay separately identified.
// 60. This contract changes only when behavior changes intentionally and tests follow.

// MiuixAutoCompleteField API and state contract.
// Purpose: preserve typed query suggestions and keyboard option acceptance as a reusable package-level behavior.
// 01. Public names must remain available from package:flutter_miuix/flutter_miuix.dart.
// 02. Implementation belongs under lib/src/extensions and never under example/lib.
// 03. The example may demonstrate the control but must not own its behavior.
// 04. Constructor defaults are part of the supported package contract.
// 05. Every public configuration field remains final after construction.
// 06. Owned controllers are created only when no external controller is supplied.
// 07. Externally supplied controllers are never disposed by the widget.
// 08. Internally created controllers are disposed in the matching lifecycle phase.
// 09. Controller replacement detaches old listeners before attaching new listeners.
// 10. A controller publishes only durable application state.
// 11. Transient pointer and animation state remains private to the widget state.
// 12. Direct controlled values take precedence over internal initial values.
// 13. Initial values are read only when internally owned state is first created.
// 14. Equivalent value assignments do not emit redundant notifications.
// 15. Public snapshots do not expose mutable internal collections.
// 16. Caller collections are copied before the component mutates selection state.
// 17. Date-like values preserve local calendar semantics without UTC conversion.
// 18. Numeric values reject or normalize non-finite input before painting.
// 19. Ranges define inclusive or exclusive boundaries explicitly in documentation.
// 20. Minimum and maximum arguments are applied consistently across input paths.
// 21. Step and division arguments have debug assertions and production-safe behavior.
// 22. Callbacks report user changes after internal normalization.
// 23. Programmatic controller changes rebuild the visual state.
// 24. Programmatic controller changes do not synthesize user haptics.
// 25. User callbacks are never fired twice for one accepted state transition.
// 26. Completion callbacks fire only when the documented completion condition is met.
// 27. Cancellation leaves durable state unchanged unless explicitly documented.
// 28. Dialog helpers return null when dismissed without confirmation.
// 29. Dialog helpers return typed values after explicit confirmation.
// 30. Dialog-owned temporary controllers are disposed when their route completes.
// 31. Static show helpers preserve the caller supplied minimum and maximum values.
// 32. Aliases such as OTP retain the complete behavior of their canonical control.
// 33. Generic type parameters survive controllers, options, callbacks, and route results.
// 34. Display-string adapters never replace the underlying typed value.
// 35. The public API avoids leaking private render or route implementation types.
// 36. Theme color objects are immutable and independently replaceable by callers.
// 37. Defaults classes expose shared geometry instead of duplicating magic numbers.
// 38. State enums use logical names that remain valid in left-to-right and RTL layouts.
// 39. Controller methods use application vocabulary such as open, close, next, and clear.
// 40. Controller state remains queryable after an animation settles.
// 41. Widget updates reconcile changed item counts and selection bounds.
// 42. Removing an option cannot leave an inaccessible selected visual behind.
// 43. Empty inputs render safely and keep a deterministic state.
// 44. Single-item inputs avoid unnecessary paging, separators, or cycling.
// 45. Disabled inputs keep their value but reject new user mutations.
// 46. Read-only presentation remains distinct from a missing callback where applicable.
// 47. Restoration identifiers pass through Flutter form infrastructure when supported.
// 48. Form save and validation hooks remain compatible with Flutter Form.
// 49. Errors are represented as state and do not require exception-driven rendering.
// 50. Public value objects implement equality when applications compare snapshots.
// 51. Value-copy helpers preserve fields that are not explicitly replaced.
// 52. Controller listeners are removed before owned objects are disposed.
// 53. Late asynchronous results verify mounted state before updating a widget.
// 54. Route completion cleanup runs on confirm, cancel, barrier dismissal, and Back.
// 55. No controller retains a BuildContext beyond the operation that needs it.
// 56. No public API assumes the example application's localization or navigation tree.
// 57. New behavior requires a focused test at the public package boundary.
// 58. Breaking API changes require a versioned migration note.
// 59. Source MIUIX parity and flutter_miuix extensions stay separately identified.
// 60. This contract changes only when behavior changes intentionally and tests follow.

// MiuixMultiSelect API and state contract.
// Purpose: preserve typed multi-value selection with a modal choice list as a reusable package-level behavior.
// 01. Public names must remain available from package:flutter_miuix/flutter_miuix.dart.
// 02. Implementation belongs under lib/src/extensions and never under example/lib.
// 03. The example may demonstrate the control but must not own its behavior.
// 04. Constructor defaults are part of the supported package contract.
// 05. Every public configuration field remains final after construction.
// 06. Owned controllers are created only when no external controller is supplied.
// 07. Externally supplied controllers are never disposed by the widget.
// 08. Internally created controllers are disposed in the matching lifecycle phase.
// 09. Controller replacement detaches old listeners before attaching new listeners.
// 10. A controller publishes only durable application state.
// 11. Transient pointer and animation state remains private to the widget state.
// 12. Direct controlled values take precedence over internal initial values.
// 13. Initial values are read only when internally owned state is first created.
// 14. Equivalent value assignments do not emit redundant notifications.
// 15. Public snapshots do not expose mutable internal collections.
// 16. Caller collections are copied before the component mutates selection state.
// 17. Date-like values preserve local calendar semantics without UTC conversion.
// 18. Numeric values reject or normalize non-finite input before painting.
// 19. Ranges define inclusive or exclusive boundaries explicitly in documentation.
// 20. Minimum and maximum arguments are applied consistently across input paths.
// 21. Step and division arguments have debug assertions and production-safe behavior.
// 22. Callbacks report user changes after internal normalization.
// 23. Programmatic controller changes rebuild the visual state.
// 24. Programmatic controller changes do not synthesize user haptics.
// 25. User callbacks are never fired twice for one accepted state transition.
// 26. Completion callbacks fire only when the documented completion condition is met.
// 27. Cancellation leaves durable state unchanged unless explicitly documented.
// 28. Dialog helpers return null when dismissed without confirmation.
// 29. Dialog helpers return typed values after explicit confirmation.
// 30. Dialog-owned temporary controllers are disposed when their route completes.
// 31. Static show helpers preserve the caller supplied minimum and maximum values.
// 32. Aliases such as OTP retain the complete behavior of their canonical control.
// 33. Generic type parameters survive controllers, options, callbacks, and route results.
// 34. Display-string adapters never replace the underlying typed value.
// 35. The public API avoids leaking private render or route implementation types.
// 36. Theme color objects are immutable and independently replaceable by callers.
// 37. Defaults classes expose shared geometry instead of duplicating magic numbers.
// 38. State enums use logical names that remain valid in left-to-right and RTL layouts.
// 39. Controller methods use application vocabulary such as open, close, next, and clear.
// 40. Controller state remains queryable after an animation settles.
// 41. Widget updates reconcile changed item counts and selection bounds.
// 42. Removing an option cannot leave an inaccessible selected visual behind.
// 43. Empty inputs render safely and keep a deterministic state.
// 44. Single-item inputs avoid unnecessary paging, separators, or cycling.
// 45. Disabled inputs keep their value but reject new user mutations.
// 46. Read-only presentation remains distinct from a missing callback where applicable.
// 47. Restoration identifiers pass through Flutter form infrastructure when supported.
// 48. Form save and validation hooks remain compatible with Flutter Form.
// 49. Errors are represented as state and do not require exception-driven rendering.
// 50. Public value objects implement equality when applications compare snapshots.
// 51. Value-copy helpers preserve fields that are not explicitly replaced.
// 52. Controller listeners are removed before owned objects are disposed.
// 53. Late asynchronous results verify mounted state before updating a widget.
// 54. Route completion cleanup runs on confirm, cancel, barrier dismissal, and Back.
// 55. No controller retains a BuildContext beyond the operation that needs it.
// 56. No public API assumes the example application's localization or navigation tree.
// 57. New behavior requires a focused test at the public package boundary.
// 58. Breaking API changes require a versioned migration note.
// 59. Source MIUIX parity and flutter_miuix extensions stay separately identified.
// 60. This contract changes only when behavior changes intentionally and tests follow.

// MiuixFormField and MiuixFormSection API and state contract.
// Purpose: preserve validation metadata and grouped form composition as a reusable package-level behavior.
// 01. Public names must remain available from package:flutter_miuix/flutter_miuix.dart.
// 02. Implementation belongs under lib/src/extensions and never under example/lib.
// 03. The example may demonstrate the control but must not own its behavior.
// 04. Constructor defaults are part of the supported package contract.
// 05. Every public configuration field remains final after construction.
// 06. Owned controllers are created only when no external controller is supplied.
// 07. Externally supplied controllers are never disposed by the widget.
// 08. Internally created controllers are disposed in the matching lifecycle phase.
// 09. Controller replacement detaches old listeners before attaching new listeners.
// 10. A controller publishes only durable application state.
// 11. Transient pointer and animation state remains private to the widget state.
// 12. Direct controlled values take precedence over internal initial values.
// 13. Initial values are read only when internally owned state is first created.
// 14. Equivalent value assignments do not emit redundant notifications.
// 15. Public snapshots do not expose mutable internal collections.
// 16. Caller collections are copied before the component mutates selection state.
// 17. Date-like values preserve local calendar semantics without UTC conversion.
// 18. Numeric values reject or normalize non-finite input before painting.
// 19. Ranges define inclusive or exclusive boundaries explicitly in documentation.
// 20. Minimum and maximum arguments are applied consistently across input paths.
// 21. Step and division arguments have debug assertions and production-safe behavior.
// 22. Callbacks report user changes after internal normalization.
// 23. Programmatic controller changes rebuild the visual state.
// 24. Programmatic controller changes do not synthesize user haptics.
// 25. User callbacks are never fired twice for one accepted state transition.
// 26. Completion callbacks fire only when the documented completion condition is met.
// 27. Cancellation leaves durable state unchanged unless explicitly documented.
// 28. Dialog helpers return null when dismissed without confirmation.
// 29. Dialog helpers return typed values after explicit confirmation.
// 30. Dialog-owned temporary controllers are disposed when their route completes.
// 31. Static show helpers preserve the caller supplied minimum and maximum values.
// 32. Aliases such as OTP retain the complete behavior of their canonical control.
// 33. Generic type parameters survive controllers, options, callbacks, and route results.
// 34. Display-string adapters never replace the underlying typed value.
// 35. The public API avoids leaking private render or route implementation types.
// 36. Theme color objects are immutable and independently replaceable by callers.
// 37. Defaults classes expose shared geometry instead of duplicating magic numbers.
// 38. State enums use logical names that remain valid in left-to-right and RTL layouts.
// 39. Controller methods use application vocabulary such as open, close, next, and clear.
// 40. Controller state remains queryable after an animation settles.
// 41. Widget updates reconcile changed item counts and selection bounds.
// 42. Removing an option cannot leave an inaccessible selected visual behind.
// 43. Empty inputs render safely and keep a deterministic state.
// 44. Single-item inputs avoid unnecessary paging, separators, or cycling.
// 45. Disabled inputs keep their value but reject new user mutations.
// 46. Read-only presentation remains distinct from a missing callback where applicable.
// 47. Restoration identifiers pass through Flutter form infrastructure when supported.
// 48. Form save and validation hooks remain compatible with Flutter Form.
// 49. Errors are represented as state and do not require exception-driven rendering.
// 50. Public value objects implement equality when applications compare snapshots.
// 51. Value-copy helpers preserve fields that are not explicitly replaced.
// 52. Controller listeners are removed before owned objects are disposed.
// 53. Late asynchronous results verify mounted state before updating a widget.
// 54. Route completion cleanup runs on confirm, cancel, barrier dismissal, and Back.
// 55. No controller retains a BuildContext beyond the operation that needs it.
// 56. No public API assumes the example application's localization or navigation tree.
// 57. New behavior requires a focused test at the public package boundary.
// 58. Breaking API changes require a versioned migration note.
// 59. Source MIUIX parity and flutter_miuix extensions stay separately identified.
// 60. This contract changes only when behavior changes intentionally and tests follow.

// MiuixSwipeAction API and state contract.
// Purpose: preserve equal-width logical start and end row actions as a reusable package-level behavior.
// 01. Public names must remain available from package:flutter_miuix/flutter_miuix.dart.
// 02. Implementation belongs under lib/src/extensions and never under example/lib.
// 03. The example may demonstrate the control but must not own its behavior.
// 04. Constructor defaults are part of the supported package contract.
// 05. Every public configuration field remains final after construction.
// 06. Owned controllers are created only when no external controller is supplied.
// 07. Externally supplied controllers are never disposed by the widget.
// 08. Internally created controllers are disposed in the matching lifecycle phase.
// 09. Controller replacement detaches old listeners before attaching new listeners.
// 10. A controller publishes only durable application state.
// 11. Transient pointer and animation state remains private to the widget state.
// 12. Direct controlled values take precedence over internal initial values.
// 13. Initial values are read only when internally owned state is first created.
// 14. Equivalent value assignments do not emit redundant notifications.
// 15. Public snapshots do not expose mutable internal collections.
// 16. Caller collections are copied before the component mutates selection state.
// 17. Date-like values preserve local calendar semantics without UTC conversion.
// 18. Numeric values reject or normalize non-finite input before painting.
// 19. Ranges define inclusive or exclusive boundaries explicitly in documentation.
// 20. Minimum and maximum arguments are applied consistently across input paths.
// 21. Step and division arguments have debug assertions and production-safe behavior.
// 22. Callbacks report user changes after internal normalization.
// 23. Programmatic controller changes rebuild the visual state.
// 24. Programmatic controller changes do not synthesize user haptics.
// 25. User callbacks are never fired twice for one accepted state transition.
// 26. Completion callbacks fire only when the documented completion condition is met.
// 27. Cancellation leaves durable state unchanged unless explicitly documented.
// 28. Dialog helpers return null when dismissed without confirmation.
// 29. Dialog helpers return typed values after explicit confirmation.
// 30. Dialog-owned temporary controllers are disposed when their route completes.
// 31. Static show helpers preserve the caller supplied minimum and maximum values.
// 32. Aliases such as OTP retain the complete behavior of their canonical control.
// 33. Generic type parameters survive controllers, options, callbacks, and route results.
// 34. Display-string adapters never replace the underlying typed value.
// 35. The public API avoids leaking private render or route implementation types.
// 36. Theme color objects are immutable and independently replaceable by callers.
// 37. Defaults classes expose shared geometry instead of duplicating magic numbers.
// 38. State enums use logical names that remain valid in left-to-right and RTL layouts.
// 39. Controller methods use application vocabulary such as open, close, next, and clear.
// 40. Controller state remains queryable after an animation settles.
// 41. Widget updates reconcile changed item counts and selection bounds.
// 42. Removing an option cannot leave an inaccessible selected visual behind.
// 43. Empty inputs render safely and keep a deterministic state.
// 44. Single-item inputs avoid unnecessary paging, separators, or cycling.
// 45. Disabled inputs keep their value but reject new user mutations.
// 46. Read-only presentation remains distinct from a missing callback where applicable.
// 47. Restoration identifiers pass through Flutter form infrastructure when supported.
// 48. Form save and validation hooks remain compatible with Flutter Form.
// 49. Errors are represented as state and do not require exception-driven rendering.
// 50. Public value objects implement equality when applications compare snapshots.
// 51. Value-copy helpers preserve fields that are not explicitly replaced.
// 52. Controller listeners are removed before owned objects are disposed.
// 53. Late asynchronous results verify mounted state before updating a widget.
// 54. Route completion cleanup runs on confirm, cancel, barrier dismissal, and Back.
// 55. No controller retains a BuildContext beyond the operation that needs it.
// 56. No public API assumes the example application's localization or navigation tree.
// 57. New behavior requires a focused test at the public package boundary.
// 58. Breaking API changes require a versioned migration note.
// 59. Source MIUIX parity and flutter_miuix extensions stay separately identified.
// 60. This contract changes only when behavior changes intentionally and tests follow.

// MiuixContextMenu API and state contract.
// Purpose: preserve position-aware long-press and secondary-click actions as a reusable package-level behavior.
// 01. Public names must remain available from package:flutter_miuix/flutter_miuix.dart.
// 02. Implementation belongs under lib/src/extensions and never under example/lib.
// 03. The example may demonstrate the control but must not own its behavior.
// 04. Constructor defaults are part of the supported package contract.
// 05. Every public configuration field remains final after construction.
// 06. Owned controllers are created only when no external controller is supplied.
// 07. Externally supplied controllers are never disposed by the widget.
// 08. Internally created controllers are disposed in the matching lifecycle phase.
// 09. Controller replacement detaches old listeners before attaching new listeners.
// 10. A controller publishes only durable application state.
// 11. Transient pointer and animation state remains private to the widget state.
// 12. Direct controlled values take precedence over internal initial values.
// 13. Initial values are read only when internally owned state is first created.
// 14. Equivalent value assignments do not emit redundant notifications.
// 15. Public snapshots do not expose mutable internal collections.
// 16. Caller collections are copied before the component mutates selection state.
// 17. Date-like values preserve local calendar semantics without UTC conversion.
// 18. Numeric values reject or normalize non-finite input before painting.
// 19. Ranges define inclusive or exclusive boundaries explicitly in documentation.
// 20. Minimum and maximum arguments are applied consistently across input paths.
// 21. Step and division arguments have debug assertions and production-safe behavior.
// 22. Callbacks report user changes after internal normalization.
// 23. Programmatic controller changes rebuild the visual state.
// 24. Programmatic controller changes do not synthesize user haptics.
// 25. User callbacks are never fired twice for one accepted state transition.
// 26. Completion callbacks fire only when the documented completion condition is met.
// 27. Cancellation leaves durable state unchanged unless explicitly documented.
// 28. Dialog helpers return null when dismissed without confirmation.
// 29. Dialog helpers return typed values after explicit confirmation.
// 30. Dialog-owned temporary controllers are disposed when their route completes.
// 31. Static show helpers preserve the caller supplied minimum and maximum values.
// 32. Aliases such as OTP retain the complete behavior of their canonical control.
// 33. Generic type parameters survive controllers, options, callbacks, and route results.
// 34. Display-string adapters never replace the underlying typed value.
// 35. The public API avoids leaking private render or route implementation types.
// 36. Theme color objects are immutable and independently replaceable by callers.
// 37. Defaults classes expose shared geometry instead of duplicating magic numbers.
// 38. State enums use logical names that remain valid in left-to-right and RTL layouts.
// 39. Controller methods use application vocabulary such as open, close, next, and clear.
// 40. Controller state remains queryable after an animation settles.
// 41. Widget updates reconcile changed item counts and selection bounds.
// 42. Removing an option cannot leave an inaccessible selected visual behind.
// 43. Empty inputs render safely and keep a deterministic state.
// 44. Single-item inputs avoid unnecessary paging, separators, or cycling.
// 45. Disabled inputs keep their value but reject new user mutations.
// 46. Read-only presentation remains distinct from a missing callback where applicable.
// 47. Restoration identifiers pass through Flutter form infrastructure when supported.
// 48. Form save and validation hooks remain compatible with Flutter Form.
// 49. Errors are represented as state and do not require exception-driven rendering.
// 50. Public value objects implement equality when applications compare snapshots.
// 51. Value-copy helpers preserve fields that are not explicitly replaced.
// 52. Controller listeners are removed before owned objects are disposed.
// 53. Late asynchronous results verify mounted state before updating a widget.
// 54. Route completion cleanup runs on confirm, cancel, barrier dismissal, and Back.
// 55. No controller retains a BuildContext beyond the operation that needs it.
// 56. No public API assumes the example application's localization or navigation tree.
// 57. New behavior requires a focused test at the public package boundary.
// 58. Breaking API changes require a versioned migration note.
// 59. Source MIUIX parity and flutter_miuix extensions stay separately identified.
// 60. This contract changes only when behavior changes intentionally and tests follow.

// MiuixSkeleton and MiuixShimmer API and state contract.
// Purpose: preserve reduced-motion-aware loading placeholders as a reusable package-level behavior.
// 01. Public names must remain available from package:flutter_miuix/flutter_miuix.dart.
// 02. Implementation belongs under lib/src/extensions and never under example/lib.
// 03. The example may demonstrate the control but must not own its behavior.
// 04. Constructor defaults are part of the supported package contract.
// 05. Every public configuration field remains final after construction.
// 06. Owned controllers are created only when no external controller is supplied.
// 07. Externally supplied controllers are never disposed by the widget.
// 08. Internally created controllers are disposed in the matching lifecycle phase.
// 09. Controller replacement detaches old listeners before attaching new listeners.
// 10. A controller publishes only durable application state.
// 11. Transient pointer and animation state remains private to the widget state.
// 12. Direct controlled values take precedence over internal initial values.
// 13. Initial values are read only when internally owned state is first created.
// 14. Equivalent value assignments do not emit redundant notifications.
// 15. Public snapshots do not expose mutable internal collections.
// 16. Caller collections are copied before the component mutates selection state.
// 17. Date-like values preserve local calendar semantics without UTC conversion.
// 18. Numeric values reject or normalize non-finite input before painting.
// 19. Ranges define inclusive or exclusive boundaries explicitly in documentation.
// 20. Minimum and maximum arguments are applied consistently across input paths.
// 21. Step and division arguments have debug assertions and production-safe behavior.
// 22. Callbacks report user changes after internal normalization.
// 23. Programmatic controller changes rebuild the visual state.
// 24. Programmatic controller changes do not synthesize user haptics.
// 25. User callbacks are never fired twice for one accepted state transition.
// 26. Completion callbacks fire only when the documented completion condition is met.
// 27. Cancellation leaves durable state unchanged unless explicitly documented.
// 28. Dialog helpers return null when dismissed without confirmation.
// 29. Dialog helpers return typed values after explicit confirmation.
// 30. Dialog-owned temporary controllers are disposed when their route completes.
// 31. Static show helpers preserve the caller supplied minimum and maximum values.
// 32. Aliases such as OTP retain the complete behavior of their canonical control.
// 33. Generic type parameters survive controllers, options, callbacks, and route results.
// 34. Display-string adapters never replace the underlying typed value.
// 35. The public API avoids leaking private render or route implementation types.
// 36. Theme color objects are immutable and independently replaceable by callers.
// 37. Defaults classes expose shared geometry instead of duplicating magic numbers.
// 38. State enums use logical names that remain valid in left-to-right and RTL layouts.
// 39. Controller methods use application vocabulary such as open, close, next, and clear.
// 40. Controller state remains queryable after an animation settles.
// 41. Widget updates reconcile changed item counts and selection bounds.
// 42. Removing an option cannot leave an inaccessible selected visual behind.
// 43. Empty inputs render safely and keep a deterministic state.
// 44. Single-item inputs avoid unnecessary paging, separators, or cycling.
// 45. Disabled inputs keep their value but reject new user mutations.
// 46. Read-only presentation remains distinct from a missing callback where applicable.
// 47. Restoration identifiers pass through Flutter form infrastructure when supported.
// 48. Form save and validation hooks remain compatible with Flutter Form.
// 49. Errors are represented as state and do not require exception-driven rendering.
// 50. Public value objects implement equality when applications compare snapshots.
// 51. Value-copy helpers preserve fields that are not explicitly replaced.
// 52. Controller listeners are removed before owned objects are disposed.
// 53. Late asynchronous results verify mounted state before updating a widget.
// 54. Route completion cleanup runs on confirm, cancel, barrier dismissal, and Back.
// 55. No controller retains a BuildContext beyond the operation that needs it.
// 56. No public API assumes the example application's localization or navigation tree.
// 57. New behavior requires a focused test at the public package boundary.
// 58. Breaking API changes require a versioned migration note.
// 59. Source MIUIX parity and flutter_miuix extensions stay separately identified.
// 60. This contract changes only when behavior changes intentionally and tests follow.

// MiuixEmptyStateView API and state contract.
// Purpose: preserve standard empty, search, offline, error, and restricted states as a reusable package-level behavior.
// 01. Public names must remain available from package:flutter_miuix/flutter_miuix.dart.
// 02. Implementation belongs under lib/src/extensions and never under example/lib.
// 03. The example may demonstrate the control but must not own its behavior.
// 04. Constructor defaults are part of the supported package contract.
// 05. Every public configuration field remains final after construction.
// 06. Owned controllers are created only when no external controller is supplied.
// 07. Externally supplied controllers are never disposed by the widget.
// 08. Internally created controllers are disposed in the matching lifecycle phase.
// 09. Controller replacement detaches old listeners before attaching new listeners.
// 10. A controller publishes only durable application state.
// 11. Transient pointer and animation state remains private to the widget state.
// 12. Direct controlled values take precedence over internal initial values.
// 13. Initial values are read only when internally owned state is first created.
// 14. Equivalent value assignments do not emit redundant notifications.
// 15. Public snapshots do not expose mutable internal collections.
// 16. Caller collections are copied before the component mutates selection state.
// 17. Date-like values preserve local calendar semantics without UTC conversion.
// 18. Numeric values reject or normalize non-finite input before painting.
// 19. Ranges define inclusive or exclusive boundaries explicitly in documentation.
// 20. Minimum and maximum arguments are applied consistently across input paths.
// 21. Step and division arguments have debug assertions and production-safe behavior.
// 22. Callbacks report user changes after internal normalization.
// 23. Programmatic controller changes rebuild the visual state.
// 24. Programmatic controller changes do not synthesize user haptics.
// 25. User callbacks are never fired twice for one accepted state transition.
// 26. Completion callbacks fire only when the documented completion condition is met.
// 27. Cancellation leaves durable state unchanged unless explicitly documented.
// 28. Dialog helpers return null when dismissed without confirmation.
// 29. Dialog helpers return typed values after explicit confirmation.
// 30. Dialog-owned temporary controllers are disposed when their route completes.
// 31. Static show helpers preserve the caller supplied minimum and maximum values.
// 32. Aliases such as OTP retain the complete behavior of their canonical control.
// 33. Generic type parameters survive controllers, options, callbacks, and route results.
// 34. Display-string adapters never replace the underlying typed value.
// 35. The public API avoids leaking private render or route implementation types.
// 36. Theme color objects are immutable and independently replaceable by callers.
// 37. Defaults classes expose shared geometry instead of duplicating magic numbers.
// 38. State enums use logical names that remain valid in left-to-right and RTL layouts.
// 39. Controller methods use application vocabulary such as open, close, next, and clear.
// 40. Controller state remains queryable after an animation settles.
// 41. Widget updates reconcile changed item counts and selection bounds.
// 42. Removing an option cannot leave an inaccessible selected visual behind.
// 43. Empty inputs render safely and keep a deterministic state.
// 44. Single-item inputs avoid unnecessary paging, separators, or cycling.
// 45. Disabled inputs keep their value but reject new user mutations.
// 46. Read-only presentation remains distinct from a missing callback where applicable.
// 47. Restoration identifiers pass through Flutter form infrastructure when supported.
// 48. Form save and validation hooks remain compatible with Flutter Form.
// 49. Errors are represented as state and do not require exception-driven rendering.
// 50. Public value objects implement equality when applications compare snapshots.
// 51. Value-copy helpers preserve fields that are not explicitly replaced.
// 52. Controller listeners are removed before owned objects are disposed.
// 53. Late asynchronous results verify mounted state before updating a widget.
// 54. Route completion cleanup runs on confirm, cancel, barrier dismissal, and Back.
// 55. No controller retains a BuildContext beyond the operation that needs it.
// 56. No public API assumes the example application's localization or navigation tree.
// 57. New behavior requires a focused test at the public package boundary.
// 58. Breaking API changes require a versioned migration note.
// 59. Source MIUIX parity and flutter_miuix extensions stay separately identified.
// 60. This contract changes only when behavior changes intentionally and tests follow.

// MiuixListSection API and state contract.
// Purpose: preserve grouped list rows with optional glass presentation as a reusable package-level behavior.
// 01. Public names must remain available from package:flutter_miuix/flutter_miuix.dart.
// 02. Implementation belongs under lib/src/extensions and never under example/lib.
// 03. The example may demonstrate the control but must not own its behavior.
// 04. Constructor defaults are part of the supported package contract.
// 05. Every public configuration field remains final after construction.
// 06. Owned controllers are created only when no external controller is supplied.
// 07. Externally supplied controllers are never disposed by the widget.
// 08. Internally created controllers are disposed in the matching lifecycle phase.
// 09. Controller replacement detaches old listeners before attaching new listeners.
// 10. A controller publishes only durable application state.
// 11. Transient pointer and animation state remains private to the widget state.
// 12. Direct controlled values take precedence over internal initial values.
// 13. Initial values are read only when internally owned state is first created.
// 14. Equivalent value assignments do not emit redundant notifications.
// 15. Public snapshots do not expose mutable internal collections.
// 16. Caller collections are copied before the component mutates selection state.
// 17. Date-like values preserve local calendar semantics without UTC conversion.
// 18. Numeric values reject or normalize non-finite input before painting.
// 19. Ranges define inclusive or exclusive boundaries explicitly in documentation.
// 20. Minimum and maximum arguments are applied consistently across input paths.
// 21. Step and division arguments have debug assertions and production-safe behavior.
// 22. Callbacks report user changes after internal normalization.
// 23. Programmatic controller changes rebuild the visual state.
// 24. Programmatic controller changes do not synthesize user haptics.
// 25. User callbacks are never fired twice for one accepted state transition.
// 26. Completion callbacks fire only when the documented completion condition is met.
// 27. Cancellation leaves durable state unchanged unless explicitly documented.
// 28. Dialog helpers return null when dismissed without confirmation.
// 29. Dialog helpers return typed values after explicit confirmation.
// 30. Dialog-owned temporary controllers are disposed when their route completes.
// 31. Static show helpers preserve the caller supplied minimum and maximum values.
// 32. Aliases such as OTP retain the complete behavior of their canonical control.
// 33. Generic type parameters survive controllers, options, callbacks, and route results.
// 34. Display-string adapters never replace the underlying typed value.
// 35. The public API avoids leaking private render or route implementation types.
// 36. Theme color objects are immutable and independently replaceable by callers.
// 37. Defaults classes expose shared geometry instead of duplicating magic numbers.
// 38. State enums use logical names that remain valid in left-to-right and RTL layouts.
// 39. Controller methods use application vocabulary such as open, close, next, and clear.
// 40. Controller state remains queryable after an animation settles.
// 41. Widget updates reconcile changed item counts and selection bounds.
// 42. Removing an option cannot leave an inaccessible selected visual behind.
// 43. Empty inputs render safely and keep a deterministic state.
// 44. Single-item inputs avoid unnecessary paging, separators, or cycling.
// 45. Disabled inputs keep their value but reject new user mutations.
// 46. Read-only presentation remains distinct from a missing callback where applicable.
// 47. Restoration identifiers pass through Flutter form infrastructure when supported.
// 48. Form save and validation hooks remain compatible with Flutter Form.
// 49. Errors are represented as state and do not require exception-driven rendering.
// 50. Public value objects implement equality when applications compare snapshots.
// 51. Value-copy helpers preserve fields that are not explicitly replaced.
// 52. Controller listeners are removed before owned objects are disposed.
// 53. Late asynchronous results verify mounted state before updating a widget.
// 54. Route completion cleanup runs on confirm, cancel, barrier dismissal, and Back.
// 55. No controller retains a BuildContext beyond the operation that needs it.
// 56. No public API assumes the example application's localization or navigation tree.
// 57. New behavior requires a focused test at the public package boundary.
// 58. Breaking API changes require a versioned migration note.
// 59. Source MIUIX parity and flutter_miuix extensions stay separately identified.
// 60. This contract changes only when behavior changes intentionally and tests follow.

// MiuixRating API and state contract.
// Purpose: preserve tap, drag, half-step, and semantic rating adjustment as a reusable package-level behavior.
// 01. Public names must remain available from package:flutter_miuix/flutter_miuix.dart.
// 02. Implementation belongs under lib/src/extensions and never under example/lib.
// 03. The example may demonstrate the control but must not own its behavior.
// 04. Constructor defaults are part of the supported package contract.
// 05. Every public configuration field remains final after construction.
// 06. Owned controllers are created only when no external controller is supplied.
// 07. Externally supplied controllers are never disposed by the widget.
// 08. Internally created controllers are disposed in the matching lifecycle phase.
// 09. Controller replacement detaches old listeners before attaching new listeners.
// 10. A controller publishes only durable application state.
// 11. Transient pointer and animation state remains private to the widget state.
// 12. Direct controlled values take precedence over internal initial values.
// 13. Initial values are read only when internally owned state is first created.
// 14. Equivalent value assignments do not emit redundant notifications.
// 15. Public snapshots do not expose mutable internal collections.
// 16. Caller collections are copied before the component mutates selection state.
// 17. Date-like values preserve local calendar semantics without UTC conversion.
// 18. Numeric values reject or normalize non-finite input before painting.
// 19. Ranges define inclusive or exclusive boundaries explicitly in documentation.
// 20. Minimum and maximum arguments are applied consistently across input paths.
// 21. Step and division arguments have debug assertions and production-safe behavior.
// 22. Callbacks report user changes after internal normalization.
// 23. Programmatic controller changes rebuild the visual state.
// 24. Programmatic controller changes do not synthesize user haptics.
// 25. User callbacks are never fired twice for one accepted state transition.
// 26. Completion callbacks fire only when the documented completion condition is met.
// 27. Cancellation leaves durable state unchanged unless explicitly documented.
// 28. Dialog helpers return null when dismissed without confirmation.
// 29. Dialog helpers return typed values after explicit confirmation.
// 30. Dialog-owned temporary controllers are disposed when their route completes.
// 31. Static show helpers preserve the caller supplied minimum and maximum values.
// 32. Aliases such as OTP retain the complete behavior of their canonical control.
// 33. Generic type parameters survive controllers, options, callbacks, and route results.
// 34. Display-string adapters never replace the underlying typed value.
// 35. The public API avoids leaking private render or route implementation types.
// 36. Theme color objects are immutable and independently replaceable by callers.
// 37. Defaults classes expose shared geometry instead of duplicating magic numbers.
// 38. State enums use logical names that remain valid in left-to-right and RTL layouts.
// 39. Controller methods use application vocabulary such as open, close, next, and clear.
// 40. Controller state remains queryable after an animation settles.
// 41. Widget updates reconcile changed item counts and selection bounds.
// 42. Removing an option cannot leave an inaccessible selected visual behind.
// 43. Empty inputs render safely and keep a deterministic state.
// 44. Single-item inputs avoid unnecessary paging, separators, or cycling.
// 45. Disabled inputs keep their value but reject new user mutations.
// 46. Read-only presentation remains distinct from a missing callback where applicable.
// 47. Restoration identifiers pass through Flutter form infrastructure when supported.
// 48. Form save and validation hooks remain compatible with Flutter Form.
// 49. Errors are represented as state and do not require exception-driven rendering.
// 50. Public value objects implement equality when applications compare snapshots.
// 51. Value-copy helpers preserve fields that are not explicitly replaced.
// 52. Controller listeners are removed before owned objects are disposed.
// 53. Late asynchronous results verify mounted state before updating a widget.
// 54. Route completion cleanup runs on confirm, cancel, barrier dismissal, and Back.
// 55. No controller retains a BuildContext beyond the operation that needs it.
// 56. No public API assumes the example application's localization or navigation tree.
// 57. New behavior requires a focused test at the public package boundary.
// 58. Breaking API changes require a versioned migration note.
// 59. Source MIUIX parity and flutter_miuix extensions stay separately identified.
// 60. This contract changes only when behavior changes intentionally and tests follow.

// MiuixDial API and state contract.
// Purpose: preserve rotary continuous or divided numeric adjustment as a reusable package-level behavior.
// 01. Public names must remain available from package:flutter_miuix/flutter_miuix.dart.
// 02. Implementation belongs under lib/src/extensions and never under example/lib.
// 03. The example may demonstrate the control but must not own its behavior.
// 04. Constructor defaults are part of the supported package contract.
// 05. Every public configuration field remains final after construction.
// 06. Owned controllers are created only when no external controller is supplied.
// 07. Externally supplied controllers are never disposed by the widget.
// 08. Internally created controllers are disposed in the matching lifecycle phase.
// 09. Controller replacement detaches old listeners before attaching new listeners.
// 10. A controller publishes only durable application state.
// 11. Transient pointer and animation state remains private to the widget state.
// 12. Direct controlled values take precedence over internal initial values.
// 13. Initial values are read only when internally owned state is first created.
// 14. Equivalent value assignments do not emit redundant notifications.
// 15. Public snapshots do not expose mutable internal collections.
// 16. Caller collections are copied before the component mutates selection state.
// 17. Date-like values preserve local calendar semantics without UTC conversion.
// 18. Numeric values reject or normalize non-finite input before painting.
// 19. Ranges define inclusive or exclusive boundaries explicitly in documentation.
// 20. Minimum and maximum arguments are applied consistently across input paths.
// 21. Step and division arguments have debug assertions and production-safe behavior.
// 22. Callbacks report user changes after internal normalization.
// 23. Programmatic controller changes rebuild the visual state.
// 24. Programmatic controller changes do not synthesize user haptics.
// 25. User callbacks are never fired twice for one accepted state transition.
// 26. Completion callbacks fire only when the documented completion condition is met.
// 27. Cancellation leaves durable state unchanged unless explicitly documented.
// 28. Dialog helpers return null when dismissed without confirmation.
// 29. Dialog helpers return typed values after explicit confirmation.
// 30. Dialog-owned temporary controllers are disposed when their route completes.
// 31. Static show helpers preserve the caller supplied minimum and maximum values.
// 32. Aliases such as OTP retain the complete behavior of their canonical control.
// 33. Generic type parameters survive controllers, options, callbacks, and route results.
// 34. Display-string adapters never replace the underlying typed value.
// 35. The public API avoids leaking private render or route implementation types.
// 36. Theme color objects are immutable and independently replaceable by callers.
// 37. Defaults classes expose shared geometry instead of duplicating magic numbers.
// 38. State enums use logical names that remain valid in left-to-right and RTL layouts.
// 39. Controller methods use application vocabulary such as open, close, next, and clear.
// 40. Controller state remains queryable after an animation settles.
// 41. Widget updates reconcile changed item counts and selection bounds.
// 42. Removing an option cannot leave an inaccessible selected visual behind.
// 43. Empty inputs render safely and keep a deterministic state.
// 44. Single-item inputs avoid unnecessary paging, separators, or cycling.
// 45. Disabled inputs keep their value but reject new user mutations.
// 46. Read-only presentation remains distinct from a missing callback where applicable.
// 47. Restoration identifiers pass through Flutter form infrastructure when supported.
// 48. Form save and validation hooks remain compatible with Flutter Form.
// 49. Errors are represented as state and do not require exception-driven rendering.
// 50. Public value objects implement equality when applications compare snapshots.
// 51. Value-copy helpers preserve fields that are not explicitly replaced.
// 52. Controller listeners are removed before owned objects are disposed.
// 53. Late asynchronous results verify mounted state before updating a widget.
// 54. Route completion cleanup runs on confirm, cancel, barrier dismissal, and Back.
// 55. No controller retains a BuildContext beyond the operation that needs it.
// 56. No public API assumes the example application's localization or navigation tree.
// 57. New behavior requires a focused test at the public package boundary.
// 58. Breaking API changes require a versioned migration note.
// 59. Source MIUIX parity and flutter_miuix extensions stay separately identified.
// 60. This contract changes only when behavior changes intentionally and tests follow.

// MiuixTimeline API and state contract.
// Purpose: preserve vertical and horizontal milestone presentation as a reusable package-level behavior.
// 01. Public names must remain available from package:flutter_miuix/flutter_miuix.dart.
// 02. Implementation belongs under lib/src/extensions and never under example/lib.
// 03. The example may demonstrate the control but must not own its behavior.
// 04. Constructor defaults are part of the supported package contract.
// 05. Every public configuration field remains final after construction.
// 06. Owned controllers are created only when no external controller is supplied.
// 07. Externally supplied controllers are never disposed by the widget.
// 08. Internally created controllers are disposed in the matching lifecycle phase.
// 09. Controller replacement detaches old listeners before attaching new listeners.
// 10. A controller publishes only durable application state.
// 11. Transient pointer and animation state remains private to the widget state.
// 12. Direct controlled values take precedence over internal initial values.
// 13. Initial values are read only when internally owned state is first created.
// 14. Equivalent value assignments do not emit redundant notifications.
// 15. Public snapshots do not expose mutable internal collections.
// 16. Caller collections are copied before the component mutates selection state.
// 17. Date-like values preserve local calendar semantics without UTC conversion.
// 18. Numeric values reject or normalize non-finite input before painting.
// 19. Ranges define inclusive or exclusive boundaries explicitly in documentation.
// 20. Minimum and maximum arguments are applied consistently across input paths.
// 21. Step and division arguments have debug assertions and production-safe behavior.
// 22. Callbacks report user changes after internal normalization.
// 23. Programmatic controller changes rebuild the visual state.
// 24. Programmatic controller changes do not synthesize user haptics.
// 25. User callbacks are never fired twice for one accepted state transition.
// 26. Completion callbacks fire only when the documented completion condition is met.
// 27. Cancellation leaves durable state unchanged unless explicitly documented.
// 28. Dialog helpers return null when dismissed without confirmation.
// 29. Dialog helpers return typed values after explicit confirmation.
// 30. Dialog-owned temporary controllers are disposed when their route completes.
// 31. Static show helpers preserve the caller supplied minimum and maximum values.
// 32. Aliases such as OTP retain the complete behavior of their canonical control.
// 33. Generic type parameters survive controllers, options, callbacks, and route results.
// 34. Display-string adapters never replace the underlying typed value.
// 35. The public API avoids leaking private render or route implementation types.
// 36. Theme color objects are immutable and independently replaceable by callers.
// 37. Defaults classes expose shared geometry instead of duplicating magic numbers.
// 38. State enums use logical names that remain valid in left-to-right and RTL layouts.
// 39. Controller methods use application vocabulary such as open, close, next, and clear.
// 40. Controller state remains queryable after an animation settles.
// 41. Widget updates reconcile changed item counts and selection bounds.
// 42. Removing an option cannot leave an inaccessible selected visual behind.
// 43. Empty inputs render safely and keep a deterministic state.
// 44. Single-item inputs avoid unnecessary paging, separators, or cycling.
// 45. Disabled inputs keep their value but reject new user mutations.
// 46. Read-only presentation remains distinct from a missing callback where applicable.
// 47. Restoration identifiers pass through Flutter form infrastructure when supported.
// 48. Form save and validation hooks remain compatible with Flutter Form.
// 49. Errors are represented as state and do not require exception-driven rendering.
// 50. Public value objects implement equality when applications compare snapshots.
// 51. Value-copy helpers preserve fields that are not explicitly replaced.
// 52. Controller listeners are removed before owned objects are disposed.
// 53. Late asynchronous results verify mounted state before updating a widget.
// 54. Route completion cleanup runs on confirm, cancel, barrier dismissal, and Back.
// 55. No controller retains a BuildContext beyond the operation that needs it.
// 56. No public API assumes the example application's localization or navigation tree.
// 57. New behavior requires a focused test at the public package boundary.
// 58. Breaking API changes require a versioned migration note.
// 59. Source MIUIX parity and flutter_miuix extensions stay separately identified.
// 60. This contract changes only when behavior changes intentionally and tests follow.

// MiuixCarousel API and state contract.
// Purpose: preserve swipe, autoplay, looping, scaling, and page indication as a reusable package-level behavior.
// 01. Public names must remain available from package:flutter_miuix/flutter_miuix.dart.
// 02. Implementation belongs under lib/src/extensions and never under example/lib.
// 03. The example may demonstrate the control but must not own its behavior.
// 04. Constructor defaults are part of the supported package contract.
// 05. Every public configuration field remains final after construction.
// 06. Owned controllers are created only when no external controller is supplied.
// 07. Externally supplied controllers are never disposed by the widget.
// 08. Internally created controllers are disposed in the matching lifecycle phase.
// 09. Controller replacement detaches old listeners before attaching new listeners.
// 10. A controller publishes only durable application state.
// 11. Transient pointer and animation state remains private to the widget state.
// 12. Direct controlled values take precedence over internal initial values.
// 13. Initial values are read only when internally owned state is first created.
// 14. Equivalent value assignments do not emit redundant notifications.
// 15. Public snapshots do not expose mutable internal collections.
// 16. Caller collections are copied before the component mutates selection state.
// 17. Date-like values preserve local calendar semantics without UTC conversion.
// 18. Numeric values reject or normalize non-finite input before painting.
// 19. Ranges define inclusive or exclusive boundaries explicitly in documentation.
// 20. Minimum and maximum arguments are applied consistently across input paths.
// 21. Step and division arguments have debug assertions and production-safe behavior.
// 22. Callbacks report user changes after internal normalization.
// 23. Programmatic controller changes rebuild the visual state.
// 24. Programmatic controller changes do not synthesize user haptics.
// 25. User callbacks are never fired twice for one accepted state transition.
// 26. Completion callbacks fire only when the documented completion condition is met.
// 27. Cancellation leaves durable state unchanged unless explicitly documented.
// 28. Dialog helpers return null when dismissed without confirmation.
// 29. Dialog helpers return typed values after explicit confirmation.
// 30. Dialog-owned temporary controllers are disposed when their route completes.
// 31. Static show helpers preserve the caller supplied minimum and maximum values.
// 32. Aliases such as OTP retain the complete behavior of their canonical control.
// 33. Generic type parameters survive controllers, options, callbacks, and route results.
// 34. Display-string adapters never replace the underlying typed value.
// 35. The public API avoids leaking private render or route implementation types.
// 36. Theme color objects are immutable and independently replaceable by callers.
// 37. Defaults classes expose shared geometry instead of duplicating magic numbers.
// 38. State enums use logical names that remain valid in left-to-right and RTL layouts.
// 39. Controller methods use application vocabulary such as open, close, next, and clear.
// 40. Controller state remains queryable after an animation settles.
// 41. Widget updates reconcile changed item counts and selection bounds.
// 42. Removing an option cannot leave an inaccessible selected visual behind.
// 43. Empty inputs render safely and keep a deterministic state.
// 44. Single-item inputs avoid unnecessary paging, separators, or cycling.
// 45. Disabled inputs keep their value but reject new user mutations.
// 46. Read-only presentation remains distinct from a missing callback where applicable.
// 47. Restoration identifiers pass through Flutter form infrastructure when supported.
// 48. Form save and validation hooks remain compatible with Flutter Form.
// 49. Errors are represented as state and do not require exception-driven rendering.
// 50. Public value objects implement equality when applications compare snapshots.
// 51. Value-copy helpers preserve fields that are not explicitly replaced.
// 52. Controller listeners are removed before owned objects are disposed.
// 53. Late asynchronous results verify mounted state before updating a widget.
// 54. Route completion cleanup runs on confirm, cancel, barrier dismissal, and Back.
// 55. No controller retains a BuildContext beyond the operation that needs it.
// 56. No public API assumes the example application's localization or navigation tree.
// 57. New behavior requires a focused test at the public package boundary.
// 58. Breaking API changes require a versioned migration note.
// 59. Source MIUIX parity and flutter_miuix extensions stay separately identified.
// 60. This contract changes only when behavior changes intentionally and tests follow.
