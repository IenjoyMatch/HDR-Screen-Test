import 'package:flutter/material.dart';

import '../../effects/miuix_effects.dart';
import '../../platform/miuix_haptics.dart';
import '../../theme/miuix_semantic_colors.dart';
import '../../theme/miuix_theme.dart';
import '../../widgets/miuix_widgets.dart';

// Autocomplete public-geometry contract:
//
// - RawAutocomplete owns the final field-relative placement rectangle.
// - This library owns only the requested content-plane width and height limits.
// - Public doubles are normalized before constructing BoxConstraints.
// - NaN cannot participate in constraint ordering and uses the documented default.
// - Positive infinity cannot describe a finite popup plane and uses the default.
// - Negative infinity likewise falls back before layout.
// - Zero and negative heights fall back to the 280dp content limit.
// - Zero and negative minimum widths fall back to 220dp.
// - Zero and negative maximum widths fall back to 420dp.
// - A finite maximum smaller than the minimum is promoted to the minimum.
// - This preserves BoxConstraints.minWidth <= maxWidth in Release builds.
// - matchFieldWidth selects the safe maximum as the authored target.
// - Compact mode selects the safe minimum as the authored target.
// - Ancestor overlay constraints may still shrink either requested width.
// - Narrow-window clamping is intentional and does not mutate the public values.
// - Result height remains content driven below the safe maximum.
// - Long result sets scroll within the safe maximum rather than overflowing.
// - Popup radius uses the theme when the public value is non-finite.
// - A finite negative radius clamps to zero before painting.
// - Field radius follows the same finite non-negative boundary.
// - Blur and opacity normalization remain inside the shared glass component.
// - Width fallback values are project component defaults, not claimed Xiaomi dp.
// - Constructor asserts are not used as a Release behavior boundary.
// - Source and HyperOS constructors share the same geometry normalization.
// - Source styling changes material, not safety or keyboard ownership.
// - RawAutocomplete continues to own highlighted-index normalization.
// - Synchronous optionsBuilder changes are observed from current editing state.
// - Controller and focus replacement remain independent from geometry changes.
// - Invalid geometry never replaces or disposes caller-owned state.
// - Tests verify finite output under NaN, infinity, negative, and reversed inputs.
// - Golden tests retain normal finite geometry as a separate visual contract.
// - Runtime checks still need compact Windows and Android split-screen widths.
// - No normalization helper schedules a frame or causes asynchronous work.
// - The helpers are pure so every rebuild resolves the same input identically.
// - The result is suitable for reusable library callers, not only the example.

double _safeAutoCompleteHeight(double value) {
  if (!value.isFinite || value <= 0) {
    return MiuixAutoCompleteDefaults.maximumOptionsHeight;
  }
  return value;
}

({double minimum, double maximum}) _safeAutoCompleteWidths(
  double minimum,
  double maximum,
) {
  final safeMinimum = minimum.isFinite && minimum > 0 ? minimum : 220.0;
  final safeMaximum = maximum.isFinite && maximum > 0 ? maximum : 420.0;
  return (
    minimum: safeMinimum,
    maximum: safeMaximum < safeMinimum ? safeMinimum : safeMaximum,
  );
}

/// Value owner for [MiuixAutoCompleteField].
class MiuixAutoCompleteController<T extends Object> extends ChangeNotifier {
  /// Creates a controller with optional initial text and selection.
  MiuixAutoCompleteController({String text = '', T? selected})
    : textController = TextEditingController(text: text),
      _selected = selected {
    textController.addListener(_relayTextChange);
  }

  /// Editing controller exposed for cursor and selection manipulation.
  final TextEditingController textController;

  T? _selected;

  /// Last option accepted by the user.
  T? get selected => _selected;

  /// Updates the selected option without rewriting visible text.
  void select(T? value) {
    if (identical(value, _selected) || value == _selected) return;
    _selected = value;
    notifyListeners();
  }

  void _relayTextChange() => notifyListeners();

