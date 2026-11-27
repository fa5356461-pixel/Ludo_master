
import 'package:flutter/material.dart';
import 'ludo_board.dart';
import 'dice_widget.dart';
import 'ludo_game.dart';

void main() {
  runApp(const LudoMaster());
}

class LudoMaster extends StatelessWidget {
  const LudoMaster({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LUDO MASTER',
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080D18),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.casino, size: 85, color: Color(0xFFD4AF37)),
            const SizedBox(height: 20),
            const Text(
              'LUDO MASTER',
              style: TextStyle(
                fontSize: 32,
                color: Color(0xFFD4AF37),
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'THE ULTIMATE LUDO EXPERIENCE',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 11,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 210,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GameScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: const Color(0xFF080D18),
                ),
                child: const Text(
                  'PLAY GAME',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
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

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final LudoGame game = LudoGame();

  final Map<int, int> diceValues = {
    0: 1,
    1: 1,
    2: 1,
    3: 1,
  };

  String message = 'RED: Roll your dice';

  static const playerColors = [
    Color(0xFFE53935),
    Color(0xFF1976D2),
    Color(0xFFFFD600),
    Color(0xFF43A047),
  ];

  int rollDiceForPlayer(int playerIndex) {
    if (playerIndex != game.currentPlayerIndex ||
        game.hasRolled ||
        game.gameFinished) {
      return diceValues[playerIndex]!;
    }

    final result = game.rollDice();
    diceValues[playerIndex] = result;

    final playerName =
        game.currentPlayer.color.name.toUpperCase();

    if (game.legalTokenIndices.isEmpty) {
      game.diceValue = null;
      game.hasRolled = false;
      game.currentPlayerIndex =
          (game.currentPlayerIndex + 1) % game.players.length;

      message = '$playerName rolled $result. No move available!';
    } else {
      message = '$playerName rolled $result. Tap a highlighted token!';
    }

    setState(() {});
    return result;
  }

  void moveToken(int tokenIndex) {
    if (!game.legalTokenIndices.contains(tokenIndex)) return;

    final playerName =
        game.currentPlayer.color.name.toUpperCase();

    final captured = game.moveToken(tokenIndex);

    setState(() {
      if (game.gameFinished) {
        message = '$playerName WINS!';
      } else if (captured) {
        message = '$playerName captured an opponent!';
      } else if (game.diceValue == null &&
          game.currentPlayer.color.name.toUpperCase() == playerName) {
        message = '$playerName gets another turn!';
      } else {
        message =
            '${game.currentPlayer.color.name.toUpperCase()} turn';
      }
    });
  }

  void resetGame() {
    setState(() {
      game.reset();
      for (var i = 0; i < 4; i++) {
        diceValues[i] = 1;
      }
      message = 'RED: Roll your dice';
    });
  }

  @override
  Widget build(BuildContext context) {
    final current = game.currentPlayerIndex;

    return Scaffold(
      backgroundColor: const Color(0xFF080D18),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111B2D),
        title: const Text(
          'LUDO MASTER',
          style: TextStyle(
            color: Color(0xFFD4AF37),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: resetGame,
            icon: const Icon(Icons.refresh),
            tooltip: 'New Game',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Text(
              game.gameFinished
                  ? 'GAME FINISHED'
                  : '${game.currentPlayer.color.name.toUpperCase()} PLAYER TURN',
              style: const TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 17,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: LudoBoard(
                    game: game,
                    onTokenTap: moveToken,
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(5, 10, 5, 12),
              decoration: const BoxDecoration(
                color: Color(0xFF111B2D),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
              ),
              child: Row(
                children: List.generate(4, (index) {
                  return Expanded(
                    child: DiceWidget(
                      key: ValueKey('player_dice_$index'),
                      playerName: game.players[index].color.name,
                      color: playerColors[index],
                      value: diceValues[index]!,
                      enabled: current == index &&
                          !game.hasRolled &&
                          !game.gameFinished,
                      onRoll: () => rollDiceForPlayer(index),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
