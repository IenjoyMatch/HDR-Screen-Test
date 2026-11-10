import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../platform/miuix_haptics.dart';
import '../../theme/miuix_semantic_colors.dart';
import '../../theme/miuix_theme.dart';

double _safeCarouselViewportFraction(double value) =>
    value.isFinite && value > 0 && value <= 1
    ? value
    : MiuixCarouselDefaults.viewportFraction;

/// Programmatic page owner for [MiuixCarousel].
class MiuixCarouselController extends ChangeNotifier {
  /// Creates a controller and its underlying [PageController].
  MiuixCarouselController({
    int initialPage = 0,
    double viewportFraction = MiuixCarouselDefaults.viewportFraction,
  }) : _index = initialPage < 0 ? 0 : initialPage,
       pageController = PageController(
         initialPage: initialPage < 0 ? 0 : initialPage,
         viewportFraction: _safeCarouselViewportFraction(viewportFraction),
       );

  /// Page position used by the carousel.
  final PageController pageController;

  int _index;
  int _itemCount = 0;
  bool _loop = false;
  bool _reduceMotion = false;
  int? _requestedIndex;
  bool _programmaticMove = false;
  int _moveGeneration = 0;
  Duration _pageMotion = MiuixCarouselDefaults.pageAnimationDuration;

  /// Last settled page index.
  int get index => _index;

  /// Moves to an explicit page.
  ///
  /// While this controller is attached to a carousel whose inherited media
  /// settings disable animations, the move jumps to its endpoint instead.
  Future<void> animateTo(
    int index, {
    Duration duration = MiuixCarouselDefaults.pageAnimationDuration,
    Curve curve = Curves.easeOutCubic,
  }) async {
    final target = _normalizeIndex(index);
    _requestedIndex = target;
    final generation = ++_moveGeneration;
    final effectiveDuration =
        duration == MiuixCarouselDefaults.pageAnimationDuration
        ? _pageMotion
        : duration;
    if (_reduceMotion || effectiveDuration <= Duration.zero) {
      _programmaticMove = false;
      pageController.jumpToPage(target);
      return;
    }
    _programmaticMove = true;
    try {
      await pageController.animateToPage(
        target,
        duration: effectiveDuration,
        curve: curve,
      );
    } finally {
      if (generation == _moveGeneration) {
        _programmaticMove = false;
        _requestedIndex = target;
      }
    }
  }

  /// Moves one page toward the reading-direction end.
  Future<void> next({
    Duration duration = MiuixCarouselDefaults.pageAnimationDuration,
    Curve curve = Curves.easeOutCubic,
  }) => animateTo(_index + 1, duration: duration, curve: curve);

  /// Moves one page toward the reading-direction start.
  Future<void> previous({
    Duration duration = MiuixCarouselDefaults.pageAnimationDuration,
    Curve curve = Curves.easeOutCubic,
  }) => animateTo(_index - 1, duration: duration, curve: curve);

  void _publishIndex(int value) {
    if (!_programmaticMove) _requestedIndex = value;
    if (_index == value) return;
    _index = value;
    notifyListeners();
  }

  bool _configure({required int itemCount, required bool loop}) {
    final previousIndex = _index;
    _itemCount = itemCount;
    _loop = loop;
    _index = _normalizeIndex(_index);
    _requestedIndex = _normalizeIndex(_requestedIndex ?? _index);
    return _index != previousIndex;
  }

  /// Publishes an index changed by a collection reconfiguration.
  void _notifyConfigurationChanged() => notifyListeners();

  /// Updates the inherited motion policy without moving during widget build.
  void _setReduceMotion(bool value) => _reduceMotion = value;

  /// Updates future default page movement without changing explicit overrides.
  void _setPageMotion(Duration value) => _pageMotion = value;

  /// Lets direct manipulation replace a pending programmatic destination.
  void _beginDirectManipulation() {
    _moveGeneration++;
    _programmaticMove = false;
    if (!pageController.hasClients) return;
    _requestedIndex = _normalizeIndex(
      (pageController.page ?? _index.toDouble()).round(),
    );
  }

  /// Stops an active programmatic transition at its requested logical page.
  void _settleReducedMotion() {
    if (!_reduceMotion || !pageController.hasClients || _itemCount <= 0) {
      return;
    }
    final current = pageController.page ?? _index.toDouble();
    final target = _normalizeIndex(_requestedIndex ?? current.round());
    _moveGeneration++;
    _programmaticMove = false;
    _requestedIndex = target;
    pageController.jumpToPage(target);
  }

