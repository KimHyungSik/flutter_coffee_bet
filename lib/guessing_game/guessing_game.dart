import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../admob/banner_adb.dart';
import '../game_over.dart';
import '../user_circle_painter.dart';

class GuessingGameApp extends StatelessWidget {
  const GuessingGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const GameScreen();
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
  final Map<int, Offset> _releaseOffset = {};

  static const int MAX_GAME_PLAY = 5;

  bool _isGameActive = false; // Tracks if the game has started
  bool _isGameOver = false; // Tracks if the game has ended
  Map<int, Offset>? _failingPointer;

  bool _isCountingDown = false; // Tracks if the countdown has started
  int _countdown = 3; // Countdown timer value
  Timer? _countdownTimer; // Timer instance

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                if (!_isGameOver)
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
                if (_isGameOver)
                  GameOverWidget(
                    title: context.tr("Loser"),
                    onRestart: _restartGame,
                    failingPointers: _failingPointer ?? {},
                  ),
                if (!_isCountingDown && !_isGameActive && !_isGameOver)
                  Stack(
                    children: [
                      IgnorePointer(
                        ignoring: true,
                        child: Center(
                          child: Text(
                            context.tr(
                                "Please_touch_3_or_more_people_at_the_same_time."),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
                      )
                    ],
                  )
              ],
            ),
          ),
          AdManager.instance.guessingGameBannerAd == null
              ? Container()
              : SizedBox(
            width: AdManager
                .instance.guessingGameBannerAd!.sizes.first.width
                .toDouble(),
            height: AdManager
                .instance.guessingGameBannerAd!.sizes.first.height
                .toDouble(),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: AdWidget(
                  ad: AdManager.instance.guessingGameBannerAd!),
            ),
          ),
        ],
      ),
    );
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (_isGameOver && _isGameActive) return;
    if (_isGameActive || _activeTouches.length >= MAX_GAME_PLAY) return;

    setState(() {
      _activeTouches[event.pointer] = _getLocalPosition(event);
    });
    _checkStartCountdown();
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (_isGameOver) return;
    if (!_activeTouches.containsKey(event.pointer)) {
      return; // Prevent new players from moving their circle after game starts
    }

    setState(() {
      _activeTouches[event.pointer] = _getLocalPosition(event);
    });
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (_activeTouches[event.pointer] == null) return;
    setState(() {
      _releaseTimes[event.pointer] = DateTime.now();
      _releaseOffset[event.pointer] = _activeTouches[event.pointer]!;
      _activeTouches.remove(event.pointer);
    });
    if (_activeTouches.isEmpty && !_isGameOver) {
      _restartGame();
    }
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
          _releaseTimes.clear();
          _releaseOffset.clear();
        });
      }
    });
  }

  Future<void> _checkGameEnd() async {
    if (_isGameActive) {
      if (await _checkSimultaneousReleases()) {
        return;
      }
      // Last player fails
      if (_activeTouches.length == 1) {
        setState(() {
          _isGameOver = true;
          _isGameActive = false;
          _failingPointer = {
            _activeTouches.keys.first: _activeTouches.values.first
          }; // No specific pointer fails, everyone loses.
        });
      }
    }
  }

  Future<bool> _checkSimultaneousReleases() async {
    // If fewer than two releases, no simultaneous check is needed
    await Future.delayed(const Duration(milliseconds: 100));
    if (_releaseTimes.length < 2 && _isGameActive) return false;

    List<int> simultaneousFailures =
        []; // Store the pointer IDs of failed players
    List<int> releaseKeys = _releaseTimes.keys.toList();

    for (int i = 0; i < releaseKeys.length; i++) {
      for (int j = 0; j < releaseKeys.length; j++) {
        if (i == j) break;
        final int pointer1 = releaseKeys[i];
        final int pointer2 = releaseKeys[j];
        final DateTime time1 = _releaseTimes[pointer1]!;
        final DateTime time2 = _releaseTimes[pointer2]!;

        // Check if the releases are within 0.5 seconds of each other
        if (time2.difference(time1).inMilliseconds.abs() <= 100) {
          if (!simultaneousFailures.contains(pointer1)) {
            simultaneousFailures.add(pointer1);
          }
          if (!simultaneousFailures.contains(pointer2)) {
            simultaneousFailures.add(pointer2);
          }
        }
      }
    }

    // Handle simultaneous failures
    if (simultaneousFailures.isNotEmpty) {
      Map<int, Offset> simultaneousFailureUsers = {
        for (var key in simultaneousFailures)
          if (_releaseOffset.containsKey(key)) key: _releaseOffset[key]!,
      };
      setState(() {
        _isGameOver = true; // End the game
        _isGameActive = false;
        _failingPointer =
            simultaneousFailureUsers; // No specific single failure
      });
    }
    return simultaneousFailures.isNotEmpty;
  }

  void _restartGame() {
    setState(() {
      _countdownTimer?.cancel();
      _countdownTimer = null;
      _activeTouches.clear();
      _isCountingDown = false;
      _isGameActive = false;
      _isGameOver = false;
      _failingPointer = null;
      _countdown = 3;
      _releaseTimes.clear();
      _releaseOffset.clear();
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
