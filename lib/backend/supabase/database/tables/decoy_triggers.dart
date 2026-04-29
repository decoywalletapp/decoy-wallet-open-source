import '../database.dart';

class DecoyTriggersTable extends SupabaseTable<DecoyTriggersRow> {
  @override
  String get tableName => 'decoy_triggers';

  @override
  DecoyTriggersRow createRow(Map<String, dynamic> data) =>
      DecoyTriggersRow(data);
}

class DecoyTriggersRow extends SupabaseDataRow {
  DecoyTriggersRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => DecoyTriggersTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String? get decoyId => getField<String>('decoy_id');
  set decoyId(String? value) => setField<String>('decoy_id', value);

  String? get triggerType => getField<String>('trigger_type');
  set triggerType(String? value) => setField<String>('trigger_type', value);

  String? get txid => getField<String>('txid');
  set txid(String? value) => setField<String>('txid', value);

  DateTime? get observedAt => getField<DateTime>('observed_at');
  set observedAt(DateTime? value) => setField<DateTime>('observed_at', value);

  dynamic get rawEvent => getField<dynamic>('raw_event');
  set rawEvent(dynamic value) => setField<dynamic>('raw_event', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get txidHmac => getField<String>('txid_hmac');
  set txidHmac(String? value) => setField<String>('txid_hmac', value);
}
