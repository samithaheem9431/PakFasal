import 'package:flutter_test/flutter_test.dart';
import 'package:pakfasal_app/src/features/profit_calculator/domain/entities/season_calculation.dart';

void main() {
  test('computes expense, profit, per-acre and margin', () {
    final season = SeasonCalculation(
      id: '1',
      cropName: 'Wheat',
      areaAcres: 2,
      seedCost: 1000,
      fertilizerCost: 2000,
      pesticideCost: 500,
      labourCost: 3000,
      irrigationCost: 1500,
      transportCost: 500,
      otherCost: 500,
      incomeTotal: 20000,
      createdAt: DateTime(2026, 1, 1),
    );

    expect(season.totalExpense, 9000);
    expect(season.profit, 11000);
    expect(season.profitPerAcre, 5500);
    expect(season.marginPercent, closeTo(55, 0.01));
  });

  test('round-trips through toMap/fromMap', () {
    final season = SeasonCalculation(
      id: 'season_1',
      cropName: 'Cotton',
      areaAcres: 1.5,
      seedCost: 100,
      fertilizerCost: 200,
      pesticideCost: 0,
      labourCost: 300,
      irrigationCost: 0,
      transportCost: 0,
      otherCost: 50,
      incomeTotal: 5000,
      yieldAmount: 10,
      marketRate: 500,
      createdAt: DateTime(2026, 3, 15, 10, 30),
    );

    final restored = SeasonCalculation.fromMap(season.toMap());
    expect(restored, isNotNull);
    expect(restored!.id, season.id);
    expect(restored.cropName, 'Cotton');
    expect(restored.totalExpense, 650);
    expect(restored.profit, 4350);
    expect(restored.yieldAmount, 10);
    expect(restored.marketRate, 500);
  });

  test('guards per-acre and margin when zero', () {
    final season = SeasonCalculation(
      id: '2',
      cropName: 'Rice',
      areaAcres: 0,
      seedCost: 100,
      fertilizerCost: 0,
      pesticideCost: 0,
      labourCost: 0,
      irrigationCost: 0,
      transportCost: 0,
      otherCost: 0,
      incomeTotal: 0,
      createdAt: DateTime(2026, 1, 1),
    );

    expect(season.profitPerAcre, isNull);
    expect(season.marginPercent, isNull);
    expect(season.profit, -100);
  });
}
