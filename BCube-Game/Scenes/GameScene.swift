//
//  GameScene.swift
//  BCube-Game
//
//  Created by Michał on 06/01/2021.
//

import SpriteKit

class GameScene: SKScene {
    
    var player: Player!
    var distanceLabel: SKLabelNode!
    var ground:SKSpriteNode!
    var obstacles: [SKSpriteNode]!
    var backgroundObjects: [SKSpriteNode]!
    
    override func didMove(to view: SKView) {
        // set world physics
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -6)
        
        // create player object
        let cube = SKSpriteNode(color: UIColor.red, size: CGSize(width: frame.width/10, height: frame.width/10))
        cube.position = CGPoint(x: frame.midX, y: frame.midY + cube.size.height*4)
        cube.name = "cube"
        
        // create cube physics
        cube.physicsBody = SKPhysicsBody(rectangleOf: cube.size)
        cube.physicsBody?.restitution = 0.05
        cube.physicsBody?.angularDamping = 0.0
        cube.zPosition = 1
        cube.physicsBody!.contactTestBitMask = cube.physicsBody!.collisionBitMask
        player = Player(body: cube)
        addChild(player.body)
        
        // create ground object
        ground = SKSpriteNode(color: UIColor.gray, size: CGSize(width: frame.width, height: cube.size.height/2))
        ground.position = CGPoint(x: frame.midX, y: frame.midY)
        ground.name = "ground"
        
        // create ground physics
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.isDynamic = false
        addChild(ground)
        
        // create obstacles
        let rectangleObstacle = SKSpriteNode(color: UIColor.gray, size: CGSize(width: cube.size.width, height: cube.size.height*1.5))
        rectangleObstacle.position = CGPoint(x: cube.position.x + 150, y: ground.position.y + 2*ground.size.height)
        rectangleObstacle.physicsBody = SKPhysicsBody(rectangleOf: rectangleObstacle.size)
        rectangleObstacle.physicsBody?.isDynamic = false
        rectangleObstacle.physicsBody?.allowsRotation = false
        rectangleObstacle.name = "rectangle"
        rectangleObstacle.zPosition = 1
        addChild(rectangleObstacle)
        
        // create background
        let backgroundBigRectangle = SKSpriteNode(color: UIColor.darkGray, size: CGSize(width: cube.size.width*2, height: cube.size.height*3))
        backgroundBigRectangle.position = CGPoint(x: cube.position.x + 150, y: ground.position.y + 0.5*(backgroundBigRectangle.size.height + ground.size.height))
        backgroundBigRectangle.zPosition = -1
        backgroundBigRectangle.physicsBody?.isDynamic = false
        addChild(backgroundBigRectangle)
        
        obstacles = [rectangleObstacle]
        backgroundObjects = [backgroundBigRectangle]
        
        distanceLabel = SKLabelNode(text: String(player.distance))
        distanceLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 100)
        distanceLabel.fontColor = UIColor.white
        distanceLabel.zPosition = -1
        distanceLabel.fontSize = 32
        addChild(distanceLabel)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if player.canJump{
//            cube.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 40.0))
            player.body.run(SKAction.moveTo(y:player.body.position.y+150, duration: 0.3), withKey: "JumpCube")
            player.canJump = false
        }
        if let _ =  player.body.action(forKey: "RotateCube"){
            player.body.removeAction(forKey: "RotateCube")
        }
        else if !player.canJump{
            player.body.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(-CGFloat.pi/2), duration: 0.3)), withKey: "RotateCube")
        }
        
        
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        player.body.removeAction(forKey: "RotateCube")
    }

    override func update(_ currentTime: TimeInterval) {
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
        distanceLabel.text = String(format:"%.1f", player.distance)+"m"
        
        for obstacle in obstacles{
            if obstacle.position.x <= frame.minX - obstacle.size.width{
                obstacle.position.x = frame.maxX + obstacle.size.width
            }
            obstacle.position.x -= 4
        }
        for obj in backgroundObjects{
            if obj.position.x <= frame.minX - obj.size.width{
                obj.position.x = frame.maxX + obj.size.width
            }
            obj.position.x -= 1
        }
        
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

