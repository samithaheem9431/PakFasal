import 'dart:io';

import 'package:flutter/foundation.dart';

/// AdMob app + ad unit IDs.
///
/// Defaults are Google's official **test** IDs so debug builds never risk
/// invalid traffic. Override for production with:
/// `--dart-define=ADMOB_ANDROID_APP_ID=...` etc.
class AdUnitIds {
  AdUnitIds._();

  // Google sample App IDs (safe for development).
  static const String _testAndroidAppId =
      'ca-app-pub-3940256099942544~3347511713';
  static const String _testIosAppId =
      'ca-app-pub-3940256099942544~1458002511';

  // Google sample interstitial unit IDs.
  static const String _testAndroidInterstitial =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testIosInterstitial =
      'ca-app-pub-3940256099942544/4411468910';

  // Google sample banner unit IDs.
  static const String _testAndroidBanner =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testIosBanner =
      'ca-app-pub-3940256099942544/2934735716';

  static const String _envAndroidAppId = String.fromEnvironment(
    'ADMOB_ANDROID_APP_ID',
    defaultValue: '',
  );
  static const String _envIosAppId = String.fromEnvironment(
    'ADMOB_IOS_APP_ID',
    defaultValue: '',
  );
  static const String _envAndroidInterstitial = String.fromEnvironment(
    'ADMOB_ANDROID_INTERSTITIAL_ID',
    defaultValue: '',
  );
  static const String _envIosInterstitial = String.fromEnvironment(
    'ADMOB_IOS_INTERSTITIAL_ID',
    defaultValue: '',
  );
  static const String _envAndroidBanner = String.fromEnvironment(
    'ADMOB_ANDROID_BANNER_ID',
    defaultValue: '',
  );
  static const String _envIosBanner = String.fromEnvironment(
    'ADMOB_IOS_BANNER_ID',
    defaultValue: '',
  );

  static String get appId {
    if (kIsWeb) return _testAndroidAppId;
    if (Platform.isIOS) {
      return _envIosAppId.isNotEmpty ? _envIosAppId : _testIosAppId;
    }
    return _envAndroidAppId.isNotEmpty ? _envAndroidAppId : _testAndroidAppId;
  }

  static String get interstitial {
    if (kIsWeb) return _testAndroidInterstitial;
    if (Platform.isIOS) {
      return _envIosInterstitial.isNotEmpty
          ? _envIosInterstitial
          : _testIosInterstitial;
    }
    return _envAndroidInterstitial.isNotEmpty
        ? _envAndroidInterstitial
        : _testAndroidInterstitial;
  }

  static String get banner {
    if (kIsWeb) return _testAndroidBanner;
    if (Platform.isIOS) {
      return _envIosBanner.isNotEmpty ? _envIosBanner : _testIosBanner;
    }
    return _envAndroidBanner.isNotEmpty
        ? _envAndroidBanner
        : _testAndroidBanner;
  }
}
