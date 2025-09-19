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
