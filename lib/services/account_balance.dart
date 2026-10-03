import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:synchronized/synchronized.dart';
import 'package:uuid/uuid.dart';

const accountBalancePilotEnabled =
    bool.fromEnvironment('DECOY_ACCOUNT_BALANCE_PILOT', defaultValue: false);

class BalanceSnapshot {
  const BalanceSnapshot({this.sats = 0, this.seededAt, this.epoch});
  final int sats;
  final DateTime? seededAt;
  final String? epoch;

  bool expired(DateTime now) =>
      seededAt == null ||
      now.toUtc().difference(seededAt!) >= const Duration(hours: 24);

  Map<String, dynamic> toJson() => {
        'sats': sats,
        'seeded_at': seededAt?.toUtc().toIso8601String(),
        'epoch': epoch,
      };

  factory BalanceSnapshot.fromJson(Map<String, dynamic> json) =>
      BalanceSnapshot(
        sats: (json['sats'] as num).toInt(),
        seededAt: DateTime.tryParse(json['seeded_at'] as String? ?? ''),
        epoch: json['epoch'] as String?,
      );
}

class BalanceOperation {
  const BalanceOperation(
      {required this.id,
      required this.kind,
      required this.sats,
      required this.at,
      this.feeSats = 0,
      this.expectedEpoch});
  final String id;
  final String kind;
  final int sats;
  final int feeSats;
  final DateTime at;
  final String? expectedEpoch;

  BalanceSnapshot apply(BalanceSnapshot before) {
    if (kind == 'seed' && !before.expired(at)) return before;
    if (kind == 'spend') {
      // An old offline spend must not drain a newly configured/reset balance.
      if (before.epoch != expectedEpoch) return before;
      final remaining = before.sats - sats;
      return BalanceSnapshot(
          sats: remaining <= feeSats + 1 ? 0 : remaining,
          seededAt: before.seededAt,
          epoch: before.epoch);
    }
    return BalanceSnapshot(sats: sats, seededAt: at, epoch: id);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind,
        'sats': sats,
        'fee_sats': feeSats,
        'at': at.toUtc().toIso8601String(),
        'expected_epoch': expectedEpoch,
      };

  factory BalanceOperation.fromJson(Map<String, dynamic> json) =>
      BalanceOperation(
        id: json['id'] as String,
        kind: json['kind'] as String,
        sats: (json['sats'] as num).toInt(),
        feeSats: (json['fee_sats'] as num).toInt(),
        at: DateTime.parse(json['at'] as String),
        expectedEpoch: json['expected_epoch'] as String?,
      );
}

class BalanceReply {
  const BalanceReply(this.eligible, this.snapshot);
  final bool eligible;
  final BalanceSnapshot snapshot;
}

abstract class BalanceRemote {
  Future<BalanceReply> read(String userId);
  Future<BalanceReply> apply(String userId, BalanceOperation operation);
}

abstract class BalanceCache {
  Future<String?> read(String userId);
  Future<void> write(String userId, String value);
}

class _BalanceSession {
  _BalanceSession(this.userId, this.lock);
  final String userId;
  final Lock lock;
  bool? eligible;
  BalanceSnapshot base = const BalanceSnapshot();
  List<BalanceOperation> pending = [];
  Future<void> ready = Future.value();
  Future<void>? syncing;

  BalanceSnapshot get value => pending.fold(base, (s, op) => op.apply(s));
  String encode(
          {BalanceSnapshot? base,
          List<BalanceOperation>? pending,
          bool? eligible}) =>
      jsonEncode({
        'eligible': eligible ?? this.eligible,
        'base': (base ?? this.base).toJson(),
        'pending': (pending ?? this.pending).map((op) => op.toJson()).toList(),
      });
}

/// Owns only simulated balance data; it never creates or refreshes auth sessions.
class AccountBalance extends ChangeNotifier {
  AccountBalance(
      {required this.remote,
      required this.cache,
      DateTime Function()? now,
      int Function()? randomSats})
      : now = now ?? DateTime.now,
        randomSats =
            randomSats ?? (() => 100000000 + Random().nextInt(400000001));

  final BalanceRemote remote;
  final BalanceCache cache;
  final DateTime Function() now;
  final int Function() randomSats;
  _BalanceSession? _session;
  final _cacheLocks = <String, Lock>{};
  bool _disposed = false;

