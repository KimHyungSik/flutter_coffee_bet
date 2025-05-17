import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class InterstitialAdManager {
  static InterstitialAdManager? _instance;
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  bool _isLoading = false;
  Timer? _loadTimer;
  int _retryAttempt = 0;
  final int _maxRetryAttempt = 3;

  // Create a completer to track when the ad is loaded
  Completer<bool>? _adLoadCompleter;

  static InterstitialAdManager get instance {
    _instance ??= InterstitialAdManager._();
    return _instance!;
  }

  InterstitialAdManager._();

  bool get isAdLoaded => _isAdLoaded;

  /// Loads an interstitial ad asynchronously
  /// Returns a Future that completes when the ad is loaded or fails
  Future<bool> loadInterstitialAd() async {
    // If an ad is already loaded, return true immediately
    if (_isAdLoaded && _interstitialAd != null) {
      return true;
    }

    // If an ad is already being loaded, return the existing completer
    if (_isLoading && _adLoadCompleter != null) {
      return _adLoadCompleter!.future;
    }

    // Create a new completer to track this load attempt
    _adLoadCompleter = Completer<bool>();
    _isLoading = true;

    // Cancel any existing load timer
    _loadTimer?.cancel();

    await InterstitialAd.load(
      adUnitId: _getInterstitialAdUnitId(),
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
          _isLoading = false;
          _retryAttempt = 0;

          // Set up ad callbacks
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              _handleAdClosed();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isAdLoaded = false;
              _interstitialAd = null;
              // Reload ad for next time
              _scheduleAdLoad();
            },
          );

          // Complete the future with success
          if (!_adLoadCompleter!.isCompleted) {
            _adLoadCompleter!.complete(true);
          }
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isAdLoaded = false;
          _isLoading = false;
          _interstitialAd = null;
          _retryAttempt++;

          // Schedule retry if under max attempts
          if (_retryAttempt <= _maxRetryAttempt) {
            _scheduleAdLoad();
          }

          // Complete the future with failure
          if (!_adLoadCompleter!.isCompleted) {
            _adLoadCompleter!.complete(false);
          }
        },
      ),
    );

    return _adLoadCompleter!.future;
  }

  /// Shows the interstitial ad if it's loaded
  /// Returns true if ad was shown, false otherwise
  Future<bool> showInterstitialAd() async {
    // If ad is not loaded, try to load it first
    if (!_isAdLoaded || _interstitialAd == null) {
      final loaded = await loadInterstitialAd();
      if (!loaded) return false;
    }

    // If ad is ready, show it
    if (_isAdLoaded && _interstitialAd != null) {
      try {
        await _interstitialAd!.show();
        return true;
      } catch (e) {
        _handleAdClosed();
        return false;
      }
    }
    
    return false;
  }

  void _handleAdClosed() {
    if (_interstitialAd != null) {
      _interstitialAd!.dispose();
    }
    _isAdLoaded = false;
    _interstitialAd = null;
    
    // Preload next ad
    _scheduleAdLoad();
  }

  void _scheduleAdLoad() {
    // Cancel any existing timer
    _loadTimer?.cancel();
    
    // Schedule ad load with backoff based on retry attempts
    final delay = Duration(seconds: _retryAttempt > 0 ? 2 * _retryAttempt : 1);
    _loadTimer = Timer(delay, () {
      loadInterstitialAd();
    });
  }

  String _getInterstitialAdUnitId() {
    if (kDebugMode) {
      // Test ad IDs
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712'
          : 'ca-app-pub-3940256099942544/4411468910';
    } else {
      // Production ad IDs
      return Platform.isAndroid
          ? 'ca-app-pub-3749644430343897/8876680211'
          : 'ca-app-pub-3749644430343897/1796266545';
    }
  }

  void dispose() {
    _loadTimer?.cancel();
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isAdLoaded = false;
  }
}