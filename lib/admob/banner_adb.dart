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

  AdManager({
    this.homeBannerAd,
    this.randomGameBannerAd,
    this.guessingGameBannerAd,
  });

  // AdManager 객체 초기화
  factory AdManager.init() => instance = AdManager(
        homeBannerAd: _loadBannerAd(),
        randomGameBannerAd: _loadBannerAd(),
        guessingGameBannerAd: _loadBannerAd(),
      );
}

AdManagerBannerAd _loadBannerAd() {
  final adUnitId = kDebugMode
      ? Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/9214589741'
          : 'ca-app-pub-3940256099942544/2435281174'
      : Platform.isAndroid
          ? 'ca-app-pub-3749644430343897/1482926499'
          : 'ca-app-pub-3749644430343897/2370462752';

  return AdManagerBannerAd(
    adUnitId: adUnitId,
    request: const AdManagerAdRequest(),
    sizes: [AdSize.banner],
    listener: AdManagerBannerAdListener(),
  )..load();
}
