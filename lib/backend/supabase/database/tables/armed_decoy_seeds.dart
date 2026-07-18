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

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get decoyId => getField<String>('decoy_id');
  set decoyId(String? value) => setField<String>('decoy_id', value);

  String? get firstName => getField<String>('first_name');
  set firstName(String? value) => setField<String>('first_name', value);

  String? get lastName => getField<String>('last_name');
  set lastName(String? value) => setField<String>('last_name', value);

  dynamic get addresses => getField<dynamic>('addresses');
  set addresses(dynamic value) => setField<dynamic>('addresses', value);

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

  String? get derivationPath => getField<String>('derivation_path');
  set derivationPath(String? value) =>
      setField<String>('derivation_path', value);
}
