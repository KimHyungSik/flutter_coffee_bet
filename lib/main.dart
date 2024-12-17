import 'package:coffee_bet/touch_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
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

  // Map to store active touches (pointer ID → position)
  final Map<int, Offset> _activeTouches = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Listener(
        onPointerDown: _handlePointerDown,
        onPointerMove: _handlePointerMove,
        onPointerUp: _handlePointerUp,
        child: CustomPaint(
          painter: TouchPainter(_activeTouches),
          child: Container(), // Makes the Listener cover the whole screen
        ),
      ),
    );
  }

  void _handlePointerDown(PointerDownEvent event) {
    setState(() {
      _activeTouches[event.pointer] = event.position;
    });
  }

  void _handlePointerMove(PointerMoveEvent event) {
    setState(() {
      _activeTouches[event.pointer] = event.position;
    });
  }

  void _handlePointerUp(PointerUpEvent event) {
    setState(() {
      _activeTouches.remove(event.pointer);
    });
  }
}
