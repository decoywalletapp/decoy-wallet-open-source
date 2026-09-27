import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';

import '/l10n/app_localizations.dart';

class AuthWalletHeading extends StatelessWidget {
  const AuthWalletHeading({super.key});

  @override
  Widget build(BuildContext context) {
    final heading = AppLocalizations.of(context)!.msgItcoinWallet;
    // Keep the Latin brand and its currency sign together in RTL sentences.
    final displayHeading = Directionality.of(context) == TextDirection.rtl
        ? heading.replaceAll('\u20bfitcoin', '\u2066\u20bfitcoin\u2069')
        : heading;
    return SizedBox(
      key: const ValueKey('auth-wallet-heading-block'),
      width: double.infinity,
      height: 140,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              displayHeading,
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
