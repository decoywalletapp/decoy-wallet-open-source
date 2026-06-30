import 'dart:convert';

import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_autocomplete_options_list.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'personal_information_model.dart';
export 'personal_information_model.dart';

void _debugLog(String message) {
  if (kDebugMode) {
    debugPrint(message);
  }
}

/// Create a page that allows users to add emergency contact information,
/// which is just going to be fields to enter in the person's first and last
/// name, and then their phone number.
///
/// Put a save button at the bottom of the screen.
class PersonalInformationWidget extends StatefulWidget {
  const PersonalInformationWidget({super.key});

  static String routeName = 'PersonalInformation';
  static String routePath = '/personalInformation';

  @override
  State<PersonalInformationWidget> createState() =>
      _PersonalInformationWidgetState();
}

class _PersonalInformationWidgetState extends State<PersonalInformationWidget> {
  late PersonalInformationModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  static const _dataKeyStorage = FlutterSecureStorage();
  static const _dataKeyName = 'decoy_data_key_b64';

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
      _debugLog('[PersonalInformation] JWT lookup failed: $error');
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

  String _cleanLoadedValue(dynamic value) {
    if (value == null) return '';
    final text = value.toString().trim();
    return text.toLowerCase() == 'null' ? '' : text;
  }

  String _jsonValue(dynamic json, String path) {
    return _cleanLoadedValue(getJsonField(json, path));
  }

  String _displayPersonalPhone(String phone) {
    final cleaned = _cleanLoadedValue(phone);
    return cleaned.isEmpty ? '' : functions.displayPhoneNumber(cleaned);
  }

