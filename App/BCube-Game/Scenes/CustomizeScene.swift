import SpriteKit
import UIKit

class CustomizeScene: SKScene{
    // game area view
    var gameAreaView: SKView!
    // player object
    var player: Player!
    // color of player cube
    var playerColor: UIColor!
    // array with moving background nodes
    var backgroundObjects: [SKSpriteNode]!
    // array with moving stars nodes
    var stars: [SKSpriteNode]!
    // bool variable that determines whether resources have been loaded
    var resourcesLoaded = false
    // node with background music
    var backgroundMusic: SKAudioNode!
    // rgb sliders
    var redSlider: UISlider!
    var greenSlider: UISlider!
    var blueSlider: UISlider!
    // bool variable that determines whether music have been muted
    var musicSwitch = true
    // label with mute / unmute text
    var musicLabel = SKLabelNode(text: "")
    
    override func didMove(to view: SKView){
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
        cube.physicsBody?.isDynamic = false
        player = Player(body: cube)
        player.body.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(-CGFloat.pi/2), duration: 1.0)))

        
        // create swipe left to go back
        let goBackLabel = SKLabelNode(text: "Swipe left to go back")
        goBackLabel.position = CGPoint(x: frame.midX, y: frame.minY + 100)
        goBackLabel.fontColor = UIColor(named: "TextColor")!
        goBackLabel.zPosition = 2
        goBackLabel.fontSize = 24
        addChild(goBackLabel)
        goBackLabel.run(SKAction.repeatForever(SKAction.sequence([SKAction.scale(to: 1.1, duration: 0.8), SKAction.scale(by: 0.9, duration: 0.8)])))
        
        // add gesture recognizer
        let swipeLeft = UISwipeGestureRecognizer()
        
        swipeLeft.direction = .left
        
        view.addGestureRecognizer(swipeLeft)
        
        swipeLeft.addTarget(self, action: #selector(swipeRecognize(sender:)))
    
        // create rgb sliders
        redSlider = UISlider(frame: CGRect(x: frame.midX, y: player.body.position.y - 150, width: frame.width/2, height: 10))
        redSlider.center.x = view.center.x
        redSlider.tintColor = UIColor.red
        redSlider.maximumValue = 255
        redSlider.minimumValue = 0
        
        greenSlider = UISlider(frame: CGRect(x: frame.midX, y: player.body.position.y - 100, width: frame.width/2, height: 10))
        greenSlider.center.x = view.center.x
        greenSlider.tintColor = UIColor.green
        greenSlider.maximumValue = 255
        greenSlider.minimumValue = 0
        
        blueSlider = UISlider(frame: CGRect(x: frame.midX, y: player.body.position.y - 50, width: frame.width/2, height: 10))
        blueSlider.center.x = view.center.x
        blueSlider.tintColor = UIColor.blue
        blueSlider.maximumValue = 255
        blueSlider.minimumValue = 0
        
        // set value of sliders to actual color
        let color = playerColor.cgColor.components
        blueSlider.value = Float(color![2]*255)
        greenSlider.value = Float(color![1]*255)
        redSlider.value = Float(color![0]*255)
        view.addSubview(redSlider)
        view.addSubview(greenSlider)
        view.addSubview(blueSlider)
        
        // display mute / unmute text
        musicLabel.position = CGPoint(x: frame.midX, y: frame.maxY-50)
        musicLabel.fontColor = UIColor(named: "TextColor")!
        musicLabel.fontSize = 24
        musicLabel.name = "musicLabel"
        addChild(musicLabel)

    }
    // if left swipe is recognized - present start scene
    @objc func swipeRecognize(sender: UISwipeGestureRecognizer){
        if sender.state == .recognized {
            // delete rgb sliders
            view?.subviews.forEach { $0.removeFromSuperview() }
            let scene = StartScene()
            scene.backgroundColor = UIColor(named: "BackgroundColor")!
            scene.size = frame.size
            scene.backgroundObjects = backgroundObjects
            scene.stars = stars
            scene.playerColor = playerColor
            scene.gameAreaView = gameAreaView
            scene.firstRun = false
            scene.musicSwitch = musicSwitch
            gameAreaView.presentScene(scene)
            UserDefaults.standard.set(playerColor.cgColor.components, forKey: "PlayerColor")
        }
    }
    // if mute / unmute music text has beed touched
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch:UITouch = touches.first! as UITouch
        let positionInScene = touch.location(in: self)
        let touchedNode = self.atPoint(positionInScene)
        if let name = touchedNode.name {
            if name == "musicLabel" {
                musicSwitch = !musicSwitch
                
            }
            
        }
        
    }
    override func update(_ currentTime: TimeInterval) {
        // if resources not have been loaded
        if !resourcesLoaded{
            player.body.color = playerColor!
            addChild(player.body)
            resourcesLoaded = true
            if let musicURL = Bundle.main.url(forResource: "introMusic", withExtension: "wav") {
                backgroundMusic = SKAudioNode(url: musicURL)
                addChild(backgroundMusic)
                backgroundMusic.run(SKAction.stop())
                if musicSwitch{
                    backgroundMusic.run(SKAction.changeVolume(to: 0.0, duration: 0))
                    backgroundMusic.run(SKAction.play())
                    backgroundMusic.run(SKAction.changeVolume(to: 0.7, duration: 2.0))
                }
            }
        }
        // mute / unmute music
        if !musicSwitch && backgroundMusic != nil{
            backgroundMusic.run(SKAction.changeVolume(to: 0.0, duration: 0.5))
        }
        else if backgroundMusic != nil{
            backgroundMusic.run(SKAction.play())
            backgroundMusic.run(SKAction.changeVolume(to: 0.7, duration: 0.5))
            
        }
        
        // set playerColor to color picked from rgb sliders
        playerColor = UIColor(red: CGFloat(redSlider.value/255), green: CGFloat(greenSlider.value/255), blue: CGFloat(blueSlider.value/255), alpha: 1)
        player.body.color = playerColor!
        
        // set mute / unmute music text
        musicLabel.text = musicSwitch ? "Tap here to mute music" : "Tap here to unmute music"
    }
}
