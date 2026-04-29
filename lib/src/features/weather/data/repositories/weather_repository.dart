import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../domain/entities/weather_models.dart';

class WeatherRepository {
  static const Duration _currentCacheTtl = Duration(minutes: 10);
  static const String _lastCurrentKey = 'current_last';

  Future<CurrentWeather> fetchCurrentWeather({
    bool forceRefresh = false,
  }) async {
    final box = Hive.box('weather_cache');

    if (!forceRefresh) {
      // Fast path: return latest cached weather immediately (no GPS wait).
      final lastCached = box.get(_lastCurrentKey) as String?;
      if (lastCached != null && lastCached.isNotEmpty) {
        final map = jsonDecode(lastCached) as Map<String, dynamic>;
        final cachedAtMillis = (map['cachedAt'] as num?)?.toInt();
        if (cachedAtMillis != null) {
          final cachedAt = DateTime.fromMillisecondsSinceEpoch(cachedAtMillis);
          final isFresh =
              DateTime.now().difference(cachedAt) <= _currentCacheTtl;
          if (isFresh) {
            return _currentFromMap(map);
          }
        }
      }
    }

    final position = await _getCurrentPosition();
    final locationKey = _locationKey(position);

    if (!forceRefresh) {
      final cached = box.get('current_$locationKey') as String?;
      if (cached != null && cached.isNotEmpty) {
        final map = jsonDecode(cached) as Map<String, dynamic>;
        final cachedAtMillis = (map['cachedAt'] as num?)?.toInt();
        if (cachedAtMillis != null) {
          final cachedAt = DateTime.fromMillisecondsSinceEpoch(cachedAtMillis);
          final isFresh =
              DateTime.now().difference(cachedAt) <= _currentCacheTtl;
          if (isFresh) {
            return _currentFromMap(map);
          }
        } else {
          return _currentFromMap(map);
        }
      }
    }

    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=${position.latitude}'
      '&longitude=${position.longitude}'
      '&current=temperature_2m,relative_humidity_2m,weather_code'
      '&hourly=precipitation_probability'
      '&daily=precipitation_probability_max'
      '&forecast_days=1'
      '&timezone=auto',
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      final cached = box.get('current_$locationKey') as String?;
      if (cached != null && cached.isNotEmpty) {
        return _currentFromJson(cached);
      }
      throw Exception('Could not fetch current weather');
    }

    final Map<String, dynamic> json =
        jsonDecode(response.body) as Map<String, dynamic>;
    final current = json['current'] as Map<String, dynamic>? ?? {};
    final hourly = json['hourly'] as Map<String, dynamic>? ?? {};
    final daily = json['daily'] as Map<String, dynamic>? ?? {};
    final hourlyTimes = (hourly['time'] as List<dynamic>? ?? []).cast<String>();
    final precipitation =
        (hourly['precipitation_probability'] as List<dynamic>? ?? [])
            .cast<num>();
    final dailyRainList =
        (daily['precipitation_probability_max'] as List<dynamic>? ?? [])
            .cast<num>();
    final currentTime = (current['time'] as String?) ?? '';
    final currentHourIndex = hourlyTimes.indexOf(currentTime);
    final hourlyRainChance =
        (currentHourIndex >= 0 && currentHourIndex < precipitation.length)
        ? precipitation[currentHourIndex].toInt()
        : (precipitation.isNotEmpty ? precipitation.first.toInt() : 0);
    final rainChance = dailyRainList.isNotEmpty
        ? dailyRainList.first.toInt()
        : hourlyRainChance;