  @override
  void dispose() {
    textController
      ..removeListener(_relayTextChange)
      ..dispose();
    super.dispose();
  }
}

/// Theme colors for autocomplete results.
@immutable
class MiuixAutoCompleteColors {
  /// Creates a complete result palette.
  const MiuixAutoCompleteColors({
    required this.background,
    required this.foreground,
    required this.highlight,
    required this.secondaryForeground,
  });

  /// Popup surface and option colors.
  final Color background;
  final Color foreground;
  final Color highlight;
  final Color secondaryForeground;
}

/// Layout and palette defaults for [MiuixAutoCompleteField].
abstract final class MiuixAutoCompleteDefaults {
  // HyperOS 4 autocomplete implementation contract:
  // - The editable field remains the only layout anchor.
  // - RawAutocomplete continues to own keyboard option traversal.
  // - The results plane follows the requested up/down direction.
  // - The results plane samples content behind its clipped silhouette.
  // - Blur and tint come from the popup token family.
  // - The global five-level glass setting scales both material channels.
  // - Only the popup shape owns shadow; no rectangular backing is added.
  // - Result height stays content-driven until the public maximum is reached.
  // - Every result retains an equal authored interaction height.
  // - Keyboard highlight changes animate the complete row surface.
  // - Pointer selection and keyboard submission share RawAutocomplete state.
  // - Logical option identity is stable across highlight retargeting.
  // - A runtime reduced-motion change replaces an in-flight highlight.
  // - Custom rows receive the same highlighted boolean as the stock row.
  // - Custom content cannot bypass the popup clip or create a second anchor.
  // - Confirmation haptics occur only after RawAutocomplete accepts a value.
  // - Popup width remains bounded on desktop instead of spanning the window.
  // - Long result sets scroll inside the anchored material plane.
  // - Ambient safe-area padding is not inserted inside the result list.
  // - Text entry retains IME action and caller-owned focus-node behavior.
  // - Caller-owned controllers and focus nodes are never disposed by the field.
  // - Replacement controllers take effect without retaining stale listeners.
  // - The popup remains readable when component glass is globally disabled.
  // - Result indication is clipped by the same continuous row silhouette.
  // These are project implementation rules derived from the public visual
  // specification, not unpublished Xiaomi geometry or timing constants.

  /// Maximum popup height before scrolling.
  static const double maximumOptionsHeight = 280;

  /// Radius of the floating results panel.
  static const double cornerRadius = 18;

  /// Height of one default option.
  static const double optionHeight = 52;

  /// Resolves result colors from MIUIX semantic roles.
  static MiuixAutoCompleteColors colors(BuildContext context) {
    final semantic = MiuixSemanticColors.of(context);
    return MiuixAutoCompleteColors(
      background: semantic['surfaceVariant'],
      foreground: semantic['onSurface'],
      highlight: semantic['tertiaryContainer'],
      secondaryForeground: semantic['onSurfaceSecondary'],
    );
  }
}

/// Converts current editing state into matching options.
typedef MiuixAutoCompleteOptionsBuilder<T extends Object> =
    Iterable<T> Function(TextEditingValue value);

/// Builds one option row.
typedef MiuixAutoCompleteOptionBuilder<T extends Object> =
    Widget Function(BuildContext context, T option, bool highlighted);

/// MIUIX-styled generic autocomplete field with keyboard navigation.
class MiuixAutoCompleteField<T extends Object> extends StatefulWidget {
  /// Creates an autocomplete field.
  const MiuixAutoCompleteField({
    super.key,
    required this.optionsBuilder,
    required this.displayStringForOption,
    this.controller,
    this.focusNode,
    this.optionBuilder,
    this.onSelected,
    this.label,
    this.hint,
    this.leadingIcon,
    this.trailingIcon,
    this.enabled = true,
    this.colors,
    this.maximumOptionsHeight = MiuixAutoCompleteDefaults.maximumOptionsHeight,
    this.minimumOptionsWidth = 220,
    this.maximumOptionsWidth = 420,
    this.matchFieldWidth = true,
    this.openDirection = OptionsViewOpenDirection.down,
    this.popupGlass = true,
    this.popupGlassBlur,
    this.popupGlassOpacity,
    this.showPopupGlassSpecular = true,
    this.popupCornerRadius = double.nan,
    this.fieldCornerRadius = double.nan,
  }) : _sourceStyle = false;

