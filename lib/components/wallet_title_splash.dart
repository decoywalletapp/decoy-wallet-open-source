import '/l10n/app_localizations.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';

class WalletTitleSplash extends StatelessWidget {
  const WalletTitleSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 40),
        child: SizedBox(
          width: double.infinity,
          height: 80,
          child: Center(
            child: Text(
              AppLocalizations.of(context)!.msgItcoinWallet,
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).displayMedium.override(
                    fontFamily: 'InterTight',
                    color: FlutterFlowTheme.of(context).primary,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
