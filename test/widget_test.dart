import 'package:calculator_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String displayValue(WidgetTester tester) {
    return tester
        .widget<Text>(find.byKey(const ValueKey('calculator-display')))
        .data!;
  }

  testWidgets('calculates a basic expression', (tester) async {
    await tester.pumpWidget(const CalculatorApp());

    await tester.tap(find.text('7'));
    await tester.tap(find.text('×'));
    await tester.tap(find.text('6'));
    await tester.tap(find.text('='));
    await tester.pumpAndSettle();

    expect(displayValue(tester), '42');
  });

  testWidgets('applies scientific functions', (tester) async {
    await tester.pumpWidget(const CalculatorApp());

    await tester.tap(find.text('9'));
    await tester.tap(find.text('√'));
    await tester.pumpAndSettle();

    expect(displayValue(tester), '3');
  });

  testWidgets('uses degrees for trig by default', (tester) async {
    await tester.pumpWidget(const CalculatorApp());

    await tester.tap(find.text('4'));
    await tester.tap(find.text('5'));
    await tester.tap(find.text('sin'));
    await tester.pumpAndSettle();

    expect(displayValue(tester), '0.7071067812');
  });

  testWidgets('uses radians when radian mode is selected', (tester) async {
    await tester.pumpWidget(const CalculatorApp());

    await tester.tap(find.text('DEG'));
    await tester.pumpAndSettle();
    expect(find.text('RAD'), findsOneWidget);
    await tester.tap(find.text('π'));
    await tester.tap(find.text('sin'));
    await tester.pumpAndSettle();

    expect(displayValue(tester), '0');
  });

  testWidgets('rejects undefined tangent values', (tester) async {
    await tester.pumpWidget(const CalculatorApp());

    await tester.tap(find.text('9'));
    await tester.tap(find.text('0').last);
    await tester.tap(find.text('tan'));
    await tester.pumpAndSettle();

    expect(displayValue(tester), 'Error');
  });
  testWidgets('keeps the rest of the scientific functions accurate', (
    tester,
  ) async {
    await tester.pumpWidget(const CalculatorApp());

    await tester.tap(find.text('6'));
    await tester.tap(find.text('0').last);
    await tester.tap(find.text('cos'));
    await tester.pumpAndSettle();
    expect(displayValue(tester), '0.5');

    await tester.tap(find.text('AC'));
    await tester.tap(find.text('1'));
    await tester.tap(find.text('0').last);
    await tester.tap(find.text('0').last);
    await tester.tap(find.text('log'));
    await tester.pumpAndSettle();
    expect(displayValue(tester), '2');

    await tester.tap(find.text('AC'));
    await tester.tap(find.text('e'));
    await tester.tap(find.text('ln'));
    await tester.pumpAndSettle();
    expect(displayValue(tester), '1');

    await tester.tap(find.text('AC'));
    await tester.tap(find.text('5'));
    await tester.tap(find.text('x²'));
    await tester.pumpAndSettle();
    expect(displayValue(tester), '25');

    await tester.tap(find.text('AC'));
    await tester.tap(find.text('4'));
    await tester.tap(find.text('1/x'));
    await tester.pumpAndSettle();
    expect(displayValue(tester), '0.25');

    await tester.tap(find.text('AC'));
    await tester.tap(find.text('1'));
    await tester.tap(find.text('0').last);
    await tester.tap(find.text('0').last);
    await tester.tap(find.text('%'));
    await tester.pumpAndSettle();
    expect(displayValue(tester), '1');
  });
  testWidgets('formats large results in scientific notation', (tester) async {
    await tester.pumpWidget(const CalculatorApp());

    await tester.tap(find.text('9'));
    await tester.tap(find.text('xʸ'));
    await tester.tap(find.text('1'));
    await tester.tap(find.text('2'));
    await tester.tap(find.text('='));
    await tester.pumpAndSettle();

    expect(displayValue(tester), '2.8242953648e11');
  });
}
