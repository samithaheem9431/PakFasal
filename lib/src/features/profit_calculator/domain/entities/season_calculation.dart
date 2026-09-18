class SeasonCalculation {
  const SeasonCalculation({
    required this.id,
    required this.cropName,
    required this.areaAcres,
    required this.seedCost,
    required this.fertilizerCost,
    required this.pesticideCost,
    required this.labourCost,
    required this.irrigationCost,
    required this.transportCost,
    required this.otherCost,
    required this.incomeTotal,
    required this.createdAt,
    this.yieldAmount = 0,
    this.marketRate = 0,
  });

  final String id;
  final String cropName;
  final double areaAcres;
  final double seedCost;
  final double fertilizerCost;
  final double pesticideCost;
  final double labourCost;
  final double irrigationCost;
  final double transportCost;
  final double otherCost;
  final double incomeTotal;
  final double yieldAmount;
  final double marketRate;
  final DateTime createdAt;

  double get totalExpense =>
      seedCost +
      fertilizerCost +
      pesticideCost +
      labourCost +
      irrigationCost +
      transportCost +
      otherCost;

  double get profit => incomeTotal - totalExpense;

  double? get profitPerAcre =>
      areaAcres > 0 ? profit / areaAcres : null;

  double? get marginPercent =>
      incomeTotal > 0 ? (profit / incomeTotal) * 100 : null;

  SeasonCalculation copyWith({
    String? id,
    String? cropName,
    double? areaAcres,
    double? seedCost,
    double? fertilizerCost,
    double? pesticideCost,
    double? labourCost,
    double? irrigationCost,
    double? transportCost,
    double? otherCost,
    double? incomeTotal,
    double? yieldAmount,
    double? marketRate,
    DateTime? createdAt,
  }) {
    return SeasonCalculation(
      id: id ?? this.id,
      cropName: cropName ?? this.cropName,
      areaAcres: areaAcres ?? this.areaAcres,
      seedCost: seedCost ?? this.seedCost,
      fertilizerCost: fertilizerCost ?? this.fertilizerCost,
      pesticideCost: pesticideCost ?? this.pesticideCost,
      labourCost: labourCost ?? this.labourCost,
      irrigationCost: irrigationCost ?? this.irrigationCost,
      transportCost: transportCost ?? this.transportCost,
      otherCost: otherCost ?? this.otherCost,
      incomeTotal: incomeTotal ?? this.incomeTotal,
      yieldAmount: yieldAmount ?? this.yieldAmount,
      marketRate: marketRate ?? this.marketRate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cropName': cropName,
      'areaAcres': areaAcres,
      'seedCost': seedCost,
      'fertilizerCost': fertilizerCost,
      'pesticideCost': pesticideCost,
      'labourCost': labourCost,
      'irrigationCost': irrigationCost,
      'transportCost': transportCost,
      'otherCost': otherCost,
      'incomeTotal': incomeTotal,
      'yieldAmount': yieldAmount,
      'marketRate': marketRate,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static SeasonCalculation? fromMap(Map<String, dynamic> data) {
    final id = data['id'] as String? ?? '';
    if (id.isEmpty) return null;

    return SeasonCalculation(
      id: id,
      cropName: data['cropName'] as String? ?? '',
      areaAcres: _asDouble(data['areaAcres']),
      seedCost: _asDouble(data['seedCost']),
      fertilizerCost: _asDouble(data['fertilizerCost']),
      pesticideCost: _asDouble(data['pesticideCost']),
      labourCost: _asDouble(data['labourCost']),
      irrigationCost: _asDouble(data['irrigationCost']),
      transportCost: _asDouble(data['transportCost']),
      otherCost: _asDouble(data['otherCost']),
      incomeTotal: _asDouble(data['incomeTotal']),
      yieldAmount: _asDouble(data['yieldAmount']),
      marketRate: _asDouble(data['marketRate']),
      createdAt:
          DateTime.tryParse(data['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  static double _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}
