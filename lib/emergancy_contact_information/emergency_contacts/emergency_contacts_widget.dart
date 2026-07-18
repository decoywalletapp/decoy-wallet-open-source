import 'dart:convert';

import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'emergency_contacts_model.dart';
export 'emergency_contacts_model.dart';

void _debugLog(String message) {
  if (kDebugMode) {
    debugPrint(message);
  }
}

/// generate a page that allows the user to add up to five emergency
/// contacts...
///
/// the emergency contacts will have first name last name and phone number...
/// save button at the bottom
class EmergencyContactsWidget extends StatefulWidget {
  const EmergencyContactsWidget({super.key});

  static String routeName = 'EmergencyContacts';
  static String routePath = '/emergencyContacts';

  @override
  State<EmergencyContactsWidget> createState() =>
      _EmergencyContactsWidgetState();
}

class _EmergencyContactsWidgetState extends State<EmergencyContactsWidget> {
  late EmergencyContactsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _contactsListController = ScrollController();
  static const _dataKeyStorage = FlutterSecureStorage();
  static const _dataKeyName = 'decoy_data_key_b64';
  static const _contactsCipherCacheName = 'decoy_contacts_cipher_b64';
  static const _contactsNonceCacheName = 'decoy_contacts_nonce_b64';
  static const _contactsWrappedCacheName = 'decoy_contacts_wrapped_b64';
  static List<Map<String, String>>? _sessionContactsCache;
  static int? _sessionContactsCountCache;
  static String? _sessionContactsUserIdCache;
  final Set<int> _recentConsentInviteSlots = <int>{};
  final Set<int> _manualContactEntrySlots = <int>{};
  static const MethodChannel _contactPickerChannel =
      MethodChannel('decoy_wallet/contact_picker');

  bool _showingConsentInviteSent(int contactSlot) =>
      _recentConsentInviteSlots.contains(contactSlot);

  String _consentInviteButtonLabel(int contactSlot, String status) {
    if (_showingConsentInviteSent(contactSlot)) {
      return 'Confirmation Link Sent';
    }

    return status == 'Not sent'
        ? 'Send Confirmation Link'
        : 'Resend Confirmation Link';
  }

  IconData _consentInviteButtonIcon(int contactSlot) {
    return _showingConsentInviteSent(contactSlot)
        ? Icons.check_circle_rounded
        : Icons.send_rounded;
  }

  void _showConsentInviteSent(int contactSlot) {
    safeSetState(() {
      _recentConsentInviteSlots.add(contactSlot);
    });

    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted || !_recentConsentInviteSlots.contains(contactSlot)) {
        return;
      }

