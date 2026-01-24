import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'generate_decoy_seed_phrase_widget.dart'
    show GenerateDecoySeedPhraseWidget;
import 'package:flutter/material.dart';

class GenerateDecoySeedPhraseModel
    extends FlutterFlowModel<GenerateDecoySeedPhraseWidget> {
  ///  Local state fields for this page.

  bool decoyOk = false;

  String? dbgDecoyId;

  String? dbgXpub;

  String? tempMnemonic;

  String? tempDecoyId;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - generateDecoyDraft] action in Button widget.
  dynamic decoyDraftOut;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
