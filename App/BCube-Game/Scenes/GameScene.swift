import SpriteKit
import UIKit

class GameScene: SKScene {
    // player object
    var player: Player!
    // color of player cube
    var playerColor: UIColor!
    // distance label placed at the top of the screen
    var distanceLabel: SKLabelNode!
    // ground node
    var ground:SKSpriteNode!
    // current obstacle object
    var obstacle: Obstacle!
    // moon node
    var moonObject: SKSpriteNode!
    // array with moving stars nodes
    var stars: [SKSpriteNode]!
    // array with moving background nodes
    var backgroundObjects: [SKSpriteNode]!
    // speed of the buildings
    var backgroundSpeed:CGFloat = 1.0
    // node with background music
    var backgroundMusic: SKAudioNode!
    // bool variable that determines whether resources have been loaded
    var resourcesLoaded = false
    // bool variable that control if game is over
    var gameover = false
    // game area view
    var gameAreaView: SKView!
    // powerUp object
    var powerUp: PowerUp!
    // labels that shows up when the game is over
    var gameoverLabel = SKLabelNode(text: "GAME OVER!")
    var tapToBackLabel = SKLabelNode(text: "tap to go back to menu")
    // bool variable that determines whether music have been muted
    var musicSwitch = true
    // hint node that shows where next obstacle will be placed
    var hint = SKSpriteNode(color: UIColor(named: "HintColor")!, size: CGSize(width: 5, height: 5))
    
