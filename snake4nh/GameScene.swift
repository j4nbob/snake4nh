//
//  GameScene.swift
//  snake4nh
//
//  Created by Jan Bob on 1/3/26.
//

import SpriteKit
import AVFoundation

enum Direction {
    case up, down, left, right
}

class GameScene: SKScene {
    var snake: [SKShapeNode] = []
    var food: SKShapeNode?
    var direction: Direction = .right
    var nextDirection: Direction = .right
    var gameSpeed: TimeInterval = 0.2
    var lastUpdateTime: TimeInterval = 0
    var score: Int = 0
    var isGameOver: Bool = false
    
    var onScoreUpdate: ((Int) -> Void)?
    var onGameOver: (() -> Void)?
    
    let cellSize: CGFloat = 20
    var gridWidth: Int = 0
    var gridHeight: Int = 0
    var offsetX: CGFloat = 0
    var offsetY: CGFloat = 0
    
    func drawWalls() {
        let wallThickness: CGFloat = 3
        let sideThickness: CGFloat = 1
        
        let playAreaWidth = CGFloat(gridWidth) * cellSize
        let playAreaHeight = CGFloat(gridHeight) * cellSize
        
        // Top wall
        let topWall = SKSpriteNode(color: .gray, size: CGSize(width: playAreaWidth, height: wallThickness))
        topWall.position = CGPoint(x: offsetX + playAreaWidth / 2, y: offsetY + playAreaHeight - wallThickness / 2)
        topWall.zPosition = 10
        addChild(topWall)
        
        // Bottom wall
        let bottomWall = SKSpriteNode(color: .gray, size: CGSize(width: playAreaWidth, height: wallThickness))
        bottomWall.position = CGPoint(x: offsetX + playAreaWidth / 2, y: offsetY + wallThickness / 2)
        bottomWall.zPosition = 10
        addChild(bottomWall)
        
        // Left wall
        let leftWall = SKSpriteNode(color: .gray, size: CGSize(width: sideThickness, height: playAreaHeight))
        leftWall.position = CGPoint(x: offsetX + sideThickness / 2, y: offsetY + playAreaHeight / 2)
        leftWall.zPosition = 10
        addChild(leftWall)
        
        // Right wall
        let rightWall = SKSpriteNode(color: .gray, size: CGSize(width: sideThickness, height: playAreaHeight))
        rightWall.position = CGPoint(x: offsetX + playAreaWidth - sideThickness / 2, y: offsetY + playAreaHeight / 2)
        rightWall.zPosition = 10
        addChild(rightWall)
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        // Configure audio session for device playback
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            print("Audio session configured successfully")
        } catch {
            print("Failed to set up audio session: \(error)")
        }
        
        // Enable scene updates
        view.isPaused = false
        view.preferredFramesPerSecond = 60
        
        // Calculate square grid dimensions based on smaller dimension
        let smallerDimension = min(size.width, size.height)
        let gridSize = Int(smallerDimension / cellSize)
        gridWidth = gridSize
        gridHeight = gridSize
        
        // Calculate offsets to center the play area
        let playAreaWidth = CGFloat(gridWidth) * cellSize
        let playAreaHeight = CGFloat(gridHeight) * cellSize
        offsetX = (size.width - playAreaWidth) / 2
        offsetY = (size.height - playAreaHeight) / 2
        
