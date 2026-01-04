//
//  PlayerView.swift
//  snake4nh
//
//  Created by Jan Bob on 1/4/26.
//

import SwiftUI

struct PlayerView: View {
    @Binding var currentView: AppView
    @AppStorage("selectedPlayer") private var selectedPlayer: String = "X"
    
    let players = ["X", "N", "H"]
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.green.opacity(0.6), .blue.opacity(0.4)]), 
                          startPoint: .topLeading, 
                          endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Text("Player :")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(radius: 10)
                    .padding(.top, 50)
                
                VStack(spacing: 40) {
                    ForEach(players, id: \.self) { player in
                        PlayerCard(
                            playerName: player,
                            isSelected: selectedPlayer == player,
                            action: {
                                selectedPlayer = player
                            }
                        )
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                Button(action: {
                    currentView = .menu
                }) {
                    Text("Back")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: 200)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.blue)
                                .shadow(radius: 5)
                        )
                }
                .padding(.bottom, 40)
            }
        }
    }
}

struct PlayerCard: View {
    let playerName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 20) {
                Image(playerName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                
                Text(playerName)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(isSelected ? .yellow : .white)
            }
            .frame(width: 160, height: 160)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color.green : Color.white.opacity(0.2))
                    .shadow(radius: isSelected ? 15 : 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.yellow : Color.clear, lineWidth: 4)
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
