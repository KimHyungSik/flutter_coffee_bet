import 'dart:async';

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

  bool _isCountingDown = false; // Tracks if the countdown has started
  int _countdown = 3; // Countdown timer value
  Timer? _countdownTimer; // Timer instance

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[900],
        body: Stack(
          children: [
            Listener(
              onPointerDown: _handlePointerDown,
              onPointerMove: _handlePointerMove,
              onPointerUp: _handlePointerUp,
              child: CustomPaint(
                painter: TouchPainter(_activeTouches),
                child: Container(), // Covers the entire screen
              ),
            ),
            if (_isCountingDown)
              Center(
                child: Text(
                  '$_countdown',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ));
  }

  void _handlePointerDown(PointerDownEvent event) {
    setState(() {
      _activeTouches[event.pointer] = _getLocalPosition(event);
    });
    _checkStartCountdown();
  }

  void _handlePointerMove(PointerMoveEvent event) {
    setState(() {
      _activeTouches[event.pointer] = _getLocalPosition(event);
    });
  }

  void _handlePointerUp(PointerUpEvent event) {
    setState(() {
      _activeTouches.remove(event.pointer);
    });
  }

  Offset _getLocalPosition(PointerEvent event) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    return box.globalToLocal(event.position);
  }

  void _checkStartCountdown() {
    if (_activeTouches.length >= 3 && !_isCountingDown) {
      setState(() {
        _isCountingDown = true;
        _countdown = 3; // Reset countdown
      });
      _startCountdown();
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel(); // Cancel any existing timer
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
      });

      if (_countdown <= 0) {
        timer.cancel();
        _onCountdownComplete();
      }
    });
  }

  void _onCountdownComplete() {
    setState(() {
      _isCountingDown = false;
      // Logic to start the game goes here
    });
    print("Game Started!");
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
