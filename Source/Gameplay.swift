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
//    var timeConst: CGFloat = 1
//    
//    
//    //Environment
//    weak var water1: CCNodeGradient!
//    weak var water2: CCNodeGradient!
//    var waterArray: [CCNodeGradient!] = []
//    
//    //Physics
//    weak var gamePhysicsNode: CCPhysicsNode!
//    var scrollSpeed: CGFloat = 5
//    
//    //Character
//    weak var character: Character!
//    var characterLevel: CGFloat = 260//boat 239
//    var divingSpeed: CGFloat = 0
//    var defaultDivingSpeed: CGFloat = 5
//    var defaultDivingSpeedUP: CGFloat = 7
//    
//    var isCatching: Bool = false
//    
//    //Fish
//    var prevTopPosition: CGFloat = 100
//    var nextTopPosition: CGFloat!
//    
//    var prevMiddlePosition: CGFloat = 100
//    var nextMiddlePosition: CGFloat!
//    
//    var prevBottomPosition: CGFloat = 100
//    var nextBottomPosition: CGFloat!
//    
//    //middle fish grid
//    
//    var numberOfRows: CGFloat!
//    var rowSize: CGFloat!
//    var middleArea: CGFloat!
//    var numberOfEmptyRows = 4
//    var minimumDistanceBetweenFishesY: CGFloat!
//    
//    var chanceOfTwoFishInARow = 0.3
//    
//    var minFishLevel: CGFloat = 10
//    var middleBottomBorder: CGFloat = 30
//    var topMiddleBorder: CGFloat = 240
//    var maxFishLevel: CGFloat = 250
//    var fishArray: [CCNode!] = []
//    
//    //    TODO:
//    var newObjectAllowance: CGFloat = 300
//    
//    
//    func didLoadFromCCB() {
//        gamePhysicsNode.collisionDelegate = self
//        character.position.y = characterLevel
//        userInteractionEnabled = true
//        waterArray.append(water1)
//        waterArray.append(water2)
//        
//        minimumDistanceBetweenFishesY = character.contentSize.height * 0.5
//        
//        var middleFish = CCBReader.load("FishMiddle") as! FishMiddle
//        rowSize = middleFish.contentSize.height + minimumDistanceBetweenFishesY
//        middleArea = topMiddleBorder - middleBottomBorder
//        numberOfRows = round(middleArea / rowSize) // middle area divided for number of even rows based on number of fish.height and distance b/w fishes
//        
//        //        newObjectAllowance = numberOfRows * 20
//    }
//    
//    func spawnFish() {
//        if fishArray.count < 1000 {
//            topLevelFish()
//            middleLevelFish()
//            bottomLevelFish()
//            newObjectAllowance -= 1
//        }
//    }
//    
//    func topLevelFish() {
//        let fish = CCBReader.load("FishTop") as! FishTop
//        let randomX = CGFloat(45) + CGFloat(arc4random_uniform(150))
//        nextTopPosition = prevTopPosition + randomX
//        fish.position = ccp(nextTopPosition, maxFishLevel - 5)
//        prevTopPosition = fish.position.x // for the next fish
//        fish.points = 1
//        gamePhysicsNode.addChild(fish)
//        fishArray.append(fish)
//    }
//    
//    func middleLevelFish() {
//        for fishRow in 1...Int(numberOfRows) {
//            var visibleChance = arc4random_uniform(100)
//            if visibleChance < 40 {
//                let fish = CCBReader.load("FishMiddle") as! FishMiddle
//                fish.position.y = topMiddleBorder - (rowSize * CGFloat(fishRow))
//                fish.position.x = prevMiddlePosition
//                fish.points = 5
//                
//                gamePhysicsNode.addChild(fish)
//                fishArray.append(fish)
//            }
//        }
//        prevMiddlePosition += (50 + CGFloat(arc4random_uniform(25)))
//    }
//    
//    func bottomLevelFish() {
//        let fish = CCBReader.load("FishBottom") as! FishBottom
//        let randomX = CGFloat(150) + CGFloat(arc4random_uniform(20))
//        nextBottomPosition = prevBottomPosition + randomX
//        fish.position = ccp(nextBottomPosition, minFishLevel + 5)
//        prevBottomPosition = fish.position.x // for the next fish
//        fish.points = 225
//        gamePhysicsNode.addChild(fish)
//        fishArray.append(fish)
//        
//    }
//    
//    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
//        let screenSize: CGRect = UIScreen.mainScreen().bounds
//        if touch.locationInWorld().x <= screenSize.width / 2 {
//            if character.position.y >= characterLevel {
//                divingSpeed = 0
//            } else {divingSpeed = defaultDivingSpeed}
//        } else {
//            if character.position.y <= minFishLevel {
//                divingSpeed = 0
//            } else {divingSpeed = -defaultDivingSpeed}
//        }
//    }
//    
//    override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!) {
//        divingSpeed = 0
//    }
//    
//    override func update(delta: CCTime) {
//        let velocityY = clampf(Float(character.physicsBody.velocity.y), -Float(divingSpeed), Float(divingSpeed))
//        
//        if character.position.y <= minFishLevel {
//            character.position.y = minFishLevel
//            //character.physicsBody.velocity = ccp(0, divingSpeed)
//        } else if character.position.y >= characterLevel {
//            character.position.y = characterLevel
//        }
//        
//        //        TODO:
//        
////        timeLeft -= Float(delta / 2)
////        if timeLeft >= 0 {
////            spawnFish()
////        }
//        
//        
//        
//        if fishArray.count < 100 {
//            println(fishArray.count)
//        }
//        spawnFish()
//
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
//        
//        if isCatching == false {
//            character.position.y += divingSpeed
//        } else {
//            if character.position.y <= characterLevel {
//                character.position.y += defaultDivingSpeedUP // return to initial stage
//            }
//        }
//        
//        if character.position.y >= characterLevel {
//            isCatching = false
//        }
//        
//        
//        
//        //        for water in waterArray {
//        //            water.position.x = water.position.x - scrollSpeed * CGFloat(delta)
//        //            if water.position.x <= -water.contentSize.width {
//        //                water.position.x += water.contentSize.width * 2
//        //            }
//        //        }
//        
//        //        for water in waterArray {
//        //            let waterWorldPosition = gamePhysicsNode.convertToWorldSpace(water.position)
//        //            let waterScreenPosition = convertToWorldSpace(waterWorldPosition)
//        //            if waterScreenPosition.x < -water.contentSize.width {
//        //                water.position = ccp(water.position.x + water.contentSize.width * 2, water.position.y)
//        //            }
//        //        }
//        for water in waterArray {
//            let waterWorldPosition = gamePhysicsNode.convertToWorldSpace(water.position)
//            let waterScreenPosition = convertToNodeSpace(waterWorldPosition)
//            if waterScreenPosition.x <= (-water.contentSize.width) {
//                water.position = ccp(water.position.x + water.contentSize.width * 2, water.position.y)
//            }
//        }
//        
//        for fish in fishArray {
//            let fishWorldPosition = gamePhysicsNode.convertToWorldSpace(fish.position)
//            let fishScreenPosition = convertToNodeSpace(fishWorldPosition)
//            if fishScreenPosition.x <= (-fish.contentSize.width) {
//                fish.removeFromParent()
//            }
//        }
//        
//        timeLeft -= Float(delta / 2)
//        if timeLeft <= 0 {
//            gameOver()
//        }
//    }
//    
//    func restart() {
//        let scene = CCBReader.loadAsScene("Gameplay")
//        CCDirector.sharedDirector().presentScene(scene)
//    }
//    
//    func share() {
//        
//    }
//    
//    
//    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, fishTop: Fish!, character: Character!) -> Bool {
//        fishTop.removeFromParent()
//        let bonusTime: Float = Float(fishTop.points/CGFloat(60)) // 25 points - 2.5 minute
//        timeLeft += bonusTime
//        points += NSInteger(fishTop.points)
//        scoreLabel.string = String(points)
//        isCatching = true
//        
//        return true
//    }
//    
//    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, fishMiddle: Fish!, character: Character!) -> Bool {
//        fishMiddle.removeFromParent()
//        let bonusTime: Float = Float(fishMiddle.points/CGFloat(60)) // 25 points - 2.5 minute
//        timeLeft += bonusTime
//        points += NSInteger(fishMiddle.points)
//        scoreLabel.string = String(points)
//        isCatching = true
//        newObjectAllowance++
//        return true
//    }
//    
//    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, fishBottom: Fish!, character: Character!) -> Bool {
//        let bonusTime: Float = Float(fishBottom.points/CGFloat(60)) // 25 points - 2.5 minute
//        timeLeft += bonusTime
//        points += NSInteger(fishBottom.points)
//        scoreLabel.string = String(points)
//        isCatching = true
//        fishBottom.removeFromParent()
//        newObjectAllowance++
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
//        newObjectAllowance++
//        scoreLabel.visible = false
//    }
//}
//
