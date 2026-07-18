import '../database.dart';

class UserEntitlementsTable extends SupabaseTable<UserEntitlementsRow> {
  @override
  String get tableName => 'user_entitlements';

  @override
  UserEntitlementsRow createRow(Map<String, dynamic> data) =>
      UserEntitlementsRow(data);
}

class UserEntitlementsRow extends SupabaseDataRow {
  UserEntitlementsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => UserEntitlementsTable();

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get entitlement => getField<String>('entitlement')!;
  set entitlement(String value) => setField<String>('entitlement', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  String? get provider => getField<String>('provider');
  set provider(String? value) => setField<String>('provider', value);

  String? get providerCustomerId => getField<String>('provider_customer_id');
  set providerCustomerId(String? value) =>
      setField<String>('provider_customer_id', value);

  String? get providerSubscriptionId =>
      getField<String>('provider_subscription_id');
  set providerSubscriptionId(String? value) =>
      setField<String>('provider_subscription_id', value);

  String? get providerStatus => getField<String>('provider_status');
  set providerStatus(String? value) =>
      setField<String>('provider_status', value);

  DateTime? get currentPeriodEnd => getField<DateTime>('current_period_end');
  set currentPeriodEnd(DateTime? value) =>
      setField<DateTime>('current_period_end', value);

  bool? get cancelAtPeriodEnd => getField<bool>('cancel_at_period_end');
  set cancelAtPeriodEnd(bool? value) =>
      setField<bool>('cancel_at_period_end', value);

  DateTime? get renewalReminderSentAt =>
      getField<DateTime>('renewal_reminder_sent_at');
  set renewalReminderSentAt(DateTime? value) =>
      setField<DateTime>('renewal_reminder_sent_at', value);

  DateTime? get activationNotifiedAt =>
      getField<DateTime>('activation_notified_at');
  set activationNotifiedAt(DateTime? value) =>
      setField<DateTime>('activation_notified_at', value);

  String? get pendingProvider => getField<String>('pending_provider');
  set pendingProvider(String? value) =>
      setField<String>('pending_provider', value);

  String? get pendingProviderSubscriptionId =>
      getField<String>('pending_provider_subscription_id');
  set pendingProviderSubscriptionId(String? value) =>
      setField<String>('pending_provider_subscription_id', value);

  String? get pendingProviderCustomerId =>
      getField<String>('pending_provider_customer_id');
  set pendingProviderCustomerId(String? value) =>
      setField<String>('pending_provider_customer_id', value);

  DateTime? get pendingStartsAt => getField<DateTime>('pending_starts_at');
  set pendingStartsAt(DateTime? value) =>
      setField<DateTime>('pending_starts_at', value);

  DateTime? get switchInitiatedAt => getField<DateTime>('switch_initiated_at');
  set switchInitiatedAt(DateTime? value) =>
      setField<DateTime>('switch_initiated_at', value);

  DateTime? get teardownGraceUntil =>
      getField<DateTime>('teardown_grace_until');
  set teardownGraceUntil(DateTime? value) =>
      setField<DateTime>('teardown_grace_until', value);
}
