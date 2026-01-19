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
}
