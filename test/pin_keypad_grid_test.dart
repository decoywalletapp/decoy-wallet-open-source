import 'package:decoy_wallet_app/components/pin_keypad_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final direction in TextDirection.values) {
    testWidgets('PIN digits keep their positions and values in $direction',
        (tester) async {
      final pressed = <String>[];
      await tester.pumpWidget(MaterialApp(
        home: Directionality(
          textDirection: direction,
          child: Scaffold(
            body: SizedBox(
              width: 300,
              height: 400,
              child: PinKeypadGrid(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3),
                children: [
                  for (final digit in [
                    '1',
                    '2',
                    '3',
                    '4',
                    '5',
                    '6',
                    '7',
                    '8',
                    '9'
                  ])
                    TextButton(
                      onPressed: () => pressed.add(digit),
                      child: Text(digit),
                    ),
                ],
              ),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      for (final row in ['123', '456', '789']) {
        expect(tester.getCenter(find.text(row[0])).dx,
            lessThan(tester.getCenter(find.text(row[1])).dx));
        expect(tester.getCenter(find.text(row[1])).dx,
            lessThan(tester.getCenter(find.text(row[2])).dx));
      }
      for (final digit in ['9', '8', '7', '6']) {
        await tester.tap(find.text(digit));
      }
      expect(pressed.join(), '9876');
      expect(tester.takeException(), isNull);
    });
  }
}
