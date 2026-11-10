import 'package:flutter/material.dart';

/// 弹窗的标题、摘要和正文共用滚动区，底部操作始终留在可见范围。
/// 长摘要不能占满固定头部，把输入区和确认操作挤到屏幕外。
/// children 使用自然高度的内容；独立的长列表应自行管理其视口。
class MiuixDialogScrollBody extends StatelessWidget {
  /// 放在 MiuixDialog 的 Flexible 内容槽中，由外层提供有限高度。
  const MiuixDialogScrollBody({
    super.key,
    // 原样保留组件身份、输入控制器和焦点，不重新创建内容。
    required this.children,
    this.footer,
    this.footerSpacing = 20,
  });

  /// 标题和摘要也放入此列表，不再成为滚动区外的无界固定头部。
  final List<Widget> children;

  /// 操作不跟随正文滚走，编辑很长的内容后仍能确认或取消。
  final Widget? footer;

  /// 间隔只在有操作时占位，纯说明弹窗不留空白。
  final double footerSpacing;

  @override
  Widget build(BuildContext context) => Column(
    // 短内容按实际高度收缩，不将普通确认框撑满整屏。
    mainAxisSize: MainAxisSize.min,
    // 正文与底栏共用宽度，窄屏无需额外居中或缩小文字。
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Flexible(
        // 标题与正文形成同一个连续阅读区，200% 字号也能读到末尾。
        child: SingleChildScrollView(
          // 单一视口使 ensureVisible 能定位末尾的输入和错误。
          child: Column(
            // 短说明按自然高度收缩，长内容才产生滚动范围。
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
            // 不限制原文行数，超出屏幕的部分保留在连续阅读区。
          ),
        ),
      ),
      if (footer case final actions?) ...[
        // 底栏保留原回调及启用状态，不将动作复制到另一棵组件树。
        // 操作先参与布局，滚动区只使用剩余的高度。
        SizedBox(height: footerSpacing),
        actions,
      ],
    ],
  );
}
