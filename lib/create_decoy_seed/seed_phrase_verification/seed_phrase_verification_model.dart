import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'seed_phrase_verification_widget.dart' show SeedPhraseVerificationWidget;
import 'package:flutter/material.dart';

class SeedPhraseVerificationModel
    extends FlutterFlowModel<SeedPhraseVerificationWidget> {
  ///  Local state fields for this page.

  List<String> words = [];
  void addToWords(String item) => words.add(item);
  void removeFromWords(String item) => words.remove(item);
  void removeAtIndexFromWords(int index) => words.removeAt(index);
  void insertAtIndexInWords(int index, String item) =>
      words.insert(index, item);
  void updateWordsAtIndex(int index, Function(String) updateFn) =>
      words[index] = updateFn(words[index]);

  List<int> quizIndices = [];
  void addToQuizIndices(int item) => quizIndices.add(item);
  void removeFromQuizIndices(int item) => quizIndices.remove(item);
  void removeAtIndexFromQuizIndices(int index) => quizIndices.removeAt(index);
  void insertAtIndexInQuizIndices(int index, int item) =>
      quizIndices.insert(index, item);
  void updateQuizIndicesAtIndex(int index, Function(int) updateFn) =>
      quizIndices[index] = updateFn(quizIndices[index]);

  int currentQuestion = 0;

  List<String> options = [];
  void addToOptions(String item) => options.add(item);
  void removeFromOptions(String item) => options.remove(item);
  void removeAtIndexFromOptions(int index) => options.removeAt(index);
  void insertAtIndexInOptions(int index, String item) =>
      options.insert(index, item);
  void updateOptionsAtIndex(int index, Function(String) updateFn) =>
      options[index] = updateFn(options[index]);

  int selectedIndex = -1;

  String correctWord = '\"\"';

  int displayIndex = 0;

  bool verifyEnabled = false;

  List<String> chosenWords = [];
  void addToChosenWords(String item) => chosenWords.add(item);
  void removeFromChosenWords(String item) => chosenWords.remove(item);
  void removeAtIndexFromChosenWords(int index) => chosenWords.removeAt(index);
  void insertAtIndexInChosenWords(int index, String item) =>
      chosenWords.insert(index, item);
  void updateChosenWordsAtIndex(int index, Function(String) updateFn) =>
      chosenWords[index] = updateFn(chosenWords[index]);

  List<int> selectedIndices = [];
  void addToSelectedIndices(int item) => selectedIndices.add(item);
  void removeFromSelectedIndices(int item) => selectedIndices.remove(item);
  void removeAtIndexFromSelectedIndices(int index) =>
      selectedIndices.removeAt(index);
  void insertAtIndexInSelectedIndices(int index, int item) =>
      selectedIndices.insert(index, item);
  void updateSelectedIndicesAtIndex(int index, Function(int) updateFn) =>
      selectedIndices[index] = updateFn(selectedIndices[index]);

  int attemptCount = 0;

  int notificationState = 0;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - splitMnemonicAction] action in SeedPhraseVerification widget.
  List<String>? splitOut;
  // Stores action output result for [Custom Action - makeQuizIndicesAction] action in SeedPhraseVerification widget.
  List<int>? indicesOut;
  // Stores action output result for [Custom Action - buildQuizStepAction] action in SeedPhraseVerification widget.
  dynamic stepOut;
  // Stores action output result for [Custom Action - buildQuizStepAction] action in Button widget.
  dynamic quizStep;
  // Stores action output result for [Custom Action - verifyAllSelectionsAction] action in Button widget.
  bool? verifyResult;
  // Stores action output result for [Custom Action - makeQuizIndicesAction] action in Button widget.
  List<int>? indicesOutRetry;
  // Stores action output result for [Custom Action - buildQuizStepAction] action in Button widget.
  dynamic quizStepRetry;
  // Stores action output result for [Custom Action - buildQuizStepAction] action in Button widget.
  dynamic quizStepMid;
  // Stores action output result for [Custom Action - verifyAllSelectionsAction] action in Button widget.
  bool? verifyResultMid;
  // Stores action output result for [Custom Action - makeQuizIndicesAction] action in Button widget.
  List<int>? indicesOutRetryMid;
  // Stores action output result for [Custom Action - buildQuizStepAction] action in Button widget.
  dynamic quizStepRetryMid;
  // Stores action output result for [Custom Action - buildQuizStepAction] action in Button widget.
  dynamic quizStepBot;
  // Stores action output result for [Custom Action - verifyAllSelectionsAction] action in Button widget.
  bool? verifyResultBot;
  // Stores action output result for [Custom Action - makeQuizIndicesAction] action in Button widget.
  List<int>? indicesOutRetryBot;
  // Stores action output result for [Custom Action - buildQuizStepAction] action in Button widget.
  dynamic quizStepRetryBot;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
