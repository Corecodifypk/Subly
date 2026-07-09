import 'package:flutter/material.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

import '../services/unity_ads_service.dart';

class UnityBannerWidget extends StatefulWidget {
  const UnityBannerWidget({
    super.key,
    required this.placementId,
    this.width,
    this.height,
    this.onBannerLoaded,
    this.onBannerClicked,
    this.onBannerFailed,
  });

  final String placementId;
  final double? width;
  final double? height;
  final VoidCallback? onBannerLoaded;
  final VoidCallback? onBannerClicked;
  final Function(String)? onBannerFailed;

  @override
  State<UnityBannerWidget> createState() => _UnityBannerWidgetState();
}

class _UnityBannerWidgetState extends State<UnityBannerWidget> {
  bool _ready = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    // Delay so banner does not load while interstitial is closing.
    Future.delayed(const Duration(milliseconds: 1500), _waitForAds);
  }

  Future<void> _waitForAds() async {
    if (!mounted) return;

    if (UnityAdsService().isInitialized) {
      setState(() => _ready = true);
      return;
    }

    for (var i = 0; i < 20; i++) {
      await Future.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;
      if (UnityAdsService().isInitialized) {
        setState(() => _ready = true);
        return;
      }
    }

    if (mounted) {
      setState(() {
        _ready = true;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.width ?? MediaQuery.of(context).size.width;
    const height = 50.0;

    if (_hasError || !_ready) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: width,
      height: height,
      child: UnityBannerAd(
        placementId: widget.placementId,
        onLoad: (placementId) => widget.onBannerLoaded?.call(),
        onClick: (placementId) => widget.onBannerClicked?.call(),
        onShown: (_) {},
        onFailed: (placementId, error, message) {
          if (mounted) setState(() => _hasError = true);
          widget.onBannerFailed?.call(message);
        },
      ),
    );
  }
}
