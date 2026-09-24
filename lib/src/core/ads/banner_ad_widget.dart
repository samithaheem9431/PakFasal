import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_unit_ids.dart';

/// Adaptive AdMob banner. Collapses to zero height until loaded (or on web).
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({
    super.key,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
  });

  final EdgeInsetsGeometry padding;

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _banner;
  bool _loaded = false;
  bool _loadRequested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _requestLoad();
  }

  Future<void> _requestLoad() async {
    if (kIsWeb || _loadRequested) return;
    _loadRequested = true;

    final width = MediaQuery.sizeOf(context).width.truncate();
    final adSize =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
    if (!mounted || adSize == null) return;

    final ad = BannerAd(
      adUnitId: AdUnitIds.banner,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (loaded) {
          if (!mounted) {
            loaded.dispose();
            return;
          }
          setState(() {
            _banner = loaded as BannerAd;
            _loaded = true;
          });
        },
        onAdFailedToLoad: (failed, error) {
          debugPrint('Banner ad failed to load: $error');
          failed.dispose();
          if (mounted) {
            setState(() {
              _banner = null;
              _loaded = false;
            });
          }
        },
      ),
    );
    await ad.load();
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banner = _banner;
    if (!_loaded || banner == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: widget.padding,
      child: Center(
        child: SizedBox(
          width: banner.size.width.toDouble(),
          height: banner.size.height.toDouble(),
          child: AdWidget(ad: banner),
        ),
      ),
    );
  }
}
