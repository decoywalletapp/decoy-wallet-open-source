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

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String? get decoyName => getField<String>('decoy_name');
  set decoyName(String? value) => setField<String>('decoy_name', value);

  String get xpub => getField<String>('xpub')!;
  set xpub(String value) => setField<String>('xpub', value);

  List<String> get addresses => getListField<String>('addresses');
  set addresses(List<String> value) => setListField<String>('addresses', value);

  bool get active => getField<bool>('active')!;
  set active(bool value) => setField<bool>('active', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
