import 'package:flutter/material.dart';

const double kAndroidBottomActionClearance = 72.0;

double decoyBottomActionPadding(
  BuildContext context, {
  double extra = 32.0,
}) {
  final mediaQuery = MediaQuery.of(context);
  final reportedBottomInset =
      mediaQuery.padding.bottom > mediaQuery.viewPadding.bottom
          ? mediaQuery.padding.bottom
          : mediaQuery.viewPadding.bottom;
  final bottomClearance =
      reportedBottomInset > 0.0 ? reportedBottomInset : 24.0;

  return bottomClearance + extra;
}

MediaQueryData withDecoyDisplayGuard(
  MediaQueryData mediaQuery,
  TargetPlatform platform,
) {
  final reportedBottomInset =
      mediaQuery.padding.bottom > mediaQuery.viewPadding.bottom
          ? mediaQuery.padding.bottom
          : mediaQuery.viewPadding.bottom;
  final bottomNavigationGuard = platform == TargetPlatform.android &&
          reportedBottomInset < kAndroidBottomActionClearance
      ? kAndroidBottomActionClearance
      : null;

  final guardedPadding = bottomNavigationGuard == null
      ? mediaQuery.padding
      : mediaQuery.padding.copyWith(bottom: bottomNavigationGuard);
  final guardedViewPadding = bottomNavigationGuard == null
      ? mediaQuery.viewPadding
      : mediaQuery.viewPadding.copyWith(bottom: bottomNavigationGuard);

  return mediaQuery.copyWith(
    boldText: false,
    padding: guardedPadding,
    textScaler: TextScaler.noScaling,
    viewPadding: guardedViewPadding,
  );
}

class DecoyDisplayGuard extends StatelessWidget {
  const DecoyDisplayGuard({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: withDecoyDisplayGuard(
        MediaQuery.of(context),
        Theme.of(context).platform,
      ),
      child: child,
    );
  }
}

class DecoyBottomSafeScroll extends StatelessWidget {
  const DecoyBottomSafeScroll({
    super.key,
    required this.child,
    this.bottomPadding,
    this.extraBottomPadding = 32.0,
  });

  final Widget child;
  final double? bottomPadding;
  final double extraBottomPadding;

  @override
  Widget build(BuildContext context) {
    final effectiveBottomPadding = bottomPadding ??
        decoyBottomActionPadding(
          context,
          extra: extraBottomPadding,
        );

    return LayoutBuilder(
      builder: (context, constraints) {
        final minimumHeight = constraints.hasBoundedHeight &&
                constraints.maxHeight > effectiveBottomPadding
            ? constraints.maxHeight - effectiveBottomPadding
            : 0.0;

        return SingleChildScrollView(
          primary: false,
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(),
          ),
          padding: EdgeInsetsDirectional.fromSTEB(
            0.0,
            0.0,
            0.0,
            effectiveBottomPadding,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minimumHeight),
            child: IntrinsicHeight(child: child),
          ),
        );
      },
    );
  }
}
