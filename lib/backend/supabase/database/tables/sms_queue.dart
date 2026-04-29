import '../database.dart';

class SmsQueueTable extends SupabaseTable<SmsQueueRow> {
  @override
  String get tableName => 'sms_queue';

  @override
  SmsQueueRow createRow(Map<String, dynamic> data) => SmsQueueRow(data);
}

class SmsQueueRow extends SupabaseDataRow {
  SmsQueueRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => SmsQueueTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String get alertId => getField<String>('alert_id')!;
  set alertId(String value) => setField<String>('alert_id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  bool? get processed => getField<bool>('processed');
  set processed(bool? value) => setField<bool>('processed', value);
}
