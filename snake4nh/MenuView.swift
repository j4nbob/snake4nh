//
//  MenuView.swift
//  snake4nh
//
//  Created by Jan Bob on 1/3/26.
//

import SwiftUI

struct MenuView: View {
    @Binding var currentView: AppView
    @Binding var gameDifficulty: GameDifficulty
    @AppStorage("selectedPlayer") private var selectedPlayer: String = "X"
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.green.opacity(0.6), .blue.opacity(0.4)]), 
                          startPoint: .topLeading, 
                          endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Image("snake")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .shadow(radius: 15)
                    .padding(.top, 20)
                
                MenuButton(title: "EAT MICE (EASY)", color: .green) {
                    gameDifficulty = .easy
                    currentView = .game
                }
                
                MenuButton(title: "EAT RATS (HARD)", color: .red) {
                    gameDifficulty = .hard
                    currentView = .game
                }
                
                Button(action: {
                    currentView = .playerView
                }) {
                    HStack(spacing: 15) {
                        Text("Choose Player :")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Image(selectedPlayer)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.brown)
                            .shadow(radius: 5)
                    )
                }
                .padding(.horizontal, 40)
                
                MenuButton(title: "🏆 The Hall Of Fame 🏆", color: .brown) {
                    currentView = .hallOfFame
                }
                
                MenuButton(title: "Exit", color: .gray) {
                    exit(0)
                }
                
                Spacer()
                
                Text("snake4nh")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.bottom, 5)
        
                Text("mmmguitars - 01.04.2026")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.bottom, 5)
            }
            .padding()
        }
    }
}

struct MenuButton: View {
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(color)
                        .shadow(radius: 5)
                )
        }
        .padding(.horizontal, 40)
    }
}

enum AppView {
    case menu
    case game
    case hallOfFame
    case playerView
}

enum GameDifficulty {
    case easy
    case hard
    
    var speed: TimeInterval {
        switch self {
        case .easy: return 0.2
        case .hard: return 0.1
        }
    }
    
    var displayName: String {
        switch self {
        case .easy: return "Easy"
        case .hard: return "Hard"
        }
    }
}
