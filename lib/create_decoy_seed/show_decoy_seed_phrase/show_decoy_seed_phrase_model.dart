import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'show_decoy_seed_phrase_widget.dart' show ShowDecoySeedPhraseWidget;
import 'package:flutter/material.dart';

class ShowDecoySeedPhraseModel
    extends FlutterFlowModel<ShowDecoySeedPhraseWidget> {
  ///  Local state fields for this page.

  String? tempMnemonic;

  List<String> words = [];
  void addToWords(String item) => words.add(item);
  void removeFromWords(String item) => words.remove(item);
  void removeAtIndexFromWords(int index) => words.removeAt(index);
  void insertAtIndexInWords(int index, String item) =>
      words.insert(index, item);
  void updateWordsAtIndex(int index, Function(String) updateFn) =>
      words[index] = updateFn(words[index]);

  bool showWarning = true;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - splitMnemonicAction] action in ShowDecoySeedPhrase widget.
  List<String>? splitOut;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
