import 'package:flutter/material.dart';

import '../../theme/miuix_semantic_colors.dart';
import '../../theme/miuix_theme.dart';
import '../../widgets/miuix_widgets.dart';

/// Palette shared by MIUIX form fields and sections.
@immutable
class MiuixFormColors {
  /// Creates a complete form palette.
  const MiuixFormColors({
    required this.sectionBackground,
    required this.label,
    required this.description,
    required this.error,
    required this.divider,
  });

  /// Group surface and text roles.
  final Color sectionBackground;
  final Color label;
  final Color description;
  final Color error;
  final Color divider;
}

/// Geometry and color defaults for form extensions.
abstract final class MiuixFormDefaults {
  // HyperOS 4 form implementation contract:
  // - One section represents one information hierarchy, not one card per row.
  // - Title and footer remain outside the clipped grouped material.
  // - The grouped-surface radius stays aligned with settings collections.
  // - Optional glass samples only inside the complete continuous silhouette.
  // - Caller-provided padding and field spacing remain explicit overrides.
  // - Error insertion changes layout without replacing the owned form control.
  // - Reduced motion removes autonomous size interpolation, not validation.
  // - Required state is expressed in text as well as through semantic color.
  // - Dividers separate internal rows and never paint beyond section padding.
  // - Source constructors isolate the already-audited former fixed geometry.
  // - Light, dark, and high-contrast roles continue through semantic colors.
  // Token values are project calibration points, not unpublished Xiaomi dp.

  /// Radius of a grouped form section.
  static const double sectionRadius = 18;

  /// Padding inside a grouped section.
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  );

  /// Gap between field metadata and its control.
  static const double contentSpacing = 8;

  /// Resolves colors from the active MIUIX semantic table.
  static MiuixFormColors colors(BuildContext context) {
    final semantic = MiuixSemanticColors.of(context);
    return MiuixFormColors(
      sectionBackground: semantic['surfaceVariant'],
      label: semantic['onSurface'],
      description: semantic['onSurfaceSecondary'],
      error: semantic['error'],
      divider: semantic['dividerLine'],
    );
  }
}

/// Builder receiving the typed Flutter [FormFieldState].
typedef MiuixFormFieldBuilder<T> = Widget Function(FormFieldState<T> field);

/// Typed form-field shell with MIUIX label, help, and error presentation.
class MiuixFormField<T> extends FormField<T> {
  /// Creates a validated MIUIX form field.
  MiuixFormField({
    super.key,
    super.initialValue,
    super.onSaved,
    super.validator,
    super.enabled = true,
    super.autovalidateMode,
    super.restorationId,
    this.label,
    this.description,
    this.required = false,
    this.colors,
    this.contentSpacing = double.nan,
    required MiuixFormFieldBuilder<T> fieldBuilder,
  }) : super(
         builder: (state) => _MiuixFormFieldBody<T>(
           state: state,
           label: label,
           description: description,
           required: required,
           colors: colors,
           contentSpacing: contentSpacing,
           sourceGeometry: false,
           fieldBuilder: fieldBuilder,
         ),
       );

  /// Creates a field shell with the former fixed metadata/error spacing.
  MiuixFormField.source({
    super.key,
    super.initialValue,
    super.onSaved,
    super.validator,
    super.enabled = true,
    super.autovalidateMode,
    super.restorationId,
    this.label,
    this.description,
    this.required = false,
    this.colors,
    required MiuixFormFieldBuilder<T> fieldBuilder,
  }) : contentSpacing = MiuixFormDefaults.contentSpacing,
       super(
         builder: (state) => _MiuixFormFieldBody<T>(
           state: state,
           label: label,
           description: description,
           required: required,
           colors: colors,
           contentSpacing: MiuixFormDefaults.contentSpacing,
           sourceGeometry: true,
           fieldBuilder: fieldBuilder,
         ),
       );

  /// Optional label and help text.
  final String? label;
  final String? description;

  /// Whether an unobtrusive required marker is appended to [label].
  final bool required;

  /// Optional palette override.
  final MiuixFormColors? colors;

  /// Gap between metadata and the input; omitted values follow theme tokens.
  final double contentSpacing;
}

class _MiuixFormFieldBody<T> extends StatelessWidget {
  const _MiuixFormFieldBody({
    required this.state,
    required this.label,
    required this.description,
    required this.required,
    required this.colors,
    required this.contentSpacing,
    required this.sourceGeometry,
    required this.fieldBuilder,
  });

  final FormFieldState<T> state;
  final String? label;
  final String? description;
  final bool required;
  final MiuixFormColors? colors;
  final double contentSpacing;
  final bool sourceGeometry;
  final MiuixFormFieldBuilder<T> fieldBuilder;

