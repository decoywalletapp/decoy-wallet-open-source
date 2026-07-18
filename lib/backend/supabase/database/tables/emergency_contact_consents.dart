import '../database.dart';

class EmergencyContactConsentsTable
    extends SupabaseTable<EmergencyContactConsentsRow> {
  @override
  String get tableName => 'emergency_contact_consents';

  @override
  EmergencyContactConsentsRow createRow(Map<String, dynamic> data) =>
      EmergencyContactConsentsRow(data);
}

class EmergencyContactConsentsRow extends SupabaseDataRow {
  EmergencyContactConsentsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => EmergencyContactConsentsTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  int get contactSlot => getField<int>('contact_slot')!;
  set contactSlot(int value) => setField<int>('contact_slot', value);

  String? get firstName => getField<String>('first_name');
  set firstName(String? value) => setField<String>('first_name', value);

  String? get lastName => getField<String>('last_name');
  set lastName(String? value) => setField<String>('last_name', value);

  String get phoneNumber => getField<String>('phone_number')!;
  set phoneNumber(String value) => setField<String>('phone_number', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  String? get latestRequestId => getField<String>('latest_request_id');
  set latestRequestId(String? value) =>
      setField<String>('latest_request_id', value);

  DateTime? get confirmedAt => getField<DateTime>('confirmed_at');
  set confirmedAt(DateTime? value) => setField<DateTime>('confirmed_at', value);

  DateTime? get deniedAt => getField<DateTime>('denied_at');
  set deniedAt(DateTime? value) => setField<DateTime>('denied_at', value);

  DateTime? get optedOutAt => getField<DateTime>('opted_out_at');
  set optedOutAt(DateTime? value) => setField<DateTime>('opted_out_at', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
