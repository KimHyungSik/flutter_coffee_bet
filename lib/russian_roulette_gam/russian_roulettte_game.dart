import 'dart:async';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../admob/banner_adb.dart';
import '../common/button/start_button.dart';
import '../utils/vibration_manager.dart';
import '../game_over.dart';

class RussianRouletteGame extends StatefulWidget {
  const RussianRouletteGame({super.key});

  @override
  State<RussianRouletteGame> createState() => _RussianRouletteGameState();
}

class _RussianRouletteGameState extends State<RussianRouletteGame> {
  static Color? baseBackgroundColor = Colors.grey[900];
  static const List<Color> chamberColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.cyan,
    Colors.brown
  ];

  bool _isGameActive = false;
  bool _isGameOver = false;
  Color? _backgroundColor = baseBackgroundColor;

  // 총의 실린더를 나타내는 변수들
  int _chamberCount = 6; // 총 실린더 칸 수
  int _bulletPosition = 0; // 총알이 있는 위치
  int _currentPosition = 0; // 현재 발사 위치
  int _roundsWon = 0; // 승리한 라운드 수
  bool _canFire = true; // 총을 쏠 수 있는지 여부
  final List<int> _usedChambers = []; // 사용된 챔버 목록

  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _resetChambers();
  }

  void _resetChambers() {
    // 총알 위치를 랜덤으로 결정
    _bulletPosition = _random.nextInt(_chamberCount);
    _currentPosition = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: baseBackgroundColor,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                if (_isGameActive && !_isGameOver) _buildGameScreen(),
                if (_isGameOver)
                  GameOverWidget(
                    title: context.tr("Loser"),
                    onRestart: _restartGame,
                    failingPointers: const {},
                  ),
                if (!_isGameActive) _readyGame(context),
              ],
            ),
          ),
          AdManager.instance.russianRouletteGameBannerAd == null
              ? Container()
              : SizedBox(
            width: AdManager
                .instance.russianRouletteGameBannerAd!.sizes.first.width
                .toDouble(),
            height: AdManager
                .instance.russianRouletteGameBannerAd!.sizes.first.height
                .toDouble(),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: AdWidget(
                  ad: AdManager.instance.russianRouletteGameBannerAd!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameScreen() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: _backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "$_currentPosition / $_chamberCount",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),
          _buildRevolver(),
          const SizedBox(height: 60),
          const SizedBox(width: 40),
          _buildActionButton(
            Icons.flash_on,
            _canFire ? Colors.red : Colors.grey,
            _fireChamber,
          ),
        ],
      ),
    );
  }

  Widget _buildRevolver() {
    return SizedBox(
      width: 300,
      height: 300,
      child: CustomPaint(
        painter: RevolverPainter(
          chamberCount: _chamberCount,
          currentPosition: _currentPosition,
          chamberColors: chamberColors,
          usedChambers: _usedChambers,
          canFire: _canFire,
        ),
        size: const Size(300, 300),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, Function() onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(24),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 36,
      ),
    );
  }

  void _fireChamber() {
    if (_isGameOver) return;
    _canFire = false;

    // Vibrate for firing
    VibrationManager.vibrateCountdown();

    Timer(const Duration(milliseconds: 1000), () {
      setState(() {
        _canFire = true;
      });
    });

    setState(() {
      if (_currentPosition == _bulletPosition) {
        // 총알에 맞음 - 게임 오버
        Timer(const Duration(milliseconds: 800), () {
          _gameOver();
        });
      } else {
        // 생존 - 다음 칸으로 이동
        _usedChambers.add(_currentPosition);
        _currentPosition = (_currentPosition + 1) % _chamberCount;
        _roundsWon++;

        // 모든 칸을 돌았다면 승리
        if (_roundsWon >= _chamberCount - 1) {
          Timer(const Duration(milliseconds: 800), () {
            _gameOver();
          });
        }
      }
    });
  }

  Widget _readyGame(BuildContext context) {
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
                    Text(
                      context.tr("Spin_the_chamber_and_test_your_luck"),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),
                    startButton(() {
                      setState(() {
                        _isGameActive = true;
                        _resetChambers();
                      });
                    }),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _buildDifficultySelector(),
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

  Widget _buildDifficultySelector() {
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
                onPressed: _decreaseChamberCount,
                icon: SvgPicture.asset(
                  'assets/icon/icon_minus.svg',
                  colorFilter: const ColorFilter.mode(
                      Color(0xFF212121), BlendMode.srcIn),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xFF121212),
                ),
                height: 88,
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        context.tr("Chamber_count"),
                        style: const TextStyle(
                          color: Color(0xFFcfcfcf),
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      Text(
                        '$_chamberCount',
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
            const SizedBox(width: 8),
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              child: IconButton(
                onPressed: _increaseChamberCount,
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

  void _increaseChamberCount() {
    setState(() {
      if (_chamberCount < 12) {
        _chamberCount += 1;
      }
    });
  }

  void _decreaseChamberCount() {
    setState(() {
      if (_chamberCount > 2) {
        _chamberCount -= 1;
      }
    });
  }

  void _gameOver() {
    setState(() {
      _isGameOver = true;
    });

    // Vibrate for game over
    VibrationManager.vibrateGameOver();
  }

  void _restartGame() {
    setState(() {
      _backgroundColor = baseBackgroundColor;
      _isGameActive = false;
      _isGameOver = false;
      _roundsWon = 0;
      _usedChambers.clear();
      _resetChambers();
    });
  }
}

// UserCirclePainter와 유사한 디자인을 가진 RevolverPainter 클래스
class RevolverPainter extends CustomPainter {
  final int chamberCount;
  final int currentPosition;
  final List<Color> chamberColors;
  final List<int> usedChambers;
  final bool canFire;

  RevolverPainter({
    required this.chamberCount,
    required this.currentPosition,
    required this.chamberColors,
    required this.usedChambers,
    required this.canFire,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) * 0.45; // 실린더 크기 유지

    // 중앙 실린더 그리기
    final cylinderPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.grey[800]!;

    canvas.drawCircle(center, radius, cylinderPaint);

    // 챔버 크기 및 배치 반경 조정
    final chamberRadius = radius * 0.18; // 챔버 크기 살짝 줄이기
    final chamberDistance = radius * 0.65; // 챔버들이 더 중앙으로 이동

    final randomIndex = Random().nextInt(chamberColors.length);

    for (int i = 0; i < chamberCount; i++) {
      final angle = 2 * pi * i / chamberCount - pi / 2;
      final chamberCenter = Offset(
        center.dx + chamberDistance * cos(angle),
        center.dy + chamberDistance * sin(angle),
      );

      final circlePaint = Paint()
        ..style = PaintingStyle.fill
        ..color = usedChambers.contains(i)
            ? chamberColors[(i + randomIndex) % chamberColors.length]
            : Colors.white;

      final strokePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = (i == currentPosition && canFire) || usedChambers.contains(i)
            ? chamberColors[(i + randomIndex) % chamberColors.length]
            : Colors.white;

      // 챔버 크기 조정하여 더 중앙으로 배치
      canvas.drawCircle(chamberCenter, chamberRadius * 0.8, circlePaint);
      canvas.drawCircle(chamberCenter, chamberRadius, strokePaint);
    }

    // 중앙 원 크기 조정
    final centerCirclePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.grey[900]!;

    canvas.drawCircle(center, radius * 0.15, centerCirclePaint); // 유지
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}