//
//  LettersGridView.swift
//  WordBomb
//
//  Created by Apps4World on 3/2/22.
//

import SwiftUI

/// Shows a grid of letters for the word
struct LettersGridView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var manager: GameManager
    @State private var selectedItem: String = ""
    private let width: Double = UIScreen.main.bounds.width/Double(6)
    
    // MARK: - Main rendering function
    var body: some View {
        let size = width - 15
        return VStack(spacing: 10) {
            ForEach(0..<6, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(0..<6, id: \.self) { column in
                        LetterBoxView(row: row, column: column)
                            .frame(width: size, height: size).cornerRadius(15)
                    }
                }
            }
        }
    }
    
    /// Create the word letter box
    private func LetterBoxView(row: Int, column: Int) -> some View {
        let background = Color("KeyboardKeyColor")
        let textColor = colorScheme == .light && background == Color("LetterBoxColor") ? Color.black : Color.white
        let letter = manager.letters[row]?[column] ?? ""
        return ZStack {
            if letter == "$" {
                selectedItem == "\(row)_\(column)" ? Color.red : Color.white
            } else { background }
            if manager.incorrectLetter == "\(row)_\(column)" {
                Color.red.animation(Animation.easeIn).onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation { manager.incorrectLetter = "" }
                    }
                }
            }
            Text(letter == "$" ? "💣" : letter)
                .font(.system(size: 25, weight: .semibold, design: .rounded))
                .foregroundColor(textColor)
            background.opacity(manager.revealedRows.contains(row) ? 0 : 1)
        }.onTapGesture {
            selectedItem = "\(row)_\(column)"
            manager.selectedLetter(atRow: row, column: column)
        }
    }
}

// MARK: - Preview UI
struct LettersGridView_Previews: PreviewProvider {
    static var previews: some View {
        LettersGridView().environmentObject(GameManager())
    }
}
