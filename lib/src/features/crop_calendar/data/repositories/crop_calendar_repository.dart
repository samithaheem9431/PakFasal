import 'dart:convert';

import 'package:hive/hive.dart';

import '../../domain/entities/crop_calendar_models.dart';

/// Persists per-user crop calendar preferences in the existing
/// `app_preferences` Hive box (already opened in `main.dart`).
///
/// Layout:
///   * `crop_plan_<cropId>`    → JSON-encoded [UserCropPlan] (per crop)
///   * `crop_selected_id`      → last-selected crop id (String)
///   * `crop_region`           → enum name of [CropRegion]
class CropCalendarRepository {
  CropCalendarRepository({Box? box})
      : _box = box ?? Hive.box(_boxName);

  static const _boxName = 'app_preferences';
  static const _planKeyPrefix = 'crop_plan_';
  static const _selectedKey = 'crop_selected_id';
  static const _regionKey = 'crop_region';

  final Box _box;

  // ── Selected crop ───────────────────────────────────────────────────────

  String loadSelectedCropId({required String fallback}) {
    final raw = _box.get(_selectedKey) as String?;
    return (raw == null || raw.isEmpty) ? fallback : raw;
  }

  Future<void> saveSelectedCropId(String cropId) async {
    await _box.put(_selectedKey, cropId);
  }

  // ── Region ─────────────────────────────────────────────────────────────

  CropRegion loadRegion() {
    final raw = _box.get(_regionKey) as String?;
    if (raw == null) return CropRegion.lahore;
    return CropRegion.values.firstWhere(
      (r) => r.name == raw,
      orElse: () => CropRegion.lahore,
    );
  }

  Future<void> saveRegion(CropRegion region) async {
    await _box.put(_regionKey, region.name);
  }

  // ── Per-crop plan ──────────────────────────────────────────────────────

  UserCropPlan? loadPlan(String cropId) {
    final raw = _box.get('$_planKeyPrefix$cropId') as String?;
    if (raw == null || raw.isEmpty) return null;
    try {
      return UserCropPlan.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> savePlan(UserCropPlan plan) async {
    await _box.put(
      '$_planKeyPrefix${plan.cropId}',
      jsonEncode(plan.toJson()),
    );
  }

  Future<void> clearPlan(String cropId) async {
    await _box.delete('$_planKeyPrefix$cropId');
  }
}
