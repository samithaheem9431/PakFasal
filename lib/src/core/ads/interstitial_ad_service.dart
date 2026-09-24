import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ad_unit_ids.dart';

/// Named placements that share the same interstitial creative but keep
/// independent click counters (every 3rd action shows an ad).
enum AdPlacement {
  sensorModule,
  getAdvice,
  profitCalculator,
}

extension on AdPlacement {
  String get prefsKey => 'ad_click_count_$name';
}

/// Loads / shows AdMob interstitials with per-placement frequency capping.
///
/// Rule: on the 3rd, 6th, 9th… tap of a placement, show a full-screen
/// interstitial (if one is ready). Duration is controlled by the ad creative
/// (typically a few seconds before the close button appears).
class InterstitialAdService {
  InterstitialAdService._();

  static final InterstitialAdService instance = InterstitialAdService._();

  static const int showEveryNthClick = 3;

  InterstitialAd? _interstitial;
  bool _isLoading = false;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    if (kIsWeb) {
      _initialized = true;
      return;
    }
    try {
      await MobileAds.instance.initialize();
      _initialized = true;
      unawaited(preload());
    } catch (e, st) {
      debugPrint('AdMob init failed: $e\n$st');
      _initialized = true;
    }
  }

  Future<void> preload() async {
    if (kIsWeb || _isLoading || _interstitial != null) return;
    _isLoading = true;
    try {
      await InterstitialAd.load(
        adUnitId: AdUnitIds.interstitial,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitial = ad;
            _isLoading = false;
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                _interstitial = null;
                unawaited(preload());
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                debugPrint('Interstitial show failed: $error');
                ad.dispose();
                _interstitial = null;
                unawaited(preload());
              },
            );
          },
          onAdFailedToLoad: (error) {
            debugPrint('Interstitial load failed: $error');
            _isLoading = false;
            _interstitial = null;
          },
        ),
      );
    } catch (e, st) {
      debugPrint('Interstitial load exception: $e\n$st');
      _isLoading = false;
    }
  }

  /// Increments the placement counter; shows an interstitial when due, then
  /// always runs [action] (even if the ad failed / wasn't ready).
  Future<void> runAfterAdGate(
    AdPlacement placement,
    FutureOr<void> Function() action,
  ) async {
    final shouldShow = await _shouldShowAndBump(placement);
    if (shouldShow) {
      await _showReadyAd();
    }
    await action();
  }

  Future<bool> _shouldShowAndBump(AdPlacement placement) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final next = (prefs.getInt(placement.prefsKey) ?? 0) + 1;
      await prefs.setInt(placement.prefsKey, next);
      return next % showEveryNthClick == 0;
    } catch (_) {
      return false;
    }
  }

  Future<void> _showReadyAd() async {
    final ad = _interstitial;
    if (ad == null) {
      unawaited(preload());
      return;
    }

    final completer = Completer<void>();
    final previous = ad.fullScreenContentCallback;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (shown) {
        previous?.onAdDismissedFullScreenContent?.call(shown);
        if (!completer.isCompleted) completer.complete();
      },
      onAdFailedToShowFullScreenContent: (shown, error) {
        previous?.onAdFailedToShowFullScreenContent?.call(shown, error);
        if (!completer.isCompleted) completer.complete();
      },
      onAdShowedFullScreenContent: previous?.onAdShowedFullScreenContent,
      onAdImpression: previous?.onAdImpression,
      onAdClicked: previous?.onAdClicked,
      onAdWillDismissFullScreenContent:
          previous?.onAdWillDismissFullScreenContent,
    );

    try {
      _interstitial = null;
      await ad.show();
      await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () {},
      );
    } catch (e, st) {
      debugPrint('Interstitial show exception: $e\n$st');
      ad.dispose();
      unawaited(preload());
    }
  }
}
