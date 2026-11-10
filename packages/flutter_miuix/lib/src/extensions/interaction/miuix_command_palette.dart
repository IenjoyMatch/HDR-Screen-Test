import '../../icons/miuix_icon_theme.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../effects/miuix_effects.dart';
import '../../platform/miuix_haptics.dart';
import '../../theme/miuix_semantic_colors.dart';
import '../../theme/miuix_theme.dart';
import '../../widgets/miuix_widgets.dart';
import '../miuix_extension_icons.dart';

/// Executable item displayed by [MiuixCommandPalette].
@immutable
class MiuixCommand {
  /// Creates a command with searchable metadata.
  const MiuixCommand({
    required this.id,
    required this.title,
    required this.onInvoke,
    this.subtitle,
    this.category,
    this.keywords = const <String>[],
    this.icon,
    this.shortcut,
    this.enabled = true,
  });

  /// Stable identity and primary label.
  final String id;
  final String title;
  final String? subtitle;
  final String? category;

  /// Additional terms matched without being displayed as the title.
  final List<String> keywords;

  /// Optional visual metadata.
  final Widget? icon;
  final ShortcutActivator? shortcut;

  final bool enabled;
  final FutureOr<void> Function() onInvoke;

  /// Lowercase corpus used by the default matcher.
  String get searchableText => <String>[
    title,
    ?subtitle,
    ?category,
    ...keywords,
  ].join(' ').toLowerCase();
}

/// Hoisted query and highlight state for an embedded command palette.
class MiuixCommandPaletteController extends ChangeNotifier {
  String _query = '';
  int _highlightedIndex = 0;

  /// Current normalized query and highlighted visible row.
  String get query => _query;
  int get highlightedIndex => _highlightedIndex;

  /// Updates the query and resets navigation to the first result.
  void setQuery(String value) {
    if (_query == value) return;
    _query = value;
    _highlightedIndex = 0;
    notifyListeners();
  }

  /// Updates the highlighted visible index.
  void highlight(int value) {
    final next = value < 0 ? 0 : value;
    if (_highlightedIndex == next) return;
    _highlightedIndex = next;
    notifyListeners();
  }
}

/// Palette roles for command search and selection.
@immutable
class MiuixCommandPaletteColors {
  const MiuixCommandPaletteColors({
    required this.foreground,
    required this.secondaryForeground,
    required this.selectedBackground,
    required this.selectedForeground,
    required this.disabledForeground,
    required this.shortcutBackground,
  });

  final Color foreground;
  final Color secondaryForeground;
  final Color selectedBackground;
  final Color selectedForeground;
  final Color disabledForeground;
  final Color shortcutBackground;
}

