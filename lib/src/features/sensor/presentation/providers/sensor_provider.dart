import 'package:flutter/material.dart';

import '../../data/repositories/sensor_repository.dart';
import '../../domain/entities/sensor_reading.dart';

class SensorProvider extends ChangeNotifier {
  SensorProvider({SensorRepository? repository})
    : _repository = repository ?? SensorRepository();

  final SensorRepository _repository;

  Stream<List<SensorReading>> get readingsStream =>
      _repository.watchRecentReadings();
}