  int _normalizeIndex(int value) {
    if (_itemCount <= 0) return 0;
    if (_loop) return (value % _itemCount + _itemCount) % _itemCount;
    return value.clamp(0, _itemCount - 1);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}

/// Theme colors for carousel page indicators.
@immutable
class MiuixCarouselColors {
  /// Creates a carousel indicator palette.
  const MiuixCarouselColors({required this.active, required this.inactive});

  /// Active and inactive dot roles.
  final Color active;
  final Color inactive;
}

/// Motion, geometry, and palette defaults for carousels.
abstract final class MiuixCarouselDefaults {
  // HyperOS 4 carousel implementation contract:
  // - Direct page dragging remains owned by PageView and follows the pointer.
  // - Programmatic page movement uses the shared carousel-page motion token.
  // - Reduced motion converts autonomous page movement to an endpoint jump.
  // - Enabling reduced motion settles an already-running programmatic request.
  // - Autoplay pauses completely while reduced motion is enabled.
  // - Pointer contact pauses autoplay without discarding the settled page.
  // - Looping normalizes controller requests across both collection edges.
  // - Non-looping requests clamp to the nearest authored child index.
  // - One page-change haptic is emitted only after PageView settles a new page.
  // - The controller publishes the same logical index that callers can observe.
  // - Caller-owned controllers are listened to but never disposed by the widget.
  // - Internally created controllers are disposed with the carousel state.
  // - Replacing a controller disconnects the previous listener synchronously.
  // - Empty child lists build no viewport, timer, or page-indicator geometry.
  // - A one-page carousel omits the indicator even when showIndicator is true.
  // - Local page indicators share the standalone indicator token family.
  // - Inactive-dot diameter reads pageIndicatorDotSize by default.
  // - Active-capsule width reads pageIndicatorActiveWidth by default.
  // - Per-item horizontal margin reads pageIndicatorSpacing by default.
  // - Page-to-indicator distance reads carouselIndicatorGap by default.
  // - Each finite widget override replaces only its corresponding metric.
  // - Invalid negative and NaN overrides fall back to a valid theme token.
  // - Invalid theme metrics fall back to the retained source measurement.
  // - Indicator height always equals the resolved inactive-dot diameter.
  // - Selected width changes without moving the indicator row's vertical axis.
  // - Animated width changes use the page-indicator motion token.
  // - A policy-key change removes any in-flight width sample under reduced motion.
  // - Indicator color roles remain independent from geometry and motion tokens.
  // - Source construction fixes former 6dp inactive-dot geometry.
  // - Source construction fixes former 18dp active-capsule geometry.
  // - Source construction fixes former 3dp margin on each item side.
  // - Source construction fixes the former 10dp vertical indicator gap.
  // - Source geometry remains independent from customized application tokens.
  // - The standard constructor is the HyperOS 4 token-consuming endpoint.
  // - Standalone MiuixPageIndicator retains its own explicit `.source` values.
  // - Carousel and standalone source active widths intentionally differ.
  // - That 18dp versus 16dp distinction records their actual former defaults.
  // - Page scaling affects child paint only and never changes viewport geometry.
  // - Neighbor scaling preserves the child center and hit-test relationship.
  // - Viewport fraction remains an explicit public layout decision.
  // - Carousel height remains an explicit public parent-layout decision.
  // - Text direction is delegated to PageView for reading-order navigation.
  // - Overscroll bookkeeping exists only to support explicit looping behavior.
  // - Edge overscroll is cleared after pointer release or cancellation.
  // - A canceled pointer cannot keep autoplay permanently paused.
  // - Timer callbacks verify mount, pointer state, and attached clients.
  // - Widget updates reschedule autoplay when timing or item count changes.
  // - Geometry keys let tests verify gap and row bounds without pixel guessing.
  // - Focused tests cover theme tokens, local overrides, source, and reduced motion.
  // - Documentation must not claim token support until those tests exercise it.
  // - All numeric defaults are project calibration values, not private Xiaomi dp.

  /// Fraction of viewport occupied by one page.
  static const double viewportFraction = .88;

  /// Scale of neighboring pages.
  static const double minimumPageScale = .94;

  /// Standard page animation duration.
  static const Duration pageAnimationDuration = Duration(milliseconds: 420);

