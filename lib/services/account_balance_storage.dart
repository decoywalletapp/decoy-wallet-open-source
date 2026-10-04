import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'account_balance.dart';

class SecureBalanceCache implements BalanceCache {
  SecureBalanceCache(this.storage);
  final FlutterSecureStorage storage;

  String _key(String userId) => 'account_simulated_balance_v1_$userId';

  @override
  Future<String?> read(String userId) => storage.read(key: _key(userId));

  @override
  Future<void> write(String userId, String value) =>
      storage.write(key: _key(userId), value: value);
}

class SupabaseBalanceRemote implements BalanceRemote {
  SupabaseBalanceRemote(this.client);
  final SupabaseClient client;

  Future<BalanceReply> _request(String userId,
      {BalanceOperation? operation}) async {
    if (client.auth.currentUser?.id != userId) {
      throw StateError('Balance owner is no longer signed in');
    }
    final response = await client.rpc('account_simulated_balance_v2', params: {
      // Also checked against auth.uid() on the server to guard auth-switch races.
      'p_expected_user_id': userId,
      'p_operation': operation?.toJson(),
    }).timeout(const Duration(seconds: 4));
    final json = Map<String, dynamic>.from(response as Map);
    return BalanceReply(
        json['eligible'] == true,
        json['balance'] == null
            ? const BalanceSnapshot()
            : BalanceSnapshot.fromJson(
                Map<String, dynamic>.from(json['balance'])));
  }

  @override
  Future<BalanceReply> read(String userId) => _request(userId);

  @override
  Future<BalanceReply> apply(String userId, BalanceOperation operation) =>
      _request(userId, operation: operation);

  @override
  Future<BalanceReply> adopt(
      String userId, int sats, String operationId) async {
    if (client.auth.currentUser?.id != userId) {
      throw StateError('Balance owner is no longer signed in');
    }
    final response =
        await client.rpc('adopt_account_simulated_balance', params: {
      'p_expected_user_id': userId,
      'p_sats': sats,
      'p_operation_id': operationId,
    }).timeout(const Duration(seconds: 8));
    final json = Map<String, dynamic>.from(response as Map);
    return BalanceReply(json['eligible'] == true,
        BalanceSnapshot.fromJson(Map<String, dynamic>.from(json['balance'])));
  }
}
