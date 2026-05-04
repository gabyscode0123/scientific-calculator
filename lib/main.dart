import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

enum AngleMode { degrees, radians }

enum CalculatorButtonRole { digit, function, operator, destructive, primary }

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F7CFF),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const ScientificCalculatorScreen(),
    );
  }
}

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
        child: Stack(
          children: [
            SafeArea(
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
                            _CalculatorHeader(
                              angleMode: _controller.angleMode,
                              onToggleAngleMode: _controller.toggleAngleMode,
                            ),
                            const SizedBox(height: 12),
                            _CalculatorDisplay(
                              expression: _controller.expressionLabel,
                              value: _controller.displayValue,
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: _CalculatorKeypad(
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
          ],
        ),
      ),
    );
  }
}

class CalculatorController extends ChangeNotifier {
  String _display = '0';
  String _expression = '';
  double? _storedValue;
  String? _pendingOperator;
  bool _replaceOnNextDigit = true;
  bool _hasError = false;
  AngleMode _angleMode = AngleMode.degrees;

  String get displayValue => _display;
  String get expressionLabel => _expression;
  AngleMode get angleMode => _angleMode;

  void handleInput(String value) {
    if (RegExp(r'^\d$').hasMatch(value)) {
      _enterDigit(value);
      return;
    }

    switch (value) {
      case '.':
        _enterDecimal();
      case 'AC':
        _clear();
      case 'DEL':
        _delete();
      case '+/-':
        _toggleSign();
      case '+':
      case '-':
      case '×':
      case '÷':
      case 'xʸ':
        _setOperator(value);
      case '=':
        _calculate();
      case '%':
        _applyPercent();
      case 'sin':
      case 'cos':
      case 'tan':
      case 'ln':
      case 'log':
      case '√':
      case 'x²':
      case '1/x':
        _applyFunction(value);
      case 'π':
        _setConstant(math.pi, 'π');
      case 'e':
        _setConstant(math.e, 'e');
    }
  }

  void toggleAngleMode() {
    _angleMode = _angleMode == AngleMode.degrees
        ? AngleMode.radians
        : AngleMode.degrees;
    notifyListeners();
  }

  void _enterDigit(String digit) {
    if (_hasError) {
      _clear(silent: true);
    }

    if (_replaceOnNextDigit || _display == '0') {
      _display = digit;
      _replaceOnNextDigit = false;
    } else if (_display.length < 18) {
      _display += digit;
    }

    notifyListeners();
  }

  void _enterDecimal() {
    if (_hasError) {
      _clear(silent: true);
    }

    if (_replaceOnNextDigit) {
      _display = '0.';
      _replaceOnNextDigit = false;
    } else if (!_display.contains('.')) {
      _display += '.';
    }

    notifyListeners();
  }

  void _setOperator(String operator) {
    if (_hasError) {
      _clear(silent: true);
      notifyListeners();
      return;
    }

    if (_pendingOperator != null && !_replaceOnNextDigit) {
      _calculate(silent: true);
      if (_hasError) {
        notifyListeners();
        return;
      }
    }

    _storedValue = _currentValue;
    _pendingOperator = operator;
    _expression = '${_formatNumber(_storedValue!)} $operator';
    _replaceOnNextDigit = true;
    notifyListeners();
  }

  void _calculate({bool silent = false}) {
    if (_pendingOperator == null || _storedValue == null || _hasError) {
      return;
    }

    final secondValue = _currentValue;
    final firstValue = _storedValue!;
    final operator = _pendingOperator!;
    final result = _calculateBinary(firstValue, secondValue, operator);

    if (result == null || result.isNaN || result.isInfinite) {
      _showError();
    } else {
      _display = _formatNumber(result);
      _expression =
          '${_formatNumber(firstValue)} $operator ${_formatNumber(secondValue)} =';
      _storedValue = null;
      _pendingOperator = null;
      _replaceOnNextDigit = true;
    }

    if (!silent) notifyListeners();
  }

  double? _calculateBinary(double first, double second, String operator) {
    return switch (operator) {
      '+' => first + second,
      '-' => first - second,
      '×' => first * second,
      '÷' => second == 0 ? null : first / second,
      'xʸ' => math.pow(first, second).toDouble(),
      _ => null,
    };
  }

  void _applyFunction(String function) {
    if (_hasError) {
      _clear(silent: true);
      notifyListeners();
      return;
    }

    final input = _currentValue;
    final result = switch (function) {
      'sin' => math.sin(_angleToRadians(input)),
      'cos' => math.cos(_angleToRadians(input)),
      'tan' => _tan(input),
      'ln' => input <= 0 ? double.nan : math.log(input),
      'log' => input <= 0 ? double.nan : math.log(input) / math.ln10,
      '√' => input < 0 ? double.nan : math.sqrt(input),
      'x²' => input * input,
      '1/x' => input == 0 ? double.nan : 1 / input,
      _ => double.nan,
    };

    if (result.isNaN || result.isInfinite) {
      _showError();
    } else {
      _display = _formatNumber(result);
      _expression = '$function(${_formatNumber(input)})';
      _replaceOnNextDigit = true;
    }

    notifyListeners();
  }

