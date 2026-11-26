
import 'dart:math';
import 'package:flutter/material.dart';

class DiceWidget extends StatefulWidget {
  const DiceWidget({super.key});

  @override
  State<DiceWidget> createState() => _DiceWidgetState();
}

class _DiceWidgetState extends State<DiceWidget> {
  final Random random = Random();

  int diceNumber = 1;
  int rollCount = 0;

  void rollDice() {
    setState(() {
      diceNumber = random.nextInt(6) + 1;
      rollCount++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedRotation(
          turns: rollCount * 0.5,
          duration: const Duration(milliseconds: 400),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              '$diceNumber',
              style: const TextStyle(
                fontSize: 55,
                fontWeight: FontWeight.bold,
                color: Color(0xFF080D18),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: rollDice,
          icon: const Icon(Icons.casino),
          label: const Text('ROLL DICE'),
        ),
      ],
    );
  }
}
