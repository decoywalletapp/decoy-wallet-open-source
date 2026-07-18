import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:csv/csv.dart';
import 'package:synchronized/synchronized.dart';
import 'backend/public_config.dart';
import 'flutter_flow/flutter_flow_util.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    secureStorage = FlutterSecureStorage();
    await _safeInitAsync(() async {
      _fakeSeeded = await secureStorage.getBool('ff_fakeSeeded') ?? _fakeSeeded;
    });
    await _safeInitAsync(() async {
      _fakeBtcBalance =
          await secureStorage.getDouble('ff_fakeBtcBalance') ?? _fakeBtcBalance;
    });
    await _safeInitAsync(() async {
      _fakeUsdValue =
          await secureStorage.getDouble('ff_fakeUsdValue') ?? _fakeUsdValue;
    });
    await _safeInitAsync(() async {
      final fakeBtcSeededAtString = await secureStorage.getString(
        'ff_fakeBtcSeededAt',
      );
      _fakeBtcSeededAt = fakeBtcSeededAtString != null
          ? DateTime.tryParse(fakeBtcSeededAtString) ?? _fakeBtcSeededAt
          : _fakeBtcSeededAt;
      if (_fakeSeeded && _fakeBtcSeededAt == null) {
        _fakeBtcSeededAt = DateTime.now().toUtc();
        await secureStorage.setString(
          'ff_fakeBtcSeededAt',
          _fakeBtcSeededAt!.toIso8601String(),
        );
      }
    });
    await _safeInitAsync(() async {
      _currentBtcPrice =
          await secureStorage.getDouble('ff_currentBtcPrice') ??
          _currentBtcPrice;
    });
    await _safeInitAsync(() async {
      _hasDecoyPin =
          await secureStorage.getBool('ff_hasDecoyPin') ?? _hasDecoyPin;
    });
    await _safeInitAsync(() async {
      _registerDecoyUrl =
          await secureStorage.getString('ff_registerDecoyUrl') ??
          _registerDecoyUrl;
    });
    await _safeInitAsync(() async {
      _registerDecoyKey =
          await secureStorage.getString('ff_registerDecoyKey') ??
          _registerDecoyKey;
    });
    await _safeInitAsync(() async {
      _serverRegistrationUrl =
          await secureStorage.getString('ff_serverRegistrationUrl') ??
          _serverRegistrationUrl;
    });
    await _safeInitAsync(() async {
      _decoyActiveId =
          await secureStorage.getString('ff_decoyActiveId') ?? _decoyActiveId;
    });
    await _safeInitAsync(() async {
      _emergencyContactsIncrement =
          await secureStorage.getInt('ff_emergencyContactsIncrement') ??
          _emergencyContactsIncrement;
    });
    await _safeInitAsync(() async {
      _biometricsEnabled =
          await secureStorage.getBool('ff_biometricsEnabled') ??
          _biometricsEnabled;
    });
    await _safeInitAsync(() async {
      _isLocked = await secureStorage.getBool('ff_isLocked') ?? _isLocked;
    });
    await _safeInitAsync(() async {
      _decoyPin911Enabled =
          await secureStorage.getBool('ff_decoyPin911Enabled') ??
          _decoyPin911Enabled;
    });
    await _safeInitAsync(() async {
      _decoyPinContactsEnabled =
          await secureStorage.getBool('ff_decoyPinContactsEnabled') ??
          _decoyPinContactsEnabled;
    });
    await _safeInitAsync(() async {
      _decoySeedArmed =
          await secureStorage.getBool('ff_decoySeedArmed') ?? _decoySeedArmed;
    });
    await _safeInitAsync(() async {
      _hasActiveSubscription =
          await secureStorage.getBool('ff_hasActiveSubscription') ??
          _hasActiveSubscription;
    });
    await _safeInitAsync(() async {
      _entitlementCheckCompleted =
          await secureStorage.getBool('ff_entitlementCheckCompleted') ??
          _entitlementCheckCompleted;
    });
    await _safeInitAsync(() async {
      _prevHasActiveSubscription =
          await secureStorage.getBool('ff_prevHasActiveSubscription') ??
          _prevHasActiveSubscription;
    });
    await _safeInitAsync(() async {
      _locationEnabled =
          await secureStorage.getBool('ff_locationEnabled') ?? _locationEnabled;
    });
    await _safeInitAsync(() async {
      _contactsDoneInc =
          await secureStorage.getInt('ff_contactsDoneInc') ?? _contactsDoneInc;
    });
    await _safeInitAsync(() async {
      _draftAddresses =
          await secureStorage.getStringList('ff_draftAddresses') ??
          _draftAddresses;
    });
    await _safeInitAsync(() async {
      _draftDerivationPath =
          await secureStorage.getString('ff_draftDerivationPath') ??
          _draftDerivationPath;
    });
    await _safeInitAsync(() async {
      _draftXpub = await secureStorage.getString('ff_draftXpub') ?? _draftXpub;
    });
    await _safeInitAsync(() async {
      _draftWatchPublicKey =
          await secureStorage.getString('ff_draftWatchPublicKey') ??
          _draftWatchPublicKey;
    });
    await _safeInitAsync(() async {
      _draftWatchPublicKeyType =
          await secureStorage.getString('ff_draftWatchPublicKeyType') ??
          _draftWatchPublicKeyType;
    });
    await _safeInitAsync(() async {
      _currentPriceMultiple =
          await secureStorage.getDouble('ff_currentPriceMultiple') ??
          _currentPriceMultiple;
    });
    await _safeInitAsync(() async {
      _pushEnabled =
          await secureStorage.getBool('ff_pushEnabled') ?? _pushEnabled;
    });
    await _safeInitAsync(() async {
      _openRenewalFromPush =
          await secureStorage.getBool('ff_openRenewalFromPush') ??
          _openRenewalFromPush;
    });
    await _safeInitAsync(() async {
      _pendingStripeCheckoutSessionId =
          await secureStorage.getString('ff_pendingStripeCheckoutSessionId') ??
          _pendingStripeCheckoutSessionId;
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late FlutterSecureStorage secureStorage;

  bool get _fakeBtcSeedExpired {
    final seededAt = _fakeBtcSeededAt;
    if (!_fakeSeeded) {
      return false;
    }
    return shouldSeedFakeBtcBalance && seededAt != null;
  }

  bool get shouldSeedFakeBtcBalance {
    final seededAt = _fakeBtcSeededAt;
    if (!_fakeSeeded) {
      return true;
    }
    if (seededAt == null) {
      return false;
    }

    final elapsedMs =
        DateTime.now().toUtc().millisecondsSinceEpoch -
        seededAt.toUtc().millisecondsSinceEpoch;
    return elapsedMs >= const Duration(hours: 24).inMilliseconds;
  }

  /// This is the user's PIN to access account
  String _userPIN = '';
  String get userPIN => _userPIN;
  set userPIN(String value) {
    _userPIN = value;
  }

  /// User's Phone Number
  String _phoneNumber = '';
  String get phoneNumber => _phoneNumber;
  set phoneNumber(String value) {
    _phoneNumber = value;
  }

  bool _fakeSeeded = false;
  bool get fakeSeeded => _fakeSeeded && !_fakeBtcSeedExpired;
  set fakeSeeded(bool value) {
    _fakeSeeded = value;
    secureStorage.setBool('ff_fakeSeeded', value);
    if (value && _fakeBtcSeededAt == null) {
      fakeBtcSeededAt = DateTime.now();
    }
  }

  void deleteFakeSeeded() {
    secureStorage.delete(key: 'ff_fakeSeeded');
  }

  bool _skipPinOnce = false;
  bool get skipPinOnce => _skipPinOnce;
  set skipPinOnce(bool value) {
    _skipPinOnce = value;
  }

  String _userEmail = '';
  String get userEmail => _userEmail;
  set userEmail(String value) {
    _userEmail = value;
  }

  double _fakeBtcBalance = 0.0;
  double get fakeBtcBalance {
    if (_fakeSeeded && _fakeBtcBalance <= 0.0 && !_fakeBtcSeedExpired) {
      return 0.000000000001;
    }
    return _fakeBtcBalance;
  }

  set fakeBtcBalance(double value) {
    _fakeBtcBalance = value;
    secureStorage.setDouble('ff_fakeBtcBalance', value);
    if (value > 0.0 &&
        (!_fakeSeeded || _fakeBtcSeededAt == null || _fakeBtcSeedExpired)) {
      fakeBtcSeededAt = DateTime.now();
    }
  }

  void deleteFakeBtcBalance() {
    secureStorage.delete(key: 'ff_fakeBtcBalance');
  }

  double _fakeUsdValue = 0.0;
  double get fakeUsdValue => _fakeUsdValue;
  set fakeUsdValue(double value) {
    _fakeUsdValue = value;
    secureStorage.setDouble('ff_fakeUsdValue', value);
  }

  void deleteFakeUsdValue() {
    secureStorage.delete(key: 'ff_fakeUsdValue');
  }

  DateTime? _fakeBtcSeededAt;
  DateTime? get fakeBtcSeededAt => _fakeBtcSeededAt;
  set fakeBtcSeededAt(DateTime? value) {
    _fakeBtcSeededAt = value;
    if (value == null) {
      secureStorage.delete(key: 'ff_fakeBtcSeededAt');
    } else {
      secureStorage.setString(
        'ff_fakeBtcSeededAt',
        value.toUtc().toIso8601String(),
      );
    }
  }

  void deleteFakeBtcSeededAt() {
    _fakeBtcSeededAt = null;
    secureStorage.delete(key: 'ff_fakeBtcSeededAt');
  }

  String _scannedQR = '';
  String get scannedQR => _scannedQR;
  set scannedQR(String value) {
    _scannedQR = value;
  }

  String _scannedAddress = '';
  String get scannedAddress => _scannedAddress;
  set scannedAddress(String value) {
    _scannedAddress = value;
  }

  String _sendAmountBtc = '';
  String get sendAmountBtc => _sendAmountBtc;
  set sendAmountBtc(String value) {
    _sendAmountBtc = value;
  }

  int _feeRateSatVb = 15;
  int get feeRateSatVb => _feeRateSatVb;
  set feeRateSatVb(int value) {
    _feeRateSatVb = value;
  }

  double _currentBtcPrice = 0.0;
  double get currentBtcPrice => _currentBtcPrice;
  set currentBtcPrice(double value) {
    _currentBtcPrice = value;
    secureStorage.setDouble('ff_currentBtcPrice', value);
  }

  void deleteCurrentBtcPrice() {
    secureStorage.delete(key: 'ff_currentBtcPrice');
  }

  String _txId = '';
  String get txId => _txId;
  set txId(String value) {
    _txId = value;
  }

  DateTime? _txStartAt = DateTime.fromMillisecondsSinceEpoch(1759695300000);
  DateTime? get txStartAt => _txStartAt;
  set txStartAt(DateTime? value) {
    _txStartAt = value;
  }

  int _txTotalMins = 60;
  int get txTotalMins => _txTotalMins;
  set txTotalMins(int value) {
    _txTotalMins = value;
  }

  String _txStatus = 'awaiting';
  String get txStatus => _txStatus;
  set txStatus(String value) {
    _txStatus = value;
  }

  String _feeBTC = '';
  String get feeBTC => _feeBTC;
  set feeBTC(String value) {
    _feeBTC = value;
  }

  String _userDecoyPIN = '';
  String get userDecoyPIN => _userDecoyPIN;
  set userDecoyPIN(String value) {
    _userDecoyPIN = value;
  }

  bool _hasDecoyPin = false;
  bool get hasDecoyPin => _hasDecoyPin;
  set hasDecoyPin(bool value) {
    _hasDecoyPin = value;
    secureStorage.setBool('ff_hasDecoyPin', value);
  }

  void deleteHasDecoyPin() {
    secureStorage.delete(key: 'ff_hasDecoyPin');
  }

  String _registerDecoyUrl = '';
  String get registerDecoyUrl => _registerDecoyUrl;
  set registerDecoyUrl(String value) {
    _registerDecoyUrl = value;
    secureStorage.setString('ff_registerDecoyUrl', value);
  }

  void deleteRegisterDecoyUrl() {
    secureStorage.delete(key: 'ff_registerDecoyUrl');
  }

  String _registerDecoyKey = const String.fromEnvironment(
    'DECOY_REGISTER_DECOY_KEY',
  );
  String get registerDecoyKey => _registerDecoyKey;
  set registerDecoyKey(String value) {
    _registerDecoyKey = value;
    secureStorage.setString('ff_registerDecoyKey', value);
  }

  void deleteRegisterDecoyKey() {
    secureStorage.delete(key: 'ff_registerDecoyKey');
  }

  String _serverRegistrationUrl = kSupabaseUrl.isEmpty
      ? ''
      : supabaseFunctionUrl('register-decoy');
  String get serverRegistrationUrl => _serverRegistrationUrl;
  set serverRegistrationUrl(String value) {
    _serverRegistrationUrl = value;
    secureStorage.setString('ff_serverRegistrationUrl', value);
  }

  void deleteServerRegistrationUrl() {
    secureStorage.delete(key: 'ff_serverRegistrationUrl');
  }

  String _decoyActiveId = '';
  String get decoyActiveId => _decoyActiveId;
  set decoyActiveId(String value) {
    _decoyActiveId = value;
    secureStorage.setString('ff_decoyActiveId', value);
  }

  void deleteDecoyActiveId() {
    secureStorage.delete(key: 'ff_decoyActiveId');
  }

  int _emergencyContactsIncrement = 0;
  int get emergencyContactsIncrement => _emergencyContactsIncrement;
  set emergencyContactsIncrement(int value) {
    _emergencyContactsIncrement = value;
    secureStorage.setInt('ff_emergencyContactsIncrement', value);
  }

  void deleteEmergencyContactsIncrement() {
    secureStorage.delete(key: 'ff_emergencyContactsIncrement');
  }

  String _pendingLink = '';
  String get pendingLink => _pendingLink;
  set pendingLink(String value) {
    _pendingLink = value;
  }

  String _linkType = '';
  String get linkType => _linkType;
  set linkType(String value) {
    _linkType = value;
  }

  String _linkToken = '';
  String get linkToken => _linkToken;
  set linkToken(String value) {
    _linkToken = value;
  }

  bool _biometricsEnabled = false;
  bool get biometricsEnabled => _biometricsEnabled;
  set biometricsEnabled(bool value) {
    _biometricsEnabled = value;
    secureStorage.setBool('ff_biometricsEnabled', value);
  }

  void deleteBiometricsEnabled() {
    secureStorage.delete(key: 'ff_biometricsEnabled');
  }

  bool _isLocked = false;
  bool get isLocked => _isLocked;
  set isLocked(bool value) {
    _isLocked = value;
    secureStorage.setBool('ff_isLocked', value);
  }

  void deleteIsLocked() {
    secureStorage.delete(key: 'ff_isLocked');
  }

  LatLng? _lastKnownLocation = LatLng(0.0, 0.0);
  LatLng? get lastKnownLocation => _lastKnownLocation;
  set lastKnownLocation(LatLng? value) {
    _lastKnownLocation = value;
  }

  bool _decoyPin911Enabled = false;
  bool get decoyPin911Enabled => _decoyPin911Enabled;
  set decoyPin911Enabled(bool value) {
    _decoyPin911Enabled = value;
    secureStorage.setBool('ff_decoyPin911Enabled', value);
  }

  void deleteDecoyPin911Enabled() {
    secureStorage.delete(key: 'ff_decoyPin911Enabled');
  }

  bool _decoyPinContactsEnabled = false;
  bool get decoyPinContactsEnabled => _decoyPinContactsEnabled;
  set decoyPinContactsEnabled(bool value) {
    _decoyPinContactsEnabled = value;
    secureStorage.setBool('ff_decoyPinContactsEnabled', value);
  }

  void deleteDecoyPinContactsEnabled() {
    secureStorage.delete(key: 'ff_decoyPinContactsEnabled');
  }

  bool _decoySeedArmed = false;
  bool get decoySeedArmed => _decoySeedArmed;
  set decoySeedArmed(bool value) {
    _decoySeedArmed = value;
    secureStorage.setBool('ff_decoySeedArmed', value);
  }

  void deleteDecoySeedArmed() {
    secureStorage.delete(key: 'ff_decoySeedArmed');
  }

  bool _hasActiveSubscription = false;
  bool get hasActiveSubscription => _hasActiveSubscription;
  set hasActiveSubscription(bool value) {
    _hasActiveSubscription = value;
    secureStorage.setBool('ff_hasActiveSubscription', value);
  }

  void deleteHasActiveSubscription() {
    secureStorage.delete(key: 'ff_hasActiveSubscription');
  }

  bool _entitlementCheckCompleted = false;
  bool get entitlementCheckCompleted => _entitlementCheckCompleted;
  set entitlementCheckCompleted(bool value) {
    _entitlementCheckCompleted = value;
    secureStorage.setBool('ff_entitlementCheckCompleted', value);
  }

  void deleteEntitlementCheckCompleted() {
    secureStorage.delete(key: 'ff_entitlementCheckCompleted');
  }

  bool _prevHasActiveSubscription = false;
  bool get prevHasActiveSubscription => _prevHasActiveSubscription;
  set prevHasActiveSubscription(bool value) {
    _prevHasActiveSubscription = value;
    secureStorage.setBool('ff_prevHasActiveSubscription', value);
  }

  void deletePrevHasActiveSubscription() {
    secureStorage.delete(key: 'ff_prevHasActiveSubscription');
  }

  bool _locationEnabled = false;
  bool get locationEnabled => _locationEnabled;
  set locationEnabled(bool value) {
    _locationEnabled = value;
    secureStorage.setBool('ff_locationEnabled', value);
  }

  void deleteLocationEnabled() {
    secureStorage.delete(key: 'ff_locationEnabled');
  }

  int _contactsDoneInc = 0;
  int get contactsDoneInc => _contactsDoneInc;
  set contactsDoneInc(int value) {
    _contactsDoneInc = value;
    secureStorage.setInt('ff_contactsDoneInc', value);
  }

  void deleteContactsDoneInc() {
    secureStorage.delete(key: 'ff_contactsDoneInc');
  }

  List<String> _draftAddresses = [];
  List<String> get draftAddresses => _draftAddresses;
  set draftAddresses(List<String> value) {
    _draftAddresses = value;
    secureStorage.setStringList('ff_draftAddresses', value);
  }

  void deleteDraftAddresses() {
    secureStorage.delete(key: 'ff_draftAddresses');
  }

  void addToDraftAddresses(String value) {
    draftAddresses.add(value);
    secureStorage.setStringList('ff_draftAddresses', _draftAddresses);
  }

  void removeFromDraftAddresses(String value) {
    draftAddresses.remove(value);
    secureStorage.setStringList('ff_draftAddresses', _draftAddresses);
  }

  void removeAtIndexFromDraftAddresses(int index) {
    draftAddresses.removeAt(index);
    secureStorage.setStringList('ff_draftAddresses', _draftAddresses);
  }

  void updateDraftAddressesAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    draftAddresses[index] = updateFn(_draftAddresses[index]);
    secureStorage.setStringList('ff_draftAddresses', _draftAddresses);
  }

  void insertAtIndexInDraftAddresses(int index, String value) {
    draftAddresses.insert(index, value);
    secureStorage.setStringList('ff_draftAddresses', _draftAddresses);
  }

  String _draftDerivationPath = '';
  String get draftDerivationPath => _draftDerivationPath;
  set draftDerivationPath(String value) {
    _draftDerivationPath = value;
    secureStorage.setString('ff_draftDerivationPath', value);
  }

  void deleteDraftDerivationPath() {
    secureStorage.delete(key: 'ff_draftDerivationPath');
  }

  String _draftXpub = '';
  String get draftXpub => _draftXpub;
  set draftXpub(String value) {
    _draftXpub = value;
    secureStorage.setString('ff_draftXpub', value);
  }

  void deleteDraftXpub() {
    secureStorage.delete(key: 'ff_draftXpub');
  }

  String _draftWatchPublicKey = '';
  String get draftWatchPublicKey => _draftWatchPublicKey;
  set draftWatchPublicKey(String value) {
    _draftWatchPublicKey = value;
    secureStorage.setString('ff_draftWatchPublicKey', value);
  }

  void deleteDraftWatchPublicKey() {
    secureStorage.delete(key: 'ff_draftWatchPublicKey');
  }

  String _draftWatchPublicKeyType = '';
  String get draftWatchPublicKeyType => _draftWatchPublicKeyType;
  set draftWatchPublicKeyType(String value) {
    _draftWatchPublicKeyType = value;
    secureStorage.setString('ff_draftWatchPublicKeyType', value);
  }

  void deleteDraftWatchPublicKeyType() {
    secureStorage.delete(key: 'ff_draftWatchPublicKeyType');
  }

  double _currentPriceMultiple = 0.0;
  double get currentPriceMultiple => _currentPriceMultiple;
  set currentPriceMultiple(double value) {
    _currentPriceMultiple = value;
    secureStorage.setDouble('ff_currentPriceMultiple', value);
  }

  void deleteCurrentPriceMultiple() {
    secureStorage.delete(key: 'ff_currentPriceMultiple');
  }

  String _entitlementStatus = 'unpaid';
  String get entitlementStatus => _entitlementStatus;
  set entitlementStatus(String value) {
    _entitlementStatus = value;
  }

  String _fcmToken = '';
  String get fcmToken => _fcmToken;
  set fcmToken(String value) {
    _fcmToken = value;
  }

  String _deviceId = '';
  String get deviceId => _deviceId;
  set deviceId(String value) {
    _deviceId = value;
  }

  bool _pushEnabled = false;
  bool get pushEnabled => _pushEnabled;
  set pushEnabled(bool value) {
    _pushEnabled = value;
    secureStorage.setBool('ff_pushEnabled', value);
  }

  void deletePushEnabled() {
    secureStorage.delete(key: 'ff_pushEnabled');
  }

  bool _openRenewalFromPush = false;
  bool get openRenewalFromPush => _openRenewalFromPush;
  set openRenewalFromPush(bool value) {
    _openRenewalFromPush = value;
    secureStorage.setBool('ff_openRenewalFromPush', value);
  }

  void deleteOpenRenewalFromPush() {
    secureStorage.delete(key: 'ff_openRenewalFromPush');
  }

  String _pendingStripeCheckoutSessionId = '';
  String get pendingStripeCheckoutSessionId => _pendingStripeCheckoutSessionId;
  set pendingStripeCheckoutSessionId(String value) {
    _pendingStripeCheckoutSessionId = value;
    if (value.isEmpty) {
      secureStorage.delete(key: 'ff_pendingStripeCheckoutSessionId');
    } else {
      secureStorage.setString('ff_pendingStripeCheckoutSessionId', value);
    }
  }

  void deletePendingStripeCheckoutSessionId() {
    secureStorage.delete(key: 'ff_pendingStripeCheckoutSessionId');
  }
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}

