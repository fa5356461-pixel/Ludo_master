
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const LudoMaster());

const gold = Color(0xFFD4AF37);
const navy = Color(0xFF080D18);

const playerColors = [
  Color(0xFFE53935),
  Color(0xFF1976D2),
  Color(0xFFFFD600),
  Color(0xFF43A047),
];

const playerNames = ['RED', 'BLUE', 'YELLOW', 'GREEN'];
const offsets = [0, 13, 26, 39];

const route = <List<int>>[
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

const safeCells = {0, 8, 13, 21, 26, 34, 39, 47};

class Token {
  int progress;
  Token({this.progress = -1});

  bool get finished => progress == 56;
}

class Player {
  final int id;
  final List<Token> tokens = List.generate(4, (_) => Token());

  Player(this.id);
}

class LudoGame {
  final players = List.generate(4, (i) => Player(i));
  final Random random = Random();

  final List<int> diceValues = [1, 1, 1, 1];

  int turn = 0;
  int? dice;
  bool rolled = false;
  bool finished = false;
  bool lastRollSkipped = false;
  int sixCount = 0;
  int? winner;

  Player get current => players[turn];

  List<int> get legalMoves {
    if (!rolled || dice == null || finished) return [];

    final result = <int>[];

    for (int i = 0; i < 4; i++) {
      final p = current.tokens[i].progress;

      if (p == -1 && dice == 6) {
        result.add(i);
      } else if (p >= 0 && p < 56 && p + dice! <= 56) {
        result.add(i);
      }
    }

    return result;
  }

  int roll() {
    if (rolled || finished) return dice ?? 1;

    lastRollSkipped = false;

    final value = random.nextInt(6) + 1;
    diceValues[turn] = value;

    if (value == 6) {
      sixCount++;

      if (sixCount == 3) {
        lastRollSkipped = true;
        dice = null;
        rolled = false;
        nextTurn();
        return value;
      }
    } else {
      sixCount = 0;
    }

    dice = value;
    rolled = true;
    return value;
  }

  bool move(int index) {
    if (!legalMoves.contains(index)) return false;

    final player = current;
    final token = player.tokens[index];

    if (token.progress == -1) {
      token.progress = 0;
    } else {
      token.progress += dice!;
    }

    final captured = capture(token);
    final reachedHome = token.progress == 56;

    if (player.tokens.every((t) => t.finished)) {
      finished = true;
      winner = turn;
    }

    final extraTurn = dice == 6 || captured || reachedHome;

    dice = null;
    rolled = false;

    if (!finished && !extraTurn) {
      nextTurn();
    }

    return captured;
  }

  bool capture(Token token) {
    if (token.progress < 0 || token.progress > 50) return false;

    final cell = (offsets[turn] + token.progress) % 52;

    if (safeCells.contains(cell)) return false;

    bool captured = false;

    for (int p = 0; p < 4; p++) {
      if (p == turn) continue;

      for (final enemy in players[p].tokens) {
        if (enemy.progress < 0 || enemy.progress > 50) continue;

        final enemyCell = (offsets[p] + enemy.progress) % 52;

        if (enemyCell == cell) {
          enemy.progress = -1;
          captured = true;
        }
      }
    }

    return captured;
  }

  void passTurn() {
    dice = null;
    rolled = false;
    nextTurn();
  }

  void nextTurn() {
    turn = (turn + 1) % 4;
    sixCount = 0;
  }

  void reset() {
    for (final player in players) {
      for (final token in player.tokens) {
        token.progress = -1;
      }
    }

    diceValues.fillRange(0, 4, 1);

    turn = 0;
    dice = null;
    rolled = false;
    finished = false;
    lastRollSkipped = false;
    sixCount = 0;
    winner = null;
  }
}

class LudoMaster extends StatelessWidget {
  const LudoMaster({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LUDO MASTER',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: navy,
        colorScheme: const ColorScheme.dark(
          primary: gold,
          secondary: gold,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF101D32), navy],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.casino, color: gold, size: 90),
              const SizedBox(height: 18),
              const Text(
                'LUDO MASTER',
                style: TextStyle(
                  color: gold,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'THE CLASSIC BOARD EXPERIENCE',
                style: TextStyle(
                  color: Colors.white54,
                  letterSpacing: 2,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 42),
              SizedBox(
                width: 220,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    foregroundColor: navy,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const GamePage(),
                      ),
                    );
                  },
                  child: const Text(
                    'PLAY GAME',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final LudoGame game = LudoGame();
  String message = 'RED: Roll the dice';

  void rollDice() {
    if (game.finished || game.rolled) return;

    final player = game.turn;
    final value = game.roll();

    setState(() {
      if (game.lastRollSkipped) {
        message = '${playerNames[player]} rolled three sixes. Turn skipped.';
      } else if (game.legalMoves.isEmpty) {
        message = '${playerNames[player]} rolled $value. No legal move.';
        game.passTurn();
        message += ' ${playerNames[game.turn]} plays.';
      } else {
        message = '${playerNames[player]} rolled $value. Tap a token.';
      }
    });
  }

  void moveToken(int player, int token) {
    if (player != game.turn || !game.rolled) return;
    if (!game.legalMoves.contains(token)) return;

    final name = playerNames[player];
    final captured = game.move(token);

    setState(() {
      if (game.finished) {
        message = '${playerNames[game.winner!]} WINS!';
      } else if (captured) {
        message = '$name captured an opponent!';
      } else if (game.turn == player) {
        message = '$name gets another turn!';
      } else {
        message = '${playerNames[game.turn]}: Roll the dice';
      }
    });
  }

  void resetGame() {
    setState(() {
      game.reset();
      message = 'RED: Roll the dice';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF111B2D),
        title: const Text(
          'LUDO MASTER',
          style: TextStyle(color: gold, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: resetGame,
            icon: const Icon(Icons.refresh, color: gold),
            tooltip: 'New game',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text(
              game.finished
                  ? 'GAME FINISHED'
                  : '${playerNames[game.turn]} PLAYER TURN',
              style: const TextStyle(
                color: gold,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: LudoBoard(
                      game: game,
                      onRoll: rollDice,
                      onTokenTap: moveToken,
                    ),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'Tap your dice to roll, then tap a legal token.',
                style: TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LudoBoard extends StatelessWidget {
  final LudoGame game;
  final VoidCallback onRoll;
  final void Function(int player, int token) onTokenTap;

  const LudoBoard({
    super.key,
    required this.game,
    required this.onRoll,
    required this.onTokenTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = min(constraints.maxWidth, constraints.maxHeight);

        return SizedBox(
          width: size,
          height: size,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: gold, width: 3),
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (details) {
                        final cell = size / 15;
                        final point = details.localPosition;

                        double nearest = cell * 0.48;
                        int? selected;

                        for (final t in game.legalMoves) {
                          final token = game.players[game.turn].tokens[t];

                          final center = tokenPosition(
                            game.turn,
                            t,
                            token.progress.toDouble(),
                            cell,
                          );

                          final distance = (point - center).distance;

                          if (distance < nearest) {
                            nearest = distance;
                            selected = t;
                          }
                        }

                        if (selected != null) {
                          onTokenTap(game.turn, selected);
                        }
                      },
                      child: CustomPaint(
                        painter: BoardPainter(game),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),

                  _positionDice(0, size),
                  _positionDice(1, size),
                  _positionDice(2, size),
                  _positionDice(3, size),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _positionDice(int player, double size) {
    final positions = [
      const [0.035, 0.035, -1.0, -1.0],
      const [-1.0, 0.035, 0.035, -1.0],
      const [-1.0, -1.0, 0.035, 0.035],
      const [0.035, -1.0, -1.0, 0.035],
    ];

    final p = positions[player];
    final active = game.turn == player && !game.finished;

    return Positioned(
      left: p[0] >= 0 ? size * p[0] : null,
      top: p[1] >= 0 ? size * p[1] : null,
      right: p[2] >= 0 ? size * p[2] : null,
      bottom: p[3] >= 0 ? size * p[3] : null,
      child: DiceWidget(
        player: player,
        value: game.diceValues[player],
        enabled: active && !game.rolled,
        onRoll: onRoll,
        size: size * 0.145,
      ),
    );
  }
}

class DiceWidget extends StatefulWidget {
  final int player;
  final int value;
  final bool enabled;
  final VoidCallback onRoll;
  final double size;

  const DiceWidget({
    super.key,
    required this.player,
    required this.value,
    required this.enabled,
    required this.onRoll,
    required this.size,
  });

  @override
  State<DiceWidget> createState() => _DiceWidgetState();
}

class _DiceWidgetState extends State<DiceWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  bool rolling = false;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> handleRoll() async {
    if (!widget.enabled || rolling) return;

    setState(() => rolling = true);

    await controller.forward(from: 0);

    if (!mounted) return;

    widget.onRoll();

    if (mounted) {
      setState(() => rolling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: handleRoll,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final face = rolling
              ? 1 + ((controller.value * 18).floor() % 6)
              : widget.value;

          final angle = rolling
              ? sin(controller.value * pi * 12) *
                  (1 - controller.value) *
                  0.18
              : 0.0;

          final scale = rolling
              ? 1 + sin(controller.value * pi) * 0.08
              : 1.0;

          return Transform.rotate(
            angle: angle,
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: widget.size,
                height: widget.size,
                padding: EdgeInsets.all(widget.size * 0.08),
                decoration: BoxDecoration(
                  color: const Color(0xFF101827),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: widget.enabled ? gold : playerColors[widget.player],
                    width: widget.enabled ? 2.5 : 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.45),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FittedBox(
                      child: Text(
                        playerNames[widget.player],
                        style: TextStyle(
                          color: playerColors[widget.player],
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: DiceFace(value: face),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class DiceFace extends StatelessWidget {
  final int value;

  const DiceFace({super.key, required this.value});

  static const spots = <int, List<Alignment>>{
    1: [Alignment.center],
    2: [Alignment(-0.55, -0.55), Alignment(0.55, 0.55)],
    3: [
      Alignment(-0.55, -0.55),
      Alignment.center,
      Alignment(0.55, 0.55),
    ],
    4: [
      Alignment(-0.55, -0.55),
      Alignment(0.55, -0.55),
      Alignment(-0.55, 0.55),
      Alignment(0.55, 0.55),
    ],
    5: [
      Alignment(-0.55, -0.55),
      Alignment(0.55, -0.55),
      Alignment.center,
      Alignment(-0.55, 0.55),
      Alignment(0.55, 0.55),
    ],
    6: [
      Alignment(-0.55, -0.55),
      Alignment(0.55, -0.55),
      Alignment(-0.55, 0),
      Alignment(0.55, 0),
      Alignment(-0.55, 0.55),
      Alignment(0.55, 0.55),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final dots = spots[value.clamp(1, 6)]!;

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFEF8),
          borderRadius: BorderRadius.circular(7),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 2),
          ],
        ),
        child: Stack(
          children: [
            for (final spot in dots)
              Align(
                alignment: spot,
                child: FractionallySizedBox(
                  widthFactor: 0.19,
                  heightFactor: 0.19,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Offset tokenPosition(
  int player,
  int token,
  double progress,
  double cell,
) {
  const bases = [
    [0, 0], [0, 9], [9, 9], [9, 0],
  ];

  const homes = [
    [2, 2], [4, 2], [2, 4], [4, 4],
  ];

  if (progress < 0) {
    return Offset(
      (bases[player][1] + homes[token][0] + 0.5) * cell,
      (bases[player][0] + homes[token][1] + 0.5) * cell,
    );
  }

  if (progress >= 56) {
    const shifts = [
      Offset(-0.22, -0.22),
      Offset(0.22, -0.22),
      Offset(-0.22, 0.22),
      Offset(0.22, 0.22),
    ];

    return Offset(
      (7.5 + shifts[token].dx) * cell,
      (7.5 + shifts[token].dy) * cell,
    );
  }

  if (progress <= 50) {
    final index = (offsets[player] + progress.floor()) % 52;
    final next = (index + 1) % 52;
    final fraction = progress - progress.floor();

    return Offset(
      (route[index][1] + 0.5 +
              (route[next][1] - route[index][1]) * fraction) *
          cell,
      (route[index][0] + 0.5 +
              (route[next][0] - route[index][0]) * fraction) *
          cell,
    );
  }

  final lane = (progress - 51).clamp(0, 5).toDouble();

  final lanes = [
    [7.0, 1.0 + lane],
    [1.0 + lane, 7.0],
    [7.0, 13.0 - lane],
    [13.0 - lane, 7.0],
  ];

  return Offset(
    (lanes[player][1] + 0.5) * cell,
    (lanes[player][0] + 0.5) * cell,
  );
}

class BoardPainter extends CustomPainter {
  final LudoGame game;

  BoardPainter(this.game);

  void cell(
    Canvas canvas,
    double s,
    int r,
    int c,
    Color color,
  ) {
    final rect = Rect.fromLTWH(c * s, r * s, s, s);

    canvas.drawRect(rect, Paint()..color = color);

    canvas.drawRect(
      rect,
      Paint()
        ..color = Colors.black26
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6,
    );
  }

  void home(
    Canvas canvas,
    double s,
    int row,
    int col,
    Color color,
  ) {
    canvas.drawRect(
      Rect.fromLTWH(col * s, row * s, 6 * s, 6 * s),
      Paint()..color = color,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          (col + 1) * s,
          (row + 1) * s,
          4 * s,
          4 * s,
        ),
        Radius.circular(s * 0.2),
      ),
      Paint()..color = const Color(0xFFFFFDF7),
    );

    const positions = [
      [2,2],[4,2],[2,4],[4,4],
    ];

    for (final p in positions) {
      final center = Offset(
        (col + p[0] + 0.5) * s,
        (row + p[1] + 0.5) * s,
      );

      canvas.drawCircle(
        center,
        s * 0.37,
        Paint()..color = color,
      );

      canvas.drawCircle(
        center,
        s * 0.25,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 15;

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF182235),
    );

    home(canvas, s, 0, 0, playerColors[0]);
    home(canvas, s, 0, 9, playerColors[1]);
    home(canvas, s, 9, 9, playerColors[2]);
    home(canvas, s, 9, 0, playerColors[3]);

    for (final p in route) {
      cell(canvas, s, p[0], p[1], const Color(0xFFFFFDF7));
    }

    for (int i = 1; i <= 5; i++) {
      cell(canvas, s, 7, i, playerColors[0]);
      cell(canvas, s, i, 7, playerColors[1]);
      cell(canvas, s, 7, 14 - i, playerColors[2]);
      cell(canvas, s, 14 - i, 7, playerColors[3]);
    }

    for (int p = 0; p < 4; p++) {
      final start = route[offsets[p]];
      cell(canvas, s, start[0], start[1], playerColors[p]);
    }

    for (final index in [8, 21, 34, 47]) {
      final point = route[index];

      final painter = TextPainter(
        text: TextSpan(
          text: '★',
          style: TextStyle(
            color: gold,
            fontSize: s * 0.65,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      painter.paint(
        canvas,
        Offset(
          (point[1] + 0.5) * s - painter.width / 2,
          (point[0] + 0.5) * s - painter.height / 2,
        ),
      );
    }

    final center = Offset(7.5 * s, 7.5 * s);

    final triangles = [
      [Offset(6*s,6*s), Offset(9*s,6*s), playerColors[0]],
      [Offset(9*s,6*s), Offset(9*s,9*s), playerColors[1]],
      [Offset(9*s,9*s), Offset(6*s,9*s), playerColors[2]],
      [Offset(6*s,9*s), Offset(6*s,6*s), playerColors[3]],
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

    for (int p = 0; p < 4; p++) {
      for (int t = 0; t < 4; t++) {
        final token = game.players[p].tokens[t];

        final pos = tokenPosition(
          p,
          t,
          token.progress.toDouble(),
          s,
        );

        canvas.drawCircle(
          pos + Offset(0, s * 0.035),
          s * 0.34,
          Paint()..color = Colors.black54,
        );

        canvas.drawCircle(
          pos,
          s * 0.29,
          Paint()..color = playerColors[p],
        );

        canvas.drawCircle(
          pos,
          s * 0.20,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4,
        );

        canvas.drawCircle(
          pos,
          s * 0.08,
          Paint()..color = Colors.white,
        );
      }
    }

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..color = gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) => true;
}
