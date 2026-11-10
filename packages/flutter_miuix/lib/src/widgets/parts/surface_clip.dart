part of '../miuix_widgets.dart';

/// Clips surface paint and pointer input without truncating child semantics.
///
/// Compose's `squircleSurface` clips the rendered subtree, yet an interactive
/// descendant that intersects the surface can retain its complete Android
/// accessibility rectangle outside that silhouette. Flutter's stock
/// [ClipPath] also clips semantic geometry, which incorrectly shortened the
/// partially visible last TabRow item at a Card edge.
class _MiuixSurfaceClip extends SingleChildRenderObjectWidget {
  const _MiuixSurfaceClip({required this.clipper, required super.child});

  final CustomClipper<Path> clipper;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderMiuixSurfaceClip(
      clipper: clipper,
      clipBehavior: Clip.antiAlias,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderMiuixSurfaceClip renderObject,
  ) {
    renderObject
      ..clipper = clipper
      ..clipBehavior = Clip.antiAlias;
  }
}

class _RenderMiuixSurfaceClip extends RenderClipPath {
  _RenderMiuixSurfaceClip({
    required super.clipper,
    required super.clipBehavior,
  });

  // RenderClipPath still performs the real canvas and pointer clip. Returning
  // null only from geometry reporting prevents Flutter's semantics builder
  // from intersecting a partially visible descendant node with the Card rect.
  @override
  Rect? describeApproximatePaintClip(RenderObject child) => null;
}