        drawWalls()
        setupGame()
    }
    
    func setupGame() {
        // Clear existing snake and food
        snake.forEach { $0.removeFromParent() }
        snake.removeAll()
        food?.removeFromParent()
        
        // Reset game state
        direction = .right
        nextDirection = .right
        score = 0
        isGameOver = false
        lastUpdateTime = 0
        
        // Create initial snake (3 segments)
        let startX = gridWidth / 2
        let startY = gridHeight / 2
        
        for i in 0..<3 {
            let segment = createSnakeSegment(x: startX - i, y: startY)
            snake.append(segment)
            addChild(segment)
        }
        
        spawnFood()
        onScoreUpdate?(score)
    }
    
    func createSnakeSegment(x: Int, y: Int) -> SKShapeNode {
        let segment = SKShapeNode(rectOf: CGSize(width: cellSize - 2, height: cellSize - 2), cornerRadius: 3)
        segment.fillColor = .green
        segment.strokeColor = .white
        segment.lineWidth = 1
        segment.position = gridToPoint(x: x, y: y)
        return segment
    }
    
    func spawnFood() {
        food?.removeFromParent()
        
        var foodX: Int
        var foodY: Int
        
        // Find empty position
        repeat {
            foodX = Int.random(in: 0..<gridWidth)
            foodY = Int.random(in: 0..<gridHeight)
        } while snake.contains(where: { pointToGrid($0.position) == (foodX, foodY) })
        
        food = SKShapeNode(circleOfRadius: cellSize / 2 - 2)
        food?.fillColor = .red
        food?.strokeColor = .white
        food?.lineWidth = 1
        food?.position = gridToPoint(x: foodX, y: foodY)
        
        if let food = food {
            addChild(food)
        }
    }
    
    func gridToPoint(x: Int, y: Int) -> CGPoint {
        let pointX = CGFloat(x) * cellSize + cellSize / 2 + offsetX
        let pointY = CGFloat(y) * cellSize + cellSize / 2 + offsetY
        return CGPoint(x: pointX, y: pointY)
    }
    
    func pointToGrid(_ point: CGPoint) -> (Int, Int) {
        let x = Int((point.x - offsetX) / cellSize)
        let y = Int((point.y - offsetY) / cellSize)
        return (x, y)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if isGameOver {
            return
        }
        
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        
        if currentTime - lastUpdateTime >= gameSpeed {
            lastUpdateTime = currentTime
            moveSnake()
        }
    }
    
    func moveSnake() {
        guard let head = snake.first else { return }
        
        // Update direction
        direction = nextDirection
        
        let currentGrid = pointToGrid(head.position)
        var newX = currentGrid.0
        var newY = currentGrid.1
        
        // Calculate new head position
        switch direction {
        case .up:
            newY += 1
        case .down:
            newY -= 1
        case .left:
            newX -= 1
        case .right:
            newX += 1
        }
        
        // Check wall collision
        if newX < 0 || newX >= gridWidth || newY < 0 || newY >= gridHeight {
            gameOver()
            return
        }
        
        // Check self collision
        if snake.dropFirst().contains(where: { pointToGrid($0.position) == (newX, newY) }) {
            gameOver()
            return
        }
        
        // Create new head
        let newHead = createSnakeSegment(x: newX, y: newY)
        addChild(newHead)
        snake.insert(newHead, at: 0)
        
        // Check food collision
        if let food = food {
            let foodGrid = pointToGrid(food.position)
            if foodGrid == (newX, newY) {
                score += 1
                onScoreUpdate?(score)
                spawnFood()
                run(SKAction.playSoundFileNamed("soundlink.caf", waitForCompletion: false))
            } else {
                // Remove tail if no food eaten
                let tail = snake.removeLast()
                tail.removeFromParent()
            }
        }
    }
    
    func changeDirection(to newDirection: Direction) {
        // Prevent 180-degree turns
        switch (direction, newDirection) {
        case (.up, .down), (.down, .up), (.left, .right), (.right, .left):
            return
        default:
            nextDirection = newDirection
            run(SKAction.playSoundFileNamed("soundstroke.caf", waitForCompletion: false))
        }
    }
    
    func gameOver() {
        isGameOver = true
        
        print("Game over - attempting to play sound")
        let soundAction = SKAction.playSoundFileNamed("soundgameover.caf", waitForCompletion: false)
        run(soundAction)
        print("Sound action executed")
    
        // Visual feedback
        snake.forEach { segment in
            segment.fillColor = .red
        }
        
        // Show game over label
        let label = SKLabelNode(text: "GAME OVER")
        label.fontSize = 40
        label.fontColor = .white
        label.position = CGPoint(x: size.width / 2, y: size.height / 2 + 40)
        label.name = "gameOverLabel"
        addChild(label)
        
        // Score label
        let scoreLabel = SKLabelNode(text: "Score: \(score)")
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        scoreLabel.name = "scoreLabel"
        addChild(scoreLabel)
        
        // Trigger callback
        onGameOver?()
    }
    
    func setSpeed(_ speed: TimeInterval) {
        gameSpeed = speed
    }
}
