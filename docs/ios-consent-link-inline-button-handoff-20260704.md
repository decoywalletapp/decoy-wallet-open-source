# iOS Handoff: Emergency Contact Consent Link UX/Security Parity

Date: 2026-07-04

Android source branch:
`/Users/mitchellwleblanc/Documents/GitHub/mobile-app-android`
`codex/android-international-phone-20260629`

Android reference HEAD before this uncommitted UI/security fix:
`f81f36a`

Android reference file:
`lib/emergancy_contact_information/emergency_contacts/emergency_contacts_widget.dart`

## Product/Security Truth

Decoy Wallet is a personal safety app disguised as a Bitcoin-wallet-style interface. Emergency contact consent links must not be exposed to the app user in a user-composed SMS.

The secure behavior is:

- The backend/Decoy Support phone number sends the contact-specific consent link directly to the emergency contact.
- The app user gets a clear in-app visual cue that the confirmation link was sent.
- The app user must not see, copy, send, or open the consent token/link.
- Do not route the app user into Messages with a prefilled consent link.
- Do not show `null` link text anywhere.

## Exact Android Behavior Now

On the Emergency Contacts page, tapping `Send Confirmation Link` or `Resend Confirmation Link`:

1. Saves/syncs the contact data as before.
2. Calls the existing consent request API as before.
3. Lets the backend send the real confirmation link from Decoy Support.
4. Keeps the user inside the app.
5. Replaces the orange button text with:
   `Confirmation Link Sent`
6. Shows a check-circle icon in that same button position.
7. Keeps that inline state visible for 5 seconds.
8. Then returns the button to:
   `Resend Confirmation Link`
9. Ignores repeat taps while the 5-second sent state is visible to avoid accidental duplicate sends.

This was tested on Android and Mitchell confirmed the flow works perfectly.

## What iOS Should Change

Apply the same behavior to the iOS Emergency Contacts page.

Likely iOS file:
`lib/emergancy_contact_information/emergency_contacts/emergency_contacts_widget.dart`

Do not blindly overwrite Android into iOS. Port the behavior surgically.

### Remove User-Side SMS Composer For Consent Links

Find the contact consent success blocks for all emergency contact slots.

Remove logic like:

- `launchUrl(...)`
- `Uri.parse("sms:...")`
- `Uri(scheme: 'sms', ...)`
- Any message body containing `CreateConsentRequestCall.link(...)`
- Any user-visible confirmation consent URL/token

The app should not open Messages after the backend consent request succeeds.

If `package:url_launcher/url_launcher.dart` is only used for this SMS consent behavior in the iOS file, remove that import. If the same file uses it elsewhere for legitimate external links, keep the import.

### Add Inline Button Sent State

Add local state to the Emergency Contacts page state class:

```dart
final Set<int> _recentConsentInviteSlots = <int>{};

bool _showingConsentInviteSent(int contactSlot) =>
    _recentConsentInviteSlots.contains(contactSlot);

String _consentInviteButtonLabel(int contactSlot, String status) {
  if (_showingConsentInviteSent(contactSlot)) {
    return 'Confirmation Link Sent';
  }

  return status == 'Not sent'
      ? 'Send Confirmation Link'
      : 'Resend Confirmation Link';
}

IconData _consentInviteButtonIcon(int contactSlot) {
  return _showingConsentInviteSent(contactSlot)
      ? Icons.check_circle_rounded
      : Icons.send_rounded;
}

void _showConsentInviteSent(int contactSlot) {
  safeSetState(() {
    _recentConsentInviteSlots.add(contactSlot);
  });

  Future.delayed(const Duration(seconds: 5), () {
    if (!mounted || !_recentConsentInviteSlots.contains(contactSlot)) {
      return;
    }

    safeSetState(() {
      _recentConsentInviteSlots.remove(contactSlot);
    });
  });
}
```

### Wire All Contact Buttons

For each contact slot button, replace the hardcoded label:

- Slot 1 uses `_consentInviteButtonLabel(1, _model.c1Status)`
- Slot 2 uses `_consentInviteButtonLabel(2, _model.c2Status)`
- Slot 3 uses `_consentInviteButtonLabel(3, _model.c3Status)`
- Slot 4 uses `_consentInviteButtonLabel(4, _model.c4Status)`
- Slot 5 uses `_consentInviteButtonLabel(5, _model.c5Status)`

Replace the send icon:

- Slot 1 uses `_consentInviteButtonIcon(1)`
- Slot 2 uses `_consentInviteButtonIcon(2)`
- Slot 3 uses `_consentInviteButtonIcon(3)`
- Slot 4 uses `_consentInviteButtonIcon(4)`
- Slot 5 uses `_consentInviteButtonIcon(5)`

At the top of each button `onPressed`, guard against duplicate taps:

```dart
if (_showingConsentInviteSent(1)) {
  return;
}
```

Use the correct slot number for each contact.

After the consent request succeeds and the status is set to `Pending`, call:

- Slot 1: `_showConsentInviteSent(1);`
- Slot 2: `_showConsentInviteSent(2);`
- Slot 3: `_showConsentInviteSent(3);`
- Slot 4: `_showConsentInviteSent(4);`
- Slot 5: `_showConsentInviteSent(5);`

Do not pass the contact name into this helper. The final UI text should simply say:
`Confirmation Link Sent`

## App Build Requirement

This is an app-code/UI/security-flow change. iOS needs a new app build for this change to reach users.

Important distinction:

- The backend-only watcher/sharding source parity commit did not require a CodeMagic/iOS app build.
- This emergency-contact consent UI/security change does require a CodeMagic/iOS app build because it changes installed Flutter/iOS app behavior.

## iOS Testing Checklist

1. Open Emergency Contacts.
2. Add or use an emergency contact.
3. Tap `Send Confirmation Link`.
4. Confirm the app does not open Messages.
5. Confirm no consent link/token appears in user-visible UI.
6. Confirm the button changes in-place to `Confirmation Link Sent` with a check icon.
7. Confirm the button returns to `Resend Confirmation Link` after about 5 seconds.
8. Confirm the emergency contact receives the Decoy Support SMS with the real confirmation link.
9. Confirm tapping the contact's Decoy Support link still opens the consent form correctly.
10. Confirm the app updates contact status to `Pending`, then `Confirmed` after contact consent.

## Android Verification Already Completed

Android debug build installed on Pixel:

- `versionName 1.0.2`
- `versionCode 10002`
- installed timestamp: `2026-07-04 13:26:24`

Android checks:

- Debug build succeeded.
- Installed and launched on Pixel.
- No remaining SMS-launch or `CreateConsentRequestCall.link(...)` exposure in the Android emergency contacts screen.
- Mitchell tested the flow through and confirmed it works perfectly.

