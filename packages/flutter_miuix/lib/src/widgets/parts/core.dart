part of '../miuix_widgets.dart';

/// Navigation item model used by bottom bars, rails, and floating bars.
///
/// A small shared model keeps navigation widgets simple and avoids forcing apps
/// to depend on Material-specific destination classes at their own boundaries.
@immutable
class MiuixNavigationItem {
  /// Creates a navigation item.
  const MiuixNavigationItem({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.badge,
    this.layoutLabel,
    this.enabled = true,
  });

  /// Icon displayed in the normal state.
  final Widget icon;

  /// Text label displayed for the destination.
  final String label;

  /// Optional source label used only to preserve the original intrinsic width.
  ///
  /// Localized labels can be substantially narrower than the labels used by
  /// the reference MIUIX sample. Floating navigation bars may measure this
  /// value invisibly while continuing to paint and announce [label].
  final String? layoutLabel;

  /// Optional selected icon.
  final Widget? selectedIcon;

  /// Optional source badge painted against the icon without affecting layout.
  ///
  /// Current NavigationBar, FloatingNavigationBar, NavigationRail, and the
  /// example's iOS-style bar all expose the same badge slot upstream.
  final Widget? badge;

  /// Whether this destination accepts pointer and semantic activation.
  ///
  /// Upstream navigation bar, floating bar, and rail item composables expose
  /// the same enabled switch. Disabled items keep their ordinary tint but do
  /// not enter the pressed state or invoke their selection callback.
  final bool enabled;
}

/// Dropdown entry model used by popup and preference widgets.
///
/// Entries are intentionally generic so the same component can represent enum
/// values, identifiers, or richer domain objects.
@immutable
class MiuixDropdownEntry<T> {
  /// Creates a dropdown entry.
  const MiuixDropdownEntry({
    required this.value,
    required this.label,
    this.icon,
    this.summary,
    this.enabled = true,
    this.selected = false,
    this.children = const [],
  });

  /// Application value associated with the entry.
  final T value;

  /// Human-readable entry label.
  final String label;

  /// Optional leading icon.
  final Widget? icon;

  /// Optional supporting text shown below the label.
  final String? summary;

  /// Whether the entry can be selected.
  final bool enabled;

  /// Whether the popup renders a selected check mark for this entry.
  final bool selected;

  /// Optional second-level entries used by current cascading popups.
  ///
  /// Current MIUIX limits visible cascading depth to two. Deeper child lists
  /// are retained in the model but ignored by the popup renderer.
  final List<MiuixDropdownEntry<T>> children;

  /// Returns a copy with explicitly overridden menu state.
  MiuixDropdownEntry<T> copyWith({
    bool? enabled,
    bool? selected,
    List<MiuixDropdownEntry<T>>? children,
  }) {
    return MiuixDropdownEntry<T>(
      value: value,
      label: label,
      icon: icon,
      summary: summary,
      enabled: enabled ?? this.enabled,
      selected: selected ?? this.selected,
      children: children ?? this.children,
    );
  }
}

/// One independently selectable group inside a MIUIX dropdown or spinner.
@immutable
class MiuixDropdownGroup<T> {
  /// Creates a group of popup entries.
  const MiuixDropdownGroup({required this.entries, this.enabled = true});

  /// Rows in this group, preserving their source order.
  final List<MiuixDropdownEntry<T>> entries;

  /// Whether every entry in this group can be activated.
  ///
  /// The current MIUIX `DropdownEntry` group overload carries its own enabled
  /// flag. Keeping that flag separate from each row lets callers disable an
  /// entire logical group without rebuilding or mutating its entry models.
  final bool enabled;
}

/// Accessibility role accepted by the source MIUIX clickable components.
///
/// Compose exposes these seven values through `androidx.compose.ui.semantics`
/// while Flutter represents some of them as semantic flags instead of entries
/// in [SemanticsRole]. Keeping a package-owned enum preserves the complete
/// source parameter surface without leaking that framework mismatch to apps.
enum MiuixAccessibilityRole {
  /// A push button.
  button,

  /// A checkbox control.
  checkbox,

  /// A switch control.
  switchControl,

  /// One choice in a mutually exclusive radio group.
  radioButton,

  /// A tab destination.
  tab,

  /// An image that contributes accessibility meaning.
  image,

  /// A control that opens a dropdown list.
  dropdownList,
}