  /// Standard autoplay delay.
  static const Duration autoPlayInterval = Duration(seconds: 4);

  /// Former fixed local-indicator geometry retained by `.source`.
  static const double sourceIndicatorDotSize = 6;
  static const double sourceIndicatorActiveWidth = 18;
  static const double sourceIndicatorSpacing = 3;
  static const double sourceIndicatorGap = 10;

  /// Resolves indicator colors from MIUIX semantics.
  static MiuixCarouselColors colors(BuildContext context) {
    final semantic = MiuixSemanticColors.of(context);
    return MiuixCarouselColors(
      active: semantic['primary'],
      inactive: semantic['onSurfaceContainerVariant'],
    );
  }
}

/// Swipeable, scalable MIUIX carousel for Android and Windows.
///
/// Reduced motion pauses autoplay, snaps programmatic and released movement,
/// and removes indicator interpolation while preserving direct pointer drag.
class MiuixCarousel extends StatefulWidget {
  /// Creates a carousel from explicit page widgets.
  const MiuixCarousel({
    super.key,
    required this.children,
    this.controller,
    this.initialPage = 0,
    this.viewportFraction = MiuixCarouselDefaults.viewportFraction,
    this.height = 220,
    this.loop = false,
    this.autoPlay = false,
    this.autoPlayInterval = MiuixCarouselDefaults.autoPlayInterval,
    this.showIndicator = true,
    this.indicatorDotSize = double.nan,
    this.indicatorActiveWidth = double.nan,
    this.indicatorSpacing = double.nan,
    this.indicatorGap = double.nan,
    this.colors,
    this.onPageChanged,
  });

  /// Creates a carousel with the former fixed 6/18/3/10dp indicator geometry.
  const MiuixCarousel.source({
    super.key,
    required this.children,
    this.controller,
    this.initialPage = 0,
    this.viewportFraction = MiuixCarouselDefaults.viewportFraction,
    this.height = 220,
    this.loop = false,
    this.autoPlay = false,
    this.autoPlayInterval = MiuixCarouselDefaults.autoPlayInterval,
    this.showIndicator = true,
    this.colors,
    this.onPageChanged,
  }) : indicatorDotSize = MiuixCarouselDefaults.sourceIndicatorDotSize,
       indicatorActiveWidth = MiuixCarouselDefaults.sourceIndicatorActiveWidth,
       indicatorSpacing = MiuixCarouselDefaults.sourceIndicatorSpacing,
       indicatorGap = MiuixCarouselDefaults.sourceIndicatorGap;

  /// Carousel pages.
  final List<Widget> children;

  /// Optional externally owned controller.
  final MiuixCarouselController? controller;

  /// Initial page and viewport geometry for the internal controller.
  final int initialPage;
  final double viewportFraction;
  final double height;

  /// Whether navigation wraps at either end.
  final bool loop;

  /// Whether automatic paging is enabled.
  final bool autoPlay;
  final Duration autoPlayInterval;

  /// Whether page dots are shown below content.
  final bool showIndicator;

  /// Optional geometry of the local page indicator.
  ///
  /// NaN resolves through the corresponding HyperOS 4 theme token. Finite
  /// values override one carousel without changing standalone indicators.
  final double indicatorDotSize;
  final double indicatorActiveWidth;
  final double indicatorSpacing;
  final double indicatorGap;

  /// Optional indicator palette.
  final MiuixCarouselColors? colors;

  /// Called after a page settles.
  final ValueChanged<int>? onPageChanged;

