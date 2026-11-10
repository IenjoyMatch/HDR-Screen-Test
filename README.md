# HDR Screen Test

一款采用 MIUIX 风格悬浮导航的 Android 屏幕检测应用。目前为 **v0.1.0-alpha.1**，最低支持 Android 10（API 29）。

## 功能

### 屏幕参数

在“屏幕”页面查看设备和显示器报告的信息：

- 当前分辨率、窗口逻辑尺寸和系统版本。
- 当前刷新率及设备支持的刷新率。
- 逻辑密度、X/Y 物理密度、估算屏幕对角线与广色域支持情况。
- 下拉刷新可重新读取数据。

显示参数由系统和厂商提供；物理密度及估算尺寸可能与产品规格或实测值不同。

### HDR 参数

在“HDR 测试”页面查看设备报告的 HDR 格式，以及期望峰值、最大帧平均和最低亮度。Android 14 及以上的部分设备还会显示当前 HDR/SDR 亮度比。没有报告的数据会显示“未提供”。

### HDR 测试图

Android 14 及以上支持以下测试图：

- **PQ 亮度阶梯**：观察不同亮度信号的层次和高光裁切。
- **HLG 渐变**：观察亮度过渡和渐变断层。
- **PQ 面积色块**：通过 `Area` 切换色块面积，通过 `Level` 切换亮度信号，观察不同条件下的表现。

使用 `Next` 切换图案，点击图案可隐藏或显示控制栏，使用 `Close` 或系统返回键退出。图上标注的亮度是目标信号值，不是仪器实测值；实际 HDR 输出取决于设备及系统显示链路。

### HDR 视频和 SDR 图案

- 选择设备上的 HDR 视频，通过 Android 原生解码器和 `SurfaceView` 播放；需要自行准备兼容的视频。
- 使用白、黑、RGB 和灰色全屏 **SDR** 图案观察坏点、均匀性和灰阶；点击切换图案。

## 下载与构建

从 [Releases](https://github.com/IenjoyMatch/HDR-Screen-Test/releases) 下载 Alpha APK。当前为调试签名包，不同构建或后续正式版本可能无法直接覆盖安装。

构建需要 Flutter 3.44.1、JDK 17、Android SDK 36、NDK 28.2 和 CMake 3.22.1：

```bash
flutter pub get
flutter analyze lib
flutter build apk --debug
```

Compile SDK 和 Target SDK 均为 36。HDR 功能尚未经过真机验证，不能替代专业仪器测量。

## 许可证

项目自身代码采用 [MIT License](LICENSE)。本地 `flutter_miuix` 组件使用 [Apache License 2.0](packages/flutter_miuix/LICENSE)；其他依赖遵循各自的许可，详见应用内的“开源许可证”和[第三方声明](THIRD_PARTY_NOTICES.md)。

