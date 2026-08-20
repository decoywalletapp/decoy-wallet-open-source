import 'package:decoy_wallet_app/utils/android_display_guard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
