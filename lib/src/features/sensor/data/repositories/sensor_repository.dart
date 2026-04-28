import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/sensor_reading.dart';

class SensorRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<SensorReading>> watchRecentReadings() async* {
    try {
      yield* _firestore
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
              );
            }).toList();

            if (mapped.isEmpty) {
              return _demoReadings();
            }

            final sorted = [...mapped]
              ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
            return sorted;
          });
    } catch (_) {
      yield _demoReadings();
    }
  }

  List<SensorReading> _demoReadings() {
    final now = DateTime.now();
    return List.generate(7, (index) {
      return SensorReading(
        soilMoisture: 42 + (index * 4.2),
        phLevel: 6.2 - (index * 0.07),
        timestamp: now.subtract(Duration(days: 6 - index)),
      );
    });
  }
}
