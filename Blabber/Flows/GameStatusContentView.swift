//
//  GameStatusContentView.swift
//  WordBomb
//
//  Created by Apps4World on 3/2/22.
//

import SwiftUI

/// Status for the game
struct GameStatusContentView: View {
    
    @EnvironmentObject var manager: GameManager
    @Environment(\.presentationMode) var presentationMode
    @State private var didAnimateIntro: Bool = false
    let correctAnswer: Bool
    let correctWord: String
    
    // MARK: - Main rendering function
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
                .opacity(didAnimateIntro ? 0.5 : 0)
                .animation(Animation.easeIn.delay(0.4))
            VStack {
                Text(correctAnswer ? "You did it!" : "Oh no!")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                Image(uiImage: UIImage(named: correctAnswer ? "correct" : "wrong")!)
                    .resizable().aspectRatio(contentMode: .fit).padding(.horizontal)
                Text(!correctAnswer ? "Try Again" : "Correct Word")
                Text(correctAnswer ? correctWord : " ").font(.system(size: 20, weight: .semibold))
            }.foregroundColor(Color("TextColor")).padding(.vertical, 30).background(
                Color("BackgroundColor").cornerRadius(20)
            )
            .padding(30)
            .offset(y: didAnimateIntro ? 0 : UIScreen.main.bounds.height)
            .animation(Animation.spring(response: 1, dampingFraction: 0.6).speed(2).delay(0.5))
        }.onTapGesture {
            didAnimateIntro = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                manager.loadNextLevelWord()
                presentationMode.wrappedValue.dismiss()
            }
        }.background(TransparentBackgroundView()).onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + (correctAnswer ? 0 : 1)) {
                if didAnimateIntro == false {
                    didAnimateIntro = true
                }
            }
        }
    }
}

// MARK: - Preview UI
struct GameStatusContentView_Previews: PreviewProvider {
    static var previews: some View {
        GameStatusContentView(correctAnswer: true, correctWord: "DEMO").environmentObject(GameManager())
    }
}
