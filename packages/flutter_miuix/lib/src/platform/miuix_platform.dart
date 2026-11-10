import 'package:flutter/foundation.dart';

/// Host families exposed by the current MIUIX multiplatform source.
enum MiuixPlatform { android, ios, desktop, wasmJs, macOS, js }

/// Returns the Flutter host family corresponding to MIUIX `platform()`.
///
/// Flutter's compile-time [kIsWasm] fact keeps JavaScript and WebAssembly hosts
/// distinct without browser sniffing.
MiuixPlatform get miuixPlatform {
  if (kIsWeb) return kIsWasm ? MiuixPlatform.wasmJs : MiuixPlatform.js;
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => MiuixPlatform.android,
    TargetPlatform.iOS => MiuixPlatform.ios,
    TargetPlatform.macOS => MiuixPlatform.macOS,
    TargetPlatform.linux || TargetPlatform.windows => MiuixPlatform.desktop,
    TargetPlatform.fuchsia => MiuixPlatform.desktop,
  };
}

/// Platform dialog policy used by MIUIX-owned overlay and window surfaces.
@immutable
class MiuixPlatformDialogProperties {
  const MiuixPlatformDialogProperties({
    this.dismissOnBackPress = false,
    this.usePlatformDefaultWidth = false,
    this.usePlatformInsets = false,
    this.transparentScrim = true,
    this.animatePlatformTransition = false,
  });

  final bool dismissOnBackPress;
  final bool usePlatformDefaultWidth;
  final bool usePlatformInsets;
  final bool transparentScrim;
  final bool animatePlatformTransition;

  @override
  bool operator ==(Object other) =>
      other is MiuixPlatformDialogProperties &&
      other.dismissOnBackPress == dismissOnBackPress &&
      other.usePlatformDefaultWidth == usePlatformDefaultWidth &&
      other.usePlatformInsets == usePlatformInsets &&
      other.transparentScrim == transparentScrim &&
      other.animatePlatformTransition == animatePlatformTransition;

  @override
  int get hashCode => Object.hash(
    dismissOnBackPress,
    usePlatformDefaultWidth,
    usePlatformInsets,
    transparentScrim,
    animatePlatformTransition,
  );
}

/// Returns the source platform's custom-dialog policy.
///
/// MIUIX dialogs own Back, width, insets, scrim, and motion on every Flutter
/// host. The Android source additionally sets `decorFitsSystemWindows=false`;
/// Flutter expresses that geometry through its route and MediaQuery instead of
/// a property on this data model.
MiuixPlatformDialogProperties miuixPlatformDialogProperties() =>
    const MiuixPlatformDialogProperties();

/// Compatibility hook for the source's platform-window side effect.
///
/// Flutter MIUIX overlays are drawn in the existing FlutterView and never ask
/// an Android platform Dialog window to add animation or dimming, so there are
/// no platform defaults to remove. Keeping this explicit no-op documents that
/// ownership and gives shared ports a safe call site.
void removeMiuixPlatformDialogDefaultEffects() {}
