import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class InterstitialAdManager {
  static InterstitialAdManager? _instance;
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;

  static InterstitialAdManager get instance {
    _instance ??= InterstitialAdManager._();
    return _instance!;
  }

  InterstitialAdManager._();

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _getInterstitialAdUnitId(),
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          print("LOGEE : InterstitialAd loaded $ad");
          _interstitialAd = ad;
          _isAdLoaded = true;

          // 광고가 닫힐 때 다시 로드하는 콜백 설정
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              _isAdLoaded = false;
              _interstitialAd = null;
              loadInterstitialAd(); // 광고가 닫히면 새 광고 로드
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              _isAdLoaded = false;
              _interstitialAd = null;
              loadInterstitialAd(); // 광고 표시 실패 시 새 광고 로드
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          print("LOGEE : InterstitialAd failed to load $error");
          _isAdLoaded = false;
          _interstitialAd = null;
        },
      ),
    );
  }

  bool get isAdLoaded => _isAdLoaded;

  void showInterstitialAd() {
    print("LOGEE : showInterstitialAd() called $_isAdLoaded $_interstitialAd");
    if (_isAdLoaded && _interstitialAd != null) {
      _interstitialAd!.show();
      _isAdLoaded = false;
    } else {
      Future.delayed(const Duration(seconds: 1), () {
        if (_isAdLoaded && _interstitialAd != null) {
          _interstitialAd!.show();
        }
      });
    }
  }

  String _getInterstitialAdUnitId() {
    if (kDebugMode) {
      // 테스트 광고 ID
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712'
          : 'ca-app-pub-3940256099942544/4411468910';
    } else {
      // 실제 광고 ID - 실제 ID로 변경 필요
      return Platform.isAndroid
          ? 'ca-app-pub-3749644430343897/8876680211'
          : 'ca-app-pub-3749644430343897/1796266545'; // 실제 iOS 전면광고 ID로 교체 필요
    }
  }

  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isAdLoaded = false;
  }
}
