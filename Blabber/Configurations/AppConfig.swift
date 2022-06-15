//
//  AppConfig.swift
//  WordBomb
//
//  Created by Apps4World on 3/2/22.
//

import SwiftUI
import Foundation

/// Generic configurations for the app
class AppConfig {
    
    /// This is the AdMob Interstitial ad id
    static let interstitialAdId: String = "ca-app-pub-3940256099942544/4411468910"
    static let rewardedAdId: String = "ca-app-pub-3940256099942544/1712485313"
    static let appOpenAdId: String = "ca-app-pub-3940256099942544/5662855259"
    static let bannerAdId: String = "ca-app-pub-3940256099942544/2934735716"
    static let adMobFrequency: Int = 2 /// after 2 revealed rows
    
    // MARK: - Settings flow items
    static let emailSupport = "support@apps4world.com"
    static let privacyURL: URL = URL(string: "https://www.google.com/")!
    static let yourAppURL: URL = URL(string: "https://apps.apple.com/app/idXXXXXX")!
    static let defaultLivesCount: Int = 4
    
    // MARK: - In App Purchases
    static let premiumVersion: String = "WordBomb.Premium"
    static let freeCategories: [GameCategory] = [.food, .household]
    static var isPremiumUser: Bool = UserDefaults.standard.bool(forKey: AppConfig.premiumVersion)
}

// MARK: - Game Categories list
enum GameCategory: String, CaseIterable, Identifiable {
    case food, sports, household, animals, places
    var icon: String {
        switch self {
        case .food:
            return "🍕"
        case .sports:
            return "⚽️"
        case .household:
            return "🏠"
        case .animals:
            return "🐶"
        case .places:
            return "✈️"
        }
    }
    var id: Int { hashValue }
}


