part of '../miuix_widgets.dart';

/// Grid palette for choosing from a finite set of theme colors.
class MiuixColorPalette extends StatelessWidget {
  /// Creates a color palette.
  const MiuixColorPalette({
    super.key,
    required this.colors,
    required this.selected,
    required this.onSelected,
    this.columns = 6,
  }) : rows = 7,
       hueColumns = 12,
       includeGrayColumn = true,
       showPreview = true,
       cornerRadius = 16,
       indicatorRadius = 10,
       _hsvMode = false;

  /// Creates a source-style HSV palette.
  const MiuixColorPalette.hsv({
    super.key,
    required Color color,
    required ValueChanged<Color> onColorChanged,
    this.rows = 7,
    this.hueColumns = 12,
    this.includeGrayColumn = true,
    this.showPreview = true,
    this.cornerRadius = 16,
    this.indicatorRadius = 10,
  }) : colors = const [],
       selected = color,
       onSelected = onColorChanged,
       columns = 6,
       _hsvMode = true;

  /// Creates a palette with the parameter names used by `ColorPalette.kt`.
  const MiuixColorPalette.source({
    super.key,
    required Color color,
    required ValueChanged<Color> onColorChanged,
    this.rows = 7,
    this.hueColumns = 12,
    this.includeGrayColumn = true,
    this.showPreview = true,
    this.cornerRadius = 16,
    this.indicatorRadius = 10,
  }) : colors = const [],
       selected = color,
       onSelected = onColorChanged,
       columns = 6,
       _hsvMode = true;

  /// Available colors.
  final List<Color> colors;

  /// Currently selected color.
  final Color selected;

  /// Selection callback.
  final ValueChanged<Color> onSelected;

  /// Number of color swatches per row.
  final int columns;

  /// Source-style HSV palette row count.
  final int rows;

  /// Source-style HSV hue column count.
  final int hueColumns;

  /// Whether the source-style palette includes the gray column.
  final bool includeGrayColumn;

  /// Whether the source-style palette displays the selected color preview.
  final bool showPreview;

  /// Corner radius of the source-style palette grid.
  final double cornerRadius;

  /// Radius of the source-style palette selection indicator.
  final double indicatorRadius;

  final bool _hsvMode;

