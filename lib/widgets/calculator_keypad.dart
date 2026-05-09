import 'package:flutter/material.dart';

import '../models/calculator_button.dart';
import 'calculator_button.dart';

class CalculatorKeypad extends StatelessWidget {
  const CalculatorKeypad({required this.onInput, super.key});

  final ValueChanged<String> onInput;

  static const List<List<CalculatorKey>> _keys = [
    [
      CalculatorKey('AC', CalculatorButtonRole.destructive),
      CalculatorKey('DEL', CalculatorButtonRole.function),
      CalculatorKey('%', CalculatorButtonRole.function),
      CalculatorKey('÷', CalculatorButtonRole.operator),
    ],
    [
      CalculatorKey('sin', CalculatorButtonRole.function),
      CalculatorKey('cos', CalculatorButtonRole.function),
      CalculatorKey('tan', CalculatorButtonRole.function),
      CalculatorKey('×', CalculatorButtonRole.operator),
    ],
    [
      CalculatorKey('ln', CalculatorButtonRole.function),
      CalculatorKey('log', CalculatorButtonRole.function),
      CalculatorKey('√', CalculatorButtonRole.function),
      CalculatorKey('-', CalculatorButtonRole.operator),
    ],
    [
      CalculatorKey('x²', CalculatorButtonRole.function),
      CalculatorKey('xʸ', CalculatorButtonRole.function),
      CalculatorKey('1/x', CalculatorButtonRole.function),
      CalculatorKey('+', CalculatorButtonRole.operator),
    ],
    [
      CalculatorKey('7', CalculatorButtonRole.digit),
      CalculatorKey('8', CalculatorButtonRole.digit),
      CalculatorKey('9', CalculatorButtonRole.digit),
      CalculatorKey('π', CalculatorButtonRole.function),
    ],
    [
      CalculatorKey('4', CalculatorButtonRole.digit),
      CalculatorKey('5', CalculatorButtonRole.digit),
      CalculatorKey('6', CalculatorButtonRole.digit),
      CalculatorKey('e', CalculatorButtonRole.function),
    ],
    [
      CalculatorKey('1', CalculatorButtonRole.digit),
      CalculatorKey('2', CalculatorButtonRole.digit),
      CalculatorKey('3', CalculatorButtonRole.digit),
      CalculatorKey('+/-', CalculatorButtonRole.function),
    ],
    [
      CalculatorKey('0', CalculatorButtonRole.digit, flex: 2),
      CalculatorKey('.', CalculatorButtonRole.digit),
      CalculatorKey('=', CalculatorButtonRole.primary),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in _keys)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  for (final key in row)
                    Expanded(
                      flex: key.flex,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: CalculatorButton(
                          label: key.label,
                          role: key.role,
                          onPressed: () => onInput(key.label),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
