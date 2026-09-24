import 'dart:io' show Platform;

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';

final _logger = Logger();

/// Google's official TEST ad unit IDs (documented at
/// https://developers.google.com/admob/flutter/test-ads) — always serve
/// test creatives, safe to ship. Replace with goen's real AdMob ad unit
/// IDs (from the AdMob console, one app + one banner + one interstitial
/// unit) before a production release.
class AdService {
  AdService._();

  static const _testBannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const _testBannerIOS = 'ca-app-pub-3940256099942544/2934735716';
  static const _testInterstitialAndroid =
      'ca-app-pub-3940256099942544/1033173712';
  static const _testInterstitialIOS =
      'ca-app-pub-3940256099942544/4411468910';

  static String get bannerAdUnitId =>
      Platform.isIOS ? _testBannerIOS : _testBannerAndroid;

  static String get interstitialAdUnitId =>
      Platform.isIOS ? _testInterstitialIOS : _testInterstitialAndroid;

  static Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
      _logger.i('📢 AdMob initialized');
    } catch (e) {
      _logger.e('❌ AdMob initialization failed: $e');
    }
  }
}

/// 対局終了時など、節目でインタースティシャル広告を出すためのコント
/// ローラー。事前ロード(preload)しておき、見せたいタイミングでshow()を
/// 呼ぶ。ロードが間に合っていなければ何も表示せず静かに諦める
/// (対局結果画面を広告待ちでブロックしたくないため)。
class InterstitialAdController {
  InterstitialAd? _ad;
  bool _isLoading = false;

  void preload() {
    if (_ad != null || _isLoading) return;
    _isLoading = true;
    InterstitialAd.load(
      adUnitId: AdService.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _isLoading = false;
        },
        onAdFailedToLoad: (error) {
          _logger.w('Interstitial ad failed to load: $error');
          _isLoading = false;
        },
      ),
    );
  }

  Future<void> showIfAvailable() async {
    final ad = _ad;
    if (ad == null) return;
    _ad = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        preload(); // 次回の対局終了に備えて次の1本を先読みしておく
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _logger.w('Interstitial ad failed to show: $error');
        ad.dispose();
      },
    );
    await ad.show();
  }

  void dispose() {
    _ad?.dispose();
    _ad = null;
  }
}
