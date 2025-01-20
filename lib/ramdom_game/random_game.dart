import 'dart:async';
import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  bool _painterVisible = true;
  int _countdown = 3;
  int _failingCount = 1;
  int? _selectedPointer; // Randomly selected pointer ID
  Map<int, Offset> _failingPointer = {};

  Timer? _randomizationTimer;
  Timer? _blankTimer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Stack(
        children: [
          if (_painterVisible)
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
              title: "당첨!",
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
                Container(
                  alignment: Alignment.center,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: IgnorePointer(
                          ignoring: true,
                          child: Text(
                            context.tr(
                                "Please_touch_2_or_more_people_at_the_same_time."),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: _buildFailingCountAdjuster(),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 40, left: 8),
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
    );
  }

  Widget _buildFailingCountAdjuster() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              child: IconButton(
                  onPressed: () {
                    setState(() {
                      if (_failingCount > 1) {
                        _failingCount--;
                      }
                    });
                  },
                  icon: SvgPicture.asset(
                    'assets/icon/icon_minus.svg',
                    colorFilter: const ColorFilter.mode(
                        Color(0xFF212121), BlendMode.srcIn),
                  )),
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Color(0xFF121212),
                ),
                height: 88,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        context.tr("Number_of_Loser"),
                        style: const TextStyle(
                          color: Color(0xFFcfcfcf),
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      Text(
                        '$_failingCount',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    if (_failingCount < 5) {
                      _failingCount++;
                    }
                  });
                },
                icon: SvgPicture.asset(
                  'assets/icon/icon_plus.svg',
                  colorFilter: const ColorFilter.mode(
                      Color(0xFF212121), BlendMode.srcIn),
                ),
              ),
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

    if (_activeTouches.isEmpty && !_isGameOver) {
      _restartGame();
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
      _blankPainter();
    }
  }

  void _blankPainter() {
    _blankTimer = Timer.periodic(const Duration(seconds: 400), (timer) {
      _painterVisible = !_painterVisible;
    });
  }

  void _startCountdown() {
    _randomizationTimer?.cancel();
    _randomizationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_activeTouches.isEmpty) {
        _restartGame();
      } else {
        setState(
          () {
            _countdown--;
          },
        );
      }

      if (_countdown <= 0) {
        timer.cancel();
        setState(() {
          _failingPointer.clear();
          _isCountingDown = false;
          _isGameActive = true;
        });
        _randomizeUser();
      }
    });
  }

  void _stopRandomizationTimer() {
    _blankTimer = null;
    _randomizationTimer?.cancel();
    _randomizationTimer = null;
  }

  void _randomizeUser() async {
    if (_activeTouches.isEmpty) return;

    setState(() {
      final random = Random();
      final keys = _activeTouches.keys.toList();
      // 선택할 유저 수를 제한
      int count = _failingCount.clamp(1, keys.length);
      List<int> selectedKeys = [];
      while (selectedKeys.length < count) {
        final randomKey = keys[random.nextInt(keys.length)];
        if (!selectedKeys.contains(randomKey)) {
          selectedKeys.add(randomKey);
        }
      }

      for (var key in selectedKeys) {
        _failingPointer[key] = _activeTouches[key]!;
      }

      for (var key in selectedKeys) {
        _failingPointer[key] = _activeTouches[key]!;
      }
      // _selectedPointer = keys[random.nextInt(keys.length)];

      // Remove all other circles except the selected one
      // _failingPointer![_selectedPointer!] = _activeTouches[_selectedPointer!]!;
      _activeTouches.clear();
      _isGameOver = true;
      _isGameActive = false;
    });
  }

  void _restartGame() {
    _stopRandomizationTimer();
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
    _randomizationTimer?.cancel();
    super.dispose();
  }
}
