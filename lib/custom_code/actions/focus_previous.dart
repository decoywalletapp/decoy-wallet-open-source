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

Future focusPrevious(BuildContext context) async {
  await Future.delayed(const Duration(milliseconds: 1));
  FocusScope.of(context).previousFocus();
}

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
