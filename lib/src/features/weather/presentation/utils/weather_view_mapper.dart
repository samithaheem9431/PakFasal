import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';

class WeatherViewMapper {
  static IconData iconForCode(int code) {
    if (code == 0) return Icons.wb_sunny;
    if (code <= 3) return Icons.cloud;
    if (code <= 67) return Icons.umbrella;
    if (code <= 77) return Icons.ac_unit;
    return Icons.thunderstorm;
  }

  static String localizedCondition(AppLocalizations l10n, int code) {
    if (code == 0) return l10n.t('weatherClear');
    if (code <= 3) return l10n.t('weatherCloudy');
    if (code <= 67) return l10n.t('weatherRain');
    if (code <= 77) return l10n.t('weatherSnow');
    if (code <= 99) return l10n.t('weatherStorm');
    return l10n.t('weatherGeneral');
  }
}
