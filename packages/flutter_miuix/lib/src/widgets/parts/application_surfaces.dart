part of '../miuix_widgets.dart';

// Application surfaces accept geometry from application state and persisted
// settings, so they share one finite non-negative boundary before layout.
// Shared extent contract:
// - Null delegates to the component's role-specific fallback.
// - A finite positive value remains an explicit application override.
// - Zero remains an explicit collapsed extent.
// - A finite negative value is projected to zero.
// - NaN never reaches a Flutter constraint or EdgeInsets constructor.
// - Positive infinity is rejected unless a component handles it explicitly.
// - Negative infinity follows the same fallback path as NaN.
// - A non-finite fallback is itself projected to zero.
// - Components may preserve a documented infinity semantic before this call.
// - The returned value is always finite and non-negative.
double _safeApplicationExtent(double? value, double fallback) {
  final safeFallback = fallback.isFinite ? math.max(0.0, fallback) : 0.0;
  final candidate = value ?? safeFallback;
  return candidate.isFinite ? math.max(0.0, candidate) : safeFallback;
}

/// Behavioral roles supported by [MiuixChip].
enum MiuixChipVariant {
  /// Invokes a lightweight contextual action.
  assist,

  /// Toggles whether content is included in a filter.
  filter,

  /// Selects one choice from an application-defined group.
  choice,

  /// Represents entered data and normally exposes deletion.
  input,

  /// Presents a suggested value or action.
  suggestion,
}

/// Explicit chip colors for light, dark, and branded surfaces.
@immutable
class MiuixChipColors {
  /// Creates a complete chip palette.
  const MiuixChipColors({
    required this.background,
    required this.foreground,
    required this.selectedBackground,
    required this.selectedForeground,
    required this.disabledBackground,
    required this.disabledForeground,
    required this.outline,
  });

  /// Idle, selected, disabled, and outline roles.
  final Color background;
  final Color foreground;
  final Color selectedBackground;
  final Color selectedForeground;
  final Color disabledBackground;
  final Color disabledForeground;
  final Color outline;
}

/// Geometry and color defaults for the complete chip family.
abstract final class MiuixChipDefaults {
  /// Compact source-aligned chip dimensions.
  static const double minimumHeight = 32;
  static const double maximumWidth = 220;
  static const double iconSize = 18;
  static const double deleteTargetSize = 20;

  /// Resolves colors without inheriting Material Chip defaults.
  static MiuixChipColors colors(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // 芯片是轻选中项；宿主提供层次时不再借用主按钮实色。
    final layers = MiuixAccentLayers.maybeOf(context);
    return MiuixChipColors(
      background: scheme.secondaryContainer.withValues(alpha: .88),
      foreground: scheme.onSecondaryContainer,
      selectedBackground: layers?.selectionFill ?? scheme.primaryContainer,
      selectedForeground:
          layers?.selectionForeground ?? scheme.onPrimaryContainer,
      // 禁用状态中性化，边界使用单独弱层，不再独立估算主色浓度。
      disabledBackground:
          layers?.disabledFill ??
          scheme.surfaceContainerHighest.withValues(alpha: .6),
      disabledForeground:
          layers?.disabledForeground ?? scheme.onSurface.withValues(alpha: .38),
      outline: layers?.outline ?? scheme.outlineVariant.withValues(alpha: .42),
    );
  }
}

/// Compact MIUIX chip with action, filter, choice, input, and suggestion roles.
class MiuixChip extends StatelessWidget {
  /// Creates a HyperOS 4 low-height glass capsule.
  const MiuixChip({
    super.key,
    required this.label,
    this.icon,
    this.avatar,
    this.trailing,
    this.onDeleted,
    this.onPressed,
    this.onSelected,
    this.variant = MiuixChipVariant.suggestion,
    this.selected = false,
    this.enabled = true,
    this.glass = true,
    this.glassBlur,
    this.glassOpacity,
    this.colors,
    this.tooltip,
  });

  /// Creates the former opaque MIUIX-compatible chip surface.
  const MiuixChip.source({
    super.key,
    required this.label,
    this.icon,
    this.avatar,
    this.trailing,
    this.onDeleted,
    this.onPressed,
    this.onSelected,
    this.variant = MiuixChipVariant.suggestion,
    this.selected = false,
    this.enabled = true,
    this.glass = false,
    this.glassBlur,
    this.glassOpacity,
    this.colors,
    this.tooltip,
  });

  /// Visible label and optional content slots.
  final String label;
  final Widget? icon;
  final Widget? avatar;
  final Widget? trailing;

  /// Deletion, action, and selection callbacks.
  final VoidCallback? onDeleted;
  final VoidCallback? onPressed;
  final ValueChanged<bool>? onSelected;

  /// Chip behavior and state.
  final MiuixChipVariant variant;
  final bool selected;
  final bool enabled;
  final bool glass;

  /// Optional role-specific material overrides.
  final double? glassBlur;
  final double? glassOpacity;

  /// Optional appearance and accessibility overrides.
  final MiuixChipColors? colors;
  final String? tooltip;

  bool get _interactive => onPressed != null || onSelected != null;

