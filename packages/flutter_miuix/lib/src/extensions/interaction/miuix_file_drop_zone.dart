import '../../icons/miuix_icon_theme.dart';
import 'dart:collection';
import 'dart:typed_data';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';

import '../../platform/miuix_haptics.dart';
import '../../theme/miuix_semantic_colors.dart';
import '../../theme/miuix_theme.dart';
import '../../widgets/miuix_widgets.dart';
import '../miuix_extension_icons.dart';

/// Portable file metadata returned by [MiuixFileDropZone].
@immutable
class MiuixDroppedFile {
  /// Creates metadata supplied by a host file picker or another data source.
  const MiuixDroppedFile({
    required this.path,
    required this.name,
    this.mimeType,
    this.length,
    this.isDirectory = false,
    this.readBytes,
  });

  /// Platform path or opaque web URI and user-visible filename.
  final String path;
  final String name;
  final String? mimeType;
  final int? length;
  final bool isDirectory;

  /// Optional lazy byte loader. Directories normally leave this null.
  final Future<Uint8List> Function()? readBytes;

  /// Reads bytes or reports that this source exposed metadata only.
  Future<Uint8List> readAsBytes() {
    final loader = readBytes;
    if (loader == null) {
      return Future<Uint8List>.error(
        StateError('No byte loader is available for $name.'),
      );
    }
    return loader();
  }
}

/// Reason a dropped or selected file was rejected.
enum MiuixFileRejectionReason {
  unsupportedType,
  tooLarge,
  directoryNotAllowed,
  tooManyFiles,
}

/// Platform operation that failed before file validation could complete.
enum MiuixFileDropOperation { browse, nativeDrop }

/// Reports a current picker or native-drop failure to the host application.
typedef MiuixFileDropErrorCallback =
    void Function(
      MiuixFileDropOperation operation,
      Object error,
      StackTrace stackTrace,
    );

/// One rejected file and its machine-readable reason.
@immutable
class MiuixRejectedFile {
  const MiuixRejectedFile({required this.file, required this.reason});

  final MiuixDroppedFile file;
  final MiuixFileRejectionReason reason;
}

/// Hoisted accepted-file collection for a file drop zone.
class MiuixFileDropController extends ChangeNotifier {
  final List<MiuixDroppedFile> _files = <MiuixDroppedFile>[];

  /// Read-only accepted files in insertion order.
  List<MiuixDroppedFile> get files =>
      UnmodifiableListView<MiuixDroppedFile>(_files);

  /// Replaces, appends, removes, or clears accepted files.
  void setFiles(Iterable<MiuixDroppedFile> values) {
    _files
      ..clear()
      ..addAll(values);
    notifyListeners();
  }

  void addAll(Iterable<MiuixDroppedFile> values) {
    final next = List<MiuixDroppedFile>.of(values);
    if (next.isEmpty) return;
    _files.addAll(next);
    notifyListeners();
  }

  void removeAt(int index) {
    _files.removeAt(index);
    notifyListeners();
  }

  void clear() {
    if (_files.isEmpty) return;
    _files.clear();
    notifyListeners();
  }
}

/// Semantic palette for native file drop feedback.
@immutable
class MiuixFileDropZoneColors {
  const MiuixFileDropZoneColors({
    required this.background,
    required this.activeBackground,
    required this.border,
    required this.activeBorder,
    required this.foreground,
    required this.secondaryForeground,
    required this.error,
  });

  final Color background;
  final Color activeBackground;
  final Color border;
  final Color activeBorder;
  final Color foreground;
  final Color secondaryForeground;
  final Color error;
}

/// Geometry and color defaults for [MiuixFileDropZone].
abstract final class MiuixFileDropZoneDefaults {
  // HyperOS 4 file-drop implementation contract:
  // - Border, fill, glass clip, and indication share one continuous shape.
  // - The inline-surface token family owns that shape and material strength.
  // - Drag entry changes local state without adding a full-window overlay.
  // - Direct native drag feedback remains independent from autonomous motion.
  // - Reduced motion snaps border and fill to the current drag endpoint.
  // - Browse and native-drop paths share validation and controller publication.
  // - Accepted and rejected collections emit distinct semantic haptic roles.
  // - File count, size, directory, extension, and MIME limits remain deterministic.
  // - A busy picker cannot start a second concurrent picker operation.
  // - Caller-owned controllers survive widget replacement and disposal.
  // - Optional glass retains tint contrast over complex desktop content.
  // - The drop target never paints outside its own inline rounded rectangle.
  // These rules preserve Windows drag behavior and Android picker fallback.

