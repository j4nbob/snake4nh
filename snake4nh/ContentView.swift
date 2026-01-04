//
//  ContentView.swift
//  snake4nh
//
//  Created by Jan Bob on 1/3/26.
//

import SwiftUI

struct ContentView: View {
    @State private var currentView: AppView = .menu
    @State private var gameDifficulty: GameDifficulty = .easy
    
    var body: some View {
        Group {
            switch currentView {
            case .menu:
                MenuView(currentView: $currentView, gameDifficulty: $gameDifficulty)
            case .game:
                GameView(currentView: $currentView, difficulty: gameDifficulty)
            case .hallOfFame:
                HallOfFameView(currentView: $currentView)
            case .playerView:
                PlayerView(currentView: $currentView)
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