  void _activate() {
    if (!enabled) return;
    if (onSelected != null) {
      onSelected!(!selected);
      MiuixHaptics.perform(
        selected ? MiuixHapticType.toggleOff : MiuixHapticType.toggleOn,
      );
    } else {
      onPressed?.call();
      MiuixHaptics.perform(MiuixHapticType.confirm);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final palette = colors ?? MiuixChipDefaults.colors(context);
    final background = !enabled
        ? palette.disabledBackground
        : selected
        ? palette.selectedBackground
        : palette.background;
    final foreground = !enabled
        ? palette.disabledForeground
        : selected
        ? palette.selectedForeground
        : palette.foreground;
    final showsCheck =
        selected &&
        (variant == MiuixChipVariant.filter ||
            variant == MiuixChipVariant.choice) &&
        icon == null;
    // 内容表面已经负责裁剪；交互层只裁剪按压提示，不再次裁剪整颗芯片。
    // 两次抗锯齿会削弱细描边，普通圆角还会切掉 G2 连续圆角的两侧。
    final ShapeBorder feedbackShape = miuixIsSquircleEnabled(context)
        ? const MiuixCapsuleBorder()
        : const StadiumBorder();
    final content = ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: MiuixChipDefaults.minimumHeight,
        maxWidth: MiuixChipDefaults.maximumWidth,
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: avatar != null || icon != null || showsCheck ? 8 : 12,
          end: onDeleted != null || trailing != null ? 6 : 12,
          top: 6,
          bottom: 6,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (avatar != null) ...<Widget>[
              SizedBox.square(dimension: 20, child: avatar),
              const SizedBox(width: 6),
            ] else if (icon != null || showsCheck) ...<Widget>[
              IconTheme(
                data: IconThemeData(
                  color: foreground,
                  size: MiuixChipDefaults.iconSize,
                ),
                child: showsCheck
                    ? _MiuixDropdownCheck(
                        color: foreground,
                        size: MiuixChipDefaults.iconSize,
                      )
                    : icon!,
              ),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                label,
                // 长操作名称保留全文；有限宽度下换行并自然增高。
                // 禁用态与选择态使用相同布局，不因状态切换裁掉文字。
                softWrap: true,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (trailing != null) ...<Widget>[
              const SizedBox(width: 6),
              IconTheme(
                data: IconThemeData(color: foreground, size: 16),
                child: trailing!,
              ),
            ],
            if (onDeleted != null) ...<Widget>[
              const SizedBox(width: 6),
              Semantics(
                button: true,
                label: '删除 $label',
                child: MiuixPressable(
                  onTap: enabled
                      ? () {
                          onDeleted?.call();
                          MiuixHaptics.perform(MiuixHapticType.confirm);
                        }
                      : null,
                  borderRadius: BorderRadius.circular(999),
                  feedbackType: MiuixPressFeedbackType.none,
                  showIndication: enabled,
                  child: SizedBox.square(
                    dimension: MiuixChipDefaults.deleteTargetSize,
                    child: MiuixThemedIcon(
                      Icons.close,
                      size: 16,
                      color: foreground,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
    final interactive = _interactive && enabled;
    final result = TweenAnimationBuilder<Color?>(
      // Matching initial endpoints avoid an invented entrance fade. On later
      // rebuilds TweenAnimationBuilder retargets its owned tween from the
      // currently sampled color to the new semantic-state color.
      tween: ColorTween(begin: background, end: background),
      duration: reduceMotion ? Duration.zero : hyperOs4.chipMotion,
      curve: Curves.easeOutCubic,
      builder: (context, animatedBackground, child) => Semantics(
        button: _interactive,
        selected:
            variant == MiuixChipVariant.filter ||
                variant == MiuixChipVariant.choice
            ? selected
            : null,
        enabled: enabled,
        label: label,
        child: MiuixPressable(
          onTap: interactive ? _activate : null,
          // 反馈层跟随表面形状；表面拥有最终裁剪和完整描边。
          // 避免在完整边框外再次叠加 ClipRRect。
          shape: feedbackShape,
          contentAlreadyClipped: true,
          feedbackType: MiuixPressFeedbackType.sink,
          showIndication: interactive,
          child: MiuixSurface(
            color: animatedBackground ?? background,
            glass: glass,
            glassBlur: glassBlur ?? hyperOs4.chipBlur,
            glassOpacity: glassOpacity ?? hyperOs4.chipTintOpacity,
            showGlassSpecular: false,
            radius: 999,
            // 使用一个逻辑像素，曲线和直线都保留可读的连续边界。
            // 沿用主题 outline，不给禁用动作新增可用态颜色。
            border: BorderSide(color: palette.outline, width: 1),
            child: content,
          ),
        ),
      ),
    );
    return tooltip == null
        ? result
        : MiuixTooltip(message: tooltip!, child: result);
  }
}

/// Avatar widget for MIUI account and contact screens.
class MiuixAvatar extends StatelessWidget {
  /// Creates an avatar.
  const MiuixAvatar({super.key, this.image, this.initials, this.size = 48});

  /// Optional image provider.
  final ImageProvider? image;

  /// Optional initials.
  final String? initials;

  /// Avatar diameter.
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final safeSize = size.isFinite ? math.max(0.0, size) : 48.0;
    return SizedBox.square(
      dimension: safeSize,
      child: ClipOval(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: .10),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: .14),
              width: .5,
            ),
          ),
          child: image == null
              ? Center(
                  child: initials == null
                      ? null
                      : Text(
                          initials!,
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: scheme.primary,
                                fontSize: safeSize * .3,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                )
              : Image(image: image!, fit: BoxFit.cover),
        ),
      ),
    );
  }
}

/// Control center tile inspired by MIUI quick settings.
class MiuixControlCenterTile extends StatelessWidget {
  /// Creates a control center tile.
  const MiuixControlCenterTile({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.onTap,
    this.enabled = true,
    this.glass = true,
    this.glassBlur,
    this.glassOpacity,
    this.cornerRadius = double.nan,
  });

  /// Creates the former opaque compatibility tile.
  ///
  /// The ordinary constructor participates in the HyperOS 4 content material
  /// and the global five-level glass setting. This named constructor retains
  /// the previous 20dp solid surface without keeping it as the new default.
  const MiuixControlCenterTile.source({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.onTap,
    this.enabled = true,
  }) : glass = false,
       glassBlur = null,
       glassOpacity = null,
       cornerRadius = 20;

  /// Tile icon.
  final Widget icon;

  /// Tile label.
  final String label;

  /// Optional value text.
  final String? value;

  /// Tap callback.
  final VoidCallback? onTap;

  /// Whether the tile is enabled.
  final bool enabled;

  /// Whether the local tile samples content behind its rounded boundary.
  final bool glass;

  /// Optional role-specific blur and tint overrides.
  final double? glassBlur;
  final double? glassOpacity;

  /// Optional continuous-corner override.
  ///
  /// The NaN default resolves through the HyperOS 4 card token.
  final double cornerRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = MiuixTheme.of(context);
    final hyperOs4 = tokens.hyperOs4;
    final scheme = Theme.of(context).colorScheme;
    final activeColor = enabled ? scheme.primary : scheme.onSurfaceVariant;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final motion = reduceMotion ? Duration.zero : hyperOs4.inputStateMotion;
    final radius = cornerRadius.isFinite
        ? math.max(0.0, cornerRadius)
        : hyperOs4.cardCornerRadius;
    final surfaceColor = glass
        ? (enabled ? scheme.surfaceContainerLow : scheme.surfaceContainerHigh)
        : (enabled
              ? scheme.surfaceContainerLow.withValues(alpha: .97)
              : scheme.surfaceContainerHigh.withValues(alpha: .8));
    return TweenAnimationBuilder<Color?>(
      // A policy key publishes the final enabled state immediately when the
      // platform requests reduced motion during an in-flight color change.
      key: ValueKey<bool>(reduceMotion),
      tween: ColorTween(begin: surfaceColor, end: surfaceColor),
      duration: motion,
      curve: Curves.easeOutCubic,
      builder: (context, animatedSurfaceColor, _) => MiuixSurface(
        key: const ValueKey('miuix-control-center-tile-surface'),
        onTap: enabled ? onTap : null,
        radius: radius,
        color: animatedSurfaceColor ?? surfaceColor,
        glass: glass,
        glassBlur: glassBlur ?? hyperOs4.contentSurfaceBlur,
        glassOpacity: glassOpacity ?? hyperOs4.contentSurfaceTintOpacity,
        border: BorderSide(
          color: enabled
              ? scheme.outlineVariant.withValues(alpha: .06)
              : scheme.outlineVariant.withValues(alpha: .12),
          width: .5,
        ),
        padding: EdgeInsets.fromLTRB(
          tokens.spacing.md - 2,
          tokens.spacing.sm,
          tokens.spacing.md - 2,
          tokens.spacing.xs + 1,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 58),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: motion,
                curve: Curves.easeOutCubic,
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: enabled
                      ? scheme.primary.withValues(alpha: .072)
                      : scheme.surfaceContainerHigh.withValues(alpha: .68),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconTheme(
                  data: IconThemeData(color: activeColor, size: 12),
                  child: icon,
                ),
              ),
              const SizedBox(height: 8),
              AnimatedDefaultTextStyle(
                duration: motion,
                curve: Curves.easeOutCubic,
                style:
                    theme.textTheme.titleMedium?.copyWith(
                      color: enabled
                          ? scheme.onSurface
                          : scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                      height: 1.0,
                    ) ??
                    const TextStyle(),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (value != null) ...[
                const SizedBox(height: 2),
                AnimatedDefaultTextStyle(
                  duration: motion,
                  curve: Curves.easeOutCubic,
                  style:
                      theme.textTheme.bodySmall?.copyWith(
                        color: enabled
                            ? scheme.onSurfaceVariant
                            : scheme.onSurfaceVariant.withValues(alpha: .72),
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        height: 1.0,
                      ) ??
                      const TextStyle(),
                  child: Text(
                    value!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Control center tile with an embedded slider.
///
/// This covers common HyperOS controls such as brightness, volume, and media
/// intensity where the tile itself is both a status surface and a value editor.
class MiuixControlSliderTile extends StatelessWidget {
  /// Creates a control slider tile.
  const MiuixControlSliderTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.glass = true,
    this.glassBlur,
    this.glassOpacity,
    this.cornerRadius = double.nan,
  });

  /// Creates the former compact opaque slider tile.
  ///
  /// This path is retained for explicit migration work. The ordinary
  /// constructor follows the HyperOS 4 content-material theme by default.
  const MiuixControlSliderTile.source({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
  }) : glass = false,
       glassBlur = null,
       glassOpacity = null,
       cornerRadius = 18;

  /// Tile icon.
  final Widget icon;

  /// Tile label.
  final String label;

  /// Current slider value.
  final double value;

  /// Change callback.
  final ValueChanged<double> onChanged;

  /// Minimum value.
  final double min;

  /// Maximum value.
  final double max;

  /// Whether the compact local surface samples content behind it.
  final bool glass;

  /// Optional role-specific backdrop and tint overrides.
  final double? glassBlur;
  final double? glassOpacity;

  /// Optional continuous-corner override.
  ///
  /// The NaN default resolves from the shared HyperOS 4 card role.
  final double cornerRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = MiuixTheme.of(context);
    final hyperOs4 = tokens.hyperOs4;
    final range = _safeRange(min, max);
    final safeValue = _finiteOr(value, range.min).clamp(range.min, range.max);
    final denominator = range.max - range.min;
    final scheme = theme.colorScheme;
    final percent = denominator == 0
        ? 0
        : (((safeValue - range.min) / denominator) * 100).round();
    final radius = cornerRadius.isFinite
        ? math.max(0.0, cornerRadius)
        : hyperOs4.cardCornerRadius;
    return MiuixSurface(
      key: const ValueKey('miuix-control-slider-tile-surface'),
      radius: radius,
      color: Color.alphaBlend(
        scheme.primary.withValues(alpha: .045),
        glass
            ? scheme.surfaceContainerLow
            : scheme.surfaceContainerLow.withValues(alpha: .98),
      ),
      glass: glass,
      glassBlur: glassBlur ?? hyperOs4.contentSurfaceBlur,
      glassOpacity: glassOpacity ?? hyperOs4.contentSurfaceTintOpacity,
      border: BorderSide(
        color: scheme.outlineVariant.withValues(alpha: .045),
        width: .5,
      ),
      padding: EdgeInsets.fromLTRB(
        tokens.spacing.xs + 6,
        tokens.spacing.xs - 1,
        tokens.spacing.xs + 6,
        tokens.spacing.xs - 3,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 34),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 18,
                  height: 18,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: .06),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: IconTheme(
                    data: IconThemeData(size: 9.5, color: scheme.primary),
                    child: icon,
                  ),
                ),
                SizedBox(width: tokens.spacing.sm),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -.15,
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '$percent%',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontSize: 6.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 0),
            MiuixSlider(
              value: safeValue,
              min: range.min,
              max: range.max,
              height: 7.5,
              trackScale: .64,
              thumbScale: .7,
              onChanged: denominator == 0
                  ? null
                  : (next) {
                      final safeNext = _normalizeSliderCallbackValue(
                        next,
                        range,
                      );
                      if ((safeNext - safeValue).abs() > 0.0005) {
                        onChanged(safeNext);
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}

/// Account header surface for MIUI account and settings pages.
class MiuixAccountHeader extends StatelessWidget {
  /// Creates an account header.
  const MiuixAccountHeader({
    super.key,
    required this.name,
    this.subtitle,
    this.avatar,
    this.trailing,
    this.onTap,
    this.glass = true,
    this.glassBlur,
    this.glassOpacity,
    this.showGlassSpecular = true,
    this.cornerRadius = double.nan,
  });

  /// Creates the former opaque account-header card.
  const MiuixAccountHeader.source({
    super.key,
    required this.name,
    this.subtitle,
    this.avatar,
    this.trailing,
    this.onTap,
  }) : glass = false,
       glassBlur = null,
       glassOpacity = null,
       showGlassSpecular = false,
       cornerRadius = MiuixCardDefaults.legacyCornerRadius;

  /// Account display name.
  final String name;

  /// Optional account subtitle.
  final String? subtitle;

  /// Optional avatar.
  final Widget? avatar;

  /// Optional trailing widget.
  final Widget? trailing;

  /// Tap callback.
  final VoidCallback? onTap;

  /// Local application-card material and shape controls.
  final bool glass;
  final double? glassBlur;
  final double? glassOpacity;
  final bool showGlassSpecular;
  final double cornerRadius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return MiuixCard(
      onTap: onTap,
      glass: glass,
      glassBlur: glassBlur,
      glassOpacity: glassOpacity,
      showGlassSpecular: showGlassSpecular,
      cornerRadius: cornerRadius,
      child: Row(
        children: [
          avatar ?? const MiuixAvatar(initials: 'Mi', size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Device status card used by connected-device and ecosystem screens.
class MiuixDeviceCard extends StatelessWidget {
  /// Creates a device card.
  const MiuixDeviceCard({
    super.key,
    required this.name,
    required this.status,
    this.icon = const MiuixThemedIcon(Icons.devices),
    this.battery,
    this.onTap,
    this.glass = true,
    this.glassBlur,
    this.glassOpacity,
    this.showGlassSpecular = true,
    this.cornerRadius = double.nan,
  });

  /// Creates the former opaque connected-device card.
  const MiuixDeviceCard.source({
    super.key,
    required this.name,
    required this.status,
    this.icon = const MiuixThemedIcon(Icons.devices),
    this.battery,
    this.onTap,
  }) : glass = false,
       glassBlur = null,
       glassOpacity = null,
       showGlassSpecular = false,
       cornerRadius = MiuixCardDefaults.legacyCornerRadius;

  /// Device name.
  final String name;

  /// Device status text.
  final String status;

  /// Device icon.
  final Widget icon;

  /// Optional battery percentage.
  final int? battery;

  /// Tap callback.
  final VoidCallback? onTap;

  /// Local application-card material and shape controls.
  final bool glass;
  final double? glassBlur;
  final double? glassOpacity;
  final bool showGlassSpecular;
  final double cornerRadius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return MiuixCard(
      onTap: onTap,
      glass: glass,
      glassBlur: glassBlur,
      glassOpacity: glassOpacity,
      showGlassSpecular: showGlassSpecular,
      cornerRadius: cornerRadius,
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: .07),
              borderRadius: BorderRadius.circular(11),
            ),
            child: IconTheme(
              data: IconThemeData(color: scheme.primary, size: 17),
              child: icon,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  status,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          if (battery != null)
            Text(
              '$battery%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

/// Application row for package installers, app managers, and security tools.
class MiuixAppListTile extends StatelessWidget {
  /// Creates an app list tile.
  const MiuixAppListTile({
    super.key,
    required this.name,
    this.packageName,
    this.icon,
    this.trailing,
    this.onTap,
    this.glass = true,
    this.glassBlur,
    this.glassOpacity,
    this.showGlassSpecular = true,
    this.cornerRadius = double.nan,
  }) : _sourceStyle = false;

  /// Creates the former opaque application-list card.
  const MiuixAppListTile.source({
    super.key,
    required this.name,
    this.packageName,
    this.icon,
    this.trailing,
    this.onTap,
  }) : glass = false,
       glassBlur = null,
       glassOpacity = null,
       showGlassSpecular = false,
       cornerRadius = MiuixCardDefaults.legacyCornerRadius,
       _sourceStyle = true;

  /// App display name.
  final String name;

  /// Optional package identifier.
  final String? packageName;

  /// Optional app icon.
  final Widget? icon;

  /// Optional trailing widget.
  final Widget? trailing;

  /// Tap callback.
  final VoidCallback? onTap;

  /// Local application-card material and shape controls.
  final bool glass;
  final double? glassBlur;
  final double? glassOpacity;
  final bool showGlassSpecular;
  final double cornerRadius;
  final bool _sourceStyle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return MiuixCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      glass: glass,
      glassBlur: glassBlur,
      glassOpacity: glassOpacity,
      showGlassSpecular: showGlassSpecular,
      cornerRadius: cornerRadius,
      child: MiuixPreference(
        title: name,
        summary: packageName,
        leading: Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: .07),
            borderRadius: BorderRadius.circular(9),
          ),
          child: IconTheme(
            data: IconThemeData(color: scheme.primary, size: 15),
            child: icon ?? const MiuixThemedIcon(Icons.apps),
          ),
        ),
        trailing: trailing,
        onTap: null,
        sourceStyle: _sourceStyle,
      ),
    );
  }
}

/// Notification-style card with app identity, title, body, and actions.
class MiuixNotificationCard extends StatelessWidget {
  /// Creates a notification card.
  const MiuixNotificationCard({
    super.key,
    required this.title,
    required this.body,
    this.appName,
    this.icon,
    this.actions = const [],
    this.glass = true,
    this.glassBlur,
    this.glassOpacity,
    this.showGlassSpecular = true,
    this.cornerRadius = double.nan,
  });

  /// Creates the former opaque notification card.
  const MiuixNotificationCard.source({
    super.key,
    required this.title,
    required this.body,
    this.appName,
    this.icon,
    this.actions = const [],
  }) : glass = false,
       glassBlur = null,
       glassOpacity = null,
       showGlassSpecular = false,
       cornerRadius = MiuixCardDefaults.legacyCornerRadius;

  /// Notification title.
  final String title;

  /// Notification body.
  final String body;

  /// Optional app name.
  final String? appName;

  /// Optional app icon.
  final Widget? icon;

  /// Optional action buttons.
  final List<Widget> actions;

  /// Local application-card material and shape controls.
  final bool glass;
  final double? glassBlur;
  final double? glassOpacity;
  final bool showGlassSpecular;
  final double cornerRadius;

  @override
  Widget build(BuildContext context) {
    final theme = MiuixTheme.of(context);
    final scheme = Theme.of(context).colorScheme;
    return MiuixCard(
      glass: glass,
      glassBlur: glassBlur,
      glassOpacity: glassOpacity,
      showGlassSpecular: showGlassSpecular,
      cornerRadius: cornerRadius,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: .07),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: IconTheme(
                  data: IconThemeData(color: scheme.primary, size: 15),
                  child: icon ?? const MiuixThemedIcon(Icons.notifications),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  appName ?? title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: theme.spacing.xs + 1),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontSize: 12,
              height: 1.2,
            ),
          ),
          if (actions.isNotEmpty) ...[
            SizedBox(height: theme.spacing.sm + 1),
            Wrap(spacing: theme.spacing.sm, children: actions),
          ],
        ],
      ),
    );
  }
}

/// Permission prompt card for privacy and security workflows.
class MiuixPermissionCard extends StatelessWidget {
  /// Creates a permission card.
  const MiuixPermissionCard({
    super.key,
    required this.permission,
    required this.description,
    required this.onAllow,
    required this.onDeny,
    this.icon = const MiuixThemedIcon(Icons.privacy_tip),
    this.glass = true,
    this.glassBlur,
    this.glassOpacity,
    this.showGlassSpecular = true,
    this.cornerRadius = double.nan,
  });

  /// Creates the former opaque permission prompt card.
  const MiuixPermissionCard.source({
    super.key,
    required this.permission,
    required this.description,
    required this.onAllow,
    required this.onDeny,
    this.icon = const MiuixThemedIcon(Icons.privacy_tip),
  }) : glass = false,
       glassBlur = null,
       glassOpacity = null,
       showGlassSpecular = false,
       cornerRadius = MiuixCardDefaults.legacyCornerRadius;

  /// Permission name.
  final String permission;

  /// Explanation shown to the user.
  final String description;

  /// Allow callback.
  final VoidCallback onAllow;

  /// Deny callback.
  final VoidCallback onDeny;

  /// Prompt icon.
  final Widget icon;

  /// Local application-card material and shape controls.
  final bool glass;
  final double? glassBlur;
  final double? glassOpacity;
  final bool showGlassSpecular;
  final double cornerRadius;

  @override
  Widget build(BuildContext context) {
    final theme = MiuixTheme.of(context);
    final scheme = Theme.of(context).colorScheme;
    return MiuixCard(
      glass: glass,
      glassBlur: glassBlur,
      glassOpacity: glassOpacity,
      showGlassSpecular: showGlassSpecular,
      cornerRadius: cornerRadius,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.error.withValues(alpha: .07),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: IconTheme(
                  data: IconThemeData(color: scheme.error, size: 15),
                  child: icon,
                ),
              ),
              const SizedBox(width: 9),
              Text(
                permission,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: theme.spacing.xs + 1),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontSize: 12,
              height: 1.2,
            ),
          ),
          SizedBox(height: theme.spacing.sm + 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              MiuixButton(label: 'Deny', filled: false, onPressed: onDeny),
              SizedBox(width: theme.spacing.sm),
              MiuixButton(label: 'Allow', filled: true, onPressed: onAllow),
            ],
          ),
        ],
      ),
    );
  }
}

