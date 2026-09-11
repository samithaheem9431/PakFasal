import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/crop_calendar_models.dart';
import 'guest_crop_planting_store.dart';

/// Crop plantings CRUD:
/// - Registered Firebase users → Firestore (`crop_plantings`)
/// - Guests / no Auth session → local Hive ([GuestCropPlantingStore])
class CropPlantingRepository {
  CropPlantingRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    GuestCropPlantingStore? guestStore,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _guestStore = guestStore ?? GuestCropPlantingStore();

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GuestCropPlantingStore _guestStore;

  static const _collection = 'crop_plantings';

  String? get currentOwnerId {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) return null;
    return uid;
  }

  /// True when plantings can be managed (Firebase user or guest local store).
  bool get canManagePlantings => true;

  bool get usesCloud => currentOwnerId != null;

  /// Streams plantings for the active identity.
  /// Re-routes between Firestore and Hive when auth changes.
  Stream<List<CropPlanting>> watchPlantings() {
    late final StreamController<List<CropPlanting>> controller;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? querySub;
    StreamSubscription<List<CropPlanting>>? guestSub;
    StreamSubscription<User?>? authSub;

    Future<void> subscribeForCurrentOwner() async {
      await querySub?.cancel();
      await guestSub?.cancel();
      querySub = null;
      guestSub = null;

      final uid = _auth.currentUser?.uid;
      if (uid == null || uid.isEmpty) {
        guestSub = _guestStore.watch().listen(
          controller.add,
          onError: controller.addError,
        );
        return;
      }

      querySub = _firestore
          .collection(_collection)
          .where('ownerId', isEqualTo: uid)
          .snapshots()
          .listen(
            (snapshot) {
              final plantings = snapshot.docs
                  .map(_fromDoc)
                  .whereType<CropPlanting>()
                  .toList()
                ..sort((a, b) => b.sowingDate.compareTo(a.sowingDate));
              controller.add(plantings);
            },
            onError: controller.addError,
          );
    }

    controller = StreamController<List<CropPlanting>>(
      onListen: () {
        authSub = _auth.authStateChanges().listen((_) {
          subscribeForCurrentOwner();
        });
      },
      onCancel: () async {
        await querySub?.cancel();
        await guestSub?.cancel();
        await authSub?.cancel();
      },
    );
    return controller.stream;
  }

  Future<CropPlanting> createPlanting({
    required CropType crop,
    required CropArea area,
    required DateTime sowingDate,
    String fieldLabel = '',
    bool remindersEnabled = true,
  }) async {
    final ownerId = currentOwnerId;
    if (ownerId == null) {
      return _guestStore.create(
        crop: crop,
        area: area,
        sowingDate: sowingDate,
        fieldLabel: fieldLabel,
        remindersEnabled: remindersEnabled,
      );
    }

    final doc = _firestore.collection(_collection).doc();
    final data = <String, dynamic>{
      'ownerId': ownerId,
      'crop': crop.name,
      'area': area.name,
      'fieldLabel': fieldLabel.trim(),
      'sowingDate': Timestamp.fromDate(
        DateTime(sowingDate.year, sowingDate.month, sowingDate.day),
      ),
      'completedStages': <String>[],
      'remindersEnabled': remindersEnabled,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await doc.set(data);
    return CropPlanting(
      id: doc.id,
      ownerId: ownerId,
      crop: crop,
      area: area,
      sowingDate: DateTime(sowingDate.year, sowingDate.month, sowingDate.day),
      completedStages: const [],
      remindersEnabled: remindersEnabled,
      fieldLabel: fieldLabel.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Future<void> updatePlanting(CropPlanting planting) async {
    final ownerId = currentOwnerId;
    if (ownerId == null) {
      if (planting.ownerId != GuestCropPlantingStore.ownerId) {
        throw StateError('Cannot update cloud planting while offline/guest.');
      }
      await _guestStore.update(planting);
      return;
    }

    if (planting.ownerId != ownerId) {
      throw StateError('Cannot update another user\'s planting.');
    }
    await _firestore.collection(_collection).doc(planting.id).update({
      'crop': planting.crop.name,
      'area': planting.area.name,
      'fieldLabel': planting.fieldLabel.trim(),
      'sowingDate': Timestamp.fromDate(
        DateTime(
          planting.sowingDate.year,
          planting.sowingDate.month,
          planting.sowingDate.day,
        ),
      ),
      'completedStages':
          planting.completedStages.map(CropPlanting.stageToKey).toList(),
      'remindersEnabled': planting.remindersEnabled,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setStageCompleted({
    required String plantingId,
    required CropStage stage,
    required bool completed,
  }) async {
    final ownerId = currentOwnerId;
    if (ownerId == null) {
      await _guestStore.setStageCompleted(
        plantingId: plantingId,
        stage: stage,
        completed: completed,
      );
      return;
    }

    final ref = _firestore.collection(_collection).doc(plantingId);
    final snap = await ref.get();
    if (!snap.exists) {
      throw StateError('Planting not found.');
    }
    final data = snap.data();
    if (data == null || data['ownerId'] != ownerId) {
      throw StateError('Cannot update another user\'s planting.');
    }

    final key = CropPlanting.stageToKey(stage);
    await ref.update({
      'completedStages': completed
          ? FieldValue.arrayUnion([key])
          : FieldValue.arrayRemove([key]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deletePlanting(String plantingId) async {
    final ownerId = currentOwnerId;
    if (ownerId == null) {
      await _guestStore.delete(plantingId);
      return;
    }

    final ref = _firestore.collection(_collection).doc(plantingId);
    final snap = await ref.get();
    if (!snap.exists) return;
    final data = snap.data();
    if (data == null || data['ownerId'] != ownerId) {
      throw StateError('Cannot delete another user\'s planting.');
    }
    await ref.delete();
  }

  CropPlanting? _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) return null;

    final crop = CropPlanting.cropFromKey(data['crop'] as String? ?? '');
    final area = CropPlanting.areaFromKey(data['area'] as String? ?? '');
    if (crop == null || area == null) return null;

    final sowingTs = data['sowingDate'] as Timestamp?;
    final sowingDate = sowingTs?.toDate() ?? DateTime.now();
    final completedRaw = data['completedStages'];
    final completed = <CropStage>[];
    if (completedRaw is List) {
      for (final item in completedRaw) {
        final stage = CropPlanting.stageFromKey(item.toString());
        if (stage != null) completed.add(stage);
      }
    }

    return CropPlanting(
      id: doc.id,
      ownerId: data['ownerId'] as String? ?? '',
      crop: crop,
      area: area,
      sowingDate: DateTime(sowingDate.year, sowingDate.month, sowingDate.day),
      completedStages: completed,
      remindersEnabled: data['remindersEnabled'] as bool? ?? true,
      fieldLabel: data['fieldLabel'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
