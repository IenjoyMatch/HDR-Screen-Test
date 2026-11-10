/// Public entry point for the flutter_miuix package.
///
/// Applications should normally import this file. The implementation stays
/// split into focused source files so the public API remains convenient while
/// the component library remains maintainable.
library flutter_miuix;

export 'src/adapters/miuix_source_adapters.dart';
export 'src/effects/miuix_effects.dart';
export 'src/effects/miuix_foreground_blur.dart';
export 'src/extensions/miuix_extensions.dart';
export 'src/icons/miuix_extended_icons.dart';
export 'src/icons/miuix_basic_icons.g.dart';
export 'src/platform/miuix_accessibility.dart';
export 'src/platform/miuix_device_tilt.dart';
export 'src/platform/miuix_haptics.dart';
export 'src/platform/miuix_platform.dart';
export 'src/platform/miuix_window_insets.dart';
export 'src/theme/miuix_semantic_colors.dart';
// 宿主可提供成对的层次，通用控件不各自猜测透明度与白字。
export 'src/theme/miuix_accent_layers.dart';
export 'src/theme/hyperos4_tokens.dart';
export 'src/theme/miuix_theme.dart';
export 'src/widgets/miuix_widgets.dart';
// 长标题与正文共用视口，应用不再维护另一份固定头部弹窗布局。
export 'src/widgets/miuix_dialog_scroll_body.dart';
// 保留页复用最后可见视口，避免背景页面跟着前台页面重复排版。
export 'src/widgets/miuix_retained_viewport.dart';

export 'src/icons/miuix_icon_theme.dart';
export 'src/icons/miuix_icon_interaction.dart';

export 'src/theme/miuix_surface_theme.dart';
