import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/repositories/crop_calendar_repository.dart';
import '../../data/repositories/crop_planting_repository.dart';
import '../../data/stage_reminder_scheduler.dart';
import '../../domain/entities/crop_calendar_models.dart';

/// Which segment is visible on the crop calendar screen.
enum CropCalendarTab { guide, myCrops, month }

/// State holder for the crop calendar screen.
///
/// Owns guide selections (crop + area), My Crops plantings (Firestore), and
/// month-view navigation. Reminder sync runs after planting mutations.
class CropCalendarProvider extends ChangeNotifier {
  CropCalendarProvider({
    CropCalendarRepository? repository,
    CropPlantingRepository? plantingRepository,
    StageReminderScheduler? reminderScheduler,
    DateTime Function()? clock,
    CropType initialCrop = CropType.wheat,
    CropArea initialArea = CropArea.multan,
    String Function(String key)? localize,
  })  : _repository = repository ?? const CropCalendarRepository(),
        _plantingRepository =
            plantingRepository ?? CropPlantingRepository(),
        _reminderScheduler = reminderScheduler ?? StageReminderScheduler(),
        _clock = clock ?? DateTime.now,
        _localize = localize,
        _selectedCrop = initialCrop,
        _selectedArea = initialArea {
    _refreshPlan();
  }

  final CropCalendarRepository _repository;
  final CropPlantingRepository _plantingRepository;
  final StageReminderScheduler _reminderScheduler;
  final DateTime Function() _clock;
  String Function(String key)? _localize;

  StreamSubscription<List<CropPlanting>>? _plantingsSub;

  CropType _selectedCrop;
  CropArea _selectedArea;
  CropCalendarPlan? _activePlan;

  CropCalendarTab _tab = CropCalendarTab.guide;
  List<CropPlanting> _plantings = const [];
  String? _activePlantingId;
  bool _plantingsLoading = false;
  String? _plantingsError;
  bool _mutating = false;
  DateTime _visibleMonth =
      DateTime(DateTime.now().year, DateTime.now().month);

  // ── Guide state ────────────────────────────────────────────────────────

  CropType get selectedCrop => _selectedCrop;
  CropArea get selectedArea => _selectedArea;
  CropCalendarPlan? get activePlan => _activePlan;

  List<CropType> get supportedCrops => _repository.supportedCrops;
  List<CropArea> get supportedAreas => _repository.supportedAreas;

  int get currentStageIndex {
    final plan = _activePlan;
    if (plan == null) return -1;
    return plan.currentStageIndex(_clock());
  }

  double get seasonProgress {
    final plan = _activePlan;
    if (plan == null) return 0;
    return plan.seasonProgress(_clock());
  }

  bool get isInSeason => currentStageIndex >= 0;

  // ── My Crops / auth ────────────────────────────────────────────────────

  CropCalendarTab get tab => _tab;
  List<CropPlanting> get plantings => _plantings;
  bool get plantingsLoading => _plantingsLoading;
  String? get plantingsError => _plantingsError;
  bool get isMutating => _mutating;
  bool get canManagePlantings => _plantingRepository.canManagePlantings;
  bool get usesCloudPlantings => _plantingRepository.usesCloud;
  DateTime get visibleMonth => _visibleMonth;

  CropPlanting? get activePlanting {
    if (_plantings.isEmpty) return null;
    if (_activePlantingId != null) {
      for (final p in _plantings) {
        if (p.id == _activePlantingId) return p;
      }
    }
    return _plantings.first;
  }

  String? get activePlantingId => activePlanting?.id;

  CropCalendarPlan? planForPlanting(CropPlanting planting) {
    return _repository.loadPlan(crop: planting.crop, area: planting.area);
  }

  List<DatedStageWindow> windowsForPlanting(CropPlanting planting) {
    final plan = planForPlanting(planting);
    if (plan == null) return const [];
    return PlantingSchedule.windowsFor(plan, planting.sowingDate);
  }

  /// Month-view stage markers: active planting if any, else guide plan months.
  List<DatedStageWindow> get monthWindows {
    final planting = activePlanting;
    if (planting != null) {
      return windowsForPlanting(planting);
    }
    final plan = _activePlan;
    if (plan == null) return const [];
    // Approximate guide windows using mid-month of sowing start in current year.
    final sowing = plan.sowingWindow;
    if (sowing == null) return const [];
    final year = _visibleMonth.year;
    final approxSowing = DateTime(year, sowing.startMonth, 15);
    return PlantingSchedule.windowsFor(plan, approxSowing);
  }

  double personalProgress(CropPlanting planting) {
    final windows = windowsForPlanting(planting);
    return PlantingSchedule.seasonProgress(windows, _clock());
  }

  double checklistProgress(CropPlanting planting) {
    final plan = planForPlanting(planting);
    if (plan == null) return 0;
    return PlantingSchedule.checklistProgress(plan, planting);
  }

  int personalStageIndex(CropPlanting planting) {
    return PlantingSchedule.currentStageIndex(
      windowsForPlanting(planting),
      _clock(),
    );
  }

