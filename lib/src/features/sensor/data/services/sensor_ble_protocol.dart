import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// BLE GATT contract shared with `firmware/pakfasal_sensor`.
class SensorBleProtocol {
  static const deviceNamePrefix = 'PakFasal-';

  /// Nordic UART-style service used by the PakFasal ESP32 sketch.
  static final serviceUuid = Guid('6E400001-B5A3-F393-E0A9-E50E24DCCA9E');

  /// App → device (WiFi/owner provisioning JSON).
  static final rxUuid = Guid('6E400002-B5A3-F393-E0A9-E50E24DCCA9E');

  /// Device → app (notify JSON readings).
  static final txUuid = Guid('6E400003-B5A3-F393-E0A9-E50E24DCCA9E');

  static bool matchesDeviceName(String? name) {
    if (name == null || name.isEmpty) return false;
    return name.startsWith(deviceNamePrefix);
  }
}
