import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';

/// Fits translated banner copy while keeping the existing condensed lettering.
class LocalizedBannerLabel extends StatelessWidget {
  const LocalizedBannerLabel(this.text, {super.key, this.fontSize = 48});

  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    Widget label() => Text(
          text,
          textAlign: TextAlign.center,
          softWrap: false,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'DECOY BEBAS',
                color: FlutterFlowTheme.of(context).info,
                fontSize: fontSize,
                letterSpacing: 0,
                lineHeight: 1.05,
                fontWeight: FontWeight.normal,
              ),
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Stack(
          alignment: Alignment.center,
          children: [
            label(),
            for (final dx in [-0.35, 0.35])
              ExcludeSemantics(
                child:
                    Transform.translate(offset: Offset(dx, 0), child: label()),
              ),
          ],
        ),
      ),
    );
  }
}
