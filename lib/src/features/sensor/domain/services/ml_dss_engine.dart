import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// On-device Machine Learning engine for the sensor DSS.
///
/// The heavy lifting (training) happens offline in `ml/train_dss_model.py`,
/// which trains three Random Forest classifiers (irrigation action, soil
/// action, priority) and exports them to `assets/ml/dss_model.json`.
///
/// This class loads that JSON once and runs the forests natively in Dart, so
/// no native ML plugin is required and inference works on every platform.
/// Each forest averages the class probabilities of its decision trees and
/// returns the highest-probability class (standard Random Forest inference).
class MlDssEngine {
  MlDssEngine._({
    required List<String> featureNames,
    required _Forest irrigation,
    required _Forest soil,
    required _Forest priority,
    required this.metrics,
  })  : _featureNames = featureNames,
        _irrigation = irrigation,
        _soil = soil,
        _priority = priority;

  static const String _assetPath = 'assets/ml/dss_model.json';

  final List<String> _featureNames;
  final _Forest _irrigation;
  final _Forest _soil;
  final _Forest _priority;

  /// Reported test accuracy per model, e.g. `{irrigation: 0.97, ...}`.
  final Map<String, double> metrics;

  /// Loads and parses the exported model from bundled assets.
  ///
  /// Throws if the asset is missing or malformed; callers should catch this
  /// and fall back to the rule-based engine.
  static Future<MlDssEngine> load() async {
    final raw = await rootBundle.loadString(_assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;

    final featureNames = (json['featureNames'] as List<dynamic>)
        .map((e) => e.toString())
        .toList();
    final models = json['models'] as Map<String, dynamic>;

    final metricsJson =
        (json['metrics'] as Map<String, dynamic>?)?['testAccuracy']
            as Map<String, dynamic>?;
    final metrics = <String, double>{};
    metricsJson?.forEach((key, value) {
      metrics[key] = (value as num).toDouble();
    });

    return MlDssEngine._(
      featureNames: featureNames,
      irrigation: _Forest.fromJson(models['irrigation'] as Map<String, dynamic>),
      soil: _Forest.fromJson(models['soil'] as Map<String, dynamic>),
      priority: _Forest.fromJson(models['priority'] as Map<String, dynamic>),
      metrics: metrics,
    );
  }

  /// Runs all three classifiers for a single reading.
  MlDssPrediction predict({
    required double moisture,
    required double ph,
    required int rainChancePercent,
    required String crop,
  }) {
    final features = _buildFeatureVector(
      moisture: moisture,
      ph: ph,
      rainChance: rainChancePercent.toDouble(),
      crop: crop,
    );

    final irrigation = _irrigation.classify(features);
    final soil = _soil.classify(features);
    final priority = _priority.classify(features);

    return MlDssPrediction(
      irrigationAction: irrigation.label,
      irrigationConfidence: irrigation.confidence,
      soilAction: soil.label,
      soilConfidence: soil.confidence,
      priority: priority.label,
      priorityConfidence: priority.confidence,
    );
  }

  /// Builds the feature vector in the exact order the model was trained with.
  List<double> _buildFeatureVector({
    required double moisture,
    required double ph,
    required double rainChance,
    required String crop,
  }) {
    return _featureNames.map((name) {
      switch (name) {
        case 'moisture':
          return moisture;
        case 'ph':
          return ph;
        case 'rainChance':
          return rainChance;
        case 'crop_Wheat':
          return crop == 'Wheat' ? 1.0 : 0.0;
        case 'crop_Rice':
          return crop == 'Rice' ? 1.0 : 0.0;
        case 'crop_Cotton':
          return crop == 'Cotton' ? 1.0 : 0.0;
        default:
          return 0.0;
      }
    }).toList();
  }
}

/// Result of a single ML DSS inference.
class MlDssPrediction {
  const MlDssPrediction({
    required this.irrigationAction,
    required this.irrigationConfidence,
    required this.soilAction,
    required this.soilConfidence,
    required this.priority,
    required this.priorityConfidence,
  });

  /// One of: irrigate_now, hold_for_rain, reduce_irrigation, maintain.
  final String irrigationAction;
  final double irrigationConfidence;

  /// One of: apply_lime, apply_gypsum, balanced.
  final String soilAction;
  final double soilConfidence;

  /// One of: HIGH, MEDIUM, LOW.
  final String priority;
  final double priorityConfidence;
}

/// A Random Forest: a collection of decision trees that vote by averaging
/// their class-probability outputs.
class _Forest {
  const _Forest({required this.classes, required this.trees});

  final List<String> classes;
  final List<_TreeNode> trees;

  factory _Forest.fromJson(Map<String, dynamic> json) {
    final classes =
        (json['classes'] as List<dynamic>).map((e) => e.toString()).toList();
    final trees = (json['trees'] as List<dynamic>)
        .map((t) => _TreeNode.fromJson(t as Map<String, dynamic>))
        .toList();
    return _Forest(classes: classes, trees: trees);
  }

  _Classification classify(List<double> features) {
    final summed = List<double>.filled(classes.length, 0);
    for (final tree in trees) {
      final probs = tree.predict(features);
      for (var i = 0; i < summed.length; i++) {
        summed[i] += probs[i];
      }
    }

    var bestIndex = 0;
    var bestValue = summed.isEmpty ? 0.0 : summed[0];
    for (var i = 1; i < summed.length; i++) {
      if (summed[i] > bestValue) {
        bestValue = summed[i];
        bestIndex = i;
      }
    }

    final total = summed.fold<double>(0, (a, b) => a + b);
    final confidence = total == 0 ? 0.0 : bestValue / total;
    return _Classification(
      label: classes[bestIndex],
      confidence: confidence,
    );
  }
}

class _Classification {
  const _Classification({required this.label, required this.confidence});

  final String label;
  final double confidence;
}

/// A single node of a decision tree. Either a leaf (holds class probabilities)
/// or a split (feature index + threshold + left/right children).
class _TreeNode {
  _TreeNode._({
    this.probabilities,
    this.featureIndex,
    this.threshold,
    this.left,
    this.right,
  });

  final List<double>? probabilities;
  final int? featureIndex;
  final double? threshold;
  final _TreeNode? left;
  final _TreeNode? right;

  bool get isLeaf => probabilities != null;

  factory _TreeNode.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('p')) {
      return _TreeNode._(
        probabilities: (json['p'] as List<dynamic>)
            .map((e) => (e as num).toDouble())
            .toList(),
      );
    }
    return _TreeNode._(
      featureIndex: (json['f'] as num).toInt(),
      threshold: (json['t'] as num).toDouble(),
      left: _TreeNode.fromJson(json['l'] as Map<String, dynamic>),
      right: _TreeNode.fromJson(json['r'] as Map<String, dynamic>),
    );
  }

  /// Walks the tree until a leaf is reached (sklearn convention:
  /// `feature <= threshold` goes left).
  List<double> predict(List<double> features) {
    _TreeNode node = this;
    while (!node.isLeaf) {
      if (features[node.featureIndex!] <= node.threshold!) {
        node = node.left!;
      } else {
        node = node.right!;
      }
    }
    return node.probabilities!;
  }
}
