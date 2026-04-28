import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/localization/app_localizations.dart';
import 'core/localization/localization_controller.dart';
import 'core/routing/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';

class PakFasalApp extends StatelessWidget {
  const PakFasalApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localizationController = context.watch<LocalizationController>();
    final themeController = context.watch<ThemeController>();

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).t('appName'),
      debugShowCheckedModeBanner: false,
      locale: localizationController.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeController.themeMode,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
