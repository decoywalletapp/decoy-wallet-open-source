import '../database.dart';

class UserConsentsTable extends SupabaseTable<UserConsentsRow> {
  @override
  String get tableName => 'user_consents';

  @override
  UserConsentsRow createRow(Map<String, dynamic> data) => UserConsentsRow(data);
}

class UserConsentsRow extends SupabaseDataRow {
  UserConsentsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => UserConsentsTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get feature => getField<String>('feature');
  set feature(String? value) => setField<String>('feature', value);

  String? get consentVersion => getField<String>('consent_version');
  set consentVersion(String? value) =>
      setField<String>('consent_version', value);

  dynamic get checkboxes => getField<dynamic>('checkboxes');
  set checkboxes(dynamic value) => setField<dynamic>('checkboxes', value);

  String? get appVersion => getField<String>('app_version');
  set appVersion(String? value) => setField<String>('app_version', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
