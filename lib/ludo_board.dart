
import 'package:flutter/material.dart';

class LudoBoard extends StatelessWidget {
  const LudoBoard({super.key});

  static const red = Color(0xFFE53935);
  static const blue = Color(0xFF1E88E5);
  static const green = Color(0xFF43A047);
  static const yellow = Color(0xFFFFD600);
  static const gold = Color(0xFFD4AF37);
  static const dark = Color(0xFF182235);

  Color cellColor(int r, int c) {
    if (r >= 6 && r <= 8 &&
        c >= 6 && c <= 8) {
      return gold;
    }

    if (r < 6 && c < 6) return red;
    if (r < 6 && c > 8) return blue;
    if (r > 8 && c < 6) return green;
    if (r > 8 && c > 8) return yellow;

    if (r >= 6 && r <= 8) return Colors.white;
    if (c >= 6 && c <= 8) return Colors.white;

    return dark;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: gold,
          borderRadius: BorderRadius.circular(10),
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 225,
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 15,
          ),
          itemBuilder: (context, index) {
            final r = index ~/ 15;
            final c = index % 15;
            final color = cellColor(r, c);

            return Container(
              margin: const EdgeInsets.all(0.5),
              decoration: BoxDecoration(
                color: color,
                border: Border.all(
                  color: Colors.black26,
                  width: 0.3,
                ),
              ),
              child: r == 7 && c == 7
                  ? const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 15,
                    )
                  : null,
            );
          },
        ),
      ),
    );
  }
}
