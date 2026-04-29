class SensorReading {
  const SensorReading({
    required this.soilMoisture,
    required this.phLevel,
    required this.timestamp,
    this.crop,
    this.rainChancePercent,
    this.recommendationSummary,
    this.recommendationDetails,
    this.recommendationPriority,
  });

  final double soilMoisture;
  final double phLevel;
  final DateTime timestamp;
  final String? crop;
  final int? rainChancePercent;
  final String? recommendationSummary;
  final String? recommendationDetails;
  final String? recommendationPriority;
}
