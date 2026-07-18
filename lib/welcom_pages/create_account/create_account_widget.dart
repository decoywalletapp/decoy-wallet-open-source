import '/backend/public_config.dart';
import '/flutter_flow/flutter_flow_autocomplete_options_list.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'create_account_model.dart';
export 'create_account_model.dart';

class CreateAccountWidget extends StatefulWidget {
  const CreateAccountWidget({super.key});

  static String routeName = 'CreateAccount';
  static String routePath = '/createAccount';

  @override
  State<CreateAccountWidget> createState() => _CreateAccountWidgetState();
}

class _CreateAccountWidgetState extends State<CreateAccountWidget> {
  late CreateAccountModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CreateAccountModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.notificationState = 0;
      safeSetState(() {});
    });

    _model.emailAddressTextController ??= TextEditingController();

    _model.passwordCreateAccountTextController ??= TextEditingController();

    _model.passwordConfirmTextController ??= TextEditingController();

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
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 8,
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(color: Colors.white),
                        alignment: AlignmentDirectional(0.0, 0.0),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Container(
                                  width: 400.0,
                                  height: 150.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).info,
                                    borderRadius: BorderRadius.circular(0.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                      6.0,
                                      0.0,
                                      0.0,
                                      0.0,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(0.0),
                                      child: Image.asset(
                                        'assets/images/DecoyLogo1-WOHiRes.jpg',
                                        width: 200.0,
                                        height: 200.0,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                    32.0,
                                    24.0,
                                    32.0,
                                    32.0,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Align(
                                        alignment: AlignmentDirectional(
                                          0.0,
                                          0.0,
                                        ),
                                        child: Text(
                                          'Create an account',
                                          style: FlutterFlowTheme.of(context)
                                              .headlineMedium
                                              .override(
                                                fontFamily: 'InterTight',
                                                fontSize: 32.0,
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                      ),
                                      Stack(
                                        children: [
                                          if (_model.notificationState
                                                  .toString() ==
                                              '0')
                                            Align(
                                              alignment: AlignmentDirectional(
                                                0.0,
                                                0.0,
                                              ),
                                              child: Text(
                                                'Let\'s get started by filling out the form below.',
                                                style:
                                                    FlutterFlowTheme.of(
                                                      context,
                                                    ).labelMedium.override(
                                                      fontFamily: 'robot',
                                                      color: Colors.black,
                                                      fontSize: 14.0,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                              ),
                                            ),
                                          if (_model.notificationState
                                                  .toString() ==
                                              '1')
                                            Align(
                                              alignment: AlignmentDirectional(
                                                0.0,
                                                0.0,
                                              ),
                                              child: Text(
                                                'PASSWORDS DO NOT MATCH',
                                                style:
                                                    FlutterFlowTheme.of(
                                                      context,
                                                    ).bodyMedium.override(
                                                      fontFamily:
                                                          FlutterFlowTheme.of(
                                                            context,
                                                          ).bodyMediumFamily,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                            context,
                                                          ).primary,
                                                      fontSize: 14.0,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      useGoogleFonts:
                                                          !FlutterFlowTheme.of(
                                                            context,
                                                          ).bodyMediumIsCustom,
                                                    ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      Container(
                                        width: 370.0,
                                        child: Autocomplete<String>(
                                          initialValue: TextEditingValue(),
                                          optionsBuilder: (textEditingValue) {
                                            if (textEditingValue.text == '') {
                                              return const Iterable<
                                                String
                                              >.empty();
                                            }
                                            return ['Option 1'].where((option) {
                                              final lowercaseOption = option
                                                  .toLowerCase();
                                              return lowercaseOption.contains(
                                                textEditingValue.text
                                                    .toLowerCase(),
                                              );
                                            });
                                          },
                                          optionsViewBuilder:
                                              (context, onSelected, options) {
                                                return AutocompleteOptionsList(
                                                  textFieldKey:
                                                      _model.emailAddressKey,
                                                  textController: _model
                                                      .emailAddressTextController!,
                                                  options: options.toList(),
                                                  onSelected: onSelected,
                                                  textStyle:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).bodyMedium.override(
                                                        fontFamily:
                                                            FlutterFlowTheme.of(
                                                              context,
                                                            ).bodyMediumFamily,
                                                        letterSpacing: 0.0,
                                                        useGoogleFonts:
                                                            !FlutterFlowTheme.of(
                                                              context,
                                                            ).bodyMediumIsCustom,
                                                      ),
                                                  textHighlightStyle:
                                                      TextStyle(),
                                                  elevation: 4.0,
                                                  optionBackgroundColor:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).primaryBackground,
                                                  optionHighlightColor:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).secondaryBackground,
                                                  maxHeight: 200.0,
                                                );
                                              },
                                          onSelected: (String selection) {
                                            safeSetState(
                                              () =>
                                                  _model.emailAddressSelectedOption =
                                                      selection,
                                            );
                                            FocusScope.of(context).unfocus();
                                          },
                                          fieldViewBuilder:
                                              (
                                                context,
                                                textEditingController,
                                                focusNode,
                                                onEditingComplete,
                                              ) {
                                                _model.emailAddressFocusNode =
                                                    focusNode;

                                                _model.emailAddressTextController =
                                                    textEditingController;
                                                return TextFormField(
                                                  key: _model.emailAddressKey,
                                                  controller:
                                                      textEditingController,
                                                  focusNode: focusNode,
                                                  onEditingComplete: () {
                                                    _model
                                                        .passwordCreateAccountFocusNode
                                                        ?.requestFocus();
                                                  },
                                                  autofocus: false,
                                                  enabled: true,
                                                  autofillHints: [
                                                    AutofillHints.email,
                                                  ],
                                                  textCapitalization:
                                                      TextCapitalization.none,
                                                  textInputAction:
                                                      TextInputAction.next,
                                                  obscureText: false,
                                                  decoration: InputDecoration(
                                                    labelText: 'Email',
                                                    labelStyle:
                                                        FlutterFlowTheme.of(
                                                          context,
                                                        ).labelMedium.override(
                                                          fontFamily: 'robot',
                                                          color:
                                                              FlutterFlowTheme.of(
                                                                context,
                                                              ).secondaryText,
                                                          fontSize: 14.0,
                                                          letterSpacing: 0.25,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                color: Color(
                                                                  0xFFFA5E00,
                                                                ),
                                                                width: 2.0,
                                                              ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12.0,
                                                              ),
                                                        ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                color: Color(
                                                                  0xFFFA5E00,
                                                                ),
                                                                width: 2.0,
                                                              ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12.0,
                                                              ),
                                                        ),
                                                    errorBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Color(
                                                          0xFFFA5E00,
                                                        ),
                                                        width: 2.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12.0,
                                                          ),
                                                    ),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                color: Color(
                                                                  0xFFFA5E00,
                                                                ),
                                                                width: 2.0,
                                                              ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12.0,
                                                              ),
                                                        ),
                                                    filled: true,
                                                    fillColor:
                                                        FlutterFlowTheme.of(
                                                          context,
                                                        ).secondaryBackground,
                                                  ),
                                                  style:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).bodyMedium.override(
                                                        fontFamily: 'robot',
                                                        color:
                                                            FlutterFlowTheme.of(
                                                              context,
                                                            ).primaryText,
                                                        fontSize: 16.0,
                                                        letterSpacing: 0.25,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                  keyboardType: TextInputType
                                                      .emailAddress,
                                                  onFieldSubmitted: (_) async {
                                                    _model
                                                        .passwordCreateAccountFocusNode
                                                        ?.requestFocus();
                                                  },
                                                  enableInteractiveSelection:
                                                      false,
                                                  validator: _model
                                                      .emailAddressTextControllerValidator
                                                      .asValidator(context),
                                                  inputFormatters: [
                                                    if (!isAndroid && !isiOS)
                                                      TextInputFormatter.withFunction((
                                                        oldValue,
                                                        newValue,
                                                      ) {
                                                        return TextEditingValue(
                                                          selection: newValue
                                                              .selection,
                                                          text: newValue.text
                                                              .toCapitalization(
                                                                TextCapitalization
                                                                    .none,
                                                              ),
                                                        );
                                                      }),
                                                  ],
                                                );
                                              },
                                        ),
                                      ),
                                      Container(
                                        width: 370.0,
                                        child: Autocomplete<String>(
                                          initialValue: TextEditingValue(),
                                          optionsBuilder: (textEditingValue) {
                                            if (textEditingValue.text == '') {
                                              return const Iterable<
                                                String
                                              >.empty();
                                            }
                                            return <String>[].where((option) {
                                              final lowercaseOption = option
                                                  .toLowerCase();
                                              return lowercaseOption.contains(
                                                textEditingValue.text
                                                    .toLowerCase(),
                                              );
                                            });
                                          },
                                          optionsViewBuilder:
                                              (context, onSelected, options) {
                                                return AutocompleteOptionsList(
                                                  textFieldKey: _model
                                                      .passwordCreateAccountKey,
                                                  textController: _model
                                                      .passwordCreateAccountTextController!,
                                                  options: options.toList(),
                                                  onSelected: onSelected,
                                                  textStyle:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).bodyMedium.override(
                                                        fontFamily:
                                                            FlutterFlowTheme.of(
                                                              context,
                                                            ).bodyMediumFamily,
                                                        letterSpacing: 0.0,
                                                        useGoogleFonts:
                                                            !FlutterFlowTheme.of(
                                                              context,
                                                            ).bodyMediumIsCustom,
                                                      ),
                                                  textHighlightStyle:
                                                      TextStyle(),
                                                  elevation: 4.0,
                                                  optionBackgroundColor:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).primaryBackground,
                                                  optionHighlightColor:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).secondaryBackground,
                                                  maxHeight: 200.0,
                                                );
                                              },
                                          onSelected: (String selection) {
                                            safeSetState(
                                              () =>
                                                  _model.passwordCreateAccountSelectedOption =
                                                      selection,
                                            );
                                            FocusScope.of(context).unfocus();
                                          },
                                          fieldViewBuilder:
                                              (
                                                context,
                                                textEditingController,
                                                focusNode,
                                                onEditingComplete,
                                              ) {
                                                _model.passwordCreateAccountFocusNode =
                                                    focusNode;

                                                _model.passwordCreateAccountTextController =
                                                    textEditingController;
                                                return TextFormField(
                                                  key: _model
                                                      .passwordCreateAccountKey,
                                                  controller:
                                                      textEditingController,
                                                  focusNode: focusNode,
                                                  onEditingComplete: () {
                                                    _model
                                                        .passwordConfirmFocusNode
                                                        ?.requestFocus();
                                                  },
                                                  autofocus: false,
                                                  enabled: true,
                                                  autofillHints: [
                                                    AutofillHints.password,
                                                  ],
                                                  textInputAction:
                                                      TextInputAction.next,
                                                  obscureText: !_model
                                                      .passwordCreateAccountVisibility,
                                                  decoration: InputDecoration(
                                                    labelText: 'Password',
                                                    labelStyle:
                                                        FlutterFlowTheme.of(
                                                          context,
                                                        ).labelMedium.override(
                                                          font: GoogleFonts.plusJakartaSans(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                      context,
                                                                    )
                                                                    .labelMedium
                                                                    .fontStyle,
                                                          ),
                                                          color:
                                                              FlutterFlowTheme.of(
                                                                context,
                                                              ).secondaryText,
                                                          fontSize: 14.0,
                                                          letterSpacing: 0.25,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                    context,
                                                                  )
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                color: Color(
                                                                  0xFFFA5E00,
                                                                ),
                                                                width: 2.0,
                                                              ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12.0,
                                                              ),
                                                        ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                color: Color(
                                                                  0xFFFA5E00,
                                                                ),
                                                                width: 2.0,
                                                              ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12.0,
                                                              ),
                                                        ),
                                                    errorBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Color(
                                                          0xFFFA5E00,
                                                        ),
                                                        width: 2.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12.0,
                                                          ),
                                                    ),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                color: Color(
                                                                  0xFFFA5E00,
                                                                ),
                                                                width: 2.0,
                                                              ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12.0,
                                                              ),
                                                        ),
                                                    filled: true,
                                                    fillColor: Color(
                                                      0xF1FFFFFF,
                                                    ),
                                                    suffixIcon: InkWell(
                                                      onTap: () async {
                                                        safeSetState(
                                                          () => _model.passwordCreateAccountVisibility =
                                                              !_model
                                                                  .passwordCreateAccountVisibility,
                                                        );
                                                      },
                                                      focusNode: FocusNode(
                                                        skipTraversal: true,
                                                      ),
                                                      child: Icon(
                                                        _model.passwordCreateAccountVisibility
                                                            ? Icons
                                                                  .visibility_outlined
                                                            : Icons
                                                                  .visibility_off_outlined,
                                                        color: Color(
                                                          0xFF57636C,
                                                        ),
                                                        size: 24.0,
                                                      ),
                                                    ),
                                                  ),
                                                  style:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).bodyMedium.override(
                                                        fontFamily: 'robot',
                                                        color:
                                                            FlutterFlowTheme.of(
                                                              context,
                                                            ).primaryText,
                                                        fontSize: 16.0,
                                                        letterSpacing: 0.25,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                  onFieldSubmitted: (_) async {
                                                    _model
                                                        .passwordConfirmFocusNode
                                                        ?.requestFocus();
                                                  },
                                                  validator: _model
                                                      .passwordCreateAccountTextControllerValidator
                                                      .asValidator(context),
                                                );
                                              },
                                        ),
                                      ),
                                      Container(
                                        width: 370.0,
                                        child: Autocomplete<String>(
                                          initialValue: TextEditingValue(),
                                          optionsBuilder: (textEditingValue) {
                                            if (textEditingValue.text == '') {
                                              return const Iterable<
                                                String
                                              >.empty();
                                            }
                                            return ['Option 1'].where((option) {
                                              final lowercaseOption = option
                                                  .toLowerCase();
                                              return lowercaseOption.contains(
                                                textEditingValue.text
                                                    .toLowerCase(),
                                              );
                                            });
                                          },
                                          optionsViewBuilder:
                                              (context, onSelected, options) {
                                                return AutocompleteOptionsList(
                                                  textFieldKey:
                                                      _model.passwordConfirmKey,
                                                  textController: _model
                                                      .passwordConfirmTextController!,
                                                  options: options.toList(),
                                                  onSelected: onSelected,
                                                  textStyle:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).bodyMedium.override(
                                                        fontFamily:
                                                            FlutterFlowTheme.of(
                                                              context,
                                                            ).bodyMediumFamily,
                                                        letterSpacing: 0.0,
                                                        useGoogleFonts:
                                                            !FlutterFlowTheme.of(
                                                              context,
                                                            ).bodyMediumIsCustom,
                                                      ),
                                                  textHighlightStyle:
                                                      TextStyle(),
                                                  elevation: 4.0,
                                                  optionBackgroundColor:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).primaryBackground,
                                                  optionHighlightColor:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).secondaryBackground,
                                                  maxHeight: 200.0,
                                                );
                                              },
                                          onSelected: (String selection) {
                                            safeSetState(
                                              () =>
                                                  _model.passwordConfirmSelectedOption =
                                                      selection,
                                            );
                                            FocusScope.of(context).unfocus();
                                          },
                                          fieldViewBuilder:
                                              (
                                                context,
                                                textEditingController,
                                                focusNode,
                                                onEditingComplete,
                                              ) {
                                                _model.passwordConfirmFocusNode =
                                                    focusNode;

                                                _model.passwordConfirmTextController =
                                                    textEditingController;
                                                return TextFormField(
                                                  key:
                                                      _model.passwordConfirmKey,
                                                  controller:
                                                      textEditingController,
                                                  focusNode: focusNode,
                                                  onEditingComplete: () {
                                                    FocusScope.of(
                                                      context,
                                                    ).unfocus();
                                                    FocusManager
                                                        .instance
                                                        .primaryFocus
                                                        ?.unfocus();
                                                  },
                                                  autofocus: false,
                                                  autofillHints: [
                                                    AutofillHints.password,
                                                  ],
                                                  textInputAction:
                                                      TextInputAction.done,
                                                  obscureText: !_model
                                                      .passwordConfirmVisibility,
                                                  decoration: InputDecoration(
                                                    labelText:
                                                        'Confirm Password',
                                                    labelStyle:
                                                        FlutterFlowTheme.of(
                                                          context,
                                                        ).labelMedium.override(
                                                          font: GoogleFonts.plusJakartaSans(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                      context,
                                                                    )
                                                                    .labelMedium
                                                                    .fontStyle,
                                                          ),
                                                          color:
                                                              FlutterFlowTheme.of(
                                                                context,
                                                              ).secondaryText,
                                                          fontSize: 14.0,
                                                          letterSpacing: 0.25,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                    context,
                                                                  )
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                color: Color(
                                                                  0xFFFA5E00,
                                                                ),
                                                                width: 2.0,
                                                              ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12.0,
                                                              ),
                                                        ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                color: Color(
                                                                  0xFFFA5E00,
                                                                ),
                                                                width: 2.0,
                                                              ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12.0,
                                                              ),
                                                        ),
                                                    errorBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Color(
                                                          0xFFFA5E00,
                                                        ),
                                                        width: 2.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12.0,
                                                          ),
                                                    ),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                color: Color(
                                                                  0xFFFA5E00,
                                                                ),
                                                                width: 2.0,
                                                              ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12.0,
                                                              ),
                                                        ),
                                                    filled: true,
                                                    fillColor: Color(
                                                      0xF1FFFFFF,
                                                    ),
                                                    suffixIcon: InkWell(
                                                      onTap: () async {
                                                        safeSetState(
                                                          () => _model.passwordConfirmVisibility =
                                                              !_model
                                                                  .passwordConfirmVisibility,
                                                        );
                                                      },
                                                      focusNode: FocusNode(
                                                        skipTraversal: true,
                                                      ),
                                                      child: Icon(
                                                        _model.passwordConfirmVisibility
                                                            ? Icons
                                                                  .visibility_outlined
                                                            : Icons
                                                                  .visibility_off_outlined,
                                                        color: Color(
                                                          0xFF57636C,
                                                        ),
                                                        size: 24.0,
                                                      ),
                                                    ),
                                                  ),
                                                  style:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).bodyMedium.override(
                                                        fontFamily: 'robot',
                                                        color:
                                                            FlutterFlowTheme.of(
                                                              context,
                                                            ).primaryText,
                                                        fontSize: 16.0,
                                                        letterSpacing: 0.25,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                  minLines: 1,
                                                  onFieldSubmitted: (_) async {
                                                    await actions
                                                        .dismissKeyboard(
                                                          context,
                                                        );
                                                  },
                                                  validator: _model
                                                      .passwordConfirmTextControllerValidator
                                                      .asValidator(context),
                                                );
                                              },
                                        ),
                                      ),
                                      SizedBox(
                                        height: _model.notificationState == 0
                                            ? 25.0
                                            : 48.0,
                                        child: Align(
                                          alignment: AlignmentDirectional(
                                            0.0,
                                            0.0,
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  width: double.infinity,
                                                  height:
                                                      _model.notificationState ==
                                                          0
                                                      ? 25.0
                                                      : 48.0,
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(
                                                      context,
                                                    ).info,
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      if (_model
                                                              .notificationState ==
                                                          0)
                                                        Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                0.0,
                                                                0.0,
                                                              ),
                                                          child: Text(
                                                            'Password Must Be At Least 10 Characters',
                                                            style:
                                                                FlutterFlowTheme.of(
                                                                  context,
                                                                ).bodyMedium.override(
                                                                  fontFamily:
                                                                      FlutterFlowTheme.of(
                                                                        context,
                                                                      ).bodyMediumFamily,
                                                                  color: FlutterFlowTheme.of(
                                                                    context,
                                                                  ).secondaryText,
                                                                  fontSize:
                                                                      14.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                        context,
                                                                      ).bodyMediumIsCustom,
                                                                ),
                                                          ),
                                                        ),
                                                      if (_model
                                                              .notificationState ==
                                                          1)
                                                        Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                0.0,
                                                                0.0,
                                                              ),
                                                          child: Text(
                                                            'INVALID PASSWORD - MUST BE AT LEAST 10 CHARACTERS',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style:
                                                                FlutterFlowTheme.of(
                                                                  context,
                                                                ).bodyMedium.override(
                                                                  fontFamily:
                                                                      FlutterFlowTheme.of(
                                                                        context,
                                                                      ).bodyMediumFamily,
                                                                  color:
                                                                      FlutterFlowTheme.of(
                                                                        context,
                                                                      ).primary,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                        context,
                                                                      ).bodyMediumIsCustom,
                                                                ),
                                                          ),
                                                        ),
                                                      if (_model
                                                              .notificationState ==
                                                          2)
                                                        Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                0.0,
                                                                0.0,
                                                              ),
                                                          child: Text(
                                                            'PASSWORDS DO NOT MATCH - TRY AGAIN',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style:
                                                                FlutterFlowTheme.of(
                                                                  context,
                                                                ).bodyMedium.override(
                                                                  fontFamily:
                                                                      FlutterFlowTheme.of(
                                                                        context,
                                                                      ).bodyMediumFamily,
                                                                  color:
                                                                      FlutterFlowTheme.of(
                                                                        context,
                                                                      ).primary,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                        context,
                                                                      ).bodyMediumIsCustom,
                                                                ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      FFButtonWidget(
                                        onPressed: () async {
                                          await actions.dismissKeyboard(
                                            context,
                                          );
                                          if (_model
                                                  .passwordCreateAccountTextController
                                                  .text ==
                                              _model
                                                  .passwordConfirmTextController
                                                  .text) {
                                            _model.ctResult = await actions
                                                .supaEmailSignUp(
                                                  _model
                                                      .emailAddressTextController
                                                      .text,
                                                  _model
                                                      .passwordCreateAccountTextController
                                                      .text,
                                                  requiredPublicConfig(
                                                    'DECOY_EMAIL_CONFIRM_URL',
                                                    kEmailConfirmUrl,
                                                  ),
                                                );
                                            if (_model.ctResult == 'ok') {
                                              context.pushNamed(
                                                ConfirmEmailPageWidget
                                                    .routeName,
                                                queryParameters: {
                                                  'emailEntry': serializeParam(
                                                    _model
                                                        .emailAddressTextController
                                                        .text,
                                                    ParamType.String,
                                                  ),
                                                }.withoutNulls,
                                              );
                                            } else {
                                              _model.notificationState = 1;
                                              safeSetState(() {});
                                              await Future.delayed(
                                                Duration(milliseconds: 3000),
                                              );
                                              _model.notificationState = 0;
                                              safeSetState(() {});
                                            }
                                          } else {
                                            _model.notificationState = 2;
                                            safeSetState(() {});
                                            await Future.delayed(
                                              Duration(milliseconds: 3000),
                                            );
                                            _model.notificationState = 0;
                                            safeSetState(() {});
                                          }

                                          safeSetState(() {});
                                        },
                                        text: 'Create Account',
                                        options: FFButtonOptions(
                                          width: 370.0,
                                          height: 50.0,
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                0.0,
                                                0.0,
                                                0.0,
                                                0.0,
                                              ),
                                          iconPadding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                0.0,
                                                0.0,
                                                0.0,
                                                0.0,
                                              ),
                                          color: Color(0xFFFA5E00),
                                          textStyle:
                                              FlutterFlowTheme.of(
                                                context,
                                              ).titleSmall.override(
                                                font: GoogleFonts.heebo(
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).titleSmall.fontStyle,
                                                ),
                                                color: Colors.white,
                                                fontSize: 18.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w600,
                                                fontStyle: FlutterFlowTheme.of(
                                                  context,
                                                ).titleSmall.fontStyle,
                                              ),
                                          elevation: 3.0,
                                          borderSide: BorderSide(
                                            color: Colors.transparent,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12.0,
                                          ),
                                        ),
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Align(
                                            alignment: AlignmentDirectional(
                                              0.0,
                                              0.0,
                                            ),
                                            child: Wrap(
                                              spacing: 0.0,
                                              runSpacing: 0.0,
                                              alignment: WrapAlignment.center,
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.center,
                                              direction: Axis.horizontal,
                                              runAlignment:
                                                  WrapAlignment.center,
                                              verticalDirection:
                                                  VerticalDirection.down,
                                              clipBehavior: Clip.none,
                                              children: [
                                                // You will have to add an action on this rich text to go to your login page.
                                                InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    context.pushNamed(
                                                      LoginPageWidget.routeName,
                                                    );
                                                  },
                                                  child: RichText(
                                                    textScaler: MediaQuery.of(
                                                      context,
                                                    ).textScaler,
                                                    text: TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text:
                                                              'Already have an account? ',
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: 'Sign In here',
                                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                            font: GoogleFonts.plusJakartaSans(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
                                                                        context,
                                                                      )
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                            ),
                                                            color: Color(
                                                              0xFFFA5E00,
                                                            ),
                                                            fontSize: 16.0,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                      context,
                                                                    )
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                        ),
                                                      ],
                                                      style:
                                                          FlutterFlowTheme.of(
                                                            context,
                                                          ).labelLarge.override(
                                                            fontFamily:
                                                                'InterTight',
                                                            color: Color(
                                                              0xFFFA5E00,
                                                            ),
                                                            fontSize: 16.0,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 25.0,
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(
                                              context,
                                            ).secondaryBackground,
                                          ),
                                        ),
                                      ),
                                    ].divide(SizedBox(height: 24.0)),
                                  ),
                                ),
                              ),
                            ].addToStart(SizedBox(height: 24.0)).addToEnd(SizedBox(height: 24.0)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