/// Update card for system updater and app updater surfaces.
class MiuixUpdateCard extends StatelessWidget {
  /// Creates an update card.
  const MiuixUpdateCard({
    super.key,
    required this.version,
    required this.summary,
    this.progress,
    this.onUpdate,
    this.glass = true,
    this.glassBlur,
    this.glassOpacity,
    this.showGlassSpecular = true,
    this.cornerRadius = double.nan,
  });

  /// Creates the former opaque update card.
  const MiuixUpdateCard.source({
    super.key,
    required this.version,
    required this.summary,
    this.progress,
    this.onUpdate,
  }) : glass = false,
       glassBlur = null,
       glassOpacity = null,
       showGlassSpecular = false,
       cornerRadius = MiuixCardDefaults.legacyCornerRadius;

  /// Version label.
  final String version;

  /// Update summary.
  final String summary;

  /// Optional download or install progress.
  final double? progress;

  /// Optional update callback.
  final VoidCallback? onUpdate;

  /// Local application-card material and shape controls.
  final bool glass;
  final double? glassBlur;
  final double? glassOpacity;
  final bool showGlassSpecular;
  final double cornerRadius;

  @override
  Widget build(BuildContext context) {
    final theme = MiuixTheme.of(context);
    final scheme = Theme.of(context).colorScheme;
    return MiuixCard(
      glass: glass,
      glassBlur: glassBlur,
      glassOpacity: glassOpacity,
      showGlassSpecular: showGlassSpecular,
      cornerRadius: cornerRadius,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            version,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: theme.spacing.xs + 1),
          Text(
            summary,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontSize: 12,
              height: 1.2,
            ),
          ),
          if (progress != null) ...[
            SizedBox(height: theme.spacing.sm + 1),
            MiuixProgressIndicator(value: progress),
          ],
          if (onUpdate != null) ...[
            SizedBox(height: theme.spacing.sm + 1),
            MiuixButton(label: 'Update', filled: true, onPressed: onUpdate),
          ],
        ],
      ),
    );
  }
}

