//
//  GameScene.swift
//  Hippo Hop
//
//  Created by Ramar Parham on 12/24/19.
//  Copyright © 2019 Ramar Parham. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
 //MARK: - Properties
    
    var ground: SKSpriteNode!
    var player: SKSpriteNode!
    var cameraNode = SKCameraNode()
    var obstacles: [SKSpriteNode] = []
    var slime: SKSpriteNode!
    
    var cameraMovePointPerSecond: CGFloat = 3000.0
    
    var lastUpdateTime: TimeInterval = 0.0
    var dt: TimeInterval = 0.0
    
    //3.0
    var isTime: CGFloat = 10.0
    var onGround = true
    var velocityY: CGFloat = 0.0
    var gravity: CGFloat = 0.6
    var playerPosY: CGFloat = 0.0
    
    var numScore: Int = 0
    var gameOver = false
    var life: Int = 3
    
    var lifeNodes: [SKSpriteNode] = []
    var scoreLbl = SKLabelNode(fontNamed: "Georgia")
    var slimeIcon: SKSpriteNode!
    
    //var pauseNode: SKSpriteNode!
    var containerNode = SKNode()
    
    var playableRect: CGRect {
        let ratio: CGFloat
        switch UIScreen.main.nativeBounds.height {
        case 2688, 1792, 2436:
            ratio = 2.16
        default:
            ratio = 16/9
        }
        
        let playableHeight = size.width / ratio
        let playableMargin = (size.height - playableHeight) / 2.0
        
        return CGRect(x: 0.0, y: playableMargin, width: size.width, height: playableHeight)
    }
    
    var cameraRect: CGRect {
        let width = playableRect.width
        let height = playableRect.height
        let x = cameraNode.position.x - size.width/2.0 + (size.width - width)/2.0
        let y = cameraNode.position.y - size.height/2.0 + (size.height - height)/2.0
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
 //MARK: - Systems
    
    override func didMove(to view: SKView) {
        setupNodes()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if !isPaused {
            if onGround {
                onGround = false
                velocityY = -25.0
            }
        }
        //guard let touch = touches.first else { return }
        //let node = atPoint(touch.location(in: self))
        
        /* if node.name == "pause" {
            if isPaused { return }
            createPanel()
            lastUpdateTime = 0.0
            dt = 0.0
            isPaused = false
            
        } else if node.name == "resume" {
            containerNode.removeFromParent()
            isPaused = false
            
            
        } else if node.name == "quit" {
            let scene = MainMenu(size: size)
            scene.scaleMode = scaleMode
            view!.presentScene(scene, transition: .doorsOpenVertical(withDuration: 0.8))
        } else {
            if !isPaused {
                if onGround {
                    onGround = false
                    velocityY = -25.0
                }
            }
            
        } */
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if velocityY < -12.5 {
            velocityY = -12.5
        }
    }
    

    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else  {
            dt = 0
        }
        lastUpdateTime = currentTime
        moveCamera()
        movePlayer()
        
        velocityY += gravity
        player.position.y -= velocityY
        
        if player.position.y < playerPosY {
            player.position.y = playerPosY
            velocityY = 0.0
            onGround = true
        }
        
        if gameOver {
            let scene = GameOver(size: size)
            scene.scaleMode = scaleMode
            view!.presentScene(scene, transition: .doorsCloseVertical(withDuration: 0.8))
        }
        
        boundCheckPlayer()
       
    }
    
}

//MARK: - Configurations

extension GameScene {
    
     func setupNodes() {
        createBG()
        createGround()
        createPlayer()
        setupObstacles()
        spawnObstacles()
        setupSlime()
        spawnSlime()
        setupPhysics()
        setupLife()
        setupScore()
        //setupPause()
        setupCamera()
           
       }
    
    func setupPhysics() {
        physicsWorld.contactDelegate = self
    }
    
    func createBG() {
        for i in 0...2 {
            let bg = SKSpriteNode(imageNamed: "background")
            bg.name = "BG"
            bg.position = CGPoint(x: CGFloat(i)*bg.frame.width, y: 0.0)
            bg.size.width = self.size.width
            bg.size.height = self.size.height
            bg.anchorPoint = CGPoint(x: 0,y: 0)
            addChild(bg)
        }
    }
    
    func createGround() {
        for i in 0...2 {
            ground = SKSpriteNode(imageNamed: "ground")
            ground.name = "ground"
            ground.anchorPoint = .zero
            ground.zPosition = 1.0
            ground.position = CGPoint(x: CGFloat(i)*ground.frame.width, y: 0.0)
            ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
            ground.physicsBody! .isDynamic = false
            ground.physicsBody!.affectedByGravity = false
            ground.physicsBody!.categoryBitMask = PhysicsCategory.Ground
            ground.physicsBody!.contactTestBitMask = PhysicsCategory.Player
            addChild(ground)
        }
    }
    
