import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'miuix_host_platform.dart';

/// Bottom window insets used by MIUIX navigation surfaces.
///
/// Android exposes navigation bars and caption bars as two independent inset
/// types. Flutter's [MediaQuery] intentionally combines system-safe regions,
/// which is useful for ordinary layout but cannot reproduce MIUIX's separate
/// navigation placement and 300 ms caption-bar animation. This value keeps the
/// two native measurements distinct and expresses both in logical pixels.
@immutable
class MiuixWindowInsets {
  /// Creates an immutable native inset sample.
  const MiuixWindowInsets({
    required this.navigationBarBottom,
    required this.captionBarBottom,
  });

  /// Empty sample used before a supported host delivers its first update.
  static const zero = MiuixWindowInsets(
    navigationBarBottom: 0,
    captionBarBottom: 0,
  );

  /// Bottom inset occupied by Android's navigation-bar inset type.
  final double navigationBarBottom;

  /// Bottom inset occupied by Android's caption-bar inset type.
  final double captionBarBottom;
}

/// Streams source-compatible Android window-inset measurements.
///
/// The stream is intentionally Android-only. Current MIUIX uses a fixed 20dp
/// regular-navigation inset on iOS, while desktop hosts normally report no
/// bottom caption bar. Widgets retain a synchronous [MediaQuery] fallback until
/// Android emits the first sample, preventing a one-frame collapse at launch.
abstract final class MiuixWindowInsetsObserver {
  static const EventChannel _channel = EventChannel(
    'flutter_miuix/window_insets',
  );

  static Stream<MiuixWindowInsets>? _events;

  /// Deterministic replacement used by widget tests.
  ///
  /// Supplying an injected stream also permits Android-targeted widget tests
  /// to exercise caption-bar changes while the test process runs on Windows.
  @visibleForTesting
  static Stream<MiuixWindowInsets>? debugEvents;

  /// Decodes native logical-pixel measurements and contains plugin teardown.
  static Stream<MiuixWindowInsets> _nativeEvents() async* {
    try {
      await for (final event in _channel.receiveBroadcastStream()) {
        if (event is! Map) continue;
        final values = Map<Object?, Object?>.from(event);
        final navigation =
            (values['navigationBarBottom'] as num?)?.toDouble() ?? 0;
        final caption = (values['captionBarBottom'] as num?)?.toDouble() ?? 0;
        // Insets cannot be negative, but clamping here also protects layout
        // from malformed custom Android embeddings using the same channel.
        yield MiuixWindowInsets(
          navigationBarBottom: navigation.clamp(0, double.infinity),
          captionBarBottom: caption.clamp(0, double.infinity),
        );
      }
    } on MissingPluginException {
      // Tests, Windows, and older host applications keep the documented
      // MediaQuery/zero fallback when the Android plugin is unavailable.
    } on PlatformException {
      // Activity detachment during a configuration change is transient. The
      // next stream subscription or native inset dispatch restores updates.
    }
  }

  /// Broadcast stream of independent navigation and caption-bar insets.
  static Stream<MiuixWindowInsets> get events {
    final override = debugEvents;
    if (override != null) return override;
    if (!miuixHostIsAndroid) {
      return const Stream<MiuixWindowInsets>.empty();
    }
    return _events ??= _nativeEvents().asBroadcastStream();
  }
}
