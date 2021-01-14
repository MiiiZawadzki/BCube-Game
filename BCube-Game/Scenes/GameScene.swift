//
//  GameScene.swift
//  BCube-Game
//
//  Created by Michał on 06/01/2021.
//

import SpriteKit
import UIKit

class GameScene: SKScene {
    var player: Player!
    var distanceLabel: SKLabelNode!
    var ground:SKSpriteNode!
    var obstacles: [SKSpriteNode]!
    var backgroundObjects: [SKSpriteNode]!
    override func didMove(to view: SKView) {
        // set world physics
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)

        // create player object
        let cube = SKSpriteNode(color: UIColor.red, size: CGSize(width: frame.width/10, height: frame.width/10))
        cube.position = CGPoint(x: frame.midX, y: frame.midY + cube.size.height*4)
        cube.name = "cube"
        
        // create cube physics
        cube.physicsBody = SKPhysicsBody(rectangleOf: cube.size)
        cube.physicsBody?.restitution = 0.0
        cube.zPosition = 1
        cube.physicsBody!.contactTestBitMask = cube.physicsBody!.collisionBitMask
        cube.physicsBody?.allowsRotation = false
        player = Player(body: cube)
        addChild(player.body)
        
        // create ground object
        ground = SKSpriteNode(color: UIColor.gray, size: CGSize(width: frame.width, height: cube.size.height/2))
        ground.position = CGPoint(x: frame.midX, y: frame.midY)
        ground.physicsBody?.restitution = 0.0
        ground.name = "ground"
        
        // create ground physics
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.isDynamic = false
        addChild(ground)
        
        backgroundObjects = createRandomBackroundObjects()
        
        // create obstacles
        let rectangleObstacle = SKSpriteNode(color: UIColor.gray, size: CGSize(width: cube.size.width, height: cube.size.height*1.5))
        rectangleObstacle.position = CGPoint(x: 300 + cube.position.x + 150, y: ground.position.y + 2*ground.size.height)
        rectangleObstacle.physicsBody = SKPhysicsBody(rectangleOf: rectangleObstacle.size)
        rectangleObstacle.physicsBody?.isDynamic = false
        rectangleObstacle.physicsBody?.allowsRotation = false
        rectangleObstacle.name = "rectangle"
        rectangleObstacle.zPosition = 1
        addChild(rectangleObstacle)
        
        let longObstacle = SKSpriteNode(color: UIColor.gray, size: CGSize(width: cube.size.width*4, height: cube.size.height*6))
        longObstacle.position = CGPoint(x: 300 + cube.position.x + 300, y: ground.position.y + 0.5*(longObstacle.size.height + ground.size.height))
        longObstacle.physicsBody = SKPhysicsBody(rectangleOf: longObstacle.size)
        longObstacle.physicsBody?.isDynamic = false
        longObstacle.physicsBody?.allowsRotation = false
        longObstacle.name = "rectangle"
        longObstacle.zPosition = 1
        addChild(longObstacle)

        
        obstacles = [rectangleObstacle, longObstacle]
        
