import 'package:flutter/foundation.dart';

import '../../data/repositories/crop_calendar_repository.dart';
import '../../domain/entities/crop_calendar_models.dart';

/// State holder for the crop calendar screen.
///
/// Owns the user's current selections (crop + area) and exposes the
/// resolved [CropCalendarPlan] plus derived values (current stage index,
/// season progress) so widgets can stay simple.
///
/// Designed for reuse: the home dashboard or a future "season summary"
/// card can read the same provider via Provider.of without re-loading.
class CropCalendarProvider extends ChangeNotifier {
  CropCalendarProvider({
    CropCalendarRepository? repository,
    DateTime Function()? clock,
    CropType initialCrop = CropType.wheat,
    CropArea initialArea = CropArea.multan,
  })  : _repository = repository ?? const CropCalendarRepository(),
        _clock = clock ?? DateTime.now,
        _selectedCrop = initialCrop,
        _selectedArea = initialArea {
    _refreshPlan();
  }

  final CropCalendarRepository _repository;
  final DateTime Function() _clock;

  CropType _selectedCrop;
  CropArea _selectedArea;
  CropCalendarPlan? _activePlan;

  // ── Read-only state ────────────────────────────────────────────────────

  CropType get selectedCrop => _selectedCrop;
  CropArea get selectedArea => _selectedArea;
  CropCalendarPlan? get activePlan => _activePlan;

  List<CropType> get supportedCrops => _repository.supportedCrops;
  List<CropArea> get supportedAreas => _repository.supportedAreas;

  /// Current stage index in [activePlan]. `-1` means off-season.
  int get currentStageIndex {
    final plan = _activePlan;
    if (plan == null) return -1;
    return plan.currentStageIndex(_clock());
  }

  /// Season progress from sowing start to harvest end, clamped `[0, 1]`.
  double get seasonProgress {
    final plan = _activePlan;
    if (plan == null) return 0;
    return plan.seasonProgress(_clock());
  }

  /// Whether the active plan is in-season for "today".
  bool get isInSeason => currentStageIndex >= 0;

  // ── Mutations ──────────────────────────────────────────────────────────

  void selectCrop(CropType crop) {
    if (_selectedCrop == crop) return;
    _selectedCrop = crop;
    _refreshPlan();
  }

  void selectArea(CropArea area) {
    if (_selectedArea == area) return;
    _selectedArea = area;
    _refreshPlan();
  }

  // ── Internal ───────────────────────────────────────────────────────────

  void _refreshPlan() {
    _activePlan = _repository.loadPlan(
      crop: _selectedCrop,
      area: _selectedArea,
    );
    notifyListeners();
  }
}
