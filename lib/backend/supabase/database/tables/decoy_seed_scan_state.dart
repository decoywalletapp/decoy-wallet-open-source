import '../database.dart';

class DecoySeedScanStateTable extends SupabaseTable<DecoySeedScanStateRow> {
  @override
  String get tableName => 'decoy_seed_scan_state';

  @override
  DecoySeedScanStateRow createRow(Map<String, dynamic> data) =>
      DecoySeedScanStateRow(data);
}

class DecoySeedScanStateRow extends SupabaseDataRow {
  DecoySeedScanStateRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => DecoySeedScanStateTable();

  String get decoyId => getField<String>('decoy_id')!;
  set decoyId(String value) => setField<String>('decoy_id', value);

  int? get lastIndex => getField<int>('last_index');
  set lastIndex(int? value) => setField<int>('last_index', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
