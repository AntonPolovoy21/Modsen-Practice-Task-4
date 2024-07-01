//
//  GameScene.swift
//  Police Race
//
//  Created by Anton Polovoy on 1.07.24.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    // MARK: Nodes
    private var backgroundNode1: SKSpriteNode!
    private var backgroundNode2: SKSpriteNode!
    private var buttonLeft: SKSpriteNode!
    private var buttonRight: SKSpriteNode!
    private var player: SKSpriteNode!
    private var enemyCars: [SKSpriteNode] = []
    
    // MARK: States
    private var backgroundHeight: CGFloat = 0
    private let timeInterval: TimeInterval = 0.01
    private let carMoveDuration: TimeInterval = 0.3
    private let carMovementDistance: CGFloat = 100
    private let enemyCarSpeed: CGFloat = 200
    private var playerPosition: PlayerPosition = .center
    private var isPlayerMoving = false
    private var gameScore = 0
    
    // MARK: Timers
    private var timer: Timer?
    private var enemySpawnTimer: Timer?
    
    var parentVC: GameViewController?
    
    override func didMove(to view: SKView) {
        initNodes()
        startBackgroundAnimation()
        startEnemyCarSpawning()
    }
    
    func initNodes() {
        addBackground1()
        addBackground2()
        addButtonToLeft()
        addButtonToRight()
        addCar()
    }
    
    func startBackgroundAnimation() {
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { [weak self] _ in
            self?.updateBackground()
        }
    }
    
    func startEnemyCarSpawning() {
        enemySpawnTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.addEnemyCar()
        }
    }
}

// MARK: Tap Methods

extension GameScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if isPlayerMoving { return }
        for touch in touches {
            let location = touch.location(in: self)
            isPlayerMoving = true
            if buttonLeft.contains(location) {
                switch playerPosition {
                case .left:
                    playerPosition = .left
                    isPlayerMoving = false
                case .center:
                    playerPosition = .left
                    movePlayerCar(to: CGPoint(x: player.position.x - carMovementDistance, y: player.position.y))
                case .right:
                    playerPosition = .center
                    movePlayerCar(to: CGPoint(x: player.position.x - carMovementDistance, y: player.position.y))
                }
            } else if buttonRight.contains(location) {
                switch playerPosition {
                case .left:
                    playerPosition = .center
                    movePlayerCar(to: CGPoint(x: player.position.x + carMovementDistance, y: player.position.y))
                case .center:
                    playerPosition = .right
                    movePlayerCar(to: CGPoint(x: player.position.x + carMovementDistance, y: player.position.y))
                case .right:
                    playerPosition = .right
                    isPlayerMoving = false
                }
            }
        }
    }
}

// MARK: Update Methods

extension GameScene {
    func updateBackground() {
        backgroundNode1.position.y -= 5
        backgroundNode2.position.y -= 5
        
        if backgroundNode1.position.y <= -backgroundHeight / 2 {
            backgroundNode1.position.y = backgroundNode2.position.y + backgroundHeight
        }
        
        if backgroundNode2.position.y <= -backgroundHeight / 2 {
            backgroundNode2.position.y = backgroundNode1.position.y + backgroundHeight
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        updateEnemyCars(currentTime)
    }
    
    private func updateEnemyCars(_ currentTime: TimeInterval) {
        for (index, enemyCar) in enemyCars.enumerated().reversed() {
            if enemyCar.position.y < -50 {
                enemyCars.remove(at: index)
                enemyCar.removeFromParent()
                gameScore += 1
            }
        }
    }
}

// MARK: Nodes Configuration Methods

extension GameScene {
    func addButtonToLeft() {
        buttonLeft = SKSpriteNode(imageNamed: "arrow_left")
        buttonLeft.size = CGSize(width: 75, height: 100)
        buttonLeft.position = CGPoint(x: size.width / 4 + 10, y: 60)
        addChild(buttonLeft)
    }
    
    func addButtonToRight() {
        buttonRight = SKSpriteNode(imageNamed: "arrow_right")
        buttonRight.size = CGSize(width: 75, height: 100)
        buttonRight.position = CGPoint(x: size.width - size.width / 4 - 10, y: 60)
        addChild(buttonRight)
    }
    
    func addBackground1() {
        let imageWidth: CGFloat = 1080
        let imageHeight: CGFloat = 2400
        let aspectRatio = imageWidth / imageHeight
        
        backgroundNode1 = SKSpriteNode(imageNamed: "game-back")
        let scaledHeight = UIScreen.main.bounds.width / aspectRatio
        backgroundNode1.size = CGSize(width: UIScreen.main.bounds.width, height: scaledHeight)
        backgroundNode1.position = CGPoint(x: size.width / 2, y: size.height / 2)
        backgroundNode1.zPosition = -3
        addChild(backgroundNode1)
        
        backgroundHeight = scaledHeight
    }
    
    func addBackground2() {
        let imageWidth: CGFloat = 1080
        let imageHeight: CGFloat = 2400
        let aspectRatio = imageWidth / imageHeight
        
        backgroundNode2 = SKSpriteNode(imageNamed: "game-back")
        let scaledHeight = UIScreen.main.bounds.width / aspectRatio
        backgroundNode2.size = CGSize(width: UIScreen.main.bounds.width, height: scaledHeight)
        backgroundNode2.position = CGPoint(x: size.width / 2, y: size.height / 2 + backgroundNode2.size.height)
        backgroundNode2.zPosition = -3
        addChild(backgroundNode2)
    }
    
    func addCar() {
        player = SKSpriteNode(imageNamed: "car-player")
        player.size = CGSize(width: 50, height: 110)
        player.position = CGPoint(x: size.width / 2, y: 150)
        addChild(player)
    }
    
    func addEnemyCar() {
        let enemyCar = SKSpriteNode(imageNamed: "car-police")
        enemyCar.size = CGSize(width: 85, height: 110)
        let carPos = PlayerPosition.allCases.randomElement()
        var posX = 0.0
        switch carPos {
        case .left:
            posX = size.width / 4
        case .center:
            posX = size.width / 2
        case .right:
            posX = size.width - size.width / 4
        default:
            posX = size.width / 4
        }
        enemyCar.position = CGPoint(x: posX, y: size.height + enemyCar.size.height / 2)
        addChild(enemyCar)
        enemyCars.append(enemyCar)
        moveEnemyCar(car: enemyCar, to: CGPoint(x: enemyCar.position.x, y: -100), duration: 5)
    }
}

// MARK: SKAction Methods

extension GameScene {
    private func movePlayerCar(to position: CGPoint) {
        let moveAction = SKAction.move(to: position, duration: carMoveDuration)
        player.run(moveAction)
        DispatchQueue.main.asyncAfter(deadline: .now() + carMoveDuration) {
            self.isPlayerMoving = false
        }
    }
    
    private func moveEnemyCar(car: SKNode, to position: CGPoint, duration: CGFloat) {
        let moveAction = SKAction.move(to: position, duration: duration)
        car.run(moveAction)
    }
}
