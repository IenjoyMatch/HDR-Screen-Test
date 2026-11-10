part of '../miuix_widgets.dart';

/// Color channels used by MIUIX linear and circular progress indicators.
@immutable
class MiuixProgressIndicatorColors {
  /// Creates a progress-indicator color set.
  const MiuixProgressIndicatorColors({
    required this.foregroundColor,
    required this.disabledForegroundColor,
    required this.backgroundColor,
  });

  /// Active progress color.
  final Color foregroundColor;

  /// Disabled progress color retained by the source color contract.
  final Color disabledForegroundColor;

  /// Track color.
  final Color backgroundColor;

  /// Resolves the source foreground channel.
  Color foreground({bool enabled = true}) =>
      enabled ? foregroundColor : disabledForegroundColor;

  /// Returns a source-style value copy with selected channels replaced.
  MiuixProgressIndicatorColors copyWith({
    Color? foregroundColor,
    Color? disabledForegroundColor,
    Color? backgroundColor,
  }) {
    return MiuixProgressIndicatorColors(
      foregroundColor: foregroundColor ?? this.foregroundColor,
      disabledForegroundColor:
          disabledForegroundColor ?? this.disabledForegroundColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }

  // Kotlin declares this model as a data class. Value equality is observable
  // through recomposition and also avoids repainting equal reconstructed sets.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MiuixProgressIndicatorColors &&
          foregroundColor == other.foregroundColor &&
          disabledForegroundColor == other.disabledForegroundColor &&
          backgroundColor == other.backgroundColor;

  @override
  int get hashCode =>
      Object.hash(foregroundColor, disabledForegroundColor, backgroundColor);
}

/// Source defaults shared by every progress-indicator adapter.
abstract final class MiuixProgressIndicatorDefaults {
  /// Source-named default linear indicator height.
  static const double defaultLinearProgressIndicatorHeight = 6;

  /// Default linear indicator height.
  static const double linearHeight = defaultLinearProgressIndicatorHeight;

  /// Source-named default circular indicator diameter.
  static const double defaultCircularProgressIndicatorSize = 30;

  /// Default circular indicator diameter.
  static const double circularSize = defaultCircularProgressIndicatorSize;

  /// Source-named default circular indicator stroke width.
  static const double defaultCircularProgressIndicatorStrokeWidth = 4;

  /// Default circular indicator stroke.
  static const double circularStrokeWidth =
      defaultCircularProgressIndicatorStrokeWidth;

  /// Source-named default orbit indicator diameter.
  static const double defaultInfiniteProgressIndicatorSize = 20;

  /// Default orbit indicator diameter.
  static const double infiniteSize = defaultInfiniteProgressIndicatorSize;

  /// Source-named default orbit-ring stroke width.
  static const double defaultInfiniteProgressIndicatorStrokeWidth = 2;

  /// Default orbit ring stroke.
  static const double infiniteStrokeWidth =
      defaultInfiniteProgressIndicatorStrokeWidth;

  /// Source-named default orbiting-dot radius.
  static const double defaultInfiniteProgressIndicatorOrbitingDotSize = 2;

  /// Default orbiting-dot radius.
  static const double orbitingDotSize =
      defaultInfiniteProgressIndicatorOrbitingDotSize;

