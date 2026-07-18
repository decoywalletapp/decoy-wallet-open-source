import '../database.dart';

class EmergencyContactOptOutTokensTable
    extends SupabaseTable<EmergencyContactOptOutTokensRow> {
  @override
  String get tableName => 'emergency_contact_opt_out_tokens';

  @override
  EmergencyContactOptOutTokensRow createRow(Map<String, dynamic> data) =>
      EmergencyContactOptOutTokensRow(data);
}

class EmergencyContactOptOutTokensRow extends SupabaseDataRow {
  EmergencyContactOptOutTokensRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => EmergencyContactOptOutTokensTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String? get consentId => getField<String>('consent_id');
  set consentId(String? value) => setField<String>('consent_id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get phoneNumber => getField<String>('phone_number')!;
  set phoneNumber(String value) => setField<String>('phone_number', value);

  String get tokenHash => getField<String>('token_hash')!;
  set tokenHash(String value) => setField<String>('token_hash', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String get source => getField<String>('source')!;
  set source(String value) => setField<String>('source', value);

  DateTime? get expiresAt => getField<DateTime>('expires_at');
  set expiresAt(DateTime? value) => setField<DateTime>('expires_at', value);

  DateTime? get usedAt => getField<DateTime>('used_at');
  set usedAt(DateTime? value) => setField<DateTime>('used_at', value);

  DateTime? get revokedAt => getField<DateTime>('revoked_at');
  set revokedAt(DateTime? value) => setField<DateTime>('revoked_at', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
