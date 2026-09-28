import 'package:decoy_wallet_app/utils/android_display_guard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final useIntrinsicHeight in [true, false]) {
    testWidgets(
        'safe scroll preserves height and scrolls ($useIntrinsicHeight)',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: DecoyBottomSafeScroll(
            useIntrinsicHeight: useIntrinsicHeight,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [SizedBox(height: 1200), Text('Bottom content')],
            ),
          ),
        ),
      ));
      final scroll = find.byType(DecoyBottomSafeScroll);
      expect(
          find.descendant(of: scroll, matching: find.byType(IntrinsicHeight)),
          useIntrinsicHeight ? findsOneWidget : findsNothing);
      await tester.ensureVisible(find.text('Bottom content'));
      await tester.pumpAndSettle();
      expect(find.text('Bottom content').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  test('safe scroll keeps intrinsic height enabled by default', () {
    expect(const DecoyBottomSafeScroll(child: SizedBox()).useIntrinsicHeight,
        isTrue);
  });

  test('adds Android bottom clearance when the OS reports no nav inset', () {
    const mediaQuery = MediaQueryData(
      padding: EdgeInsets.only(top: 24.0),
      viewPadding: EdgeInsets.only(top: 24.0),
    );

    final guarded = withDecoyDisplayGuard(
      mediaQuery,
      TargetPlatform.android,
    );

    expect(guarded.padding.bottom, kAndroidBottomActionClearance);
    expect(guarded.viewPadding.bottom, kAndroidBottomActionClearance);
  });

  test('keeps a larger Android nav inset reported by the device', () {
    const mediaQuery = MediaQueryData(
      padding: EdgeInsets.only(top: 24.0, bottom: 90.0),
      viewPadding: EdgeInsets.only(top: 24.0, bottom: 90.0),
    );

    final guarded = withDecoyDisplayGuard(
      mediaQuery,
      TargetPlatform.android,
    );

    expect(guarded.padding.bottom, 90.0);
    expect(guarded.viewPadding.bottom, 90.0);
  });

  test('does not add Android clearance on iOS', () {
    const mediaQuery = MediaQueryData(
      padding: EdgeInsets.only(top: 24.0),
      viewPadding: EdgeInsets.only(top: 24.0),
    );

    final guarded = withDecoyDisplayGuard(
      mediaQuery,
      TargetPlatform.iOS,
    );

    expect(guarded.padding.bottom, 0.0);
    expect(guarded.viewPadding.bottom, 0.0);
  });
}
