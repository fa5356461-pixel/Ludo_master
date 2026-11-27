
import 'package:flutter/material.dart';

class LudoBoard extends StatelessWidget {
  const LudoBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFD4AF37),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 14,
              offset: Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(3),
        child: CustomPaint(
          painter: _LudoBoardPainter(),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _LudoBoardPainter extends CustomPainter {
  static const int size = 15;

  final Color red = const Color(0xFFE53935);
  final Color blue = const Color(0xFF1976D2);
  final Color green = const Color(0xFF43A047);
  final Color yellow = const Color(0xFFFFD600);
  final Color track = const Color(0xFFFFFDF7);
  final Color line = const Color(0xFF263238);

  void drawCell(
    Canvas canvas,
    double cell,
    int row,
    int col,
    Color color,
  ) {
    final rect = Rect.fromLTWH(
      col * cell,
      row * cell,
      cell,
      cell,
    );

    canvas.drawRect(
      rect,
      Paint()..color = color,
    );

    canvas.drawRect(
      rect,
      Paint()
        ..color = line.withOpacity(0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6,
    );
  }

  void drawHome(
    Canvas canvas,
    double cell,
    int row,
    int col,
    Color color,
  ) {
    final outer = Rect.fromLTWH(
      col * cell,
      row * cell,
      6 * cell,
      6 * cell,
    );

    canvas.drawRect(outer, Paint()..color = color);

    final inner = Rect.fromLTWH(
      (col + 1) * cell,
      (row + 1) * cell,
      4 * cell,
      4 * cell,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        inner,
        Radius.circular(cell * 0.25),
      ),
      Paint()..color = const Color(0xFFFFFDF7),
    );

    final positions = [
      Offset(col + 2, row + 2),
      Offset(col + 4, row + 2),
      Offset(col + 2, row + 4),
      Offset(col + 4, row + 4),
    ];

    for (final position in positions) {
      final center = Offset(
        (position.dx + 0.5) * cell,
        (position.dy + 0.5) * cell,
      );

      canvas.drawCircle(
        center,
        cell * 0.36,
        Paint()..color = color,
      );

      canvas.drawCircle(
        center,
        cell * 0.27,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );

      canvas.drawCircle(
        center,
        cell * 0.12,
        Paint()..color = color,
      );
    }
  }

  void drawCenter(Canvas canvas, double cell) {
    final center = Offset(7.5 * cell, 7.5 * cell);

    final triangles = [
      [Offset(6 * cell, 6 * cell), Offset(9 * cell, 6 * cell), center, red],
      [Offset(9 * cell, 6 * cell), Offset(9 * cell, 9 * cell), center, blue],
      [Offset(9 * cell, 9 * cell), Offset(6 * cell, 9 * cell), center, yellow],
      [Offset(6 * cell, 9 * cell), Offset(6 * cell, 6 * cell), center, green],
    ];

    for (final item in triangles) {
      final path = Path()
        ..moveTo((item[0] as Offset).dx, (item[0] as Offset).dy)
        ..lineTo((item[1] as Offset).dx, (item[1] as Offset).dy)
        ..lineTo((item[2] as Offset).dx, (item[2] as Offset).dy)
        ..close();

      canvas.drawPath(
        path,
        Paint()..color = item[3] as Color,
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / 15;

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF182235),
    );

    // Four player home areas.
    drawHome(canvas, cell, 0, 0, red);
    drawHome(canvas, cell, 0, 9, blue);
    drawHome(canvas, cell, 9, 0, green);
    drawHome(canvas, cell, 9, 9, yellow);

    // Main 52-square Ludo track.
    final route = <List<int>>[
      [6,1],[6,2],[6,3],[6,4],[6,5],
      [5,6],[4,6],[3,6],[2,6],[1,6],
      [0,6],[0,7],[0,8],
      [1,8],[2,8],[3,8],[4,8],[5,8],
      [6,9],[6,10],[6,11],[6,12],[6,13],[6,14],
      [7,14],[8,14],
      [8,13],[8,12],[8,11],[8,10],[8,9],
      [9,8],[10,8],[11,8],[12,8],[13,8],[14,8],
      [14,7],[14,6],
      [13,6],[12,6],[11,6],[10,6],[9,6],
      [8,5],[8,4],[8,3],[8,2],[8,1],[8,0],
      [7,0],[6,0],
    ];

    for (final point in route) {
      drawCell(canvas, cell, point[0], point[1], track);
    }

    // Four coloured home lanes.
    for (int i = 1; i <= 5; i++) {
      drawCell(canvas, cell, 7, i, red);
      drawCell(canvas, cell, i, 7, blue);
      drawCell(canvas, cell, 7, 14 - i, yellow);
      drawCell(canvas, cell, 14 - i, 7, green);
    }

    // Starting squares.
    drawCell(canvas, cell, 6, 1, red);
    drawCell(canvas, cell, 1, 8, blue);
    drawCell(canvas, cell, 8, 13, yellow);
    drawCell(canvas, cell, 13, 6, green);

    // Safe squares.
    final safePoints = [
      [6,2], [2,8], [8,12], [12,6],
      [6,1], [1,8], [8,13], [13,6],
    ];

    for (final point in safePoints) {
      final center = Offset(
        (point[1] + 0.5) * cell,
        (point[0] + 0.5) * cell,
      );

      final text = TextPainter(
        text: TextSpan(
          text: '★',
          style: TextStyle(
            fontSize: cell * 0.65,
            color: const Color(0xFFD4AF37),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      text.paint(
        canvas,
        Offset(
          center.dx - text.width / 2,
          center.dy - text.height / 2,
        ),
      );
    }

    // Four-colour finishing centre.
    drawCenter(canvas, cell);

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..color = const Color(0xFFD4AF37)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _LudoBoardPainter oldDelegate) {
    return false;
  }
}
