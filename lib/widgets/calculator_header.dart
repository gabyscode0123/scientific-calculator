import 'package:flutter/material.dart';

import '../models/angle_mode.dart';

class CalculatorHeader extends StatelessWidget {
  const CalculatorHeader({
    required this.angleMode,
    required this.onToggleAngleMode,
    super.key,
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
