part of '../miuix_widgets.dart';

/// Expandable MIUIX search surface with cleanup and result content.
///
/// Source-parity contract:
///
/// The Compose control is a search surface, not merely a decorated text field.
/// It owns a capsule row, an optional action outside that capsule, and results.
/// Those three regions intentionally remain one widget in the Flutter API.
/// Keeping them together lets expansion drive one coherent transition.
/// The caller remains the source of truth for the expanded state.
/// This mirrors Compose's `expanded` plus `onExpandedChange` pairing.
/// A tap asks the parent to expand and also requests keyboard focus.
/// Keyboard focus asks for expansion when the parent has not done so already.
/// Submitting does not silently collapse because the source delegates that rule.
/// The supplied submission callback can update the controlled expanded value.
/// System back first asks the search surface to collapse.
/// Navigation is allowed only when the controlled surface is already collapsed.
/// A controlled collapse clears both query text and keyboard focus.
/// Query clearing is deferred until after build to avoid parent build mutation.
/// The change callback receives an empty string when that cleanup occurs.
/// Replacing the controller detaches the old listener before using the new one.
/// Listener ownership stays with this state; controller ownership stays outside.
///
/// Capsule geometry:
///
/// The HyperOS 4 capsule has a project-calibrated height of 48 logical pixels.
/// A bounded legacy host may offer 45dp; the capsule accepts that constraint
/// instead of overflowing while its semantics still expose a 48dp target.
/// Its radius is deliberately pill-like instead of a small rounded rectangle.
/// Its fill is `surfaceContainerHigh` and it has no visible outline.
/// The normal leading search slot is 44dp with a 20dp constrained glyph.
/// Normal leading spacing is 16 before the glyph and 8 after it.
/// Normal trailing spacing is 8 before cleanup and 16 after it.
/// The cleanup slot mirrors the same 44dp outer and 20dp inner geometry.
/// Search text is 17 logical pixels and uses medium weight.
/// The placeholder shares those metrics but uses the variant foreground.
/// The placeholder disappears during expansion even before query input.
/// The editable region expands between fixed leading and trailing controls.
/// A stack keeps placeholder and editable baselines perfectly coincident.
/// The outside action is a sibling of the capsule, never painted inside it.
/// `insideMargin` belongs only to the capsule, matching Compose `insideMargin`.
/// Result content starts below the complete row, including the outside action.
///
/// Compact-width behavior:
///
/// Real MIUIX layouts normally give search enough width for text and actions.
/// Flutter widgets can nevertheless be embedded in arbitrary narrow constraints.
/// Below 96 pixels the control reduces padding and glyph sizes defensively.
/// Cleanup is suppressed when showing it would consume the editable region.
/// Below 44 pixels the search glyph becomes the only meaningful visible affordance.
/// That emergency mode is not a new visual variant exposed to applications.
/// It exists solely to preserve Flutter's no-overflow layout contract.
/// The normal source metrics resume automatically as soon as width permits.
/// Default height is preserved even in emergency width mode.
/// A finite parent height remains authoritative so restored routes cannot
/// report a transient Flex overflow while their app-bar geometry settles.
/// A zero-width editable child remains valid and continues to own focus semantics.
/// Text is retained by the controller when it temporarily cannot be painted.
/// Restoring width therefore restores the same query without state loss.
/// Directional padding keeps the same behavior for left-to-right and RTL text.
/// The cleanup affordance is removed rather than clipped into an unusable target.
/// The outer row can still animate an action without changing capsule internals.
///
/// Expansion animation:
///
/// The end action uses horizontal size and slide transitions together.
/// It grows from the logical end so the capsule gives up width progressively.
/// Clipping prevents the incoming action from drawing across the capsule.
/// The source-like 300 millisecond duration uses a cubic ease-in-out curve.
/// A keyed hidden subtree ensures settled actions leave the render tree.
/// That removal matters for hit testing and for accessibility traversal.
/// Results use vertical size plus opacity instead of horizontal movement.
/// Their shorter 220 millisecond duration keeps search response feeling immediate.
/// Result clipping prevents content from painting above the expanding boundary.
/// A keyed hidden result subtree likewise disappears after transition settlement.
/// Tests can therefore distinguish a visually hidden child from a removed child.
/// Parent rebuilds may replace result content without resetting field focus.
/// Expansion never creates a private query controller or copies caller text.
/// The same query is visible to caller logic throughout every animation frame.
///
/// Focus and input details:
///
/// `EditableText` is used so MIUIX metrics are not altered by Material padding.
/// The cursor uses the active primary color from the current color scheme.
/// Selection tint uses a translucent form of that same primary color.
/// The text input action is Search on platforms that expose action labels.
/// The field remains single-line and relies on horizontal editing navigation.
/// Cleanup is pressable through MIUIX feedback rather than a Material splash.
/// Tapping anywhere on the capsule activates the field.
/// The focus listener also refreshes painting for cursor and focus-dependent state.
/// Controller changes rebuild placeholder and cleanup visibility immediately.
/// Programmatic query edits receive the same visual updates as keyboard edits.
/// A no-op cleanup avoids duplicate callbacks for an already empty controller.
/// Focus disposal removes its listener before releasing the node.
/// Controller disposal is intentionally never performed by this widget.
///
/// Integration guidance:
///
/// Use `outsideEndAction` for localized Cancel text or an equivalent action.
/// That action should set `expanded` to false through the owning state.
/// Use `expandedContent` for suggestions or filtered search results.
/// Callers may omit both slots and still use the capsule as a compact field.
/// A null expansion callback leaves focus functional without inventing state.
/// Controlled callers should rebuild promptly after an expansion request.
/// Pages that replace their app bar can use this same controlled state.
/// Pages that expand in place can keep the result slot directly below the row.
/// `PopScope` behavior is local, so unrelated routes keep normal back handling.
/// Theme changes update all colors without recreating the text controller.
/// Locale changes can replace the hint and outside action independently.
/// The component does not filter, sort, or select results on the caller's behalf.
/// This separation preserves the source sample's fixed suggestions as well as search.
/// The ordinary leading and cleanup slots each preserve the source 44dp bound.
/// Their asymmetric 16dp/8dp padding lives inside that bound, not outside it.
/// Consequently each normal vector is constrained to 20dp without scaling the row.
/// The editable line begins exactly 44dp after the capsule's directional start.
/// A visible cleanup slot consumes the same 44dp at the directional end.
/// These measurements follow Compose modifier order rather than visual guesswork.
/// Compact-width adaptations are isolated below the source's practical width.
/// They never alter the normal-width metrics used by phones, tablets, or desktop.
/// The slot keys expose those otherwise invisible constraints to regression tests.
/// Physical-density tests additionally cover Compose's independent pixel rounding.
/// Focus does not resize either slot, so the caret cannot jump during expansion.
/// Text entry only toggles the cleanup slot and leaves the leading origin stable.
/// Directional padding automatically mirrors both slots under right-to-left text.
/// Icon painters remain centered in their constrained space on every platform.
/// Golden tests cover the capsule's normal source geometry and visual states.
/// Widget tests cover expansion, cleanup, slot removal, and pathological widths.
class MiuixSearchBar extends StatefulWidget {
  /// Creates a search bar.
  const MiuixSearchBar({
    super.key,
    required this.controller,
    this.hint = 'Search',
    this.onChanged,
    this.onSubmitted,
    this.expanded = false,
    this.onExpandedChanged,
    this.insideMargin = const EdgeInsets.symmetric(horizontal: 12),
    this.outsideEndAction,
    this.expandedContent,
    this.glass = true,
  }) : inputField = null;

