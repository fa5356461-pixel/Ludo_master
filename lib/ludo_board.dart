
import 'package:flutter/material.dart';

class LudoBoard extends StatelessWidget {
  const LudoBoard({super.key});

  static const colors = [
    Color(0xFFE53935),
    Color(0xFF43A047),
    Color(0xFFFFD600),
    Color(0xFF1E88E5),
  ];

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: const Color(0xFFD4AF37),
          borderRadius: BorderRadius.circular(12),
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 9,
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
          itemBuilder: (context, index) {
            final color = colors[index % 4];

            return Container(
              margin: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: index == 4
                    ? const Color(0xFF080D18)
                    : color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: index == 4
                    ? const Icon(
                        Icons.star,
                        color: Color(0xFFD4AF37),
                        size: 35,
                      )
                    : const Icon(
                        Icons.circle,
                        color: Colors.white,
                        size: 18,
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}
