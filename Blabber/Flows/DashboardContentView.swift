//
//  DashboardContentView.swift
//  WordBomb
//
//  Created by Apps4World on 3/2/22.
//

import SwiftUI

/// Main dashboard for the app
struct DashboardContentView: View {
    
    @EnvironmentObject var manager: GameManager
    
    // MARK: - Main rendering function
    var body: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()
            VStack(spacing: 0) {
                HeaderNavigationView
                GameCategoriesView
                AnswerStatsSectionView
                LettersSectionView
            }.disabled(manager.fullScreenMode != nil)
        }
        
        /// Show tutorial for the first time when app launches
        .onAppear(perform: {
            if manager.didShowTutorial == false {
                manager.didShowTutorial = true
                manager.fullScreenMode = .tutorial
            }
        })
        
        /// Full modal screen flow
        .fullScreenCover(item: $manager.fullScreenMode) { type in
            switch type {
            case .settings:
                SettingsContentView().environmentObject(manager)
            case .correct, .wrong:
                GameStatusContentView(correctAnswer: type == .correct, correctWord: manager.word).environmentObject(manager)
            case .stats:
                StatsContentView().environmentObject(manager)
            case .tutorial:
                TutorialContentView().environmentObject(manager)
            }
        }
    }
    
    /// Game Header navigation view
    private var HeaderNavigationView: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()
            VStack {
                Spacer()
                HStack(alignment: .center) {
                    Button {
                        manager.fullScreenMode = .stats
                    } label: {
                        Image(systemName: "chart.bar.xaxis").font(.system(size: 20, weight: .medium))
                    }
                    Spacer()
                    Text("Word") + Text("Bomb").bold()
                    Spacer()
                    Button {
                        manager.fullScreenMode = .settings
                    } label: {
                        Image(systemName: "gearshape.fill").font(.system(size: 20, weight: .medium))
                    }
                }.font(.system(size: 28, design: .rounded)).padding(.horizontal)
            }.padding(.bottom, 10)
        }.frame(height: 40).foregroundColor(Color("TextColor"))
    }
    
    /// Game Category carousel view
    private var GameCategoriesView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                Spacer(minLength: 1)
                ForEach(GameCategory.allCases) { gameCategory in
                    Button {
                        if !manager.isPremiumUser && !AppConfig.freeCategories.contains(gameCategory) {
                            presentAlert(title: "In-App Purchase", message: "To unlock all game categories, you must purchase the full version.", primaryAction: UIAlertAction(title: "Purchase", style: .default, handler: { _ in
                                manager.purchasePremiumVersion()
                            }), secondaryAction: UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                        } else {
                            manager.updateGameCategory(gameCategory)
                        }
                    } label: {
                        CategoryView(gameCategory)
                    }.opacity(!manager.isPremiumUser && !AppConfig.freeCategories.contains(gameCategory) ? 0.3 : 1)
                }
                Spacer(minLength: 1)
            }
            Color("LetterBoxColor").frame(height: 1).padding()
        }.padding(.top, 20).background(Color("BackgroundColor"))
    }
    
    /// Category item in the carousel
    private func CategoryView(_ gameCategory: GameCategory) -> some View {
        VStack(spacing: 5) {
            Text(gameCategory.icon)
            Text(gameCategory.rawValue.capitalized).opacity(
                manager.gameCategory == gameCategory ? 1 : 0.5
            )
        }
        .font(.system(size: 20, design: .rounded))
        .padding(.horizontal, 15).padding(.vertical, 7)
        .foregroundColor(gameCategory == manager.gameCategory ? Color.white : Color("TextColor"))
        .background(
            Color(gameCategory == manager.gameCategory ? "PrimaryColor" : "LetterBoxColor" )
                .opacity(gameCategory == manager.gameCategory ? 1 : 0.5).cornerRadius(15)
        )
    }
    
    /// Bottom section view
    private var LettersSectionView: some View {
        VStack(spacing: hasNotch ? 20 : 10) {
            if hasNotch {
                Capsule().frame(width: 45, height: 5).padding(10).opacity(0.5)
                    .foregroundColor(Color("KeyboardKeyColor"))
                    .padding(.top, 10)
            }
            LettersGridView().environmentObject(manager)
                .padding(.top, hasNotch ? 0 : 20)
        }
        .padding(.horizontal, 20).padding(.bottom, hasNotch ? 30 : 20).background(
            RoundedCorner(radius: 30, corners: [.topLeft, .topRight])
                .foregroundColor(Color("KeyboardBackgroundColor"))
                .ignoresSafeArea()
        )
    }
    
    /// Answer & Lives section
    private var AnswerStatsSectionView: some View {
        VStack(spacing: 0) {
            Spacer()
            AnswerLettersView().environmentObject(manager)
            HStack {
                ForEach(0..<AppConfig.defaultLivesCount, id: \.self) { index in
                    Image(systemName: "heart\(index < manager.livesCount ? ".fill" : "")")
                }
            }
            .foregroundColor(.red)
            .font(.system(size: hasNotch ? 30 : 20))
            .padding(hasNotch ? 25 : 10)
            Spacer()
        }
    }
    
    /// Check if the device is large enought to accomodate the UI
    private var hasNotch: Bool {
        UIDevice.current.hasNotch
    }
}

// MARK: - Preview UI
struct DashboardContentView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardContentView().environmentObject(GameManager())
    }
}

