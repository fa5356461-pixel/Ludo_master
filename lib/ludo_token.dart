
import 'package:flutter/material.dart';

class LudoToken extends StatelessWidget {
  final Color color;
  final int tokenNumber;
  final bool selected;
  final VoidCallback onTap;

  const LudoToken({
    super.key,
    required this.color,
    required this.tokenNumber,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: selected ? 1.2 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? Colors.white : Colors.black,
              width: selected ? 4 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: selected ? 12 : 4,
              ),
            ],
          ),
          child: Center(
            child: Text(
              '$tokenNumber',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
