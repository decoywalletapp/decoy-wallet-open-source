import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:decoy_wallet_app/auth/unlock_diagnostics.dart';
import 'package:decoy_wallet_app/auth/app_unlock_state.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class PrivateTestDirectory extends PathProviderPlatform {
  PrivateTestDirectory(this.path);
  final String path;
  @override
  Future<String?> getApplicationSupportPath() async => path;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('disabled diagnostics never invoke storage', () async {
    var writes = 0;
    final trace = UnlockDiagnostics(
        enabled: false,
        write: (_) async {
          writes++;
        });
    trace.record(UnlockTraceEvent.pinPressed,
        error: StateError('secret PIN or token must not be stored'));
    await trace.flush();
    expect(writes, 0);
  });

  test('error values and foreign stack content never enter the record',
      () async {
    var output = '';
    final trace = UnlockDiagnostics(
        enabled: true,
        write: (value) async {
          output = value;
        });
    trace.record(UnlockTraceEvent.preparationFailed,
        error: PlatformException(code: 'secret-token', message: 'PIN=9876'),
        stack: StackTrace.fromString(
            '#0 secret-user@example.invalid (package:decoy_wallet_app/auth/app_unlock_state.dart:130:7)\n'
            '#1 https://private.invalid/?token=secret\n'
            '#2 secret-PIN=9876 (package:foreign/private.dart:4:2)'));
    await trace.flush();
    final event = (jsonDecode(output)['events'] as List).single;
    expect(event['failure'], 'platform');
    expect(event['locations'],
        ['package:decoy_wallet_app/auth/app_unlock_state.dart:130:7']);
    expect(output, isNot(contains('secret')));
    expect(output, isNot(contains('9876')));
    expect(output, isNot(contains('private.invalid')));
  });

  test('buffer and pending writes stay bounded during slow storage', () async {
    final blocked = Completer<void>();
    var writes = 0;
    var output = '';
    final trace = UnlockDiagnostics(
        enabled: true,
        write: (value) async {
          writes++;
          output = value;
          if (writes == 1) await blocked.future;
        });
    for (var index = 0; index < 1000; index++) {
      trace.record(UnlockTraceEvent.pinPrepared);
    }
    expect(writes, 1);
    blocked.complete();
    await trace.flush();
    final events = jsonDecode(output)['events'] as List;
    expect(events, hasLength(UnlockDiagnostics.maxEvents));
    expect(events.first['sequence'], 873);
    expect(events.last['sequence'], 1000);
    expect(writes, 2);
  });

  test('storage failure is contained and later events can be saved', () async {
    var fail = true;
    var output = '';
    final trace = UnlockDiagnostics(
        enabled: true,
        write: (value) async {
          if (fail) throw const FileSystemException('private path');
          output = value;
        });
    trace.record(UnlockTraceEvent.pinPressed);
    await trace.flush();
    fail = false;
    trace.record(UnlockTraceEvent.verificationFinished);
    await trace.flush();
    expect(jsonDecode(output)['events'], hasLength(2));
  });

  test('trace does not wait for disk before returning to unlock code',
      () async {
    final blocked = Completer<void>();
    final trace =
        UnlockDiagnostics(enabled: true, write: (_) => blocked.future);
    var continuationRan = false;
    trace.record(UnlockTraceEvent.decoyStarted);
    continuationRan = true;
    expect(continuationRan, isTrue);
    blocked.complete();
    await trace.flush();
  });

  test('test build writes only the bounded private diagnostic file', () async {
    final directory =
        await Directory.systemTemp.createTemp('decoy-unlock-trace-');
    final previous = PathProviderPlatform.instance;
    PathProviderPlatform.instance = PrivateTestDirectory(directory.path);
    try {
      final unlock = AppUnlockState()..bindUser('private-owner');
      unlock.preparePin(unlock.attempt, paidDecoyAllowed: true);
      final attempt = unlock.attempt!;
      expect(unlock.beginDecoy(attempt), isTrue);
      await expectLater(
          unlock.runDecoyPreparation(attempt, () async {
            throw PlatformException(
                code: 'private-code', message: 'secret PIN=9876');
          }),
          throwsA(isA<PlatformException>()));
      expect(unlock.ownerUnlocked, isFalse);
      expect(unlock.pinReady, isTrue);
      expect(unlock.allows(AppRouteAccess.owner), isFalse);
      expect(unlock.allows(AppRouteAccess.decoy), isFalse);
      unlockDiagnostics.record(UnlockTraceEvent.pinCreated);
      await unlockDiagnostics.flush();
      final files = await directory.list().toList();
      if (unlockDiagnosticsEnabled) {
        expect(files, hasLength(1));
        expect(files.single.path.endsWith('/unlock-diagnostics.json'), isTrue);
        final contents = await File(files.single.path).readAsString();
        final events = jsonDecode(contents)['events'] as List;
        expect(events.last['event'], 'pinCreated');
        expect(
            events.any((event) =>
                event['event'] == 'preparationFailed' &&
                event['failure'] == 'platform'),
            isTrue);
        expect(contents, isNot(contains('private-owner')));
        expect(contents, isNot(contains('private-code')));
        expect(contents, isNot(contains('9876')));
      } else {
        expect(files, isEmpty);
      }
    } finally {
      PathProviderPlatform.instance = previous;
      await directory.delete(recursive: true);
    }
  });
}
