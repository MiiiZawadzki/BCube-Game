import SpriteKit

class Player{
    init(body: SKSpriteNode) {
        self.body = body
        self.canJump = true
        self.collideWithObstacle = false
        self.distance = 0.0
        self.direction = .center
    }
    var body: SKSpriteNode!
    var canJump: Bool!
    var collideWithObstacle: Bool!
    var distance: Float!
    var direction: Direction!
}
enum Direction {
    case up, down, center
}