  @override
  Widget build(BuildContext context) {
    if (_hsvMode) {
      return _MiuixHsvColorPalette(
        color: selected,
        onColorChanged: onSelected,
        rows: rows,
        hueColumns: hueColumns,
        includeGrayColumn: includeGrayColumn,
        showPreview: showPreview,
        cornerRadius: cornerRadius,
        indicatorRadius: indicatorRadius,
      );
    }

    final theme = MiuixTheme.of(context);
    final safeColumns = columns <= 0 ? 6 : columns;
    return GridView.count(
      crossAxisCount: safeColumns,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: theme.spacing.sm,
      crossAxisSpacing: theme.spacing.sm,
      children: [
        for (final color in colors)
          MiuixPressable(
            onTap: () => onSelected(color),
            feedbackType: MiuixPressFeedbackType.none,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.toARGB32() == selected.toARGB32()
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).colorScheme.outlineVariant,
                  width: color.toARGB32() == selected.toARGB32() ? 3 : 1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _MiuixHsvColorPalette extends StatefulWidget {
  const _MiuixHsvColorPalette({
    required this.color,
    required this.onColorChanged,
    required this.rows,
    required this.hueColumns,
    required this.includeGrayColumn,
    required this.showPreview,
    required this.cornerRadius,
    required this.indicatorRadius,
  });

  final Color color;
  final ValueChanged<Color> onColorChanged;
  final int rows;
  final int hueColumns;
  final bool includeGrayColumn;
  final bool showPreview;
  final double cornerRadius;
  final double indicatorRadius;

  @override
  State<_MiuixHsvColorPalette> createState() => _MiuixHsvColorPaletteState();
}

class _MiuixHsvColorPaletteState extends State<_MiuixHsvColorPalette> {
  late int _selectedRow;
  late int _selectedColumn;
  late double _alpha;
  Color? _lastEmittedColor;
  ({double hue, double saturation, double value})? _lastAcceptedHsv;

  int get _safeRows => widget.rows <= 0 ? 7 : widget.rows;

  int get _safeHueColumns => widget.hueColumns <= 0 ? 12 : widget.hueColumns;

  int get _totalColumns => _safeHueColumns + (widget.includeGrayColumn ? 1 : 0);

  double get _safeIndicatorRadius =>
      _finiteOr(widget.indicatorRadius, 10).clamp(1.0, 40.0);

  double get _safeCornerRadius =>
      _finiteOr(widget.cornerRadius, 16).clamp(0.0, 90.0);

  @override
  void initState() {
    super.initState();
    _syncSelectionFromColor();
  }

  @override
  void didUpdateWidget(covariant _MiuixHsvColorPalette oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.color.toARGB32() != widget.color.toARGB32() ||
        oldWidget.rows != widget.rows ||
        oldWidget.hueColumns != widget.hueColumns ||
        oldWidget.includeGrayColumn != widget.includeGrayColumn) {
      _syncSelectionFromColor();
    }
  }

  void _syncSelectionFromColor() {
    final hsv = HSVColor.fromColor(widget.color);
    final currentHsv = (
      hue: hsv.hue,
      saturation: hsv.saturation,
      value: hsv.value,
    );
    final lastAccepted = _lastAcceptedHsv;
    if (lastAccepted != null &&
        _paletteHsvApproximatelyEqual(lastAccepted, currentHsv)) {
      // ColorPalette.kt keeps the authored cell when the parent merely echoes
      // the color emitted by that cell. Only alpha and the accepted HSV token
      // are refreshed in this branch.
      _alpha = widget.color.a;
      _lastAcceptedHsv = currentHsv;
      return;
    }
    final rowSv = _buildPaletteRowSv(_safeRows);
    final grayV = _buildPaletteGrayV(_safeRows);
    final isGray = widget.includeGrayColumn && hsv.saturation < .05;
    final column = isGray
        ? _totalColumns - 1
        : ((hsv.hue % 360) / 360 * _safeHueColumns)
              .round()
              .clamp(0, _safeHueColumns - 1)
              .toInt();
    final row = isGray
        ? _nearestPaletteGrayRow(hsv.value, grayV)
        : _nearestPaletteColorRow(hsv.saturation, hsv.value, rowSv);
    _selectedColumn = column;
    _selectedRow = row;
    _alpha = hsv.alpha.clamp(0.0, 1.0);
    _lastAcceptedHsv = currentHsv;
  }

  void _selectCell(
    Offset localPosition,
    Size size,
    TextDirection textDirection,
  ) {
    if (size.width <= 0 || size.height <= 0) {
      return;
    }
    // Gesture coordinates sit on a continuous edge-inclusive plane, whereas
    // palette indices occupy a discrete edge-exclusive interval. Subtracting a
    // tiny epsilon keeps a pointer exactly on the far edge in the last cell.
    //
    // The max call matters for accessibility scaling and animated constraints:
    // a legal positive extent below epsilon would otherwise turn the upper
    // bound negative and make clamp throw before the next layout can recover.
    // Logical widgets may legally be constrained below one pixel. Clamp to a
    // non-negative exclusive edge so a tiny palette remains interactive
    // instead of constructing a reversed numeric range.
    final maximumY = math.max(0.0, size.height - .000001);
    final maximumX = math.max(0.0, size.width - .000001);
    final row =
        ((localPosition.dy.clamp(0.0, maximumY) / size.height) * _safeRows)
            .floor()
            .clamp(0, _safeRows - 1);
    final visualColumn =
        ((localPosition.dx.clamp(0.0, maximumX) / size.width) * _totalColumns)
            .floor()
            .clamp(0, _totalColumns - 1);
    final column = textDirection == TextDirection.rtl
        ? _totalColumns - 1 - visualColumn
        : visualColumn;
    final rowSv = _buildPaletteRowSv(_safeRows);
    final grayV = _buildPaletteGrayV(_safeRows);
    final color = _paletteCellColor(
      column: column,
      row: row,
      rowSv: rowSv,
      grayV: grayV,
      hueColumns: _safeHueColumns,
      includeGrayColumn: widget.includeGrayColumn,
    ).withValues(alpha: _alpha);
    if (_selectedColumn != column || _selectedRow != row) {
      setState(() {
        _selectedColumn = column;
        _selectedRow = row;
        _lastEmittedColor = color;
      });
    } else {
      _lastEmittedColor = color;
    }
    final emittedHsv = HSVColor.fromColor(color);
    _lastAcceptedHsv = (
      hue: emittedHsv.hue,
      saturation: emittedHsv.saturation,
      value: emittedHsv.value,
    );
    // The source invokes the callback for every down/move sample, including a
    // sample that still resolves to the already-selected cell.
    widget.onColorChanged(color);
  }

  @override
  Widget build(BuildContext context) {
    final rowSv = _buildPaletteRowSv(_safeRows);
    final grayV = _buildPaletteGrayV(_safeRows);
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final sourceSliderHeight = _miuixRoundLogicalDimension(26, pixelRatio);
    final sourcePaletteHeight = _miuixRoundLogicalDimension(180, pixelRatio);
    final sourceSpacing = _miuixRoundLogicalDimension(12, pixelRatio);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showPreview) ...[
          _miuixColorShapeClip(
            context,
            clipKey: const ValueKey('miuix-color-palette-preview-clip'),
            radius: sourceSliderHeight / 2,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _lastEmittedColor ?? widget.color,
              ),
              child: SizedBox(height: sourceSliderHeight),
            ),
          ),
          SizedBox(height: sourceSpacing),
        ],
        _miuixColorShapeClip(
          context,
          clipKey: const ValueKey('miuix-color-palette-canvas-clip'),
          radius: _safeCornerRadius,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final paletteSize = Size(
                constraints.maxWidth.isFinite ? constraints.maxWidth : 320,
                sourcePaletteHeight,
              );
              final textDirection = Directionality.of(context);
              void select(Offset position) =>
                  _selectCell(position, paletteSize, textDirection);

              return Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: (event) => select(event.localPosition),
                child: RawGestureDetector(
                  behavior: HitTestBehavior.opaque,
                  gestures: {
                    _MiuixConsumedPanGestureRecognizer:
                        GestureRecognizerFactoryWithHandlers<
                          _MiuixConsumedPanGestureRecognizer
                        >(_MiuixConsumedPanGestureRecognizer.new, (recognizer) {
                          recognizer.dragStartBehavior = DragStartBehavior.down;
                          recognizer.onStart = null;
                          recognizer.onUpdate = (details) =>
                              select(details.localPosition);
                        }),
                  },
                  child: SizedBox(
                    key: const ValueKey('miuix-hsv-palette-canvas'),
                    height: sourcePaletteHeight,
                    child: CustomPaint(
                      painter: _MiuixHsvPalettePainter(
                        rows: _safeRows,
                        hueColumns: _safeHueColumns,
                        includeGrayColumn: widget.includeGrayColumn,
                        selectedRow: _selectedRow,
                        selectedColumn: _selectedColumn,
                        rowSv: rowSv,
                        grayV: grayV,
                        indicatorRadius: _safeIndicatorRadius,
                        textDirection: textDirection,
                        pixelRatio: pixelRatio,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: sourceSpacing),
        _MiuixHsvAlphaSlider(
          value: _alpha,
          baseColor: _paletteCellColor(
            column: _selectedColumn,
            row: _selectedRow,
            rowSv: rowSv,
            grayV: grayV,
            hueColumns: _safeHueColumns,
            includeGrayColumn: widget.includeGrayColumn,
          ),
          onChanged: (value) {
            final alpha = _finiteOr(value, _alpha).clamp(0.0, 1.0);
            final baseColor = _paletteCellColor(
              column: _selectedColumn,
              row: _selectedRow,
              rowSv: rowSv,
              grayV: grayV,
              hueColumns: _safeHueColumns,
              includeGrayColumn: widget.includeGrayColumn,
            );
            final color = baseColor.withValues(alpha: alpha);
            if (alpha != _alpha) {
              setState(() {
                _alpha = alpha;
                _lastEmittedColor = color;
              });
            } else {
              _lastEmittedColor = color;
            }
            final hsv = HSVColor.fromColor(baseColor);
            _lastAcceptedHsv = (
              hue: hsv.hue,
              saturation: hsv.saturation,
              value: hsv.value,
            );
            widget.onColorChanged(color);
          },
        ),
      ],
    );
  }
}

/// Claims a two-dimensional MIUIX control on its first real pointer movement.
/// This mirrors Compose's consumed pointer changes while leaving stationary
/// taps available to the surrounding tap recognizer.
class _MiuixConsumedPanGestureRecognizer extends PanGestureRecognizer {
  @override
  bool hasSufficientGlobalDistanceToAccept(
    PointerDeviceKind pointerDeviceKind,
    double? deviceTouchSlop,
  ) {
    return globalDistanceMoved.abs() > 0;
  }
}

bool _paletteHsvApproximatelyEqual(
  ({double hue, double saturation, double value}) first,
  ({double hue, double saturation, double value}) second,
) {
  final rawHueDistance = (first.hue - second.hue).abs();
  final hueDistance = math.min(rawHueDistance, 360 - rawHueDistance);
  return hueDistance <= 1.5 &&
      (first.saturation - second.saturation).abs() <= .02 &&
      (first.value - second.value).abs() <= .02;
}

class _MiuixHsvPalettePainter extends CustomPainter {
  const _MiuixHsvPalettePainter({
    required this.rows,
    required this.hueColumns,
    required this.includeGrayColumn,
    required this.selectedRow,
    required this.selectedColumn,
    required this.rowSv,
    required this.grayV,
    required this.indicatorRadius,
    required this.textDirection,
    required this.pixelRatio,
  });

  final int rows;
  final int hueColumns;
  final bool includeGrayColumn;
  final int selectedRow;
  final int selectedColumn;
  final List<({double saturation, double value})> rowSv;
  final List<double> grayV;
  final double indicatorRadius;
  final TextDirection textDirection;
  final double pixelRatio;

  // Physical-grid parity notes:
  // - Compose lays out the palette in an integer-sized Android placeable.
  // - Its Canvas therefore reports a physical width and height in whole pixels.
  // - Every column edge uses integer division, `(column * width) / columns`.
  // - Every row edge uses the corresponding integer division over the height.
  // - Remainder pixels are distributed between cells instead of discarded.
  // - That distribution can make neighboring cells differ by one physical pixel.
  // - It also guarantees that the final edge lands on the exact canvas boundary.
  // - Computing in logical pixels would place many edges between device pixels.
  // - Flutter would antialias those fractional edges and create faint grid seams.
  // - Rounding the complete canvas first reproduces the source placeable size.
  // - Dividing only after that rounding reproduces the source remainder pattern.
  // - Converting each edge back to logical units lets Flutter paint on that grid.
  // - RTL mirrors the finished integer-width cell rather than recomputing widths.
  // - The selection center uses the same two edges as its underlying color cell.
  // - This avoids a half-cell drift when the width is not divisible by 13.
  // - Device-pixel ratio changes must repaint because they change edge placement.
  // - Color values themselves remain independent of density and layout direction.
  // - The source four-stop indicator shadow is painted after all grid cells.
  // - The surrounding shape clip then applies the source G2 corner contour.
  @override
  void paint(Canvas canvas, Size size) {
    final totalColumns = hueColumns + (includeGrayColumn ? 1 : 0);
    final cellPaint = Paint();
    final isRtl = textDirection == TextDirection.rtl;
    // Compose receives an integer-pixel Canvas and divides those integer
    // dimensions before drawing. Recreate those physical edges so fractional
    // Flutter logical pixels cannot introduce antialiased seams between cells.
    final safePixelRatio = _finiteOr(pixelRatio, 1).clamp(1.0, 16.0);
    final physicalWidth = (size.width * safePixelRatio).round();
    final physicalHeight = (size.height * safePixelRatio).round();
    double columnEdge(int column) =>
        ((column * physicalWidth) ~/ totalColumns) / safePixelRatio;
    double rowEdge(int row) =>
        ((row * physicalHeight) ~/ rows) / safePixelRatio;
    for (var row = 0; row < rows; row++) {
      final top = rowEdge(row);
      final bottom = rowEdge(row + 1);
      for (var column = 0; column < totalColumns; column++) {
        final start = columnEdge(column);
        final end = columnEdge(column + 1);
        final left = isRtl ? size.width - end : start;
        cellPaint.color = _paletteCellColor(
          column: column,
          row: row,
          rowSv: rowSv,
          grayV: grayV,
          hueColumns: hueColumns,
          includeGrayColumn: includeGrayColumn,
        );
        canvas.drawRect(
          Rect.fromLTRB(left, top, left + (end - start), bottom),
          cellPaint,
        );
      }
    }

    if (rows <= 0 || totalColumns <= 0) {
      return;
    }
    final visualColumn = isRtl
        ? totalColumns - 1 - selectedColumn
        : selectedColumn;
    final center = Offset(
      (columnEdge(visualColumn) + columnEdge(visualColumn + 1)) / 2,
      (rowEdge(selectedRow) + rowEdge(selectedRow + 1)) / 2,
    );
    // PaletteCanvas and ColorSlider share the same four-stop ring shadow in
    // the source. A blurred filled disc incorrectly darkens the selected cell.
    _paintMiuixColorSliderIndicator(
      canvas,
      center,
      indicatorRadius: indicatorRadius,
    );
  }

  @override
  bool shouldRepaint(covariant _MiuixHsvPalettePainter oldDelegate) {
    return rows != oldDelegate.rows ||
        hueColumns != oldDelegate.hueColumns ||
        includeGrayColumn != oldDelegate.includeGrayColumn ||
        selectedRow != oldDelegate.selectedRow ||
        selectedColumn != oldDelegate.selectedColumn ||
        indicatorRadius != oldDelegate.indicatorRadius ||
        textDirection != oldDelegate.textDirection ||
        pixelRatio != oldDelegate.pixelRatio;
  }
}

List<({double saturation, double value})> _buildPaletteRowSv(int rows) {
  if (rows <= 1) {
    return const [(saturation: 1, value: 1)];
  }
  if (rows == 7) {
    const saturation = [.10, .35, .70, 1.00, 1.00, 1.00, 1.00];
    const value = [1.00, 1.00, 1.00, .85, .65, .45, .20];
    return [
      for (var index = 0; index < 7; index++)
        (saturation: saturation[index], value: value[index]),
    ];
  }
  final topBrightCut = math.min(.34, 2 / (rows - 1));
  return [
    for (var index = 0; index < rows; index++)
      () {
        final t = index / (rows - 1);
        final sRamp = (t / .35).clamp(0.0, 1.0);
        final saturation = (.10 + .90 * sRamp).clamp(0.0, 1.0);
        final value = t <= topBrightCut
            ? 1.0
            : _lerpDouble(
                1,
                .20,
                ((t - topBrightCut) / (1 - topBrightCut)).clamp(0.0, 1.0),
              );
        return (saturation: saturation, value: value);
      }(),
  ];
}

List<double> _buildPaletteGrayV(int rows) {
  if (rows <= 1) {
    return const [1];
  }
  return [for (var index = 0; index < rows; index++) 1 - index / (rows - 1)];
}

Color _paletteCellColor({
  required int column,
  required int row,
  required List<({double saturation, double value})> rowSv,
  required List<double> grayV,
  required int hueColumns,
  required bool includeGrayColumn,
}) {
  final safeHueColumns = hueColumns <= 0 ? 12 : hueColumns;
  final totalColumns = safeHueColumns + (includeGrayColumn ? 1 : 0);
  final safeRow = row.clamp(0, rowSv.length - 1).toInt();
  final safeColumn = column.clamp(0, totalColumns - 1).toInt();
  if (includeGrayColumn && safeColumn == totalColumns - 1) {
    final value = grayV[safeRow].clamp(0.0, 1.0);
    return HSVColor.fromAHSV(1, 0, 0, value).toColor();
  }
  final sv = rowSv[safeRow];
  final hue = (safeColumn * (360 / safeHueColumns)) % 360;
  return HSVColor.fromAHSV(
    1,
    hue.toDouble(),
    sv.saturation,
    sv.value,
  ).toColor();
}

int _nearestPaletteGrayRow(double targetValue, List<double> grayV) {
  var index = 0;
  var distance = double.infinity;
  for (var i = 0; i < grayV.length; i++) {
    final next = math.pow(targetValue - grayV[i], 2).toDouble();
    if (next < distance) {
      distance = next;
      index = i;
    }
  }
  return index;
}

int _nearestPaletteColorRow(
  double targetSaturation,
  double targetValue,
  List<({double saturation, double value})> rowSv,
) {
  var index = 0;
  var distance = double.infinity;
  for (var i = 0; i < rowSv.length; i++) {
    final ds = targetSaturation - rowSv[i].saturation;
    final dv = targetValue - rowSv[i].value;
    final next = ds * ds + dv * dv;
    if (next < distance) {
      distance = next;
      index = i;
    }
  }
  return index;
}

double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
