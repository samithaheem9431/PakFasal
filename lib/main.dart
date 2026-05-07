import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'src/app.dart';
import 'src/core/localization/localization_controller.dart';
import 'src/core/theme/theme_controller.dart';
import 'src/features/auth/presentation/providers/auth_session_controller.dart';
import 'src/features/weather/presentation/providers/weather_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  await Hive.openBox('weather_cache');
  await Hive.openBox('learning_cache');
  await Hive.openBox('app_preferences');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthSessionController()),
        ChangeNotifierProxyProvider<AuthSessionController, LocalizationController>(
          create: (_) => LocalizationController(),
          update: (_, auth, localizationController) {
            final controller = localizationController ?? LocalizationController();
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
}