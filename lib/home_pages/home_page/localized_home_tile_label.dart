import 'package:auto_size_text/auto_size_text.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';

/// Fits translated labels within the unchanged home tile dimensions.
class LocalizedHomeTileLabel extends StatelessWidget {
  const LocalizedHomeTileLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final style = FlutterFlowTheme.of(context).titleMedium.override(
          fontFamily: 'DECOY BEBAS',
          color: FlutterFlowTheme.of(context).info,
          fontSize: 42,
          letterSpacing: 0,
          fontWeight: FontWeight.normal,
        );
    Widget label() => Center(
          child: AutoSizeText(
            text,
            style: style,
            textAlign: TextAlign.center,
            textDirection: Directionality.of(context),
            locale: locale,
            maxLines: 2,
            minFontSize: 12,
            maxFontSize: 42,
            stepGranularity: 0.5,
            wrapWords: const {'ja', 'ko', 'zh'}.contains(locale.languageCode),
          ),
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Stack(
        fit: StackFit.expand,
        children: [
          label(),
          for (final dx in [-0.35, 0.35])
            ExcludeSemantics(
              child: Transform.translate(
                offset: Offset(dx, 0),
                child: label(),
              ),
            ),
        ],
      ),
    );
  }
}
