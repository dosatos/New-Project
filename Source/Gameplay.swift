//class Gameplay: CCNode, CCPhysicsCollisionDelegate {
//    //Interface
//    enum gameState {
//        case Play, Pause, Mainscene, Gameover
//    }
//    
//    weak var energyBar: CCSprite!
//    var timeLeft: Float = 5 {
//        didSet {
//            timeLeft = max(min(timeLeft, 10), 0)
//            energyBar.scaleX = timeLeft / Float (10)
//        }
//    }
//    
//    weak var scoreLabel : CCLabelTTF!
//    weak var yourScore : CCLabelTTF!
//    weak var bestScore : CCLabelTTF!
//    var points : NSInteger = 0
//    weak var gameOverScreen : CCNodeColor!
//    
//    var mainscene: MainScene?
//    
//    
//    //Environment
//    weak var water1: CCNodeGradient!
//    weak var water2: CCNodeGradient!
//    var waterArray: [CCNodeGradient!] = []
//    
//    //Physics
//    weak var gamePhysicsNode: CCPhysicsNode!
//    var scrollSpeed: CGFloat = 19
//    
//    //Character
//    weak var character: Character!
//    var characterLevel: CGFloat = 160
//    var divingSpeed: CGFloat = 870
//    
//    //Fish
//    var prevPosition: CGFloat = 500
//    var nextPosition: CGFloat!
//    var fishLevel: CGFloat = 40
//    var fishArray: [CCSprite!] = []
//    
//    func didLoadFromCCB() {
//        gamePhysicsNode.collisionDelegate = self
//        character.position.y = characterLevel
//        userInteractionEnabled = true
//        waterArray.append(water1)
//        waterArray.append(water2)
//    }
//    
//    func spawnFish() {
//        let fish = CCBReader.load("Fish") as! Fish
//        var randomX = CGFloat(500) + CGFloat(arc4random_uniform(300))
//        nextPosition = prevPosition + randomX
//        fish.position = ccp(nextPosition, fishLevel)
//        prevPosition = fish.position.x // for the next fish
//        gamePhysicsNode.addChild(fish)
//        fishArray.append(fish)
//    }
//    
//    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
//        character.physicsBody.velocity = ccp(0, -divingSpeed)
//    }
//    
//    override func update(delta: CCTime) {
//        let velocityY = clampf(Float(character.physicsBody.velocity.y), -Float(divingSpeed), Float(divingSpeed))
//        
//        if character.position.y <= fishLevel {
//            character.position.y = fishLevel
//            character.physicsBody.velocity = ccp(0, divingSpeed)
//        } else if character.position.y >= characterLevel {
//            character.position.y = characterLevel
//        }
//        
//        spawnFish()
//        
//        for fish in fishArray {
//            if CGFloat(fish.position.x) < -fish.contentSize.width {
//                fishArray.removeAtIndex(0)
//            }
//        }
//        
//        gamePhysicsNode.position.x -= scrollSpeed
//        character.position.x += scrollSpeed
//        
////        for water in waterArray {
////            water.position.x = water.position.x - scrollSpeed * CGFloat(delta)
////            if water.position.x <= -water.contentSize.width {
////                water.position.x += water.contentSize.width * 2
////            }
////        }
//        
////        for water in waterArray {
////            let waterWorldPosition = gamePhysicsNode.convertToWorldSpace(water.position)
////            let waterScreenPosition = convertToWorldSpace(waterWorldPosition)
////            if waterScreenPosition.x < -water.contentSize.width {
////                water.position = ccp(water.position.x + water.contentSize.width * 2, water.position.y)
////            }
////        }
//        for water in waterArray {
//            let waterWorldPosition = gamePhysicsNode.convertToWorldSpace(water.position)
//            let waterScreenPosition = convertToNodeSpace(waterWorldPosition)
//            if waterScreenPosition.x <= (-water.contentSize.width) {
//                water.position = ccp(water.position.x + water.contentSize.width * 2, water.position.y)
//            }
//        }
//        
//        timeLeft -= Float(delta)
//        if timeLeft <= 0 {
//            gameOver()
//        }
//        
//        println(GameStatistics.bestPoints)
//    }
//    
//    func restart() {
//        let scene = CCBReader.loadAsScene("Gameplay")
//        CCDirector.sharedDirector().presentScene(scene)
//    }
//
//    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, fish: Fish!, character: Character!) -> Bool {
//        fish.removeFromParent()
//        timeLeft += 0.65
//        points++
//        scoreLabel.string = String(points)
//        return true
//    }
//    
//    func gameOver() {
//        paused = true
//        gameOverScreen.visible = true
//        yourScore.string = scoreLabel.string
//        if points > GameStatistics.bestPoints {
//            GameStatistics.bestPoints = points
//        }
//        bestScore.string = String(GameStatistics.bestPoints)
//        
//        scoreLabel.visible = false
//    }
//}
//
