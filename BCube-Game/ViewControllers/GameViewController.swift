//
//  GameViewController.swift
//  BCube-Game
//
//  Created by Michał on 06/01/2021.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    @IBOutlet weak var gameAreaView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    // Load the SKScene from 'GameScene.sks'
    let scene = GameScene()
        scene.backgroundColor = UIColor(named: "BackgroundColor")!
    // Set the scale mode to scale to fit the window
    scene.scaleMode = .aspectFill
    scene.size = gameAreaView.bounds.size
    gameAreaView.presentScene(scene)
        

    gameAreaView.ignoresSiblingOrder = true

//    gameAreaView.showsFPS = true
//    gameAreaView.showsNodeCount = true
//    gameAreaView.showsPhysics = true
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
