import SpriteKit
import UIKit

class StartScene: SKScene {
    // game area view
    var gameAreaView: SKView!
    // ground node
    var ground:SKSpriteNode!
    // moon node
    var moonObject: SKSpriteNode!
    // array with moving stars nodes
    var stars: [SKSpriteNode]!
    // array with moving background nodes
    var backgroundObjects: [SKSpriteNode]!
    // node with background music
    var backgroundMusic: SKAudioNode!
    // player object
    var player: Player!
    // color of player cube
    var playerColor: UIColor!
    // bool variable that determines whether resources have been loaded
    var resourcesLoaded = false
    // bool variable that determines if game has started
    var gameSceneSwitch = false
    // bool variable that determines if user selected customize
    var customizeSceneSwitch = false
    // bool variable that determines if scene is loaded first time
    var firstRun = true
    // bool variable that determines whether music have been muted
    var musicSwitch = true
    
    override func didMove(to view: SKView) {
        // create world physics
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
            
            if musicSwitch{
                if let musicURL = Bundle.main.url(forResource: "introMusic", withExtension: "wav") {
                    backgroundMusic = SKAudioNode(url: musicURL)
                    addChild(backgroundMusic)
                    backgroundMusic.run(SKAction.stop())
                    backgroundMusic.run(SKAction.changeVolume(to: 0.0, duration: 0))
                    backgroundMusic.run(SKAction.play())
                    backgroundMusic.run(SKAction.changeVolume(to: 0.7, duration: 2.0))
                }
            }
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
        
        // create swipe up to play label
        let playLabel = SKLabelNode(text: "Swipe up to play!")
        playLabel.position = CGPoint(x: frame.midX, y: frame.maxY - (ground.position.y + 0.5*ground.size.height) / 2)
        playLabel.fontColor = UIColor(named: "TextColor")!
        playLabel.zPosition = 2
        playLabel.fontSize = 32
        addChild(playLabel)
        playLabel.run(SKAction.repeatForever(SKAction.sequence([SKAction.scale(to: 1.1, duration: 0.8), SKAction.scale(by: 0.9, duration: 0.8)])))
        
        // create swpie down to customize
        let customizeLabel = SKLabelNode(text: "Swipe down to customize")
        customizeLabel.position = CGPoint(x: frame.midX, y: frame.minY + (ground.position.y + 0.5*ground.size.height) / 2)
        customizeLabel.fontColor = UIColor(named: "TextColor")!
        customizeLabel.zPosition = 2
        customizeLabel.fontSize = 24
        addChild(customizeLabel)

        
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
    
    // recognize swipe direction and set proper bool variable (game / customize)
    @objc func swipeRecognize(sender: UISwipeGestureRecognizer){
        if sender.state == .recognized {
            switch sender.direction {
            case .up:
                if musicSwitch{
                    backgroundMusic.run(SKAction.changeVolume(to: 0.0, duration: 0.5))
                }
                player.body.physicsBody = nil
                player.body.run(SKAction.moveTo(y: frame.midY + player.body.size.height*4, duration: 0.15))
                gameSceneSwitch = true
            case .down:
                if musicSwitch{
                    backgroundMusic.run(SKAction.changeVolume(to: 0.0, duration: 0.5))
                }
                ground.physicsBody?.isDynamic = true
                customizeSceneSwitch = true
            default:
                print("")
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // set player color
        if let color = playerColor{
            player.body.color = color
        }
        // present game scene if gameSceneSwitch has been set to true and animation ended
        if gameSceneSwitch && player.body.position.y >= frame.midY + player.body.size.height*4 - 1{
            let scene = GameScene()
            scene.backgroundColor = UIColor(named: "BackgroundColor")!
            scene.size = frame.size
            scene.stars = stars
            scene.gameAreaView = gameAreaView
            scene.playerColor = playerColor
            scene.backgroundObjects = backgroundObjects
            scene.musicSwitch = musicSwitch
            gameAreaView.presentScene(scene)
            gameSceneSwitch = false
        }
        // present customize scene if gameSceneSwitch has been set to true and animation ended
        if customizeSceneSwitch && player.body.position.y <= frame.midY - player.body.size.height*4 + 1{
            let scene = CustomizeScene()
            scene.size = frame.size
            scene.backgroundColor = UIColor(named: "BackgroundColor")!
            scene.playerColor = playerColor
            scene.gameAreaView = gameAreaView
            scene.stars = stars
            scene.musicSwitch = musicSwitch
            scene.backgroundObjects = backgroundObjects
            gameAreaView.presentScene(scene)
            customizeSceneSwitch = false
        }
        // if resources not have been loaded and it is not first run
        if !resourcesLoaded && !firstRun{
            player.body.color = playerColor
            for star in stars{
                addChild(star)
            }
            for obj in backgroundObjects{
                addChild(obj)
            }
            if musicSwitch{
                if let musicURL = Bundle.main.url(forResource: "introMusic", withExtension: "wav") {
                    backgroundMusic = SKAudioNode(url: musicURL)
                    addChild(backgroundMusic)
                    backgroundMusic.run(SKAction.stop())
                    backgroundMusic.run(SKAction.changeVolume(to: 0.0, duration: 0))
                    backgroundMusic.run(SKAction.play())
                    backgroundMusic.run(SKAction.changeVolume(to: 0.7, duration: 2.0))
                }
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
        // result array
        var backgroundObjects = [SKSpriteNode]()
        
        // number of background objects
        let count = Int.random(in: 2..<5)
        
        // array from which the colors are drawn
        var colors = [UIColor(named: "BackgroundObject1")!, UIColor(named: "BackgroundObject2")!, UIColor(named: "BackgroundObject3")!, UIColor(named: "BackgroundObject4")!, UIColor(named: "BackgroundObject5")!]
        
        // divide screen into count parts
        let dx = frame.maxX/CGFloat(count)
        
        // minimal x-position
        var min = frame.minX + 100
        
        // create background objects
        for _ in 0..<count{
            
            // choose backround object height and width
            let height = CGFloat.random(in: player.body.size.width..<player.body.size.width*5)
            let width = CGFloat.random(in: player.body.size.width*1.5..<player.body.size.width*4)
            
            // choose color index
            let colorIndex = Int.random(in: 0..<colors.count)
            
            // create background object
            let backgroundRectangle = SKSpriteNode(color: colors[colorIndex], size: CGSize(width: width, height: height))
            
            // remove used color
            colors.remove(at: colorIndex)
            
            // set position of the background object on the screen
            backgroundRectangle.position = CGPoint(x: CGFloat.random(in: min..<min + dx), y: ground.position.y + 0.5*(backgroundRectangle.size.height + ground.size.height))
            
            // increase minmal x-position
            min += dx
            
            // set z-position
            backgroundRectangle.zPosition = -1
            
            // set physics
            backgroundRectangle.physicsBody?.isDynamic = false
            
            // add background object
            backgroundObjects.append(backgroundRectangle)
            addChild(backgroundRectangle)
        }
        return backgroundObjects
    }
}
