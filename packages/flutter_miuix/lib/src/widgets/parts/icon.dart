part of '../miuix_widgets.dart';

/// Backing artwork accepted by [MiuixIcon].
///
/// MIUIX exposes overloads for vectors, bitmaps, and painters. Dart has no
/// function overloading, so the public constructors store the matching Flutter
/// artwork here and share one source-compatible rendering pipeline.
enum _MiuixIconArtworkType {
  /// A font-backed vector icon.
  iconData,

  /// A bitmap or other Flutter image provider.
  image,

  /// Commands painted directly into a canvas.
  painter,
}

/// Private Flutter counterpart of the source `LocalContentColor`.
///
/// Keeping this scope separate from the app-wide Material IconTheme prevents a
/// MIUIX surface from recoloring unrelated Material widgets elsewhere.
class _MiuixContentColor extends InheritedWidget {
  /// Publishes one content color to MIUIX drawing primitives below it.
  const _MiuixContentColor({required this.color, required super.child});

  /// Active source content color.
  final Color color;

  /// Reads the nearest explicit MIUIX content-color provider.
  static Color? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_MiuixContentColor>()
        ?.color;
  }

  @override
  bool updateShouldNotify(_MiuixContentColor oldWidget) {
    return oldWidget.color != color;
  }
}

/// MIUIX icon that supports vector, bitmap, and painter artwork.
///
/// The unnamed constructor remains compatible with earlier `flutter_miuix`
/// releases. [MiuixIcon.image] corresponds to the source `ImageBitmap`
/// overload, while [MiuixIcon.painter] corresponds to its `Painter` overload.
/// Icons inherit the nearest [IconTheme] color just as upstream icons inherit
/// `LocalContentColor`; [applyTint] can disable that tint completely.
class MiuixIcon extends StatelessWidget {
  /// Creates a font-backed vector icon.
  ///
  /// [tint] is the source-compatible name. [color] remains as a compatibility
  /// alias; callers must not supply both. When neither is set the nearest
  /// [IconTheme] color is used, falling back to the theme's on-surface color.
  const MiuixIcon(
    IconData icon, {
    super.key,
    this.size,
    this.color,
    this.tint,
    this.tintListenable,
    this.applyTint = true,
    this.semanticLabel,
    this.contentDescription,
  }) : _type = _MiuixIconArtworkType.iconData,
       _icon = icon,
       _image = null,
       _painter = null,
       intrinsicSize = null,
       fit = BoxFit.contain;

  /// Creates an icon from bitmap or image-provider artwork.
  ///
  /// Unlike a vector without intrinsic dimensions, a bitmap keeps its natural
  /// size when [size] is omitted. [fit] mirrors Compose `ContentScale.Fit`.
  const MiuixIcon.image(
    ImageProvider image, {
    super.key,
    this.size,
    this.color,
    this.tint,
    this.tintListenable,
    this.applyTint = true,
    this.semanticLabel,
    this.contentDescription,
    this.fit = BoxFit.contain,
  }) : _type = _MiuixIconArtworkType.image,
       _icon = null,
       _image = image,
       _painter = null,
       intrinsicSize = null;

  /// Creates an icon from canvas painter artwork.
  ///
  /// Flutter painters do not report an intrinsic size. The source therefore
  /// assigns its 24dp fallback unless [intrinsicSize] is explicitly supplied.
  const MiuixIcon.painter(
    CustomPainter painter, {
    super.key,
    this.size,
    this.intrinsicSize,
    this.color,
    this.tint,
    this.tintListenable,
    this.applyTint = true,
    this.semanticLabel,
    this.contentDescription,
    this.fit = BoxFit.contain,
  }) : _type = _MiuixIconArtworkType.painter,
       _icon = null,
       _image = null,
       _painter = painter;

  /// The source default for artwork without finite intrinsic dimensions.
  static const double defaultSize = 24;

  /// Optional square side requested by the caller.
  final double? size;

  /// Compatibility alias for [tint].
  final Color? color;

  /// Static source tint.
  final Color? tint;

  /// A reactive counterpart of the source `ColorProducer` overload.
  ///
  /// A null value disables tint for the current frame. When this producer is
  /// present it takes precedence over [tint], [color], and inherited color.
  final ValueListenable<Color?>? tintListenable;

