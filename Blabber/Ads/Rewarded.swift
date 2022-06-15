//
//  Rewarded.swift
//  WordBomb
//
//  Created by Apps4World on 3/2/22.
//

import GoogleMobileAds

// MARK: - Google AdMob Rewarded Ads - Support class
class Rewarded: NSObject, GADFullScreenContentDelegate {
    var rewardedAd: GADRewardedAd?
    var rewardFunction: ((_ didFinishWatchingAd: Bool) -> Void)? = nil
    private var didEarnRewards: Bool = false

    static var shared: Rewarded = Rewarded()
    
    /// Request AdMob Rewarded ads
    func loadAd() {
        let request = GADRequest()
        GADRewardedAd.load(withAdUnitID: AppConfig.rewardedAdId, request: request) { ad, _ in
            self.rewardedAd = ad
            self.rewardedAd?.fullScreenContentDelegate = self
        }
    }
    
    func showAd(rewardFunction: @escaping (_ didFinishWatchingAd: Bool) -> Void) {
        self.rewardFunction = rewardFunction
        self.didEarnRewards = false
        if self.rewardedAd != nil {
            guard var root = UIApplication.shared.windows.first?.rootViewController else { return }
            if let presenter = root.presentedViewController { root = presenter }
            self.rewardedAd?.present(fromRootViewController: root, userDidEarnRewardHandler: {
                root.presentedViewController?.dismiss(animated: true, completion: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.rewardFunction?(true)
                        self.loadAd()
                    }
                })
            })
        }
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        self.loadAd()
    }
    
    var isRewardedAdReady: Bool {
        rewardedAd != nil
    }
}
