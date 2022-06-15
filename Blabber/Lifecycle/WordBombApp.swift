//
//  WordBombApp.swift
//  WordBomb
//
//  Created by Apps4World on 3/2/22.
//

import SwiftUI

@main
struct WordBombApp: App {
    
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var manager: GameManager = GameManager()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    // MARK: - Main rendering function
    var body: some Scene {
        WindowGroup {
            DashboardContentView().environmentObject(manager).onChange(of: scenePhase) { newValue in
                if newValue == .active {
                    AppOpen.shared.showAppOpenAds()
                }
            }
        }
    }
}

// MARK: - Present an alert from anywhere in the app
func presentAlert(title: String, message: String, primaryAction: UIAlertAction = .ok, secondaryAction: UIAlertAction? = nil) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(primaryAction)
    if let secondary = secondaryAction { alert.addAction(secondary) }
    rootController?.present(alert, animated: true, completion: nil)
}

extension UIAlertAction {
    static var ok: UIAlertAction {
        UIAlertAction(title: "OK", style: .cancel, handler: nil)
    }
}

var rootController: UIViewController? {
    var root = UIApplication.shared.windows.first?.rootViewController
    if let presenter = root?.presentedViewController { root = presenter }
    return root
}

/// Create a shape with specific rounded corners
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension String {
    subscript(idx: Int) -> String {
        String(self[index(startIndex, offsetBy: idx)])
    }
}

struct TransparentBackgroundView: UIViewRepresentable {
    func updateUIView(_ uiView: UIView, context: Context) {}
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }
}

extension UIDevice {
    var hasNotch: Bool {
        let bottom = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 00
        return bottom > 0
    }
}
