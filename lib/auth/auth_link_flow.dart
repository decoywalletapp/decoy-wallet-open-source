import 'package:flutter/material.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/nav/nav.dart';
import 'auth_link_service.dart';
import '/l10n/app_localizations.dart';

final _emailConfirmations = <NavigatorState, Future<String?>>{};

Future<String?> _requestEmail(BuildContext context) {
  if (!context.mounted) return Future.value(null);
  final navigator = Navigator.of(context, rootNavigator: true);
  // Newer links reuse the intended recipient, but only the latest may commit.
  return _emailConfirmations.putIfAbsent(navigator, () {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _ConfirmLinkEmail(),
    ).whenComplete(() {
      _emailConfirmations.remove(navigator);
    });
  });
}

Future<AcceptedAuthLink?> acceptAuthLink(BuildContext context, Uri uri) {
  final unlock = AppStateNotifier.instance.unlock;
  final attempt = unlock.attempt;
  return SupaFlow.authLinks.accept(
    uri,
    mayContinue: () =>
        context.mounted &&
        !unlock.inDecoy &&
        (attempt == null || unlock.isCurrent(attempt)),
    requestEmail: () => _requestEmail(context),
  );
}

class _ConfirmLinkEmail extends StatefulWidget {
  const _ConfirmLinkEmail();
  @override
  State<_ConfirmLinkEmail> createState() => _ConfirmLinkEmailState();
}

class _ConfirmLinkEmailState extends State<_ConfirmLinkEmail> {
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _continue() {
    if (_email.text.trim().isNotEmpty) Navigator.of(context).pop(_email.text);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.msgEnterYourEmail),
        content: TextField(
          key: const ValueKey('auth-link-email'),
          controller: _email,
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autocorrect: false,
          enableSuggestions: false,
          decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.msgEmail),
          onSubmitted: (_) => _continue(),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.msgCancel)),
          TextButton(
              onPressed: _continue,
              child: Text(AppLocalizations.of(context)!.msgContinue)),
        ],
      );
}
