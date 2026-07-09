import 'unity_ads_service.dart';
import 'unity_interstitial_ad.dart';
import 'unity_rewarded_ad.dart';

/// Shared Unity Ads instances used across the app.
final unityAds = UnityAdsService();

final UnityInterstitialAd splashInterstitial = UnityInterstitialAd(
  placementId: unityAds.interstitialAdId,
);

final UnityInterstitialAd actionInterstitial = UnityInterstitialAd(
  placementId: unityAds.interstitialAdId,
);

final UnityRewardedAd actionRewarded = UnityRewardedAd(
  placementId: unityAds.rewardedAdId,
);
