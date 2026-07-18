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

String buildLocationJsonString(LatLng? emergencyLocation) {
  if (emergencyLocation == null) {
    return '{"lat":null,"lng":null}';
  }

  final lat = emergencyLocation.latitude;
  final lng = emergencyLocation.longitude;

  return '{"lat":$lat,"lng":$lng}';
}
