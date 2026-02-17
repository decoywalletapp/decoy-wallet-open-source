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

import 'dart:math' as math;

import 'dart:convert';
import 'dart:math' as math;

Future<dynamic> buildQuizStepAction(
  List<String> words,
  List<int> quizIndices,
  int currentQuestion,
) async {
  // which word (0-based) are we quizzing?
  final quizWordIndex = quizIndices[currentQuestion];

  // the correct word
  final correct = words[quizWordIndex];

  // pick two distinct distractors (not the correct index)
  final rng = math.Random();
  int a, b;
  do {
    a = rng.nextInt(words.length);
  } while (a == quizWordIndex);
  do {
    b = rng.nextInt(words.length);
  } while (b == quizWordIndex || b == a);

  // build + shuffle options
  final options = <String>[correct, words[a], words[b]]..shuffle(rng);

  // 1-based number for UI label "Choose word #N"
  final displayIndex = quizWordIndex + 1;

  // Return a plain map (FF JSON)
  return {
    'options': options,
    'correctWord': correct,
    'displayIndex': displayIndex,
  };
}

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
