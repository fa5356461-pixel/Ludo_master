
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
  bool isRolling = false;

  Future<void> rollDice() async {
    if (isRolling) return;

    setState(() {
      isRolling = true;
      diceNumber = random.nextInt(6) + 1;
      rollCount++;
    });

    await Future.delayed(const Duration(milliseconds: 750));

    if (!mounted) return;

    setState(() {
      isRolling = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedRotation(
          turns: rollCount * 1.5,
          duration: const Duration(milliseconds: 750),
          curve: Curves.easeOutCubic,
          child: AnimatedScale(
            scale: isRolling ? 1.12 : 1.0,
            duration: const Duration(milliseconds: 250),
            child: Container(
              width: 104,
              height: 104,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4AF37)
                        .withOpacity(0.35),
                    blurRadius: 22,
                    spreadRadius: 2,
                  ),
                  const BoxShadow(
                    color: Colors.black54,
                    blurRadius: 12,
                    offset: Offset(0, 7),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFDF7),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: CustomPaint(
                  painter: _DiceFacePainter(diceNumber),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 22),

        SizedBox(
          width: 180,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: isRolling ? null : rollDice,
            icon: const Icon(Icons.casino),
            label: Text(
              isRolling ? 'ROLLING...' : 'ROLL DICE',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: const Color(0xFF080D18),
              disabledBackgroundColor: Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DiceFacePainter extends CustomPainter {
  final int number;

  _DiceFacePainter(this.number);

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = const Color(0xFF182235)
      ..style = PaintingStyle.fill;

    final x1 = size.width * 0.25;
    final x2 = size.width * 0.50;
    final x3 = size.width * 0.75;

    final y1 = size.height * 0.25;
    final y2 = size.height * 0.50;
    final y3 = size.height * 0.75;

    final positions = <int, List<Offset>>{
      1: [Offset(x2, y2)],
      2: [Offset(x1, y1), Offset(x3, y3)],
      3: [Offset(x1, y1), Offset(x2, y2), Offset(x3, y3)],
      4: [
        Offset(x1, y1), Offset(x3, y1),
        Offset(x1, y3), Offset(x3, y3)
      ],
      5: [
        Offset(x1, y1), Offset(x3, y1),
        Offset(x2, y2),
        Offset(x1, y3), Offset(x3, y3)
      ],
      6: [
        Offset(x1, y1), Offset(x3, y1),
        Offset(x1, y2), Offset(x3, y2),
        Offset(x1, y3), Offset(x3, y3)
      ],
    };

    for (final point in positions[number]!) {
      canvas.drawCircle(point, size.width * 0.065, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DiceFacePainter oldDelegate) {
    return oldDelegate.number != number;
  }
}
