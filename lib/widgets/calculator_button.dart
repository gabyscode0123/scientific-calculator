import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/calculator_button.dart';

class CalculatorButton extends StatefulWidget {
  const CalculatorButton({
    required this.label,
    required this.role,
    required this.onPressed,
    super.key,
  });

  final String label;
  final CalculatorButtonRole role;
  final VoidCallback onPressed;

  @override
  State<CalculatorButton> createState() => _CalculatorButtonState();
}

class _CalculatorButtonState extends State<CalculatorButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = _ButtonColors.fromRole(widget.role);

    return Semantics(
      button: true,
      label: _semanticLabel(widget.label),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapCancel: () => setState(() => _isPressed = false),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 90),
          scale: _isPressed ? 0.97 : 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.background.withValues(
                    alpha: _isPressed ? colors.pressedOpacity : colors.opacity,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colors.border.withValues(alpha: 0.32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.shadow.withValues(alpha: 0.2),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: TextStyle(
                    color: colors.foreground,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _semanticLabel(String label) {
    return switch (label) {
      'DEL' => 'delete',
      'AC' => 'all clear',
      '×' => 'multiply',
      '÷' => 'divide',
      '√' => 'square root',
      'x²' => 'square',
      'xʸ' => 'power',
      '+/-' => 'toggle sign',
      _ => label,
    };
  }
}

class _ButtonColors {
  const _ButtonColors({
    required this.background,
    required this.foreground,
    required this.border,
    required this.shadow,
    required this.opacity,
    required this.pressedOpacity,
  });

  final Color background;
  final Color foreground;
  final Color border;
  final Color shadow;
  final double opacity;
  final double pressedOpacity;

  factory _ButtonColors.fromRole(CalculatorButtonRole role) {
    return switch (role) {
      CalculatorButtonRole.digit => const _ButtonColors(
        background: Color(0xFFFFFFFF),
        foreground: Color(0xFF2D2940),
        border: Color(0xFFFFFFFF),
        shadow: Color(0xFFFFC3A0),
        opacity: 0.56,
        pressedOpacity: 0.72,
      ),
      CalculatorButtonRole.function => const _ButtonColors(
        background: Color(0xFFFFFFFF),
        foreground: Color(0xFF2D2940),
        border: Color(0xFFFFFFFF),
        shadow: Color(0xFFFFC3A0),
        opacity: 0.46,
        pressedOpacity: 0.66,
      ),
      CalculatorButtonRole.operator => const _ButtonColors(
        background: Color(0xFFD86F46),
        foreground: Color(0xFF241008),
        border: Color(0xFFFFC3A0),
        shadow: Color(0xFF8F3F25),
        opacity: 0.9,
        pressedOpacity: 1,
      ),
      CalculatorButtonRole.destructive => const _ButtonColors(
        background: Color(0xFFC84F69),
        foreground: Color(0xFF230B12),
        border: Color(0xFFFFB7C8),
        shadow: Color(0xFF873149),
        opacity: 0.88,
        pressedOpacity: 1,
      ),
      CalculatorButtonRole.primary => const _ButtonColors(
        background: Color(0xFF7D68C7),
        foreground: Color(0xFF140D2E),
        border: Color(0xFFD8C7FF),
        shadow: Color(0xFF56419B),
        opacity: 0.92,
        pressedOpacity: 1,
      ),
    };
  }
}
