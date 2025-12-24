import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:csv/csv.dart';
import 'package:synchronized/synchronized.dart';
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
      _currentBtcPrice = await secureStorage.getDouble('ff_currentBtcPrice') ??
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
      _decoyId = await secureStorage.getString('ff_decoyId') ?? _decoyId;
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
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late FlutterSecureStorage secureStorage;

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

  String _authJwt = '';
  String get authJwt => _authJwt;
  set authJwt(String value) {
    _authJwt = value;
  }

  bool _fakeSeeded = false;
  bool get fakeSeeded => _fakeSeeded;
  set fakeSeeded(bool value) {
    _fakeSeeded = value;
    secureStorage.setBool('ff_fakeSeeded', value);
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
  double get fakeBtcBalance => _fakeBtcBalance;
  set fakeBtcBalance(double value) {
    _fakeBtcBalance = value;
    secureStorage.setDouble('ff_fakeBtcBalance', value);
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

  String _registerDecoyKey =
      'f304badb5fdabea85139de4c6b08f331fbe790b047d3dcf81d5243bba9d5a0dd';
  String get registerDecoyKey => _registerDecoyKey;
  set registerDecoyKey(String value) {
    _registerDecoyKey = value;
    secureStorage.setString('ff_registerDecoyKey', value);
  }

  void deleteRegisterDecoyKey() {
    secureStorage.delete(key: 'ff_registerDecoyKey');
  }

  String _serverRegistrationUrl =
      'https://vxmrthyumzrfgtuvjqmr.functions.supabase.co/register-decoy';
  String get serverRegistrationUrl => _serverRegistrationUrl;
  set serverRegistrationUrl(String value) {
    _serverRegistrationUrl = value;
    secureStorage.setString('ff_serverRegistrationUrl', value);
  }

  void deleteServerRegistrationUrl() {
    secureStorage.delete(key: 'ff_serverRegistrationUrl');
  }

  String _decoyId = '';
  String get decoyId => _decoyId;
  set decoyId(String value) {
    _decoyId = value;
    secureStorage.setString('ff_decoyId', value);
  }

  void deleteDecoyId() {
    secureStorage.delete(key: 'ff_decoyId');
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
