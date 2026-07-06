import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../../core/config/app_config.dart';
import '../../constants/weather_constants.dart';
import '../../domain/entities/weather_models.dart';

/// Result envelope returned by [WeatherApiService] so callers can branch on
/// success / failure without try/catch boilerplate at every call site.
class WeatherApiResult<T> {
  const WeatherApiResult.success(this.data) : error = null;
  const WeatherApiResult.failure(this.error) : data = null;

  final T? data;
  final Object? error;

  bool get isSuccess => data != null && error == null;
}

/// Fetches weather data from the keyless Open-Meteo API (primary — blended
/// forecast-model data that matches consumer apps like Google/AccuWeather
/// more closely) with a transparent fallback to OpenWeatherMap when
/// [AppConfig.openWeatherApiKey] is set and Open-Meteo's request fails.
///
/// The service exposes three high-level methods that the repository
/// composes:
///   * [fetchSnapshot]   — current + hourly + daily + alerts in one call
///   * [searchCities]    — direct geocoding for the city-search screen
///   * [reverseGeocode]  — reverse geocoding for human-readable labels
///
/// Each method returns a [WeatherApiResult] so transient failures can be
/// surfaced to the UI without throwing.
class WeatherApiService {
  WeatherApiService({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  bool get _hasOwmKey => AppConfig.hasOpenWeatherApiKey;
  bool get _useOneCallV3 => AppConfig.useOneCallV3 && _hasOwmKey;

  /// Fetches a complete [WeatherSnapshot] for the given coordinates.
  ///
  /// Open-Meteo (blended forecast-model data) is the primary source: it
  /// tracks much closer to what users see in Google/AccuWeather than
  /// OpenWeatherMap's free-tier `/weather` endpoint, which reports raw
  /// nearest-station readings that can run several degrees hot in places
  /// like Multan during peak summer heat. OpenWeatherMap is kept only as
  /// an automatic fallback if Open-Meteo's request fails.
  Future<WeatherApiResult<WeatherSnapshot>> fetchSnapshot({
    required double latitude,
    required double longitude,
    required String locationLabel,
  }) async {
    try {
      return WeatherApiResult.success(
        await _fetchSnapshotOpenMeteo(
          latitude: latitude,
          longitude: longitude,
          locationLabel: locationLabel,
        ),
      );
    } catch (primaryError) {
      if (_useOneCallV3) {
        try {
          return WeatherApiResult.success(
            await _fetchSnapshotOwmV3(
              latitude: latitude,
              longitude: longitude,
              locationLabel: locationLabel,
            ),
          );
        } catch (_) {/* fall through to v2.5 / failure below */}
      }
      if (_hasOwmKey) {
        try {
          return WeatherApiResult.success(
            await _fetchSnapshotOwmV25(
              latitude: latitude,
              longitude: longitude,
              locationLabel: locationLabel,
            ),
          );
        } catch (_) {/* fall through to failure below */}
      }
      return WeatherApiResult.failure(primaryError);
    }
  }

  // ── OpenWeatherMap One Call API 3.0 (preferred, paid) ──────────────────

  Future<WeatherSnapshot> _fetchSnapshotOwmV3({
    required double latitude,
    required double longitude,
    required String locationLabel,
  }) async {
    final uri = Uri.parse(
      '${AppConfig.openWeatherBaseUrl}${WeatherConstants.owmOneCallV3Path}'
      '?lat=$latitude&lon=$longitude'
      '&exclude=minutely'
      '&units=metric'
      '&lang=en'
      '&appid=${AppConfig.openWeatherApiKey}',
    );

    final response = await _httpClient
        .get(uri)
        .timeout(WeatherConstants.httpTimeout);

    if (response.statusCode != 200) {
      throw Exception('OWM One Call v3 failed: ${response.statusCode}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return _snapshotFromOneCallJson(body, latitude, longitude, locationLabel);
  }

  WeatherSnapshot _snapshotFromOneCallJson(
    Map<String, dynamic> json,
    double latitude,
    double longitude,
    String locationLabel,
  ) {
    final current = json['current'] as Map<String, dynamic>? ?? const {};
    final hourly = (json['hourly'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    final daily = (json['daily'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    final alerts = (json['alerts'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();

    final currentWeatherList =
        (current['weather'] as List<dynamic>? ?? const []);
    final firstWeather = currentWeatherList.isNotEmpty
        ? currentWeatherList.first as Map<String, dynamic>
        : const <String, dynamic>{};
    final iconCode = firstWeather['icon'] as String?;
    final conditionLabel = firstWeather['description'] as String?;
    final owmId = ((firstWeather['id'] as num?) ?? 800).toInt();

    final firstDay = daily.isNotEmpty ? daily.first : const {};
    final dailyTemp = (firstDay['temp'] as Map<String, dynamic>?) ?? const {};
    final dailyPop = ((firstDay['pop'] as num?) ?? 0).toDouble();

    final currentEntity = CurrentWeather(
      locationLabel: locationLabel,
      temperatureC: ((current['temp'] as num?) ?? 0).toDouble(),
      apparentTemperatureC:
          ((current['feels_like'] as num?) ?? (current['temp'] as num?) ?? 0)
              .toDouble(),
      humidity: ((current['humidity'] as num?) ?? 0).toInt(),
      windSpeedKmh: _msToKmh(((current['wind_speed'] as num?) ?? 0).toDouble()),
      pressureHpa: ((current['pressure'] as num?) ?? 0).toInt(),
      visibilityKm:
          (((current['visibility'] as num?) ?? 0).toDouble() / 1000).clamp(
        0,
        99,
      ),
      uvIndex: ((current['uvi'] as num?) ?? 0).toDouble(),
      airQualityIndex: 0,
      weatherAlert: alerts.isEmpty
          ? null
          : (alerts.first['event'] as String?) ?? 'Weather alert',
      rainChancePercent: (dailyPop * 100).round(),
      conditionCode: _owmIdToInternalCode(owmId),
      conditionLabel: conditionLabel,
      iconCode: iconCode,
      minTempC: ((dailyTemp['min'] as num?) ?? 0).toDouble(),
      maxTempC: ((dailyTemp['max'] as num?) ?? 0).toDouble(),
      dewPointC: ((current['dew_point'] as num?) ?? 0).toDouble(),
      cloudCoverPercent: ((current['clouds'] as num?) ?? 0).toInt(),
      windDirectionDeg: ((current['wind_deg'] as num?) ?? 0).toInt(),
      sunrise: _epochSecToDate(current['sunrise']),
      sunset: _epochSecToDate(current['sunset']),
      observedAt: _epochSecToDate(current['dt']),
      latitude: latitude,
      longitude: longitude,
    );

    final hourlyEntities = hourly
        .take(WeatherConstants.hourlySliderItemCount + 12)
        .map((row) {
      final time = _epochSecToDate(row['dt']);
      final weatherList =
          (row['weather'] as List<dynamic>? ?? const []);
      final w = weatherList.isNotEmpty
          ? weatherList.first as Map<String, dynamic>
          : const <String, dynamic>{};
      return HourlyForecastPoint(
        timeLabel: time == null ? '--' : DateFormat('h a').format(time),
        temperatureC: ((row['temp'] as num?) ?? 0).toDouble(),
        conditionCode:
            _owmIdToInternalCode(((w['id'] as num?) ?? 800).toInt()),
        time: time,
        iconCode: w['icon'] as String?,
        rainProbabilityPercent:
            (((row['pop'] as num?) ?? 0).toDouble() * 100).round(),
        windSpeedKmh: _msToKmh(((row['wind_speed'] as num?) ?? 0).toDouble()),
      );
    }).toList();

    final dailyEntities = daily.take(WeatherConstants.dailyForecastDays).map(
      (row) {
        final date = _epochSecToDate(row['dt']) ?? DateTime.now();
        final temp = (row['temp'] as Map<String, dynamic>?) ?? const {};
        final weatherList =
            (row['weather'] as List<dynamic>? ?? const []);
        final w = weatherList.isNotEmpty
            ? weatherList.first as Map<String, dynamic>
            : const <String, dynamic>{};
        return DailyForecast(
          dateLabel: DateFormat('EEE, d MMM').format(date),
          maxTempC: ((temp['max'] as num?) ?? 0).toDouble(),
          minTempC: ((temp['min'] as num?) ?? 0).toDouble(),
          rainChance: (((row['pop'] as num?) ?? 0).toDouble() * 100).round(),
          conditionCode:
              _owmIdToInternalCode(((w['id'] as num?) ?? 800).toInt()),
          date: date,
          iconCode: w['icon'] as String?,
          conditionLabel: w['description'] as String?,
          windSpeedKmh:
              _msToKmh(((row['wind_speed'] as num?) ?? 0).toDouble()),
          humidity: ((row['humidity'] as num?) ?? 0).toInt(),
          uvIndex: ((row['uvi'] as num?) ?? 0).toDouble(),
          sunrise: _epochSecToDate(row['sunrise']),
          sunset: _epochSecToDate(row['sunset']),
        );
      },
    ).toList();

    final alertEntities = alerts.map((row) {
      return WeatherAlert(
        title: (row['event'] as String?) ?? 'Weather alert',
        description: (row['description'] as String?) ?? '',
        severity: WeatherSeverity.warning,
        sender: row['sender_name'] as String?,
        start: _epochSecToDate(row['start']),
        end: _epochSecToDate(row['end']),
        tags: ((row['tags'] as List<dynamic>?) ?? const [])
            .whereType<String>()
            .toList(),
      );
    }).toList();

    return WeatherSnapshot(
      location: WeatherLocation(
        label: locationLabel,
        latitude: latitude,
        longitude: longitude,
      ),
      current: currentEntity,
      hourly: hourlyEntities,
      daily: dailyEntities,
      alerts: alertEntities,
      fetchedAt: DateTime.now(),
    );
  }

  // ── OpenWeatherMap free-tier (2.5) — current + 5 day / 3 hr forecast ──

  Future<WeatherSnapshot> _fetchSnapshotOwmV25({
    required double latitude,
    required double longitude,
    required String locationLabel,
  }) async {
    final currentUri = Uri.parse(
      '${AppConfig.openWeatherBaseUrl}${WeatherConstants.owmCurrentPath}'
      '?lat=$latitude&lon=$longitude'
      '&units=metric&lang=en'
      '&appid=${AppConfig.openWeatherApiKey}',
    );
    final forecastUri = Uri.parse(
      '${AppConfig.openWeatherBaseUrl}${WeatherConstants.owmFiveDayForecastPath}'
      '?lat=$latitude&lon=$longitude'
      '&units=metric&lang=en'
      '&appid=${AppConfig.openWeatherApiKey}',
    );
    final aqiUri = Uri.parse(
      '${AppConfig.openWeatherBaseUrl}${WeatherConstants.owmAirQualityPath}'
      '?lat=$latitude&lon=$longitude'
      '&appid=${AppConfig.openWeatherApiKey}',
    );

    final results = await Future.wait([
      _httpClient.get(currentUri).timeout(WeatherConstants.httpTimeout),
      _httpClient.get(forecastUri).timeout(WeatherConstants.httpTimeout),
      _httpClient
          .get(aqiUri)
          .timeout(WeatherConstants.httpTimeout)
          .catchError((_) => http.Response('{}', 200)),
    ]);

    if (results[0].statusCode != 200 || results[1].statusCode != 200) {
      throw Exception(
        'OWM v2.5 failed: ${results[0].statusCode}/${results[1].statusCode}',
      );
    }

    final currentJson = jsonDecode(results[0].body) as Map<String, dynamic>;
    final forecastJson = jsonDecode(results[1].body) as Map<String, dynamic>;
    final aqi = _aqiUsFromOwmAir(jsonDecode(results[2].body));

    return _snapshotFromOwmV25(
      currentJson: currentJson,
      forecastJson: forecastJson,
      aqi: aqi,
      latitude: latitude,
      longitude: longitude,
      locationLabel: locationLabel,
    );
  }

  WeatherSnapshot _snapshotFromOwmV25({
    required Map<String, dynamic> currentJson,
    required Map<String, dynamic> forecastJson,
    required int aqi,
    required double latitude,
    required double longitude,
    required String locationLabel,
  }) {
    final main = (currentJson['main'] as Map<String, dynamic>?) ?? const {};
    final wind = (currentJson['wind'] as Map<String, dynamic>?) ?? const {};
    final sys = (currentJson['sys'] as Map<String, dynamic>?) ?? const {};
    final clouds =
        (currentJson['clouds'] as Map<String, dynamic>?) ?? const {};
    final weatherList =
        (currentJson['weather'] as List<dynamic>? ?? const []);
    final firstW = weatherList.isNotEmpty
        ? weatherList.first as Map<String, dynamic>
        : const <String, dynamic>{};
    final owmId = ((firstW['id'] as num?) ?? 800).toInt();

    // 3-hour buckets from /forecast — split into hourly (next ~12 buckets,
    // i.e. ~36 hours) and daily aggregation (group by date).
    final list = (forecastJson['list'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();

    final hourlyEntities = list
        .take(WeatherConstants.hourlySliderItemCount)
        .map((row) {
      final mainRow =
          (row['main'] as Map<String, dynamic>?) ?? const {};
      final weatherRow =
          ((row['weather'] as List<dynamic>? ?? const [])).cast<Map>();
      final w = weatherRow.isNotEmpty
          ? Map<String, dynamic>.from(weatherRow.first)
          : const <String, dynamic>{};
      final time = _epochSecToDate(row['dt']);
      final pop = ((row['pop'] as num?) ?? 0).toDouble();
      final windRow = (row['wind'] as Map<String, dynamic>?) ?? const {};
      return HourlyForecastPoint(
        timeLabel: time == null ? '--' : DateFormat('h a').format(time),
        temperatureC: ((mainRow['temp'] as num?) ?? 0).toDouble(),
        conditionCode:
            _owmIdToInternalCode(((w['id'] as num?) ?? 800).toInt()),
        time: time,
        iconCode: w['icon'] as String?,
        rainProbabilityPercent: (pop * 100).round(),
        windSpeedKmh: _msToKmh(((windRow['speed'] as num?) ?? 0).toDouble()),
      );
    }).toList();

    final dailyEntities = _aggregateDailyFromOwmV25(list);

    final pop24h = list.take(8).fold<double>(
        0, (acc, row) => acc + (((row['pop'] as num?) ?? 0).toDouble()));
    final rainChance = ((pop24h / (list.isEmpty ? 1 : 8)) * 100).round();

    final currentEntity = CurrentWeather(
      locationLabel: locationLabel,
      temperatureC: ((main['temp'] as num?) ?? 0).toDouble(),
      apparentTemperatureC:
          ((main['feels_like'] as num?) ?? (main['temp'] as num?) ?? 0)
              .toDouble(),
      humidity: ((main['humidity'] as num?) ?? 0).toInt(),
      windSpeedKmh: _msToKmh(((wind['speed'] as num?) ?? 0).toDouble()),
      pressureHpa: ((main['pressure'] as num?) ?? 0).toInt(),
      visibilityKm:
          (((currentJson['visibility'] as num?) ?? 0).toDouble() / 1000)
              .clamp(0, 99),
      uvIndex: 0, // not provided by 2.5 weather endpoint
      airQualityIndex: aqi,
      weatherAlert: null,
      rainChancePercent: rainChance.clamp(0, 100),
      conditionCode: _owmIdToInternalCode(owmId),
      conditionLabel: firstW['description'] as String?,
      iconCode: firstW['icon'] as String?,
      minTempC: dailyEntities.isNotEmpty ? dailyEntities.first.minTempC : null,
      maxTempC: dailyEntities.isNotEmpty ? dailyEntities.first.maxTempC : null,
      cloudCoverPercent: ((clouds['all'] as num?) ?? 0).toInt(),
      windDirectionDeg: ((wind['deg'] as num?) ?? 0).toInt(),
      sunrise: _epochSecToDate(sys['sunrise']),
      sunset: _epochSecToDate(sys['sunset']),
      observedAt: _epochSecToDate(currentJson['dt']),
      latitude: latitude,
      longitude: longitude,
    );

    return WeatherSnapshot(
      location: WeatherLocation(
        label: locationLabel,
        latitude: latitude,
        longitude: longitude,
      ),
      current: currentEntity,
      hourly: hourlyEntities,
      daily: dailyEntities,
      alerts: const [],
      fetchedAt: DateTime.now(),
    );
  }

  /// Groups 3-hour forecast buckets by date and produces one [DailyForecast]
  /// per day with min/max + dominant weather code.
  List<DailyForecast> _aggregateDailyFromOwmV25(
    List<Map<String, dynamic>> list,
  ) {
    final byDate = <String, List<Map<String, dynamic>>>{};
    for (final row in list) {
      final ts = _epochSecToDate(row['dt']);
      if (ts == null) continue;
      final key = DateFormat('yyyy-MM-dd').format(ts);
      byDate.putIfAbsent(key, () => []).add(row);
    }

    final days = byDate.entries.take(WeatherConstants.dailyForecastDays).map(
      (entry) {
        final rows = entry.value;
        double maxT = -double.infinity;
        double minT = double.infinity;
        double sumPop = 0;
        final codeCounts = <int, int>{};
        Map<String, dynamic> noonRow = rows.first;
        DateTime? noonTime;
        for (final row in rows) {
          final m = (row['main'] as Map<String, dynamic>?) ?? const {};
          final mx = ((m['temp_max'] as num?) ?? 0).toDouble();
          final mn = ((m['temp_min'] as num?) ?? 0).toDouble();
          if (mx > maxT) maxT = mx;
          if (mn < minT) minT = mn;
          sumPop += ((row['pop'] as num?) ?? 0).toDouble();
          final wList =
              (row['weather'] as List<dynamic>? ?? const []).cast<Map>();
          if (wList.isNotEmpty) {
            final id =
                ((wList.first['id'] as num?) ?? 800).toInt();
            codeCounts[id] = (codeCounts[id] ?? 0) + 1;
          }
          final ts = _epochSecToDate(row['dt']);
          if (ts != null && (noonTime == null || (ts.hour - 12).abs() < (noonTime.hour - 12).abs())) {
            noonRow = row;
            noonTime = ts;
          }
        }
        final dominantCode = codeCounts.entries
            .fold<MapEntry<int, int>>(
              const MapEntry<int, int>(800, 0),
              (best, e) => e.value > best.value ? e : best,
            )
            .key;
        final wList =
            (noonRow['weather'] as List<dynamic>? ?? const []).cast<Map>();
        final w = wList.isNotEmpty
            ? Map<String, dynamic>.from(wList.first)
            : const <String, dynamic>{};
        final date = DateTime.parse(entry.key);
        return DailyForecast(
          dateLabel: DateFormat('EEE, d MMM').format(date),
          maxTempC: maxT == -double.infinity ? 0 : maxT,
          minTempC: minT == double.infinity ? 0 : minT,
          rainChance: ((sumPop / rows.length) * 100).round(),
          conditionCode: _owmIdToInternalCode(dominantCode),
          date: date,
          iconCode: w['icon'] as String?,
          conditionLabel: w['description'] as String?,
        );
      },
    ).toList();

    return days;
  }

  // ── Open-Meteo fallback (keyless) ─────────────────────────────────────

  Future<WeatherSnapshot> _fetchSnapshotOpenMeteo({
    required double latitude,
    required double longitude,
    required String locationLabel,
  }) async {
    final uri = Uri.parse(
      '${AppConfig.weatherApiBaseUrl}${WeatherConstants.openMeteoForecastPath}'
      '?latitude=$latitude&longitude=$longitude'
      '&current=temperature_2m,apparent_temperature,relative_humidity_2m,'
      'weather_code,wind_speed_10m,wind_direction_10m,surface_pressure,'
      'visibility,uv_index,cloud_cover,dew_point_2m'
      '&hourly=temperature_2m,weather_code,precipitation_probability,wind_speed_10m'
      '&daily=weathercode,temperature_2m_max,temperature_2m_min,'
      'precipitation_probability_max,sunrise,sunset,uv_index_max,wind_speed_10m_max'
      '&forecast_hours=${WeatherConstants.hourlySliderItemCount + 12}'
      '&forecast_days=${WeatherConstants.dailyForecastDays}'
      '&timezone=auto'
      '&temperature_unit=celsius'
      '&wind_speed_unit=kmh',
    );

    final response = await _httpClient
        .get(uri)
        .timeout(WeatherConstants.httpTimeout);
    if (response.statusCode != 200) {
      throw Exception('Open-Meteo failed: ${response.statusCode}');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;

    final aqi = await _fetchOpenMeteoAirQuality(latitude, longitude);

    final current = json['current'] as Map<String, dynamic>? ?? const {};
    final hourly = json['hourly'] as Map<String, dynamic>? ?? const {};
    final daily = json['daily'] as Map<String, dynamic>? ?? const {};

    final hTimes = (hourly['time'] as List? ?? []).cast<String>();
    final hTemps = (hourly['temperature_2m'] as List? ?? []).cast<num>();
    final hCodes = (hourly['weather_code'] as List? ?? []).cast<num>();
    final hPop =
        (hourly['precipitation_probability'] as List? ?? []).cast<num>();
    final hWind = (hourly['wind_speed_10m'] as List? ?? []).cast<num>();

    final hourlyEntities = List.generate(
      [hTimes.length, hTemps.length, hCodes.length, hPop.length].reduce(
        (a, b) => a < b ? a : b,
      ),
      (i) {
        final time = DateTime.tryParse(hTimes[i]);
        return HourlyForecastPoint(
          timeLabel:
              time == null ? '--' : DateFormat('h a').format(time),
          temperatureC: hTemps[i].toDouble(),
          conditionCode: hCodes[i].toInt(),
          time: time,
          rainProbabilityPercent: hPop[i].toInt(),
          windSpeedKmh: i < hWind.length ? hWind[i].toDouble() : null,
        );
      },
    );

    final dDates = (daily['time'] as List? ?? []).cast<String>();
    final dMax = (daily['temperature_2m_max'] as List? ?? []).cast<num>();
    final dMin = (daily['temperature_2m_min'] as List? ?? []).cast<num>();
    final dPop =
        (daily['precipitation_probability_max'] as List? ?? []).cast<num>();
    final dCodes = (daily['weathercode'] as List? ?? []).cast<num>();
    final dSunrise = (daily['sunrise'] as List? ?? []).cast<String>();
    final dSunset = (daily['sunset'] as List? ?? []).cast<String>();
    final dUv = (daily['uv_index_max'] as List? ?? []).cast<num>();
    final dWind = (daily['wind_speed_10m_max'] as List? ?? []).cast<num>();

    final dailyCount = [
      dDates.length,
      dMax.length,
      dMin.length,
      dPop.length,
      dCodes.length,
      WeatherConstants.dailyForecastDays,
    ].reduce((a, b) => a < b ? a : b);

    final dailyEntities = List.generate(dailyCount, (i) {
      final date = DateTime.tryParse(dDates[i]) ?? DateTime.now();
      return DailyForecast(
        dateLabel: DateFormat('EEE, d MMM').format(date),
        maxTempC: dMax[i].toDouble(),
        minTempC: dMin[i].toDouble(),
        rainChance: dPop[i].toInt(),
        conditionCode: dCodes[i].toInt(),
        date: date,
        sunrise: i < dSunrise.length ? DateTime.tryParse(dSunrise[i]) : null,
        sunset: i < dSunset.length ? DateTime.tryParse(dSunset[i]) : null,
        uvIndex: i < dUv.length ? dUv[i].toDouble() : null,
        windSpeedKmh: i < dWind.length ? dWind[i].toDouble() : null,
      );
    });

    final firstDay = dailyEntities.isNotEmpty ? dailyEntities.first : null;

    final currentEntity = CurrentWeather(
      locationLabel: locationLabel,
      temperatureC: ((current['temperature_2m'] as num?) ?? 0).toDouble(),
      apparentTemperatureC:
          ((current['apparent_temperature'] as num?) ??
                  (current['temperature_2m'] as num?) ??
                  0)
              .toDouble(),
      humidity: ((current['relative_humidity_2m'] as num?) ?? 0).toInt(),
      windSpeedKmh: ((current['wind_speed_10m'] as num?) ?? 0).toDouble(),
      pressureHpa: ((current['surface_pressure'] as num?) ?? 0).toInt(),
      visibilityKm:
          (((current['visibility'] as num?) ?? 0).toDouble() / 1000).clamp(
        0,
        99,
      ),
      uvIndex: ((current['uv_index'] as num?) ?? 0).toDouble(),
      airQualityIndex: aqi,
      weatherAlert: null,
      rainChancePercent: firstDay?.rainChance ?? 0,
      conditionCode: ((current['weather_code'] as num?) ?? 0).toInt(),
      minTempC: firstDay?.minTempC,
      maxTempC: firstDay?.maxTempC,
      dewPointC: ((current['dew_point_2m'] as num?))?.toDouble(),
      cloudCoverPercent: ((current['cloud_cover'] as num?) ?? 0).toInt(),
      windDirectionDeg:
          ((current['wind_direction_10m'] as num?) ?? 0).toInt(),
      sunrise: firstDay?.sunrise,
      sunset: firstDay?.sunset,
      observedAt: DateTime.tryParse((current['time'] as String?) ?? ''),
      latitude: latitude,
      longitude: longitude,
    );

    return WeatherSnapshot(
      location: WeatherLocation(
        label: locationLabel,
        latitude: latitude,
        longitude: longitude,
      ),
      current: currentEntity,
      hourly: hourlyEntities,
      daily: dailyEntities,
      alerts: const [],
      fetchedAt: DateTime.now(),
    );
  }

  // ── Geocoding ─────────────────────────────────────────────────────────

  /// Searches for cities matching [query]. Uses OWM direct geocoding when
  /// an API key is configured, Open-Meteo otherwise.
  Future<WeatherApiResult<List<WeatherLocation>>> searchCities(
    String query,
  ) async {
    final trimmed = query.trim();
    if (trimmed.length < WeatherConstants.citySearchMinChars) {
      return const WeatherApiResult.success(<WeatherLocation>[]);
    }
    try {
      if (_hasOwmKey) {
        return WeatherApiResult.success(await _searchOwm(trimmed));
      }
      return WeatherApiResult.success(await _searchOpenMeteo(trimmed));
    } catch (error) {
      return WeatherApiResult.failure(error);
    }
  }

  Future<List<WeatherLocation>> _searchOwm(String query) async {
    final uri = Uri.parse(
      '${AppConfig.openWeatherBaseUrl}${WeatherConstants.owmGeoDirectPath}'
      '?q=${Uri.encodeQueryComponent(query)}'
      '&limit=${WeatherConstants.citySearchMaxResults}'
      '&appid=${AppConfig.openWeatherApiKey}',
    );
    final response =
        await _httpClient.get(uri).timeout(WeatherConstants.httpTimeout);
    if (response.statusCode != 200) {
      throw Exception('OWM geocode failed: ${response.statusCode}');
    }
    final list = (jsonDecode(response.body) as List<dynamic>)
        .cast<Map<String, dynamic>>();
    return list.map((row) {
      final name = (row['name'] as String?) ?? query;
      final country = (row['country'] as String?) ?? '';
      final state = (row['state'] as String?) ?? '';
      final label = country.isEmpty
          ? name
          : (state.isEmpty ? '$name, $country' : '$name, $state, $country');
      return WeatherLocation(
        label: label,
        latitude: ((row['lat'] as num?) ?? 0).toDouble(),
        longitude: ((row['lon'] as num?) ?? 0).toDouble(),
        country: country.isEmpty ? null : country,
        admin1: state.isEmpty ? null : state,
      );
    }).toList();
  }

  Future<List<WeatherLocation>> _searchOpenMeteo(String query) async {
    final uri = Uri.parse(
      '${WeatherConstants.openMeteoGeocodingBaseUrl}/search'
      '?name=${Uri.encodeQueryComponent(query)}'
      '&count=${WeatherConstants.citySearchMaxResults}'
      '&language=en&format=json',
    );
    final response =
        await _httpClient.get(uri).timeout(WeatherConstants.httpTimeout);
    if (response.statusCode != 200) {
      throw Exception('Open-Meteo geocode failed: ${response.statusCode}');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final results = (json['results'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    return results.map((row) {
      final name = (row['name'] as String?) ?? query;
      final country = (row['country'] as String?) ?? '';
      final admin1 = (row['admin1'] as String?) ?? '';
      final label = country.isEmpty
          ? name
          : (admin1.isEmpty
              ? '$name, $country'
              : '$name, $admin1, $country');
      return WeatherLocation(
        label: label,
        latitude: ((row['latitude'] as num?) ?? 0).toDouble(),
        longitude: ((row['longitude'] as num?) ?? 0).toDouble(),
        country: country.isEmpty ? null : country,
        admin1: admin1.isEmpty ? null : admin1,
      );
    }).toList();
  }

  /// Reverse geocodes [latitude]/[longitude] to a friendly label like
  /// "Lahore, Pakistan". Returns the raw coords as fallback.
  Future<String> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    final fallback =
        '${latitude.toStringAsFixed(2)}, ${longitude.toStringAsFixed(2)}';
    try {
      if (_hasOwmKey) {
        final uri = Uri.parse(
          '${AppConfig.openWeatherBaseUrl}${WeatherConstants.owmGeoReversePath}'
          '?lat=$latitude&lon=$longitude&limit=1'
          '&appid=${AppConfig.openWeatherApiKey}',
        );
        final response =
            await _httpClient.get(uri).timeout(WeatherConstants.httpTimeout);
        if (response.statusCode == 200) {
          final list = (jsonDecode(response.body) as List<dynamic>)
              .cast<Map<String, dynamic>>();
          if (list.isNotEmpty) {
            final row = list.first;
            final name = (row['name'] as String?) ?? '';
            final country = (row['country'] as String?) ?? '';
            if (name.isNotEmpty) {
              return country.isEmpty ? name : '$name, $country';
            }
          }
        }
      }
      // Open-Meteo reverse geocoder.
      final uri = Uri.parse(
        '${WeatherConstants.openMeteoGeocodingBaseUrl}/reverse'
        '?latitude=$latitude&longitude=$longitude'
        '&count=1&language=en&format=json',
      );
      final response =
          await _httpClient.get(uri).timeout(WeatherConstants.httpTimeout);
      if (response.statusCode != 200) return fallback;
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final results = (json['results'] as List<dynamic>? ?? const []);
      if (results.isEmpty) return fallback;
      final first = results.first as Map<String, dynamic>;
      final name = (first['name'] as String?) ?? '';
      final country = (first['country'] as String?) ?? '';
      if (name.isEmpty) return fallback;
      if (country.isEmpty) return name;
      return '$name, $country';
    } catch (_) {
      return fallback;
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  /// Maps OpenWeatherMap "id" codes to the same internal code-space the
  /// existing UI mapper understands (clear=0, cloudy<=3, rain<=67, snow<=77,
  /// storm>=95). This lets us reuse [WeatherViewMapper] without churn.
  int _owmIdToInternalCode(int owmId) {
    if (owmId >= 200 && owmId <= 232) return 95; // thunderstorm
    if (owmId >= 300 && owmId <= 321) return 51; // drizzle
    if (owmId >= 500 && owmId <= 504) return 63; // rain
    if (owmId == 511) return 66; // freezing rain
    if (owmId >= 520 && owmId <= 531) return 80; // showers
    if (owmId >= 600 && owmId <= 622) return 73; // snow
    if (owmId >= 700 && owmId <= 781) return 45; // atmosphere (mist/fog)
    if (owmId == 800) return 0; // clear
    if (owmId == 801) return 1; // few clouds
    if (owmId == 802) return 2; // scattered clouds
    if (owmId == 803 || owmId == 804) return 3; // overcast
    return 0;
  }

  double _msToKmh(double ms) => ms * 3.6;

  DateTime? _epochSecToDate(dynamic value) {
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt() * 1000);
    }
    return null;
  }

  /// Converts OpenWeatherMap's air-pollution `aqi` (1..5) to a US-AQI proxy
  /// so the UI can keep using the same threshold logic. Returns 0 if the
  /// payload is empty (e.g. AQ endpoint not enabled on the key).
  int _aqiUsFromOwmAir(dynamic body) {
    if (body is! Map<String, dynamic>) return 0;
    final list = (body['list'] as List<dynamic>? ?? const []);
    if (list.isEmpty) return 0;
    final main = ((list.first as Map<String, dynamic>)['main']
            as Map<String, dynamic>?) ??
        const {};
    final aqi = ((main['aqi'] as num?) ?? 0).toInt();
    // Approximate mapping from OWM's 1..5 buckets to US-AQI midpoints.
    return switch (aqi) {
      1 => 25,
      2 => 75,
      3 => 125,
      4 => 175,
      5 => 250,
      _ => 0,
    };
  }

  Future<int> _fetchOpenMeteoAirQuality(double lat, double lon) async {
    try {
      final uri = Uri.parse(
        '${WeatherConstants.openMeteoAirQualityBaseUrl}/air-quality'
        '?latitude=$lat&longitude=$lon&current=us_aqi&timezone=auto',
      );
      final response =
          await _httpClient.get(uri).timeout(WeatherConstants.httpTimeout);
      if (response.statusCode != 200) return 0;
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final current = json['current'] as Map<String, dynamic>? ?? const {};
      return ((current['us_aqi'] as num?) ?? 0).toInt();
    } catch (_) {
      return 0;
    }
  }

  void dispose() {
    _httpClient.close();
  }
}
