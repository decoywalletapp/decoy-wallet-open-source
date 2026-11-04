import '/auth/supabase_auth/auth_util.dart';
import '/backend/public_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'workshop_claim_client.dart';
import 'workshop_qr_page.dart';

Future<bool> openWorkshopQr(BuildContext context) async {
  final accountId = currentUserUid;
  final client = http.Client();
  Future<WorkshopClaimReceipt> claim(
    String qr, {
    bool confirmCancelRenewal = false,
  }) async {
    if (accountId.isEmpty || currentUserUid != accountId) {
      throw const WorkshopClaimException(WorkshopClaimFailure.signedOut);
    }
    final service = WorkshopClaimClient(
      endpoint: Uri.parse(
          '${requiredPublicConfig('DECOY_WORKSHOP_CLAIM_BASE_URL', kWorkshopClaimBaseUrl)}/claim-workshop-access'),
      client: client,
    );
    final receipt = await service.claim(
      qr: qr,
      jwt: currentJwtToken,
      confirmCancelRenewal: confirmCancelRenewal,
    );
    if (currentUserUid != accountId) {
      throw const WorkshopClaimException(WorkshopClaimFailure.signedOut);
    }
    return receipt;
  }

  try {
    final activated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => WorkshopQrPage(
          claim: claim,
          claimWithBillingConfirmation: (qr) =>
              claim(qr, confirmCancelRenewal: true),
        ),
      ),
    );
    return activated == true && currentUserUid == accountId;
  } finally {
    client.close();
  }
}
