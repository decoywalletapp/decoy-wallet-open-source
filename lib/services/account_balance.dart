import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:synchronized/synchronized.dart';
import 'package:uuid/uuid.dart';

const accountBalancePilotEnabled =
    bool.fromEnvironment('DECOY_ACCOUNT_BALANCE_PILOT', defaultValue: false);

class BalanceSnapshot {
  const BalanceSnapshot(
      {this.sats = 0,
      this.seededAt,
      this.epoch,
      this.configuredSats,
      this.drainedAt,
      this.refilledFromEpoch});
  final int sats;
  final DateTime? seededAt;
  final String? epoch;
  final int? configuredSats;
  final DateTime? drainedAt;
  final String? refilledFromEpoch;

  bool needsSeed(DateTime now) =>
      seededAt == null ||
      (sats == 0 &&
          configuredSats != 0 &&
          drainedAt != null &&
          now.toUtc().difference(drainedAt!) >= const Duration(hours: 24));

  Map<String, dynamic> toJson() => {
        'sats': sats,
        'seeded_at': seededAt?.toUtc().toIso8601String(),
        'epoch': epoch,
        'configured_sats': configuredSats,
        'drained_at': drainedAt?.toUtc().toIso8601String(),
        'refilled_from_epoch': refilledFromEpoch,
      };

  factory BalanceSnapshot.fromJson(Map<String, dynamic> json) =>
      BalanceSnapshot(
        sats: (json['sats'] as num).toInt(),
        seededAt: DateTime.tryParse(json['seeded_at'] as String? ?? ''),
        epoch: json['epoch'] as String?,
        // Older pilot records cannot identify the original custom amount.
        // Preserve their remaining balance until the user configures it again.
        configuredSats: json.containsKey('configured_sats')
            ? (json['configured_sats'] as num?)?.toInt()
            : json['seeded_at'] != null
                ? (json['sats'] as num).toInt()
                : null,
        drainedAt: DateTime.tryParse(json['drained_at'] as String? ?? ''),
        refilledFromEpoch: json['refilled_from_epoch'] as String?,
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
    if (kind == 'seed' &&
        (!before.needsSeed(at) ||
            (before.epoch != null && before.epoch != expectedEpoch))) {
      return before;
    }
    if (kind == 'spend') {
      // An old offline spend must not drain a newly configured/reset balance.
      if (before.epoch == null ||
          before.epoch != expectedEpoch ||
          sats == 0 ||
          before.sats == 0) return before;
      final remaining = before.sats - sats;
      final drained = remaining <= feeSats + 1;
      return BalanceSnapshot(
          sats: drained ? 0 : remaining,
          seededAt: before.seededAt,
          epoch: before.epoch,
          configuredSats: before.configuredSats,
          drainedAt: drained ? at : null,
          refilledFromEpoch: before.refilledFromEpoch);
    }
    return BalanceSnapshot(
        sats: kind == 'seed' ? before.configuredSats ?? sats : sats,
        seededAt: at,
        epoch: id,
        configuredSats: kind == 'configure' ? sats : before.configuredSats,
        refilledFromEpoch: kind == 'seed' ? before.epoch : null);
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
  bool get hasInitializedBalance =>
      eligible == true && value.seededAt != null && value.epoch != null;
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
        await _initializeNewBalance(session);
      }
      while (_current(session) &&
          session.eligible == true &&
          session.pending.isNotEmpty) {
        final operation = session.pending.first;
        final result = await remote.apply(session.userId, operation);
        if (!_current(session)) return;
        await _accept(session, result, acknowledged: operation);
      }
    } catch (_) {
      // The durable per-account queue is retried on entry, resume, or next edit.
    }
  }

  Future<void> _initializeNewBalance(_BalanceSession session) =>
      session.lock.synchronized(() async {
        if (!_current(session) || session.eligible != true) return;
        final current = session.value;
        // Only a confirmed, never-initialized account gets an early default.
        // Refilling a drained balance remains exclusive to the PIN entry flow.
        if (current.sats != 0 ||
            current.epoch != null ||
            current.seededAt != null ||
            current.configuredSats != null ||
            current.drainedAt != null ||
            session.pending.isNotEmpty) return;
        final operation = BalanceOperation(
            id: const Uuid().v4(),
            kind: 'seed',
            sats: randomSats(),
            at: now().toUtc());
        final pending = [operation];
        await cache.write(session.userId, session.encode(pending: pending));
        if (!_current(session)) return;
        session.pending = pending;
        _notify();
      });

  Future<void> _accept(_BalanceSession session, BalanceReply reply,
          {BalanceOperation? acknowledged}) =>
      session.lock.synchronized(() async {
        if (!_current(session)) return;
        final snapshot = reply.snapshot;
        final sameRefill = acknowledged?.kind == 'seed' &&
            snapshot.epoch != null &&
            snapshot.epoch != acknowledged!.id &&
            snapshot.refilledFromEpoch == acknowledged.expectedEpoch &&
            (acknowledged.expectedEpoch != null ||
                snapshot.configuredSats == null);
        // Two phones can refill the same drained cycle. Rebase only sends from
        // that same refill, never sends predating a manual configuration.
        final pending = session.pending
            .where((op) => op.id != acknowledged?.id)
            .map((op) => sameRefill &&
                    op.kind == 'spend' &&
                    op.expectedEpoch == acknowledged.id
                ? BalanceOperation(
                    id: op.id,
                    kind: op.kind,
                    sats: op.sats,
                    feeSats: op.feeSats,
                    at: op.at,
                    expectedEpoch: snapshot.epoch)
                : op)
            .toList();
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
        if (kind == 'seed') {
          if (!session.value.needsSeed(now())) return true;
          // The server starts the cooldown when it accepts a drain. Do not
          // refill an unacknowledged offline drain ahead of that clock.
          if (session.value.seededAt != null && session.pending.isNotEmpty) {
            return true;
          }
        }
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