/// Universal row/container primitive for building custom Miuix components.
///
/// This mirrors MIUIX `BasicComponent`: it provides a leading slot, text area,
/// trailing slot, enabled state, and press handling while leaving the concrete
/// behavior to the caller.
class MiuixBasicComponent extends StatelessWidget {
  /// Creates a basic component row.
  const MiuixBasicComponent({
    super.key,
    required this.title,
    this.summary,
    this.titleColors,
    this.summaryColors,
    this.leading,
    this.trailing,
    this.bottomAction,
    this.insideMargin = MiuixBasicComponentDefaults.insideMargin,
    this.onTap,
    this.onLongPress,
    this.feedbackType = MiuixPressFeedbackType.none,
    this.enabled = true,
    this.standalone = true,
  }) : holdDown = false,
       onClickLabel = null,
       role = null,
       interactionSource = null,
       _sourceContent = null,
       _showTitle = true,
       _sourceStyle = false;

  /// Creates the upstream text-and-summary overload without a card wrapper.
  const MiuixBasicComponent.sourceText({
    super.key,
    String? title,
    this.summary,
    this.titleColors,
    this.summaryColors,
    Widget? startAction,
    Widget? endActions,
    this.bottomAction,
    this.insideMargin = MiuixBasicComponentDefaults.insideMargin,
    VoidCallback? onClick,
    this.onClickLabel,
    this.role,
    bool holdDownState = false,
    this.enabled = true,
    this.interactionSource,
  }) : title = title ?? '',
       leading = startAction,
       trailing = endActions,
       onTap = onClick,
       onLongPress = null,
       feedbackType = MiuixPressFeedbackType.none,
       holdDown = holdDownState,
       standalone = false,
       _sourceContent = null,
       _showTitle = title != null,
       _sourceStyle = true;

  /// Creates the upstream arbitrary-content overload without a card wrapper.
  const MiuixBasicComponent.source({
    super.key,
    required Widget content,
    Widget? startAction,
    Widget? endActions,
    this.bottomAction,
    this.insideMargin = MiuixBasicComponentDefaults.insideMargin,
    VoidCallback? onClick,
    this.onClickLabel,
    this.role,
    bool holdDownState = false,
    this.enabled = true,
    this.interactionSource,
  }) : title = '',
       summary = null,
       titleColors = null,
       summaryColors = null,
       leading = startAction,
       trailing = endActions,
       onTap = onClick,
       onLongPress = null,
       feedbackType = MiuixPressFeedbackType.none,
       holdDown = holdDownState,
       standalone = false,
       _sourceContent = content,
       _showTitle = false,
       _sourceStyle = true;

  /// Main title.
  final String title;

  /// Optional supporting text.
  final String? summary;

  /// Optional source title foreground pair.
  final MiuixBasicComponentColors? titleColors;

  /// Optional source summary foreground pair.
  final MiuixBasicComponentColors? summaryColors;

  /// Optional leading slot.
  final Widget? leading;

  /// Optional trailing slot.
  final Widget? trailing;

  /// Optional full-width action shown eight pixels below the main row.
  final Widget? bottomAction;

  /// Padding around the row and optional bottom action.
  final EdgeInsetsGeometry insideMargin;

  /// Optional tap callback.
  final VoidCallback? onTap;

  /// Optional accessibility description for the click action.
  final String? onClickLabel;

  /// Optional source accessibility role for the clickable row.
  final MiuixAccessibilityRole? role;

  /// Optional long-press callback.
  final VoidCallback? onLongPress;

  /// MIUIX press-feedback style used by this card.
  final MiuixPressFeedbackType feedbackType;

  /// Whether source indication remains held without a pointer.
  final bool holdDown;

  /// Whether the row is interactive.
  final bool enabled;

  /// Whether to supply its own card surface instead of joining a parent card.
  final bool standalone;

  /// Optional observer shared with source press interactions.
  final MiuixInteractionSource? interactionSource;

  final Widget? _sourceContent;
  final bool _showTitle;
  final bool _sourceStyle;

  @override
  Widget build(BuildContext context) {
    final preference = MiuixPreference(
      title: title,
      summary: summary,
      titleColors: titleColors,
      summaryColors: summaryColors,
      showTitle: _showTitle,
      leading: leading,
      trailing: trailing,
      centerContent: _sourceContent,
      bottomAction: bottomAction,
      insideMargin: insideMargin,
      enabled: enabled,
      onTap: standalone ? null : (enabled ? onTap : null),
      onTapHint: onClickLabel,
      role: role,
      holdDown: holdDown,
      interactionSource: interactionSource,
      sourceStyle: _sourceStyle,
    );
    if (!standalone) {
      return preference;
    }
    return MiuixCard(
      onTap: enabled ? onTap : null,
      onLongPress: enabled ? onLongPress : null,
      feedbackType: feedbackType,
      padding: EdgeInsets.zero,
      child: preference,
    );
  }
}

