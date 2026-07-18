import '../database.dart';

class UserDevicesTable extends SupabaseTable<UserDevicesRow> {
  @override
  String get tableName => 'user_devices';

  @override
  UserDevicesRow createRow(Map<String, dynamic> data) => UserDevicesRow(data);
}

class UserDevicesRow extends SupabaseDataRow {
  UserDevicesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => UserDevicesTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get deviceId => getField<String>('device_id')!;
  set deviceId(String value) => setField<String>('device_id', value);

  String? get platform => getField<String>('platform');
  set platform(String? value) => setField<String>('platform', value);

  String get fcmToken => getField<String>('fcm_token')!;
  set fcmToken(String value) => setField<String>('fcm_token', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  DateTime? get fcmTokenUpdatedAt => getField<DateTime>('fcm_token_updated_at');
  set fcmTokenUpdatedAt(DateTime? value) =>
      setField<DateTime>('fcm_token_updated_at', value);
}
