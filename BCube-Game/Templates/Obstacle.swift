import SpriteKit

class Obstacle{
    init(body: SKSpriteNode) {
        self.body = body
        self.speed = 4.0
    }
    var body: SKSpriteNode!
    var orientation: Orientation!
    var speed: CGFloat!
}
enum Orientation{
    case top, bottom, center
}
