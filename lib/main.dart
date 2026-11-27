
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
  bool get inBase => progress == -1;
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

  int turn = 0;
  int? dice;
  bool rolled = false;
  bool finished = false;
  int sixCount = 0;
  int? winner;

  Player get current => players[turn];

  List<int> get legalMoves {
    if (!rolled || dice == null || finished) return [];

    final result = <int>[];
    for (int i = 0; i < 4; i++) {
      final p = current.tokens[i].progress;
      if (p == -1 && dice == 6) result.add(i);
      if (p >= 0 && p < 56 && p + dice! <= 56) {
        result.add(i);
      }
    }
    return result;
  }

  int roll() {
    if (rolled || finished) return dice ?? 1;

    dice = random.nextInt(6) + 1;
    rolled = true;

    if (dice == 6) {
      sixCount++;
      if (sixCount == 3) {
        dice = null;
        rolled = false;
        sixCount = 0;
        nextTurn();
        return 6;
      }
    } else {
      sixCount = 0;
    }

    return dice!;
  }

  bool move(int index) {
    if (!legalMoves.contains(index)) return false;

    final token = current.tokens[index];
    final oldProgress = token.progress;

    if (oldProgress == -1) {
      token.progress = 0;
    } else {
      token.progress += dice!;
    }

    final captured = capture(token);
    final reachedHome = token.progress == 56;

    if (current.tokens.every((t) => t.finished)) {
      finished = true;
      winner = turn;
    }

    final extraTurn = dice == 6 || captured || reachedHome;

    dice = null;
    rolled = false;

    if (!finished && !extraTurn) nextTurn();

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

  void nextTurn() {
    turn = (turn + 1) % 4;
    sixCount = 0;
  }

  void reset() {
    for (final p in players) {
      for (final t in p.tokens) {
        t.progress = -1;
      }
    }
    turn = 0;
    dice = null;
    rolled = false;
    finished = false;
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
      if (game.sixCount == 0 && value == 6 && !game.rolled) {
        message = '${playerNames[player]} rolled three sixes. Turn skipped.';
      } else if (game.legalMoves.isEmpty) {
        message = '${playerNames[player]} rolled $value. No legal move.';
        game.dice = null;
        game.rolled = false;
        game.nextTurn();
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
        final size = constraints.maxWidth;

        return Container(
          decoration: BoxDecoration(
            color: gold,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(3),
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) {
                    final cell = size / 15;
                    final point = details.localPosition;

                    double nearest = cell * 0.55;
                    int? selectedPlayer;
                    int? selectedToken;

                    for (int p = 0; p < 4; p++) {
                      for (final t in game.legalMoves) {
                        final token = game.players[p].tokens[t];
                        if (p != game.turn) continue;

                        final center = tokenPosition(
                          p,
                          t,
                          token.progress.toDouble(),
                          cell,
                        );

                        final distance = (point - center).distance;
                        if (distance < nearest) {
                          nearest = distance;
                          selectedPlayer = p;
                          selectedToken = t;
                        }
                      }
                    }

                    if (selectedPlayer != null && selectedToken != null) {
                      onTokenTap(selectedPlayer, selectedToken);
                    }
                  },
                  child: CustomPaint(
                    painter: BoardPainter(game),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
              _dice(0, Alignment.center, size),
              _dice(1, Alignment.center, size),
              _dice(2, Alignment.center, size),
              _dice(3, Alignment.center, size),
            ],
          ),
        );
      },
    );
  }

  Widget _dice(int player, Alignment ignored, double size) {
    final isActive = game.turn == player;
    final canRoll = isActive && !game.rolled && !game.finished;
    final value = isActive && game.dice != null ? game.dice! : null;

    return Positioned(
      left: player == 0 || player == 3 ? size * 0.265 : null,
      right: player == 1 || player == 2 ? size * 0.265 : null,
      top: player == 0 || player == 1 ? size * 0.265 : null,
      bottom: player == 2 || player == 3 ? size * 0.265 : null,
      child: GestureDetector(
        onTap: canRoll ? onRoll : null,
        child: Container(
          width: size * 0.19,
          height: size * 0.19,
          decoration: BoxDecoration(
            color: const Color(0xFF101827).withOpacity(0.94),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: isActive ? gold : playerColors[player],
              width: isActive ? 2 : 1,
            ),
            boxShadow: const [
              BoxShadow(color: Colors.black45, blurRadius: 5),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                playerNames[player],
                style: TextStyle(
                  color: playerColors[player],
                  fontSize: size * 0.022,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Container(
                width: size * 0.09,
                height: size * 0.09,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Center(
                  child: Text(
                    value?.toString() ?? '⚄',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                canRoll ? 'ROLL' : isActive && game.rolled ? 'MOVE' : 'WAIT',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Offset tokenPosition(int player, int token, double progress, double cell) {
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

  final lane = (progress - 51).clamp(0, 5);
  final lanes = [
    [7, 1 + lane],
    [1 + lane, 7],
    [7, 13 - lane],
    [13 - lane, 7],
  ];

  return Offset(
    (lanes[player][1] + 0.5) * cell,
    (lanes[player][0] + 0.5) * cell,
  );
}

class BoardPainter extends CustomPainter {
  final LudoGame game;
  BoardPainter(this.game);

  void cell(Canvas canvas, double s, int r, int c, Color color) {
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

  void home(Canvas canvas, double s, int row, int col, Color color) {
    canvas.drawRect(
      Rect.fromLTWH(col * s, row * s, 6 * s, 6 * s),
      Paint()..color = color,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH((col + s / s) * s, (row + 1) * s, 4 * s, 4 * s),
        Radius.circular(s * 0.2),
      ),
      Paint()..color = const Color(0xFFFFFDF7),
    );

    const positions = [[2,2],[4,2],[2,4],[4,4]];
    for (final p in positions) {
      final center = Offset(
        (col + p[0] + 0.5) * s,
        (row + p[1] + 0.5) * s,
      );
      canvas.drawCircle(center, s * 0.37, Paint()..color = color);
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

    // Safe stars: these match the game capture-protection cells.
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
      canvas.drawPath(path, Paint()..color = item[2] as Color);
    }

    for (int p = 0; p < 4; p++) {
      for (int t = 0; t < 4; t++) {
        final token = game.players[p].tokens[t];
        final pos = tokenPosition(p, t, token.progress.toDouble(), s);

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
