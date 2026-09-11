import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../domain/entities/crop_calendar_models.dart';

/// Schedules local notifications for upcoming crop-calendar stage windows.
///
/// Uses [flutter_local_notifications] only — no FCM, weather, or sensor copy.
class StageReminderScheduler {
  StageReminderScheduler({
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  static const _channelId = 'crop_stage_reminders';
  static const _channelName = 'Crop stage reminders';
  static const _channelDescription =
      'Reminders when a crop calendar stage window starts';

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Karachi'));
    } catch (_) {
      // Fall back to device local if zone data is unavailable.
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: android, iOS: ios);

    await _plugin.initialize(settings: settings);

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    _initialized = true;
  }

  /// Cancels existing stage reminders for [planting], then schedules one
  /// notification per upcoming incomplete stage (9:00 local on stage start).
  Future<void> syncPlantingReminders({
    required CropPlanting planting,
    required List<DatedStageWindow> windows,
    required String Function(CropStage stage) stageTitle,
    required String Function(CropStage stage) bodyForStage,
  }) async {
    await init();
    await cancelPlantingReminders(planting.id, windows);

    if (!planting.remindersEnabled) return;

    final now = DateTime.now();
    for (final window in windows) {
      if (planting.isStageCompleted(window.stage)) continue;
      if (!window.start.isAfter(now)) continue;

      final scheduled = tz.TZDateTime(
        tz.local,
        window.start.year,
        window.start.month,
        window.start.day,
        9,
      );
      if (!scheduled.isAfter(tz.TZDateTime.now(tz.local))) continue;

      final id = notificationId(planting.id, window.stage);
      try {
        await _plugin.zonedSchedule(
          id: id,
          title: stageTitle(window.stage),
          body: bodyForStage(window.stage),
          scheduledDate: scheduled,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              _channelId,
              _channelName,
              channelDescription: _channelDescription,
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
            ),
            iOS: const DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      } catch (e, st) {
        debugPrint('Stage reminder schedule failed ($id): $e\n$st');
      }
    }
  }

  Future<void> cancelPlantingReminders(
    String plantingId,
    List<DatedStageWindow> windows,
  ) async {
    await init();
    for (final window in windows) {
      await _plugin.cancel(id: notificationId(plantingId, window.stage));
    }
  }

  Future<void> cancelAllForPlanting(String plantingId) async {
    await init();
    for (final stage in CropStage.values) {
      await _plugin.cancel(id: notificationId(plantingId, stage));
    }
  }

  /// Stable 31-bit notification id from planting + stage.
  static int notificationId(String plantingId, CropStage stage) {
    final raw = Object.hash(plantingId, stage.name) & 0x7fffffff;
    return raw == 0 ? 1 : raw;
  }
}
