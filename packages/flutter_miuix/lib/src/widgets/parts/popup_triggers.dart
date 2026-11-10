part of '../miuix_widgets.dart';

/// Builds a custom dropdown trigger from the menu lifecycle.
///
/// [onPressed] is null while the trigger is disabled. [expanded] stays true
/// until the popup's exit transition finishes, which lets source IconButtons
/// retain their hold-down indication for the complete popup lifecycle.
typedef MiuixDropdownTriggerBuilder =
    Widget Function(
      BuildContext context,
      VoidCallback? onPressed,
      bool expanded,
    );

/// Dropdown menu built from Miuix entries.
class MiuixDropdownMenuButton<T> extends StatefulWidget {
  /// Creates a dropdown menu button.
  const MiuixDropdownMenuButton({
    super.key,
    required this.entries,
    required this.onSelected,
    this.groups = const [],
    this.child,
    this.triggerBuilder,
    this.presentation = MiuixPopupPresentation.window,
    this.alignment = MiuixPopupAlignment.bottomEnd,
    this.positioning = MiuixPopupPositioning.dropdown,
    this.renderInRootScaffold = true,
    this.enabled = true,
    this.onExpandedChange,
    this.popupAnchorInsets = EdgeInsets.zero,
    this.popupAnchorOffset = Offset.zero,
    this.collapseOnSelection = true,
    this.allowMultipleSelection = false,
    this.popupMinWidth = 200,
    this.popupBuilder,
    this.canDismiss,
    this.cascadingController,
  });

  /// Menu entries.
  final List<MiuixDropdownEntry<T>> entries;

  /// Optional independent groups separated by source dividers.
  final List<MiuixDropdownGroup<T>> groups;

  /// Selection callback.
  final ValueChanged<T> onSelected;

  /// Legacy button child wrapped in the package's general pressable.
  final Widget? child;

  /// Optional source-aware trigger builder.
  ///
  /// Use this for MIUIX IconButton popup anchors. The returned widget owns its
  /// own press indication and semantics while this menu still owns expansion.
  final MiuixDropdownTriggerBuilder? triggerBuilder;

  /// Popup route family used by this trigger.
  final MiuixPopupPresentation presentation;

  /// Anchor alignment of the popup.
  final MiuixPopupAlignment alignment;

  /// Position-provider family matching MIUIX Dropdown or ContextMenu.
  final MiuixPopupPositioning positioning;

  /// Whether Overlay routes use the outermost scaffold.
  final bool renderInRootScaffold;

  /// Whether the trigger can open the menu.
  final bool enabled;

  /// Called when popup expansion starts or finishes.
  final ValueChanged<bool>? onExpandedChange;

  /// Insets removed from the trigger bounds when positioning the popup.
  ///
  /// This lets a source-compatible 48dp touch target retain a smaller 40dp
  /// visual popup anchor. The default keeps the full trigger bounds.
  final EdgeInsets popupAnchorInsets;

  /// Translation applied after resolving the visual trigger rectangle.
  ///
  /// Fractional-density source fixtures use this to preserve Compose's
  /// physical-pixel rounding without changing the trigger's layout or target.
  final Offset popupAnchorOffset;

  /// Whether selecting a row dismisses the popup.
  final bool collapseOnSelection;

  /// Whether more than one checked row may be retained in each group.
  final bool allowMultipleSelection;

  /// Source-clamped minimum popup width.
  final double popupMinWidth;

  /// Optional popup body used by source variants such as cascading menus.
  final Widget Function(ValueChanged<T> onSelected)? popupBuilder;

  /// Optional dynamic dismissal guard used by nested popup depth.
  final bool Function()? canDismiss;

  /// Optional navigation-depth channel for a custom cascading popup body.
  ///
  /// Ordinary dropdowns leave this null. Current cascading adapters supply the
  /// same controller to their popup body and host so predictive Back can freeze
  /// and animate the depth that owned the gesture.
  final MiuixCascadingPopupController? cascadingController;

  @override
  State<MiuixDropdownMenuButton<T>> createState() =>
      _MiuixDropdownMenuButtonState<T>();
}

