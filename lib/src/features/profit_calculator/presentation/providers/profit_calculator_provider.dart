import 'package:flutter/material.dart';

import '../../data/season_calculation_store.dart';
import '../../domain/entities/season_calculation.dart';

enum IncomeMode { totalSale, yieldTimesRate }

class ProfitCalculatorProvider extends ChangeNotifier {
  ProfitCalculatorProvider({SeasonCalculationStore? store})
      : _store = store ?? SeasonCalculationStore() {
    // Load saved seasons after construction (async Hive open-safe).
    Future.microtask(refreshSaved);
  }

  final SeasonCalculationStore _store;

  String _editingId = '';
  String cropName = '';
  double areaAcres = 0;
  double seedCost = 0;
  double fertilizerCost = 0;
  double pesticideCost = 0;
  double labourCost = 0;
  double irrigationCost = 0;
  double transportCost = 0;
  double otherCost = 0;
  double incomeTotal = 0;
  double yieldAmount = 0;
  double marketRate = 0;
  IncomeMode incomeMode = IncomeMode.totalSale;

  List<SeasonCalculation> savedSeasons = const [];
  int formSyncToken = 0;
  bool isSaving = false;
  String? lastError;

  double get totalExpense =>
      seedCost +
      fertilizerCost +
      pesticideCost +
      labourCost +
      irrigationCost +
      transportCost +
      otherCost;

  double get effectiveIncome {
    if (incomeMode == IncomeMode.yieldTimesRate) {
      return yieldAmount * marketRate;
    }
    return incomeTotal;
  }

  double get profit => effectiveIncome - totalExpense;

  double? get profitPerAcre =>
      areaAcres > 0 ? profit / areaAcres : null;

  double? get marginPercent =>
      effectiveIncome > 0 ? (profit / effectiveIncome) * 100 : null;

  bool get canSave => cropName.trim().isNotEmpty;

  Future<void> refreshSaved() async {
    try {
      savedSeasons = await _store.loadAll();
      lastError = null;
    } catch (e) {
      savedSeasons = <SeasonCalculation>[];
      lastError = e.toString();
    }
    notifyListeners();
  }

  void setCropName(String value) {
    cropName = value;
    notifyListeners();
  }

  void setAreaAcres(double value) {
    areaAcres = value;
    notifyListeners();
  }

  void setSeedCost(double value) {
    seedCost = value;
    notifyListeners();
  }

  void setFertilizerCost(double value) {
    fertilizerCost = value;
    notifyListeners();
  }

  void setPesticideCost(double value) {
    pesticideCost = value;
    notifyListeners();
  }

  void setLabourCost(double value) {
    labourCost = value;
    notifyListeners();
  }

  void setIrrigationCost(double value) {
    irrigationCost = value;
    notifyListeners();
  }

  void setTransportCost(double value) {
    transportCost = value;
    notifyListeners();
  }

  void setOtherCost(double value) {
    otherCost = value;
    notifyListeners();
  }

  void setIncomeTotal(double value) {
    incomeTotal = value;
    notifyListeners();
  }

  void setYieldAmount(double value) {
    yieldAmount = value;
    notifyListeners();
  }

  void setMarketRate(double value) {
    marketRate = value;
    notifyListeners();
  }

  void setIncomeMode(IncomeMode mode) {
    incomeMode = mode;
    notifyListeners();
  }

  void clearForm() {
    _editingId = '';
    cropName = '';
    areaAcres = 0;
    seedCost = 0;
    fertilizerCost = 0;
    pesticideCost = 0;
    labourCost = 0;
    irrigationCost = 0;
    transportCost = 0;
    otherCost = 0;
    incomeTotal = 0;
    yieldAmount = 0;
    marketRate = 0;
    incomeMode = IncomeMode.totalSale;
    formSyncToken++;
    notifyListeners();
  }

  void loadSeason(SeasonCalculation season) {
    _editingId = season.id;
    cropName = season.cropName;
    areaAcres = season.areaAcres;
    seedCost = season.seedCost;
    fertilizerCost = season.fertilizerCost;
    pesticideCost = season.pesticideCost;
    labourCost = season.labourCost;
    irrigationCost = season.irrigationCost;
    transportCost = season.transportCost;
    otherCost = season.otherCost;
    incomeTotal = season.incomeTotal;
    yieldAmount = season.yieldAmount;
    marketRate = season.marketRate;
    incomeMode = (season.yieldAmount > 0 || season.marketRate > 0)
        ? IncomeMode.yieldTimesRate
        : IncomeMode.totalSale;
    formSyncToken++;
    notifyListeners();
  }

  /// Returns `true` on success, `false` if crop name missing, throws on Hive errors
  /// only after setting [lastError] — callers should check return + [lastError].
  Future<bool> saveSeason() async {
    if (!canSave) {
      lastError = null;
      return false;
    }

    isSaving = true;
    lastError = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final income = effectiveIncome;
      DateTime createdAt = now;
      if (_editingId.isNotEmpty) {
        for (final s in savedSeasons) {
          if (s.id == _editingId) {
            createdAt = s.createdAt;
            break;
          }
        }
      }

      final season = SeasonCalculation(
        id: _editingId.isEmpty
            ? 'season_${now.microsecondsSinceEpoch}'
            : _editingId,
        cropName: cropName.trim(),
        areaAcres: areaAcres,
        seedCost: seedCost,
        fertilizerCost: fertilizerCost,
        pesticideCost: pesticideCost,
        labourCost: labourCost,
        irrigationCost: irrigationCost,
        transportCost: transportCost,
        otherCost: otherCost,
        incomeTotal: income,
        yieldAmount:
            incomeMode == IncomeMode.yieldTimesRate ? yieldAmount : 0,
        marketRate:
            incomeMode == IncomeMode.yieldTimesRate ? marketRate : 0,
        createdAt: createdAt,
      );

      await _store.save(season);
      _editingId = season.id;
      savedSeasons = await _store.loadAll();
      return true;
    } catch (e) {
      lastError = e.toString();
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> deleteSeason(String id) async {
    try {
      await _store.delete(id);
      lastError = null;
      if (_editingId == id) {
        clearForm();
        await refreshSaved();
      } else {
        await refreshSaved();
      }
    } catch (e) {
      lastError = e.toString();
      notifyListeners();
    }
  }
}
