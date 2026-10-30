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
    // Keep the initiating PIN page mounted and visible while preparation runs.
    // Its Enter button owns the progress indicator and failure recovery.
    return AbsorbPointer(
      key: const ValueKey('pin-input-presentation'),
      absorbing: active,
      child: ExcludeSemantics(
        excluding: active,
        child: child,
      ),
    );
  }
}
