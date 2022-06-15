//
//  Banner.swift
//  WordBomb
//
//  Created by Apps4World on 3/2/22.
//

import SwiftUI
import GoogleMobileAds

// MARK: - Google AdMob Banner Ads - Support class
struct Banner: View {

    @State var smallBannerSize: Bool = true
    @State private var didLoadBanner: Bool = false
    
    // MARK: - Main rendering function
    var body: some View {
        let bannerType = smallBannerSize ? GADAdSizeBanner : GADAdSizeMediumRectangle
        return VStack {
            if !AppConfig.isPremiumUser {
                if smallBannerSize { Spacer() }
                HStack {
                    Spacer()
                    GADBannerViewController(bannerType: bannerType, didLoadAd: $didLoadBanner)
                        .frame(width: min(bannerType.size.width, UIScreen.main.bounds.width),
                               height: didLoadBanner ? bannerType.size.height : 0, alignment: .center)
                    Spacer()
                }
            }
        }
    }
}

struct GADBannerViewController: UIViewControllerRepresentable {
    var bannerType: GADAdSize
    @Binding var didLoadAd: Bool
    
    func makeUIViewController(context: Context) -> UIViewController {
        let view = GADBannerView(adSize: bannerType)
        let viewController = BannerViewController()
        viewController.didLoadBanner = { didLoadAd = true }
        view.adUnitID = AppConfig.bannerAdId
        view.delegate = viewController
        view.rootViewController = viewController
        viewController.view.addSubview(view)
        viewController.view.frame = CGRect(origin: .zero, size: bannerType.size)
        view.load(GADRequest())
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

class BannerViewController: UIViewController, GADBannerViewDelegate {
    var didLoadBanner: (() -> Void)? = nil
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        didLoadBanner?()
    }
}