  @override
  State<MiuixCarousel> createState() => _MiuixCarouselState();
}

class _MiuixCarouselState extends State<MiuixCarousel> {
  // Dynamic collection and controller contract:
  // - Widget children are the current authoritative page universe.
  // - Controller index is normalized after every page-count change.
  // - Empty collections normalize the public logical index to zero.
  // - Shrink keeps the nearest surviving non-looping page selected.
  // - Loop configuration uses modular normalization in both directions.
  // - Logical normalization is mirrored into the rendered PageController.
  // - Page synchronization occurs after the new viewport attaches.
  // - Every scheduled synchronization carries a local generation token.
  // - A later widget update invalidates an older pending synchronization.
  // - A controller replacement invalidates work owned by the old controller.
  // - State disposal invalidates every remaining post-frame synchronization.
  // - Collection-forced index changes notify external controller listeners.
  // - Collection-forced index changes publish onPageChanged exactly once.
  // - Collection-forced jumps do not emit a direct-manipulation haptic.
  // - Ordinary settled user pages continue to emit the page haptic.
  // - Rebuilding an internal viewport preserves the current legal index.
  // - A changed internal viewportFraction creates a matching PageController.
  // - External controller viewport geometry remains caller-authored.
  // - Controller replacement detaches the former listener synchronously.
  // - Internal controller replacement disposes its former PageController.
  // - Page synchronization never calls a detached PageController.
  // - A missing PageView client postpones physical work without throwing.
  // - Empty children remove PageView while still publishing logical reset.
  // - Re-adding pages uses the controller's current normalized page.
  // - Zero or negative autoplay periods create no periodic timer.
  // - Autoplay is canceled before any new interval is considered.
  // - Autoplay reads current loop and page-count state on every tick.
  // - Pointer contact keeps an active timer from advancing the page.
  // - Pointer release clears accumulated edge overscroll in every branch.
  // - Reduced motion prevents autonomous timer creation entirely.
  // - Runtime reduced motion settles only the latest programmatic request.
  // - Theme motion changes affect later default programmatic transitions.
  // - Explicit caller durations remain authoritative over theme defaults.
  // - Indicator index clamps defensively even during collection transition.
  // - Stable indicator geometry never depends on a removed page widget.
  // - Public viewport fractions are normalized before PageController construction.
  // - Finite fractions in the open-zero through one interval remain exact.
  // - Zero, negative, non-finite, and above-one values use the calibrated default.
  // - This boundary is identical for direct controllers and internal controllers.
  // - Negative initial pages resolve to logical and physical page zero.
  // - Oversized initial pages retain their request until item count becomes known.
  // - Configuration then clamps them and synchronizes the attached physical viewport.
  // - Initial synchronization runs after PageView obtains its first client.
  // - It publishes no page-change callback for merely correcting invalid input.
  // - Reconfiguration-driven later corrections retain their documented publication.
  // - Invalid or non-positive carousel heights resolve to the 220dp usable default.
  // - SizedBox therefore never receives NaN, infinity, zero, or negative height.
  // - Active indicator width is never smaller than the inactive-dot diameter.
  // - A caller may still make active and inactive indicators deliberately equal.
  // - Indicator spacing and gap continue to accept an explicit visual zero.
  // - Negative or non-finite indicator metrics fall through theme then source fallback.
  // - A non-positive page-indicator motion token settles at the current endpoint.
  // - Such a token never reaches an implicit AnimationController as negative duration.
  // - Reduced-motion policy shares the same zero-duration indicator endpoint.
  // - External controllers keep their already-constructed viewport geometry authoritative.
  // - Widget viewport updates rebuild only an internally owned PageController.
  // - Equivalent invalid fractions normalize equally and do not churn that controller.
  // - Controller reconstruction retains the nearest current logical page.
  // - Its previous listener is removed before its PageController is disposed.
  // - Pending initial and update synchronizations are generation-guarded independently.
  // - This prevents a corrected old viewport from jumping a replacement controller.
  // - Geometry normalization affects layout only, never loop or autoplay semantics.
  // - The same rules apply to standard and source-style carousel constructors.
  // These rules keep async route frames and public state in one page domain.

  late MiuixCarouselController _controller;
  late bool _ownsController;
  Timer? _autoPlayTimer;
  bool _pointerDown = false;
  bool _reduceMotion = false;
  double _edgeOverscroll = 0;
  int _motionPreferenceGeneration = 0;
  int _configurationGeneration = 0;
  int? _configurationJumpTarget;

  @override
  void initState() {
    super.initState();
    _attachController();
    _synchronizeConfiguredPage(publishIndexChange: false);
    _scheduleAutoPlay();
  }

