import '../database.dart';

class RecoveryExchangeCodesTable
    extends SupabaseTable<RecoveryExchangeCodesRow> {
  @override
  String get tableName => 'recovery_exchange_codes';

  @override
  RecoveryExchangeCodesRow createRow(Map<String, dynamic> data) =>
      RecoveryExchangeCodesRow(data);
}

class RecoveryExchangeCodesRow extends SupabaseDataRow {
  RecoveryExchangeCodesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => RecoveryExchangeCodesTable();

  String get code => getField<String>('code')!;
  set code(String value) => setField<String>('code', value);

  String get accessToken => getField<String>('access_token')!;
  set accessToken(String value) => setField<String>('access_token', value);

  String get refreshToken => getField<String>('refresh_token')!;
  set refreshToken(String value) => setField<String>('refresh_token', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get usedAt => getField<DateTime>('used_at');
  set usedAt(DateTime? value) => setField<DateTime>('used_at', value);
}