/// Inline alert banner for warnings, tips, and status messages.
class MiuixInlineAlert extends StatelessWidget {
  /// Creates a HyperOS 4 inline alert with semantic glass tint.
  const MiuixInlineAlert({
    super.key,
    required this.message,
    this.icon = const MiuixThemedIcon(Icons.info),
    this.severity = MiuixAlertSeverity.info,
    this.title,
    this.action,
    this.onDismissed,
    this.glass = true,
    this.glassBlur,
    this.glassOpacity,
    this.cornerRadius,
  });

  /// Creates the former opaque inline-alert presentation.
  const MiuixInlineAlert.source({
    super.key,
    required this.message,
    this.icon = const MiuixThemedIcon(Icons.info),
    this.severity = MiuixAlertSeverity.info,
    this.title,
    this.action,
    this.onDismissed,
    this.glass = false,
    this.glassBlur,
    this.glassOpacity,
    this.cornerRadius = 18,
  });

  /// Alert message.
  final String message;

  /// Alert icon.
  final Widget icon;

  /// Alert severity.
  final MiuixAlertSeverity severity;

  /// Optional heading, inline action, and dismiss callback.
  final String? title;
  final Widget? action;
  final VoidCallback? onDismissed;

  /// Whether the alert uses the package glass surface.
  final bool glass;

