import '/l10n/app_localizations.dart';
import '/l10n/language_picker.dart';
import '/components/localized_banner_label.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/build_provenance.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'settings_model.dart';
export 'settings_model.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key});

  static String routeName = 'Settings';
  static String routePath = '/settings';

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  late SettingsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SettingsModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).height < 780.0;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: PopScope(
        canPop: false,
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: ClampingScrollPhysics(),
              ),
              padding: EdgeInsets.only(bottom: compact ? 24.0 : 36.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildBackButton(context, compact),
                      _buildTitle(context),
                      SizedBox(height: compact ? 22.0 : 30.0),
                      _SettingsSection(
                        label: AppLocalizations.of(context)!.msgAccount,
                        children: [
                          _SettingsTile(
                            icon: Icons.language_rounded,
                            label: AppLocalizations.of(context)!.msgLanguage,
                            onTap: () => showLanguagePicker(context),
                          ),
                          _SettingsTile(
                            icon: Icons.pin_rounded,
                            label: AppLocalizations.of(context)!.msgChangeAccountEntryPin,
                            onTap: () async =>
                                context.pushNamed(ChangePinWidget.routeName),
                          ),
                          _SettingsTile(
                            icon: Icons.workspace_premium_rounded,
                            label: AppLocalizations.of(context)!.msgMySubscription,
                            onTap: _openSubscription,
                          ),
                          _SettingsTile(
                            icon: Icons.currency_bitcoin_rounded,
                            label: AppLocalizations.of(context)!.msgConfigureBitcoinBalance,
                            onTap: () async => context.pushNamed(
                              ConfigureBitcoinBalanceWidget.routeName,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18.0),
                      _SettingsSection(
                        label: AppLocalizations.of(context)!.msgSafetySupport,
                        children: [
                          _SettingsTile(
                            icon: Icons.tune_rounded,
                            label: AppLocalizations.of(context)!.msgControlCenter,
                            onTap: () async => context
                                .pushNamed(ControlCenterWidget.routeName),
                          ),
                          _SettingsTile(
                            icon: Icons.support_agent_rounded,
                            label: AppLocalizations.of(context)!.msgContactUs,
                            onTap: () async => context
                                .pushNamed(SupportTicketWidget.routeName),
                          ),
                          _SettingsTile(
                            icon: Icons.play_circle_outline_rounded,
                            label: AppLocalizations.of(context)!.msgTutorials,
                            onTap: () async =>
                                context.pushNamed(TutorialsWidget.routeName),
                          ),
                          _SettingsTile(
                            icon: Icons.language_rounded,
                            label: AppLocalizations.of(context)!.msgWebsite,
                            onTap: () async => launchURL(
                              'https://www.decoywalletapp.com',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18.0),
                      _SettingsSection(
                        label: AppLocalizations.of(context)!.msgLegal,
                        children: [
                          _SettingsTile(
                            icon: Icons.privacy_tip_outlined,
                            label: AppLocalizations.of(context)!.msgPrivacyPolicy,
                            onTap: () async => context
                                .pushNamed(PrivacyPolicyWidget.routeName),
                          ),
                          _SettingsTile(
                            icon: Icons.description_outlined,
                            label: AppLocalizations.of(context)!.msgTermsConditions,
                            onTap: () async =>
                                context.pushNamed(TermsofUseWidget.routeName),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: _SettingsTile(
                          icon: Icons.delete_outline_rounded,
                          label: AppLocalizations.of(context)!.msgDeleteUserAccount,
                          isDestructive: true,
                          standalone: true,
                          onTap: () async => context
                              .pushNamed(DeleteUserAccountWidget.routeName),
                        ),
                      ),
                      SizedBox(height: compact ? 22.0 : 30.0),
                      _buildSocialLinks(context),
                      const SizedBox(height: 20.0),
                      _buildLogOut(context),
                      const SizedBox(height: 12.0),
                      _buildCompactSourceVerification(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context, bool compact) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(left: 12.0, top: compact ? 2.0 : 8.0),
        child: FlutterFlowIconButton(
          borderColor: Colors.transparent,
          borderRadius: 30.0,
          buttonSize: 46.0,
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF15161E),
            size: 25.0,
          ),
          onPressed: () async => context.safePop(),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final title = AppLocalizations.of(context)!.msgSettings;
    final keepEnglishLayout =
        Localizations.localeOf(context).languageCode == 'en';
    final titleStyle = FlutterFlowTheme.of(context).bodyMedium.override(
          fontFamily: 'DECOY BEBAS',
          color: FlutterFlowTheme.of(context).info,
          fontSize: 52.0,
          letterSpacing: 0.8,
          fontWeight: FontWeight.normal,
          lineHeight: 1.05,
        );

    return LayoutBuilder(builder: (context, constraints) {
      var blockWidth = 190.0;
      if (!keepEnglishLayout) {
        final measurement = TextPainter(
          text: TextSpan(
              text: title, style: titleStyle.copyWith(letterSpacing: 0)),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
          maxLines: 1,
        )..layout();
        final maximumWidth =
            (constraints.maxWidth - 40).clamp(0.0, double.infinity);
        blockWidth = (measurement.width + 32)
            .clamp(190.0.clamp(0.0, maximumWidth), maximumWidth);
        measurement.dispose();
      }
      return Align(
        alignment: Alignment.center,
        child: Material(
          color: Colors.transparent,
          elevation: 3.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            key: const ValueKey('settings-title-block'),
            width: blockWidth,
            height: 71.0,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primary,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: keepEnglishLayout
                ? Stack(
                    children: [
                      Align(
                        alignment: const Alignment(0.05, 0.0),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Text(AppLocalizations.of(context)!.msgSettings,
                              style: titleStyle),
                        ),
                      ),
                      Align(
                        alignment: const Alignment(-0.05, 0.0),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Text(AppLocalizations.of(context)!.msgSettings,
                              style: titleStyle),
                        ),
                      ),
                    ],
                  )
                : LocalizedBannerLabel(title, fontSize: 52),
          ),
        ),
      );
    });
  }

  Future<void> _openSubscription() async {
    _model.settingsQue = await UserEntitlementsTable().queryRows(
      queryFn: (q) => q
          .eqOrNull('user_id', currentUserUid)
          .eqOrNull('entitlement', 'decoy_wallet'),
    );
    if (!mounted) return;

    final entitlement = _model.settingsQue?.firstOrNull;
    if (entitlement?.isActive == true) {
      context.pushNamed(ManageSubscriptionWidget.routeName);
    } else {
      context.pushNamed(SubscriptionOptionsWidget.routeName);
    }
    safeSetState(() {});
  }

  Widget _buildSocialLinks(BuildContext context) {
    return Column(
      children: [
         Text(
          AppLocalizations.of(context)!.msgFollowDecoyWallet,
          style: TextStyle(
            color: Color(0xFF69717D),
            fontSize: 11.0,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12.0),
        Wrap(
          alignment: WrapAlignment.center,
          runSpacing: 14.0,
          children: [
            _SocialButton(
              tooltip: 'Nostr',
              onTap: () => launchURL(
                'https://primal.net/p/nprofile1qqsywp6yr7r4aemlalupwmluj953tr6dh8tujw77w6dt9k4p2gn9m2cte4kqn',
              ),
              child: Image.asset(
                'assets/images/nostr-logo.png',
                width: 36.0,
                height: 36.0,
                fit: BoxFit.cover,
              ),
            ),
            _SocialButton(
              tooltip: AppLocalizations.of(context)!.msgRumble,
              onTap: () => launchURL('https://rumble.com/user/DecoyWalletApp'),
              child: Image.asset('assets/images/rumble.jpg'),
            ),
            _SocialButton(
              tooltip: AppLocalizations.of(context)!.msgYoutube,
              onTap: () => launchURL(
                'https://youtube.com/@decoywalletapp?si=p67QJDUJx2ArQbvL',
              ),
              child: Container(
                width: 36.0,
                height: 25.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF0000),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: const Center(
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 22.0,
                  ),
                ),
              ),
            ),
            _SocialButton(
              tooltip: AppLocalizations.of(context)!.msgInstagram,
              onTap: () => launchURL(
                'https://www.instagram.com/decoywalletapp/',
              ),
              child: Container(
                width: 36.0,
                height: 36.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9.0),
                  gradient: const LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [
                      Color(0xFFFFD35A),
                      Color(0xFFFF3D57),
                      Color(0xFFC13584),
                      Color(0xFF5851DB),
                    ],
                  ),
                ),
                child: const Center(
                  child: FaIcon(
                    FontAwesomeIcons.instagram,
                    color: Colors.white,
                    size: 25.0,
                  ),
                ),
              ),
            ),
            _SocialButton(
              tooltip: 'X',
              onTap: () => launchURL('https://x.com/decoywalletapp?s=21'),
              child: Image.asset('assets/images/xlogo.png'),
            ),
            _SocialButton(
              tooltip: 'GitHub',
              onTap: () => launchURL(
                'https://github.com/decoywalletapp/decoy-wallet-open-source',
              ),
              child: const FaIcon(
                FontAwesomeIcons.github,
                color: Color(0xFF161B22),
                size: 34.0,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLogOut(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: SizedBox(
        height: 48.0,
        child: OutlinedButton.icon(
          onPressed: () async {
            GoRouter.of(context).prepareAuthEvent();
            await authManager.signOut();
            GoRouter.of(context).clearRedirectLocation();
            if (!context.mounted) return;
            context.goNamedAuth(LoginPageWidget.routeName, context.mounted);
          },
          icon: Icon(
            Icons.logout_rounded,
            size: 20.0,
            color: FlutterFlowTheme.of(context).primary,
          ),
          label: Text(
            AppLocalizations.of(context)!.msgLogOut,
            style: TextStyle(
              color: FlutterFlowTheme.of(context).primary,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: FlutterFlowTheme.of(context).primary,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactSourceVerification(BuildContext context) {
    final commitUrl = DecoyBuildProvenance.commitUrl;
    final sourceLine =
        'Source: ${DecoyBuildProvenance.sourceRef} @ ${DecoyBuildProvenance.shortCommit}';
    final buildLine = 'Version ${DecoyBuildProvenance.versionLabel}';
    final textStyle = FlutterFlowTheme.of(context).bodySmall.override(
          fontFamily: 'Inter',
          color: FlutterFlowTheme.of(context).secondaryText,
          fontSize: 9.0,
          letterSpacing: 0.0,
          lineHeight: 1.2,
        );

    return InkWell(
      onTap: commitUrl == null ? null : () async => launchURL(commitUrl),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            Text(
              sourceLine,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: textStyle,
            ),
            Text(
              buildLine,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: textStyle,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.label, required this.children});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final sectionChildren = <Widget>[];
    for (var index = 0; index < children.length; index++) {
      if (index > 0) {
        sectionChildren.add(const Divider(
          height: 1.0,
          thickness: 1.0,
          indent: 64.0,
          color: Color(0xFFE9EBEE),
        ));
      }
      sectionChildren.add(children[index]);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF69717D),
                fontSize: 11.0,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: const Color(0xFFE3E6EA)),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 10.0,
                  color: Color(0x12000000),
                  offset: Offset(0.0, 3.0),
                ),
              ],
            ),
            child: Column(children: sectionChildren),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
    this.standalone = false,
  });

  final IconData icon;
  final String label;
  final Future<void> Function() onTap;
  final bool isDestructive;
  final bool standalone;

  @override
  Widget build(BuildContext context) {
    final accent = isDestructive
        ? const Color(0xFFD90429)
        : FlutterFlowTheme.of(context).primary;

    final tile = Material(
      color: isDestructive ? const Color(0xFFFFF7F8) : Colors.transparent,
      borderRadius: BorderRadius.circular(8.0),
      child: InkWell(
        onTap: () => onTap(),
        borderRadius: BorderRadius.circular(8.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 58.0),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              children: [
                Container(
                  width: 36.0,
                  height: 36.0,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Icon(icon, color: accent, size: 21.0),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isDestructive
                          ? const Color(0xFFD90429)
                          : const Color(0xFF15161E),
                      fontFamily: 'InterTight',
                      fontSize: 17.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.0,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDestructive
                      ? const Color(0xFFD90429)
                      : const Color(0xFF7C8490),
                  size: 23.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (!standalone) return tile;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: const Color(0xFFFFCDD5)),
      ),
      child: tile,
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.tooltip,
    required this.onTap,
    required this.child,
  });

  final String tooltip;
  final Future<void> Function() onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7.0),
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.white,
          elevation: 1.5,
          borderRadius: BorderRadius.circular(8.0),
          child: InkWell(
            onTap: () => onTap(),
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              width: 48.0,
              height: 48.0,
              padding: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: const Color(0xFFE3E6EA)),
              ),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}
