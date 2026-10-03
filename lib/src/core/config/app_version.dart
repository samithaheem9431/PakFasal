/// Single source of truth for the marketing version shown in-app.
///
/// Keep in sync with `version:` in `pubspec.yaml` (the `x.y.z` part before `+`).
/// Build number (`+N`) is for store uploads and is not shown to users.
class AppVersion {
  AppVersion._();

  /// User-facing semantic version (e.g. Play Store "version name").
  static const String name = '1.0.0';

  /// Monotonic build number (Play Store "version code").
  static const int build = 2;

  /// Full Flutter version string: `name+build`.
  static const String full = '$name+$build';
}