  void _attachController({int? internalInitialPage}) {
    _ownsController = widget.controller == null;
    _controller =
        widget.controller ??
        MiuixCarouselController(
          initialPage: internalInitialPage ?? widget.initialPage,
          viewportFraction: _safeCarouselViewportFraction(
            widget.viewportFraction,
          ),
        );
    _controller.addListener(_rebuild);
    _controller._configure(
      itemCount: widget.children.length,
      loop: widget.loop,
    );
    _controller._setReduceMotion(_reduceMotion);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller._setPageMotion(
      MiuixTheme.of(context).hyperOs4.carouselPageMotion,
    );
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion == _reduceMotion) return;
    _reduceMotion = reduceMotion;
    _controller._setReduceMotion(reduceMotion);
    _scheduleAutoPlay();
    final generation = ++_motionPreferenceGeneration;
    if (!reduceMotion) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          !_reduceMotion ||
          generation != _motionPreferenceGeneration) {
        return;
      }
      _controller._settleReducedMotion();
    });
  }

  @override
  void didUpdateWidget(MiuixCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _controller.removeListener(_rebuild);
      if (_ownsController) _controller.dispose();
      _attachController();
    } else if (_ownsController &&
        _safeCarouselViewportFraction(oldWidget.viewportFraction) !=
            _safeCarouselViewportFraction(widget.viewportFraction)) {
      final retainedIndex = _controller.index;
      _controller.removeListener(_rebuild);
      _controller.dispose();
      _attachController(internalInitialPage: retainedIndex);
    }
    if (oldWidget.autoPlay != widget.autoPlay ||
        oldWidget.autoPlayInterval != widget.autoPlayInterval ||
        oldWidget.children.length != widget.children.length) {
      _scheduleAutoPlay();
    }
    final indexChanged = _controller._configure(
      itemCount: widget.children.length,
      loop: widget.loop,
    );
    _synchronizeConfiguredPage(publishIndexChange: indexChanged);
  }

  void _synchronizeConfiguredPage({required bool publishIndexChange}) {
    _configurationJumpTarget = null;
    final generation = ++_configurationGeneration;
    final configuredController = _controller;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          generation != _configurationGeneration ||
          !identical(_controller, configuredController)) {
        return;
      }
      if (publishIndexChange) {
        configuredController._notifyConfigurationChanged();
      }
      if (widget.children.isEmpty ||
          !configuredController.pageController.hasClients) {
        if (publishIndexChange) {
          widget.onPageChanged?.call(configuredController.index);
        }
        return;
      }
      final renderedPage = configuredController.pageController.page;
      if (renderedPage == null ||
          (renderedPage - configuredController.index).abs() < .001) {
        if (publishIndexChange) {
          widget.onPageChanged?.call(configuredController.index);
        }
        return;
      }
      if (publishIndexChange) {
        _configurationJumpTarget = configuredController.index;
      }
      configuredController.pageController.jumpToPage(
        configuredController.index,
      );
    });
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  void _scheduleAutoPlay() {
    _autoPlayTimer?.cancel();
    if (_reduceMotion ||
        !widget.autoPlay ||
        widget.children.length < 2 ||
        widget.autoPlayInterval <= Duration.zero) {
      return;
    }
    _autoPlayTimer = Timer.periodic(widget.autoPlayInterval, (_) {
      if (!mounted || _pointerDown || !_controller.pageController.hasClients) {
        return;
      }
      final last = widget.children.length - 1;
      if (_controller.index >= last) {
        if (widget.loop) {
          _controller.animateTo(0);
        }
      } else {
        _controller.animateTo(_controller.index + 1);
      }
    });
  }

  void _handlePageChanged(int index) {
    final configurationJump = _configurationJumpTarget == index;
    _configurationJumpTarget = null;
    _controller._publishIndex(index);
    if (!configurationJump) {
      MiuixHaptics.perform(MiuixHapticType.textHandleMove);
    }
    widget.onPageChanged?.call(index);
  }

  void _handlePointerUp() {
    _pointerDown = false;
    if (_reduceMotion && _controller.pageController.hasClients) {
      final overscroll = _edgeOverscroll;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_reduceMotion) return;
        final current =
            _controller.pageController.page ?? _controller.index.toDouble();
        final target = widget.loop && overscroll < -20
            ? widget.children.length - 1
            : widget.loop && overscroll > 20
            ? 0
            : current.round();
        unawaited(_controller.animateTo(target));
      });
      _edgeOverscroll = 0;
      return;
    }
    if (widget.loop && widget.children.isNotEmpty) {
      if (_edgeOverscroll < -20) {
        _controller.animateTo(widget.children.length - 1);
      } else if (_edgeOverscroll > 20) {
        _controller.animateTo(0);
      }
    }
    _edgeOverscroll = 0;
  }

  @override
  void dispose() {
    _motionPreferenceGeneration++;
    _configurationGeneration++;
    _configurationJumpTarget = null;
    _autoPlayTimer?.cancel();
    _controller.removeListener(_rebuild);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.colors ?? MiuixCarouselDefaults.colors(context);
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    if (widget.children.isEmpty) return const SizedBox.shrink();
    final currentIndex = _controller.index.clamp(0, widget.children.length - 1);
    // Indicator geometry is independent from page motion. Each optional value
    // resolves to a shared page-indicator token, while `.source` supplies finite
    // former constants through the same path. Invalid public overrides cannot
    // introduce negative constraints or NaN paint geometry.
    double indicatorMetric(double value, double token, double fallback) {
      if (value.isFinite && value >= 0) return value;
      if (token.isFinite && token >= 0) return token;
      return fallback;
    }

    final indicatorDotSize = indicatorMetric(
      widget.indicatorDotSize,
      hyperOs4.pageIndicatorDotSize,
      MiuixCarouselDefaults.sourceIndicatorDotSize,
    );
    final indicatorActiveWidth = math.max(
      indicatorDotSize,
      indicatorMetric(
        widget.indicatorActiveWidth,
        hyperOs4.pageIndicatorActiveWidth,
        MiuixCarouselDefaults.sourceIndicatorActiveWidth,
      ),
    );
    final indicatorSpacing = indicatorMetric(
      widget.indicatorSpacing,
      hyperOs4.pageIndicatorSpacing,
      MiuixCarouselDefaults.sourceIndicatorSpacing,
    );
    final indicatorGap = indicatorMetric(
      widget.indicatorGap,
      hyperOs4.carouselIndicatorGap,
      MiuixCarouselDefaults.sourceIndicatorGap,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        NotificationListener<OverscrollNotification>(
          onNotification: (notification) {
            if (widget.loop) _edgeOverscroll += notification.overscroll;
            return false;
          },
          child: Listener(
            onPointerDown: (_) {
              _pointerDown = true;
              _edgeOverscroll = 0;
              _controller._beginDirectManipulation();
            },
            onPointerUp: (_) => _handlePointerUp(),
            onPointerCancel: (_) => _handlePointerUp(),
            child: SizedBox(
              height: widget.height.isFinite && widget.height > 0
                  ? widget.height
                  : 220,
              child: PageView.builder(
                controller: _controller.pageController,
                itemCount: widget.children.length,
                allowImplicitScrolling: true,
                onPageChanged: _handlePageChanged,
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: _controller.pageController,
                    child: widget.children[index],
                    builder: (context, child) {
                      var distance = (index - currentIndex).abs().toDouble();
                      if (_controller.pageController.hasClients &&
                          _controller
                              .pageController
                              .position
                              .hasContentDimensions) {
                        distance =
                            ((_controller.pageController.page ??
                                        currentIndex.toDouble()) -
                                    index)
                                .abs();
                      }
                      final scale =
                          (1 -
                                  distance.clamp(0.0, 1.0) *
                                      (1 -
                                          MiuixCarouselDefaults
                                              .minimumPageScale))
                              .clamp(
                                MiuixCarouselDefaults.minimumPageScale,
                                1.0,
                              );
                      return Transform.scale(scale: scale, child: child);
                    },
                  );
                },
              ),
            ),
          ),
        ),
        if (widget.showIndicator && widget.children.length > 1) ...<Widget>[
          SizedBox(
            key: const ValueKey('miuix-carousel-indicator-gap'),
            height: indicatorGap,
          ),
          Row(
            key: const ValueKey('miuix-carousel-indicator-row'),
            mainAxisSize: MainAxisSize.min,
            children: List<Widget>.generate(widget.children.length, (index) {
              final selected = index == currentIndex;
              return AnimatedContainer(
                // Policy identity prevents an in-flight width sample from
                // surviving after the system asks for reduced motion.
                key: ValueKey<(int, bool)>((index, _reduceMotion)),
                duration:
                    _reduceMotion ||
                        hyperOs4.pageIndicatorMotion <= Duration.zero
                    ? Duration.zero
                    : hyperOs4.pageIndicatorMotion,
                curve: Curves.easeOutCubic,
                width: selected ? indicatorActiveWidth : indicatorDotSize,
                height: indicatorDotSize,
                margin: EdgeInsets.symmetric(horizontal: indicatorSpacing),
                decoration: BoxDecoration(
                  color: selected ? palette.active : palette.inactive,
                  borderRadius: BorderRadius.circular(999),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
