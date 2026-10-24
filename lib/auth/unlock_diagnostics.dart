import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

enum UnlockTraceEvent {
  userChanged,
  locked,
  pinPrepared,
  decoyRejected,
  decoyStarted,
  decoyFinishRejected,
  decoyFinished,
  preparationFailed,
  pinCreated,
  pinDisposed,
  pinPressed,
  locationFinished,
  verificationStarted,
  verificationFinished,
  profileStarted,
  profileFinished,
  keyStarted,
  keyFinished,
  contactsDecrypted,
  personalDecrypted,
  consentStarted,
  consentFinished,
  consentHandled,
  balanceStarted,
  balanceFinished,
  pageDetached,
  navigationRequested,
  routeBlocked,
  routeError,
}

enum UnlockFailureKind {
  format,
  state,
  range,
  type,
  argument,
  timeout,
  platform,
  other
}

const unlockDiagnosticsEnabled =
    bool.fromEnvironment('DECOY_UNLOCK_DIAGNOSTICS', defaultValue: false);

Future<File>? _diagnosticFile;
Future<void> _writePrivateTrace(String content) async {
  late File file;
  try {
    file = await (_diagnosticFile ??= () async {
      final directory = await getApplicationSupportDirectory();
      await directory.create(recursive: true);
      return File('${directory.path}/unlock-diagnostics.json');
    }());
  } catch (_) {
    _diagnosticFile = null;
    rethrow;
  }
  final pending = File('${file.path}.tmp');
  await pending.writeAsString(content, flush: true);
  await pending.rename(file.path);
}

final unlockDiagnostics = UnlockDiagnostics(
  enabled: unlockDiagnosticsEnabled,
  write: _writePrivateTrace,
);

/// Test-build-only, bounded local breadcrumbs. No input values or identities.
class UnlockDiagnostics {
  UnlockDiagnostics({required this.enabled, required this.write});

  final bool enabled;
  final Future<void> Function(String) write;
  static const maxEvents = 128;
  final _events = <Map<String, Object>>[];
  final _clock = Stopwatch();
  int _sequence = 0;
  bool _dirty = false;
  Future<void>? _saving;

  void record(UnlockTraceEvent event, {Object? error, StackTrace? stack}) {
    if (!enabled) return;
    _clock.start();
    final row = <String, Object>{
      'sequence': ++_sequence,
      'elapsedMs': _clock.elapsedMilliseconds,
      'event': event.name,
    };
    if (error != null) {
      row['failure'] = _failure(error).name;
      // Extract only source locations, never exception messages or arguments.
      final locations = RegExp(
        r'package:decoy_wallet_app/[a-zA-Z0-9_/.]+\.dart:[0-9]+(?::[0-9]+)?',
      )
          .allMatches(stack?.toString() ?? '')
          .take(6)
          .map((match) => match.group(0)!)
          .toList();
      if (locations.isNotEmpty) row['locations'] = locations;
    }
    _events.add(row);
    if (_events.length > maxEvents) _events.removeAt(0);
    _dirty = true;
    _scheduleSave();
  }

  void _scheduleSave() {
    _saving ??= _save().whenComplete(() {
      _saving = null;
      if (_dirty) _scheduleSave();
    });
  }

  Future<void> _save() async {
    while (_dirty) {
      _dirty = false;
      final content = jsonEncode({'schema': 1, 'events': _events});
      try {
        await write(content);
      } catch (_) {
        // A diagnostic storage failure must never change unlock behavior.
      }
    }
  }

  Future<void> flush() async {
    while (_saving != null) {
      await _saving;
    }
  }

  static UnlockFailureKind _failure(Object error) {
    if (error is FormatException) return UnlockFailureKind.format;
    if (error is RangeError) return UnlockFailureKind.range;
    if (error is StateError) return UnlockFailureKind.state;
    if (error is TypeError) return UnlockFailureKind.type;
    if (error is ArgumentError) return UnlockFailureKind.argument;
    if (error is TimeoutException) return UnlockFailureKind.timeout;
    if (error is PlatformException) return UnlockFailureKind.platform;
    return UnlockFailureKind.other;
  }
}
