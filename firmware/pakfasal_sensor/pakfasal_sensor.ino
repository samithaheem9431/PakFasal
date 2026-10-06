/*
 * PakFasal hybrid soil node (ESP32)
 * ---------------------------------
 * BLE: advertises as PakFasal-<last4MAC>, Nordic UART service
 *      TX notify JSON: {"m":45.2,"p":6.8,"id":"<deviceId>"}
 *      RX write JSON:  {"wifi":{"ssid":"...","pass":"..."},"ownerId":"..."}
 * WiFi: PATCH Firestore REST doc sensor_live/{deviceId}
 *
 * Pins (change if needed):
 *   Moisture (capacitive analog) -> GPIO34
 *   pH analog                    -> GPIO35
 *
 * Libraries (Arduino Library Manager):
 *   - ESP32 BLE Arduino (built-in with ESP32 core)
 *   - ArduinoJson
 *   - Preferences (built-in)
 *
 * Before WiFi cloud upload works, set FIREBASE_API_KEY and FIREBASE_PROJECT_ID
 * below (Firebase Console → Project settings). Firestore rules already allow
 * sensor_live writes that include matching deviceId + moisture/ph bounds.
 */

#include <Arduino.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <WiFi.h>
#include <HTTPClient.h>
#include <Preferences.h>
#include <ArduinoJson.h>

// ===== USER CONFIG =====
static const char *FIREBASE_API_KEY = "YOUR_FIREBASE_WEB_API_KEY";
static const char *FIREBASE_PROJECT_ID = "YOUR_FIREBASE_PROJECT_ID";
static const int MOISTURE_PIN = 34;
static const int PH_PIN = 35;
static const uint32_t BLE_NOTIFY_MS = 2000;
static const uint32_t WIFI_UPLOAD_MS = 60000;

// Nordic UART UUIDs (must match Flutter SensorBleProtocol)
#define SERVICE_UUID           "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
#define CHARACTERISTIC_UUID_RX "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
#define CHARACTERISTIC_UUID_TX "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"

Preferences prefs;
BLECharacteristic *pTxCharacteristic = nullptr;
bool deviceConnected = false;
String deviceId;
String wifiSsid;
String wifiPass;
String ownerId;
uint32_t lastBleNotify = 0;
uint32_t lastWifiUpload = 0;

float readMoisturePercent() {
  // Capacitive sensors: dry ~high ADC, wet ~low. Calibrate for your probe.
  int raw = analogRead(MOISTURE_PIN);
  float pct = map(raw, 3200, 1400, 0, 100);
  if (pct < 0) pct = 0;
  if (pct > 100) pct = 100;
  return pct;
}

float readPh() {
  // Placeholder linear map — calibrate with buffer solutions.
  int raw = analogRead(PH_PIN);
  float voltage = raw * (3.3f / 4095.0f);
  float ph = 7.0f + ((2.5f - voltage) * 3.5f);
  if (ph < 0) ph = 0;
  if (ph > 14) ph = 14;
  return ph;
}

String buildReadingJson(float m, float p) {
  StaticJsonDocument<192> doc;
  doc["m"] = m;
  doc["p"] = p;
  doc["id"] = deviceId;
  String out;
  serializeJson(doc, out);
  return out;
}

void tryConnectWifi() {
  if (wifiSsid.isEmpty()) return;
  if (WiFi.status() == WL_CONNECTED) return;
  WiFi.mode(WIFI_STA);
  WiFi.begin(wifiSsid.c_str(), wifiPass.c_str());
  uint32_t start = millis();
  while (WiFi.status() != WL_CONNECTED && millis() - start < 15000) {
    delay(250);
  }
}