    final currentWeather = CurrentWeather(
      locationLabel:
          '${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}',
      temperatureC: ((current['temperature_2m'] as num?) ?? 0).toDouble(),
      humidity: ((current['relative_humidity_2m'] as num?) ?? 0).toInt(),
      rainChancePercent: rainChance,
      conditionCode: ((current['weather_code'] as num?) ?? 0).toInt(),
    );
    final encoded = _currentToJson(currentWeather);
    box.put('current_$locationKey', encoded);
    box.put(_lastCurrentKey, encoded);
    return currentWeather;
  }

  Future<List<DailyForecast>> fetchSevenDayForecast({
    bool forceRefresh = false,
  }) async {
    final position = await _getCurrentPosition();
    final locationKey = _locationKey(position);
    final box = Hive.box('weather_cache');

    if (!forceRefresh) {
      final cached = box.get('forecast_$locationKey') as String?;
      if (cached != null && cached.isNotEmpty) {
        return _forecastFromJson(cached);
      }
    }

    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=${position.latitude}'
      '&longitude=${position.longitude}'
      '&daily=weathercode,temperature_2m_max,temperature_2m_min,precipitation_probability_max'
      '&timezone=auto'
      '&forecast_days=7',
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      final cached = box.get('forecast_$locationKey') as String?;
      if (cached != null && cached.isNotEmpty) {
        return _forecastFromJson(cached);
      }
      throw Exception('Could not fetch 7-day forecast');
    }

    final Map<String, dynamic> json =
        jsonDecode(response.body) as Map<String, dynamic>;
    final daily = json['daily'] as Map<String, dynamic>? ?? {};
    final dates = (daily['time'] as List<dynamic>? ?? []).cast<String>();
    final maxTemps = (daily['temperature_2m_max'] as List<dynamic>? ?? [])
        .cast<num>();
    final minTemps = (daily['temperature_2m_min'] as List<dynamic>? ?? [])
        .cast<num>();
    final rainList =
        (daily['precipitation_probability_max'] as List<dynamic>? ?? [])
            .cast<num>();
    final weatherCodes = (daily['weathercode'] as List<dynamic>? ?? [])
        .cast<num>();

    final itemCount = [
      dates.length,
      maxTemps.length,
      minTemps.length,
      rainList.length,
      weatherCodes.length,
      7,
    ].reduce((a, b) => a < b ? a : b);

    final forecast = List.generate(itemCount, (index) {
      final date = DateTime.tryParse(dates[index]) ?? DateTime.now();
      return DailyForecast(
        dateLabel: DateFormat('EEE, d MMM').format(date),
        maxTempC: maxTemps[index].toDouble(),
        minTempC: minTemps[index].toDouble(),
        rainChance: rainList[index].toInt(),
        conditionCode: weatherCodes[index].toInt(),
      );
    });
    box.put('forecast_$locationKey', _forecastToJson(forecast));
    return forecast;
  }

  Future<Position> _getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission not granted.');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
      ),
    );
  }

  String _locationKey(Position position) {
    return '${position.latitude.toStringAsFixed(2)}_${position.longitude.toStringAsFixed(2)}';
  }

  String _currentToJson(CurrentWeather data) {
    return jsonEncode({
      'locationLabel': data.locationLabel,
      'temperatureC': data.temperatureC,
      'humidity': data.humidity,
      'rainChancePercent': data.rainChancePercent,
      'conditionCode': data.conditionCode,
      'cachedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  CurrentWeather _currentFromJson(String source) {
    final map = jsonDecode(source) as Map<String, dynamic>;
    return _currentFromMap(map);
  }

  CurrentWeather _currentFromMap(Map<String, dynamic> map) {
    return CurrentWeather(
      locationLabel: (map['locationLabel'] as String?) ?? 'Unknown',
      temperatureC: ((map['temperatureC'] as num?) ?? 0).toDouble(),
      humidity: ((map['humidity'] as num?) ?? 0).toInt(),
      rainChancePercent: ((map['rainChancePercent'] as num?) ?? 0).toInt(),
      conditionCode: ((map['conditionCode'] as num?) ?? 0).toInt(),
    );
  }

  String _forecastToJson(List<DailyForecast> forecast) {
    return jsonEncode(
      forecast
          .map(
            (e) => {
              'dateLabel': e.dateLabel,
              'maxTempC': e.maxTempC,
              'minTempC': e.minTempC,
              'rainChance': e.rainChance,
              'conditionCode': e.conditionCode,
            },
          )
          .toList(),
    );
  }

  List<DailyForecast> _forecastFromJson(String source) {
    final list = (jsonDecode(source) as List<dynamic>);
    return list.map((item) {
      final map = item as Map<String, dynamic>;
      return DailyForecast(
        dateLabel: (map['dateLabel'] as String?) ?? '',
        maxTempC: ((map['maxTempC'] as num?) ?? 0).toDouble(),
        minTempC: ((map['minTempC'] as num?) ?? 0).toDouble(),
        rainChance: ((map['rainChance'] as num?) ?? 0).toInt(),
        conditionCode: ((map['conditionCode'] as num?) ?? 0).toInt(),
      );
    }).toList();
  }
}