        distanceLabel = SKLabelNode(text: String(player.distance))
        distanceLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 100)
        distanceLabel.fontColor = UIColor.white
        distanceLabel.zPosition = -1
        distanceLabel.fontSize = 32
        addChild(distanceLabel)
        
        // add gesture recognizer
        let swipeUp = UISwipeGestureRecognizer()
        let swipeDown = UISwipeGestureRecognizer()
        
        swipeUp.direction = .up
        swipeDown.direction = .down
        
        view.addGestureRecognizer(swipeUp)
        view.addGestureRecognizer(swipeDown)
        
        swipeUp.addTarget(self, action: #selector(swipeRecognize(sender:)))
        swipeDown.addTarget(self, action: #selector(swipeRecognize(sender:)))
    }
    
    @objc func swipeRecognize(sender: UISwipeGestureRecognizer){
        if sender.state == .recognized {
            switch sender.direction {
            case .up:
                player.direction = .up
            case .down:
                player.direction = .down
            default:
                player.direction = .center
            }
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let _ =  player.body.action(forKey: "RotateCube"){
            
        }
        else{
            player.body.run(SKAction.rotate(byAngle: CGFloat(-CGFloat.pi/2), duration: 0.15), withKey: "RotateCube")
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }

    override func update(_ currentTime: TimeInterval) {
        controlPlayer()
        distanceLabel.text = String(format:"%.1f", player.distance)+"m"
        
        for obstacle in obstacles{
            if obstacle.position.x <= frame.minX - obstacle.size.width{
                obstacle.position.x = frame.maxX + obstacle.size.width
            }
            obstacle.position.x -= 4
        }
        if backgroundObjects.count == 0{
            backgroundObjects = createRandomBackroundObjects()
        }
        for obj in backgroundObjects{
            obj.position.x -= 1
            if obj.frame.maxX <= frame.minX{
                // delete object
                obj.removeFromParent()
                backgroundObjects = backgroundObjects.filter({$0 !== obj})
            }
        }
    }
    func controlPlayer(){
        // control x-axis position
        if player.body.position.x >= frame.midX-2{
            player.body.position.x = frame.midX
            player.distance += 0.05
        }
        else{
            player.body.position.x += 2
            if !player.collideWithObstacle{
                player.distance += 0.1
            }
        }
        // control y-axis position
        switch player.direction {
        case .up:
            player.body.position.y += 6
        case .down:
            player.body.position.y -= 6
        default:
            player.direction = .center
        }
    }
    func createRandomBackroundObjects() -> [SKSpriteNode] {
        let count = Int.random(in: 2..<5)
        var colors = [UIColor.blue, UIColor.black, UIColor.darkGray, UIColor.purple, UIColor.systemOrange]
        let dx = frame.maxX/CGFloat(count)
        var min = frame.minX
        var backgroundObjects = [SKSpriteNode]()
        for _ in 1..<count+1{
            let height = CGFloat.random(in: player.body.size.width..<player.body.size.width*5)
            let width = CGFloat.random(in: player.body.size.width*1.5..<player.body.size.width*4)
            let colorIndex = Int.random(in: 0..<colors.count)
            let backgroundRectangle = SKSpriteNode(color: colors[colorIndex], size: CGSize(width: width, height: height))
            colors.remove(at: colorIndex)
            backgroundRectangle.position = CGPoint(x: frame.maxX + CGFloat.random(in: min..<min + dx), y: ground.position.y + 0.5*(backgroundRectangle.size.height + ground.size.height))
            min += dx
            backgroundRectangle.zPosition = -1
            backgroundRectangle.physicsBody?.isDynamic = false
            backgroundObjects.append(backgroundRectangle)
            addChild(backgroundRectangle)
        }
        return backgroundObjects
    }
    func cubeCollisionBetween(cube: SKNode, object: SKNode) {
        if object.name == "ground" {
            player.canJump = true
        }
        if object.name == "rectangle" {
            if player.canJump{
                player.collideWithObstacle = (abs(player.body.frame.maxX - object.frame.minX)<4)
            }
            player.canJump = true
        }
    }
    func cubeStopCollisionBetween(cube: SKNode, object: SKNode) {
        if object.name == "rectangle" {
            player.collideWithObstacle = false
        }
    }

}
extension GameScene: SKPhysicsContactDelegate{
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "cube" {
            cubeCollisionBetween(cube: contact.bodyA.node!, object: contact.bodyB.node!)
        } else if contact.bodyB.node?.name == "cube" {
            cubeCollisionBetween(cube: contact.bodyB.node!, object: contact.bodyA.node!)
        }
    }
    func didEnd(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "cube" {
            cubeStopCollisionBetween(cube: contact.bodyA.node!, object: contact.bodyB.node!)
        } else if contact.bodyB.node?.name == "cube" {
            cubeStopCollisionBetween(cube: contact.bodyB.node!, object: contact.bodyA.node!)
        }
    }
}

