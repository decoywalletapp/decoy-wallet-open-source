import '/legal/legal_documents.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';

class LegalDocumentView extends StatelessWidget {
  const LegalDocumentView({
    super.key,
    required this.paragraphs,
    required this.fontSize,
    required this.lineHeight,
    required this.paragraphSpacing,
  });

  final List<LegalDocumentParagraph> paragraphs;
  final double fontSize;
  final double lineHeight;
  final double paragraphSpacing;

  @override
  Widget build(BuildContext context) {
    final baseStyle = FlutterFlowTheme.of(context).bodyMedium.override(
          fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
          fontSize: fontSize,
          letterSpacing: 0.0,
          lineHeight: lineHeight,
          useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
        );
    final boldStyle = baseStyle.copyWith(fontWeight: FontWeight.w700);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final paragraph in paragraphs)
          Padding(
            padding: EdgeInsets.only(bottom: paragraphSpacing),
            child: RichText(
              textAlign: paragraph.textAlign,
              text: TextSpan(
                style: baseStyle,
                children: [
                  if (paragraph.isBullet) TextSpan(text: '• '),
                  for (final run in paragraph.runs)
                    TextSpan(
                      text: run.text,
                      style: run.isBold ? boldStyle : baseStyle,
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