  /// Optional material and continuous-corner overrides.
  final double? glassBlur;
  final double? glassOpacity;
  final double? cornerRadius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final color = switch (severity) {
      MiuixAlertSeverity.info => scheme.primary.withValues(alpha: .08),
      MiuixAlertSeverity.warning => Colors.amber.shade100,
      MiuixAlertSeverity.error => scheme.error.withValues(alpha: .10),
      MiuixAlertSeverity.success => Colors.green.shade100,
    };
    final alert = MiuixSurface(
      color: color,
      glass: glass,
      glassBlur: glassBlur ?? hyperOs4.inlineSurfaceBlur,
      glassOpacity: glassOpacity ?? hyperOs4.inlineSurfaceTintOpacity,
      radius: cornerRadius ?? hyperOs4.inlineSurfaceCornerRadius,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: BorderSide(
        color: switch (severity) {
          MiuixAlertSeverity.info => scheme.primary.withValues(alpha: .14),
          MiuixAlertSeverity.warning => Colors.amber.shade300.withValues(
            alpha: .28,
          ),
          MiuixAlertSeverity.error => scheme.error.withValues(alpha: .18),
          MiuixAlertSeverity.success => Colors.green.shade300.withValues(
            alpha: .24,
          ),
        },
        width: .5,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconTheme(
            data: IconThemeData(
              color: switch (severity) {
                MiuixAlertSeverity.info => scheme.primary,
                MiuixAlertSeverity.warning => Colors.amber.shade800,
                MiuixAlertSeverity.error => scheme.error,
                MiuixAlertSeverity.success => Colors.green.shade700,
              },
              size: 18,
            ),
            child: icon,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (title != null)
                  Text(
                    title!,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (title != null) const SizedBox(height: 2),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface,
                    fontSize: 13,
                    height: 1.25,
                  ),
                ),
                if (action != null) ...<Widget>[
                  const SizedBox(height: 8),
                  action!,
                ],
              ],
            ),
          ),
          if (onDismissed != null) ...<Widget>[
            const SizedBox(width: 6),
            MiuixIconButton(
              icon: const MiuixThemedIcon(Icons.close_rounded),
              tooltip: '关闭',
              minWidth: 32,
              minHeight: 32,
              onPressed: () {
                MiuixHaptics.perform(MiuixHapticType.toggleOff);
                onDismissed!();
              },
            ),
          ],
        ],
      ),
    );
    return Semantics(
      container: true,
      liveRegion: true,
      label: title == null ? message : '$title. $message',
      child: alert,
    );
  }
}

