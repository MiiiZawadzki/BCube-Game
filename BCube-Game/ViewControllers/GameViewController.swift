import UIKit
import SpriteKit

class GameViewController: UIViewController {

    @IBOutlet weak var gameAreaView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create scene to cover status bar
        let scene2 = EmptyScene()
        scene2.backgroundColor = UIColor(named: "BackgroundColor")!
        scene2.scaleMode = .aspectFill
        scene2.size = view.bounds.size
        (view as! SKView).presentScene(scene2)
        

        // create new start scene
        let scene = StartScene()
        scene.backgroundColor = UIColor(named: "BackgroundColor")!
        // if user set the player color use this color
        if UserDefaults.standard.array(forKey: "PlayerColor") != nil{
            let color = UserDefaults.standard.array(forKey: "PlayerColor")!
            scene.playerColor = UIColor(red: color[0] as! CGFloat, green: color[1] as! CGFloat, blue: color[2] as! CGFloat, alpha: 1.0)
        }
        else{
            scene.playerColor = UIColor(named: "PlayerColor")!
        }
        scene.size = gameAreaView.bounds.size
        scene.gameAreaView = gameAreaView
        gameAreaView.presentScene(scene)

        gameAreaView.ignoresSiblingOrder = true
    }
    
    // hide status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
