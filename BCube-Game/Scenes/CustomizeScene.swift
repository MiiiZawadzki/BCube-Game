import SpriteKit
import UIKit

class CustomizeScene: SKScene, UIColorPickerViewControllerDelegate {
    var gameAreaView: SKView!
    var player: Player!
    var playerColor: UIColor!
    var backgroundObjects: [SKSpriteNode]!
    var stars: [SKSpriteNode]!
    var resourcesLoaded = false
    var backgroundMusic: SKAudioNode!
    var redSlider: UISlider!
    var greenSlider: UISlider!
    var blueSlider: UISlider!
    var musicSwitch = true
    var musicLabel = SKLabelNode(text: "")
    override func didMove(to view: SKView) {
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
        redSlider = UISlider(frame: CGRect(x: frame.width/4, y: player.body.position.y - 150, width: frame.width/2, height: 10))
        redSlider.tintColor = UIColor.red
        redSlider.maximumValue = 255
        redSlider.minimumValue = 0
        
        greenSlider = UISlider(frame: CGRect(x: frame.width/4, y: player.body.position.y - 100, width: frame.width/2, height: 10))
        greenSlider.tintColor = UIColor.green
        greenSlider.maximumValue = 255
        greenSlider.minimumValue = 0
        
        blueSlider = UISlider(frame: CGRect(x: frame.width/4, y: player.body.position.y - 50, width: frame.width/2, height: 10))
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
        
        
        musicLabel.position = CGPoint(x: frame.midX, y: frame.maxY-50)
        musicLabel.fontColor = UIColor(named: "TextColor")!
        musicLabel.fontSize = 24
        musicLabel.name = "musicLabel"
        addChild(musicLabel)

    }
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
        if !resourcesLoaded{
            player.body.color = playerColor!
            addChild(player.body)
            resourcesLoaded = true
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
        if !musicSwitch && backgroundMusic != nil{
            backgroundMusic.run(SKAction.changeVolume(to: 0.0, duration: 0.5))
        }
        else if backgroundMusic != nil{
            backgroundMusic.run(SKAction.changeVolume(to: 0.7, duration: 0.5))
            
        }
        playerColor = UIColor(red: CGFloat(redSlider.value/255), green: CGFloat(greenSlider.value/255), blue: CGFloat(blueSlider.value/255), alpha: 1)
        player.body.color = playerColor!
        musicLabel.text = musicSwitch ? "Tap here to mute music" : "Tap here to unmute music"
    }
}
