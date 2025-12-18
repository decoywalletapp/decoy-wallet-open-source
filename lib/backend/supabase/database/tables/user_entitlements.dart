import '../database.dart';

class UserEntitlementsTable extends SupabaseTable<UserEntitlementsRow> {
  @override
  String get tableName => 'user_entitlements';

  @override
  UserEntitlementsRow createRow(Map<String, dynamic> data) =>
      UserEntitlementsRow(data);
}

class UserEntitlementsRow extends SupabaseDataRow {
  UserEntitlementsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => UserEntitlementsTable();

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get entitlement => getField<String>('entitlement')!;
  set entitlement(String value) => setField<String>('entitlement', value);

  bool get isActive => getField<bool>('is_active')!;
  set isActive(bool value) => setField<bool>('is_active', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