/// Geometry and semantic defaults for the command palette.
abstract final class MiuixCommandPaletteDefaults {
  // HyperOS 4 command-palette implementation contract:
  // - Search remains the first focusable element in the embedded panel.
  // - Query changes preserve a content-fitting panel rather than full height.
  // - Arrow keys move one visible logical result at a time.
  // - Disabled results cannot become an invokable endpoint.
  // - Highlight is expressed by the complete row, not an icon-only marker.
  // - Row background and foreground colors interpolate on one timeline.
  // - The collection-row token family owns timing and continuous corners.
  // - Shortcut labels remain subordinate to the command's primary content.
  // - Filtering resets the highlighted visible coordinate deterministically.
  // - Pointer and keyboard invocation publish the same command object.
  // - Confirmation haptics occur only for enabled command invocation.
  // - Escape delegates to the caller instead of assuming a route topology.
  // - Runtime reduced motion discards an in-flight highlight sample.
  // - The final logical selection stays legible when animation is disabled.
  // - Panel resizing and row highlighting use independent motion channels.
  // - Visible rows do not inherit route-level safe-area list padding.
  // - Long command collections scroll while the search field stays fixed.
  // - The caller's maximum height is a cap, never a forced panel height.
  // - Empty search results retain the same anchored panel coordinate space.
  // - Category and subtitle text remain secondary during row highlighting.
  // - Arbitrary shortcut activators have a stable compact textual fallback.
  // - Custom invocation futures are not started for disabled commands.
  // - Controller replacement preserves ownership and listener disposal rules.
  // These are auditable project rules inferred from official presentation;
  // the duration and radius tokens remain explicitly project-calibrated.
  // Keyboard coordinate and dismissal contract:
  // - Highlight indices are coordinates in the filtered visible command list.
  // - They are not coordinates in the caller's complete unfiltered catalogue.
  // - Query changes reset the controller coordinate before the next navigation key.
  // - A disabled row is never painted as the active keyboard endpoint.
  // - Normalization searches forward first, then backward from an invalid endpoint.
  // - If every visible command is disabled, zero is only a dormant coordinate.
  // - That dormant coordinate does not confer selected semantics on its row.
  // - Up and Down traverse enabled results without wrapping at either boundary.
  // - Multi-step movement consumes one enabled result for each requested step.
  // - Home selects the first enabled result rather than the first physical row.
  // - End selects the last enabled result rather than the last physical row.
  // - Main Enter and numpad Enter invoke the same currently enabled command.
  // - Pointer activation first publishes its row as the current highlighted result.
  // - Embedded palettes intentionally allow multiple successive command invocations.
  // - They cannot assume that an invocation always dismisses their host surface.
  // - Modal `show` helpers instead own a one-shot dismissal barrier per route.
  // - That barrier prevents a double activation from popping the caller underneath.
  // - It is local to one modal invocation and never leaks into embedded behavior.
  // - Escape remains repeatable for embedded hosts that implement custom dismissal.
  // - Modal Escape shares the same guarded close function as pointer invocation.
  // - Command work starts only after the dialog Future reports the chosen command.
  // - This ensures route removal completes before arbitrary async work mutates UI.
  // - A command exception remains visible to the caller awaiting the show Future.
  // - Keyboard scrolling uses the complete row extent, including surface padding.
  // - It moves only when the target lies outside the current results viewport.
  // - Rows already fully visible never cause unnecessary scroll animation.
  // - The target offset is clamped to the scroll position's legal extent.
  // - Reduced motion jumps directly to that legal offset in the next frame.
  // - Normal motion uses the same collection-row duration as selection feedback.
  // - A controller replacement invalidates scheduled scroll work for its predecessor.
  // - Scroll work also checks attachment because short result sets may not scroll.
  // - Dynamic catalogue shrink normalizes before any indexed row access is published.
  // - Dynamic catalogue growth preserves a still-valid enabled highlighted coordinate.
  // - Duplicate authored ids do not create duplicate animation keys in one list.
  // - The visible index disambiguates those ids while retaining predictable motion.
  // - Stable unique ids remain recommended when callers reorder catalogue entries.
  // - Non-finite maximum height cannot enter a SizedBox or clamp boundary.
  // - Such values resolve to the calibrated 520dp default upper bound.
  // - A non-positive finite maximum resolves to the same usable default bound.
  // - A small positive maximum remains an explicit hard cap below minimum height.
  // - Short catalogues fit their content instead of expanding to that upper bound.
  // - Search, result list, and panel resize remain independent focus/motion channels.
  // - Runtime autofocus enablement requests search focus after the updated frame.
  // - Runtime autofocus disablement does not forcibly steal focus from application UI.
  // - External query updates synchronize text and collapse the selection to the end.
  // - Text selection-only edits do not rewrite controller query state.
  // - Custom filters receive the normalized lowercase trimmed query.
  // - Searchable command text remains lowercase but preserves caller-visible labels.
  // - Shortcut badges are presentation metadata, not an implicit global registration.
  // - Global opening remains owned by `MiuixCommandPaletteShortcut` and its focus scope.
  // - All these rules apply in both dialog-owned and caller-owned palette surfaces.

  static const double maxWidth = 680;
  static const double maxHeight = 520;
  static const double minHeight = 180;
  static const double rowHeight = 58;
  static const double completeRowExtent = rowHeight + 18;
  static const double cornerRadius = 22;