    override func didMove(to view: SKView){
        // create player object
        let cube = SKSpriteNode(color: UIColor(named: "PlayerColor")!, size: CGSize(width: frame.width/10, height: frame.width/10))
        cube.position = CGPoint(x: frame.midX, y: frame.midY + cube.size.height*4)
        cube.name = "cube"

        // create cube physics
        cube.physicsBody = SKPhysicsBody(rectangleOf: cube.size)
        cube.physicsBody?.restitution = 0.0
        cube.zPosition = 2
        cube.physicsBody!.contactTestBitMask = cube.physicsBody!.collisionBitMask
        cube.physicsBody?.allowsRotation = false
        
        // create player object
        player = Player(body: cube)

        // set world physics
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        // create rect bigger than frame size
        let newRect = CGRect(x: frame.minX - player.body.size.width-2, y: frame.minY, width: frame.width+player.body.size.width+2, height: frame.height)
        physicsBody = SKPhysicsBody(edgeLoopFrom: newRect)

        
        // create ground object
        ground = SKSpriteNode(color: UIColor(named: "GroundColor")!, size: CGSize(width: frame.width, height: cube.size.height/2))
        ground.position = CGPoint(x: frame.midX, y: frame.midY)
        ground.physicsBody?.restitution = 0.0
        ground.name = "ground"
        
        // create ground physics
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.isDynamic = false
        addChild(ground)
        
        // create powerUp Object
        powerUp = PowerUp(body: SKSpriteNode(color: UIColor(named: "PowerUpColor")!, size: CGSize(width: 10, height: 10)))
        // create powerUp physics
        powerUp.body.physicsBody = SKPhysicsBody(rectangleOf: powerUp.body.size)
        powerUp.body.physicsBody?.isDynamic = false
        powerUp.body.name = "powerUp"
        // create powerUp animations
        powerUp.body.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(-CGFloat.pi/2), duration: 0.666)))
        powerUp.body.run(SKAction.repeatForever(SKAction.sequence([SKAction.colorize(with: playerColor, colorBlendFactor: 1, duration: 0.333),SKAction.colorize(with: UIColor(named: "PowerUpColor")!, colorBlendFactor: 1, duration: 0.333)])))
        
        // generate obstacles
        obstacle = createRandomObstacle()
        
        // create distance label
        distanceLabel = SKLabelNode(text: String(player.distance))
        distanceLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 40)
        distanceLabel.fontColor = UIColor(named: "TextColor")!
        distanceLabel.zPosition = 2
        distanceLabel.fontSize = 32
        addChild(distanceLabel)
        
        // create moon object
        moonObject = SKSpriteNode(color: UIColor(named: "MoonColor")!, size: CGSize(width: 70, height: 70))
        moonObject.position = CGPoint(x: frame.midX + 100, y: frame.maxY - 180)
        moonObject.zPosition = -5
        addChild(moonObject)
        
        // add hint square
        hint.zPosition = 2
        addChild(hint)
        
        // create game over label
        gameoverLabel.position = CGPoint(x: frame.midX, y: frame.maxY - (ground.position.y + 0.5*ground.size.height) / 2)
        gameoverLabel.fontColor = UIColor(named: "TextColor")!
        gameoverLabel.zPosition = 2
        gameoverLabel.fontSize = 32
        addChild(gameoverLabel)
        
        // tap to go back label
        tapToBackLabel.position = CGPoint(x: frame.midX, y: gameoverLabel.position.y - 30)
        tapToBackLabel.fontColor = UIColor(named: "TextColor")!
        tapToBackLabel.zPosition = 2
        tapToBackLabel.fontSize = 16
        addChild(tapToBackLabel)
        
        tapToBackLabel.run(SKAction.repeatForever(SKAction.sequence([SKAction.scale(to: 1.1, duration: 0.8), SKAction.scale(by: 0.9, duration: 0.8)])))
        
        // hide labels until game is over
        gameoverLabel.isHidden = true
        tapToBackLabel.isHidden = true
        
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
    
    // recognize swipe direction and set player direction
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
        player.direction = .center
        if let _ =  player.body.action(forKey: "RotateCube"){
            
        }
        else{
            player.body.run(SKAction.rotate(byAngle: CGFloat(-CGFloat.pi/2), duration: 0.15), withKey: "RotateCube")
        }
        
        // present start scene
        if gameover{
            let scene = StartScene()
            scene.backgroundColor = UIColor(named: "BackgroundColor")!
            scene.size = frame.size
            scene.gameAreaView = gameAreaView
            scene.backgroundObjects = backgroundObjects
            scene.stars = stars
            scene.firstRun = false
            scene.musicSwitch = musicSwitch
            scene.playerColor = playerColor
            gameAreaView.presentScene(scene)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // if resources not have been loaded
        if !resourcesLoaded{
            player.body.color = playerColor!
            addChild(player.body)
            for star in stars{
                addChild(star)
            }
            for obj in backgroundObjects{
                addChild(obj)
            }
            resourcesLoaded = true
            if musicSwitch{
                if let musicURL = Bundle.main.url(forResource: "mainMusic", withExtension: "wav") {
                    backgroundMusic = SKAudioNode(url: musicURL)
                    addChild(backgroundMusic)
                    backgroundMusic.run(SKAction.stop())
                    backgroundMusic.run(SKAction.changeVolume(to: 0.0, duration: 0))
                    backgroundMusic.run(SKAction.play())
                    backgroundMusic.run(SKAction.changeVolume(to: 0.7, duration: 0.1))
                }
            }
        }
        
        // set hint position
        hint.isHidden = false
        let midH = frame.maxY - (ground.position.y + 0.5*ground.size.height) / 2
        switch obstacle.orientation {
        case .bottom:
            hint.position = CGPoint(x: frame.size.width - 10, y: (ground.position.y + 0.5*ground.size.height) + 10)
        case .center:
            hint.position = CGPoint(x: frame.size.width - 10, y: midH)
        case .top:
            hint.position = CGPoint(x: frame.size.width - 10, y: frame.maxY - 10)
        default:
            hint.position = CGPoint(x: frame.size.width - 10, y: ground.position.y + 100)
        }
        if obstacle.body.frame.minX <= frame.midX{
            hint.isHidden = true
        }
        
        // Update distance label
        distanceLabel.text = String(format:"%.1f", player.distance)+"m"
        
        // if player cube position is lower than minX - slow down background and obstacle and set game over
        if player.body.position.x + player.body.size.width/2 < frame.minX{
            var dx1 = min(obstacle.speed, backgroundSpeed)
            var dx2 = dx1/max(obstacle.speed, backgroundSpeed) * dx1
            dx1 /= 3
            dx2 /= 3
            if obstacle.speed > 0{
                obstacle.speed -= dx1
            }
            if backgroundSpeed > 0{
                backgroundSpeed -= dx2
            }
            gameOver()
        }
        // while game is running
        else{
            controlPlayer()
            // increase speed every 10 meters
            obstacle.speed = CGFloat(Int(player.distance / 10))/5 + 4
            backgroundSpeed = CGFloat(Int(player.distance / 10)/2)/5 + 1
        }
        
        // check if obstacle left the screen
        if obstacle.body.frame.maxX <= frame.minX{
            obstacle.body.removeFromParent()
            obstacle = createRandomObstacle()
        }
        
        // move obstacle
        obstacle.body.position.x -= obstacle.speed
        
        // if powerUp can spawn set its position
        if powerUp.canSpawn{
            var powerUpPos: CGFloat = 0
            powerUp.body.removeFromParent()
            switch obstacle.orientation {
            case .bottom:
                powerUpPos = frame.maxY - (frame.maxY - obstacle.body.frame.maxY) / 2
            case .center:
                let i = Int.random(in: 0...1)
                if i == 1{
                    powerUpPos = frame.maxY - (frame.maxY - obstacle.body.frame.maxY) / 2
                }
                else{
                    powerUpPos = ground.frame.maxY + (obstacle.body.frame.minY - ground.frame.maxY) / 2
                }
            case .top:
                powerUpPos = ground.frame.maxY + (obstacle.body.frame.minY - ground.frame.maxY) / 2
            default:
                powerUpPos = CGFloat.random(in: frame.maxY...obstacle.body.frame.maxY)
            }
            powerUp.body.position = CGPoint(x: obstacle.body.position.x, y: powerUpPos)
            addChild(powerUp.body)
            powerUp.canSpawn = false
        }
        
        // move powerUp with obstacle
        powerUp.body.position.x -= obstacle.speed

        
        // check if all background objects left the screen
        if backgroundObjects.count == 0{
            backgroundObjects = createRandomBackroundObjects()
        }
        
        // iterate through all background objects
        for obj in backgroundObjects{
            // move background objects
            obj.position.x -= backgroundSpeed
            
            // check if background object left the screen
            if obj.frame.maxX <= frame.minX{
                // delete object
                obj.removeFromParent()
                backgroundObjects = backgroundObjects.filter({$0 !== obj})
            }
        }
        
        // move stars
        for star in stars{
            star.position.x -= 0.05
            if star.frame.maxX <= frame.minX{
                star.position.x = frame.maxX + 2
            }
        }
    }

    func controlPlayer(){
        // control x-axis position
        if player.body.position.x >= frame.midX-2{
            player.body.position.x = frame.midX
            player.distance += Float(0.01*obstacle.speed)
        }
        // speed up to go to center position
        else{
            player.body.position.x += 2
            if !player.collideWithObstacle{
                player.distance += Float(0.02*obstacle.speed)
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
    
    func gameOver(){
        gameover = true
        if UserDefaults.standard.float(forKey: "Highscore") < player.distance{
            UserDefaults.standard.set(player.distance, forKey: "Highscore")
        }
        gameoverLabel.isHidden = false
        tapToBackLabel.isHidden = false
        if musicSwitch{
            backgroundMusic.run(SKAction.changeVolume(to: 0.0, duration: 1.0))
        }

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
            backgroundRectangle.position = CGPoint(x: frame.maxX + CGFloat.random(in: min..<min + dx), y: ground.position.y + 0.5*(backgroundRectangle.size.height + ground.size.height))
            
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
    
    func createRandomObstacle() -> Obstacle {
        // choose orientation on the screen (bottom, top, center)
        let orientation = Int.random(in: 0..<3)
        
        // choose obstacle height and width
        let maxHeight = frame.maxY - ground.position.y - 2*player.body.size.height
        let height = CGFloat.random(in: player.body.size.width*2..<maxHeight)
        let width = CGFloat.random(in: player.body.size.width*1.5..<player.body.size.width*3)
        
        // create obstacle
        let object = SKSpriteNode(color: UIColor(named: "ObstacleColor")!, size: CGSize(width: width, height: height))
        let obstacleObject = Obstacle(body: object)
        
        // set obstacle properties
        obstacleObject.body.name = "obstacle"
        obstacleObject.body.zPosition = 1
        
        // set orientation
        if orientation == 0{
            obstacleObject.orientation = .bottom
            obstacleObject.body.position = CGPoint(x: frame.maxX + 100, y: ground.position.y + 0.5*(obstacleObject.body.size.height + ground.size.height))
        }
        if orientation == 1{
            obstacleObject.orientation = .top
            obstacleObject.body.position = CGPoint(x: frame.maxX + 100, y: frame.maxY - 0.5*object.size.height)
        }
        if orientation == 2{
            obstacleObject.orientation = .center
            obstacleObject.body.size.height = player.body.size.height*CGFloat.random(in: 2...5)
            obstacleObject.body.position = CGPoint(x: frame.maxX + 100, y: ground.position.y + (frame.maxY - ground.position.y)/2)
        }
        
        // set physics
        if !powerUp.collected{
            obstacleObject.body.physicsBody = SKPhysicsBody(rectangleOf: obstacleObject.body.size)
            obstacleObject.body.physicsBody?.isDynamic = false
            obstacleObject.body.physicsBody?.allowsRotation = false
        }
        // add obstacle
        addChild(obstacleObject.body)
        let powerUpChance = Int.random(in: powerUp.chanceRange)
        powerUp.canSpawn = (powerUpChance == powerUp.luckyNumber && !powerUp.collected)
        return obstacleObject
    }
    
    func createRandomStars() -> [SKSpriteNode]{
        // result array
        var result = [SKSpriteNode]()
        
        // create stars
        for _ in 0..<Int.random(in: 80..<90) {
            let star = SKSpriteNode(color: UIColor(named: "StarColor")!, size: CGSize(width: 1, height: 1))
            star.position = CGPoint(x: CGFloat.random(in: frame.minX..<frame.maxX), y: CGFloat.random(in: (ground.position.y+ground.size.height)..<frame.maxY))
            star.zPosition = -6
            result.append(star)
            addChild(star)
        }
        return result
    }
    
    func cubeCollisionBetween(cube: SKNode, object: SKNode) {
        if object.name == "ground" {
            player.canJump = true
        }
        if object.name == "obstacle" {
            if player.canJump{
                player.collideWithObstacle = (abs(player.body.frame.maxX - object.frame.minX)<4)
            }
            player.canJump = true
        }
        if object.name == "powerUp" {
            powerUpPlayer()
            powerUp.body.removeFromParent()
        }
    }
    
    func cubeStopCollisionBetween(cube: SKNode, object: SKNode) {
        if object.name == "obstacle" {
            player.collideWithObstacle = false
        }
    }
    
    func powerUpPlayer(){
        powerUp.collected = true
        self.run(SKAction.colorize(with: UIColor(named: "BackgroundLightColor")!, colorBlendFactor: 1.0, duration: 1.0))
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.powerUp.collected = false
            self.run(SKAction.colorize(with: UIColor(named: "BackgroundColor")!, colorBlendFactor: 1.0, duration: 1.0))
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

