// HyperOS 4 file-drop-zone project contract.
//
// This contract documents MiuixFileDropZone's public-library behavior.
// Xiaomi does not publish a file-drop component specification or dp table.
// The visual values below are explicit project calibrations.
//
// ---------------------------------------------------------------------------
// Public constructors and ownership
// ---------------------------------------------------------------------------
//
// The unnamed constructor is the HyperOS 4 default presentation.
// The source constructor is the explicit former opaque presentation.
// Both constructors preserve the complete file validation API.
// Both constructors preserve native DropTarget integration.
// Both constructors preserve the host-injected picker fallback.
// Both constructors preserve caller-owned controller lifetime.
// Both constructors preserve default internally owned controller lifetime.
// Both constructors preserve custom builder content.
// Both constructors preserve accepted and rejected result callbacks.
// Both constructors preserve enabled and native-drop policies.
// The implementation remains in lib rather than the example application.
//
// ---------------------------------------------------------------------------
// HyperOS 4 material defaults
// ---------------------------------------------------------------------------
//
// The ordinary constructor enables glass by default.
// Its blur reads hyperOs4.inlineSurfaceBlur.
// Its tint reads hyperOs4.inlineSurfaceTintOpacity.
// Its corner reads hyperOs4.inlineSurfaceCornerRadius.
// Its autonomous state duration reads hyperOs4.inputStateMotion.
// Global enableGlass can still disable actual backdrop filtering.
// Global glassIntensity still scales blur and tint through MiuixGlass.
// The component does not define a second glass-intensity table.
// The default inline blur is a 20-sigma project calibration.
// The default inline tint is a 0.62 project calibration.
// The default inline corner is a 20dp project calibration.
// None of those values are described as unpublished Xiaomi constants.
// cornerRadius overrides only this component's geometry.
// glassBlur overrides only this component's requested blur.
// glassOpacity overrides only this component's standard tint input.
// showGlassSpecular independently controls the clipped edge reflection.
// glass false creates a solid surface with the same ordinary geometry.
// glass false does not imply source mode.
//
// ---------------------------------------------------------------------------
// Source presentation
// ---------------------------------------------------------------------------
//
// MiuixFileDropZone.source sets glass false.
// Source mode disables the glass specular edge.
// Source mode fixes the old project corner at 22dp.
// Source mode uses RoundedRectangleBorder rather than the G2 radius path.
// Source mode retains the same 176dp minimum height.
// Source mode retains the same 20dp content padding.
// Source mode retains validation, haptics, and controller behavior.
// Source mode retains the same input-state motion unless reduced.
// Source mode does not sample content behind its opaque panel.
// Source mode remains opt-in and is never selected by runtime fallback.
//
// ---------------------------------------------------------------------------
// Unified shape and paint order
// ---------------------------------------------------------------------------
//
// Fill, border, glass clipping, and pointer indication share one Surface.
// The former outer AnimatedContainer no longer owns a separate RRect border.
// The former inner MiuixSurface no longer owns a different G2 fill path.
// Ordinary mode supplies radius to MiuixSurface.
// Ordinary glass lets MiuixGlass own that radius-based clipped material.
// Ordinary solid mode lets MiuixSurface own the same radius-based G2 surface.
// Source mode supplies an explicit RoundedRectangleBorder shape.
// MiuixSurface paints BorderSide inside the effective resolved shape.
// Border paint therefore cannot extend beyond the glass or solid silhouette.
// Interactive indication uses the same effective shape.
// Content padding remains inside that shared interaction clip.
// The drop target never paints a full-window drag overlay.
// The drop target never paints beyond its own resolved outline.
// A zero corner override is valid for a custom rectangular ordinary surface.
// Negative, NaN, or infinite corner overrides use the inline token fallback.
//
// ---------------------------------------------------------------------------
// Drag-state animation
// ---------------------------------------------------------------------------
//
// Native drag entry sets the logical dragging state immediately.
// Native drag exit clears the logical dragging state immediately.
// TweenAnimationBuilder owns only autonomous visual interpolation.
// The tween endpoint is zero when no drag is inside the target.
// The tween endpoint is one while a drag is inside the target.
// Background interpolates from background to activeBackground.
// Border color interpolates from border to activeBorder.
// Border width interpolates from 1dp to 2dp.
// All three channels consume the same progress sample.
// The easing curve is easeOutCubic.
// Normal duration reads inputStateMotion.
// The default project duration is not represented as an official value.
// The motion key includes the current reduced-motion policy.
// A policy change discards any stale in-flight visual sample.
// Reduced motion uses Duration.zero.
// Reduced motion resolves background to its current logical endpoint.
// Reduced motion resolves border color to its current logical endpoint.
// Reduced motion resolves border width to exactly 1dp or 2dp.
// Reduced motion does not disable native drag event delivery.
// Reduced motion does not disable file validation or callbacks.
// Reduced motion does not disable haptic feedback.
//
// ---------------------------------------------------------------------------
// Native drop and picker convergence
// ---------------------------------------------------------------------------
//
// DropTarget remains enabled only when the widget is enabled.
// Native drop completion clears dragging and sets busy before wrapping files.
// Directory items skip byte-length lookup.
// Non-directory length lookup failures resolve to unknown length.
// Native file data remains lazy through DropItem.readAsBytes.
// Picker files and native files converge on _accept.
// A busy picker cannot start a second picker operation.
// Picker completion clears busy in a finally block while mounted.
// Disabled widgets do not invoke the host picker.
// Missing picker callbacks do not install a browse tap action.
// The complete surface is tappable when a picker callback exists.
// The browse button invokes that identical guarded picker method.
// Busy state disables the browse button and shows compact progress feedback.
// Native dragging text changes synchronously with logical drag state.
// Custom builders receive current dragging and accepted file state.
//
// ---------------------------------------------------------------------------
// Validation order
// ---------------------------------------------------------------------------
//
// Directory policy is checked before file-type policy.
// File-type policy is checked before size policy.
// Size policy is checked before maximum-count policy.
// Empty extension and MIME lists accept every file type.
// Extension checks are case insensitive.
// Extension checks accept authored values with or without a leading dot.
// MIME checks are case insensitive.
// MIME patterns ending in slash-star accept their complete type family.
// Exact MIME patterns require exact normalized equality.
// Extension and MIME allow-lists combine with logical OR.
// Unknown file length does not fabricate a too-large rejection.
// Directories are accepted only when allowDirectories is true.
// Existing controller files count against maximumFiles when append is true.
// Existing controller files do not count when append is false.
// Accepted and rejected lists preserve incoming order.
// Each rejected item exposes one machine-readable rejection reason.
// Accepted callback receives an unmodifiable list.
// Rejected callback receives an unmodifiable list.
//
// ---------------------------------------------------------------------------
// Controller publication
// ---------------------------------------------------------------------------
//
// append true adds accepted files to existing controller state.
// append false replaces controller state with accepted files.
// Rejected files are never inserted into controller state.
// Empty append operations publish no controller notification.
// setFiles replaces the complete mutable internal list.
// Public files expose an unmodifiable list view.
// removeAt removes exactly the requested accepted item.
// clear publishes only when state was nonempty.
// Widget-owned controllers are disposed with widget state.
// Caller-owned controllers are observed but never disposed by the widget.
// Controller replacement removes the old listener before attaching the new one.
// Controller changes rebuild custom and default content.
//
// ---------------------------------------------------------------------------
// Haptic roles
// ---------------------------------------------------------------------------
//
// Drag entry emits gestureThresholdActivate once per native entry callback.
// Drag exit emits no acceptance or confirmation feedback.
// A nonempty accepted collection emits confirm.
// A nonempty rejected collection emits gestureThresholdActivate.
// A mixed result emits both semantic roles once.
// Empty accepted and rejected collections emit no completion feedback.
// Disabled widgets emit no picker or drop-result feedback.
// Haptic delivery remains delegated to MiuixHaptics platform policy.
//
// ---------------------------------------------------------------------------
// Semantics and content
// ---------------------------------------------------------------------------
//
// The complete surface publishes the configured title as its label.
// The complete surface publishes selected file count as its value.
// The semantic button flag is present only when a picker callback exists.
// The semantic enabled state follows widget.enabled.
// Default content uses the package upload glyph rather than a Material fallback.
// Default title changes to release guidance during native drag.
// Default subtitle changes to accepted item count after selection.
// Foreground roles remain readable over ordinary glass and solid fallback.
// Active border and icon roles use the semantic primary channel.
// Error colors remain available to host-provided rejection presentation.
// Custom content remains inside the same semantic drop-zone container.
//
// ---------------------------------------------------------------------------
// Required regression evidence
// ---------------------------------------------------------------------------
//
// Ordinary default must expose glass true.
// Ordinary default radius must resolve to inlineSurfaceCornerRadius.
// Ordinary blur and opacity must resolve to inline material tokens.
// Ordinary idle border width must equal 1dp.
// A live drag at 100ms of a 777ms token must produce width between 1 and 2.
// Enabling reduced motion during that drag must produce width exactly 2dp.
// Solid ordinary override must preserve its explicit radius and border.
// Source must expose glass false and no specular edge.
// Source must expose a 22dp RoundedRectangleBorder.
// Picker validation must preserve accepted controller state and rejections.
// Four visual baselines must cover ordinary/source and light/dark modes.
// Every baseline must show both idle and active drag states.
// Ordinary baselines must show backdrop influence inside the clipped surface.
// Source baselines must remain opaque.
// Active baselines must show primary fill and thicker primary border.
// Full static analysis and the complete test suite must pass.
// Scope, comment-ratio, Android, Windows, and library gates must pass.