/// Immutable container and foreground colors used by [MiuixCard].
///
/// MIUIX keeps these two channels independent. In particular, changing the
/// card fill must not silently replace the locally inherited text/icon color.
@immutable
class MiuixCardColors {
  /// Creates a card color pair.
  const MiuixCardColors({required this.color, required this.contentColor});

  /// Background painted inside the card shape.
  final Color color;

  /// Color inherited by text and icons in the card.
  final Color contentColor;

  /// Returns a copy with independently replaced color channels.
  MiuixCardColors copyWith({Color? color, Color? contentColor}) {
    return MiuixCardColors(
      color: color ?? this.color,
      contentColor: contentColor ?? this.contentColor,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MiuixCardColors &&
            other.color == color &&
            other.contentColor == contentColor;
  }

  @override
  int get hashCode => Object.hash(color, contentColor);
}

/// Source defaults for the MIUIX v1.0.9 card.
abstract final class MiuixCardDefaults {
  /// Explicit compatibility radius used by the pre-HyperOS visual style.
  static const double legacyCornerRadius = 16;

  /// Default continuous-corner radius.
  ///
  /// Xiaomi does not publish this value as a developer token. The 20dp value
  /// is the project's calibrated HyperOS 4 default and remains overrideable.
  static const double cornerRadius = 20;

  /// Default padding inside the card.
  static const EdgeInsets insideMargin = EdgeInsets.zero;

