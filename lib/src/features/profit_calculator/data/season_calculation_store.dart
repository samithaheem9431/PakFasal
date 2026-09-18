import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../domain/entities/season_calculation.dart';

/// Local Hive persistence for crop-season profit calculations.
class SeasonCalculationStore {
  SeasonCalculationStore({Box? box}) : _box = box;

  static const boxName = 'profit_calculator';
  static const _listKey = 'seasons';

  Box? _box;

  Future<Box> _ensureBox() async {
    final existing = _box;
    if (existing != null && existing.isOpen) return existing;

    if (Hive.isBoxOpen(boxName)) {
      _box = Hive.box(boxName);
    } else {
      _box = await Hive.openBox(boxName);
    }
    return _box!;
  }

  Future<List<SeasonCalculation>> loadAll() async {
    try {
      final box = await _ensureBox();
      final raw = box.get(_listKey);
      if (raw is! String || raw.isEmpty) return <SeasonCalculation>[];

      final decoded = jsonDecode(raw);
      if (decoded is! List) return <SeasonCalculation>[];

      final seasons = <SeasonCalculation>[];
      for (final item in decoded) {
        if (item is! Map) continue;
        final season =
            SeasonCalculation.fromMap(Map<String, dynamic>.from(item));
        if (season != null) seasons.add(season);
      }
      seasons.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return seasons;
    } catch (_) {
      return <SeasonCalculation>[];
    }
  }

  Future<void> save(SeasonCalculation season) async {
    final list = [...await loadAll()];
    final index = list.indexWhere((s) => s.id == season.id);
    if (index >= 0) {
      list[index] = season;
    } else {
      list.insert(0, season);
    }
    await _persist(list);
  }

  Future<void> delete(String id) async {
    final list = [...await loadAll()]..removeWhere((s) => s.id == id);
    await _persist(list);
  }

  Future<void> _persist(List<SeasonCalculation> seasons) async {
    final box = await _ensureBox();
    final sorted = [...seasons]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final encoded = jsonEncode(sorted.map((s) => s.toMap()).toList());
    await box.put(_listKey, encoded);
    await box.flush();
  }
}
