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

import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';

import 'package:permission_handler/permission_handler.dart';

Future<String?> getLocationPermissionStatus() async {
  final whenInUse = await Permission.locationWhenInUse.status;
  final always = await Permission.locationAlways.status;
  final location = await Permission.location.status;

  return 'whenInUse=${whenInUse.name}|always=${always.name}|location=${location.name}';
}