class _MiuixDropdownMenuButtonState<T>
    extends State<MiuixDropdownMenuButton<T>> {
  // Open-menu ownership contract:
  //
  // - The trigger State owns exactly one active popup operation.
  // - _expanded prevents a second pointer or keyboard event opening another.
  // - The popup route lives outside this element's ordinary build subtree.
  // - Parent rebuilds therefore require an explicit revision notification.
  // - Revision is a signal only; the builder reads the current widget fields.
  // - Entries and groups are never captured as immutable opening snapshots.
  // - A replacement popupBuilder is also read from the current widget.
  // - allowMultipleSelection and minWidth update without closing the route.
  // - Selection dispatch reads the current onSelected callback at tap time.
  // - This prevents a new row from invoking the callback owner from an old frame.
  // - mounted protects callbacks when the trigger is removed with a popup open.
  // - didUpdateWidget compares collection identity per Flutter widget convention.
  // - Callers mutating a List in place must still rebuild with a new collection.
  // - Revision changes are deferred until the parent frame completes.
  // - Deferral prevents marking the Overlay dirty during its own build phase.
  // - Multiple changes in one frame collapse into one popup rebuild.
  // - The ValueNotifier is disposed with the trigger State.
  // - Popup builders stop listening automatically when route content unmounts.
  // - Anchor geometry is resolved separately through the trigger GlobalKey.
  // - Insets shrink or expand that rectangle before presentation routing.
  // - Both opening geometry and the live provider use the same resolver.
  // - Overlay and Window modes therefore see identical logical anchor bounds.
  // - LayerLink remains available for compositor-following fallback.
  // - Empty opening collections do not create a dismiss-only empty route.
  // - Collections that become empty while open may render the empty popup state.
  // - collapseOnSelection remains a host-level decision, not a content rebuild.
  // - The finally block publishes collapsed state after every dismissal path.
  // - External focus restoration is left to the host route or Overlay focus scope.
  // - Keyboard activation and pointer activation share this single openMenu path.
  // - Tests replace entries and callbacks while the route remains visible.
  // - Tests also verify outside dismissal returns focus to the trigger scope.
  final LayerLink _link = LayerLink();
  final GlobalKey _anchorKey = GlobalKey();
  final ValueNotifier<int> _popupRevision = ValueNotifier<int>(0);
  bool _expanded = false;
  bool _popupRefreshScheduled = false;

  @override
  void didUpdateWidget(covariant MiuixDropdownMenuButton<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_expanded || _popupRefreshScheduled) return;
    if (oldWidget.entries == widget.entries &&
        oldWidget.groups == widget.groups &&
        oldWidget.popupBuilder == widget.popupBuilder &&
        oldWidget.allowMultipleSelection == widget.allowMultipleSelection &&
        oldWidget.popupMinWidth == widget.popupMinWidth) {
      return;
    }
    // The route is outside this element's build subtree. Notify it after the
    // parent frame so a synchronous StatefulBuilder update cannot mark an
    // OverlayEntry dirty while that overlay is already building.
    _popupRefreshScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _popupRefreshScheduled = false;
      if (mounted && _expanded) _popupRevision.value++;
    });
  }

  @override
  void dispose() {
    _popupRevision.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> openMenu() async {
      if (!widget.enabled ||
          (widget.entries.isEmpty &&
              widget.groups.every((group) => group.entries.isEmpty)) ||
          _expanded) {
        return;
      }
      setState(() => _expanded = true);
      widget.onExpandedChange?.call(true);
      try {
        Rect? resolveAnchorRect() {
          final anchorContext = _anchorKey.currentContext;
          final triggerRect = anchorContext == null
              ? null
              : _miuixGlobalRect(anchorContext);
          if (triggerRect == null) return null;
          // EdgeInsets.deflateRect proportionally collapses oversized insets
          // instead of producing an inverted rectangle. First remove NaN and
          // infinity so a customized touch target cannot poison popup layout.
          final safeInsets = _miuixSafePopupAnchorInsets(
            widget.popupAnchorInsets,
          );
          return _miuixSafePopupAnchorRect(safeInsets.deflateRect(triggerRect));
        }

        final anchorRect = resolveAnchorRect();
        // The ValueListenableBuilder is deliberately constructed inside the
        // popup body rather than around the trigger. Revisions rebuild only the
        // detached route subtree and do not restart its visibility transition.
        // Reading widget below is safe while this State is mounted; dismissal
        // unmounts the listener before dispose releases the ValueNotifier.
        Widget buildLivePopup(ValueChanged<T> select) {
          return ValueListenableBuilder<int>(
            valueListenable: _popupRevision,
            builder: (context, revision, _) {
              final custom = widget.popupBuilder;
              return custom?.call(select) ??
                  MiuixListPopup<T>(
                    entries: widget.entries,
                    groups: widget.groups,
                    minWidth: widget.popupMinWidth,
                    allowMultipleSelection: widget.allowMultipleSelection,
                    onSelected: select,
                  );
            },
          );
        }

        await _showMiuixDropdownMenu<T>(
          context: context,
          entries: widget.entries,
          groups: widget.groups,
          onSelected: (value) {
            if (mounted) widget.onSelected(value);
          },
          popupBuilder: buildLivePopup,
          presentation: widget.presentation,
          link: _link,
          anchorRect: anchorRect,
          anchorRectProvider: resolveAnchorRect,
          alignment: widget.alignment,
          positioning: widget.positioning,
          renderInRootScaffold: widget.renderInRootScaffold,
          popupAnchorOffset: widget.popupAnchorOffset,
          closeOnSelection: widget.collapseOnSelection,
          allowMultipleSelection: widget.allowMultipleSelection,
          popupMinWidth: widget.popupMinWidth,
          canDismiss: widget.canDismiss,
          cascadingController: widget.cascadingController,
        );
      } finally {
        if (mounted) {
          setState(() => _expanded = false);
          widget.onExpandedChange?.call(false);
        }
      }
    }

    final canOpen =
        widget.enabled &&
        (widget.entries.isNotEmpty ||
            widget.groups.any((group) => group.entries.isNotEmpty));
    final triggerBuilder = widget.triggerBuilder;
    final trigger = triggerBuilder != null
        ? triggerBuilder(
            context,
            canOpen ? () => unawaited(openMenu()) : null,
            _expanded,
          )
        : MiuixPressable(
            onTap: canOpen ? () => unawaited(openMenu()) : null,
            feedbackType: MiuixPressFeedbackType.none,
            showIndication: canOpen,
            child: AnimatedOpacity(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 160),
              opacity: widget.enabled ? 1 : .38,
              child: widget.child ?? const SizedBox.shrink(),
            ),
          );
    return CompositedTransformTarget(
      link: _link,
      child: SizedBox(key: _anchorKey, child: trigger),
    );
  }
}

