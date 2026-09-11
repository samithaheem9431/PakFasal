import 'dart:async';
import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/crop_calendar_models.dart';

/// Local Hive persistence for guest crop plantings (never written to Firebase).
class GuestCropPlantingStore {
  GuestCropPlantingStore({Box? box}) : _box = box;

  static const boxName = 'crop_calendar_guest';
  static const ownerId = 'guest';
  static const _listKey = 'plantings';

  Box? _box;
  final _controller = StreamController<List<CropPlanting>>.broadcast();

  Box get _ensureBox {
    final existing = _box;
    if (existing != null && existing.isOpen) return existing;
    _box = Hive.box(boxName);
    return _box!;
  }

  Stream<List<CropPlanting>> watch() async* {
    yield loadAll();
    yield* _controller.stream;
  }

  List<CropPlanting> loadAll() {
    final raw = _ensureBox.get(_listKey);
    if (raw is! String || raw.isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      final plantings = <CropPlanting>[];
      for (final item in decoded) {
        if (item is! Map) continue;
        final planting = _fromMap(Map<String, dynamic>.from(item));
        if (planting != null) plantings.add(planting);
      }
      plantings.sort((a, b) => b.sowingDate.compareTo(a.sowingDate));
      return plantings;
    } catch (_) {
      return const [];
    }
  }

  Future<CropPlanting> create({
    required CropType crop,
    required CropArea area,
    required DateTime sowingDate,
    String fieldLabel = '',
    bool remindersEnabled = true,
  }) async {
    final now = DateTime.now();
    final planting = CropPlanting(
      id: 'guest_${now.microsecondsSinceEpoch}',
      ownerId: ownerId,
      crop: crop,
      area: area,
      sowingDate: DateTime(sowingDate.year, sowingDate.month, sowingDate.day),
      completedStages: const [],
      remindersEnabled: remindersEnabled,
      fieldLabel: fieldLabel.trim(),
      createdAt: now,
      updatedAt: now,
    );
    final next = [planting, ...loadAll()];
    await _persist(next);
    return planting;
  }

  Future<void> update(CropPlanting planting) async {
    final list = loadAll();
    final index = list.indexWhere((p) => p.id == planting.id);
    if (index < 0) {
      throw StateError('Planting not found.');
    }
    final updated = planting.copyWith(
      ownerId: ownerId,
      updatedAt: DateTime.now(),
    );
    list[index] = updated;
    await _persist(list);
  }

  Future<void> setStageCompleted({
    required String plantingId,
    required CropStage stage,
    required bool completed,
  }) async {
    final list = loadAll();
    final index = list.indexWhere((p) => p.id == plantingId);
    if (index < 0) {
      throw StateError('Planting not found.');
    }
    final current = list[index];
    final stages = [...current.completedStages];
    if (completed) {
      if (!stages.contains(stage)) stages.add(stage);
    } else {
      stages.remove(stage);
    }
    list[index] = current.copyWith(
      completedStages: stages,
      updatedAt: DateTime.now(),
    );
    await _persist(list);
  }

  Future<void> delete(String plantingId) async {
    final list = loadAll().where((p) => p.id != plantingId).toList();
    await _persist(list);
  }

  Future<void> _persist(List<CropPlanting> plantings) async {
    final sorted = [...plantings]
      ..sort((a, b) => b.sowingDate.compareTo(a.sowingDate));
    final encoded = jsonEncode(sorted.map(_toMap).toList());
    await _ensureBox.put(_listKey, encoded);
    if (!_controller.isClosed) {
      _controller.add(sorted);
    }
  }

  Map<String, dynamic> _toMap(CropPlanting planting) {
    return {
      'id': planting.id,
      'ownerId': ownerId,
      'crop': planting.crop.name,
      'area': planting.area.name,
      'fieldLabel': planting.fieldLabel,
      'sowingDate': planting.sowingDate.toIso8601String(),
      'completedStages':
          planting.completedStages.map(CropPlanting.stageToKey).toList(),
      'remindersEnabled': planting.remindersEnabled,
      'createdAt': planting.createdAt?.toIso8601String(),
      'updatedAt': planting.updatedAt?.toIso8601String(),
    };
  }

  CropPlanting? _fromMap(Map<String, dynamic> data) {
    final crop = CropPlanting.cropFromKey(data['crop'] as String? ?? '');
    final area = CropPlanting.areaFromKey(data['area'] as String? ?? '');
    if (crop == null || area == null) return null;

    final sowingDate =
        DateTime.tryParse(data['sowingDate'] as String? ?? '') ?? DateTime.now();
    final completed = <CropStage>[];
    final completedRaw = data['completedStages'];
    if (completedRaw is List) {
      for (final item in completedRaw) {
        final stage = CropPlanting.stageFromKey(item.toString());
        if (stage != null) completed.add(stage);
      }
    }

    return CropPlanting(
      id: data['id'] as String? ?? '',
      ownerId: ownerId,
      crop: crop,
      area: area,
      sowingDate: DateTime(sowingDate.year, sowingDate.month, sowingDate.day),
      completedStages: completed,
      remindersEnabled: data['remindersEnabled'] as bool? ?? true,
      fieldLabel: data['fieldLabel'] as String? ?? '',
      createdAt: DateTime.tryParse(data['createdAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(data['updatedAt'] as String? ?? ''),
    );
  }

  void dispose() {
    _controller.close();
  }
}
