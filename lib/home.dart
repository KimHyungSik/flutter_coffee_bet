import 'dart:math';

import 'package:coffee_bet/guessing_game/guessing_game.dart';
import 'package:coffee_bet/ramdom_game/random_game.dart';
import 'package:coffee_bet/russian_roulette_gam/russian_roulettte_game.dart';
import 'package:coffee_bet/touch_roulette/touch_roulette_game.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'admob/interstitial_ad_manager.dart';
import 'draw_lots_game/draw_lots_game.dart';
import 'utils/vibration_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _vibrationEnabled = true;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    if (_random.nextInt(100) < 50) {
      InterstitialAdManager.instance.showInterstitialAd();
    }

    _loadVibrationSetting();
  }

  Future<void> _loadVibrationSetting() async {
    final isEnabled = VibrationManager.isVibrationEnabled();
    setState(() {
      _vibrationEnabled = isEnabled;
    });
  }

  Future<void> _toggleVibration() async {
    final isEnabled = await VibrationManager.toggleVibration();
    setState(() {
      _vibrationEnabled = isEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 40, right: 16),
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: _toggleVibration,
                icon: Icon(
                  _vibrationEnabled
                      ? Icons.vibration
                      : Icons.phonelink_erase_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
          Align(
            alignment: const AlignmentDirectional(0, 0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _homeButton(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RandomGameApp()),
                      );
                    },
                    title: context.tr("Random_Game"),
                  ),
                  const SizedBox(height: 16),
                  _homeButton(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DrawingLotsGameApp(),
                        ),
                      );
                    },
                    title: context.tr("DrawingLots_Game"),
                  ),
                  const SizedBox(height: 16),
                  _homeButton(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const GuessingGameApp()),
                      );
                    },
                    title: context.tr("Sense_Game"),
                  ),
                  const SizedBox(height: 16),
                  _homeButton(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TouchRouletteGame(),
                        ),
                      );
                    },
                    title: context.tr("Touch_Roulette"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _homeButton({required Function() onTap, required String title}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF434343),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  color: Colors.yellow,
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 14, 0, 10),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
