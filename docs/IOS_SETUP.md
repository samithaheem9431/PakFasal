# PakFasal — iPhone build (Mac checklist)

Windows se iOS build nahi hota. Dost ka Mac milne pe ye steps follow karo.

**Bundle ID:** `com.example.pakfasalApp`  
**Firebase project:** `pakfasalapp`

---

## 1. Mac pe software

1. App Store se **Xcode** install karo, kholo, license accept karo.
2. Terminal:

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
sudo gem install cocoapods
```

3. [Flutter](https://docs.flutter.dev/get-started/install/macos) install karo, phir:

```bash
flutter doctor
```

Xcode / CocoaPods green hone chahiye.

---

## 2. Project copy

Project USB / GitHub se Mac pe lao. Phir:

```bash
cd /path/to/pakfasal_app
flutter pub get
cd ios
pod install
cd ..
```

Local config (agar use karte ho):

```bash
cp config/app_config.json config/dev.json
# edit config/dev.json as needed
```

---

## 3. Firebase — `GoogleService-Info.plist`

1. [Firebase Console](https://console.firebase.google.com) → project **pakfasalapp**
2. Project settings → Your apps → iOS app (`com.example.pakfasalApp`)
3. **GoogleService-Info.plist** download karo
4. File ko `ios/Runner/GoogleService-Info.plist` pe rakho
5. Xcode mein `Runner.xcworkspace` kholo → ensure file **Runner** target mein checked ho

Agar Bundle ID change kiya to Firebase mein naya iOS app add karo aur `lib/firebase_options.dart` update karo (`flutterfire configure`).

---

## 4. iPhone ready

1. Cable se Mac se connect
2. iPhone pe **Trust This Computer**
3. **Settings → Privacy & Security → Developer Mode** → ON (restart)
4. Free Apple ID se testing OK (app ~7 din chalega, phir dubara sign)

---

## 5. Xcode signing

1. Kholo: `ios/Runner.xcworkspace` (`.xcodeproj` nahi)
2. Left pe **Runner** target select
3. **Signing & Capabilities**
   - **Automatically manage signing** ON
   - **Team** = apna Apple ID (Add Account se login)
   - Bundle Identifier = `com.example.pakfasalApp`  
     (agar “already in use” aaye to `com.yourname.pakfasal` rakho — Firebase se match karna)
4. Top device dropdown se apna **iPhone** select

---

## 6. Run

```bash
flutter devices
flutter run
```

Ya Xcode ▶ Play.

Pehli dafa iPhone pe:

**Settings → General → VPN & Device Management** → developer app → **Trust**

---

## Common errors

| Error | Fix |
|-------|-----|
| No devices | Cable, Trust, Developer Mode |
| Signing failed | Team select, unique Bundle ID |
| `pod install` fail | `flutter pub get` pehle, phir `cd ios && pod install` |
| Firebase / Crashlytics crash | `GoogleService-Info.plist` missing / wrong target |
| Face ID crash | `NSFaceIDUsageDescription` already added in `Info.plist` |

---

## Permissions already in app

`ios/Runner/Info.plist` mein ye set hain:

- Location (weather)
- Microphone + Speech (voice chat)
- Face ID (secure unlock)