  /// Resolves `ProgressIndicatorDefaults.progressIndicatorColors`.
  static MiuixProgressIndicatorColors progressIndicatorColors(
    BuildContext context, {
    Color? foregroundColor,
    Color? disabledForegroundColor,
    Color? backgroundColor,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final semantic = MiuixSemanticColors.of(context);
    return MiuixProgressIndicatorColors(
      foregroundColor: foregroundColor ?? scheme.primary,
      disabledForegroundColor:
          disabledForegroundColor ?? semantic['disabledPrimarySlider'],
      backgroundColor: backgroundColor ?? scheme.secondaryContainer,
    );
  }

  /// Compatibility shorthand for [progressIndicatorColors].
  static MiuixProgressIndicatorColors colors(BuildContext context) =>
      progressIndicatorColors(context);
}

/// Converts unchecked theme motion tokens into an AnimationController-safe
/// duration. Zero deliberately means a stable indeterminate frame rather than
/// an assertion-producing repeat loop.
///
/// Motion-token contract:
///
/// * Negative durations are treated as authoring errors and become zero.
/// * A zero duration is a supported static-loading presentation.
/// * Finite determinate progress never needs an autonomous clock.
/// * Linear static loading keeps a centered partial segment visible.
/// * Circular static loading keeps a medium sweep at twelve o'clock.
/// * Orbit static loading keeps the dot at its initial angular position.
/// * Loading semantics remain active even when pixels are stationary.
/// * Reduced-motion policy and zero-clock policy share the same endpoints.
/// * Updating a duration re-evaluates whether its controller may repeat.
/// * A positive replacement duration restarts an indeterminate controller.
/// * A zero replacement duration stops an already-running controller.
/// * Rotation and sweep clocks can be independently enabled or frozen.
/// * Source constructors retain their known-positive compatibility clocks.
/// * Only unchecked theme tokens require this defensive normalization.
/// * Painters receive normalized controller values, never invalid time input.
Duration _safeProgressDuration(Duration duration) =>
    duration < Duration.zero ? Duration.zero : duration;

/// Linear and circular progress indicator wrapper.
class MiuixProgressIndicator extends StatelessWidget {
  /// Creates a progress indicator.
  const MiuixProgressIndicator({
    super.key,
    double? value,
    double? progress,
    this.circular = false,
    this.colors,
    this.height = double.nan,
    this.strokeWidth = double.nan,
    this.size = double.nan,
  }) : value = progress ?? value,
       _sourceMotion = false;

  /// Creates an indicator with the MIUIX 1.0.9 geometry and motion clocks.
  const MiuixProgressIndicator.source({
    super.key,
    double? value,
    double? progress,
    this.circular = false,
    this.colors,
    this.height = MiuixProgressIndicatorDefaults.linearHeight,
    this.strokeWidth = MiuixProgressIndicatorDefaults.circularStrokeWidth,
    this.size = MiuixProgressIndicatorDefaults.circularSize,
  }) : value = progress ?? value,
       _sourceMotion = true;

  /// Compatibility progress value, or null for indeterminate.
  final double? value;

  /// Source-named progress value, or null for indeterminate.
  double? get progress => value;

  /// Whether to render a circular indicator.
  final bool circular;

  /// Optional source color channels.
  final MiuixProgressIndicatorColors? colors;

  /// Linear indicator height.
  final double height;

  /// Circular indicator stroke width.
  final double strokeWidth;

  /// Circular indicator diameter.
  final double size;

  final bool _sourceMotion;

  @override
  Widget build(BuildContext context) {
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final effectiveColors =
        colors ?? MiuixProgressIndicatorDefaults.colors(context);
    final effectiveHeight = height.isFinite
        ? height
        : hyperOs4.progressLinearHeight;
    final effectiveStrokeWidth = strokeWidth.isFinite
        ? strokeWidth
        : hyperOs4.progressCircularStrokeWidth;
    final effectiveSize = size.isFinite ? size : hyperOs4.progressCircularSize;
    return circular
        ? _MiuixCircularProgress(
            value: value,
            colors: effectiveColors,
            strokeWidth: effectiveStrokeWidth,
            size: effectiveSize,
            rotationDuration: _safeProgressDuration(
              _sourceMotion
                  ? const Duration(milliseconds: 1000)
                  : hyperOs4.progressCircularRotationMotion,
            ),
            sweepDuration: _safeProgressDuration(
              _sourceMotion
                  ? const Duration(milliseconds: 1600)
                  : hyperOs4.progressCircularSweepMotion,
            ),
          )
        : _MiuixLinearProgress(
            value: value,
            colors: effectiveColors,
            height: effectiveHeight,
            duration: _safeProgressDuration(
              _sourceMotion
                  ? const Duration(milliseconds: 1250)
                  : hyperOs4.progressLinearMotion,
            ),
          );
  }
}

class _MiuixLinearProgress extends StatefulWidget {
  const _MiuixLinearProgress({
    this.value,
    required this.colors,
    required this.height,
    required this.duration,
  });

