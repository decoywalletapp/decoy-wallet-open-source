import 'package:flutter/material.dart';

/// Numeric key positions stay stable when the surrounding page is right-to-left.
class PinKeypadGrid extends StatelessWidget {
  const PinKeypadGrid({
    super.key,
    required this.children,
    required this.gridDelegate,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.scrollDirection = Axis.vertical,
  });

  final List<Widget> children;
  final SliverGridDelegate gridDelegate;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final Axis scrollDirection;

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.ltr,
        child: GridView(
          padding: padding,
          physics: physics,
          gridDelegate: gridDelegate,
          shrinkWrap: shrinkWrap,
          scrollDirection: scrollDirection,
          children: children,
        ),
      );
}
