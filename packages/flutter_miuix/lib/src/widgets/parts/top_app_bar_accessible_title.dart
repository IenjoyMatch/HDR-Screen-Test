part of '../miuix_widgets.dart';

// 大标题位于图标行下方，字体放大或换行时必须增加标题区高度。
// 不能只放大 Text 后继续使用 94dp，否则文字会压到返回按钮。
extension _MiuixAccessibleLargeTitle on MiuixTopAppBar {
  // 此处只扩展大标题区，不改变紧凑标题的既有碰撞算法。
  // 无效自定义内边距沿用组件默认值，避免测量出 NaN 宽度。
  // 系统非线性缩放通过 TextScaler 保留，不能简化成单一比例。
  // 正反阅读方向共用排版规则，文字宽度不随返回手势边缘变化。
  // 每次测量创建一个段落，不插入隐藏 Text 参与页面布局。
  // 字体角色自带行高必须计入，不能只用 fontSize 估计文字盒子。
  // largeTitle 可以与紧凑标题不同，测量对象须与展开绘制一致。
  // 短于正常单行的内容不会缩短标题栏，维持正常字号的视觉基线。
  // 副标题增长独立测量，不能拿主标题字号估计它的增量。
  // 页面语言与 Text 保持一致，用于中文字体回退和断行。
  // 增量随展开比例插值，不会在折叠时突然消失。
  // 相同增量交给滚动行程，避免正文滚动量与标题绘制分离。
  // 资源测量不涉及应用状态，只依赖当前视口、字体和标题配置。
  double _largeTitleExtra(BuildContext context) {
    if (!large) return 0;
    // 与绘制分支使用相同字体角色、字号和字重，避免测量与显示不一致。
    final style = Theme.of(context).textTheme.displaySmall?.copyWith(
      fontSize: 32,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    );
    final padding = titlePadding.isFinite ? math.max(0.0, titlePadding) : 26.0;
    // 分栏页面通过其 MediaQuery 提供局部宽度，与标题真实排版一致。
    final width = math.max(1.0, MediaQuery.sizeOf(context).width - padding * 2);
    final scaler = MediaQuery.textScalerOf(context);
    final direction = Directionality.of(context);
    // 基线为旧版正常字号单行高度，短标题的原有尺寸与像素位置保持一致。
    double height(
      String text,
      TextStyle? textStyle,
      TextScaler textScaler, {
      int? maxLines,
    }) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: textStyle),
        textDirection: direction,
        textScaler: textScaler,
        maxLines: maxLines,
        locale: Localizations.maybeLocaleOf(context),
      )..layout(maxWidth: width);
      final result = painter.height;
      // Paragraph 持有原生资源，不让每次滚动测量的临时对象积累。
      painter.dispose();
      return result;
    }

    final text = largeTitle ?? title;
    // 正常字号也考虑长标题自然换行，不能用省略号藏掉后半段。
    var extra = math.max(
      0.0,
      height(text, style, scaler) -
          height(text, style, TextScaler.noScaling, maxLines: 1),
    );
    if (_hasSubtitle) {
      // 兼容旧副标题参数，新增页面仍应只使用主标题。
      final supporting = Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );
      extra += math.max(
        0.0,
        height(subtitle!, supporting, scaler) -
            height(subtitle!, supporting, TextScaler.noScaling, maxLines: 1),
      );
    }
    // 扩展值仅影响展开区和折叠行程，不移动图标行的触摸与菜单锚点。
    return extra;
  }
}

