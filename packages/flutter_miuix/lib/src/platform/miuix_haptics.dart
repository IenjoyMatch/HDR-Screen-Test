import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Source haptic roles used by interactive MIUIX components.
///
/// Android 14 exposes dedicated constants for most of these roles. Flutter's
/// built-in [HapticFeedback] API exposes only a smaller cross-platform subset,
/// so flutter_miuix includes a native Android bridge for the exact platform
/// role. Other platforms receive the closest supported fallback automatically.
enum MiuixHapticType {
  /// A source `combinedClickable` long-click gesture was accepted.
  longPress,

  /// A contextual popup or preference menu was opened.
  contextClick,

  /// A binary control changed to its enabled or selected state.
  toggleOn,

  /// A binary control changed to its disabled or unselected state.
  toggleOff,

  /// A tri-state control crossed its indeterminate segment.
  segmentTick,

  /// A picker or stepped slider moved to a neighboring value.
  textHandleMove,

  /// A drag crossed an activation boundary such as a slider edge.
  gestureThresholdActivate,

  /// An explicit operation completed successfully.
  confirm,
}

/// Dispatches source MIUIX haptic roles with a safe platform fallback.
abstract final class MiuixHaptics {
  static const MethodChannel _channel = MethodChannel('flutter_miuix/haptics');

  /// Performs one source haptic role.
  ///
  /// Android package consumers receive the corresponding native
  /// `HapticFeedbackConstants` automatically. A host without an attached
  /// Android activity still receives Flutter's nearest standard feedback.
  static Future<void> perform(MiuixHapticType type) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        final handled = await _channel.invokeMethod<bool>(
          'performHapticFeedback',
          <String, Object>{'type': type.name},
        );
        if (handled ?? false) return;
      } on MissingPluginException {
        // Plain Dart/package hosts intentionally fall through to Flutter.
      } on PlatformException {
        // A platform that rejects an unavailable constant also falls back.
      }
    }

    await switch (type) {
      MiuixHapticType.longPress => HapticFeedback.heavyImpact(),
      MiuixHapticType.contextClick => HapticFeedback.mediumImpact(),
      MiuixHapticType.toggleOn ||
      MiuixHapticType.toggleOff => HapticFeedback.lightImpact(),
      MiuixHapticType.segmentTick ||
      MiuixHapticType.textHandleMove => HapticFeedback.selectionClick(),
      MiuixHapticType.gestureThresholdActivate ||
      MiuixHapticType.confirm => HapticFeedback.mediumImpact(),
    };
  }
}
