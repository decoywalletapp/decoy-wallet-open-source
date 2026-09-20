import '/auth/supabase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'duress_settings_page_model.dart';
export 'duress_settings_page_model.dart';

class DuressSettingsPageWidget extends StatefulWidget {
  const DuressSettingsPageWidget({super.key});

  static String routeName = 'DuressSettingsPage';
  static String routePath = '/duressSettingsPage';

  @override
  State<DuressSettingsPageWidget> createState() =>
      _DuressSettingsPageWidgetState();
}

class _DuressSettingsPageWidgetState extends State<DuressSettingsPageWidget> {
  late DuressSettingsPageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const _background = Color(0xFF080C0D);
  static const _panel = Color(0xFF121819);
  static const _border = Color(0xFF263032);
  static const _muted = Color(0xFF929A9D);
  static const _orange = Color(0xFFFF5A00);

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DuressSettingsPageModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _logOut() async {
    GoRouter.of(context).prepareAuthEvent();
    await authManager.signOut();
    GoRouter.of(context).clearRedirectLocation();
    if (mounted) {
      context.goNamedAuth(LoginPageWidget.routeName, context.mounted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: _background,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 28.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FlutterFlowIconButton(
                        borderColor: _border,
                        borderRadius: 8.0,
                        borderWidth: 1.0,
                        buttonSize: 42.0,
                        fillColor: _panel,
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 23.0,
                        ),
                        onPressed: () async => context.safePop(),
                      ),
                    ),
                    const SizedBox(height: 34.0),
                    Align(
                      child: Container(
                        width: 76.0,
                        height: 76.0,
                        decoration: BoxDecoration(
                          color: _orange,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 18.0,
                              color: Color(0x42000000),
                              offset: Offset(0.0, 9.0),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.settings_rounded,
                          color: Colors.white,
                          size: 38.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22.0),
                    Text(
                      'Settings',
                      textAlign: TextAlign.center,
                      style:
                          FlutterFlowTheme.of(context).headlineMedium.override(
                                fontFamily: 'InterTight',
                                color: Colors.white,
                                fontSize: 31.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w800,
                              ),
                    ),
                    const SizedBox(height: 8.0),
                    const Text(
                      'Manage your wallet preferences and session.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _muted,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 34.0),
                    _sectionLabel('WALLET'),
                    const SizedBox(height: 9.0),
                    _settingsPanel([
                      _settingsRow(
                        icon: Icons.currency_bitcoin_rounded,
                        title: 'Currency',
                        value: 'Bitcoin',
                      ),
                      _settingsRow(
                        icon: Icons.hub_outlined,
                        title: 'Network',
                        value: 'Bitcoin Mainnet',
                      ),
                    ]),
                    const SizedBox(height: 24.0),
                    _sectionLabel('SECURITY'),
                    const SizedBox(height: 9.0),
                    _settingsPanel([
                      _settingsRow(
                        icon: Icons.lock_outline_rounded,
                        title: 'App lock',
                        value: 'Active',
                      ),
                      _settingsRow(
                        icon: Icons.smartphone_rounded,
                        title: 'Signed-in device',
                        value: 'This device',
                      ),
                    ]),
                    const SizedBox(height: 22.0),
                    SizedBox(
                      height: 56.0,
                      child: OutlinedButton.icon(
                        onPressed: _logOut,
                        icon: const Icon(Icons.logout_rounded, size: 21.0),
                        label: const Text('Log Out'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: _orange, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) => Text(
        label,
        style: const TextStyle(
          color: _muted,
          fontSize: 11.0,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w800,
        ),
      );

  Widget _settingsPanel(List<Widget> rows) => Container(
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: _border),
        ),
        child: Column(children: rows),
      );

  Widget _settingsRow({
    required IconData icon,
    required String title,
    required String value,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
        child: Row(
          children: [
            Container(
              width: 38.0,
              height: 38.0,
              decoration: BoxDecoration(
                color: const Color(0xFF202829),
                borderRadius: BorderRadius.circular(8.0),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: _orange, size: 21.0),
            ),
            const SizedBox(width: 13.0),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: _muted,
                fontSize: 13.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
}
