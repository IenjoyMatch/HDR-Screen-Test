import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_miuix/flutter_miuix.dart';
import 'package:hdr_screen_test/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('hdr_screen_test/display');
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          channel,
          (call) async => <String, Object>{
            'api': 36,
            'device': 'Test phone',
            'android': '16',
            'width': 1080,
            'height': 2400,
            'density': 420,
            'widthDp': 411,
            'heightDp': 900,
            'hdrTypes': <String>['HDR10'],
            'rates': <double>[60, 120],
          },
        );
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  testWidgets('opaque compact top bar keeps scroll content below it', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
    final bar = tester.widget<MiuixTopAppBar>(find.byType(MiuixTopAppBar));
    expect(bar.glass, isFalse);
    expect(bar.large, isFalse);
    final bottom = tester.getBottomLeft(find.text('HDR Screen Test')).dy;
    final contentTop = tester.getTopLeft(find.text('了解你的屏幕')).dy;
    expect(contentTop, greaterThan(bottom));
  });

  testWidgets('selection is evenly inset inside the capsule at both ends', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
    final surface = find.byKey(const ValueKey('floating-navigation-surface'));
    final indicator = find.byKey(
      const ValueKey('floating-navigation-selection-indicator'),
    );
    void expectAligned(bool left) {
      final outer = tester.getRect(surface);
      final inner = tester.getRect(indicator);
      final edge = left ? inner.left - outer.left : outer.right - inner.right;
      expect(edge, closeTo(inner.top - outer.top, 1));
      expect(edge, closeTo(outer.bottom - inner.bottom, 1));
      final box = tester.widget<DecoratedBox>(
        find
            .descendant(of: indicator, matching: find.byType(DecoratedBox))
            .first,
      );
      expect(
        (box.decoration as ShapeDecoration).shape,
        isA<MiuixCapsuleBorder>(),
      );
      final glass = tester.widget<MiuixGlass>(
        find.descendant(of: surface, matching: find.byType(MiuixGlass)).first,
      );
      expect(glass.shape, isA<MiuixCapsuleBorder>());
    }

    expectAligned(true);
    await tester.tap(find.text('HDR 测试').last);
    await tester.pumpAndSettle();
    expectAligned(false);
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpAndSettle();
    expectAligned(false);
    await tester.tap(find.text('屏幕').last);
    await tester.pumpAndSettle();
    expectAligned(true);
  });
}

