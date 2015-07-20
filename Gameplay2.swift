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
//    //Environment
//    weak var water1: CCNodeGradient!
//    weak var water2: CCNodeGradient!
//    var waterArray: [CCNodeGradient!] = []
//    
//    //Physics
//    weak var gamePhysicsNode: CCPhysicsNode!
//    var scrollSpeed: CGFloat = 3
//    
//    //Character
//    weak var character: Character!
//    var characterLevel: CGFloat = 260//boat 239
//    var divingSpeed: CGFloat = 0
//    var defaultDivingSpeed: CGFloat = 5
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
//        //middle fish grid
//    
//    var screenSize: CGRect!
//    
//    var numberOfColumns: CGFloat!
//    var columnSize: CGFloat!
//    var middleAreaX: CGFloat!
//    var minimumDistanceBetweenFishesX: CGFloat!
//    
//    var numberOfRows: CGFloat!
//    var rowSize: CGFloat!
//    var middleAreaY: CGFloat!
//    var minimumDistanceBetweenFishesY: CGFloat!
//
//    var chanceOfTwoFishInARow = 0.3
//
//    var minFishLevel: CGFloat = 10
//    var middleBottomBorder: CGFloat = 30
//    var topMiddleBorder: CGFloat = 240
//    var maxFishLevel: CGFloat = 250
//    var fishArrayT: [CCNode!] = []
//    var fishArrayM: [CCNode!] = []
//    var fishArrayB: [CCNode!] = []
//    
//    var topFish: FishTop!
//    var middleFish: FishMiddle!
//    var bottomFish: FishBottom!
//    
//    func didLoadFromCCB() {
//        gamePhysicsNode.collisionDelegate = self
//        character.position.y = characterLevel
//        userInteractionEnabled = true
//        waterArray.append(water1)
//        waterArray.append(water2)
//
//        minimumDistanceBetweenFishesY = character.contentSize.height * 0.5
//        minimumDistanceBetweenFishesX = 50
//
//        topFish = CCBReader.load("FishTop") as! FishTop
//        middleFish = CCBReader.load("FishMiddle") as! FishMiddle
//        bottomFish = CCBReader.load("FishBottom") as! FishBottom
//        
//        rowSize = middleFish.contentSize.height + minimumDistanceBetweenFishesY
//        middleAreaY = topMiddleBorder - middleBottomBorder
//        numberOfRows = round(middleAreaY / rowSize) // middle area divided for number of equal rows based on number of fish.height and distance b/w fishes
//        
//        screenSize = UIScreen.mainScreen().bounds
//        
//        columnSize = middleFish.contentSize.width + minimumDistanceBetweenFishesX
//        middleAreaX = middleFish.contentSize.width + screenSize.width
//        numberOfColumns = round(middleAreaX / columnSize) // middle area divided for number of equal columns based on number of fish.width and distance b/w fishes
//        
//        println(columnSize)
//        println(middleAreaX)
//        println(numberOfColumns)
//        println(numberOfRows)
//        
//        topLevelFish()
//        middleLevelFish()
//        bottomLevelFish()
//        
//    }
//    
////    TODO - re-spawning distance
//    
//    func topLevelFish() {
//        for fishColumn in 1...Int(numberOfColumns) {
//        let fish = CCBReader.load("FishTop") as! FishTop
//            fish.position.y = maxFishLevel - 5
//            fish.position.x = fish.contentSize.width + minimumDistanceBetweenFishesX + (columnSize * CGFloat(fishColumn))
//            fish.points = 5
//            gamePhysicsNode.addChild(fish)
//            fishArrayT.append(fish)
//        }
//    }
//    
//    func middleLevelFish() {
//        for fishColumn in 1...Int(numberOfColumns) {
//            for fishRow in 1...Int(numberOfRows) {
//                let fish = CCBReader.load("FishMiddle") as! FishMiddle
//                fish.position.y = topMiddleBorder - (rowSize * CGFloat(fishRow))
//                fish.position.x = fish.contentSize.width + minimumDistanceBetweenFishesX + (columnSize * CGFloat(fishColumn))
//                fish.points = 10
//                gamePhysicsNode.addChild(fish)
//                fishArrayM.append(fish)
//            }
//        }
//    }
//    
//    func bottomLevelFish() {
//        for fishColumn in 1...Int(numberOfColumns) {
//            let fish = CCBReader.load("FishBottom") as! FishBottom
//            fish.position.y = minFishLevel + 5
//            fish.position.x = fish.contentSize.width + minimumDistanceBetweenFishesX + (columnSize * CGFloat(fishColumn))
//            fish.points = 50
//            gamePhysicsNode.addChild(fish)
//            fishArrayB.append(fish)
//        }
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
//        gamePhysicsNode.position.x -= scrollSpeed
//        character.position.x += scrollSpeed
//        
//        if isCatching == false {
//            character.position.y += divingSpeed
//        } else {
//            if character.position.y <= characterLevel {
//                character.position.y += defaultDivingSpeed // return to initial stage
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
//        println(fishArrayM.count)
//        
//        for fish in fishArrayT {
//            let fishWorldPosition = gamePhysicsNode.convertToWorldSpace(fish.position)
//            let fishScreenPosition = convertToNodeSpace(fishWorldPosition)
//            if fishScreenPosition.x <= (-fish.contentSize.width) {
//                fish.position = ccp(fish.position.x + screenSize.width, fish.position.y)
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
//        scoreLabel.visible = false
//    }
//}
//
