import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../domain/entities/live_sensor_sample.dart';
import 'sensor_ble_protocol.dart';

enum SensorBleConnectionState {
  unsupported,
  poweredOff,
  idle,
  scanning,
  connecting,
  connected,
  disconnected,
}

class SensorBleScanHit {
  const SensorBleScanHit({
    required this.device,
    required this.name,
    required this.rssi,
  });

  final BluetoothDevice device;
  final String name;
  final int rssi;
}

/// Scans / connects to PakFasal ESP32 soil nodes over BLE.
class SensorBleService {
  final _connectionController =
      StreamController<SensorBleConnectionState>.broadcast();
  final _sampleController = StreamController<LiveSensorSample>.broadcast();
  final _scanController = StreamController<List<SensorBleScanHit>>.broadcast();

  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<BluetoothConnectionState>? _connSub;
  StreamSubscription<List<int>>? _notifySub;
  BluetoothDevice? _device;
  BluetoothCharacteristic? _rxCharacteristic;
  final Map<String, SensorBleScanHit> _hits = {};

  Stream<SensorBleConnectionState> get connectionStates =>
      _connectionController.stream;
  Stream<LiveSensorSample> get samples => _sampleController.stream;
  Stream<List<SensorBleScanHit>> get scanHits => _scanController.stream;

  BluetoothDevice? get connectedDevice => _device;

  Future<bool> ensureReady() async {
    final supported = await FlutterBluePlus.isSupported;
    if (!supported) {
      _emit(SensorBleConnectionState.unsupported);
      return false;
    }

    final adapterState = await FlutterBluePlus.adapterState.first;
    if (adapterState != BluetoothAdapterState.on) {
      _emit(SensorBleConnectionState.poweredOff);
      try {
        await FlutterBluePlus.turnOn();
      } catch (_) {
        return false;
      }
    }

    final granted = await _requestPermissions();
    if (!granted) return false;
    return true;
  }

  Future<bool> _requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.locationWhenInUse,
      ].request();
      return statuses.values.every(
        (s) => s.isGranted || s.isLimited || s.isRestricted,
      );
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final status = await Permission.bluetooth.request();
      return status.isGranted || status.isLimited || status.isRestricted;
    }
    return true;
  }

  Future<void> startScan({Duration timeout = const Duration(seconds: 12)}) async {
    final ready = await ensureReady();
    if (!ready) return;

    await stopScan();
    _hits.clear();
    _scanController.add(const []);
    _emit(SensorBleConnectionState.scanning);

    _scanSub = FlutterBluePlus.scanResults.listen((results) {
      for (final result in results) {
        final name = result.device.platformName.isNotEmpty
            ? result.device.platformName
            : (result.advertisementData.advName);
        if (!SensorBleProtocol.matchesDeviceName(name)) continue;
        _hits[result.device.remoteId.str] = SensorBleScanHit(
          device: result.device,
          name: name,
          rssi: result.rssi,
        );
      }
      final sorted = _hits.values.toList()
        ..sort((a, b) => b.rssi.compareTo(a.rssi));
      _scanController.add(sorted);
    });

    await FlutterBluePlus.startScan(
      timeout: timeout,
      androidUsesFineLocation: true,
    );

    // If still scanning state after timeout and not connected, go idle.
    await Future<void>.delayed(timeout);
    if (_device == null) {
      await stopScan();
      _emit(SensorBleConnectionState.idle);
    }
  }

  Future<void> stopScan() async {
    await _scanSub?.cancel();
    _scanSub = null;
    try {
      await FlutterBluePlus.stopScan();
    } catch (_) {}
  }

  Future<void> connect(BluetoothDevice device) async {
    final ready = await ensureReady();
    if (!ready) return;

    await stopScan();
    await disconnect();
    _emit(SensorBleConnectionState.connecting);

    try {
      await device.connect(
        license: License.nonprofit,
        timeout: const Duration(seconds: 20),
      );
      _device = device;
      _connSub = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _teardownConnection(emitDisconnected: true);
        }
      });

      await device.discoverServices();
      BluetoothCharacteristic? tx;
      BluetoothCharacteristic? rx;
      for (final service in device.servicesList) {
        if (service.uuid != SensorBleProtocol.serviceUuid) continue;
        for (final c in service.characteristics) {
          if (c.uuid == SensorBleProtocol.txUuid) tx = c;
          if (c.uuid == SensorBleProtocol.rxUuid) rx = c;
        }
      }
      if (tx == null) {
        throw StateError('PakFasal sensor TX characteristic missing.');
      }
      _rxCharacteristic = rx;
      await tx.setNotifyValue(true);
      _notifySub = tx.onValueReceived.listen(_onNotifyBytes);

      _emit(SensorBleConnectionState.connected);
    } catch (e, st) {
      debugPrint('sensor_ble: connect failed: $e\n$st');
      await disconnect();
      _emit(SensorBleConnectionState.disconnected);
      rethrow;
    }
  }

  void _onNotifyBytes(List<int> bytes) {
    if (bytes.isEmpty) return;
    try {
      final text = utf8.decode(bytes, allowMalformed: true).trim();
      if (text.isEmpty) return;
      final decoded = jsonDecode(text);
      if (decoded is! Map) return;
      final map = Map<String, dynamic>.from(decoded);
      final moisture = (map['m'] as num?)?.toDouble();
      final ph = (map['p'] as num?)?.toDouble();
      final deviceId = (map['id'] as String?)?.trim();
      if (moisture == null || ph == null || deviceId == null || deviceId.isEmpty) {
        return;
      }
      final sample = LiveSensorSample(
        soilMoisture: moisture.clamp(0, 100).toDouble(),
        phLevel: ph.clamp(0, 14).toDouble(),
        deviceId: deviceId,
        source: 'ble',
        updatedAt: DateTime.now(),
        deviceName: _device?.platformName,
      );
      if (sample.isValid) {
        _sampleController.add(sample);
      }
    } catch (e) {
      debugPrint('sensor_ble: bad notify payload: $e');
    }
  }

  /// Optional WiFi + owner provisioning for the ESP32 hybrid firmware.
  Future<void> provisionWifi({
    required String ssid,
    required String password,
    required String ownerId,
  }) async {
    final rx = _rxCharacteristic;
    if (rx == null) {
      throw StateError('Sensor not connected for provisioning.');
    }
    final payload = utf8.encode(
      jsonEncode({
        'wifi': {'ssid': ssid, 'pass': password},
        'ownerId': ownerId,
      }),
    );
    await rx.write(payload, withoutResponse: false);
  }

  Future<void> disconnect() async {
    await _teardownConnection(emitDisconnected: false);
    _emit(SensorBleConnectionState.idle);
  }

  Future<void> _teardownConnection({required bool emitDisconnected}) async {
    await _notifySub?.cancel();
    _notifySub = null;
    await _connSub?.cancel();
    _connSub = null;
    _rxCharacteristic = null;
    final device = _device;
    _device = null;
    if (device != null) {
      try {
        await device.disconnect();
      } catch (_) {}
    }
    if (emitDisconnected) {
      _emit(SensorBleConnectionState.disconnected);
    }
  }

  void _emit(SensorBleConnectionState state) {
    if (!_connectionController.isClosed) {
      _connectionController.add(state);
    }
  }

  Future<void> dispose() async {
    await stopScan();
    await disconnect();
    await _connectionController.close();
    await _sampleController.close();
    await _scanController.close();
  }
}
