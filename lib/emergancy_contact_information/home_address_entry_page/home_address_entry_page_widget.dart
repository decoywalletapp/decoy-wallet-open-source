import 'dart:convert';

import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_autocomplete_options_list.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_address_entry_page_model.dart';
export 'home_address_entry_page_model.dart';

void _debugLog(String message) {
  if (kDebugMode) {
    debugPrint(message);
  }
}

/// create a page where the user enters their home address and then save
/// button at bottom
///
class HomeAddressEntryPageWidget extends StatefulWidget {
  const HomeAddressEntryPageWidget({super.key});

  static String routeName = 'HomeAddressEntryPage';
  static String routePath = '/homeAddressEntryPage';

  @override
  State<HomeAddressEntryPageWidget> createState() =>
      _HomeAddressEntryPageWidgetState();
}

class _HomeAddressEntryPageWidgetState
    extends State<HomeAddressEntryPageWidget> {
  late HomeAddressEntryPageModel _model;

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

  String _cleanLoadedValue(dynamic value) {
    if (value == null) return '';
    final text = value.toString().trim();
    return text.toLowerCase() == 'null' ? '' : text;
  }

  String _jsonValue(dynamic json, String path) {
    return _cleanLoadedValue(getJsonField(json, path));
  }

  String? _storageKeyForCurrentUser(String name) {
    final userId = currentUserUid.trim();
    if (userId.isEmpty) {
      return null;
    }
    return '$name.$userId';
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
    } catch (_) {}
  }

  Future<String> _newOrStoredDataKey() async {
    final key = await actions.generateDataKeyIfMissing();
    return _normalizeDataKeyB64(key) ?? key;
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
      _debugLog('[HomeAddress] JWT lookup failed: $error');
      return '';
    }
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

  Future<String?> _dataKeyForWrappedRow(String? wrappedB64) async {
    final wrapped = wrappedB64?.trim() ?? '';
    if (wrapped.isEmpty) {
      return null;
    }

    try {
      final jwt = await _jwtForApi();
      final unwrapResp = await WrapDataKeyUnwrapCall.call(
        wrappedB64: wrapped,
        jwt: jwt,
      );
      final key = _normalizeDataKeyB64(
        _extractUnwrappedDataKey(unwrapResp.jsonBody),
      );
      if (unwrapResp.succeeded && key != null) {
        return key;
      }
      _debugLog(
        '[HomeAddress] data key unwrap failed: '
        'status=${unwrapResp.statusCode}, jwt=${jwt.isNotEmpty}, '
        'key=${key != null}',
      );
    } catch (error) {
      _debugLog('[HomeAddress] data key unwrap threw: $error');
    }
    return null;
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
        _debugLog('[HomeAddress] save key row lookup failed: $error');
      }
    }

    return _dataKeyForWrappedRow(wrapped);
  }

  void _setAddressFields(dynamic addrObj) {
    _model.streetAddressTextController?.text =
        _jsonValue(addrObj, r'''$.street''');
    _model.cityTextController?.text = _jsonValue(addrObj, r'''$.city''');
    _model.stateTextController?.text = _jsonValue(addrObj, r'''$.state''');
    _model.zipTextController?.text = _jsonValue(addrObj, r'''$.zip''');
    final country = _jsonValue(addrObj, r'''$.country''');
    _model.countryTextController?.text = country.isNotEmpty ? country : 'USA';
    _model.apartmentTextController?.text = _jsonValue(addrObj, r'''$.apt''');
  }

  void _clearAddressFields() {
    _model.streetAddressTextController?.clear();
    _model.cityTextController?.clear();
    _model.stateTextController?.clear();
    _model.zipTextController?.clear();
    _model.countryTextController?.text = 'USA';
    _model.apartmentTextController?.clear();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeAddressEntryPageModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.addressSaved = 0;
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
              (row.addressCiphertext ?? '').trim().isNotEmpty &&
              (row.addressNonce ?? '').trim().isNotEmpty,
          orElse: () => _model.rows!.first,
        );
        _model.rowCipherB64 = selectedRow.addressCiphertext;
        _model.rowNonceB64 = selectedRow.addressNonce;
        _model.wrappedB64 = selectedRow.wrappedDatakey;
        safeSetState(() {});
        final hasSavedAddressPayload =
            (_model.rowCipherB64 ?? '').trim().isNotEmpty &&
                (_model.rowNonceB64 ?? '').trim().isNotEmpty;
        if (hasSavedAddressPayload) {
          _model.dataKeyOut = await _dataKeyForWrappedRow(_model.wrappedB64);
          if ((_model.dataKeyOut ?? '').trim().isNotEmpty) {
            _model.dataKeyB64 = _model.dataKeyOut;
            _model.addrObj = await actions.aesGcmDecryptToMap(
              _model.rowCipherB64!,
              _model.rowNonceB64!,
              _model.dataKeyB64!,
            );
            _model.debugJSON = _model.addrObj?.toString();
            if (getJsonField(_model.addrObj, r'''$._ok''') == false) {
              _debugLog(
                '[HomeAddress] address decrypt failed: '
                '${getJsonField(_model.addrObj, r'''$._error''')}',
              );
              _clearAddressFields();
            } else {
              _setAddressFields(_model.addrObj);
              await _rememberDataKey(_model.dataKeyB64!);
            }
          } else {
            _clearAddressFields();
          }
        } else {
          _model.dataKeyOut2 = await _dataKeyForWrappedRow(_model.wrappedB64) ??
              await _newOrStoredDataKey();
          _model.dataKeyB64 = _model.dataKeyOut2;
          _clearAddressFields();
        }
      } else {
        _model.dataKeyOut2 = await _newOrStoredDataKey();
        _model.dataKeyB64 = _model.dataKeyOut2;
        _model.rowCipherB64 = '';
        _model.rowNonceB64 = '';
        _model.wrappedB64 = '';
        _clearAddressFields();
      }
      safeSetState(() {});
    });

    _model.streetAddressTextController ??= TextEditingController();

    _model.cityTextController ??= TextEditingController();
    _model.cityFocusNode ??= FocusNode();

    _model.stateTextController ??= TextEditingController();
    _model.stateFocusNode ??= FocusNode();

    _model.zipTextController ??= TextEditingController();
    _model.zipFocusNode ??= FocusNode();

    _model.countryTextController ??= TextEditingController(text: 'USA');
    _model.countryFocusNode ??= FocusNode();

    _model.apartmentTextController ??= TextEditingController();
    _model.apartmentFocusNode ??= FocusNode();

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
          backgroundColor: FlutterFlowTheme.of(context).info,
          body: SafeArea(
            top: true,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
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
                  Container(
                    width: 400.0,
                    child: Form(
                      key: _model.formKey,
                      autovalidateMode: AutovalidateMode.disabled,
                      child: Align(
                        alignment: AlignmentDirectional(0.0, 0.0),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              24.0, 0.0, 24.0, 0.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Stack(
                                  children: [
                                    Align(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: Material(
                                        color: Colors.transparent,
                                        elevation: 3.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        child: Container(
                                          width: 100.0,
                                          height: 100.0,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: Icon(
                                        Icons.home_rounded,
                                        color:
                                            FlutterFlowTheme.of(context).info,
                                        size: 100.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Container(
                                      width: 400.0,
                                      child: Autocomplete<String>(
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
                                            textFieldKey:
                                                _model.streetAddressKey,
                                            textController: _model
                                                .streetAddressTextController!,
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
                                          safeSetState(() => _model
                                                  .streetAddressSelectedOption =
                                              selection);
                                          FocusScope.of(context).unfocus();
                                        },
                                        fieldViewBuilder: (
                                          context,
                                          textEditingController,
                                          focusNode,
                                          onEditingComplete,
                                        ) {
                                          _model.streetAddressFocusNode =
                                              focusNode;

                                          _model.streetAddressTextController =
                                              textEditingController;
                                          return TextFormField(
                                            key: _model.streetAddressKey,
                                            controller: textEditingController,
                                            focusNode: focusNode,
                                            onEditingComplete:
                                                onEditingComplete,
                                            autofocus: false,
                                            enabled: true,
                                            autofillHints: [
                                              AutofillHints.fullStreetAddress
                                            ],
                                            textInputAction:
                                                TextInputAction.next,
                                            obscureText: false,
                                            decoration: InputDecoration(
                                              labelText: 'Street Address',
                                              labelStyle: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMediumFamily,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                    letterSpacing: 0.25,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMediumIsCustom,
                                                  ),
                                              hintText: '123 Ocean Dr.',
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
                                                    letterSpacing: 0.0,
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
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                  fontSize: 16.0,
                                                  letterSpacing: 0.25,
                                                  useGoogleFonts:
                                                      !FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMediumIsCustom,
                                                ),
                                            keyboardType:
                                                TextInputType.streetAddress,
                                            cursorColor:
                                                FlutterFlowTheme.of(context)
                                                    .primaryText,
                                            validator: _model
                                                .streetAddressTextControllerValidator
                                                .asValidator(context),
                                          );
                                        },
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            width: 200.0,
                                            child: TextFormField(
                                              controller:
                                                  _model.cityTextController,
                                              focusNode: _model.cityFocusNode,
                                              autofocus: false,
                                              autofillHints: [
                                                AutofillHints.addressCity
                                              ],
                                              textInputAction:
                                                  TextInputAction.next,
                                              obscureText: false,
                                              decoration: InputDecoration(
                                                labelText: 'City',
                                                labelStyle: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      fontFamily:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMediumFamily,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                      letterSpacing: 0.25,
                                                      useGoogleFonts:
                                                          !FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMediumIsCustom,
                                                    ),
                                                hintText: 'Miami Beach',
                                                hintStyle: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      fontFamily:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMediumFamily,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .secondaryText,
                                                      letterSpacing: 0.0,
                                                      useGoogleFonts:
                                                          !FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMediumIsCustom,
                                                    ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    width: 1.5,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    width: 1.5,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .error,
                                                    width: 1.5,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
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
                                                      BorderRadius.circular(
                                                          12.0),
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
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMediumFamily,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                    fontSize: 16.0,
                                                    letterSpacing: 0.25,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMediumIsCustom,
                                                  ),
                                              cursorColor:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              validator: _model
                                                  .cityTextControllerValidator
                                                  .asValidator(context),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            width: 200.0,
                                            child: TextFormField(
                                              controller:
                                                  _model.stateTextController,
                                              focusNode: _model.stateFocusNode,
                                              autofocus: false,
                                              autofillHints: [
                                                AutofillHints.addressState
                                              ],
                                              textCapitalization:
                                                  TextCapitalization.characters,
                                              textInputAction:
                                                  TextInputAction.next,
                                              obscureText: false,
                                              decoration: InputDecoration(
                                                labelText: 'State',
                                                labelStyle: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      fontFamily:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMediumFamily,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                      letterSpacing: 0.25,
                                                      useGoogleFonts:
                                                          !FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMediumIsCustom,
                                                    ),
                                                hintText: 'FL',
                                                hintStyle: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      fontFamily:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMediumFamily,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .secondaryText,
                                                      letterSpacing: 0.0,
                                                      useGoogleFonts:
                                                          !FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMediumIsCustom,
                                                    ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    width: 1.5,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    width: 1.5,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .error,
                                                    width: 1.5,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
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
                                                      BorderRadius.circular(
                                                          12.0),
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
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMediumFamily,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                    fontSize: 16.0,
                                                    letterSpacing: 0.25,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMediumIsCustom,
                                                  ),
                                              maxLength: 2,
                                              maxLengthEnforcement:
                                                  MaxLengthEnforcement.enforced,
                                              buildCounter: (context,
                                                      {required currentLength,
                                                      required isFocused,
                                                      maxLength}) =>
                                                  null,
                                              cursorColor:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              validator: _model
                                                  .stateTextControllerValidator
                                                  .asValidator(context),
                                              inputFormatters: [
                                                if (!isAndroid && !isiOS)
                                                  TextInputFormatter
                                                      .withFunction(
                                                          (oldValue, newValue) {
                                                    return TextEditingValue(
                                                      selection:
                                                          newValue.selection,
                                                      text: newValue.text
                                                          .toCapitalization(
                                                              TextCapitalization
                                                                  .characters),
                                                    );
                                                  }),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ].divide(SizedBox(width: 12.0)),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            width: 200.0,
                                            child: TextFormField(
                                              controller:
                                                  _model.zipTextController,
                                              focusNode: _model.zipFocusNode,
                                              autofocus: false,
                                              autofillHints: [
                                                AutofillHints.email
                                              ],
                                              textInputAction:
                                                  TextInputAction.next,
                                              obscureText: false,
                                              decoration: InputDecoration(
                                                labelText: 'ZIP Code',
                                                labelStyle: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      fontFamily:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMediumFamily,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                      letterSpacing: 0.25,
                                                      useGoogleFonts:
                                                          !FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMediumIsCustom,
                                                    ),
                                                hintText: '33139',
                                                hintStyle: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      fontFamily:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMediumFamily,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .secondaryText,
                                                      letterSpacing: 0.0,
                                                      useGoogleFonts:
                                                          !FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMediumIsCustom,
                                                    ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    width: 1.5,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    width: 1.5,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .error,
                                                    width: 1.5,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
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
                                                      BorderRadius.circular(
                                                          12.0),
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
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMediumFamily,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                    fontSize: 16.0,
                                                    letterSpacing: 0.25,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMediumIsCustom,
                                                  ),
                                              keyboardType:
                                                  TextInputType.number,
                                              cursorColor:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              validator: _model
                                                  .zipTextControllerValidator
                                                  .asValidator(context),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            width: 200.0,
                                            child: TextFormField(
                                              controller:
                                                  _model.countryTextController,
                                              focusNode:
                                                  _model.countryFocusNode,
                                              autofocus: false,
                                              textInputAction:
                                                  TextInputAction.next,
                                              readOnly: true,
                                              obscureText: false,
                                              decoration: InputDecoration(
                                                labelText: 'Country',
                                                labelStyle: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      fontFamily:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMediumFamily,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                      letterSpacing: 0.25,
                                                      useGoogleFonts:
                                                          !FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMediumIsCustom,
                                                    ),
                                                hintText: '33139',
                                                hintStyle: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      fontFamily:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMediumFamily,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .secondaryText,
                                                      letterSpacing: 0.0,
                                                      useGoogleFonts:
                                                          !FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMediumIsCustom,
                                                    ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    width: 1.5,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    width: 1.5,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .error,
                                                    width: 1.5,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
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
                                                      BorderRadius.circular(
                                                          12.0),
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
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMediumFamily,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                    fontSize: 16.0,
                                                    letterSpacing: 0.25,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMediumIsCustom,
                                                  ),
                                              keyboardType:
                                                  TextInputType.number,
                                              cursorColor:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              validator: _model
                                                  .countryTextControllerValidator
                                                  .asValidator(context),
                                            ),
                                          ),
                                        ),
                                      ].divide(SizedBox(width: 12.0)),
                                    ),
                                    Container(
                                      width: 400.0,
                                      child: TextFormField(
                                        controller:
                                            _model.apartmentTextController,
                                        focusNode: _model.apartmentFocusNode,
                                        autofocus: false,
                                        textInputAction: TextInputAction.done,
                                        obscureText: false,
                                        decoration: InputDecoration(
                                          labelText:
                                              'Apartment/Unit (Optional)',
                                          labelStyle: FlutterFlowTheme.of(
                                                  context)
                                              .bodyMedium
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMediumFamily,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                letterSpacing: 0.25,
                                                useGoogleFonts:
                                                    !FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMediumIsCustom,
                                              ),
                                          hintText: 'Apt 4B',
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
                                                letterSpacing: 0.0,
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
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              fontSize: 16.0,
                                              letterSpacing: 0.25,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .bodyMediumIsCustom,
                                            ),
                                        cursorColor:
                                            FlutterFlowTheme.of(context)
                                                .primaryText,
                                        validator: _model
                                            .apartmentTextControllerValidator
                                            .asValidator(context),
                                      ),
                                    ),
                                  ].divide(SizedBox(height: 16.0)),
                                ),
                              ),
                              Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: FFButtonWidget(
                                  onPressed: () async {
                                    await actions.dismissKeyboard(
                                      context,
                                    );
                                    _model.playload =
                                        await actions.buildAddressPayloadV1(
                                      _model.streetAddressTextController.text,
                                      _model.cityTextController.text,
                                      _model.stateTextController.text,
                                      _model.zipTextController.text,
                                      _model.apartmentTextController.text,
                                      _model.countryTextController.text,
                                    );
                                    _model.addressJson = _model.playload;
                                    safeSetState(() {});
                                    if (loggedIn == true) {
                                      _model.keyOut =
                                          await _currentRowDataKeyForSave();
                                      _model.keyOut ??=
                                          await _newOrStoredDataKey();
                                      _model.dataKeyB64 = _model.keyOut;
                                      safeSetState(() {});
                                      _model.enc =
                                          await actions.aesGcmEncryptString(
                                        _model.addressJson!,
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
                                        await _rememberDataKey(
                                            _model.dataKeyB64!);
                                        safeSetState(() {});
                                        _model.supaRows =
                                            await DecoyWalletTable().queryRows(
                                          queryFn: (q) => q.eqOrNull(
                                            'user_id',
                                            currentUserUid,
                                          ),
                                        );
                                        if (_model.supaRows != null &&
                                            (_model.supaRows)!.isNotEmpty) {
                                          await DecoyWalletTable().update(
                                            data: {
                                              'wrapped_datakey':
                                                  _model.wrappedB64,
                                              'address_ciphertext':
                                                  _model.ctB64,
                                              'address_nonce': _model.nonceB64,
                                              'address_version': 1,
                                              'updated_at':
                                                  supaSerialize<DateTime>(
                                                      getCurrentTimestamp),
                                              'address_complete': (_model
                                                              .streetAddressTextController
                                                              .text !=
                                                          '') &&
                                                      (_model.cityTextController
                                                              .text !=
                                                          '') &&
                                                      (_model.stateTextController
                                                              .text !=
                                                          '') &&
                                                      (_model.zipTextController
                                                              .text !=
                                                          '')
                                                  ? true
                                                  : false,
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
                                          _model.addressSaved = 1;
                                          safeSetState(() {});
                                          await Future.delayed(
                                            Duration(
                                              milliseconds: 2000,
                                            ),
                                          );
                                          context.safePop();
                                        } else {
                                          _model.insRow =
                                              await DecoyWalletTable().insert({
                                            'user_id': currentUserUid,
                                            'wrapped_datakey':
                                                _model.wrappedB64,
                                            'address_ciphertext': _model.ctB64,
                                            'address_nonce': _model.nonceB64,
                                            'address_version': 1,
                                            'updated_at':
                                                supaSerialize<DateTime>(
                                                    getCurrentTimestamp),
                                            'address_complete': (_model
                                                            .streetAddressTextController
                                                            .text !=
                                                        '') &&
                                                    (_model.cityTextController
                                                            .text !=
                                                        '') &&
                                                    (_model.stateTextController
                                                            .text !=
                                                        '') &&
                                                    (_model.zipTextController
                                                            .text !=
                                                        '')
                                                ? true
                                                : false,
                                          });
                                          _model.decoyWalletRefresh2 =
                                              await DecoyWalletTable()
                                                  .queryRows(
                                            queryFn: (q) => q.eqOrNull(
                                              'user_id',
                                              currentUserUid,
                                            ),
                                          );
                                          _model.addressSaved = 1;
                                          safeSetState(() {});
                                          await Future.delayed(
                                            Duration(
                                              milliseconds: 2000,
                                            ),
                                          );
                                          context.safePop();
                                        }
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'ERROR #010 - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT',
                                              style: TextStyle(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                              ),
                                            ),
                                            duration:
                                                Duration(milliseconds: 4000),
                                            backgroundColor:
                                                FlutterFlowTheme.of(context)
                                                    .secondary,
                                          ),
                                        );
                                      }
                                    } else {
                                      context
                                          .goNamed(LoginPageWidget.routeName);
                                    }

                                    safeSetState(() {});
                                  },
                                  text: 'Save & Exit',
                                  options: FFButtonOptions(
                                    width: 250.0,
                                    height: 56.0,
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        24.0, 0.0, 24.0, 0.0),
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    color: FlutterFlowTheme.of(context).primary,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .override(
                                          font: GoogleFonts.heebo(
                                            fontWeight: FontWeight.w600,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleMedium
                                                    .fontStyle,
                                          ),
                                          color: Colors.white,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleMedium
                                                  .fontStyle,
                                        ),
                                    elevation: 3.0,
                                    borderSide: BorderSide(
                                      color: Colors.transparent,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              ),
                            ]
                                .divide(SizedBox(height: 40.0))
                                .addToStart(SizedBox(height: 40.0))
                                .addToEnd(SizedBox(height: 0.0)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ]
                    .addToStart(SizedBox(height: 48.0))
                    .addToEnd(SizedBox(height: 200.0)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
