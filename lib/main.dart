import 'dart:async';

import 'package:coffee_bet/user_circle_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game_over.dart';

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
  final Map<int, DateTime> _releaseTimes = {}; // Finger release times

  static const int MAX_GAME_PLAY = 5;

  bool _isGameActive = false; // Tracks if the game has started
  int _lastFailingPointer = -1; // Pointer ID of the failing player
  bool _isGameOver = false; // Tracks if the game has ended
  Map<int, Offset>? _failingPointer;

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
                painter: UserCirclePainter(_activeTouches),
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
            if (_isGameOver)
              GameOverWidget(
                onRestart: _restartGame,
                failingPointers: _failingPointer ?? {},
              ),
          ],
        ));
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (_isGameActive || _activeTouches.length >= MAX_GAME_PLAY) return;

    setState(() {
      _activeTouches[event.pointer] = _getLocalPosition(event);
    });
    _checkStartCountdown();
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (!_activeTouches.containsKey(event.pointer)) {
      return; // Prevent new players from moving their circle after game starts
    }

    setState(() {
      _activeTouches[event.pointer] = _getLocalPosition(event);
    });
  }

  void _handlePointerUp(PointerUpEvent event) {
    setState(() {
      _activeTouches.remove(event.pointer);
    });
    _checkGameEnd();
  }

  Offset _getLocalPosition(PointerEvent event) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    return box.globalToLocal(event.position);
  }

  void _checkStartCountdown() {
    if (_activeTouches.length >= 3 && !_isCountingDown && !_isGameActive) {
      setState(() {
        _isCountingDown = true;
        _countdown = 3;
      });
      _startCountdown();
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
      });

      if (_countdown <= 0) {
        timer.cancel();
        setState(() {
          _isCountingDown = false;
          _isGameActive = true;
        });
      }
    });
  }

  void _checkGameEnd() {
    if (_isGameActive) {
      // Last player fails
      if (_activeTouches.length == 1) {
        setState(() {
          _isGameOver = true;
          _failingPointer = {
            _activeTouches.keys.first: _activeTouches.values.first
          }; // No specific pointer fails, everyone loses.
        });
      }
    }
  }

  void _restartGame() {
    setState(() {
      _activeTouches.clear();
      _isCountingDown = false;
      _isGameActive = false;
      _isGameOver = false;
      _failingPointer = null;
      _countdown = 3;
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
