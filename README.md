# HDR Screen Test

Android 屏幕参数查询和 HDR 测试应用，采用 MIUIX 风格悬浮导航。

## 功能

- 查看当前显示分辨率、窗口尺寸、刷新率、密度和估算对角线，以及设备报告的 HDR 格式和亮度参数。
- Android 14 及以上提供 PQ 亮度阶梯、HLG 渐变和 PQ 面积色块测试信号；实际 HDR 输出取决于设备，信号值并不是实测亮度。
- 选择本地 HDR 视频，使用原生解码器和 SurfaceView 播放；白、黑、RGB 和灰色 SDR 辅助观察图案。
- 查看第三方开源许可证。

最低 Android 10（API 29），Compile SDK 和 Target SDK 36。首个 Alpha 使用调试签名，后续正式签名版本可能无法覆盖安装。HDR 相关功能尚未通过真机验证。

## 构建

需要 Flutter 3.44.1（或与本地 MIUIX 组件兼容的版本）、JDK 17、Android SDK 36、NDK 28.2.13676358、CMake 3.22.1，以及可访问 Gradle、Google Maven、Maven Central 和 pub 的网络。

```sh
flutter pub get
flutter analyze lib
flutter build apk --debug
```

应用自己的源码采用 [MIT License](LICENSE)。第三方 `flutter_miuix` 保留 [Apache 2.0 许可证](packages/flutter_miuix/LICENSE)，其他依赖的许可证可在应用内查看。详见 [第三方声明](THIRD_PARTY_NOTICES.md)。

