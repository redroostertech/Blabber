//
//  StatsContentView.swift
//  WordBomb
//
//  Created by Apps4World on 3/2/22.
//

import SwiftUI

// MARK: - Stats Highlights type
enum StatsType: String, CaseIterable, Identifiable {
    case won, lost
    var id: Int { hashValue }
    
    var color: Color {
        switch self {
        case .won:
            return Color(#colorLiteral(red: 0.1190171716, green: 0.721068723, blue: 0.6405861576, alpha: 1))
        case .lost:
            return Color(#colorLiteral(red: 0.973535955, green: 0.2599409819, blue: 0.299492985, alpha: 1))
        }
    }
    
    var icon: String {
        switch self {
        case .won:
            return "correct"
        case .lost:
            return "wrong"
        }
    }
}

/// Show generic game stats
struct StatsContentView: View {
    
    @EnvironmentObject private var manager: GameManager
    
    // MARK: - Main rendering function
    var body: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()
            VStack(spacing: 10) {
                HeaderTitle
                ScrollView(.vertical, showsIndicators: false) {
                    Spacer(minLength: 10)
                    VStack(spacing: 15) {
                        LazyVGrid(columns: Array(repeating: GridItem(spacing: 15), count: 2)) {
                            ForEach(StatsType.allCases) { type in
                                StatsTile(type: type)
                            }
                        }
                        Banner(smallBannerSize: false)
                        WinRateTile
                        CategoryWordsStatsView
                    }
                    Spacer(minLength: 10)
                }.padding(.horizontal)
            }
        }
    }
    
    /// Header title
    private var HeaderTitle: some View {
        HStack(alignment: .top) {
            Text("Game Stats").font(.largeTitle).bold()
            Spacer()
            Button {
                manager.fullScreenMode = nil
            } label: {
                Image(systemName: "xmark").font(.system(size: 18, weight: .medium))
            }
        }.padding(.horizontal).foregroundColor(Color("TextColor"))
    }
    
    /// Stats tile view
    private func StatsTile(type: StatsType) -> some View {
        ZStack {
            type.color.cornerRadius(20)
            VStack(spacing: 0) {
                Image(uiImage: UIImage(named: type.icon)!)
                    .resizable().aspectRatio(contentMode: .fit)
                    .padding(.horizontal, 20).padding(.top, 10)
                HStack {
                    Text(type.rawValue.uppercased())
                    Spacer()
                    Text(type == .won ? "\(manager.correctAnswers)" : "\(manager.wrongAnswers)")
                }
                .padding().foregroundColor(.white)
                .font(.system(size: 20, weight: .semibold))
            }
        }
    }
    
    /// Win rate percentage
    private var WinRateTile: some View {
        let won: Double = Double(manager.correctAnswers)
        let lost: Double = Double(max(1, manager.wrongAnswers))
        let rate = String(format: "%.f%%", won / (won + lost) * 100.0)
        return ZStack {
            Color("PrimaryColor").cornerRadius(20)
            HStack(spacing: 20) {
                Text("WIN RATE")
                Text(rate)
            }
            .foregroundColor(.white)
            .font(.system(size: 20, weight: .semibold))
        }.frame(height: 65)
    }
    
    /// Category words stats
    private var CategoryWordsStatsView: some View {
        VStack(spacing: 20) {
            Color("LetterBoxColor").frame(height: 1)
            VStack(spacing: 20) {
                ForEach(GameCategory.allCases) { gameCategory in
                    HStack(spacing: 10) {
                        Text(gameCategory.icon)
                        Text(gameCategory.rawValue.capitalized)
                        Spacer()
                        Text(manager.completedWords(forCategory: gameCategory.rawValue))
                    }.font(.system(size: 22, weight: .semibold))
                    Color("LetterBoxColor").frame(height: 1)
                }
            }
        }.padding(.top)
    }
}

// MARK: - Preview UI
struct StatsContentView_Previews: PreviewProvider {
    static var previews: some View {
        StatsContentView().environmentObject(GameManager())
    }
}
