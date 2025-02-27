import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  // singleton instance
  static AdManager instance = AdManager();

  // 스크린 별로 사용될 AdManagerBannerAd 객체들
  AdManagerBannerAd? homeBannerAd;
  AdManagerBannerAd? randomGameBannerAd;
  AdManagerBannerAd? guessingGameBannerAd;
  AdManagerBannerAd? touchRouletteGameBannerAd;
  AdManagerBannerAd? russianRouletteGameBannerAd;

  AdManager({
    this.homeBannerAd,
    this.randomGameBannerAd,
    this.guessingGameBannerAd,
    this.touchRouletteGameBannerAd,
    this.russianRouletteGameBannerAd,
  });

  // AdManager 객체 초기화
  factory AdManager.init() => instance = AdManager(
        homeBannerAd: _loadBannerAd(
          homeBannerAdId,
        ),
        randomGameBannerAd: _loadBannerAd(
          randomGameBannerAdId,
        ),
        guessingGameBannerAd: _loadBannerAd(
          guessingGameBannerAdId,
        ),
        touchRouletteGameBannerAd: _loadBannerAd(
          touchRouletteGameBannerAdId
        ),
        russianRouletteGameBannerAd: _loadBannerAd(
          russianRouletteGameBannerAdId
        ),
      );
}

final homeBannerAdId = kDebugMode
// 테스트 광고 ID
    ? Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/9214589741'
        : 'ca-app-pub-3940256099942544/2435281174'
// 실제 광고 ID
    : Platform.isAndroid
        ? 'ca-app-pub-3749644430343897/1482926499'
        : 'ca-app-pub-3749644430343897/2370462752';

final randomGameBannerAdId = kDebugMode
    ? Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/9214589741'
        : 'ca-app-pub-3940256099942544/2435281174'
    : Platform.isAndroid
        ? 'ca-app-pub-3749644430343897/4890315318'
        : 'ca-app-pub-3749644430343897/8850280626';

final guessingGameBannerAdId = kDebugMode
    ? Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/9214589741'
        : 'ca-app-pub-3940256099942544/2435281174'
    : Platform.isAndroid
        ? 'ca-app-pub-3749644430343897/3952638161'
        : 'ca-app-pub-3749644430343897/7537198955';

final touchRouletteGameBannerAdId = kDebugMode
    ? Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/9214589741'
        : 'ca-app-pub-3940256099942544/2435281174'
    : Platform.isAndroid
        ? 'ca-app-pub-3749644430343897/1031500354'
        : 'ca-app-pub-3749644430343897/2132296207';

final russianRouletteGameBannerAdId = kDebugMode
    ? Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/9214589741'
        : 'ca-app-pub-3940256099942544/2435281174'
    : Platform.isAndroid
        ? 'ca-app-pub-3749644430343897/6510779477'
        : 'ca-app-pub-3749644430343897/9105153225';

AdManagerBannerAd _loadBannerAd(String adUnitId) {
  return AdManagerBannerAd(
    adUnitId: adUnitId,
    request: const AdManagerAdRequest(),
    sizes: [AdSize.banner],
    listener: AdManagerBannerAdListener(),
  )..load();
}
