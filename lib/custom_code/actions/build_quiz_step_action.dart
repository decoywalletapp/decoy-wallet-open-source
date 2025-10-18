// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Inputs: words(List<String>), currentQuestion(int), quizIndices(List<int>)
// Returns JSON: { quizIndices, correctIndex, displayIndex, options, correctWord }

import 'dart:convert';
import 'dart:math' as math;

Future<dynamic> buildQuizStepAction(
  List<String> words,
  int currentQuestion,
  List<int> quizIndices,
) async {
  final r = math.Random.secure();
  final wlen = words.length;

  // Ensure we have 3 distinct indices total
  final target = (wlen >= 3) ? 3 : wlen;
  final set = <int>{...quizIndices};
  while (set.length < target && set.length < wlen) {
    set.add(r.nextInt(wlen));
  }
  final finalIndices = set.toList(growable: false);

  // Clamp currentQuestion
  final cq = (currentQuestion < 0)
      ? 0
      : (currentQuestion >= finalIndices.length
          ? finalIndices.length - 1
          : currentQuestion);

  final correctIdx = finalIndices[cq];
  final correctWord = words[correctIdx];

  // Build 2 distractors
  final pool = <String>[
    for (final w in words)
      if (w != correctWord) w
  ];
  final distractors = <String>[];
  while (distractors.length < 2 && pool.isNotEmpty) {
    final pick = pool[r.nextInt(pool.length)];
    if (!distractors.contains(pick)) distractors.add(pick);
  }

  final options = <String>[correctWord, ...distractors]..shuffle(r);

  return {
    "quizIndices": finalIndices,
    "correctIndex": correctIdx,
    "displayIndex": correctIdx + 1, // 1-based for the UI label
    "options": options,
    "correctWord": correctWord
  };
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