  void _applyPercent() {
    if (_hasError) {
      _clear(silent: true);
    }

    final result = _currentValue / 100;
    _display = _formatNumber(result);
    _expression = '${_formatNumber(_currentValue)}%';
    _replaceOnNextDigit = true;
    notifyListeners();
  }

  void _setConstant(double value, String label) {
    if (_hasError) {
      _clear(silent: true);
    }

    _display = _formatNumber(value);
    _expression = label;
    _replaceOnNextDigit = false;
    notifyListeners();
  }

  void _toggleSign() {
    if (_hasError || _display == '0') return;

    _display = _display.startsWith('-') ? _display.substring(1) : '-$_display';
    notifyListeners();
  }

  void _delete() {
    if (_hasError || _replaceOnNextDigit || _display.length <= 1) {
      _display = '0';
      _hasError = false;
      _replaceOnNextDigit = true;
    } else {
      _display = _display.substring(0, _display.length - 1);
      if (_display == '-') _display = '0';
    }

    notifyListeners();
  }

  void _clear({bool silent = false}) {
    _display = '0';
    _expression = '';
    _storedValue = null;
    _pendingOperator = null;
    _replaceOnNextDigit = true;
    _hasError = false;

    if (!silent) notifyListeners();
  }

  void _showError() {
    _display = 'Error';
    _expression = 'Invalid operation';
    _storedValue = null;
    _pendingOperator = null;
    _replaceOnNextDigit = true;
    _hasError = true;
  }

  double _tan(double value) {
    final radians = _angleToRadians(value);
    final cosine = math.cos(radians);
    if (cosine.abs() < 1e-12) return double.nan;

    return math.sin(radians) / cosine;
  }

  double _angleToRadians(double value) {
    return _angleMode == AngleMode.degrees ? value * math.pi / 180 : value;
  }

  double get _currentValue => double.tryParse(_display) ?? 0;

  String _formatNumber(double value) {
    if (value == 0) return '0';

    final rounded = value.abs() < 1e-10 ? 0.0 : value;
    if (rounded == 0) return '0';

    if (rounded.abs() >= 1e10 || rounded.abs() < 1e-6) {
      return _formatScientificNotation(rounded);
    }

    final fixed = rounded.toStringAsFixed(10);
    final compact = fixed.replaceAll(RegExp(r'\.?0+$'), '');

    return compact.length > 12 ? _formatScientificNotation(rounded) : compact;
  }

  String _formatScientificNotation(double value) {
    return value
        .toStringAsExponential(10)
        .replaceAll(RegExp(r'\.?0+e'), 'e')
        .replaceAll('e+', 'e');
  }
}

class _CalculatorHeader extends StatelessWidget {
  const _CalculatorHeader({
    required this.angleMode,
    required this.onToggleAngleMode,
  });

  final AngleMode angleMode;
  final VoidCallback onToggleAngleMode;

  @override
  Widget build(BuildContext context) {
    final isDegrees = angleMode == AngleMode.degrees;

    return Row(
      children: [
        const Spacer(),
        Tooltip(
          message: isDegrees ? 'Switch to radians' : 'Switch to degrees',
          child: TextButton(
            onPressed: onToggleAngleMode,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF2D2940),
              backgroundColor: Colors.white.withValues(alpha: 0.48),
              minimumSize: const Size(58, 38),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.72)),
              ),
            ),
            child: Text(
              isDegrees ? 'DEG' : 'RAD',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CalculatorDisplay extends StatelessWidget {
  const _CalculatorDisplay({required this.expression, required this.value});

  final String expression;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 20),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(
              height: 24,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Text(
                  expression,
                  key: const ValueKey('calculator-expression'),
                  style: TextStyle(
                    color: const Color(0xFF4A5366).withValues(alpha: 0.78),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  value,
                  key: const ValueKey('calculator-display'),
                  maxLines: 1,
                  style: const TextStyle(
                    color: Color(0xFF20283A),
                    fontSize: 52,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                    height: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalculatorKeypad extends StatelessWidget {
  const _CalculatorKeypad({required this.onInput});

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
                        child: _CalculatorButton(
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

class _CalculatorButton extends StatefulWidget {
  const _CalculatorButton({
    required this.label,
    required this.role,
    required this.onPressed,
  });

  final String label;
  final CalculatorButtonRole role;
  final VoidCallback onPressed;

  @override
  State<_CalculatorButton> createState() => _CalculatorButtonState();
}

class _CalculatorButtonState extends State<_CalculatorButton> {
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

class CalculatorKey {
  const CalculatorKey(this.label, this.role, {this.flex = 1});

  final String label;
  final CalculatorButtonRole role;
  final int flex;
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