  /// Optional l10n lookup for reminder text (set from UI).
  void setLocalizer(String Function(String key)? localize) {
    _localize = localize;
  }

  /// Starts listening to plantings (Firestore for registered, Hive for guests).
  void startWatchingPlantings() {
    if (_plantingsSub != null) return;
    _plantingsLoading = true;
    _plantingsError = null;
    notifyListeners();

    _plantingsSub = _plantingRepository.watchPlantings().listen(
      (list) {
        _plantings = list;
        _plantingsLoading = false;
        _plantingsError = null;
        if (_activePlantingId != null &&
            list.every((p) => p.id != _activePlantingId)) {
          _activePlantingId = list.isEmpty ? null : list.first.id;
        } else if (_activePlantingId == null && list.isNotEmpty) {
          _activePlantingId = list.first.id;
        }
        notifyListeners();
      },
      onError: (Object e, StackTrace st) {
        debugPrint('Plantings watch error: $e\n$st');
        _plantingsLoading = false;
        _plantingsError = e.toString();
        notifyListeners();
      },
    );
  }

  void selectTab(CropCalendarTab value) {
    if (_tab == value) return;
    _tab = value;
    notifyListeners();
  }

  void selectActivePlanting(String? id) {
    if (_activePlantingId == id) return;
    _activePlantingId = id;
    notifyListeners();
  }

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

  void goToPreviousMonth() {
    _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1);
    notifyListeners();
  }

  void goToNextMonth() {
    _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
    notifyListeners();
  }

  void goToCurrentMonth() {
    final now = _clock();
    _visibleMonth = DateTime(now.year, now.month);
    notifyListeners();
  }

  Future<void> addPlanting({
    required CropType crop,
    required CropArea area,
    required DateTime sowingDate,
    String fieldLabel = '',
    bool remindersEnabled = true,
  }) async {
    _mutating = true;
    notifyListeners();
    try {
      final planting = await _plantingRepository.createPlanting(
        crop: crop,
        area: area,
        sowingDate: sowingDate,
        fieldLabel: fieldLabel,
        remindersEnabled: remindersEnabled,
      );
      _activePlantingId = planting.id;
      _tab = CropCalendarTab.myCrops;
      await _syncRemindersFor(planting);
    } finally {
      _mutating = false;
      notifyListeners();
    }
  }

  Future<void> toggleStageCompleted({
    required CropPlanting planting,
    required CropStage stage,
  }) async {
    final completed = !planting.isStageCompleted(stage);
    _mutating = true;
    notifyListeners();
    try {
      await _plantingRepository.setStageCompleted(
        plantingId: planting.id,
        stage: stage,
        completed: completed,
      );
      final updated = planting.copyWith(
        completedStages: completed
            ? [...planting.completedStages, stage]
            : planting.completedStages.where((s) => s != stage).toList(),
      );
      await _syncRemindersFor(updated);
    } finally {
      _mutating = false;
      notifyListeners();
    }
  }

  Future<void> setRemindersEnabled({
    required CropPlanting planting,
    required bool enabled,
  }) async {
    final updated = planting.copyWith(remindersEnabled: enabled);
    _mutating = true;
    notifyListeners();
    try {
      await _plantingRepository.updatePlanting(updated);
      await _syncRemindersFor(updated);
    } finally {
      _mutating = false;
      notifyListeners();
    }
  }

  Future<void> deletePlanting(CropPlanting planting) async {
    _mutating = true;
    notifyListeners();
    try {
      await _reminderScheduler.cancelAllForPlanting(planting.id);
      await _plantingRepository.deletePlanting(planting.id);
      if (_activePlantingId == planting.id) {
        _activePlantingId = null;
      }
    } finally {
      _mutating = false;
      notifyListeners();
    }
  }

  Future<void> ensureRemindersInitialized() => _reminderScheduler.init();

  void _refreshPlan() {
    _activePlan = _repository.loadPlan(
      crop: _selectedCrop,
      area: _selectedArea,
    );
    notifyListeners();
  }

  Future<void> _syncRemindersFor(CropPlanting planting) async {
    final windows = windowsForPlanting(planting);
    final localize = _localize ?? (String key) => key;
    String stageLabel(CropStage stage) {
      final key = switch (stage) {
        CropStage.sowing => 'cropCalStageSowing',
        CropStage.irrigation => 'cropCalStageIrrigation',
        CropStage.fertilizer => 'cropCalStageFertilizer',
        CropStage.pestControl => 'cropCalStagePestControl',
        CropStage.harvest => 'cropCalStageHarvest',
      };
      return localize(key);
    }

    await _reminderScheduler.syncPlantingReminders(
      planting: planting,
      windows: windows,
      stageTitle: stageLabel,
      bodyForStage: (stage) => localize('cropCalReminderBody')
          .replaceAll('{stage}', stageLabel(stage)),
    );
  }

  @override
  void dispose() {
    _plantingsSub?.cancel();
    super.dispose();
  }
}
