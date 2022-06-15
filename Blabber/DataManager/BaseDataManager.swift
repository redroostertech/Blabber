//
//  BaseDataManager.swift
//  WordBomb
//
//  Created by Apps4World on 3/2/22.
//

import SwiftUI
import Foundation

// MARK: - Word level manager
open class BaseDataManager: NSObject {
    /// Get a random word for a given category based on levels data
    /// - Parameters:
    ///   - levels: a dictionary of game levels and words per each leve
    ///   - category: game category selected by the user
    /// - Returns: returns a random word
    static func word(_ levels: [String: [String]], category: String) -> String? {
        guard let levelWords = levels[category] else { return nil }
        let completedWords = UserDefaults.standard.stringArray(forKey: category) ?? [String]()
        let randomWord = levelWords.filter({ !completedWords.contains($0) }).randomElement()
        return randomWord
    }
    
    /// Verify if the submitted letters matches the current level correct word
    /// - Parameters:
    ///   - letters: the letters for the row
    ///   - correctWord: the correct expected word
    /// - Returns: a boolean
    func isSubmittedWordCorrect(_ letters: [String], correctWord: String) -> Bool {
        letters.joined().lowercased() == correctWord
    }
    
    /// Mark a correct word as completed so we won't show it again
    /// - Parameters:
    ///   - word: correct word
    ///   - category: game category
    func markCompleted(word: String, category: String) {
        var completedWords = UserDefaults.standard.stringArray(forKey: category) ?? [String]()
        completedWords.append(word)
        UserDefaults.standard.set(completedWords, forKey: category)
        UserDefaults.standard.synchronize()
    }
    
    /// Returns the total words count completed for a category
    /// - Parameter category: game category
    /// - Returns: completed words
    func completedWords(forCategory category: String) -> Int {
        UserDefaults.standard.stringArray(forKey: category)?.count ?? 0
    }
    
    /// Get a new set of lives each day
    var canRefillLivesToday: Bool {
        if UserDefaults.standard.bool(forKey: "lives_\(Date().dailyKey)") == false {
            UserDefaults.standard.set(true, forKey: "lives_\(Date().dailyKey)")
            UserDefaults.standard.synchronize()
            return true
        }
        return false
    }
}

/// Get the daily key identifier
extension Date {
    var dailyKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: self)
    }
}
