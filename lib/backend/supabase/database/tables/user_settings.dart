import '../database.dart';

class UserSettingsTable extends SupabaseTable<UserSettingsRow> {
  @override
  String get tableName => 'user_settings';

  @override
  UserSettingsRow createRow(Map<String, dynamic> data) => UserSettingsRow(data);
}

class UserSettingsRow extends SupabaseDataRow {
  UserSettingsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => UserSettingsTable();

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  bool? get pushEnabled => getField<bool>('push_enabled');
  set pushEnabled(bool? value) => setField<bool>('push_enabled', value);

  bool? get biometricsEnabled => getField<bool>('biometrics_enabled');
  set biometricsEnabled(bool? value) =>
      setField<bool>('biometrics_enabled', value);

  bool? get locationEnabled => getField<bool>('location_enabled');
  set locationEnabled(bool? value) => setField<bool>('location_enabled', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