  /// Creates the former opaque autocomplete field and result plane.
  const MiuixAutoCompleteField.source({
    super.key,
    required this.optionsBuilder,
    required this.displayStringForOption,
    this.controller,
    this.focusNode,
    this.optionBuilder,
    this.onSelected,
    this.label,
    this.hint,
    this.leadingIcon,
    this.trailingIcon,
    this.enabled = true,
    this.colors,
    this.maximumOptionsHeight = MiuixAutoCompleteDefaults.maximumOptionsHeight,
    this.minimumOptionsWidth = 220,
    this.maximumOptionsWidth = 420,
    this.matchFieldWidth = true,
    this.openDirection = OptionsViewOpenDirection.down,
  }) : popupGlass = false,
       popupGlassBlur = null,
       popupGlassOpacity = null,
       showPopupGlassSpecular = false,
       popupCornerRadius = MiuixAutoCompleteDefaults.cornerRadius,
       fieldCornerRadius = MiuixTextFieldDefaults.legacyCornerRadius,
       _sourceStyle = true;

  /// Supplies candidates for the current query.
  final MiuixAutoCompleteOptionsBuilder<T> optionsBuilder;

  /// Converts a typed option to visible text.
  final String Function(T option) displayStringForOption;

  /// Optional externally owned package controller and focus node.
  final MiuixAutoCompleteController<T>? controller;
  final FocusNode? focusNode;

  /// Optional custom result row.
  final MiuixAutoCompleteOptionBuilder<T>? optionBuilder;

  /// Called after the user accepts a result.
  final ValueChanged<T>? onSelected;

  /// Text-field metadata and adornments.
  final String? label;
  final String? hint;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final bool enabled;

  /// Popup palette and geometry.
  final MiuixAutoCompleteColors? colors;
  final double maximumOptionsHeight;
  final double minimumOptionsWidth;
  final double maximumOptionsWidth;

  /// Whether the result plane follows the editable-field width.
  ///
  /// [maximumOptionsWidth] still caps wide desktop fields. Set this to false
  /// to use [minimumOptionsWidth] as an explicit compact plane width.
  final bool matchFieldWidth;
  final OptionsViewOpenDirection openDirection;

  /// Whether the anchored result plane samples content behind itself.
  final bool popupGlass;

  /// Optional result-plane material overrides.
  final double? popupGlassBlur;
  final double? popupGlassOpacity;
  final bool showPopupGlassSpecular;

  /// Optional popup and editable-field shape overrides.
  ///
  /// NaN resolves through the corresponding HyperOS 4 theme role.
  final double popupCornerRadius;
  final double fieldCornerRadius;

  final bool _sourceStyle;

  @override
  State<MiuixAutoCompleteField<T>> createState() =>
      _MiuixAutoCompleteFieldState<T>();
}

