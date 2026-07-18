import '../database.dart';

class DecoySeedBaselinesTable extends SupabaseTable<DecoySeedBaselinesRow> {
  @override
  String get tableName => 'decoy_seed_baselines';

  @override
  DecoySeedBaselinesRow createRow(Map<String, dynamic> data) =>
      DecoySeedBaselinesRow(data);
}

class DecoySeedBaselinesRow extends SupabaseDataRow {
  DecoySeedBaselinesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => DecoySeedBaselinesTable();

  String get decoyId => getField<String>('decoy_id')!;
  set decoyId(String value) => setField<String>('decoy_id', value);

  DateTime? get baselinedAt => getField<DateTime>('baselined_at');
  set baselinedAt(DateTime? value) => setField<DateTime>('baselined_at', value);
}