void uploadFirestore(float m, float p) {
  if (WiFi.status() != WL_CONNECTED) {
    tryConnectWifi();
    if (WiFi.status() != WL_CONNECTED) return;
  }
  if (String(FIREBASE_API_KEY) == "YOUR_FIREBASE_WEB_API_KEY") return;

  String url = String("https://firestore.googleapis.com/v1/projects/") +
               FIREBASE_PROJECT_ID +
               "/databases/(default)/documents/sensor_live/" + deviceId +
               "?key=" + FIREBASE_API_KEY +
               "&updateMask.fieldPaths=deviceId" +
               "&updateMask.fieldPaths=soilMoisture" +
               "&updateMask.fieldPaths=phLevel" +
               "&updateMask.fieldPaths=source" +
               "&updateMask.fieldPaths=updatedAt" +
               "&updateMask.fieldPaths=ownerId" +
               "&updateMask.fieldPaths=deviceName";

  StaticJsonDocument<512> body;
  JsonObject fields = body.createNestedObject("fields");
  fields["deviceId"]["stringValue"] = deviceId;
  fields["soilMoisture"]["doubleValue"] = m;
  fields["phLevel"]["doubleValue"] = p;
  fields["source"]["stringValue"] = "wifi";
  fields["deviceName"]["stringValue"] = String("PakFasal-") + deviceId.substring(deviceId.length() > 4 ? deviceId.length() - 4 : 0);
  if (!ownerId.isEmpty()) {
    fields["ownerId"]["stringValue"] = ownerId;
  }
  // Server timestamp via client clock (ms since epoch as integer string).
  fields["updatedAt"]["integerValue"] = String((long long)time(nullptr));

  // Prefer timestampValue RFC3339:
  time_t now = time(nullptr);
  if (now > 100000) {
    char buf[32];
    strftime(buf, sizeof(buf), "%Y-%m-%dT%H:%M:%SZ", gmtime(&now));
    fields.remove("updatedAt");
    fields["updatedAt"]["timestampValue"] = buf;
  }

  String payload;
  serializeJson(body, payload);

  HTTPClient http;
  http.begin(url);
  http.addHeader("Content-Type", "application/json");
  int code = http.PATCH(payload);
  Serial.printf("Firestore PATCH %d\n", code);
  http.end();
}

class ServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer *pServer) override { deviceConnected = true; }
  void onDisconnect(BLEServer *pServer) override {
    deviceConnected = false;
    pServer->startAdvertising();
  }
};

class RxCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *pCharacteristic) override {
    String value = pCharacteristic->getValue().c_str();
    if (value.length() == 0) return;
    StaticJsonDocument<384> doc;
    if (deserializeJson(doc, value)) return;
    if (doc.containsKey("wifi")) {
      wifiSsid = doc["wifi"]["ssid"] | "";
      wifiPass = doc["wifi"]["pass"] | "";
      prefs.putString("ssid", wifiSsid);
      prefs.putString("pass", wifiPass);
      tryConnectWifi();
    }
    if (doc.containsKey("ownerId")) {
      ownerId = doc["ownerId"] | "";
      prefs.putString("ownerId", ownerId);
    }
  }
};

void setup() {
  Serial.begin(115200);
  analogReadResolution(12);

  prefs.begin("pakfasal", false);
  wifiSsid = prefs.getString("ssid", "");
  wifiPass = prefs.getString("pass", "");
  ownerId = prefs.getString("ownerId", "");

  uint64_t mac = ESP.getEfuseMac();
  char idBuf[20];
  snprintf(idBuf, sizeof(idBuf), "%04X%08X", (uint16_t)(mac >> 32), (uint32_t)mac);
  deviceId = String(idBuf);
  String advName = String("PakFasal-") + deviceId.substring(deviceId.length() - 4);

  BLEDevice::init(advName.c_str());
  BLEServer *pServer = BLEDevice::createServer();
  pServer->setCallbacks(new ServerCallbacks());
  BLEService *pService = pServer->createService(SERVICE_UUID);
  pTxCharacteristic = pService->createCharacteristic(
      CHARACTERISTIC_UUID_TX,
      BLECharacteristic::PROPERTY_NOTIFY);
  pTxCharacteristic->addDescriptor(new BLE2902());
  BLECharacteristic *pRxCharacteristic = pService->createCharacteristic(
      CHARACTERISTIC_UUID_RX,
      BLECharacteristic::PROPERTY_WRITE);
  pRxCharacteristic->setCallbacks(new RxCallbacks());
  pService->start();
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->start();

  configTime(0, 0, "pool.ntp.org");
  tryConnectWifi();
  Serial.printf("Advertising as %s id=%s\n", advName.c_str(), deviceId.c_str());
}

void loop() {
  float m = readMoisturePercent();
  float p = readPh();
  uint32_t now = millis();

  if (deviceConnected && pTxCharacteristic && (now - lastBleNotify >= BLE_NOTIFY_MS)) {
    lastBleNotify = now;
    String json = buildReadingJson(m, p);
    pTxCharacteristic->setValue(json.c_str());
    pTxCharacteristic->notify();
  }

  if (now - lastWifiUpload >= WIFI_UPLOAD_MS) {
    lastWifiUpload = now;
    uploadFirestore(m, p);
  }
}
