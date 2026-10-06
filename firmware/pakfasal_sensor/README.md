# PakFasal ESP32 soil sensor (BLE + WiFi)

Flash `pakfasal_sensor.ino` with Arduino IDE / PlatformIO (ESP32 board).

## Wiring

| Sensor | ESP32 pin |
|--------|-----------|
| Capacitive moisture (AO) | GPIO34 |
| Soil pH module (AO) | GPIO35 |
| Both VCC | 3.3V (or 5V if module requires it — use level care) |
| Both GND | GND |

## App flow

1. Power the ESP32 — it advertises as `PakFasal-XXXX`.
2. In PakFasal → Sensor Data → **Scan Bluetooth** → Connect.
3. Live moisture/pH appears; tap **Get advice**.
4. Optional: **Wi‑Fi setup** while BLE-connected (sends SSID/password + ownerId).
5. Set `FIREBASE_API_KEY` + `FIREBASE_PROJECT_ID` in the sketch for cloud uploads to `sensor_live/{deviceId}`.

## Protocol

Notify JSON: `{"m":45.2,"p":6.8,"id":"AABBCCDD"}`  
Provision JSON: `{"wifi":{"ssid":"...","pass":"..."},"ownerId":"..."}`
