//
//  HallOfFameView.swift
//  snake4nh
//
//  Created by Jan Bob on 1/3/26.
//

import SwiftUI

struct HallOfFameView: View {
    @Binding var currentView: AppView
    @State private var highScores: [[String: Any]] = []
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.purple.opacity(0.6), .blue.opacity(0.4)]), 
                          startPoint: .topLeading, 
                          endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("🏆 THE HALL OF FAME 🏆")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(radius: 10)
                    .padding(.top, 40)
                
                if highScores.isEmpty {
                    VStack(spacing: 10) {
                        Text("No scores yet!")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                        
                        Text("Play a game to set your first record")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.top, 10)
                } else {
                    ScrollView {
                        VStack(spacing: 6) {
                            ForEach(Array(highScores.enumerated()), id: \.offset) { index, score in
                                ScoreRow(
                                    rank: index + 1,
                                    score: score["score"] as? Int ?? 0,
                                    difficulty: score["difficulty"] as? String ?? "Unknown",
                                    date: Date(timeIntervalSince1970: score["date"] as? TimeInterval ?? 0),
                                    player: score["player"] as? String ?? "X"
                                )
                            }
                        }
                        .padding()
                    }
                }
                
                Spacer()
                
                Button(action: {
                    currentView = .menu
                }) {
                    Text("Back")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue)
                                .shadow(radius: 5)
                        )
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            loadHighScores()
        }
    }
    
    func loadHighScores() {
        highScores = UserDefaults.standard.array(forKey: "highScores") as? [[String: Any]] ?? []
    }
}

struct ScoreRow: View {
    let rank: Int
    let score: Int
    let difficulty: String
    let date: Date
    let player: String
    
    var body: some View {
        HStack {
            Text("#\(rank)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(rank <= 3 ? .yellow : .white)
                .frame(width: 40)
            
            Image(player)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("\(score) points")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("•")
                        .foregroundColor(.white.opacity(0.5))
                    
                    Text(difficulty)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(difficulty == "Easy" ? .green : .orange)
                }
                
                Text(formatDate(date))
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.15))
        )
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
