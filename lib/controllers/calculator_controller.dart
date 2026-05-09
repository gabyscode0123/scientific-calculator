import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../models/angle_mode.dart';

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
