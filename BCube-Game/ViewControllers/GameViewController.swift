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
    let scene = GameScene(size: gameAreaView.bounds.size)
    // Set the scale mode to scale to fit the window
    scene.scaleMode = .aspectFill
    
    gameAreaView.presentScene(scene)


    gameAreaView.ignoresSiblingOrder = true

    gameAreaView.showsFPS = true
    gameAreaView.showsNodeCount = true
    gameAreaView.showsPhysics = true
    }
}
