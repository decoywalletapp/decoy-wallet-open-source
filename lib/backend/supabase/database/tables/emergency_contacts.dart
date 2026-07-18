import '../database.dart';

class EmergencyContactsTable extends SupabaseTable<EmergencyContactsRow> {
  @override
  String get tableName => 'emergency_contacts';

  @override
  EmergencyContactsRow createRow(Map<String, dynamic> data) =>
      EmergencyContactsRow(data);
}

class EmergencyContactsRow extends SupabaseDataRow {
  EmergencyContactsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => EmergencyContactsTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get contactCiphertext => getField<String>('contact_ciphertext')!;
  set contactCiphertext(String value) =>
      setField<String>('contact_ciphertext', value);

  String get contactNonce => getField<String>('contact_nonce')!;
  set contactNonce(String value) => setField<String>('contact_nonce', value);

  String get keyId => getField<String>('key_id')!;
  set keyId(String value) => setField<String>('key_id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