      safeSetState(() {
        _recentConsentInviteSlots.remove(contactSlot);
      });
    });
  }

  String? _normalizeDataKeyB64(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }

    try {
      var normalized = text.replaceAll('-', '+').replaceAll('_', '/');
      final pad = normalized.length % 4;
      if (pad != 0) {
        normalized = normalized + ('=' * (4 - pad));
      }

      final bytes = base64.decode(normalized);
      if (bytes.length != 16 && bytes.length != 32) {
        return null;
      }
      return base64UrlEncode(bytes);
    } catch (_) {
      return null;
    }
  }

  Future<void> _rememberDataKey(String keyB64) async {
    final normalized = _normalizeDataKeyB64(keyB64);
    if (normalized == null) {
      return;
    }

    try {
      await _dataKeyStorage.write(key: _dataKeyName, value: normalized);
      final userKey = _storageKeyForCurrentUser(_dataKeyName);
      if (userKey != null) {
        await _dataKeyStorage.write(key: userKey, value: normalized);
      }
    } catch (_) {
      try {
        await _dataKeyStorage.delete(key: _dataKeyName);
        await _dataKeyStorage.write(key: _dataKeyName, value: normalized);
        final userKey = _storageKeyForCurrentUser(_dataKeyName);
        if (userKey != null) {
          await _dataKeyStorage.delete(key: userKey);
          await _dataKeyStorage.write(key: userKey, value: normalized);
        }
      } catch (_) {}
    }
  }

  Future<String> _newOrStoredDataKey() async {
    final key = await actions.generateDataKeyIfMissing();
    return _normalizeDataKeyB64(key) ?? key;
  }

  Future<String?> _storedDataKeyOrNull() async {
    try {
      final userKey = _storageKeyForCurrentUser(_dataKeyName);
      if (userKey != null) {
        final userValue = _normalizeDataKeyB64(
          await _dataKeyStorage.read(key: userKey),
        );
        if (userValue != null) {
          return userValue;
        }
      }
      return _normalizeDataKeyB64(
        await _dataKeyStorage.read(key: _dataKeyName),
      );
    } catch (_) {
      return null;
    }
  }

  Future<String> _jwtForApi() async {
    final cached = currentJwtToken.trim();
    if (cached.isNotEmpty) {
      return cached;
    }

    try {
      final session = SupaFlow.client.auth.currentSession;
      final sessionToken = session?.accessToken.trim() ?? '';
      if (sessionToken.isNotEmpty) {
        return sessionToken;
      }

      final refreshed = await SupaFlow.client.auth.refreshSession();
      return refreshed.session?.accessToken.trim() ?? '';
    } catch (error) {
      _debugLog('[EmergencyContacts] JWT lookup failed: $error');
      return '';
    }
  }

  String? _storageKeyForCurrentUser(String name) {
    final userId = currentUserUid.trim();
    if (userId.isEmpty) {
      return null;
    }
    return '$name.$userId';
  }

  Map<String, String> _contactSnapshot(int slot) {
    switch (slot) {
      case 1:
        return {
          'first': _model.c1FirstTFTextController?.text ?? '',
          'last': _model.c1LastTFTextController?.text ?? '',
          'phone': _model.c1PhoneTFTextController?.text ?? '',
          'status': _model.c1Status,
        };
      case 2:
        return {
          'first': _model.c2FirstTFTextController?.text ?? '',
          'last': _model.c2LastTFTextController?.text ?? '',
          'phone': _model.c2PhoneTFTextController?.text ?? '',
          'status': _model.c2Status,
        };
      case 3:
        return {
          'first': _model.c3FirstTFTextController?.text ?? '',
          'last': _model.c3LastTFTextController?.text ?? '',
          'phone': _model.c3PhoneTFTextController?.text ?? '',
          'status': _model.c3Status,
        };
      case 4:
        return {
          'first': _model.c4FirstTFTextController?.text ?? '',
          'last': _model.c4LastTFTextController?.text ?? '',
          'phone': _model.c4PhoneTFTextController?.text ?? '',
          'status': _model.c4Status,
        };
      case 5:
        return {
          'first': _model.c5FirstTFTextController?.text ?? '',
          'last': _model.c5LastTFTextController?.text ?? '',
          'phone': _model.c5PhoneTFTextController?.text ?? '',
          'status': _model.c5Status,
        };
      default:
        return _emptyContactSnapshot();
    }
  }

  Map<String, String> _emptyContactSnapshot() => {
        'first': '',
        'last': '',
        'phone': '',
        'status': 'Not sent',
      };

  void _setContactSlot(int slot, Map<String, String> contact) {
    final first = contact['first'] ?? '';
    final last = contact['last'] ?? '';
    final phone = functions.sanitizePhoneDigits(contact['phone'] ?? '');
    final status =
        functions.emergencyContactStatusLabel(contact['status'] ?? 'Not sent');

    switch (slot) {
      case 1:
        _model.c1FirstTFTextController?.text = first;
        _model.c1LastTFTextController?.text = last;
        _model.c1PhoneTFTextController?.text = phone;
        _model.c1PhoneTFMask.updateMask(
          newValue: TextEditingValue(text: phone),
        );
        _model.c1Status = status;
        return;
      case 2:
        _model.c2FirstTFTextController?.text = first;
        _model.c2LastTFTextController?.text = last;
        _model.c2PhoneTFTextController?.text = phone;
        _model.c2PhoneTFMask.updateMask(
          newValue: TextEditingValue(text: phone),
        );
        _model.c2Status = status;
        return;
      case 3:
        _model.c3FirstTFTextController?.text = first;
        _model.c3LastTFTextController?.text = last;
        _model.c3PhoneTFTextController?.text = phone;
        _model.c3PhoneTFMask.updateMask(
          newValue: TextEditingValue(text: phone),
        );
        _model.c3Status = status;
        return;
      case 4:
        _model.c4FirstTFTextController?.text = first;
        _model.c4LastTFTextController?.text = last;
        _model.c4PhoneTFTextController?.text = phone;
        _model.c4PhoneTFMask.updateMask(
          newValue: TextEditingValue(text: phone),
        );
        _model.c4Status = status;
        return;
      case 5:
        _model.c5FirstTFTextController?.text = first;
        _model.c5LastTFTextController?.text = last;
        _model.c5PhoneTFTextController?.text = phone;
        _model.c5PhoneTFMask.updateMask(
          newValue: TextEditingValue(text: phone),
        );
        _model.c5Status = status;
        return;
    }
  }

  void _deleteContactSlot(int slot) {
    final deleteIndex = slot - 1;
    if (deleteIndex < 0 || deleteIndex >= _model.contactsCount) {
      return;
    }

    final manualSlotsAfterDelete = _manualContactEntrySlots
        .map<int?>((entrySlot) {
          if (entrySlot == slot) {
            return null;
          }
          if (entrySlot > slot) {
            return entrySlot - 1;
          }
          return entrySlot;
        })
        .whereType<int>()
        .where((entrySlot) => entrySlot >= 1 && entrySlot <= 5)
        .toSet();

    final contacts = List<Map<String, String>>.generate(
      5,
      (index) => _contactSnapshot(index + 1),
    );
    contacts.removeAt(deleteIndex);
    contacts.add(_emptyContactSnapshot());

    safeSetState(() {
      for (var index = 0; index < 5; index++) {
        _setContactSlot(index + 1, contacts[index]);
      }
      _model.contactsCount = (_model.contactsCount - 1).clamp(1, 5).toInt();
      _manualContactEntrySlots
        ..clear()
        ..addAll(manualSlotsAfterDelete
            .where((entrySlot) => entrySlot <= _model.contactsCount));
    });
  }

  bool _contactSlotHasDetails(int slot) {
    final contact = _contactSnapshot(slot);
    final status = functions.emergencyContactStatusLabel(
      contact['status'] ?? 'Not sent',
    );
    return (contact['first'] ?? '').trim().isNotEmpty ||
        (contact['last'] ?? '').trim().isNotEmpty ||
        (contact['phone'] ?? '').trim().isNotEmpty ||
        status != 'Not sent';
  }

  bool _shouldShowContactEntryChoice(int slot) {
    return !_contactSlotHasDetails(slot) &&
        !_manualContactEntrySlots.contains(slot);
  }

  void _showManualContactEntry(int slot) {
    safeSetState(() {
      _manualContactEntrySlots.add(slot);
    });
  }

  Future<void> _pickDeviceContactForSlot(int slot) async {
    try {
      final result = await _contactPickerChannel
          .invokeMapMethod<String, dynamic>('pickContact');
      if (!mounted || result == null) {
        return;
      }

      final firstName = (result['firstName'] ?? '').toString().trim();
      final lastName = (result['lastName'] ?? '').toString().trim();
      final phoneNumber = (result['phoneNumber'] ?? '').toString().trim();

      if (firstName.isEmpty && lastName.isEmpty && phoneNumber.isEmpty) {
        _showManualContactEntry(slot);
        return;
      }

      safeSetState(() {
        _manualContactEntrySlots.add(slot);
        _setContactSlot(slot, {
          'first': firstName,
          'last': lastName,
          'phone': phoneNumber,
          'status': 'Not sent',
        });
      });
    } catch (error) {
      _debugLog('[EmergencyContacts] contact picker failed: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not open contacts. Enter contact manually.',
              style: TextStyle(
                color: FlutterFlowTheme.of(context).primaryText,
              ),
            ),
            duration: const Duration(seconds: 3),
            backgroundColor: FlutterFlowTheme.of(context).secondary,
          ),
        );
      }
      _showManualContactEntry(slot);
    }
  }

  Widget _buildContactEntryChoice(int slot) {
    Widget buildChoiceButton({
      required IconData icon,
      required String label,
      required VoidCallback onPressed,
      required Color color,
      required Color textColor,
      required double elevation,
      BorderSide? borderSide,
    }) {
      return FFButtonWidget(
        onPressed: onPressed,
        text: label,
        icon: Icon(
          icon,
          size: 26.0,
        ),
        options: FFButtonOptions(
          width: 300.0,
          height: 58.0,
          padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
          iconPadding:
              const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 10.0, 0.0),
          color: color,
          textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                color: textColor,
                fontSize: 20.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w600,
                useGoogleFonts:
                    !FlutterFlowTheme.of(context).titleSmallIsCustom,
              ),
          elevation: elevation,
          borderSide: borderSide,
          borderRadius: BorderRadius.circular(8.0),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 22.0, 0.0, 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildChoiceButton(
            icon: Icons.person_add_alt_1_rounded,
            label: 'Choose From Contacts',
            onPressed: () {
              _pickDeviceContactForSlot(slot);
            },
            color: FlutterFlowTheme.of(context).primary,
            textColor: FlutterFlowTheme.of(context).info,
            elevation: 6.0,
            borderSide: BorderSide(
              color: FlutterFlowTheme.of(context).primary,
            ),
          ),
          buildChoiceButton(
            icon: Icons.arrow_forward_rounded,
            label: 'Enter Manually',
            onPressed: () {
              _showManualContactEntry(slot);
            },
            color: FlutterFlowTheme.of(context).secondaryBackground,
            textColor: FlutterFlowTheme.of(context).primaryText,
            elevation: 2.0,
            borderSide: BorderSide(
              color: FlutterFlowTheme.of(context).primary,
              width: 2.0,
            ),
          ),
        ].divide(const SizedBox(height: 16.0)),
      ),
    );
  }

  bool _hydrateSessionContactsCache() {
    final cachedContacts = _sessionContactsCache;
    if (cachedContacts == null ||
        cachedContacts.isEmpty ||
        _sessionContactsUserIdCache != currentUserUid) {
      return false;
    }

    for (var index = 0; index < 5; index++) {
      final contact = index < cachedContacts.length
          ? cachedContacts[index]
          : _emptyContactSnapshot();
      _setContactFields(
        index + 1,
        first: contact['first'] ?? '',
        last: contact['last'] ?? '',
        phone: contact['phone'] ?? '',
      );
      _setContactSlotStatus(
        index + 1,
        functions.emergencyContactStatusLabel(contact['status'] ?? 'Not sent'),
      );
    }
    _model.contactsCount = (_sessionContactsCountCache ?? 1).clamp(1, 5);
    _debugLog('[EmergencyContacts] hydrated session contacts cache');
    return true;
  }

  void _rememberSessionContactsCache() {
    _sessionContactsCache = List<Map<String, String>>.generate(
      5,
      (index) => _contactSnapshot(index + 1),
    );
    _sessionContactsCountCache = _model.contactsCount.clamp(1, 5);
    _sessionContactsUserIdCache = currentUserUid;
  }

  Future<bool> _hydrateEncryptedContactsCache() async {
    final cipherKey = _storageKeyForCurrentUser(_contactsCipherCacheName);
    final nonceKey = _storageKeyForCurrentUser(_contactsNonceCacheName);
    if (cipherKey == null || nonceKey == null) {
      return false;
    }

    try {
      final dataKey = await _storedDataKeyOrNull();
      if (dataKey == null || dataKey.isEmpty) {
        return false;
      }

      final cipherB64 =
          (await _dataKeyStorage.read(key: cipherKey))?.trim() ?? '';
      final nonceB64 =
          (await _dataKeyStorage.read(key: nonceKey))?.trim() ?? '';
      if (cipherB64.isEmpty || nonceB64.isEmpty) {
        return false;
      }

      final contactsObj = await actions.aesGcmDecryptToMap(
        cipherB64,
        nonceB64,
        dataKey,
      );
      if (getJsonField(contactsObj, r'''$._ok''') == false) {
        _debugLog(
          '[EmergencyContacts] encrypted cache decrypt failed: '
          '${getJsonField(contactsObj, r'''$._error''')}',
        );
        return false;
      }

      _model.dataKeyB64 = dataKey;
      _model.contactsObj = contactsObj;
      _model.contactsJson = contactsObj.toString();
      _applyStoredContactsToFields();
      _applyStoredConsentStatusFallbacks();
      _syncContactsCountToLoadedFields();
      _debugLog('[EmergencyContacts] hydrated encrypted contacts cache');
      return true;
    } catch (error) {
      _debugLog('[EmergencyContacts] encrypted cache load threw: $error');
      return false;
    }
  }

  Future<void> _rememberEncryptedContactsCache({
    required String cipherB64,
    required String nonceB64,
    required String wrappedB64,
  }) async {
    final cipherKey = _storageKeyForCurrentUser(_contactsCipherCacheName);
    final nonceKey = _storageKeyForCurrentUser(_contactsNonceCacheName);
    final wrappedKey = _storageKeyForCurrentUser(_contactsWrappedCacheName);
    if (cipherKey == null || nonceKey == null || wrappedKey == null) {
      return;
    }

    try {
      await _dataKeyStorage.write(key: cipherKey, value: cipherB64.trim());
      await _dataKeyStorage.write(key: nonceKey, value: nonceB64.trim());
      await _dataKeyStorage.write(key: wrappedKey, value: wrappedB64.trim());
      _debugLog('[EmergencyContacts] remembered encrypted contacts cache');
    } catch (error) {
      _debugLog('[EmergencyContacts] encrypted cache write threw: $error');
    }
  }

  Future<void> _clearEncryptedContactsCache() async {
    final cipherKey = _storageKeyForCurrentUser(_contactsCipherCacheName);
    final nonceKey = _storageKeyForCurrentUser(_contactsNonceCacheName);
    final wrappedKey = _storageKeyForCurrentUser(_contactsWrappedCacheName);
    if (cipherKey == null || nonceKey == null || wrappedKey == null) {
      return;
    }

    try {
      await _dataKeyStorage.delete(key: cipherKey);
      await _dataKeyStorage.delete(key: nonceKey);
      await _dataKeyStorage.delete(key: wrappedKey);
    } catch (error) {
      _debugLog('[EmergencyContacts] encrypted cache clear threw: $error');
    }
  }

  void _setContactSlotStatus(int slot, String status) {
    switch (slot) {
      case 1:
        _model.c1Status = status;
        return;
      case 2:
        _model.c2Status = status;
        return;
      case 3:
        _model.c3Status = status;
        return;
      case 4:
        _model.c4Status = status;
        return;
      case 5:
        _model.c5Status = status;
        return;
    }
  }

  String _storedConsentStatusForContact(int index) {
    final raw = getJsonField(
      _model.contactsObj,
      '\$.contacts[$index].consent_status',
    )?.toString();
    return functions.emergencyContactStatusLabel(raw);
  }

  void _applyStoredConsentStatusFallbacks() {
    final stored = List<String>.generate(
      5,
      (index) => _storedConsentStatusForContact(index),
    );

    if (_model.c1Status == 'Not sent' && stored[0] != 'Not sent') {
      _model.c1Status = stored[0];
    }
    if (_model.c2Status == 'Not sent' && stored[1] != 'Not sent') {
      _model.c2Status = stored[1];
    }
    if (_model.c3Status == 'Not sent' && stored[2] != 'Not sent') {
      _model.c3Status = stored[2];
    }
    if (_model.c4Status == 'Not sent' && stored[3] != 'Not sent') {
      _model.c4Status = stored[3];
    }
    if (_model.c5Status == 'Not sent' && stored[4] != 'Not sent') {
      _model.c5Status = stored[4];
    }
  }

  void _resetConsentStatusAfterPhoneEdit(int slot) {
    switch (slot) {
      case 1:
        if (_model.c1Status == 'Not sent') return;
        _model.c1Status = 'Not sent';
        break;
      case 2:
        if (_model.c2Status == 'Not sent') return;
        _model.c2Status = 'Not sent';
        break;
      case 3:
        if (_model.c3Status == 'Not sent') return;
        _model.c3Status = 'Not sent';
        break;
      case 4:
        if (_model.c4Status == 'Not sent') return;
        _model.c4Status = 'Not sent';
        break;
      case 5:
        if (_model.c5Status == 'Not sent') return;
        _model.c5Status = 'Not sent';
        break;
      default:
        return;
    }
    safeSetState(() {});
  }

  String _cleanLoadedValue(dynamic value) {
    if (value == null) return '';
    final text = value.toString().trim();
    return text.toLowerCase() == 'null' ? '' : text;
  }

  String _jsonValue(dynamic json, String path) {
    return _cleanLoadedValue(getJsonField(json, path));
  }

  bool _hasContactText(String first, String last, String phone) {
    return first.trim().isNotEmpty ||
        last.trim().isNotEmpty ||
        phone.trim().isNotEmpty;
  }

  String _displayContactPhone(String phone) {
    final cleaned = _cleanLoadedValue(phone);
    return cleaned.isEmpty ? '' : functions.displayPhoneNumber(cleaned);
  }

  Future<String?> _dataKeyForWrappedRow(
    String wrappedB64, {
    bool allowCreateFallback = true,
  }) async {
    final wrapped = wrappedB64.trim();
    if (wrapped.isNotEmpty) {
      try {
        final jwt = await _jwtForApi();
        final unwrapResp = await WrapDataKeyUnwrapCall.call(
          wrappedB64: wrapped,
          jwt: jwt,
        );
        final key = _normalizeDataKeyB64(
          _extractUnwrappedDataKey(unwrapResp.jsonBody),
        );
        if ((unwrapResp.succeeded) && key != null) {
          await _rememberDataKey(key);
          return key;
        }
        _debugLog(
          '[EmergencyContacts] data key unwrap failed: '
          'status=${unwrapResp.statusCode}, jwt=${jwt.isNotEmpty}, '
          'wrapped=${wrapped.isNotEmpty}, key=${key != null}',
        );
      } catch (error) {
        _debugLog('[EmergencyContacts] data key unwrap threw: $error');
      }
    }

    if (allowCreateFallback) {
      return _newOrStoredDataKey();
    }
    return _storedDataKeyOrNull();
  }

  Future<String> _currentRowDataKeyForSave() async {
    var wrapped = _model.wrappedB64.trim();
    if (wrapped.isEmpty) {
      try {
        final rows = await DecoyWalletTable().queryRows(
          queryFn: (q) => q
              .eqOrNull(
                'user_id',
                currentUserUid,
              )
              .order('updated_at', ascending: false),
          limit: 1,
        );
        if (rows.isNotEmpty) {
          wrapped = (rows.first.wrappedDatakey ?? '').trim();
          _model.wrappedB64 = wrapped;
        }
      } catch (error) {
        _debugLog('[EmergencyContacts] save key row lookup failed: $error');
      }
    }

    if (wrapped.isNotEmpty) {
      final key = await _dataKeyForWrappedRow(wrapped);
      if ((key ?? '').trim().isNotEmpty) {
        return key!;
      }
    }

    return _newOrStoredDataKey();
  }

  String _extractUnwrappedDataKey(dynamic response) {
    for (final path in const [
      r'''$.dataKeyB64''',
      r'''$.data_key_b64''',
      r'''$.unwrappedB64''',
      r'''$.keyB64''',
      r'''$.plaintextB64''',
    ]) {
      final value = _jsonValue(response, path);
      if (value.isNotEmpty) return value;
    }
    return _cleanLoadedValue(response);
  }

  void _setContactFields(
    int slot, {
    required String first,
    required String last,
    required String phone,
  }) {
    final cleanFirst = _cleanLoadedValue(first);
    final cleanLast = _cleanLoadedValue(last);
    final displayPhone = _displayContactPhone(phone);

    switch (slot) {
      case 1:
        _model.c1FirstTFTextController?.text = cleanFirst;
        _model.c1LastTFTextController?.text = cleanLast;
        _model.c1PhoneTFTextController?.text = displayPhone;
        _model.c1PhoneTFMask.updateMask(
          newValue: TextEditingValue(text: displayPhone),
        );
        return;
      case 2:
        _model.c2FirstTFTextController?.text = cleanFirst;
        _model.c2LastTFTextController?.text = cleanLast;
        _model.c2PhoneTFTextController?.text = displayPhone;
        _model.c2PhoneTFMask.updateMask(
          newValue: TextEditingValue(text: displayPhone),
        );
        return;
      case 3:
        _model.c3FirstTFTextController?.text = cleanFirst;
        _model.c3LastTFTextController?.text = cleanLast;
        _model.c3PhoneTFTextController?.text = displayPhone;
        _model.c3PhoneTFMask.updateMask(
          newValue: TextEditingValue(text: displayPhone),
        );
        return;
      case 4:
        _model.c4FirstTFTextController?.text = cleanFirst;
        _model.c4LastTFTextController?.text = cleanLast;
        _model.c4PhoneTFTextController?.text = displayPhone;
        _model.c4PhoneTFMask.updateMask(
          newValue: TextEditingValue(text: displayPhone),
        );
        return;
      case 5:
        _model.c5FirstTFTextController?.text = cleanFirst;
        _model.c5LastTFTextController?.text = cleanLast;
        _model.c5PhoneTFTextController?.text = displayPhone;
        _model.c5PhoneTFMask.updateMask(
          newValue: TextEditingValue(text: displayPhone),
        );
        return;
    }
  }

  bool _contactSlotHasText(int slot) {
    switch (slot) {
      case 1:
        return _hasContactText(
          _model.c1FirstTFTextController?.text ?? '',
          _model.c1LastTFTextController?.text ?? '',
          _model.c1PhoneTFTextController?.text ?? '',
        );
      case 2:
        return _hasContactText(
          _model.c2FirstTFTextController?.text ?? '',
          _model.c2LastTFTextController?.text ?? '',
          _model.c2PhoneTFTextController?.text ?? '',
        );
      case 3:
        return _hasContactText(
          _model.c3FirstTFTextController?.text ?? '',
          _model.c3LastTFTextController?.text ?? '',
          _model.c3PhoneTFTextController?.text ?? '',
        );
      case 4:
        return _hasContactText(
          _model.c4FirstTFTextController?.text ?? '',
          _model.c4LastTFTextController?.text ?? '',
          _model.c4PhoneTFTextController?.text ?? '',
        );
      case 5:
        return _hasContactText(
          _model.c5FirstTFTextController?.text ?? '',
          _model.c5LastTFTextController?.text ?? '',
          _model.c5PhoneTFTextController?.text ?? '',
        );
      default:
        return false;
    }
  }

  void _raiseContactsCountTo(int slot) {
    if (slot > _model.contactsCount) {
      _model.contactsCount = slot.clamp(1, 5).toInt();
    }
  }

  void _syncContactsCountToLoadedFields() {
    for (var slot = 5; slot >= 1; slot--) {
      if (_contactSlotHasText(slot)) {
        _model.contactsCount = slot;
        return;
      }
    }
    _model.contactsCount = 1;
  }

  void _applyStoredContactsToFields() {
    if (_model.contactsObj == null ||
        getJsonField(_model.contactsObj, r'''$._ok''') == false) {
      return;
    }

    for (var index = 0; index < 5; index++) {
      final first = _jsonValue(
        _model.contactsObj,
        '\$.contacts[$index].first',
      );
      final last = _jsonValue(
        _model.contactsObj,
        '\$.contacts[$index].last',
      );
      final phone = _jsonValue(
        _model.contactsObj,
        '\$.contacts[$index].phone',
      );
      if (_hasContactText(first, last, phone)) {
        _setContactFields(
          index + 1,
          first: first,
          last: last,
          phone: phone,
        );
      }
    }
    _syncContactsCountToLoadedFields();
  }

  bool _applyLegacyContactPayload(dynamic payload) {
    dynamic decoded = payload;
    if (decoded is String) {
      final text = decoded.trim();
      if (text.isEmpty || text.toLowerCase() == 'null') return false;
      try {
        decoded = jsonDecode(text);
      } catch (_) {
        return false;
      }
    }

    dynamic contacts;
    if (decoded is List) {
      contacts = decoded;
    } else if (decoded is Map) {
      contacts = decoded['contacts'] ??
          decoded['emergencyContacts'] ??
          decoded['emergency_contacts'] ??
          decoded['contactsJson'];
      if (contacts is String) {
        try {
          contacts = jsonDecode(contacts);
        } catch (_) {
          contacts = null;
        }
      }
    }

    if (contacts is! List) return false;

    var applied = false;
    for (var index = 0; index < contacts.length && index < 5; index++) {
      final contact = contacts[index];
      if (contact is! Map) continue;
      final slot = int.tryParse(_cleanLoadedValue(contact['slot'])) ??
          int.tryParse(_cleanLoadedValue(contact['contact_slot'])) ??
          index + 1;
      if (slot < 1 || slot > 5 || _contactSlotHasText(slot)) continue;

      final first = _cleanLoadedValue(
        contact['first'] ?? contact['firstName'] ?? contact['first_name'],
      );
      final last = _cleanLoadedValue(
        contact['last'] ?? contact['lastName'] ?? contact['last_name'],
      );
      final phone = _cleanLoadedValue(
        contact['phone'] ?? contact['phoneNumber'] ?? contact['phone_number'],
      );
      if (!_hasContactText(first, last, phone)) continue;

      _setContactFields(
        slot,
        first: first,
        last: last,
        phone: phone,
      );
      _setContactSlotStatus(
        slot,
        functions.emergencyContactStatusLabel(
          contact['consent_status'] ?? contact['status'],
        ),
      );
      _raiseContactsCountTo(slot);
      applied = true;
    }

    return applied;
  }

  void _applyConsentDetailsFallbacks() {
    if (!(_model.topConsentResp?.succeeded ?? false)) return;

    final body = _model.topConsentResp?.jsonBody ?? '';
    void apply(
      int slot,
      dynamic first,
      dynamic last,
      dynamic phone, [
      dynamic status,
    ]) {
      if (_contactSlotHasText(slot)) return;
      final cleanFirst = _cleanLoadedValue(first);
      final cleanLast = _cleanLoadedValue(last);
      final cleanPhone = _cleanLoadedValue(phone);
      if (!_hasContactText(cleanFirst, cleanLast, cleanPhone)) return;

      _setContactFields(
        slot,
        first: cleanFirst,
        last: cleanLast,
        phone: cleanPhone,
      );
      final cleanStatus = functions.emergencyContactStatusLabel(status);
      if (cleanStatus != 'Not sent') {
        _setContactSlotStatus(slot, cleanStatus);
      }
      _raiseContactsCountTo(slot);
    }

    apply(
      1,
      GetConsentStatusesCall.slot1First(body),
      GetConsentStatusesCall.slot1Last(body),
      GetConsentStatusesCall.slot1Phone(body),
    );
    apply(
      2,
      GetConsentStatusesCall.slot2First(body),
      GetConsentStatusesCall.slot2Last(body),
      GetConsentStatusesCall.slot2Phone(body),
    );
    apply(
      3,
      GetConsentStatusesCall.slot3First(body),
      GetConsentStatusesCall.slot3Last(body),
      GetConsentStatusesCall.slot3Phone(body),
    );
    apply(
      4,
      GetConsentStatusesCall.slot4First(body),
      GetConsentStatusesCall.slot4Last(body),
      GetConsentStatusesCall.slot4Phone(body),
    );
    apply(
      5,
      GetConsentStatusesCall.slot5First(body),
      GetConsentStatusesCall.slot5Last(body),
      GetConsentStatusesCall.slot5Phone(body),
    );

    final consents = GetConsentStatusesCall.consents(body);
    if (consents is List) {
      for (final consent in consents) {
        if (consent is! Map) continue;
        final slot = int.tryParse(_cleanLoadedValue(consent['contact_slot'])) ??
            int.tryParse(_cleanLoadedValue(consent['contactSlot'])) ??
            int.tryParse(_cleanLoadedValue(consent['slot']));
        if (slot == null || slot < 1 || slot > 5) continue;

        apply(
          slot,
          consent['first_name'] ?? consent['firstName'] ?? consent['first'],
          consent['last_name'] ?? consent['lastName'] ?? consent['last'],
          consent['phone_number'] ?? consent['phoneNumber'] ?? consent['phone'],
          consent['status'] ?? consent['consent_status'],
        );
      }
      _debugLog(
        '[EmergencyContacts] consent fallback rows: ${consents.length}',
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EmergencyContactsModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final hydratedFromSession = _hydrateSessionContactsCache();
      if (hydratedFromSession) {
        safeSetState(() {});
      } else if (await _hydrateEncryptedContactsCache()) {
        _rememberSessionContactsCache();
        safeSetState(() {});
      }

      final apiJwt = await _jwtForApi();
      final Future<ApiCallResponse?> consentStatusFuture =
          GetConsentStatusesCall.call(
        jwt: apiJwt,
      ).then<ApiCallResponse?>((response) => response).catchError((error) {
        _debugLog('[EmergencyContacts] consent status load threw: $error');
        return null;
      });
      _model.rows = await DecoyWalletTable().queryRows(
        queryFn: (q) => q
            .eqOrNull(
              'user_id',
              currentUserUid,
            )
            .order('updated_at', ascending: false),
        limit: 10,
      );
      if (_model.rows != null && (_model.rows)!.isNotEmpty) {
        final selectedRow = _model.rows!.firstWhere(
          (row) =>
              (row.contactsCiphertext ?? '').trim().isNotEmpty &&
              (row.contactsNonce ?? '').trim().isNotEmpty,
          orElse: () => _model.rows!.first,
        );
        _model.rowCipherB64 = selectedRow.contactsCiphertext;
        _model.rowNonceB64 = selectedRow.contactsNonce;
        _model.wrappedB64 = selectedRow.wrappedDatakey ?? '';
        safeSetState(() {});
        final hasSavedContactPayload =
            (_model.rowCipherB64 ?? '').trim().isNotEmpty &&
                (_model.rowNonceB64 ?? '').trim().isNotEmpty;
        _debugLog(
          '[EmergencyContacts] saved contact payload: '
          'rows=${_model.rows?.length ?? 0}, selectedHasContacts=$hasSavedContactPayload, cipher=${(_model.rowCipherB64 ?? '').trim().isNotEmpty}, '
          'nonce=${(_model.rowNonceB64 ?? '').trim().isNotEmpty}, wrapped=${_model.wrappedB64.trim().isNotEmpty}',
        );
        if (hasSavedContactPayload) {
          _model.dataKeyOut = _model.wrappedB64.trim().isNotEmpty
              ? await _dataKeyForWrappedRow(
                  _model.wrappedB64,
                  allowCreateFallback: false,
                )
              : await _storedDataKeyOrNull();
          if ((_model.dataKeyOut ?? '').trim().isNotEmpty) {
            _model.dataKeyB64 = _model.dataKeyOut!;
            safeSetState(() {});
            _model.contactsObj = await actions.aesGcmDecryptToMap(
              _model.rowCipherB64!,
              _model.rowNonceB64!,
              _model.dataKeyB64,
            );
          } else {
            _model.contactsObj = {
              '_ok': false,
              '_error': 'missing data key',
            };
          }
          _model.contactsJson = _model.contactsObj!.toString();
          if (getJsonField(_model.contactsObj, r'''$._ok''') == false) {
            _debugLog(
              '[EmergencyContacts] contacts decrypt failed: '
              '${getJsonField(_model.contactsObj, r'''$._error''')}',
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'ERROR #008 - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT',
                  style: TextStyle(
                    color: FlutterFlowTheme.of(context).primaryText,
                  ),
                ),
                duration: Duration(milliseconds: 4000),
                backgroundColor: FlutterFlowTheme.of(context).secondary,
              ),
            );
          } else {
            await _rememberEncryptedContactsCache(
              cipherB64: _model.rowCipherB64!,
              nonceB64: _model.rowNonceB64!,
              wrappedB64: _model.wrappedB64,
            );
          }
          _applyStoredContactsToFields();
          safeSetState(() {});
          _model.contactsCount = () {
            if (getJsonField(
                  _model.contactsObj,
                  r'''$.contacts[4].first''',
                ) !=
                null) {
              return (5);
            } else if (getJsonField(
                  _model.contactsObj,
                  r'''$.contacts[3].first''',
                ) !=
                null) {
              return (4);
            } else if (getJsonField(
                  _model.contactsObj,
                  r'''$.contacts[2].first''',
                ) !=
                null) {
              return (3);
            } else if (getJsonField(
                  _model.contactsObj,
                  r'''$.contacts[1].first''',
                ) !=
                null) {
              return (2);
            } else if (getJsonField(
                  _model.contactsObj,
                  r'''$.contacts[0].first''',
                ) !=
                null) {
              return (1);
            } else {
              return 1;
            }
          }();
          if (!(_model.topConsentResp?.succeeded ?? false)) {
            _applyStoredConsentStatusFallbacks();
          }
          safeSetState(() {});
          if (getJsonField(
                _model.contactsObj,
                r'''$.contacts[0].first''',
              ) ==
              null) {
            safeSetState(() {
              _model.c1FirstTFTextController?.text = '';
            });
          } else {
            safeSetState(() {
              _model.c1FirstTFTextController?.text = getJsonField(
                _model.contactsObj,
                r'''$.contacts[0].first''',
              ).toString();
            });
          }

          if (getJsonField(
                _model.contactsObj,
                r'''$.contacts[0].last''',
              ) ==
              null) {
            safeSetState(() {
              _model.c1LastTFTextController?.text = '';
            });
          } else {
            safeSetState(() {
              _model.c1LastTFTextController?.text = getJsonField(
                _model.contactsObj,
                r'''$.contacts[0].last''',
              ).toString();
            });
          }

          if (getJsonField(
                _model.contactsObj,
                r'''$.contacts[0].phone''',
              ) ==
              null) {
            safeSetState(() {
              _model.c1PhoneTFTextController?.text = '';
              _model.c1PhoneTFMask.updateMask(
                newValue: TextEditingValue(
                  text: _model.c1PhoneTFTextController!.text,
                ),
              );
            });
          } else {
            safeSetState(() {
              _model.c1PhoneTFTextController?.text =
                  functions.displayUSPhone(getJsonField(
                _model.contactsObj,
                r'''$.contacts[0].phone''',
              ).toString());
              _model.c1PhoneTFMask.updateMask(
                newValue: TextEditingValue(
                  text: _model.c1PhoneTFTextController!.text,
                ),
              );
            });
          }

          if (getJsonField(
                _model.contactsObj,
                r'''$.contacts[1].first''',
              ) ==
              null) {
            safeSetState(() {
              _model.c2FirstTFTextController?.text = '';
            });
          } else {
            safeSetState(() {
              _model.c2FirstTFTextController?.text = getJsonField(
                _model.contactsObj,
                r'''$.contacts[1].first''',
              ).toString();
            });
          }

          if (getJsonField(
                _model.contactsObj,
                r'''$.contacts[1].last''',
              ) ==
              null) {
            safeSetState(() {
              _model.c2LastTFTextController?.text = '';
            });
          } else {
            safeSetState(() {
              _model.c2LastTFTextController?.text = getJsonField(
                _model.contactsObj,
                r'''$.contacts[1].last''',
              ).toString();
            });
          }

          if (getJsonField(
                _model.contactsObj,
                r'''$.contacts[1].phone''',
              ) ==
              null) {
            safeSetState(() {
              _model.c2PhoneTFTextController?.text = '';
              _model.c2PhoneTFMask.updateMask(
                newValue: TextEditingValue(
                  text: _model.c2PhoneTFTextController!.text,
                ),
              );
            });
          } else {
            safeSetState(() {
              _model.c2PhoneTFTextController?.text =
                  functions.displayUSPhone(getJsonField(
                _model.contactsObj,
                r'''$.contacts[1].phone''',
              ).toString());
              _model.c2PhoneTFMask.updateMask(
                newValue: TextEditingValue(
                  text: _model.c2PhoneTFTextController!.text,
                ),
              );
            });
          }

          if (getJsonField(
                _model.contactsObj,
                r'''$.contacts[2].first''',
              ) ==
              null) {
            safeSetState(() {
              _model.c3FirstTFTextController?.text = '';
            });
          } else {
            safeSetState(() {
              _model.c3FirstTFTextController?.text = getJsonField(
                _model.contactsObj,
                r'''$.contacts[2].first''',
              ).toString();
            });
          }

          if (getJsonField(
                _model.contactsObj,
                r'''$.contacts[2].last''',
              ) ==
              null) {
            safeSetState(() {
              _model.c3LastTFTextController?.text = '';
            });
          } else {
            safeSetState(() {
              _model.c3LastTFTextController?.text = getJsonField(
                _model.contactsObj,
                r'''$.contacts[2].last''',
              ).toString();
            });
          }

          if (getJsonField(
                _model.contactsObj,
                r'''$.contacts[2].phone''',
              ) ==
              null) {
            safeSetState(() {
              _model.c3PhoneTFTextController?.text = '';
              _model.c3PhoneTFMask.updateMask(
                newValue: TextEditingValue(
                  text: _model.c3PhoneTFTextController!.text,
                ),
              );
            });
          } else {
            safeSetState(() {
              _model.c3PhoneTFTextController?.text =
                  functions.displayUSPhone(getJsonField(
                _model.contactsObj,
                r'''$.contacts[2].phone''',
              ).toString());
              _model.c3PhoneTFMask.updateMask(
                newValue: TextEditingValue(
                  text: _model.c3PhoneTFTextController!.text,
                ),
              );
            });
          }

          if (getJsonField(
                _model.contactsObj,
                r'''$.contacts[3].first''',
              ) ==
              null) {
            safeSetState(() {
              _model.c4FirstTFTextController?.text = '';
            });
          } else {
            safeSetState(() {
              _model.c4FirstTFTextController?.text = getJsonField(
                _model.contactsObj,
                r'''$.contacts[3].first''',
              ).toString();
            });
          }

          if (getJsonField(
                _model.contactsObj,
                r'''$.contacts[3].last''',
              ) ==
              null) {
            safeSetState(() {
              _model.c4LastTFTextController?.text = '';
            });
          } else {
            safeSetState(() {
              _model.c4LastTFTextController?.text = getJsonField(
                _model.contactsObj,
                r'''$.contacts[3].last''',
              ).toString();
            });
          }

          if (getJsonField(
                _model.contactsObj,
                r'''$.contacts[3].phone''',
              ) ==
              null) {
            safeSetState(() {
              _model.c4PhoneTFTextController?.text = '';
              _model.c4PhoneTFMask.updateMask(
                newValue: TextEditingValue(
                  text: _model.c4PhoneTFTextController!.text,
                ),
              );
            });
          } else {
            safeSetState(() {
              _model.c4PhoneTFTextController?.text =
                  functions.displayUSPhone(getJsonField(
                _model.contactsObj,
                r'''$.contacts[3].phone''',
              ).toString());
              _model.c4PhoneTFMask.updateMask(
                newValue: TextEditingValue(
                  text: _model.c4PhoneTFTextController!.text,
                ),
              );
            });
          }

          if (getJsonField(
                _model.contactsObj,
                r'''$.contacts[4].first''',
              ) ==
              null) {
            safeSetState(() {
              _model.c5FirstTFTextController?.text = '';
            });
          } else {
            safeSetState(() {
              _model.c5FirstTFTextController?.text = getJsonField(
                _model.contactsObj,
                r'''$.contacts[4].first''',
              ).toString();
            });
          }

          if (getJsonField(
                _model.contactsObj,
                r'''$.contacts[4].last''',
              ) ==
              null) {
            safeSetState(() {
              _model.c5LastTFTextController?.text = '';
            });
          } else {
            safeSetState(() {
              _model.c5LastTFTextController?.text = getJsonField(
                _model.contactsObj,
                r'''$.contacts[4].last''',
              ).toString();
            });
          }

          if (getJsonField(
                _model.contactsObj,
                r'''$.contacts[4].phone''',
              ) ==
              null) {
            safeSetState(() {
              _model.c5PhoneTFTextController?.text = '';
              _model.c5PhoneTFMask.updateMask(
                newValue: TextEditingValue(
                  text: _model.c5PhoneTFTextController!.text,
                ),
              );
            });
          } else {
            safeSetState(() {
              _model.c5PhoneTFTextController?.text =
                  functions.displayUSPhone(getJsonField(
                _model.contactsObj,
                r'''$.contacts[4].phone''',
              ).toString());
              _model.c5PhoneTFMask.updateMask(
                newValue: TextEditingValue(
                  text: _model.c5PhoneTFTextController!.text,
                ),
              );
            });
          }
        } else {
          await _clearEncryptedContactsCache();
          _model.dataKeyOut2 = _model.wrappedB64.trim().isNotEmpty
              ? await _dataKeyForWrappedRow(_model.wrappedB64)
              : await _newOrStoredDataKey();
          _model.dataKeyB64 = _model.dataKeyOut2!;
          safeSetState(() {});
        }
      } else {
        await _clearEncryptedContactsCache();
        _model.dataKeyOut2 = await _newOrStoredDataKey();
        _model.dataKeyB64 = _model.dataKeyOut2!;
        safeSetState(() {});
        safeSetState(() {
          _model.c1FirstTFTextController?.text = _model.c1First;

          _model.c1LastTFTextController?.text = _model.c1Last;

          _model.c1PhoneTFTextController?.text = _model.c1Phone;

          _model.c1PhoneTFMask.updateMask(
            newValue: TextEditingValue(text: _model.c1Phone),
          );
          _model.c2FirstTFTextController?.text = _model.c2First;

          _model.c2LastTFTextController?.text = _model.c2Last;

          _model.c2PhoneTFTextController?.text = _model.c2Phone;

          _model.c2PhoneTFMask.updateMask(
            newValue: TextEditingValue(text: _model.c2Phone),
          );
          _model.c3FirstTFTextController?.text = _model.c3First;

          _model.c3LastTFTextController?.text = _model.c3Last;

          _model.c3PhoneTFTextController?.text = _model.c3Phone;

          _model.c3PhoneTFMask.updateMask(
            newValue: TextEditingValue(text: _model.c3Phone),
          );
          _model.c4FirstTFTextController?.text = _model.c4First;

          _model.c4LastTFTextController?.text = _model.c4Last;

          _model.c4PhoneTFTextController?.text = _model.c4Phone;

          _model.c4PhoneTFMask.updateMask(
            newValue: TextEditingValue(text: _model.c4Phone),
          );
          _model.c5FirstTFTextController?.text = _model.c5First;

          _model.c5LastTFTextController?.text = _model.c5Last;

          _model.c5PhoneTFTextController?.text = _model.c5Phone;

          _model.c5PhoneTFMask.updateMask(
            newValue: TextEditingValue(text: _model.c5Phone),
          );
        });
      }
      _model.topConsentResp = await consentStatusFuture;
      _debugLog(
        '[EmergencyContacts] consent status load: '
        'status=${_model.topConsentResp?.statusCode}, jwt=${apiJwt.isNotEmpty}',
      );

      if ((_model.topConsentResp?.succeeded ?? false)) {
        _model.c1Status = functions
            .emergencyContactStatusLabel(GetConsentStatusesCall.slot1Status(
          (_model.topConsentResp?.jsonBody ?? ''),
        )?.toString());
        _model.c2Status = functions
            .emergencyContactStatusLabel(GetConsentStatusesCall.slot2Status(
          (_model.topConsentResp?.jsonBody ?? ''),
        )?.toString());
        _model.c3Status = functions
            .emergencyContactStatusLabel(GetConsentStatusesCall.slot3Status(
          (_model.topConsentResp?.jsonBody ?? ''),
        )?.toString());
        _model.c4Status = functions
            .emergencyContactStatusLabel(GetConsentStatusesCall.slot4Status(
          (_model.topConsentResp?.jsonBody ?? ''),
        )?.toString());
        _model.c5Status = functions
            .emergencyContactStatusLabel(GetConsentStatusesCall.slot5Status(
          (_model.topConsentResp?.jsonBody ?? ''),
        )?.toString());
        safeSetState(() {});
      }
      _applyConsentDetailsFallbacks();
      _syncContactsCountToLoadedFields();
      _rememberSessionContactsCache();
      safeSetState(() {});
    });

    _model.c1FirstTFTextController ??=
        TextEditingController(text: _model.c1First);
    _model.c1FirstTFFocusNode ??= FocusNode();

    _model.c1LastTFTextController ??=
        TextEditingController(text: _model.c1Last);
    _model.c1LastTFFocusNode ??= FocusNode();

    _model.c1PhoneTFTextController ??=
        TextEditingController(text: _model.c1Phone);
    _model.c1PhoneTFFocusNode ??= FocusNode();

    _model.c1PhoneTFMask = MaskTextInputFormatter(mask: '(###) ###-####');
    _model.c2FirstTFTextController ??=
        TextEditingController(text: _model.c2First);
    _model.c2FirstTFFocusNode ??= FocusNode();

    _model.c2LastTFTextController ??=
        TextEditingController(text: _model.c2Last);
    _model.c2LastTFFocusNode ??= FocusNode();

    _model.c2PhoneTFTextController ??=
        TextEditingController(text: _model.c2Phone);
    _model.c2PhoneTFFocusNode ??= FocusNode();

    _model.c2PhoneTFMask = MaskTextInputFormatter(mask: '(###) ###-####');
    _model.c3FirstTFTextController ??=
        TextEditingController(text: _model.c3First);
    _model.c3FirstTFFocusNode ??= FocusNode();

    _model.c3LastTFTextController ??=
        TextEditingController(text: _model.c3Last);
    _model.c3LastTFFocusNode ??= FocusNode();

    _model.c3PhoneTFTextController ??=
        TextEditingController(text: _model.c3Phone);
    _model.c3PhoneTFFocusNode ??= FocusNode();

    _model.c3PhoneTFMask = MaskTextInputFormatter(mask: '(###) ###-####');
    _model.c4FirstTFTextController ??=
        TextEditingController(text: _model.c4First);
    _model.c4FirstTFFocusNode ??= FocusNode();

    _model.c4LastTFTextController ??=
        TextEditingController(text: _model.c4Last);
    _model.c4LastTFFocusNode ??= FocusNode();

    _model.c4PhoneTFTextController ??=
        TextEditingController(text: _model.c4Phone);
    _model.c4PhoneTFFocusNode ??= FocusNode();

    _model.c4PhoneTFMask = MaskTextInputFormatter(mask: '(###) ###-####');
    _model.c5FirstTFTextController ??=
        TextEditingController(text: _model.c5First);
    _model.c5FirstTFFocusNode ??= FocusNode();

    _model.c5LastTFTextController ??=
        TextEditingController(text: _model.c5Last);
    _model.c5LastTFFocusNode ??= FocusNode();

    _model.c5PhoneTFTextController ??=
        TextEditingController(text: _model.c5Phone);
    _model.c5PhoneTFFocusNode ??= FocusNode();

    _model.c5PhoneTFMask = MaskTextInputFormatter(mask: '(###) ###-####');
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _contactsListController.dispose();
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: PopScope(
        canPop: false,
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: Colors.white,
          body: SafeArea(
            top: true,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Align(
                      alignment: AlignmentDirectional(-1.0, 0.0),
                      child: Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 0.0, 0.0),
                        child: FlutterFlowIconButton(
                          borderColor: Colors.transparent,
                          borderRadius: 20.0,
                          buttonSize: 40.0,
                          icon: Icon(
                            Icons.arrow_back_rounded,
                            color: FlutterFlowTheme.of(context).primaryText,
                            size: 24.0,
                          ),
                          onPressed: () async {
                            context.safePop();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 20.0),
                  child: Material(
                    color: Colors.transparent,
                    elevation: 5.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Container(
                      width: 250.0,
                      height: 120.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).primary,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      alignment: AlignmentDirectional(0.0, 0.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 12.0, 0.0, 0.0),
                            child: Stack(
                              children: [
                                Align(
                                  alignment: AlignmentDirectional(-0.01, 0.0),
                                  child: Text(
                                    'EMERGENCY',
                                    textAlign: TextAlign.center,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'DECOY BEBAS',
                                          color:
                                              FlutterFlowTheme.of(context).info,
                                          fontSize: 48.0,
                                          letterSpacing: 0.5,
                                          fontWeight: FontWeight.normal,
                                          lineHeight: 1.0,
                                        ),
                                  ),
                                ),
                                Align(
                                  alignment: AlignmentDirectional(0.01, 0.0),
                                  child: Text(
                                    'EMERGENCY',
                                    textAlign: TextAlign.center,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'DECOY BEBAS',
                                          color:
                                              FlutterFlowTheme.of(context).info,
                                          fontSize: 48.0,
                                          letterSpacing: 0.5,
                                          fontWeight: FontWeight.normal,
                                          lineHeight: 1.0,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Stack(
                                children: [
                                  Align(
                                    alignment: AlignmentDirectional(0.01, 0.0),
                                    child: Text(
                                      'CONTACTS',
                                      textAlign: TextAlign.center,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'DECOY BEBAS',
                                            color: FlutterFlowTheme.of(context)
                                                .info,
                                            fontSize: 48.0,
                                            letterSpacing: 0.5,
                                            fontWeight: FontWeight.normal,
                                            lineHeight: 1.0,
                                          ),
                                    ),
                                  ),
                                  Align(
                                    alignment: AlignmentDirectional(-0.01, 0.0),
                                    child: Text(
                                      'CONTACTS',
                                      textAlign: TextAlign.center,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'DECOY BEBAS',
                                            color: FlutterFlowTheme.of(context)
                                                .info,
                                            fontSize: 48.0,
                                            letterSpacing: 0.5,
                                            fontWeight: FontWeight.normal,
                                            lineHeight: 1.0,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: _contactsListController,
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Form(
                            key: _model.formKey,
                            autovalidateMode: AutovalidateMode.disabled,
                            child: Align(
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    16.0, 0.0, 16.0, 0.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (_model.contactsCount >= 1)
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            16.0, 16.0, 16.0, 0.0),
                                        child: Material(
                                          color: Colors.transparent,
                                          elevation: 3.0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          child: Container(
                                            width: 400.0,
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                              border: Border.all(
                                                color: valueOrDefault<Color>(
                                                  () {
                                                    if (_model.c1Status ==
                                                        'Confirmed') {
                                                      return Color(0xFF0CD40B);
                                                    } else if (_model
                                                            .c1Status ==
                                                        'Pending') {
                                                      return FlutterFlowTheme
                                                              .of(context)
                                                          .primary;
                                                    } else if (_model
                                                            .c1Status ==
                                                        'Denied') {
                                                      return FlutterFlowTheme
                                                              .of(context)
                                                          .error;
                                                    } else if (_model
                                                            .c1Status ==
                                                        'Opted out') {
                                                      return FlutterFlowTheme
                                                              .of(context)
                                                          .error;
                                                    } else if (_model
                                                            .c1Status ==
                                                        'Not sent') {
                                                      return FlutterFlowTheme
                                                              .of(context)
                                                          .primary;
                                                    } else {
                                                      return FlutterFlowTheme
                                                              .of(context)
                                                          .primary;
                                                    }
                                                  }(),
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                                ),
                                                width: 2.5,
                                              ),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(16.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Contact 1',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleMedium
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleMediumFamily,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleMediumIsCustom,
                                                                ),
                                                      ),
                                                      FlutterFlowIconButton(
                                                        borderRadius: 16.0,
                                                        buttonSize: 32.0,
                                                        fillColor:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        icon: Icon(
                                                          Icons.delete_outline,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .info,
                                                          size: 16.0,
                                                        ),
                                                        onPressed: () async {
                                                          _deleteContactSlot(1);
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  if (_shouldShowContactEntryChoice(
                                                      1))
                                                    _buildContactEntryChoice(1)
                                                  else ...[
                                                    TextFormField(
                                                      controller: _model
                                                          .c1FirstTFTextController,
                                                      focusNode: _model
                                                          .c1FirstTFFocusNode,
                                                      autofocus: false,
                                                      textCapitalization:
                                                          TextCapitalization
                                                              .words,
                                                      textInputAction:
                                                          TextInputAction.next,
                                                      obscureText: false,
                                                      decoration:
                                                          InputDecoration(
                                                        hintText: 'First Name',
                                                        hintStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily,
                                                                  letterSpacing:
                                                                      0.25,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMediumIsCustom,
                                                                ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color:
                                                                valueOrDefault<
                                                                    Color>(
                                                              () {
                                                                if (_model
                                                                        .c1Status ==
                                                                    'Confirmed') {
                                                                  return Color(
                                                                      0xFF0CD40B);
                                                                } else if (_model
                                                                        .c1Status ==
                                                                    'Pending') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary;
                                                                } else if (_model
                                                                        .c1Status ==
                                                                    'Denied') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .error;
                                                                } else if (_model
                                                                        .c1Status ==
                                                                    'Opted out') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .error;
                                                                } else if (_model
                                                                        .c1Status ==
                                                                    'Not sent') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary;
                                                                } else {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary;
                                                                }
                                                              }(),
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .primary,
                                                            ),
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        errorBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: Color(
                                                                0x00000000),
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        focusedErrorBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: Color(
                                                                0x00000000),
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                      ),
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            fontSize: 16.0,
                                                            letterSpacing: 0.25,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                      keyboardType:
                                                          TextInputType.name,
                                                      cursorColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                      validator: _model
                                                          .c1FirstTFTextControllerValidator
                                                          .asValidator(context),
                                                      inputFormatters: [
                                                        if (!isAndroid &&
                                                            !isiOS)
                                                          TextInputFormatter
                                                              .withFunction(
                                                                  (oldValue,
                                                                      newValue) {
                                                            return TextEditingValue(
                                                              selection: newValue
                                                                  .selection,
                                                              text: newValue
                                                                  .text
                                                                  .toCapitalization(
                                                                      TextCapitalization
                                                                          .words),
                                                            );
                                                          }),
                                                      ],
                                                    ),
                                                    TextFormField(
                                                      controller: _model
                                                          .c1LastTFTextController,
                                                      focusNode: _model
                                                          .c1LastTFFocusNode,
                                                      autofocus: false,
                                                      textCapitalization:
                                                          TextCapitalization
                                                              .words,
                                                      textInputAction:
                                                          TextInputAction.next,
                                                      obscureText: false,
                                                      decoration:
                                                          InputDecoration(
                                                        hintText: 'Last Name',
                                                        hintStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily,
                                                                  letterSpacing:
                                                                      0.25,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMediumIsCustom,
                                                                ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color:
                                                                valueOrDefault<
                                                                    Color>(
                                                              () {
                                                                if (_model
                                                                        .c1Status ==
                                                                    'Confirmed') {
                                                                  return Color(
                                                                      0xFF0CD40B);
                                                                } else if (_model
                                                                        .c1Status ==
                                                                    'Pending') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary;
                                                                } else if (_model
                                                                        .c1Status ==
                                                                    'Denied') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .error;
                                                                } else if (_model
                                                                        .c1Status ==
                                                                    'Opted out') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .error;
                                                                } else if (_model
                                                                        .c1Status ==
                                                                    'Not sent') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary;
                                                                } else {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary;
                                                                }
                                                              }(),
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .primary,
                                                            ),
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        errorBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: Color(
                                                                0x00000000),
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        focusedErrorBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: Color(
                                                                0x00000000),
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                      ),
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            fontSize: 16.0,
                                                            letterSpacing: 0.25,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                      keyboardType:
                                                          TextInputType.name,
                                                      cursorColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                      validator: _model
                                                          .c1LastTFTextControllerValidator
                                                          .asValidator(context),
                                                      inputFormatters: [
                                                        if (!isAndroid &&
                                                            !isiOS)
                                                          TextInputFormatter
                                                              .withFunction(
                                                                  (oldValue,
                                                                      newValue) {
                                                            return TextEditingValue(
                                                              selection: newValue
                                                                  .selection,
                                                              text: newValue
                                                                  .text
                                                                  .toCapitalization(
                                                                      TextCapitalization
                                                                          .words),
                                                            );
                                                          }),
                                                      ],
                                                    ),
                                                    TextFormField(
                                                      controller: _model
                                                          .c1PhoneTFTextController,
                                                      focusNode: _model
                                                          .c1PhoneTFFocusNode,
                                                      onChanged: (_) {
                                                        _resetConsentStatusAfterPhoneEdit(
                                                            1);
                                                        EasyDebounce.debounce(
                                                          '_model.c1PhoneTFTextController',
                                                          Duration(
                                                              milliseconds:
                                                                  2000),
                                                          () async {
                                                            _model.c1PhoneDigits =
                                                                functions.sanitizePhoneDigits(
                                                                    _model
                                                                        .c1PhoneTFTextController
                                                                        .text);
                                                            safeSetState(() {});
                                                            if ((_model.c1PhoneDigits !=
                                                                        null &&
                                                                    _model.c1PhoneDigits !=
                                                                        '') &&
                                                                ((_model.c1PhoneDigits!)
                                                                        .length ==
                                                                    10)) {
                                                              safeSetState(() {
                                                                _model.c1PhoneTFTextController
                                                                        ?.text =
                                                                    functions.formatAsUsPhone(
                                                                        _model
                                                                            .c1PhoneDigits!);
                                                                _model
                                                                    .c1PhoneTFMask
                                                                    .updateMask(
                                                                  newValue:
                                                                      TextEditingValue(
                                                                    text: _model
                                                                        .c1PhoneTFTextController!
                                                                        .text,
                                                                  ),
                                                                );
                                                              });
                                                            }
                                                          },
                                                        );
                                                      },
                                                      autofocus: false,
                                                      enabled: true,
                                                      textInputAction:
                                                          TextInputAction.next,
                                                      obscureText: false,
                                                      decoration:
                                                          InputDecoration(
                                                        hintText:
                                                            'Phone Number',
                                                        hintStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily,
                                                                  letterSpacing:
                                                                      0.25,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMediumIsCustom,
                                                                ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color:
                                                                valueOrDefault<
                                                                    Color>(
                                                              () {
                                                                if (_model
                                                                        .c1Status ==
                                                                    'Confirmed') {
                                                                  return Color(
                                                                      0xFF0CD40B);
                                                                } else if (_model
                                                                        .c1Status ==
                                                                    'Pending') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary;
                                                                } else if (_model
                                                                        .c1Status ==
                                                                    'Denied') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .error;
                                                                } else if (_model
                                                                        .c1Status ==
                                                                    'Opted out') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .error;
                                                                } else if (_model
                                                                        .c1Status ==
                                                                    'Not sent') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary;
                                                                } else {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary;
                                                                }
                                                              }(),
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .primary,
                                                            ),
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        errorBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: Color(
                                                                0x00000000),
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        focusedErrorBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: Color(
                                                                0x00000000),
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                      ),
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            fontSize: 16.0,
                                                            letterSpacing: 0.25,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                      keyboardType:
                                                          TextInputType.phone,
                                                      cursorColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                      validator: _model
                                                          .c1PhoneTFTextControllerValidator
                                                          .asValidator(context),
                                                    ),
                                                    SizedBox(
                                                      height: 30.0,
                                                      child: Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                0.0, 0.0),
                                                        child: Container(
                                                          width:
                                                              double.infinity,
                                                          height: 30.0,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryBackground,
                                                          ),
                                                          child: Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0.0, 0.0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Align(
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          0.0),
                                                                  child: Text(
                                                                    'Status: ',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          fontFamily:
                                                                              FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                          fontSize:
                                                                              16.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          useGoogleFonts:
                                                                              !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                        ),
                                                                  ),
                                                                ),
                                                                Text(
                                                                  () {
                                                                    if (_model
                                                                            .c1Status ==
                                                                        'Not sent') {
                                                                      return 'Not sent';
                                                                    } else if (_model
                                                                            .c1Status ==
                                                                        'Pending') {
                                                                      return 'Pending';
                                                                    } else if (_model
                                                                            .c1Status ==
                                                                        'Confirmed') {
                                                                      return 'Confirmed';
                                                                    } else if (_model
                                                                            .c1Status ==
                                                                        'Denied') {
                                                                      return 'Denied';
                                                                    } else if (_model
                                                                            .c1Status ==
                                                                        'Opted out') {
                                                                      return 'Opted out';
                                                                    } else {
                                                                      return 'Not sent';
                                                                    }
                                                                  }(),
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        fontFamily:
                                                                            FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                        color: valueOrDefault<
                                                                            Color>(
                                                                          () {
                                                                            if (_model.c1Status ==
                                                                                'Confirmed') {
                                                                              return Color(0xFF0CD40B);
                                                                            } else if (_model.c1Status ==
                                                                                'Pending') {
                                                                              return FlutterFlowTheme.of(context).primary;
                                                                            } else if (_model.c1Status ==
                                                                                'Denied') {
                                                                              return FlutterFlowTheme.of(context).error;
                                                                            } else if (_model.c1Status ==
                                                                                'Opted out') {
                                                                              return FlutterFlowTheme.of(context).error;
                                                                            } else if (_model.c1Status ==
                                                                                'Not sent') {
                                                                              return FlutterFlowTheme.of(context).primaryText;
                                                                            } else {
                                                                              return FlutterFlowTheme.of(context).primary;
                                                                            }
                                                                          }(),
                                                                          FlutterFlowTheme.of(context)
                                                                              .primaryText,
                                                                        ),
                                                                        fontSize:
                                                                            16.0,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        useGoogleFonts:
                                                                            !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Stack(
                                                      children: [
                                                        Material(
                                                          color: Colors
                                                              .transparent,
                                                          elevation: 3.0,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                          ),
                                                          child: Container(
                                                            width: 300.0,
                                                            height: 50.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primary,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                            ),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                  _consentInviteButtonLabel(
                                                                      1,
                                                                      _model
                                                                          .c1Status),
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        fontFamily:
                                                                            FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .info,
                                                                        fontSize:
                                                                            18.0,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        useGoogleFonts:
                                                                            !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                      ),
                                                                ),
                                                                Icon(
                                                                  _consentInviteButtonIcon(
                                                                      1),
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .info,
                                                                  size: 24.0,
                                                                ),
                                                              ].divide(SizedBox(
                                                                  width: 12.0)),
                                                            ),
                                                          ),
                                                        ),
                                                        Opacity(
                                                          opacity: 0.0,
                                                          child: FFButtonWidget(
                                                            onPressed:
                                                                () async {
                                                              if (_showingConsentInviteSent(
                                                                  1)) {
                                                                return;
                                                              }
                                                              _model.c1PhoneDigits =
                                                                  functions.sanitizePhoneDigits(
                                                                      _model
                                                                          .c1PhoneTFTextController
                                                                          .text);
                                                              safeSetState(
                                                                  () {});
                                                              await actions
                                                                  .dismissKeyboard(
                                                                context,
                                                              );
                                                              _model.contactsPayloadslot1 =
                                                                  await actions
                                                                      .buildContactsPayloadV2(
                                                                _model
                                                                    .c1FirstTFTextController
                                                                    .text,
                                                                _model
                                                                    .c1LastTFTextController
                                                                    .text,
                                                                _model
                                                                    .c1PhoneTFTextController
                                                                    .text,
                                                                _model
                                                                    .c2FirstTFTextController
                                                                    .text,
                                                                _model
                                                                    .c2LastTFTextController
                                                                    .text,
                                                                _model
                                                                    .c2PhoneTFTextController
                                                                    .text,
                                                                _model
                                                                    .c3FirstTFTextController
                                                                    .text,
                                                                _model
                                                                    .c3LastTFTextController
                                                                    .text,
                                                                _model
                                                                    .c3PhoneTFTextController
                                                                    .text,
                                                                _model
                                                                    .c4FirstTFTextController
                                                                    .text,
                                                                _model
                                                                    .c4LastTFTextController
                                                                    .text,
                                                                _model
                                                                    .c4PhoneTFTextController
                                                                    .text,
                                                                _model
                                                                    .c5FirstTFTextController
                                                                    .text,
                                                                _model
                                                                    .c5LastTFTextController
                                                                    .text,
                                                                _model
                                                                    .c5PhoneTFTextController
                                                                    .text,
                                                                _model
                                                                    .contactsCount,
                                                                _model.c1Status,
                                                                _model.c2Status,
                                                                _model.c3Status,
                                                                _model.c4Status,
                                                                _model.c5Status,
                                                              );
                                                              _model.contactsJson =
                                                                  _model
                                                                      .contactsPayloadslot1!;
                                                              safeSetState(
                                                                  () {});
                                                              if (loggedIn ==
                                                                  true) {
                                                                _model.keyOutslot1 =
                                                                    await _currentRowDataKeyForSave();
                                                                _model.dataKeyB64 =
                                                                    _model
                                                                        .keyOutslot1!;
                                                                safeSetState(
                                                                    () {});
                                                                _model.encslot1 =
                                                                    await actions
                                                                        .aesGcmEncryptString(
                                                                  _model
                                                                      .contactsJson,
                                                                  _model
                                                                      .dataKeyB64,
                                                                );
                                                                _model.ctB64 =
                                                                    getJsonField(
                                                                  _model
                                                                      .encslot1,
                                                                  r'''$.ciphertextB64''',
                                                                ).toString();
                                                                _model.nonceB64 =
                                                                    getJsonField(
                                                                  _model
                                                                      .encslot1,
                                                                  r'''$.nonceB64''',
                                                                ).toString();
                                                                safeSetState(
                                                                    () {});
                                                                _model.wrapslot1 =
                                                                    await WrapDataKeyCall
                                                                        .call(
                                                                  dataKeyB64: _model
                                                                      .dataKeyB64,
                                                                  jwt:
                                                                      await _jwtForApi(),
                                                                );

                                                                if ((_model
                                                                        .wrapslot1
                                                                        ?.succeeded ??
                                                                    false)) {
                                                                  _model.wrappedB64 =
                                                                      _jsonValue(
                                                                    (_model.wrapslot1
                                                                            ?.jsonBody ??
                                                                        ''),
                                                                    r'''$.wrappedB64''',
                                                                  );
                                                                  safeSetState(
                                                                      () {});
                                                                  _model.updslot1 =
                                                                      await DecoyWalletTable()
                                                                          .queryRows(
                                                                    queryFn: (q) =>
                                                                        q.eqOrNull(
                                                                      'user_id',
                                                                      currentUserUid,
                                                                    ),
                                                                  );
                                                                  if (_model.updslot1 !=
                                                                          null &&
                                                                      (_model.updslot1)!
                                                                          .isNotEmpty) {
                                                                    await DecoyWalletTable()
                                                                        .update(
                                                                      data: {
                                                                        'wrapped_datakey':
                                                                            _model.wrappedB64,
                                                                        'updated_at':
                                                                            supaSerialize<DateTime>(getCurrentTimestamp),
                                                                        'contacts_ciphertext':
                                                                            _model.ctB64,
                                                                        'contacts_nonce':
                                                                            _model.nonceB64,
                                                                        'contacts_version':
                                                                            1,
                                                                        'created_at':
                                                                            supaSerialize<DateTime>(getCurrentTimestamp),
                                                                        'contacts_complete': functions.hasConfirmedEmergencyContact(
                                                                            _model.c1Status,
                                                                            _model.c2Status,
                                                                            _model.c3Status,
                                                                            _model.c4Status,
                                                                            _model.c5Status),
                                                                      },
                                                                      matchingRows:
                                                                          (rows) =>
                                                                              rows.eqOrNull(
                                                                        'user_id',
                                                                        currentUserUid,
                                                                      ),
                                                                    );
                                                                    _model.decoyWalletRefresh1slot1 =
                                                                        await DecoyWalletTable()
                                                                            .queryRows(
                                                                      queryFn:
                                                                          (q) =>
                                                                              q.eqOrNull(
                                                                        'user_id',
                                                                        currentUserUid,
                                                                      ),
                                                                    );
                                                                    FFAppState()
                                                                            .emergencyContactsIncrement =
                                                                        _model
                                                                            .contactsCount;
                                                                    safeSetState(
                                                                        () {});
                                                                  } else {
                                                                    _model.insRowslot1 =
                                                                        await DecoyWalletTable()
                                                                            .insert({
                                                                      'wrapped_datakey':
                                                                          _model
                                                                              .wrappedB64,
                                                                      'updated_at':
                                                                          supaSerialize<DateTime>(
                                                                              getCurrentTimestamp),
                                                                      'contacts_ciphertext':
                                                                          _model
                                                                              .ctB64,
                                                                      'contacts_nonce':
                                                                          _model
                                                                              .nonceB64,
                                                                      'contacts_version':
                                                                          1,
                                                                      'user_id':
                                                                          currentUserUid,
                                                                      'contacts_complete': functions.hasConfirmedEmergencyContact(
                                                                          _model
                                                                              .c1Status,
                                                                          _model
                                                                              .c2Status,
                                                                          _model
                                                                              .c3Status,
                                                                          _model
                                                                              .c4Status,
                                                                          _model
                                                                              .c5Status),
                                                                    });
                                                                    _model.decoyWalletRefresh2slot1 =
                                                                        await DecoyWalletTable()
                                                                            .queryRows(
                                                                      queryFn:
                                                                          (q) =>
                                                                              q.eqOrNull(
                                                                        'user_id',
                                                                        currentUserUid,
                                                                      ),
                                                                    );
                                                                    FFAppState()
                                                                            .emergencyContactsIncrement =
                                                                        _model
                                                                            .contactsCount;
                                                                    safeSetState(
                                                                        () {});
                                                                  }

                                                                  _model.consentSlotsList = functions
                                                                      .buildConsentSlotsListFINAL(
                                                                          _model
                                                                              .c1FirstTFTextController
                                                                              .text,
                                                                          _model
                                                                              .c1LastTFTextController
                                                                              .text,
                                                                          _model
                                                                              .c1PhoneTFTextController
                                                                              .text,
                                                                          _model
                                                                              .c1Status,
                                                                          _model
                                                                              .c2FirstTFTextController
                                                                              .text,
                                                                          _model
                                                                              .c2LastTFTextController
                                                                              .text,
                                                                          _model
                                                                              .c2PhoneTFTextController
                                                                              .text,
                                                                          _model
                                                                              .c2Status,
                                                                          _model
                                                                              .c3FirstTFTextController
                                                                              .text,
                                                                          _model
                                                                              .c3LastTFTextController
                                                                              .text,
                                                                          _model
                                                                              .c3PhoneTFTextController
                                                                              .text,
                                                                          _model
                                                                              .c3Status,
                                                                          _model
                                                                              .c4FirstTFTextController
                                                                              .text,
                                                                          _model
                                                                              .c4LastTFTextController
                                                                              .text,
                                                                          _model
                                                                              .c4PhoneTFTextController
                                                                              .text,
                                                                          _model
                                                                              .c4Status,
                                                                          _model
                                                                              .c5FirstTFTextController
                                                                              .text,
                                                                          _model
                                                                              .c5LastTFTextController
                                                                              .text,
                                                                          _model
                                                                              .c5PhoneTFTextController
                                                                              .text,
                                                                          _model
                                                                              .c5Status)
                                                                      .toList()
                                                                      .cast<
                                                                          dynamic>();
                                                                  safeSetState(
                                                                      () {});
                                                                  _model.syncConsentRespslot1 =
                                                                      await SyncConsentSlotsCall
                                                                          .call(
                                                                    jwt:
                                                                        currentJwtToken,
                                                                    slotsJsonJson:
                                                                        _model
                                                                            .consentSlotsList,
                                                                  );

                                                                  if ((_model
                                                                          .syncConsentRespslot1
                                                                          ?.succeeded ??
                                                                      true)) {
                                                                    _model.createConsentResp1 =
                                                                        await CreateConsentRequestCall
                                                                            .call(
                                                                      userId:
                                                                          currentUserUid,
                                                                      contactSlot:
                                                                          1,
                                                                      firstName: _model
                                                                          .c1FirstTFTextController
                                                                          .text,
                                                                      lastName: _model
                                                                          .c1LastTFTextController
                                                                          .text,
                                                                      phoneNumber:
                                                                          _model
                                                                              .c1PhoneDigits,
                                                                      jwt:
                                                                          currentJwtToken,
                                                                    );

                                                                    if ((_model
                                                                            .createConsentResp1
                                                                            ?.succeeded ??
                                                                        true)) {
                                                                      _model.c1Status =
                                                                          'Pending';
                                                                      _model.consentSlotsList = functions
                                                                          .buildConsentSlotsListFINAL(
                                                                              _model.c1FirstTFTextController.text,
                                                                              _model.c1LastTFTextController.text,
                                                                              _model.c1PhoneTFTextController.text,
                                                                              'Pending',
                                                                              _model.c2FirstTFTextController.text,
                                                                              _model.c2LastTFTextController.text,
                                                                              _model.c2PhoneTFTextController.text,
                                                                              _model.c2Status,
                                                                              _model.c3FirstTFTextController.text,
                                                                              _model.c3LastTFTextController.text,
                                                                              _model.c3PhoneTFTextController.text,
                                                                              _model.c3Status,
                                                                              _model.c4FirstTFTextController.text,
                                                                              _model.c4LastTFTextController.text,
                                                                              _model.c4PhoneTFTextController.text,
                                                                              _model.c4Status,
                                                                              _model.c5FirstTFTextController.text,
                                                                              _model.c5LastTFTextController.text,
                                                                              _model.c5PhoneTFTextController.text,
                                                                              _model.c5Status)
                                                                          .toList()
                                                                          .cast<dynamic>();
                                                                      safeSetState(
                                                                          () {});
                                                                      _showConsentInviteSent(
                                                                          1);

                                                                      _model.ohcoolDiffslot1 =
                                                                          await GetConsentStatusesCall
                                                                              .call(
                                                                        jwt:
                                                                            currentJwtToken,
                                                                      );

                                                                      if ((_model
                                                                              .ohcoolDiffslot1
                                                                              ?.succeeded ??
                                                                          true)) {
                                                                        _model.consentSlotsList = functions
                                                                            .buildConsentSlotsListFINAL(
                                                                                _model.c1FirstTFTextController.text,
                                                                                _model.c1LastTFTextController.text,
                                                                                _model.c1PhoneTFTextController.text,
                                                                                'Pending',
                                                                                _model.c2FirstTFTextController.text,
                                                                                _model.c2LastTFTextController.text,
                                                                                _model.c2PhoneTFTextController.text,
                                                                                _model.c2Status,
                                                                                _model.c3FirstTFTextController.text,
                                                                                _model.c3LastTFTextController.text,
                                                                                _model.c3PhoneTFTextController.text,
                                                                                _model.c3Status,
                                                                                _model.c4FirstTFTextController.text,
                                                                                _model.c4LastTFTextController.text,
                                                                                _model.c4PhoneTFTextController.text,
                                                                                _model.c4Status,
                                                                                _model.c5FirstTFTextController.text,
                                                                                _model.c5LastTFTextController.text,
                                                                                _model.c5PhoneTFTextController.text,
                                                                                _model.c5Status)
                                                                            .toList()
                                                                            .cast<dynamic>();
                                                                        _model.c1First =
                                                                            GetConsentStatusesCall.slot1First(
                                                                          (_model.ohcoolDiffslot1?.jsonBody ??
                                                                              ''),
                                                                        ).toString();
                                                                        _model.c1Last =
                                                                            GetConsentStatusesCall.slot1Last(
                                                                          (_model.ohcoolDiffslot1?.jsonBody ??
                                                                              ''),
                                                                        ).toString();
                                                                        _model.c1Phone =
                                                                            GetConsentStatusesCall.slot1Phone(
                                                                          (_model.ohcoolDiffslot1?.jsonBody ??
                                                                              ''),
                                                                        ).toString();
                                                                        safeSetState(
                                                                            () {});
                                                                      }
                                                                    }
                                                                  }
                                                                } else {
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    SnackBar(
                                                                      content:
                                                                          Text(
                                                                        'ERROR #009 - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT',
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryText,
                                                                        ),
                                                                      ),
                                                                      duration: Duration(
                                                                          milliseconds:
                                                                              4000),
                                                                      backgroundColor:
                                                                          FlutterFlowTheme.of(context)
                                                                              .secondary,
                                                                    ),
                                                                  );
                                                                }
                                                              } else {
                                                                context.goNamed(
                                                                    LoginPageWidget
                                                                        .routeName);
                                                              }

                                                              safeSetState(
                                                                  () {});
                                                            },
                                                            text: _model.c1Status ==
                                                                    'Not sent'
                                                                ? 'Send Confirmation Link'
                                                                : 'Resend Confirmation Link',
                                                            options:
                                                                FFButtonOptions(
                                                              width: 300.0,
                                                              height: 50.0,
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          16.0,
                                                                          0.0,
                                                                          16.0,
                                                                          0.0),
                                                              iconPadding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          0.0,
                                                                          0.0),
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primary,
                                                              textStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .override(
                                                                        fontFamily:
                                                                            FlutterFlowTheme.of(context).titleSmallFamily,
                                                                        color: Colors
                                                                            .white,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        useGoogleFonts:
                                                                            !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                      ),
                                                              elevation: 3.0,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.0),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ].divide(
                                                    SizedBox(height: 12.0)),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (_model.contactsCount >= 2)
                                      Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  16.0, 16.0, 16.0, 0.0),
                                          child: Material(
                                            color: Colors.transparent,
                                            elevation: 3.0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                            child: AnimatedContainer(
                                              duration:
                                                  Duration(milliseconds: 2000),
                                              curve: Curves.easeInOut,
                                              width: 400.0,
                                              decoration: BoxDecoration(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                                border: Border.all(
                                                  color: valueOrDefault<Color>(
                                                    () {
                                                      if (_model.c2Status ==
                                                          'Confirmed') {
                                                        return Color(
                                                            0xFF0CD40B);
                                                      } else if (_model
                                                              .c2Status ==
                                                          'Pending') {
                                                        return FlutterFlowTheme
                                                                .of(context)
                                                            .primary;
                                                      } else if (_model
                                                              .c2Status ==
                                                          'Denied') {
                                                        return FlutterFlowTheme
                                                                .of(context)
                                                            .error;
                                                      } else if (_model
                                                              .c2Status ==
                                                          'Opted out') {
                                                        return FlutterFlowTheme
                                                                .of(context)
                                                            .error;
                                                      } else if (_model
                                                              .c2Status ==
                                                          'Not sent') {
                                                        return FlutterFlowTheme
                                                                .of(context)
                                                            .primary;
                                                      } else {
                                                        return FlutterFlowTheme
                                                                .of(context)
                                                            .primary;
                                                      }
                                                    }(),
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                  ),
                                                  width: 2.5,
                                                ),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(16.0),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          'Contact 2',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .titleMedium
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleMediumFamily,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleMediumIsCustom,
                                                              ),
                                                        ),
                                                        FlutterFlowIconButton(
                                                          borderRadius: 16.0,
                                                          buttonSize: 32.0,
                                                          fillColor:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .primary,
                                                          icon: Icon(
                                                            Icons
                                                                .delete_outline,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .info,
                                                            size: 16.0,
                                                          ),
                                                          onPressed: () async {
                                                            _deleteContactSlot(
                                                                2);
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                    if (_shouldShowContactEntryChoice(
                                                        2))
                                                      _buildContactEntryChoice(
                                                          2)
                                                    else ...[
                                                      TextFormField(
                                                        controller: _model
                                                            .c2FirstTFTextController,
                                                        focusNode: _model
                                                            .c2FirstTFFocusNode,
                                                        autofocus: false,
                                                        textCapitalization:
                                                            TextCapitalization
                                                                .words,
                                                        textInputAction:
                                                            TextInputAction
                                                                .next,
                                                        obscureText: false,
                                                        decoration:
                                                            InputDecoration(
                                                          hintText:
                                                              'First Name',
                                                          hintStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        FlutterFlowTheme.of(context)
                                                                            .bodyMediumFamily,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    useGoogleFonts:
                                                                        !FlutterFlowTheme.of(context)
                                                                            .bodyMediumIsCustom,
                                                                  ),
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color:
                                                                  valueOrDefault<
                                                                      Color>(
                                                                () {
                                                                  if (_model
                                                                          .c2Status ==
                                                                      'Confirmed') {
                                                                    return Color(
                                                                        0xFF0CD40B);
                                                                  } else if (_model
                                                                          .c2Status ==
                                                                      'Pending') {
                                                                    return FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary;
                                                                  } else if (_model
                                                                          .c2Status ==
                                                                      'Denied') {
                                                                    return FlutterFlowTheme.of(
                                                                            context)
                                                                        .error;
                                                                  } else if (_model
                                                                          .c2Status ==
                                                                      'Opted out') {
                                                                    return FlutterFlowTheme.of(
                                                                            context)
                                                                        .error;
                                                                  } else if (_model
                                                                          .c2Status ==
                                                                      'Not sent') {
                                                                    return FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary;
                                                                  } else {
                                                                    return FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary;
                                                                  }
                                                                }(),
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .primary,
                                                              ),
                                                              width: 1.5,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primary,
                                                              width: 1.5,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                          ),
                                                          errorBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: Color(
                                                                  0x00000000),
                                                              width: 1.5,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                          ),
                                                          focusedErrorBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: Color(
                                                                  0x00000000),
                                                              width: 1.5,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                          ),
                                                          filled: true,
                                                          fillColor:
                                                              Colors.white,
                                                        ),
                                                        style: FlutterFlowTheme
                                                                .of(context)
                                                            .bodyMedium
                                                            .override(
                                                              fontFamily:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily,
                                                              fontSize: 16.0,
                                                              letterSpacing:
                                                                  0.25,
                                                              useGoogleFonts:
                                                                  !FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumIsCustom,
                                                            ),
                                                        keyboardType:
                                                            TextInputType.name,
                                                        cursorColor:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primaryText,
                                                        validator: _model
                                                            .c2FirstTFTextControllerValidator
                                                            .asValidator(
                                                                context),
                                                        inputFormatters: [
                                                          if (!isAndroid &&
                                                              !isiOS)
                                                            TextInputFormatter
                                                                .withFunction(
                                                                    (oldValue,
                                                                        newValue) {
                                                              return TextEditingValue(
                                                                selection: newValue
                                                                    .selection,
                                                                text: newValue
                                                                    .text
                                                                    .toCapitalization(
                                                                        TextCapitalization
                                                                            .words),
                                                              );
                                                            }),
                                                        ],
                                                      ),
                                                      TextFormField(
                                                        controller: _model
                                                            .c2LastTFTextController,
                                                        focusNode: _model
                                                            .c2LastTFFocusNode,
                                                        autofocus: false,
                                                        textCapitalization:
                                                            TextCapitalization
                                                                .words,
                                                        textInputAction:
                                                            TextInputAction
                                                                .next,
                                                        obscureText: false,
                                                        decoration:
                                                            InputDecoration(
                                                          hintText: 'Last Name',
                                                          hintStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        FlutterFlowTheme.of(context)
                                                                            .bodyMediumFamily,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    useGoogleFonts:
                                                                        !FlutterFlowTheme.of(context)
                                                                            .bodyMediumIsCustom,
                                                                  ),
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color:
                                                                  valueOrDefault<
                                                                      Color>(
                                                                () {
                                                                  if (_model
                                                                          .c2Status ==
                                                                      'Confirmed') {
                                                                    return Color(
                                                                        0xFF0CD40B);
                                                                  } else if (_model
                                                                          .c2Status ==
                                                                      'Pending') {
                                                                    return FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary;
                                                                  } else if (_model
                                                                          .c2Status ==
                                                                      'Denied') {
                                                                    return FlutterFlowTheme.of(
                                                                            context)
                                                                        .error;
                                                                  } else if (_model
                                                                          .c2Status ==
                                                                      'Opted out') {
                                                                    return FlutterFlowTheme.of(
                                                                            context)
                                                                        .error;
                                                                  } else if (_model
                                                                          .c2Status ==
                                                                      'Not sent') {
                                                                    return FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary;
                                                                  } else {
                                                                    return FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary;
                                                                  }
                                                                }(),
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .primary,
                                                              ),
                                                              width: 1.5,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primary,
                                                              width: 1.5,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                          ),
                                                          errorBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: Color(
                                                                  0x00000000),
                                                              width: 1.5,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                          ),
                                                          focusedErrorBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: Color(
                                                                  0x00000000),
                                                              width: 1.5,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                          ),
                                                          filled: true,
                                                          fillColor:
                                                              Colors.white,
                                                        ),
                                                        style: FlutterFlowTheme
                                                                .of(context)
                                                            .bodyMedium
                                                            .override(
                                                              fontFamily:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily,
                                                              fontSize: 16.0,
                                                              letterSpacing:
                                                                  0.25,
                                                              useGoogleFonts:
                                                                  !FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumIsCustom,
                                                            ),
                                                        keyboardType:
                                                            TextInputType.name,
                                                        cursorColor:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primaryText,
                                                        validator: _model
                                                            .c2LastTFTextControllerValidator
                                                            .asValidator(
                                                                context),
                                                        inputFormatters: [
                                                          if (!isAndroid &&
                                                              !isiOS)
                                                            TextInputFormatter
                                                                .withFunction(
                                                                    (oldValue,
                                                                        newValue) {
                                                              return TextEditingValue(
                                                                selection: newValue
                                                                    .selection,
                                                                text: newValue
                                                                    .text
                                                                    .toCapitalization(
                                                                        TextCapitalization
                                                                            .words),
                                                              );
                                                            }),
                                                        ],
                                                      ),
                                                      TextFormField(
                                                        controller: _model
                                                            .c2PhoneTFTextController,
                                                        focusNode: _model
                                                            .c2PhoneTFFocusNode,
                                                        onChanged: (_) {
                                                          _resetConsentStatusAfterPhoneEdit(
                                                              2);
                                                          EasyDebounce.debounce(
                                                            '_model.c2PhoneTFTextController',
                                                            Duration(
                                                                milliseconds:
                                                                    2000),
                                                            () async {
                                                              _model.c2PhoneDigits =
                                                                  functions.sanitizePhoneDigits(
                                                                      _model
                                                                          .c2PhoneTFTextController
                                                                          .text);
                                                              safeSetState(
                                                                  () {});
                                                              if ((_model.c2PhoneDigits !=
                                                                          null &&
                                                                      _model.c2PhoneDigits !=
                                                                          '') &&
                                                                  ((_model.c2PhoneDigits!)
                                                                          .length ==
                                                                      10)) {
                                                                safeSetState(
                                                                    () {
                                                                  _model.c2PhoneTFTextController
                                                                          ?.text =
                                                                      functions.formatAsUsPhone(
                                                                          _model
                                                                              .c2PhoneDigits!);
                                                                  _model
                                                                      .c2PhoneTFMask
                                                                      .updateMask(
                                                                    newValue:
                                                                        TextEditingValue(
                                                                      text: _model
                                                                          .c2PhoneTFTextController!
                                                                          .text,
                                                                    ),
                                                                  );
                                                                });
                                                              }
                                                            },
                                                          );
                                                        },
                                                        autofocus: false,
                                                        textInputAction:
                                                            TextInputAction
                                                                .next,
                                                        obscureText: false,
                                                        decoration:
                                                            InputDecoration(
                                                          hintText:
                                                              'Phone Number',
                                                          hintStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        FlutterFlowTheme.of(context)
                                                                            .bodyMediumFamily,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    useGoogleFonts:
                                                                        !FlutterFlowTheme.of(context)
                                                                            .bodyMediumIsCustom,
                                                                  ),
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color:
                                                                  valueOrDefault<
                                                                      Color>(
                                                                () {
                                                                  if (_model
                                                                          .c2Status ==
                                                                      'Confirmed') {
                                                                    return Color(
                                                                        0xFF0CD40B);
                                                                  } else if (_model
                                                                          .c2Status ==
                                                                      'Pending') {
                                                                    return FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary;
                                                                  } else if (_model
                                                                          .c2Status ==
                                                                      'Denied') {
                                                                    return FlutterFlowTheme.of(
                                                                            context)
                                                                        .error;
                                                                  } else if (_model
                                                                          .c2Status ==
                                                                      'Opted out') {
                                                                    return FlutterFlowTheme.of(
                                                                            context)
                                                                        .error;
                                                                  } else if (_model
                                                                          .c2Status ==
                                                                      'Not sent') {
                                                                    return FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary;
                                                                  } else {
                                                                    return FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary;
                                                                  }
                                                                }(),
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .primary,
                                                              ),
                                                              width: 1.5,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primary,
                                                              width: 1.5,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                          ),
                                                          errorBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: Color(
                                                                  0x00000000),
                                                              width: 1.5,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                          ),
                                                          focusedErrorBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: Color(
                                                                  0x00000000),
                                                              width: 1.5,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                          ),
                                                          filled: true,
                                                          fillColor:
                                                              Colors.white,
                                                        ),
                                                        style: FlutterFlowTheme
                                                                .of(context)
                                                            .bodyMedium
                                                            .override(
                                                              fontFamily:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily,
                                                              fontSize: 16.0,
                                                              letterSpacing:
                                                                  0.25,
                                                              useGoogleFonts:
                                                                  !FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumIsCustom,
                                                            ),
                                                        keyboardType:
                                                            TextInputType.phone,
                                                        cursorColor:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primaryText,
                                                        validator: _model
                                                            .c2PhoneTFTextControllerValidator
                                                            .asValidator(
                                                                context),
                                                      ),
                                                      SizedBox(
                                                        height: 30.0,
                                                        child: Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  0.0, 0.0),
                                                          child: Container(
                                                            width:
                                                                double.infinity,
                                                            height: 30.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondaryBackground,
                                                            ),
                                                            child: Align(
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0.0, 0.0),
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Align(
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                    child: Text(
                                                                      'Status: ',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .override(
                                                                            fontFamily:
                                                                                FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                            fontSize:
                                                                                16.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            useGoogleFonts:
                                                                                !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    () {
                                                                      if (_model
                                                                              .c2Status ==
                                                                          'Not sent') {
                                                                        return 'Not sent';
                                                                      } else if (_model
                                                                              .c2Status ==
                                                                          'Pending') {
                                                                        return 'Pending';
                                                                      } else if (_model
                                                                              .c2Status ==
                                                                          'Confirmed') {
                                                                        return 'Confirmed';
                                                                      } else if (_model
                                                                              .c2Status ==
                                                                          'Denied') {
                                                                        return 'Denied';
                                                                      } else if (_model
                                                                              .c2Status ==
                                                                          'Opted out') {
                                                                        return 'Opted out';
                                                                      } else {
                                                                        return 'Not sent';
                                                                      }
                                                                    }(),
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          fontFamily:
                                                                              FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                          color:
                                                                              valueOrDefault<Color>(
                                                                            () {
                                                                              if (_model.c2Status == 'Confirmed') {
                                                                                return Color(0xFF0CD40B);
                                                                              } else if (_model.c2Status == 'Pending') {
                                                                                return FlutterFlowTheme.of(context).primary;
                                                                              } else if (_model.c2Status == 'Denied') {
                                                                                return FlutterFlowTheme.of(context).error;
                                                                              } else if (_model.c2Status == 'Opted out') {
                                                                                return FlutterFlowTheme.of(context).error;
                                                                              } else if (_model.c2Status == 'Not sent') {
                                                                                return FlutterFlowTheme.of(context).primaryText;
                                                                              } else {
                                                                                return FlutterFlowTheme.of(context).primary;
                                                                              }
                                                                            }(),
                                                                            FlutterFlowTheme.of(context).primaryText,
                                                                          ),
                                                                          fontSize:
                                                                              16.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          useGoogleFonts:
                                                                              !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                        ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Stack(
                                                        children: [
                                                          Material(
                                                            color: Colors
                                                                .transparent,
                                                            elevation: 3.0,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                            ),
                                                            child: Container(
                                                              width: 300.0,
                                                              height: 50.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primary,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8.0),
                                                              ),
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Text(
                                                                    _consentInviteButtonLabel(
                                                                        2,
                                                                        _model
                                                                            .c2Status),
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          fontFamily:
                                                                              FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                          color:
                                                                              FlutterFlowTheme.of(context).info,
                                                                          fontSize:
                                                                              18.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          useGoogleFonts:
                                                                              !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                        ),
                                                                  ),
                                                                  Icon(
                                                                    _consentInviteButtonIcon(
                                                                        2),
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .info,
                                                                    size: 24.0,
                                                                  ),
                                                                ].divide(SizedBox(
                                                                    width:
                                                                        12.0)),
                                                              ),
                                                            ),
                                                          ),
                                                          Opacity(
                                                            opacity: 0.0,
                                                            child: Align(
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0.0, 0.0),
                                                              child:
                                                                  FFButtonWidget(
                                                                onPressed:
                                                                    () async {
                                                                  if (_showingConsentInviteSent(
                                                                      2)) {
                                                                    return;
                                                                  }
                                                                  _model.c2PhoneDigits =
                                                                      functions.sanitizePhoneDigits(_model
                                                                          .c2PhoneTFTextController
                                                                          .text);
                                                                  safeSetState(
                                                                      () {});
                                                                  await actions
                                                                      .dismissKeyboard(
                                                                    context,
                                                                  );
                                                                  _model.contactsPayloadslot2 =
                                                                      await actions
                                                                          .buildContactsPayloadV2(
                                                                    _model
                                                                        .c1FirstTFTextController
                                                                        .text,
                                                                    _model
                                                                        .c1LastTFTextController
                                                                        .text,
                                                                    _model
                                                                        .c1PhoneTFTextController
                                                                        .text,
                                                                    _model
                                                                        .c2FirstTFTextController
                                                                        .text,
                                                                    _model
                                                                        .c2LastTFTextController
                                                                        .text,
                                                                    _model
                                                                        .c2PhoneTFTextController
                                                                        .text,
                                                                    _model
                                                                        .c3FirstTFTextController
                                                                        .text,
                                                                    _model
                                                                        .c3LastTFTextController
                                                                        .text,
                                                                    _model
                                                                        .c3PhoneTFTextController
                                                                        .text,
                                                                    _model
                                                                        .c4FirstTFTextController
                                                                        .text,
                                                                    _model
                                                                        .c4LastTFTextController
                                                                        .text,
                                                                    _model
                                                                        .c4PhoneTFTextController
                                                                        .text,
                                                                    _model
                                                                        .c5FirstTFTextController
                                                                        .text,
                                                                    _model
                                                                        .c5LastTFTextController
                                                                        .text,
                                                                    _model
                                                                        .c5PhoneTFTextController
                                                                        .text,
                                                                    _model
                                                                        .contactsCount,
                                                                    _model
                                                                        .c1Status,
                                                                    _model
                                                                        .c2Status,
                                                                    _model
                                                                        .c3Status,
                                                                    _model
                                                                        .c4Status,
                                                                    _model
                                                                        .c5Status,
                                                                  );
                                                                  _model.contactsJson =
                                                                      _model
                                                                          .contactsPayloadslot2!;
                                                                  safeSetState(
                                                                      () {});
                                                                  if (loggedIn ==
                                                                      true) {
                                                                    _model.keyOutslot2 =
                                                                        await _currentRowDataKeyForSave();
                                                                    _model.dataKeyB64 =
                                                                        _model
                                                                            .keyOutslot2!;
                                                                    safeSetState(
                                                                        () {});
                                                                    _model.encslot2 =
                                                                        await actions
                                                                            .aesGcmEncryptString(
                                                                      _model
                                                                          .contactsJson,
                                                                      _model
                                                                          .dataKeyB64,
                                                                    );
                                                                    _model.ctB64 =
                                                                        getJsonField(
                                                                      _model
                                                                          .encslot2,
                                                                      r'''$.ciphertextB64''',
                                                                    ).toString();
                                                                    _model.nonceB64 =
                                                                        getJsonField(
                                                                      _model
                                                                          .encslot2,
                                                                      r'''$.nonceB64''',
                                                                    ).toString();
                                                                    safeSetState(
                                                                        () {});
                                                                    _model.wrapslot2 =
                                                                        await WrapDataKeyCall
                                                                            .call(
                                                                      dataKeyB64:
                                                                          _model
                                                                              .dataKeyB64,
                                                                      jwt:
                                                                          await _jwtForApi(),
                                                                    );

                                                                    if ((_model
                                                                            .wrapslot2
                                                                            ?.succeeded ??
                                                                        false)) {
                                                                      _model.wrappedB64 =
                                                                          _jsonValue(
                                                                        (_model.wrapslot2?.jsonBody ??
                                                                            ''),
                                                                        r'''$.wrappedB64''',
                                                                      );
                                                                      safeSetState(
                                                                          () {});
                                                                      _model.updslot2 =
                                                                          await DecoyWalletTable()
                                                                              .queryRows(
                                                                        queryFn:
                                                                            (q) =>
                                                                                q.eqOrNull(
                                                                          'user_id',
                                                                          currentUserUid,
                                                                        ),
                                                                      );
                                                                      if (_model.updslot2 !=
                                                                              null &&
                                                                          (_model.updslot2)!
                                                                              .isNotEmpty) {
                                                                        await DecoyWalletTable()
                                                                            .update(
                                                                          data: {
                                                                            'wrapped_datakey':
                                                                                _model.wrappedB64,
                                                                            'updated_at':
                                                                                supaSerialize<DateTime>(getCurrentTimestamp),
                                                                            'contacts_ciphertext':
                                                                                _model.ctB64,
                                                                            'contacts_nonce':
                                                                                _model.nonceB64,
                                                                            'contacts_version':
                                                                                1,
                                                                            'created_at':
                                                                                supaSerialize<DateTime>(getCurrentTimestamp),
                                                                            'contacts_complete': functions.hasConfirmedEmergencyContact(
                                                                                _model.c1Status,
                                                                                _model.c2Status,
                                                                                _model.c3Status,
                                                                                _model.c4Status,
                                                                                _model.c5Status),
                                                                          },
                                                                          matchingRows: (rows) =>
                                                                              rows.eqOrNull(
                                                                            'user_id',
                                                                            currentUserUid,
                                                                          ),
                                                                        );
                                                                        _model.decoyWalletRefresh1slot2222 =
                                                                            await DecoyWalletTable().queryRows(
                                                                          queryFn: (q) =>
                                                                              q.eqOrNull(
                                                                            'user_id',
                                                                            currentUserUid,
                                                                          ),
                                                                        );
                                                                        FFAppState().emergencyContactsIncrement =
                                                                            _model.contactsCount;
                                                                        safeSetState(
                                                                            () {});
                                                                      } else {
                                                                        _model.insRowslot22222 =
                                                                            await DecoyWalletTable().insert({
                                                                          'wrapped_datakey':
                                                                              _model.wrappedB64,
                                                                          'updated_at':
                                                                              supaSerialize<DateTime>(getCurrentTimestamp),
                                                                          'contacts_ciphertext':
                                                                              _model.ctB64,
                                                                          'contacts_nonce':
                                                                              _model.nonceB64,
                                                                          'contacts_version':
                                                                              1,
                                                                          'user_id':
                                                                              currentUserUid,
                                                                          'contacts_complete': functions.hasConfirmedEmergencyContact(
                                                                              _model.c1Status,
                                                                              _model.c2Status,
                                                                              _model.c3Status,
                                                                              _model.c4Status,
                                                                              _model.c5Status),
                                                                        });
                                                                        _model.decoyWalletRefresh2slot22222 =
                                                                            await DecoyWalletTable().queryRows(
                                                                          queryFn: (q) =>
                                                                              q.eqOrNull(
                                                                            'user_id',
                                                                            currentUserUid,
                                                                          ),
                                                                        );
                                                                        FFAppState().emergencyContactsIncrement =
                                                                            _model.contactsCount;
                                                                        safeSetState(
                                                                            () {});
                                                                      }

                                                                      _model.consentSlotsList = functions
                                                                          .buildConsentSlotsListFINAL(
                                                                              _model.c1FirstTFTextController.text,
                                                                              _model.c1LastTFTextController.text,
                                                                              _model.c1PhoneTFTextController.text,
                                                                              _model.c1Status,
                                                                              _model.c2FirstTFTextController.text,
                                                                              _model.c2LastTFTextController.text,
                                                                              _model.c2PhoneTFTextController.text,
                                                                              _model.c2Status,
                                                                              _model.c3FirstTFTextController.text,
                                                                              _model.c3LastTFTextController.text,
                                                                              _model.c3PhoneTFTextController.text,
                                                                              _model.c3Status,
                                                                              _model.c4FirstTFTextController.text,
                                                                              _model.c4LastTFTextController.text,
                                                                              _model.c4PhoneTFTextController.text,
                                                                              _model.c4Status,
                                                                              _model.c5FirstTFTextController.text,
                                                                              _model.c5LastTFTextController.text,
                                                                              _model.c5PhoneTFTextController.text,
                                                                              _model.c5Status)
                                                                          .toList()
                                                                          .cast<dynamic>();
                                                                      safeSetState(
                                                                          () {});
                                                                      _model.syncConsentRespslot22 =
                                                                          await SyncConsentSlotsCall
                                                                              .call(
                                                                        jwt:
                                                                            currentJwtToken,
                                                                        slotsJsonJson:
                                                                            _model.consentSlotsList,
                                                                      );

                                                                      if ((_model
                                                                              .syncConsentRespslot22
                                                                              ?.succeeded ??
                                                                          true)) {
                                                                        _model.createConsentResp2slot2 =
                                                                            await CreateConsentRequestCall.call(
                                                                          userId:
                                                                              currentUserUid,
                                                                          contactSlot:
                                                                              2,
                                                                          firstName: _model
                                                                              .c2FirstTFTextController
                                                                              .text,
                                                                          lastName: _model
                                                                              .c2LastTFTextController
                                                                              .text,
                                                                          phoneNumber:
                                                                              _model.c2PhoneDigits,
                                                                          jwt:
                                                                              currentJwtToken,
                                                                        );

                                                                        if ((_model.createConsentResp2slot2?.succeeded ??
                                                                            true)) {
                                                                          _model.c2Status =
                                                                              'Pending';
                                                                          _model.consentSlotsList = functions
                                                                              .buildConsentSlotsListFINAL(_model.c1FirstTFTextController.text, _model.c1LastTFTextController.text, _model.c1PhoneTFTextController.text, 'Pending', _model.c2FirstTFTextController.text, _model.c2LastTFTextController.text, _model.c2PhoneTFTextController.text, _model.c2Status, _model.c3FirstTFTextController.text, _model.c3LastTFTextController.text, _model.c3PhoneTFTextController.text, _model.c3Status, _model.c4FirstTFTextController.text, _model.c4LastTFTextController.text, _model.c4PhoneTFTextController.text, _model.c4Status, _model.c5FirstTFTextController.text, _model.c5LastTFTextController.text, _model.c5PhoneTFTextController.text, _model.c5Status)
                                                                              .toList()
                                                                              .cast<dynamic>();
                                                                          safeSetState(
                                                                              () {});
                                                                          _showConsentInviteSent(
                                                                              2);

                                                                          _model.prettycooolslot2 =
                                                                              await GetConsentStatusesCall.call(
                                                                            jwt:
                                                                                currentJwtToken,
                                                                          );

                                                                          if ((_model.prettycooolslot2?.succeeded ??
                                                                              true)) {
                                                                            _model.consentSlotsList =
                                                                                functions.buildConsentSlotsListFINAL(_model.c1FirstTFTextController.text, _model.c1LastTFTextController.text, _model.c1PhoneTFTextController.text, 'Pending', _model.c2FirstTFTextController.text, _model.c2LastTFTextController.text, _model.c2PhoneTFTextController.text, _model.c2Status, _model.c3FirstTFTextController.text, _model.c3LastTFTextController.text, _model.c3PhoneTFTextController.text, _model.c3Status, _model.c4FirstTFTextController.text, _model.c4LastTFTextController.text, _model.c4PhoneTFTextController.text, _model.c4Status, _model.c5FirstTFTextController.text, _model.c5LastTFTextController.text, _model.c5PhoneTFTextController.text, _model.c5Status).toList().cast<dynamic>();
                                                                            _model.c2First =
                                                                                GetConsentStatusesCall.slot2First(
                                                                              (_model.prettycooolslot2?.jsonBody ?? ''),
                                                                            ).toString();
                                                                            _model.c2Last =
                                                                                GetConsentStatusesCall.slot2Last(
                                                                              (_model.prettycooolslot2?.jsonBody ?? ''),
                                                                            ).toString();
                                                                            _model.c2Phone =
                                                                                GetConsentStatusesCall.slot2Phone(
                                                                              (_model.prettycooolslot2?.jsonBody ?? ''),
                                                                            ).toString();
                                                                            safeSetState(() {});
                                                                          }
                                                                        }
                                                                      }
                                                                    } else {
                                                                      ScaffoldMessenger.of(
                                                                              context)
                                                                          .showSnackBar(
                                                                        SnackBar(
                                                                          content:
                                                                              Text(
                                                                            'ERROR #009 - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT',
                                                                            style:
                                                                                TextStyle(
                                                                              color: FlutterFlowTheme.of(context).primaryText,
                                                                            ),
                                                                          ),
                                                                          duration:
                                                                              Duration(milliseconds: 4000),
                                                                          backgroundColor:
                                                                              FlutterFlowTheme.of(context).secondary,
                                                                        ),
                                                                      );
                                                                    }
                                                                  } else {
                                                                    context.goNamed(
                                                                        LoginPageWidget
                                                                            .routeName);
                                                                  }

                                                                  safeSetState(
                                                                      () {});
                                                                },
                                                                text: _model.c2Status ==
                                                                        'Not sent'
                                                                    ? 'Send Confirmation Link'
                                                                    : 'Resend Confirmation Link',
                                                                options:
                                                                    FFButtonOptions(
                                                                  width: 300.0,
                                                                  height: 50.0,
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          16.0,
                                                                          0.0,
                                                                          16.0,
                                                                          0.0),
                                                                  iconPadding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          0.0,
                                                                          0.0),
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary,
                                                                  textStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .override(
                                                                        fontFamily:
                                                                            FlutterFlowTheme.of(context).titleSmallFamily,
                                                                        color: Colors
                                                                            .white,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        useGoogleFonts:
                                                                            !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                      ),
                                                                  elevation:
                                                                      3.0,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10.0),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ].divide(
                                                      SizedBox(height: 12.0)),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (_model.contactsCount >= 3)
                                      Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  16.0, 16.0, 16.0, 0.0),
                                          child: Container(
                                            width: 400.0,
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                              border: Border.all(
                                                color: valueOrDefault<Color>(
                                                  () {
                                                    if (_model.c3Status ==
                                                        'Confirmed') {
                                                      return Color(0xFF0CD40B);
                                                    } else if (_model
                                                            .c3Status ==
                                                        'Pending') {
                                                      return FlutterFlowTheme
                                                              .of(context)
                                                          .primary;
                                                    } else if (_model
                                                            .c3Status ==
                                                        'Denied') {
                                                      return FlutterFlowTheme
                                                              .of(context)
                                                          .error;
                                                    } else if (_model
                                                            .c3Status ==
                                                        'Opted out') {
                                                      return FlutterFlowTheme
                                                              .of(context)
                                                          .error;
                                                    } else if (_model
                                                            .c3Status ==
                                                        'Not sent') {
                                                      return FlutterFlowTheme
                                                              .of(context)
                                                          .primary;
                                                    } else {
                                                      return FlutterFlowTheme
                                                              .of(context)
                                                          .primary;
                                                    }
                                                  }(),
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                                ),
                                                width: 2.5,
                                              ),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(16.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Contact 3',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleMedium
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleMediumFamily,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleMediumIsCustom,
                                                                ),
                                                      ),
                                                      FlutterFlowIconButton(
                                                        borderRadius: 16.0,
                                                        buttonSize: 32.0,
                                                        fillColor:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        icon: Icon(
                                                          Icons.delete_outline,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .info,
                                                          size: 16.0,
                                                        ),
                                                        onPressed: () async {
                                                          _deleteContactSlot(3);
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  if (_shouldShowContactEntryChoice(
                                                      3))
                                                    _buildContactEntryChoice(3)
                                                  else ...[
                                                    TextFormField(
                                                      controller: _model
                                                          .c3FirstTFTextController,
                                                      focusNode: _model
                                                          .c3FirstTFFocusNode,
                                                      autofocus: false,
                                                      textCapitalization:
                                                          TextCapitalization
                                                              .words,
                                                      textInputAction:
                                                          TextInputAction.next,
                                                      obscureText: false,
                                                      decoration:
                                                          InputDecoration(
                                                        hintText: 'First Name',
                                                        hintStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMediumIsCustom,
                                                                ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color:
                                                                valueOrDefault<
                                                                    Color>(
                                                              () {
                                                                if (_model
                                                                        .c3Status ==
                                                                    'Confirmed') {
                                                                  return Color(
                                                                      0xFF0CD40B);
                                                                } else if (_model
                                                                        .c3Status ==
                                                                    'Pending') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary;
                                                                } else if (_model
                                                                        .c3Status ==
                                                                    'Denied') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .error;
                                                                } else if (_model
                                                                        .c3Status ==
                                                                    'Opted out') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .error;
                                                                } else if (_model
                                                                        .c3Status ==
                                                                    'Not sent') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary;
                                                                } else {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary;
                                                                }
                                                              }(),
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .primary,
                                                            ),
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        errorBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: Color(
                                                                0x00000000),
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        focusedErrorBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: Color(
                                                                0x00000000),
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                      ),
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            fontSize: 16.0,
                                                            letterSpacing: 0.25,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                      keyboardType:
                                                          TextInputType.name,
                                                      cursorColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                      validator: _model
                                                          .c3FirstTFTextControllerValidator
                                                          .asValidator(context),
                                                      inputFormatters: [
                                                        if (!isAndroid &&
                                                            !isiOS)
                                                          TextInputFormatter
                                                              .withFunction(
                                                                  (oldValue,
                                                                      newValue) {
                                                            return TextEditingValue(
                                                              selection: newValue
                                                                  .selection,
                                                              text: newValue
                                                                  .text
                                                                  .toCapitalization(
                                                                      TextCapitalization
                                                                          .words),
                                                            );
                                                          }),
                                                      ],
                                                    ),
                                                    TextFormField(
                                                      controller: _model
                                                          .c3LastTFTextController,
                                                      focusNode: _model
                                                          .c3LastTFFocusNode,
                                                      autofocus: false,
                                                      textCapitalization:
                                                          TextCapitalization
                                                              .words,
                                                      textInputAction:
                                                          TextInputAction.next,
                                                      obscureText: false,
                                                      decoration:
                                                          InputDecoration(
                                                        hintText: 'Last Name',
                                                        hintStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMediumIsCustom,
                                                                ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color:
                                                                valueOrDefault<
                                                                    Color>(
                                                              () {
                                                                if (_model
                                                                        .c3Status ==
                                                                    'Confirmed') {
                                                                  return Color(
                                                                      0xFF0CD40B);
                                                                } else if (_model
                                                                        .c3Status ==
                                                                    'Pending') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary;
                                                                } else if (_model
                                                                        .c3Status ==
                                                                    'Denied') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .error;
                                                                } else if (_model
                                                                        .c3Status ==
                                                                    'Opted out') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .error;
                                                                } else if (_model
                                                                        .c3Status ==
                                                                    'Not sent') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary;
                                                                } else {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary;
                                                                }
                                                              }(),
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .primary,
                                                            ),
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        errorBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: Color(
                                                                0x00000000),
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        focusedErrorBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: Color(
                                                                0x00000000),
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                      ),
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            fontSize: 16.0,
                                                            letterSpacing: 0.25,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                      keyboardType:
                                                          TextInputType.name,
                                                      cursorColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                      validator: _model
                                                          .c3LastTFTextControllerValidator
                                                          .asValidator(context),
                                                      inputFormatters: [
                                                        if (!isAndroid &&
                                                            !isiOS)
                                                          TextInputFormatter
                                                              .withFunction(
                                                                  (oldValue,
                                                                      newValue) {
                                                            return TextEditingValue(
                                                              selection: newValue
                                                                  .selection,
                                                              text: newValue
                                                                  .text
                                                                  .toCapitalization(
                                                                      TextCapitalization
                                                                          .words),
                                                            );
                                                          }),
                                                      ],
                                                    ),
                                                    TextFormField(
                                                      controller: _model
                                                          .c3PhoneTFTextController,
                                                      focusNode: _model
                                                          .c3PhoneTFFocusNode,
                                                      onChanged: (_) {
                                                        _resetConsentStatusAfterPhoneEdit(
                                                            3);
                                                        EasyDebounce.debounce(
                                                          '_model.c3PhoneTFTextController',
                                                          Duration(
                                                              milliseconds:
                                                                  2000),
                                                          () async {
                                                            _model.c3PhoneDigits =
                                                                functions.sanitizePhoneDigits(
                                                                    _model
                                                                        .c3PhoneTFTextController
                                                                        .text);
                                                            safeSetState(() {});
                                                            if ((_model.c3PhoneDigits !=
                                                                        null &&
                                                                    _model.c3PhoneDigits !=
                                                                        '') &&
                                                                ((_model.c3PhoneDigits!)
                                                                        .length ==
                                                                    10)) {
                                                              safeSetState(() {
                                                                _model.c3PhoneTFTextController
                                                                        ?.text =
                                                                    functions.formatAsUsPhone(
                                                                        _model
                                                                            .c3PhoneDigits!);
                                                                _model
                                                                    .c3PhoneTFMask
                                                                    .updateMask(
                                                                  newValue:
                                                                      TextEditingValue(
                                                                    text: _model
                                                                        .c3PhoneTFTextController!
                                                                        .text,
                                                                  ),
                                                                );
                                                              });
                                                            }
                                                          },
                                                        );
                                                      },
                                                      autofocus: false,
                                                      textInputAction:
                                                          TextInputAction.next,
                                                      obscureText: false,
                                                      decoration:
                                                          InputDecoration(
                                                        hintText:
                                                            'Phone Number',
                                                        hintStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMediumIsCustom,
                                                                ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color:
                                                                valueOrDefault<
                                                                    Color>(
                                                              () {
                                                                if (_model
                                                                        .c3Status ==
                                                                    'Confirmed') {
                                                                  return Color(
                                                                      0xFF0CD40B);
                                                                } else if (_model
                                                                        .c3Status ==
                                                                    'Pending') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary;
                                                                } else if (_model
                                                                        .c3Status ==
                                                                    'Denied') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .error;
                                                                } else if (_model
                                                                        .c3Status ==
                                                                    'Opted out') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .error;
                                                                } else if (_model
                                                                        .c3Status ==
                                                                    'Not sent') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary;
                                                                } else {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary;
                                                                }
                                                              }(),
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .primary,
                                                            ),
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        errorBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: Color(
                                                                0x00000000),
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        focusedErrorBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: Color(
                                                                0x00000000),
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                      ),
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            fontSize: 16.0,
                                                            letterSpacing: 0.25,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                      keyboardType:
                                                          TextInputType.phone,
                                                      cursorColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                      validator: _model
                                                          .c3PhoneTFTextControllerValidator
                                                          .asValidator(context),
                                                    ),
                                                    SizedBox(
                                                      height: 30.0,
                                                      child: Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                0.0, 0.0),
                                                        child: Container(
                                                          width:
                                                              double.infinity,
                                                          height: 30.0,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryBackground,
                                                          ),
                                                          child: Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0.0, 0.0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Align(
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          0.0),
                                                                  child: Text(
                                                                    'Status: ',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          fontFamily:
                                                                              FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                          fontSize:
                                                                              16.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          useGoogleFonts:
                                                                              !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                        ),
                                                                  ),
                                                                ),
                                                                Text(
                                                                  () {
                                                                    if (_model
                                                                            .c3Status ==
                                                                        'Not sent') {
                                                                      return 'Not sent';
                                                                    } else if (_model
                                                                            .c3Status ==
                                                                        'Pending') {
                                                                      return 'Pending';
                                                                    } else if (_model
                                                                            .c3Status ==
                                                                        'Confirmed') {
                                                                      return 'Confirmed';
                                                                    } else if (_model
                                                                            .c3Status ==
                                                                        'Denied') {
                                                                      return 'Denied';
                                                                    } else if (_model
                                                                            .c3Status ==
                                                                        'Opted out') {
                                                                      return 'Opted out';
                                                                    } else {
                                                                      return 'Not sent';
                                                                    }
                                                                  }(),
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        fontFamily:
                                                                            FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                        color: valueOrDefault<
                                                                            Color>(
                                                                          () {
                                                                            if (_model.c3Status ==
                                                                                'Confirmed') {
                                                                              return Color(0xFF0CD40B);
                                                                            } else if (_model.c3Status ==
                                                                                'Pending') {
                                                                              return FlutterFlowTheme.of(context).primary;
                                                                            } else if (_model.c3Status ==
                                                                                'Denied') {
                                                                              return FlutterFlowTheme.of(context).error;
                                                                            } else if (_model.c3Status ==
                                                                                'Opted out') {
                                                                              return FlutterFlowTheme.of(context).error;
                                                                            } else if (_model.c3Status ==
                                                                                'Not sent') {
                                                                              return FlutterFlowTheme.of(context).primaryText;
                                                                            } else {
                                                                              return FlutterFlowTheme.of(context).primary;
                                                                            }
                                                                          }(),
                                                                          FlutterFlowTheme.of(context)
                                                                              .primaryText,
                                                                        ),
                                                                        fontSize:
                                                                            16.0,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        useGoogleFonts:
                                                                            !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 300.0,
                                                      height: 50.0,
                                                      child: Stack(
                                                        children: [
                                                          Material(
                                                            color: Colors
                                                                .transparent,
                                                            elevation: 3.0,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                            ),
                                                            child: Container(
                                                              width: 300.0,
                                                              height: 100.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primary,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8.0),
                                                              ),
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Text(
                                                                    _consentInviteButtonLabel(
                                                                        3,
                                                                        _model
                                                                            .c3Status),
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          fontFamily:
                                                                              FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                          color:
                                                                              FlutterFlowTheme.of(context).info,
                                                                          fontSize:
                                                                              18.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          useGoogleFonts:
                                                                              !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                        ),
                                                                  ),
                                                                  Icon(
                                                                    _consentInviteButtonIcon(
                                                                        3),
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .info,
                                                                    size: 24.0,
                                                                  ),
                                                                ].divide(SizedBox(
                                                                    width:
                                                                        12.0)),
                                                              ),
                                                            ),
                                                          ),
                                                          Opacity(
                                                            opacity: 0.0,
                                                            child:
                                                                FFButtonWidget(
                                                              onPressed:
                                                                  () async {
                                                                if (_showingConsentInviteSent(
                                                                    3)) {
                                                                  return;
                                                                }
                                                                _model.c3PhoneDigits =
                                                                    functions.sanitizePhoneDigits(_model
                                                                        .c3PhoneTFTextController
                                                                        .text);
                                                                safeSetState(
                                                                    () {});
                                                                await actions
                                                                    .dismissKeyboard(
                                                                  context,
                                                                );
                                                                _model.contactsPayloadslot3 =
                                                                    await actions
                                                                        .buildContactsPayloadV2(
                                                                  _model
                                                                      .c1FirstTFTextController
                                                                      .text,
                                                                  _model
                                                                      .c1LastTFTextController
                                                                      .text,
                                                                  _model
                                                                      .c1PhoneTFTextController
                                                                      .text,
                                                                  _model
                                                                      .c2FirstTFTextController
                                                                      .text,
                                                                  _model
                                                                      .c2LastTFTextController
                                                                      .text,
                                                                  _model
                                                                      .c2PhoneTFTextController
                                                                      .text,
                                                                  _model
                                                                      .c3FirstTFTextController
                                                                      .text,
                                                                  _model
                                                                      .c3LastTFTextController
                                                                      .text,
                                                                  _model
                                                                      .c3PhoneTFTextController
                                                                      .text,
                                                                  _model
                                                                      .c4FirstTFTextController
                                                                      .text,
                                                                  _model
                                                                      .c4LastTFTextController
                                                                      .text,
                                                                  _model
                                                                      .c4PhoneTFTextController
                                                                      .text,
                                                                  _model
                                                                      .c5FirstTFTextController
                                                                      .text,
                                                                  _model
                                                                      .c5LastTFTextController
                                                                      .text,
                                                                  _model
                                                                      .c5PhoneTFTextController
                                                                      .text,
                                                                  _model
                                                                      .contactsCount,
                                                                  _model
                                                                      .c1Status,
                                                                  _model
                                                                      .c2Status,
                                                                  _model
                                                                      .c3Status,
                                                                  _model
                                                                      .c4Status,
                                                                  _model
                                                                      .c5Status,
                                                                );
                                                                _model.contactsJson =
                                                                    _model
                                                                        .contactsPayloadslot3!;
                                                                safeSetState(
                                                                    () {});
                                                                if (loggedIn ==
                                                                    true) {
                                                                  _model.keyOutslot3 =
                                                                      await _currentRowDataKeyForSave();
                                                                  _model.dataKeyB64 =
                                                                      _model
                                                                          .keyOutslot3!;
                                                                  safeSetState(
                                                                      () {});
                                                                  _model.encslot3 =
                                                                      await actions
                                                                          .aesGcmEncryptString(
                                                                    _model
                                                                        .contactsJson,
                                                                    _model
                                                                        .dataKeyB64,
                                                                  );
                                                                  _model.ctB64 =
                                                                      getJsonField(
                                                                    _model
                                                                        .encslot3,
                                                                    r'''$.ciphertextB64''',
                                                                  ).toString();
                                                                  _model.nonceB64 =
                                                                      getJsonField(
                                                                    _model
                                                                        .encslot3,
                                                                    r'''$.nonceB64''',
                                                                  ).toString();
                                                                  safeSetState(
                                                                      () {});
                                                                  _model.wrapslot3 =
                                                                      await WrapDataKeyCall
                                                                          .call(
                                                                    dataKeyB64:
                                                                        _model
                                                                            .dataKeyB64,
                                                                    jwt:
                                                                        await _jwtForApi(),
                                                                  );

                                                                  if ((_model
                                                                          .wrapslot3
                                                                          ?.succeeded ??
                                                                      false)) {
                                                                    _model.wrappedB64 =
                                                                        _jsonValue(
                                                                      (_model.wrapslot3
                                                                              ?.jsonBody ??
                                                                          ''),
                                                                      r'''$.wrappedB64''',
                                                                    );
                                                                    safeSetState(
                                                                        () {});
                                                                    _model.updslot3 =
                                                                        await DecoyWalletTable()
                                                                            .queryRows(
                                                                      queryFn:
                                                                          (q) =>
                                                                              q.eqOrNull(
                                                                        'user_id',
                                                                        currentUserUid,
                                                                      ),
                                                                    );
                                                                    if (_model.updslot3 !=
                                                                            null &&
                                                                        (_model.updslot3)!
                                                                            .isNotEmpty) {
                                                                      await DecoyWalletTable()
                                                                          .update(
                                                                        data: {
                                                                          'wrapped_datakey':
                                                                              _model.wrappedB64,
                                                                          'updated_at':
                                                                              supaSerialize<DateTime>(getCurrentTimestamp),
                                                                          'contacts_ciphertext':
                                                                              _model.ctB64,
                                                                          'contacts_nonce':
                                                                              _model.nonceB64,
                                                                          'contacts_version':
                                                                              1,
                                                                          'created_at':
                                                                              supaSerialize<DateTime>(getCurrentTimestamp),
                                                                          'contacts_complete': functions.hasConfirmedEmergencyContact(
                                                                              _model.c1Status,
                                                                              _model.c2Status,
                                                                              _model.c3Status,
                                                                              _model.c4Status,
                                                                              _model.c5Status),
                                                                        },
                                                                        matchingRows:
                                                                            (rows) =>
                                                                                rows.eqOrNull(
                                                                          'user_id',
                                                                          currentUserUid,
                                                                        ),
                                                                      );
                                                                      _model.decoyWalletRefresh1slot3333 =
                                                                          await DecoyWalletTable()
                                                                              .queryRows(
                                                                        queryFn:
                                                                            (q) =>
                                                                                q.eqOrNull(
                                                                          'user_id',
                                                                          currentUserUid,
                                                                        ),
                                                                      );
                                                                      FFAppState()
                                                                              .emergencyContactsIncrement =
                                                                          _model
                                                                              .contactsCount;
                                                                      safeSetState(
                                                                          () {});
                                                                    } else {
                                                                      _model.insRowslot33333 =
                                                                          await DecoyWalletTable()
                                                                              .insert({
                                                                        'wrapped_datakey':
                                                                            _model.wrappedB64,
                                                                        'updated_at':
                                                                            supaSerialize<DateTime>(getCurrentTimestamp),
                                                                        'contacts_ciphertext':
                                                                            _model.ctB64,
                                                                        'contacts_nonce':
                                                                            _model.nonceB64,
                                                                        'contacts_version':
                                                                            1,
                                                                        'user_id':
                                                                            currentUserUid,
                                                                        'contacts_complete': functions.hasConfirmedEmergencyContact(
                                                                            _model.c1Status,
                                                                            _model.c2Status,
                                                                            _model.c3Status,
                                                                            _model.c4Status,
                                                                            _model.c5Status),
                                                                      });
                                                                      _model.decoyWalletRefresh2slot33333 =
                                                                          await DecoyWalletTable()
                                                                              .queryRows(
                                                                        queryFn:
                                                                            (q) =>
                                                                                q.eqOrNull(
                                                                          'user_id',
                                                                          currentUserUid,
                                                                        ),
                                                                      );
                                                                      FFAppState()
                                                                              .emergencyContactsIncrement =
                                                                          _model
                                                                              .contactsCount;
                                                                      safeSetState(
                                                                          () {});
                                                                    }

                                                                    _model.consentSlotsList = functions
                                                                        .buildConsentSlotsListFINAL(
                                                                            _model
                                                                                .c1FirstTFTextController.text,
                                                                            _model
                                                                                .c1LastTFTextController.text,
                                                                            _model
                                                                                .c1PhoneTFTextController.text,
                                                                            _model
                                                                                .c1Status,
                                                                            _model
                                                                                .c2FirstTFTextController.text,
                                                                            _model
                                                                                .c2LastTFTextController.text,
                                                                            _model
                                                                                .c2PhoneTFTextController.text,
                                                                            _model
                                                                                .c2Status,
                                                                            _model
                                                                                .c3FirstTFTextController.text,
                                                                            _model
                                                                                .c3LastTFTextController.text,
                                                                            _model
                                                                                .c3PhoneTFTextController.text,
                                                                            _model
                                                                                .c3Status,
                                                                            _model
                                                                                .c4FirstTFTextController.text,
                                                                            _model
                                                                                .c4LastTFTextController.text,
                                                                            _model
                                                                                .c4PhoneTFTextController.text,
                                                                            _model
                                                                                .c4Status,
                                                                            _model
                                                                                .c5FirstTFTextController.text,
                                                                            _model
                                                                                .c5LastTFTextController.text,
                                                                            _model
                                                                                .c5PhoneTFTextController.text,
                                                                            _model
                                                                                .c5Status)
                                                                        .toList()
                                                                        .cast<
                                                                            dynamic>();
                                                                    safeSetState(
                                                                        () {});
                                                                    _model.syncConsentRespslot33 =
                                                                        await SyncConsentSlotsCall
                                                                            .call(
                                                                      jwt:
                                                                          currentJwtToken,
                                                                      slotsJsonJson:
                                                                          _model
                                                                              .consentSlotsList,
                                                                    );

                                                                    if ((_model
                                                                            .syncConsentRespslot33
                                                                            ?.succeeded ??
                                                                        true)) {
                                                                      _model.createConsentResp2slot3 =
                                                                          await CreateConsentRequestCall
                                                                              .call(
                                                                        userId:
                                                                            currentUserUid,
                                                                        contactSlot:
                                                                            3,
                                                                        firstName: _model
                                                                            .c3FirstTFTextController
                                                                            .text,
                                                                        lastName: _model
                                                                            .c3LastTFTextController
                                                                            .text,
                                                                        phoneNumber:
                                                                            _model.c3PhoneDigits,
                                                                        jwt:
                                                                            currentJwtToken,
                                                                      );

                                                                      if ((_model
                                                                              .createConsentResp2slot3
                                                                              ?.succeeded ??
                                                                          true)) {
                                                                        _model.c3Status =
                                                                            'Pending';
                                                                        _model.consentSlotsList = functions
                                                                            .buildConsentSlotsListFINAL(
                                                                                _model.c1FirstTFTextController.text,
                                                                                _model.c1LastTFTextController.text,
                                                                                _model.c1PhoneTFTextController.text,
                                                                                'Pending',
                                                                                _model.c2FirstTFTextController.text,
                                                                                _model.c2LastTFTextController.text,
                                                                                _model.c2PhoneTFTextController.text,
                                                                                _model.c2Status,
                                                                                _model.c3FirstTFTextController.text,
                                                                                _model.c3LastTFTextController.text,
                                                                                _model.c3PhoneTFTextController.text,
                                                                                _model.c3Status,
                                                                                _model.c4FirstTFTextController.text,
                                                                                _model.c4LastTFTextController.text,
                                                                                _model.c4PhoneTFTextController.text,
                                                                                _model.c4Status,
                                                                                _model.c5FirstTFTextController.text,
                                                                                _model.c5LastTFTextController.text,
                                                                                _model.c5PhoneTFTextController.text,
                                                                                _model.c5Status)
                                                                            .toList()
                                                                            .cast<dynamic>();
                                                                        safeSetState(
                                                                            () {});
                                                                        _showConsentInviteSent(
                                                                            3);

                                                                        _model.prettycooolslot3 =
                                                                            await GetConsentStatusesCall.call(
                                                                          jwt:
                                                                              currentJwtToken,
                                                                        );

                                                                        if ((_model.prettycooolslot3?.succeeded ??
                                                                            true)) {
                                                                          _model.consentSlotsList = functions
                                                                              .buildConsentSlotsListFINAL(_model.c1FirstTFTextController.text, _model.c1LastTFTextController.text, _model.c1PhoneTFTextController.text, 'Pending', _model.c2FirstTFTextController.text, _model.c2LastTFTextController.text, _model.c2PhoneTFTextController.text, _model.c2Status, _model.c3FirstTFTextController.text, _model.c3LastTFTextController.text, _model.c3PhoneTFTextController.text, _model.c3Status, _model.c4FirstTFTextController.text, _model.c4LastTFTextController.text, _model.c4PhoneTFTextController.text, _model.c4Status, _model.c5FirstTFTextController.text, _model.c5LastTFTextController.text, _model.c5PhoneTFTextController.text, _model.c5Status)
                                                                              .toList()
                                                                              .cast<dynamic>();
                                                                          _model.c3First =
                                                                              GetConsentStatusesCall.slot3First(
                                                                            (_model.prettycooolslot3?.jsonBody ??
                                                                                ''),
                                                                          ).toString();
                                                                          _model.c3Last =
                                                                              GetConsentStatusesCall.slot3Last(
                                                                            (_model.prettycooolslot3?.jsonBody ??
                                                                                ''),
                                                                          ).toString();
                                                                          _model.c3Phone =
                                                                              GetConsentStatusesCall.slot3Phone(
                                                                            (_model.prettycooolslot3?.jsonBody ??
                                                                                ''),
                                                                          ).toString();
                                                                          safeSetState(
                                                                              () {});
                                                                        }
                                                                      }
                                                                    }
                                                                  } else {
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .showSnackBar(
                                                                      SnackBar(
                                                                        content:
                                                                            Text(
                                                                          'ERROR #009 - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT',
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).primaryText,
                                                                          ),
                                                                        ),
                                                                        duration:
                                                                            Duration(milliseconds: 4000),
                                                                        backgroundColor:
                                                                            FlutterFlowTheme.of(context).secondary,
                                                                      ),
                                                                    );
                                                                  }
                                                                } else {
                                                                  context.goNamed(
                                                                      LoginPageWidget
                                                                          .routeName);
                                                                }

                                                                safeSetState(
                                                                    () {});
                                                              },
                                                              text: _model.c3Status ==
                                                                      'Not sent'
                                                                  ? 'Send Confirmation Link'
                                                                  : 'Resend Confirmation Link',
                                                              options:
                                                                  FFButtonOptions(
                                                                width: double
                                                                    .infinity,
                                                                height: 50.0,
                                                                padding: EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        16.0,
                                                                        0.0,
                                                                        16.0,
                                                                        0.0),
                                                                iconPadding:
                                                                    EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primary,
                                                                textStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .titleSmallFamily,
                                                                      color: Colors
                                                                          .white,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .titleSmallIsCustom,
                                                                    ),
                                                                elevation: 3.0,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10.0),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ].divide(
                                                    SizedBox(height: 12.0)),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (_model.contactsCount >= 4)
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            16.0, 16.0, 16.0, 0.0),
                                        child: Material(
                                          color: Colors.transparent,
                                          elevation: 3.0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          child: Container(
                                            width: 400.0,
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                              border: Border.all(
                                                color: valueOrDefault<Color>(
                                                  () {
                                                    if (_model.c4Status ==
                                                        'Confirmed') {
                                                      return Color(0xFF0CD40B);
                                                    } else if (_model
                                                            .c4Status ==
                                                        'Pending') {
                                                      return FlutterFlowTheme
                                                              .of(context)
                                                          .primary;
                                                    } else if (_model
                                                            .c4Status ==
                                                        'Denied') {
                                                      return FlutterFlowTheme
                                                              .of(context)
                                                          .error;
                                                    } else if (_model
                                                            .c4Status ==
                                                        'Opted out') {
                                                      return FlutterFlowTheme
                                                              .of(context)
                                                          .error;
                                                    } else if (_model
                                                            .c4Status ==
                                                        'Not sent') {
                                                      return FlutterFlowTheme
                                                              .of(context)
                                                          .primary;
                                                    } else {
                                                      return FlutterFlowTheme
                                                              .of(context)
                                                          .primary;
                                                    }
                                                  }(),
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                                ),
                                                width: 2.5,
                                              ),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(16.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Contact 4',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleMedium
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleMediumFamily,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleMediumIsCustom,
                                                                ),
                                                      ),
                                                      FlutterFlowIconButton(
                                                        borderRadius: 16.0,
                                                        buttonSize: 32.0,
                                                        fillColor:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        icon: Icon(
                                                          Icons.delete_outline,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .info,
                                                          size: 16.0,
                                                        ),
                                                        onPressed: () async {
                                                          _deleteContactSlot(4);
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  if (_shouldShowContactEntryChoice(
                                                      4))
                                                    _buildContactEntryChoice(4)
                                                  else ...[
                                                    TextFormField(
                                                      controller: _model
                                                          .c4FirstTFTextController,
                                                      focusNode: _model
                                                          .c4FirstTFFocusNode,
                                                      autofocus: false,
                                                      textCapitalization:
                                                          TextCapitalization
                                                              .words,
                                                      textInputAction:
                                                          TextInputAction.next,
                                                      obscureText: false,
                                                      decoration:
                                                          InputDecoration(
                                                        hintText: 'First Name',
                                                        hintStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMediumIsCustom,
                                                                ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color:
                                                                valueOrDefault<
                                                                    Color>(
                                                              () {
                                                                if (_model
                                                                        .c4Status ==
                                                                    'Confirmed') {
                                                                  return Color(
                                                                      0xFF0CD40B);
                                                                } else if (_model
                                                                        .c4Status ==
                                                                    'Pending') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary;
                                                                } else if (_model
                                                                        .c4Status ==
                                                                    'Denied') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .error;
                                                                } else if (_model
                                                                        .c4Status ==
                                                                    'Opted out') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .error;
                                                                } else if (_model
                                                                        .c4Status ==
                                                                    'Not sent') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary;
                                                                } else {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary;
                                                                }
                                                              }(),
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .primary,
                                                            ),
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        errorBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: Color(
                                                                0x00000000),
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        focusedErrorBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: Color(
                                                                0x00000000),
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                      ),
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            fontSize: 16.0,
                                                            letterSpacing: 0.25,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                      keyboardType:
                                                          TextInputType.name,
                                                      cursorColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                      validator: _model
                                                          .c4FirstTFTextControllerValidator
                                                          .asValidator(context),
                                                      inputFormatters: [
                                                        if (!isAndroid &&
                                                            !isiOS)
                                                          TextInputFormatter
                                                              .withFunction(
                                                                  (oldValue,
                                                                      newValue) {
                                                            return TextEditingValue(
                                                              selection: newValue
                                                                  .selection,
                                                              text: newValue
                                                                  .text
                                                                  .toCapitalization(
                                                                      TextCapitalization
                                                                          .words),
                                                            );
                                                          }),
                                                      ],
                                                    ),
                                                    TextFormField(
                                                      controller: _model
                                                          .c4LastTFTextController,
                                                      focusNode: _model
                                                          .c4LastTFFocusNode,
                                                      autofocus: false,
                                                      textCapitalization:
                                                          TextCapitalization
                                                              .words,
                                                      textInputAction:
                                                          TextInputAction.next,
                                                      obscureText: false,
                                                      decoration:
                                                          InputDecoration(
                                                        hintText: 'Last Name',
                                                        hintStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMediumIsCustom,
                                                                ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color:
                                                                valueOrDefault<
                                                                    Color>(
                                                              () {
                                                                if (_model
                                                                        .c4Status ==
                                                                    'Confirmed') {
                                                                  return Color(
                                                                      0xFF0CD40B);
                                                                } else if (_model
                                                                        .c4Status ==
                                                                    'Pending') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary;
                                                                } else if (_model
                                                                        .c4Status ==
                                                                    'Denied') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .error;
                                                                } else if (_model
                                                                        .c4Status ==
                                                                    'Opted out') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .error;
                                                                } else if (_model
                                                                        .c4Status ==
                                                                    'Not sent') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary;
                                                                } else {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary;
                                                                }
                                                              }(),
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .primary,
                                                            ),
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        errorBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: Color(
                                                                0x00000000),
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        focusedErrorBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: Color(
                                                                0x00000000),
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                      ),
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            fontSize: 16.0,
                                                            letterSpacing: 0.25,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                      keyboardType:
                                                          TextInputType.name,
                                                      cursorColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                      validator: _model
                                                          .c4LastTFTextControllerValidator
                                                          .asValidator(context),
                                                      inputFormatters: [
                                                        if (!isAndroid &&
                                                            !isiOS)
                                                          TextInputFormatter
                                                              .withFunction(
                                                                  (oldValue,
                                                                      newValue) {
                                                            return TextEditingValue(
                                                              selection: newValue
                                                                  .selection,
                                                              text: newValue
                                                                  .text
                                                                  .toCapitalization(
                                                                      TextCapitalization
                                                                          .words),
                                                            );
                                                          }),
                                                      ],
                                                    ),
                                                    TextFormField(
                                                      controller: _model
                                                          .c4PhoneTFTextController,
                                                      focusNode: _model
                                                          .c4PhoneTFFocusNode,
                                                      onChanged: (_) {
                                                        _resetConsentStatusAfterPhoneEdit(
                                                            4);
                                                        EasyDebounce.debounce(
                                                          '_model.c4PhoneTFTextController',
                                                          Duration(
                                                              milliseconds:
                                                                  2000),
                                                          () async {
                                                            _model.c4PhoneDigits =
                                                                functions.sanitizePhoneDigits(
                                                                    _model
                                                                        .c4PhoneTFTextController
                                                                        .text);
                                                            safeSetState(() {});
                                                            if ((_model.c4PhoneDigits !=
                                                                        null &&
                                                                    _model.c4PhoneDigits !=
                                                                        '') &&
                                                                ((_model.c4PhoneDigits!)
                                                                        .length ==
                                                                    10)) {
                                                              safeSetState(() {
                                                                _model.c4PhoneTFTextController
                                                                        ?.text =
                                                                    functions.formatAsUsPhone(
                                                                        _model
                                                                            .c4PhoneDigits!);
                                                                _model
                                                                    .c4PhoneTFMask
                                                                    .updateMask(
                                                                  newValue:
                                                                      TextEditingValue(
                                                                    text: _model
                                                                        .c4PhoneTFTextController!
                                                                        .text,
                                                                  ),
                                                                );
                                                              });
                                                            }
                                                          },
                                                        );
                                                      },
                                                      autofocus: false,
                                                      textInputAction:
                                                          TextInputAction.next,
                                                      obscureText: false,
                                                      decoration:
                                                          InputDecoration(
                                                        hintText:
                                                            'Phone Number',
                                                        hintStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMediumIsCustom,
                                                                ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color:
                                                                valueOrDefault<
                                                                    Color>(
                                                              () {
                                                                if (_model
                                                                        .c4Status ==
                                                                    'Confirmed') {
                                                                  return Color(
                                                                      0xFF0CD40B);
                                                                } else if (_model
                                                                        .c4Status ==
                                                                    'Pending') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary;
                                                                } else if (_model
                                                                        .c4Status ==
                                                                    'Denied') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .error;
                                                                } else if (_model
                                                                        .c4Status ==
                                                                    'Opted out') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .error;
                                                                } else if (_model
                                                                        .c4Status ==
                                                                    'Not sent') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary;
                                                                } else {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary;
                                                                }
                                                              }(),
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .primary,
                                                            ),
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        errorBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: Color(
                                                                0x00000000),
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        focusedErrorBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: Color(
                                                                0x00000000),
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                      ),
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            fontSize: 16.0,
                                                            letterSpacing: 0.25,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                      keyboardType:
                                                          TextInputType.phone,
                                                      cursorColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                      validator: _model
                                                          .c4PhoneTFTextControllerValidator
                                                          .asValidator(context),
                                                    ),
                                                    SizedBox(
                                                      height: 30.0,
                                                      child: Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                0.0, 0.0),
                                                        child: Container(
                                                          width:
                                                              double.infinity,
                                                          height: 30.0,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryBackground,
                                                          ),
                                                          child: Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0.0, 0.0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Align(
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          0.0),
                                                                  child: Text(
                                                                    'Status: ',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          fontFamily:
                                                                              FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                          fontSize:
                                                                              16.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          useGoogleFonts:
                                                                              !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                        ),
                                                                  ),
                                                                ),
                                                                Text(
                                                                  () {
                                                                    if (_model
                                                                            .c4Status ==
                                                                        'Not sent') {
                                                                      return 'Not sent';
                                                                    } else if (_model
                                                                            .c4Status ==
                                                                        'Pending') {
                                                                      return 'Pending';
                                                                    } else if (_model
                                                                            .c4Status ==
                                                                        'Confirmed') {
                                                                      return 'Confirmed';
                                                                    } else if (_model
                                                                            .c4Status ==
                                                                        'Denied') {
                                                                      return 'Denied';
                                                                    } else if (_model
                                                                            .c4Status ==
                                                                        'Opted out') {
                                                                      return 'Opted out';
                                                                    } else {
                                                                      return 'Not sent';
                                                                    }
                                                                  }(),
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        fontFamily:
                                                                            FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                        color: valueOrDefault<
                                                                            Color>(
                                                                          () {
                                                                            if (_model.c4Status ==
                                                                                'Confirmed') {
                                                                              return Color(0xFF0CD40B);
                                                                            } else if (_model.c4Status ==
                                                                                'Pending') {
                                                                              return FlutterFlowTheme.of(context).primary;
                                                                            } else if (_model.c4Status ==
                                                                                'Denied') {
                                                                              return FlutterFlowTheme.of(context).error;
                                                                            } else if (_model.c4Status ==
                                                                                'Opted out') {
                                                                              return FlutterFlowTheme.of(context).error;
                                                                            } else if (_model.c4Status ==
                                                                                'Not sent') {
                                                                              return FlutterFlowTheme.of(context).primaryText;
                                                                            } else {
                                                                              return FlutterFlowTheme.of(context).primary;
                                                                            }
                                                                          }(),
                                                                          FlutterFlowTheme.of(context)
                                                                              .primaryText,
                                                                        ),
                                                                        fontSize:
                                                                            16.0,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        useGoogleFonts:
                                                                            !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Stack(
                                                      children: [
                                                        Material(
                                                          color: Colors
                                                              .transparent,
                                                          elevation: 3.0,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                          ),
                                                          child: Container(
                                                            width: 300.0,
                                                            height: 50.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primary,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                            ),
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0.0, 0.0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                  _consentInviteButtonLabel(
                                                                      4,
                                                                      _model
                                                                          .c4Status),
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        fontFamily:
                                                                            FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .info,
                                                                        fontSize:
                                                                            18.0,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        useGoogleFonts:
                                                                            !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                      ),
                                                                ),
                                                                Icon(
                                                                  _consentInviteButtonIcon(
                                                                      4),
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .info,
                                                                  size: 24.0,
                                                                ),
                                                              ].divide(SizedBox(
                                                                  width: 12.0)),
                                                            ),
                                                          ),
                                                        ),
                                                        Opacity(
                                                          opacity: 0.0,
                                                          child: FFButtonWidget(
                                                            onPressed:
                                                                () async {
                                                              if (_showingConsentInviteSent(
                                                                  4)) {
                                                                return;
                                                              }
                                                              _model.c4PhoneDigits =
                                                                  functions.sanitizePhoneDigits(
                                                                      _model
                                                                          .c4PhoneTFTextController
                                                                          .text);
                                                              safeSetState(
                                                                  () {});
                                                              await actions
                                                                  .dismissKeyboard(
                                                                context,
                                                              );
                                                              _model.contactsPayloadslot4 =
                                                                  await actions
                                                                      .buildContactsPayloadV2(
                                                                _model
                                                                    .c1FirstTFTextController
                                                                    .text,
                                                                _model
                                                                    .c1LastTFTextController
                                                                    .text,
                                                                _model
                                                                    .c1PhoneTFTextController
                                                                    .text,
                                                                _model
                                                                    .c2FirstTFTextController
                                                                    .text,
                                                                _model
                                                                    .c2LastTFTextController
                                                                    .text,
                                                                _model
                                                                    .c2PhoneTFTextController
                                                                    .text,
                                                                _model
                                                                    .c3FirstTFTextController
                                                                    .text,
                                                                _model
                                                                    .c3LastTFTextController
                                                                    .text,
                                                                _model
                                                                    .c3PhoneTFTextController
                                                                    .text,
                                                                _model
                                                                    .c4FirstTFTextController
                                                                    .text,
                                                                _model
                                                                    .c4LastTFTextController
                                                                    .text,
                                                                _model
                                                                    .c4PhoneTFTextController
                                                                    .text,
                                                                _model
                                                                    .c5FirstTFTextController
                                                                    .text,
                                                                _model
                                                                    .c5LastTFTextController
                                                                    .text,
                                                                _model
                                                                    .c5PhoneTFTextController
                                                                    .text,
                                                                _model
                                                                    .contactsCount,
                                                                _model.c1Status,
                                                                _model.c2Status,
                                                                _model.c3Status,
                                                                _model.c4Status,
                                                                _model.c5Status,
                                                              );
                                                              _model.contactsJson =
                                                                  _model
                                                                      .contactsPayloadslot4!;
                                                              safeSetState(
                                                                  () {});
                                                              if (loggedIn ==
                                                                  true) {
                                                                _model.keyOutslot4 =
                                                                    await _currentRowDataKeyForSave();
                                                                _model.dataKeyB64 =
                                                                    _model
                                                                        .keyOutslot4!;
                                                                safeSetState(
                                                                    () {});
                                                                _model.encslot4 =
                                                                    await actions
                                                                        .aesGcmEncryptString(
                                                                  _model
                                                                      .contactsJson,
                                                                  _model
                                                                      .dataKeyB64,
                                                                );
                                                                _model.ctB64 =
                                                                    getJsonField(
                                                                  _model
                                                                      .encslot4,
                                                                  r'''$.ciphertextB64''',
                                                                ).toString();
                                                                _model.nonceB64 =
                                                                    getJsonField(
                                                                  _model
                                                                      .encslot4,
                                                                  r'''$.nonceB64''',
                                                                ).toString();
                                                                safeSetState(
                                                                    () {});
                                                                _model.wrapslot4 =
                                                                    await WrapDataKeyCall
                                                                        .call(
                                                                  dataKeyB64: _model
                                                                      .dataKeyB64,
                                                                  jwt:
                                                                      await _jwtForApi(),
                                                                );

                                                                if ((_model
                                                                        .wrapslot4
                                                                        ?.succeeded ??
                                                                    false)) {
                                                                  _model.wrappedB64 =
                                                                      _jsonValue(
                                                                    (_model.wrapslot4
                                                                            ?.jsonBody ??
                                                                        ''),
                                                                    r'''$.wrappedB64''',
                                                                  );
                                                                  safeSetState(
                                                                      () {});
                                                                  _model.updslot4 =
                                                                      await DecoyWalletTable()
                                                                          .queryRows(
                                                                    queryFn: (q) =>
                                                                        q.eqOrNull(
                                                                      'user_id',
                                                                      currentUserUid,
                                                                    ),
                                                                  );
                                                                  if (_model.updslot4 !=
                                                                          null &&
                                                                      (_model.updslot4)!
                                                                          .isNotEmpty) {
                                                                    await DecoyWalletTable()
                                                                        .update(
                                                                      data: {
                                                                        'wrapped_datakey':
                                                                            _model.wrappedB64,
                                                                        'updated_at':
                                                                            supaSerialize<DateTime>(getCurrentTimestamp),
                                                                        'contacts_ciphertext':
                                                                            _model.ctB64,
                                                                        'contacts_nonce':
                                                                            _model.nonceB64,
                                                                        'contacts_version':
                                                                            1,
                                                                        'created_at':
                                                                            supaSerialize<DateTime>(getCurrentTimestamp),
                                                                        'contacts_complete': functions.hasConfirmedEmergencyContact(
                                                                            _model.c1Status,
                                                                            _model.c2Status,
                                                                            _model.c3Status,
                                                                            _model.c4Status,
                                                                            _model.c5Status),
                                                                      },
                                                                      matchingRows:
                                                                          (rows) =>
                                                                              rows.eqOrNull(
                                                                        'user_id',
                                                                        currentUserUid,
                                                                      ),
                                                                    );
                                                                    _model.decoyWalletRefresh1slot4444 =
                                                                        await DecoyWalletTable()
                                                                            .queryRows(
                                                                      queryFn:
                                                                          (q) =>
                                                                              q.eqOrNull(
                                                                        'user_id',
                                                                        currentUserUid,
                                                                      ),
                                                                    );
                                                                    FFAppState()
                                                                            .emergencyContactsIncrement =
                                                                        _model
                                                                            .contactsCount;
                                                                    safeSetState(
                                                                        () {});
                                                                  } else {
                                                                    _model.insRowslot4444 =
                                                                        await DecoyWalletTable()
                                                                            .insert({
                                                                      'wrapped_datakey':
                                                                          _model
                                                                              .wrappedB64,
                                                                      'updated_at':
                                                                          supaSerialize<DateTime>(
                                                                              getCurrentTimestamp),
                                                                      'contacts_ciphertext':
                                                                          _model
                                                                              .ctB64,
                                                                      'contacts_nonce':
                                                                          _model
                                                                              .nonceB64,
                                                                      'contacts_version':
                                                                          1,
                                                                      'user_id':
                                                                          currentUserUid,
                                                                      'contacts_complete': functions.hasConfirmedEmergencyContact(
                                                                          _model
                                                                              .c1Status,
                                                                          _model
                                                                              .c2Status,
                                                                          _model
                                                                              .c3Status,
                                                                          _model
                                                                              .c4Status,
                                                                          _model
                                                                              .c5Status),
                                                                    });
                                                                    _model.decoyWalletRefresh2slot4444 =
                                                                        await DecoyWalletTable()
                                                                            .queryRows(
                                                                      queryFn:
                                                                          (q) =>
                                                                              q.eqOrNull(
                                                                        'user_id',
                                                                        currentUserUid,
                                                                      ),
                                                                    );
                                                                    FFAppState()
                                                                            .emergencyContactsIncrement =
                                                                        _model
                                                                            .contactsCount;
                                                                    safeSetState(
                                                                        () {});
                                                                  }

                                                                  _model.consentSlotsList = functions
                                                                      .buildConsentSlotsListFINAL(
                                                                          _model
                                                                              .c1FirstTFTextController
                                                                              .text,
                                                                          _model
                                                                              .c1LastTFTextController
                                                                              .text,
                                                                          _model
                                                                              .c1PhoneTFTextController
                                                                              .text,
                                                                          _model
                                                                              .c1Status,
                                                                          _model
                                                                              .c2FirstTFTextController
                                                                              .text,
                                                                          _model
                                                                              .c2LastTFTextController
                                                                              .text,
                                                                          _model
                                                                              .c2PhoneTFTextController
                                                                              .text,
                                                                          _model
                                                                              .c2Status,
                                                                          _model
                                                                              .c3FirstTFTextController
                                                                              .text,
                                                                          _model
                                                                              .c3LastTFTextController
                                                                              .text,
                                                                          _model
                                                                              .c3PhoneTFTextController
                                                                              .text,
                                                                          _model
                                                                              .c3Status,
                                                                          _model
                                                                              .c4FirstTFTextController
                                                                              .text,
                                                                          _model
                                                                              .c4LastTFTextController
                                                                              .text,
                                                                          _model
                                                                              .c4PhoneTFTextController
                                                                              .text,
                                                                          _model
                                                                              .c4Status,
                                                                          _model
                                                                              .c5FirstTFTextController
                                                                              .text,
                                                                          _model
                                                                              .c5LastTFTextController
                                                                              .text,
                                                                          _model
                                                                              .c5PhoneTFTextController
                                                                              .text,
                                                                          _model
                                                                              .c5Status)
                                                                      .toList()
                                                                      .cast<
                                                                          dynamic>();
                                                                  safeSetState(
                                                                      () {});
                                                                  _model.syncConsentRespslot44 =
                                                                      await SyncConsentSlotsCall
                                                                          .call(
                                                                    jwt:
                                                                        currentJwtToken,
                                                                    slotsJsonJson:
                                                                        _model
                                                                            .consentSlotsList,
                                                                  );

                                                                  if ((_model
                                                                          .syncConsentRespslot44
                                                                          ?.succeeded ??
                                                                      true)) {
                                                                    _model.createConsentResp2slot4 =
                                                                        await CreateConsentRequestCall
                                                                            .call(
                                                                      userId:
                                                                          currentUserUid,
                                                                      contactSlot:
                                                                          4,
                                                                      firstName: _model
                                                                          .c4FirstTFTextController
                                                                          .text,
                                                                      lastName: _model
                                                                          .c4LastTFTextController
                                                                          .text,
                                                                      phoneNumber:
                                                                          _model
                                                                              .c4PhoneDigits,
                                                                      jwt:
                                                                          currentJwtToken,
                                                                    );

                                                                    if ((_model
                                                                            .createConsentResp2slot4
                                                                            ?.succeeded ??
                                                                        true)) {
                                                                      _model.consentSlotsList = functions
                                                                          .buildConsentSlotsListFINAL(
                                                                              _model.c1FirstTFTextController.text,
                                                                              _model.c1LastTFTextController.text,
                                                                              _model.c1PhoneTFTextController.text,
                                                                              'Pending',
                                                                              _model.c2FirstTFTextController.text,
                                                                              _model.c2LastTFTextController.text,
                                                                              _model.c2PhoneTFTextController.text,
                                                                              _model.c2Status,
                                                                              _model.c3FirstTFTextController.text,
                                                                              _model.c3LastTFTextController.text,
                                                                              _model.c3PhoneTFTextController.text,
                                                                              _model.c3Status,
                                                                              _model.c4FirstTFTextController.text,
                                                                              _model.c4LastTFTextController.text,
                                                                              _model.c4PhoneTFTextController.text,
                                                                              _model.c4Status,
                                                                              _model.c5FirstTFTextController.text,
                                                                              _model.c5LastTFTextController.text,
                                                                              _model.c5PhoneTFTextController.text,
                                                                              _model.c5Status)
                                                                          .toList()
                                                                          .cast<dynamic>();
                                                                      _model.c4Status =
                                                                          'Pending';
                                                                      safeSetState(
                                                                          () {});
                                                                      _showConsentInviteSent(
                                                                          4);

                                                                      _model.prettycooolslot4 =
                                                                          await GetConsentStatusesCall
                                                                              .call(
                                                                        jwt:
                                                                            currentJwtToken,
                                                                      );

                                                                      if ((_model
                                                                              .prettycooolslot4
                                                                              ?.succeeded ??
                                                                          true)) {
                                                                        _model.consentSlotsList = functions
                                                                            .buildConsentSlotsListFINAL(
                                                                                _model.c1FirstTFTextController.text,
                                                                                _model.c1LastTFTextController.text,
                                                                                _model.c1PhoneTFTextController.text,
                                                                                'Pending',
                                                                                _model.c2FirstTFTextController.text,
                                                                                _model.c2LastTFTextController.text,
                                                                                _model.c2PhoneTFTextController.text,
                                                                                _model.c2Status,
                                                                                _model.c3FirstTFTextController.text,
                                                                                _model.c3LastTFTextController.text,
                                                                                _model.c3PhoneTFTextController.text,
                                                                                _model.c3Status,
                                                                                _model.c4FirstTFTextController.text,
                                                                                _model.c4LastTFTextController.text,
                                                                                _model.c4PhoneTFTextController.text,
                                                                                _model.c4Status,
                                                                                _model.c5FirstTFTextController.text,
                                                                                _model.c5LastTFTextController.text,
                                                                                _model.c5PhoneTFTextController.text,
                                                                                _model.c5Status)
                                                                            .toList()
                                                                            .cast<dynamic>();
                                                                        _model.c4First =
                                                                            GetConsentStatusesCall.slot4First(
                                                                          (_model.prettycooolslot4?.jsonBody ??
                                                                              ''),
                                                                        ).toString();
                                                                        _model.c4Last =
                                                                            GetConsentStatusesCall.slot4Last(
                                                                          (_model.prettycooolslot4?.jsonBody ??
                                                                              ''),
                                                                        ).toString();
                                                                        _model.c4Phone =
                                                                            GetConsentStatusesCall.slot4Phone(
                                                                          (_model.prettycooolslot4?.jsonBody ??
                                                                              ''),
                                                                        ).toString();
                                                                        safeSetState(
                                                                            () {});
                                                                      }
                                                                    }
                                                                  }
                                                                } else {
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    SnackBar(
                                                                      content:
                                                                          Text(
                                                                        'ERROR #009 - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT',
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryText,
                                                                        ),
                                                                      ),
                                                                      duration: Duration(
                                                                          milliseconds:
                                                                              4000),
                                                                      backgroundColor:
                                                                          FlutterFlowTheme.of(context)
                                                                              .secondary,
                                                                    ),
                                                                  );
                                                                }
                                                              } else {
                                                                context.goNamed(
                                                                    LoginPageWidget
                                                                        .routeName);
                                                              }

                                                              safeSetState(
                                                                  () {});
                                                            },
                                                            text: _model.c4Status ==
                                                                    'Not sent'
                                                                ? 'Send Confirmation Link'
                                                                : 'Resend Confirmation Link',
                                                            options:
                                                                FFButtonOptions(
                                                              width: 300.0,
                                                              height: 50.0,
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          16.0,
                                                                          0.0,
                                                                          16.0,
                                                                          0.0),
                                                              iconPadding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          0.0,
                                                                          0.0),
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primary,
                                                              textStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .override(
                                                                        fontFamily:
                                                                            FlutterFlowTheme.of(context).titleSmallFamily,
                                                                        color: Colors
                                                                            .white,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        useGoogleFonts:
                                                                            !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                      ),
                                                              elevation: 3.0,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.0),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ].divide(
                                                    SizedBox(height: 12.0)),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (_model.contactsCount >= 5)
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            16.0, 16.0, 16.0, 0.0),
                                        child: Material(
                                          color: Colors.transparent,
                                          elevation: 3.0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          child: Container(
                                            width: 400.0,
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                              border: Border.all(
                                                color: valueOrDefault<Color>(
                                                  () {
                                                    if (_model.c5Status ==
                                                        'Confirmed') {
                                                      return Color(0xFF0CD40B);
                                                    } else if (_model
                                                            .c5Status ==
                                                        'Pending') {
                                                      return FlutterFlowTheme
                                                              .of(context)
                                                          .primary;
                                                    } else if (_model
                                                            .c5Status ==
                                                        'Denied') {
                                                      return FlutterFlowTheme
                                                              .of(context)
                                                          .error;
                                                    } else if (_model
                                                            .c5Status ==
                                                        'Opted out') {
                                                      return FlutterFlowTheme
                                                              .of(context)
                                                          .error;
                                                    } else if (_model
                                                            .c5Status ==
                                                        'Not sent') {
                                                      return FlutterFlowTheme
                                                              .of(context)
                                                          .primary;
                                                    } else {
                                                      return FlutterFlowTheme
                                                              .of(context)
                                                          .primary;
                                                    }
                                                  }(),
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                                ),
                                                width: 2.5,
                                              ),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(16.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Contact 5',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleMedium
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleMediumFamily,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleMediumIsCustom,
                                                                ),
                                                      ),
                                                      FlutterFlowIconButton(
                                                        borderRadius: 16.0,
                                                        buttonSize: 32.0,
                                                        fillColor:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        icon: Icon(
                                                          Icons.delete_outline,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .info,
                                                          size: 16.0,
                                                        ),
                                                        onPressed: () async {
                                                          _deleteContactSlot(5);
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  if (_shouldShowContactEntryChoice(
                                                      5))
                                                    _buildContactEntryChoice(5)
                                                  else ...[
                                                    TextFormField(
                                                      controller: _model
                                                          .c5FirstTFTextController,
                                                      focusNode: _model
                                                          .c5FirstTFFocusNode,
                                                      autofocus: false,
                                                      textCapitalization:
                                                          TextCapitalization
                                                              .words,
                                                      textInputAction:
                                                          TextInputAction.next,
                                                      obscureText: false,
                                                      decoration:
                                                          InputDecoration(
                                                        hintText: 'First Name',
                                                        hintStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMediumIsCustom,
                                                                ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color:
                                                                valueOrDefault<
                                                                    Color>(
                                                              () {
                                                                if (_model
                                                                        .c5Status ==
                                                                    'Confirmed') {
                                                                  return Color(
                                                                      0xFF0CD40B);
                                                                } else if (_model
                                                                        .c5Status ==
                                                                    'Pending') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary;
                                                                } else if (_model
                                                                        .c5Status ==
                                                                    'Denied') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .error;
                                                                } else if (_model
                                                                        .c5Status ==
                                                                    'Opted out') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .error;
                                                                } else if (_model
                                                                        .c5Status ==
                                                                    'Not sent') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary;
                                                                } else {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary;
                                                                }
                                                              }(),
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .primary,
                                                            ),
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        errorBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: Color(
                                                                0x00000000),
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        focusedErrorBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: Color(
                                                                0x00000000),
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                      ),
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            fontSize: 16.0,
                                                            letterSpacing: 0.25,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                      keyboardType:
                                                          TextInputType.name,
                                                      cursorColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                      validator: _model
                                                          .c5FirstTFTextControllerValidator
                                                          .asValidator(context),
                                                      inputFormatters: [
                                                        if (!isAndroid &&
                                                            !isiOS)
                                                          TextInputFormatter
                                                              .withFunction(
                                                                  (oldValue,
                                                                      newValue) {
                                                            return TextEditingValue(
                                                              selection: newValue
                                                                  .selection,
                                                              text: newValue
                                                                  .text
                                                                  .toCapitalization(
                                                                      TextCapitalization
                                                                          .words),
                                                            );
                                                          }),
                                                      ],
                                                    ),
                                                    TextFormField(
                                                      controller: _model
                                                          .c5LastTFTextController,
                                                      focusNode: _model
                                                          .c5LastTFFocusNode,
                                                      autofocus: false,
                                                      textCapitalization:
                                                          TextCapitalization
                                                              .words,
                                                      textInputAction:
                                                          TextInputAction.next,
                                                      obscureText: false,
                                                      decoration:
                                                          InputDecoration(
                                                        hintText: 'Last Name',
                                                        hintStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMediumIsCustom,
                                                                ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color:
                                                                valueOrDefault<
                                                                    Color>(
                                                              () {
                                                                if (_model
                                                                        .c5Status ==
                                                                    'Confirmed') {
                                                                  return Color(
                                                                      0xFF0CD40B);
                                                                } else if (_model
                                                                        .c5Status ==
                                                                    'Pending') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary;
                                                                } else if (_model
                                                                        .c5Status ==
                                                                    'Denied') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .error;
                                                                } else if (_model
                                                                        .c5Status ==
                                                                    'Opted out') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .error;
                                                                } else if (_model
                                                                        .c5Status ==
                                                                    'Not sent') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary;
                                                                } else {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary;
                                                                }
                                                              }(),
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .primary,
                                                            ),
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        errorBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: Color(
                                                                0x00000000),
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        focusedErrorBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: Color(
                                                                0x00000000),
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                      ),
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            fontSize: 16.0,
                                                            letterSpacing: 0.25,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                      keyboardType:
                                                          TextInputType.name,
                                                      cursorColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                      validator: _model
                                                          .c5LastTFTextControllerValidator
                                                          .asValidator(context),
                                                      inputFormatters: [
                                                        if (!isAndroid &&
                                                            !isiOS)
                                                          TextInputFormatter
                                                              .withFunction(
                                                                  (oldValue,
                                                                      newValue) {
                                                            return TextEditingValue(
                                                              selection: newValue
                                                                  .selection,
                                                              text: newValue
                                                                  .text
                                                                  .toCapitalization(
                                                                      TextCapitalization
                                                                          .words),
                                                            );
                                                          }),
                                                      ],
                                                    ),
                                                    TextFormField(
                                                      controller: _model
                                                          .c5PhoneTFTextController,
                                                      focusNode: _model
                                                          .c5PhoneTFFocusNode,
                                                      onChanged: (_) {
                                                        _resetConsentStatusAfterPhoneEdit(
                                                            5);
                                                        EasyDebounce.debounce(
                                                          '_model.c5PhoneTFTextController',
                                                          Duration(
                                                              milliseconds:
                                                                  2000),
                                                          () async {
                                                            _model.c5PhoneDigits =
                                                                functions.sanitizePhoneDigits(
                                                                    _model
                                                                        .c5PhoneTFTextController
                                                                        .text);
                                                            safeSetState(() {});
                                                            if ((_model.c5PhoneDigits !=
                                                                        null &&
                                                                    _model.c5PhoneDigits !=
                                                                        '') &&
                                                                ((_model.c5PhoneDigits!)
                                                                        .length ==
                                                                    10)) {
                                                              safeSetState(() {
                                                                _model.c5PhoneTFTextController
                                                                        ?.text =
                                                                    functions.formatAsUsPhone(
                                                                        _model
                                                                            .c5PhoneDigits!);
                                                                _model
                                                                    .c5PhoneTFMask
                                                                    .updateMask(
                                                                  newValue:
                                                                      TextEditingValue(
                                                                    text: _model
                                                                        .c5PhoneTFTextController!
                                                                        .text,
                                                                  ),
                                                                );
                                                              });
                                                            }
                                                          },
                                                        );
                                                      },
                                                      autofocus: false,
                                                      textInputAction:
                                                          TextInputAction.done,
                                                      obscureText: false,
                                                      decoration:
                                                          InputDecoration(
                                                        hintText:
                                                            'Phone Number',
                                                        hintStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMediumIsCustom,
                                                                ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color:
                                                                valueOrDefault<
                                                                    Color>(
                                                              () {
                                                                if (_model
                                                                        .c5Status ==
                                                                    'Confirmed') {
                                                                  return Color(
                                                                      0xFF0CD40B);
                                                                } else if (_model
                                                                        .c5Status ==
                                                                    'Pending') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary;
                                                                } else if (_model
                                                                        .c5Status ==
                                                                    'Denied') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .error;
                                                                } else if (_model
                                                                        .c5Status ==
                                                                    'Opted out') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .error;
                                                                } else if (_model
                                                                        .c5Status ==
                                                                    'Not sent') {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary;
                                                                } else {
                                                                  return FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary;
                                                                }
                                                              }(),
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .primary,
                                                            ),
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        errorBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: Color(
                                                                0x00000000),
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        focusedErrorBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: Color(
                                                                0x00000000),
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                      ),
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            fontSize: 16.0,
                                                            letterSpacing: 0.25,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                      keyboardType:
                                                          TextInputType.phone,
                                                      cursorColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                      validator: _model
                                                          .c5PhoneTFTextControllerValidator
                                                          .asValidator(context),
                                                    ),
                                                    SizedBox(
                                                      height: 30.0,
                                                      child: Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                0.0, 0.0),
                                                        child: Container(
                                                          width:
                                                              double.infinity,
                                                          height: 30.0,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryBackground,
                                                          ),
                                                          child: Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0.0, 0.0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Align(
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          0.0),
                                                                  child: Text(
                                                                    'Status: ',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          fontFamily:
                                                                              FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                          fontSize:
                                                                              16.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          useGoogleFonts:
                                                                              !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                        ),
                                                                  ),
                                                                ),
                                                                Text(
                                                                  () {
                                                                    if (_model
                                                                            .c5Status ==
                                                                        'Not sent') {
                                                                      return 'Not sent';
                                                                    } else if (_model
                                                                            .c5Status ==
                                                                        'Pending') {
                                                                      return 'Pending';
                                                                    } else if (_model
                                                                            .c5Status ==
                                                                        'Confirmed') {
                                                                      return 'Confirmed';
                                                                    } else if (_model
                                                                            .c5Status ==
                                                                        'Denied') {
                                                                      return 'Denied';
                                                                    } else if (_model
                                                                            .c5Status ==
                                                                        'Opted out') {
                                                                      return 'Opted out';
                                                                    } else {
                                                                      return 'Not sent';
                                                                    }
                                                                  }(),
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        fontFamily:
                                                                            FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                        color: valueOrDefault<
                                                                            Color>(
                                                                          () {
                                                                            if (_model.c5Status ==
                                                                                'Confirmed') {
                                                                              return Color(0xFF0CD40B);
                                                                            } else if (_model.c5Status ==
                                                                                'Pending') {
                                                                              return FlutterFlowTheme.of(context).primary;
                                                                            } else if (_model.c5Status ==
                                                                                'Denied') {
                                                                              return FlutterFlowTheme.of(context).error;
                                                                            } else if (_model.c5Status ==
                                                                                'Opted out') {
                                                                              return FlutterFlowTheme.of(context).error;
                                                                            } else if (_model.c5Status ==
                                                                                'Not sent') {
                                                                              return FlutterFlowTheme.of(context).primaryText;
                                                                            } else {
                                                                              return FlutterFlowTheme.of(context).primary;
                                                                            }
                                                                          }(),
                                                                          FlutterFlowTheme.of(context)
                                                                              .primaryText,
                                                                        ),
                                                                        fontSize:
                                                                            16.0,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        useGoogleFonts:
                                                                            !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Stack(
                                                      children: [
                                                        Material(
                                                          color: Colors
                                                              .transparent,
                                                          elevation: 3.0,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                          ),
                                                          child: Container(
                                                            width: 300.0,
                                                            height: 50.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primary,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                            ),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                  _consentInviteButtonLabel(
                                                                      5,
                                                                      _model
                                                                          .c5Status),
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        fontFamily:
                                                                            FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .info,
                                                                        fontSize:
                                                                            18.0,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        useGoogleFonts:
                                                                            !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                      ),
                                                                ),
                                                                Icon(
                                                                  _consentInviteButtonIcon(
                                                                      5),
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .info,
                                                                  size: 24.0,
                                                                ),
                                                              ].divide(SizedBox(
                                                                  width: 12.0)),
                                                            ),
                                                          ),
                                                        ),
                                                        Opacity(
                                                          opacity: 0.0,
                                                          child: FFButtonWidget(
                                                            onPressed:
                                                                () async {
                                                              if (_showingConsentInviteSent(
                                                                  5)) {
                                                                return;
                                                              }
                                                              _model.c5PhoneDigits =
                                                                  functions.sanitizePhoneDigits(
                                                                      _model
                                                                          .c5PhoneTFTextController
                                                                          .text);
                                                              safeSetState(
                                                                  () {});
                                                              await actions
                                                                  .dismissKeyboard(
                                                                context,
                                                              );
                                                              _model.contactsPayloadslot5 =
                                                                  await actions
                                                                      .buildContactsPayloadV2(
                                                                _model
                                                                    .c1FirstTFTextController
                                                                    .text,
                                                                _model
                                                                    .c1LastTFTextController
                                                                    .text,
                                                                _model
                                                                    .c1PhoneTFTextController
                                                                    .text,
                                                                _model
                                                                    .c2FirstTFTextController
                                                                    .text,
                                                                _model
                                                                    .c2LastTFTextController
                                                                    .text,
                                                                _model
                                                                    .c2PhoneTFTextController
                                                                    .text,
                                                                _model
                                                                    .c3FirstTFTextController
                                                                    .text,
                                                                _model
                                                                    .c3LastTFTextController
                                                                    .text,
                                                                _model
                                                                    .c3PhoneTFTextController
                                                                    .text,
                                                                _model
                                                                    .c4FirstTFTextController
                                                                    .text,
                                                                _model
                                                                    .c4LastTFTextController
                                                                    .text,
                                                                _model
                                                                    .c4PhoneTFTextController
                                                                    .text,
                                                                _model
                                                                    .c5FirstTFTextController
                                                                    .text,
                                                                _model
                                                                    .c5LastTFTextController
                                                                    .text,
                                                                _model
                                                                    .c5PhoneTFTextController
                                                                    .text,
                                                                _model
                                                                    .contactsCount,
                                                                _model.c1Status,
                                                                _model.c2Status,
                                                                _model.c3Status,
                                                                _model.c4Status,
                                                                _model.c5Status,
                                                              );
                                                              _model.contactsJson =
                                                                  _model
                                                                      .contactsPayloadslot5!;
                                                              safeSetState(
                                                                  () {});
                                                              if (loggedIn ==
                                                                  true) {
                                                                _model.keyOutslot5 =
                                                                    await _currentRowDataKeyForSave();
                                                                _model.dataKeyB64 =
                                                                    _model
                                                                        .keyOutslot5!;
                                                                safeSetState(
                                                                    () {});
                                                                _model.encslot5 =
                                                                    await actions
                                                                        .aesGcmEncryptString(
                                                                  _model
                                                                      .contactsJson,
                                                                  _model
                                                                      .dataKeyB64,
                                                                );
                                                                _model.ctB64 =
                                                                    getJsonField(
                                                                  _model
                                                                      .encslot5,
                                                                  r'''$.ciphertextB64''',
                                                                ).toString();
                                                                _model.nonceB64 =
                                                                    getJsonField(
                                                                  _model
                                                                      .encslot5,
                                                                  r'''$.nonceB64''',
                                                                ).toString();
                                                                safeSetState(
                                                                    () {});
                                                                _model.wrapslot5 =
                                                                    await WrapDataKeyCall
                                                                        .call(
                                                                  dataKeyB64: _model
                                                                      .dataKeyB64,
                                                                  jwt:
                                                                      await _jwtForApi(),
                                                                );

                                                                if ((_model
                                                                        .wrapslot5
                                                                        ?.succeeded ??
                                                                    false)) {
                                                                  _model.wrappedB64 =
                                                                      _jsonValue(
                                                                    (_model.wrapslot5
                                                                            ?.jsonBody ??
                                                                        ''),
                                                                    r'''$.wrappedB64''',
                                                                  );
                                                                  safeSetState(
                                                                      () {});
                                                                  _model.updslot5 =
                                                                      await DecoyWalletTable()
                                                                          .queryRows(
                                                                    queryFn: (q) =>
                                                                        q.eqOrNull(
                                                                      'user_id',
                                                                      currentUserUid,
                                                                    ),
                                                                  );
                                                                  if (_model.updslot5 !=
                                                                          null &&
                                                                      (_model.updslot5)!
                                                                          .isNotEmpty) {
                                                                    await DecoyWalletTable()
                                                                        .update(
                                                                      data: {
                                                                        'wrapped_datakey':
                                                                            _model.wrappedB64,
                                                                        'updated_at':
                                                                            supaSerialize<DateTime>(getCurrentTimestamp),
                                                                        'contacts_ciphertext':
                                                                            _model.ctB64,
                                                                        'contacts_nonce':
                                                                            _model.nonceB64,
                                                                        'contacts_version':
                                                                            1,
                                                                        'created_at':
                                                                            supaSerialize<DateTime>(getCurrentTimestamp),
                                                                        'contacts_complete': functions.hasConfirmedEmergencyContact(
                                                                            _model.c1Status,
                                                                            _model.c2Status,
                                                                            _model.c3Status,
                                                                            _model.c4Status,
                                                                            _model.c5Status),
                                                                      },
                                                                      matchingRows:
                                                                          (rows) =>
                                                                              rows.eqOrNull(
                                                                        'user_id',
                                                                        currentUserUid,
                                                                      ),
                                                                    );
                                                                    _model.decoyWalletRefresh1slot5555 =
                                                                        await DecoyWalletTable()
                                                                            .queryRows(
                                                                      queryFn:
                                                                          (q) =>
                                                                              q.eqOrNull(
                                                                        'user_id',
                                                                        currentUserUid,
                                                                      ),
                                                                    );
                                                                    FFAppState()
                                                                            .emergencyContactsIncrement =
                                                                        _model
                                                                            .contactsCount;
                                                                    safeSetState(
                                                                        () {});
                                                                  } else {
                                                                    _model.insRowslot5555 =
                                                                        await DecoyWalletTable()
                                                                            .insert({
                                                                      'wrapped_datakey':
                                                                          _model
                                                                              .wrappedB64,
                                                                      'updated_at':
                                                                          supaSerialize<DateTime>(
                                                                              getCurrentTimestamp),
                                                                      'contacts_ciphertext':
                                                                          _model
                                                                              .ctB64,
                                                                      'contacts_nonce':
                                                                          _model
                                                                              .nonceB64,
                                                                      'contacts_version':
                                                                          1,
                                                                      'user_id':
                                                                          currentUserUid,
                                                                      'contacts_complete': functions.hasConfirmedEmergencyContact(
                                                                          _model
                                                                              .c1Status,
                                                                          _model
                                                                              .c2Status,
                                                                          _model
                                                                              .c3Status,
                                                                          _model
                                                                              .c4Status,
                                                                          _model
                                                                              .c5Status),
                                                                    });
                                                                    _model.decoyWalletRefresh2slot5555 =
                                                                        await DecoyWalletTable()
                                                                            .queryRows(
                                                                      queryFn:
                                                                          (q) =>
                                                                              q.eqOrNull(
                                                                        'user_id',
                                                                        currentUserUid,
                                                                      ),
                                                                    );
                                                                    FFAppState()
                                                                            .emergencyContactsIncrement =
                                                                        _model
                                                                            .contactsCount;
                                                                    safeSetState(
                                                                        () {});
                                                                  }

                                                                  _model.consentSlotsList = functions
                                                                      .buildConsentSlotsListFINAL(
                                                                          _model
                                                                              .c1FirstTFTextController
                                                                              .text,
                                                                          _model
                                                                              .c1LastTFTextController
                                                                              .text,
                                                                          _model
                                                                              .c1PhoneTFTextController
                                                                              .text,
                                                                          _model
                                                                              .c1Status,
                                                                          _model
                                                                              .c2FirstTFTextController
                                                                              .text,
                                                                          _model
                                                                              .c2LastTFTextController
                                                                              .text,
                                                                          _model
                                                                              .c2PhoneTFTextController
                                                                              .text,
                                                                          _model
                                                                              .c2Status,
                                                                          _model
                                                                              .c3FirstTFTextController
                                                                              .text,
                                                                          _model
                                                                              .c3LastTFTextController
                                                                              .text,
                                                                          _model
                                                                              .c3PhoneTFTextController
                                                                              .text,
                                                                          _model
                                                                              .c3Status,
                                                                          _model
                                                                              .c4FirstTFTextController
                                                                              .text,
                                                                          _model
                                                                              .c4LastTFTextController
                                                                              .text,
                                                                          _model
                                                                              .c4PhoneTFTextController
                                                                              .text,
                                                                          _model
                                                                              .c4Status,
                                                                          _model
                                                                              .c5FirstTFTextController
                                                                              .text,
                                                                          _model
                                                                              .c5LastTFTextController
                                                                              .text,
                                                                          _model
                                                                              .c5PhoneTFTextController
                                                                              .text,
                                                                          _model
                                                                              .c5Status)
                                                                      .toList()
                                                                      .cast<
                                                                          dynamic>();
                                                                  safeSetState(
                                                                      () {});
                                                                  _model.syncConsentRespslot55 =
                                                                      await SyncConsentSlotsCall
                                                                          .call(
                                                                    jwt:
                                                                        currentJwtToken,
                                                                    slotsJsonJson:
                                                                        _model
                                                                            .consentSlotsList,
                                                                  );

                                                                  if ((_model
                                                                          .syncConsentRespslot55
                                                                          ?.succeeded ??
                                                                      true)) {
                                                                    _model.createConsentResp2slot5 =
                                                                        await CreateConsentRequestCall
                                                                            .call(
                                                                      userId:
                                                                          currentUserUid,
                                                                      contactSlot:
                                                                          5,
                                                                      firstName: _model
                                                                          .c5FirstTFTextController
                                                                          .text,
                                                                      lastName: _model
                                                                          .c5LastTFTextController
                                                                          .text,
                                                                      phoneNumber:
                                                                          _model
                                                                              .c5PhoneDigits,
                                                                      jwt:
                                                                          currentJwtToken,
                                                                    );

                                                                    if ((_model
                                                                            .createConsentResp2slot5
                                                                            ?.succeeded ??
                                                                        true)) {
                                                                      _model.consentSlotsList = functions
                                                                          .buildConsentSlotsListFINAL(
                                                                              _model.c1FirstTFTextController.text,
                                                                              _model.c1LastTFTextController.text,
                                                                              _model.c1PhoneTFTextController.text,
                                                                              'Pending',
                                                                              _model.c2FirstTFTextController.text,
                                                                              _model.c2LastTFTextController.text,
                                                                              _model.c2PhoneTFTextController.text,
                                                                              _model.c2Status,
                                                                              _model.c3FirstTFTextController.text,
                                                                              _model.c3LastTFTextController.text,
                                                                              _model.c3PhoneTFTextController.text,
                                                                              _model.c3Status,
                                                                              _model.c4FirstTFTextController.text,
                                                                              _model.c4LastTFTextController.text,
                                                                              _model.c4PhoneTFTextController.text,
                                                                              _model.c4Status,
                                                                              _model.c5FirstTFTextController.text,
                                                                              _model.c5LastTFTextController.text,
                                                                              _model.c5PhoneTFTextController.text,
                                                                              _model.c5Status)
                                                                          .toList()
                                                                          .cast<dynamic>();
                                                                      _model.c5Status =
                                                                          'Pending';
                                                                      safeSetState(
                                                                          () {});
                                                                      _showConsentInviteSent(
                                                                          5);

                                                                      _model.prettycooolslot5 =
                                                                          await GetConsentStatusesCall
                                                                              .call(
                                                                        jwt:
                                                                            currentJwtToken,
                                                                      );

                                                                      if ((_model
                                                                              .prettycooolslot5
                                                                              ?.succeeded ??
                                                                          true)) {
                                                                        _model.consentSlotsList = functions
                                                                            .buildConsentSlotsListFINAL(
                                                                                _model.c1FirstTFTextController.text,
                                                                                _model.c1LastTFTextController.text,
                                                                                _model.c1PhoneTFTextController.text,
                                                                                'Pending',
                                                                                _model.c2FirstTFTextController.text,
                                                                                _model.c2LastTFTextController.text,
                                                                                _model.c2PhoneTFTextController.text,
                                                                                _model.c2Status,
                                                                                _model.c3FirstTFTextController.text,
                                                                                _model.c3LastTFTextController.text,
                                                                                _model.c3PhoneTFTextController.text,
                                                                                _model.c3Status,
                                                                                _model.c4FirstTFTextController.text,
                                                                                _model.c4LastTFTextController.text,
                                                                                _model.c4PhoneTFTextController.text,
                                                                                _model.c4Status,
                                                                                _model.c5FirstTFTextController.text,
                                                                                _model.c5LastTFTextController.text,
                                                                                _model.c5PhoneTFTextController.text,
                                                                                _model.c5Status)
                                                                            .toList()
                                                                            .cast<dynamic>();
                                                                        _model.c5First =
                                                                            GetConsentStatusesCall.slot5First(
                                                                          (_model.prettycooolslot5?.jsonBody ??
                                                                              ''),
                                                                        ).toString();
                                                                        _model.c5Last =
                                                                            GetConsentStatusesCall.slot5Last(
                                                                          (_model.prettycooolslot5?.jsonBody ??
                                                                              ''),
                                                                        ).toString();
                                                                        _model.c5Phone =
                                                                            GetConsentStatusesCall.slot5Phone(
                                                                          (_model.prettycooolslot5?.jsonBody ??
                                                                              ''),
                                                                        ).toString();
                                                                        safeSetState(
                                                                            () {});
                                                                      }
                                                                    }
                                                                  }
                                                                } else {
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    SnackBar(
                                                                      content:
                                                                          Text(
                                                                        'ERROR #009 - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT',
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryText,
                                                                        ),
                                                                      ),
                                                                      duration: Duration(
                                                                          milliseconds:
                                                                              4000),
                                                                      backgroundColor:
                                                                          FlutterFlowTheme.of(context)
                                                                              .secondary,
                                                                    ),
                                                                  );
                                                                }
                                                              } else {
                                                                context.goNamed(
                                                                    LoginPageWidget
                                                                        .routeName);
                                                              }

                                                              safeSetState(
                                                                  () {});
                                                            },
                                                            text: _model.c5Status ==
                                                                    'Not sent'
                                                                ? 'Send Confirmation Link'
                                                                : 'Resend Confirmation Link',
                                                            options:
                                                                FFButtonOptions(
                                                              width: 300.0,
                                                              height: 50.0,
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          16.0,
                                                                          0.0,
                                                                          16.0,
                                                                          0.0),
                                                              iconPadding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          0.0,
                                                                          0.0),
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primary,
                                                              textStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .override(
                                                                        fontFamily:
                                                                            FlutterFlowTheme.of(context).titleSmallFamily,
                                                                        color: Colors
                                                                            .white,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        useGoogleFonts:
                                                                            !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                      ),
                                                              elevation: 3.0,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.0),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ].divide(
                                                    SizedBox(height: 12.0)),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (_model.contactsCount <= 4)
                                      FlutterFlowIconButton(
                                        borderRadius: 0.0,
                                        fillColor: Colors.white,
                                        icon: Icon(
                                          Icons.add_circle_rounded,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          size: 35.0,
                                        ),
                                        onPressed: () async {
                                          safeSetState(() {
                                            _model.contactsCount =
                                                (_model.contactsCount + 1)
                                                    .clamp(1, 5)
                                                    .toInt();
                                          });
                                        },
                                      ),
                                    Align(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: FFButtonWidget(
                                        onPressed: () async {
                                          await actions.dismissKeyboard(
                                            context,
                                          );
                                          _model.contactsPayload = await actions
                                              .buildContactsPayloadV2(
                                            _model.c1FirstTFTextController.text,
                                            _model.c1LastTFTextController.text,
                                            _model.c1PhoneTFTextController.text,
                                            _model.c2FirstTFTextController.text,
                                            _model.c2LastTFTextController.text,
                                            _model.c2PhoneTFTextController.text,
                                            _model.c3FirstTFTextController.text,
                                            _model.c3LastTFTextController.text,
                                            _model.c3PhoneTFTextController.text,
                                            _model.c4FirstTFTextController.text,
                                            _model.c4LastTFTextController.text,
                                            _model.c4PhoneTFTextController.text,
                                            _model.c5FirstTFTextController.text,
                                            _model.c5LastTFTextController.text,
                                            _model.c5PhoneTFTextController.text,
                                            _model.contactsCount,
                                            _model.c1Status,
                                            _model.c2Status,
                                            _model.c3Status,
                                            _model.c4Status,
                                            _model.c5Status,
                                          );
                                          _model.contactsJson =
                                              _model.contactsPayload!;
                                          safeSetState(() {});
                                          if (loggedIn == true) {
                                            _model.keyOut =
                                                await _currentRowDataKeyForSave();
                                            _model.dataKeyB64 = _model.keyOut!;
                                            safeSetState(() {});
                                            _model.enc = await actions
                                                .aesGcmEncryptString(
                                              _model.contactsJson,
                                              _model.dataKeyB64,
                                            );
                                            _model.ctB64 = getJsonField(
                                              _model.enc,
                                              r'''$.ciphertextB64''',
                                            ).toString();
                                            _model.nonceB64 = getJsonField(
                                              _model.enc,
                                              r'''$.nonceB64''',
                                            ).toString();
                                            safeSetState(() {});
                                            _model.wrap =
                                                await WrapDataKeyCall.call(
                                              dataKeyB64: _model.dataKeyB64,
                                              jwt: await _jwtForApi(),
                                            );

                                            if ((_model.wrap?.succeeded ??
                                                false)) {
                                              _model.wrappedB64 = _jsonValue(
                                                (_model.wrap?.jsonBody ?? ''),
                                                r'''$.wrappedB64''',
                                              );
                                              safeSetState(() {});
                                              _model.upd =
                                                  await DecoyWalletTable()
                                                      .queryRows(
                                                queryFn: (q) => q.eqOrNull(
                                                  'user_id',
                                                  currentUserUid,
                                                ),
                                              );
                                              if (_model.upd != null &&
                                                  (_model.upd)!.isNotEmpty) {
                                                await DecoyWalletTable().update(
                                                  data: {
                                                    'wrapped_datakey':
                                                        _model.wrappedB64,
                                                    'updated_at': supaSerialize<
                                                            DateTime>(
                                                        getCurrentTimestamp),
                                                    'contacts_ciphertext':
                                                        _model.ctB64,
                                                    'contacts_nonce':
                                                        _model.nonceB64,
                                                    'contacts_version': 1,
                                                    'created_at': supaSerialize<
                                                            DateTime>(
                                                        getCurrentTimestamp),
                                                    'contacts_complete': functions
                                                        .hasConfirmedEmergencyContact(
                                                            _model.c1Status,
                                                            _model.c2Status,
                                                            _model.c3Status,
                                                            _model.c4Status,
                                                            _model.c5Status),
                                                  },
                                                  matchingRows: (rows) =>
                                                      rows.eqOrNull(
                                                    'user_id',
                                                    currentUserUid,
                                                  ),
                                                );
                                                _model.decoyWalletRefresh1 =
                                                    await DecoyWalletTable()
                                                        .queryRows(
                                                  queryFn: (q) => q.eqOrNull(
                                                    'user_id',
                                                    currentUserUid,
                                                  ),
                                                );
                                                FFAppState()
                                                        .emergencyContactsIncrement =
                                                    _model.contactsCount;
                                                safeSetState(() {});
                                              } else {
                                                _model.insRow =
                                                    await DecoyWalletTable()
                                                        .insert({
                                                  'wrapped_datakey':
                                                      _model.wrappedB64,
                                                  'updated_at':
                                                      supaSerialize<DateTime>(
                                                          getCurrentTimestamp),
                                                  'contacts_ciphertext':
                                                      _model.ctB64,
                                                  'contacts_nonce':
                                                      _model.nonceB64,
                                                  'contacts_version': 1,
                                                  'user_id': currentUserUid,
                                                  'contacts_complete': functions
                                                      .hasConfirmedEmergencyContact(
                                                    _model.c1Status,
                                                    _model.c2Status,
                                                    _model.c3Status,
                                                    _model.c4Status,
                                                    _model.c5Status,
                                                  ),
                                                });
                                                _model.decoyWalletRefresh2 =
                                                    await DecoyWalletTable()
                                                        .queryRows(
                                                  queryFn: (q) => q.eqOrNull(
                                                    'user_id',
                                                    currentUserUid,
                                                  ),
                                                );
                                                FFAppState()
                                                        .emergencyContactsIncrement =
                                                    _model.contactsCount;
                                                safeSetState(() {});
                                              }

                                              await _rememberDataKey(
                                                  _model.dataKeyB64);
                                              await _rememberEncryptedContactsCache(
                                                cipherB64: _model.ctB64,
                                                nonceB64: _model.nonceB64,
                                                wrappedB64: _model.wrappedB64,
                                              );
                                              _rememberSessionContactsCache();
                                              _model.consentSlotsList = functions
                                                  .buildConsentSlotsListFINAL(
                                                      _model
                                                          .c1FirstTFTextController
                                                          .text,
                                                      _model
                                                          .c1LastTFTextController
                                                          .text,
                                                      _model
                                                          .c1PhoneTFTextController
                                                          .text,
                                                      _model.c1Status,
                                                      _model
                                                          .c2FirstTFTextController
                                                          .text,
                                                      _model
                                                          .c2LastTFTextController
                                                          .text,
                                                      _model
                                                          .c2PhoneTFTextController
                                                          .text,
                                                      _model.c2Status,
                                                      _model
                                                          .c3FirstTFTextController
                                                          .text,
                                                      _model
                                                          .c3LastTFTextController
                                                          .text,
                                                      _model
                                                          .c3PhoneTFTextController
                                                          .text,
                                                      _model.c3Status,
                                                      _model
                                                          .c4FirstTFTextController
                                                          .text,
                                                      _model
                                                          .c4LastTFTextController
                                                          .text,
                                                      _model
                                                          .c4PhoneTFTextController
                                                          .text,
                                                      _model.c4Status,
                                                      _model
                                                          .c5FirstTFTextController
                                                          .text,
                                                      _model
                                                          .c5LastTFTextController
                                                          .text,
                                                      _model
                                                          .c5PhoneTFTextController
                                                          .text,
                                                      _model.c5Status)
                                                  .toList()
                                                  .cast<dynamic>();
                                              safeSetState(() {});
                                              _model.syncConsentResp =
                                                  await SyncConsentSlotsCall
                                                      .call(
                                                jwt: await _jwtForApi(),
                                                slotsJsonJson:
                                                    _model.consentSlotsList,
                                              );

                                              if ((_model.syncConsentResp
                                                      ?.succeeded ??
                                                  true)) {
                                                context.safePop();
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'ERROR #030 - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT',
                                                      style: TextStyle(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primaryText,
                                                      ),
                                                    ),
                                                    duration: Duration(
                                                        milliseconds: 4000),
                                                    backgroundColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .secondary,
                                                  ),
                                                );
                                              }
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'ERROR #009 - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT',
                                                    style: TextStyle(
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                    ),
                                                  ),
                                                  duration: Duration(
                                                      milliseconds: 4000),
                                                  backgroundColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondary,
                                                ),
                                              );
                                            }
                                          } else {
                                            context.goNamed(
                                                LoginPageWidget.routeName);
                                          }

                                          safeSetState(() {});
                                        },
                                        text: 'Save & Exit',
                                        options: FFButtonOptions(
                                          width: 200.0,
                                          height: 56.0,
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  16.0, 0.0, 16.0, 0.0),
                                          iconPadding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 0.0, 0.0),
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          textStyle: FlutterFlowTheme.of(
                                                  context)
                                              .titleSmall
                                              .override(
                                                font: GoogleFonts.heebo(
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleSmall
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .info,
                                                fontSize: 20.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .fontStyle,
                                              ),
                                          elevation: 3.0,
                                          borderSide: BorderSide(
                                            color: Colors.transparent,
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                      ),
                                    ),
                                  ]
                                      .divide(SizedBox(height: 12.0))
                                      .addToStart(SizedBox(height: 0.0))
                                      .addToEnd(SizedBox(height: 32.0)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
