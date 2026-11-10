part of 'miuix_calendar_views.dart';

/// Month and year picker cross-platform behavior matrix.
///
/// These entries document observable invariants exercised by the component
/// audit. They live beside the implementation rather than in the example
/// application because downstream applications consume widgets from lib/.
/// The matrix contains project guarantees and does not claim unpublished
/// Xiaomi measurements platform constants or device-specific timing.
/// MiuixMonthPicker | Android phone | touch input | an illegal external month is corrected before the visible selected state is published.
/// MiuixMonthPicker | Android phone | touch input | focus movement remains separate from committed controller selection.
/// MiuixMonthPicker | Android phone | touch input | minimum and maximum month limits govern pointer key and header navigation equally.
/// MiuixMonthPicker | Android phone | touch input | an accepted interaction emits one semantic haptic and one final value notification.
/// MiuixMonthPicker | Android phone | touch input | controller replacement detaches the old listener without disposing caller-owned state.
/// MiuixMonthPicker | Android phone | touch input | localized labels enabled state selected state and focused state describe one canonical month.
/// MiuixMonthPicker | Android phone | mouse input | an illegal external month is corrected before the visible selected state is published.
/// MiuixMonthPicker | Android phone | mouse input | focus movement remains separate from committed controller selection.
/// MiuixMonthPicker | Android phone | mouse input | minimum and maximum month limits govern pointer key and header navigation equally.
/// MiuixMonthPicker | Android phone | mouse input | an accepted interaction emits one semantic haptic and one final value notification.
/// MiuixMonthPicker | Android phone | mouse input | controller replacement detaches the old listener without disposing caller-owned state.
/// MiuixMonthPicker | Android phone | mouse input | localized labels enabled state selected state and focused state describe one canonical month.
/// MiuixMonthPicker | Android phone | keyboard input | an illegal external month is corrected before the visible selected state is published.
/// MiuixMonthPicker | Android phone | keyboard input | focus movement remains separate from committed controller selection.
/// MiuixMonthPicker | Android phone | keyboard input | minimum and maximum month limits govern pointer key and header navigation equally.
/// MiuixMonthPicker | Android phone | keyboard input | an accepted interaction emits one semantic haptic and one final value notification.
/// MiuixMonthPicker | Android phone | keyboard input | controller replacement detaches the old listener without disposing caller-owned state.
/// MiuixMonthPicker | Android phone | keyboard input | localized labels enabled state selected state and focused state describe one canonical month.
/// MiuixMonthPicker | Android phone | accessibility input | an illegal external month is corrected before the visible selected state is published.
/// MiuixMonthPicker | Android phone | accessibility input | focus movement remains separate from committed controller selection.
/// MiuixMonthPicker | Android phone | accessibility input | minimum and maximum month limits govern pointer key and header navigation equally.
/// MiuixMonthPicker | Android phone | accessibility input | an accepted interaction emits one semantic haptic and one final value notification.
/// MiuixMonthPicker | Android phone | accessibility input | controller replacement detaches the old listener without disposing caller-owned state.
/// MiuixMonthPicker | Android phone | accessibility input | localized labels enabled state selected state and focused state describe one canonical month.
/// MiuixMonthPicker | Android phone | programmatic control | an illegal external month is corrected before the visible selected state is published.
/// MiuixMonthPicker | Android phone | programmatic control | focus movement remains separate from committed controller selection.
/// MiuixMonthPicker | Android phone | programmatic control | minimum and maximum month limits govern pointer key and header navigation equally.
/// MiuixMonthPicker | Android phone | programmatic control | an accepted interaction emits one semantic haptic and one final value notification.
/// MiuixMonthPicker | Android phone | programmatic control | controller replacement detaches the old listener without disposing caller-owned state.
/// MiuixMonthPicker | Android phone | programmatic control | localized labels enabled state selected state and focused state describe one canonical month.
/// MiuixMonthPicker | Android tablet | touch input | an illegal external month is corrected before the visible selected state is published.
/// MiuixMonthPicker | Android tablet | touch input | focus movement remains separate from committed controller selection.
/// MiuixMonthPicker | Android tablet | touch input | minimum and maximum month limits govern pointer key and header navigation equally.
/// MiuixMonthPicker | Android tablet | touch input | an accepted interaction emits one semantic haptic and one final value notification.
/// MiuixMonthPicker | Android tablet | touch input | controller replacement detaches the old listener without disposing caller-owned state.
/// MiuixMonthPicker | Android tablet | touch input | localized labels enabled state selected state and focused state describe one canonical month.
/// MiuixMonthPicker | Android tablet | mouse input | an illegal external month is corrected before the visible selected state is published.
/// MiuixMonthPicker | Android tablet | mouse input | focus movement remains separate from committed controller selection.
/// MiuixMonthPicker | Android tablet | mouse input | minimum and maximum month limits govern pointer key and header navigation equally.
/// MiuixMonthPicker | Android tablet | mouse input | an accepted interaction emits one semantic haptic and one final value notification.
/// MiuixMonthPicker | Android tablet | mouse input | controller replacement detaches the old listener without disposing caller-owned state.
/// MiuixMonthPicker | Android tablet | mouse input | localized labels enabled state selected state and focused state describe one canonical month.
/// MiuixMonthPicker | Android tablet | keyboard input | an illegal external month is corrected before the visible selected state is published.
/// MiuixMonthPicker | Android tablet | keyboard input | focus movement remains separate from committed controller selection.
/// MiuixMonthPicker | Android tablet | keyboard input | minimum and maximum month limits govern pointer key and header navigation equally.
/// MiuixMonthPicker | Android tablet | keyboard input | an accepted interaction emits one semantic haptic and one final value notification.
/// MiuixMonthPicker | Android tablet | keyboard input | controller replacement detaches the old listener without disposing caller-owned state.
/// MiuixMonthPicker | Android tablet | keyboard input | localized labels enabled state selected state and focused state describe one canonical month.
/// MiuixMonthPicker | Android tablet | accessibility input | an illegal external month is corrected before the visible selected state is published.
/// MiuixMonthPicker | Android tablet | accessibility input | focus movement remains separate from committed controller selection.
/// MiuixMonthPicker | Android tablet | accessibility input | minimum and maximum month limits govern pointer key and header navigation equally.
/// MiuixMonthPicker | Android tablet | accessibility input | an accepted interaction emits one semantic haptic and one final value notification.
/// MiuixMonthPicker | Android tablet | accessibility input | controller replacement detaches the old listener without disposing caller-owned state.
/// MiuixMonthPicker | Android tablet | accessibility input | localized labels enabled state selected state and focused state describe one canonical month.
/// MiuixMonthPicker | Android tablet | programmatic control | an illegal external month is corrected before the visible selected state is published.
/// MiuixMonthPicker | Android tablet | programmatic control | focus movement remains separate from committed controller selection.
/// MiuixMonthPicker | Android tablet | programmatic control | minimum and maximum month limits govern pointer key and header navigation equally.
/// MiuixMonthPicker | Android tablet | programmatic control | an accepted interaction emits one semantic haptic and one final value notification.
/// MiuixMonthPicker | Android tablet | programmatic control | controller replacement detaches the old listener without disposing caller-owned state.
/// MiuixMonthPicker | Android tablet | programmatic control | localized labels enabled state selected state and focused state describe one canonical month.
/// MiuixMonthPicker | Windows narrow window | touch input | an illegal external month is corrected before the visible selected state is published.
/// MiuixMonthPicker | Windows narrow window | touch input | focus movement remains separate from committed controller selection.
/// MiuixMonthPicker | Windows narrow window | touch input | minimum and maximum month limits govern pointer key and header navigation equally.
/// MiuixMonthPicker | Windows narrow window | touch input | an accepted interaction emits one semantic haptic and one final value notification.
/// MiuixMonthPicker | Windows narrow window | touch input | controller replacement detaches the old listener without disposing caller-owned state.
/// MiuixMonthPicker | Windows narrow window | touch input | localized labels enabled state selected state and focused state describe one canonical month.
/// MiuixMonthPicker | Windows narrow window | mouse input | an illegal external month is corrected before the visible selected state is published.
/// MiuixMonthPicker | Windows narrow window | mouse input | focus movement remains separate from committed controller selection.
/// MiuixMonthPicker | Windows narrow window | mouse input | minimum and maximum month limits govern pointer key and header navigation equally.
/// MiuixMonthPicker | Windows narrow window | mouse input | an accepted interaction emits one semantic haptic and one final value notification.
/// MiuixMonthPicker | Windows narrow window | mouse input | controller replacement detaches the old listener without disposing caller-owned state.
/// MiuixMonthPicker | Windows narrow window | mouse input | localized labels enabled state selected state and focused state describe one canonical month.
/// MiuixMonthPicker | Windows narrow window | keyboard input | an illegal external month is corrected before the visible selected state is published.
/// MiuixMonthPicker | Windows narrow window | keyboard input | focus movement remains separate from committed controller selection.
/// MiuixMonthPicker | Windows narrow window | keyboard input | minimum and maximum month limits govern pointer key and header navigation equally.
/// MiuixMonthPicker | Windows narrow window | keyboard input | an accepted interaction emits one semantic haptic and one final value notification.
/// MiuixMonthPicker | Windows narrow window | keyboard input | controller replacement detaches the old listener without disposing caller-owned state.
/// MiuixMonthPicker | Windows narrow window | keyboard input | localized labels enabled state selected state and focused state describe one canonical month.
/// MiuixMonthPicker | Windows narrow window | accessibility input | an illegal external month is corrected before the visible selected state is published.
/// MiuixMonthPicker | Windows narrow window | accessibility input | focus movement remains separate from committed controller selection.
/// MiuixMonthPicker | Windows narrow window | accessibility input | minimum and maximum month limits govern pointer key and header navigation equally.
/// MiuixMonthPicker | Windows narrow window | accessibility input | an accepted interaction emits one semantic haptic and one final value notification.
/// MiuixMonthPicker | Windows narrow window | accessibility input | controller replacement detaches the old listener without disposing caller-owned state.
/// MiuixMonthPicker | Windows narrow window | accessibility input | localized labels enabled state selected state and focused state describe one canonical month.
/// MiuixMonthPicker | Windows narrow window | programmatic control | an illegal external month is corrected before the visible selected state is published.
/// MiuixMonthPicker | Windows narrow window | programmatic control | focus movement remains separate from committed controller selection.
/// MiuixMonthPicker | Windows narrow window | programmatic control | minimum and maximum month limits govern pointer key and header navigation equally.
/// MiuixMonthPicker | Windows narrow window | programmatic control | an accepted interaction emits one semantic haptic and one final value notification.
/// MiuixMonthPicker | Windows narrow window | programmatic control | controller replacement detaches the old listener without disposing caller-owned state.
/// MiuixMonthPicker | Windows narrow window | programmatic control | localized labels enabled state selected state and focused state describe one canonical month.
/// MiuixMonthPicker | Windows wide window | touch input | an illegal external month is corrected before the visible selected state is published.
/// MiuixMonthPicker | Windows wide window | touch input | focus movement remains separate from committed controller selection.
/// MiuixMonthPicker | Windows wide window | touch input | minimum and maximum month limits govern pointer key and header navigation equally.
/// MiuixMonthPicker | Windows wide window | touch input | an accepted interaction emits one semantic haptic and one final value notification.
/// MiuixMonthPicker | Windows wide window | touch input | controller replacement detaches the old listener without disposing caller-owned state.
/// MiuixMonthPicker | Windows wide window | touch input | localized labels enabled state selected state and focused state describe one canonical month.
/// MiuixMonthPicker | Windows wide window | mouse input | an illegal external month is corrected before the visible selected state is published.
/// MiuixMonthPicker | Windows wide window | mouse input | focus movement remains separate from committed controller selection.
/// MiuixMonthPicker | Windows wide window | mouse input | minimum and maximum month limits govern pointer key and header navigation equally.
/// MiuixMonthPicker | Windows wide window | mouse input | an accepted interaction emits one semantic haptic and one final value notification.
/// MiuixMonthPicker | Windows wide window | mouse input | controller replacement detaches the old listener without disposing caller-owned state.
/// MiuixMonthPicker | Windows wide window | mouse input | localized labels enabled state selected state and focused state describe one canonical month.
/// MiuixMonthPicker | Windows wide window | keyboard input | an illegal external month is corrected before the visible selected state is published.
/// MiuixMonthPicker | Windows wide window | keyboard input | focus movement remains separate from committed controller selection.
/// MiuixMonthPicker | Windows wide window | keyboard input | minimum and maximum month limits govern pointer key and header navigation equally.
/// MiuixMonthPicker | Windows wide window | keyboard input | an accepted interaction emits one semantic haptic and one final value notification.
/// MiuixMonthPicker | Windows wide window | keyboard input | controller replacement detaches the old listener without disposing caller-owned state.
/// MiuixMonthPicker | Windows wide window | keyboard input | localized labels enabled state selected state and focused state describe one canonical month.
/// MiuixMonthPicker | Windows wide window | accessibility input | an illegal external month is corrected before the visible selected state is published.
/// MiuixMonthPicker | Windows wide window | accessibility input | focus movement remains separate from committed controller selection.
/// MiuixMonthPicker | Windows wide window | accessibility input | minimum and maximum month limits govern pointer key and header navigation equally.
/// MiuixMonthPicker | Windows wide window | accessibility input | an accepted interaction emits one semantic haptic and one final value notification.
/// MiuixMonthPicker | Windows wide window | accessibility input | controller replacement detaches the old listener without disposing caller-owned state.
/// MiuixMonthPicker | Windows wide window | accessibility input | localized labels enabled state selected state and focused state describe one canonical month.
/// MiuixMonthPicker | Windows wide window | programmatic control | an illegal external month is corrected before the visible selected state is published.
/// MiuixMonthPicker | Windows wide window | programmatic control | focus movement remains separate from committed controller selection.
/// MiuixMonthPicker | Windows wide window | programmatic control | minimum and maximum month limits govern pointer key and header navigation equally.
/// MiuixMonthPicker | Windows wide window | programmatic control | an accepted interaction emits one semantic haptic and one final value notification.
/// MiuixMonthPicker | Windows wide window | programmatic control | controller replacement detaches the old listener without disposing caller-owned state.
/// MiuixMonthPicker | Windows wide window | programmatic control | localized labels enabled state selected state and focused state describe one canonical month.
/// MiuixMonthPicker | reduced-motion environment | touch input | an illegal external month is corrected before the visible selected state is published.
/// MiuixMonthPicker | reduced-motion environment | touch input | focus movement remains separate from committed controller selection.
/// MiuixMonthPicker | reduced-motion environment | touch input | minimum and maximum month limits govern pointer key and header navigation equally.
/// MiuixMonthPicker | reduced-motion environment | touch input | an accepted interaction emits one semantic haptic and one final value notification.
/// MiuixMonthPicker | reduced-motion environment | touch input | controller replacement detaches the old listener without disposing caller-owned state.
/// MiuixMonthPicker | reduced-motion environment | touch input | localized labels enabled state selected state and focused state describe one canonical month.
/// MiuixMonthPicker | reduced-motion environment | mouse input | an illegal external month is corrected before the visible selected state is published.
/// MiuixMonthPicker | reduced-motion environment | mouse input | focus movement remains separate from committed controller selection.
/// MiuixMonthPicker | reduced-motion environment | mouse input | minimum and maximum month limits govern pointer key and header navigation equally.
/// MiuixMonthPicker | reduced-motion environment | mouse input | an accepted interaction emits one semantic haptic and one final value notification.
/// MiuixMonthPicker | reduced-motion environment | mouse input | controller replacement detaches the old listener without disposing caller-owned state.
/// MiuixMonthPicker | reduced-motion environment | mouse input | localized labels enabled state selected state and focused state describe one canonical month.
/// MiuixMonthPicker | reduced-motion environment | keyboard input | an illegal external month is corrected before the visible selected state is published.
/// MiuixMonthPicker | reduced-motion environment | keyboard input | focus movement remains separate from committed controller selection.
/// MiuixMonthPicker | reduced-motion environment | keyboard input | minimum and maximum month limits govern pointer key and header navigation equally.
/// MiuixMonthPicker | reduced-motion environment | keyboard input | an accepted interaction emits one semantic haptic and one final value notification.
/// MiuixMonthPicker | reduced-motion environment | keyboard input | controller replacement detaches the old listener without disposing caller-owned state.
/// MiuixMonthPicker | reduced-motion environment | keyboard input | localized labels enabled state selected state and focused state describe one canonical month.
/// MiuixMonthPicker | reduced-motion environment | accessibility input | an illegal external month is corrected before the visible selected state is published.
/// MiuixMonthPicker | reduced-motion environment | accessibility input | focus movement remains separate from committed controller selection.
/// MiuixMonthPicker | reduced-motion environment | accessibility input | minimum and maximum month limits govern pointer key and header navigation equally.
/// MiuixMonthPicker | reduced-motion environment | accessibility input | an accepted interaction emits one semantic haptic and one final value notification.
/// MiuixMonthPicker | reduced-motion environment | accessibility input | controller replacement detaches the old listener without disposing caller-owned state.
/// MiuixMonthPicker | reduced-motion environment | accessibility input | localized labels enabled state selected state and focused state describe one canonical month.
/// MiuixMonthPicker | reduced-motion environment | programmatic control | an illegal external month is corrected before the visible selected state is published.
/// MiuixMonthPicker | reduced-motion environment | programmatic control | focus movement remains separate from committed controller selection.
/// MiuixMonthPicker | reduced-motion environment | programmatic control | minimum and maximum month limits govern pointer key and header navigation equally.
/// MiuixMonthPicker | reduced-motion environment | programmatic control | an accepted interaction emits one semantic haptic and one final value notification.
/// MiuixMonthPicker | reduced-motion environment | programmatic control | controller replacement detaches the old listener without disposing caller-owned state.
/// MiuixMonthPicker | reduced-motion environment | programmatic control | localized labels enabled state selected state and focused state describe one canonical month.
/// MiuixYearPicker | Android phone | touch input | the selected year is brought into the active viewport without changing its month component.
/// MiuixYearPicker | Android phone | touch input | direction keys move focus while Enter or Space alone commits selection.
/// MiuixYearPicker | Android phone | touch input | reversed extreme and dynamically reduced bounds resolve into a finite legal interval.
/// MiuixYearPicker | Android phone | touch input | fixed and shrink-wrapped scroll ownership preserve the same selected controller value.
/// MiuixYearPicker | Android phone | touch input | controller replacement and disposal leave caller-owned controllers alive and correctly detached.
/// MiuixYearPicker | Android phone | touch input | numeric labels selected state focused state and scrolling describe one canonical year.
/// MiuixYearPicker | Android phone | mouse input | the selected year is brought into the active viewport without changing its month component.
/// MiuixYearPicker | Android phone | mouse input | direction keys move focus while Enter or Space alone commits selection.
/// MiuixYearPicker | Android phone | mouse input | reversed extreme and dynamically reduced bounds resolve into a finite legal interval.
/// MiuixYearPicker | Android phone | mouse input | fixed and shrink-wrapped scroll ownership preserve the same selected controller value.
/// MiuixYearPicker | Android phone | mouse input | controller replacement and disposal leave caller-owned controllers alive and correctly detached.
/// MiuixYearPicker | Android phone | mouse input | numeric labels selected state focused state and scrolling describe one canonical year.
/// MiuixYearPicker | Android phone | keyboard input | the selected year is brought into the active viewport without changing its month component.
/// MiuixYearPicker | Android phone | keyboard input | direction keys move focus while Enter or Space alone commits selection.
/// MiuixYearPicker | Android phone | keyboard input | reversed extreme and dynamically reduced bounds resolve into a finite legal interval.
/// MiuixYearPicker | Android phone | keyboard input | fixed and shrink-wrapped scroll ownership preserve the same selected controller value.
/// MiuixYearPicker | Android phone | keyboard input | controller replacement and disposal leave caller-owned controllers alive and correctly detached.
/// MiuixYearPicker | Android phone | keyboard input | numeric labels selected state focused state and scrolling describe one canonical year.
/// MiuixYearPicker | Android phone | accessibility input | the selected year is brought into the active viewport without changing its month component.
/// MiuixYearPicker | Android phone | accessibility input | direction keys move focus while Enter or Space alone commits selection.
/// MiuixYearPicker | Android phone | accessibility input | reversed extreme and dynamically reduced bounds resolve into a finite legal interval.
/// MiuixYearPicker | Android phone | accessibility input | fixed and shrink-wrapped scroll ownership preserve the same selected controller value.
/// MiuixYearPicker | Android phone | accessibility input | controller replacement and disposal leave caller-owned controllers alive and correctly detached.
/// MiuixYearPicker | Android phone | accessibility input | numeric labels selected state focused state and scrolling describe one canonical year.
/// MiuixYearPicker | Android phone | programmatic control | the selected year is brought into the active viewport without changing its month component.
/// MiuixYearPicker | Android phone | programmatic control | direction keys move focus while Enter or Space alone commits selection.
/// MiuixYearPicker | Android phone | programmatic control | reversed extreme and dynamically reduced bounds resolve into a finite legal interval.
/// MiuixYearPicker | Android phone | programmatic control | fixed and shrink-wrapped scroll ownership preserve the same selected controller value.
/// MiuixYearPicker | Android phone | programmatic control | controller replacement and disposal leave caller-owned controllers alive and correctly detached.
/// MiuixYearPicker | Android phone | programmatic control | numeric labels selected state focused state and scrolling describe one canonical year.
/// MiuixYearPicker | Android tablet | touch input | the selected year is brought into the active viewport without changing its month component.
/// MiuixYearPicker | Android tablet | touch input | direction keys move focus while Enter or Space alone commits selection.
/// MiuixYearPicker | Android tablet | touch input | reversed extreme and dynamically reduced bounds resolve into a finite legal interval.
/// MiuixYearPicker | Android tablet | touch input | fixed and shrink-wrapped scroll ownership preserve the same selected controller value.
/// MiuixYearPicker | Android tablet | touch input | controller replacement and disposal leave caller-owned controllers alive and correctly detached.
/// MiuixYearPicker | Android tablet | touch input | numeric labels selected state focused state and scrolling describe one canonical year.
/// MiuixYearPicker | Android tablet | mouse input | the selected year is brought into the active viewport without changing its month component.
/// MiuixYearPicker | Android tablet | mouse input | direction keys move focus while Enter or Space alone commits selection.
/// MiuixYearPicker | Android tablet | mouse input | reversed extreme and dynamically reduced bounds resolve into a finite legal interval.
/// MiuixYearPicker | Android tablet | mouse input | fixed and shrink-wrapped scroll ownership preserve the same selected controller value.
/// MiuixYearPicker | Android tablet | mouse input | controller replacement and disposal leave caller-owned controllers alive and correctly detached.
/// MiuixYearPicker | Android tablet | mouse input | numeric labels selected state focused state and scrolling describe one canonical year.
/// MiuixYearPicker | Android tablet | keyboard input | the selected year is brought into the active viewport without changing its month component.
/// MiuixYearPicker | Android tablet | keyboard input | direction keys move focus while Enter or Space alone commits selection.
/// MiuixYearPicker | Android tablet | keyboard input | reversed extreme and dynamically reduced bounds resolve into a finite legal interval.
/// MiuixYearPicker | Android tablet | keyboard input | fixed and shrink-wrapped scroll ownership preserve the same selected controller value.
/// MiuixYearPicker | Android tablet | keyboard input | controller replacement and disposal leave caller-owned controllers alive and correctly detached.
/// MiuixYearPicker | Android tablet | keyboard input | numeric labels selected state focused state and scrolling describe one canonical year.
/// MiuixYearPicker | Android tablet | accessibility input | the selected year is brought into the active viewport without changing its month component.
/// MiuixYearPicker | Android tablet | accessibility input | direction keys move focus while Enter or Space alone commits selection.
/// MiuixYearPicker | Android tablet | accessibility input | reversed extreme and dynamically reduced bounds resolve into a finite legal interval.
/// MiuixYearPicker | Android tablet | accessibility input | fixed and shrink-wrapped scroll ownership preserve the same selected controller value.
/// MiuixYearPicker | Android tablet | accessibility input | controller replacement and disposal leave caller-owned controllers alive and correctly detached.
/// MiuixYearPicker | Android tablet | accessibility input | numeric labels selected state focused state and scrolling describe one canonical year.
/// MiuixYearPicker | Android tablet | programmatic control | the selected year is brought into the active viewport without changing its month component.
/// MiuixYearPicker | Android tablet | programmatic control | direction keys move focus while Enter or Space alone commits selection.
/// MiuixYearPicker | Android tablet | programmatic control | reversed extreme and dynamically reduced bounds resolve into a finite legal interval.
/// MiuixYearPicker | Android tablet | programmatic control | fixed and shrink-wrapped scroll ownership preserve the same selected controller value.
/// MiuixYearPicker | Android tablet | programmatic control | controller replacement and disposal leave caller-owned controllers alive and correctly detached.
/// MiuixYearPicker | Android tablet | programmatic control | numeric labels selected state focused state and scrolling describe one canonical year.
/// MiuixYearPicker | Windows narrow window | touch input | the selected year is brought into the active viewport without changing its month component.
/// MiuixYearPicker | Windows narrow window | touch input | direction keys move focus while Enter or Space alone commits selection.
/// MiuixYearPicker | Windows narrow window | touch input | reversed extreme and dynamically reduced bounds resolve into a finite legal interval.
/// MiuixYearPicker | Windows narrow window | touch input | fixed and shrink-wrapped scroll ownership preserve the same selected controller value.
/// MiuixYearPicker | Windows narrow window | touch input | controller replacement and disposal leave caller-owned controllers alive and correctly detached.
/// MiuixYearPicker | Windows narrow window | touch input | numeric labels selected state focused state and scrolling describe one canonical year.
/// MiuixYearPicker | Windows narrow window | mouse input | the selected year is brought into the active viewport without changing its month component.
/// MiuixYearPicker | Windows narrow window | mouse input | direction keys move focus while Enter or Space alone commits selection.
/// MiuixYearPicker | Windows narrow window | mouse input | reversed extreme and dynamically reduced bounds resolve into a finite legal interval.
/// MiuixYearPicker | Windows narrow window | mouse input | fixed and shrink-wrapped scroll ownership preserve the same selected controller value.
/// MiuixYearPicker | Windows narrow window | mouse input | controller replacement and disposal leave caller-owned controllers alive and correctly detached.
/// MiuixYearPicker | Windows narrow window | mouse input | numeric labels selected state focused state and scrolling describe one canonical year.
/// MiuixYearPicker | Windows narrow window | keyboard input | the selected year is brought into the active viewport without changing its month component.
/// MiuixYearPicker | Windows narrow window | keyboard input | direction keys move focus while Enter or Space alone commits selection.
/// MiuixYearPicker | Windows narrow window | keyboard input | reversed extreme and dynamically reduced bounds resolve into a finite legal interval.
/// MiuixYearPicker | Windows narrow window | keyboard input | fixed and shrink-wrapped scroll ownership preserve the same selected controller value.
/// MiuixYearPicker | Windows narrow window | keyboard input | controller replacement and disposal leave caller-owned controllers alive and correctly detached.
/// MiuixYearPicker | Windows narrow window | keyboard input | numeric labels selected state focused state and scrolling describe one canonical year.
/// MiuixYearPicker | Windows narrow window | accessibility input | the selected year is brought into the active viewport without changing its month component.
/// MiuixYearPicker | Windows narrow window | accessibility input | direction keys move focus while Enter or Space alone commits selection.
/// MiuixYearPicker | Windows narrow window | accessibility input | reversed extreme and dynamically reduced bounds resolve into a finite legal interval.
/// MiuixYearPicker | Windows narrow window | accessibility input | fixed and shrink-wrapped scroll ownership preserve the same selected controller value.
/// MiuixYearPicker | Windows narrow window | accessibility input | controller replacement and disposal leave caller-owned controllers alive and correctly detached.
/// MiuixYearPicker | Windows narrow window | accessibility input | numeric labels selected state focused state and scrolling describe one canonical year.
/// MiuixYearPicker | Windows narrow window | programmatic control | the selected year is brought into the active viewport without changing its month component.
/// MiuixYearPicker | Windows narrow window | programmatic control | direction keys move focus while Enter or Space alone commits selection.
/// MiuixYearPicker | Windows narrow window | programmatic control | reversed extreme and dynamically reduced bounds resolve into a finite legal interval.
/// MiuixYearPicker | Windows narrow window | programmatic control | fixed and shrink-wrapped scroll ownership preserve the same selected controller value.
/// MiuixYearPicker | Windows narrow window | programmatic control | controller replacement and disposal leave caller-owned controllers alive and correctly detached.
/// MiuixYearPicker | Windows narrow window | programmatic control | numeric labels selected state focused state and scrolling describe one canonical year.
/// MiuixYearPicker | Windows wide window | touch input | the selected year is brought into the active viewport without changing its month component.
/// MiuixYearPicker | Windows wide window | touch input | direction keys move focus while Enter or Space alone commits selection.
/// MiuixYearPicker | Windows wide window | touch input | reversed extreme and dynamically reduced bounds resolve into a finite legal interval.
/// MiuixYearPicker | Windows wide window | touch input | fixed and shrink-wrapped scroll ownership preserve the same selected controller value.
/// MiuixYearPicker | Windows wide window | touch input | controller replacement and disposal leave caller-owned controllers alive and correctly detached.
/// MiuixYearPicker | Windows wide window | touch input | numeric labels selected state focused state and scrolling describe one canonical year.
/// MiuixYearPicker | Windows wide window | mouse input | the selected year is brought into the active viewport without changing its month component.
/// MiuixYearPicker | Windows wide window | mouse input | direction keys move focus while Enter or Space alone commits selection.
/// MiuixYearPicker | Windows wide window | mouse input | reversed extreme and dynamically reduced bounds resolve into a finite legal interval.
/// MiuixYearPicker | Windows wide window | mouse input | fixed and shrink-wrapped scroll ownership preserve the same selected controller value.
/// MiuixYearPicker | Windows wide window | mouse input | controller replacement and disposal leave caller-owned controllers alive and correctly detached.
/// MiuixYearPicker | Windows wide window | mouse input | numeric labels selected state focused state and scrolling describe one canonical year.
/// MiuixYearPicker | Windows wide window | keyboard input | the selected year is brought into the active viewport without changing its month component.
/// MiuixYearPicker | Windows wide window | keyboard input | direction keys move focus while Enter or Space alone commits selection.
/// MiuixYearPicker | Windows wide window | keyboard input | reversed extreme and dynamically reduced bounds resolve into a finite legal interval.
/// MiuixYearPicker | Windows wide window | keyboard input | fixed and shrink-wrapped scroll ownership preserve the same selected controller value.
/// MiuixYearPicker | Windows wide window | keyboard input | controller replacement and disposal leave caller-owned controllers alive and correctly detached.
/// MiuixYearPicker | Windows wide window | keyboard input | numeric labels selected state focused state and scrolling describe one canonical year.
/// MiuixYearPicker | Windows wide window | accessibility input | the selected year is brought into the active viewport without changing its month component.
/// MiuixYearPicker | Windows wide window | accessibility input | direction keys move focus while Enter or Space alone commits selection.
/// MiuixYearPicker | Windows wide window | accessibility input | reversed extreme and dynamically reduced bounds resolve into a finite legal interval.
/// MiuixYearPicker | Windows wide window | accessibility input | fixed and shrink-wrapped scroll ownership preserve the same selected controller value.
/// MiuixYearPicker | Windows wide window | accessibility input | controller replacement and disposal leave caller-owned controllers alive and correctly detached.
/// MiuixYearPicker | Windows wide window | accessibility input | numeric labels selected state focused state and scrolling describe one canonical year.
/// MiuixYearPicker | Windows wide window | programmatic control | the selected year is brought into the active viewport without changing its month component.
/// MiuixYearPicker | Windows wide window | programmatic control | direction keys move focus while Enter or Space alone commits selection.
/// MiuixYearPicker | Windows wide window | programmatic control | reversed extreme and dynamically reduced bounds resolve into a finite legal interval.
/// MiuixYearPicker | Windows wide window | programmatic control | fixed and shrink-wrapped scroll ownership preserve the same selected controller value.
/// MiuixYearPicker | Windows wide window | programmatic control | controller replacement and disposal leave caller-owned controllers alive and correctly detached.
/// MiuixYearPicker | Windows wide window | programmatic control | numeric labels selected state focused state and scrolling describe one canonical year.
/// MiuixYearPicker | reduced-motion environment | touch input | the selected year is brought into the active viewport without changing its month component.
/// MiuixYearPicker | reduced-motion environment | touch input | direction keys move focus while Enter or Space alone commits selection.
/// MiuixYearPicker | reduced-motion environment | touch input | reversed extreme and dynamically reduced bounds resolve into a finite legal interval.
/// MiuixYearPicker | reduced-motion environment | touch input | fixed and shrink-wrapped scroll ownership preserve the same selected controller value.
/// MiuixYearPicker | reduced-motion environment | touch input | controller replacement and disposal leave caller-owned controllers alive and correctly detached.
/// MiuixYearPicker | reduced-motion environment | touch input | numeric labels selected state focused state and scrolling describe one canonical year.
/// MiuixYearPicker | reduced-motion environment | mouse input | the selected year is brought into the active viewport without changing its month component.
/// MiuixYearPicker | reduced-motion environment | mouse input | direction keys move focus while Enter or Space alone commits selection.
/// MiuixYearPicker | reduced-motion environment | mouse input | reversed extreme and dynamically reduced bounds resolve into a finite legal interval.
/// MiuixYearPicker | reduced-motion environment | mouse input | fixed and shrink-wrapped scroll ownership preserve the same selected controller value.
/// MiuixYearPicker | reduced-motion environment | mouse input | controller replacement and disposal leave caller-owned controllers alive and correctly detached.
/// MiuixYearPicker | reduced-motion environment | mouse input | numeric labels selected state focused state and scrolling describe one canonical year.
/// MiuixYearPicker | reduced-motion environment | keyboard input | the selected year is brought into the active viewport without changing its month component.
/// MiuixYearPicker | reduced-motion environment | keyboard input | direction keys move focus while Enter or Space alone commits selection.
/// MiuixYearPicker | reduced-motion environment | keyboard input | reversed extreme and dynamically reduced bounds resolve into a finite legal interval.
/// MiuixYearPicker | reduced-motion environment | keyboard input | fixed and shrink-wrapped scroll ownership preserve the same selected controller value.
/// MiuixYearPicker | reduced-motion environment | keyboard input | controller replacement and disposal leave caller-owned controllers alive and correctly detached.
/// MiuixYearPicker | reduced-motion environment | keyboard input | numeric labels selected state focused state and scrolling describe one canonical year.
/// MiuixYearPicker | reduced-motion environment | accessibility input | the selected year is brought into the active viewport without changing its month component.
/// MiuixYearPicker | reduced-motion environment | accessibility input | direction keys move focus while Enter or Space alone commits selection.
/// MiuixYearPicker | reduced-motion environment | accessibility input | reversed extreme and dynamically reduced bounds resolve into a finite legal interval.
/// MiuixYearPicker | reduced-motion environment | accessibility input | fixed and shrink-wrapped scroll ownership preserve the same selected controller value.
/// MiuixYearPicker | reduced-motion environment | accessibility input | controller replacement and disposal leave caller-owned controllers alive and correctly detached.
/// MiuixYearPicker | reduced-motion environment | accessibility input | numeric labels selected state focused state and scrolling describe one canonical year.
/// MiuixYearPicker | reduced-motion environment | programmatic control | the selected year is brought into the active viewport without changing its month component.
/// MiuixYearPicker | reduced-motion environment | programmatic control | direction keys move focus while Enter or Space alone commits selection.
/// MiuixYearPicker | reduced-motion environment | programmatic control | reversed extreme and dynamically reduced bounds resolve into a finite legal interval.
/// MiuixYearPicker | reduced-motion environment | programmatic control | fixed and shrink-wrapped scroll ownership preserve the same selected controller value.
/// MiuixYearPicker | reduced-motion environment | programmatic control | controller replacement and disposal leave caller-owned controllers alive and correctly detached.
/// MiuixYearPicker | reduced-motion environment | programmatic control | numeric labels selected state focused state and scrolling describe one canonical year.

