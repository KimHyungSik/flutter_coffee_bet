import 'package:coffee_bet/guessing_game/guessing_game.dart';
import 'package:coffee_bet/ramdom_game/random_game.dart';
import 'package:coffee_bet/touch_roulette/touch_roulette_game.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'admob/banner_adb.dart';
import 'admob/full_width_banner.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Align(
              alignment: const AlignmentDirectional(0, 0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 16,
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
                      _homeButton(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TouchRouletteGame(),
                            ),
                          );
                        },
                        title: context.tr("Touch_Roulette"),
                      ),
                    ]),
              ),
            ),
          ),
          AdManager.instance.homeBannerAd == null
              ? Container()
              : SizedBox(
                  width: AdManager.instance.homeBannerAd!.sizes.first.width
                      .toDouble(),
                  height: AdManager.instance.homeBannerAd!.sizes.first.height
                      .toDouble(),
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: AdWidget(ad: AdManager.instance.homeBannerAd!)),
                ),
        ],
      ),
    );
  }

  Widget _homeButton({required Function() onTap, required String title}) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
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
