import 'package:flutter/material.dart';

void main() {
  runApp(const GuessingGameApp());
}

class GuessingGameApp extends StatelessWidget {
  const GuessingGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guessing Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Guessing Game'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Touch to Play!',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}
