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

import '/flutter_flow/custom_functions.dart';
// DO NOT REMOVE THE BLOCK ABOVE

// Extra imports
import 'package:app_links/app_links.dart';
import 'dart:async';

class DeepLinkProbe extends StatefulWidget {
  const DeepLinkProbe({Key? key}) : super(key: key);

  @override
  State<DeepLinkProbe> createState() => _DeepLinkProbeState();
}

class _DeepLinkProbeState extends State<DeepLinkProbe> {
  AppLinks? _appLinks;
  StreamSubscription<Uri>? _sub;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _appLinks = AppLinks();

    // 1) Link that launched the app (cold start)
    try {
      final uri = await _appLinks!.getInitialLink();
      if (uri != null) _report('initial', uri);
    } catch (e) {
      _toast('Probe error (initial): $e');
    }

    // 2) Links while the app is running
    _sub = _appLinks!.uriLinkStream.listen(
      (uri) => _report('stream', uri),
      onError: (e) => _toast('Probe error (stream): $e'),
    );
  }

  void _report(String source, Uri uri) {
    final qp = uri.queryParameters;
    final tokenHash = qp['token_hash'] ?? qp['tokenHash'];
    final t = qp['type'];
    debugPrint(
        '[PROBE][$source] uri=$uri  host=${uri.host}  path=${uri.path}  token=$tokenHash  type=$t');

    final msg =
        '[$source]\n$uri\nhost=${uri.host}\npath=${uri.path}\ntoken=${tokenHash ?? '-'}\ntype=${t ?? '-'}';
    _toast(msg);
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 4)),
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
