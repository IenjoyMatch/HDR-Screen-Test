part of '../miuix_widgets.dart';

// Compose's selectable modifier inherits the platform minimum interactive
// component size. TabRow intentionally keeps its 42dp or 35dp painted item,
// while Android exposes a separately centered 48dp pointer and semantic node.
const double _miuixTabMinimumInteractiveSize = 48;

/// Keeps a tab's visual measurement separate from its Android interaction box.
///
/// Pointers inside the painted item continue through [MiuixPressable]. Only
/// the narrow vertical band outside that item is claimed by this proxy, which
/// avoids two recognizers competing for the same gesture. Semantics are drawn
/// in a viewport-independent sibling layer below because Flutter viewports
/// otherwise clip descendant semantic rectangles to their visual height.
class _MiuixTabTouchTarget extends SingleChildRenderObjectWidget {
  const _MiuixTabTouchTarget({
    required this.selected,
    required this.minimumSize,
    required this.onTap,
    required this.interactionSource,
    required super.child,
  });

  final bool selected;
  final double minimumSize;
  final VoidCallback onTap;
  final MiuixInteractionSource? interactionSource;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderMiuixTabTouchTarget(
      selected: selected,
      minimumSize: minimumSize,
      onTap: onTap,
      interactionSource: interactionSource,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderMiuixTabTouchTarget renderObject,
  ) {
    renderObject
      ..selected = selected
      ..minimumSize = minimumSize
      ..onTap = onTap
      ..interactionSource = interactionSource;
  }
}

/// Render bridge for the out-of-layout portion of a MIUIX tab target.
class _RenderMiuixTabTouchTarget extends RenderProxyBox {
  _RenderMiuixTabTouchTarget({
    required bool selected,
    required double minimumSize,
    required VoidCallback onTap,
    required MiuixInteractionSource? interactionSource,
  }) : _selected = selected,
       _minimumSize = minimumSize,
       _onTap = onTap,
       _interactionSource = interactionSource {
    _tapRecognizer = TapGestureRecognizer(debugOwner: this);
    _syncRecognizer();
  }

  late final TapGestureRecognizer _tapRecognizer;
  bool _selected;
  double _minimumSize;
  VoidCallback _onTap;
  MiuixInteractionSource? _interactionSource;

  bool get selected => _selected;
  set selected(bool value) {
    if (_selected == value) return;
    _selected = value;
  }

  double get minimumSize => _minimumSize;
  set minimumSize(double value) {
    if (_minimumSize == value) return;
    _minimumSize = value;
  }

  VoidCallback get onTap => _onTap;
  set onTap(VoidCallback value) {
    if (_onTap == value) return;
    _onTap = value;
    _syncRecognizer();
  }

  MiuixInteractionSource? get interactionSource => _interactionSource;
  set interactionSource(MiuixInteractionSource? value) {
    if (identical(_interactionSource, value)) return;
    _interactionSource?.setPressed(false);
    _interactionSource = value;
    _syncRecognizer();
  }

  Rect get _interactiveBounds => Rect.fromCenter(
    center: size.center(Offset.zero),
    width: math.max(size.width, minimumSize),
    height: math.max(size.height, minimumSize),
  );

  void _syncRecognizer() {
    _tapRecognizer
      ..onTap = _onTap
      ..onTapDown = (_) {
        _interactionSource?.setPressed(true);
      }
      ..onTapUp = (_) {
        _interactionSource?.setPressed(false);
      }
      ..onTapCancel = () {
        _interactionSource?.setPressed(false);
      };
  }

  void _handleGlobalPointer(PointerEvent event) {
    if (event is! PointerDownEvent || !attached || size.isEmpty) {
      return;
    }
    final localPosition = globalToLocal(event.position);
    if (!size.contains(localPosition) &&
        _interactiveBounds.contains(localPosition)) {
      _tapRecognizer.addPointer(event);
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (size.contains(position)) {
      return hitTestChildren(result, position: position);
    }
    // The global route owns only the expanded band because ordinary ancestor
    // render boxes do not ask children to hit-test outside measured bounds.
    return false;
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    GestureBinding.instance.pointerRouter.addGlobalRoute(_handleGlobalPointer);
  }

  @override
  void detach() {
    GestureBinding.instance.pointerRouter.removeGlobalRoute(
      _handleGlobalPointer,
    );
    _interactionSource?.setPressed(false);
    super.detach();
  }

  @override
  void dispose() {
    _tapRecognizer.dispose();
    super.dispose();
  }
}

/// Semantics-only sibling that is not clipped by the horizontal viewport.
class _MiuixTabSemanticsTarget extends LeafRenderObjectWidget {
  const _MiuixTabSemanticsTarget({
    super.key,
    required this.label,
    required this.selected,
    required this.textDirection,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final TextDirection textDirection;
  final VoidCallback onTap;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderMiuixTabSemanticsTarget(
      label: label,
      selected: selected,
      textDirection: textDirection,
      onTap: onTap,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderMiuixTabSemanticsTarget renderObject,
  ) {
    renderObject
      ..label = label
      ..selected = selected
      ..textDirection = textDirection
      ..onTap = onTap;
  }
}

class _RenderMiuixTabSemanticsTarget extends RenderBox {
  _RenderMiuixTabSemanticsTarget({
    required String label,
    required bool selected,
    required TextDirection textDirection,
    required VoidCallback onTap,
  }) : _label = label,
       _selected = selected,
       _textDirection = textDirection,
       _onTap = onTap;

  String _label;
  bool _selected;
  TextDirection _textDirection;
  VoidCallback _onTap;

  String get label => _label;
  set label(String value) {
    if (_label == value) return;
    _label = value;
    markNeedsSemanticsUpdate();
  }

  bool get selected => _selected;
  set selected(bool value) {
    if (_selected == value) return;
    _selected = value;
    markNeedsSemanticsUpdate();
  }

  TextDirection get textDirection => _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsSemanticsUpdate();
  }

  VoidCallback get onTap => _onTap;
  set onTap(VoidCallback value) {
    if (_onTap == value) return;
    _onTap = value;
    markNeedsSemanticsUpdate();
  }

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      constraints.constrain(Size.zero);

  @override
  void performResize() {
    size = computeDryLayout(constraints);
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) => false;

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config
      ..isSemanticBoundary = true
      ..role = SemanticsRole.tab
      ..label = label
      ..textDirection = textDirection
      ..isEnabled = true
      ..isSelected = selected
      ..onTap = _onTap;
  }
}