  static const double minimumHeight = 176;
  static const double cornerRadius = 22;

  static MiuixFileDropZoneColors colors(BuildContext context) {
    final semantic = MiuixSemanticColors.of(context);
    return MiuixFileDropZoneColors(
      background: semantic['surfaceContainer'],
      activeBackground: semantic['primaryContainer'],
      border: semantic['dividerLine'],
      activeBorder: semantic['primary'],
      foreground: semantic['onSurface'],
      secondaryForeground: semantic['onSurfaceSecondary'],
      error: semantic['error'],
    );
  }
}

/// Native file drop surface with a host-injected picker fallback.
///
/// Windows, macOS, Linux, web, and preview Android drop events are received by
/// `desktop_drop`. Mobile applications can provide [onBrowseRequested] using
/// the picker and permission policy already chosen by the host app. Both paths
/// produce the same [MiuixDroppedFile] model and pass through identical limits.
class MiuixFileDropZone extends StatefulWidget {
  /// Creates a native drop target.
  const MiuixFileDropZone({
    super.key,
    this.controller,
    this.onFilesAccepted,
    this.onFilesRejected,
    this.onBrowseRequested,
    this.onError,
    this.acceptedExtensions = const <String>[],
    this.acceptedMimeTypes = const <String>[],
    this.maximumFiles,
    this.maximumBytes,
    this.allowDirectories = false,
    this.append = true,
    this.enabled = true,
    this.enableNativeDrop = true,
    this.title = '将文件拖到这里',
    this.subtitle = '或选择文件',
    this.browseLabel = '选择文件',
    this.icon,
    this.builder,
    this.minimumHeight = MiuixFileDropZoneDefaults.minimumHeight,
    this.cornerRadius,
    this.glass = true,
    this.glassBlur,
    this.glassOpacity,
    this.showGlassSpecular = true,
    this.colors,
  }) : _sourceStyle = false;

  /// Creates the former fixed-radius opaque file drop target.
  const MiuixFileDropZone.source({
    super.key,
    this.controller,
    this.onFilesAccepted,
    this.onFilesRejected,
    this.onBrowseRequested,
    this.onError,
    this.acceptedExtensions = const <String>[],
    this.acceptedMimeTypes = const <String>[],
    this.maximumFiles,
    this.maximumBytes,
    this.allowDirectories = false,
    this.append = true,
    this.enabled = true,
    this.enableNativeDrop = true,
    this.title = '将文件拖到这里',
    this.subtitle = '或选择文件',
    this.browseLabel = '选择文件',
    this.icon,
    this.builder,
    this.minimumHeight = MiuixFileDropZoneDefaults.minimumHeight,
    this.colors,
  }) : cornerRadius = MiuixFileDropZoneDefaults.cornerRadius,
       glass = false,
       glassBlur = null,
       glassOpacity = null,
       showGlassSpecular = false,
       _sourceStyle = true;

  final MiuixFileDropController? controller;

  /// Accepted and rejected result callbacks.
  final ValueChanged<List<MiuixDroppedFile>>? onFilesAccepted;
  final ValueChanged<List<MiuixRejectedFile>>? onFilesRejected;

  /// Host picker bridge used by Android and as a desktop alternative.
  final Future<List<MiuixDroppedFile>> Function()? onBrowseRequested;

  /// Receives current platform failures after the busy state is released.
  ///
  /// Stale failures from a replaced controller or configuration are ignored.
  /// Without a callback the failure is reported through [FlutterError].
  final MiuixFileDropErrorCallback? onError;

  /// Empty allow-lists accept every type. Extensions may include or omit '.'.
  final List<String> acceptedExtensions;
  final List<String> acceptedMimeTypes;

  /// Optional count and byte-size constraints.
  final int? maximumFiles;
  final int? maximumBytes;
  final bool allowDirectories;
  final bool append;
  final bool enabled;
  final bool enableNativeDrop;

  /// Default empty-state content.
  final String title;
  final String subtitle;
  final String browseLabel;
  final Widget? icon;