  /// Creates the original MIUIX `SearchBar` parameter form.
  ///
  /// [inputField] is an arbitrary slot by design. The upstream container does
  /// not create or style the field; applications normally place a
  /// [MiuixInputField] here.
  MiuixSearchBar.source({
    super.key,
    required this.inputField,
    required ValueChanged<bool> onExpandedChange,
    Size insideMargin = MiuixSearchBarDefaults.insideMargin,
    this.expanded = false,
    this.outsideEndAction,
    required Widget content,
    this.glass = true,
  }) : controller = null,
       hint = '',
       onChanged = null,
       onSubmitted = null,
       onExpandedChanged = onExpandedChange,
       insideMargin = EdgeInsets.symmetric(
         horizontal: insideMargin.width,
         vertical: insideMargin.height,
       ),
       expandedContent = content;

  /// Text controller used by the earlier combined Flutter convenience form.
  final TextEditingController? controller;

  /// Arbitrary source input-field slot.
  final Widget? inputField;

  /// Placeholder text.
  final String hint;

  /// Change callback.
  final ValueChanged<String>? onChanged;

  /// Submit callback.
  final ValueChanged<String>? onSubmitted;

  /// Whether search results and the outside action are visible.
  final bool expanded;

  /// Called when focus, tapping, or back navigation changes expansion.
  final ValueChanged<bool>? onExpandedChanged;

