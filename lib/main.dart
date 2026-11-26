
import 'package:flutter/material.dart';
import 'ludo_board.dart';

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
            const Icon(Icons.casino, size: 80, color: Color(0xFFD4AF37)),
            const SizedBox(height: 20),
            const Text(
              'LUDO MASTER',
              style: TextStyle(
                fontSize: 30,
                color: Color(0xFFD4AF37),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 35),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GameScreen(),
                  ),
                );
              },
              child: const Text('PLAY GAME'),
            ),
          ],
        ),
      ),
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080D18),
      appBar: AppBar(title: const Text('LUDO MASTER')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: const LudoBoard(),
        ),
      ),
    );
  }
}
