class Gameplay: CCNode, CCPhysicsCollisionDelegate {
    //Interface
    enum gameState {
        case Play, Pause, Mainscene, Gameover
    }
    
    weak var energyBar: CCSprite!
    var timeLeft: Float = 5 {
        didSet {
            timeLeft = max(min(timeLeft, 10), 0)
            energyBar.scaleX = timeLeft / Float (10)
        }
    }
    
    weak var scoreLabel : CCLabelTTF!
    weak var yourScore : CCLabelTTF!
    weak var bestScore : CCLabelTTF!
    var points : NSInteger = 0
    weak var gameOverScreen : CCNodeColor!
    
    var mainscene: MainScene?
    
    
    //Environment
    weak var water1: CCNodeGradient!
    weak var water2: CCNodeGradient!
    var waterArray: [CCNodeGradient!] = []
    
    //Physics
    weak var gamePhysicsNode: CCPhysicsNode!
    var scrollSpeed: CGFloat = 10
    
    //Character
    weak var character: Character!
    var characterLevel: CGFloat = 210//boat 239
    var divingSpeed: CGFloat = 0
    var defaultDivingSpeed: CGFloat = 5
    var isCatching: Bool = false
    
    //Fish
    var prevPosition: CGFloat = 500
    var nextPosition: CGFloat!

    var minFishLevel: CGFloat = 40
    var middleBottomBorder: CGFloat = 70
    var topMiddleBorder: CGFloat = 150
    var maxFishLevel: CGFloat = 190

    var fishArray: [CCSprite!] = []
    
    func didLoadFromCCB() {
        gamePhysicsNode.collisionDelegate = self
        character.position.y = characterLevel
        userInteractionEnabled = true
        waterArray.append(water1)
        waterArray.append(water2)
    }
    
    func topLevelFish() {
        let fish = CCBReader.load("Fish") as! Fish
        let randomY = fish.randomPositionY(min: topMiddleBorder, max: maxFishLevel)
        let randomX = CGFloat(50) + CGFloat(arc4random_uniform(150))
        nextPosition = prevPosition + randomX
        fish.position = ccp(nextPosition, randomY)
        prevPosition = fish.position.x // for the next fish
        gamePhysicsNode.addChild(fish)
        fishArray.append(fish)
    }
    
    func middleLevelFish() {
        let fish = CCBReader.load("Fish") as! Fish
        let randomY = fish.randomPositionY(min: middleBottomBorder, max: topMiddleBorder)
        let randomX = CGFloat(50) + CGFloat(arc4random_uniform(150))
        nextPosition = prevPosition + randomX
        fish.position = ccp(nextPosition, randomY)
        prevPosition = fish.position.x // for the next fish
        gamePhysicsNode.addChild(fish)
        fishArray.append(fish)
    }
    
    func bottomLevelFish() {
        let fish = CCBReader.load("Fish") as! Fish
        let randomY = fish.randomPositionY(min: minFishLevel, max: middleBottomBorder)
        let randomX = CGFloat(50) + CGFloat(arc4random_uniform(150))
        nextPosition = prevPosition + randomX
        fish.position = ccp(nextPosition, randomY)
        prevPosition = fish.position.x // for the next fish
        gamePhysicsNode.addChild(fish)
        fishArray.append(fish)

    }
    
    func spawnFish() {
        let random = arc4random_uniform(100)
        if random < 34 {
            topLevelFish()
        } else if random < 69 {
            middleLevelFish()
        } else {
            bottomLevelFish()
        }
    }
    
    // TODO: add to update method changing the position, and add to touchBegan.location the change of the vectors triggered in update method
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        if touch.locationInWorld().x <= screenSize.width / 2 {
            if character.position.y >= characterLevel {
                divingSpeed = 0
            } else {divingSpeed = defaultDivingSpeed}
        } else {
            if character.position.y <= minFishLevel {
                divingSpeed = 0
            } else {divingSpeed = -defaultDivingSpeed}
        }
    }
    
    override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        divingSpeed = 0
    }
    
    override func update(delta: CCTime) {
        let velocityY = clampf(Float(character.physicsBody.velocity.y), -Float(divingSpeed), Float(divingSpeed))
        
        if character.position.y <= minFishLevel {
            character.position.y = minFishLevel
            //character.physicsBody.velocity = ccp(0, divingSpeed)
        } else if character.position.y >= characterLevel {
            character.position.y = characterLevel
        }
        
        spawnFish()
        
        for fish in fishArray {
            if CGFloat(fish.position.x) < -fish.contentSize.width {
                fishArray.removeAtIndex(0)
            }
        }
        
        gamePhysicsNode.position.x -= scrollSpeed
        character.position.x += scrollSpeed
        if isCatching == false {
            character.position.y += divingSpeed
        } else {
            if character.position.y <= characterLevel {
                character.position.y += defaultDivingSpeed
            }
            }
        }
        
        //        for water in waterArray {
        //            water.position.x = water.position.x - scrollSpeed * CGFloat(delta)
        //            if water.position.x <= -water.contentSize.width {
        //                water.position.x += water.contentSize.width * 2
        //            }
        //        }
        
        //        for water in waterArray {
        //            let waterWorldPosition = gamePhysicsNode.convertToWorldSpace(water.position)
        //            let waterScreenPosition = convertToWorldSpace(waterWorldPosition)
        //            if waterScreenPosition.x < -water.contentSize.width {
        //                water.position = ccp(water.position.x + water.contentSize.width * 2, water.position.y)
        //            }
        //        }
        for water in waterArray {
            let waterWorldPosition = gamePhysicsNode.convertToWorldSpace(water.position)
            let waterScreenPosition = convertToNodeSpace(waterWorldPosition)
            if waterScreenPosition.x <= (-water.contentSize.width) {
                water.position = ccp(water.position.x + water.contentSize.width * 2, water.position.y)
            }
        }
        
        timeLeft -= Float(delta)
        if timeLeft <= 0 {
            gameOver()
        }
    }
    
    func restart() {
        let scene = CCBReader.loadAsScene("Gameplay")
        CCDirector.sharedDirector().presentScene(scene)
    }
    
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, fish: Fish!, character: Character!) -> Bool {
        fish.removeFromParent()
        timeLeft += 0.65
        points++
        scoreLabel.string = String(points)
        isCatching = true
        
        return true
    }
    
    func gameOver() {
        paused = true
        gameOverScreen.visible = true
        yourScore.string = scoreLabel.string
        if points > GameStatistics.bestPoints {
            GameStatistics.bestPoints = points
        }
        bestScore.string = String(GameStatistics.bestPoints)
        
        scoreLabel.visible = false
    }
}