  final double? value;
  final MiuixProgressIndicatorColors colors;
  final double height;
  final Duration duration;

  @override
  State<_MiuixLinearProgress> createState() => _MiuixLinearProgressState();
}

class _MiuixLinearProgressState extends State<_MiuixLinearProgress>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion == reduceMotion && _controller.isAnimating) {
      return;
    }
    _reduceMotion = reduceMotion;
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant _MiuixLinearProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
      _syncAnimation();
    }
    if (oldWidget.value != widget.value) {
      _syncAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncAnimation() {
    if (widget.value == null) {
      if (_reduceMotion || widget.duration == Duration.zero) {
        _controller.stop();
        // A centered partial bar remains recognizable as indeterminate while
        // avoiding the autonomous sweep that reduced-motion users disabled.
        _controller.value = .5;
        return;
      }
      if (!_controller.isAnimating) {
        // The source conditional branch forgets its transition whenever a
        // finite value is shown, so a later indeterminate phase starts at zero.
        _controller.value = 0;
        _controller.repeat();
      }
      return;
    }
    if (_controller.isAnimating) {
      _controller.stop();
    }
    _controller.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.value == null
        ? null
        : _finiteOr(widget.value!, 0).clamp(0.0, 1.0);
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final height = _miuixRoundLogicalDimension(
      math.max(0, _finiteOr(widget.height, 0)),
      pixelRatio,
    );
    return Semantics(
      value: progress == null ? null : '${(progress * 100).round()}%',
      minValue: progress == null ? null : '0',
      maxValue: progress == null ? null : '1',
      role: progress == null
          ? SemanticsRole.loadingSpinner
          : SemanticsRole.progressBar,
      child: SizedBox(
        key: const ValueKey('miuix-linear-progress'),
        height: height,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: _MiuixLinearProgressPainter(
                progress: progress,
                animation: _controller.value,
                colors: widget.colors,
              ),
              child: const SizedBox.expand(),
            );
          },
        ),
      ),
    );
  }
}

class _MiuixLinearProgressPainter extends CustomPainter {
  const _MiuixLinearProgressPainter({
    required this.progress,
    required this.animation,
    required this.colors,
  });

  final double? progress;
  final double animation;
  final MiuixProgressIndicatorColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(size.height / 2);
    final background = Paint()..color = colors.backgroundColor;
    final foreground = Paint()..color = colors.foreground();
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, radius),
      background,
    );
    if (progress == null) {
      for (var i = 0; i < 3; i++) {
        final raw = animation - i;
        final adjusted = raw - raw.floorToDouble();
        final segment = size.width * .45;
        final left = size.width * adjusted;
        final rect = Rect.fromLTWH(left, 0, segment, size.height);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect.intersect(Offset.zero & size), radius),
          foreground,
        );
        if (left + segment > size.width) {
          final overflow = left + segment - size.width;
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(0, 0, overflow, size.height),
              radius,
            ),
            foreground,
          );
        }
      }
      return;
    }
    final minWidth = size.height;
    final width = minWidth + (size.width - minWidth) * progress!;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, width, size.height), radius),
      foreground,
    );
  }

  @override
  bool shouldRepaint(covariant _MiuixLinearProgressPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        animation != oldDelegate.animation ||
        colors != oldDelegate.colors;
  }
}

class _MiuixCircularProgress extends StatefulWidget {
  const _MiuixCircularProgress({
    this.value,
    required this.colors,
    required this.strokeWidth,
    required this.size,
    required this.rotationDuration,
    required this.sweepDuration,
  });

