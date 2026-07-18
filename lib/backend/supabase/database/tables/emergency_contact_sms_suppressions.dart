import '../database.dart';

class EmergencyContactSmsSuppressionsTable
    extends SupabaseTable<EmergencyContactSmsSuppressionsRow> {
  @override
  String get tableName => 'emergency_contact_sms_suppressions';

  @override
  EmergencyContactSmsSuppressionsRow createRow(Map<String, dynamic> data) =>
      EmergencyContactSmsSuppressionsRow(data);
}

class EmergencyContactSmsSuppressionsRow extends SupabaseDataRow {
  EmergencyContactSmsSuppressionsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => EmergencyContactSmsSuppressionsTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String get phoneNumber => getField<String>('phone_number')!;
  set phoneNumber(String value) => setField<String>('phone_number', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String get source => getField<String>('source')!;
  set source(String value) => setField<String>('source', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  DateTime? get optedOutAt => getField<DateTime>('opted_out_at');
  set optedOutAt(DateTime? value) => setField<DateTime>('opted_out_at', value);
}