/// Overlay-named dropdown menu adapter.
class MiuixOverlayDropdownMenu<T> extends MiuixDropdownMenuButton<T> {
  /// Creates an overlay dropdown menu.
  const MiuixOverlayDropdownMenu({
    super.key,
    required super.entries,
    required super.onSelected,
    required super.child,
    super.groups,
    super.enabled,
    super.onExpandedChange,
    super.renderInRootScaffold,
    super.alignment,
    super.positioning,
    super.collapseOnSelection,
    super.allowMultipleSelection,
    super.popupMinWidth,
  }) : super(presentation: MiuixPopupPresentation.overlay);
}

/// Window-named dropdown menu adapter.
class MiuixWindowDropdownMenu<T> extends MiuixDropdownMenuButton<T> {
  /// Creates a window dropdown menu.
  const MiuixWindowDropdownMenu({
    super.key,
    required super.entries,
    required super.onSelected,
    required super.child,
    super.groups,
    super.enabled,
    super.onExpandedChange,
    super.alignment,
    super.positioning,
    super.collapseOnSelection,
    super.allowMultipleSelection,
    super.popupMinWidth,
  }) : super(presentation: MiuixPopupPresentation.window);
}

/// Icon-triggered dropdown menu.
class MiuixIconDropdownMenu<T> extends StatelessWidget {
  /// Creates an icon dropdown menu.
  const MiuixIconDropdownMenu({
    super.key,
    required this.icon,
    this.entries = const [],
    this.groups = const [],
    required this.onSelected,
    this.tooltip,
    this.presentation = MiuixPopupPresentation.window,
    this.enabled = true,
    this.onExpandedChange,
    this.renderInRootScaffold = true,
    this.alignment = MiuixPopupAlignment.bottomEnd,
    this.positioning = MiuixPopupPositioning.dropdown,
    this.collapseOnSelection = true,
    this.allowMultipleSelection = false,
    this.popupMinWidth = 200,
  });

