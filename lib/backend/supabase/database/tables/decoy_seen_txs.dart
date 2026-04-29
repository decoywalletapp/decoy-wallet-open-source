import '../database.dart';

class DecoySeenTxsTable extends SupabaseTable<DecoySeenTxsRow> {
  @override
  String get tableName => 'decoy_seen_txs';

  @override
  DecoySeenTxsRow createRow(Map<String, dynamic> data) => DecoySeenTxsRow(data);
}

class DecoySeenTxsRow extends SupabaseDataRow {
  DecoySeenTxsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => DecoySeenTxsTable();

  String get decoyId => getField<String>('decoy_id')!;
  set decoyId(String value) => setField<String>('decoy_id', value);

  DateTime? get firstSeenAt => getField<DateTime>('first_seen_at');
  set firstSeenAt(DateTime? value) =>
      setField<DateTime>('first_seen_at', value);

  String get txidHmac => getField<String>('txid_hmac')!;
  set txidHmac(String value) => setField<String>('txid_hmac', value);
}
