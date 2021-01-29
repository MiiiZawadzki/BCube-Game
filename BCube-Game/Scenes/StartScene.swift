import SpriteKit
import UIKit

class StartScene: SKScene {
    var gameAreaView: SKView!
    var ground:SKSpriteNode!
    var moonObject: SKSpriteNode!
    var stars: [SKSpriteNode]!
    var backgroundObjects: [SKSpriteNode]!
    var player: Player!
    var resourcesLoaded = false
    var sceneSwitch = false
    var firstRun = true
    override func didMove(to view: SKView) {
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)

        // create player object
        let cube = SKSpriteNode(color: UIColor(named: "PlayerColor")!, size: CGSize(width: frame.width/10, height: frame.width/10))
        cube.position = CGPoint(x: frame.midX, y: frame.midY + cube.size.height*4)
        cube.name = "cube"
        
        // create cube physics
        cube.physicsBody = SKPhysicsBody(rectangleOf: cube.size)
        cube.physicsBody?.restitution = 0.5
        cube.zPosition = 1
        cube.physicsBody!.contactTestBitMask = cube.physicsBody!.collisionBitMask
        cube.physicsBody?.allowsRotation = false
        player = Player(body: cube)
        addChild(player.body)
        
        // create ground
        ground = SKSpriteNode(color: UIColor(named: "GroundColor")!, size: CGSize(width: frame.width, height: cube.size.height/2))
        ground.position = CGPoint(x: frame.midX, y: frame.midY)
        ground.physicsBody?.restitution = 0.0
        ground.name = "ground"
        
        // create ground physics
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.isDynamic = false
        addChild(ground)
        
        if firstRun{
            // generate stars
            stars = createRandomStars()
            
            // generate background objects
            backgroundObjects = createRandomBackroundObjects()
        }
        
        // create moon object
        moonObject = SKSpriteNode(color: UIColor(named: "MoonColor")!, size: CGSize(width: 70, height: 70))
        moonObject.position = CGPoint(x: frame.midX + 100, y: frame.maxY - 180)
        moonObject.zPosition = -5
        addChild(moonObject)
        
        // create max distance label
        let distanceLabel = SKLabelNode(text: "High score: \(String(format:"%.1f", UserDefaults.standard.float(forKey: "Highscore")))m")
        distanceLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 40)
        distanceLabel.fontColor = UIColor(named: "TextColor")!
        distanceLabel.zPosition = 2
        distanceLabel.fontSize = 24
        addChild(distanceLabel)
        
        // create tap to play label
        let playLabel = SKLabelNode(text: "Tap to play!")
        playLabel.position = CGPoint(x: frame.midX, y: frame.maxY - (ground.position.y + 0.5*ground.size.height) / 2)
        playLabel.fontColor = UIColor(named: "TextColor")!
        playLabel.zPosition = 2
        playLabel.fontSize = 32
        addChild(playLabel)
        playLabel.run(SKAction.repeatForever(SKAction.sequence([SKAction.scale(to: 1.1, duration: 0.8), SKAction.scale(by: 0.9, duration: 0.8)])))
        
    }
    override func update(_ currentTime: TimeInterval) {
        if sceneSwitch && player.body.position.y >= frame.midY + player.body.size.height*4 - 1{
            let scene = GameScene()
            scene.backgroundColor = UIColor(named: "BackgroundColor")!
            scene.size = frame.size
            scene.stars = stars
            scene.gameAreaView = gameAreaView
            scene.backgroundObjects = backgroundObjects
            gameAreaView.presentScene(scene)
            sceneSwitch = false
        }
        if !resourcesLoaded && !firstRun{
            for star in stars{
                addChild(star)
            }
            for obj in backgroundObjects{
                addChild(obj)
            }
            resourcesLoaded = true
        }
        for star in stars{
            star.position.x -= 0.05
            if star.frame.maxX <= frame.minX{
                star.position.x = frame.maxX + 2
            }
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        player.body.physicsBody = nil
        player.body.run(SKAction.moveTo(y: frame.midY + player.body.size.height*4, duration: 0.15))
        sceneSwitch = true
        
        
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
    func createRandomStars() -> [SKSpriteNode]{
        var result = [SKSpriteNode]()
        for _ in 0..<Int.random(in: 80..<90) {
            let star = SKSpriteNode(color: UIColor(named: "StarColor")!, size: CGSize(width: 1, height: 1))
            star.position = CGPoint(x: CGFloat.random(in: frame.minX..<frame.maxX), y: CGFloat.random(in: (ground.position.y+ground.size.height)..<frame.maxY))
            star.zPosition = -6
            result.append(star)
            addChild(star)
        }
        return result
    }
    func createRandomBackroundObjects() -> [SKSpriteNode] {
        let count = Int.random(in: 2..<5)
        var colors = [UIColor(named: "BackgroundObject1")!, UIColor(named: "BackgroundObject2")!, UIColor(named: "BackgroundObject3")!, UIColor(named: "BackgroundObject4")!, UIColor(named: "BackgroundObject5")!]
        let dx = frame.maxX/CGFloat(count)
        var min = frame.minX + 100
        var backgroundObjects = [SKSpriteNode]()
        for _ in 1..<count+1{
            let height = CGFloat.random(in: player.body.size.width..<player.body.size.width*5)
            let width = CGFloat.random(in: player.body.size.width*1.5..<player.body.size.width*4)
            let colorIndex = Int.random(in: 0..<colors.count)
            let backgroundRectangle = SKSpriteNode(color: colors[colorIndex], size: CGSize(width: width, height: height))
            colors.remove(at: colorIndex)
            backgroundRectangle.position = CGPoint(x: CGFloat.random(in: min..<min + dx), y: ground.position.y + 0.5*(backgroundRectangle.size.height + ground.size.height))
            min += dx
            backgroundRectangle.zPosition = -1
            backgroundRectangle.physicsBody?.isDynamic = false
            backgroundObjects.append(backgroundRectangle)
            addChild(backgroundRectangle)
        }
        return backgroundObjects
    }
}