/// Alert severity values.
enum MiuixAlertSeverity {
  /// Informational state.
  info,

  /// Warning state.
  warning,

  /// Error state.
  error,

  /// Success state.
  success,
}

/// Promotional or instructional banner.
class MiuixBanner extends StatelessWidget {
  /// Creates a HyperOS 4 local glass banner.
  const MiuixBanner({
    super.key,
    required this.title,
    required this.message,
    this.action,
    this.leading,
    this.onDismissed,
    this.glass = true,
    this.glassBlur,
    this.glassOpacity,
    this.cornerRadius,
    this.liveRegion = false,
  });

  /// Creates the former opaque banner presentation.
  const MiuixBanner.source({
    super.key,
    required this.title,
    required this.message,
    this.action,
    this.leading,
    this.onDismissed,
    this.glass = false,
    this.glassBlur,
    this.glassOpacity,
    this.cornerRadius = 20,
    this.liveRegion = false,
  });

  /// Banner title.
  final String title;

  /// Banner message.
  final String message;

  /// Optional action.
  final Widget? action;

  /// Optional leading artwork and dismiss control.
  final Widget? leading;
  final VoidCallback? onDismissed;

  /// Optional package glass surface and announcement policy.
  final bool glass;
  final double? glassBlur;
  final double? glassOpacity;
  final double? cornerRadius;
  final bool liveRegion;

  @override
  Widget build(BuildContext context) {
    final theme = MiuixTheme.of(context);
    final hyperOs4 = theme.hyperOs4;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final banner = MiuixSurface(
      color: surfaceColor,
      glass: glass,
      glassBlur: glassBlur ?? hyperOs4.inlineSurfaceBlur,
      glassOpacity: glassOpacity ?? hyperOs4.inlineSurfaceTintOpacity,
      radius: cornerRadius ?? hyperOs4.inlineSurfaceCornerRadius,
      border: BorderSide(
        color: Theme.of(
          context,
        ).colorScheme.outlineVariant.withValues(alpha: .18),
        width: .5,
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (leading != null) ...<Widget>[
            IconTheme(
              data: IconThemeData(
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
              child: leading!,
            ),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: theme.spacing.xs + 2),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
                if (action != null) ...[
                  SizedBox(height: theme.spacing.sm + 2),
                  action!,
                ],
              ],
            ),
          ),
          if (onDismissed != null) ...<Widget>[
            const SizedBox(width: 8),
            MiuixIconButton(
              icon: const MiuixThemedIcon(Icons.close_rounded),
              tooltip: '关闭',
              onPressed: () {
                MiuixHaptics.perform(MiuixHapticType.toggleOff);
                onDismissed!();
              },
            ),
          ],
        ],
      ),
    );
    return Semantics(
      container: true,
      liveRegion: liveRegion,
      label: '$title. $message',
      child: banner,
    );
  }
}

/// Empty state component for lists and dashboards.
class MiuixEmptyState extends StatelessWidget {
  /// Creates a HyperOS 4 content-first empty state.
  const MiuixEmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon = const MiuixThemedIcon(Icons.inbox),
    this.action,
    this.announce = true,
    this.maximumWidth,
    this.padding,
    this.iconSize,
  }) : _sourceGeometry = false;

  /// Creates the former unconstrained empty-state composition.
  const MiuixEmptyState.source({
    super.key,
    required this.title,
    this.message,
    this.icon = const MiuixThemedIcon(Icons.inbox, size: 56),
    this.action,
    this.announce = false,
  }) : maximumWidth = null,
       padding = null,
       iconSize = null,
       _sourceGeometry = true;

  /// Empty state title.
  final String title;

  /// Optional message.
  final String? message;

  /// Empty state icon.
  final Widget icon;

  /// Optional action.
  final Widget? action;

  /// Whether assistive technologies announce the empty-state update.
  final bool announce;

  /// Optional readable-width, outer-padding, and icon-size overrides.
  final double? maximumWidth;
  final double? padding;
  final double? iconSize;

  final bool _sourceGeometry;

  @override
  Widget build(BuildContext context) {
    final theme = MiuixTheme.of(context);
    final scheme = Theme.of(context).colorScheme;
    final hyperOs4 = theme.hyperOs4;
    // The legacy constructor preserves the old scattered 20/52/10/6/10dp
    // geometry and unconstrained line width. HyperOS 4 resolves every standard
    // metric from one auditable token family while optional public overrides
    // remain local to this instance.
    final requestedMaximumWidth = maximumWidth;
    final resolvedMaximumWidth =
        _sourceGeometry || requestedMaximumWidth == double.infinity
        ? double.infinity
        : _safeApplicationExtent(
            requestedMaximumWidth,
            hyperOs4.emptyStateMaximumWidth,
          );
    final resolvedPadding = _sourceGeometry
        ? theme.spacing.xl
        : _safeApplicationExtent(padding, hyperOs4.emptyStatePadding);
    final resolvedIconSize = _sourceGeometry
        ? 52.0
        : _safeApplicationExtent(iconSize, hyperOs4.emptyStateIconSize);
    final resolvedTitleSpacing = _sourceGeometry
        ? theme.spacing.sm + 2
        : hyperOs4.emptyStateTitleSpacing;
    final resolvedMessageSpacing = _sourceGeometry
        ? theme.spacing.xs + 2
        : hyperOs4.emptyStateMessageSpacing;
    final resolvedActionSpacing = _sourceGeometry
        ? theme.spacing.md
        : hyperOs4.emptyStateActionSpacing;
    final content = ConstrainedBox(
      key: const ValueKey('miuix-empty-state-content'),
      constraints: BoxConstraints(maxWidth: resolvedMaximumWidth),
      child: Padding(
        padding: EdgeInsets.all(resolvedPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconTheme(
              key: const ValueKey('miuix-empty-state-icon-theme'),
              data: IconThemeData(
                color: scheme.onSurfaceVariant.withValues(alpha: .92),
                size: resolvedIconSize,
              ),
              child: icon,
            ),
            SizedBox(
              key: const ValueKey('miuix-empty-state-title-spacing'),
              height: resolvedTitleSpacing,
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (message != null) ...[
              SizedBox(
                key: const ValueKey('miuix-empty-state-message-spacing'),
                height: resolvedMessageSpacing,
              ),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
            ],
            if (action != null) ...[
              SizedBox(
                key: const ValueKey('miuix-empty-state-action-spacing'),
                height: resolvedActionSpacing,
              ),
              action!,
            ],
          ],
        ),
      ),
    );
    // Empty content belongs to the page hierarchy rather than a modal surface.
    // Centering remains outside the constrained composition so wide windows do
    // not stretch copy, and announcing merges title and explanation exactly
    // once without changing the visible child semantics.
    return Semantics(
      container: true,
      liveRegion: announce,
      label: message == null ? title : '$title. $message',
      child: Center(child: content),
    );
  }
}

