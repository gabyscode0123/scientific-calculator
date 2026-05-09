import 'package:flutter/material.dart';

import '../controllers/calculator_controller.dart';
import '../widgets/calculator_display.dart';
import '../widgets/calculator_header.dart';
import '../widgets/calculator_keypad.dart';

class ScientificCalculatorScreen extends StatefulWidget {
  const ScientificCalculatorScreen({super.key});

  @override
  State<ScientificCalculatorScreen> createState() =>
      _ScientificCalculatorScreenState();
}

class _ScientificCalculatorScreenState
    extends State<ScientificCalculatorScreen> {
  final CalculatorController _controller = CalculatorController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFB7C8),
              Color(0xFFFFC3A0),
              Color(0xFFFFF1A8),
              Color(0xFFB8D8FF),
              Color(0xFFD8C7FF),
            ],
            stops: [0, 0.24, 0.5, 0.76, 1],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return Column(
                      children: [
                        CalculatorHeader(
                          angleMode: _controller.angleMode,
                          onToggleAngleMode: _controller.toggleAngleMode,
                        ),
                        const SizedBox(height: 12),
                        CalculatorDisplay(
                          expression: _controller.expressionLabel,
                          value: _controller.displayValue,
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: CalculatorKeypad(
                            onInput: _controller.handleInput,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
