import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'src/app.dart';
import 'src/core/error/error_logger.dart';
import 'src/core/localization/localization_controller.dart';
import 'src/core/theme/theme_controller.dart';
import 'src/features/auth/presentation/providers/auth_session_controller.dart';
import 'src/features/weather/presentation/providers/weather_provider.dart';

Future<void> main() async {
  // runZonedGuarded catches async errors that aren't caught by
  // FlutterError.onError or PlatformDispatcher.onError (e.g. errors thrown
  // from Future callbacks before any await).
  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await ErrorLogger.instance.init();

      await Hive.initFlutter();
      await Hive.openBox('weather_cache');
      await Hive.openBox('learning_cache');
      await Hive.openBox('app_preferences');

      final authController = AuthSessionController();
      // Mirror the signed-in user id into Crashlytics so reports are grouped
      // per user. Fires immediately for the current state and on each change.
      void syncCrashlyticsUser() {
        ErrorLogger.instance.setUserId(authController.userId);
      }
      authController.addListener(syncCrashlyticsUser);
      syncCrashlyticsUser();

      runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: authController),
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
            ChangeNotifierProvider(
              create: (_) => WeatherProvider()..startAutoRefresh(),
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
