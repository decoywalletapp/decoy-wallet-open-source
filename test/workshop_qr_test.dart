import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:decoy_wallet_app/components/redemption_option_card.dart';
import 'package:decoy_wallet_app/components/workshop_qr_option_card.dart';
import 'package:decoy_wallet_app/l10n/app_localizations.dart';
import 'package:decoy_wallet_app/welcom_pages/subscription_options/subscription_options_widget.dart';
import 'package:decoy_wallet_app/workshop/workshop_claim_client.dart';
import 'package:decoy_wallet_app/workshop/workshop_qr_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'localization_fonts.dart';

final qr = 'decoy-workshop:v1:${List.filled(43, 'A').join()}';

Widget shell(Widget child) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      theme: ThemeData(fontFamily: 'robot', useMaterial3: false),
      home: child,
    );

Future<void> capture(WidgetTester tester, GlobalKey key, String name) async {
  if (!const bool.fromEnvironment('DECOY_CAPTURE_WORKSHOP')) return;
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final dir = Directory('/private/tmp/decoy-workshop-qr');
    await dir.create(recursive: true);
    await File('${dir.path}/$name.png')
        .writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await loadLocalizationFonts();
  });

  for (final width in [320.0, 402.0]) {
    testWidgets('fourth tile is separate, below Redeem Code at $width',
        (tester) async {
      tester.view.physicalSize = Size(width, 874);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final key = GlobalKey();
      await tester.pumpWidget(shell(
          RepaintBoundary(key: key, child: const SubscriptionOptionsWidget())));
      await tester.pumpAndSettle();
      final workshop = find.byType(WorkshopQrOptionCard);
      final redemption = find.byType(RedemptionOptionCard);
      expect(workshop, findsOneWidget);
      expect(redemption, findsOneWidget);
      expect(tester.getSize(workshop), tester.getSize(redemption));
      expect(tester.getSize(workshop).height, 260);
      expect(tester.getTopLeft(workshop).dy,
          greaterThan(tester.getBottomLeft(redemption).dy));
      expect(find.descendant(of: redemption, matching: workshop), findsNothing);
      await tester.ensureVisible(workshop);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await capture(tester, key, 'workshop-tile-${width.toInt()}');
    });
  }

  testWidgets('test QR recognizes camera result without any claim',
      (tester) async {
    var claims = 0;
    await tester.pumpWidget(shell(WorkshopQrPage(
      scan: () async => workshopPreviewQr,
      claim: (_) async {
        claims++;
        throw StateError('must not grant');
      },
    )));
    await tester.pumpAndSettle();
    expect(find.text('Test QR recognized'), findsOneWidget);
    expect(find.text('Preview only. No account access has changed.'),
        findsOneWidget);
    expect(claims, 0);
  });

  for (final width in [320.0, 402.0]) {
    testWidgets('billing confirmation needs a deliberate tap at $width',
        (tester) async {
      tester.view.physicalSize = Size(width, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var confirmed = 0;
      final key = GlobalKey();
      await tester.pumpWidget(shell(RepaintBoundary(
        key: key,
        child: WorkshopQrPage(
          scan: () async => qr,
          claim: (_) async => throw const WorkshopClaimException(
              WorkshopClaimFailure.billingConfirmationRequired),
          claimWithBillingConfirmation: (value) async {
            expect(value, qr);
            confirmed++;
            return WorkshopClaimReceipt(
                accessEndsAt: DateTime.utc(2126), alreadyClaimed: false);
          },
        ),
      )));
      await tester.pumpAndSettle();
      expect(find.text('Stop future card renewals?'), findsOneWidget);
      expect(find.text('Not now'), findsOneWidget);
      expect(confirmed, 0);
      expect(tester.takeException(), isNull);
      await capture(tester, key, 'workshop-billing-${width.toInt()}');
      await tester.tap(find.text('Claim access and stop renewals'));
      await tester.pumpAndSettle();
      expect(confirmed, 1);
      expect(find.text('Workshop access activated'), findsOneWidget);
    });
  }

  testWidgets('dismissing billing confirmation never cancels renewals',
      (tester) async {
    var confirmed = 0;
    await tester.pumpWidget(shell(WorkshopQrPage(
      scan: () async => qr,
      claim: (_) async => throw const WorkshopClaimException(
          WorkshopClaimFailure.billingConfirmationRequired),
      claimWithBillingConfirmation: (_) async {
        confirmed++;
        throw StateError('must not be called');
      },
    )));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    expect(confirmed, 0);
  });

  testWidgets('invalid code and cancel never call claim', (tester) async {
    var claims = 0;
    var scans = 0;
    await tester.pumpWidget(shell(WorkshopQrPage(
      scan: () async => scans++ == 0 ? 'https://attacker.invalid' : null,
      claim: (_) async {
        claims++;
        throw StateError('must not grant');
      },
    )));
    await tester.pumpAndSettle();
    expect(find.text('This is not a valid workshop QR.'), findsOneWidget);
    await tester.tap(find.text('Scan QR'));
    await tester.pumpAndSettle();
    expect(claims, 0);
    expect(find.text('This is not a valid workshop QR.'), findsNothing);
  });

  testWidgets('camera denied offers settings without a claim', (tester) async {
    var opened = 0;
    await tester.pumpWidget(shell(WorkshopQrPage(
      scan: () async => throw const WorkshopCameraDenied(),
      openSettings: () async {
        opened++;
        return true;
      },
      claim: (_) async => throw StateError('must not grant'),
    )));
    await tester.pumpAndSettle();
    expect(find.text('Camera access is off.'), findsOneWidget);
    await tester.tap(find.text('Open Settings'));
    await tester.pumpAndSettle();
    expect(opened, 1);
  });

  testWidgets('transient failure retries the same claim, then confirms access',
      (tester) async {
    var scans = 0;
    var claims = 0;
    await tester.pumpWidget(shell(WorkshopQrPage(
      scan: () async {
        scans++;
        return qr;
      },
      claim: (value) async {
        expect(value, qr);
        if (claims++ == 0) {
          throw const WorkshopClaimException(WorkshopClaimFailure.unavailable);
        }
        return WorkshopClaimReceipt(
            accessEndsAt: DateTime.utc(2126), alreadyClaimed: true);
      },
    )));
    await tester.pumpAndSettle();
    expect(find.text('Workshop access activated'), findsNothing);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Workshop access activated'), findsOneWidget);
    expect(scans, 1);
    expect(claims, 2);
  });

  testWidgets('closed campaign never shows a success or a retained retry',
      (tester) async {
    await tester.pumpWidget(shell(WorkshopQrPage(
      scan: () async => qr,
      claim: (_) async =>
          throw const WorkshopClaimException(WorkshopClaimFailure.closed),
    )));
    await tester.pumpAndSettle();
    expect(find.text('Workshop claims are closed.'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
    expect(find.text('Workshop access activated'), findsNothing);
  });

  testWidgets(
      'pending claim has no duplicate action; late completion after disposal is safe',
      (tester) async {
    final pending = Completer<WorkshopClaimReceipt>();
    var count = 0;
    await tester.pumpWidget(shell(WorkshopQrPage(
      scan: () async => qr,
      claim: (_) {
        count++;
        return pending.future;
      },
    )));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Confirming access'), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
    await tester.pumpWidget(const SizedBox());
    pending.complete(WorkshopClaimReceipt(
        accessEndsAt: DateTime.utc(2126), alreadyClaimed: false));
    await tester.pump();
    expect(count, 1);
    expect(tester.takeException(), isNull);
  });
}
