import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../effects/miuix_effects.dart';
import 'miuix_host_platform.dart';

/// Device-tilt bridge contract.
///
/// Source correspondence:
///
/// * Android reads `TYPE_GAME_ROTATION_VECTOR` first.
/// * `TYPE_ROTATION_VECTOR` is the source fallback.
/// * Sensor delivery uses `SENSOR_DELAY_GAME`.
/// * Samples are converted through Android's rotation matrix.
/// * Pitch and roll are expressed in radians.
/// * Gravity values stay in normalized device coordinates.
/// * Every channel is smoothed with a coefficient of `.15`.
/// * The first sample seeds the smoother without interpolation.
///
/// Coordinate correspondence:
///
/// * Positive roll moves a virtual light toward increasing X.
/// * Positive pitch moves a virtual light toward decreasing Y.
/// * Light Z is not affected by device orientation.
/// * The primary source sensitivity is `.15` UV per radian.
/// * The secondary source sensitivity is `.12` UV per radian.
/// * Positions are deliberately not clamped before shader evaluation.
///
/// Lifecycle correspondence:
///
/// * Listening begins only while at least one Dart subscriber exists.
/// * Android registration also requires a resumed host Activity.
/// * Pausing the Activity immediately unregisters the sensor listener.
/// * Resuming re-registers while the Dart subscriber is still present.
/// * Cancelling the final EventChannel listener unregisters immediately.
/// * Detaching the plugin releases both the sensor and event sink.
/// * A configuration change never retains the old Activity callback.
///
/// Fallback correspondence:
///
/// * Android devices without either rotation sensor emit no sample.
/// * Windows has no native channel implementation and emits no sample.
/// * A missing plugin is treated as a neutral, static orientation.
/// * Callers initialize their state with [MiuixDeviceTilt.zero].
/// * The original preset remains immutable between sensor frames.
/// * No camera, location, or runtime permission is requested.
///
/// Rendering correspondence:
///
/// * Sensor data changes only highlight light positions.
/// * Blur radius, tint, noise, and blend colors are unaffected.
/// * Each frame derives from the base preset, preventing drift.
/// * The shader keeps the source's two independent light sources.
/// * Static screenshot output is unchanged at zero orientation.
/// * Platforms without sensors therefore match the source fallback.
///
/// Testing correspondence:
///
/// * Pure transform tests verify both source equations.
/// * Widget tests inject a deterministic broadcast stream.
/// * The injected stream avoids loading native code in the test runner.
/// * Android Release checks verify the 20 ms registration period.
/// * Android background checks verify unregister and re-register events.
/// * A zero sample is restored before existing visual goldens run.
///
/// Event payload correspondence:
///
/// * The channel name is stable package API, not an example-only detail.
/// * Each event contains pitch, roll, gravityX, and gravityY keys.
/// * Native float values cross the standard codec as finite doubles.
/// * Missing keys decode to zero for forward-compatible hosts.
/// * Unknown extra keys are ignored by the Dart decoder.
/// * Non-map events are discarded before application state changes.
/// * One broadcast subscription is shared by all Dart listeners.
/// * Listener errors do not replace the last valid orientation sample.
/// * Re-subscribing starts from the caller's neutral or retained state.
/// * No sensor sample is persisted to disk or sent over the network.
/// * Event delivery has no haptic or accessibility side effect.
/// * Consumers may choose independent sensitivities without changing input.
///
/// This contract is intentionally documented beside the implementation. It
/// prevents later refactors from replacing rotation-vector orientation with
/// raw accelerometer values, degrees, pointer tilt, or a continuously active
/// background listener, all of which would visibly or behaviorally diverge
/// from the current MIUIX implementation.
///
/// Smoothed device orientation consumed by MIUIX tilt-driven highlights.
@immutable
class MiuixDeviceTilt {
  /// Creates a device-tilt sample in radians and normalized gravity units.
  const MiuixDeviceTilt({
    required this.pitch,
    required this.roll,
    required this.gravityX,
    required this.gravityY,
  });

  /// Neutral sample used before Android emits its first rotation-vector value.
  static const zero = MiuixDeviceTilt(
    pitch: 0,
    roll: 0,
    gravityX: 0,
    gravityY: 0,
  );

  /// Device pitch in radians.
  final double pitch;

  /// Device roll in radians.
  final double roll;

  /// Smoothed horizontal gravity component.
  final double gravityX;

