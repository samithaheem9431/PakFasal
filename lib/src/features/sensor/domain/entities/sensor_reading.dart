class SensorReading {
  const SensorReading({
    required this.soilMoisture,
    required this.phLevel,
    required this.timestamp,
  });

  final double soilMoisture;
  final double phLevel;
  final DateTime timestamp;
}
