import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

class WalletFeaturePreviewWidget extends StatelessWidget {
  const WalletFeaturePreviewWidget({
    super.key,
    required this.feature,
  });

  static String routeName = 'WalletFeaturePreview';
  static String routePath = '/wallet-feature-preview';

  final String feature;

  static const _background = Color(0xFF080C0D);
  static const _panel = Color(0xFF121819);
  static const _border = Color(0xFF263032);
  static const _muted = Color(0xFF929A9D);
  static const _orange = Color(0xFFF7931A);

  _FeatureContent get _content {
    switch (feature) {
      case 'limit-order':
        return const _FeatureContent(
          title: 'Limit Order',
          subtitle: 'Choose a target price for your next Bitcoin purchase.',
          icon: Icons.stars_rounded,
          sectionTitle: 'Order details',
          rows: [
            ('Order type', 'Buy'),
            ('Asset', 'Bitcoin'),
            ('Settlement', 'USD balance'),
          ],
        );
      case 'bitcoin-pay':
        return const _FeatureContent(
          title: 'Bitcoin Pay',
          subtitle: 'Receive part of your paycheck directly in Bitcoin.',
          icon: Icons.account_balance_rounded,
          sectionTitle: 'Payment setup',
          rows: [
            ('Deposit asset', 'Bitcoin'),
            ('Frequency', 'Every payday'),
            ('Status', 'Not configured'),
          ],
        );
      case 'auto-withdraw':
        return const _FeatureContent(
          title: 'Auto Withdraw',
          subtitle: 'Automatically send purchased Bitcoin to your wallet.',
          icon: Icons.send_rounded,
          sectionTitle: 'Withdrawal settings',
          rows: [
            ('Asset', 'Bitcoin'),
            ('Network', 'Bitcoin Mainnet'),
            ('Status', 'Not configured'),
          ],
        );
      case 'recurring-buy':
      default:
        return const _FeatureContent(
          title: 'Recurring Buy',
          subtitle: 'Set a schedule for automatic Bitcoin purchases.',
          icon: Icons.edit_calendar_rounded,
          sectionTitle: 'Purchase schedule',
          rows: [
            ('Asset', 'Bitcoin'),
            ('Frequency', 'Not selected'),
            ('Payment method', 'Not selected'),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = _content;
    return Scaffold(
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
                      child:
                          Icon(content.icon, color: Colors.white, size: 36.0),
                    ),
                  ),
                  const SizedBox(height: 22.0),
                  Text(
                    content.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    content.subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 14.0,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 38.0),
                  Text(
                    content.sectionTitle.toUpperCase(),
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 11.0,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 9.0),
                  Container(
                    decoration: BoxDecoration(
                      color: _panel,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: _border),
                    ),
                    child: Column(
                      children: [
                        for (var index = 0;
                            index < content.rows.length;
                            index++) ...[
                          if (index > 0)
                            const Divider(height: 1.0, color: _border),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 17.0,
                              vertical: 17.0,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    content.rows[index].$1,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Text(
                                  content.rows[index].$2,
                                  style: const TextStyle(
                                    color: _muted,
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 22.0),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF101617),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: _border),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            color: _orange, size: 21.0),
                        SizedBox(width: 11.0),
                        Expanded(
                          child: Text(
                            'Complete the required details to continue.',
                            style: TextStyle(
                              color: _muted,
                              fontSize: 13.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureContent {
  const _FeatureContent({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.sectionTitle,
    required this.rows,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String sectionTitle;
  final List<(String, String)> rows;
}
