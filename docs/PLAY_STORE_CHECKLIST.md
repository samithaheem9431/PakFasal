# Play Store readiness (Privacy / Data Safety)

## Done in the app

- In-app **Privacy Policy** screen: About → Privacy Policy, Profile → Privacy Policy
- Online defaults (GitHub Pages — site published from repo root):
  - https://samithaheem9431.github.io/PakFasal/docs/privacy/
  - https://samithaheem9431.github.io/PakFasal/docs/delete-account/
- Pages files: `docs/privacy/`, `docs/delete-account/`, `docs/index.html`
- Account delete also wipes **crop plantings** (plus profile + sensor readings)
- Unused signup **phone** field removed
- Release signing ready when you add `android/key.properties`
- **AdMob left on Google test IDs** (testing phase)

## You still must do before Play submission

1. **Push** these `docs/` changes to `main`, then enable GitHub Pages (`/docs` on `main`) — see `docs/legal/README.md`.
2. Confirm both URLs open publicly in a browser.
3. Play Console → **App content → Privacy policy** → paste Privacy URL.
4. Play Console → **Data safety** → fill form + **Account deletion** URL.
5. Declare **Contains ads = Yes**.
6. When leaving testing: production AdMob IDs + upload keystore, then:
   `flutter build appbundle --release`