  /// Resolves the default color pair with independent caller overrides.
  static MiuixCardColors colors(
    BuildContext context, {
    Color? color,
    Color? contentColor,
  }) {
    final semantic = MiuixSemanticColors.of(context);
    return MiuixCardColors(
      color: color ?? semantic['surfaceContainer'],
      contentColor: contentColor ?? semantic['onSurfaceContainer'],
    );
  }
}

/// Card component with Miuix shape, color, and press feedback.
class MiuixCard extends StatelessWidget {
  /// Creates a HyperOS 4 content card with local backdrop material.
  const MiuixCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.feedbackType = MiuixPressFeedbackType.none,
    this.padding,
    this.insideMargin,
    this.margin,
    this.glass = true,
    this.glassBlur,
    this.glassOpacity,
    this.showGlassSpecular = true,
    this.color,
    this.colors,
    this.cornerRadius = double.nan,
    this.holdDown = false,
    this.showIndication = false,
  });

  /// Creates the interactive source overload with MIUIX parameter names.
  ///
  /// The ordinary constructor remains available for existing Flutter callers;
  /// this factory makes a direct `Card.kt` translation mechanically obvious.
  factory MiuixCard.source({
    Key? key,
    required Widget content,
    double cornerRadius = MiuixCardDefaults.legacyCornerRadius,
    EdgeInsetsGeometry insideMargin = MiuixCardDefaults.insideMargin,
    MiuixCardColors? colors,
    MiuixPressFeedbackType pressFeedbackType = MiuixPressFeedbackType.none,
    bool holdDownState = false,
    bool showIndication = false,
    VoidCallback? onClick,
    VoidCallback? onLongPress,
  }) {
    return MiuixCard(
      key: key,
      cornerRadius: cornerRadius,
      insideMargin: insideMargin,
      glass: false,
      showGlassSpecular: false,
      colors: colors,
      feedbackType: pressFeedbackType,
      holdDown: holdDownState,
      showIndication: showIndication,
      onTap: onClick,
      onLongPress: onLongPress,
      child: content,
    );
  }

  /// Card content.
  final Widget child;

  /// Optional tap callback.
  final VoidCallback? onTap;

  /// Optional long-press callback.
  final VoidCallback? onLongPress;

  /// MIUIX press-feedback style used by this card.
  final MiuixPressFeedbackType feedbackType;

  /// Inner padding.
  ///
  /// Compatibility alias for [insideMargin].
  final EdgeInsetsGeometry? padding;

  /// Source-named padding inside the card.
  final EdgeInsetsGeometry? insideMargin;

  /// Outer margin.
  final EdgeInsetsGeometry? margin;

  /// Whether to render as a glass card.
  final bool glass;

  /// Optional role-specific backdrop sigma and standard tint opacity.
  final double? glassBlur;
  final double? glassOpacity;

  /// Whether local card glass paints its restrained specular highlight.
  final bool showGlassSpecular;

  /// Optional explicit surface color for palette previews and custom cards.
  ///
  /// Compatibility override that takes precedence over [colors].
  final Color? color;

  /// Source color pair for the background and inherited content.
  final MiuixCardColors? colors;

  /// Continuous-corner radius of the card.
  final double cornerRadius;

  /// Whether press feedback remains held after the pointer is released.
  ///
  /// Upstream cards use this while a long-press action owns an open dialog.
  final bool holdDown;

  /// Whether a pressed overlay is shown independently of motion feedback.
  final bool showIndication;

  @override
  Widget build(BuildContext context) {
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final resolvedColors = colors ?? MiuixCardDefaults.colors(context);
    final baseColor = color ?? resolvedColors.color;
    final effectiveColor = glass
        ? baseColor.withValues(alpha: math.min(baseColor.a, .93))
        : baseColor;
    final effectiveCornerRadius = cornerRadius.isFinite
        ? math.max(0.0, cornerRadius)
        : hyperOs4.cardCornerRadius;
    // The current source spelling wins over the legacy compatibility alias.
    // This deterministic precedence is identical in debug and release.
    final effectiveInsideMargin =
        insideMargin ?? padding ?? MiuixCardDefaults.insideMargin;
    final hasClickAction = onTap != null || onLongPress != null;
    final usesCallbackFreeHoldMotion =
        !hasClickAction &&
        holdDown &&
        feedbackType != MiuixPressFeedbackType.none;
    final surface = MiuixSurface(
      // Card.kt installs combinedClickable only when at least one callback is
      // present. A feedback type or showIndication alone must not synthesize
      // a button, empty click callback, keyboard focus, hover, or press state.
      onTap: hasClickAction ? onTap : null,
      onLongPress: onLongPress,
      feedbackType: feedbackType,
      // HoldDownObserver feeds the same interaction source as clickable only
      // in the callback branch. The callback-free motion branch is wrapped
      // separately below so it can remain pointer-inert like the source.
      holdDown: hasClickAction && holdDown,
      showIndication: hasClickAction && showIndication,
      padding: effectiveInsideMargin,
      margin: usesCallbackFreeHoldMotion ? null : margin,
      glass: glass,
      glassBlur: glassBlur ?? hyperOs4.contentSurfaceBlur,
      glassOpacity: glassOpacity ?? hyperOs4.contentSurfaceTintOpacity,
      showGlassSpecular: showGlassSpecular,
      radius: effectiveCornerRadius,
      color: effectiveColor,
      contentColor: resolvedColors.contentColor,
      // Upstream BasicCard is only clip + background; it never paints an
      // outline. A faint Material-style border still creates two physical
      // edge pixels on the 420-dpi reference device and changes the apparent
      // card height, so the ordinary MIUIX card deliberately leaves it null.
      child: child,
    );
    if (!usesCallbackFreeHoldMotion) {
      return surface;
    }

    // Source order is caller modifier -> pressable -> BasicCard shape. This
    // branch exists only for externally held Sink/Tilt without a click/long-
    // click callback. It preserves that outer transform but deliberately
    // installs no pointer recognizer or accessibility action.
    final heldSurface = MiuixPressable(
      feedbackType: feedbackType,
      holdDown: true,
      feedbackOnly: true,
      pointerInputEnabled: false,
      child: surface,
    );
    final effectiveMargin = margin == null
        ? null
        : _miuixRoundedInsets(context, margin!);
    return Container(margin: effectiveMargin, child: heldSurface);
  }
}

/// Rounds one Compose-like measurement without accumulating sibling values.
///
/// Do not pass a sum of unrelated dimensions here. Compose modifier nodes
/// round their own padding, text, and child measurements independently; the
/// caller must preserve those boundaries to avoid density-dependent drift.
double _miuixRoundLogicalDimension(double logical, double pixelRatio) {
  if (!pixelRatio.isFinite || pixelRatio <= 0) return logical;
  return (logical * pixelRatio).roundToDouble() / pixelRatio;
}

/// Returns the integer-pixel height of a Compose text placeable.
///
/// Text layout encloses fractional font bounds instead of rounding them to the
/// nearest pixel. At 3x density, for example, the MIUIX 17sp button line box is
/// 59.16px and therefore occupies 60px.
double _miuixCeilLogicalDimension(double logical, double pixelRatio) {
  if (!pixelRatio.isFinite || pixelRatio <= 0) return logical;
  return (logical * pixelRatio).ceilToDouble() / pixelRatio;
}

