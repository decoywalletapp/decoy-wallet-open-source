import '../database.dart';

class DecoyWalletTable extends SupabaseTable<DecoyWalletRow> {
  @override
  String get tableName => 'decoy_wallet';

  @override
  DecoyWalletRow createRow(Map<String, dynamic> data) => DecoyWalletRow(data);
}

class DecoyWalletRow extends SupabaseDataRow {
  DecoyWalletRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => DecoyWalletTable();

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get walletName => getField<String>('wallet_name');
  set walletName(String? value) => setField<String>('wallet_name', value);

  bool? get isTriggered => getField<bool>('is_triggered');
  set isTriggered(bool? value) => setField<bool>('is_triggered', value);

  dynamic get metadata => getField<dynamic>('metadata');
  set metadata(dynamic value) => setField<dynamic>('metadata', value);

  DateTime? get triggeredAt => getField<DateTime>('triggered_at');
  set triggeredAt(DateTime? value) => setField<DateTime>('triggered_at', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get decoyType => getField<String>('decoy_type');
  set decoyType(String? value) => setField<String>('decoy_type', value);

  String? get phoneNumber => getField<String>('phone_number');
  set phoneNumber(String? value) => setField<String>('phone_number', value);

  String? get encryptedPin => getField<String>('encrypted_pin');
  set encryptedPin(String? value) => setField<String>('encrypted_pin', value);

  bool? get isPhoneVerified => getField<bool>('is_phone_verified');
  set isPhoneVerified(bool? value) =>
      setField<bool>('is_phone_verified', value);

  DateTime? get verifiedAt => getField<DateTime>('verified_at');
  set verifiedAt(DateTime? value) => setField<DateTime>('verified_at', value);

  String? get decoyPinHash => getField<String>('decoy_pin_hash');
  set decoyPinHash(String? value) => setField<String>('decoy_pin_hash', value);

  String? get decoyPinSalt => getField<String>('decoy_pin_salt');
  set decoyPinSalt(String? value) => setField<String>('decoy_pin_salt', value);

  DateTime? get decoyPinSetAt => getField<DateTime>('decoy_pin_set_at');
  set decoyPinSetAt(DateTime? value) =>
      setField<DateTime>('decoy_pin_set_at', value);

  bool? get decoyModeEnabled => getField<bool>('decoy_mode_enabled');
  set decoyModeEnabled(bool? value) =>
      setField<bool>('decoy_mode_enabled', value);
}
