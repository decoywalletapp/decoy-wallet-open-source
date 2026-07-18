import '../database.dart';

class StripeEventsTable extends SupabaseTable<StripeEventsRow> {
  @override
  String get tableName => 'stripe_events';

  @override
  StripeEventsRow createRow(Map<String, dynamic> data) => StripeEventsRow(data);
}

class StripeEventsRow extends SupabaseDataRow {
  StripeEventsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => StripeEventsTable();

  int? get id => getField<int>('id');
  set id(int? value) => setField<int>('id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String get stripeEventId => getField<String>('stripe_event_id')!;
  set stripeEventId(String value) => setField<String>('stripe_event_id', value);

  String get type => getField<String>('type')!;
  set type(String value) => setField<String>('type', value);

  bool? get livemode => getField<bool>('livemode');
  set livemode(bool? value) => setField<bool>('livemode', value);

  String? get apiVersion => getField<String>('api_version');
  set apiVersion(String? value) => setField<String>('api_version', value);

  String? get account => getField<String>('account');
  set account(String? value) => setField<String>('account', value);

  int? get created => getField<int>('created');
  set created(int? value) => setField<int>('created', value);

  String? get requestId => getField<String>('request_id');
  set requestId(String? value) => setField<String>('request_id', value);

  String? get idempotencyKey => getField<String>('idempotency_key');
  set idempotencyKey(String? value) =>
      setField<String>('idempotency_key', value);

  dynamic get payload => getField<dynamic>('payload')!;
  set payload(dynamic value) => setField<dynamic>('payload', value);
}
