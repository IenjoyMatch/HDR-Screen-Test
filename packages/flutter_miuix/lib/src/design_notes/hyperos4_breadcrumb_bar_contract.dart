// HyperOS 4 breadcrumb-bar implementation contract.
//
// This comment-only contract separates the new project-calibrated default
// from the existing source-parity path and records the evidence required for
// future changes to path navigation on Android, tablets, and Windows.
//
// Evidence boundary:
// - Xiaomi does not publish a breadcrumb metric table for HyperOS 4 apps.
// - Standard dimensions are calibrated from the shared design language.
// - They must never be described as unpublished official Xiaomi parameters.
// - The exact older MIUIX geometry remains attributable to the source path.
//
// Standard material hierarchy:
// - The complete path owns exactly one inline surface.
// - The surface clips blur, tint, reflection, and content to one silhouette.
// - Ordinary path segments remain transparent over the shared material.
// - Only the current path receives a semantic selected background.
// - Separators remain subordinate and never receive independent surfaces.
// - The bar does not blur each segment or resample the same scene repeatedly.
// - glass=false changes material, not the standard bar's spatial hierarchy.
//
// Standard token resolution:
// - Radius resolves from inlineSurfaceCornerRadius unless explicitly replaced.
// - Blur resolves from inlineSurfaceBlur unless explicitly replaced.
// - Tint resolves from inlineSurfaceTintOpacity unless explicitly replaced.
// - Edge reflection can be disabled independently from blur and tint.
// - Background color remains a semantic surface role in light and dark themes.
// - Segment foregrounds use secondary, selected, and disabled semantic roles.
//
// Standard project-calibrated geometry:
// - A visible segment is 36dp high.
// - Segment horizontal content padding is 12dp.
// - The default maximum segment width is 200dp.
// - The real pointer and accessibility target remains at least 48dp high.
// - The touch target overlaps visual inset instead of inflating path spacing.
// - Long labels ellipsize without changing separator or neighbor allocation.
//
// Source compatibility:
// - MiuixBreadcrumbBar.source owns no complete-bar material.
// - Every segment retains its former independently filled capsule.
// - Visible segment height remains 32dp.
// - Horizontal segment padding remains 10dp.
// - Maximum segment width remains 160dp.
// - Highlight weight remains the former medium role.
// - Scroll centering retains the source spring and physical-pixel truncation.
// - Existing interaction observers and nullable indication remain supported.
//
// Interaction:
// - The full segment target is clickable rather than only its text glyphs.
// - Standard selection changes emit one lightweight segment haptic.
// - Re-selecting the current segment does not emit a false change haptic.
// - Source mode does not invent haptics absent from the parity path.
// - Horizontal drag, touch scrolling, and mouse wheel remain viewport-owned.
// - User scrolling cancels an autonomous highlight-centering spring.
// - Disabled segments expose no tap action while scrolling remains available.
//
// Motion and accessibility:
// - Standard selected fill, foreground, and weight share one motion sample.
// - Retargeting begins from the currently visible sample.
// - Reduced motion replaces in-flight selection with the logical endpoint.
// - Reduced motion also jumps autonomous highlight centering to its endpoint.
// - Each segment remains a distinct semantic button with its path label.
// - Logical start ordering and separator direction follow text direction.
// - The selected visual state never changes the segment's measured width.
//
// Verification requirements:
// - Tests inspect standard inline token resolution and explicit solid override.
// - Tests prove source has no outer glass and retains 32/10/160 geometry.
// - Tests cover selection retargeting and reduced-motion replacement.
// - Existing source spring, scroll cancellation, RTL, and semantics stay green.
// - Light and dark goldens compare standard and source hierarchy directly.
// - Full static analysis, package tests, and release gates remain mandatory.
