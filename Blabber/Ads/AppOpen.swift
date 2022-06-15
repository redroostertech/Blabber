//
//  AppOpen.swift
//  WordBomb
//
//  Created by Apps4World on 3/2/22.
//

import GoogleMobileAds

// MARK: - Google AdMob App Open Ads - Support class
class AppOpen: NSObject, GADFullScreenContentDelegate {
    private var appOpenAd: GADAppOpenAd?
    static let shared: AppOpen = AppOpen()
    
    /// Request AdMob App Open ads
    func loadAd(showWhenReady: Bool = false) {
        let request = GADRequest()
        GADAppOpenAd.load(withAdUnitID: AppConfig.appOpenAdId, request: request, orientation: .portrait) { ad, _ in
            self.appOpenAd = ad
            self.appOpenAd?.fullScreenContentDelegate = self
            if showWhenReady { self.showAppOpenAds() }
        }
    }
    
    func showAppOpenAds() {
        if self.appOpenAd != nil, !AppConfig.isPremiumUser {
            var root = UIApplication.shared.windows.first?.rootViewController
            if let presenter = root?.presentedViewController { root = presenter }
            self.appOpenAd?.present(fromRootViewController: root!)
        }
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        loadAd()
    }
}
