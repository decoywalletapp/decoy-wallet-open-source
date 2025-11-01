// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

class VerifyAnyLink extends StatefulWidget {
  final double? width;
  final double? height;
  const VerifyAnyLink({Key? key, this.width, this.height}) : super(key: key);

  @override
  State<VerifyAnyLink> createState() => _VerifyAnyLinkState();
}

class _VerifyAnyLinkState extends State<VerifyAnyLink> {
  AppLinks? _appLinks;
  StreamSubscription<Uri>? _sub;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _appLinks = AppLinks();

    // Cold start
    try {
      final uri = await _appLinks!.getInitialLink();
      if (kDebugMode) debugPrint('[VerifyAnyLink] initial link: $uri');
      if (uri != null) _handleUri(uri);
    } catch (e, st) {
      if (kDebugMode)
        debugPrint('[VerifyAnyLink] getInitialLink error: $e\n$st');
    }

    // Warm
    _sub = _appLinks!.uriLinkStream.listen(
      (uri) {
        if (kDebugMode) debugPrint('[VerifyAnyLink] stream link: $uri');
        _handleUri(uri);
      },
      onError: (e) {
        if (kDebugMode) debugPrint('[VerifyAnyLink] stream error: $e');
      },
    );
  }

  Future<void> _handleUri(Uri uri) async {
    final p = uri.queryParameters;
    final tokenHash = p['token_hash'] ?? p['tokenHash'];
    final t = (p['type'] ?? 'signup').toLowerCase();
    if (tokenHash == null || tokenHash.isEmpty) return;

    final typeMap = <String, OtpType>{
      'signup': OtpType.signup,
      'magiclink': OtpType.magiclink,
      'recovery': OtpType.recovery,
      'invite': OtpType.invite,
      'email_change': OtpType.emailChange,
    };
    final otpType = typeMap[t] ?? OtpType.signup;
    final client = Supabase.instance.client;

    try {
      final res = await client.auth.verifyOTP(
        type: otpType,
        tokenHash: tokenHash,
      );

      // let session hydrate
      await Future.delayed(const Duration(milliseconds: 300));
      final session = client.auth.currentSession ?? res.session;
      final ok = session != null || res.user != null;
      if (!ok || !mounted) return;

      // Optional: promote pending_email -> email on your profile row
      try {
        final uid = client.auth.currentUser?.id;
        final nowEmail =
            (client.auth.currentUser?.email ?? '').trim().toLowerCase();
        if (uid != null && nowEmail.isNotEmpty) {
          // maybeSingle() can return null; keep everything nullable-safe
          final dynamic profDyn = await client
              .from('profiles') // <-- change table name if yours differs
              .select()
              .eq('id', uid)
              .maybeSingle();

          final Map<String, dynamic>? prof =
              (profDyn is Map<String, dynamic>) ? profDyn : null;

          String pending = '';
          final dynamic val = prof?['pending_email']; // null-safe index
          if (val is String) {
            pending = val.trim().toLowerCase();
          }

          if (pending.isNotEmpty && pending == nowEmail) {
            await client.from('profiles').update({
              'email': nowEmail,
              'pending_email': null,
              'email_verified': true,
            }).eq('id', uid);
          }
        }
      } catch (e, st) {
        if (kDebugMode)
          debugPrint('[VerifyAnyLink] profile promote err: $e\n$st');
      }

      if (!_navigated && mounted) {
        _navigated = true;
        context.goNamed('phoneNumberInput'); // next step in your flow
      }
    } on AuthApiException catch (e, st) {
      if (e.code == 'otp_expired' || e.statusCode == 403) {
        if (kDebugMode) debugPrint('[VerifyAnyLink] expired/403: $e\n$st');
        return;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    } catch (e, st) {
      if (!mounted) return;
      if (kDebugMode) debugPrint('[VerifyAnyLink] ERROR: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: widget.width, height: widget.height);
  }
}