/// Resolves and rounds every inset edge as its own Compose padding dimension.
EdgeInsets _miuixRoundedInsets(
  BuildContext context,
  EdgeInsetsGeometry geometry,
) {
  final resolved = geometry.resolve(Directionality.of(context));
  final ratio = MediaQuery.devicePixelRatioOf(context);
  return EdgeInsets.fromLTRB(
    _miuixRoundLogicalDimension(resolved.left, ratio),
    _miuixRoundLogicalDimension(resolved.top, ratio),
    _miuixRoundLogicalDimension(resolved.right, ratio),
    _miuixRoundLogicalDimension(resolved.bottom, ratio),
  );
}

/// Curated icon entry point mirroring MIUIX icon namespaces.
///
/// Flutter uses committed fonts generated from the authoritative Kotlin vector
/// objects. Single-layer Basic aliases retain their source viewport, while
/// common extended aliases resolve the current Regular optical-weight glyph.
/// The layered SearchCleanup artwork is rendered by the search components and
/// cannot be losslessly represented by Flutter's single-glyph [IconData].
abstract final class MiuixIcons {
  /// Common basic icons.
  static const basic = MiuixBasicIcons();

  /// Normal-weight icon aliases.
  static const normal = MiuixNormalIcons();

  /// Light-weight icon aliases.
  static const light = MiuixLightIcons();

  /// Medium-weight icon aliases.
  static const medium = MiuixMediumIcons();

  /// Demibold icon aliases.
  static const demibold = MiuixDemiboldIcons();

  /// Extended icon aliases for apps and actions.
  static const extended = MiuixExtendedIcons();
}

/// Basic MIUIX icon aliases.
class MiuixBasicIcons {
  /// Creates a basic icon namespace.
  const MiuixBasicIcons();

  /// Back or forward arrow.
  IconData get arrowRight => MiuixBasicIconCatalog.arrowRight;

  /// Up/down sorting arrow.
  IconData get arrowUpDown => MiuixBasicIconCatalog.arrowUpDown;

  /// Check mark.
  IconData get check => MiuixBasicIconCatalog.check;

  /// Close mark.
  IconData get close => MiuixBasicIconCatalog.close;

  /// Search magnifier.
  IconData get search => MiuixBasicIconCatalog.search;

  /// Material compatibility alias for a standalone search cleanup action.
  ///
  /// MIUIX SearchCleanup contains three independently translucent layers, so
  /// [MiuixSearchBar] and [MiuixSearchBarCompat] use the exact source painter
  /// instead. A single font glyph cannot preserve those alpha channels.
  IconData get searchCleanup => Icons.cancel;

  /// Sidebar action.
  IconData get sidebar => MiuixBasicIconCatalog.sidebar;
}

/// Normal icon namespace.
class MiuixNormalIcons extends MiuixBasicIcons {
  /// Creates a normal icon namespace.
  const MiuixNormalIcons();
}

/// Light icon namespace.
class MiuixLightIcons extends MiuixBasicIcons {
  /// Creates a light icon namespace.
  const MiuixLightIcons();
}

/// Medium icon namespace.
class MiuixMediumIcons extends MiuixBasicIcons {
  /// Creates a medium icon namespace.
  const MiuixMediumIcons();
}

/// Demibold icon namespace.
class MiuixDemiboldIcons extends MiuixBasicIcons {
  /// Creates a demibold icon namespace.
  const MiuixDemiboldIcons();
}

/// Extended MIUIX icon aliases commonly used by Xiaomi apps.
class MiuixExtendedIcons extends MiuixBasicIcons {
  /// Creates an extended icon namespace.
  const MiuixExtendedIcons();

  /// Add action.
  IconData get add => _regular('Add');

  /// Delete action.
  IconData get delete => _regular('Delete');

  /// Home destination.
  IconData get home => _regular('Home');

  /// Info action.
  IconData get info => _regular('Info');

  /// Location permission or place.
  IconData get location => _regular('Location');

  /// More actions.
  IconData get more => _regular('More');

  /// Phone device.
  IconData get phone => _regular('Phone');

  /// Refresh action.
  IconData get refresh => _regular('Refresh');

  /// Settings destination.
  IconData get settings => _regular('Settings');

  /// Share action.
  IconData get share => _regular('Share');

  /// Theme action.
  IconData get theme => _regular('Theme');

  /// Update action.
  IconData get update => _regular('Update');

  /// Resolves a required current-source glyph from the committed catalogue.
  IconData _regular(String name) {
    final icon = MiuixExtendedIconCatalog.find(name);
    if (icon == null) {
      // Public aliases and the generated catalogue ship as one library unit.
      // A missing name means those generated sources are inconsistent, so do
      // not defer the failure to a null assertion with build-mode differences.
      throw StateError('Missing generated MIUIX extended icon: $name');
    }
    return icon.regular;
  }
}
