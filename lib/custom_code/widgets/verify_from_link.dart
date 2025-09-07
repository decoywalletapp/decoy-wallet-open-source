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

// lib/custom_code/widgets/verify_from_link.dart
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VerifyFromLink extends StatefulWidget {
  const VerifyFromLink({
    Key? key,
    required this.tokenHash,
    this.type,
  }) : super(key: key);

  final String tokenHash;
  final String? type;

  @override
  State<VerifyFromLink> createState() => _VerifyFromLinkState();
}

class _VerifyFromLinkState extends State<VerifyFromLink> {
  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    try {
      final client = Supabase.instance.client;

      // Map URL param to Supabase OtpType (defaults to signup)
      final t = (widget.type ?? 'signup').toLowerCase();
      final otpType = <String, OtpType>{
            'signup': OtpType.signup,
            'magiclink': OtpType.magiclink,
            'recovery': OtpType.recovery,
            'invite': OtpType.invite,
            'email_change': OtpType.emailChange,
          }[t] ??
          OtpType.signup;

      final res = await client.auth.verifyOTP(
        type: otpType,
        tokenHash: widget.tokenHash,
      );

      final ok = res.session != null || res.user != null;
      if (!mounted) return;

      if (ok) {
        // Go straight to your paywall/subscription page
        context.goNamed('subscriptionOptions');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification failed.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
