import '../icons/miuix_icon_theme.dart';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../icons/miuix_extended_icons.dart';

/// Shared MIUIX glyphs used by package-level extension controls.
///
/// The extension widgets are not part of the upstream Compose component
/// catalogue, but their default artwork still needs to belong to the same
/// visual language as the core library. Keeping these lookups in one place
/// prevents individual controls from quietly falling back to Material glyphs
/// with different stroke weight, optical bounds, or arrow direction.
///
/// Only glyphs with an unambiguous semantic match are exposed here. A control
/// without a genuine MIUIX equivalent should retain its existing artwork or
/// accept a caller-provided icon instead of reusing a merely similar symbol.
abstract final class MiuixExtensionGlyphs {
  /// Returns the regular optical weight from the bundled upstream catalogue.
  static IconData _regular(String name) {
    final family = MiuixExtendedIconCatalog.find(name);
    if (family == null) {
      // This is a package-generation invariant, not recoverable application
      // input. Substituting the first unrelated icon in Release would conceal
      // a broken catalogue and can give an action the wrong meaning.
      throw StateError('Missing bundled MIUIX extension glyph: $name');
    }
    return family.regular;
  }

  /// Backward month or tree-navigation chevron.
  static final IconData chevronBackward = _regular('ChevronBackward');

  /// Forward month or tree-navigation chevron.
  static final IconData chevronForward = _regular('ChevronForward');

  /// Retries an operation or reloads lazy content.
  static final IconData refresh = _regular('Refresh');

  /// Confirms a selected or completed state.
  static final IconData confirm = _regular('Ok');

  /// Closes a transient field, popup, or error state.
  static final IconData close = _regular('Close');

  /// Represents a skipped or removed state.
  static final IconData remove = _regular('Remove');

  /// Starts a search operation.
  static final IconData search = _regular('Search');

  /// Uploads a file from the host application.
  static final IconData upload = _regular('UploadCloud');
}

/// Cardinal directions supported by [MiuixExtensionChevron].
enum MiuixExtensionChevronDirection { backward, forward, up, down }

/// Rotates the upstream forward/backward chevron without substituting another
/// similarly named glyph.
///
/// In the official icon set `ExpandMore` means expanding a view to its corners;
/// it is not Material's downward disclosure arrow. Deriving vertical arrows
/// from the real MIUIX chevron preserves the correct stroke and optical bounds
/// while avoiding that name collision.
class MiuixExtensionChevron extends StatelessWidget {
  /// Creates one directional MIUIX chevron.
  const MiuixExtensionChevron({
    super.key,
    required this.direction,
    this.color,
    this.size,
  });

  /// Desired physical arrow direction.
  final MiuixExtensionChevronDirection direction;

  /// Optional icon color inherited from [IconTheme] when null.
  final Color? color;

  /// Optional square icon extent inherited from [IconTheme] when null.
  final double? size;

  @override
  Widget build(BuildContext context) {
    final vertical = switch (direction) {
      MiuixExtensionChevronDirection.up => -math.pi / 2,
      MiuixExtensionChevronDirection.down => math.pi / 2,
      _ => 0.0,
    };
    final icon = MiuixThemedIcon(
      direction == MiuixExtensionChevronDirection.backward
          ? MiuixExtensionGlyphs.chevronBackward
          : MiuixExtensionGlyphs.chevronForward,
      color: color,
      size: size,
    );
    return vertical == 0
        ? icon
        : Transform.rotate(angle: vertical, child: icon);
  }
}
