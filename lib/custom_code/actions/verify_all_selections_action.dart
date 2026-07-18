// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/supabase/supabase.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Returns true iff the user's three selections match the correct word
// for each quiz question index.
// Returns true iff the three picked words match the correct words.

Future<bool> verifyAllSelectionsAction(
  List<String> words,
  List<int> quizIndices,
  List<String> chosenWords,
) async {
  // Need exactly 3 selections and 3 quiz indices
  if (chosenWords.length != 3 || quizIndices.length != 3) return false;

  for (int q = 0; q < 3; q++) {
    final quizWordIndex = quizIndices[q]; // 0-based word number asked
    final correct = words[quizWordIndex]; // correct word text
    if (chosenWords[q] != correct) return false;
  }
  return true;
}
// We need the three options for this question exactly how buildQuizStepAction did it.
// If your buildQuizStepAction always places the correct word among 0..2 and shuffles,
// the easiest consistent check is to rebuild that same step here or—better—
// have buildQuizStepAction's logic be deterministic from (words, quizIndices, q)
// so this action can reconstruct the same 3 options and compare.
//
// Simpler approach: pass the three correct words aside as we go.
// Since we chose to verify at the end, we’ll reconstruct minimally:

// Minimal deterministic reconstruction: correct equals words[quizWordIndex],
// the chosenOptionIndex represents the user's pick within that step's options.
// If your step always ensured the correct word was included once,
// we can just compare the user's picked text against the known correct text:
//
// We need the chosen text. Store it during taps OR pass it here:
// If you didn't store texts, modify the option-tap to also push
// the chosen word text into a parallel list `chosenWords`.
// We'll use that: (See below wiring)
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