  /// Resolves a content-fitting panel height under the caller's upper bound.
  ///
  /// Command rows include their surface inset and separation in addition to
  /// [rowHeight]. Keeping [maxHeight] as a cap makes the public `maxHeight`
  /// argument behave as its name promises instead of forcing every short
  /// command list into a near-full-screen panel.
  static double panelHeight({
    required int commandCount,
    double maxHeight = MiuixCommandPaletteDefaults.maxHeight,
  }) {
    final safeCount = commandCount.clamp(0, 1000000);
    final safeMaximum = maxHeight.isFinite && maxHeight > 0
        ? maxHeight
        : MiuixCommandPaletteDefaults.maxHeight;
    final lowerBound = safeMaximum < minHeight ? safeMaximum : minHeight;
    const searchAndGap = 66.0;
    return (searchAndGap + safeCount * completeRowExtent).clamp(
      lowerBound,
      safeMaximum,
    );
  }

  static MiuixCommandPaletteColors colors(BuildContext context) {
    final semantic = MiuixSemanticColors.of(context);
    return MiuixCommandPaletteColors(
      foreground: semantic['onSurface'],
      secondaryForeground: semantic['onSurfaceSecondary'],
      selectedBackground: semantic['primaryContainer'],
      selectedForeground: semantic['onPrimaryContainer'],
      disabledForeground: semantic['disabledOnSurface'],
      shortcutBackground: semantic['surfaceContainerHigh'],
    );
  }
}

/// Search-first keyboard command launcher.
class MiuixCommandPalette extends StatefulWidget {
  /// Creates an embeddable command palette panel.
  const MiuixCommandPalette({
    super.key,
    required this.commands,
    this.controller,
    this.onInvoked,
    this.onDismiss,
    this.commandFilter,
    this.searchHint = '搜索命令',
    this.emptyMessage = '没有匹配的命令',
    this.autofocus = true,
    this.maxHeight = MiuixCommandPaletteDefaults.maxHeight,
    this.backgroundColor,
    this.glass = true,
    this.glassBlur,
    this.glassOpacity,
    this.showGlassSpecular = true,
    this.cornerRadius = double.nan,
    this.colors,
  }) : _ownsPanelSurface = true;

  /// Creates the former host-owned command list without a panel material.
  ///
  /// This is the compatibility form for applications that already place the
  /// palette inside their own opaque dialog or card. The ordinary constructor
  /// now owns one HyperOS 4 popup surface when it is embedded directly.
  const MiuixCommandPalette.source({
    super.key,
    required this.commands,
    this.controller,
    this.onInvoked,
    this.onDismiss,
    this.commandFilter,
    this.searchHint = '搜索命令',
    this.emptyMessage = '没有匹配的命令',
    this.autofocus = true,
    this.maxHeight = MiuixCommandPaletteDefaults.maxHeight,
    this.colors,
  }) : backgroundColor = null,
       glass = false,
       glassBlur = null,
       glassOpacity = null,
       showGlassSpecular = false,
       cornerRadius = MiuixCommandPaletteDefaults.cornerRadius,
       _ownsPanelSurface = false;

  /// Complete command catalogue.
  final List<MiuixCommand> commands;
  final MiuixCommandPaletteController? controller;

  /// Invocation and dismissal callbacks for embedded use.
  final ValueChanged<MiuixCommand>? onInvoked;
  final VoidCallback? onDismiss;

  /// Optional custom query matcher.
  final bool Function(MiuixCommand command, String query)? commandFilter;

  final String searchHint;
  final String emptyMessage;
  final bool autofocus;
  final double maxHeight;

  /// Embedded-panel material overrides.
  final Color? backgroundColor;
  final bool glass;
  final double? glassBlur;
  final double? glassOpacity;
  final bool showGlassSpecular;
  final double cornerRadius;
  final MiuixCommandPaletteColors? colors;

  final bool _ownsPanelSurface;