  final double? value;
  final MiuixProgressIndicatorColors colors;
  final double strokeWidth;
  final double size;
  final Duration rotationDuration;
  final Duration sweepDuration;

  @override
  State<_MiuixCircularProgress> createState() => _MiuixCircularProgressState();
}

class _MiuixCircularProgressState extends State<_MiuixCircularProgress>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _sweepController;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.rotationDuration,
    );
    _sweepController = AnimationController(
      vsync: this,
      duration: widget.sweepDuration,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion == reduceMotion &&
        _controller.isAnimating &&
        _sweepController.isAnimating) {
      return;
    }
    _reduceMotion = reduceMotion;
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant _MiuixCircularProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rotationDuration != widget.rotationDuration) {
      _controller.duration = widget.rotationDuration;
    }
    if (oldWidget.sweepDuration != widget.sweepDuration) {
      _sweepController.duration = widget.sweepDuration;
    }
    if (oldWidget.value != widget.value ||
        oldWidget.rotationDuration != widget.rotationDuration ||
        oldWidget.sweepDuration != widget.sweepDuration) {
      _syncAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _sweepController.dispose();
    super.dispose();
  }

  void _syncAnimation() {
    if (widget.value == null) {
      if (_reduceMotion ||
          (widget.rotationDuration == Duration.zero &&
              widget.sweepDuration == Duration.zero)) {
        _controller.stop();
        _sweepController.stop();
        // Freeze a medium sweep at twelve o'clock. The loading role remains
        // exposed to assistive technology even though pixels no longer move.
        _controller.value = 0;
        _sweepController.value = .5;
        return;
      }
      if (widget.rotationDuration > Duration.zero && !_controller.isAnimating) {
        _controller.value = 0;
        _controller.repeat();
      } else if (widget.rotationDuration == Duration.zero) {
        _controller.stop();
        _controller.value = 0;
      }
      if (widget.sweepDuration > Duration.zero &&
          !_sweepController.isAnimating) {
        _sweepController.value = 0;
        _sweepController.repeat();
      } else if (widget.sweepDuration == Duration.zero) {
        _sweepController.stop();
        _sweepController.value = .5;
      }
      return;
    }
    if (_controller.isAnimating) {
      _controller.stop();
    }
    if (_sweepController.isAnimating) {
      _sweepController.stop();
    }
    _controller.value = 0;
    _sweepController.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.value == null
        ? null
        : _finiteOr(widget.value!, 0).clamp(0.0, 1.0);
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final size = _miuixRoundLogicalDimension(
      math.max(0, _finiteOr(widget.size, 0)),
      pixelRatio,
    );
    final strokeWidth = math
        .max(0, _finiteOr(widget.strokeWidth, 0))
        .clamp(0.0, size)
        .toDouble();
    return Semantics(
      value: progress == null ? null : '${(progress * 100).round()}%',
      minValue: progress == null ? null : '0',
      maxValue: progress == null ? null : '1',
      role: progress == null
          ? SemanticsRole.loadingSpinner
          : SemanticsRole.progressBar,
      child: SizedBox.square(
        key: const ValueKey('miuix-circular-progress'),
        dimension: size,
        child: AnimatedBuilder(
          animation: Listenable.merge([_controller, _sweepController]),
          builder: (context, _) {
            return CustomPaint(
              painter: _MiuixCircularProgressPainter(
                progress: progress,
                rotation: _controller.value,
                sweepProgress: _sweepController.value,
                colors: widget.colors,
                strokeWidth: strokeWidth,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MiuixCircularProgressPainter extends CustomPainter {
  const _MiuixCircularProgressPainter({
    required this.progress,
    required this.rotation,
    required this.sweepProgress,
    required this.colors,
    required this.strokeWidth,
  });

  final double? progress;
  final double rotation;
  final double sweepProgress;
  final MiuixProgressIndicatorColors colors;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect =
        Offset(strokeWidth / 2, strokeWidth / 2) &
        Size(size.width - strokeWidth, size.height - strokeWidth);
    final background = Paint()
      ..color = colors.backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final foreground = Paint()
      ..color = colors.foreground()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;
    // ProgressIndicator.kt uses drawCircle for the track. A 360-degree arc has
    // a seam/cap path on some raster backends and is not the same primitive.
    canvas.drawCircle(center, radius, background);
    final start = progress == null ? rotation * math.pi * 2 : -math.pi / 2;
    final sweep = progress == null
        ? debugMiuixCircularIndeterminateSweepDegrees(sweepProgress) *
              math.pi /
              180
        : ((.1 + (359.9 * progress!)) * math.pi / 180);
    canvas.drawArc(rect, start, sweep, false, foreground);
  }

  @override
  bool shouldRepaint(covariant _MiuixCircularProgressPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        rotation != oldDelegate.rotation ||
        sweepProgress != oldDelegate.sweepProgress ||
        colors != oldDelegate.colors ||
        strokeWidth != oldDelegate.strokeWidth;
  }
}

/// Exposes the MIUIX circular indeterminate sweep timing for tests.
@visibleForTesting
double debugMiuixCircularIndeterminateSweepDegrees(double progress) {
  final t = progress.clamp(0.0, 1.0);
  return t <= .5 ? 30 + 180 * t : 210 - 180 * t;
}

class _MiuixOrbitProgress extends StatefulWidget {
  const _MiuixOrbitProgress({
    required this.color,
    required this.size,
    required this.strokeWidth,
    required this.orbitingDotSize,
    required this.duration,
  });

  final Color color;
  final double size;
  final double strokeWidth;
  final double orbitingDotSize;
  final Duration duration;

  @override
  State<_MiuixOrbitProgress> createState() => _MiuixOrbitProgressState();
}

class _MiuixOrbitProgressState extends State<_MiuixOrbitProgress>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion == reduceMotion && _controller.isAnimating) {
      return;
    }
    _reduceMotion = reduceMotion;
    if (reduceMotion) {
      _controller.stop();
      // Keep the orbiting dot visible without implying a completed value.
      _controller.value = 0;
    } else if (widget.duration > Duration.zero && !_controller.isAnimating) {
      _controller.repeat();
    } else if (widget.duration == Duration.zero) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void didUpdateWidget(covariant _MiuixOrbitProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
      if (_reduceMotion || widget.duration == Duration.zero) {
        _controller.stop();
        _controller.value = 0;
      } else if (!_controller.isAnimating) {
        _controller.repeat();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final size = _miuixRoundLogicalDimension(
      math.max(0, _finiteOr(widget.size, 0)),
      pixelRatio,
    );
    final strokeWidth = math
        .max(0, _finiteOr(widget.strokeWidth, 0))
        .clamp(0.0, size)
        .toDouble();
    final orbitingDotSize = math
        .max(0, _finiteOr(widget.orbitingDotSize, 0))
        .clamp(0.0, size / 2)
        .toDouble();
    return Semantics(
      role: SemanticsRole.loadingSpinner,
      child: SizedBox.square(
        key: const ValueKey('miuix-infinite-progress'),
        dimension: size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: _MiuixOrbitProgressPainter(
                animation: _controller.value,
                color: widget.color,
                strokeWidth: strokeWidth,
                orbitingDotSize: orbitingDotSize,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MiuixOrbitProgressPainter extends CustomPainter {
  const _MiuixOrbitProgressPainter({
    required this.animation,
    required this.color,
    required this.strokeWidth,
    required this.orbitingDotSize,
  });

  final double animation;
  final Color color;
  final double strokeWidth;
  final double orbitingDotSize;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, paint);
    final angle = animation * math.pi * 2;
    final orbitRadius = radius - 2 * orbitingDotSize;
    canvas.drawCircle(
      center +
          Offset(math.cos(angle) * orbitRadius, math.sin(angle) * orbitRadius),
      orbitingDotSize,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _MiuixOrbitProgressPainter oldDelegate) {
    return animation != oldDelegate.animation ||
        color != oldDelegate.color ||
        strokeWidth != oldDelegate.strokeWidth ||
        orbitingDotSize != oldDelegate.orbitingDotSize;
  }
}

/// Linear progress adapter.
class MiuixLinearProgressIndicator extends MiuixProgressIndicator {
  /// Creates a linear progress indicator.
  const MiuixLinearProgressIndicator({
    super.key,
    super.value,
    super.progress,
    super.colors,
    super.height,
  }) : super(circular: false);

  /// Creates the linear adapter with MIUIX 1.0.9 geometry and motion.
  const MiuixLinearProgressIndicator.source({
    super.key,
    super.value,
    super.progress,
    super.colors,
  }) : super.source(circular: false);
}

/// Circular progress adapter.
class MiuixCircularProgressIndicator extends MiuixProgressIndicator {
  /// Creates a circular progress indicator.
  const MiuixCircularProgressIndicator({
    super.key,
    super.value,
    super.progress,
    super.colors,
    super.strokeWidth,
    super.size,
  }) : super(circular: true);

  /// Creates the circular adapter with MIUIX 1.0.9 geometry and motion.
  const MiuixCircularProgressIndicator.source({
    super.key,
    super.value,
    super.progress,
    super.colors,
  }) : super.source(circular: true);
}

/// Indeterminate progress adapter matching MIUIX `InfiniteProgressIndicator`.
class MiuixInfiniteProgressIndicator extends MiuixProgressIndicator {
  /// Creates an indeterminate progress indicator.
  const MiuixInfiniteProgressIndicator({
    super.key,
    super.circular = false,
    this.color = defaultColor,
    super.size,
    super.strokeWidth,
    this.orbitingDotSize = double.nan,
  }) : super(value: null);

  /// Creates the orbit adapter with MIUIX 1.0.9 geometry and motion.
  const MiuixInfiniteProgressIndicator.source({
    super.key,
    super.circular = false,
    this.color = defaultColor,
  }) : orbitingDotSize = MiuixProgressIndicatorDefaults.orbitingDotSize,
       super.source(
         value: null,
         size: MiuixProgressIndicatorDefaults.infiniteSize,
         strokeWidth: MiuixProgressIndicatorDefaults.infiniteStrokeWidth,
       );

  /// Compose `Color.Gray`, the exact source default for the orbit indicator.
  static const Color defaultColor = Color(0xFF888888);

  /// Orbit and dot color.
  final Color color;

  /// Orbiting-dot radius.
  final double orbitingDotSize;

  @override
  Widget build(BuildContext context) {
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final effectiveSize = size.isFinite ? size : hyperOs4.progressInfiniteSize;
    final effectiveStrokeWidth = strokeWidth.isFinite
        ? strokeWidth
        : hyperOs4.progressInfiniteStrokeWidth;
    final effectiveDotSize = orbitingDotSize.isFinite
        ? orbitingDotSize
        : hyperOs4.progressOrbitingDotSize;
    return circular
        ? _MiuixCircularProgress(
            colors: colors ?? MiuixProgressIndicatorDefaults.colors(context),
            strokeWidth: effectiveStrokeWidth,
            size: effectiveSize,
            rotationDuration: _safeProgressDuration(
              _sourceMotion
                  ? const Duration(milliseconds: 1000)
                  : hyperOs4.progressCircularRotationMotion,
            ),
            sweepDuration: _safeProgressDuration(
              _sourceMotion
                  ? const Duration(milliseconds: 1600)
                  : hyperOs4.progressCircularSweepMotion,
            ),
          )
        : _MiuixOrbitProgress(
            color: color,
            size: effectiveSize,
            strokeWidth: effectiveStrokeWidth,
            orbitingDotSize: effectiveDotSize,
            duration: _safeProgressDuration(
              _sourceMotion
                  ? const Duration(milliseconds: 800)
                  : hyperOs4.progressOrbitMotion,
            ),
          );
  }
}