  String? get userId => _session?.userId;
  bool? get eligible => _session?.eligible;
  BalanceSnapshot get value => _session?.value ?? const BalanceSnapshot();
  bool get hasPendingChanges => _session?.pending.isNotEmpty ?? false;

  Future<void> selectUser(String? userId) {
    if (userId == _session?.userId) return _session?.ready ?? Future.value();
    final session = userId == null
        ? null
        : _BalanceSession(userId, _cacheLocks.putIfAbsent(userId, Lock.new));
    _session = session;
    _notify(); // Clear the previous user's values before any asynchronous work.
    if (session == null) return Future.value();
    return session.ready = _load(session);
  }

  bool _current(_BalanceSession s) => !_disposed && identical(s, _session);
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> _load(_BalanceSession session) async {
    try {
      final raw =
          await session.lock.synchronized(() => cache.read(session.userId));
      if (!_current(session)) return;
      if (raw != null) {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        session.eligible = json['eligible'] as bool?;
        session.base = BalanceSnapshot.fromJson(json['base']);
        session.pending = (json['pending'] as List)
            .map((op) => BalanceOperation.fromJson(op))
            .toList();
        _notify();
      }
    } catch (_) {
      // Never fall back to the old device-wide value or another account's cache.
    }
    if (_current(session)) {
      if (session.eligible == true) {
        unawaited(_sync(session));
      } else {
        await _sync(session);
      }
    }
  }

  Future<void> refresh() async {
    final session = _session;
    if (session == null) return;
    await session.ready;
    if (_current(session)) await _sync(session);
  }

  Future<void> _sync(_BalanceSession session) {
    if (session.syncing != null) return session.syncing!;
    return session.syncing = _runSync(session).whenComplete(() {
      session.syncing = null;
    });
  }

  Future<void> _runSync(_BalanceSession session) async {
    try {
      // Flush durable operations before reading. A lost acknowledgement may
      // already be committed remotely; replaying it over a fresh read would
      // temporarily subtract twice while offline.
      if (session.pending.isEmpty || session.eligible != true) {
        final reply = await remote.read(session.userId);
        if (!_current(session)) return;
        await _accept(session, reply);
      }
      while (_current(session) &&
          session.eligible == true &&
          session.pending.isNotEmpty) {
        final operation = session.pending.first;
        final result = await remote.apply(session.userId, operation);
        if (!_current(session)) return;
        await _accept(session, result, acknowledgedId: operation.id);
      }
    } catch (_) {
      // The durable per-account queue is retried on entry, resume, or next edit.
    }
  }

  Future<void> _accept(_BalanceSession session, BalanceReply reply,
          {String? acknowledgedId}) =>
      session.lock.synchronized(() async {
        if (!_current(session)) return;
        final pending =
            session.pending.where((op) => op.id != acknowledgedId).toList();
        await cache.write(
            session.userId,
            session.encode(
                base: reply.snapshot,
                pending: pending,
                eligible: reply.eligible));
        if (!_current(session)) return;
        session.eligible = reply.eligible;
        session.base = reply.snapshot;
        session.pending = pending;
        _notify();
      });

  Future<bool> ensureSeeded() => _edit('seed', randomSats());
  Future<bool> configure(double btc) => _edit('configure', _sats(btc));
  Future<bool> spend(double grossBtc, double feeBtc) =>
      _edit('spend', _sats(grossBtc), feeSats: _sats(feeBtc));

  static int _sats(double btc) {
    if (!btc.isFinite || btc < 0 || btc > 21000000) {
      throw ArgumentError.value(btc, 'btc');
    }
    return (btc * 100000000).round();
  }

  Future<bool> _edit(String kind, int sats, {int feeSats = 0}) async {
    final session = _session;
    if (session == null) return false;
    await session.ready;
    if (!_current(session) || session.eligible != true) return false;
    try {
      final saved = await session.lock.synchronized(() async {
        if (!_current(session)) return false;
        if (kind == 'seed' && !session.value.expired(now())) return true;
        final operation = BalanceOperation(
            id: const Uuid().v4(),
            kind: kind,
            sats: sats,
            feeSats: feeSats,
            at: now().toUtc(),
            expectedEpoch: session.value.epoch);
        final pending = [...session.pending, operation];
        await cache.write(session.userId, session.encode(pending: pending));
        if (!_current(session)) return false;
        session.pending = pending;
        _notify();
        return true;
      });
      if (saved && _current(session)) unawaited(_sync(session));
      return saved;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _session = null;
    super.dispose();
  }
}