  @override
  Widget build(BuildContext context) {
    final palette = colors ?? MiuixFormDefaults.colors(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final motion = hyperOs4.inputStateMotion;
    final resolvedContentSpacing = contentSpacing.isFinite
        ? contentSpacing.clamp(0.0, double.infinity).toDouble()
        : hyperOs4.formFieldContentSpacing;
    final metadata = <Widget>[
      if (label != null)
        Text.rich(
          TextSpan(
            text: label,
            children: <InlineSpan>[
              if (required)
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: palette.error),
                ),
            ],
          ),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: palette.label,
            fontWeight: FontWeight.w600,
          ),
        ),
      if (description != null)
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            description!,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: palette.description),
          ),
        ),
    ];

    return Semantics(
      textField: true,
      enabled: state.widget.enabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (metadata.isNotEmpty) ...metadata,
          if (metadata.isNotEmpty)
            SizedBox(
              key: const ValueKey('miuix-form-field-content-spacing'),
              height: resolvedContentSpacing,
            ),
          fieldBuilder(state),
          if (reduceMotion)
            _errorContent(context, palette)
          else
            AnimatedSize(
              duration: motion,
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: _errorContent(context, palette),
            ),
        ],
      ),
    );
  }

  /// Builds one exact validation branch for animated and reduced layouts.
  Widget _errorContent(BuildContext context, MiuixFormColors palette) {
    if (!state.hasError) return const SizedBox.shrink();
    final errorSpacing = sourceGeometry
        ? 6.0
        : MiuixTheme.of(context).hyperOs4.formErrorSpacing;
    return Padding(
      key: const ValueKey('miuix-form-field-error'),
      padding: EdgeInsets.only(top: errorSpacing),
      child: Text(
        state.errorText!,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: palette.error),
      ),
    );
  }
}

/// Grouped MIUIX form container with optional title and footer.
class MiuixFormSection extends StatelessWidget {
  /// Creates a grouped form section with HyperOS 4 content glass by default.
  const MiuixFormSection({
    super.key,
    this.title,
    this.footer,
    required this.children,
    this.colors,
    this.padding = MiuixFormDefaults.sectionPadding,
    this.showDividers = true,
    this.cornerRadius = double.nan,
    this.glass = true,
  }) : _sourceGeometry = false;

  /// Creates a grouped section with the former fixed opaque geometry.
  const MiuixFormSection.source({
    super.key,
    this.title,
    this.footer,
    required this.children,
    this.colors,
    this.showDividers = true,
  }) : padding = MiuixFormDefaults.sectionPadding,
       cornerRadius = MiuixFormDefaults.sectionRadius,
       glass = false,
       _sourceGeometry = true;

  /// Optional section title and explanatory footer.
  final String? title;
  final String? footer;

  /// Form fields or arbitrary controls in visual order.
  final List<Widget> children;

  /// Optional palette override.
  final MiuixFormColors? colors;

  /// Content padding inside the grouped surface.
  final EdgeInsetsGeometry padding;

  /// Whether separators are inserted between children.
  final bool showDividers;

  /// Continuous outer radius; omitted values follow grouped-surface tokens.
  final double cornerRadius;

  /// Whether the complete clipped section samples content glass.
  final bool glass;

  final bool _sourceGeometry;

  @override
  Widget build(BuildContext context) {
    final palette = colors ?? MiuixFormDefaults.colors(context);
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final radius = cornerRadius.isFinite
        ? cornerRadius.clamp(0.0, double.infinity).toDouble()
        : hyperOs4.settingsGroupCornerRadius;
    final resolvedPadding =
        !_sourceGeometry && padding == MiuixFormDefaults.sectionPadding
        ? EdgeInsets.symmetric(
            horizontal: hyperOs4.formSectionHorizontalPadding,
            vertical: hyperOs4.formSectionVerticalPadding,
          )
        : padding;
    final dividerExtent = _sourceGeometry ? 25.0 : hyperOs4.formDividerExtent;
    final fieldGap = _sourceGeometry ? 16.0 : hyperOs4.formFieldGap;
    final body = <Widget>[];
    for (var index = 0; index < children.length; index++) {
      if (index > 0 && showDividers) {
        body.add(
          Divider(height: dividerExtent, thickness: 1, color: palette.divider),
        );
      } else if (index > 0) {
        body.add(SizedBox(height: fieldGap));
      }
      body.add(children[index]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (title != null)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
            child: Text(
              title!,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: palette.label,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        MiuixSurface(
          key: const ValueKey('miuix-form-section-surface'),
          color: palette.sectionBackground,
          radius: radius,
          padding: resolvedPadding,
          glass: glass,
          glassBlur: hyperOs4.contentSurfaceBlur,
          glassOpacity: hyperOs4.contentSurfaceTintOpacity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: body,
          ),
        ),
        if (footer != null)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 0),
            child: Text(
              footer!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: palette.description),
            ),
          ),
      ],
    );
  }
}
