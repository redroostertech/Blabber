//
//  GameManager.swift
//  WordBomb
//
//  Created by Apps4World on 3/2/22.
//

import SwiftUI
import Foundation
import PurchaseKit

/// Full Screen flow
enum FullScreenMode: Int, Identifiable {
    case stats, wrong, correct, settings, tutorial
    var id: Int { hashValue }
}

/// Main game data manager
class GameManager: NSObject, ObservableObject {
    
    /// Dynamic properties that the UI will react to
    @Published var word: String = ""
    @Published var gameCategory: GameCategory = .food
    @Published var fullScreenMode: FullScreenMode?
    @Published var letters: [Int: [String]] = [Int: [String]]()
    @Published var selectedLetters: [String] = Array(repeating: "", count: 6)
    @Published var revealedRows: [Int] = [Int]()
    @Published var incorrectLetter: String = ""
    
    /// Dynamic properties that the UI will react to AND store values in UserDefaults
    @AppStorage("livesCount") var livesCount: Int = AppConfig.defaultLivesCount
    @AppStorage("didShowTutorial") var didShowTutorial: Bool = false
    @AppStorage("correctAnswers") var correctAnswers: Int = 0
    @AppStorage("wrongAnswers") var wrongAnswers: Int = 0
    @AppStorage(AppConfig.premiumVersion) var isPremiumUser: Bool = false {
        didSet { AppConfig.isPremiumUser = isPremiumUser }
    }
    
    /// Private properties used in this class only
    private var levelsData: [String: [String]] = [String: [String]]()
    private var wordManager = BaseDataManager()
    
    /// Default init method
    override init() {
        super.init()
        loadGameLevels()
    }
    
    /// Load all levels
    private func loadGameLevels() {
        guard let path = Bundle.main.path(forResource: "Data", ofType: "json"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe),
              let json = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String: [String]]
        else { return }
        levelsData = json
        setupCategoryWord()
    }
    
    /// Setup category word
    private func setupCategoryWord() {
        if let randomWord = BaseDataManager.word(levelsData, category: gameCategory.rawValue) {
            DispatchQueue.main.async {
                self.word = randomWord
                self.setupRandomLettersGrid()
                if self.livesCount == 0 {
                    self.livesCount = self.wordManager.canRefillLivesToday ? AppConfig.defaultLivesCount : 0
                }
            }
        } else {
            presentAlert(title: "Oops!", message: "Looks like there are no words or you have completed all words for this category")
        }
    }
}

// MARK: - Letters/Word interaction methods
extension GameManager {
    /// Capture selected letters by the user and append to the possible word solution
    func selectedLetter(atRow row: Int, column: Int) {
        if !selectedLetters.contains("") {
            submitCurrentWordSelection()
        } else {
            if livesCount == 0 {
                let freeLives: UIAlertAction? = Rewarded.shared.isRewardedAdReady ? UIAlertAction(title: "FREE Lives", style: .default, handler: { _ in
                    self.getExtraLives()
                }) : nil
                presentAlert(title: "No More Lives", message: "Sorry, you don't have enough lives to play. You will get more lives tomorrow", primaryAction: UIAlertAction(title: "Cancel", style: .cancel, handler: nil), secondaryAction: freeLives)
            } else {
                let letter = letters[row]![column]
                if letter == "$" {
                    showGameOverFlow()
                } else {
                    insertLetter(row: row, column: column, letter: letter)
                }
            }
        }
    }
    
    /// Insert the correct letter in the correct spot
    private func insertLetter(row: Int, column: Int, letter: String) {
        if revealedRows.contains(row) {
            var isCorrectLetter = false
            word.uppercased().map({ String($0) }).enumerated().forEach { index, item in
                if item == letter {
                    selectedLetters[index] = letter
                    isCorrectLetter = true
                }
            }
            if !selectedLetters.contains("") {
                submitCurrentWordSelection()
            } else {
                if isCorrectLetter == false {
                    incorrectLetter = "\(row)_\(column)"
                }
            }
        } else {
            if revealedRows.count % 3 == 0 {
                Interstitial.shared.showInterstitialAds()
            }
            revealedRows.append(row)
        }
    }
    
    /// Setup random letters into the grid view
    func setupRandomLettersGrid() {
        let wordLetters = word.uppercased().shuffled()
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        for row in 0..<6 {
            var randomCharacters = Array(characters.shuffled()).prefix(5)
            randomCharacters.append("$")
            randomCharacters = randomCharacters.shuffled().prefix(5)
            randomCharacters.append(wordLetters[row])
            letters[row] = randomCharacters.shuffled().map({ "\($0)" })
        }
    }
    
    /// Verify the current word selection and submit
    func submitCurrentWordSelection() {
        if wordManager.isSubmittedWordCorrect(selectedLetters, correctWord: word) {
            wordManager.markCompleted(word: word, category: gameCategory.rawValue)
            fullScreenMode = .correct
            correctAnswers += 1
        } else {
            showGameOverFlow()
        }
    }
    
    /// Game over - Reload the game
    func showGameOverFlow() {
        revealedRows.removeAll()
        revealedRows = [0, 1, 2, 3, 4, 5, 6]
        fullScreenMode = .wrong
        wrongAnswers += 1
        livesCount -= 1
        Rewarded.shared.loadAd()
    }
    
    /// Updated game category
    func updateGameCategory(_ gameCategory: GameCategory) {
        if revealedRows.count > 0 {
            presentAlert(title: "Game Progress", message: "Are you sure you want to change the game category? You will lose your current progress", primaryAction: UIAlertAction(title: "I'm sure", style: .default, handler: { _ in
                DispatchQueue.main.async {
                    self.gameCategory = gameCategory
                    self.loadNextLevelWord()
                }
            }), secondaryAction: UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        } else {
            self.gameCategory = gameCategory
            self.setupCategoryWord()
        }
    }
    
    /// Get the ratio of completed correct words per category
    func completedWords(forCategory category: String) -> String {
        "\(wordManager.completedWords(forCategory: category))/\(levelsData[category]?.count ?? 0)"
    }
    
    /// Load next level
    func loadNextLevelWord() {
        letters.removeAll()
        revealedRows.removeAll()
        selectedLetters = Array(repeating: "", count: 6)
        wordManager = BaseDataManager()
        setupCategoryWord()
    }
    
    /// Get extra lives
    private func getExtraLives() {
        Rewarded.shared.showAd { didFinishWatchingAd in
            if didFinishWatchingAd {
                DispatchQueue.main.async {
                    self.livesCount = AppConfig.defaultLivesCount
                }
            }
        }
    }
    
    /// Purchase premium version
    func purchasePremiumVersion() {
        PKManager.purchaseProduct(identifier: AppConfig.premiumVersion) { error, status, _ in
            if let message = error {
                presentAlert(title: "Oops!", message: message)
            }
            if status == .success {
                DispatchQueue.main.async {
                    self.isPremiumUser = true
                }
            }
        }
    }
}

