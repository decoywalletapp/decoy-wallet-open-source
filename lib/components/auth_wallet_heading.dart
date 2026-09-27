import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';

import '/l10n/app_localizations.dart';

class AuthWalletHeading extends StatelessWidget {
  const AuthWalletHeading({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 140,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              AppLocalizations.of(context)!.msgItcoinWallet,
              key: const ValueKey('auth-wallet-heading'),
              textAlign: TextAlign.center,
              maxLines: 1,
              style: FlutterFlowTheme.of(context).displayMedium.override(
                    fontFamily: 'InterTight',
                    color: FlutterFlowTheme.of(context).primary,
                    letterSpacing: 0,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
