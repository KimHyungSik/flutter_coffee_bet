import 'dart:async';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../game_over.dart';

class TouchRouletteGame extends StatefulWidget {
  const TouchRouletteGame({super.key});

  @override
  State<TouchRouletteGame> createState() => _TouchRouletteGameState();
}

class _TouchRouletteGameState extends State<TouchRouletteGame> {
  static const List<Color> backGroundColorList = [
    Color(0xFFFFC1CC), // Pastel Pink
    Color(0xFFB2F5EA), // Pastel Mint
    Color(0xFFCCE5FF), // Pastel Blue
    Color(0xFFFFF2B2), // Pastel Yellow
    Color(0xFFE1C4FC), // Pastel Purple
  ];

  static Color? baseBackgroundColor = Colors.grey[900];

  bool _isGameActive = false;
  bool _isGameOver = false;
  Color? _backgroundColor = baseBackgroundColor;

  int _winnerChance = 30; // Initial chance of winning 30%

  final Random _random = Random();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: baseBackgroundColor,
      body: Stack(
        children: [
          GestureDetector(
            onTapDown: (_) => _changeColor(true), // Trigger on press
            onTapUp: (_) => _changeColor(false), // Reset on release
            onTapCancel: () => _changeColor(false), // Reset on cancel
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300), // Animation duration
              curve: Curves.easeInOut, // Smooth animation
              color: _backgroundColor,
              child: Container(),
            ),
          ),
          if (_isGameOver)
            GameOverWidget(
              title: context.tr("Loser"),
              onRestart: _restartGame,
              failingPointers: {},
            ),
          if (!_isGameActive)
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
                            "순서대로\n 터치해 주세요.",
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
            ),
        ],
      ),
    );
  }

  // Get a random pastel color from the list
  Color _getRandomColor() {
    return backGroundColorList[_random.nextInt(backGroundColorList.length)];
  }

  // Determine if the user wins based on the current chance
  bool _isWinner() {
    return _random.nextInt(100) < _winnerChance; // Variable chance
  }

  void _changeColor(bool isPressed) {
    if (_isGameOver) return;
    setState(() {
      _isGameActive = true;
      if (isPressed) {
        if (_isWinner()) {
          _backgroundColor = _getRandomColor();
          _gameOver();
        } else {
          _backgroundColor = _getRandomColor();
        }
      } else {
        _backgroundColor = baseBackgroundColor;
      }
    });
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
    });
    Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _isGameActive = false;
        _isGameOver = false;
      });
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
