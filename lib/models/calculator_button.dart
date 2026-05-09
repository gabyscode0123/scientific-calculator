enum CalculatorButtonRole { digit, function, operator, destructive, primary }

class CalculatorKey {
  const CalculatorKey(this.label, this.role, {this.flex = 1});

  final String label;
  final CalculatorButtonRole role;
  final int flex;
}
