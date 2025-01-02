import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../game_over.dart';
import '../user_circle_painter.dart';

class RandomGameApp extends StatelessWidget {
  const RandomGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const RandomGameScreen();
  }
}

class RandomGameScreen extends StatefulWidget {
  const RandomGameScreen({super.key});

  @override
  _RandomGameScreenState createState() => _RandomGameScreenState();
}

class _RandomGameScreenState extends State<RandomGameScreen>
    with SingleTickerProviderStateMixin {
  final Map<int, Offset> _activeTouches = {};
  static const int MAX_GAME_PLAY = 5;

  bool _isCountingDown = false;
  bool _isGameActive = false;
  bool _isGameOver = false; // Tracks if the game has ended
  bool _isRandomizing = false;
  int _countdown = 3;
  int? _selectedPointer; // Randomly selected pointer ID
  Map<int, Offset> _failingPointer = {};

  Timer? _randomizationTimer;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true); // Makes the animation repeat for the flashing effect
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Stack(
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
            if (_isGameOver)
              GameOverWidget(
                onRestart: _restartGame,
                failingPointers: _failingPointer ?? {},
              ),
            if (_isCountingDown)
              IgnorePointer(
                ignoring: true,
                child: Center(
                  child: Text(
                    '$_countdown',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            if (!_isCountingDown && !_isGameActive && !_isGameOver)
              Stack(
                children: [
                  const IgnorePointer(
                    ignoring: true,
                    child: Center(
                      child: Text(
                        'Touch and hold\nwith at least 2 fingers!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 8, left: 8),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        iconSize: 36,
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (_isGameActive || _activeTouches.length >= MAX_GAME_PLAY) return;

    setState(() {
      _activeTouches[event.pointer] = _getLocalPosition(event);
    });

    _startRandomizationTimer();
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (!_activeTouches.containsKey(event.pointer)) return;

    setState(() {
      _activeTouches[event.pointer] = _getLocalPosition(event);
    });
  }

  void _handlePointerUp(PointerUpEvent event) {
    setState(() {
      _activeTouches.remove(event.pointer);
    });

    if (_activeTouches.isEmpty) {
      _stopRandomizationTimer();
    }
  }

  Offset _getLocalPosition(PointerEvent event) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    return box.globalToLocal(event.position);
  }

  void _startRandomizationTimer() {
    if (_activeTouches.length >= 2 && !_isCountingDown && !_isGameActive) {
      setState(() {
        _isCountingDown = true;
        _countdown = 3;
      });
      _startCountdown();
    }
  }

  void _startCountdown() {
    _randomizationTimer?.cancel();
    _randomizationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
      });

      if (_countdown <= 0) {
        timer.cancel();
        setState(() {
          _failingPointer.clear();
          _isCountingDown = false;
          _isGameActive = true;
          _isRandomizing = true;
        });
        _randomizeUser();
      }
    });
  }

  void _stopRandomizationTimer() {
    _randomizationTimer?.cancel();
    _randomizationTimer = null;
  }

  void _randomizeUser() async {
    if (_activeTouches.isEmpty) return;

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        final random = Random();
        final keys = _activeTouches.keys.toList();
        _selectedPointer = keys[random.nextInt(keys.length)];
        _isRandomizing = false;

        // Remove all other circles except the selected one
        _failingPointer![_selectedPointer!] = _activeTouches[_selectedPointer!]!;
        print("LOGEE 1 _failingPointer  $_failingPointer");
        _activeTouches.clear();
        _isGameOver = true;
        _isGameActive = false;
      });
    });
  }

  void _restartGame() {
    setState(() {
      _activeTouches.clear();
      _isCountingDown = false;
      _isGameActive = false;
      _isGameOver = false;
      _countdown = 3;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _randomizationTimer?.cancel();
    super.dispose();
  }
}
