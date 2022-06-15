//
//  AppDelegate.swift
//  WordBomb
//
//  Created by Apps4World on 3/2/22.
//

import UIKit
import Foundation
import PurchaseKit
import GoogleMobileAds
import AppTrackingTransparency

/// App delegate for SwiftUI application
class AppDelegate: NSObject, UIApplicationDelegate {
    
    /// Initial configuration when app finishes launching
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        PKManager.loadProducts(identifiers: [AppConfig.premiumVersion])
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { _ in self.requestIDFA() }
        return true
    }
    
    /// Display the App Tracking Transparency authorization request for accessing the IDFA
    func requestIDFA() {
        ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
            AppOpen.shared.loadAd(showWhenReady: true)
            Interstitial.shared.loadAd()
            Rewarded.shared.loadAd()
        })
    }
}
