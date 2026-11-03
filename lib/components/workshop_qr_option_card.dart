import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WorkshopQrOptionCard extends StatelessWidget {
  const WorkshopQrOptionCard({
    super.key,
    required this.onPressed,
    this.height = 260,
  });

  final Future<void> Function() onPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Material(
      color: Colors.transparent,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 350,
        height: height,
        decoration: BoxDecoration(
          color: theme.info,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.primary, width: 3),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: theme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.qr_code_scanner_rounded,
                  color: theme.info, size: 52),
            ),
            const SizedBox(height: 10),
            FFButtonWidget(
              onPressed: onPressed,
              text: 'Workshop QR',
              options: FFButtonOptions(
                width: 250,
                height: 50,
                padding: const EdgeInsets.all(8),
                color: theme.primary,
                textStyle: theme.titleMedium.override(
                  font: GoogleFonts.heebo(fontWeight: FontWeight.w600),
                  color: theme.info,
                  letterSpacing: 0,
                  fontWeight: FontWeight.w600,
                ),
                elevation: 3,
                borderSide: const BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