    func createPlayer() {
        player = SKSpriteNode(imageNamed: "hippo")
        player.name = "hippo"
        player.setScale(0.85)
        player.position = CGPoint(x: frame.width/2.0 - 100.0, y: ground.frame.height + player.frame.height/2.0)
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width/2.0)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.restitution = 0.0
        player.physicsBody!.categoryBitMask = PhysicsCategory.Player
        player.physicsBody!.contactTestBitMask =
            PhysicsCategory.Obstacle  | PhysicsCategory.Slime
        playerPosY = player.position.y
        
        addChild(player)
    }
    
    func setupCamera() {
        addChild(cameraNode)
        camera = cameraNode
        cameraNode.position = CGPoint(x: frame.midX, y: frame.midY)
    }
    
    func moveCamera() {
        let amountToMove = CGPoint(x: cameraMovePointPerSecond * CGFloat(dt), y: 0.0)
        cameraNode.position += amountToMove
        
        //Background
        enumerateChildNodes(withName: "BG") { (node, _) in
            let node = node as! SKSpriteNode
            
            if node.position.x + node.frame.width < self.cameraRect.origin.x {
                node.position = CGPoint(x: node.position.x + node.frame.width*2.0, y: node.position.y)
            }
        }
        
        //Ground
        enumerateChildNodes(withName: "ground") { (node, _) in
            let node = node as! SKSpriteNode
            
            if node.position.x + node.frame.width < self.cameraRect.origin.x {
                node.position = CGPoint(x: node.position.x + node.frame.width*2.0, y: node.position.y)
            }
        }
    }
    
    func movePlayer() {
       let amountToMove = cameraMovePointPerSecond * CGFloat(dt)
       let rotate = CGFloat(1).degreesToRadians() * amountToMove/2.5
        player.zRotation -= rotate
        player.position.x += amountToMove
    }
    
    func setupObstacles() {
        for i in 1...3 {
            let sprite = SKSpriteNode(imageNamed: "Obstacle-\(i)")
            sprite.name = "Obstacle"
            obstacles.append(sprite)
        }
    
    
     
        for i in 1...2 {
            let sprite = SKSpriteNode(imageNamed: "block-\(i)")
            sprite.name = "block"
            obstacles.append(sprite)
        }
        
        let index = Int(arc4random_uniform(UInt32(obstacles.count-5)))
        let sprite = obstacles[index].copy() as! SKSpriteNode
        sprite.zPosition = 5.0
        sprite.setScale(0.85)
        sprite.position = CGPoint(x: cameraRect.maxX + sprite.frame.width/2.0, y: ground.frame.height + sprite.frame.height/2.0)
        
        sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
        sprite.physicsBody!.affectedByGravity = false
        sprite.physicsBody!.isDynamic = false
        
        if sprite.name == "Obstacle-1" {
            sprite.physicsBody!.categoryBitMask = PhysicsCategory.Obstacle
        } else {
            sprite.physicsBody!.categoryBitMask = PhysicsCategory.Obstacle
        }
        
        sprite.physicsBody!.contactTestBitMask = PhysicsCategory.Player
        addChild(sprite)
        sprite.run(.sequence([
            .wait(forDuration: 10.0),
            .removeFromParent()
        ]))
    }
    
    func spawnObstacles () {
        //1.5
        let random = Double(CGFloat.random(min: 4.5 ,max: isTime))
        run(.repeatForever(.sequence([
            .wait(forDuration: random),
                .run { [weak self] in
                    self?.setupObstacles()
            }
        
        ])))
        
        run(.repeatForever(.sequence([
            .wait(forDuration: 5.0),
                .run {
                    self.isTime -= 0.01
                    
                    if self.isTime <= 1.5 {
                        self.isTime = 1.5
                    }
            }
        ])))
        
        
        
     
    }
    
    func setupSlime() {
        slime = SKSpriteNode(imageNamed: "slime")
        slime.name = "slime"
        slime.zPosition = 20.0
        slime.setScale(0.85)
        let slimeHeight = slime.frame.height
        let random = CGFloat.random(min: -slimeHeight, max: slimeHeight*2.0)
        slime.position = CGPoint(x: cameraRect.maxX + slime.frame.width, y: size.height/2.0 + random)
        slime.physicsBody = SKPhysicsBody(circleOfRadius: slime.size.width/2.0)
        slime.physicsBody!.affectedByGravity = false
        slime.physicsBody!.isDynamic = false
        slime.physicsBody!.categoryBitMask = PhysicsCategory.Slime
        slime.physicsBody!.contactTestBitMask = PhysicsCategory.Player
        
        addChild(slime)
        slime.run(.sequence([.wait(forDuration: 15.0), .removeFromParent()]))
        
        
    }
    
    func spawnSlime() {
        //2.5 6.0
        let random = CGFloat.random(min: 6.5, max: 12.0)
        run(.repeatForever(.sequence([
            .wait(forDuration: TimeInterval(random)),
            .run { [weak self] in
                self?.setupSlime()
            }
        ])))
    }
    
        func setupLife() {
        let node1 = SKSpriteNode(imageNamed: "life-on")
        let node2 = SKSpriteNode(imageNamed: "life-on")
        let node3 = SKSpriteNode(imageNamed: "life-on")
        setupLifePos(node1, i: 1.0, j: 0.0)
        setupLifePos(node2, i: 2.0, j: 8.0)
        setupLifePos(node3, i: 3.0, j: 16.0)
        lifeNodes.append(node1)
        lifeNodes.append(node2)
        lifeNodes.append(node3)
    }
    
    func setupLifePos(_ node: SKSpriteNode, i: CGFloat, j: CGFloat) {
        let width = playableRect.width
        let height = playableRect.height
        
        node.setScale(0.5)
        node.zPosition = 50.0
        node.position = CGPoint(x: -width/2.0 + node.frame.width*i + j - 15.0, y: height/2.0 - node.frame.height/2.0)
        
        cameraNode.addChild(node)
    }
    
    func setupScore() {
        
        slimeIcon = SKSpriteNode(imageNamed: "slime")
        slimeIcon.setScale(0.5)
        slimeIcon.zPosition = 50.0
        slimeIcon.position = CGPoint(x: -playableRect.width/2.0 + slimeIcon.frame.width, y: playableRect.height/2.5 - lifeNodes[0].frame.height/2.0 - slimeIcon.frame.height/2.0)

        cameraNode.addChild(slimeIcon)
        
        scoreLbl.text = "\(numScore)"
        scoreLbl.fontSize = 60.0
        scoreLbl.horizontalAlignmentMode = .left
        scoreLbl.verticalAlignmentMode = .top
        scoreLbl.zPosition = 50.0
        scoreLbl.position = CGPoint(x: -playableRect.width/2.0 + slimeIcon.frame.width*2.0 - 10.0, y: slimeIcon.position.y + slimeIcon.frame.height/2.0 - 8.0)
        
        cameraNode.addChild(scoreLbl)
    }
    
    /* func setupPause() {
        pauseNode = SKSpriteNode(imageNamed: "pause")
        pauseNode.setScale(0.5)
        pauseNode.zPosition = 50.0
        pauseNode.name = "pause"
        pauseNode.position = CGPoint(x: playableRect.width/2.0 - pauseNode.frame.width/2.0 - 30.0, y: playableRect.height/2.0 - pauseNode.frame.height/2.0 - 10.0)
        
        cameraNode.addChild(pauseNode)
    } */
    
     /* func createPanel() {
        cameraNode.addChild(containerNode)
        
        let panel = SKSpriteNode(imageNamed: "panel")
        panel.zPosition = 60.0
        panel.position = .zero
        containerNode.addChild(panel)
        
        let resume = SKSpriteNode(imageNamed: "resume")
        resume.zPosition = 70.0
        resume.name = "resume"
        resume.setScale(0.7)
        resume.position = CGPoint(x: -panel.frame.width/2.0 + resume.frame.width*1.5, y: 0.0)
        panel.addChild(resume)
        
        let quit = SKSpriteNode(imageNamed: "back")
        quit.zPosition = 70.0
        quit.name = "quit"
        quit.setScale(0.7)
        quit.position = CGPoint(x: panel.frame.width/2.0 + resume.frame.width*1.5, y: 0.0)
        quit.addChild(quit)
    } */
    
    func boundCheckPlayer() {
        let bottomLeft = CGPoint(x: cameraRect.minX, y: cameraRect.minY)
        if player.position.x <= bottomLeft.x {
            player.position.x = bottomLeft.x
            lifeNodes.forEach( { $0.texture = SKTexture(imageNamed: "life-off")})
            numScore = 0
            scoreLbl.text = "\(numScore)"
            gameOver = true
        }
    }
    
    func setupGameOver() {
        life -= 1
        if life <= 0 { life = 0}
        lifeNodes[life].texture = SKTexture(imageNamed: "life-off")
        
        if life <= 0 && !gameOver {
            gameOver = true
        }
    }
}

//MARK: - SKPhysicsContactDelegate

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let other = contact.bodyA.categoryBitMask == PhysicsCategory.Player ? contact.bodyB : contact.bodyA
        
        switch other.categoryBitMask {
        case PhysicsCategory.Obstacle:
            cameraMovePointPerSecond += 150.0
            numScore -= 1
            if numScore <= 0 { numScore = 0 }
            //scoreLbl.text = "\(numScore)"
            print("GameOver")
        case PhysicsCategory.Slime:
            if let node = other.node {
                node.removeFromParent()
                numScore += 1
                scoreLbl.text = "\(numScore)"
                if numScore % 5 == 0 {
                    cameraMovePointPerSecond += 100.0
                }
                
                let highscore = ScoreGenerator.sharedInstance.getHighscore()
                if numScore > highscore {
                    ScoreGenerator.sharedInstance.setHighscore(highscore)
                    ScoreGenerator.sharedInstance.setScore(numScore)
                }
            }
           
        default: break
        }
    }
}
