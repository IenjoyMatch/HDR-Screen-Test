part of '../miuix_widgets.dart';

/// Immutable source color roles used by [MiuixTextField].
@immutable
class MiuixTextFieldColors {
  /// Creates a complete text-field palette.
  const MiuixTextFieldColors({
    required this.backgroundColor,
    required this.labelColor,
    required this.borderColor,
  });

  /// Filled field surface in every interaction state.
  final Color backgroundColor;

  /// Inline and floating label foreground.
  final Color labelColor;

  /// Focused outline and default cursor foreground.
  final Color borderColor;

  /// Returns an independently overridden immutable palette.
  MiuixTextFieldColors copyWith({
    Color? backgroundColor,
    Color? labelColor,
    Color? borderColor,
  }) {
    return MiuixTextFieldColors(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      labelColor: labelColor ?? this.labelColor,
      borderColor: borderColor ?? this.borderColor,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MiuixTextFieldColors &&
            other.backgroundColor == backgroundColor &&
            other.labelColor == labelColor &&
            other.borderColor == borderColor;
  }

  @override
  int get hashCode => Object.hash(backgroundColor, labelColor, borderColor);
}

/// Exact public constants exposed by the upstream `TextFieldDefaults` object.
///
/// Compose names these values `CornerRadius` and `InsideMargin`. Dart style
/// uses lower camel case while retaining the same logical dimensions.
abstract final class MiuixTextFieldDefaults {
  /// Explicit MIUIX 1.0.9 radius for [MiuixTextField.source].
  static const double legacyCornerRadius = 16;

  /// Default G2 or ordinary rounded-corner radius.
  static const double cornerRadius = 20;

  /// Default horizontal and vertical content inset.
  static const EdgeInsets insideMargin = EdgeInsets.all(16);

  /// Resolves the three current upstream semantic color roles.
  static MiuixTextFieldColors colors(
    BuildContext context, {
    Color? backgroundColor,
    Color? labelColor,
    Color? borderColor,
  }) {
    final semantic = MiuixSemanticColors.of(context);
    return MiuixTextFieldColors(
      backgroundColor: backgroundColor ?? semantic['secondaryContainer'],
      labelColor: labelColor ?? semantic['onSecondaryContainer'],
      borderColor: borderColor ?? semantic['primary'],
    );
  }
}

/// Immutable snapshot reported by [MiuixTextField.onTextLayout].
///
/// Compose exposes `TextLayoutResult`; Flutter does not expose the private
/// `RenderEditable` paragraph result as a stable public object. This adapter
/// records the source-observable parts without leaking a disposable painter.
@immutable
class MiuixTextFieldLayoutResult {
  /// Creates an immutable editable-text layout snapshot.
  const MiuixTextFieldLayoutResult({
    required this.size,
    required this.lineCount,
    required this.didExceedMaxLines,
    required this.text,
  });

  /// Painted paragraph size before the surrounding inside margin is added.
  final Size size;

  /// Number of laid-out visual lines after wrapping.
  final int lineCount;

  /// Whether the configured maximum line count clipped additional text.
  final bool didExceedMaxLines;

  /// Plain controller text used for this layout pass.
  final String text;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MiuixTextFieldLayoutResult &&
            other.size == size &&
            other.lineCount == lineCount &&
            other.didExceedMaxLines == didExceedMaxLines &&
            other.text == text;
  }

  @override
  int get hashCode => Object.hash(size, lineCount, didExceedMaxLines, text);
}
