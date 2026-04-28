class CurrentWeather {
  const CurrentWeather({
    required this.locationLabel,
    required this.temperatureC,
    required this.humidity,
    required this.rainChancePercent,
    required this.conditionCode,
  });

  final String locationLabel;
  final double temperatureC;
  final int humidity;
  final int rainChancePercent;
  final int conditionCode;
}

class DailyForecast {
  const DailyForecast({
    required this.dateLabel,
    required this.maxTempC,
    required this.minTempC,
    required this.rainChance,
    required this.conditionCode,
  });

  final String dateLabel;
  final double maxTempC;
  final double minTempC;
  final int rainChance;
  final int conditionCode;
}
