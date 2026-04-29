import '../database.dart';

class EmergencyContactConsentRequestsTable
    extends SupabaseTable<EmergencyContactConsentRequestsRow> {
  @override
  String get tableName => 'emergency_contact_consent_requests';

  @override
  EmergencyContactConsentRequestsRow createRow(Map<String, dynamic> data) =>
      EmergencyContactConsentRequestsRow(data);
}

class EmergencyContactConsentRequestsRow extends SupabaseDataRow {
  EmergencyContactConsentRequestsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => EmergencyContactConsentRequestsTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String get consentId => getField<String>('consent_id')!;
  set consentId(String value) => setField<String>('consent_id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  int get contactSlot => getField<int>('contact_slot')!;
  set contactSlot(int value) => setField<int>('contact_slot', value);

  String get phoneNumber => getField<String>('phone_number')!;
  set phoneNumber(String value) => setField<String>('phone_number', value);

  String get tokenHash => getField<String>('token_hash')!;
  set tokenHash(String value) => setField<String>('token_hash', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  String? get decision => getField<String>('decision');
  set decision(String? value) => setField<String>('decision', value);

  DateTime get expiresAt => getField<DateTime>('expires_at')!;
  set expiresAt(DateTime value) => setField<DateTime>('expires_at', value);

  DateTime? get sentAt => getField<DateTime>('sent_at');
  set sentAt(DateTime? value) => setField<DateTime>('sent_at', value);

  DateTime? get respondedAt => getField<DateTime>('responded_at');
  set respondedAt(DateTime? value) => setField<DateTime>('responded_at', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
