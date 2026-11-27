
import 'package:flutter/material.dart';
import 'ludo_game.dart';

class LudoBoard extends StatelessWidget {
  final LudoGame? game;

  const LudoBoard({super.key, this.game});

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
          painter: _LudoBoardPainter(game),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _LudoBoardPainter extends CustomPainter {
  final LudoGame? game;

  _LudoBoardPainter(this.game);

  static const route = <List<int>>[
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

  static const colors = [
    Color(0xFFE53935),
    Color(0xFF1976D2),
    Color(0xFFFFD600),
    Color(0xFF43A047),
  ];

  static const offsets = [0, 13, 26, 39];

  static const bases = [
    [0, 0], [0, 9], [9, 9], [9, 0],
  ];

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

    canvas.drawRect(rect, Paint()..color = color);

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
    canvas.drawRect(
      Rect.fromLTWH(
        col * cell,
        row * cell,
        6 * cell,
        6 * cell,
      ),
      Paint()..color = color,
    );

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
      [2, 2], [4, 2], [2, 4], [4, 4],
    ];

    for (final p in positions) {
      canvas.drawCircle(
        Offset(
          (col + p[0] + 0.5) * cell,
          (row + p[1] + 0.5) * cell,
        ),
        cell * 0.36,
        Paint()..color = color,
      );
    }
  }

  void drawCenter(Canvas canvas, double cell) {
    final center = Offset(7.5 * cell, 7.5 * cell);

    final triangles = [
      [Offset(6 * cell, 6 * cell), Offset(9 * cell, 6 * cell), colors[0]],
      [Offset(9 * cell, 6 * cell), Offset(9 * cell, 9 * cell), colors[1]],
      [Offset(9 * cell, 9 * cell), Offset(6 * cell, 9 * cell), colors[2]],
      [Offset(6 * cell, 9 * cell), Offset(6 * cell, 6 * cell), colors[3]],
    ];

    for (final item in triangles) {
      final a = item[0] as Offset;
      final b = item[1] as Offset;

      final path = Path()
        ..moveTo(a.dx, a.dy)
        ..lineTo(b.dx, b.dy)
        ..lineTo(center.dx, center.dy)
        ..close();

      canvas.drawPath(
        path,
        Paint()..color = item[2] as Color,
      );
    }
  }

  Offset tokenPosition(
    int playerIndex,
    int tokenIndex,
    int progress,
    double cell,
  ) {
    final base = bases[playerIndex];

    if (progress == -1) {
      const positions = [
        [2, 2], [4, 2], [2, 4], [4, 4],
      ];

      return Offset(
        (base[1] + positions[tokenIndex][0] + 0.5) * cell,
        (base[0] + positions[tokenIndex][1] + 0.5) * cell,
      );
    }

    if (progress == 56) {
      const shifts = [
        Offset(-0.25, -0.25),
        Offset(0.25, -0.25),
        Offset(-0.25, 0.25),
        Offset(0.25, 0.25),
      ];

      return Offset(
        (7.5 + shifts[tokenIndex].dx) * cell,
        (7.5 + shifts[tokenIndex].dy) * cell,
      );
    }

    if (progress >= 51) {
      final step = progress - 51;

      final lanes = [
        [7, 1 + step],
        [1 + step, 7],
        [7, 13 - step],
        [13 - step, 7],
      ];

      return Offset(
        (lanes[playerIndex][1] + 0.5) * cell,
        (lanes[playerIndex][0] + 0.5) * cell,
      );
    }

    final global = (offsets[playerIndex] + progress) % 52;
    final point = route[global];

    return Offset(
      (point[1] + 0.5) * cell,
      (point[0] + 0.5) * cell,
    );
  }

  void drawTokens(Canvas canvas, double cell) {
    if (game == null) return;

    for (var p = 0; p < game!.players.length; p++) {
      final player = game!.players[p];

      for (var t = 0; t < player.tokens.length; t++) {
        final position = tokenPosition(
          p,
          t,
          player.tokens[t].progress,
          cell,
        );

        canvas.drawCircle(
          position,
          cell * 0.34,
          Paint()..color = Colors.black54,
        );

        canvas.drawCircle(
          position,
          cell * 0.29,
          Paint()..color = colors[p],
        );

        canvas.drawCircle(
          position,
          cell * 0.20,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );

        canvas.drawCircle(
          position,
          cell * 0.09,
          Paint()..color = Colors.white,
        );
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / 15;

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF182235),
    );

    drawHome(canvas, cell, 0, 0, colors[0]);
    drawHome(canvas, cell, 0, 9, colors[1]);
    drawHome(canvas, cell, 9, 9, colors[2]);
    drawHome(canvas, cell, 9, 0, colors[3]);

    for (final point in route) {
      drawCell(
        canvas,
        cell,
        point[0],
        point[1],
        track,
      );
    }

    for (var i = 1; i <= 5; i++) {
      drawCell(canvas, cell, 7, i, colors[0]);
      drawCell(canvas, cell, i, 7, colors[1]);
      drawCell(canvas, cell, 7, 14 - i, colors[2]);
      drawCell(canvas, cell, 14 - i, 7, colors[3]);
    }

    drawCell(canvas, cell, 6, 1, colors[0]);
    drawCell(canvas, cell, 1, 8, colors[1]);
    drawCell(canvas, cell, 8, 13, colors[2]);
    drawCell(canvas, cell, 13, 6, colors[3]);

    const safePoints = [
      [6, 2], [2, 8], [8, 12], [12, 6],
      [6, 1], [1, 8], [8, 13], [13, 6],
    ];

    for (final point in safePoints) {
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
          (point[1] + 0.5) * cell - text.width / 2,
          (point[0] + 0.5) * cell - text.height / 2,
        ),
      );
    }

    drawCenter(canvas, cell);
    drawTokens(canvas, cell);

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
    return true;
  }
}
