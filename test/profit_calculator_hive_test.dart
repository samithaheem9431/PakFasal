import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:pakfasal_app/src/features/profit_calculator/data/season_calculation_store.dart';
import 'package:pakfasal_app/src/features/profit_calculator/domain/entities/season_calculation.dart';
import 'package:pakfasal_app/src/features/profit_calculator/presentation/providers/profit_calculator_provider.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('profit_calc_hive_');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('saveSeason persists to Hive and reloads', () async {
    final store = SeasonCalculationStore();
    final provider = ProfitCalculatorProvider(store: store);

    provider.setCropName('Wheat');
    provider.setAreaAcres(2);
    provider.setSeedCost(1000);
    provider.setIncomeTotal(15000);

    final ok = await provider.saveSeason();
    expect(ok, isTrue);
    expect(provider.lastError, isNull);
    expect(provider.savedSeasons, hasLength(1));
    expect(provider.savedSeasons.first.cropName, 'Wheat');
    expect(provider.savedSeasons.first.profit, 14000);

    // Fresh store/provider simulates leaving and reopening the screen.
    final reloaded = ProfitCalculatorProvider(store: SeasonCalculationStore());
    await reloaded.refreshSaved();
    expect(reloaded.savedSeasons, hasLength(1));
    expect(reloaded.savedSeasons.first.cropName, 'Wheat');
    expect(reloaded.savedSeasons.first.totalExpense, 1000);
  });

  test('store save/load round trip without provider', () async {
    final store = SeasonCalculationStore();
    final season = SeasonCalculation(
      id: 'season_test',
      cropName: 'Cotton',
      areaAcres: 1,
      seedCost: 100,
      fertilizerCost: 200,
      pesticideCost: 0,
      labourCost: 0,
      irrigationCost: 0,
      transportCost: 0,
      otherCost: 0,
      incomeTotal: 1000,
      createdAt: DateTime(2026, 1, 1),
    );

    await store.save(season);
    final loaded = await store.loadAll();
    expect(loaded, hasLength(1));
    expect(loaded.first.id, 'season_test');
    expect(loaded.first.profit, 700);
  });
}
