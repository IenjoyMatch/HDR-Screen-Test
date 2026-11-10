import 'package:flutter/material.dart';

import '../../theme/miuix_semantic_colors.dart';
import '../../theme/miuix_theme.dart';

/// Theme colors for skeleton loading placeholders.
@immutable
class MiuixSkeletonColors {
  /// Creates a skeleton palette.
  const MiuixSkeletonColors({required this.base, required this.highlight});

  /// Resting placeholder color.
  final Color base;

  /// Moving highlight color.
  final Color highlight;
}

/// Animation and color defaults for [MiuixSkeleton].
abstract final class MiuixSkeletonDefaults {
  /// Duration of one complete shimmer pass.
  static const Duration duration = Duration(milliseconds: 1350);

  /// Former fixed corner radius, retained by the source-style constructor.
  static const double cornerRadius = 12;

  /// Resolves neutral MIUIX semantic roles for the current theme.
  static MiuixSkeletonColors colors(BuildContext context) {
    final semantic = MiuixSemanticColors.of(context);
    return MiuixSkeletonColors(
      base: semantic['secondaryContainer'],
      highlight: semantic['surfaceContainerHigh'],
    );
  }
}

/// Animated MIUIX loading placeholder that respects reduced motion.
class MiuixSkeleton extends StatefulWidget {
  /// Creates a rectangular or circular placeholder.
  const MiuixSkeleton({
    super.key,
    this.width,
    this.height,
    this.cornerRadius = double.nan,
    this.shape = BoxShape.rectangle,
    this.colors,
    this.duration = MiuixSkeletonDefaults.duration,
    this.enabled = true,
  });

  /// Creates a placeholder with the former fixed 12dp rectangle geometry.
  const MiuixSkeleton.source({
    super.key,
    this.width,
    this.height,
    this.shape = BoxShape.rectangle,
    this.colors,
    this.duration = MiuixSkeletonDefaults.duration,
    this.enabled = true,
  }) : cornerRadius = MiuixSkeletonDefaults.cornerRadius;

  /// Optional explicit placeholder extent.
  final double? width;
  final double? height;

  /// Rectangle corner radius, ignored for circles.
  final double cornerRadius;

  /// Rectangle or circle placeholder shape.
  final BoxShape shape;

  /// Optional palette and animation overrides.
  final MiuixSkeletonColors? colors;
  final Duration duration;
  final bool enabled;

  @override
  State<MiuixSkeleton> createState() => _MiuixSkeletonState();
}

class _MiuixSkeletonState extends State<MiuixSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation;

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(vsync: this, duration: Duration.zero);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(MiuixSkeleton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAnimation();
  }

  void _syncAnimation() {
    // A caller-provided non-default duration remains an explicit API override.
    // The unchanged compatibility default instead follows the application token
    // so existing call sites migrate without losing source compatibility.
    final requestedDuration = widget.duration == MiuixSkeletonDefaults.duration
        ? MiuixTheme.of(context).hyperOs4.skeletonMotion
        : widget.duration;
    final duration = requestedDuration < Duration.zero
        ? Duration.zero
        : requestedDuration;
    _animation.duration = duration;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (widget.enabled && !reduceMotion && duration > Duration.zero) {
      if (!_animation.isAnimating) _animation.repeat();
    } else {
      _animation.stop();
      // Reduced motion must be deterministic rather than preserving whichever
      // shimmer phase happened to be visible when the preference changed.
      _animation.value = .5;
    }
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors ?? MiuixSkeletonDefaults.colors(context);
    // A finite value is an explicit caller override. The sentinel lets old
    // source code adopt the shared HyperOS calibration without widening the
    // public field type or silently changing explicit values.
    final themeCorner = MiuixTheme.of(context).hyperOs4.skeletonCornerRadius;
    final safeThemeCorner = themeCorner.isFinite && themeCorner >= 0
        ? themeCorner
        : 0.0;
    final cornerRadius = widget.cornerRadius.isFinite
        ? widget.cornerRadius.clamp(0.0, double.infinity).toDouble()
        : safeThemeCorner;
    final width = _safeSkeletonExtent(widget.width);
    final height = _safeSkeletonExtent(widget.height);
    return Semantics(
      label: 'Loading',
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final progress = widget.enabled ? _animation.value : .5;
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              shape: widget.shape,
              borderRadius: widget.shape == BoxShape.rectangle
                  ? BorderRadius.circular(cornerRadius)
                  : null,
              gradient: LinearGradient(
                begin: Alignment(-2.5 + progress * 5, 0),
                end: Alignment(-.5 + progress * 5, 0),
                colors: <Color>[colors.base, colors.highlight, colors.base],
                stops: const <double>[0, .5, 1],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Null retains the ordinary unconstrained axis. Explicit invalid geometry is
// collapsed to zero instead of propagating an impossible tight constraint.
// Skeleton extent contract:
// - Null keeps the original Container axis unconstrained.
// - Finite positive values retain their exact logical size.
// - Zero remains a valid invisible placeholder axis.
// - Negative values collapse without creating negative BoxConstraints.
// - NaN collapses instead of poisoning intrinsic layout calculations.
// - Both infinities collapse instead of requesting an infinite tight size.
// - Width and height apply the same rule to avoid asymmetric failures.
// - Animation and semantics remain mounted even for a zero-sized placeholder.
double? _safeSkeletonExtent(double? value) {
  if (value == null) return null;
  if (!value.isFinite || value < 0) return 0;
  return value;
}

/// Shimmer-named facade for applications that use that terminology.
class MiuixShimmer extends MiuixSkeleton {
  /// Creates a shimmer placeholder.
  const MiuixShimmer({
    super.key,
    super.width,
    super.height,
    super.cornerRadius,
    super.shape,
    super.colors,
    super.duration,
    super.enabled,
  });

  /// Creates the shimmer facade with the former fixed 12dp geometry.
  const MiuixShimmer.source({
    super.key,
    super.width,
    super.height,
    super.shape,
    super.colors,
    super.duration,
    super.enabled,
  }) : super.source();
}
