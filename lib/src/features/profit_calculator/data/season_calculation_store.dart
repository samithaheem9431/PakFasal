import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../domain/entities/season_calculation.dart';

/// Local Hive persistence for crop-season profit calculations.
class SeasonCalculationStore {
  SeasonCalculationStore({Box? box}) : _box = box;

  static const boxName = 'profit_calculator';
  static const _listKey = 'seasons';

  Box? _box;

  Box get _ensureBox {
    final existing = _box;
    if (existing != null && existing.isOpen) return existing;
    _box = Hive.box(boxName);
    return _box!;
  }

  List<SeasonCalculation> loadAll() {
    final raw = _ensureBox.get(_listKey);
    if (raw is! String || raw.isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
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
      return const [];
    }
  }

  Future<void> save(SeasonCalculation season) async {
    final list = loadAll();
    final index = list.indexWhere((s) => s.id == season.id);
    if (index >= 0) {
      list[index] = season;
    } else {
      list.insert(0, season);
    }
    await _persist(list);
  }

  Future<void> delete(String id) async {
    final list = loadAll().where((s) => s.id != id).toList();
    await _persist(list);
  }

  Future<void> _persist(List<SeasonCalculation> seasons) async {
    final sorted = [...seasons]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final encoded = jsonEncode(sorted.map((s) => s.toMap()).toList());
    await _ensureBox.put(_listKey, encoded);
  }
}
