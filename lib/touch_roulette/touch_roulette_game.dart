import 'dart:async';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../common/button/start_button.dart';
import '../game_over.dart';
import '../user_circle_painter.dart';

class TouchRouletteGame extends StatefulWidget {
  const TouchRouletteGame({super.key});

  @override
  State<TouchRouletteGame> createState() => _TouchRouletteGameState();
}

class _TouchRouletteGameState extends State<TouchRouletteGame> {
  static Color? baseBackgroundColor = Colors.grey[900];

  bool _isGameActive = false;
  bool _isGameOver = false;
  Color? _backgroundColor = baseBackgroundColor;

  int _winnerChance = 30; // Initial chance of winning 30%
  final Map<int, Offset> _activeTouches = {};
  final Random _random = Random();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: baseBackgroundColor,
      body: Stack(
        children: [
          Listener(
            onPointerDown: _touchScreen, // Tr Reset on cancel
            child: CustomPaint(
              painter: UserCirclePainter(_activeTouches),
              child: Container(), // Covers the entire screen
            ),
          ),
          if (_isGameOver)
            GameOverWidget(
              title: context.tr("Loser"),
              onRestart: _restartGame,
              failingPointers: {},
            ),
          if (!_isGameActive)
            readyGame(context),
        ],
      ),
    );
  }

  Stack readyGame(BuildContext context) {
    return Stack(
            children: [
              Container(
                alignment: Alignment.center,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IgnorePointer(
                            ignoring: true,
                            child: Text(
                              "순서대로\n 터치해 주세요.",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 22,),
                          startButton(() {
                            setState(() {
                              _isGameActive = true;
                            });
                          }),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _buildButtonAdjuster(),
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
          );
  }

  bool _isWinner() {
    return _random.nextInt(100) < _winnerChance; // Variable chance
  }

  void _touchScreen(PointerDownEvent event) {
    if (_isGameOver  || !_isGameActive) return;
    setState(() {
      _activeTouches[event.pointer] = _getLocalPosition(event);
      if (_isWinner()) {
        _gameOver();
      }
    });
  }

  Offset _getLocalPosition(PointerEvent event) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    return box.globalToLocal(event.position);
  }

  void _gameOver() {
    setState(() {
      _isGameOver = true;
    });
  }

  void _increaseChance() {
    setState(() {
      if (_winnerChance < 95) {
        _winnerChance += 5; // Increase chance by 5% (maximum 100%)
      }
    });
  }

  void _decreaseChance() {
    setState(() {
      if (_winnerChance > 5) {
        _winnerChance -= 5; // Decrease chance by 5% (minimum 0%)
      }
    });
  }

  void _restartGame() {
    setState(() {
      _backgroundColor = baseBackgroundColor;
      _isGameActive = false;
      _isGameOver = false;
      _activeTouches.clear();
    });
  }

  Widget _buildButtonAdjuster() {
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
                  onPressed: _decreaseChance,
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
                        "당첨확룰",
                        style: const TextStyle(
                          color: Color(0xFFcfcfcf),
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      Text(
                        '$_winnerChance%',
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
                onPressed: _increaseChance,
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
}