extension FlutterSecureStorageExtensions on FlutterSecureStorage {
  static final _lock = Lock();

  Future<void> writeSync({required String key, String? value}) async =>
      await _lock.synchronized(() async {
        await write(key: key, value: value);
      });

  void remove(String key) => delete(key: key);

  Future<String?> getString(String key) async => await read(key: key);
  Future<void> setString(String key, String value) async =>
      await writeSync(key: key, value: value);

  Future<bool?> getBool(String key) async => (await read(key: key)) == 'true';
  Future<void> setBool(String key, bool value) async =>
      await writeSync(key: key, value: value.toString());

  Future<int?> getInt(String key) async =>
      int.tryParse(await read(key: key) ?? '');
  Future<void> setInt(String key, int value) async =>
      await writeSync(key: key, value: value.toString());

  Future<double?> getDouble(String key) async =>
      double.tryParse(await read(key: key) ?? '');
  Future<void> setDouble(String key, double value) async =>
      await writeSync(key: key, value: value.toString());

  Future<List<String>?> getStringList(String key) async =>
      await read(key: key).then((result) {
        if (result == null || result.isEmpty) {
          return null;
        }
        return CsvToListConverter()
            .convert(result)
            .first
            .map((e) => e.toString())
            .toList();
      });
  Future<void> setStringList(String key, List<String> value) async =>
      await writeSync(key: key, value: ListToCsvConverter().convert([value]));
}
