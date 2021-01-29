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
        scene.size = gameAreaView.bounds.size
        scene.gameAreaView = gameAreaView
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