  /// Complete content override receiving drag state and accepted files.
  final Widget Function(
    BuildContext context,
    bool dragging,
    List<MiuixDroppedFile> files,
  )?
  builder;

  final double minimumHeight;
  final double? cornerRadius;
  final bool glass;
  final double? glassBlur;
  final double? glassOpacity;
  final bool showGlassSpecular;
  final MiuixFileDropZoneColors? colors;
  final bool _sourceStyle;

  @override
  State<MiuixFileDropZone> createState() => _MiuixFileDropZoneState();
}

class _MiuixFileDropZoneState extends State<MiuixFileDropZone> {
  late MiuixFileDropController _controller;
  late bool _ownsController;
  bool _dragging = false;
  bool _busy = false;
  // File-operation ownership contract:
  // - Browse and native drop share one mutation channel.
  // - At most one current generation may write controller files.
  // - Every accepted operation increments the generation before awaiting.
  // - Controller replacement revokes the previous generation immediately.
  // - Picker callback replacement also revokes the previous generation.
  // - Disabling the zone revokes work started while it was enabled.
  // - Revocation resets visual busy and drag state for the new widget contract.
  // - It does not attempt to cancel platform picker or native filesystem work.
  // - A stale success is ignored rather than applied to a newer controller.
  // - A stale validation result cannot call the newer acceptance callback.
  // - A stale rejection cannot call the newer rejection callback.
  // - A stale failure is absorbed because its initiating owner no longer exists.
  // - A current failure reaches the host callback or Flutter error reporting.
  // - Current failure cleanup always releases the busy state in `finally`.
  // - Native wrapping and picker completion follow the same generation rule.
  // - The busy guard prevents two native drops from racing each other.
  // - The busy guard also prevents browse from overlapping an active drop.
  // - Drop enter/leave visuals never grant permission to mutate file state.
  // Native-target availability contract:
  // - The native target is available only while the widget is enabled and idle.
  // - Busy is shared by picker work and native metadata wrapping.
  // - Starting either operation rebuilds the target with `enable` set to false.
  // - This prevents a second platform operation before its callbacks can fire.
  // - A callback captured from the previous build can still arrive afterward.
  // - Every native callback therefore checks current availability again.
  // - A stale enter callback cannot restore drag highlighting during picker work.
  // - A stale done callback cannot replace or append files during picker work.
  // - A rejected done callback clears any highlight left by an earlier enter.
  // - The clear is visual cleanup only and does not increment the generation.
  // - An exit callback may clear highlighting even after availability changed.
  // - Clearing an already-clear highlight is intentionally harmless.
  // - The target becomes available again only after the owning finally block.
  // - Completion callbacks observe the controller update before availability.
  // - Error callbacks observe the error before availability is restored visually.
  // - Both observations happen in one event-loop operation without a new request.
  // - Disabled widgets never emit drag-entry haptics from stale callbacks.
  // - Busy widgets likewise never emit a second drag-entry haptic.
  // - Reduced motion changes decoration timing but not target availability.
  // - Native enablement is independent from whether a picker bridge exists.
  // - Picker enablement is independent from whether native drop is supported.
  // - Both paths still share the same validation and publication transaction.
  // Operation-error ownership contract:
  // - Platform failures are distinct from validation rejections.
  // - Unsupported type, size, directory, and count remain rejection callbacks.
  // - Picker exceptions and native metadata failures use the error callback.
  // - The error callback receives the operation that produced the failure.
  // - It also receives the original object without wrapping or string conversion.
  // - The original stack trace is retained for application diagnostics.
  // - Hosts can map the operation to localized retry or explanation affordances.
  // - Hosts can present a snackbar without parsing platform exception messages.
  // - Replacing the error callback revokes work owned by the previous callback.
  // - A stale failure is not forwarded to either the old or the new callback.
  // - Disposing the widget likewise turns a late failure into a no-op.
  // - A current failure is reported exactly once for its generation.
  // - Accepted and rejected callbacks are not invoked for a failed operation.
  // - Haptic confirmation is not emitted for a failed operation.
  // - Busy cleanup remains in finally and runs even if host reporting throws.
  // - A throwing host callback remains the host's error and is not swallowed.
  // - Without a host callback FlutterError receives the original failure.
  // - FlutterError reporting includes the library and file-operation context.
  // - Default reporting avoids an unawaited Future rethrow from a tap callback.
  // - Default reporting remains visible to Flutter's normal diagnostics pipeline.
  // - Reporting never converts a failed operation into an empty successful batch.
  // - An actual empty picker result remains a successful no-change operation.
  // - Append mode keeps existing files after either kind of platform failure.
  // - Replace mode also keeps existing files because validation never began.
  // - Retry becomes available only after the failed generation releases busy.
  // - A retry receives a new generation and cannot be cleared by old cleanup.
  // - Native and browse errors follow the same lifecycle and cleanup ordering.
  // Publication ordering contract:
  // - Native metadata is fully wrapped before batch validation starts.
  // - Failure to wrap one item fails the platform operation as one batch.
  // - Partially wrapped items are never published beside an unwrapped failure.
  // - Validation still retains incoming order after wrapping succeeds.
  // - Controller mutation occurs before accepted and rejected host callbacks.
  // - Accepted callbacks receive only files committed in this operation.
  // - Rejected callbacks receive only files rejected in this operation.
  // - Each callback receives an unmodifiable snapshot of its result partition.
  // - A host mutation after callback return cannot alter those snapshots.
  // - Availability restoration occurs after all current publication callbacks.
  // - A synchronous rebuild from controller notification cannot start overlap.
  // - It sees busy true until the operation's finally block completes.
  // - A callback-triggered widget replacement increments the generation.
  // - The old finally block then cannot clear a newer operation's busy state.
  // - These ordering rules apply equally to source and HyperOS presentation.
  // - Glass, shape, and motion options never change file-operation ownership.
  // - Labels and icons may rebuild without invalidating an active operation.
  // - Validation constraints and publication callbacks always invalidate it.
  // - The explicit contract keeps visual state aligned with data ownership.
  // - Validation executes only after operation ownership is rechecked.
  // - Maximum-file accounting therefore observes one coherent controller.
  // - Append mode never combines a stale batch with a replacement controller.
  // - Replace mode never clears a new controller because an old picker returned.
  // - A widget disposal makes mounted false and blocks every completion write.
  // - External controllers remain caller-owned and are never disposed here.
  // - Private controllers retain the existing ownership behavior on replacement.
  // - Callback identity is checked at widget update, before the next build paints.
  // - The generation is monotonic only within one State lifetime, which is enough.
  // - Integer overflow is not practically reachable within a Flutter State life.
  // - File byte readers remain lazy and are not invoked during batch validation.
  // - Directory entries still bypass byte-length probing as before.
  // - MIME and extension checks remain pure and independent of operation tokens.
  // - Haptic feedback occurs only for the batch that actually commits.
  // - Tests replace both controller and picker while the first Future is pending.
  // - The stale result must leave both old and new controllers unchanged.
  // - A following fresh operation must still be enabled and commit normally.
  // - Merely resetting `_busy` would not prevent the stale `_accept` call.
  // - Merely checking mounted would not distinguish a reused State generation.
  // - Capturing the old controller would write stale data into an inactive owner.
  // - Applying to the new controller would corrupt the replacement's state.
  // - Generation comparison is therefore required at every asynchronous boundary.
  // Public configuration normalization contract:
  // - Release behavior cannot depend on constructor assertions being enabled.
  // - A non-positive file count resolves to one accepted file per collection.
  // - This fallback preserves a useful single-file picker instead of disabling it.
  // - A negative byte ceiling resolves to zero rather than becoming unlimited.
  // - An explicit zero byte ceiling remains valid for empty-file workflows.
  // - Unknown native lengths cannot be guessed and therefore remain admissible.
  // - Hosts may inspect or read those unknown-length files after acceptance.
  // - A non-finite minimum height resolves to the calibrated default height.
  // - A non-positive minimum height follows the same deterministic fallback.
  // - Layout never receives NaN, infinity, or a negative minimum constraint.
  // - Empty extension patterns carry no type information and never match.
  // - A lone period is likewise ignored rather than matching names ending in it.
  // - Extension matching trims surrounding configuration whitespace.
  // - Extension matching remains case-insensitive across desktop filesystems.
  // - MIME patterns trim whitespace before exact or wildcard comparison.
  // - Empty MIME patterns never turn a non-empty allow-list into allow-all.
  // - An entirely empty allow-list continues to mean that all types are allowed.
  // - A list containing only invalid patterns is an authored restrictive list.
  // - Therefore such a list rejects instead of silently becoming allow-all.
  // - Directory admission is evaluated before file type and byte constraints.
  // - Accepted directories may still be filtered by an authored type allow-list.
  // - Existing appended files consume the configured count before new candidates.
  // - Rejected candidates do not consume a slot needed by a later valid candidate.
  // - Input order is retained for both accepted and rejected result collections.
  // - Replace mode publishes an empty accepted list as a real controller clear.
  // - Append mode avoids notifying the controller when no file was accepted.
  // - Acceptance and rejection callbacks receive immutable result snapshots.
  // - Controller storage remains caller-readable but mutation stays controller-owned.
  // - Disabled visual state reaches the nested browse button as well as the shell.
  // - A disabled button cannot look actionable while `_browse` silently refuses it.
  // - Native DropTarget enablement mirrors the same effective enabled state.
  // - Turning native drop off invalidates a native operation already in flight.
  // - Changing only labels or decoration does not invalidate file operations.
  // - Changing validation values invalidates them before the next result commits.
  // - Changing publication callbacks also creates a new operation generation.
  // - Old callbacks are never invoked with data validated by a newer configuration.
  // - New callbacks are never invoked with data selected under an older contract.
  // - Callback identity comparison is intentional even for equivalent closures.
  // - List identity comparison assumes widget configuration lists are immutable.
  // - This follows Flutter's immutable-widget input convention for public fields.
  // - A busy indicator belongs only to the generation that currently owns work.
  // - Revocation clears that indicator without attempting platform cancellation.
  // - The next valid browse action may start immediately after configuration change.
  // - A stale `finally` block cannot clear the busy state of that newer action.
  // - Current platform errors remain observable instead of being swallowed globally.
  // - Errors from revoked owners are absorbed because no current caller owns them.
  // - Haptic confirmation remains tied to committed accepted or rejected batches.
  // - Geometry normalization changes layout safety, not filtering or callback order.
  // - These invariants apply equally to Android picker and desktop drag entry paths.
  int _operationGeneration = 0;