  /// Margin around the capsule inside the full search row.
  final EdgeInsetsGeometry insideMargin;

  /// Action animated at the row end while expanded, usually Cancel.
  final Widget? outsideEndAction;

  /// Result content revealed below the search row while expanded.
  final Widget? expandedContent;

  /// Whether the default convenience capsule samples the page backdrop.
  ///
  /// A custom [inputField] remains fully caller-owned.
  final bool glass;

  @override
  State<MiuixSearchBar> createState() => _MiuixSearchBarState();
}

/// Preserves the source's 48dp accessibility target around a 45dp field.
///
/// Compose expands the semantics bounds of interactive controls without
/// changing their measured layout. A taller Flutter box would move the next
/// section by 3dp, so this render object expands only [semanticBounds].
/// Merging descendants keeps the platform node exposed as an editable field
/// instead of adding a redundant wrapper beside [EditableText].
/// The expansion is centered because native captures add the same 1.5dp above
/// and below the painted capsule.
/// Horizontal bounds remain unchanged and continue to follow [insideMargin].
/// The wrapper deliberately owns no color, padding, transform, or paint phase.
/// It therefore cannot alter golden images or the following section's origin.
/// The merged node inherits text-field value, selection, focus, and actions.
/// Screen readers consequently retain native editing behavior and class hints.
/// This is different from adding a second labelled semantics-only button.
/// A duplicate node would make TalkBack stop twice on the same search field.
/// The surrounding row still owns the ordinary pointer activation callback.
/// Keyboard focus continues to be managed by the existing [FocusNode].
/// Narrow-width adaptations keep their compact glyph metrics unchanged.
/// Only a target shorter than 48dp receives vertical semantic expansion.
/// A future caller with a taller field will retain its natural semantic size.
/// Widget tests guard both the unchanged 45dp layout and the 48dp node.
class _MiuixSearchSemanticsTarget extends SingleChildRenderObjectWidget {
  /// Creates the source-sized semantic target.
  const _MiuixSearchSemanticsTarget({super.key, required super.child});

  /// Builds the render object that owns the merged semantic boundary.
  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderMiuixSearchSemanticsTarget();
  }
}

/// Render-side semantics expansion for [_MiuixSearchSemanticsTarget].
class _RenderMiuixSearchSemanticsTarget extends RenderProxyBox {
  /// Source minimum interactive target for Compose text fields.
  static const double _minimumSemanticHeight = 48;

  /// Expands equally above and below the unchanged 45dp layout box.
  @override
  Rect get semanticBounds {
    final extra = math.max(0.0, (_minimumSemanticHeight - size.height) / 2);
    return Rect.fromLTRB(0, -extra, size.width, size.height + extra);
  }

  /// Combines the gesture and editable descendants into the expanded node.
  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config
      ..isSemanticBoundary = true
      ..isMergingSemanticsOfDescendants = true;
  }
}