// 小标题可显式采用完整阅读模式，正常短标题仍沿用既有碰撞布局。
// 仅在主标题实际溢出时增加下方区域，不改变图标、触摸范围或弹窗锚点。
extension _MiuixAccessibleSmallTitle on MiuixTopAppBar {
  // 样式入口同时供测量与绘制调用，不能一处20sp、另一处继承不同字号。
  // 颜色随主标题主题变化，行高、字重与绘制分支保持一致。
  // 这是显式的小标题阅读能力，不改变默认源布局的省略号契约。
  // 大标题沿用原有可访问扩展高度，不叠加第二套下方标题。
  // 正常字号短标题不额外留白，只有真实溢出才切换布局。
  // 已经选中的图标、Tooltip和Popup锚点仍位于原图标行。
  // 相同参数在Scaffold预留高度与组件绘制阶段各自可独立测量。
  // 不缓存第一次手机宽度，拖动独立窗口时直接采用当前MediaQuery。
  // 横向安全区在外层SafeArea消耗，测量也须同步扣除该宽度。
  // 无效padding沿用默认值，避免NaN进入TextPainter和Positioned。
  // leading与actions占位不对称，不能把较宽一侧镜像到另一侧来猜标题宽度。
  // actions数量与材质通过既有widthFor换算，保持可点击图标原本间距。
  // 原紧凑算法还使用90%最大宽度，内部左右26dp不能重复或遗漏扣除。
  // 标题测量以实际TextScaler为准，支持非线性字号缩放。
  // Locale与Directionality也进入TextPainter，中文断行和RTL不能共用猜测宽度。
  // 首次单行测量只检查是否能容纳，不用于绘制完整标题。
  // 单行高度高于原图标行时，即使水平能放下也需要独立阅读区。
  // 这是为了避免超大字号的上沿或下沿被原50dp高度裁掉。
  // 切换后标题取得图标行下方的完整宽度，自然换行而不缩小字体。
  // 全文高度返回给sourcePreferredSize，不能只让Text画出父级边界。
  // 下方标题不成为新的手势目标，原返回、刷新仍由原图标执行。
  // subtitle仅为兼容旧API，存在时按自己的14sp样式自然接在主标题之后。
  // 副标题测量不能直接套用20sp主标题行高。
  // 最终外层统一加入50dp图标行和8dp下边距，两处不能重复添加。
  // 所有临时Paragraph均及时dispose，窗口持续缩放不会积累原生排版资源。
  // 此方法无状态，也不会触发scrollBehavior通知或重建调用方页面。
  // 禁用选项或large=true时立即返回null，默认控件不会增加段落测量成本。
  // 在标准Flutter Scaffold直接使用时，调用方需用preferredSizeFor预留上下文高度。
  // MiuixScaffold已在tight约束建立前完成该上下文查询。
  // 宽度变化只影响标题区域高度，不改变公开回调、焦点或图标排序。
  // RTL通过既有相对定位完成，测量本身不手工交换图标。
  // 宽度最少保留一个逻辑像素，避免极端约束变成负宽度异常。
  // 该能力属于布局，不承担业务字符串裁剪或标题内容改写。
  // 样式默认值仍来自同一HyperOS主题，不新增另一个硬编码颜色表。
  TextStyle? _compactTitleTextStyle(BuildContext context) =>
      Theme.of(context).textTheme.titleLarge?.copyWith(
        color: titleColor ?? Theme.of(context).colorScheme.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      );

  double? _smallWrappedTitleHeight(BuildContext context) {
    if (large || !wrapSmallTitle) return null;
    // 使用实际窗口与安全区，而非全局设备宽度，跨屏缩放时会重新测量。
    final insets = defaultWindowInsetsPadding
        ? MediaQuery.paddingOf(context).horizontal
        : 0.0;
    final width = math.max(1.0, MediaQuery.sizeOf(context).width - insets);
    double padding(double value, double fallback) =>
        value.isFinite ? math.max(0.0, value) : fallback;
    // 与现有紧凑标题相同的非对称操作占位，避免只按两侧最大值猜测可用空间。
    final titleInset = padding(
      titlePadding,
      MiuixTopAppBarDefaults.titlePadding,
    );
    final leadingWidth = leading == null
        ? 0.0
        : 40 +
              padding(
                navigationIconPadding,
                MiuixTopAppBarDefaults.navigationIconPadding,
              );
    final count = actions?.length ?? 0;
    final actionWidth = count == 0
        ? 0.0
        : _MiuixTopBarActions.widthFor(count, actionStyle) +
              padding(
                actionIconPadding,
                MiuixTopAppBarDefaults.actionIconPadding,
              ) -
              4;
    final available = math.max(
      1.0,
      (width - leadingWidth - actionWidth) *
              MiuixTopAppBar.titleMaxWidthFraction -
          titleInset * 2,
    );
    final style = _compactTitleTextStyle(context);
    // 测量与实际Text共用字号、行高、方向、语言及非线性TextScaler。
    TextPainter paragraph(String text, TextStyle? style, {int? maxLines}) =>
        TextPainter(
          text: TextSpan(text: text, style: style),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
          locale: Localizations.maybeLocaleOf(context),
          maxLines: maxLines,
        );
    final single = paragraph(title, style, maxLines: 1)
      ..layout(maxWidth: available);
    final overflow =
        single.didExceedMaxLines ||
        single.height > MiuixTopAppBar.smallTopAppBarCenterHeight;
    single.dispose();
    if (!overflow) return null;
    // 溢出后使用图标行下方完整宽度，自然换行而非缩小字号或增加省略号。
    final fullWidth = math.max(1.0, width - titleInset * 2);
    final full = paragraph(title, style)..layout(maxWidth: fullWidth);
    var height = full.height;
    full.dispose();
    // subtitle仅为旧API兼容保留，启用完整模式时也不能裁掉已有文本。
    if (_hasSubtitle) {
      final supporting = paragraph(
        subtitle!,
        Theme.of(context).textTheme.bodyMedium?.copyWith(
          color:
              subtitleColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      )..layout(maxWidth: fullWidth);
      height += supporting.height;
      supporting.dispose();
    }
    // 返回正文实际高度，外层统一加入图标行与底部间距并交给Scaffold预留。
    return height;
  }
}
