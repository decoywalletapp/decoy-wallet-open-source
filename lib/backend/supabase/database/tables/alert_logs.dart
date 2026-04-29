import '../database.dart';

class AlertLogsTable extends SupabaseTable<AlertLogsRow> {
  @override
  String get tableName => 'alert_logs';

  @override
  AlertLogsRow createRow(Map<String, dynamic> data) => AlertLogsRow(data);
}

class AlertLogsRow extends SupabaseDataRow {
  AlertLogsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AlertLogsTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get triggerType => getField<String>('trigger_type')!;
  set triggerType(String value) => setField<String>('trigger_type', value);

  bool? get success => getField<bool>('success');
  set success(bool? value) => setField<bool>('success', value);

  String? get errorMessage => getField<String>('error_message');
  set errorMessage(String? value) => setField<String>('error_message', value);

  double? get lat => getField<double>('lat');
  set lat(double? value) => setField<double>('lat', value);

  double? get lng => getField<double>('lng');
  set lng(double? value) => setField<double>('lng', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get txid => getField<String>('txid');
  set txid(String? value) => setField<String>('txid', value);

  String? get locationCiphertext => getField<String>('location_ciphertext');
  set locationCiphertext(String? value) =>
      setField<String>('location_ciphertext', value);

  String? get locationNonce => getField<String>('location_nonce');
  set locationNonce(String? value) => setField<String>('location_nonce', value);

  int? get locationVersion => getField<int>('location_version');
  set locationVersion(int? value) => setField<int>('location_version', value);

  String? get locationWrappedDatakey =>
      getField<String>('location_wrapped_datakey');
  set locationWrappedDatakey(String? value) =>
      setField<String>('location_wrapped_datakey', value);

  String? get txidHmac => getField<String>('txid_hmac');
  set txidHmac(String? value) => setField<String>('txid_hmac', value);
}
