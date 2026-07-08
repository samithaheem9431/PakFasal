/// Result of a time-series moisture forecast.
class MoistureForecast {
  const MoistureForecast({
    required this.predictedNext,
    required this.slopePerReading,
    required this.trend,
    required this.rSquared,
    required this.basedOnPoints,
  });

  /// Predicted soil moisture for the next reading (clamped to 0-100%).
  final double predictedNext;

  /// Change in moisture per reading (slope of the fitted line).
  final double slopePerReading;

  /// One of: `rising`, `falling`, `stable`.
  final String trend;

  /// Goodness of fit (0-1). Higher means the linear trend explains the data
  /// well and the forecast is more trustworthy.
  final double rSquared;

  /// How many historical readings the forecast was computed from.
  final int basedOnPoints;
}

/// A lightweight time-series predictor that fits a simple linear regression
/// (ordinary least squares) over the recent moisture readings and extrapolates
/// the next value.
///
/// This complements the Random Forest DSS classifier with a *predictive*
/// (forecasting) ML technique: instead of only reacting to the current
/// reading, it estimates where soil moisture is heading next.
class MoistureForecaster {
  /// Slope magnitude (% per reading) below which the trend is "stable".
  static const double _stableThreshold = 0.75;

  /// Fits `y = a + b*x` where x is the reading index (0..n-1) and y is the
  /// moisture value, then predicts y at x = n.
  ///
  /// Returns `null` when there are fewer than 3 readings (not enough signal).
  static MoistureForecast? forecast(List<double> series) {
    final n = series.length;
    if (n < 3) return null;

    final xs = List<double>.generate(n, (i) => i.toDouble());
    final meanX = xs.reduce((a, b) => a + b) / n;
    final meanY = series.reduce((a, b) => a + b) / n;

    var sxy = 0.0;
    var sxx = 0.0;
    var syy = 0.0;
    for (var i = 0; i < n; i++) {
      final dx = xs[i] - meanX;
      final dy = series[i] - meanY;
      sxy += dx * dy;
      sxx += dx * dx;
      syy += dy * dy;
    }

    // Flat data (all x equal is impossible here; guard for all-y-equal).
    final slope = sxx == 0 ? 0.0 : sxy / sxx;
    final intercept = meanY - slope * meanX;

    final rawPrediction = intercept + slope * n;
    final predictedNext = rawPrediction.clamp(0.0, 100.0).toDouble();

    // R^2 = 1 - SS_res / SS_tot.
    var ssRes = 0.0;
    for (var i = 0; i < n; i++) {
      final fitted = intercept + slope * xs[i];
      final err = series[i] - fitted;
      ssRes += err * err;
    }
    final rSquared = syy == 0 ? 1.0 : (1 - ssRes / syy).clamp(0.0, 1.0).toDouble();

    final String trend;
    if (slope > _stableThreshold) {
      trend = 'rising';
    } else if (slope < -_stableThreshold) {
      trend = 'falling';
    } else {
      trend = 'stable';
    }

    return MoistureForecast(
      predictedNext: double.parse(predictedNext.toStringAsFixed(1)),
      slopePerReading: double.parse(slope.toStringAsFixed(2)),
      trend: trend,
      rSquared: double.parse(rSquared.toStringAsFixed(2)),
      basedOnPoints: n,
    );
  }

  /// Convenience helper used by the UI to describe the confidence bucket.
  static String confidenceBucket(double rSquared) {
    if (rSquared >= 0.75) return 'high';
    if (rSquared >= 0.4) return 'medium';
    return 'low';
  }
}
