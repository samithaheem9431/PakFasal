import 'package:flutter/foundation.dart';

import '../../data/crop_calendar_catalog.dart';
import '../../data/repositories/crop_calendar_repository.dart';
import '../../domain/entities/crop_calendar_models.dart';

/// Drives the Crop Calendar screen: which crop is selected, the user's
/// sowing plan for that crop, and the active region.
///
/// Persistence is delegated to [CropCalendarRepository] (Hive-backed).
/// All reads on Hive are synchronous, so the provider hydrates immediately
/// in [ensureLoaded] without flashing a loading state.
class CropCalendarProvider extends ChangeNotifier {
  CropCalendarProvider({CropCalendarRepository? repository})
      : _repository = repository ?? CropCalendarRepository();

  final CropCalendarRepository _repository;

  String _selectedCropId = CropCalendarCatalog.cropIds.first;
  UserCropPlan? _activePlan;
  CropRegion _region = CropRegion.lahore;
  bool _hydrated = false;

  // ── Public state ───────────────────────────────────────────────────────

  String get selectedCropId => _selectedCropId;
  CropCalendar get selectedCalendar =>
      CropCalendarCatalog.byId(_selectedCropId);
  UserCropPlan? get activePlan => _activePlan;
  CropRegion get region => _region;
  bool get hasPlan => _activePlan != null;

  /// True once initial Hive read has completed. Renders are safe before
  /// this flips because defaults are sane.
  bool get isHydrated => _hydrated;

  // ── Lifecycle ──────────────────────────────────────────────────────────

  /// Idempotent — call from `initState` of the screen.
  void ensureLoaded() {
    if (_hydrated) return;
    _selectedCropId = _repository.loadSelectedCropId(
      fallback: CropCalendarCatalog.cropIds.first,
    );
    _region = _repository.loadRegion();
    _activePlan = _repository.loadPlan(_selectedCropId);
    _hydrated = true;
    notifyListeners();
  }

  // ── Mutations ──────────────────────────────────────────────────────────

  Future<void> selectCrop(String cropId) async {
    if (cropId == _selectedCropId) return;
    _selectedCropId = cropId;
    _activePlan = _repository.loadPlan(cropId);
    await _repository.saveSelectedCropId(cropId);
    notifyListeners();
  }

  Future<void> setSowingDate(DateTime date) async {
    final existing = _activePlan;
    final next = existing == null
        ? UserCropPlan(cropId: _selectedCropId, sowingDate: date)
        : existing.copyWith(sowingDate: date);
    _activePlan = next;
    await _repository.savePlan(next);
    notifyListeners();
  }

  Future<void> setRemindersEnabled(bool enabled) async {
    final existing = _activePlan;
    if (existing == null) return;
    final next = existing.copyWith(remindersEnabled: enabled);
    _activePlan = next;
    await _repository.savePlan(next);
    notifyListeners();
  }

  Future<void> setRegion(CropRegion region) async {
    if (region == _region) return;
    _region = region;
    await _repository.saveRegion(region);
    notifyListeners();
  }

  Future<void> clearPlan() async {
    final cropId = _selectedCropId;
    _activePlan = null;
    await _repository.clearPlan(cropId);
    notifyListeners();
  }
}
