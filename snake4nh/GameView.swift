//
//  GameView.swift
//  snake4nh
//
//  Created by Jan Bob on 1/3/26.
//

import SwiftUI
import SpriteKit

struct GameView: View {
    @Binding var currentView: AppView
    let difficulty: GameDifficulty
    @AppStorage("selectedPlayer") private var selectedPlayer: String = "X"
    @State private var score: Int = 0
    @State private var isGameOver: Bool = false
    
    // Create scene as a stored property
    private var gameScene: GameScene
    
    init(currentView: Binding<AppView>, difficulty: GameDifficulty) {
        self._currentView = currentView
        self.difficulty = difficulty
        
        // Initialize the game scene
        let scene = GameScene(size: CGSize(width: 400, height: 600))
        scene.scaleMode = .aspectFill
        scene.setSpeed(difficulty.speed)
        self.gameScene = scene
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Score and difficulty header
                    HStack {
                        Image(selectedPlayer)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                        
                        Text("Score: \(score)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text(difficulty.displayName)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(difficulty == .easy ? .green : .orange)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.2))
                            )
                    }
                    .padding()
                    //.background(Color.gray.opacity(0.3))
                    
                    // Game scene
                    SpriteView(scene: gameScene)
                        .frame(height: geometry.size.height - 180)
                        .onAppear {
                            setupSceneCallbacks()
                        }
                    
                    // Control buttons or Game Over buttons
                    VStack(spacing: 20) {
                        if isGameOver {
                            // Game over button
                            Button(action: {
                                saveScore(score: score, difficulty: difficulty)
                                currentView = .menu
                            }) {
                                Text("OK")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 200, height: 60)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.blue)
                                            .shadow(radius: 5)
                                    )
                            }
                            .padding(.top, 40)
                        } else {
                            // Direction buttons
                            DirectionButton(direction: "↑", color: .blue) {
                                gameScene.changeDirection(to: .up)
                            }
                            
                            HStack(spacing: 40) {
                                DirectionButton(direction: "←", color: .blue) {
                                    gameScene.changeDirection(to: .left)
                                }
                                .offset(y: -40)
                                
                                DirectionButton(direction: "↓", color: .blue) {
                                    gameScene.changeDirection(to: .down)
                                }
                                
                                DirectionButton(direction: "→", color: .blue) {
                                    gameScene.changeDirection(to: .right)
                                }
                                .offset(y: -40)
                            }
                        }
                    }
                    .frame(height: 140)
                    .frame(maxWidth: .infinity)
                    //.background(Color.gray.opacity(0.3))
                }
            }
        }
        .statusBar(hidden: true)
    }
    
    func setupSceneCallbacks() {
        gameScene.onScoreUpdate = { [self] newScore in
            score = newScore
        }
        
        gameScene.onGameOver = { [self] in
            isGameOver = true
        }
    }
    
    func saveScore(score: Int, difficulty: GameDifficulty) {
        var scores = UserDefaults.standard.array(forKey: "highScores") as? [[String: Any]] ?? []
        
        let newScore: [String: Any] = [
            "score": score,
            "difficulty": difficulty.displayName,
            "date": Date().timeIntervalSince1970,
            "player": selectedPlayer
        ]
        
        scores.append(newScore)
        
        // Keep only top 10 scores
        scores.sort { (($0["score"] as? Int) ?? 0) > (($1["score"] as? Int) ?? 0) }
        if scores.count > 10 {
            scores = Array(scores.prefix(10))
        }
        
        UserDefaults.standard.set(scores, forKey: "highScores")
    }
}

struct DirectionButton: View {
    let direction: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(direction)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 70, height: 70)
                .background(
                    Circle()
                        .fill(color)
                        .shadow(radius: 5)
                )
        }
    }
}
