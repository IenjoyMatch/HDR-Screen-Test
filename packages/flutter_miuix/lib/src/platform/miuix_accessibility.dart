import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Android accessibility timing used by transient MIUIX surfaces.
///
/// MIUIX delegates snackbar timeouts to Android's AccessibilityManager so a
/// user's "time to take action" preference can lengthen messages containing
/// text, icons, or controls. Flutter does not expose that calculation through
/// its framework API, therefore the package's Android plugin provides the
/// missing native query.
abstract final class MiuixAccessibility {
  static const MethodChannel _channel = MethodChannel(
    'flutter_miuix/accessibility',
  );

  /// Returns Android's recommended timeout for one snackbar.
  ///
  /// The original duration is returned on Windows, older/unattached Android
  /// hosts, tests without the plugin, and any platform-channel failure.
  static Future<Duration> recommendedSnackbarTimeout(
    Duration original, {
    required bool hasAction,
  }) async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return original;
    }
    try {
      final milliseconds = await _channel.invokeMethod<int>(
        'recommendedTimeoutMillis',
        <String, Object>{
          'originalTimeoutMillis': original.inMilliseconds,
          'hasAction': hasAction,
        },
      );
      if (milliseconds != null && milliseconds > 0) {
        return Duration(milliseconds: milliseconds);
      }
    } on MissingPluginException {
      // A pure Dart host deliberately falls back to the requested duration.
    } on PlatformException {
      // Native services can be unavailable while an engine is detaching.
    }
    return original;
  }
}

// Snackbar accessibility parity contract:
//
// 1. Short, long, and custom durations enter this bridge before any Timer.
// 2. Indefinite entries never create a Timer and therefore need no query.
// 3. Android receives the original timeout as a whole millisecond count.
// 4. Text and icon flags are always present because Snackbar.kt sets both.
// 5. The controls flag is present only when an action label is rendered.
// 6. A trailing dismiss icon does not alter the source hasAction argument.
// 7. Android API 29 and newer perform the platform recommendation natively.
// 8. Older Android versions return the caller's requested duration unchanged.
// 9. Windows retains the requested duration without opening a method channel.
// 10. Missing plugins retain package usability in pure Dart/widget-test hosts.
// 11. A detaching engine may reject the call and must use the safe fallback.
// 12. Non-positive native responses are invalid and cannot create a Timer.
// 13. The widget checks mounted and visible state after the async round trip.
// 14. A manually dismissed entry cannot be resurrected by a delayed response.
// 15. The timeout starts after recommendation, as Compose delay() does.
// 16. Action and dismissal result futures remain independent of animation.
// 17. Visual geometry and spring motion do not depend on timeout resolution.
// 18. Tests mock this exact channel and assert both native argument flags.