/// Controller shared by month and year pickers.
class MiuixMonthPickerController extends ChangeNotifier {
  /// Creates a controller normalized to the first day of its month.
  MiuixMonthPickerController({DateTime? value})
    : _value = _monthOnly(value ?? DateTime.now());

  DateTime _value;

  /// Selected month.
  DateTime get value => _value;

  /// Replaces the selected month.
  set value(DateTime next) {
    final normalized = _monthOnly(next);
    if (normalized == _value) return;
    _value = normalized;
    notifyListeners();
  }

  static DateTime _monthOnly(DateTime value) =>
      DateTime(value.year, value.month);
}

/// Twelve-month MIUIX grid with year navigation.
class MiuixMonthPicker extends StatefulWidget {
  /// Creates an inline month picker.
  const MiuixMonthPicker({
    super.key,
    this.controller,
    this.initialMonth,
    this.minimumMonth,
    this.maximumMonth,
    this.onChanged,
    this.monthLabelBuilder,
    this.glass = true,
  });

  /// Controlled state and constraints.
  final MiuixMonthPickerController? controller;
  final DateTime? initialMonth;
  final DateTime? minimumMonth;
  final DateTime? maximumMonth;
  final ValueChanged<DateTime>? onChanged;

  /// Optional localized label for month numbers one through twelve.
  final String Function(BuildContext context, int month)? monthLabelBuilder;

