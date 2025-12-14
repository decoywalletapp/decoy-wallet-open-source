import '../database.dart';

class ArmedDecoySeedsTable extends SupabaseTable<ArmedDecoySeedsRow> {
  @override
  String get tableName => 'armed_decoy_seeds';

  @override
  ArmedDecoySeedsRow createRow(Map<String, dynamic> data) =>
      ArmedDecoySeedsRow(data);
}

class ArmedDecoySeedsRow extends SupabaseDataRow {
  ArmedDecoySeedsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ArmedDecoySeedsTable();

  String? get decoyId => getField<String>('decoy_id');
  set decoyId(String? value) => setField<String>('decoy_id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get xpub => getField<String>('xpub');
  set xpub(String? value) => setField<String>('xpub', value);

  List<String> get addresses => getListField<String>('addresses');
  set addresses(List<String>? value) =>
      setListField<String>('addresses', value);

  bool? get decoyActive => getField<bool>('decoy_active');
  set decoyActive(bool? value) => setField<bool>('decoy_active', value);

  DateTime? get decoyCreatedAt => getField<DateTime>('decoy_created_at');
  set decoyCreatedAt(DateTime? value) =>
      setField<DateTime>('decoy_created_at', value);

  String? get decoyWalletId => getField<String>('decoy_wallet_id');
  set decoyWalletId(String? value) =>
      setField<String>('decoy_wallet_id', value);

  String? get decoySeedDecoyId => getField<String>('decoy_seed_decoy_id');
  set decoySeedDecoyId(String? value) =>
      setField<String>('decoy_seed_decoy_id', value);

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

  String? get firstName => getField<String>('first_name');
  set firstName(String? value) => setField<String>('first_name', value);

  String? get lastName => getField<String>('last_name');
  set lastName(String? value) => setField<String>('last_name', value);
}
