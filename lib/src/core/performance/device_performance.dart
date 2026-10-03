import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

/// Heuristics for low-RAM / low-GPU devices common in the PakFasal audience.
///
/// Call [init] once from `main()` after `WidgetsFlutterBinding.ensureInitialized()`.
class DevicePerformance {
  DevicePerformance._();

  static bool _initialized = false;
  static bool _isLowEnd = false;

  static bool get isLowEnd {
    assert(_initialized, 'Call DevicePerformance.init() from main() first.');
    return _isLowEnd;
  }

  /// Prefer lighter decode budgets and fewer looping animations.
  static void init() {
    if (_initialized) return;
    _initialized = true;

    final views = WidgetsBinding.instance.platformDispatcher.views;
    if (views.isEmpty) {
      _isLowEnd = false;
      _applyImageCacheLimits();
      return;
    }

    final view = views.first;
    final dpr = view.devicePixelRatio;
    final logical = view.physicalSize / dpr;
    final shortest = math.min(logical.width, logical.height);
    final pixels = view.physicalSize.width * view.physicalSize.height;

    // Mid/low Android phones: ≤2x DPR, narrow screens, or under ~2MP physical.
    _isLowEnd = dpr <= 2.0 || shortest < 360 || pixels < 2.2e6;
    _applyImageCacheLimits();
  }

  static void _applyImageCacheLimits() {
    final cache = PaintingBinding.instance.imageCache;
    if (_isLowEnd) {
      cache.maximumSize = 80;
      cache.maximumSizeBytes = 48 << 20; // 48 MB
    } else {
      cache.maximumSize = 120;
      cache.maximumSizeBytes = 96 << 20; // 96 MB
    }
  }

  /// Decode width for asset/network images (physical pixels).
  static int decodeWidth(double logicalWidth, {double? devicePixelRatio}) {
    final dpr = devicePixelRatio ??
        ui.PlatformDispatcher.instance.views.first.devicePixelRatio;
    final maxPx = _isLowEnd ? 720 : 1200;
    return (logicalWidth * dpr).round().clamp(64, maxPx);
  }

  /// Skip heavy looping Lottie / particle / shimmer effects when true.
  static bool get reduceMotion => _isLowEnd;
}
