import '../database.dart';

class NotificationJobsTable extends SupabaseTable<NotificationJobsRow> {
  @override
  String get tableName => 'notification_jobs';

  @override
  NotificationJobsRow createRow(Map<String, dynamic> data) =>
      NotificationJobsRow(data);
}

class NotificationJobsRow extends SupabaseDataRow {
  NotificationJobsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => NotificationJobsTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get type => getField<String>('type')!;
  set type(String value) => setField<String>('type', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  String get body => getField<String>('body')!;
  set body(String value) => setField<String>('body', value);

  DateTime get sendAt => getField<DateTime>('send_at')!;
  set sendAt(DateTime value) => setField<DateTime>('send_at', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  int? get attempts => getField<int>('attempts');
  set attempts(int? value) => setField<int>('attempts', value);

  String? get lastError => getField<String>('last_error');
  set lastError(String? value) => setField<String>('last_error', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
