import 'package:flutter/widgets.dart';

/// 在已保留的隐藏页中冻结视口，避免其他页面的标题栏或键盘改动反复排版。
/// 此组件不隐藏页面；调用者仍需用 IndexedStack 或 Offstage 控制可见性。
/// 业务数据更新不由这里缓存，恢复可见时立即使用当前窗口约束。
class MiuixRetainedViewport extends StatefulWidget {
  const MiuixRetainedViewport({
    super.key,
    required this.active,
    required this.child,
  });

  // active 代表当前页正在展示，不能用是否已经访问过代替。
  final bool active;
  // 子树的 State 和控制器归调用方所有，此处不创建或销毁它们。
  final Widget child;

  @override
  State<MiuixRetainedViewport> createState() => _MiuixRetainedViewportState();
}

class _MiuixRetainedViewportState extends State<MiuixRetainedViewport> {
  // 只保存当前组件的窗口尺寸，不保存全局屏幕或页面业务状态。
  Size? _viewport;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      // 无界滚动容器不能展开为无限尺寸；这种用法沿原来的自然布局。
      // 清除旧尺寸，下一次回到有界窗口时重新采样。
      if (!constraints.hasBoundedWidth || !constraints.hasBoundedHeight) {
        _viewport = null;
        return widget.child;
      }
      // 首次挂载仍需建立布局；隐藏之后保留最后一次可见时的视口。
      // 窗口旋转、分屏或键盘变化等到该页再次可见时一次应用。
      if (widget.active || _viewport == null) {
        _viewport = constraints.biggest;
      }
      // 外层接受当前窗口约束，内层保持已保存的精确宽高。
      // Flutter 可据此复用隐藏列表的布局，不触发滚动位置纠正。
      // 不使用缩放、裁剪或固定设计尺寸，活动页仍按实际窗口布局。
      // 滚动位置依然由原 ScrollPosition 管理，不在恢复后再执行 jumpTo。
      return OverflowBox(
        alignment: AlignmentDirectional.topStart,
        minWidth: _viewport!.width,
        maxWidth: _viewport!.width,
        minHeight: _viewport!.height,
        maxHeight: _viewport!.height,
        child: widget.child,
      );
    },
  );
}
