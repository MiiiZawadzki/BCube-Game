import SpriteKit

class PowerUp{
    init(body: SKSpriteNode) {
        self.body = body
        self.canSpawn = false
        self.collected = false
        self.chanceRange = 1...25
        self.luckyNumber = 14
    }
    var body: SKSpriteNode!
    var canSpawn: Bool!
    var collected: Bool!
    var chanceRange: ClosedRange<Int>!
    var luckyNumber: Int!
}