  Future<String?> _dataKeyForWrappedRow(
    String wrappedB64, {
    bool allowCreateFallback = true,
    bool remember = false,
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
          if (remember) {
            await _rememberDataKey(key);
          }
          return key;
        }
        _debugLog(
          '[PersonalInformation] data key unwrap failed: '
          'status=${unwrapResp.statusCode}, jwt=${jwt.isNotEmpty}, '
          'wrapped=${wrapped.isNotEmpty}, key=${key != null}',
        );
      } catch (error) {
        _debugLog('[PersonalInformation] data key unwrap threw: $error');
      }
    }

    if (allowCreateFallback) {
      return _newOrStoredDataKey();
    }
    return null;
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

  void _setPersonalFields({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
  }) {
    final displayPhone = _displayPersonalPhone(phone);
    _model.firstNameTextController?.text = _cleanLoadedValue(firstName);
    _model.lastNameTextController?.text = _cleanLoadedValue(lastName);
    _model.phoneTextController?.text = displayPhone;
    _model.phoneMask.updateMask(
      newValue: TextEditingValue(text: displayPhone),
    );
    _model.emailTextController?.text = _cleanLoadedValue(email);
  }

  Future<List<String>> _storedDataKeyCandidates({
    String? excluding,
  }) async {
    final candidates = <String>[];
    final excluded = _normalizeDataKeyB64(excluding);

    void addCandidate(String? value) {
      final normalized = _normalizeDataKeyB64(value);
      if (normalized == null || normalized == excluded) {
        return;
      }
      if (!candidates.contains(normalized)) {
        candidates.add(normalized);
      }
    }

    try {
      final userKey = _storageKeyForCurrentUser(_dataKeyName);
      if (userKey != null) {
        addCandidate(await _dataKeyStorage.read(key: userKey));
      }
      addCandidate(await _dataKeyStorage.read(key: _dataKeyName));
    } catch (_) {}

    return candidates;
  }

  Future<Map<String, dynamic>?> _decryptPersonalWithCandidateKeys(
    String? primaryKey,
  ) async {
    final candidates = <String>[];

    void addCandidate(String? value) {
      final normalized = _normalizeDataKeyB64(value);
      if (normalized == null || candidates.contains(normalized)) {
        return;
      }
      candidates.add(normalized);
    }

    addCandidate(primaryKey);
    for (final key in await _storedDataKeyCandidates(excluding: primaryKey)) {
      addCandidate(key);
    }

    dynamic lastError;
    for (final key in candidates) {
      final obj = await actions.aesGcmDecryptToMap(
        _model.rowCipherB64!,
        _model.rowNonceB64!,
        key,
      );
      if (getJsonField(obj, r'''$._ok''') == true) {
        return {
          'key': key,
          'obj': obj,
        };
      }
      lastError = getJsonField(obj, r'''$._error''');
    }

    _debugLog(
      '[PersonalInformation] personal decrypt failed for all candidate keys: '
      '$lastError',
    );
    return null;
  }

  Future<void> _repairPersonalPayloadToKey({
    required dynamic personalObj,
    required String targetKey,
  }) async {
    final normalizedKey = _normalizeDataKeyB64(targetKey);
    if (normalizedKey == null) {
      return;
    }

    try {
      final personalJson = await actions.buildPersonalJson(
        _jsonValue(personalObj, r'''$.firstName'''),
        _jsonValue(personalObj, r'''$.lastName'''),
        _jsonValue(personalObj, r'''$.phone'''),
        _jsonValue(personalObj, r'''$.email'''),
      );
      final enc = await actions.aesGcmEncryptString(
        personalJson,
        normalizedKey,
      );
      await DecoyWalletTable().update(
        data: {
          'personal_ciphertext': _jsonValue(enc, r'''$.ciphertextB64'''),
          'personal_nonce': _jsonValue(enc, r'''$.nonceB64'''),
          'personal_version': 1,
          'personal_complete':
              _jsonValue(personalObj, r'''$.firstName''').isNotEmpty &&
                  _jsonValue(personalObj, r'''$.lastName''').isNotEmpty,
          'updated_at': supaSerialize<DateTime>(getCurrentTimestamp),
        },
        matchingRows: (rows) => rows.eqOrNull(
          'user_id',
          currentUserUid,
        ),
      );
      await _rememberDataKey(normalizedKey);
      _debugLog('[PersonalInformation] repaired personal payload row key');
    } catch (error) {
      _debugLog('[PersonalInformation] personal repair failed: $error');
    }
  }

  Future<String?> _currentRowDataKeyForSave() async {
    var wrapped = (_model.wrappedB64 ?? '').trim();
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
        _debugLog('[PersonalInformation] save key row lookup failed: $error');
      }
    }

    if (wrapped.isNotEmpty) {
      return _dataKeyForWrappedRow(
        wrapped,
        allowCreateFallback: false,
        remember: false,
      );
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PersonalInformationModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.personalSaved = 0;
      safeSetState(() {});
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
              (row.personalCiphertext ?? '').trim().isNotEmpty &&
              (row.personalNonce ?? '').trim().isNotEmpty,
          orElse: () => _model.rows!.first,
        );
        _model.rowCipherB64 = selectedRow.personalCiphertext;
        _model.rowNonceB64 = selectedRow.personalNonce;
        _model.wrappedB64 = selectedRow.wrappedDatakey ?? '';
        _model.origEmail = currentUserEmail;
        safeSetState(() {});

        final hasSavedPersonalPayload =
            (_model.rowCipherB64 ?? '').trim().isNotEmpty &&
                (_model.rowNonceB64 ?? '').trim().isNotEmpty;
        if (hasSavedPersonalPayload) {
          final canonicalKey = (_model.wrappedB64 ?? '').trim().isNotEmpty
              ? await _dataKeyForWrappedRow(
                  _model.wrappedB64!,
                  allowCreateFallback: false,
                  remember: false,
                )
              : null;
          final decryptResult =
              await _decryptPersonalWithCandidateKeys(canonicalKey);

          if (decryptResult == null) {
            _model.personalObj = {
              '_ok': false,
              '_error': 'unrecoverable local data key mismatch',
            };
            _model.dataKeyB64 = canonicalKey ?? await _newOrStoredDataKey();
            _model.origPhone = '';
            _setPersonalFields(
              firstName: '',
              lastName: '',
              phone: '',
              email: currentUserEmail,
            );
          } else {
            _model.dataKeyB64 = decryptResult['key'] as String?;
            _model.personalObj = decryptResult['obj'];
            final loadedPhone = _jsonValue(_model.personalObj, r'''$.phone''');
            final loadedEmail = _jsonValue(_model.personalObj, r'''$.email''');
            _model.origPhone = functions.sanitizePhoneNumber(loadedPhone);
            _setPersonalFields(
              firstName: _jsonValue(_model.personalObj, r'''$.firstName'''),
              lastName: _jsonValue(_model.personalObj, r'''$.lastName'''),
              phone: loadedPhone,
              email: currentUserEmail != '' ? currentUserEmail : loadedEmail,
            );
            final loadedKey = _normalizeDataKeyB64(_model.dataKeyB64);
            final normalizedCanonical = _normalizeDataKeyB64(canonicalKey);
            if (normalizedCanonical != null) {
              if (loadedKey != normalizedCanonical) {
                await _repairPersonalPayloadToKey(
                  personalObj: _model.personalObj,
                  targetKey: normalizedCanonical,
                );
                _model.dataKeyB64 = normalizedCanonical;
              } else {
                await _rememberDataKey(normalizedCanonical);
              }
            } else if (loadedKey != null) {
              await _rememberDataKey(loadedKey);
            }
          }
        } else {
          _model.dataKeyOut2 = (_model.wrappedB64 ?? '').trim().isNotEmpty
              ? await _dataKeyForWrappedRow(
                  _model.wrappedB64!,
                  allowCreateFallback: false,
                  remember: false,
                )
              : await _newOrStoredDataKey();
          _model.dataKeyB64 = _model.dataKeyOut2;
          _setPersonalFields(
            firstName: '',
            lastName: '',
            phone: '',
            email: currentUserEmail,
          );
        }
      } else {
        _model.dataKeyOut2 = await _newOrStoredDataKey();
        _model.dataKeyB64 = _model.dataKeyOut2;
        _setPersonalFields(
          firstName: '',
          lastName: '',
          phone: '',
          email: currentUserEmail,
        );
      }
      safeSetState(() {});
    });

    _model.firstNameTextController ??= TextEditingController();
    _model.firstNameFocusNode ??= FocusNode();

    _model.lastNameTextController ??= TextEditingController();

    _model.phoneTextController ??= TextEditingController();
    _model.phoneFocusNode ??= FocusNode();

    _model.phoneMask = MaskTextInputFormatter(mask: '(###) ###-####');
    _model.emailTextController ??= TextEditingController();
    _model.emailFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
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
            child: Align(
              alignment: AlignmentDirectional(0.0, 0.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: AlignmentDirectional(-1.0, 0.0),
                      child: Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 0.0, 0.0),
                        child: FlutterFlowIconButton(
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
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              Material(
                                color: Colors.transparent,
                                elevation: 3.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Container(
                                  width: 100.0,
                                  height: 100.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).primary,
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.person,
                                color: FlutterFlowTheme.of(context).info,
                                size: 100.0,
                              ),
                            ],
                          ),
                          Container(
                            width: 400.0,
                            child: Form(
                              key: _model.formKey,
                              autovalidateMode: AutovalidateMode.disabled,
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'First Name',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMediumFamily,
                                              letterSpacing: 0.25,
                                              fontWeight: FontWeight.w500,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .bodyMediumIsCustom,
                                            ),
                                      ),
                                      TextFormField(
                                        controller:
                                            _model.firstNameTextController,
                                        focusNode: _model.firstNameFocusNode,
                                        autofocus: false,
                                        enabled: true,
                                        autofillHints: [
                                          AutofillHints.givenName
                                        ],
                                        textCapitalization:
                                            TextCapitalization.words,
                                        textInputAction: TextInputAction.next,
                                        obscureText: false,
                                        decoration: InputDecoration(
                                          hintText: 'Enter first name',
                                          hintStyle: FlutterFlowTheme.of(
                                                  context)
                                              .bodyMedium
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMediumFamily,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                letterSpacing: 0.25,
                                                useGoogleFonts:
                                                    !FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMediumIsCustom,
                                              ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              width: 1.5,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              width: 1.5,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .error,
                                              width: 1.5,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .error,
                                              width: 1.5,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          filled: true,
                                          fillColor:
                                              FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          contentPadding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  16.0, 16.0, 16.0, 16.0),
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMediumFamily,
                                              fontSize: 16.0,
                                              letterSpacing: 0.25,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .bodyMediumIsCustom,
                                            ),
                                        keyboardType: TextInputType.name,
                                        cursorColor:
                                            FlutterFlowTheme.of(context)
                                                .primary,
                                        validator: _model
                                            .firstNameTextControllerValidator
                                            .asValidator(context),
                                        inputFormatters: [
                                          if (!isAndroid && !isiOS)
                                            TextInputFormatter.withFunction(
                                                (oldValue, newValue) {
                                              return TextEditingValue(
                                                selection: newValue.selection,
                                                text: newValue.text
                                                    .toCapitalization(
                                                        TextCapitalization
                                                            .words),
                                              );
                                            }),
                                        ],
                                      ),
                                    ].divide(SizedBox(height: 8.0)),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Last Name',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMediumFamily,
                                              letterSpacing: 0.25,
                                              fontWeight: FontWeight.w500,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .bodyMediumIsCustom,
                                            ),
                                      ),
                                      Autocomplete<String>(
                                        initialValue: TextEditingValue(),
                                        optionsBuilder: (textEditingValue) {
                                          if (textEditingValue.text == '') {
                                            return const Iterable<
                                                String>.empty();
                                          }
                                          return <String>[].where((option) {
                                            final lowercaseOption =
                                                option.toLowerCase();
                                            return lowercaseOption.contains(
                                                textEditingValue.text
                                                    .toLowerCase());
                                          });
                                        },
                                        optionsViewBuilder:
                                            (context, onSelected, options) {
                                          return AutocompleteOptionsList(
                                            textFieldKey: _model.lastNameKey,
                                            textController:
                                                _model.lastNameTextController!,
                                            options: options.toList(),
                                            onSelected: onSelected,
                                            textStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .override(
                                                      fontFamily:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMediumFamily,
                                                      letterSpacing: 0.0,
                                                      useGoogleFonts:
                                                          !FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMediumIsCustom,
                                                    ),
                                            textHighlightStyle: TextStyle(),
                                            elevation: 4.0,
                                            optionBackgroundColor:
                                                FlutterFlowTheme.of(context)
                                                    .primaryBackground,
                                            optionHighlightColor:
                                                FlutterFlowTheme.of(context)
                                                    .secondaryBackground,
                                            maxHeight: 200.0,
                                          );
                                        },
                                        onSelected: (String selection) {
                                          safeSetState(() =>
                                              _model.lastNameSelectedOption =
                                                  selection);
                                          FocusScope.of(context).unfocus();
                                        },
                                        fieldViewBuilder: (
                                          context,
                                          textEditingController,
                                          focusNode,
                                          onEditingComplete,
                                        ) {
                                          _model.lastNameFocusNode = focusNode;

                                          _model.lastNameTextController =
                                              textEditingController;
                                          return TextFormField(
                                            key: _model.lastNameKey,
                                            controller: textEditingController,
                                            focusNode: focusNode,
                                            onEditingComplete:
                                                onEditingComplete,
                                            autofocus: false,
                                            enabled: true,
                                            autofillHints: [
                                              AutofillHints.familyName
                                            ],
                                            textCapitalization:
                                                TextCapitalization.words,
                                            textInputAction:
                                                TextInputAction.next,
                                            obscureText: false,
                                            decoration: InputDecoration(
                                              hintText: 'Enter last name',
                                              hintStyle: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMediumFamily,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryText,
                                                    letterSpacing: 0.25,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMediumIsCustom,
                                                  ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  width: 1.5,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  width: 1.5,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .error,
                                                  width: 1.5,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                              focusedErrorBorder:
                                                  OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .error,
                                                  width: 1.5,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                              filled: true,
                                              fillColor:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              contentPadding:
                                                  EdgeInsetsDirectional
                                                      .fromSTEB(16.0, 16.0,
                                                          16.0, 16.0),
                                            ),
                                            style: FlutterFlowTheme.of(context)
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
                                            keyboardType: TextInputType.name,
                                            cursorColor:
                                                FlutterFlowTheme.of(context)
                                                    .primary,
                                            validator: _model
                                                .lastNameTextControllerValidator
                                                .asValidator(context),
                                            inputFormatters: [
                                              if (!isAndroid && !isiOS)
                                                TextInputFormatter.withFunction(
                                                    (oldValue, newValue) {
                                                  return TextEditingValue(
                                                    selection:
                                                        newValue.selection,
                                                    text: newValue.text
                                                        .toCapitalization(
                                                            TextCapitalization
                                                                .words),
                                                  );
                                                }),
                                            ],
                                          );
                                        },
                                      ),
                                    ].divide(SizedBox(height: 8.0)),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Phone Number',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMediumFamily,
                                              letterSpacing: 0.25,
                                              fontWeight: FontWeight.w500,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .bodyMediumIsCustom,
                                            ),
                                      ),
                                      TextFormField(
                                        controller: _model.phoneTextController,
                                        focusNode: _model.phoneFocusNode,
                                        autofocus: false,
                                        textInputAction: TextInputAction.next,
                                        obscureText: false,
                                        decoration: InputDecoration(
                                          hintText: 'Enter phone number',
                                          hintStyle: FlutterFlowTheme.of(
                                                  context)
                                              .bodyMedium
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMediumFamily,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                letterSpacing: 0.25,
                                                useGoogleFonts:
                                                    !FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMediumIsCustom,
                                              ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              width: 1.5,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              width: 1.5,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .error,
                                              width: 1.5,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .error,
                                              width: 1.5,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          filled: true,
                                          fillColor:
                                              FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          contentPadding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  16.0, 16.0, 16.0, 16.0),
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMediumFamily,
                                              fontSize: 16.0,
                                              letterSpacing: 0.25,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .bodyMediumIsCustom,
                                            ),
                                        keyboardType: TextInputType.phone,
                                        cursorColor:
                                            FlutterFlowTheme.of(context)
                                                .primary,
                                        validator: _model
                                            .phoneTextControllerValidator
                                            .asValidator(context),
                                      ),
                                    ].divide(SizedBox(height: 8.0)),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Email',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMediumFamily,
                                              letterSpacing: 0.25,
                                              fontWeight: FontWeight.w500,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .bodyMediumIsCustom,
                                            ),
                                      ),
                                      TextFormField(
                                        controller: _model.emailTextController,
                                        focusNode: _model.emailFocusNode,
                                        autofocus: false,
                                        obscureText: false,
                                        decoration: InputDecoration(
                                          hintText: 'Enter email',
                                          hintStyle: FlutterFlowTheme.of(
                                                  context)
                                              .bodyMedium
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMediumFamily,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                letterSpacing: 0.25,
                                                useGoogleFonts:
                                                    !FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMediumIsCustom,
                                              ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              width: 1.5,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              width: 1.5,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .error,
                                              width: 1.5,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .error,
                                              width: 1.5,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          filled: true,
                                          fillColor:
                                              FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          contentPadding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  16.0, 16.0, 16.0, 16.0),
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMediumFamily,
                                              fontSize: 16.0,
                                              letterSpacing: 0.25,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .bodyMediumIsCustom,
                                            ),
                                        cursorColor:
                                            FlutterFlowTheme.of(context)
                                                .primary,
                                        validator: _model
                                            .emailTextControllerValidator
                                            .asValidator(context),
                                      ),
                                    ].divide(SizedBox(height: 8.0)),
                                  ),
                                ].divide(SizedBox(height: 20.0)),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 12.0, 0.0, 0.0),
                            child: FFButtonWidget(
                              onPressed: () async {
                                await actions.dismissKeyboard(
                                  context,
                                );
                                _model.changedPhone =
                                    functions.sanitizePhoneNumber(
                                        _model.phoneTextController.text);
                                _model.changedEmail = functions.normalizeEmail(
                                    _model.emailTextController.text);
                                _model.personalJsonOut =
                                    await actions.buildPersonalJson(
                                  _model.firstNameTextController.text,
                                  _model.lastNameTextController.text,
                                  (_model.changedPhone != null &&
                                          _model.changedPhone != '')
                                      ? _model.phoneTextController.text
                                      : (_model.origPhone ?? ''),
                                  (currentUserEmail != '') &&
                                          (functions.normalizeEmail(
                                                  currentUserEmail) !=
                                              functions.normalizeEmail(
                                                  _model.changedEmail))
                                      ? currentUserEmail
                                      : _model.emailTextController.text,
                                );
                                _model.personalJson = _model.personalJsonOut;
                                safeSetState(() {});
                                if (loggedIn == true) {
                                  _model.keyOut =
                                      await _currentRowDataKeyForSave();
                                  _model.keyOut ??=
                                      await actions.generateDataKeyIfMissing();
                                  _model.dataKeyB64 =
                                      _normalizeDataKeyB64(_model.keyOut) ??
                                          _model.keyOut;
                                  safeSetState(() {});
                                  _model.enc =
                                      await actions.aesGcmEncryptString(
                                    _model.personalJson!,
                                    _model.dataKeyB64!,
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
                                  _model.wrap = await WrapDataKeyCall.call(
                                    dataKeyB64: _model.dataKeyB64,
                                    jwt: await _jwtForApi(),
                                  );

                                  if ((_model.wrap?.succeeded ?? false)) {
                                    _model.wrappedB64 = _jsonValue(
                                      (_model.wrap?.jsonBody ?? ''),
                                      r'''$.wrappedB64''',
                                    );
                                    await _rememberDataKey(_model.dataKeyB64!);
                                    safeSetState(() {});
                                    _model.supaRows =
                                        await DecoyWalletTable().queryRows(
                                      queryFn: (q) => q
                                          .eqOrNull(
                                            'user_id',
                                            currentUserUid,
                                          )
                                          .order('updated_at'),
                                    );
                                    if (_model.supaRows != null &&
                                        (_model.supaRows)!.isNotEmpty) {
                                      await DecoyWalletTable().update(
                                        data: {
                                          'personal_ciphertext': _model.ctB64,
                                          'personal_nonce': _model.nonceB64,
                                          'personal_version': 1,
                                          'wrapped_datakey': _model.wrappedB64,
                                          'updated_at': supaSerialize<DateTime>(
                                              getCurrentTimestamp),
                                          'personal_complete': (_model
                                                          .firstNameTextController
                                                          .text !=
                                                      '') &&
                                                  (_model.lastNameTextController
                                                          .text !=
                                                      '')
                                              ? true
                                              : false,
                                        },
                                        matchingRows: (rows) => rows.eqOrNull(
                                          'user_id',
                                          currentUserUid,
                                        ),
                                      );
                                      _model.refreshedDecoyWallet1 =
                                          await DecoyWalletTable().queryRows(
                                        queryFn: (q) => q.eqOrNull(
                                          'user_id',
                                          currentUserUid,
                                        ),
                                      );
                                      _model.personalSaved =
                                          _model.personalSaved + 1;
                                      safeSetState(() {});
                                      _model.changedEmail =
                                          functions.normalizeEmail(
                                              _model.emailTextController.text);
                                      _model.changedPhone =
                                          functions.sanitizePhoneNumber(
                                              _model.phoneTextController.text);
                                      safeSetState(() {});
                                      if ((functions.normalizeEmail(
                                                  currentUserEmail) !=
                                              functions.normalizeEmail(
                                                  _model.changedEmail)) &&
                                          (_model.changedEmail != null &&
                                              _model.changedEmail != '')) {
                                        _model.changedEmailHash =
                                            await GetEmailHashCall.call(
                                          jwt: await _jwtForApi(),
                                          email: functions.normalizeEmail(
                                              _model.changedEmail),
                                        );

                                        await DecoyWalletTable().update(
                                          data: {
                                            'pending_email':
                                                functions.normalizeEmail(
                                                    _model.changedEmail),
                                            'email_verified': false,
                                            'email_verified_at':
                                                supaSerialize<DateTime>(
                                                    getCurrentTimestamp),
                                            'pending_email_hash':
                                                GetEmailHashCall.emailHash(
                                              (_model.changedEmailHash
                                                      ?.jsonBody ??
                                                  ''),
                                            ).toString(),
                                          },
                                          matchingRows: (rows) => rows.eqOrNull(
                                            'user_id',
                                            currentUserUid,
                                          ),
                                        );
                                        FFAppState().userEmail =
                                            functions.normalizeEmail(
                                                _model.changedEmail);
                                        safeSetState(() {});
                                        if (_model.changedEmail!.isEmpty) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Email required!',
                                              ),
                                            ),
                                          );
                                          return;
                                        }

                                        AppStateNotifier.instance
                                            .updateNotifyOnAuthChange(false);
                                        await authManager.updateEmail(
                                          email: _model.changedEmail!,
                                          context: context,
                                        );
                                        safeSetState(() {});

                                        context.pushNamed(
                                          ConfirmEmailPageWidget.routeName,
                                          queryParameters: {
                                            'emailEntry': serializeParam(
                                              _model.emailTextController.text,
                                              ParamType.String,
                                            ),
                                          }.withoutNulls,
                                        );
                                      } else {
                                        if (_model.origPhone !=
                                            _model.changedPhone) {
                                          context.pushNamed(
                                              PhoneNumberInputWidget.routeName);
                                        } else {
                                          await Future.delayed(
                                            Duration(
                                              milliseconds: 250,
                                            ),
                                          );
                                          _model.personalSaved =
                                              _model.personalSaved + -1;
                                          safeSetState(() {});
                                          context.safePop();
                                        }
                                      }
                                    } else {
                                      _model.supaNameInserts =
                                          await DecoyWalletTable().insert({
                                        'personal_ciphertext': _model.ctB64,
                                        'personal_nonce': _model.nonceB64,
                                        'personal_version': 1,
                                        'wrapped_datakey': _model.wrappedB64,
                                        'updated_at': supaSerialize<DateTime>(
                                            getCurrentTimestamp),
                                        'user_id': currentUserUid,
                                        'personal_complete': (_model
                                                        .firstNameTextController
                                                        .text !=
                                                    '') &&
                                                (_model.lastNameTextController
                                                        .text !=
                                                    '')
                                            ? true
                                            : false,
                                      });
                                      _model.refreshedDecoyWallet2 =
                                          await DecoyWalletTable().queryRows(
                                        queryFn: (q) => q.eqOrNull(
                                          'user_id',
                                          currentUserUid,
                                        ),
                                      );
                                      _model.personalSaved =
                                          _model.personalSaved + 1;
                                      safeSetState(() {});
                                      await Future.delayed(
                                        Duration(
                                          milliseconds: 250,
                                        ),
                                      );
                                      _model.personalSaved =
                                          _model.personalSaved + -1;
                                      safeSetState(() {});
                                      context.safePop();
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'ERROR #011 - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT',
                                          style: TextStyle(
                                            color: FlutterFlowTheme.of(context)
                                                .primaryText,
                                          ),
                                        ),
                                        duration: Duration(milliseconds: 4000),
                                        backgroundColor:
                                            FlutterFlowTheme.of(context)
                                                .secondary,
                                      ),
                                    );
                                  }
                                } else {
                                  context.goNamed(LoginPageWidget.routeName);
                                }

                                safeSetState(() {});
                              },
                              text: 'Save & Exit',
                              options: FFButtonOptions(
                                width: 250.0,
                                height: 56.0,
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    16.0, 0.0, 16.0, 0.0),
                                iconPadding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
                                color: FlutterFlowTheme.of(context).primary,
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .titleSmallFamily,
                                      color: Colors.white,
                                      fontSize: 18.0,
                                      letterSpacing: 0.0,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .titleSmallIsCustom,
                                    ),
                                elevation: 3.0,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ),
                        ]
                            .divide(SizedBox(height: 24.0))
                            .addToStart(SizedBox(height: 24.0)),
                      ),
                    ),
                  ].addToEnd(SizedBox(height: 100.0)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
