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

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

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

  String? get accountPinHash => getField<String>('account_pin_hash');
  set accountPinHash(String? value) =>
      setField<String>('account_pin_hash', value);

  String? get accountPinSalt => getField<String>('account_pin_salt');
  set accountPinSalt(String? value) =>
      setField<String>('account_pin_salt', value);

  String? get accountPinAlgo => getField<String>('account_pin_algo');
  set accountPinAlgo(String? value) =>
      setField<String>('account_pin_algo', value);

  String? get decoyPinAlgo => getField<String>('decoy_pin_algo');
  set decoyPinAlgo(String? value) => setField<String>('decoy_pin_algo', value);

  String? get decoyEncryptedPin => getField<String>('decoy_encrypted_pin');
  set decoyEncryptedPin(String? value) =>
      setField<String>('decoy_encrypted_pin', value);

  String? get wrappedDatakey => getField<String>('wrapped_datakey');
  set wrappedDatakey(String? value) =>
      setField<String>('wrapped_datakey', value);

  String? get contactsCiphertext => getField<String>('contacts_ciphertext');
  set contactsCiphertext(String? value) =>
      setField<String>('contacts_ciphertext', value);

  String? get contactsNonce => getField<String>('contacts_nonce');
  set contactsNonce(String? value) => setField<String>('contacts_nonce', value);

  int? get contactsVersion => getField<int>('contacts_version');
  set contactsVersion(int? value) => setField<int>('contacts_version', value);

  String? get addressCiphertext => getField<String>('address_ciphertext');
  set addressCiphertext(String? value) =>
      setField<String>('address_ciphertext', value);

  String? get addressNonce => getField<String>('address_nonce');
  set addressNonce(String? value) => setField<String>('address_nonce', value);

  int? get addressVersion => getField<int>('address_version');
  set addressVersion(int? value) => setField<int>('address_version', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  String? get personalNonce => getField<String>('personal_nonce');
  set personalNonce(String? value) => setField<String>('personal_nonce', value);

  int? get personalVersion => getField<int>('personal_version');
  set personalVersion(int? value) => setField<int>('personal_version', value);

  String? get personalCiphertext => getField<String>('personal_ciphertext');
  set personalCiphertext(String? value) =>
      setField<String>('personal_ciphertext', value);

  bool? get emailVerified => getField<bool>('email_verified');
  set emailVerified(bool? value) => setField<bool>('email_verified', value);

  DateTime? get emailVerifiedAt => getField<DateTime>('email_verified_at');
  set emailVerifiedAt(DateTime? value) =>
      setField<DateTime>('email_verified_at', value);

  String? get pendingEmail => getField<String>('pending_email');
  set pendingEmail(String? value) => setField<String>('pending_email', value);

  bool? get useCurrentLocation => getField<bool>('use_current_location');
  set useCurrentLocation(bool? value) =>
      setField<bool>('use_current_location', value);

  bool? get personalComplete => getField<bool>('personal_complete');
  set personalComplete(bool? value) =>
      setField<bool>('personal_complete', value);

  bool? get addressComplete => getField<bool>('address_complete');
  set addressComplete(bool? value) => setField<bool>('address_complete', value);

  bool? get contactsComplete => getField<bool>('contacts_complete');
  set contactsComplete(bool? value) =>
      setField<bool>('contacts_complete', value);

  bool? get hasDecoySeedAck => getField<bool>('has_decoy_seed_ack');
  set hasDecoySeedAck(bool? value) =>
      setField<bool>('has_decoy_seed_ack', value);

  bool? get hasDecoyPinAck => getField<bool>('has_decoy_pin_ack');
  set hasDecoyPinAck(bool? value) => setField<bool>('has_decoy_pin_ack', value);

  bool? get decoySeedArmed => getField<bool>('decoy_seed_armed');
  set decoySeedArmed(bool? value) => setField<bool>('decoy_seed_armed', value);

  bool? get decoySeedContactsEnabled =>
      getField<bool>('decoy_seed_contacts_enabled');
  set decoySeedContactsEnabled(bool? value) =>
      setField<bool>('decoy_seed_contacts_enabled', value);

  DateTime? get decoySeedLastTriggeredAt =>
      getField<DateTime>('decoy_seed_last_triggered_at');
  set decoySeedLastTriggeredAt(DateTime? value) =>
      setField<DateTime>('decoy_seed_last_triggered_at', value);

  String? get decoySeedDecoyId => getField<String>('decoy_seed_decoy_id');
  set decoySeedDecoyId(String? value) =>
      setField<String>('decoy_seed_decoy_id', value);

  bool? get decoyPin911Enabled => getField<bool>('decoy_pin_911_enabled');
  set decoyPin911Enabled(bool? value) =>
      setField<bool>('decoy_pin_911_enabled', value);

  bool? get decoyPinContactsEnabled =>
      getField<bool>('decoy_pin_contacts_enabled');
  set decoyPinContactsEnabled(bool? value) =>
      setField<bool>('decoy_pin_contacts_enabled', value);

  DateTime? get lastTeardownAt => getField<DateTime>('last_teardown_at');
  set lastTeardownAt(DateTime? value) =>
      setField<DateTime>('last_teardown_at', value);

  DateTime? get decoySeedArmedAt => getField<DateTime>('decoy_seed_armed_at');
  set decoySeedArmedAt(DateTime? value) =>
      setField<DateTime>('decoy_seed_armed_at', value);

  String? get phoneE164Hash => getField<String>('phone_e164_hash');
  set phoneE164Hash(String? value) =>
      setField<String>('phone_e164_hash', value);

  String? get emailHash => getField<String>('email_hash');
  set emailHash(String? value) => setField<String>('email_hash', value);

  String? get pendingEmailHash => getField<String>('pending_email_hash');
  set pendingEmailHash(String? value) =>
      setField<String>('pending_email_hash', value);

  bool? get setupComplete => getField<bool>('setup_complete');
  set setupComplete(bool? value) => setField<bool>('setup_complete', value);

  DateTime? get setupCompletedAt => getField<DateTime>('setup_completed_at');
  set setupCompletedAt(DateTime? value) =>
      setField<DateTime>('setup_completed_at', value);

  bool? get agreementsComplete => getField<bool>('agreements_complete');
  set agreementsComplete(bool? value) =>
      setField<bool>('agreements_complete', value);

  DateTime? get agreementsCompletedAt =>
      getField<DateTime>('agreements_completed_at');
  set agreementsCompletedAt(DateTime? value) =>
      setField<DateTime>('agreements_completed_at', value);
}
