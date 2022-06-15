//
//  Interstitial.swift
//  WordBomb
//
//  Created by Apps4World on 3/2/22.
//

import GoogleMobileAds

// MARK: - Google AdMob Interstitial Ads - Support class
class Interstitial: NSObject, GADFullScreenContentDelegate {
    private var interstitial: GADInterstitialAd?
    static var shared: Interstitial = Interstitial()
    
    /// Request AdMob Interstitial ads
    func loadAd() {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: AppConfig.interstitialAdId, request: request, completionHandler: { [self] ad, error in
            if ad != nil { interstitial = ad }
            interstitial?.fullScreenContentDelegate = self
        })
    }
    
    func showInterstitialAds() {
        if self.interstitial != nil, !AppConfig.isPremiumUser {
            var root = UIApplication.shared.windows.first?.rootViewController
            if let presenter = root?.presentedViewController { root = presenter }
            self.interstitial?.present(fromRootViewController: root!)
        }
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        loadAd()
    }
}
