import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'core/localization/app_localizations.dart';
import 'core/localization/localization_controller.dart';
import 'core/routing/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/widgets/app_lock_gate.dart';
import 'core/widgets/pakfasal_scaffold.dart';

class PakFasalApp extends StatelessWidget {
  const PakFasalApp({super.key});

  /// Nastaliq glyphs look larger than Roboto at the same nominal size.
  static const double _urduTextScale = 0.88;

  @override
  Widget build(BuildContext context) {
    final localizationController = context.watch<LocalizationController>();
    final themeController = context.watch<ThemeController>();
    final locale = localizationController.locale;
    final isUrdu = locale.languageCode == 'ur';

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).t('appName'),
      debugShowCheckedModeBanner: false,
      locale: locale,
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
      builder: (context, child) {
        Widget content = AppLockGate(child: child ?? const SizedBox.shrink());

        content = Directionality(
          // Explicit direction — Material also sets this via [locale], but
          // some chrome forces LTR; content still needs the locale direction.
          textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
          child: content,
        );

        if (isUrdu) {
          final mq = MediaQuery.of(context);
          final systemFactor = mq.textScaler.scale(1);
          content = MediaQuery(
            data: mq.copyWith(
              textScaler: TextScaler.linear(systemFactor * _urduTextScale),
            ),
            child: Theme(
              data: _urduTheme(Theme.of(context)),
              child: content,
            ),
          );
        }

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: pakFasalSystemOverlay(context),
          child: content,
        );
      },
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }

  /// Noto Nastaliq Urdu for readable RTL body/title text.
  static ThemeData _urduTheme(ThemeData base) {
    TextStyle tune(TextStyle? style) {
      final s = style ?? const TextStyle();
      return s.copyWith(
        // Slightly tighter than before — scale already shrinks glyphs.
        height: (s.height ?? 1.2) < 1.4 ? 1.45 : s.height,
      );
    }

    final nastaliq = GoogleFonts.notoNastaliqUrduTextTheme(base.textTheme);
    final primaryNastaliq =
        GoogleFonts.notoNastaliqUrduTextTheme(base.primaryTextTheme);

    return base.copyWith(
      textTheme: nastaliq.copyWith(
        displayLarge: tune(nastaliq.displayLarge),
        displayMedium: tune(nastaliq.displayMedium),
        displaySmall: tune(nastaliq.displaySmall),
        headlineLarge: tune(nastaliq.headlineLarge),
        headlineMedium: tune(nastaliq.headlineMedium),
        headlineSmall: tune(nastaliq.headlineSmall),
        titleLarge: tune(nastaliq.titleLarge),
        titleMedium: tune(nastaliq.titleMedium),
        titleSmall: tune(nastaliq.titleSmall),
        bodyLarge: tune(nastaliq.bodyLarge),
        bodyMedium: tune(nastaliq.bodyMedium),
        bodySmall: tune(nastaliq.bodySmall),
        labelLarge: tune(nastaliq.labelLarge),
        labelMedium: tune(nastaliq.labelMedium),
        labelSmall: tune(nastaliq.labelSmall),
      ),
      primaryTextTheme: primaryNastaliq,
      appBarTheme: base.appBarTheme.copyWith(
        titleTextStyle: GoogleFonts.notoNastaliqUrdu(
          textStyle: base.appBarTheme.titleTextStyle,
          height: 1.45,
        ),
      ),
    );
  }
}
