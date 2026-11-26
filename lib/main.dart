
import 'package:flutter/material.dart';

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
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF080D18),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD4AF37),
          brightness: Brightness.dark,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.casino,
                size: 90,
                color: Color(0xFFD4AF37),
              ),
              const SizedBox(height: 20),
              const Text(
                'LUDO MASTER',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                  color: Color(0xFFD4AF37),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'THE ULTIMATE LUDO EXPERIENCE',
                style: TextStyle(color: Colors.white60),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.play_arrow),
                label: const Text('PLAY GAME'),
              ),
              const SizedBox(height: 15),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.person),
                label: const Text('PLAYER ACCOUNT'),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.admin_panel_settings),
                label: const Text('BOSS ACCOUNT'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