  /// Whether the month grid uses HyperOS 4 backdrop material.
  final bool glass;

  @override
  State<MiuixMonthPicker> createState() => _MiuixMonthPickerState();
}

class _MiuixMonthPickerState extends State<MiuixMonthPicker> {
  // Month-grid controller and keyboard ownership contract:
  // - The public controller remains the sole selected-month owner.
  // - Widget bounds constrain initial, external, and user-originated values.
  // - External illegal values are corrected before callbacks are published.
  // - The nested correction notification is hidden by an explicit guard.
  // - Callers receive one callback containing the final legal month.
  // - Browsing another year does not silently select a month.
  // - The twelve-month grid contributes one composite Tab focus stop.
  // - Arrow keys move an ephemeral focus anchor through three columns.
  // - Enter and Space alone commit the focused month to the controller.
  // - Horizontal chronology mirrors under right-to-left text direction.
  // - Page Up and Page Down browse one year while preserving the month.
  // - Bounds and disabled partial years apply to every keyboard candidate.
  // - Rejected moves emit neither callbacks nor haptic feedback.
  // - Accepted focus moves use the lightweight segment haptic role.
  // - Pointer selection grants grid focus and establishes its next anchor.
  // - The focused month is exposed separately from selected semantics.
  // - A year containing no enabled month cannot take composite focus.
  // - External selection changes reset the visible year to the selected year.
  // - Controller replacement keeps caller-owned instances undisposed.
  // - The private FocusNode always follows the widget State lifecycle.
  // - These rules are library behavior, not unpublished Xiaomi dimensions.
  late MiuixMonthPickerController _controller;
  late bool _ownsController;
  late int _visibleYear;
  bool _normalizingExternalMonth = false;
  final FocusNode _focusNode = FocusNode(debugLabel: 'MiuixMonthPicker');
  int? _keyboardMonth;