/// Expandable card for dense settings or information sections.
class MiuixExpandableCard extends StatefulWidget {
  /// Creates a HyperOS 4 expandable glass section.
  const MiuixExpandableCard({
    super.key,
    required this.title,
    required this.children,
    this.leading,
    this.subtitle,
    this.trailing,
    this.initiallyExpanded = false,
    this.expanded,
    this.onExpandedChanged,
    this.enabled = true,
    this.glass = true,
    this.glassBlur,
    this.glassOpacity,
    this.cornerRadius,
  });

  /// Creates the former opaque, rectangular expandable section.
  const MiuixExpandableCard.source({
    super.key,
    required this.title,
    required this.children,
    this.leading,
    this.subtitle,
    this.trailing,
    this.initiallyExpanded = false,
    this.expanded,
    this.onExpandedChanged,
    this.enabled = true,
    this.glass = false,
    this.glassBlur,
    this.glassOpacity,
    this.cornerRadius = 0,
  });

  /// Card title.
  final String title;

  /// Optional leading widget.
  final Widget? leading;

  /// Optional supporting label and trailing content.
  final String? subtitle;
  final Widget? trailing;

  /// Child widgets shown when expanded.
  final List<Widget> children;

  /// Whether the card starts expanded.
  final bool initiallyExpanded;

  /// Controlled expansion value and change callback.
  final bool? expanded;
  final ValueChanged<bool>? onExpandedChanged;

  /// Interaction and optional package glass policy.
  final bool enabled;
  final bool glass;

  /// Optional material and continuous-corner overrides.
  final double? glassBlur;
  final double? glassOpacity;
  final double? cornerRadius;

  @override
  State<MiuixExpandableCard> createState() => _MiuixExpandableCardState();
}

class _MiuixExpandableCardState extends State<MiuixExpandableCard> {
  late bool _expanded;

  bool get _hasChildren => widget.children.isNotEmpty;
  bool get _effectiveExpanded => _hasChildren && (widget.expanded ?? _expanded);

  void _toggle() {
    if (!_hasChildren || !widget.enabled) return;
    final next = !_effectiveExpanded;
    if (widget.expanded == null) setState(() => _expanded = next);
    widget.onExpandedChanged?.call(next);
    MiuixHaptics.perform(
      next ? MiuixHapticType.toggleOn : MiuixHapticType.toggleOff,
    );
  }

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded && _hasChildren;
  }

  @override
  void didUpdateWidget(covariant MiuixExpandableCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_hasChildren) {
      _expanded = false;
    } else if (oldWidget.initiallyExpanded != widget.initiallyExpanded) {
      _expanded = widget.initiallyExpanded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final motion = reduceMotion ? Duration.zero : hyperOs4.inlineSurfaceMotion;
    final radius = widget.cornerRadius ?? hyperOs4.inlineSurfaceCornerRadius;
    final card = MiuixSurface(
      padding: EdgeInsets.zero,
      color: scheme.surface,
      glass: widget.glass,
      glassBlur: widget.glassBlur ?? hyperOs4.inlineSurfaceBlur,
      glassOpacity: widget.glassOpacity ?? hyperOs4.inlineSurfaceTintOpacity,
      radius: radius,
      border: BorderSide(
        color: scheme.outlineVariant.withValues(alpha: .18),
        width: .5,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MiuixPressable(
            onTap: _hasChildren && widget.enabled ? _toggle : null,
            borderRadius: BorderRadius.circular(radius),
            feedbackType: MiuixPressFeedbackType.none,
            showIndication: _hasChildren && widget.enabled,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  if (widget.leading != null) ...[
                    IconTheme(
                      data: IconThemeData(color: scheme.onSurface, size: 18),
                      child: widget.leading!,
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: widget.enabled
                                    ? scheme.onSurface
                                    : scheme.onSurface.withValues(alpha: .38),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        if (widget.subtitle != null)
                          Text(
                            widget.subtitle!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                      ],
                    ),
                  ),
                  if (widget.trailing != null) ...<Widget>[
                    const SizedBox(width: 8),
                    widget.trailing!,
                  ],
                  if (_hasChildren) ...<Widget>[
                    const SizedBox(width: 6),
                    _MiuixVerticalDisclosureArrow(
                      key: const ValueKey('miuix-expandable-card-arrow'),
                      expanded: _effectiveExpanded,
                      color: scheme.onSurfaceVariant,
                      duration: motion,
                    ),
                  ],
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: motion,
            crossFadeState: _effectiveExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: widget.children,
              ),
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
    return Semantics(
      container: true,
      button: _hasChildren,
      enabled: widget.enabled,
      expanded: _hasChildren ? _effectiveExpanded : null,
      label: widget.subtitle == null
          ? widget.title
          : '${widget.title}. ${widget.subtitle}',
      child: card,
    );
  }
}

/// Page indicator for carousels and onboarding flows.
class MiuixPageIndicator extends StatelessWidget {
  /// Creates a page indicator.
  const MiuixPageIndicator({
    super.key,
    required this.count,
    required this.index,
    this.dotSize,
    this.activeWidth,
    this.spacing,
  }) : _sourceGeometry = false;

  /// Creates an indicator with the former fixed 6/16/2.5dp geometry.
  const MiuixPageIndicator.source({
    super.key,
    required this.count,
    required this.index,
  }) : dotSize = null,
       activeWidth = null,
       spacing = null,
       _sourceGeometry = true;

  /// Number of pages.
  final int count;

  /// Active page index.
  final int index;

  /// Optional geometry overrides; omitted values follow HyperOS 4 tokens.
  final double? dotSize;
  final double? activeWidth;
  final double? spacing;

  final bool _sourceGeometry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    // The source entry point is deliberately insulated from theme calibration.
    // Normal values are sanitized so external data cannot create invalid box
    // constraints while custom applications may still author their geometry.
    final resolvedDotSize = _sourceGeometry
        ? 6.0
        : _safeApplicationExtent(dotSize, hyperOs4.pageIndicatorDotSize);
    final requestedActiveWidth = _sourceGeometry
        ? 16.0
        : _safeApplicationExtent(
            activeWidth,
            hyperOs4.pageIndicatorActiveWidth,
          );
    final resolvedActiveWidth = math.max(resolvedDotSize, requestedActiveWidth);
    final resolvedSpacing = _sourceGeometry
        ? 2.5
        : _safeApplicationExtent(spacing, hyperOs4.pageIndicatorSpacing);
    final safeCount = count < 0 ? 0 : count;
    final safeIndex = safeCount == 0 ? -1 : index.clamp(0, safeCount - 1);
    if (safeCount == 0) {
      return const SizedBox.shrink();
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < safeCount; i++)
          AnimatedContainer(
            // Recreate an in-flight implicit animation when the inherited
            // policy changes so reduced motion cannot retain a sampled width.
            key: ValueKey<(int, bool)>((i, reduceMotion)),
            duration: reduceMotion
                ? Duration.zero
                : hyperOs4.pageIndicatorMotion,
            curve: Curves.easeOutCubic,
            width: i == safeIndex ? resolvedActiveWidth : resolvedDotSize,
            height: resolvedDotSize,
            margin: EdgeInsets.symmetric(horizontal: resolvedSpacing),
            decoration: BoxDecoration(
              color: i == safeIndex
                  ? scheme.primary.withValues(alpha: .92)
                  : scheme.outlineVariant.withValues(alpha: .72),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
      ],
    );
  }
}

