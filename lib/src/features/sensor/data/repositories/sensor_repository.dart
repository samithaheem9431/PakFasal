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

  Future<SensorRuleConfig> fetchRuleConfig() async {
    final doc = await _firestore.collection('sensor_config').doc('rules').get();
    final data = doc.data();
    if (data == null) {
      return const SensorRuleConfig();
    }

    return SensorRuleConfig(
      moistureLowThreshold:
          ((data['moistureLowThreshold'] as num?) ?? 45).toDouble(),
      moistureHighThreshold:
          ((data['moistureHighThreshold'] as num?) ?? 75).toDouble(),
      phLowThreshold: ((data['phLowThreshold'] as num?) ?? 5.5).toDouble(),
      phHighThreshold: ((data['phHighThreshold'] as num?) ?? 7.5).toDouble(),
      rainChanceThreshold: ((data['rainChanceThreshold'] as num?) ?? 50).toInt(),
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