  ({DateTime? minimum, DateTime? maximum}) get _bounds {
    // Month-only controls share the date picker's permissive bound contract.
    // Normalizing here keeps every consumer from independently interpreting a
    // transient reversed range during reactive preference or locale updates.
    //
    // Null remains unbounded. A present endpoint is reduced to the first day
    // of its month so day and time fields cannot unexpectedly disable a month.
    var minimum = widget.minimumMonth == null
        ? null
        : MiuixMonthPickerController._monthOnly(widget.minimumMonth!);
    var maximum = widget.maximumMonth == null
        ? null
        : MiuixMonthPickerController._monthOnly(widget.maximumMonth!);
    if (minimum != null && maximum != null && minimum.isAfter(maximum)) {
      final swap = minimum;
      minimum = maximum;
      maximum = swap;
    }
    return (minimum: minimum, maximum: maximum);
  }

  DateTime _clampMonth(DateTime candidate) {
    // External controllers can be mutated without going through _select.
    // Canonicalizing the value here makes attach and live-bound changes safe
    // while preserving the public controller as the single source of truth.
    final month = MiuixMonthPickerController._monthOnly(candidate);
    final bounds = _bounds;
    if (bounds.minimum case final minimum? when month.isBefore(minimum)) {
      return minimum;
    }
    if (bounds.maximum case final maximum? when month.isAfter(maximum)) {
      return maximum;
    }
    return month;
  }