/// Visual state for a compact [MiuixStepperRow].
enum MiuixStepperRowState { pending, current, completed, error }

/// Stepper row for setup flows and update/install progress.
class MiuixStepperRow extends StatelessWidget {
  /// Creates a stepper row.
  const MiuixStepperRow({
    super.key,
    required this.index,
    required this.title,
    this.subtitle,
    this.completed = false,
    this.state,
    this.icon,
    this.trailing,
    this.onTap,
    this.enabled = true,
  });

  /// Step index.
  final int index;

  /// Step title.
  final String title;

  /// Optional subtitle.
  final String? subtitle;

  /// Whether the step is complete.
  final bool completed;

  /// Full state override; [completed] remains the compatibility shortcut.
  final MiuixStepperRowState? state;

  /// Optional marker, trailing content, and row activation.
  final Widget? icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final motion = reduceMotion ? Duration.zero : hyperOs4.processStateMotion;
    final resolvedState =
        state ??
        (completed
            ? MiuixStepperRowState.completed
            : MiuixStepperRowState.pending);
    final markerColor = switch (resolvedState) {
      MiuixStepperRowState.current ||
      MiuixStepperRowState.completed => scheme.primary,
      MiuixStepperRowState.error => scheme.error,
      MiuixStepperRowState.pending => scheme.secondaryContainer,
    };
    final markerForeground = switch (resolvedState) {
      MiuixStepperRowState.current ||
      MiuixStepperRowState.completed => scheme.onPrimary,
      MiuixStepperRowState.error => scheme.onError,
      MiuixStepperRowState.pending => scheme.onSecondaryContainer,
    };
    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            TweenAnimationBuilder<Color?>(
              // The policy identity removes any sampled intermediate marker
              // color as soon as reduced motion becomes authoritative.
              key: ValueKey<bool>(reduceMotion),
              tween: ColorTween(begin: markerColor, end: markerColor),
              duration: motion,
              curve: Curves.easeOutCubic,
              builder: (context, animatedMarkerColor, _) => DecoratedBox(
                decoration: BoxDecoration(
                  color: animatedMarkerColor ?? markerColor,
                  shape: BoxShape.circle,
                ),
                child: SizedBox.square(
                  dimension: 32,
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: motion,
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeOutCubic,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(
                            begin: .86,
                            end: 1,
                          ).animate(animation),
                          child: child,
                        ),
                      ),
                      child: KeyedSubtree(
                        key: ValueKey<MiuixStepperRowState>(resolvedState),
                        child:
                            icon ??
                            (resolvedState == MiuixStepperRowState.completed
                                ? _MiuixDropdownCheck(
                                    color: markerForeground,
                                    size: 18,
                                  )
                                : resolvedState == MiuixStepperRowState.error
                                ? MiuixThemedIcon(
                                    Icons.close,
                                    color: markerForeground,
                                    size: 18,
                                  )
                                : Text(
                                    '$index',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(color: markerForeground),
                                  )),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: motion,
                    curve: Curves.easeOutCubic,
                    style:
                        Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight:
                              resolvedState == MiuixStepperRowState.current
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: enabled
                              ? scheme.onSurface
                              : scheme.onSurface.withValues(alpha: .38),
                        ) ??
                        const TextStyle(),
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) ...<Widget>[
              const SizedBox(width: 10),
              trailing!,
            ],
          ],
        ),
      ),
    );
    return Semantics(
      button: onTap != null,
      enabled: enabled,
      selected: resolvedState == MiuixStepperRowState.current,
      label: subtitle == null ? title : '$title. $subtitle',
      child: MiuixPressable(
        onTap: enabled && onTap != null
            ? () {
                MiuixHaptics.perform(MiuixHapticType.segmentTick);
                onTap!();
              }
            : null,
        borderRadius: BorderRadius.circular(hyperOs4.collectionRowCornerRadius),
        feedbackType: MiuixPressFeedbackType.none,
        showIndication: enabled && onTap != null,
        child: row,
      ),
    );
  }
}

/// Loading dialog helper.
class MiuixLoadingDialog {
  /// Shows an indeterminate loading dialog.
  static Future<T?> show<T>({
    required BuildContext context,
    String message = 'Loading...',
    String? details,
    double? progress,
    bool cancelable = false,
    String cancelLabel = 'Cancel',
    VoidCallback? onCancel,
    bool glass = true,
  }) {
    var cancellationReported = false;
    void reportCancellation() {
      if (cancellationReported) return;
      cancellationReported = true;
      onCancel?.call();
    }

    return MiuixDialog.show<T>(
      context: context,
      title: message,
      summary: details,
      // MiuixDialog already owns the clipped HyperOS 4 backdrop material.
      // Wrapping it in another MiuixGlass sampled and tinted the same pixels
      // twice, producing a cloudy opaque panel at stronger intensity levels.
      glass: glass,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (progress == null)
            const Center(child: MiuixInfiniteProgressIndicator())
          else
            Semantics(
              value: '${(progress.clamp(0.0, 1.0) * 100).round()}%',
              child: MiuixProgressIndicator(value: progress),
            ),
          if (cancelable) ...<Widget>[
            const SizedBox(height: 14),
            MiuixTextButton(
              label: cancelLabel,
              onPressed: () {
                reportCancellation();
                Navigator.maybeOf(context, rootNavigator: true)?.maybePop();
              },
            ),
          ],
        ],
      ),
      barrierDismissible: cancelable,
      onDismissRequest: cancelable ? reportCancellation : null,
    );
  }
}

/// Toast and snackbar helper.
class MiuixToast {
  /// Shows a snackbar-like toast.
  static MiuixSnackbarController show(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    MiuixSnackbarDuration duration = MiuixSnackbarDuration.short,
    bool withDismissAction = false,
  }) {
    if (!context.mounted) {
      return MiuixSnackbar.show(context, message);
    }
    MiuixHaptics.perform(MiuixHapticType.contextClick);
    return MiuixSnackbar.show(
      context,
      message,
      action: actionLabel == null
          ? null
          : SnackBarAction(label: actionLabel, onPressed: onAction ?? () {}),
      duration: duration,
      withDismissAction: withDismissAction,
      // Plain toast feedback must never block controls behind its overlay.
      ignorePointer: actionLabel == null && !withDismissAction,
    );
  }
}
