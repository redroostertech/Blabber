//
//  AnswerLettersView.swift
//  WordBomb
//
//  Created by Apps4World on 3/2/22.
//

import SwiftUI

/// Shows a stack of letters for the word that the user selected
struct AnswerLettersView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var manager: GameManager
    private let width: Double = UIScreen.main.bounds.width/Double(6)
    
    // MARK: - Main rendering function
    var body: some View {
        let size = width - 15
        return HStack(spacing: 10) {
            ForEach(0..<6, id: \.self) { index in
                LetterBoxView(atIndex: index).frame(width: size, height: size)
                    .cornerRadius(15)
            }
        }
    }
    
    /// Create the word letter box
    private func LetterBoxView(atIndex index: Int) -> some View {
        let letter = manager.selectedLetters[index]
        return ZStack {
            if colorScheme == .dark {
                Color.white
            } else {
                Color("LetterBoxColor")
            }
            Text(letter != "" ? letter.components(separatedBy: "_")[0] : "")
                .font(.system(size: 25, weight: .semibold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? Color.black : Color("TextColor"))
        }
    }
}

// MARK: - Preview UI
struct AnswerLettersView_Previews: PreviewProvider {
    static var previews: some View {
        AnswerLettersView().environmentObject(GameManager())
    }
}
