//
//  SettingsContentView.swift
//  WordBomb
//
//  Created by Apps4World on 3/2/22.
//

import SwiftUI
import StoreKit
import MessageUI
import PurchaseKit

/// Main settings view
struct SettingsContentView: View {
    
    @EnvironmentObject private var manager: GameManager
    @State private var showLoadingView: Bool = false
    
    // MARK: - Main rendering function
    var body: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()
            
            VStack(spacing: 10) {
                HeaderTitle
                ScrollView(.vertical, showsIndicators: false, content: {
                    VStack {
                        CustomHeader(title: "IN-APP PURCHASES")
                        InAppPurchasesView
                        CustomHeader(title: "TUTORIAL")
                        TutorialItemView
                        CustomHeader(title: "SPREAD THE WORD")
                        RatingShareView
                        CustomHeader(title: "SUPPORT & PRIVACY")
                        PrivacySupportView
                        Banner(smallBannerSize: false)
                    }.padding([.leading, .trailing], 18)
                    Spacer(minLength: 20)
                }).padding(.top, 5)
            }
            
            /// Show loading view
            LoadingView(isLoading: $showLoadingView)
        }
    }
    
    /// Header title
    private var HeaderTitle: some View {
        HStack(alignment: .top) {
            Text("Settings").font(.largeTitle).bold()
            Spacer()
            Button {
                manager.fullScreenMode = nil
            } label: {
                Image(systemName: "xmark").font(.system(size: 18, weight: .medium))
            }
        }.padding(.horizontal).foregroundColor(Color("TextColor"))
    }
    
    /// Create custom header view
    private func CustomHeader(title: String, subtitle: String? = nil) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title).font(.system(size: 18, weight: .medium))
                if let subtitleText = subtitle {
                    Text(subtitleText)
                }
            }
            Spacer()
        }.foregroundColor(Color("TextColor"))
    }
    
    /// Custom settings item
    private func SettingsItem(title: String, icon: String, action: @escaping() -> Void) -> some View {
        Button(action: {
            UIImpactFeedbackGenerator().impactOccurred()
            action()
        }, label: {
            HStack {
                Image(systemName: icon).resizable().aspectRatio(contentMode: .fit)
                    .frame(width: 22, height: 22, alignment: .center)
                Text(title).font(.system(size: 18))
                Spacer()
                Image(systemName: "chevron.right")
            }.foregroundColor(Color("TextColor")).padding()
        })
    }
    
    // MARK: - In App Purchases
    private var InAppPurchasesView: some View {
        VStack {
            SettingsItem(title: "Upgrade Premium", icon: "crown") {
                manager.purchasePremiumVersion()
            }
            Color("TextColor").frame(height: 1).opacity(0.2)
            SettingsItem(title: "Restore Purchases", icon: "arrow.clockwise") {
                showLoadingView = true
                PKManager.restorePurchases { _, status, _ in
                    DispatchQueue.main.async {
                        showLoadingView = false
                        if status == .restored { manager.isPremiumUser = true }
                    }
                }
            }
        }.padding([.top, .bottom], 5).background(
            Color("Secondary").cornerRadius(15)
                .shadow(color: Color.black.opacity(0.07), radius: 10)
        ).padding(.bottom, 40)
    }
    
    // MARK: - Tutorial option
    private var TutorialItemView: some View {
        VStack {
            SettingsItem(title: "How to Play?", icon: "questionmark.circle") {
                manager.fullScreenMode = .tutorial
            }
        }.padding([.top, .bottom], 5).background(
            Color("Secondary").cornerRadius(15)
                .shadow(color: Color.black.opacity(0.07), radius: 10)
        ).padding(.bottom, 40)
    }
    
    // MARK: - Rating and Share
    private var RatingShareView: some View {
        VStack {
            SettingsItem(title: "Rate App", icon: "star") {
                if let scene = UIApplication.shared.windows.first?.windowScene {
                    SKStoreReviewController.requestReview(in: scene)
                }
            }
            Color("TextColor").frame(height: 1).opacity(0.2)
            SettingsItem(title: "Share App", icon: "square.and.arrow.up") {
                let shareController = UIActivityViewController(activityItems: [AppConfig.yourAppURL], applicationActivities: nil)
                rootController?.present(shareController, animated: true, completion: nil)
            }
        }.padding([.top, .bottom], 5).background(
            Color("Secondary").cornerRadius(15)
                .shadow(color: Color.black.opacity(0.07), radius: 10)
        ).padding(.bottom, 40)
    }
    
    // MARK: - Support & Privacy
    private var PrivacySupportView: some View {
        VStack {
            SettingsItem(title: "E-Mail us", icon: "envelope.badge") {
                EmailPresenter.shared.present()
            }
            Color("TextColor").frame(height: 1).opacity(0.2)
            SettingsItem(title: "Privacy Policy", icon: "hand.raised") {
                UIApplication.shared.open(AppConfig.privacyURL, options: [:], completionHandler: nil)
            }
        }.padding([.top, .bottom], 5).background(
            Color("Secondary").cornerRadius(15)
                .shadow(color: Color.black.opacity(0.07), radius: 10)
        )
    }
}

// MARK: - Preview UI
struct SettingsContentView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsContentView().environmentObject(GameManager())
    }
}

// MARK: - Mail presenter for SwiftUI
class EmailPresenter: NSObject, MFMailComposeViewControllerDelegate {
    public static let shared = EmailPresenter()
    private override init() { }
    
    func present() {
        if !MFMailComposeViewController.canSendMail() {
            let alert = UIAlertController(title: "Email Simulator", message: "Email is not supported on the simulator. This will work on a physical device only.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            rootController?.present(alert, animated: true, completion: nil)
            return
        }
        let picker = MFMailComposeViewController()
        picker.setToRecipients([AppConfig.emailSupport])
        picker.mailComposeDelegate = self
        rootController?.present(picker, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        rootController?.dismiss(animated: true, completion: nil)
    }
}

/// Show a loading indicator view
struct LoadingView: View {
    
    @Binding var isLoading: Bool
    
    // MARK: - Main rendering function
    var body: some View {
        ZStack {
            if isLoading {
                Color.black.edgesIgnoringSafeArea(.all).opacity(0.4)
                ProgressView("please wait...")
                    .scaleEffect(1.1, anchor: .center)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .foregroundColor(.white).padding()
                    .background(RoundedRectangle(cornerRadius: 10).opacity(0.7))
            }
        }.colorScheme(.light)
    }
}