  /// Opens a MIUIX dialog and invokes the selected command after dismissal.
  static Future<MiuixCommand?> show({
    required BuildContext context,
    required List<MiuixCommand> commands,
    String title = '命令面板',
    String searchHint = '搜索命令',
    String emptyMessage = '没有匹配的命令',
    bool Function(MiuixCommand command, String query)? commandFilter,
  }) async {
    // MiuixDialog is installed on the root navigator. Capture that same
    // navigator before awaiting so an action opened from a nested tab/router
    // dismisses the modal rather than popping the page underneath it.
    // Capturing also avoids looking up an inherited Navigator from dialog
    // content after asynchronous command work has changed the widget tree.
    final navigator = Navigator.of(context, rootNavigator: true);
    var dismissalCommitted = false;
    void closeWith(MiuixCommand? command) {
      if (dismissalCommitted || !navigator.mounted) return;
      dismissalCommitted = true;
      navigator.pop(command);
    }

    final command = await MiuixDialog.show<MiuixCommand>(
      context: context,
      title: title,
      maxWidth: MiuixCommandPaletteDefaults.maxWidth,
      insideMargin: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      content: MiuixCommandPalette(
        commands: commands,
        searchHint: searchHint,
        emptyMessage: emptyMessage,
        commandFilter: commandFilter,
        // The dialog owns the only backdrop-filtering surface in this route.
        // A transparent palette shell retains clipping and sizing without
        // stacking a second blur over the same scene.
        glass: false,
        backgroundColor: Colors.transparent,
        showGlassSpecular: false,
        cornerRadius: 0,
        onInvoked: closeWith,
        onDismiss: () => closeWith(null),
      ),
    );
    if (command != null) await command.onInvoke();
    return command;
  }

  /// Opens the former opaque MIUIX dialog presentation.
  static Future<MiuixCommand?> showSource({
    required BuildContext context,
    required List<MiuixCommand> commands,
    String title = '命令面板',
    String searchHint = '搜索命令',
    String emptyMessage = '没有匹配的命令',
    bool Function(MiuixCommand command, String query)? commandFilter,
  }) async {
    // Keep source-backed and immediate palettes behaviorally identical. Both
    // route through the root overlay and therefore must close through the root
    // navigator even when the caller lives inside a nested navigation shell.
    final navigator = Navigator.of(context, rootNavigator: true);
    var dismissalCommitted = false;
    void closeWith(MiuixCommand? command) {
      if (dismissalCommitted || !navigator.mounted) return;
      dismissalCommitted = true;
      navigator.pop(command);
    }

    final command = await MiuixDialog.show<MiuixCommand>(
      context: context,
      title: title,
      maxWidth: MiuixCommandPaletteDefaults.maxWidth,
      insideMargin: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      glass: false,
      content: MiuixCommandPalette.source(
        commands: commands,
        searchHint: searchHint,
        emptyMessage: emptyMessage,
        commandFilter: commandFilter,
        onInvoked: closeWith,
        onDismiss: () => closeWith(null),
      ),
    );
    if (command != null) await command.onInvoke();
    return command;
  }

  @override
  State<MiuixCommandPalette> createState() => _MiuixCommandPaletteState();
}

