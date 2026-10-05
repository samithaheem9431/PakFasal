import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'src/app.dart';
import 'src/core/ads/interstitial_ad_service.dart';
import 'src/core/config/app_config.dart';
import 'src/core/error/error_logger.dart';
import 'src/core/localization/localization_controller.dart';
import 'src/core/performance/device_performance.dart';
import 'src/core/theme/app_colors.dart';
import 'src/core/theme/theme_controller.dart';
import 'src/features/auth/presentation/providers/auth_session_controller.dart';
import 'src/features/auth/presentation/providers/biometric_lock_controller.dart';
import 'src/features/crop_calendar/data/repositories/guest_crop_planting_store.dart';
import 'src/features/crop_calendar/presentation/providers/crop_calendar_provider.dart';
import 'src/features/learning/data/repositories/crop_diseases_repository.dart';
import 'src/features/marketplace/data/repositories/marketplace_repository.dart';
import 'src/features/profit_calculator/data/season_calculation_store.dart';
import 'src/features/weather/presentation/providers/weather_provider.dart';

Future<void> main() async {
  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: AppColors.white,
          systemNavigationBarDividerColor: AppColors.white,
          systemNavigationBarContrastEnforced: false,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );
      DevicePerformance.init();

      // Critical path only — open Hive boxes in parallel (not one-by-one).
      await AppConfig.init();
      await Future.wait([
        Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
        Hive.initFlutter(),
      ]);

      await Future.wait([
        Hive.openBox('app_preferences'),
        Hive.openBox('weather_cache'),
        Hive.openBox('learning_cache'),
        Hive.openBox('govt_schemes_cache'),
        Hive.openBox(MarketplaceRepository.cacheBoxName),
        Hive.openBox(GuestCropPlantingStore.boxName),
        Hive.openBox(SeasonCalculationStore.boxName),
      ]);

      // Crashlytics + AdMob after first frame so they don't block splash paint.
      unawaited(
        Future(() async {
          await ErrorLogger.instance.init();
          await InterstitialAdService.instance.init();
        }),
      );

      // Warm Pests & Diseases metadata + images in the background so the
      // Learning module opens from disk cache instead of waiting on network.
      unawaited(_warmLearningPestsDiseasesCache());

      final authController = AuthSessionController();
      final biometricLockController = BiometricLockController();
      // Mirror the signed-in user id into Crashlytics so reports are grouped
      // per user. Fires immediately for the current state and on each change.
      void syncCrashlyticsUser() {
        ErrorLogger.instance.setUserId(authController.userId);
      }
      authController.addListener(syncCrashlyticsUser);
      syncCrashlyticsUser();
      biometricLockController.onSessionChanged(
        hasRegisteredUser:
            authController.currentUser != null && !authController.isGuestUser,
        userId: authController.userId,
      );

      runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: authController),
            ChangeNotifierProvider.value(value: biometricLockController),
            ChangeNotifierProxyProvider<AuthSessionController, LocalizationController>(
              create: (_) => LocalizationController(),
              update: (_, auth, localizationController) {
                final controller =
                    localizationController ?? LocalizationController();
                controller.onUserChanged(auth.userId);
                return controller;
              },
            ),
            ChangeNotifierProxyProvider<AuthSessionController, ThemeController>(
              create: (_) => ThemeController(),
              update: (_, auth, themeController) {
                final controller = themeController ?? ThemeController();
                controller.onUserChanged(auth.userId);
                return controller;
              },
            ),
            // Weather refresh starts when Home mounts — not at cold start.
            ChangeNotifierProvider(create: (_) => WeatherProvider()),
            ChangeNotifierProvider(
              create: (_) => CropCalendarProvider(),
            ),
          ],
          child: const PakFasalApp(),
        ),
      );
    },
    (error, stack) {
      ErrorLogger.instance.recordNonFatal(
        error,
        stack,
        context: 'uncaught_zone_error',
      );
    },
  );
}

Future<void> _warmLearningPestsDiseasesCache() async {
  try {
    await CropDiseasesRepository().fetchCropDiseases();
  } catch (_) {
    // Offline / first-run without network — ignore; screen will retry later.
  }
}
