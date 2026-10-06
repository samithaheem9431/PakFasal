/// A live soil sample from BLE or WiFi (not yet saved as history advice).
class LiveSensorSample {
  const LiveSensorSample({
    required this.soilMoisture,
    required this.phLevel,
    required this.deviceId,
    required this.source,
    required this.updatedAt,
    this.deviceName,
  });

  final double soilMoisture;
  final double phLevel;
  final String deviceId;
  final String source; // `ble` | `wifi`
  final DateTime updatedAt;
  final String? deviceName;

  bool get isValid =>
      soilMoisture >= 0 &&
      soilMoisture <= 100 &&
      phLevel >= 0 &&
      phLevel <= 14 &&
      deviceId.isNotEmpty;
}
