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
        
        
        // create new game scene
        let scene = GameScene()
        scene.backgroundColor = UIColor(named: "BackgroundColor")!
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        scene.size = gameAreaView.bounds.size
        gameAreaView.presentScene(scene)
            

        gameAreaView.ignoresSiblingOrder = true

        gameAreaView.showsFPS = true
        gameAreaView.showsNodeCount = true
        gameAreaView.showsPhysics = true
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