class _MiuixCommandPaletteState extends State<MiuixCommandPalette> {
  late MiuixCommandPaletteController _controller;
  late bool _ownsController;
  late final TextEditingController _query;
  final FocusNode _searchFocus = FocusNode(debugLabel: 'CommandPaletteSearch');
  final ScrollController _resultsScroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _attachController();
    _query = TextEditingController(text: _controller.query);
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _searchFocus.requestFocus();
      });
    }
  }

  void _attachController() {
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? MiuixCommandPaletteController();
    _controller.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(MiuixCommandPalette oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.autofocus && widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _searchFocus.requestFocus();
      });
    }
    if (oldWidget.controller == widget.controller) return;
    _controller.removeListener(_rebuild);
    if (_ownsController) _controller.dispose();
    _attachController();
    _query.value = TextEditingValue(
      text: _controller.query,
      selection: TextSelection.collapsed(offset: _controller.query.length),
    );
  }

  void _rebuild() {
    if (!mounted) return;
    if (_query.text != _controller.query) {
      _query.value = TextEditingValue(
        text: _controller.query,
        selection: TextSelection.collapsed(offset: _controller.query.length),
      );
    }
    setState(() {});
  }

  List<MiuixCommand> get _visible {
    final query = _controller.query.trim().toLowerCase();
    if (query.isEmpty) return List<MiuixCommand>.of(widget.commands);
    return widget.commands
        .where((command) {
          return widget.commandFilter?.call(command, query) ??
              command.searchableText.contains(query);
        })
        .toList(growable: false);
  }

  int? _nearestEnabledIndex(
    List<MiuixCommand> visible,
    int preferred, {
    int direction = 1,
  }) {
    if (visible.isEmpty) return null;
    final start = preferred.clamp(0, visible.length - 1);
    if (visible[start].enabled) return start;
    for (var distance = 1; distance < visible.length; distance++) {
      final primary = start + distance * (direction < 0 ? -1 : 1);
      if (primary >= 0 &&
          primary < visible.length &&
          visible[primary].enabled) {
        return primary;
      }
      final secondary = start - distance * (direction < 0 ? -1 : 1);
      if (secondary >= 0 &&
          secondary < visible.length &&
          visible[secondary].enabled) {
        return secondary;
      }
    }
    return null;
  }

  void _publishHighlight(int index) {
    _controller.highlight(index);
    final observedController = _controller;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !identical(_controller, observedController)) return;
      if (!_resultsScroll.hasClients) return;
      final position = _resultsScroll.position;
      final rowTop = index * MiuixCommandPaletteDefaults.completeRowExtent;
      final rowBottom = rowTop + MiuixCommandPaletteDefaults.completeRowExtent;
      final viewportTop = position.pixels;
      final viewportBottom = viewportTop + position.viewportDimension;
      var target = viewportTop;
      if (rowTop < viewportTop) {
        target = rowTop;
      } else if (rowBottom > viewportBottom) {
        target = rowBottom - position.viewportDimension;
      } else {
        return;
      }
      target = target.clamp(position.minScrollExtent, position.maxScrollExtent);
      if (MediaQuery.disableAnimationsOf(context)) {
        _resultsScroll.jumpTo(target);
      } else {
        _resultsScroll.animateTo(
          target,
          duration: MiuixTheme.of(context).hyperOs4.collectionRowMotion,
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _move(int delta) {
    final visible = _visible;
    if (visible.isEmpty || delta == 0) return;
    final direction = delta < 0 ? -1 : 1;
    var current = _controller.highlightedIndex.clamp(0, visible.length - 1);
    if (!visible[current].enabled) {
      final normalized = _nearestEnabledIndex(
        visible,
        current,
        direction: direction,
      );
      if (normalized != null) _publishHighlight(normalized);
      return;
    }
    for (var remaining = delta.abs(); remaining > 0; remaining--) {
      int? candidate;
      for (
        var index = current + direction;
        index >= 0 && index < visible.length;
        index += direction
      ) {
        if (visible[index].enabled) {
          candidate = index;
          break;
        }
      }
      if (candidate == null) break;
      current = candidate;
    }
    _publishHighlight(current);
  }

  void _moveToBoundary(bool end) {
    final visible = _visible;
    final indices = end
        ? Iterable<int>.generate(visible.length).toList().reversed
        : Iterable<int>.generate(visible.length);
    for (final index in indices) {
      if (visible[index].enabled) {
        _publishHighlight(index);
        return;
      }
    }
  }

  void _invoke(MiuixCommand command, int index) {
    if (!command.enabled) return;
    _publishHighlight(index);
    widget.onInvoked?.call(command);
    MiuixHaptics.perform(MiuixHapticType.confirm);
  }

  void _invokeHighlighted() {
    final visible = _visible;
    if (visible.isEmpty) return;
    final preferred = _controller.highlightedIndex.clamp(0, visible.length - 1);
    final index = _nearestEnabledIndex(visible, preferred);
    if (index != null) _invoke(visible[index], index);
  }

  void _normalizeHighlightAfterBuild() {
    // Highlight normalization contract:
    // - The controller stores a coordinate in the currently visible results.
    // - Dynamic filtering and catalogue shrink can invalidate that coordinate.
    // - Empty results use zero as the deterministic dormant coordinate.
    // - Non-empty results clamp to the nearest remaining visible row.
    // - Correction occurs after build so listeners cannot rebuild mid-layout.
    // - The controller identity is captured with the frame that requested it.
    // - A replacement controller rejects correction work for the former owner.
    // - Current visible results are recomputed when the callback actually runs.
    // - Multiple scheduled corrections collapse through controller no-op checks.
    // - Correcting navigation state emits no command invocation or haptic event.
    // - Query, custom filters and catalogue updates all share this one barrier.
    // - Future asynchronous normalization must preserve the same ownership rule.
    final observedController = _controller;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !identical(_controller, observedController)) return;
      final currentVisible = _visible;
      final preferred = currentVisible.isEmpty
          ? 0
          : observedController.highlightedIndex.clamp(
              0,
              currentVisible.length - 1,
            );
      final target = _nearestEnabledIndex(currentVisible, preferred) ?? 0;
      if (currentVisible.isNotEmpty && currentVisible[target].enabled) {
        _publishHighlight(target);
      } else {
        observedController.highlight(target);
      }
    });
  }

  String _shortcutLabel(ShortcutActivator shortcut) {
    if (shortcut is SingleActivator) {
      final parts = <String>[
        if (shortcut.control) 'Ctrl',
        if (shortcut.meta) 'Meta',
        if (shortcut.alt) 'Alt',
        if (shortcut.shift) 'Shift',
        shortcut.trigger.keyLabel.toUpperCase(),
      ];
      return parts.join('+');
    }
    return shortcut.toString();
  }

  Widget _commandRow(
    MiuixCommand command,
    int index,
    MiuixCommandPaletteColors colors,
  ) {
    final selected = command.enabled && index == _controller.highlightedIndex;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: TweenAnimationBuilder<double>(
        key: ValueKey<(String, int, bool)>((command.id, index, reduceMotion)),
        tween: Tween<double>(end: selected ? 1 : 0),
        duration: reduceMotion ? Duration.zero : hyperOs4.collectionRowMotion,
        curve: Curves.easeOutCubic,
        builder: (context, selectionProgress, _) {
          final foreground = !command.enabled
              ? colors.disabledForeground
              : Color.lerp(
                  colors.foreground,
                  colors.selectedForeground,
                  selectionProgress,
                )!;
          final background = Color.lerp(
            Colors.transparent,
            colors.selectedBackground,
            selectionProgress,
          )!;
          return Semantics(
            button: true,
            enabled: command.enabled,
            selected: selected,
            label: command.title,
            child: MiuixSurface(
              key: ValueKey<Object>(('miuix-command-row', command.id)),
              radius: hyperOs4.collectionRowCornerRadius,
              color: background,
              onTap: command.enabled ? () => _invoke(command, index) : null,
              onLongPress: command.enabled
                  ? () => _invoke(command, index)
                  : null,
              padding: const EdgeInsetsDirectional.fromSTEB(12, 7, 10, 7),
              child: SizedBox(
                height: MiuixCommandPaletteDefaults.rowHeight,
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: 36,
                      child: IconTheme(
                        data: IconThemeData(color: foreground, size: 22),
                        child: command.icon ?? const MiuixThemedIcon(Icons.bolt_rounded),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            command.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: foreground,
                                  fontWeight: selected ? FontWeight.w600 : null,
                                ),
                          ),
                          if (command.subtitle != null ||
                              command.category != null)
                            Text(
                              command.subtitle ?? command.category!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: colors.secondaryForeground),
                            ),
                        ],
                      ),
                    ),
                    if (command.shortcut != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colors.shortcutBackground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _shortcutLabel(command.shortcut!),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: colors.secondaryForeground),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_rebuild);
    if (_ownsController) _controller.dispose();
    _query.dispose();
    _searchFocus.dispose();
    _resultsScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors ?? MiuixCommandPaletteDefaults.colors(context);
    final semantic = MiuixSemanticColors.of(context);
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final visible = _visible;
    if ((visible.isEmpty && _controller.highlightedIndex != 0) ||
        (visible.isNotEmpty &&
            (_controller.highlightedIndex >= visible.length ||
                !visible[_controller.highlightedIndex].enabled))) {
      _normalizeHighlightAfterBuild();
    }
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.arrowUp): _PaletteMoveIntent(-1),
        SingleActivator(LogicalKeyboardKey.arrowDown): _PaletteMoveIntent(1),
        SingleActivator(LogicalKeyboardKey.home): _PaletteBoundaryIntent(false),
        SingleActivator(LogicalKeyboardKey.end): _PaletteBoundaryIntent(true),
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _PaletteMoveIntent: CallbackAction<_PaletteMoveIntent>(
            onInvoke: (intent) {
              _move(intent.delta);
              return null;
            },
          ),
          _PaletteBoundaryIntent: CallbackAction<_PaletteBoundaryIntent>(
            onInvoke: (intent) {
              _moveToBoundary(intent.end);
              return null;
            },
          ),
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _invokeHighlighted();
              return null;
            },
          ),
          DismissIntent: CallbackAction<DismissIntent>(
            onInvoke: (_) {
              widget.onDismiss?.call();
              return null;
            },
          ),
        },
        child: Builder(
          builder: (context) {
            final content = SizedBox(
              height: MiuixCommandPaletteDefaults.panelHeight(
                commandCount: visible.length,
                maxHeight: widget.maxHeight,
              ),
              child: Column(
                children: <Widget>[
                  MiuixTextField(
                    controller: _query,
                    focusNode: _searchFocus,
                    hint: widget.searchHint,
                    singleLine: true,
                    leadingIcon: MiuixThemedIcon(MiuixExtensionGlyphs.search),
                    trailingIcon: _query.text.isEmpty
                        ? null
                        : MiuixIconButton(
                            icon: MiuixThemedIcon(MiuixExtensionGlyphs.close),
                            tooltip: '清除搜索',
                            onPressed: () {
                              _query.clear();
                              _controller.setQuery('');
                            },
                          ),
                    onChanged: _controller.setQuery,
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: visible.isEmpty
                        ? Center(
                            child: Text(
                              widget.emptyMessage,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(color: colors.secondaryForeground),
                            ),
                          )
                        : ListView.builder(
                            controller: _resultsScroll,
                            primary: false,
                            padding: EdgeInsets.zero,
                            itemCount: visible.length,
                            itemBuilder: (context, index) =>
                                _commandRow(visible[index], index, colors),
                          ),
                  ),
                ],
              ),
            );
            final panel = widget._ownsPanelSurface
                ? MiuixSurface(
                    key: const ValueKey('miuix-command-palette-surface'),
                    radius: widget.cornerRadius.isFinite
                        ? widget.cornerRadius
                              .clamp(0.0, double.infinity)
                              .toDouble()
                        : hyperOs4.popupCornerRadius,
                    color:
                        widget.backgroundColor ?? semantic['surfaceContainer'],
                    glass: widget.glass,
                    glassBlur: widget.glassBlur ?? hyperOs4.popupBlur,
                    glassOpacity:
                        widget.glassOpacity ?? hyperOs4.popupTintOpacity,
                    glassOptics: MiuixGlassOptics.transient,
                    showGlassSpecular: widget.showGlassSpecular,
                    child: content,
                  )
                : content;
            if (reduceMotion) return panel;
            return AnimatedSize(
              alignment: Alignment.topCenter,
              duration: MiuixTheme.of(context).hyperOs4.inlineSurfaceMotion,
              curve: Curves.easeOutCubic,
              child: panel,
            );
          },
        ),
      ),
    );
  }
}

/// Wraps a subtree with the conventional Ctrl/Cmd+K palette shortcut.
class MiuixCommandPaletteShortcut extends StatelessWidget {
  const MiuixCommandPaletteShortcut({
    super.key,
    required this.child,
    required this.onOpen,
  });

  final Widget child;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.keyK, control: true):
            _OpenPaletteIntent(),
        SingleActivator(LogicalKeyboardKey.keyK, meta: true):
            _OpenPaletteIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _OpenPaletteIntent: CallbackAction<_OpenPaletteIntent>(
            onInvoke: (_) {
              onOpen();
              return null;
            },
          ),
        },
        child: Focus(autofocus: true, child: child),
      ),
    );
  }
}

class _PaletteMoveIntent extends Intent {
  const _PaletteMoveIntent(this.delta);
  final int delta;
}

class _PaletteBoundaryIntent extends Intent {
  const _PaletteBoundaryIntent(this.end);
  final bool end;
}

class _OpenPaletteIntent extends Intent {
  const _OpenPaletteIntent();
}
