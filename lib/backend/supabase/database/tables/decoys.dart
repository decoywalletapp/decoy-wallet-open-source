import '../database.dart';

class DecoysTable extends SupabaseTable<DecoysRow> {
  @override
  String get tableName => 'decoys';

  @override
  DecoysRow createRow(Map<String, dynamic> data) => DecoysRow(data);
}

class DecoysRow extends SupabaseDataRow {
  DecoysRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => DecoysTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String? get decoyName => getField<String>('decoy_name');
  set decoyName(String? value) => setField<String>('decoy_name', value);

  List<String> get addresses => getListField<String>('addresses');
  set addresses(List<String>? value) =>
      setListField<String>('addresses', value);

  bool? get active => getField<bool>('active');
  set active(bool? value) => setField<bool>('active', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get network => getField<String>('network');
  set network(String? value) => setField<String>('network', value);

  int? get lastCheckedHeight => getField<int>('last_checked_height');
  set lastCheckedHeight(int? value) =>
      setField<int>('last_checked_height', value);

  DateTime? get lastActivityAt => getField<DateTime>('last_activity_at');
  set lastActivityAt(DateTime? value) =>
      setField<DateTime>('last_activity_at', value);

  String? get derivationPath => getField<String>('derivation_path');
  set derivationPath(String? value) =>
      setField<String>('derivation_path', value);

  String? get xpub => getField<String>('xpub');
  set xpub(String? value) => setField<String>('xpub', value);

  String? get zpub => getField<String>('zpub');
  set zpub(String? value) => setField<String>('zpub', value);

  String? get watchPublicKey => getField<String>('watch_public_key');
  set watchPublicKey(String? value) =>
      setField<String>('watch_public_key', value);

  String? get watchPublicKeyType => getField<String>('watch_public_key_type');
  set watchPublicKeyType(String? value) =>
      setField<String>('watch_public_key_type', value);
}
