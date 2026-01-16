// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

String buildLocationJsonString(LatLng? emergencyLocation) {
  if (emergencyLocation == null) {
    return '{"lat":null,"lng":null}';
  }

  return '{"lat":${emergencyLocation.latitude},"lng":${emergencyLocation.longitude}}';
}

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
