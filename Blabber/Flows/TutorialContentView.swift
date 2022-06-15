//
//  TutorialContentView.swift
//  WordBomb
//
//  Created by Apps4World on 3/2/22.
//

import SwiftUI

/// Tutorial steps
enum TutorialStep: String, Identifiable, CaseIterable {
    case words, letters
    var id: Int { hashValue }
    
    /// Title
    var title: String {
        switch self {
        case .words:
            return "All words have 6 letters"
        case .letters:
            return "Reveal the letters for each row"
        }
    }
    
    /// Subtitle
    var subtitle: String {
        switch self {
        case .words:
            return "Guess the word within \(AppConfig.defaultLivesCount) lives"
        case .letters:
            return "But avoid all the bombs"
        }
    }
}

/// A simple tutorial for the game
struct TutorialContentView: View {
    
    @EnvironmentObject private var manager: GameManager
    @Environment(\.colorScheme) var colorScheme
    @State private var step: TutorialStep = .words
    @State private var animatedTags: [Int] = [Int]()
    private let word: String = "BURGER"
    
    // MARK: - Main rendering function
    var body: some View {
        ZStack {
            Color("KeyboardBackgroundColor").ignoresSafeArea()
            VStack(spacing: 50) {
                Spacer()
                ForEach(0..<4, id: \.self) { index in
                    if index == 0 {
                        Text(step.title)
                            .opacity(animatedTags.contains(index) ? 1: 0)
                    } else if index == 1 {
                        WordSectionView.tag(index)
                            .opacity(animatedTags.contains(index) ? 1: 0)
                    } else if index == 2 {
                        Text(step.subtitle).tag(index)
                            .opacity(animatedTags.contains(index) ? 1: 0)
                    } else {
                        ContinueButton.tag(index)
                            .opacity(animatedTags.contains(index) ? 1: 0)
                    }
                }.multilineTextAlignment(.center).foregroundColor(Color.white)
                Spacer()
            }.font(.system(size: 22, weight: .medium, design: .rounded))
        }.onAppear {
            if animatedTags.count == 0 && step == .words {
                startAnimation()
            }
        }
    }
    
    /// Word section
    private var WordSectionView: some View {
        ZStack {
            if step == .words {
                AnswerLettersView().environmentObject(CustomManager)
            } else {
                LettersGridView().animation(nil)
                    .environmentObject(CustomManager)
            }
        }
    }
    
    /// Continue button
    private var ContinueButton: some View {
        Button {
            if step == .words {
                animatedTags.removeAll()
                step = .letters
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    startAnimation()
                }
            } else {
                manager.fullScreenMode = nil
            }
        } label: {
            ZStack {
                Color("PrimaryColor")
                Text("Continue").font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
        }.cornerRadius(10).padding(.horizontal, 50).frame(height: 45)
    }
    
    /// Updated animation for each element in order
    private func startAnimation() {
        if animatedTags.count != 4 {
            let lastIndex = animatedTags.last
            withAnimation(Animation.easeIn(duration: 1.3)) {
                animatedTags.append(lastIndex == nil ? 0 : lastIndex! + 1)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                startAnimation()
            }
        }
    }
    
    /// Custom data manager
    private var CustomManager: GameManager {
        let manager = GameManager()
        manager.word = word
        manager.selectedLetters = word.map({ String($0) })
        manager.revealedRows = [0, 1, 2, 3, 4, 5, 6]
        return manager
    }
}

// MARK: - Preview UI
struct TutorialContentView_Previews: PreviewProvider {
    static var previews: some View {
        TutorialContentView().environmentObject(GameManager())
    }
}
