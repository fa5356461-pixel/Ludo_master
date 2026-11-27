
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
            const Icon(
              Icons.casino,
              size: 85,
              color: Color(0xFFD4AF37),
            ),
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

  String message = 'Roll the dice to start';

  int rollDice() {
    final result = game.rollDice();

    if (game.legalTokenIndices.isEmpty) {
      final playerName = game.currentPlayer.color.name.toUpperCase();

      game.diceValue = null;
      game.hasRolled = false;
      game.currentPlayerIndex =
          (game.currentPlayerIndex + 1) % game.players.length;

      message = '$playerName rolled $result. No legal move!';
    } else {
      message =
          '${game.currentPlayer.color.name.toUpperCase()} rolled $result';
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
      } else {
        message = '$playerName moved token ${tokenIndex + 1}';
      }
    });
  }

  void resetGame() {
    setState(() {
      game.reset();
      message = 'New game started. Roll the dice!';
    });
  }

  @override
  Widget build(BuildContext context) {
    final legalMoves = game.legalTokenIndices;

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
            const SizedBox(height: 10),

            Text(
              game.gameFinished
                  ? 'GAME FINISHED'
                  : 'CURRENT PLAYER: ${game.currentPlayer.color.name.toUpperCase()}',
              style: const TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 17,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),

            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: LudoBoard(game: game),
                ),
              ),
            ),

            if (!game.gameFinished && game.hasRolled) ...[
              const Text(
                'SELECT A TOKEN TO MOVE',
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                children: legalMoves.map((index) {
                  return ElevatedButton(
                    onPressed: () => moveToken(index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: const Color(0xFF080D18),
                    ),
                    child: Text('TOKEN ${index + 1}'),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
            ],

            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: DiceWidget(
                onRoll: rollDice,
                enabled: !game.hasRolled && !game.gameFinished,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