  /// Smoothed vertical gravity component.
  final double gravityY;
}

/// Rotation-vector stream matching the Android implementation of MIUIX.
///
/// Platforms without a supported native sensor emit no values, leaving callers
/// at [MiuixDeviceTilt.zero] just like the source's non-sensor fallback.
abstract final class MiuixDeviceTiltSensor {
  static const EventChannel _channel = EventChannel(
    'flutter_miuix/device_tilt',
  );

  static Stream<MiuixDeviceTilt>? _events;

  /// Optional deterministic stream used by widget tests without native code.
  @visibleForTesting
  static Stream<MiuixDeviceTilt>? debugEvents;

  /// Converts the native stream while containing a missing host plugin.
  ///
  /// `Stream.handleError` suppresses ordinary data-stream errors, but the
  /// test messenger can report an EventChannel listen failure through the
  /// binding before that transformed stream installs its first listener. An
  /// async iterator owns the subscription itself and therefore catches both
  /// the listen failure and later platform errors at the same boundary.
  static Stream<MiuixDeviceTilt> _nativeEvents() async* {
    try {
      await for (final event in _channel.receiveBroadcastStream()) {
        if (event is! Map) continue;
        final values = Map<Object?, Object?>.from(event);
        yield MiuixDeviceTilt(
          pitch: (values['pitch'] as num?)?.toDouble() ?? 0,
          roll: (values['roll'] as num?)?.toDouble() ?? 0,
          gravityX: (values['gravityX'] as num?)?.toDouble() ?? 0,
          gravityY: (values['gravityY'] as num?)?.toDouble() ?? 0,
        );
      }
    } on MissingPluginException {
      // Flutter tests and Windows retain the documented neutral fallback.
    } on PlatformException {
      // A detached Android activity also keeps the last valid orientation.
    }
  }

  /// Broadcast stream of smoothed device orientation samples.
  static Stream<MiuixDeviceTilt> get events {
    final override = debugEvents;
    if (override != null) return override;
    // Golden tests may override Flutter's target platform to Android while
    // still running in a Windows process. The native EventChannel exists only
    // on a real Android host; using the process fact prevents a test messenger
    // MissingPluginException without weakening injected sensor-stream tests.
    if (!miuixHostIsAndroid) return const Stream<MiuixDeviceTilt>.empty();
    return _events ??= _nativeEvents().asBroadcastStream();
  }
}

/// Applies the source TiltLight position equations to a highlight preset.
extension MiuixTiltDrivenHighlight on MiuixHighlight {
  /// Returns a copy whose two light positions follow [tilt].
  MiuixHighlight drivenByTilt(
    MiuixDeviceTilt tilt, {
    double primarySensitivity = .15,
    double secondarySensitivity = .12,
  }) {
    final style = resolvedStyle;
    if (style is MiuixBloomStroke) {
      final primary = style.primaryLight.position;
      final secondary = style.secondaryLight.position;
      return copyWith(
        position: MiuixLightPosition(
          dx: primary.dx + primarySensitivity * tilt.roll,
          dy: primary.dy - primarySensitivity * tilt.pitch,
          z: primary.z,
        ),
        secondaryPosition: MiuixLightPosition(
          dx: secondary.dx + secondarySensitivity * tilt.roll,
          dy: secondary.dy - secondarySensitivity * tilt.pitch,
          z: secondary.z,
        ),
        style: style.copyWith(
          primaryLight: style.primaryLight.copyWith(
            position: MiuixLightPosition(
              dx: primary.dx + primarySensitivity * tilt.roll,
              dy: primary.dy - primarySensitivity * tilt.pitch,
              z: primary.z,
            ),
          ),
          secondaryLight: style.secondaryLight.copyWith(
            position: MiuixLightPosition(
              dx: secondary.dx + secondarySensitivity * tilt.roll,
              dy: secondary.dy - secondarySensitivity * tilt.pitch,
              z: secondary.z,
            ),
          ),
        ),
      );
    }
    return copyWith(
      position: MiuixLightPosition(
        dx: position.dx + primarySensitivity * tilt.roll,
        dy: position.dy - primarySensitivity * tilt.pitch,
        z: position.z,
      ),
      secondaryPosition: MiuixLightPosition(
        dx: secondaryPosition.dx + secondarySensitivity * tilt.roll,
        dy: secondaryPosition.dy - secondarySensitivity * tilt.pitch,
        z: secondaryPosition.z,
      ),
    );
  }
}
