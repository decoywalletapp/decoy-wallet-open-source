import '../database.dart';

class BtcpayWebhookEventsTable extends SupabaseTable<BtcpayWebhookEventsRow> {
  @override
  String get tableName => 'btcpay_webhook_events';

  @override
  BtcpayWebhookEventsRow createRow(Map<String, dynamic> data) =>
      BtcpayWebhookEventsRow(data);
}

class BtcpayWebhookEventsRow extends SupabaseDataRow {
  BtcpayWebhookEventsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => BtcpayWebhookEventsTable();

  String get invoiceId => getField<String>('invoice_id')!;
  set invoiceId(String value) => setField<String>('invoice_id', value);

  String get eventType => getField<String>('event_type')!;
  set eventType(String value) => setField<String>('event_type', value);

  DateTime? get processedAt => getField<DateTime>('processed_at');
  set processedAt(DateTime? value) => setField<DateTime>('processed_at', value);
}