class _MiuixSearchBarState extends State<MiuixSearchBar> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_handleFocusChanged);
    widget.controller?.addListener(_handleControllerChanged);
    // A source search takeover is commonly inserted already expanded (for
    // example, the icon catalogue replaces its entire app bar). In that case
    // didUpdateWidget never sees a false-to-true transition, so restore the
    // Compose autofocus contract after the first layout explicitly.
    if (widget.expanded && widget.controller != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.expanded) {
          _focusNode.requestFocus();
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant MiuixSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChanged);
      widget.controller?.addListener(_handleControllerChanged);
    }
    if (oldWidget.controller != null &&
        oldWidget.expanded &&
        !widget.expanded) {
      final collapsedController = oldWidget.controller!;
      // Compose InputField clears its query and focus after collapse. Schedule
      // the mutation outside build so controlled parents see the same result.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || widget.expanded) {
          return;
        }
        _focusNode.unfocus();
        // A parent may swap or remove the controller in the same frame as the
        // collapse. The deferred cleanup belongs only to the query that was
        // visible at collapse time; never erase a replacement controller.
        if (!identical(widget.controller, collapsedController)) {
          return;
        }
        if (collapsedController.text.isNotEmpty) {
          collapsedController.clear();
          widget.onChanged?.call('');
        }
      });
    } else if (widget.controller != null &&
        !oldWidget.expanded &&
        widget.expanded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.expanded) {
          _focusNode.requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleControllerChanged);
    _focusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    super.dispose();
  }

  void _handleControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleFocusChanged() {
    if (widget.controller != null && _focusNode.hasFocus && !widget.expanded) {
      widget.onExpandedChanged?.call(true);
    }
    _handleControllerChanged();
  }

  void _handleChanged(String value) {
    widget.onChanged?.call(value);
    _handleControllerChanged();
  }

  void _clear() {
    if (widget.controller!.text.isEmpty) {
      return;
    }
    widget.controller!.clear();
    widget.onChanged?.call('');
  }

  void _activate() {
    if (!widget.expanded) {
      widget.onExpandedChanged?.call(true);
    }
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final scheme = theme.colorScheme;
    final hasText = widget.controller?.text.isNotEmpty ?? false;
    final searchBorderRadius = BorderRadius.circular(999);
    final textStyle =
        theme.textTheme.bodyLarge?.copyWith(
          color: scheme.onSurface,
          fontSize: 17,
          fontWeight: FontWeight.w500,
        ) ??
        TextStyle(
          color: scheme.onSurface,
          fontSize: 17,
          fontWeight: FontWeight.w500,
        );
    final compatibilitySearchInput = LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            constraints.maxWidth.isFinite && constraints.maxWidth < 96;
        // Normal source padding is retained whenever a useful text field can
        // fit. At pathological widths, reserve the remaining pixels for the
        // icon instead of allowing its fixed padding to overflow the Row.
        final iconOnly =
            constraints.maxWidth.isFinite && constraints.maxWidth < 44;
        final leadingStart = iconOnly
            ? 2.0
            : compact
            ? 8.0
            : 16.0;
        final leadingEnd = iconOnly
            ? 2.0
            : compact
            ? 4.0
            : 8.0;
        final trailingStart = compact ? 4.0 : 8.0;
        final trailingEnd = compact ? 8.0 : 16.0;
        // Compose applies `size(44.dp)` before its directional padding.
        // Padding therefore constrains the ordinary vector to 20dp instead
        // of adding 24dp around an already 24dp glyph.
        final leadingGlyph = iconOnly
            ? 14.0
            : compact
            ? 17.0
            : 20.0;
        final leadingExtent = leadingStart + leadingGlyph + leadingEnd;
        final trailingGlyph = compact ? 15.0 : 20.0;
        final trailingExtent = trailingStart + trailingGlyph + trailingEnd;
        final showTrailing = hasText && (!compact || constraints.maxWidth > 64);
        // HyperOS 4 normally receives the complete 48dp token. Source-derived
        // app bars can still reserve a 45dp visual slot while expanding only
        // semantics to 48dp. Respecting that finite slot prevents a hidden
        // three-pixel child overflow when the retained route becomes visible
        // during a page pop, without changing unconstrained/default geometry.
        final searchHeight = constraints.maxHeight.isFinite
            ? math.min(hyperOs4.searchHeight, constraints.maxHeight)
            : hyperOs4.searchHeight;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _activate,
          child: MiuixGlass(
            key: const ValueKey('miuix-search-bar-container'),
            enabled: widget.glass,
            blur: hyperOs4.searchBlur,
            opacity: hyperOs4.searchTintOpacity,
            color: scheme.surfaceContainerHigh,
            borderRadius: searchBorderRadius,
            padding: EdgeInsets.zero,
            showSpecular: true,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: searchHeight),
              child: Row(
                children: [
                  SizedBox(
                    key: const ValueKey('miuix-search-leading-slot'),
                    width: leadingExtent,
                    height: compact || iconOnly ? leadingGlyph : 44,
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(
                        start: leadingStart,
                        end: leadingEnd,
                      ),
                      child: Center(
                        child: MiuixThemedIcon(
                          MiuixIcons.basic.search,
                          size: leadingGlyph,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      alignment: AlignmentDirectional.centerStart,
                      children: [
                        if (!hasText && !widget.expanded)
                          IgnorePointer(
                            child: Text(
                              widget.hint,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textStyle.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        EditableText(
                          key: const ValueKey('miuix-search-bar-input'),
                          controller: widget.controller!,
                          focusNode: _focusNode,
                          style: textStyle,
                          cursorColor: scheme.primary,
                          backgroundCursorColor: scheme.onSurface,
                          maxLines: 1,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.search,
                          onChanged: _handleChanged,
                          onSubmitted: widget.onSubmitted,
                          selectionColor: scheme.primary.withValues(alpha: .24),
                        ),
                      ],
                    ),
                  ),
                  if (showTrailing)
                    SizedBox(
                      key: const ValueKey('miuix-search-trailing-slot'),
                      width: trailingExtent,
                      height: compact ? trailingGlyph : 44,
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(
                          start: trailingStart,
                          end: trailingEnd,
                        ),
                        child: Center(
                          child: MiuixPressable(
                            onTap: _clear,
                            borderRadius: BorderRadius.circular(999),
                            feedbackType: MiuixPressFeedbackType.none,
                            showIndication: true,
                            child: _MiuixSearchCleanupIcon(
                              key: const ValueKey('miuix-search-bar-clear'),
                              size: trailingGlyph,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
    final searchInput = widget.inputField ?? compatibilitySearchInput;
    final action = widget.outsideEndAction;
    final results = widget.expandedContent;
    return LayoutBuilder(
      builder: (context, outerConstraints) {
        // A collapsed search row may live in a source-derived 45dp app-bar
        // slot. Column otherwise lays out this Row with an unbounded main axis,
        // so the 48dp child never sees the host limit and overflows by 3dp.
        final collapsedRowHeight =
            !widget.expanded && outerConstraints.maxHeight.isFinite
            ? math.min(hyperOs4.searchHeight, outerConstraints.maxHeight)
            : null;
        return PopScope(
          canPop: !widget.expanded,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop && widget.expanded) {
              widget.onExpandedChanged?.call(false);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: collapsedRowHeight,
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: widget.insideMargin,
                        child: _MiuixSearchSemanticsTarget(
                          key: const ValueKey('miuix-search-semantic-target'),
                          child: searchInput,
                        ),
                      ),
                    ),
                    _MiuixSearchVisibility(
                      visible: widget.expanded && action != null,
                      axis: Axis.horizontal,
                      slideFromEnd: true,
                      child: KeyedSubtree(
                        key: const ValueKey('miuix-search-outside-action'),
                        child: action ?? const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
              ),
              _MiuixSearchVisibility(
                visible: widget.expanded && results != null,
                axis: Axis.vertical,
                fade: true,
                child: KeyedSubtree(
                  key: const ValueKey('miuix-search-expanded-content'),
                  child: results ?? const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Exact Flutter rendering of the source `SearchCleanup` ImageVector.
///
/// The upstream glyph is not a monochrome filled cancel icon: its circular
/// field uses 6% of the supplied tint and its rounded cross uses 30%.
class _MiuixSearchCleanupIcon extends StatelessWidget {
  const _MiuixSearchCleanupIcon({
    super.key,
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final resolved = MiuixIconTheme.resolveOf(context, MiuixBasicIconCatalog.close);
    if (resolved != MiuixBasicIconCatalog.close) {
      return MiuixThemedIcon(resolved, size: size, color: color.withValues(alpha: .6));
    }
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _MiuixSearchCleanupPainter(color)),
    );
  }
}

class _MiuixSearchCleanupPainter extends CustomPainter {
  const _MiuixSearchCleanupPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final extent = size.shortestSide;
    final center = size.center(Offset.zero);
    final alpha = color.a;
    canvas.drawCircle(
      center,
      extent * 32 / 68,
      Paint()..color = color.withValues(alpha: alpha * .06),
    );

    final inset = extent * 23.3934 / 68;
    final far = extent - inset;
    final crossPaint = Paint()
      ..color = color.withValues(alpha: alpha * .30)
      ..strokeWidth = extent * 6 / 68
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawLine(Offset(inset, inset), Offset(far, far), crossPaint)
      ..drawLine(Offset(far, inset), Offset(inset, far), crossPaint);
  }

  @override
  bool shouldRepaint(covariant _MiuixSearchCleanupPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
