
import 'package:flutter/material.dart';

class DiceWidget extends StatefulWidget {
  final String playerName;
  final Color color;
  final int value;
  final bool enabled;
  final int Function() onRoll;

  const DiceWidget({
    super.key,
    required this.playerName,
    required this.color,
    required this.value,
    required this.enabled,
    required this.onRoll,
  });

  @override
  State<DiceWidget> createState() => _DiceWidgetState();
}

class _DiceWidgetState extends State<DiceWidget> {
  bool isRolling = false;
  int rollCount = 0;

  Future<void> rollDice() async {
    if (isRolling || !widget.enabled) return;

    setState(() {
      isRolling = true;
      rollCount++;
    });

    await Future.delayed(const Duration(milliseconds: 550));

    if (!mounted) return;

    widget.onRoll();

    if (!mounted) return;

    setState(() {
      isRolling = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.enabled;

    return GestureDetector(
      onTap: active ? rollDice : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        decoration: BoxDecoration(
          color: active
              ? widget.color.withOpacity(0.17)
              : const Color(0xFF182235),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? widget.color : Colors.white12,
            width: active ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.playerName.toUpperCase(),
              maxLines: 1,
              style: TextStyle(
                color: active ? widget.color : Colors.white54,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 7),
            AnimatedRotation(
              turns: isRolling ? rollCount * 1.5 : 0,
              duration: const Duration(milliseconds: 550),
              curve: Curves.easeOutCubic,
              child: AnimatedScale(
                scale: isRolling ? 1.12 : 1,
                duration: const Duration(milliseconds: 180),
                child: Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: active
                        ? const Color(0xFFD4AF37)
                        : Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: widget.color.withOpacity(0.35),
                              blurRadius: 10,
                            ),
                          ]
                        : [],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFDF7),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: CustomPaint(
                      painter: _DiceFacePainter(widget.value),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              isRolling
                  ? 'ROLLING'
                  : active
                      ? 'YOUR TURN'
                      : 'WAIT',
              maxLines: 1,
              style: TextStyle(
                color: active ? widget.color : Colors.white38,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiceFacePainter extends CustomPainter {
  final int number;

  _DiceFacePainter(this.number);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF182235);

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
        Offset(x1, y3), Offset(x3, y3),
      ],
      5: [
        Offset(x1, y1), Offset(x3, y1),
        Offset(x2, y2),
        Offset(x1, y3), Offset(x3, y3),
      ],
      6: [
        Offset(x1, y1), Offset(x3, y1),
        Offset(x1, y2), Offset(x3, y2),
        Offset(x1, y3), Offset(x3, y3),
      ],
    };

    for (final point in positions[number]!) {
      canvas.drawCircle(point, size.width * 0.065, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DiceFacePainter oldDelegate) {
    return oldDelegate.number != number;
  }
}