  /// Trigger icon.
  final Widget icon;

  /// Optional trigger tooltip.
  final String? tooltip;

  /// Menu entries.
  final List<MiuixDropdownEntry<T>> entries;

  /// Optional independently selected groups.
  final List<MiuixDropdownGroup<T>> groups;

  /// Selection callback.
  final ValueChanged<T> onSelected;

  /// Popup route family used by this trigger.
  final MiuixPopupPresentation presentation;

  /// Whether the icon trigger can open the menu.
  final bool enabled;

  /// Called when popup expansion starts or finishes.
  final ValueChanged<bool>? onExpandedChange;

  /// Whether Overlay presentation uses the outermost Scaffold host.
  final bool renderInRootScaffold;

  /// Anchor alignment of the popup.
  final MiuixPopupAlignment alignment;

  /// Position-provider family used for the anchored popup.
  final MiuixPopupPositioning positioning;

  /// Whether a row selection closes the popup.
  final bool collapseOnSelection;

  /// Whether groups permit multiple simultaneous checks.
  final bool allowMultipleSelection;

  /// Minimum source popup width.
  final double popupMinWidth;

  @override
  Widget build(BuildContext context) {
    Widget menu = MiuixDropdownMenuButton<T>(
      entries: entries,
      groups: groups,
      onSelected: onSelected,
      presentation: presentation,
      enabled: enabled,
      onExpandedChange: onExpandedChange,
      renderInRootScaffold: renderInRootScaffold,
      alignment: alignment,
      positioning: positioning,
      collapseOnSelection: collapseOnSelection,
      allowMultipleSelection: allowMultipleSelection,
      popupMinWidth: popupMinWidth,
      triggerBuilder: (context, onPressed, expanded) => MiuixIconButton(
        onPressed: onPressed == null
            ? null
            : () {
                unawaited(MiuixHaptics.perform(MiuixHapticType.contextClick));
                onPressed();
              },
        enabled: enabled,
        holdDownState: expanded,
        child: IconTheme.merge(
          data: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
          child: icon,
        ),
      ),
    );
    final message = tooltip;
    if (message != null && message.isNotEmpty) {
      menu = MiuixTooltip(message: message, child: menu);
    }
    return menu;
  }
}

/// Overlay-named icon dropdown menu.
class MiuixOverlayIconDropdownMenu<T> extends MiuixIconDropdownMenu<T> {
  /// Creates an overlay icon dropdown menu.
  const MiuixOverlayIconDropdownMenu({
    super.key,
    required super.icon,
    super.entries,
    super.groups,
    required super.onSelected,
    super.tooltip,
    super.enabled,
    super.onExpandedChange,
    super.renderInRootScaffold,
    super.collapseOnSelection,
    super.allowMultipleSelection,
    super.popupMinWidth,
  }) : super(presentation: MiuixPopupPresentation.overlay);
}

/// Window-named icon dropdown menu.
class MiuixWindowIconDropdownMenu<T> extends MiuixIconDropdownMenu<T> {
  /// Creates a window icon dropdown menu.
  const MiuixWindowIconDropdownMenu({
    super.key,
    required super.icon,
    super.entries,
    super.groups,
    required super.onSelected,
    super.tooltip,
    super.enabled,
    super.onExpandedChange,
    super.collapseOnSelection,
    super.allowMultipleSelection,
    super.popupMinWidth,
  }) : super(presentation: MiuixPopupPresentation.window);
}