  /// Whether static or inherited tint is applied.
  ///
  /// Set this to false for the source `Color.Unspecified` behavior. A
  /// [tintListenable] still takes precedence and can independently emit null.
  final bool applyTint;

  /// Compatibility name for the localized accessibility description.
  final String? semanticLabel;

  /// Source-compatible localized accessibility description.
  final String? contentDescription;

  /// Natural canvas extent for painter artwork.
  final Size? intrinsicSize;

  /// Scaling mode used inside the resolved icon extent.
  final BoxFit fit;

  /// Kind of artwork selected by the public constructor.
  final _MiuixIconArtworkType _type;

  /// Font icon used by the unnamed constructor.
  final IconData? _icon;

  /// Image provider used by [MiuixIcon.image].
  final ImageProvider? _image;

  /// Canvas painter used by [MiuixIcon.painter].
  final CustomPainter? _painter;

  /// Resolves invalid runtime dimensions to the source fallback.
  ///
  /// A nullable result is retained for bitmap artwork because omitting an
  /// explicit size intentionally asks Flutter to preserve image dimensions.
  double? get _safeSize {
    final requested = size;
    if (requested == null) return null;
    return requested.isFinite && requested >= 0 ? requested : defaultSize;
  }

  /// Rejects painter extents which would poison CustomPaint constraints.
  Size get _safeIntrinsicSize {
    final requested = intrinsicSize;
    if (requested == null ||
        !requested.width.isFinite ||
        !requested.height.isFinite ||
        requested.width < 0 ||
        requested.height < 0) {
      return const Size.square(defaultSize);
    }
    return requested;
  }

  /// Resolves the static equivalent of upstream `LocalContentColor`.
  Color _staticTint(BuildContext context) {
    final explicit = tint ?? color;
    if (explicit != null) return explicit;
    final scoped = _MiuixContentColor.maybeOf(context);
    if (scoped != null) return scoped;

    // IconTheme is the natural Flutter adapter for a caller-provided content
    // color. Material 3 also synthesizes a root IconTheme using a different
    // semantic role, though, so only treat a changed nested value as explicit.
    final theme = Theme.of(context);
    final inherited = IconTheme.of(context).color;
    if (inherited != null && inherited != theme.iconTheme.color) {
      return inherited;
    }
    return theme.colorScheme.onSurface;
  }

  /// Paints the selected artwork with the resolved optional tint.
  Widget _buildArtwork(Color? resolvedTint) {
    final resolvedSize = _safeSize;
    switch (_type) {
      case _MiuixIconArtworkType.iconData:
        return MiuixThemedIcon(
          _icon,
          size: resolvedSize ?? defaultSize,
          color: resolvedTint,
          // Semantics are applied once around every artwork type below.
          semanticLabel: null,
        );
      case _MiuixIconArtworkType.image:
        return Image(
          image: _image!,
          width: resolvedSize,
          height: resolvedSize,
          fit: fit,
          color: resolvedTint,
          colorBlendMode: resolvedTint == null ? null : BlendMode.srcIn,
          excludeFromSemantics: true,
        );
      case _MiuixIconArtworkType.painter:
        final naturalSize = resolvedSize == null
            ? _safeIntrinsicSize
            : Size.square(resolvedSize);
        Widget painted = CustomPaint(size: naturalSize, painter: _painter);
        if (resolvedTint != null) {
          painted = ColorFiltered(
            colorFilter: ColorFilter.mode(resolvedTint, BlendMode.srcIn),
            child: painted,
          );
        }
        return painted;
    }
  }

  /// Applies the source image role only when a description is supplied.
  Widget _withSemantics(Widget child) {
    final description = contentDescription ?? semanticLabel;
    if (description == null) return child;
    return Semantics(
      label: description,
      image: true,
      excludeSemantics: true,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final producer = tintListenable;
    if (producer != null) {
      return ValueListenableBuilder<Color?>(
        valueListenable: producer,
        builder: (context, producedTint, _) {
          return _withSemantics(_buildArtwork(producedTint));
        },
      );
    }
    final resolvedTint = applyTint ? _staticTint(context) : null;
    return _withSemantics(_buildArtwork(resolvedTint));
  }
}