class _MiuixAutoCompleteFieldState<T extends Object>
    extends State<MiuixAutoCompleteField<T>> {
  // Controller and focus ownership contract:
  // - Text editing state and focus state are independent resources.
  // - Either resource may be internally created or caller supplied.
  // - Internally created resources are disposed by this State object.
  // - Caller supplied resources are detached but never disposed here.
  // - Replacing the controller must not replace an unchanged focus node.
  // - Replacing the focus node must not replace an unchanged controller.
  // - Internal text therefore survives an external focus-node hot swap.
  // - Internal focus therefore survives an external controller hot swap.
  // - A newly supplied controller becomes visible in the same rebuild.
  // - A newly supplied focus node participates in the same rebuild.
  // - A removed external controller is replaced with fresh internal state.
  // - A removed external focus node is replaced with a fresh internal node.
  // - No listener remains attached to a superseded package controller.
  // - The RawAutocomplete receives one coherent resource pair per build.
  // - Suggestions are always calculated from the active text controller.
  // - Selection writes only to the active package controller, when present.
  // - Accepting an option cannot write through a detached controller.
  // - Keyboard highlight is owned by RawAutocomplete, not this State.
  // - Open popup geometry follows the currently rendered field anchor.
  // - Focus replacement lets RawAutocomplete close or reopen naturally.
  // - This component does not force focus onto a newly supplied node.
  // - This component does not copy focus from a removed external node.
  // - Text selection remains part of TextEditingController state.
  // - Composing-region state remains part of TextEditingController state.
  // - Rebuilding for theme changes does not recreate either resource.
  // - Rebuilding for locale changes does not recreate either resource.
  // - Rebuilding for enabled changes does not recreate either resource.
  // - Generic option type changes require a new widget State by design.
  // - Field disposal detaches resources before the State becomes invalid.
  // - Internal controller disposal also releases its text controller.
  // - External package-controller disposal remains the caller's duty.
  // - External focus-node disposal remains the caller's duty.
  // - Object identity, not equality, decides whether a resource changed.
  // - Independent attach helpers make ownership explicit at each boundary.
  // - Independent detach helpers prevent cross-resource state loss.
  // - The combined attach helper is reserved for initial State setup.
  // - The combined detach path is intentionally avoided during hot swaps.
  // - Disabled fields retain editing state for later re-enablement.
  // - Popup material configuration is independent from object ownership.
  // - Source-style compatibility does not change lifecycle guarantees.
  // - Glass strength changes do not change controller or focus identity.
  // - Reduced-motion changes do not change controller or focus identity.
  // - Custom option builders cannot take ownership of these resources.
  // - Asynchronous option production is not accepted by this API contract.
  // - Synchronous option rebuilds always observe the latest editing value.
  // - Disposal remains idempotent from the widget lifecycle perspective.
  // These rules guard reusable library behavior rather than example state.

  late MiuixAutoCompleteController<T> _controller;
  late FocusNode _focusNode;
  late bool _ownsController;
  late bool _ownsFocusNode;

  @override
  void initState() {
    super.initState();
    _attachObjects();
  }

  void _attachObjects() {
    _attachController();
    _attachFocusNode();
  }

  void _attachController() {
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? MiuixAutoCompleteController<T>();
  }

  void _attachFocusNode() {
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode();
  }

  void _detachController() {
    if (_ownsController) _controller.dispose();
  }

  void _detachFocusNode() {
    if (_ownsFocusNode) _focusNode.dispose();
  }

  @override
  void didUpdateWidget(MiuixAutoCompleteField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Controller and focus ownership are independent. Replacing either one
    // must not discard editing state owned by the other channel.
    if (oldWidget.controller != widget.controller) {
      _detachController();
      _attachController();
    }
    if (oldWidget.focusNode != widget.focusNode) {
      _detachFocusNode();
      _attachFocusNode();
    }
  }

  @override
  void dispose() {
    _detachController();
    _detachFocusNode();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<T>(
      textEditingController: _controller.textController,
      focusNode: _focusNode,
      displayStringForOption: widget.displayStringForOption,
      optionsBuilder: widget.optionsBuilder,
      optionsViewOpenDirection: widget.openDirection,
      onSelected: (option) {
        _controller.select(option);
        MiuixHaptics.perform(MiuixHapticType.confirm);
        widget.onSelected?.call(option);
      },
      fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
        final hyperOs4 = MiuixTheme.of(context).hyperOs4;
        final fieldRadius = widget.fieldCornerRadius.isFinite
            ? widget.fieldCornerRadius.clamp(0.0, double.infinity).toDouble()
            : hyperOs4.textFieldCornerRadius;
        return MiuixTextField(
          key: ValueKey<String>(
            widget._sourceStyle
                ? 'miuix-autocomplete-source-field'
                : 'miuix-autocomplete-field',
          ),
          controller: controller,
          focusNode: focusNode,
          label: widget.label,
          hint: widget.hint,
          leadingIcon: widget.leadingIcon,
          trailingIcon: widget.trailingIcon,
          enabled: widget.enabled,
          cornerRadius: fieldRadius,
          singleLine: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => onSubmitted(),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        final palette =
            widget.colors ?? MiuixAutoCompleteDefaults.colors(context);
        final values = options.toList(growable: false);
        final reduceMotion = MediaQuery.disableAnimationsOf(context);
        final hyperOs4 = MiuixTheme.of(context).hyperOs4;
        final popupRadius = widget.popupCornerRadius.isFinite
            ? widget.popupCornerRadius.clamp(0.0, double.infinity).toDouble()
            : hyperOs4.popupCornerRadius;
        final widths = _safeAutoCompleteWidths(
          widget.minimumOptionsWidth,
          widget.maximumOptionsWidth,
        );
        final maximumHeight = _safeAutoCompleteHeight(
          widget.maximumOptionsHeight,
        );
        final targetWidth = widget.matchFieldWidth
            ? widths.maximum
            : widths.minimum;
        // RawAutocomplete already owns actual up/down placement and may choose
        // a direction from the live viewport. Shrink-wrapping this subtree
        // leaves that framework anchor authoritative while parent constraints
        // safely clamp the requested width and height on narrow windows.
        return Align(
          alignment: AlignmentDirectional.topStart,
          widthFactor: 1,
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: targetWidth,
              maxWidth: targetWidth,
              maxHeight: maximumHeight,
            ),
            child: MiuixSurface(
              key: const ValueKey('miuix-autocomplete-popup'),
              color: palette.background,
              radius: popupRadius,
              shadowElevation: 12,
              glass: widget.popupGlass,
              glassBlur: widget.popupGlassBlur ?? hyperOs4.popupBlur,
              glassOpacity:
                  widget.popupGlassOpacity ?? hyperOs4.popupTintOpacity,
              glassOptics: MiuixGlassOptics.transient,
              showGlassSpecular: widget.showPopupGlassSpecular,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 6),
                shrinkWrap: true,
                itemCount: values.length,
                itemBuilder: (context, index) {
                  final option = values[index];
                  return Builder(
                    builder: (context) {
                      final highlighted =
                          AutocompleteHighlightedOption.of(context) == index;
                      final custom = widget.optionBuilder?.call(
                        context,
                        option,
                        highlighted,
                      );
                      return TweenAnimationBuilder<double>(
                        // Autocomplete may retarget on every arrow-key press.
                        // Stable option identity preserves that trajectory;
                        // the policy bit snaps an in-flight highlight when
                        // reduced motion becomes active at runtime.
                        key: ValueKey<(T, bool)>((option, reduceMotion)),
                        tween: Tween<double>(end: highlighted ? 1 : 0),
                        duration: reduceMotion
                            ? Duration.zero
                            : hyperOs4.collectionRowMotion,
                        curve: Curves.easeOutCubic,
                        builder: (context, highlightProgress, _) {
                          final background = Color.lerp(
                            Colors.transparent,
                            palette.highlight,
                            highlightProgress,
                          )!;
                          return MiuixSurface(
                            key: ValueKey<Object>((
                              'miuix-autocomplete-option',
                              option,
                            )),
                            radius: hyperOs4.collectionRowCornerRadius,
                            color: background,
                            onTap: () => onSelected(option),
                            feedbackType: MiuixPressFeedbackType.sink,
                            child: SizedBox(
                              height: MiuixAutoCompleteDefaults.optionHeight,
                              child:
                                  custom ??
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Align(
                                      alignment:
                                          AlignmentDirectional.centerStart,
                                      child: Text(
                                        widget.displayStringForOption(option),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              color: palette.foreground,
                                            ),
                                      ),
                                    ),
                                  ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
