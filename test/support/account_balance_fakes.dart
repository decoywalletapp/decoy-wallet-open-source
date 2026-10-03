import 'dart:async';
import 'package:decoy_wallet_app/services/account_balance.dart';

class MemoryCache implements BalanceCache {
  final values = <String, String>{};
  bool fail = false;
  Completer<void>? blockNextWrite;
  @override
  Future<String?> read(String userId) async => values[userId];
  @override
  Future<void> write(String userId, String value) async {
    if (fail) throw StateError('storage unavailable');
    final blocked = blockNextWrite;
    blockNextWrite = null;
    if (blocked != null) await blocked.future;
    values[userId] = value;
  }
}

class MemoryRemote implements BalanceRemote {
  MemoryRemote({this.now});
  final DateTime Function()? now;
  final values = <String, BalanceSnapshot>{};
  final applied = <String>{};
  final users = {'a', 'b', 'c', 'd'};
  bool offline = false;
  bool loseNextReply = false;
  Completer<BalanceReply>? delayedRead;
  String? delayedUser;

  @override
  Future<BalanceReply> read(String userId) async {
    if (offline) throw StateError('offline');
    if (userId == delayedUser) return delayedRead!.future;
    return BalanceReply(
        users.contains(userId), values[userId] ?? const BalanceSnapshot());
  }

  @override
  Future<BalanceReply> apply(String userId, BalanceOperation operation) async {
    if (offline) throw StateError('offline');
    if (applied.add('$userId:${operation.id}')) {
      final received = BalanceOperation.fromJson({
        ...operation.toJson(),
        'at': (now?.call() ?? operation.at).toUtc().toIso8601String(),
      });
      values[userId] =
          received.apply(values[userId] ?? const BalanceSnapshot());
    }
    if (loseNextReply) {
      loseNextReply = false;
      throw StateError('response lost after commit');
    }
    return BalanceReply(true, values[userId]!);
  }
}
