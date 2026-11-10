import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// 等宽、等高的一行内容，行高取当前内容所需的最大高度。
///
/// 用在纵向滚动页面中的并列卡片；父级必须提供有限宽度。
/// 子项先按列宽自然布局，再以同行最大高度重新布局。
/// 不使用固有尺寸查询，因此子项可以包含 LayoutBuilder。
/// 两次测量都在同一布局阶段完成，不会先显示短卡再跳高。
/// 子项应能接受最小高度，例如背景表面和普通 Column。
/// 本组件不提供固有尺寸；请勿放在 IntrinsicHeight 中。
/// 不在无界高度内使用 Expanded；长正文应自然换行。
/// 只统一当前行，不会把不同的行也拉成相同高度。
/// 父级若限定最大高度，必须给完整内容留够空间。
/// 本组件不会通过裁剪或省略号隐藏超出父级的正文。
/// 不主动改变子项的 padding、背景、圆角或语义标签。
/// 子项外边距也属于测量范围；需要齐边时采用一致外边距。
/// 对只改变自身而不接受最小高度的子项，应另包可扩展表面。
/// 字号、宽度、子项数量和正文变化均按当前内容重新计算。
/// 适合少量摘要卡片，不代替大量数据使用的懒加载列表。
/// 空行保留父级宽度，单项占满整行，不预留缺省列。
class MiuixEqualHeightRow extends MultiChildRenderObjectWidget {
  /// 保持传入顺序，方向由当前 Directionality 决定。
  const MiuixEqualHeightRow({
    super.key,
    required super.children,
    this.spacing = 16,
  }) : assert(spacing >= 0 && spacing < double.infinity);

  /// 列间距；极窄父级下只压缩间距，不产生负列宽。
  final double spacing;

  // 方向在构建时读取，继承环境变化会走后续参数更新。
  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderEqualHeightRow(spacing, Directionality.of(context));

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    // 参数更新参与正常布局失效，不缓存首帧或历史最高高度。
    // 公共接口保留 RenderObject 类型，不向调用方暴露私有渲染实现。
    (renderObject as _RenderEqualHeightRow).configure(
      spacing,
      Directionality.of(context),
    );
  }
}

// Flutter 的容器父数据基类是抽象类，专用类型同时约束兄弟链接。
class _EqualHeightParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderEqualHeightRow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _EqualHeightParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _EqualHeightParentData> {
  _RenderEqualHeightRow(this._spacing, this._direction);

  // 仅保存几何参数；测量结果不跨布局缓存。
  double _spacing;
  // 使用逻辑阅读顺序，避免 RTL 下数据与入口对调。
  TextDirection _direction;

  void configure(double spacing, TextDirection direction) {
    // 无变化不触发布局，主题单纯重绘不必重复测量。
    if (_spacing == spacing && _direction == direction) return;
    _spacing = spacing;
    _direction = direction;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    // 保存偏移和兄弟链接，绘制、命中测试使用同一坐标。
    if (child.parentData is! _EqualHeightParentData) {
      child.parentData = _EqualHeightParentData();
    }
  }

  @override
  void performLayout() {
    // 宽度来自布局约束，不读取屏幕尺寸，适用于分屏和桌面窗口。
    if (!constraints.hasBoundedWidth) {
      // 无界宽度无法定义等宽列；明确暴露父级约束错误。
      throw FlutterError('MiuixEqualHeightRow requires a bounded width.');
    }
    final width = constraints.maxWidth;
    if (childCount == 0) {
      // 空集合也遵守父级最小高度，避免未赋值的 RenderBox。
      size = constraints.constrain(Size(width, 0));
      return;
    }
    // 单项没有列间距，避免除以零或在尾部留出空列。
    final gap = childCount == 1
        ? 0.0
        : math.min(_spacing, width / (childCount - 1));
    // 间距先受可用宽度约束，列宽不会因窗口过窄而变为负数。
    final columnWidth = math.max(
      0.0,
      (width - gap * (childCount - 1)) / childCount,
    );
    // 列宽相同才能按真实换行比较高度，不能先测无限宽正文。
    final natural = BoxConstraints.tightFor(width: columnWidth);
    // 同时满足父级的最小高度要求，例如一行的最小触摸区域。
    var height = constraints.minHeight;
    var child = firstChild;
    while (child != null) {
      // 先解除旧行高，数据减少或字号变小时也能重新收缩。
      // parentUsesSize 保证异步子内容变化会重新测量整行。
      child.layout(natural, parentUsesSize: true);
      // 只合并高度，列宽始终由父级决定，长文字通过换行展开。
      height = math.max(height, child.size.height);
      child = childAfter(child);
    }
    // 不安排帧回调补高，当前帧绘制前已经有最终行尺寸。
    // 页面中的行应位于纵向滚动区，让长内容决定高度。
    // 若调用方显式限制最大高度，则仍遵守父级布局契约。
    height = constraints.constrainHeight(height);
    // 高度只约束下限，保留无界上限让子项的尺寸变化向上传递。
    // 若使用紧高度，Flutter 会把子项设为布局边界，异步更新将无法增高整行。
    // 下一次测量会重新解除下限，因此内容减少时也能收缩。
    final equal = BoxConstraints(
      minWidth: columnWidth,
      maxWidth: columnWidth,
      minHeight: height,
      // 上限保持开放，Column 不会意外扩展到父级的整屏高度。
      maxHeight: double.infinity,
    );
    var index = 0;
    // 第二次从首项遍历，首项不一定是较高内容。
    child = firstChild;
    while (child != null) {
      // 第二次直接约束背景表面，不能仅给外层占位盒补白。
      // 不重建子树，输入焦点、滚动状态和点击回调均保留。
      child.layout(equal, parentUsesSize: true);
      final data = child.parentData! as _EqualHeightParentData;
      final logicalX = index * (columnWidth + gap);
      // 翻转整列位置而非子树，文字自身的方向仍由继承环境控制。
      data.offset = Offset(
        _direction == TextDirection.ltr
            ? logicalX
            : width - columnWidth - logicalX,
        0,
      );
      index++;
      child = childAfter(child);
    }
    // 本行只取最大自然高度，后续行仍能独立保持紧凑。
    size = Size(width, height);
  }

  // 复用容器默认绘制顺序，保持子项的裁剪和手势区域完整。
  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  // 点击使用第二次布局后的真实卡片边界，包括补齐的底部。
  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