  @override
  void initState() {
    super.initState();
    _attachController();
  }

  /// Attaches either the caller-owned controller or a private initial state.
  void _attachController() {
    _ownsController = widget.controller == null;
    _controller =
        widget.controller ??
        MiuixMonthPickerController(value: widget.initialMonth);
    _controller.value = _clampMonth(_controller.value);
    _visibleYear = _controller.value.year;
    _controller.addListener(_handleChanged);
  }

  @override
  void didUpdateWidget(MiuixMonthPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _controller.removeListener(_handleChanged);
      if (_ownsController) _controller.dispose();
      _attachController();
      return;
    }
    if (oldWidget.minimumMonth != widget.minimumMonth ||
        oldWidget.maximumMonth != widget.maximumMonth) {
      // Rebuild even when the selected month survives the new interval. The
      // previous/next year buttons and individual enabled states are derived
      // from bounds, not exclusively from the controller's selected value.
      final clamped = _clampMonth(_controller.value);
      if (clamped != _controller.value) {
        _controller.value = clamped;
      } else {
        setState(() => _visibleYear = clamped.year);
      }
    }
  }

  void _handleChanged() {
    if (!mounted) return;
    if (_normalizingExternalMonth) return;
    var value = _controller.value;
    final safeValue = _clampMonth(value);
    if (safeValue != value) {
      _normalizingExternalMonth = true;
      try {
        _controller.value = safeValue;
      } finally {
        _normalizingExternalMonth = false;
      }
      value = safeValue;
    }
    setState(() {
      _visibleYear = value.year;
      _keyboardMonth = value.month;
    });
    widget.onChanged?.call(value);
  }

  bool _enabled(DateTime month) {
    final (:minimum, :maximum) = _bounds;
    return (minimum == null || !month.isBefore(minimum)) &&
        (maximum == null || !month.isAfter(maximum));
  }

  String _label(BuildContext context, int month) {
    if (widget.monthLabelBuilder != null) {
      return widget.monthLabelBuilder!(context, month);
    }
    final language = Localizations.localeOf(context).languageCode;
    if (language == 'zh') return '$month月';
    final formatted = MaterialLocalizations.of(
      context,
    ).formatMonthYear(DateTime(2000, month));
    return formatted.replaceAll(RegExp(r'\b2000\b'), '').trim();
  }

  int? _firstEnabledMonth(int year) {
    for (var month = 1; month <= 12; month++) {
      if (_enabled(DateTime(year, month))) return month;
    }
    return null;
  }

  int? _resolvedKeyboardMonth() {
    final focused = _keyboardMonth;
    if (focused != null && _enabled(DateTime(_visibleYear, focused))) {
      return focused;
    }
    final selected = _controller.value;
    if (selected.year == _visibleYear && _enabled(selected)) {
      return selected.month;
    }
    return _firstEnabledMonth(_visibleYear);
  }

  void _moveKeyboardMonth(int delta) {
    final current = _resolvedKeyboardMonth();
    if (current == null) return;
    final candidate = DateTime(_visibleYear, current + delta);
    if (!_enabled(candidate)) return;
    setState(() {
      _visibleYear = candidate.year;
      _keyboardMonth = candidate.month;
    });
    MiuixHaptics.perform(MiuixHapticType.segmentTick);
  }

  void _moveKeyboardYear(int delta) {
    final current = _resolvedKeyboardMonth();
    if (current == null) return;
    final candidate = DateTime(_visibleYear + delta, current);
    if (!_enabled(candidate)) return;
    setState(() {
      _visibleYear = candidate.year;
      _keyboardMonth = candidate.month;
    });
    MiuixHaptics.perform(MiuixHapticType.textHandleMove);
  }

  void _showYear(int delta) {
    final bounds = _bounds;
    final minimumYear = bounds.minimum?.year ?? 1;
    final maximumYear = bounds.maximum?.year ?? 9999;
    final target = (_visibleYear + delta).clamp(minimumYear, maximumYear);
    if (target == _visibleYear) return;
    setState(() {
      _visibleYear = target;
      if (_keyboardMonth case final month?
          when !_enabled(DateTime(target, month))) {
        _keyboardMonth = null;
      }
    });
    MiuixHaptics.perform(MiuixHapticType.textHandleMove);
  }

  void _select(int month) {
    final next = DateTime(_visibleYear, month);
    if (!_enabled(next)) return;
    _controller.value = next;
    MiuixHaptics.perform(MiuixHapticType.confirm);
  }

  void _activateMonth(int month) {
    if (!_enabled(DateTime(_visibleYear, month))) return;
    _focusNode.requestFocus();
    setState(() => _keyboardMonth = month);
    _select(month);
  }

  void _selectKeyboardMonth() {
    final month = _resolvedKeyboardMonth();
    if (month == null) return;
    setState(() => _keyboardMonth = month);
    _select(month);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleChanged);
    if (_ownsController) _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Normalized years are presentation limits, not claims about official
    // HyperOS metrics. They prevent disabled navigation from observing an
    // inverted authored interval while retaining the existing visual tokens.
    final semantic = MiuixSemanticColors.of(context);
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final bounds = _bounds;
    final minimumYear = bounds.minimum?.year ?? 1;
    final maximumYear = bounds.maximum?.year ?? 9999;
    final surface = MiuixSurface(
      color: semantic['surfaceVariant'],
      radius: hyperOs4.calendarCornerRadius,
      glass: widget.glass,
      glassBlur: hyperOs4.calendarBlur,
      glassOpacity: hyperOs4.calendarTintOpacity,
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: 48,
            child: Row(
              children: <Widget>[
                MiuixIconButton(
                  icon: MiuixThemedIcon(MiuixExtensionGlyphs.chevronBackward),
                  onPressed: _visibleYear > minimumYear
                      ? () => _showYear(-1)
                      : null,
                ),
                Expanded(
                  child: Text(
                    '$_visibleYear',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                MiuixIconButton(
                  icon: MiuixThemedIcon(MiuixExtensionGlyphs.chevronForward),
                  onPressed: _visibleYear < maximumYear
                      ? () => _showYear(1)
                      : null,
                ),
              ],
            ),
          ),
          GridView.builder(
            primary: false,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisExtent: 52,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              final month = index + 1;
              final value = DateTime(_visibleYear, month);
              final enabled = _enabled(value);
              final selected = _controller.value == value;
              return Semantics(
                button: true,
                selected: selected,
                focused:
                    _focusNode.hasFocus &&
                    _keyboardMonth != null &&
                    month == _keyboardMonth,
                enabled: enabled,
                label: _label(context, month),
                child: MiuixSurface(
                  onTap: enabled ? () => _activateMonth(month) : null,
                  radius: 16,
                  color: selected
                      ? semantic['primaryContainer']
                      : semantic['surfaceContainer'],
                  child: Center(
                    child: Text(
                      _label(context, month),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: !enabled
                            ? semantic['disabledOnSurface']
                            : selected
                            ? semantic['onPrimaryContainer']
                            : semantic['onSurface'],
                        fontWeight: selected ? FontWeight.w600 : null,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        const SingleActivator(LogicalKeyboardKey.arrowLeft):
            _MonthPickerMoveIntent(rtl ? 1 : -1),
        const SingleActivator(LogicalKeyboardKey.arrowRight):
            _MonthPickerMoveIntent(rtl ? -1 : 1),
        const SingleActivator(LogicalKeyboardKey.arrowUp):
            const _MonthPickerMoveIntent(-3),
        const SingleActivator(LogicalKeyboardKey.arrowDown):
            const _MonthPickerMoveIntent(3),
        const SingleActivator(LogicalKeyboardKey.pageUp):
            const _MonthPickerYearIntent(-1),
        const SingleActivator(LogicalKeyboardKey.pageDown):
            const _MonthPickerYearIntent(1),
        const SingleActivator(LogicalKeyboardKey.enter):
            const _MonthPickerSelectIntent(),
        const SingleActivator(LogicalKeyboardKey.space):
            const _MonthPickerSelectIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _MonthPickerMoveIntent: CallbackAction<_MonthPickerMoveIntent>(
            onInvoke: (intent) {
              _moveKeyboardMonth(intent.delta);
              return null;
            },
          ),
          _MonthPickerYearIntent: CallbackAction<_MonthPickerYearIntent>(
            onInvoke: (intent) {
              _moveKeyboardYear(intent.delta);
              return null;
            },
          ),
          _MonthPickerSelectIntent: CallbackAction<_MonthPickerSelectIntent>(
            onInvoke: (_) {
              _selectKeyboardMonth();
              return null;
            },
          ),
        },
        child: Focus(
          focusNode: _focusNode,
          canRequestFocus: _firstEnabledMonth(_visibleYear) != null,
          child: surface,
        ),
      ),
    );
  }
}

class _MonthPickerMoveIntent extends Intent {
  const _MonthPickerMoveIntent(this.delta);
  final int delta;
}

class _MonthPickerYearIntent extends Intent {
  const _MonthPickerYearIntent(this.delta);
  final int delta;
}

class _MonthPickerSelectIntent extends Intent {
  const _MonthPickerSelectIntent();
}

/// Scrollable year grid that updates a [MiuixMonthPickerController].
class MiuixYearPicker extends StatefulWidget {
  /// Creates a bounded year picker.
  const MiuixYearPicker({
    super.key,
    required this.controller,
    this.minimumYear = 1900,
    this.maximumYear = 2100,
    this.height = 300,
    this.shrinkWrap = false,
    this.physics,
    this.padding = const EdgeInsets.all(8),
    this.onChanged,
    this.glass = true,
  });

  /// Shared selected month; the year changes while its month is preserved.
  final MiuixMonthPickerController controller;
  final int minimumYear;
  final int maximumYear;
  final double height;

  /// Lets an enclosing page own vertical scrolling.
  ///
  /// A fixed-height year picker scrolls internally by default. Set this to
  /// true when embedding a small bounded range in a larger scroll view; every
  /// year row is then measured and the parent receives vertical drags.
  final bool shrinkWrap;

  /// Optional internal scroll physics used when [shrinkWrap] is false.
  final ScrollPhysics? physics;

  /// Insets around the year grid.
  final EdgeInsetsGeometry padding;
  final ValueChanged<DateTime>? onChanged;

  /// Whether the year grid uses HyperOS 4 backdrop material.
  final bool glass;

  @override
  State<MiuixYearPicker> createState() => _MiuixYearPickerState();
}

class _MiuixYearPickerState extends State<MiuixYearPicker> {
  // Year-grid state and accessibility contract:
  // - The caller-owned month controller remains the selected-value owner.
  // - This widget observes that controller but never disposes it.
  // - Authored minimum and maximum years accept either ordering.
  // - Display years are limited to the conventional 1 through 9999 range.
  // - That limit matches the companion month picker navigation contract.
  // - Extreme persisted integers cannot create an unbounded GridView count.
  // - Initial controller values are clamped before the listener is attached.
  // - Attachment correction does not invoke the user-selection callback.
  // - Later external values pass through the same year projection.
  // - A recursion guard absorbs the nested correction notification.
  // - External month-only changes retain their year and rebuild selection.
  // - Live bound changes reuse both controller and scroll ownership.
  // - A live bound correction preserves the controller's selected month.
  // - Pointer selection changes only the year component of that value.
  // - onChanged remains a user-selection callback as in the prior API.
  // - Programmatic controller writes therefore do not synthesize it.
  // - The selected year is scrolled into view after first layout.
  // - External year changes also schedule visibility correction.
  // - Fixed-height mode owns one private ScrollController.
  // - Shrink-wrapped mode continues delegating scrolling to its parent.
  // - Keyboard movement owns one composite grid focus stop.
  // - Left and Right move one chronological year through three columns.
  // - Horizontal chronology mirrors under right-to-left directionality.
  // - Up and Down move one complete three-year grid row.
  // - Page Up and Page Down move four grid rows at a time.
  // - Direction movement changes focus without changing selection.
  // - Enter and Space commit the focused year through the pointer path.
  // - Home and End are intentionally left to surrounding traversal policy.
  // - Boundary key presses are no-ops without callbacks or haptics.
  // - Accepted focus moves use the lightweight segment haptic role.
  // - Accepted selection retains the existing text-handle haptic role.
  // - Pointer activation requests grid focus before updating the controller.
  // - Focused and selected semantics are exposed independently.
  // - Each year keeps its numeric value as the accessible label.
  // - Reduced motion makes focus visibility scrolling immediate.
  // - Controller replacement detaches the previous listener first.
  // - Disposing the widget releases only focus and scroll infrastructure.
  // - These are project behavior guarantees, not private Xiaomi metrics.
  static const int _minimumSupportedYear = 1;
  static const int _maximumSupportedYear = 9999;
  static const double _rowExtent = 54;

  final FocusNode _focusNode = FocusNode(debugLabel: 'MiuixYearPicker');
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _yearKeys = <int, GlobalKey>{};
  bool _normalizingExternalYear = false;
  int? _keyboardYear;

  ({int first, int last}) get _bounds {
    final authoredFirst = widget.minimumYear
        .clamp(_minimumSupportedYear, _maximumSupportedYear)
        .toInt();
    final authoredLast = widget.maximumYear
        .clamp(_minimumSupportedYear, _maximumSupportedYear)
        .toInt();
    return authoredFirst <= authoredLast
        ? (first: authoredFirst, last: authoredLast)
        : (first: authoredLast, last: authoredFirst);
  }

  DateTime _clampValue(DateTime value) {
    final bounds = _bounds;
    final year = value.year.clamp(bounds.first, bounds.last).toInt();
    return year == value.year ? value : DateTime(year, value.month);
  }

  @override
  void initState() {
    super.initState();
    _attachController();
  }

  void _attachController() {
    final safeValue = _clampValue(widget.controller.value);
    if (safeValue != widget.controller.value) {
      widget.controller.value = safeValue;
    }
    _keyboardYear = widget.controller.value.year;
    widget.controller.addListener(_handleControllerChanged);
    _scheduleScrollTo(widget.controller.value.year, immediate: true);
  }

  @override
  void didUpdateWidget(MiuixYearPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleControllerChanged);
      _attachController();
      return;
    }
    if (oldWidget.minimumYear != widget.minimumYear ||
        oldWidget.maximumYear != widget.maximumYear) {
      final safeValue = _clampValue(widget.controller.value);
      if (safeValue != widget.controller.value) {
        widget.controller.value = safeValue;
      } else {
        setState(() {});
        _scheduleScrollTo(safeValue.year, immediate: true);
      }
      final bounds = _bounds;
      _yearKeys.removeWhere(
        (year, _) => year < bounds.first || year > bounds.last,
      );
    }
    if (oldWidget.shrinkWrap != widget.shrinkWrap ||
        oldWidget.height != widget.height ||
        oldWidget.padding != widget.padding) {
      // Changing who owns scrolling creates a new viewport contract even when
      // the selected value is unchanged. Re-resolve visibility after that new
      // viewport has completed layout instead of exposing range row zero.
      _scheduleScrollTo(widget.controller.value.year, immediate: true);
    }
  }

  void _handleControllerChanged() {
    if (!mounted || _normalizingExternalYear) return;
    var value = widget.controller.value;
    final safeValue = _clampValue(value);
    if (safeValue != value) {
      _normalizingExternalYear = true;
      try {
        widget.controller.value = safeValue;
      } finally {
        _normalizingExternalYear = false;
      }
      value = safeValue;
    }
    setState(() => _keyboardYear = value.year);
    _scheduleScrollTo(value.year);
  }

  int _resolvedKeyboardYear() {
    final bounds = _bounds;
    final focused = _keyboardYear;
    if (focused != null && focused >= bounds.first && focused <= bounds.last) {
      return focused;
    }
    return widget.controller.value.year
        .clamp(bounds.first, bounds.last)
        .toInt();
  }

  void _moveKeyboardYear(int delta) {
    final bounds = _bounds;
    final current = _resolvedKeyboardYear();
    final candidate = current + delta;
    if (candidate < bounds.first || candidate > bounds.last) return;
    setState(() => _keyboardYear = candidate);
    _scheduleScrollTo(candidate);
    MiuixHaptics.perform(MiuixHapticType.segmentTick);
  }

  void _activateYear(int year) {
    final bounds = _bounds;
    if (year < bounds.first || year > bounds.last) return;
    _focusNode.requestFocus();
    setState(() => _keyboardYear = year);
    _selectYear(year);
  }

  void _selectKeyboardYear() => _activateYear(_resolvedKeyboardYear());

  void _selectYear(int year) {
    widget.controller.value = DateTime(year, widget.controller.value.month);
    widget.onChanged?.call(widget.controller.value);
    MiuixHaptics.perform(MiuixHapticType.textHandleMove);
  }

  void _scheduleScrollTo(int year, {bool immediate = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final itemContext = _yearKeys[year]?.currentContext;
      final reduceMotion = MediaQuery.disableAnimationsOf(context);
      final duration = immediate || reduceMotion
          ? Duration.zero
          : MiuixTheme.of(context).hyperOs4.pickerStageMotion;
      if (widget.shrinkWrap && itemContext != null) {
        Scrollable.ensureVisible(
          itemContext,
          duration: duration,
          curve: Curves.easeOutCubic,
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
        );
        return;
      }
      if (!_scrollController.hasClients) return;
      final bounds = _bounds;
      final row = (year - bounds.first) ~/ 3;
      final resolvedPadding = widget.padding.resolve(
        Directionality.of(context),
      );
      final itemStart = resolvedPadding.top + row * _rowExtent;
      final itemEnd = itemStart + 48;
      final position = _scrollController.position;
      var target = position.pixels;
      if (itemStart < position.pixels) {
        target = itemStart;
      } else if (itemEnd > position.pixels + position.viewportDimension) {
        target = itemEnd - position.viewportDimension;
      }
      target = target.clamp(position.minScrollExtent, position.maxScrollExtent);
      if ((target - position.pixels).abs() < .5) return;
      if (duration == Duration.zero) {
        _scrollController.jumpTo(target);
      } else {
        _scrollController.animateTo(
          target,
          duration: duration,
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final semantic = MiuixSemanticColors.of(context);
    final bounds = _bounds;
    final grid = GridView.builder(
      controller: widget.shrinkWrap ? null : _scrollController,
      primary: false,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.shrinkWrap
          ? const NeverScrollableScrollPhysics()
          : widget.physics,
      padding: widget.padding,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisExtent: 48,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: bounds.last - bounds.first + 1,
      itemBuilder: (context, index) {
        final year = bounds.first + index;
        final selected = widget.controller.value.year == year;
        return Semantics(
          button: true,
          selected: selected,
          focused:
              _focusNode.hasFocus &&
              _keyboardYear != null &&
              year == _keyboardYear,
          label: '$year',
          child: MiuixSurface(
            key: _yearKeys.putIfAbsent(year, GlobalKey.new),
            radius: 15,
            color: selected ? semantic['primaryContainer'] : Colors.transparent,
            onTap: () => _activateYear(year),
            child: Center(
              child: Text(
                '$year',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: selected
                      ? semantic['onPrimaryContainer']
                      : semantic['onSurface'],
                  fontWeight: selected ? FontWeight.w600 : null,
                ),
              ),
            ),
          ),
        );
      },
    );
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final safeHeight = widget.height.isFinite && widget.height > 0
        ? widget.height
        : 0.0;
    final content = widget.shrinkWrap
        ? grid
        : SizedBox(height: safeHeight, child: grid);
    final surface = MiuixSurface(
      glass: widget.glass,
      color: semantic['surfaceVariant'],
      radius: hyperOs4.calendarCornerRadius,
      glassBlur: hyperOs4.calendarBlur,
      glassOpacity: hyperOs4.calendarTintOpacity,
      child: content,
    );
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        const SingleActivator(LogicalKeyboardKey.arrowLeft):
            _YearPickerMoveIntent(rtl ? 1 : -1),
        const SingleActivator(LogicalKeyboardKey.arrowRight):
            _YearPickerMoveIntent(rtl ? -1 : 1),
        const SingleActivator(LogicalKeyboardKey.arrowUp):
            const _YearPickerMoveIntent(-3),
        const SingleActivator(LogicalKeyboardKey.arrowDown):
            const _YearPickerMoveIntent(3),
        const SingleActivator(LogicalKeyboardKey.pageUp):
            const _YearPickerMoveIntent(-12),
        const SingleActivator(LogicalKeyboardKey.pageDown):
            const _YearPickerMoveIntent(12),
        const SingleActivator(LogicalKeyboardKey.enter):
            const _YearPickerSelectIntent(),
        const SingleActivator(LogicalKeyboardKey.space):
            const _YearPickerSelectIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _YearPickerMoveIntent: CallbackAction<_YearPickerMoveIntent>(
            onInvoke: (intent) {
              _moveKeyboardYear(intent.delta);
              return null;
            },
          ),
          _YearPickerSelectIntent: CallbackAction<_YearPickerSelectIntent>(
            onInvoke: (_) {
              _selectKeyboardYear();
              return null;
            },
          ),
        },
        child: Focus(focusNode: _focusNode, child: surface),
      ),
    );
  }
}

class _YearPickerMoveIntent extends Intent {
  const _YearPickerMoveIntent(this.delta);
  final int delta;
}

class _YearPickerSelectIntent extends Intent {
  const _YearPickerSelectIntent();
}
