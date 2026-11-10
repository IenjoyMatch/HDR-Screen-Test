import 'package:flutter/material.dart';

/// 已配对的强调色层次，供玻璃导航、选择和辅助表面共用。
/// 这里只运输绘制角色，不选择应用的主题来源或生成第二套莫奈方案。
class MiuixAccentLayers extends ThemeExtension<MiuixAccentLayers> {
  // 层次表不持有业务选择索引，只随主题快照更新。
  // 前景和衬底应一次替换，避免中间帧出现白字配浅底。
  // 镜片的透色与文字的清晰度是两个不同通道。
  // 面板实体遮罩不等于主题染色比例。
  // 显式组件参数仍优先，保留现有定制调用。
  // 没有扩展时沿原组件默认，不强制使用某一种取色算法。
  // 不保存 BuildContext，旧路由销毁后可以正常回收。
  // copyWith 只生成新快照，不能反向修改旧主题。
  // 同一份扩展可供底部、侧栏与分段控件共同读取。
  /// 所有角色须一起提供，避免半透明底色仍搭配实色按钮白字。
  MiuixAccentLayers({
    required Map<String, Color> colors,
    required this.navigationPanelOpacity,
  }) : colors = Map.unmodifiable(colors) {
    // 缺失角色直接暴露调用错误，不静默改用另一组默认色。
    for (final name in names) {
      if (!colors.containsKey(name)) {
        throw ArgumentError.value(name, 'colors', 'Missing accent layer');
      }
    }
  }

  /// 显示角色固定命名，动画只在同一角色之间插值。
  /// 这张表没有账号、偏好键或业务状态，库不负责缓存这些内容。
  static const names = [
    'accentForeground',
    'navigationFill',
    'navigationForeground',
    'selectionFill',
    'selectionForeground',
    'subtleFill',
    'subtleForeground',
    'outline',
    'textSelection',
    'inactiveTrack',
    'disabledFill',
    'disabledForeground',
  ];

  /// 不可变颜色快照，后续修改调用方原 Map 不会影响已经绘制的主题。
  final Map<String, Color> colors;

  /// 面板实体遮罩，与镜片色的 Alpha、真实背景模糊分别控制。
  final double navigationPanelOpacity;

  /// 宿主明确提供层次表时启用；没有扩展的旧 source 调用保持原语义。
  static MiuixAccentLayers? maybeOf(BuildContext context) =>
      Theme.of(context).extension<MiuixAccentLayers>();

  /// 透明导航镜片，后方内容仍可透过。
  Color get navigationFill => colors['navigationFill']!;

  /// 配对镜片的文字与图标，不能再施加镜片的透明度。
  Color get navigationForeground => colors['navigationForeground']!;

  /// 校准后的中性导航文字；旧调用未提供时仍由组件原语义方案承接。
  /// 可用的未选项不是禁用状态，不能额外叠加禁用透明度。
  Color? get navigationUnselectedForeground =>
      colors['navigationUnselectedForeground'];

  /// 普通选中项的轻染色表面，区别于完整主操作填充。
  Color get selectionFill => colors['selectionFill']!;

  /// 对选中表面校准的前景，不沿用 onPrimary。
  Color get selectionForeground => colors['selectionForeground']!;

  /// 非操作提示和图标底色，比选择状态更轻。
  Color get subtleFill => colors['subtleFill']!;

  /// 淡衬底的配对强调文字，保留独立前景层。
  Color get subtleForeground => colors['subtleForeground']!;

  /// 无填充文字操作使用的强调前景。
  Color get accentForeground => colors['accentForeground']!;

  /// 结构边界的弱强调，不代替输入焦点或错误语义。
  Color get outline => colors['outline']!;

  /// 正文选区覆盖色，原正文颜色仍由文本主题控制。
  Color get textSelection => colors['textSelection']!;

  /// 未完成轨道，仍可看出可操作的完整范围。
  Color get inactiveTrack => colors['inactiveTrack']!;

  /// 中性禁用表面，避免与可用主按钮混淆。
  Color get disabledFill => colors['disabledFill']!;

  /// 与禁用表面成对的文字，不复用亮色主按钮白字。
  Color get disabledForeground => colors['disabledForeground']!;

  @override
  // 覆盖绘制槽位时创建新快照，原主题实例保持不变。
  MiuixAccentLayers copyWith({
    Map<String, Color>? colors,
    double? navigationPanelOpacity,
  }) => MiuixAccentLayers(
    colors: {...this.colors, ...?colors},
    navigationPanelOpacity:
        navigationPanelOpacity ?? this.navigationPanelOpacity,
  );

  @override
  // 前景与衬底同时过渡，不把上一主题的白字留到新的淡底。
  MiuixAccentLayers lerp(covariant MiuixAccentLayers? other, double t) {
    if (other == null) return this;
    // 端点保留原 Color 子类和精确通道，不产生数值相同但类型不同的新颜色。
    if (t <= 0) return this;
    if (t >= 1) return other;
    // 使用 Flutter 的主题动画，不持有另外一套独立动画控制器。
    return MiuixAccentLayers(
      colors: {
        // 可选的新角色同样参与动画，不能在切换主题时短暂丢回旧灰字。
        // 可选角色缺少一端时保留已有色，不让导航文字从透明淡入。
        for (final name in {...colors.keys, ...other.colors.keys})
          name: Color.lerp(
            colors[name] ?? other.colors[name],
            other.colors[name] ?? colors[name],
            t,
          )!,
      },
      navigationPanelOpacity:
          navigationPanelOpacity +
          (other.navigationPanelOpacity - navigationPanelOpacity) * t,
    );
  }
}
