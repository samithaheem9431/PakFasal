import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/sensor_reading.dart';

class SensorRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<SensorReading>> watchRecentReadings() {
    return _firestore
        .collection('sensor_readings')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
          final mapped = snapshot.docs.map((doc) {
            final data = doc.data();
            final timestamp = data['timestamp'] as Timestamp?;
            return SensorReading(
              soilMoisture: ((data['soilMoisture'] as num?) ?? 0).toDouble(),
              phLevel: ((data['phLevel'] as num?) ?? 0).toDouble(),
              timestamp: timestamp?.toDate() ?? DateTime.now(),
              crop: data['crop'] as String?,
              rainChancePercent: (data['rainChancePercent'] as num?)?.toInt(),
              recommendationSummary: data['recommendationSummary'] as String?,
              recommendationDetails: data['recommendationDetails'] as String?,
              recommendationPriority: data['recommendationPriority'] as String?,
            );
          }).toList();

          final sorted = [...mapped]
            ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
          return sorted;
        });
  }

  Future<void> addReading({
    required double soilMoisture,
    required double phLevel,
    required String crop,
    required int rainChancePercent,
    required String recommendationSummary,
    required String recommendationDetails,
    required String recommendationPriority,
  }) async {
    await _firestore.collection('sensor_readings').add({
      'soilMoisture': soilMoisture,
      'phLevel': phLevel,
      'crop': crop,
      'rainChancePercent': rainChancePercent,
      'recommendationSummary': recommendationSummary,
      'recommendationDetails': recommendationDetails,
      'recommendationPriority': recommendationPriority,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> clearAllReadings() async {
    const batchSize = 200;
    while (true) {
      final snapshot = await _firestore
          .collection('sensor_readings')
          .limit(batchSize)
          .get();
      if (snapshot.docs.isEmpty) {
        break;
      }

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  /// Reads the rule-set document at `sensor_config/rules`.
  ///
  /// Expected document shape (any missing field falls back to the default):
  /// ```
  /// {
  ///   "default": { "moistureLowThreshold": 45, "moistureHighThreshold": 75,
  ///                "phLowThreshold": 5.5, "phHighThreshold": 7.5,
  ///                "rainChanceThreshold": 50 },
  ///   "Wheat":  { ... per-crop overrides ... },
  ///   "Rice":   { ... },
  ///   "Cotton": { ... }
  /// }
  /// ```
  ///
  /// When a crop key is missing the [SensorRuleSet.forCrop] lookup falls back
  /// to the `default` entry, and when the whole document is missing
  /// [SensorRuleSet.fallback] is returned with agronomy-based defaults for
  /// Pakistani crops.
  Future<SensorRuleSet> fetchRuleSet() async {
    final doc = await _firestore.collection('sensor_config').doc('rules').get();
    final data = doc.data();
    if (data == null) {
      return SensorRuleSet.fallback();
    }

    final fallback = SensorRuleSet.fallback();
    final defaultConfig = _parseConfig(
      data['default'] as Map<String, dynamic>?,
      fallback.defaultConfig,
    );
    final perCrop = <String, SensorRuleConfig>{};
    for (final crop in const ['Wheat', 'Rice', 'Cotton']) {
      final cropFallback = fallback.perCrop[crop] ?? defaultConfig;
      perCrop[crop] = _parseConfig(
        data[crop] as Map<String, dynamic>?,
        cropFallback,
      );
    }
    return SensorRuleSet(defaultConfig: defaultConfig, perCrop: perCrop);
  }

  SensorRuleConfig _parseConfig(
    Map<String, dynamic>? data,
    SensorRuleConfig fallback,
  ) {
    if (data == null) return fallback;
    return SensorRuleConfig(
      moistureLowThreshold:
          ((data['moistureLowThreshold'] as num?) ?? fallback.moistureLowThreshold)
              .toDouble(),
      moistureHighThreshold:
          ((data['moistureHighThreshold'] as num?) ?? fallback.moistureHighThreshold)
              .toDouble(),
      phLowThreshold:
          ((data['phLowThreshold'] as num?) ?? fallback.phLowThreshold).toDouble(),
      phHighThreshold:
          ((data['phHighThreshold'] as num?) ?? fallback.phHighThreshold).toDouble(),
      rainChanceThreshold:
          ((data['rainChanceThreshold'] as num?) ?? fallback.rainChanceThreshold)
              .toInt(),
    );
  }
}

class SensorRuleConfig {
  const SensorRuleConfig({
    this.moistureLowThreshold = 45,
    this.moistureHighThreshold = 75,
    this.phLowThreshold = 5.5,
    this.phHighThreshold = 7.5,
    this.rainChanceThreshold = 50,
  });

  final double moistureLowThreshold;
  final double moistureHighThreshold;
  final double phLowThreshold;
  final double phHighThreshold;
  final int rainChanceThreshold;
}

/// A bundle of [SensorRuleConfig]s indexed by crop, plus a `default` config
/// used for any crop without an explicit override.
///
/// Per-crop defaults are tuned for Pakistani agronomy:
///  * Wheat   – moderate water need, neutral pH (40–70%, pH 6.0–7.5).
///  * Rice    – paddy crop, very high moisture, slightly acidic soil
///              (70–95%, pH 5.5–7.0). Higher rain threshold because
///              rice tolerates standing water.
///  * Cotton  – drought tolerant, tolerates alkaline soils
///              (35–65%, pH 6.0–8.0).
class SensorRuleSet {
  const SensorRuleSet({
    required this.defaultConfig,
    required this.perCrop,
  });

  factory SensorRuleSet.fallback() {
    const defaultConfig = SensorRuleConfig();
    return const SensorRuleSet(
      defaultConfig: defaultConfig,
      perCrop: {
        'Wheat': SensorRuleConfig(
          moistureLowThreshold: 40,
          moistureHighThreshold: 70,
          phLowThreshold: 6.0,
          phHighThreshold: 7.5,
          rainChanceThreshold: 50,
        ),
        'Rice': SensorRuleConfig(
          moistureLowThreshold: 70,
          moistureHighThreshold: 95,
          phLowThreshold: 5.5,
          phHighThreshold: 7.0,
          rainChanceThreshold: 60,
        ),
        'Cotton': SensorRuleConfig(
          moistureLowThreshold: 35,
          moistureHighThreshold: 65,
          phLowThreshold: 6.0,
          phHighThreshold: 8.0,
          rainChanceThreshold: 45,
        ),
      },
    );
  }

  final SensorRuleConfig defaultConfig;
  final Map<String, SensorRuleConfig> perCrop;

  /// Returns the per-crop override if present, otherwise the default config.
  SensorRuleConfig forCrop(String crop) =>
      perCrop[crop] ?? defaultConfig;
}
