import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vibration/vibration.dart';

import 'admob/banner_adb.dart';
import 'admob/interstitial_ad_manager.dart';
import 'home.dart';
import 'utils/vibration_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  AdManager.init();

  InterstitialAdManager.instance.loadInterstitialAd();

  await EasyLocalization.ensureInitialized();

  // Initialize vibration manager
  await VibrationManager.initialize();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  runApp(
    EasyLocalization(
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('de', 'DE'),
          Locale('ko', 'KR'),
          Locale('ja', 'JP'),
          Locale('es', 'ES'),
          Locale('fr', 'FR'),
          Locale('vi', 'VN'),
          Locale('th', 'TH')
        ],
        path: 'assets/translations',
        fallbackLocale: const Locale('en', 'US'),
        child: const MainScreen()),
  );
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomeScreen(),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
    );
  }
}