  int? get _effectiveMaximumFiles {
    final value = widget.maximumFiles;
    if (value == null) return null;
    return value > 0 ? value : 1;
  }

  int? get _effectiveMaximumBytes {
    final value = widget.maximumBytes;
    if (value == null) return null;
    return value >= 0 ? value : 0;
  }

  double get _effectiveMinimumHeight {
    final value = widget.minimumHeight;
    return value.isFinite && value > 0
        ? value
        : MiuixFileDropZoneDefaults.minimumHeight;
  }

  bool get _canAcceptNativeDrop => widget.enabled && !_busy;

  @override
  void initState() {
    super.initState();
    _attachController();
  }

  void _attachController() {
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? MiuixFileDropController();
    _controller.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(MiuixFileDropZone oldWidget) {
    super.didUpdateWidget(oldWidget);
    // An asynchronous selection is owned by the complete validation and
    // publication contract that started it. Applying a late batch through new
    // limits or new callbacks is just as stale as writing it to a new
    // controller, so every behavior-bearing field participates here.
    final operationChanged =
        oldWidget.controller != widget.controller ||
        oldWidget.onBrowseRequested != widget.onBrowseRequested ||
        oldWidget.onError != widget.onError ||
        oldWidget.onFilesAccepted != widget.onFilesAccepted ||
        oldWidget.onFilesRejected != widget.onFilesRejected ||
        oldWidget.acceptedExtensions != widget.acceptedExtensions ||
        oldWidget.acceptedMimeTypes != widget.acceptedMimeTypes ||
        oldWidget.maximumFiles != widget.maximumFiles ||
        oldWidget.maximumBytes != widget.maximumBytes ||
        oldWidget.allowDirectories != widget.allowDirectories ||
        oldWidget.append != widget.append ||
        oldWidget.enableNativeDrop != widget.enableNativeDrop ||
        (oldWidget.enabled && !widget.enabled);
    if (operationChanged) {
      // Results from a picker or native drop started under the old owner must
      // not be committed into a replacement controller or callback contract.
      _operationGeneration++;
      _busy = false;
      _dragging = false;
    }
    if (oldWidget.controller != widget.controller) {
      _controller.removeListener(_rebuild);
      if (_ownsController) _controller.dispose();
      _attachController();
    }
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  Future<MiuixDroppedFile> _wrapNative(DropItem item) async {
    int? length;
    if (item is! DropItemDirectory) {
      try {
        length = await item.length();
      } on Object {
        length = null;
      }
    }
    return MiuixDroppedFile(
      path: item.path,
      name: item.name,
      mimeType: item.mimeType,
      length: length,
      isDirectory: item is DropItemDirectory,
      readBytes: item is DropItemDirectory ? null : item.readAsBytes,
    );
  }

  bool _typeAllowed(MiuixDroppedFile file) {
    if (widget.acceptedExtensions.isEmpty && widget.acceptedMimeTypes.isEmpty) {
      return true;
    }
    final normalizedName = file.name.toLowerCase();
    final extensionAllowed = widget.acceptedExtensions.any((extension) {
      final normalized = extension.trim().toLowerCase();
      if (normalized.isEmpty || normalized == '.') return false;
      return normalizedName.endsWith(
        normalized.startsWith('.') ? normalized : '.$normalized',
      );
    });
    final mime = file.mimeType?.toLowerCase();
    final mimeAllowed =
        mime != null &&
        widget.acceptedMimeTypes.any((pattern) {
          final normalized = pattern.trim().toLowerCase();
          if (normalized.isEmpty) return false;
          if (normalized.endsWith('/*')) {
            return mime.startsWith(
              normalized.substring(0, normalized.length - 1),
            );
          }
          return mime == normalized;
        });
    return extensionAllowed || mimeAllowed;
  }

  void _accept(List<MiuixDroppedFile> incoming) {
    final accepted = <MiuixDroppedFile>[];
    final rejected = <MiuixRejectedFile>[];
    final existingCount = widget.append ? _controller.files.length : 0;
    final maximumFiles = _effectiveMaximumFiles;
    final maximumBytes = _effectiveMaximumBytes;
    for (final file in incoming) {
      MiuixFileRejectionReason? reason;
      if (file.isDirectory && !widget.allowDirectories) {
        reason = MiuixFileRejectionReason.directoryNotAllowed;
      } else if (!_typeAllowed(file)) {
        reason = MiuixFileRejectionReason.unsupportedType;
      } else if (maximumBytes != null &&
          file.length != null &&
          file.length! > maximumBytes) {
        reason = MiuixFileRejectionReason.tooLarge;
      } else if (maximumFiles != null &&
          existingCount + accepted.length >= maximumFiles) {
        reason = MiuixFileRejectionReason.tooManyFiles;
      }
      if (reason == null) {
        accepted.add(file);
      } else {
        rejected.add(MiuixRejectedFile(file: file, reason: reason));
      }
    }
    if (widget.append) {
      _controller.addAll(accepted);
    } else {
      _controller.setFiles(accepted);
    }
    if (accepted.isNotEmpty) {
      widget.onFilesAccepted?.call(
        List<MiuixDroppedFile>.unmodifiable(accepted),
      );
      MiuixHaptics.perform(MiuixHapticType.confirm);
    }
    if (rejected.isNotEmpty) {
      widget.onFilesRejected?.call(
        List<MiuixRejectedFile>.unmodifiable(rejected),
      );
      MiuixHaptics.perform(MiuixHapticType.gestureThresholdActivate);
    }
  }

  void _reportOperationError(
    MiuixFileDropOperation operation,
    Object error,
    StackTrace stackTrace,
  ) {
    final callback = widget.onError;
    if (callback != null) {
      callback(operation, error, stackTrace);
      return;
    }
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'flutter_miuix',
        context: ErrorDescription('while completing a file drop operation'),
      ),
    );
  }

