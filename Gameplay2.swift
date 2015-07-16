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
    var prevTopPosition: CGFloat = 500
    var nextTopPosition: CGFloat!

    var prevMiddlePosition: CGFloat = 500
    var nextMiddlePosition: CGFloat!
    
        //middle fish grid
    
    var numberOfRows = 10
    var numberOfEmptyRows = 4
    var minimumDistanceBetweenFishes = 10
    var chanceOfTwoFishInARow = 0.3

    var prevBottomPosition: CGFloat = 500
    var nextBottomPosition: CGFloat!
    
    var minFishLevel: CGFloat = 40
    var middleBottomBorder: CGFloat = 70
    var centerBorder: CGFloat = 125
    var topMiddleBorder: CGFloat = 180
    var maxFishLevel: CGFloat = 190
    var fishArray: [CCSprite!] = []
    
    func didLoadFromCCB() {
        gamePhysicsNode.collisionDelegate = self
        character.position.y = characterLevel
        userInteractionEnabled = true
        waterArray.append(water1)
        waterArray.append(water2)
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
    
    func topLevelFish() {
        let fish = CCBReader.load("FishTop") as! FishTop
        let randomY = fish.randomPositionY(min: topMiddleBorder + 5, max: maxFishLevel)
        let randomX = CGFloat(45) + CGFloat(arc4random_uniform(150))
        nextTopPosition = prevTopPosition + randomX
        fish.position = ccp(nextTopPosition, randomY)
        prevTopPosition = fish.position.x // for the next fish
        fish.points = 5
        fish.scale = 0.5
        gamePhysicsNode.addChild(fish)
        fishArray.append(fish)
    }
    
    func middleLevelFish() {
        let fish = CCBReader.load("FishMiddle") as! FishMiddle
        let randomY = fish.randomPositionY(min: centerBorder, max: topMiddleBorder)
        let randomX = CGFloat(50) + CGFloat(arc4random_uniform(125))
        nextMiddlePosition = prevMiddlePosition + randomX
        fish.position = ccp(nextMiddlePosition, randomY)
        prevMiddlePosition = fish.position.x // for the next fish
        fish.points = 10
        fish.scale = 0.7
        gamePhysicsNode.addChild(fish)
        fishArray.append(fish)
        
        let fish2 = CCBReader.load("FishMiddle") as! FishMiddle
        let randomY2 = fish2.randomPositionY(min: middleBottomBorder, max: centerBorder)
//        let randomX2 = randomX
//        nextMiddlePosition = prevMiddlePosition + randomX2
        fish2.position = ccp(fish.position.x, randomY2)
//        prevMiddlePosition = fish2.position.x // for the next fish
        fish2.points = 10
        fish2.scale = 0.7
        gamePhysicsNode.addChild(fish2)
        fishArray.append(fish2)
    }
    
    func bottomLevelFish() {
        let fish = CCBReader.load("FishBottom") as! FishBottom
        let randomY = fish.randomPositionY(min: minFishLevel, max: middleBottomBorder - 5)
        let randomX = CGFloat(200) + CGFloat(arc4random_uniform(20))
        nextBottomPosition = prevBottomPosition + randomX
        fish.position = ccp(nextBottomPosition, randomY)
        prevBottomPosition = fish.position.x // for the next fish
        fish.points = 50
        fish.scale = 0.7
        gamePhysicsNode.addChild(fish)
        fishArray.append(fish)

    }
    

    
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
                character.position.y += defaultDivingSpeed // return to initial stage
            }
        }
        
        if character.position.y >= characterLevel {
            isCatching = false
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
        
//        timeLeft -= Float(delta / 2)
        if timeLeft <= 0 {
            gameOver()
        }
    }
    
    func restart() {
        let scene = CCBReader.loadAsScene("Gameplay")
        CCDirector.sharedDirector().presentScene(scene)
    }
    
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, fishTop: Fish!, character: Character!) -> Bool {
        fishTop.removeFromParent()
        let bonusTime: Float = Float(fishTop.points/CGFloat(60)) // 25 points - 2.5 minute
        timeLeft += bonusTime
        points += NSInteger(fishTop.points)
        scoreLabel.string = String(points)
        isCatching = true
        
        return true
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, fishMiddle: Fish!, character: Character!) -> Bool {
        fishMiddle.removeFromParent()
        let bonusTime: Float = Float(fishMiddle.points/CGFloat(60)) // 25 points - 2.5 minute
        timeLeft += bonusTime
        points += NSInteger(fishMiddle.points)
        scoreLabel.string = String(points)
        isCatching = true
        
        return true
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, fishBottom: Fish!, character: Character!) -> Bool {
        fishBottom.removeFromParent()
        let bonusTime: Float = Float(fishBottom.points/CGFloat(60)) // 25 points - 2.5 minute
        timeLeft += bonusTime
        points += NSInteger(fishBottom.points)
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

