import '/components/wallet_title_splash.dart';
import 'package:flutter/material.dart';

class PinUnlockHandoff extends StatelessWidget {
  const PinUnlockHandoff({
    super.key,
    required this.active,
    required this.child,
  });

  final bool active;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: active ? 1 : 0),
      duration: reduceMotion || !active
          ? Duration.zero
          : const Duration(milliseconds: 320),
      child: child,
      builder: (context, progress, child) => Stack(
        fit: StackFit.expand,
        children: [
          // Retain the initiating PIN state; only its presentation fades.
          AbsorbPointer(
            key: const ValueKey('pin-input-presentation'),
            absorbing: active,
            child: ExcludeSemantics(
              excluding: active,
              child: Opacity(
                key: const ValueKey('pin-input-opacity'),
                opacity: 1 -
                    const Interval(0, 0.45, curve: Curves.easeOutCubic)
                        .transform(progress),
                child: child,
              ),
            ),
          ),
          if (active)
            IgnorePointer(
              child: Opacity(
                key: const ValueKey('pin-title-opacity'),
                opacity: const Interval(0.3, 1, curve: Curves.easeInOutCubic)
                    .transform(progress),
                child: const SafeArea(
                  child: WalletTitleSplash(
                    key: ValueKey('pin-unlock-title'),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