  Future<void> _drop(DropDoneDetails details) async {
    if (!_canAcceptNativeDrop) {
      if (_dragging) setState(() => _dragging = false);
      return;
    }
    final generation = ++_operationGeneration;
    setState(() {
      _dragging = false;
      _busy = true;
    });
    try {
      final files = await Future.wait(details.files.map(_wrapNative));
      if (!mounted || generation != _operationGeneration) return;
      _accept(files);
    } catch (error, stackTrace) {
      // An invalidated native request belongs to an old widget generation and
      // must not surface an asynchronous error into its replacement owner.
      if (mounted && generation == _operationGeneration) {
        _reportOperationError(
          MiuixFileDropOperation.nativeDrop,
          error,
          stackTrace,
        );
      }
    } finally {
      if (mounted && generation == _operationGeneration) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _browse() async {
    final picker = widget.onBrowseRequested;
    if (!widget.enabled || picker == null || _busy) return;
    final generation = ++_operationGeneration;
    setState(() => _busy = true);
    try {
      final files = await picker();
      if (mounted && generation == _operationGeneration) _accept(files);
    } catch (error, stackTrace) {
      if (mounted && generation == _operationGeneration) {
        _reportOperationError(MiuixFileDropOperation.browse, error, stackTrace);
      }
    } finally {
      if (mounted && generation == _operationGeneration) {
        setState(() => _busy = false);
      }
    }
  }

  Widget _defaultContent(MiuixFileDropZoneColors colors) {
    final files = _controller.files;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        IconTheme(
          data: IconThemeData(
            color: _dragging ? colors.activeBorder : colors.foreground,
            size: 42,
          ),
          child: widget.icon ?? MiuixThemedIcon(MiuixExtensionGlyphs.upload),
        ),
        const SizedBox(height: 10),
        Text(
          _dragging ? '松开以添加文件' : widget.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: colors.foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          files.isEmpty ? widget.subtitle : '已选择 ${files.length} 个项目',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colors.secondaryForeground),
        ),
        if (widget.onBrowseRequested != null) ...<Widget>[
          const SizedBox(height: 12),
          MiuixButton(
            label: widget.browseLabel,
            onPressed: !widget.enabled || _busy ? null : _browse,
            icon: _busy
                ? const SizedBox.square(
                    dimension: 18,
                    child: MiuixInfiniteProgressIndicator(),
                  )
                : null,
          ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_rebuild);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors ?? MiuixFileDropZoneDefaults.colors(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final motion = hyperOs4.inputStateMotion;
    final radius = _dropZoneNonNegative(
      widget.cornerRadius,
      hyperOs4.inlineSurfaceCornerRadius,
    );
    final surface = Semantics(
      button: widget.onBrowseRequested != null,
      enabled: widget.enabled,
      label: widget.title,
      value: '已选择 ${_controller.files.length} 个项目',
      child: TweenAnimationBuilder<double>(
        key: ValueKey<Object>(('miuix-file-drop-motion', reduceMotion)),
        tween: Tween<double>(end: _dragging ? 1 : 0),
        duration: reduceMotion ? Duration.zero : motion,
        curve: Curves.easeOutCubic,
        builder: (context, progress, _) {
          final border = BorderSide(
            color: Color.lerp(colors.border, colors.activeBorder, progress)!,
            width: 1 + progress,
          );
          final background = Color.lerp(
            colors.background,
            colors.activeBackground,
            progress,
          )!;
          final sourceShape = widget._sourceStyle
              ? RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius),
                )
              : null;
          return ConstrainedBox(
            constraints: BoxConstraints(minHeight: _effectiveMinimumHeight),
            child: MiuixSurface(
              key: const ValueKey('miuix-file-drop-surface'),
              shape: sourceShape,
              radius: widget._sourceStyle ? null : radius,
              border: border,
              color: background,
              glass: widget.glass,
              glassBlur: widget.glassBlur ?? hyperOs4.inlineSurfaceBlur,
              glassOpacity:
                  widget.glassOpacity ?? hyperOs4.inlineSurfaceTintOpacity,
              showGlassSpecular: widget.showGlassSpecular,
              onTap: widget.onBrowseRequested == null ? null : _browse,
              enabled: widget.enabled,
              padding: const EdgeInsets.all(20),
              child:
                  widget.builder?.call(context, _dragging, _controller.files) ??
                  _defaultContent(colors),
            ),
          );
        },
      ),
    );
    if (!widget.enableNativeDrop) return surface;
    return DropTarget(
      enable: _canAcceptNativeDrop,
      onDragEntered: (_) {
        if (!_canAcceptNativeDrop) return;
        setState(() => _dragging = true);
        MiuixHaptics.perform(MiuixHapticType.gestureThresholdActivate);
      },
      onDragExited: (_) => setState(() => _dragging = false),
      onDragDone: _drop,
      child: surface,
    );
  }
}

double _dropZoneNonNegative(double? value, double fallback) =>
    value != null && value.isFinite && value >= 0 ? value : fallback;
